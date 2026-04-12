using RemoteCopilot.Api.Domain.Model;

namespace RemoteCopilot.Api.Domain.Repositories;

public interface IConversationRepository
{
    Task<ConversationThread> CreateAsync(string sessionId, string title, CancellationToken cancellationToken);

    Task<ConversationThread?> GetByIdAsync(string conversationId, CancellationToken cancellationToken);

    Task<ConversationThread?> GetBySessionIdAsync(string sessionId, CancellationToken cancellationToken);

    Task<IReadOnlyList<ConversationMessage>> GetMessagesAsync(string conversationId, CancellationToken cancellationToken);

    Task<ConversationMessage> AddMessageAsync(
        string conversationId,
        string role,
        string content,
        string status,
        string? error,
        CancellationToken cancellationToken);

    Task UpdateMessageAsync(
        string messageId,
        string content,
        string status,
        string? error,
        CancellationToken cancellationToken);
}
