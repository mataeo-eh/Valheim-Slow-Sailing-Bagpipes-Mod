using SailingBagpipes;

// Test doubles model Valheim's verified public boarding API; no Unity runtime is
// available here. Real trigger boundaries/network ownership require the in-game matrix.
var local = new Player();
var remote = new Player();
var boatA = new Ship();
var boatB = new Ship();
void Check(string scenario, Ship? expected)
{
    var actual = OnboardShipResolver.Resolve(local, out _);
    if (!ReferenceEquals(expected, actual)) throw new Exception(scenario);
    Console.WriteLine("PASS: " + scenario);
}

Check("ashore with no boat", null);
boatA.Players.Add(remote);
Ship.LocalShip = boatA;
Check("another player aboard does not enable local music", null);
boatA.Players.Add(local);
Check("standing passenger without a controller", boatA);
local.ControlledShip = boatA;
Check("helmsman aboard", boatA);
local.ControlledShip = null;
Check("releasing the rudder keeps passenger eligibility", boatA);
boatA.Players.Remove(local);
Check("stale local ship after disembarking", null);
local.ControlledShip = boatA;
Check("stale controller after disembarking", null);
boatB.Players.Add(local);
Ship.LocalShip = boatB;
Check("actual boarding beats a stale controller on another boat", boatB);
local.ControlledShip = boatB;
Ship.LocalShip = boatA;
Check("valid controlled boat wins when boarding volumes overlap", boatB);
local.ControlledShip = null;
Ship.LocalShip = boatB;
Check("passenger on a second boat resolves only that boat", boatB);
boatB.Players.Clear();
Ship.LocalShip = null;
Check("leaving the second boat clears eligibility", null);

internal sealed class Player
{
    internal Ship? ControlledShip;
    public Ship? GetControlledShip() => ControlledShip;
}

internal sealed class Ship
{
    internal static Ship? LocalShip;
    internal readonly HashSet<Player> Players = new();
    public static Ship? GetLocalShip() => LocalShip;
    public bool IsPlayerInBoat(Player player) => Players.Contains(player);
}
