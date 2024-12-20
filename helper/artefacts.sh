function ySyncArtefacts {
	if ! command -v jq > /dev/null; then
		echo -e "${_yerror}[ERROR] In order to parse the manifest, the command line tool jq is required. Please install it and retry!${_yclear}"
		return 1
	fi

	# Determine manifest file (either parameter or workspace)
	MANIFEST_FILE=
	if [[ "$1" != "" ]]; then
		MANIFEST_FILE=$(realpath "$1")
	elif [[ "$CXDEV_WORKSPACE_HOME" != "" ]]; then
		MANIFEST_FILE="$CXDEV_WORKSPACE_HOME/core-customize/manifest.json"
	fi
	if [ ! -f "$MANIFEST_FILE" ]; then
		echo -e "${_yerror}[ERROR] Given manifest file is missing or pointing to unknown location!${_yclear}"
		_ySyncArtefactsHelp
		return 2
	fi

	# Sync Dependencies with CXDEV sync folder
	if command -v jq > /dev/null; then
		COMMERCESUITE_VERSION=$(jq '.commerceSuiteVersion' -r "$MANIFEST_FILE")
		echo -e "${_yinfo}[INFO] Manifest file location to use: ${_yunderline}$MANIFEST_FILE${_yclear}"
		echo -e "${_yinfo}[INFO] SAP Commerce Suite version in manifest: ${_ybold}$COMMERCESUITE_VERSION${_yclear}"
		_ySyncArtefact "commerce-suite" "$COMMERCESUITE_VERSION"

		echo -e "${_yinfo}[INFO] Processing extension packs in manifest"
		for i in $(jq '.extensionPacks[]?.name' -c -r "$MANIFEST_FILE"); do
			EXTPACK_NAME=$i
			EXTPACK_VERSION=$(jq '.extensionPacks[]? | select(.name == "'${EXTPACK_NAME}'") | .version' -c -r "$MANIFEST_FILE")
			echo -e "${_yinfo}[INFO] Found extension pack: ${_ybold}$EXTPACK_NAME${_yreset} (version: ${_ybold}$EXTPACK_VERSION${_yreset})${_yclear}"
			_ySyncArtefact "$EXTPACK_NAME" "$EXTPACK_VERSION"
		done
	fi	
}

function _ySyncArtefact {
	# For ZSH we need to set the bash_rematch option
	if command -v setopt > /dev/null && [[ ! -o bash_rematch ]]; then
		setopt local_options bash_rematch
	fi

	ARTEFACT_NAME=
	ARTEFACT_ID1=
	ARTEFACT_ID2=

	# Find artefact name and IDs used by SAP in downloadable artefacts
	case "$1" in
		"commerce-suite")
			ARTEFACT_NAME="$1"
			ARTEFACT_ID1="CXCOMCL"
			ARTEFACT_ID2="CXCOMM"
			;;
		"hybris-commerce-integrations")
			ARTEFACT_NAME="$1"
			ARTEFACT_ID1="CXCOMIEP"
			ARTEFACT_ID2="CXCOMINT"
			;;
		*)
			echo -e "${_yerror}[ERROR] No artefact found for identifier: ${_ybold}$1${_yclear}"
			return 1
			;;
	esac

	# Parse and split artefact version
	versionRegEx="([0-9]{4})\\.([0-9]{1,3})"
	VERSION=
	PATCH_LEVEL=
	if [[ "$2" =~ $versionRegEx ]]; then
		VERSION=${BASH_REMATCH[@]:1:1}
		PATCH_LEVEL=${BASH_REMATCH[@]:2:1}
	else
		echo -e "${_yerror}[ERROR] Artefact version does not match pattern XXXX.YYY! Given:${_ybold}$2${_yclear}"
		return 1
	fi

	# First check if the file is already available
	TARGET_PATH="${CXDEVHOME}/dependencies/${ARTEFACT_NAME}/${ARTEFACT_NAME}-${VERSION}.${PATCH_LEVEL}.zip"
	if [ -f "$TARGET_PATH" ]; then
		echo -e "${_yinfo}[INFO] Artefact found in local cache: ${_yunderline}$TARGET_PATH${_yclear}"
		return 0
	fi

	# Now try to find it in sync folder
	echo -e "${_yinfo}[INFO] Artefact not found in local cache: ${_yunderline}$TARGET_PATH${_yclear}"
	if [[ "" == "$CXDEVSYNCDIR" ]]; then
		echo -e "${_yerror}[ERROR] Artefact cannot be downloaded automatically because variable ${_ybold}CXDEVSYNCDIR${_yreset} is not set!${_yclear}"
		echo -e "${_ywarn}[WARN] Please download the artefact manually and place it at: ${_yunderline}$TARGET_PATH${_yclear}"
		echo -e "${_yinfo}[INFO] ${_yblink}Consider setting the ${_ybold}CXDEVSYNCDIR${_yreset}${_yblink} variable in your environment!${_yclear}"
	elif [ ! -d "$CXDEVSYNCDIR" ]; then
		echo -e "${_yerror}[ERROR] Artefact cannot be downloaded automatically because configured ${_ybold}CXDEVSYNCDIR${_yreset} is not found!${_yclear}"
		echo -e "${_yerror}[ERROR] ${_ybold}CXDEVSYNCDIR${_yreset} is set to: $CXDEVSYNCDIR${_yclear}"
		echo -e "${_ywarn}[WARN] Check your ${_ybold}CXDEVSYNCDIR${_yreset} and retry or download the artefact manually and place it at: ${_yunderline}$TARGET_PATH${_yclear}"
		return 1
	fi
	
	SOURCE_PATH=$(find "$CXDEVSYNCDIR" -type f -iname "*${VERSION}*${PATCH_LEVEL}*" \( -iname "*${ARTEFACT_NAME}*" -o -iname "*${ARTEFACT_ID1}*" -o -iname "*${ARTEFACT_ID2}*" \))
	if [ -f "$SOURCE_PATH" ]; then
		echo -e "${_yinfo}[INFO] Artefact found in sync folder: ${_yunderline}$SOURCE_PATH${_yclear}"
		echo -e "${_yinfo}[INFO] Copy artefact to local cache: ${_yunderline}$TARGET_PATH${_yclear}"
		if command -v rsync > /dev/null; then
			rsync -h --progress "$SOURCE_PATH" "$TARGET_PATH"
		else
			cp "$SOURCE_PATH" "$TARGET_PATH"
		fi
	fi

	if [ -f "$TARGET_PATH" ]; then
		echo -e "${_yinfo}[INFO] Artefact downloaded successfully.${_yclear}"
	else
		echo -e "${_yinfo}[ERROR] Failed to download the artefact, please check!${_yclear}"
	fi
}

function _ySyncArtefactsHelp {
	echo
	echo -e         "        usage: ySyncArtefacts path"
	echo 
	echo -e         "${_ybold}OPTION SUMMARY${_yreset}"
	echo 
	echo -e         "        path            the path to a ${_ybold}'manifest.json'${_yreset} file, typically the root directory"
	echo -e         "                        of the project's git repository used by SAP!"
	echo -e "${_yreset}${_yclear}"
}