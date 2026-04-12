using System.Collections.Concurrent;
using System.Threading.Channels;
using RemoteCopilot.Api.Domain.Events;
using RemoteCopilot.Api.Domain.Services;

namespace RemoteCopilot.Api.Infrastructure.Managers;

public sealed class ConversationStreamPublisher : IConversationStreamPublisher
{
    private readonly ConcurrentDictionary<string, ConcurrentDictionary<Guid, Channel<ConversationStreamEvent>>> _subscriptions = new();

    public async ValueTask PublishAsync(ConversationStreamEvent streamEvent, CancellationToken cancellationToken)
    {
        if (!_subscriptions.TryGetValue(streamEvent.ConversationId, out var subscribers))
        {
            return;
        }

        foreach (var subscriber in subscribers.Values)
        {
            await subscriber.Writer.WriteAsync(streamEvent, cancellationToken);
        }
    }

    public async IAsyncEnumerable<ConversationStreamEvent> SubscribeAsync(
        string conversationId,
        [System.Runtime.CompilerServices.EnumeratorCancellation] CancellationToken cancellationToken)
    {
        var channel = Channel.CreateUnbounded<ConversationStreamEvent>();
        var subscriptionId = Guid.NewGuid();

        var subscribers = _subscriptions.GetOrAdd(
            conversationId,
            _ => new ConcurrentDictionary<Guid, Channel<ConversationStreamEvent>>());
        subscribers[subscriptionId] = channel;

        try
        {
            while (await channel.Reader.WaitToReadAsync(cancellationToken))
            {
                while (channel.Reader.TryRead(out var streamEvent))
                {
                    yield return streamEvent;
                }
            }
        }
        finally
        {
            subscribers.TryRemove(subscriptionId, out _);
            if (subscribers.IsEmpty)
            {
                _subscriptions.TryRemove(conversationId, out _);
            }
        }
    }
}
