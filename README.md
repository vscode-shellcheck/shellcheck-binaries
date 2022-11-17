# ShellCheck binaries for the VS Code extension

ShellCheck binaries distributed in `.tar.gz` format for Linux and macOS, including M1 Macs. Used by [ShellCheck VS Code extension](https://github.com/vscode-shellcheck/vscode-shellcheck).

## Why?

- ShellCheck doesn't officially provide binaries for M1 Macs.
- ShellCheck ships binaries packaged in `.tar.xz` format, in which [`bindl`](https://github.com/felipecrs/bindl/issues/217) doesn't support.

## How to generate more binaries?

Simply push a new tag to this repository in the format `v*.*.*` matching the [ShellCheck version](https://github.com/koalaman/shellcheck/releases). The CI will generate binaries for all supported platforms and upload them to the release.
