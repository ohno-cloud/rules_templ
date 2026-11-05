"""Unit tests for starlark helpers
See https://bazel.build/rules/testing#testing-starlark-utilities
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//templ/private:toolchains_repo.bzl", "PLATFORMS")
load("//templ/private:versions.bzl", "TOOL_VERSIONS")

def _smoke_test_impl(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, ["0.3.1100"], TOOL_VERSIONS.keys())
    for checksums in TOOL_VERSIONS.values():
        asserts.equals(env, sorted(PLATFORMS.keys()), sorted(checksums.keys()))
        for checksum in checksums.values():
            asserts.equals(env, 64, len(checksum))
    return unittest.end(env)

# The unittest library requires that we export the test cases as named test rules,
# but their names are arbitrary and don't appear anywhere.
_t0_test = unittest.make(_smoke_test_impl)

def versions_test_suite(name):
    unittest.suite(name, _t0_test)
