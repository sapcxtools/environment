function yLoadProject {
	if [[ "" == "$1" ]]; then
		echo -e "\e[31m [WARN] Wrong parameters! Please use syntax: yLoadProject <PATH> (<NAME>)! \e[39m"
		return 1
	fi

	# Print project information
	PROJECT_NAME=
	if [[ "" != "$2" ]]; then
		PROJECT_NAME=$2
	else 
		PROJECT_NAME=`/usr/bin/basename $1`
	fi
	echo -e "\e[32m [INFO] Applying project settings for:\e[33m\e[1m $PROJECT_NAME \e[0m\e[39m"
	echo -n -e "\033]0;${PROJECT_NAME}\007"

	# Load workspace location
	if [ -d "$1" ]; then
		cd "$1"
	else
		echo -e "\e[31m [WARN] No workspace found at $1! \e[39m"
		return 1
	fi
	WORKSPACE_HOME=`pwd`
	echo -e "\e[32m [INFO] Switched to workspace location:\e[39m $WORKSPACE_HOME"
	
	# Detect platform structure
	PLATFORM_HOME=$WORKSPACE_HOME/server/hybris/bin/platform
	PLATFORM_HOME_ALTERNATIVE=$WORKSPACE_HOME/hybris/bin/platform
	if [ -d "$PLATFORM_HOME_ALTERNATIVE" ]; then
		PLATFORM_HOME=$PLATFORM_HOME_ALTERNATIVE
	fi
	PLATFORM_HOME_CCV2=$WORKSPACE_HOME/core-customize/hybris/bin/platform
	if [ -d "$WORKSPACE_HOME/core-customize" ]; then
		echo -e "\e[32m [INFO] SAP Cloud Repository structure detected!\e[39m "
		PLATFORM_HOME=$PLATFORM_HOME_CCV2
		
		# Link global dependencies
		GLOBAL_DEPENDENCIES=$CXDEVHOME/dependencies
		if [ -d "$GLOBAL_DEPENDENCIES" ]; then
			if [ -L "$WORKSPACE_HOME/dependencies" ] && [[ $(readlink "$WORKSPACE_HOME/dependencies") == "$GLOBAL_DEPENDENCIES" ]]; then
				echo -e "\e[32m [INFO] Global dependencies folder already linked, no optimization needed.\e[39m "
			else
				if [ -d "$WORKSPACE_HOME/dependencies" ]; then 
					echo -e "\e[32m [INFO] Relink dependencies to global dependencies folder to save disk space!\e[39m "
					rm -Rf "$WORKSPACE_HOME/dependencies"
				else
					echo -e "\e[32m [INFO] Link dependencies to global dependencies folder to save disk space!\e[39m "
				fi
				ln -s "$GLOBAL_DEPENDENCIES" "$WORKSPACE_HOME/dependencies"
			fi

			yUpdateArtefacts
		fi
		
		# Link global certificates
		GLOBAL_CERTIFICATES=$CXDEVHOME/certificates
		if [ -d "$GLOBAL_CERTIFICATES" ]; then
			if [ -L "$WORKSPACE_HOME/certificates" ] && [[ $(readlink "$WORKSPACE_HOME/certificates") == "$GLOBAL_CERTIFICATES" ]]; then
				echo -e "\e[32m [INFO] Global certificates folder already linked, no optimization needed.\e[39m "
			else
				if [ -d "$WORKSPACE_HOME/certificates" ]; then 
					echo -e "\e[32m [INFO] Use local certificates folder from project configuration! (Remove and rerun to use global certificates instead)\e[39m "
				else 
					if [ -L "$WORKSPACE_HOME/certificates" ]; then 
						echo -e "\e[32m [INFO] Relink certificates to global certificates folder!\e[39m "
						rm -Rf "$WORKSPACE_HOME/certificates"
					else
						echo -e "\e[32m [INFO] Link certificates to global certificates folder!\e[39m "
					fi
					ln -s "$GLOBAL_CERTIFICATES" "$WORKSPACE_HOME/certificates"
				fi
			fi
		fi
	fi

	# Load Java environment
	BACKEND_HOME=$WORKSPACE_HOME/core-customize
	if [ -f "$BACKEND_HOME/.java-version" ]; then
		JAVA_VERSION=`cat "$BACKEND_HOME/.java-version"`
		if [ -d "`sdk home java $JAVA_VERSION`" ]; then
			sdk use java $JAVA_VERSION
		else
			echo -e "\e[31m [WARN] Java virtual machine not found: $JAVA_VERSION! Try to install using SDKman. \e[39m"
			sdk install java $JAVA_VERSION

			if [ -d "`sdk home java $JAVA_VERSION`" ]; then
				sdk use java $JAVA_VERSION
			else
				echo -e "\e[31m [WARN] Java virtual machine cannot be installed: $JAVA_VERSION! \e[39m"
				cd $WORKSPACE_HOME
				return 2
			fi
		fi
	else
		echo -e "\e[31m [WARN] No Java version configured within project, missing file:\e[33m\e[1m $WORKSPACE_HOME/core-customizer/.java-version \e[0m\e[39m"
		echo -e "\e[32m [WARN] Fallback to Java version configured in system environment! \e[39m"
	fi
	echo -e "\e[32m [INFO] JAVA_HOME set to:\e[39m $JAVA_HOME"
	echo -e "\e[34m"
	java -version
	echo -e "\e[39m"
	
	# Load SAP Commerce platform environment
	if [ -d "$PLATFORM_HOME" ]; then
		echo -e "\e[32m [INFO] SAP Commerce installation found at:\e[39m $PLATFORM_HOME"
		cd "$PLATFORM_HOME"

		# Load Ant environment
		echo -e "\e[32m [INFO] Loading ant environment configuration...\e[39m"
		echo -e "\e[34m"
		source setantenv.sh
		echo -e "\e[39m"

		echo -e "\e[32m [INFO] Environment configuration found at:\e[39m $PLATFORM_HOME/env.properties"
		CONFDIR=`cat env.properties | grep HYBRIS_CONFIG_DIR | sed "s#HYBRIS_CONFIG_DIR=\\\${platformhome}#.#"`
		if [ -d "$CONFDIR/local-config" ]; then
			cd "$CONFDIR/local-config"
			HYBRIS_OPT_CONFIG_DIR=`pwd`
			echo -e "\e[32m [INFO] Additional local configuration found at:\e[39m $HYBRIS_OPT_CONFIG_DIR"
			
			# Relink global configuration profiles
			ENABLEDPROFILESHOME=$CXDEVHOME/configuration/enabled
			echo -e "\e[32m [INFO] Relink global configuration profiles from:\e[39m $ENABLEDPROFILESHOME"

			[ -f "80-local.properties" ] && rm -f 80-local.properties
			[ -f "81-local.properties" ] && rm -f 81-local.properties
			[ -f "82-local.properties" ] && rm -f 82-local.properties
			[ -f "83-local.properties" ] && rm -f 83-local.properties
			[ -f "84-local.properties" ] && rm -f 84-local.properties
			[ -f "85-local.properties" ] && rm -f 85-local.properties
			[ -f "86-local.properties" ] && rm -f 86-local.properties
			[ -f "87-local.properties" ] && rm -f 87-local.properties
			[ -f "88-local.properties" ] && rm -f 88-local.properties
			[ -f "89-local.properties" ] && rm -f 89-local.properties
			
			if [ -d "$ENABLEDPROFILESHOME" ]; then
				cd "$ENABLEDPROFILESHOME"
				for i in $(ls -A); do 
    				ln -s "$ENABLEDPROFILESHOME/$i" $HYBRIS_OPT_CONFIG_DIR
				done
			fi

			cd "$PLATFORM_HOME"
		else
			HYBRIS_OPT_CONFIG_DIR=
		fi

		# Relink SAP JCO Library (if necessary)
		if [ -d "$PLATFORM_HOME/../modules/sap-framework-core/sapcorejco/lib" ]; then
			cd "$PLATFORM_HOME/../modules/sap-framework-core/sapcorejco/lib"
			OS=`/usr/bin/uname`
			CPU_ARCHITECTURE=`/usr/bin/uname -m`
			echo -e "\e[32m [INFO] SAP JCO Library found at:\e[39m `pwd`"
			
			if [[ "$OS" == "Darwin" && "$CPU_ARCHITECTURE" == "arm64" ]]; then
				echo -e "\e[32m [INFO] ARM64 CPU detected, replacing JCO Library with version from:\e[39m $CXDEVHOME/dependencies/sapjco/current.\e[39m"
				rm -f sapjco3.jar
				rm -f libsapjco3.dylib
				rm -f sapjcomanifest.mf
				ln -s "$CXDEVHOME/dependencies/sapjco/current/sapjco3.jar" .
				ln -s "$CXDEVHOME/dependencies/sapjco/current/libsapjco3.dylib" .
				ln -s "$CXDEVHOME/dependencies/sapjco/current/sapjcomanifest.mf" .
			fi

			if [[ "$OS" == "Linux" && "$CPU_ARCHITECTURE" == "arm64" ]]; then
				echo -e "\e[32m [INFO] ARM64 CPU detected, replacing JCO Library with version from:\e[39m $CXDEVHOME/dependencies/sapjco/current.\e[39m"
				rm -f sapjco3.jar
				rm -f libsapjco3.so
				rm -f sapjcomanifest.mf
				ln -s "$CXDEVHOME/dependencies/sapjco/current/sapjco3.jar" .
				ln -s "$CXDEVHOME/dependencies/sapjco/current/libsapjco3.so" .
				ln -s "$CXDEVHOME/dependencies/sapjco/current/sapjcomanifest.mf" .
			fi
		fi

		# Verify SAP CX Tools extensions
		if [ -d "$PLATFORM_HOME/../custom/sapcxtools" ]; then
			cd "$PLATFORM_HOME/../custom/sapcxtools"
			SAPCXTOOLS_HOME=`pwd`
			SAPCXTOOLS_PREFIX=`grealpath --relative-to=$WORKSPACE_HOME $SAPCXTOOLS_HOME`
			cd "$PLATFORM_HOME"

			echo -e "\e[32m [INFO] SAP CX Tools found at:\e[39m $SAPCXTOOLS_HOME"
		else
			SAPCXTOOLS_HOME=
			SAPCXTOOLS_PREFIX=
		fi
	else
		echo -e "\e[31m [WARN] No hybris installation found at:\e[39m $PLATFORM_HOME!"
		PLATFORM_HOME=
		HYBRIS_OPT_CONFIG_DIR=
		SAPCXTOOLS_HOME=
		SAPCXTOOLS_PREFIX=
	fi

	cd "$WORKSPACE_HOME"

	# Load storefront configuration
	if [ -d "js-storefront" ]; then
		cd js-storefront
		cd `find . -type d -not -iname ".*" -not -iname "bootstrap" -not -iname "build" -maxdepth 1`
		STOREFRONT_HOME=`pwd`
		echo -e "\e[32m [INFO] Composable storefront found at:\e[39m $STOREFRONT_HOME"

		# Load nodenv environment
		if [ -f "$STOREFRONT_HOME/.node-version" ]; then
			NODE_VERSION=`cat "$STOREFRONT_HOME/.node-version"`
			if [ -z $(nodenv version-name) ]; then
				echo -e "\e[31m [WARN] Node environment not found: $NODE_VERSION! Try to install using nodenv. \e[39m"
				nodenv install $NODE_VERSION

				if [ -z $(nodenv version-name) ]; then
					echo -e "\e[31m [WARN] Node environment cannot be installed: $NODE_VERSION! \e[39m"
					cd $WORKSPACE_HOME
					return 2
				fi
			fi
		else
			echo -e "\e[31m [WARN] No node version configured within project, missing file:\e[33m\e[1m $STOREFRONT_HOME/.java-version \e[0m\e[39m"
			echo -e "\e[32m [WARN] Fallback to Java version configured in system environment! \e[39m"
		fi
		echo -e "\e[32m [INFO] Node environment: \e[39m"
		echo -e "\e[34m"
		nodenv version
		echo -e "\e[39m"
	else
		STOREFRONT_HOME=
	fi

	cd "$WORKSPACE_HOME"

	export PROJECT_NAME
	export WORKSPACE_HOME
	export PLATFORM_HOME
	export STOREFRONT_HOME
	export HYBRIS_OPT_CONFIG_DIR
	export SAPCXTOOLS_HOME
	export SAPCXTOOLS_PREFIX
}
