namespace DangerSnake.Items
{
    public enum ItemType
    {
        Shield = 0,
        Bomb = 1,
        Sword = 2,
        Boomerang = 3
    }

    public enum AttackOutcome
    {
        None,
        BlockedByShield,
        CutOne,
        CutHalf,
        Kill
    }

    public static class ItemEffect
    {
        public static AttackOutcome ResolveAppleAttack(ItemType item)
        {
            switch (item)
            {
                case ItemType.Bomb:
                    return AttackOutcome.CutHalf;
                case ItemType.Sword:
                    return AttackOutcome.Kill;
                case ItemType.Boomerang:
                    return AttackOutcome.CutOne;
                case ItemType.Shield:
                    // Shield on apple: contact still nips one cell if unshielded snake.
                    return AttackOutcome.CutOne;
                default:
                    return AttackOutcome.None;
            }
        }

        public static string DisplayName(ItemType type)
        {
            switch (type)
            {
                case ItemType.Shield: return "Shield";
                case ItemType.Bomb: return "Bomb";
                case ItemType.Sword: return "Sword";
                case ItemType.Boomerang: return "Boomerang";
                default: return type.ToString();
            }
        }
    }
}
