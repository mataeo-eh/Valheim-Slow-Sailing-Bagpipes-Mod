# Automated Releases to Thunderstore and Nexus Mods

This repo can publish a release to both platforms with one command:

```powershell
.\release.ps1 -DryRun   # build, package, verify - publishes nothing
.\release.ps1           # the real thing
```

**Always run `-DryRun` first.** Thunderstore package versions are immutable: once `1.0.6` is
published it can never be replaced or deleted, only superseded by `1.0.7`.

---

## How the version stays consistent

The repo-root **`VERSION`** file is the single source of truth. Nothing else authors a version
number:

| Consumer | How it gets the version |
|----------|-------------------------|
| The compiled DLL (`[BepInPlugin]`, `AssemblyVersion`) | `SlowSailingBagpipes.csproj` reads `VERSION` at build time and generates `GeneratedModVersion.cs` into `obj/` |
| `dist/thunderstore/manifest.json` | `package_thunderstore.bat` stamps it via `tools/Set-ManifestVersion.ps1` |
| Package zip filenames | both `package_*.bat` read `VERSION` |
| Thunderstore publish | `release.ps1` passes `--package-version` |
| Nexus upload | `release.ps1` sets `INPUT_VERSION` |

`release.ps1` then *verifies* rather than trusts: after building it reads the version back out
of the compiled assembly with Mono.Cecil and aborts if it does not equal `VERSION`, and it
hashes the staged DLLs against the freshly built one before publishing.

To cut a release: edit `VERSION`, update `CHANGELOG.md`, commit, run `.\release.ps1`.

---

## Configuration layout

| File | Contents | Committed? |
|------|----------|-----------|
| `VERSION` | just the version, e.g. `1.0.6` | yes |
| `release.config.json` | namespace, Nexus mod/file IDs, pinned tool tag | yes |
| `thunderstore.toml` | publish routing (repository + community) | yes |
| `.env` | `TCLI_AUTH_TOKEN`, `NEXUSMODS_API_KEY` | **no - gitignored** |

`release.ps1` loads `.env` itself, so no shell setup is needed. It prints only the *names* of
the variables it loaded, never the values.

### Verify `.env` stays out of git

```bash
git check-ignore -v .env        # should print the matching .gitignore rule
git log --all -- .env           # should print nothing
```

Both currently pass. If you ever rotate tokens, only `.env` changes.

---

## What the pipeline does

1. Load `.env`, validate both tokens are present
2. Read and validate `VERSION` (must be `MAJOR.MINOR.PATCH`)
3. Preflight: clean git tree, version is greater than the published Thunderstore latest,
   required tooling on PATH
4. `dotnet build -c Release`
5. **Verify** the built DLL's `[BepInPlugin]` version equals `VERSION`
6. Run both packaging scripts
7. **Verify** staged DLLs hash-match the build and `manifest.json` agrees
8. Publish to Thunderstore (`tcli publish --file`)
9. Upload a new version to Nexus

Steps 8 and 9 are the only irreversible ones; `-DryRun` stops after 7.

Flags: `-DryRun`, `-SkipThunderstore`, `-SkipNexus` (useful if one platform succeeded and the
other failed), `-AllowDirtyTree`.

---

## Thunderstore

Fully automatable. Uses the official CLI:

```bash
dotnet tool install -g tcli
```

Token comes from your Thunderstore **Team page → Service Accounts → Add Service Account**.
Store it in `.env` as `TCLI_AUTH_TOKEN`.

`release.ps1` publishes the prebuilt zip produced by `package_thunderstore.bat`, so the zip's
own `manifest.json` remains the source of truth for description and dependencies.
`thunderstore.toml` deliberately does **not** duplicate those — it only says where to publish.

Package: `Therunner/SlowSailingBagpipes` in the `valheim` community.

---

## Nexus Mods

Partially automatable, with a real constraint.

The Upload API entered open beta on 2026-03-17. There is no official CLI, and the upload is a
multipart presigned-URL flow (create multipart upload → upload parts → complete → finalise →
poll). Rather than reimplement that, `release.ps1` runs Nexus's own published GitHub Action
locally via `node`: the action is driven entirely by `INPUT_*` environment variables, so it
works outside GitHub Actions. It is cloned at the tag pinned in `release.config.json`
(`uploadActionTag`) into `.release-tools/` and cached.

