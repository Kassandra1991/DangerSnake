#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace DangerSnake.Editor
{
    /// <summary>
    /// Menu items for WebGL (itch.io) and iOS (Xcode / TestFlight) builds.
    /// </summary>
    public static class BuildPipelineMenu
    {
        const string WebGlOut = "Builds/WebGL";
        const string IosOut = "Builds/iOS";

        static readonly string[] Scenes =
        {
            "Assets/Scenes/Boot.unity",
            "Assets/Scenes/Menu.unity",
            "Assets/Scenes/Game.unity"
        };

        [MenuItem("DangerSnake/Build/WebGL (itch.io)")]
        public static void BuildWebGL()
        {
            EnsureFolder(WebGlOut);
            PlayerSettings.WebGL.compressionFormat = WebGLCompressionFormat.Brotli;
            PlayerSettings.WebGL.decompressionFallback = true;
            PlayerSettings.WebGL.memorySize = 32;
            PlayerSettings.productName = "DangerSnake";

            var options = new BuildPlayerOptions
            {
                scenes = Scenes,
                locationPathName = WebGlOut,
                target = BuildTarget.WebGL,
                options = BuildOptions.None
            };

            var report = BuildPipeline.BuildPlayer(options);
            LogReport("WebGL", report);
            if (report.summary.result == BuildResult.Succeeded)
            {
                Debug.Log(
                    "WebGL ready. Zip the Builds/WebGL folder and upload to itch.io " +
                    "(Kind: HTML, check 'This file will be played in the browser').");
                EditorUtility.RevealInFinder(WebGlOut);
            }
        }

        [MenuItem("DangerSnake/Build/iOS (Xcode / TestFlight)")]
        public static void BuildIOS()
        {
            EnsureFolder(IosOut);
            PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.iOS, "com.dangersnake.game");
            PlayerSettings.iOS.targetOSVersionString = "13.0";
            PlayerSettings.iOS.sdkVersion = iOSSdkVersion.DeviceSDK;
            PlayerSettings.SetScriptingBackend(BuildTargetGroup.iOS, ScriptingImplementation.IL2CPP);
            PlayerSettings.productName = "DangerSnake";
            PlayerSettings.bundleVersion = "0.1.0";
            PlayerSettings.iOS.buildNumber = "1";

            var options = new BuildPlayerOptions
            {
                scenes = Scenes,
                locationPathName = IosOut,
                target = BuildTarget.iOS,
                options = BuildOptions.None
            };

            var report = BuildPipeline.BuildPlayer(options);
            LogReport("iOS", report);
            if (report.summary.result == BuildResult.Succeeded)
            {
                Debug.Log(
                    "iOS Xcode project exported to Builds/iOS. Open in Xcode, sign with your " +
                    "Apple Developer team, Archive → Distribute to TestFlight.");
                EditorUtility.RevealInFinder(IosOut);
            }
        }

        [MenuItem("DangerSnake/Build/Open itch.io checklist")]
        public static void OpenItchChecklist()
        {
            var path = Path.GetFullPath("Docs/ITCH_IO.md");
            if (File.Exists(path))
                Application.OpenURL("file://" + path);
            else
                Debug.LogWarning("Missing Docs/ITCH_IO.md");
        }

        static void EnsureFolder(string relative)
        {
            var full = Path.GetFullPath(relative);
            Directory.CreateDirectory(full);
        }

        static void LogReport(string label, BuildReport report)
        {
            var s = report.summary;
            Debug.Log($"[DangerSnake] {label} build {s.result} in {s.totalTime} — size {s.totalSize} bytes");
            if (s.result != BuildResult.Succeeded)
                Debug.LogError($"[DangerSnake] {label} failed. See Console for compiler/build errors.");
        }
    }
}
#endif
