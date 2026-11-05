namespace SailingBagpipes;

internal static class OnboardShipResolver
{
    internal static Ship? Resolve(Player player, out string source)
    {
        // Never require local control or network ownership: passengers need music too.
        // Require onboard membership rather than guessing from distance to a boat.
        var controlledShip = player.GetControlledShip();
        if (controlledShip != null && controlledShip.IsPlayerInBoat(player))
        {
            source = "Player.GetControlledShip";
            return controlledShip;
        }

        // Valheim maintains this list using local boarding triggers, including standing
        // passengers and seated players. Reject stale entries after disembarking.
        var onboardShip = Ship.GetLocalShip();
        if (onboardShip != null && onboardShip.IsPlayerInBoat(player))
        {
            source = "Ship.GetLocalShip (onboard)";
            return onboardShip;
        }

        source = "None";
        return null;
    }
}
