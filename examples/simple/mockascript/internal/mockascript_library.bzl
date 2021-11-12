def _mockascript_library_impl(ctx):
    pass

mockascript_library = rule(
    implementation = _mockascript_library_impl,
    attrs = {},
    doc = "",
)
