#! /bin/sh


set -e

X="Bob"
SHOULD_COCOAPODS_CHECKOUT=1
SHOULD_SKIP_CARTHAGE=0
SHOULD_SKIP_COCOAPODS=1
  
  
if ( [[ "$X" == *ob ]] && (( $SHOULD_SKIP_CARTHAGE )) ) || \
   ( [[ "$X" == *ed ]] && (( $SHOULD_SKIP_COCOAPODS )) )
then 
	echo "in"
else
	echo "out" 
fi



if  [[ "$X" == *ob ]] && [ $SHOULD_SKIP_CARTHAGE -eq 1 ]
then 
	echo "in"
else
	echo "out" 
fi
  