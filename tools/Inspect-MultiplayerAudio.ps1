[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ManagedDir,
    [Parameter(Mandatory)][string]$CecilPath,
    [Parameter(Mandatory)][string]$OutputPath
)
$ErrorActionPreference = 'Stop'
Add-Type -Path $CecilPath

function Get-AllTypes($Module) {
    $queue = [Collections.Generic.Queue[object]]::new()
    foreach ($type in $Module.Types) { $queue.Enqueue($type) }
    while ($queue.Count) {
        $type = $queue.Dequeue()
        $type
        foreach ($nested in $type.NestedTypes) { $queue.Enqueue($nested) }
    }
}

$registrations = [Collections.Generic.List[object]]::new()
$capabilityCalls = [Collections.Generic.List[object]]::new()
$evidence = [Collections.Generic.List[object]]::new()
$assemblies = [Collections.Generic.List[object]]::new()
$selected = @{
    MusicVolume = @('Awake', 'RPC_PlayMusic', 'PlayMusic')
    MusicMan = @('FindMusic', 'StartMusic')
    MusicLocation = @('Awake', 'SetPlayed')
    ZNetScene = @('GetPrefab', 'RPC_SpawnObject')
    ZRoutedRpc = @('HandleRoutedRPC')
    ZNetView = @('HandleRoutedRPC')
    ZRpc = @('HandlePackage')
    ZNet = @('RPC_RemoteCommand', 'InternalCommand')
    Ship = @('GetLocalShip', 'IsPlayerInBoat', 'UpdateControlls', 'OnTriggerEnter', 'OnTriggerExit')
    ZSFX = @('Play')
}

foreach ($name in @('assembly_valheim', 'assembly_utils', 'SoftReferenceableAssets', 'Splatform')) {
    $path = Join-Path $ManagedDir "$name.dll"
    $assembly = [Mono.Cecil.AssemblyDefinition]::ReadAssembly($path)
    try {
        $assemblies.Add([pscustomobject]@{ Name = $name; SHA256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash })
        foreach ($type in @(Get-AllTypes $assembly.MainModule)) {
            foreach ($method in $type.Methods) {
                if (!$method.HasBody) { continue }
                $ops = @($method.Body.Instructions)
                for ($i = 0; $i -lt $ops.Count; $i++) {
                    $operand = $ops[$i].Operand
                    if ($operand -isnot [Mono.Cecil.MethodReference]) { continue }
                    if ($operand.DeclaringType.Name -in @('ZRpc', 'ZRoutedRpc', 'ZNetView') -and $operand.Name -eq 'Register') {
                        $preceding = @($ops | Select-Object -First $i | Select-Object -Last 16)
                        $registrations.Add([pscustomobject]@{
                            Assembly = $name; Site = $method.FullName; Offset = $ops[$i].Offset
                            Name = (@($preceding | Where-Object { $_.OpCode.Name -eq 'ldstr' } | Select-Object -Last 1).Operand -join '')
                            Handler = (@($preceding | Where-Object { $_.OpCode.Name -eq 'ldftn' } | Select-Object -Last 1).Operand.FullName -join '')
                        })
                    }
                    if ($operand.FullName -match 'AudioClip::(Create|SetData)|GetAudioClip|DownloadHandler|AssetBundle::LoadFrom|VideoPlayer::|Application::OpenURL|Reflection.Assembly::Load|SteamUser::.*Voice|Party.*(Voice|ChatControl)|Runtime::AddManifest') {
                        $capabilityCalls.Add([pscustomobject]@{ Assembly = $name; Method = $method.FullName; Call = $operand.FullName })
                    }
                }
                if ($name -eq 'assembly_valheim' -and $selected.ContainsKey($type.FullName) -and $method.Name -in $selected[$type.FullName]) {
                    $evidence.Add([pscustomobject]@{
                        Method = $method.FullName
                        Instructions = @($ops | ForEach-Object ToString)
                    })
                }
            }
        }
    } finally { $assembly.Dispose() }
}

# Generated IL is for local review; keep it outside tracked source/package directories.
[pscustomobject]@{
    Assemblies = @($assemblies.ToArray())
    RegistrationSites = @($registrations.ToArray())
    CapabilityCalls = @($capabilityCalls.ToArray())
    Evidence = @($evidence.ToArray())
} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Output "Inspected $($assemblies.Count) assemblies; $($registrations.Count) RPC registration sites. Wrote local evidence report."
