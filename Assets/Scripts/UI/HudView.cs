using DangerSnake.Gameplay;
using DangerSnake.Items;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace DangerSnake.UI
{
    public sealed class HudView : MonoBehaviour
    {
        Text _score;
        Text _status;
        Text _shield;
        Text _weapon;
        GameObject _gameOverPanel;
        Text _gameOverText;
        Button _restartButton;
        GameSession _session;

        public void Bind(GameSession session) => _session = session;

        public void Build()
        {
            var canvasGo = new GameObject("HUD", typeof(Canvas), typeof(CanvasScaler), typeof(GraphicRaycaster));
            canvasGo.transform.SetParent(transform, false);
            var canvas = canvasGo.GetComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            var scaler = canvasGo.GetComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1080, 1920);

            EnsureEventSystem();

            _score = CreateLabel(canvasGo.transform, "Score", new Vector2(0.05f, 0.92f), new Vector2(0.5f, 0.98f), 36, TextAnchor.UpperLeft);
            _shield = CreateLabel(canvasGo.transform, "Shield", new Vector2(0.5f, 0.92f), new Vector2(0.95f, 0.98f), 28, TextAnchor.UpperRight);
            _weapon = CreateLabel(canvasGo.transform, "Weapon", new Vector2(0.05f, 0.86f), new Vector2(0.95f, 0.92f), 26, TextAnchor.UpperCenter);
            _status = CreateLabel(canvasGo.transform, "Status", new Vector2(0.05f, 0.02f), new Vector2(0.95f, 0.1f), 24, TextAnchor.LowerCenter);

            _gameOverPanel = new GameObject("GameOver", typeof(Image));
            _gameOverPanel.transform.SetParent(canvasGo.transform, false);
            var panelRt = _gameOverPanel.GetComponent<RectTransform>();
            Stretch(panelRt, 0.1f, 0.3f, 0.9f, 0.7f);
            _gameOverPanel.GetComponent<Image>().color = new Color(0f, 0f, 0f, 0.75f);

            _gameOverText = CreateLabel(_gameOverPanel.transform, "GO", new Vector2(0.05f, 0.45f), new Vector2(0.95f, 0.9f), 40, TextAnchor.MiddleCenter);
            _restartButton = CreateButton(_gameOverPanel.transform, "Restart", new Vector2(0.2f, 0.1f), new Vector2(0.8f, 0.35f), () =>
            {
                _gameOverPanel.SetActive(false);
                _session.Restart();
            });

            var menuBtn = CreateButton(canvasGo.transform, "Menu", new Vector2(0.02f, 0.02f), new Vector2(0.22f, 0.08f),
                () => SceneManager.LoadScene("Menu"));
            _gameOverPanel.SetActive(false);
        }

        public void ShowPlaying(int score, bool shield, ItemType? appleWeapon, string status)
        {
            _score.text = "Score " + score;
            _shield.text = shield ? "SHIELD" : string.Empty;
            _weapon.text = appleWeapon.HasValue
                ? "Apple: " + ItemEffect.DisplayName(appleWeapon.Value)
                : "Apple: unarmed";
            _status.text = status ?? string.Empty;
            if (_gameOverPanel.activeSelf)
                _gameOverPanel.SetActive(false);
        }

        public void ShowGameOver(int score, string reason)
        {
            _gameOverPanel.SetActive(true);
            _gameOverText.text = reason + "\nScore " + score;
        }

        static void EnsureEventSystem()
        {
            if (Object.FindFirstObjectByType<UnityEngine.EventSystems.EventSystem>() != null) return;
            var es = new GameObject("EventSystem",
                typeof(UnityEngine.EventSystems.EventSystem),
                typeof(UnityEngine.EventSystems.StandaloneInputModule));
            Object.DontDestroyOnLoad(es);
        }

        static Text CreateLabel(Transform parent, string name, Vector2 amin, Vector2 amax, int size, TextAnchor anchor)
        {
            var go = new GameObject(name, typeof(Text));
            go.transform.SetParent(parent, false);
            var rt = go.GetComponent<RectTransform>();
            Stretch(rt, amin.x, amin.y, amax.x, amax.y);
            var text = go.GetComponent<Text>();
            text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            if (text.font == null)
                text.font = Resources.GetBuiltinResource<Font>("Arial.ttf");
            text.fontSize = size;
            text.alignment = anchor;
            text.color = Color.white;
            text.horizontalOverflow = HorizontalWrapMode.Wrap;
            text.verticalOverflow = VerticalWrapMode.Overflow;
            return text;
        }

        static Button CreateButton(Transform parent, string label, Vector2 amin, Vector2 amax, UnityEngine.Events.UnityAction onClick)
        {
            var go = new GameObject(label + "Button", typeof(Image), typeof(Button));
            go.transform.SetParent(parent, false);
            var rt = go.GetComponent<RectTransform>();
            Stretch(rt, amin.x, amin.y, amax.x, amax.y);
            go.GetComponent<Image>().color = new Color(0.15f, 0.45f, 0.28f, 0.95f);
            var btn = go.GetComponent<Button>();
            btn.onClick.AddListener(onClick);

            var textGo = new GameObject("Label", typeof(Text));
            textGo.transform.SetParent(go.transform, false);
            var trt = textGo.GetComponent<RectTransform>();
            Stretch(trt, 0f, 0f, 1f, 1f);
            var text = textGo.GetComponent<Text>();
            text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            if (text.font == null)
                text.font = Resources.GetBuiltinResource<Font>("Arial.ttf");
            text.text = label;
            text.alignment = TextAnchor.MiddleCenter;
            text.fontSize = 28;
            text.color = Color.white;
            return btn;
        }

        static void Stretch(RectTransform rt, float xmin, float ymin, float xmax, float ymax)
        {
            rt.anchorMin = new Vector2(xmin, ymin);
            rt.anchorMax = new Vector2(xmax, ymax);
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;
        }
    }
}
