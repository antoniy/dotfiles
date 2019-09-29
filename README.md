# Dotfiles

Dotfiles are the customization files that are used to personalize your Linux or other Unix-based system. You can tell that a file is a dotfile because the name of the file will begin with a period--a dot! The period at the beginning of a filename or directory name indicates that it is a hidden file or directory. This repository contains my personal dotfiles. They are stored here for convenience so that I may quickly access them on new machines or new installs. Also, others may find some of my configurations helpful in customizing their own dotfiles.

## Usage

Config files are placed in bare Git repository. This eliminates the need of tooling, symlinks or other special configuration. Config file structure is preserved exactly as it is originally on the system.

### New repository from scratch

For initial initialization, we need to create the repository and configure a few minor things:

Create new bare Git repository
```shell
git init --bare $HOME/.cfg
```

Add an alias Git command to access our new repository and configure it to use home directory as a working tree. The command below pipes the output to `.zshrc` but feel free to adjust for your prefered shell.
```shell
echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.zshrc
```

Configure our new repo to now show *untracked* files in status. This is useful as our entire home directory is our working tree and we probably don't want to see every single file we have as an untracked one.
```shell
config config --local status.showUntrackedFiles no
```

Afterwards adding configuration to the repository is trivial.
```shell
config status
config add .vimrc
config commit -m "Add vimrc"
config add .bashrc
config commit -m "Add bashrc"
config push
```
### Install on a new system

We'll need to create our alias again:
```shell
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

We'll also add `.gitignore` file that will indicate that we should ignore the repo itself.
```shell
echo ".cfg" >> .gitignore
```

Then we should clone the repo itself.
```shell
git clone --bare <repo-url> $HOME/.cfg
```

We need to configure the repo to not show untracked files.
```shell
config config --local status.showUntrackedFiles no
```

And then it's a matter of working with standard Git though we'll do it through our `config` alias.
```shell
config checkout
config status
config add .vimrc
config commit -m "Add vimrc"
```

Inspiration: https://www.atlassian.com/git/tutorials/dotfiles

## ZSH

### Dependencies

* [oh-my-zsh](https://ohmyz.sh/) - You need to place oh-my-zsh into `~/.oh-my-zsh` directory
* [fzf](https://github.com/junegunn/fzf) - A command-line fuzzy finder 
* [fzf-extras](https://github.com/atweiden/fzf-extras) - Key bindings from fzf
* [exa](https://the.exa.website/) - A modern replacement for *ls*

# License

The files and scripts in this repository are licensed under the MIT License, which is a very permissive license allowing you to use, modify, copy, distribute, sell, give away, etc. the software.  In other words, do what you want with it.  The  only requirement with the MIT License is that the license and copyright notice must be provided with the software.

