# Helium Flatpak Packaging

This folder contains a Flatpak manifest to package the latest prebuilt Helium Browser binary
from the official GitHub releases.

## Build and Install

```bash
flatpak-builder --user --install --force-clean build-dir com.imputnet.Helium.yml
flatpak run com.imputnet.Helium
```

## Updating

To update to a newer release:
1. The manifest already points to the latest GitHub release.
2. Rebuild with `flatpak-builder --install`.
