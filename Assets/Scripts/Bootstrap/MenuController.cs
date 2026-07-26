using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace DangerSnake.Bootstrap
{
    public sealed class MenuController : MonoBehaviour
    {
        void Start()
        {
            BuildUi();
        }

        void BuildUi()
        {
            if (Camera.main == null)
            {
                var camGo = new GameObject("Main Camera", typeof(Camera));
                camGo.tag = "MainCamera";
                var cam = camGo.GetComponent<Camera>();
                cam.orthographic = true;
                cam.backgroundColor = new Color(0.05f, 0.1f, 0.07f);
                cam.transform.position = new Vector3(0, 0, -10);
            }
            else
            {
                Camera.main.orthographic = true;
                Camera.main.backgroundColor = new Color(0.05f, 0.1f, 0.07f);
            }

            var canvasGo = new GameObject("MenuCanvas", typeof(Canvas), typeof(CanvasScaler), typeof(GraphicRaycaster));
            var canvas = canvasGo.GetComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            var scaler = canvasGo.GetComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1080, 1920);

            if (Object.FindFirstObjectByType<UnityEngine.EventSystems.EventSystem>() == null)
            {
                new GameObject("EventSystem",
                    typeof(UnityEngine.EventSystems.EventSystem),
                    typeof(UnityEngine.EventSystems.StandaloneInputModule));
            }

            CreateText(canvasGo.transform, "DangerSnake", 72, new Vector2(0.05f, 0.62f), new Vector2(0.95f, 0.82f));
            CreateText(canvasGo.transform,
                "The apple fights back.\nShield · Bomb · Sword · Boomerang",
                28,
                new Vector2(0.1f, 0.45f),
                new Vector2(0.9f, 0.6f));

            CreateButton(canvasGo.transform, "Play", new Vector2(0.25f, 0.28f), new Vector2(0.75f, 0.4f),
                () => SceneManager.LoadScene("Game"));

#if UNITY_WEBGL && !UNITY_EDITOR
            CreateText(canvasGo.transform, "WebGL build · keyboard", 22,
                new Vector2(0.1f, 0.08f), new Vector2(0.9f, 0.16f));
#elif UNITY_IOS
            CreateText(canvasGo.transform, "iOS · swipe to steer", 22,
                new Vector2(0.1f, 0.08f), new Vector2(0.9f, 0.16f));
#else
            CreateText(canvasGo.transform, "WASD / arrows · swipe also works", 22,
                new Vector2(0.1f, 0.08f), new Vector2(0.9f, 0.16f));
#endif
        }

        static void CreateText(Transform parent, string content, int size, Vector2 amin, Vector2 amax)
        {
            var go = new GameObject("Label", typeof(Text));
            go.transform.SetParent(parent, false);
            var rt = go.GetComponent<RectTransform>();
            rt.anchorMin = amin;
            rt.anchorMax = amax;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;
            var text = go.GetComponent<Text>();
            text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            if (text.font == null)
                text.font = Resources.GetBuiltinResource<Font>("Arial.ttf");
            text.text = content;
            text.fontSize = size;
            text.alignment = TextAnchor.MiddleCenter;
            text.color = Color.white;
            text.horizontalOverflow = HorizontalWrapMode.Wrap;
            text.verticalOverflow = VerticalWrapMode.Overflow;
        }

        static void CreateButton(Transform parent, string label, Vector2 amin, Vector2 amax, UnityEngine.Events.UnityAction action)
        {
            var go = new GameObject(label, typeof(Image), typeof(Button));
            go.transform.SetParent(parent, false);
            var rt = go.GetComponent<RectTransform>();
            rt.anchorMin = amin;
            rt.anchorMax = amax;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;
            go.GetComponent<Image>().color = new Color(0.18f, 0.55f, 0.32f);
            go.GetComponent<Button>().onClick.AddListener(action);

            var t = new GameObject("Text", typeof(Text));
            t.transform.SetParent(go.transform, false);
            var trt = t.GetComponent<RectTransform>();
            trt.anchorMin = Vector2.zero;
            trt.anchorMax = Vector2.one;
            trt.offsetMin = Vector2.zero;
            trt.offsetMax = Vector2.zero;
            var text = t.GetComponent<Text>();
            text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            if (text.font == null)
                text.font = Resources.GetBuiltinResource<Font>("Arial.ttf");
            text.text = label;
            text.fontSize = 40;
            text.alignment = TextAnchor.MiddleCenter;
            text.color = Color.white;
        }
    }
}
