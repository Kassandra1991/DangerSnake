using UnityEngine;

namespace DangerSnake.Core
{
    public readonly struct GridPos
    {
        public readonly int X;
        public readonly int Y;

        public GridPos(int x, int y)
        {
            X = x;
            Y = y;
        }

        public static GridPos operator +(GridPos a, GridPos b) => new GridPos(a.X + b.X, a.Y + b.Y);
        public static GridPos operator -(GridPos a, GridPos b) => new GridPos(a.X - b.X, a.Y - b.Y);
        public static bool operator ==(GridPos a, GridPos b) => a.X == b.X && a.Y == b.Y;
        public static bool operator !=(GridPos a, GridPos b) => !(a == b);

        public int Manhattan(GridPos other) => Mathf.Abs(X - other.X) + Mathf.Abs(Y - other.Y);

        public override bool Equals(object obj) => obj is GridPos other && this == other;
        public override int GetHashCode() => (X * 397) ^ Y;
        public override string ToString() => $"({X},{Y})";
    }

    public static class Directions
    {
        public static readonly GridPos Up = new GridPos(0, 1);
        public static readonly GridPos Down = new GridPos(0, -1);
        public static readonly GridPos Left = new GridPos(-1, 0);
        public static readonly GridPos Right = new GridPos(1, 0);

        public static readonly GridPos[] All = { Up, Down, Left, Right };

        public static GridPos Opposite(GridPos dir)
        {
            if (dir == Up) return Down;
            if (dir == Down) return Up;
            if (dir == Left) return Right;
            if (dir == Right) return Left;
            return dir;
        }
    }
}
