# CX DEV Environment

CX Dev Tools is a suite of tools and extensions that provide best-in-class
enhancements of the standard CX products of SAP. The environment is a set
of configurations, alias and scripts that speeds up your local development
with SAP Commerce Cloud tremendously.

## Core features

- Handling of multiple SAP Commerce projects with ease
- Sharing global configuration profiles between projects
- Sharing global dependencies & artefacts between projects
- Automatical local installation process of SAP Commerce
- Reconfiguration of local environment with predefined profiles
- Preconfigured SSL and SSO profiles

## Preconditions

In order to make CX DEV environment work there are a couple of preconditions
that need to be fulfilled:

- SDKman: for handling of Java versions
- nodenv: for handling of node versions

### SDKMAN

CXDEV uses SDKman for managing the Java versions (sapmachine) within the
projects. The installation is 100% automated by using the following prompt:

```
curl -s "https://get.sdkman.io" | bash
```

Afterwards to following lines have to be added to your shell run configuration
(`~/.bashrc` or `~/.zshrc`) file:

```
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
```

### NODENV

CXDEV use nodenv for managing the Node versions within the projects. For the
installation we need to split by operating system, as the automatic setup
process has not been established for all operating systems.

#### Mac OS

We recommend to use the package manager "Homebrew" for the installation.
Homebrew can be installed easily by running the following prompt:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Afterwards we can install the basic tools by running the following commands:

```
brew install coreutils fontutils git git-flow nodenv
```

Note: It is very important to keep nodenv up-to-date on a frequently base.
Another good reason to use a package manager for it. Homebrew updates with:

```
brew update
brew upgrade
```

That's it!

#### WSL unter Windows

For the installation of nodenv within a WSL container a couple of manual steps
are required. The following shows the scripts required as a simply copy-paste
process:

```
# install the base app
git clone https://github.com/nodenv/nodenv.git ~/.nodenv
# add nodenv to system wide bin dir to allow executing it everywhere
sudo ln -vs ~/.nodenv/bin/nodenv /usr/local/bin/nodenv
# compile dynamic bash extension to speed up nodenv - this can safely fail
cd ~/.nodenv
src/configure && make -C src || true
cd ~/
# install plugins
mkdir -p "$(nodenv root)"/plugins
git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build
git clone https://github.com/nodenv/nodenv-aliases.git $(nodenv root)/plugins/nodenv-aliases
# install a node version to bootstrap shims
nodenv install 18.18.2
nodenv global 18
# make shims available system wide
sudo ln -vs $(nodenv root)/shims/* /usr/local/bin/
# make sure everything is working
node --version
npm --version
npx --version
```

## Installation

The installation of CXDEV is also very simple by running the following prompt:

```
curl -s "https://raw.githubusercontent.com/sapcxtools/environment/refs/heads/develop/install.sh" | bash
```

Everything else will be done by the installer.

## Post-Installation topics

In order to use of the CXDEV environment, please make sure that you have
downloaded the installation artefacts from SAP that are references within your
`manifest.json` file.

For more information please refer to the README.md files within the two
required artefacts:

- [SAP Commerce Suite](./dependencies/commercesuite/README.md)
- [SAP Commerce Integration Pack](./dependencies/integrationpack/README.md)

Restart your terminal once again and you are ready to start working with CXDEV!

Simply open your project by running `yLoadProject <PATH>`. You may want to
define an alias for this or even multiple aliases per project:

```
alias yproject1='yLoadProject /path/to/customerA/project1 "Customer Projekt1"
alias yproject2='yLoadProject /path/to/customerB/project2 "Customer Projekt2"
alias yproject3='yLoadProject /path/to/customerC/project3 "Customer Projekt3"
```

Registering these aliases will allow you to simply type `yproject1` instead of
the long command every time.
