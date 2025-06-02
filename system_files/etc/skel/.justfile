# Justfile for dawn-dx post-install setup

set dotenv-load := true
set shell := ["bash", "-cu"]

# Run everything
default:
    just --list

setup-dawn-dx
    just setup-flatpak
    just setup-ssh
    just clone-repos
    just setup-emacs
    just build-iso

# Add flathub and install Zen browser
setup-flatpak:
    flatpak remote-list | grep -q flathub || \
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    if [[ -f "$HOME/Repos/flatpak_install" ]]; then \
        xargs -a "$HOME/Repos/flatpak_install" -r flatpak --system -y install; \
    fi

# Generate SSH key and add to agent
setup-ssh:
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then \
        ssh-keygen -t ed25519 -C "{{EMAIL}}" -N "" -f "$HOME/.ssh/id_ed25519"; \
    fi
    if [ -z "$$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then \
        eval "$$(ssh-agent -s)"; \
    fi
    fingerprint=$$(ssh-keygen -lf "$$HOME/.ssh/id_ed25519.pub" | awk '{print $$2}')
    ssh-add -l | grep -q "$$fingerprint" || ssh-add "$$HOME/.ssh/id_ed25519"

# Clone repos and install Flatpaks from flatpaks.d
clone-repos:
    if ! gh auth status &>/dev/null; then \
       gh auth login -h github.com -w; \
    fi
    if [[ "$$(gh api user --jq .login)" = "{{USERNAME}}" ]]
        gh repo clone {{USERNAME}}/emacs.d ~/Repos/emacs.d; \
        gh repo clone {{USERNAME}}/nvim.d ~/Repos/nvim.d; \
        gh repo clone {{USERNAME}}/org.d ~/Repos/org.d; \
        gh repo clone {{USERNAME}}/scripts.d ~/Repos/scripts.d; \
        gh repo clone {{USERNAME}}/texmf.d ~/Repos/texmf.d; \
    if
    
# Clone Emacs config and enable Emacs daemon
setup-emacs:
    if [[ -d ~/Repos/emacs.d ]]; then \
        rm -rf ~/.emacs ~/.emacs.d; \
        git clone https://github.com/jamescherti/minimal-emacs.d.git ~/.emacs.d; \
        ln -sf ~/Repos/emacs.d/* ~/.emacs.d; \
        if ! systemctl --user is-enabled emacs.service >/dev/null 2>&1; then \
            systemctl --user enable emacs.service; \
        fi; \
        if ! systemctl --user is-active emacs.service >/dev/null 2>&1; then \
            systemctl --user start emacs.service; \
        fi; \
    fi
    
# Generate custom BlueBuild ISO
build-iso:
    sudo bluebuild generate-iso --iso-name {{IMAGE}}.iso image ghcr.io/{{USERNAME}}/{{IMAGE}}
