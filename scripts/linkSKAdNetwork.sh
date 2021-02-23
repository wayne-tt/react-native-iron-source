#!/usr/bin/env bash

if [ "$1" = ""  ]; then
  echo "1st argument SKAdNetwork name is required"
  exit 0;
fi

SK_AD_NETWORK="${1}.skadnetwork"
RN_ROOT_DIR="${2-.}"
INFO_PLIST_PATH=""
INFO_PLIST_PATH_A="$RN_ROOT_DIR/ios/$(cat "$RN_ROOT_DIR/app.json" | npx json appName)/Info.plist"
INFO_PLIST_PATH_B="$RN_ROOT_DIR/ios/$(cat "$RN_ROOT_DIR/app.json" | npx json displayName)/Info.plist"

if [ -f "$INFO_PLIST_PATH_A" ]; then
  INFO_PLIST_PATH=$INFO_PLIST_PATH_A
fi

if [ -f "$INFO_PLIST_PATH_B" ]; then
  INFO_PLIST_PATH=$INFO_PLIST_PATH_B
fi

if [ "$INFO_PLIST_PATH" = "" ]; then
  echo "Coundn't find Info.plist file. Manual linking of $SK_AD_NETWORK is required. See https://developers.ironsrc.com/ironsource-mobile/ios/ios-14-network-support/ for details";
  exit 0;
fi

ARRAY_FOUND=$(plutil -p "$INFO_PLIST_PATH" | grep "SKAdNetworkItems" | wc -l | xargs)
ENTRY_FOUND=$(plutil -p "$INFO_PLIST_PATH" | grep "$SK_AD_NETWORK" | wc -l | xargs)

if [[ ARRAY_FOUND -eq 0 ]]; then
  plutil -insert SKAdNetworkItems -xml "<array />" "$INFO_PLIST_PATH"
fi

if [[ ENTRY_FOUND -eq 0 ]]; then
  echo "Adding $SK_AD_NETWORK to Info.plist. Please commit this change";
  plutil -insert SKAdNetworkItems.0 -xml "<dict>
        <key>SKAdNetworkIdentifier</key>
        <string>$SK_AD_NETWORK</string>
    </dict>" "$INFO_PLIST_PATH"
fi
