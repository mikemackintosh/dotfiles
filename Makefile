install:
	./install.sh

me:
	ln -s $(HOME)/.dotfiles/private/git/config $(HOME)/.private/git/config

update:
	git pull

upload:
	git push
