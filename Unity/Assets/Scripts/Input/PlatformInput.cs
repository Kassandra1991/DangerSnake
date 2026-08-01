using DangerSnake.Core;
using UnityEngine;

namespace DangerSnake.Input
{
    /// <summary>
    /// Combines keyboard (WebGL/desktop) and swipe (iOS/touch) without branching gameplay.
    /// </summary>
    public sealed class PlatformInput : IInput
    {
        readonly KeyboardInput _keyboard = new KeyboardInput();
        readonly SwipeInput _swipe = new SwipeInput();

        public GridPos PollDirection()
        {
            var key = _keyboard.PollDirection();
            if (key.X != 0 || key.Y != 0)
                return key;

            return _swipe.PollDirection();
        }

        public static bool PreferTouchHints
        {
            get
            {
#if UNITY_IOS || UNITY_ANDROID
                return true;
#else
                return Application.isMobilePlatform;
#endif
            }
        }
    }
}
