using RemoteCopilot.Api.Domain.Events;

namespace RemoteCopilot.Api.Domain.Services;

public interface IConversationStreamPublisher
{
    IAsyncEnumerable<ConversationStreamEvent> SubscribeAsync(string conversationId, CancellationToken cancellationToken);

    ValueTask PublishAsync(ConversationStreamEvent streamEvent, CancellationToken cancellationToken);
}
