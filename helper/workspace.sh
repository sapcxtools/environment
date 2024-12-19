# Define ANSI colors and markers
clear="\e[0m"
error="\e[31m"
warn="\e[33m"
info="\e[32m"
debug="\e[34m"

bold="\e[1m"
italic="\e[3m"
underline="\e[4m"
blink="\e[5m"
reset="\e[21m\e[22m\e[23m\e[24m\e[25m\e[26m\e[27m\e[28m\e[29m"

# Global configurations
GLOBAL_DEPENDENCIES="$CXDEVHOME/dependencies"
GLOBAL_CERTIFICATES="$CXDEVHOME/certificates"
GLOBAL_CONFIGRUATIONS="$CXDEVHOME/configuration"

function yLoadWorkspace {
	MODE=normal
	if [[ "true" == "$3" ]]; then
		MODE=silent
	fi
	alias echo='[[ "$MODE" != "silent" ]] && echo'

	[[ "$MODE" != "silent" ]] && echo -e "${info}[INFO] CXDEV Tools Environment Setup for SAP Commerce Cloud${clear}"

	if [[ "" == "$1" ]]; then
		echo -e "${error}[ERROR] CXDEV Tools cannot apply SAP Commerce workspace settings due to missing ${bold}path${reset} parameter!${clear}"
		_yLoadWorkspaceHelp
		return 1
	fi

	if [ ! -d "$1" ]; then
		echo -e "${error}[ERROR] CXDEV Tools cannot find a SAP Commerce workspace at ${underline}$1${reset}.${clear}"
		_yLoadWorkspaceHelp
		return 1
	fi

	# Workspace information
	WORKSPACE_HOME=$(realpath "$1")
	WORKSPACE_NAME=
	if [[ "" != "$2" ]]; then
		WORKSPACE_NAME=$2
	else 
		WORKSPACE_NAME=`/usr/bin/basename $1`
	fi

	# Link global dependencies
	if [ -d "$GLOBAL_DEPENDENCIES" ]; then
		if [ -L "$WORKSPACE_HOME/dependencies" ] && [[ $(readlink "$WORKSPACE_HOME/dependencies") == "$GLOBAL_DEPENDENCIES" ]]; then
			echo -e "${info}[INFO] Global dependencies folder already linked, no optimization needed.${clear}"
		else
			if [ -d "$WORKSPACE_HOME/dependencies" ]; then 
				echo -e "${info}[INFO] Relink dependencies to global dependencies folder to save disk space!${clear}"
				rm -Rf "$WORKSPACE_HOME/dependencies"
			else
				echo -e "${info}[INFO] Link dependencies to global dependencies folder to save disk space!${clear}"
			fi
			ln -s "$GLOBAL_DEPENDENCIES" "$WORKSPACE_HOME/dependencies"
		fi
	fi
	
	# Link global certificates
	if [ -d "$GLOBAL_CERTIFICATES" ]; then
		if [ -L "$WORKSPACE_HOME/certificates" ] && [[ $(readlink "$WORKSPACE_HOME/certificates") == "$GLOBAL_CERTIFICATES" ]]; then
			echo -e "${info}[INFO] Global certificates folder already linked, no optimization needed.${clear}"
		else
			if [ -d "$WORKSPACE_HOME/certificates" ]; then 
				echo -e "${info}[INFO] Use local certificates folder from workspace configuration! (Remove and rerun to use global certificates instead)${clear}"
			else 
				if [ -L "$WORKSPACE_HOME/certificates" ]; then 
					echo -e "${info}[INFO] Relink certificates to global certificates folder!${clear}"
					rm -Rf "$WORKSPACE_HOME/certificates"
				else
					echo -e "${info}[INFO] Link certificates to global certificates folder!${clear}"
				fi
				ln -s "$GLOBAL_CERTIFICATES" "$WORKSPACE_HOME/certificates"
			fi
		fi
	fi
	
	# Load Java environment
	CXDEV_JAVA_VERSION=
	CXDEV_JAVA_VERSION_FILE=$(find "$WORKSPACE_HOME" -iname '.java-version' -maxdepth 3 | head -1)
	if [ -f "$CXDEV_JAVA_VERSION_FILE" ]; then
		CXDEV_JAVA_VERSION=$(cat "$CXDEV_JAVA_VERSION_FILE")
		echo -e "${info}[INFO] Java version ${bold}$CXDEV_JAVA_VERSION${reset} defined in: ${underline}$CXDEV_JAVA_VERSION_FILE${reset}${clear}"
		SDKMAN_JAVA_HOME=$(sdk home java $CXDEV_JAVA_VERSION)
		if [ ! -d "$SDKMAN_JAVA_HOME" ]; then
			echo -e "${info}[INFO] Java version ${bold}$CXDEV_JAVA_VERSION${reset} not available! Trying to install with SDKman:${clear}"
			echo -ne "${debug}"
			sdk install java $CXDEV_JAVA_VERSION
			echo -ne "${clear}"

			SDKMAN_JAVA_HOME=$(sdk home java $CXDEV_JAVA_VERSION)
			if [ ! -d "$SDKMAN_JAVA_HOME" ]; then
				echo -e "${error}[ERROR] Java version ${bold}$CXDEV_JAVA_VERSION${reset} cannot be installed!${clear}"
				return 2
			else
				echo -e "${info}[INFO] Java version ${bold}$CXDEV_JAVA_VERSION${reset} successfully installed with SDKman.${clear}"
			fi
		fi

		echo -e "${info}[INFO] Loading Java version ${bold}$CXDEV_JAVA_VERSION${reset} using SDKman.${clear}"
		sdk use java $CXDEV_JAVA_VERSION 2>&1 >> /dev/null
	else
		echo -e "${warn}[WARN] No Java version configured within workspace, missing file: ${underline}.java-version${clear}"
		if command -v java > /dev/null; then
			echo -e "${warn}[WARN] Fallback to Java version configured in system environment!${clear}"
			CXDEV_JAVA_VERSION=$(java -version 2>&1 | head -1)
			echo -e "${info}[INFO] Detected Java version is ${bold}$CXDEV_JAVA_VERSION${clear}"
			echo -e "${warn}[WARN] ${blink}Please verify that the Java version is the correct for your repository!${clear}"
		else
			echo -e "${error}[ERROR] Cannot fallback to Java version of system, Java was not found!${clear}"
			return 2
		fi
	fi

	# Load node environment
	CXDEV_NODE_VERSION=
	CXDEV_NODE_VERSION_FILE=$(find "$WORKSPACE_HOME" -iname '.node-version' -maxdepth 3 | head -1)
	if [ -f "$CXDEV_NODE_VERSION_FILE" ]; then
		CXDEV_NODE_VERSION=$(cat "$CXDEV_NODE_VERSION_FILE")
		echo -e "${info}[INFO] Node version ${bold}$CXDEV_NODE_VERSION${reset} defined in: ${underline}$CXDEV_NODE_VERSION_FILE${clear}"
		if [ -z $(nodenv version-name) ]; then
			echo -e "${warn}[WARN] Node version ${bold}$CXDEV_NODE_VERSION${reset} not available! Trying to install with nodenv:${clear}"
			echo -ne "${debug}"
			nodenv install $CXDEV_NODE_VERSION
			echo -ne "${clear}"

			if [ -z $(nodenv version-name) ]; then
				echo -e "${warn}[WARN] Node version ${bold}$CXDEV_NODE_VERSION${reset} cannot be installed!${clear}"
				return 2
			else
				echo -e "${info}[INFO] Node version ${bold}$CXDEV_NODE_VERSION${reset} successfully installed with nodenv.${clear}"
			fi
		fi

		echo -e "${info}[INFO] Loading Node version ${bold}$CXDEV_NODE_VERSION${reset} using nodenv.${clear}"
		nodenv shell $CXDEV_NODE_VERSION 2>&1 >> /dev/null
	elif [ -d "$WORKSPACE_HOME/js-storefront" ]; then
		echo -e "${warn}[WARN] No node version configured within workspace, missing file: ${underline}.node-version${clear}"
		echo -e "${warn}[WARN] Fallback to node version configured in system environment!${clear}"
		CXDEV_NODE_VERSION=$(nodenv version-name)
		echo -e "${info}[INFO] Detected node version is ${bold}$CXDEV_NODE_VERSION${clear}"
		echo -e "${warn}[WARN] ${blink}Please verify that the node version is the correct for your project!${clear}"
	fi

	# Detect platform structure (supported are classic, embedded or CCv2)
	PLATFORM_HOME=$WORKSPACE_HOME/server/hybris/bin/platform
	PLATFORM_HOME_ALTERNATIVE=$WORKSPACE_HOME/hybris/bin/platform
	if [ -d "$PLATFORM_HOME_ALTERNATIVE" ]; then
		PLATFORM_HOME=$PLATFORM_HOME_ALTERNATIVE
	fi
	PLATFORM_HOME_CCV2=$WORKSPACE_HOME/core-customize/hybris/bin/platform
	if [ -d "$WORKSPACE_HOME/core-customize" ]; then
		echo -e "${info}[INFO] Cloud repository structure detected!${clear}"
		PLATFORM_HOME=$PLATFORM_HOME_CCV2

		ySyncArtefacts "$WORKSPACE_HOME/core-customize/manifest.json"
	fi

	# Load SAP Commerce platform environment
	if [ -d "$PLATFORM_HOME" ]; then
		echo -e "${info}[INFO] SAP Commerce installation found at: ${underline}$PLATFORM_HOME${clear}"

		# Load Ant environment
		echo -e "${info}[INFO] Loading Apache ant settings from platform.${clear}"
		echo -ne "${debug}"
		cd "$PLATFORM_HOME"
		source setantenv.sh | indent
		echo -ne "${clear}"

		# Load SAP Commerce configuration
		echo -e "${info}[INFO] Environment configuration found at: ${underline}$PLATFORM_HOME/env.properties${clear}"
		RELATIVE_CONFIG_DIR=$(cat "$PLATFORM_HOME/env.properties" | grep HYBRIS_CONFIG_DIR | sed "s#HYBRIS_CONFIG_DIR=\\\${platformhome}#.#" | tr -d '\r\n')
		HYBRIS_CONFIG_DIR=$(realpath "$PLATFORM_HOME/$RELATIVE_CONFIG_DIR")
		echo -e "${info}[INFO] Using configuration folder at: ${underline}$HYBRIS_CONFIG_DIR${clear}"
		if [ -d "$HYBRIS_CONFIG_DIR/local-config" ]; then
			HYBRIS_OPT_CONFIG_DIR="$HYBRIS_CONFIG_DIR/local-config"
			echo -e "${info}[INFO] Additional local configuration found at: ${underline}$HYBRIS_OPT_CONFIG_DIR${clear}"
			
			# Relink global configuration profiles
			ENABLEDPROFILESHOME=$GLOBAL_CONFIGRUATIONS/enabled
			echo -e "${info}[INFO] Relink global configuration profiles from: ${underline}$ENABLEDPROFILESHOME${clear}"

			[ -f "$HYBRIS_OPT_CONFIG_DIR/80-local.properties" ] && rm -f "$HYBRIS_OPT_CONFIG_DIR/80-local.properties"
			[ -f "$HYBRIS_OPT_CONFIG_DIR/81-local.properties" ] && rm -f "$HYBRIS_OPT_CONFIG_DIR/81-local.properties"
			[ -f "$HYBRIS_OPT_CONFIG_DIR/82-local.properties" ] && rm -f "$HYBRIS_OPT_CONFIG_DIR/82-local.properties"
			[ -f "$HYBRIS_OPT_CONFIG_DIR/83-local.properties" ] && rm -f "$HYBRIS_OPT_CONFIG_DIR/83-local.properties"
			[ -f "$HYBRIS_OPT_CONFIG_DIR/84-local.properties" ] && rm -f "$HYBRIS_OPT_CONFIG_DIR/84-local.properties"
			[ -f "$HYBRIS_OPT_CONFIG_DIR/85-local.properties" ] && rm -f "$HYBRIS_OPT_CONFIG_DIR/85-local.properties"
			[ -f "$HYBRIS_OPT_CONFIG_DIR/86-local.properties" ] && rm -f "$HYBRIS_OPT_CONFIG_DIR/86-local.properties"
			[ -f "$HYBRIS_OPT_CONFIG_DIR/87-local.properties" ] && rm -f "$HYBRIS_OPT_CONFIG_DIR/87-local.properties"
			[ -f "$HYBRIS_OPT_CONFIG_DIR/88-local.properties" ] && rm -f "$HYBRIS_OPT_CONFIG_DIR/88-local.properties"
			[ -f "$HYBRIS_OPT_CONFIG_DIR/89-local.properties" ] && rm -f "$HYBRIS_OPT_CONFIG_DIR/89-local.properties"
			
			if [ -d "$ENABLEDPROFILESHOME" ]; then
				find "$ENABLEDPROFILESHOME" -type l -iname "8*-local.properties" | xargs -I {} cp -R {} "$HYBRIS_OPT_CONFIG_DIR"
			fi
		else
			echo -e "${info}[INFO] No optional ${bold}local-config${reset} folder found at in your config folder.${clear}"
			echo -e "${info}[INFO] ${blink}Consider updating your workspace to make use of local-config folder!${clear}"
			HYBRIS_OPT_CONFIG_DIR=
		fi

		# Exchange SAP JCO Library (if necessary)
		SAPJCO_LIB_PATH=$(realpath "$PLATFORM_HOME/../modules/sap-framework-core/sapcorejco/lib")
		if [ -d "$SAPJCO_LIB_PATH" ]; then
			OS=$(/usr/bin/uname)
			CPU_ARCHITECTURE=$(/usr/bin/uname -m)
			echo -e "${info}[INFO] SAP JCO Library found at: ${underline}$SAPJCO_LIB_PATH${clear}"
			if [[ "$OS" == "Darwin" && "$CPU_ARCHITECTURE" == "arm64" ]]; then
				echo -e "${info}[INFO] $OS/$CPU_ARCHITECTURE detected, replacing JCO Library with version from: ${underline}$GLOBAL_DEPENDENCIES/sapjco/current${clear}"
				rm -f "$SAPJCO_LIB_PATH/sapjco3.jar"
				rm -f "$SAPJCO_LIB_PATH/sapjcomanifest.mf"
				rm -f "$SAPJCO_LIB_PATH/libsapjco3.dylib"
				ln -s "$GLOBAL_DEPENDENCIES/sapjco/current/sapjco3.jar" "$SAPJCO_LIB_PATH"
				ln -s "$GLOBAL_DEPENDENCIES/sapjco/current/sapjcomanifest.mf" "$SAPJCO_LIB_PATH"
				ln -s "$GLOBAL_DEPENDENCIES/sapjco/current/libsapjco3.dylib" "$SAPJCO_LIB_PATH"
			fi
			if [[ "$OS" == "Linux" && "$CPU_ARCHITECTURE" == "arm64" ]]; then
				echo -e "${info}[INFO] $OS/$CPU_ARCHITECTURE detected, replacing JCO Library with version from: ${underline}$GLOBAL_DEPENDENCIES/sapjco/current${clear}"
				rm -f "$SAPJCO_LIB_PATH/sapjco3.jar"
				rm -f "$SAPJCO_LIB_PATH/sapjcomanifest.mf"
				rm -f "$SAPJCO_LIB_PATH/libsapjco3.so"
				ln -s "$GLOBAL_DEPENDENCIES/sapjco/current/sapjco3.jar" "$SAPJCO_LIB_PATH"
				ln -s "$GLOBAL_DEPENDENCIES/sapjco/current/sapjcomanifest.mf" "$SAPJCO_LIB_PATH"
				ln -s "$GLOBAL_DEPENDENCIES/sapjco/current/libsapjco3.so" "$SAPJCO_LIB_PATH"
			fi
		fi
	else
		echo -e "${warn}[WARN] No hybris installation found at: ${underline}$PLATFORM_HOME${clear}"
		PLATFORM_HOME=
		HYBRIS_CONFIG_DIR=
		HYBRIS_OPT_CONFIG_DIR=
	fi

	# Load storefront configuration
	STOREFRONT_HOME=
	if [ -d "$WORKSPACE_HOME/js-storefront" ]; then
		STOREFRONT_HOME=$(find "$WORKSPACE_HOME/js-storefront" -type d -not -iname "js-storefront" -not -iname "bootstrap" -not -iname "build" -maxdepth 1)
		echo -e "${info}[INFO] Composable storefront found at: ${underline}$STOREFRONT_HOME${clear}"
	fi

	# Switch to workspace
	cd "$WORKSPACE_HOME"
	echo -e "${info}[INFO] Switched to workspace location: ${underline}$WORKSPACE_HOME${clear}"
	echo -e "${info}[INFO] CXDEV Tools Environment Setup finished.${clear}"
	echo -n -e "\033]0;${WORKSPACE_NAME}\007"

	yShowWorkspace | indent
	
	# Export environment variables
	export WORKSPACE_HOME
	export WORKSPACE_NAME
	export CXDEV_JAVA_VERSION
	export CXDEV_JAVA_VERSION_FILE
	export CXDEV_NODE_VERSION
	export CXDEV_NODE_VERSION_FILE
	export PLATFORM_HOME
	export HYBRIS_CONFIG_DIR
	export HYBRIS_OPT_CONFIG_DIR
	export STOREFRONT_HOME
}