### The constraint

**The API can only add a new version to a file that already exists.** It cannot create a mod
page or a new file entry. If you ever start a *new* mod, the page and its first file must be
created through the website once; everything after that automates.

### The v1 / v3 ID trap (this cost a failed run)

**Nexus v1 and v3 use different ID namespaces, and the Upload API is v3.** Feeding it v1 IDs
fails with a badly misleading error:

```
403 - "You do not have permission to upload files to this mod."
```

That is an ID resolution failure, not a permissions problem. The IDs you get from the mod page
URL and from the v1 API are *not* the ones this API wants:

| Meaning | Value | Where it comes from |
|---------|-------|---------------------|
| Game-scoped id (mod page URL) | `3349` | `nexusmods.com/valheim/mods/3349` — **links only, never API calls** |
| v3 mod id | `15749645077781` | `GET /v3/games/valheim/mods/3349` → `data.id` |
| v3 mod_file id | `7418183` | `GET /v3/mods/15749645077781/files` → `data.mod_files[].id` |

Note the v1 API reports `file_id` 20598 and 20599 as two separate *files*; in v3 they are two
*versions* of the single mod_file `7418183`. `release.config.json` records all three values
with the exact calls needed to rediscover them.

### The action leaks your API key when run locally

`@actions/core` always writes `::debug::` lines to stdout and relies on the GitHub Actions
runner to decide whether to display them. Run outside GitHub there is no such filter, so the
action prints its full request headers — **including the API key** — on every call.

`release.ps1` filters those lines out and redacts the key from anything else the action emits.
If you ever run the action directly rather than through `release.ps1`, pipe its output through
a filter or expect your key in the logs.

Requires Node 20+ (24 is what this was tested against) and `NEXUSMODS_API_KEY` in `.env`.

### Stability caveat

This is a beta API. The action tag is pinned on purpose — bump it deliberately, not
automatically. Nexus's GraphQL API carries an explicit warning that existing features "may
change or disappear without warning."

---

## Gotchas already hit and handled

These are baked into the scripts; listed so a future change does not undo them.

- **`tcli publish --file` is mutually exclusive** with `--package-name`, `--package-namespace`
  and `--package-version`. With a prebuilt zip, identity comes from `thunderstore.toml` plus
  the zip's own `manifest.json`, so `release.ps1` stamps the toml's `versionNumber` instead of
  passing a flag.
- **Thunderstore's package API is cached.** After publishing, `api/experimental/package/...`
  can still report the previous version for a while. The package page is authoritative; a
  duplicate publish attempt returning "Package of the same namespace, name and version already
  exists" also confirms success.
- **Windows PowerShell 5.1 writes a UTF-8 BOM** with `Set-Content -Encoding utf8`, which
  Thunderstore's manifest parser can reject. `tools/Set-ManifestVersion.ps1` writes UTF-8
  without a BOM explicitly.
- **Nexus boolean inputs**: `archive_existing_version` is read with `getBooleanInput` and has
  no default outside GitHub Actions, so it must always be set to a literal `true`/`false`.

---

## If a release half-fails

The two publishes are independent and happen in order. If Thunderstore succeeds and Nexus
fails, **do not re-run the whole script** — Thunderstore will reject the duplicate version.
Instead:

```powershell
.\release.ps1 -SkipThunderstore
```

and vice versa with `-SkipNexus`.

---

## Sources

- [thunderstore-io/thunderstore-cli](https://github.com/thunderstore-io/thunderstore-cli)
- [Getting a Thunderstore API token](https://github.com/Kesomannen/gale/wiki/Getting-a-Thunderstore-API-token)
- [Nexus-Mods/upload-action](https://github.com/Nexus-Mods/upload-action)
- [Nexus Mods: Upload API Open Beta Now Live](https://www.nexusmods.com/news/15454)
- [Nexus Mods GraphQL API](https://graphql.nexusmods.com/)
