using DangerSnake.Core;

namespace DangerSnake.Input
{
    public interface IInput
    {
        /// <summary>Queued direction for the next snake tick. Zero means no change.</summary>
        GridPos PollDirection();
    }
}
