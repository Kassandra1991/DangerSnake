using DangerSnake.Core;
using DangerSnake.Gameplay;
using DangerSnake.UI;
using UnityEngine;

namespace DangerSnake.Bootstrap
{
    /// <summary>
    /// Wires Game scene objects at runtime so scenes stay minimal.
    /// </summary>
    public sealed class GameBootstrap : MonoBehaviour
    {
        [SerializeField] GameConfig config;

        void Start()
        {
            if (Camera.main == null)
            {
                var camGo = new GameObject("Main Camera", typeof(Camera), typeof(AudioListener));
                camGo.tag = "MainCamera";
                camGo.transform.position = new Vector3(0, 0, -10);
            }

            if (config == null)
            {
                config = Resources.Load<GameConfig>("GameConfig");
                if (config == null)
                    config = ScriptableObject.CreateInstance<GameConfig>();
            }

            var root = new GameObject("GameRoot");
            var view = root.AddComponent<GameView>();
            var hud = root.AddComponent<HudView>();
            var session = root.AddComponent<GameSession>();

            hud.Build();
            hud.Bind(session);
            session.Bind(config, view, hud);
            session.StartMatch();
        }
    }
}
