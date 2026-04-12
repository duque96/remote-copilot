using System.Text.Json;

namespace RemoteCopilot.Api.Domain.Events;

public sealed record ConversationStreamEvent(
    string Type,
    string ConversationId,
    DateTimeOffset Timestamp,
    string? MessageId = null,
    string? EventId = null,
    string? ParentEventId = null,
    bool Ephemeral = false,
    string Source = "sdk",
    JsonElement? Data = null);
