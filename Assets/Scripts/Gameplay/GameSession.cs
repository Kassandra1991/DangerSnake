using System.Collections.Generic;
using DangerSnake.Core;
using DangerSnake.Gameplay;
using DangerSnake.Input;
using DangerSnake.Items;
using DangerSnake.UI;
using UnityEngine;

namespace DangerSnake.Gameplay
{
    /// <summary>
    /// Owns the fixed tick loop: snake, apple AI, items, combat.
    /// </summary>
    public sealed class GameSession : MonoBehaviour
    {
        [SerializeField] GameConfig config;

        GridModel _grid;
        SnakeController _snake;
        AppleAI _apple;
        ItemSpawner _items;
        CombatResolver _combat;
        PlatformInput _input;
        GameView _view;
        HudView _hud;

        readonly HashSet<GridPos> _occupied = new HashSet<GridPos>();
        readonly HashSet<GridPos> _appleBlocked = new HashSet<GridPos>();

        float _tickTimer;
        bool _running;
        string _status = string.Empty;

        public void Bind(GameConfig cfg, GameView view, HudView hud)
        {
            config = cfg;
            _view = view;
            _hud = hud;
        }

        public void StartMatch()
        {
            if (config == null)
                config = ScriptableObject.CreateInstance<GameConfig>();

            _grid = new GridModel(config.Width, config.Height, config.CellSize);
            _snake = new SnakeController();
            _apple = new AppleAI(config);
            _items = new ItemSpawner(config);
            _combat = new CombatResolver();
            _input = new PlatformInput();

            var start = new GridPos(config.Width / 4, config.Height / 2);
            _snake.Reset(start, config.StartLength, Directions.Right);
            _apple.Reset(new GridPos(config.Width * 3 / 4, config.Height / 2));
            _items.Reset();

            _tickTimer = 0f;
            _running = true;
            _status = PlatformInput.PreferTouchHints
                ? "Swipe to steer. Eat the apple — but watch its weapons!"
                : "Arrows/WASD to steer. Eat the apple — but watch its weapons!";

            _view.BuildBoard(_grid);
            RefreshView();
            _hud.ShowPlaying(_snake.Score, _snake.HasShield, _apple.HeldItem, _status);
        }

        void Update()
        {
            if (!_running) return;

            var dir = _input.PollDirection();
            if (dir.X != 0 || dir.Y != 0)
                _snake.SetDirection(dir);

            RebuildOccupied();
            _items.TickRealtime(Time.deltaTime, _grid, _occupied);

            _tickTimer += Time.deltaTime;
            while (_tickTimer >= config.TickInterval)
            {
                _tickTimer -= config.TickInterval;
                StepTick();
                if (!_running) break;
            }

            RefreshView();
            _hud.ShowPlaying(_snake.Score, _snake.HasShield, _apple.HeldItem, _status);
        }

        void StepTick()
        {
            RebuildOccupied();

            // Snake moves first.
            if (!_snake.TickMove(_grid))
            {
                EndGame("Crashed!");
                return;
            }

            // Eating apple grows the snake; apple respawns if unarmed.
            if (_snake.Head == _apple.Position)
            {
                if (_apple.HeldItem.HasValue)
                {
                    ResolveContactAttack();
                    if (!_snake.IsAlive)
                    {
                        EndGame("The apple struck you down!");
                        return;
                    }
                }
                else
                {
                    _snake.QueueGrow();
                    RespawnApple();
                    _status = "Yum! +" + 10;
                }
            }

            // Apple may pick up an item before moving.
            if (!_apple.HeldItem.HasValue && _items.TryPickupAt(_apple.Position, out var picked))
            {
                _apple.Pickup(picked);
                _status = "Apple armed: " + ItemEffect.DisplayName(picked) + "!";
            }

            // Snake can also pick up shield (and other items as shield-only benefit for v1).
            if (_items.TryPickupAt(_snake.Head, out var snakeItem))
            {
                if (snakeItem == ItemType.Shield)
                {
                    _snake.GrantShield();
                    _status = "Shield online!";
                }
                else
                {
                    // Non-shield items claimed by snake just deny the apple — score snack.
                    _snake.QueueGrow();
                    _status = "Denied the " + ItemEffect.DisplayName(snakeItem) + "!";
                }
            }

            RebuildAppleBlocked();
            var appleStep = _apple.Tick(_snake, _grid, _items.Items, _appleBlocked);

            if (_apple.HeldItem.HasValue)
            {
                if (_apple.HeldItem.Value == ItemType.Boomerang && (appleStep.X != 0 || appleStep.Y != 0))
                {
                    if (_combat.TryBoomerangHit(_apple.Position, appleStep, _snake, _grid, out var boom))
                    {
                        _status = Describe(boom);
                        _apple.ConsumeHeldItem();
                        if (!_snake.IsAlive)
                        {
                            EndGame("Boomerang!");
                            return;
                        }
                    }
                }

                if (_snake.Occupies(_apple.Position) || _snake.Head == _apple.Position)
                {
                    ResolveContactAttack();
                    if (!_snake.IsAlive)
                    {
                        EndGame("The apple struck you down!");
                        return;
                    }
                }
            }
            else if (_snake.Head == _apple.Position)
            {
                _snake.QueueGrow();
                RespawnApple();
            }

            if (!_snake.IsAlive)
                EndGame("Game over");
        }

        void ResolveContactAttack()
        {
            if (!_apple.HeldItem.HasValue) return;
            var outcome = _combat.ApplyAppleAttack(_snake, _apple.HeldItem.Value);
            _status = Describe(outcome);
            _apple.ConsumeHeldItem();
            if (_snake.IsAlive)
                RespawnApple();
        }

        static string Describe(AttackOutcome outcome)
        {
            switch (outcome)
            {
                case AttackOutcome.BlockedByShield: return "Shield absorbed the hit!";
                case AttackOutcome.CutOne: return "Lost a segment!";
                case AttackOutcome.CutHalf: return "Bomb cut you in half!";
                case AttackOutcome.Kill: return "Sword finish!";
                default: return string.Empty;
            }
        }

        void RespawnApple()
        {
            RebuildOccupied();
            _occupied.Remove(_apple.Position);
            if (_grid.TryGetEmptyCell(_occupied, out var cell))
                _apple.Reset(cell);
        }

        void RebuildOccupied()
        {
            _grid.CollectOccupied(_snake.Body, _apple.Position, _items.Positions, _occupied);
        }

        void RebuildAppleBlocked()
        {
            _appleBlocked.Clear();
            // Apple can step onto snake head when attacking; otherwise avoid body.
            for (var i = 0; i < _snake.Body.Count; i++)
            {
                if (_apple.Mode == AppleMode.Attack && i == 0) continue;
                _appleBlocked.Add(_snake.Body[i]);
            }

            foreach (var item in _items.Items)
            {
                // Items are pickable, not blocked.
            }
        }

        void RefreshView()
        {
            _view.Render(_grid, _snake, _apple, _items.Items);
        }

        void EndGame(string reason)
        {
            _running = false;
            _status = reason;
            RefreshView();
            _hud.ShowGameOver(_snake.Score, reason);
        }

        public void Restart() => StartMatch();
    }
}
