using System.Collections.Generic;
using UnityEngine;

namespace DangerSnake.Core
{
    /// <summary>
    /// Occupancy and bounds for the playfield grid.
    /// </summary>
    public sealed class GridModel
    {
        public int Width { get; }
        public int Height { get; }
        public float CellSize { get; }
        public Vector2 Origin { get; }

        public GridModel(int width, int height, float cellSize = 1f)
        {
            Width = width;
            Height = height;
            CellSize = cellSize;
            Origin = new Vector2(-(width - 1) * cellSize * 0.5f, -(height - 1) * cellSize * 0.5f);
        }

        public bool InBounds(GridPos pos) =>
            pos.X >= 0 && pos.Y >= 0 && pos.X < Width && pos.Y < Height;

        public Vector3 ToWorld(GridPos pos) =>
            new Vector3(Origin.x + pos.X * CellSize, Origin.y + pos.Y * CellSize, 0f);

        public bool TryGetEmptyCell(ISet<GridPos> occupied, out GridPos result)
        {
            var free = new List<GridPos>(Width * Height);
            for (var x = 0; x < Width; x++)
            {
                for (var y = 0; y < Height; y++)
                {
                    var p = new GridPos(x, y);
                    if (!occupied.Contains(p))
                        free.Add(p);
                }
            }

            if (free.Count == 0)
            {
                result = default;
                return false;
            }

            result = free[Random.Range(0, free.Count)];
            return true;
        }

        public void CollectOccupied(
            IEnumerable<GridPos> snake,
            GridPos apple,
            IEnumerable<GridPos> items,
            HashSet<GridPos> into)
        {
            into.Clear();
            foreach (var s in snake)
                into.Add(s);
            into.Add(apple);
            foreach (var i in items)
                into.Add(i);
        }
    }
}
