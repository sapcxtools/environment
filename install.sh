#!/bin/bash
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# Global variables
export CXDEV_DOWNLOAD_URL="https://github.com/sapcxtools/environment/archive/refs/tags/"
export CXDEV_VERSION="1.0.0"
export CXDEV_INSTALL_DIR="$HOME/.cxdev"

# Sanity checks
if [ -d "$CXDEV_INSTALL_DIR" ]; then
	echo "CXDEV environment found."
	echo ""
	echo "======================================================================================================"
	echo " You already have CXDEV environment installed."
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for unzip..."
if ! command -v unzip > /dev/null; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install unzip on your system using your favourite package manager."
	echo ""
	echo " Restart after installing unzip."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for curl..."
if ! command -v curl > /dev/null; then
	echo "Not found."
	echo ""
	echo "======================================================================================================"
	echo " Please install curl on your system using your favourite package manager."
	echo ""
	echo " Restart after installing curl."
	echo "======================================================================================================"
	echo ""
	exit 1
fi


echo "Looking for sed..."
if [ -z $(command -v sed) ]; then
    echo "Not found."
    echo ""
    echo "======================================================================================================"
    echo " Please install sed on your system using your favourite package manager."
    echo ""
    echo " Restart after installing sed."
    echo "======================================================================================================"
    echo ""
    exit 1
fi

echo "Looking for SDKman..."
if ! command -v sdk > /dev/null; then
    echo "Not found."
    echo ""
    echo "======================================================================================================"
    echo " Please install SDKman on your system using:"
    echo ""
    echo " curl -s "https://get.sdkman.io" | bash"
    echo ""
    echo " Restart after installing SDKman."
    echo "======================================================================================================"
    echo ""
    exit 1
fi

echo "Looking for nodenv..."
if ! command -v nodenv > /dev/null; then
    echo "Not found."
    echo ""
    echo "======================================================================================================"
    echo " Please install nodenv on your system using your favourite package manager or type:"
    echo ""
    echo " curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash"
    echo ""
    echo " Restart after installing nodenv."
    echo "======================================================================================================"
    echo ""
    exit 1
fi

# Create structure
mkdir -p $CXDEV_INSTALL_DIR
mkdir -p $CXDEV_INSTALL_DIR/tmp

# Download
echo "* Downloading..."
cxdev_zip_file="${CXDEV_INSTALL_DIR}/tmp/cxdev-${CXDEV_VERSION}.zip"
curl --fail --location --progress-bar "${CXDEV_DOWNLOAD_URL}/v${CXDEV_VERSION}.zip" > "$cxdev_zip_file"

# check integrity
echo "* Checking archive integrity..."
ARCHIVE_OK=$(unzip -qt "$cxdev_zip_file" | grep 'No errors detected in compressed data')
if [[ -z "$ARCHIVE_OK" ]]; then
	echo "Downloaded zip archive corrupt. Are you connected to the internet?"
	echo ""
	echo "If problems persist, please ask for help on our Discord server:"
	echo "* easy sign up:"
	echo "  https://discord.gg/y9mVJYVyu4"
	echo "* report on our #help channel:"
	echo "  https://discord.com/channels/1245471991117512754/1245486255295299644"
	exit
fi

# extract archive
echo "* Extracting archive..."
unzip -qo "$cxdev_zip_file" -d "$CXDEV_INSTALL_DIR"

# clean up
echo "* Cleaning up..."
rm -rf "$CXDEV_INSTALL_DIR/tmp"

echo ""

# Link in profile
cxdev_init_snippet=$(cat <<-END
# CXDEV Environment
source "$CXDEV_INSTALL_DIR/cxdev.sh"
#export CXDEVSYNCDIR="/mnt/sapartefacts"
END
)
cxdev_bash_profile="${HOME}/.bash_profile"
cxdev_profile="${HOME}/.profile"
cxdev_bashrc="${HOME}/.bashrc"
cxdev_zshrc="${ZDOTDIR:-${HOME}}/.zshrc"

if [[ "$(uname)" == "Darwin" ]]; then
  touch "$cxdev_bash_profile"
  echo "Attempt update of login bash profile on OSX..."
  if [[ -z $(grep 'cxdev.sh' "$cxdev_bash_profile") ]]; then
    echo -e "\n$cxdev_init_snippet" >> "$cxdev_bash_profile"
    echo "Added cxdev init snippet to $cxdev_bash_profile"
  fi

  echo "Attempt update of zsh profile..."
  touch "$cxdev_zshrc"
  if [[ -z $(grep 'cxdev.sh' "$cxdev_zshrc") ]]; then
      echo -e "\n$cxdev_init_snippet" >> "$cxdev_zshrc"
      echo "Added cxdev init snippet to ${cxdev_zshrc}"
  fi
else
  echo "Attempt update of interactive bash profile on regular UNIX..."
  touch "${cxdev_bashrc}"
  if [[ -z $(grep 'cxdev.sh' "$cxdev_bashrc") ]]; then
      echo -e "\n$cxdev_init_snippet" >> "$cxdev_bashrc"
      echo "Added cxdev init snippet to $cxdev_bashrc"
  fi
fi

echo -e "\n\n\nAll done!\n\n"
