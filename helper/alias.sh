# CX DEV Environment Alias
alias toworkspace='cd "$CXDEV_WORKSPACE_HOME"'
alias toplatform='cd "$CXDEV_PLATFORM_HOME"'
alias toconfig='cd "$CXDEV__OPT_CONFIG_DIR"'
alias tostorefront='cd "$CXDEV_STOREFRONT_HOME"'

alias yreload='yLoadWorkspace "$CXDEV_WORKSPACE_HOME" "$CXDEV_WORKSPACE_NAME"'
alias ysetup='toworkspace && ./gradlew setupLocalDevelopment && yreload'
alias yreformat='toworkspace && ./gradlew spotlessApply'

alias yserver='toplatform && ant customize server && toworkspace'
alias ybuild='toplatform && ant build && toworkspace'
alias yrebuild='toplatform && ant clean customize all && toworkspace'
alias yrush='toplatform && cd ../modules/smartedit/smartedittools && ant rushupdatefull -Dpath=./ && ant rushrebuilddev -Dpath=./ && toworkspace'
alias yinit='toplatform && ant initialize -Dtenant=master && toworkspace'
alias yreinit='toplatform && ant clean customize all initialize -Dtenant=master && toworkspace'

alias ystart='toplatform && ./hybrisserver.sh'
alias ydebug='toplatform && ./hybrisserver.sh debug'
alias ystorefront='tostorefront && npm start'
alias ystorefrontssl='tostorefront && npm local'

alias ymails='open $CXDEV_PLATFORM_HOME/../../log/mails'
alias yunittests='toplatform && ant unittests && toworkspace && ytestresult'
alias yinttests='toplatform && ant integrationtests && toworkspace && ytestresult'
alias ytestresult='open $CXDEV_WORKSPACE_HOME/core-customize/hybris/log/junit/test-results/index.html'
