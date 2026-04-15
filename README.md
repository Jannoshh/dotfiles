# dotfiles
ZSH, Tmux, Vim and ssh setup on both local/remote machines.

## Installation

### Step 1
Install dependencies (e.g. oh-my-zsh and related plugins), you can specify options to install specific programs: tmux, zsh, note that your dev-vm will already have tmux and zsh installed so you don't need to provide any options in this case, but you may need to provide these if you are installing locally. 

Installation on a mac machine requires homebrew so install this [from here](https://brew.sh/) first if you haven't already.

```bash
# Install dependencies (remove tmux or zsh if you don't need to install them)
./install.sh --tmux --zsh
```

### Step 2
Deploy (e.g. source aliases for .zshrc, apply oh-my-zsh settings etc..)
```bash
# Remote linux machine
./deploy.sh  
# (optional) Deploy with extra aliases (useful for remote machines where you want specific aliases)
./deploy.sh --aliases=speechmatics
# (optional) Include simple vimrc 
./deploy.sh --vim
```

### Step 3
This set of dotfiles uses the powerlevel10k theme for zsh, this makes your terminal look better and adds lots of useful features, e.g. env indicators, git status etc...

Note that as the provided powerlevel10k config uses special icons it is *highly recommended* you install a custom font that supports these icons. A guide to do that is [here](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k). Alternatively you can set up powerlevel10k to not use these icons (but it won't look as good!)

This repo comes with a preconfigured powerlevel10k theme in [`./config/p10k.zsh`](./config/p10k.zsh) but you can reconfigure this by running `p10k configure` which will launch an interactive window. 


When you get to the last two options below
```
Powerlevel10k config file already exists.
Overwrite ~/git/dotfiles/config/p10k.zsh?
# Press y for YES

Apply changes to ~/.zshrc?
# Press n for NO 
```

## Getting to know these dotfiles

* Any software or command line tools you need, add them to the [install.sh](./install.sh) script. Try adding a new command line tool to the install script.
* Any new plugins or environment setup, add them to the [config/zshrc.sh](./config/zshrc.sh) script.
* Any aliases you need, add them to the [config/aliases.sh](./config/aliases.sh) script. Try adding your own alias to the bottom of the file. For example, try setting `cd1` to your most used git repo so you can just type `cd1` to get to it.
* Any setup you do in a new RunPod, add it to [runpod/runpod_setup.sh](./runpod/runpod_setup.sh).

## Cursor

Cursor `settings.json` and `keybindings.json` (which include the Vim plugin config and hyper-key shortcuts) live in [`./cursor`](./cursor). To apply them:

```bash
# macOS
cp ./cursor/settings.json "$HOME/Library/Application Support/Cursor/User/settings.json"
cp ./cursor/keybindings.json "$HOME/Library/Application Support/Cursor/User/keybindings.json"

# Install the extension list
xargs -n1 cursor --install-extension < ./cursor/extensions.txt
```

To re-export the extension list after installing new ones: `cursor --list-extensions > ./cursor/extensions.txt`.

## iTerm2

Visual-only setup — font, colors, cursor, scrollback, window sizing. No keybindings, commands, or machine-specific state.

- [`./iterm/DynamicProfile-default.json`](./iterm/DynamicProfile-default.json) — an iTerm2 *Dynamic Profile*. Copy or symlink it into `~/Library/Application Support/iTerm2/DynamicProfiles/` and iTerm2 will pick it up automatically on next launch. Appears as the profile named `dotfiles-default`.
- [`./iterm/onedark.itermcolors`](./iterm/onedark.itermcolors) / [`./iterm/onedarker.itermcolors`](./iterm/onedarker.itermcolors) — color schemes, importable via iTerm2 → Settings → Profiles → Colors → Color Presets → Import.

```bash
mkdir -p "$HOME/Library/Application Support/iTerm2/DynamicProfiles"
cp ./iterm/DynamicProfile-default.json "$HOME/Library/Application Support/iTerm2/DynamicProfiles/"
```

## Claude Code

[`./claude/statusline-command.sh`](./claude/statusline-command.sh) is a custom Claude Code status line showing directory, git branch, and context usage. Copy it into `~/.claude/` and reference it from `~/.claude/settings.json`:

```bash
cp ./claude/statusline-command.sh "$HOME/.claude/statusline-command.sh"
chmod +x "$HOME/.claude/statusline-command.sh"
```

A few other settings in `~/.claude/settings.json` worth turning on:

```json
{
  "alwaysThinkingEnabled": true,
  "effortLevel": "high",
  "showThinkingSummaries": true,
  "autoUpdates": true,
  "autoUpdatePlugins": true,
  "includeCoAuthoredBy": false,
  "cleanupPeriodDays": 99999,
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "0"
  },
  "statusLine": {
    "type": "command",
    "command": "/Users/<you>/.claude/statusline-command.sh"
  }
}
```

- `alwaysThinkingEnabled` / `showThinkingSummaries` — keep extended thinking on by default and show a summary in the UI.
- `effortLevel: high` — biases toward more thorough reasoning.
- `includeCoAuthoredBy: false` — drops the `Co-Authored-By: Claude` trailer from commits.
- `cleanupPeriodDays: 99999` — effectively never auto-delete session transcripts.
- `CLAUDE_CODE_ENABLE_TELEMETRY: "0"` — opt out of telemetry.

## Docker image for runpod

To build the docker image for runpod, you can run the following command:

```bash
export DOCKER_DEFAULT_PLATFORM=linux/amd64
docker build -f runpod/johnh_dev.Dockerfile -t jplhughes1/runpod-dev .

# Build with buildx
docker buildx create --name mybuilder --use
docker buildx build --platform linux/amd64 -f runpod/johnh_dev.Dockerfile -t jplhughes1/runpod-dev . --push

```

To test it

```bash
docker run -it -v $PWD/runpod/entrypoint.sh:/dotfiles/runpod/entrypoint.sh -e USE_ZSH=true jplhughes1/runpod-dev /bin/zsh
```

To push it to docker hub

```bash
docker push jplhughes1/runpod-dev
```

