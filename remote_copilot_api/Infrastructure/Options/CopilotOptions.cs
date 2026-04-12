namespace RemoteCopilot.Api.Infrastructure.Options;

public sealed class CopilotOptions
{
    public const string SectionName = "Copilot";

    public string ServerUrl { get; set; } = "127.0.0.1:3000";

    public string ClientName { get; set; } = "remote-copilot-api";

    public string Model { get; set; } = "gpt-5";

    public string ConfigDirectory { get; set; } = "/data/copilot-home";

    public List<string> SkillDirectories { get; set; } = [];

    public List<string> DisabledSkills { get; set; } = [];
}
