#!/bin/bash

# where to store the sparse-image
WORKSPACE=${HOME}/workspace.dmg.sparseimage
MOUNTPOINT=/Volumes/Workspace

create() {
    hdiutil create -type SPARSE -fs 'Case-sensitive Journaled HFS+' -size 60g -volname Workspace ${WORKSPACE}
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
                <string>${MOUNTPOINT}</string>
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
        hdiutil detach $m
    fi
}

attach() {
    hdiutil attach -notremovable -nobrowse -mountpoint ${MOUNTPOINT} ${WORKSPACE}
}

compact() {
    detach
    hdiutil compact ${WORKSPACE} -batteryallowed
    attach
}

case "$1" in
    create) create;;
    automount) automount;;
    attach) attach;;
    detach) detach;;
    compact) compact;;
    *) ;;
esac