#! /bin/sh


set -e

SHOULD_CARTHAGE_CHECKOUT=1
SHOULD_COCOAPODS_CHECKOUT=1
SHOULD_SKIP_CARTHAGE=1
SHOULD_SKIP_COCOAPODS=1

while test $# -gt 0; do
	case "$1" in
		-skip-carthage)
			SHOULD_SKIP_CARTHAGE=0
			shift
			;;
		-skip-cocoapods)
			SHOULD_SKIP_COCOAPODS=0
			shift
			;;
		-skip-carthage-checkouts)
			SHOULD_CARTHAGE_CHECKOUT=0
			shift
			;;
		-skip-cocoapods-checkouts)
			SHOULD_COCOAPODS_CHECKOUT=0
			shift
			;;
		*)
			echo "$1 is not a recognized flag!"
			echo "Possible options are:"
			echo "   -skip-carthage"
			echo "   -skip-cocoapods"
			echo "   -skip-carthage-checkouts"
			echo "   -skip-cocoapods-checkouts"
			exit 1;
			;;
	esac
done  



echo "SHOULD_CARTHAGE_CHECKOUT=$SHOULD_CARTHAGE_CHECKOUT"
echo "SHOULD_COCOAPODS_CHECKOUT=$SHOULD_COCOAPODS_CHECKOUT"
echo "SHOULD_SKIP_CARTHAGE=$SHOULD_SKIP_CARTHAGE"
echo "SHOULD_SKIP_COCOAPODS=$SHOULD_SKIP_COCOAPODS"
  
  