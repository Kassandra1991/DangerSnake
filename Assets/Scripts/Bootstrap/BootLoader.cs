using UnityEngine;
using UnityEngine.SceneManagement;

namespace DangerSnake.Bootstrap
{
    /// <summary>
    /// First scene entry: jump to Menu.
    /// </summary>
    public sealed class BootLoader : MonoBehaviour
    {
        void Start()
        {
            Application.targetFrameRate = 60;
            Screen.sleepTimeout = SleepTimeout.NeverSleep;
            SceneManager.LoadScene("Menu");
        }
    }
}
