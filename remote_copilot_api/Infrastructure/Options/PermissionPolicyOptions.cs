namespace RemoteCopilot.Api.Infrastructure.Options;

public sealed class PermissionPolicyOptions
{
    public const string SectionName = "PermissionPolicy";

    public bool AllowShellByDefault { get; set; } = true;

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
