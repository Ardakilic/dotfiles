# dotfiles

Minimal dotfiles for my daily setup.

Nothing fancy, just practical improvements.

---

## Environment

- macOS
- zsh
- WezTerm

---

## Requirements

Install with Homebrew:

- wezterm@nightly
- curl
- eza
- bat
- jaq
- powerlevel10k
- zsh-syntax-highlighting
- zsh-autosuggestions

---

## Font

- Monolisa (Nerd Font patched)

Needed for icons and prompt.

---

## Setup

Clone:

```sh
git clone https://github.com/Ardakilic/dotfiles ~/.dotfiles
````

Copy config:

```sh
cp ~/.dotfiles/.zshrc ~/.zshrc
cp ~/.dotfiles/.wezterm.lua ~/.wezterm.lua
```

Reload:

```sh
source ~/.zshrc
```

---

## Notes

* Built for macOS (Homebrew paths)
* Some parts assume WezTerm
* Not portable without tweaks