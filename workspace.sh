#!/bin/bash

# where to store the sparse-image
WORKSPACE=${HOME}/projects-case-sensitive.dmg.sparseimage

create() {
    hdiutil create -type SPARSE -fs 'Case-sensitive Journaled HFS+' -size 50g -volname projects-case-sensitive ${WORKSPACE}
}

automount() {
    cat << EOF > com.workspace.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>RunAtLoad</key>
        <true/>
        <key>Label</key>
        <string>com.workspace</string>
        <key>ProgramArguments</key>
        <array>
            <string>hdiutil</string>
            <string>attach</string>
            <string>-notremovable</string>
            <string>-nobrowse</string>
            <string>-mountpoint</string>
            <string>/Volumes/workspace</string>
            <string>${WORKSPACE}</string>
        </array>
    </dict>
</plist>
EOF
    sudo cp com.workspace.plist /Library/LaunchDaemons/com.workspace.plist
}

detach() {
    m=$(hdiutil info | grep "/Volumes/workspace" | cut -f1)
    if [ ! -z "$m" ]; then
        sudo hdiutil detach $m
    fi
}

attach() {
    sudo hdiutil attach -notremovable -nobrowse -mountpoint ${HOME}/projects-case-sensitive ${WORKSPACE}
}

compact() {
    detach
    hdiutil compact ${WORKSPACE} -batteryallowed
    attach
}

help() {
    cat <<EOF
usage: workspace <command>

Possible commands:
   create       Initialize a new case-sensitive volume. Only needed one time
   automount    Configure OS X to mount the volume automatically on restart
   mount        Attach the case-sensitive volume
   compact      Remove any uneeded reserved space in the volume
   help         Display this message
EOF
}

invalid() {
    printf "workspace: '$1' is not a valid command.\n\n";
    help
}

case "$1" in
    create) create;;
    automount) automount;;
    mount) attach;;
    unmount) detach;;
    compact) compact;;
    help) help;;
    '') help;;
    *) invalid $1;;
esac
