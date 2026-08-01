using DangerSnake.Core;
using UnityEngine;

namespace DangerSnake.Input
{
    /// <summary>
    /// WASD / arrow keys — primary for WebGL and editor.
    /// </summary>
    public sealed class KeyboardInput : IInput
    {
        GridPos _queued;

        public GridPos PollDirection()
        {
            if (UnityEngine.Input.GetKeyDown(KeyCode.UpArrow) || UnityEngine.Input.GetKeyDown(KeyCode.W))
                _queued = Directions.Up;
            else if (UnityEngine.Input.GetKeyDown(KeyCode.DownArrow) || UnityEngine.Input.GetKeyDown(KeyCode.S))
                _queued = Directions.Down;
            else if (UnityEngine.Input.GetKeyDown(KeyCode.LeftArrow) || UnityEngine.Input.GetKeyDown(KeyCode.A))
                _queued = Directions.Left;
            else if (UnityEngine.Input.GetKeyDown(KeyCode.RightArrow) || UnityEngine.Input.GetKeyDown(KeyCode.D))
                _queued = Directions.Right;

            var result = _queued;
            _queued = default;
            return result;
        }
    }
}
