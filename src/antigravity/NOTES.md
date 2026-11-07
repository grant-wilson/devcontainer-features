## Usage

Add this feature to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/grant-wilson/devcontainer-features/antigravity:1": {}
  }
}
```

The feature installs Google's standalone Antigravity CLI as `agy` in
`/usr/local/bin`, available to root and the remote container user. It downloads
the official Linux release for amd64 or arm64 and requires a Debian/Ubuntu-based
image. No desktop environment or Node.js installation is required.

To pin a CLI release, set the feature's `version` option, for example
`"version": "1.5.3"`. The default is `latest`.

After rebuilding the container, run `agy` in your workspace as your normal
container user and complete the interactive trust and Google sign-in flow.
Authentication is not performed during the image build. For remote/SSH sessions,
the CLI provides an authorization URL to open locally; see the
[official CLI documentation](https://antigravity.google/docs/cli/overview).

## VS Code and the Antigravity desktop application

Use `agy` from VS Code's integrated terminal. This feature installs only the
standalone CLI, not Google's separate Antigravity desktop application.

No official standalone Antigravity VS Code extension was verified, so the
feature does not declare one in `customizations.vscode.extensions`. It does not
substitute Gemini Code Assist or an unofficial extension.
