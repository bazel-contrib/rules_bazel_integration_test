"""Module containing Bazelisk constants and utility functions."""

_DEFAULT_VERSION = "1.26.0"

_BAZELISK_URL_TEMPLATE = "https://github.com/bazelbuild/bazelisk/releases/download/v{version}/{filename}"

def _is_linux(os_name):
    return os_name.startswith("linux")

def _is_macos(os_name):
    return os_name.startswith("mac os")

def _is_windows(os_name):
    return os_name.startswith("windows")

def _is_x86_64(arch_name):
    return arch_name.startswith("amd64") or arch_name.startswith("x86_64")

def _is_arm(arch_name):
    return arch_name.startswith("aarch64") or arch_name.startswith("arm")

def _url(os, arch, version = _DEFAULT_VERSION):
    """Provide the Bazelisk URL for a specific version, OS, arch.

    Args:
        os: The OS name as a `string`.
        arch: The arch as a `string`.
        version: Optional. The version as a `string`. Uses the default version
            if not specified.

    Returns:
        A URl as a `string`.
    """
    os_name = os.lower()
    arch_name = arch.lower()
    if _is_linux(os_name) and _is_x86_64(arch_name):
        suffix = "linux-amd64"
    elif _is_linux(os_name) and _is_arm(arch_name):
        suffix = "linux-arm64"
    elif _is_macos(os_name) and _is_x86_64(arch_name):
        suffix = "darwin-amd64"
    elif _is_macos(os_name) and _is_arm(arch_name):
        suffix = "darwin-arm64"
    elif _is_windows(os_name) and _is_x86_64(arch_name):
        suffix = "windows-amd64.exe"
    elif _is_windows(os_name) and _is_arm(arch_name):
        suffix = "windows-arm64.exe"
    else:
        fail("Unrecognized os and arch. os: {}, arch: {}".format(
            os_name,
            arch_name,
        ))

    filename = "bazelisk-%s" % suffix
    return _BAZELISK_URL_TEMPLATE.format(
        version = version,
        filename = filename,
    )

bazelisks = struct(
    DEFAULT_VERSION = _DEFAULT_VERSION,
    url = _url,
)
