# Update, install new, and remove unwanted Flatpaks
dawn-manage-flatpaks:
  #!/usr/bin/env bash
  set -euo pipefail

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
