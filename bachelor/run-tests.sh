#!/bin/bash

main() {
    
    ../Tools/autotest/autotest.py build.Copter

    for filename in missions/*
    do
        move_mission $filename

        echo "starting $filename"

        if [[ $map == true ]]; then
            ../Tools/autotest/autotest.py test.Copter.Autofly --speedup $speedup --map
        else
            ../Tools/autotest/autotest.py test.Copter.Autofly --speedup $speedup
        fi

        move_logs $filename
    done

    remove_attacks
    cleanup
}

move_mission() {
    cp $1 ../Tools/autotest/ArduCopter_Tests/Autofly/mission.txt
}

move_logs() {
    filename=$(basename $1)
    lastlog="$(sed 's/\r$//' logs/LASTLOG.TXT)"

    mv logs/0000000$lastlog.BIN $logfolder/$filename$attack".BIN"
}

cleanup() {
    rm -rf logs/
    rm -rf terrain/
    rm -rf test.ArduCopter/
    rm *.tlog
    rm eeprom.bin
}

inject_sm_attack() {
    file="../libraries/AP_Motors/AP_MotorsMatrix.h"

    sed -i 's/int flag = 0/int flag = 1/g' $file
}

inject_ad_attack() {
    echo "TODO"
}

remove_attacks() {
    file="../libraries/AP_Motors/AP_MotorsMatrix.h"

    sed -i 's/int flag = 1/int flag = 0/g' $file
}

show_help() {
    echo "Preconditions:"
    echo "  - this script should be located in a subfolder inside the ardupilot directory"
    echo "  - the mission files should be located in a mission/ folder inside this directory"
    echo "  - the mission files should be named without file-extensions (mission and not mission.txt)"
    echo ""
    echo "CLI usage:"
    echo "  - a: specify attack (switch-mode...), if not provided, no-attack-version will be run"
    echo "  - l: specify folder to save logs, mandatory"
    echo "  - s: speedup, if not provided the simulation will run at speedup 5"
    echo "  - m: if set, the simulation will open the map"
    echo ""
    echo "Log-Files and Test-Results:"
    echo "  - log-files are located in the specified log-folder"
    echo "  - log-files are named after the mission files and the attack (e.g. modified_copter_sm_attack.BIN)" 
}

while getopts a:l:s:bhm option
do
    case "${option}" in
        h) show_help
           exit;;
        s) speedup=${OPTARG};;
        l) logfolder=${OPTARG};;
        a) attack=${OPTARG};;
        m) map=true;;
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
    attack="_no_attack"
elif [[ $attack == "switch-mode" ]]; then
    echo "Building Switch-Mode attack"
    attack="_sm_attack"
    inject_sm_attack
elif [[ $attack == "art-delay" ]]; then
    echo "Building Artificial-Delay attack"
    attack="_at_delay"
    inject_ad_attack
else
    echo "Unkown attack, using Non-Attack-Version"
    attack="none"
fi

main