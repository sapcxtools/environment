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

function yGlobalConfig {
	if [[ "" != "$1" && "enable" != "$1" && "disable" != "$1" ]]; then
		echo -e "${error}[ERROR] Unknown input parameters!${clear}"
		_yGlobalConfigHelp
		return 1
	fi

	PROFILE=
	PROFILENAME=
	case "$2" in 
	"80" | "localdev")
		PROFILE=80;
		PROFILENAME=localdev;;
	"81" | "ssl")
		PROFILE=81;
		PROFILENAME=ssl;;
	"83" | "backoffice")
		PROFILE=83;
		PROFILENAME=backoffice;;
	"84" | "smartedit")
		PROFILE=84;
		PROFILENAME=smartedit;;
	"88" | "sso")
		PROFILE=88;
		PROFILENAME=sso;;
	esac

	PROFILESHOME=$CXDEVHOME/configuration/profiles
	ENABLEDPROFILESHOME=$CXDEVHOME/configuration/enabled

	if [[ "$1" == "" ]] || [ ! -f "$PROFILESHOME/$PROFILE-$PROFILENAME.properties" ]; then
		if [[ "$1" != "" ]]; then
			echo -e "${warn}[WARN] Given configuration profile not found!${clear}"
		fi

		# For ZSH we need to set the bash_rematch option
		if command -v setopt > /dev/null && [[ ! -o bash_rematch ]]; then
			setopt local_options bash_rematch
		fi

		# Parse and split configuration profiles
		profileRegEx="^.*\/([^\/]*\/[^\/]*\/(.*)-(.*)\.properties)$"
		echo -e "${info}[INFO] Available profiles are:${clear}"
		echo -e "       +----+---------------+---------+--------------------------------------------------------+"
		echo -e "       + ID + Alias         + Enabled + File                                                   +"
		echo -e "       +----+---------------+---------+--------------------------------------------------------+"
		for i in $(find "$CXDEVHOME/configuration/profiles" -type f -iname "*.properties" | sort -V); do 
			if [[ "$i" =~ $profileRegEx ]]; then
				if [ -f "$CXDEVHOME/configuration/enabled/${BASH_REMATCH[@]:2:1}-local.properties" ]; then
					PARAMS=(${BASH_REMATCH[@]:2:1} ${BASH_REMATCH[@]:3:1} "true" ${BASH_REMATCH[@]:1:1})
					printf "       | %2d | %-13s | ${info}%-7s${clear} | %-54s |\n" $PARAMS
				else
					PARAMS=(${BASH_REMATCH[@]:2:1} ${BASH_REMATCH[@]:3:1} "false" ${BASH_REMATCH[@]:1:1})
					printf "       | %2d | %-13s | ${error}%-7s${clear} | %-54s |\n" $PARAMS
				fi
			fi
		done
		echo -e "       +----+---------------+---------+--------------------------------------------------------+"
		return 1
	fi

	if [[ "enable" == "$1" ]]; then
		echo -e "${info}[INFO] Enable configuration profile:\e[33m\e[1m $PROFILE-$PROFILENAME.properties${clear}"
		if [ -f "$ENABLEDPROFILESHOME/$PROFILE-local.properties" ]; then
			echo -e "${info}[INFO] Property file $PROFILE-$PROFILENAME.properties already enabled.${clear}"
		else
			mkdir -p "$ENABLEDPROFILESHOME"
			ln -s "$PROFILESHOME/$PROFILE-$PROFILENAME.properties" "$ENABLEDPROFILESHOME/$PROFILE-local.properties"
			echo -e "${info}[INFO] Property file $PROFILE-$PROFILENAME.properties enabled.${clear}"
		fi
	fi

	if [[ "disable" == "$1" ]]; then
		echo -e "${info}[INFO] Disable configuration profile:\e[33m\e[1m $PROFILE-$PROFILENAME.properties${clear}"
		if [ -f "$ENABLEDPROFILESHOME/$PROFILE-local.properties" ]; then
			rm "$ENABLEDPROFILESHOME/$PROFILE-local.properties"
			echo -e "${info}[INFO] Property file $PROFILE-$PROFILENAME.properties disabled.${clear}"
		else
			echo -e "${info}[INFO] Property file $PROFILE-$PROFILENAME.properties already disabled.${clear}"
		fi
	fi

	if [[ "$CXDEV_WORKSPACE_HOME" == "" ]]; then
		echo -e "\e[31m [WARN] No workspace loaded. Configuration will be applied when project is loaded.${_yclear}"
		return 1
	else
		echo -e "${info}[INFO] Workspace found at: $CXDEV_WORKSPACE_HOME. Applying configuration now...${clear}"
		yreload
	fi

	unset PROFILE
	unset PROFILENAME
	unset PROFILESHOME
	unset ENABLEDPROFILESHOME
}

function _yGlobalConfigHelp {
	echo
	echo -e         "        usage: yGlobalConfig [action] [config]"
	echo 
	echo -e         "${bold}OPTION SUMMARY${reset}"
	echo 
	echo -e         "        action          action can be either of the following"
	echo -e         "                        ${bold}enable${reset} - enables the given configuration profile"
	echo -e         "                        ${bold}disable${reset} - disables the given configuration profile"
	echo -e         "        config          config can be either"
	echo -e         "                        an ID of an existing configuration profile"
	echo -e         "                        an alias of an existing configuration profile"
	echo 
	echo -e         "        Calling yGlobalConfig without options will show all avaliable configuration profiles."
	echo -e "${reset}${clear}"
}