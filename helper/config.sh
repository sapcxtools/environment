yGlobalConfig () {
	if [[ "" != "$1" && "enable" != "$1" && "disable" != "$1" ]]; then
		echo -e "${_yerror}[ERROR] Unknown input parameters!${_yclear}"
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
			echo -e "${_ywarn}[WARN] Given configuration profile not found!${_yclear}"
		fi

		# For ZSH we need to set the bash_rematch option
		if command -v setopt > /dev/null && [[ ! -o bash_rematch ]]; then
			setopt local_options bash_rematch
		fi

		# Parse and split configuration profiles
		profileRegEx="^.*\/([^\/]*\/[^\/]*\/(.*)-(.*)\.properties)$"
		echo -e "${_yinfo}[INFO] Available profiles are:${_yclear}"
		echo -e "       +----+---------------+---------+--------------------------------------------------------+"
		echo -e "       + ID + Alias         + Enabled + File                                                   +"
		echo -e "       +----+---------------+---------+--------------------------------------------------------+"
		for i in $(find "$CXDEVHOME/configuration/profiles" -type f -iname "*.properties" | sort -V); do 
			if [[ "$i" =~ $profileRegEx ]]; then
				if [ -f "$CXDEVHOME/configuration/enabled/${BASH_REMATCH[@]:2:1}-local.properties" ]; then
					PARAMS=(${BASH_REMATCH[@]:2:1} ${BASH_REMATCH[@]:3:1} "true" ${BASH_REMATCH[@]:1:1})
					printf "       | %2d | %-13s | ${_yinfo}%-7s${_yclear} | %-54s |\n" $PARAMS
				else
					PARAMS=(${BASH_REMATCH[@]:2:1} ${BASH_REMATCH[@]:3:1} "false" ${BASH_REMATCH[@]:1:1})
					printf "       | %2d | %-13s | ${_yerror}%-7s${_yclear} | %-54s |\n" $PARAMS
				fi
			fi
		done
		echo -e "       +----+---------------+---------+--------------------------------------------------------+"
		return 1
	fi

	if [[ "enable" == "$1" ]]; then
		echo -e "${_yinfo}[INFO] Enable configuration profile ${_ybold}$PROFILENAME ($PROFILE)${_yclear}"
		if [ -f "$ENABLEDPROFILESHOME/$PROFILE-local.properties" ]; then
			echo -e "${_yinfo}[INFO] Configuration profile ${_ybold}$PROFILENAME ($PROFILE)${_yreset} already enabled.${_yclear}"
		else
			mkdir -p "$ENABLEDPROFILESHOME"
			ln -s "$PROFILESHOME/$PROFILE-$PROFILENAME.properties" "$ENABLEDPROFILESHOME/$PROFILE-local.properties"
			echo -e "${_yinfo}[INFO] Configuration profiles ${_ybold}$PROFILENAME ($PROFILE)${_yreset} was enabled successfully.${_yclear}"
		fi
	fi

	if [[ "disable" == "$1" ]]; then
		echo -e "${_yinfo}[INFO] Disable configuration profile${_ybold}$PROFILENAME ($PROFILE)${_yclear}"
		if [ -f "$ENABLEDPROFILESHOME/$PROFILE-local.properties" ]; then
			rm "$ENABLEDPROFILESHOME/$PROFILE-local.properties"
			echo -e "${_yinfo}[INFO] Configuration profile ${_ybold}$PROFILENAME ($PROFILE)${_yreset} was disabled successfully.${_yclear}"
		else
			echo -e "${_yinfo}[INFO] Configuration profile ${_ybold}$PROFILENAME ($PROFILE)${_yreset} already disabled.${_yclear}"
		fi
	fi

	if [[ "$CXDEV_WORKSPACE_HOME" == "" ]]; then
		echo -e "${_ywarn}[WARN] No workspace loaded. Configuration will be applied when project is loaded.${_yclear}"
		return 1
	else
		echo -e "${_yinfo}[INFO] Workspace found at: $CXDEV_WORKSPACE_HOME. Applying configuration now...${_yclear}"
		yreload
	fi

	unset PROFILE
	unset PROFILENAME
	unset PROFILESHOME
	unset ENABLEDPROFILESHOME
}

_yGlobalConfigHelp () {
	echo
	echo -e         "        usage: yGlobalConfig [action] [config]"
	echo 
	echo -e         "${_ybold}OPTION SUMMARY${_yreset}"
	echo 
	echo -e         "        action          action can be either of the following"
	echo -e         "                        ${_ybold}enable${_yreset} - enables the given configuration profile"
	echo -e         "                        ${_ybold}disable${_yreset} - disables the given configuration profile"
	echo -e         "        config          config can be either"
	echo -e         "                        an ID of an existing configuration profile"
	echo -e         "                        an alias of an existing configuration profile"
	echo 
	echo -e         "        Calling yGlobalConfig without options will show all avaliable configuration profiles."
	echo -e "${_yreset}${_yclear}"
}