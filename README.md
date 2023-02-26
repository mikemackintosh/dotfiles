```
    ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
    ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
    ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
    ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
    ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
    ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```
# <div align="center">mikentosh's dotfiles</div>

### Overview
These dotfiles have been a work in progress for the past few years. The include everything from setup scripts to my vim config and Bash helpers. I am still a Bash fanboy, and have quite a bit of experience with it by this point. I use these across linux and macOS and when possible I always add in support for OS detection.

I do not have any personally identifiable information within my dotfiles, including my `.gitconfig` (and the crowd goes willldddd). This is to allow everyone to consume the configurations while allowing them to have non-breaking changes.

## Installing
To install, clone the repo to `.doftiles` within your home directory.

    git clone https://github.com/mikemackintosh/dotfiles $HOME/.dotfiles

Once cloned, install with:

    $HOME/.dotfiles/install.sh

It will back up existing configuration files and create symlinks to the `.dotfiles/` directory.

## Private Parts
I introduced a `.private/` directory a few years back during the DevOps boom. It had one purpose which was to allow me to keep privileged material available to my Bash environment, but also prevent it from being checked in to Git. This directory is ignored by `.gitignore` but the user-specific configurations are exported to Bash.

This wasn't designed to be uber secure, it was designed to reduce the presence of secrets in source.

#### .gitconfig
To add your `.gitconfig`, add it to `.private/git/config`. My config is as follows:

    [url "git@github.com:"]
        insteadOf = https://github.com/

    [user]
    	email = mike [at] zyp [dot] ip
    	name = Mike Mackintosh

Add your own values here. By not including this by default within the top-level of the package, I am not accidentally attributed to your code. Something I have seen go very wrong in the past.

#### env secrets
Env secrets are the meat and potatoes for a lot of services. Either they use a privileged configuration files, service account or env variables to pass secrets from the tty to the service. There's nothing wrong with this, and that's fine as long as you have good security posture with your device; don't leave it unlocked, strong local password, full disk encryption, and you don't willy nilly download and run code without understanding what it does first.

Under the hood, my dotfiles will source every `*.sh` file in `.private/`. This exports the functions to your Bash environment. This leaves the secrets unset until they are explicitly set by calling a function. This method prevents the secrets from being stored in your `.bash_history` as well.

The scripts have the following format:

    #!/bin/Bash
    function set_thingy_token() {
      [ ! -z  ] && echo "Setting thingy token in env as THINGY_TOKEN..."
      export THINGY_TOKEN=deadb33ff0dad
    }

You can automatically create these files by using a helper method, `addsecret`.

    Usage: addsecret <service> <secret>

For example. `addsecret thingy deadb33ff0dad`, would generate the above file. You would access the secret after running `set_thingy_token` with `$THINGY_TOKEN`.

    curl -H"Authorization: Bearer $THINGY_TOKEN" https://thin.gy/some/privileged/endpoint

And yes, we can all still enjoy a certain level of immaturity from time to time.
