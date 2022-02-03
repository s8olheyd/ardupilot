#!/bin/bash

main() {
    
    #missions=("modified_copter") #"modified_copter_long")

    for filename in missions/* #"${missions[@]}"
    do
        move_mission $filename

        echo "starting $filename"

        if [[ $build == true ]]; then
            ../Tools/autotest/autotest.py build.Copter test.Copter.Autofly --speedup $speedup --map
        else 
            ../Tools/autotest/autotest.py test.Copter.Autofly --speedup $speedup --map
        fi

        move_logs $filename
    done

    cleanup
}

move_mission() {
    cp $1 ../Tools/autotest/ArduCopter_Tests/Autofly/mission.txt
}

move_logs() {
    filename=$(basename $1)
    lastlog="$(sed 's/\r$//' logs/LASTLOG.TXT)"

    mv logs/0000000$lastlog.BIN $logfolder/$filename".BIN"
}

cleanup() {
    rm -rf logs/
    rm -rf terrain/
    rm -rf test.ArduCopter/
    rm *.tlog
    rm eeprom.bin
}

inject_sm_attack() {
    echo "TODO"
}

while getopts a:l:s:b option
do
    case "${option}" in
        s) speedup=${OPTARG};;
        b) build=true;;
        l) logfolder=${OPTARG};;
        a) attack=${OPTARG};;
    esac
done

if [[ -z $logfolder ]]; then
    echo "Logfolder must be specified!"
    exit 1
fi

if [[ -z $speedup ]]; then
    echo "No Speedup specified, using 5"
    speedup=5
fi

if [[ -z $attack ]]; then
    echo "No attack specified, using Non-Attack-Version"
    attack="none"
elif [[ $attack == "switch-mode" ]]; then
    echo "Building Switch-Mode attack"
    attack="sm"
else
    echo "Unkown attack, using Non-Attack-Version"
    attack="none"
fi

main