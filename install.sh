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
if [ -f "$CXDEV_INSTALL_DIR/cxdev.sh" ]; then
	echo "CXDEV environment found."
	echo ""
	echo "======================================================================================================"
	echo " You already have CXDEV environment installed."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

if ! command -v unzip 2>&1 > /dev/null; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install unzip on your system using your favourite package manager."
	echo ""
	echo " Restart after installing unzip."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

if ! command -v curl 2>&1 > /dev/null; then
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

if ! command -v sed 2>&1 > /dev/null; then
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

# Create structure
mkdir -p $CXDEV_INSTALL_DIR
mkdir -p $CXDEV_INSTALL_DIR/tmp

# Download
cxdev_zip_file="${CXDEV_INSTALL_DIR}/tmp/cxdev-${CXDEV_VERSION}.zip"
curl --fail --location --progress-bar "${CXDEV_DOWNLOAD_URL}/${CXDEV_VERSION}.zip" > "$cxdev_zip_file"

# check integrity
ARCHIVE_OK=$(unzip -qt "$cxdev_zip_file" | grep 'No errors detected in compressed data')
if [[ -z "$ARCHIVE_OK" ]]; then
	echo "Downloaded zip archive is corrupt. Are you connected to the internet?"
	echo ""
	echo "If problems persist, please ask for help on our Discord server:"
	echo "* easy sign up:"
	echo "  https://discord.gg/y9mVJYVyu4"
	echo "* report on our #help channel:"
	echo "  https://discord.com/channels/1245471991117512754/1245486255295299644"
	exit 1
fi

# extract archive
unzip -qo "$cxdev_zip_file" -d "$CXDEV_INSTALL_DIR/tmp"

# copy over files
cp -r "$CXDEV_INSTALL_DIR/tmp/environment-$CXDEV_VERSION/." "$CXDEV_INSTALL_DIR"

# clean up
rm -rf "$CXDEV_INSTALL_DIR/tmp"

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
  if [[ -z $(grep 'cxdev.sh' "$cxdev_bash_profile") ]]; then
    echo -e "\n$cxdev_init_snippet" >> "$cxdev_bash_profile"
  fi

  touch "$cxdev_zshrc"
  if [[ -z $(grep 'cxdev.sh' "$cxdev_zshrc") ]]; then
      echo -e "\n$cxdev_init_snippet" >> "$cxdev_zshrc"
  fi
else
  touch "${cxdev_bashrc}"
  if [[ -z $(grep 'cxdev.sh' "$cxdev_bashrc") ]]; then
      echo -e "\n$cxdev_init_snippet" >> "$cxdev_bashrc"
  fi
fi