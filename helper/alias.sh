# CX DEV Environment Alias
alias toworkspace='cd "$WORKSPACE_HOME"'
alias toplatform='cd "$PLATFORM_HOME"'
alias toconfig='cd "$HYBRIS_OPT_CONFIG_DIR"'
alias tostorefront='cd "$STOREFRONT_HOME"'

alias yreload='yLoadProject "$WORKSPACE_HOME" "$PROJECT_NAME"'
alias ysetup='toworkspace && ./gradlew setupLocalDevelopment && yreload'
alias yreformat='toworkspace && ./gradlew spotlessApply'

alias yserver='toplatform && ant customize server && toworkspace'
alias ybuild='toplatform && ant build && toworkspace'
alias yrush='toplatform && cd ../modules/smartedit/smartedittools && ant rushupdatefull -Dpath=./ && ant rushrebuilddev -Dpath=./ && toworkspace'
alias yrebuild='toplatform && ant clean all && toworkspace'
alias yinit='toplatform && ant all initialize -Dtenant=master && toworkspace'
alias yreinit='toplatform && ant clean all initialize -Dtenant=master && toworkspace'

alias ystart='toplatform && ./hybrisserver.sh'
alias ydebug='toplatform && ./hybrisserver.sh debug'
alias ystorefront='tostorefront && npm start'
alias ystorefrontssl='tostorefront && npm local'

alias ymails='open $PLATFORM_HOME/../../log/mails'
alias yunittests='toplatform && ant unittests && toworkspace && ytestresult'
alias ytestresult='open $WORKSPACE_HOME/core-customize/hybris/log/junit/test-results/index.html'
