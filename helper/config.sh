function yGlobalConfig {
	PROFILE=
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

	if [[ "enable" != "$1" ]] && [[ "disable" != "$1" ]]; then
		echo -e "\e[31m [WARN] Wrong parameters! Please use syntax: yLocalConfig enable|disable <ID|ALIAS>! \e[39m"
	fi

	if [ ! -f "$PROFILESHOME/$PROFILE-$PROFILENAME.properties" ]; then
		echo -e "\e[31m [WARN] Given configuration profile not found! \e[39m"
		echo -e "\e[32m [INFO] Available profiles are: \e[39m"

		PWD=`PWD`
		cd $PROFILESHOME
		for i in $(ls *.properties); do 
			echo -e "\e[32m        - $(echo $i | sed -E 's/(.*)-(.*)\.properties/ID: \1, ALIAS: \2/g') \e[39m"
		done
		cd $PWD
		return 1
	fi

	if [[ "enable" == "$1" ]]; then
		echo -e "\e[32m [INFO] Enable configuration profile:\e[33m\e[1m $PROFILE-$PROFILENAME.properties \e[0m\e[39m"
		if [ -f "$ENABLEDPROFILESHOME/$PROFILE-local.properties" ]; then
			echo -e "\e[32m [INFO] Property file $PROFILE-$PROFILENAME.properties already enabled. \e[39m"
		else
			mkdir -p "$ENABLEDPROFILESHOME"
			ln -s "$PROFILESHOME/$PROFILE-$PROFILENAME.properties" "$ENABLEDPROFILESHOME/$PROFILE-local.properties"
			echo -e "\e[32m [INFO] Property file $PROFILE-$PROFILENAME.properties enabled. \e[39m"
		fi
	fi

	if [[ "disable" == "$1" ]]; then
		echo -e "\e[32m [INFO] Disable configuration profile:\e[33m\e[1m $PROFILE-$PROFILENAME.properties \e[0m\e[39m"
		if [ -f "$ENABLEDPROFILESHOME/$PROFILE-local.properties" ]; then
			rm "$ENABLEDPROFILESHOME/$PROFILE-local.properties"
			echo -e "\e[32m [INFO] Property file $PROFILE-$PROFILENAME.properties disabled. \e[39m"
		else
			echo -e "\e[32m [INFO] Property file $PROFILE-$PROFILENAME.properties already disabled. \e[39m"
		fi
	fi

	if [[ "$WORKSPACE_HOME" == "" ]]; then
		echo -e "\e[31m [WARN] No workspace loaded. Configuration will be applied when project is loaded.\e[39m"
		return 1
	else
		echo -e "\e[32m [INFO] Workspace found at: $WORKSPACE_HOME. Applying configuration now... \e[39m"
		yreload
	fi
}
