# Workspace commands

This repository now lives at Valheim_Mods/mods/SlowSailingBagpipes. Its Git history and remote are unchanged. Shared build, deploy, packaging and release automation lives in ../../scripts; private credentials and caches live in the parent. Packaging metadata lives in packaging/ and generated output in ../../dist/SlowSailingBagpipes/.

From Valheim_Mods, use:

```powershell
.\scripts\build.ps1 -Mod SlowSailingBagpipes
.\scripts\deploy.ps1 -Mod SlowSailingBagpipes
.\scripts\package.ps1 -Mod SlowSailingBagpipes
.\scripts\release.ps1 -Mod SlowSailingBagpipes -DryRun
```

These commands supersede the old batch scripts and release instructions in historical docs. Direct dotnet builds remain supported. Deployment defaults to an existing Test_Mods profile; create it first or supply -ProfileDir. No shared scripts are tracked in this repository.
