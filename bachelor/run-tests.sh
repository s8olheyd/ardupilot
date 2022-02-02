#!/bin/bash

main() {
    missions=("modified_copter") #"modified_copter_long")

    for i in "${missions[@]}"
    do
        move_mission "$i.txt"

        echo "starting $i"

        if [[ $build == true ]]; then
            ../Tools/autotest/autotest.py build.Copter test.Copter.Autofly --map
        else 
            ../Tools/autotest/autotest.py test.Copter.Autofly --map
        fi

        move_logs $i
    done
}

move_mission() {
    cp $1 ../Tools/autotest/ArduCopter_Tests/Autofly/mission.txt
}

move_logs() {
    lastlog="$(sed 's/\r$//' logs/LASTLOG.TXT)"
    mv logs/0000000$lastlog.BIN $logfolder/$1".BIN"
}

cleanup() {
    echo "cleanup"
}

while getopts l:s:b option
do
    case "${option}" in
        s) speedup=${OPTARG};;
        b) build=true;;
        l) logfolder=${OPTARG};;
    esac
done

if [[ -z $logfolder ]]; then
    echo "Logfolder must be specified!"
    exit 1
fi

main