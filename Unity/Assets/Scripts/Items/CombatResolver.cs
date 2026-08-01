using System.Collections.Generic;
using DangerSnake.Core;
using DangerSnake.Gameplay;
using UnityEngine;

namespace DangerSnake.Items
{
    /// <summary>
    /// Applies apple weapon outcomes and snake shield rules.
    /// </summary>
    public sealed class CombatResolver
    {
        public AttackOutcome ApplyAppleAttack(SnakeController snake, ItemType weapon)
        {
            if (snake.HasShield)
            {
                snake.ConsumeShield();
                return AttackOutcome.BlockedByShield;
            }

            var outcome = ItemEffect.ResolveAppleAttack(weapon);
            switch (outcome)
            {
                case AttackOutcome.CutOne:
                    snake.TrimCells(1);
                    break;
                case AttackOutcome.CutHalf:
                    snake.TrimCells(Mathf.Max(1, snake.Length / 2));
                    break;
                case AttackOutcome.Kill:
                    snake.Kill();
                    break;
            }

            return outcome;
        }

        public bool TryBoomerangHit(
            GridPos applePos,
            GridPos direction,
            SnakeController snake,
            GridModel grid,
            out AttackOutcome outcome)
        {
            outcome = AttackOutcome.None;
            var cursor = applePos + direction;
            while (grid.InBounds(cursor))
            {
                if (snake.Occupies(cursor))
                {
                    outcome = ApplyAppleAttack(snake, ItemType.Boomerang);
                    return true;
                }

                cursor += direction;
            }

            return false;
        }
    }
}
