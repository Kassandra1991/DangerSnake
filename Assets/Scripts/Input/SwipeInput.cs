using DangerSnake.Core;
using UnityEngine;

namespace DangerSnake.Input
{
    /// <summary>
    /// Swipe gestures for iOS / touch devices.
    /// </summary>
    public sealed class SwipeInput : IInput
    {
        const float MinSwipePixels = 40f;

        Vector2 _start;
        bool _tracking;
        GridPos _queued;

        public GridPos PollDirection()
        {
            if (UnityEngine.Input.touchCount > 0)
            {
                var touch = UnityEngine.Input.GetTouch(0);
                HandleFinger(touch.phase, touch.position);
            }
            else
            {
                // Editor / desktop fallback for testing swipes with mouse.
                if (UnityEngine.Input.GetMouseButtonDown(0))
                    HandleFinger(TouchPhase.Began, UnityEngine.Input.mousePosition);
                else if (UnityEngine.Input.GetMouseButton(0))
                    HandleFinger(TouchPhase.Moved, UnityEngine.Input.mousePosition);
                else if (UnityEngine.Input.GetMouseButtonUp(0))
                    HandleFinger(TouchPhase.Ended, UnityEngine.Input.mousePosition);
            }

            var result = _queued;
            _queued = default;
            return result;
        }

        void HandleFinger(TouchPhase phase, Vector2 pos)
        {
            switch (phase)
            {
                case TouchPhase.Began:
                    _start = pos;
                    _tracking = true;
                    break;
                case TouchPhase.Ended:
                case TouchPhase.Canceled:
                    if (_tracking)
                        ResolveSwipe(pos - _start);
                    _tracking = false;
                    break;
            }
        }

        void ResolveSwipe(Vector2 delta)
        {
            if (delta.magnitude < MinSwipePixels) return;

            if (Mathf.Abs(delta.x) > Mathf.Abs(delta.y))
                _queued = delta.x > 0 ? Directions.Right : Directions.Left;
            else
                _queued = delta.y > 0 ? Directions.Up : Directions.Down;
        }
    }
}
