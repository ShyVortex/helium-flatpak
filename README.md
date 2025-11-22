# Helium Flatpak

This folder contains a Flatpak manifest to package the latest prebuilt [Helium Browser](https://github.com/imputnet/helium) binary
from the official [GitHub releases](https://github.com/imputnet/helium-linux/releases).

## Build and Install

You can build and install the Flatpak locally:

```bash
flatpak-builder --user --install --force-clean build-dir computer.helium.Helium.yml
flatpak run computer.helium.Helium
```

## Install from repo
Alternatively, you can install Helium directly from the Flatpak repository:

```bash
flatpak remote-add --user --no-gpg-verify helium-repo https://shyvortex.github.io/helium-flatpak/
flatpak install helium-repo computer.helium.Helium
flatpak run computer.helium.Helium
```