function yShowWorkspace {
	echo -e "${info}"
	echo -e "${bold}Workspace Overview${reset}"
	echo -e "==============================================================================="
	echo -e "${bold}Workspace name${reset}           ${italic}$WORKSPACE_NAME${reset}"
	echo -e "${bold}Workspace path${reset}           ${underline}$WORKSPACE_HOME${reset}"
	echo -e "==============================================================================="
	echo -e "${bold}Platform home${reset}            ${underline}$PLATFORM_HOME${reset}"
	echo -e "${bold}Hybris Configuration${reset}     ${underline}$HYBRIS_OPT_CONFIG_DIR${reset}"
	echo -e "${bold}Optional Configuration${reset}   ${underline}$HYBRIS_OPT_CONFIG_DIR${reset}"
	echo -e "${bold}Storefront home${reset}          ${underline}$STOREFRONT_HOME${reset}"
	echo -e "==============================================================================="
	if command -v jq > /dev/null; then
		MANIFEST_FILE=$WORKSPACE_HOME/core-customize/manifest.json
		if [ -f "$MANIFEST_FILE" ]; then
			COMMERCESUITE_VERSION=$(jq '.commerceSuiteVersion' -r $MANIFEST_FILE)
			echo -e "SAP Commerce Suite (in manifest): $COMMERCESUITE_VERSION${reset}"
			echo -e "Extension Packs (in manifest):"
			for i in $(jq '.extensionPacks[]?.name' -c -r "$MANIFEST_FILE"); do
				EXTPACK_NAME=$i
				EXTPACK_VERSION=$(jq '.extensionPacks[]? | select(.name == "'${EXTPACK_NAME}'") | .version' -c -r "$MANIFEST_FILE")
				echo -e " - extension pack: $EXTPACK_NAME (version: $EXTPACK_VERSION)"
			done
			echo -e "==============================================================================="
		fi
	fi
	echo -e "${bold}Java version (detected)${reset}  ${italic}$CXDEV_JAVA_VERSION${reset}"
	echo -e "${bold}Java version file${reset}        ${italic}$CXDEV_JAVA_VERSION_FILE${reset}"
	echo -e "${bold}Node version (detected)${reset}  ${italic}$CXDEV_NODE_VERSION${reset}"
	echo -e "${bold}Node version file${reset}        ${italic}$CXDEV_NODE_VERSION_FILE${reset}"
	echo -e "==============================================================================="
	echo -ne "${clear}"
}

function _yLoadWorkspaceHelp {
	echo
	echo -e         "        usage: yLoadWorkspace path [name]"
	echo 
	echo -e         "${bold}OPTION SUMMARY${reset}"
	echo 
	echo -e         "        path            the workspace path, typically the root directory"
	echo -e         "                        of the project's git repository used by SAP!"
	echo -e         "                        This folder should contain the root directories"
	echo -e         "                        ${bold}'core-customize'${reset} and optional 'js-storefront'."
	echo -e         "        name            the workspace name (optional parameter)"
	echo -e         "                        the name is used"
	echo -e         "                        - within the log messages"
	echo -e         "                        - title of the terminal window"
	echo -e "${reset}${clear}"
}

function indent {
	sed 's/^/       /'
}