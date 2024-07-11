#/bin/bash
ll packages/ | grep '-' | awk '{original=$NF;gsub(/apache-/,"",$NF);split($NF,arr,"-");print "ln -s packages/"original" "arr[1]}'
