using DangerSnake.Core;

namespace DangerSnake.Items
{
    public sealed class FieldItem
    {
        public GridPos Position;
        public ItemType Type;

        public FieldItem(GridPos position, ItemType type)
        {
            Position = position;
            Type = type;
        }
    }
}
