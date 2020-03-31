#! /bin/sh

###############################################################################
# Ensure Script Exits immediately if any command exits with a non-zero status #
###############################################################################
# http://stackoverflow.com/questions/1378274/in-a-bash-script-how-can-i-exit-the-entire-script-if-a-certain-condition-occurs#1379904
set -e


SHOULD_CHECKOUT=1
echo "SHOULD_CHECKOUT=$SHOULD_CHECKOUT"

SCRIPT_DIRECTORY="$(dirname $0)"
echo "SCRIPT_DIRECTORY=$SCRIPT_DIRECTORY"


####################
# Define Functions #
####################

runCarthageBuilds() {
	echo "------ BEGIN runCarthageBuilds ------"

	local XCODE_VERSION_FILE="$1"
	local NAME="$2"
	echo "XCODE_VERSION_FILE=$XCODE_VERSION_FILE"
	echo "NAME=$NAME"
	
	assignXcodeBuildPathFor "$XCODE_VERSION_FILE"
	echo "XCODEBUILD_PATH=$XCODEBUILD_PATH"	
	
	local WORKING_DIRECTORY="$SCRIPT_DIRECTORY/$NAME"
	local WORKSPACE_FILENAME="$NAME.xcworkspace"
	echo "WORKING_DIRECTORY=$WORKING_DIRECTORY"
	echo "WORKSPACE_FILENAME=$WORKSPACE_FILENAME"

	pushd "$WORKING_DIRECTORY"

	#sudo xcode-select -s /Applications/Xcode-11.4.app/Contents/Developer

	if [ "$SHOULD_CHECKOUT" -gt 0 ]; then
		sh "checkout.sh"
	fi

	"$XCODEBUILD_PATH" -workspace "$WORKSPACE_FILENAME" -scheme "Swift-iOS"
	"$XCODEBUILD_PATH" -workspace "$WORKSPACE_FILENAME" -scheme "Swift-macOS"
	"$XCODEBUILD_PATH" -workspace "$WORKSPACE_FILENAME" -scheme "ObjectiveC-iOS"
	"$XCODEBUILD_PATH" -workspace "$WORKSPACE_FILENAME" -scheme "ObjectiveC-macOS"

	popd
	
	echo "------ END runCarthageBuilds ------"
}

# Usage `assignXcodeBuildPath FILENAME_CONTAINING_DESIRED_VERSION`
function assignXcodeBuildPathFor { # outputs path to $XCODEBUILD_PATH var
	
	local DESIRED_XCODE_VERSION_FILENAME="$1"
	echo "DESIRED_XCODE_VERSION_FILENAME=$DESIRED_XCODE_VERSION_FILENAME"
	
	local DESIRED_XCODE_VERSION_FILEPATH="$SCRIPT_DIRECTORY/$DESIRED_XCODE_VERSION_FILENAME"
	echo "DESIRED_XCODE_VERSION_FILEPATH=$DESIRED_XCODE_VERSION_FILEPATH"
	
	local DESIRED_XCODE_VERSION=$( head -n 1 "$DESIRED_XCODE_VERSION_FILEPATH" )
	echo "DESIRED_XCODE_VERSION=$DESIRED_XCODE_VERSION"
	
	echo "***** Attempting to identify Xcode (xcodebuild) with version '$DESIRED_XCODE_VERSION' *****"
	
	for app in /Applications/*Xcode*.app/; do 
		echo $app;
		local CANDIDATE_XCODEBUILD_PATH="${app}Contents/Developer/usr/bin/xcodebuild"
		if [ -e "$CANDIDATE_XCODEBUILD_PATH" ]; then
			echo "   xcodebuild exists ($CANDIDATE_XCODEBUILD_PATH)"
			local XCODE_VERSION=$( "$CANDIDATE_XCODEBUILD_PATH" -version | head -n 1 )
			echo "   VERSION: $XCODE_VERSION"
			
			if [ "$XCODE_VERSION" == "$DESIRED_XCODE_VERSION" ]; then
				echo "***** FOUND '$DESIRED_XCODE_VERSION' at $CANDIDATE_XCODEBUILD_PATH *****"
				XCODEBUILD_PATH="$CANDIDATE_XCODEBUILD_PATH"
				return 0 # Return with zero code to indicate success
			fi
		else
			echo "   xcodebuild missing ($XCODEBUILD_PATH)"
		fi
	done
	
	# If we got here the DESIRED_XCODE_VERSION was not found
	echo "ERROR: No Xcode (xcodebuild) found for version '$DESIRED_XCODE_VERSION' as defined in '$DESIRED_XCODE_VERSION_FILENAME'" >&2
	exit 1 # Exit with a non-zero code to indicate failure and kill the script

}

###################
# Carthage-Minimum #
###################

runCarthageBuilds "MINIMUM_SUPPORTED_XCODE_VERSION" "Carthage-Minimum"


###################
# Carthage-Latest #
###################

runCarthageBuilds "Latest_SUPPORTED_XCODE_VERSION" "Carthage-Latest"








