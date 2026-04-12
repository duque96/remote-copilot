namespace RemoteCopilot.Api.Infrastructure.Options;

public sealed class PermissionPolicyOptions
{
    public const string SectionName = "PermissionPolicy";

    public List<string> AllowedShellCommands { get; set; } =
    [
        "cat",
        "dart",
        "dotnet",
        "fd",
        "find",
        "flutter",
        "git",
        "go",
        "grep",
        "head",
        "ls",
        "node",
        "npm",
        "pnpm",
        "pwd",
        "python",
        "python3",
        "rg",
        "sed",
        "tail",
        "wc",
        "yarn"
    ];

    public List<string> DeniedShellFragments { get; set; } =
    [
        " rm ",
        " sudo ",
        " shutdown",
        " reboot",
        " mkfs",
        " :(){:|:&};:"
    ];
}
