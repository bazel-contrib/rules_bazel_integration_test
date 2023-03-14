"""Implementation of `mockascript_library`."""

def _mockascript_library_impl(_ctx):
    pass

mockascript_library = rule(
    implementation = _mockascript_library_impl,
    attrs = {},
    doc = "",
)
