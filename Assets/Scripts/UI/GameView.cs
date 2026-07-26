using System.Collections.Generic;
using DangerSnake.Core;
using DangerSnake.Gameplay;
using DangerSnake.Items;
using UnityEngine;

namespace DangerSnake.UI
{
    /// <summary>
    /// Runtime-drawn board using colored quads (no external art required).
    /// </summary>
    public sealed class GameView : MonoBehaviour
    {
        Transform _root;
        readonly List<Transform> _snakeParts = new List<Transform>(64);
        Transform _apple;
        readonly List<Transform> _itemViews = new List<Transform>(8);
        readonly List<Transform> _cells = new List<Transform>(256);

        static readonly Color BoardDark = new Color(0.07f, 0.12f, 0.09f);
        static readonly Color BoardLite = new Color(0.09f, 0.16f, 0.11f);
        static readonly Color SnakeColor = new Color(0.35f, 0.85f, 0.45f);
        static readonly Color SnakeHead = new Color(0.55f, 1f, 0.6f);
        static readonly Color AppleColor = new Color(0.95f, 0.25f, 0.28f);
        static readonly Color AppleArmed = new Color(1f, 0.55f, 0.15f);

        public void BuildBoard(GridModel grid)
        {
            if (_root != null)
                Destroy(_root.gameObject);

            _root = new GameObject("Board").transform;
            _root.SetParent(transform, false);
            _snakeParts.Clear();
            _itemViews.Clear();
            _cells.Clear();
            _apple = null;

            for (var x = 0; x < grid.Width; x++)
            {
                for (var y = 0; y < grid.Height; y++)
                {
                    var cell = CreateQuad("Cell", (x + y) % 2 == 0 ? BoardDark : BoardLite, 0.92f);
                    cell.position = grid.ToWorld(new GridPos(x, y));
                    cell.SetParent(_root, true);
                    _cells.Add(cell);
                }
            }

            FitCamera(grid);
        }

        public void Render(GridModel grid, SnakeController snake, AppleAI apple, IReadOnlyList<FieldItem> items)
        {
            EnsureCount(_snakeParts, snake.Length, "Snake", SnakeColor, _root);
            for (var i = 0; i < snake.Length; i++)
            {
                var t = _snakeParts[i];
                t.gameObject.SetActive(true);
                t.position = grid.ToWorld(snake.Body[i]);
                var mr = t.GetComponent<MeshRenderer>();
                mr.material.color = i == 0
                    ? (snake.HasShield ? new Color(0.4f, 0.75f, 1f) : SnakeHead)
                    : SnakeColor;
                t.localScale = Vector3.one * (i == 0 ? 0.88f : 0.78f) * grid.CellSize;
            }

            for (var i = snake.Length; i < _snakeParts.Count; i++)
                _snakeParts[i].gameObject.SetActive(false);

            if (_apple == null)
            {
                _apple = CreateQuad("Apple", AppleColor, 0.7f);
                _apple.SetParent(_root, true);
            }

            _apple.position = grid.ToWorld(apple.Position);
            _apple.GetComponent<MeshRenderer>().material.color =
                apple.HeldItem.HasValue ? AppleArmed : AppleColor;
            _apple.localScale = Vector3.one * 0.7f * grid.CellSize;

            EnsureCount(_itemViews, items.Count, "Item", Color.white, _root);
            for (var i = 0; i < items.Count; i++)
            {
                var t = _itemViews[i];
                t.gameObject.SetActive(true);
                t.position = grid.ToWorld(items[i].Position);
                t.GetComponent<MeshRenderer>().material.color = ColorFor(items[i].Type);
                t.localScale = Vector3.one * 0.55f * grid.CellSize;
            }

            for (var i = items.Count; i < _itemViews.Count; i++)
                _itemViews[i].gameObject.SetActive(false);
        }

        static Color ColorFor(ItemType type)
        {
            switch (type)
            {
                case ItemType.Shield: return new Color(0.35f, 0.7f, 1f);
                case ItemType.Bomb: return new Color(0.2f, 0.2f, 0.22f);
                case ItemType.Sword: return new Color(0.9f, 0.85f, 0.35f);
                case ItemType.Boomerang: return new Color(0.85f, 0.45f, 0.2f);
                default: return Color.white;
            }
        }

        void EnsureCount(List<Transform> list, int count, string name, Color color, Transform parent)
        {
            while (list.Count < count)
            {
                var t = CreateQuad(name, color, 0.8f);
                t.SetParent(parent, true);
                list.Add(t);
            }
        }

        static Transform CreateQuad(string name, Color color, float scale) =>
            QuadFactory.Create(name, color, scale);

        static void FitCamera(GridModel grid)
        {
            var cam = Camera.main;
            if (cam == null) return;
            cam.orthographic = true;
            cam.backgroundColor = new Color(0.04f, 0.07f, 0.05f);
            var aspect = (float)Screen.width / Mathf.Max(1, Screen.height);
            var halfH = grid.Height * grid.CellSize * 0.55f + 0.5f;
            var halfW = grid.Width * grid.CellSize * 0.55f + 0.5f;
            cam.orthographicSize = Mathf.Max(halfH, halfW / aspect);
            cam.transform.position = new Vector3(0f, 0.4f, -10f);
        }
    }
}
