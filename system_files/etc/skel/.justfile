# Update, install new, and remove unwanted Flatpaks
dawn-manage-flatpaks:
  #!/usr/bin/env bash
  set -euo pipefail

  # Ensure Flathub remote exists
  echo "=== Setting Up Flathub ==="
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # Config paths (adjust as needed)
  FLATPAK_INSTALL_LIST="$HOME/.config/flatpak_install"

  # Check if files exist
  if [[ ! -f "$FLATPAK_INSTALL_LIST" ]]; then
    echo "Error: Install list not found at '$FLATPAK_INSTALL_LIST'"
    exit 1
  fi

  echo "=== Updating Flatpaks ==="
  
  # Install Flatpaks
  if [[ -s "$FLATPAK_INSTALL_LIST" ]]; then
    echo "Installing Flatpaks..."
    xargs -a "$FLATPAK_INSTALL_LIST" flatpak --system -y install
  else
    echo "No Flatpaks to install."
  fi

  # Update Flatpaks
  echo "Updating Flatpaks..."
  flatpak update -y

  # Clean up unused runtimes
  echo "Cleaning dependencies..."
  flatpak uninstall --unused -y

  echo "=== Update complete! ==="

# Generate ISO file
dawn-generate-iso:
  #!/usr/bin/env bash
  set -euo pipefail

  # Check if bluebuild is already installed
  if ! command -v bluebuild &> /dev/null; then
    echo "Installing bluebuild..."
    podman run --pull always --rm ghcr.io/blue-build/cli:latest-installer | bash
  else
    echo "bluebuild is already installed"
  fi

  # Generate ISO name with current date in YYYYMMDDHHMM format
  ISO_NAME="dawn-$(date +'%Y%m%d%H%M').iso"

  echo "Generating ISO: ${ISO_NAME}"
  sudo bluebuild generate-iso --iso-name "${ISO_NAME}" image ghcr.io/cscarinci/dawn-dx
