using System.Collections.Generic;
using DangerSnake.Core;
using DangerSnake.Items;
using UnityEngine;

namespace DangerSnake.Gameplay
{
    public enum AppleMode
    {
        Flee,
        SeekItem,
        Attack
    }

    public sealed class AppleAI
    {
        public GridPos Position { get; private set; }
        public AppleMode Mode { get; private set; } = AppleMode.Flee;
        public ItemType? HeldItem { get; private set; }
        public int AttackTicksLeft { get; private set; }

        readonly GameConfig _config;

        public AppleAI(GameConfig config)
        {
            _config = config;
        }

        public void Reset(GridPos start)
        {
            Position = start;
            Mode = AppleMode.Flee;
            HeldItem = null;
            AttackTicksLeft = 0;
        }

        public void Pickup(ItemType type)
        {
            HeldItem = type;
            Mode = AppleMode.Attack;
            AttackTicksLeft = _config.AttackChargeTicks;
        }

        public void ConsumeHeldItem()
        {
            HeldItem = null;
            AttackTicksLeft = 0;
            Mode = AppleMode.Flee;
        }

        public GridPos Tick(
            SnakeController snake,
            GridModel grid,
            IReadOnlyList<FieldItem> items,
            HashSet<GridPos> blocked)
        {
            UpdateMode(snake, items);

            var desired = ChooseTarget(snake, items);
            var step = ChooseStep(desired, snake.Head, grid, blocked);
            if (step.X != 0 || step.Y != 0)
                Position += step;

            if (Mode == AppleMode.Attack)
            {
                AttackTicksLeft--;
                if (AttackTicksLeft <= 0)
                    ConsumeHeldItem();
            }

            return step;
        }

        void UpdateMode(SnakeController snake, IReadOnlyList<FieldItem> items)
        {
            if (HeldItem.HasValue)
            {
                Mode = AppleMode.Attack;
                return;
            }

            if (items.Count > 0 && Random.value < _config.AppleSeekItemBias)
                Mode = AppleMode.SeekItem;
            else
                Mode = AppleMode.Flee;
        }

        GridPos ChooseTarget(SnakeController snake, IReadOnlyList<FieldItem> items)
        {
            switch (Mode)
            {
                case AppleMode.Attack:
                    return snake.Head;
                case AppleMode.SeekItem:
                    return NearestItem(items);
                default:
                    // Flee: mirror away from snake head.
                    return Position + (Position - snake.Head);
            }
        }

        GridPos NearestItem(IReadOnlyList<FieldItem> items)
        {
            if (items.Count == 0) return Position;
            var best = items[0];
            var bestDist = Position.Manhattan(best.Position);
            for (var i = 1; i < items.Count; i++)
            {
                var d = Position.Manhattan(items[i].Position);
                if (d < bestDist)
                {
                    bestDist = d;
                    best = items[i];
                }
            }

            return best.Position;
        }

        GridPos ChooseStep(GridPos target, GridPos snakeHead, GridModel grid, HashSet<GridPos> blocked)
        {
            GridPos best = default;
            var bestScore = int.MinValue;

            foreach (var dir in Directions.All)
            {
                var next = Position + dir;
                if (!grid.InBounds(next)) continue;
                if (blocked.Contains(next) && next != snakeHead) continue;

                var score = -next.Manhattan(target);
                // Prefer not walking onto snake body unless attacking.
                if (Mode != AppleMode.Attack && next == snakeHead)
                    score -= 100;

                // Slight randomness to avoid deterministic loops.
                score += Random.Range(0, 2);

                if (score > bestScore)
                {
                    bestScore = score;
                    best = dir;
                }
            }

            return best;
        }
    }
}
