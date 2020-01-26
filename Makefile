default: config bat compton config-files dunst git gnupg htop i3 lf mpv pcmanfm pet polybar scripts sxhkd systemd termite tmux vim x11 xfce4 zathura zsh

darwin: config bat config-files git gnupg htop karabiner lf mpv pet scripts tmux vim zsh

bat: config
	stow -R bat

compton: config
	stow -R compton

config-files: config
	stow -R config-files

dunst: config
	stow -R dunst

git: config
	stow -R git

gnupg: config
	stow -R gnupg

htop: config
	stow -R htop

i3: config
	stow -R i3

karabiner: config
	stow -R karabiner

lf: config
	stow -R lf

mpv: config
	stow -R mpv

pcmanfm: config
	stow -R pcmanfm

pet: config
	stow -R pet

polybar: config
	stow -R polybar

scripts: config
	stow -R scripts

sxhkd: config
	stow -R sxhkd

systemd: config
	stow -R systemd

termite: config
	stow -R termite

tmux: config
	stow -R tmux

vim: config
	stow -R vim

x11: config
	stow -R x11

xfce4: config
	stow -R xfce4

zathura: config
	stow -R zathura

zsh: config
	stow -R zsh

config: .stowrc

.stowrc:
	echo "--target=${HOME}" > .stowrc

