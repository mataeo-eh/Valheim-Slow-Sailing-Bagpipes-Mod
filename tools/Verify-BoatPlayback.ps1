[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ManagedDir,
    [Parameter(Mandatory)][string]$CecilPath,
    [Parameter(Mandatory)][string]$PluginPath
)
$ErrorActionPreference = 'Stop'
Add-Type -Path $CecilPath
$game = [Mono.Cecil.AssemblyDefinition]::ReadAssembly((Join-Path $ManagedDir 'assembly_valheim.dll'))
$mod = [Mono.Cecil.AssemblyDefinition]::ReadAssembly($PluginPath)
function Assert-Check([bool]$Condition, [string]$Message) {
    if (!$Condition) { throw $Message }
    Write-Output "PASS: $Message"
}
try {
    $ship = $game.MainModule.Types | Where-Object FullName -EQ Ship
    $localShip = @($ship.Methods | Where-Object { $_.Name -eq 'GetLocalShip' -and $_.IsPublic -and $_.IsStatic -and $_.ReturnType.FullName -eq 'Ship' })
    $membership = @($ship.Methods | Where-Object { $_.Name -eq 'IsPlayerInBoat' -and $_.IsPublic -and $_.Parameters.Count -eq 1 -and $_.Parameters[0].ParameterType.FullName -eq 'Player' })
    Assert-Check ($localShip.Count -eq 1 -and $membership.Count -eq 1) 'current game exposes the exact passenger boarding APIs'
    $controls = ($ship.Methods | Where-Object Name -EQ UpdateControlls).Body.Instructions
    Assert-Check ([bool]($controls.Operand -match 'ZDOVars::s_forward') -and [bool]($controls.Operand -match 'ZDO::GetInt') -and [bool]($controls.Operand -match 'ZDO::Set')) 'vanilla ship speed has a replicated read/write path'

    $plugin = $mod.MainModule.Types | Where-Object FullName -EQ SailingBagpipes.Plugin
    $resolver = $mod.MainModule.Types | Where-Object FullName -EQ SailingBagpipes.OnboardShipResolver
    $resolveOps = ($resolver.Methods | Where-Object Name -EQ Resolve).Body.Instructions
    Assert-Check (@($resolveOps | Where-Object { [string]$_.Operand -eq 'System.Boolean Ship::IsPlayerInBoat(Player)' }).Count -eq 2) 'both helmsman and passenger paths validate local player membership'
    Assert-Check (@($resolveOps | Where-Object { [string]$_.Operand -eq 'Ship Ship::GetLocalShip()' }).Count -eq 1) 'passenger path uses vanilla local boarding state'

    $updateOps = ($plugin.Methods | Where-Object Name -EQ Update).Body.Instructions
    Assert-Check ([bool]($updateOps.Operand -match 'OnboardShipResolver::Resolve')) 'built plugin calls the tested passenger resolver'
    # ReferenceEquals is emitted as reference-comparison branches by Roslyn in Release.
    Assert-Check (@($updateOps | Where-Object { $_.OpCode.Name -like 'bne.un*' }).Count -gt 0 -and @($updateOps | Where-Object { $_.OpCode.Name -like 'beq*' }).Count -gt 0) 'player/ship context identity comparisons are present in Release IL'
    $resetOps = @((($plugin.Methods | Where-Object Name -EQ ResetPlaybackContext).Body.Instructions))
    $stop = $resetOps | Where-Object { [string]$_.Operand -eq 'System.Void SailingBagpipes.Plugin::StopBagpipes(System.Boolean)' }
    Assert-Check ($null -ne $stop -and $stop.Previous.OpCode.Name -eq 'ldc.i4.1') 'context reset stops playback immediately'
    foreach ($field in @('_resumeUntil', '_paddleTimer', '_lastEligibleRowingState', '_playbackPlayer', '_playbackShip')) {
        Assert-Check ([bool]($resetOps | Where-Object { $_.OpCode.Name -eq 'stfld' -and $_.Operand.Name -eq $field })) "context reset clears $field"
    }
    $stopCalls = ($plugin.Methods | Where-Object Name -EQ StopBagpipes).Body.Instructions.Operand
    Assert-Check ([bool]($stopCalls -match 'CancelPendingPlayback') -and [bool]($stopCalls -match 'CancelFade') -and [bool]($stopCalls -match 'SetGameMusicSuppressed')) 'stop path cancels loads/fades and restores local soundtrack'

    $queue = [Collections.Generic.Queue[object]]::new()
    foreach ($type in $mod.MainModule.Types) { $queue.Enqueue($type) }
    $networkCalls = 0
    while ($queue.Count) {
        $type = $queue.Dequeue()
        foreach ($nested in $type.NestedTypes) { $queue.Enqueue($nested) }
        foreach ($method in $type.Methods | Where-Object HasBody) {
            $networkCalls += @($method.Body.Instructions | Where-Object {
                $_.Operand -is [Mono.Cecil.MethodReference] -and $_.Operand.DeclaringType.Name -in @('ZRpc', 'ZRoutedRpc', 'ZNetView', 'ZDO', 'ZNetScene')
            }).Count
        }
    }
    Assert-Check ($networkCalls -eq 0) 'compiled plugin has no RPC, ZDO, network view or network prefab calls'
    Write-Output 'Static verification only; Unity audio/physics and mixed-client gameplay still require TESTING.md.'
} finally { $mod.Dispose(); $game.Dispose() }
