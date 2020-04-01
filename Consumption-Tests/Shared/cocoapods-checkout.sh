#! /bin/sh

# Carthage cannot work with files in your local copy. It can only work with files committed 
# to a git repository (since it checkouts the files into its own Carthage/Checkouts directory).
# This is a little annoying during development when you want to test that your local changes
# haven't broken anything.  
# To work around this, this script...
#  - (if necessary) commits your local changes (don't worry this will be undone later) 
#  - tags the commit (giving it a name incorporating the current date/time)
#  - (if necessary) resets the commit (putting your working copy back as it was before)
#  - create/updates the Cartfile so it points to the tag that was just created
#  - performs a `carthage update` 
#  - removes the tag 


###############################################################################
# Ensure Script Exits immediately if any command exits with a non-zero status #
###############################################################################
# http://stackoverflow.com/questions/1378274/in-a-bash-script-how-can-i-exit-the-entire-script-if-a-certain-condition-occurs#1379904 
set -e


###############################################
# Extract Command Line Arguments to Variables #
###############################################

while getopts ":w:x:" opt; do
    case $opt in
        w)
            echo "-w (Working Directory) was triggered, Parameter: $OPTARG"
            WORKING_DIRECTORY_UNEXPANDED=$OPTARG
            WORKING_DIRECTORY="$(cd "$(dirname "$WORKING_DIRECTORY_UNEXPANDED")"; pwd)/$(basename "$WORKING_DIRECTORY_UNEXPANDED")"
            echo "WORKING_DIRECTORY_UNEXPANDED=${WORKING_DIRECTORY_UNEXPANDED}"
            echo "WORKING_DIRECTORY=${WORKING_DIRECTORY}"
        ;;
        x)
            echo "-x (Xcode Version Filename) was triggered, Parameter: $OPTARG"
            XCODE_VERSION_FILENAME=$OPTARG
            echo "XCODE_VERSION_FILENAME=${XCODE_VERSION_FILENAME}"
        ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1 # exit with non-zero code to indicate failure
        ;;
    esac
done


#############################
# Check Mandatory Arguments #
#############################

if [ -z "${WORKING_DIRECTORY}" ]; then
    echo "ERROR: Mandatory -w (Working Directory) argument was NOT specified" >&2
    exit 1 # exit with non-zero code to indicate failure
fi

if [ -z "${XCODE_VERSION_FILENAME}" ]; then
    echo "ERROR: Mandatory -x (Xcode Version Filename) argument was NOT specified" >&2
    exit 1 # exit with non-zero code to indicate failure
fi


######################
# Check Xcode-Select #
######################

SCRIPT_DIRECTORY="$(dirname $0)"
XCODE_VERSION_FILEPATH="$SCRIPT_DIRECTORY/../$XCODE_VERSION_FILENAME"
XCODE_VERSION=$( head -n 1 "$XCODE_VERSION_FILEPATH" )
ACTUAL_XCODE_VERSION=$( xcodebuild -version | head -n 1)
echo "SCRIPT_DIRECTORY=${SCRIPT_DIRECTORY}"
echo "XCODE_VERSION_FILEPATH=${XCODE_VERSION_FILEPATH}"
echo "XCODE_VERSION=${XCODE_VERSION}"
echo "ACTUAL_XCODE_VERSION=${ACTUAL_XCODE_VERSION}"

if [ "$XCODE_VERSION" != "$ACTUAL_XCODE_VERSION" ]; then
    echo "ERROR: The Xcode Version specified ($XCODE_VERSION) does not match the current Xcode version ($ACTUAL_XCODE_VERSION)" >&2
    echo "Install the appropriate version of Xcode and use \`xcode-select -s\` to select the appropriate version."
    echo "Note: the format of the desired Xcode Version should exactly match what is output with \`xcodebuild -version\`."
    exit 1 # exit with non-zero code to indicate failure
fi


#################################################
# Validation Successfully, perform the checkout #
#################################################

# Temporarily change directory into the $WORKING_DIRECTORY
pushd "${WORKING_DIRECTORY}"

# Remove any existing Cocoapods related files/directories
rm -f "Podfile"
rm -f "Podfile.lock"
rm -rf "Pods"

IOS_VERSION="8"
MAC_VERSION="10.11"

# Create the Podfile from the template (in the specified WORKING_DIRECTORY)
# replacing all the appropriate placeholders.
sed <Podfile.template \
    -e "s#{IOS_VERSION}#${IOS_VERSION}#" \
    -e "s#{MAC_VERSION}#${MAC_VERSION}#" \
    >Podfile

# Perform the `pod install` (using the Cartfile we just created/updated)
pod deintegrate Swift.xcodeproj
pod deintegrate ObjectiveC.xcodeproj
pod install

# Return to original directory
popd
