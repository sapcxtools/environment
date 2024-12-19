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

function ySyncArtefacts {
	if ! command -v jq > /dev/null; then
		echo -e "${error}[ERROR] In order to parse the manifest, the command line tool jq is required. Please install it and retry!${clear}"
		_ySyncArtefactsHelp
		return 1
	fi

	if [ ! -d "$CXDEVSYNCDIR" ]; then
		echo -e "${error}[ERROR] Environment variable CXDEVSYNCDIR missing or pointing to unknown directory, please check your configuration!${clear}"
		_ySyncArtefactsHelp
		return 2
	fi

	# Determine manifest file (either parameter or workspace)
	MANIFEST_FILE=
	if [[ "$1" != "" ]]; then
		MANIFEST_FILE=$(realpath "$1")
	elif [[ "$WORKSPACE_HOME" != "" ]]; then
		MANIFEST_FILE="$WORKSPACE_HOME/core-customize/manifest.json"
	fi
	if [ ! -f "$MANIFEST_FILE" ]; then
		echo -e "${error}[ERROR] Given manifest file is missing or pointing to unknown location!${clear}"
		_ySyncArtefactsHelp
		return 2
	fi

	# Sync Dependencies with CXDEV sync folder
	if command -v jq > /dev/null; then
		COMMERCESUITE_VERSION=$(jq '.commerceSuiteVersion' -r "$MANIFEST_FILE")
		echo -e "${info}[INFO] Manifest file location to use: $MANIFEST_FILE${clear}"
		echo -e "${info}[INFO] SAP Commerce Suite (in manifest): $COMMERCESUITE_VERSION${clear}"

		if [ -d "$CXDEVSYNCDIR" ]; then
			COMMERCE_ARTEFACT=$(find "$CXDEVSYNCDIR" -type f -iname "*commerce-suite*" -iname "*${COMMERCESUITE_VERSION}*")
			if [ -f "$COMMERCE_ARTEFACT" ]; then
				echo "..... TODO SYMLINK (work in progress) ....."
				# ln -s "$COMMERCE_ARTEFACT" 
			fi
		fi

		echo -e "${info}[INFO] Extension Packs (in manifest):"
		for i in $(jq '.extensionPacks[]?.name' -c -r "$MANIFEST_FILE"); do
			EXTPACK_NAME=$i
			EXTPACK_VERSION=$(jq '.extensionPacks[]? | select(.name == "'${EXTPACK_NAME}'") | .version' -c -r "$MANIFEST_FILE")
			echo -e "${info}       - extension pack: $EXTPACK_NAME (version: $EXTPACK_VERSION)"

			if [ -d "$CXDEVSYNCDIR" ]; then
				EXTPACK_ARTEFACT=$(find "$CXDEVSYNCDIR" -type f -iname "*${EXTPACK_NAME}*" -iname "*${EXTPACK_VERSION}*")
				if [ -f "$EXTPACK_ARTEFACT" ]; then
					echo "..... TODO SYMLINK (work in progress) ....."
					# ln -s "$EXTPACK_ARTEFACT" 
				fi
			fi

		done
		
	fi	
}

function _yUpdateArtefacts {
	# Update Commerce Suite Artefacts
	cd "$CXDEVHOME/dependencies/commercesuite"
	_yRelinkArtefacts
	
	# Update Integration Pack Artefacts
	cd "$CXDEVHOME/dependencies/integrationpack"
	_yRelinkArtefacts
}

function _yRelinkArtefacts {
	# Relink SAP Artefacts with correct versions
	find . -maxdepth 1 -type l | xargs rm -f
	for i in $(ls -A); do
		if [[ $i =~ ^.*\.(zip|ZIP) ]]; then
			ln -s $i $(echo $i | sed -E 's/([A-Z]+)([0-9]{4}).*_([0-9]{1,3})-.*(ZIP|zip)/\1-\2.\3.zip/g')
		fi
	done
}

function _ySyncArtefactsHelp {
	echo
	echo -e         "        usage: ySyncArtefacts path"
	echo 
	echo -e         "${bold}OPTION SUMMARY${reset}"
	echo 
	echo -e         "        path            the path to a ${bold}'manifest.json'${reset} file, typically the root directory"
	echo -e         "                        of the project's git repository used by SAP!"
	echo -e "${reset}${clear}"
}