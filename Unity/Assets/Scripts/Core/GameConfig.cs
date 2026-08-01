using UnityEngine;

namespace DangerSnake.Core
{
    [CreateAssetMenu(menuName = "DangerSnake/Game Config", fileName = "GameConfig")]
    public sealed class GameConfig : ScriptableObject
    {
        [Header("Grid")]
        public int Width = 16;
        public int Height = 12;
        public float CellSize = 0.55f;

        [Header("Timing")]
        public float TickInterval = 0.18f;

        [Header("Snake")]
        public int StartLength = 4;

        [Header("Items")]
        public float ItemSpawnInterval = 4.5f;
        public int MaxItemsOnField = 3;

        [Header("Apple AI")]
        public int AttackChargeTicks = 12;
        public float AppleSeekItemBias = 0.65f;
    }
}
