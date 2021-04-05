default: config bat config-files git gnupg htop scripts tmux vim zsh alacritty starship doom

linux: config bat compton config-files dunst git gnupg htop i3 lf mpv pcmanfm pet polybar scripts sxhkd systemd termite tmux vim x11 xfce4 zathura zsh alacritty xmonad xmobar starship doom

darwin: config bat config-files git gnupg htop karabiner lf mpv pet scripts tmux vim zsh alacritty doom

bat: config
	stow --no-fold -R bat

compton: config
	stow --no-fold -R compton

config-files: config
	stow --no-fold -R config-files

dunst: config
	stow --no-fold -R dunst

git: config
	stow --no-fold -R git

gnupg: config
	stow --no-fold -R gnupg

htop: config
	stow --no-fold -R htop

i3: config
	stow --no-fold -R i3

karabiner: config
	stow --no-fold -R karabiner

lf: config
	stow --no-fold -R lf

mpv: config
	stow --no-fold -R mpv

pcmanfm: config
	stow --no-fold -R pcmanfm

pet: config
	stow --no-fold -R pet

polybar: config
	stow --no-fold -R polybar

scripts: config
	stow -R scripts

sxhkd: config
	stow --no-fold -R sxhkd

systemd: config
	stow --no-fold -R systemd

termite: config
	stow --no-fold -R termite

tmux: config
	stow --no-fold -R tmux

vim: config
	stow --no-fold -R vim

x11: config
	stow --no-fold -R x11

xfce4: config
	stow --no-fold -R xfce4

zathura: config
	stow --no-fold -R zathura

alacritty: config
	stow --no-fold -R alacritty

zsh: config
	stow --no-fold -R zsh

xmonad: config
	stow --no-fold -R xmonad

xmobar: config
	stow --no-fold -R xmobar

starship: config
	stow --no-fold -R starship

doom: config
	stow --no-fold -R doom

config: .stowrc

.stowrc:
	echo "--target=${HOME}" > .stowrc

