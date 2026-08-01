using System.Collections.Generic;
using DangerSnake.Core;
using DangerSnake.Items;
using UnityEngine;

namespace DangerSnake.Gameplay
{
    public sealed class ItemSpawner
    {
        readonly GameConfig _config;
        readonly List<FieldItem> _items = new List<FieldItem>(8);
        float _cooldown;

        public IReadOnlyList<FieldItem> Items => _items;

        public ItemSpawner(GameConfig config)
        {
            _config = config;
            _cooldown = config.ItemSpawnInterval * 0.5f;
        }

        public void Reset()
        {
            _items.Clear();
            _cooldown = _config.ItemSpawnInterval * 0.5f;
        }

        public void TickRealtime(float dt, GridModel grid, HashSet<GridPos> occupied)
        {
            _cooldown -= dt;
            if (_cooldown > 0f) return;
            if (_items.Count >= _config.MaxItemsOnField) return;

            if (grid.TryGetEmptyCell(occupied, out var cell))
            {
                var type = (ItemType)Random.Range(0, 4);
                _items.Add(new FieldItem(cell, type));
            }

            _cooldown = _config.ItemSpawnInterval;
        }

        public bool TryPickupAt(GridPos pos, out ItemType type)
        {
            for (var i = 0; i < _items.Count; i++)
            {
                if (_items[i].Position == pos)
                {
                    type = _items[i].Type;
                    _items.RemoveAt(i);
                    return true;
                }
            }

            type = default;
            return false;
        }

        public IEnumerable<GridPos> Positions
        {
            get
            {
                for (var i = 0; i < _items.Count; i++)
                    yield return _items[i].Position;
            }
        }
    }
}
