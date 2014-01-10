#!/bin/bash

# where to store the sparse-image
WORKSPACE=~/Documents/workspace.dmg.sparseimage

create() {
    hdiutil create -type SPARSE -fs 'Case-sensitive Journaled HFS+' -size 60g -volname workspace ${WORKSPACE}
}

detach() {
    m=$(hdiutil info | grep "/Volumes/workspace" | cut -f1)
    if [ ! -z "$m" ]; then
        hdiutil detach $m
    fi
}

attach() {
    hdiutil attach ${WORKSPACE}
}

compact() {
    detach
    hdiutil compact ${WORKSPACE} -batteryallowed
    attach
}

case "$1" in
    create) create;;
    attach) attach;;
    detach) detach;;
    compact) compact;;
    *) ;;
esac