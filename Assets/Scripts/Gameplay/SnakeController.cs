using System.Collections.Generic;
using DangerSnake.Core;
using UnityEngine;

namespace DangerSnake.Gameplay
{
    public sealed class SnakeController
    {
        readonly List<GridPos> _body = new List<GridPos>(64);
        GridPos _pendingDir;
        GridPos _dir;
        bool _growNext;
        bool _alive = true;

        public IReadOnlyList<GridPos> Body => _body;
        public GridPos Head => _body[0];
        public GridPos Direction => _dir;
        public int Length => _body.Count;
        public bool IsAlive => _alive && _body.Count > 0;
        public bool HasShield { get; private set; }
        public int Score { get; private set; }

        public void Reset(GridPos start, int length, GridPos initialDir)
        {
            _body.Clear();
            _dir = initialDir;
            _pendingDir = initialDir;
            _growNext = false;
            _alive = true;
            HasShield = false;
            Score = 0;

            for (var i = 0; i < length; i++)
                _body.Add(new GridPos(start.X - initialDir.X * i, start.Y - initialDir.Y * i));
        }

        public void SetDirection(GridPos dir)
        {
            if (dir.X == 0 && dir.Y == 0) return;
            if (dir == Directions.Opposite(_dir)) return;
            _pendingDir = dir;
        }

        public void GrantShield() => HasShield = true;

        public void ConsumeShield() => HasShield = false;

        public void QueueGrow()
        {
            _growNext = true;
            Score += 10;
        }

        public bool Occupies(GridPos pos)
        {
            for (var i = 0; i < _body.Count; i++)
            {
                if (_body[i] == pos) return true;
            }

            return false;
        }

        public void TrimCells(int count)
        {
            if (count <= 0) return;
            var remove = Mathf.Min(count, Mathf.Max(0, _body.Count - 1));
            if (remove <= 0)
            {
                Kill();
                return;
            }

            _body.RemoveRange(_body.Count - remove, remove);
            if (_body.Count <= 0)
                Kill();
        }

        public void Kill()
        {
            _alive = false;
        }

        /// <summary>
        /// Advances one cell. Returns false if the snake dies from wall/self.
        /// </summary>
        public bool TickMove(GridModel grid)
        {
            if (!IsAlive) return false;

            _dir = _pendingDir;
            var next = Head + _dir;

            if (!grid.InBounds(next))
            {
                Kill();
                return false;
            }

            // Allow moving into the tail cell if it will vacate (classic snake rule).
            var tail = _body[_body.Count - 1];
            for (var i = 0; i < _body.Count; i++)
            {
                if (_body[i] == next)
                {
                    var isVacatingTail = !_growNext && next == tail;
                    if (!isVacatingTail)
                    {
                        Kill();
                        return false;
                    }
                }
            }

            _body.Insert(0, next);
            if (_growNext)
                _growNext = false;
            else
                _body.RemoveAt(_body.Count - 1);

            return true;
        }
    }
}
