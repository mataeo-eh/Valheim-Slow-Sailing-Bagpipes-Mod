# Automating Releases to Thunderstore and Nexus Mods

Research notes and a concrete plan for letting a script (or a coding agent) push a new build
to both platforms deterministically.

**Short version:** Thunderstore is fully automatable, including publishing brand-new versions.
Nexus Mods is *partially* automatable — the Upload API (open beta since March 2026) can push a
new file to a mod page that already exists, but it cannot create a new mod page. So the ideal
end state is: one command publishes to Thunderstore outright and uploads a new version to an
existing Nexus mod page.

---

## Blocker to fix first: the version number lives in four places

Right now `1.0.6` is written independently in:

| File | Form |
|------|------|
| `src/SlowSailingBagpipes/Plugin.cs` | `private const string PluginVersion = "1.0.6";` |
| `dist/thunderstore/manifest.json` | `"version_number": "1.0.6"` |
| `package_thunderstore.bat` | `set "VERSION=1.0.6"` |
| `package_nexus.bat` | `set "VERSION=1.0.6"` |

Any automation built on top of this is only as deterministic as the human who remembered to
update all four. **Single-source the version before wiring up publishing.** Recommended: a
`VERSION` file at the repo root, read by the build and stamped into the other three at package
time. This is a prerequisite, not a nice-to-have — a mismatch between `PluginVersion` and
`manifest.json` is exactly the kind of error that produces a silently broken Thunderstore
listing.

---

## Thunderstore — fully automatable

Thunderstore's official CLI is [`tcli`](https://github.com/thunderstore-io/thunderstore-cli).

### One-time setup

1. On Thunderstore, open your **Team** page → **Service Accounts** tab → **Add Service Account**.
2. Copy the API token it generates (shown once).
3. Store it as `TCLI_AUTH_TOKEN` — a GitHub repository secret for CI, or a local environment
   variable / secret manager entry for local runs. Do **not** put it in `thunderstore.toml`.

### Install

```bash
dotnet tool install -g tcli
```

The `dotnet tool` build covers package building and publishing, which is all this project
needs. (The standalone release additionally does mod installation/profile management.)

### Publishing

`tcli` can publish an already-built zip, which fits this repo well since
`package_thunderstore.bat` already produces a correctly structured archive:

```bash
tcli publish --file dist/SlowSailingBagpipes-Thunderstore-v1.0.6.zip
```

with `TCLI_AUTH_TOKEN` set in the environment. Configuration (namespace/team, package name,
communities, dependencies) lives in a `thunderstore.toml` at the repo root.

### GitHub Actions

Either call `tcli` directly, or use the community action
[`dhkatz/thunderstore-publish`](https://github.com/dhkatz/thunderstore-publish), which accepts
a prebuilt zip via its `file` input and takes the token as `token` (passed through to
`TCLI_AUTH_TOKEN` internally). Required inputs: `communities`, `namespace`, `name`, `version`,
`description`, `token`.

---

## Nexus Mods — partially automatable

Nexus opened its **Upload API** to public beta on 2026-03-17. There is an official GitHub
Action: [`Nexus-Mods/upload-action`](https://github.com/Nexus-Mods/upload-action), built on the
Nexus v3 API.

### One-time setup

1. Generate a personal API key from **API key settings** on your Nexus account.
2. Store it as a secret, e.g. `NEXUSMODS_API_KEY`.
3. Create the mod page and upload the first file **manually through the website** — this step
   cannot be automated.
4. Note the `file_id` of the existing file; the action versions that file.

### Usage

```yaml
- name: Upload to NexusMods
  uses: Nexus-Mods/upload-action@<tag>
  with:
    api_key: ${{ secrets.NEXUSMODS_API_KEY }}
    file_id: <file_id>
    filename: SlowSailingBagpipes-NexusMods-v1.0.6.zip
    version: 1.0.6
    category: main
```

Optional inputs cover `display_name`, `description`, `changelog`, archive settings and mod
manager configuration. The action outputs `version_id` for the newly uploaded version.

### Caveats worth knowing before relying on this

- **Update-only.** The action explicitly cannot create new mods. Initial publication of any
  *future* mod still needs the web UI once.
- **Beta surface.** Nexus also exposes a GraphQL API, but their own documentation warns that it
  is still in development and that "existing features may change or disappear without warning."
  Pin the action to a tag rather than tracking `main`, and expect to revisit this.

---

## Recommended end state

```
VERSION file  ──►  build  ──►  package_*.bat  ──►  ┬─ tcli publish            (Thunderstore)
                                                    └─ Nexus-Mods/upload-action (Nexus)
```

Sequence for a release:

1. Bump the single `VERSION` file.
2. Build + package (existing `.bat` scripts, with the version injected rather than hardcoded).
3. Publish to Thunderstore via `tcli`.
4. Upload to Nexus via the upload action.
5. Tag the git commit to match.

Steps 2–4 are safely automatable today. Step 1 needs the single-source refactor above. The only
genuinely manual, one-time-per-mod step is creating the Nexus mod page.

---

## Sources

- [thunderstore-io/thunderstore-cli](https://github.com/thunderstore-io/thunderstore-cli)
- [dhkatz/thunderstore-publish action](https://github.com/dhkatz/thunderstore-publish)
- [Getting a Thunderstore API token](https://github.com/Kesomannen/gale/wiki/Getting-a-Thunderstore-API-token)
- [Nexus-Mods/upload-action](https://github.com/Nexus-Mods/upload-action)
- [Nexus Mods: Upload API Open Beta Now Live](https://www.nexusmods.com/news/15454)
- [Nexus Mods GraphQL API](https://graphql.nexusmods.com/)
