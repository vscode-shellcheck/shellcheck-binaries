# ShellCheck binaries for the VS Code extension

ShellCheck binaries repackaged in `.tar.gz` format.

## Why?

- ShellCheck ships binaries packaged in `.tar.xz` format, and [`bindl`](https://github.com/felipecrs/bindl) had no support for `.tar.xz` (but now it does).

## How to add a new version?

Simply add the new version to the [matrix](https://github.com/vscode-shellcheck/shellcheck-binaries/blob/babb67a25637dabc4c9651e358be0b7a25dcdfb9/.github/workflows/ci.yaml#L41).

## Development

Install dependencies:

```sh
npm ci
```

### Check

```sh
npm run check
```

### Fix

```sh
npm run fix
```
