using RemoteCopilot.Api.Common.Errors;

namespace RemoteCopilot.Api.Common.Results;

public sealed class AppResult<T>
{
    private AppResult(bool isSuccess, T? value, AppError? error)
    {
        IsSuccess = isSuccess;
        Value = value;
        Error = error;
    }

    public bool IsSuccess { get; }

    public T? Value { get; }

    public AppError? Error { get; }

    public static AppResult<T> Success(T value) => new(true, value, null);

    public static AppResult<T> Failure(string code, string message) =>
        new(false, default, new AppError(code, message));
}
