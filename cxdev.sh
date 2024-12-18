export CXDEVHOME=$(dirname "$(realpath $0)")

# Include CX DEV environment files
source $CXDEVHOME/helper/alias.sh
source $CXDEVHOME/helper/artefacts.sh
source $CXDEVHOME/helper/config.sh
source $CXDEVHOME/helper/project.sh
