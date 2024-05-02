# Pre-setup
    echo "Configuring your mac, password will be necessary"
    # Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
    osascript -e 'tell application "System Preferences" to quit'
    # Ask for the administrator password upfront
    sudo -v
    # Keep-alive: update existing `sudo` time stamp until `.macos` has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

function defaultsset {

# Aliases
    alias firewall='/usr/libexec/ApplicationFirewall/socketfilterfw'
    alias firewalltoggle='firewall --setglobalstate off && firewall --setglobalstate on'
    alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder; echo "DNS cache flushed"'
    alias fixopenwith='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'
    alias dropboxfinderreset='pluginkit -e use -i com.getdropbox.dropbox.garcon'
    alias fixApp="xattr -cr /Applications/$1.app" # MacOS sometimes pretends apps made by developers that don't pay them a fee are 'corrupted'. This is not true and the apps can be easily run.

# Compatibility aliases
    alias top="btop"
    #alias top="htop"

# Other
    sudo /usr/libexec/configureLocalKDC

# Functions
function restart {
  if [[ "$(fdesetup isactive)" = "true" ]]; then
    # FileVault authenticated restart
    sudo fdesetup authrestart -verbose
  else
    # Normal restart
    sudo shutdown -r now "Rebooting now"
  fi
}

function sysinfo {
  uname -a
  sw_vers -productVersion
  system_profiler SPSoftwareDataType
}

# Defaults
    defaults write -g InitialKeyRepeat -int 15 # normal minimum is 15 (225 ms)
    defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "

    # Disable transparency which improves performance but looks worse
    #defaults write com.apple.universalaccess reduceTransparency -bool true

    # Set purple accent color that looks way better than the default MacOS purple
    defaults write NSGlobalDomain AppleHighlightColor -string "0.435294 0.427450 1.000000"
    # Set sidebar icon size to small
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

    # Auto-show scrollbar
    defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"

    # Disable the over-the-top focus ring animation
    defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

    # Increase window resize speed for Cocoa applications
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Disable the “Are you sure you want to open this application?” dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # Remove duplicates in the “Open With” menu
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

    # Disable the crash reporter
    defaults write com.apple.CrashReporter DialogType -string "none"

    # Set Help Viewer windows to non-floating mode
    defaults write com.apple.helpviewer DevMode -bool true

    # Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
    # Show language menu in the top right corner of the boot screen
    sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

    # Trackpad: enable tap to click for this user and for the login screen
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Increase sound quality for Bluetooth headphones/headsets
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    # Use scroll gesture with the Ctrl (^) modifier key to zoom
    defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
    defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

    # Stop Apple Music from responding to the keyboard media keys
    launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

    # Enable lid wakeup
    sudo pmset -a lidwake 1

    # Sleep the display after 15 minutes
    sudo pmset -a displaysleep 15

    # Disable machine sleep while charging
    sudo pmset -c sleep 0

    # Set machine sleep to 20 minutes on battery
    sudo pmset -b sleep 20

    # Hibernation mode
    # 0: Disable hibernation (speeds up entering sleep mode)
    # 3: Copy RAM to disk so the system state can still be restored in case of power failure.
    sudo pmset -a hibernatemode 3

    # Remove the sleep image file to save disk space
    #sudo rm /private/var/vm/sleepimage
    # Create a zero-byte file instead…
    #sudo touch /private/var/vm/sleepimage
    # …and make sure it can’t be rewritten
    #sudo chflags uchg /private/var/vm/sleepimage

    # Require password after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1

    # Save screenshots to Pictures
    defaults write com.apple.screencapture location -string "${HOME}/Pictures"

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true

    # Enable subpixel font rendering on non-Apple LCDs
    # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
    defaults write NSGlobalDomain AppleFontSmoothing -int 1

    # Enable HiDPI display modes (requires restart)
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

    # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
    defaults write com.apple.finder QuitMenuItem -bool true

    # Finder: disable window animations and Get Info animations
    defaults write com.apple.finder DisableAllAnimations -bool true

    # Set your home folder as the default location for new Finder windows
    defaults write com.apple.finder NewWindowTarget -string "PfLo"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

    # Finder: show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Finder: hide status bar
    defaults write com.apple.finder ShowStatusBar -bool false

    # Finder: show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Display full POSIX path as Finder window title
    #defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Enable spring loading for directories
    defaults write NSGlobalDomain com.apple.springing.enabled -bool true

    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Enable snap-to-grid for icons on the desktop and in other icon views
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

    # Use list view in all Finder windows by default
    # Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false

    # Enable AirDrop over Ethernet
    defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

    # Show the ~/Library folder
    chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

    # Show the /Volumes folder
    sudo chflags nohidden /Volumes
    # Show the .config folder
    sudo chflags nohidden "${HOME}/.config"

    # Remove Dropbox’s green checkmark icons in Finder
    file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
    [ -e "${file}" ] && mv -f "${file}" "${file}.bak"

    # Expand the following File Info panes:
    # “General”, “Open with”, and “Sharing & Permissions”
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

    # Enable highlight hover effect for the grid view of a stack (Dock)
    defaults write com.apple.dock mouse-over-hilite-stack -bool true

    # Set the icon size of Dock items to 36 pixels
    defaults write com.apple.dock tilesize -int 36

    # Change minimize/maximize window effect
    defaults write com.apple.dock mineffect -string "scale"

    # Minimize windows into their application’s icon
    defaults write com.apple.dock minimize-to-application -bool true

    # Enable spring loading for all Dock items
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

    # Show indicator lights for open applications in the Dock
    defaults write com.apple.dock show-process-indicators -bool true

    # Wipe all (default) app icons from the Dock
    #defaults write com.apple.dock persistent-apps -array

    # Don’t animate opening applications from the Dock
    defaults write com.apple.dock launchanim -bool false

    # Speed up Mission Control animations
    defaults write com.apple.dock expose-animation-duration -float 0.1

    # Group windows by application in Mission Control
    defaults write com.apple.dock expose-group-by-app -bool true

    # Don’t automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false

    # Shorten the auto-hiding Dock delay
    defaults write com.apple.dock autohide-delay -float 0.1
    # Remove the animation when hiding/showing the Dock
    defaults write com.apple.dock autohide-time-modifier -float 0

    # Don't automatically hide and show the Dock
    defaults write com.apple.dock autohide -bool false

    # Make Dock icons of hidden applications translucent
    defaults write com.apple.dock showhidden -bool true

    # Don’t show recent applications in Dock
    defaults write com.apple.dock show-recents -bool false

    # Add iOS & Watch Simulator to Launchpad
    sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
    sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

    # Add a spacer to the left side of the Dock (where the applications are)
    #defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'

    # Press Tab to highlight each item on a web page
    defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

    # Show the full URL in the address bar (note: this still hides the scheme)
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

    # Prevent Safari from opening ‘safe’ files automatically after downloading
    defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

    # Don't allow hitting the Backspace key to go to the previous page in history
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool false

    # Hide Safari’s bookmarks bar by default
    defaults write com.apple.Safari ShowFavoritesBar -bool false

    # Enable Safari’s debug menu
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

    # Remove useless icons from Safari’s bookmarks bar
    defaults write com.apple.Safari ProxiesInBookmarksBar "()"

    # Enable the Develop menu and the Web Inspector in Safari
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

    # Add a context menu item for showing the Web Inspector in web views
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

    # Disable AutoFill
    defaults write com.apple.Safari AutoFillFromAddressBook -bool false
    defaults write com.apple.Safari AutoFillPasswords -bool false
    defaults write com.apple.Safari AutoFillCreditCardData -bool false
    defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

    # Warn about fraudulent websites
    defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

    # Block pop-up windows
    defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

    # Disable auto-playing video
    defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
    defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
    defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false

    # Enable “Do Not Track”
    defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

    # Update extensions automatically
    defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

    # Disable send and reply animations in Mail.app
    defaults write com.apple.mail DisableReplyAnimations -bool true
    defaults write com.apple.mail DisableSendAnimations -bool true

    # Disable Safari’s thumbnail cache for History and Top Sites
    defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

    # Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
    defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

    # Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
    defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

    # Display emails in threaded mode, sorted by date (newest at the top)
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "no"
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

    # Disable inline attachments (just show the icons)
    defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

    # Change indexing order and disable some search results
    defaults write com.apple.spotlight orderedItems -array \
        '{"enabled" = 1;"name" = "APPLICATIONS";}' \
        '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
        '{"enabled" = 1;"name" = "DIRECTORIES";}' \
        '{"enabled" = 1;"name" = "PDF";}' \
        '{"enabled" = 1;"name" = "FONTS";}' \
        '{"enabled" = 0;"name" = "DOCUMENTS";}' \
        '{"enabled" = 0;"name" = "MESSAGES";}' \
        '{"enabled" = 0;"name" = "CONTACT";}' \
        '{"enabled" = 0;"name" = "EVENT_TODO";}' \
        '{"enabled" = 0;"name" = "IMAGES";}' \
        '{"enabled" = 0;"name" = "BOOKMARKS";}' \
        '{"enabled" = 0;"name" = "MUSIC";}' \
        '{"enabled" = 0;"name" = "MOVIES";}' \
        '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
        '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
        '{"enabled" = 0;"name" = "SOURCE";}'

    # Load new settings before rebuilding the index
    killall mds > /dev/null 2>&1
    # Make sure indexing is enabled for the main volume
    sudo mdutil -i on / > /dev/null
    # Rebuild the index from scratch
    sudo mdutil -E / > /dev/null

    # Disable the annoying line marks
    defaults write com.apple.Terminal ShowLineMarks -int 0

    # Don’t display the annoying prompt when quitting iTerm
    defaults write com.googlecode.iterm2 PromptOnQuit -bool false

    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    # Visualize CPU usage in the Activity Monitor Dock icon
    defaults write com.apple.ActivityMonitor IconType -int 5

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort Activity Monitor results by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    # Enable the debug menu in Address Book
    defaults write com.apple.addressbook ABShowDebugMenu -bool true

    # Enable the debug menu in Disk Utility
    defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
    defaults write com.apple.DiskUtility advanced-image-options -bool true

    # Don't autoplay videos when opened with QuickTime Player
    defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool false

    # Enable the WebKit Developer Tools in the Mac App Store
    defaults write com.apple.appstore WebKitDeveloperExtras -bool true

    # Enable Debug Menu in the Mac App Store
    defaults write com.apple.appstore ShowDebugMenu -bool true

    # Enable the automatic update check
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

    # Check for software updates daily, not just once per week
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

    # Download newly available updates in background
    defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

    # Install System data files & security updates
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

    # Turn on app auto-update
    defaults write com.apple.commerce AutoUpdate -bool true

    # Prevent Photos from opening automatically when devices are plugged in
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

    # Disable automatic emoji substitution (i.e. use plain text smileys)
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

    # Disable the all too sensitive backswipe on trackpads
    defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
    defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false
    defaults write com.mozilla.Firefox AppleEnableSwipeNavigateWithScrolls -bool false

    # Disable the all too sensitive backswipe on Magic Mouse
    defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
    defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false


    # Expand the print dialog by default
    defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
    defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

    # Use `~/Documents/Torrents` to store incomplete downloads
    defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
    defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Documents/Torrents"

    # Use `~/Downloads` to store completed downloads
    defaults write org.m0k.transmission DownloadLocationConstant -bool true

    # Don’t prompt for confirmation before removing non-downloading active transfers
    defaults write org.m0k.transmission CheckRemoveDownloading -bool true

    # Trash original torrent files
    defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

    # Hide the donate message
    defaults write org.m0k.transmission WarningDonate -bool false
    # Hide the legal disclaimer
    defaults write org.m0k.transmission WarningLegal -bool false

    # IP block list.
    # Source: https://giuliomac.wordpress.com/2014/02/19/best-blocklist-for-transmission/
    defaults write org.m0k.transmission BlocklistNew -bool true
    defaults write org.m0k.transmission BlocklistURL -string "http://john.bitsurge.net/public/biglist.p2p.gz"
    defaults write org.m0k.transmission BlocklistAutoUpdate -bool true

    # Randomize port on launch
    defaults write org.m0k.transmission RandomPort -bool true

    # Enable the hidden ‘Develop’ menu
    defaults write com.twitter.twitter-mac ShowDevelopMenu -bool true

    # Bypass the annoyingly slow t.co URL shortener
    defaults write com.tapbots.TweetbotMac OpenURLsDirectly -bool true

    # fix location
    defaults write com.apple.Dock size-immutable -bool yes

    # improve Safari security
    defaults write com.apple.Safari \
    com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled \
    -bool false
    defaults write com.apple.Safari \
    com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles \
    -bool false

    # diable automatic period substitution
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

    # allow text selection in Quick Look
    defaults write com.apple.finder QLEnableTextSelection -bool true

    defaults write com.apple.dock wvous-tl-corner -int 0
    defaults write com.apple.dock wvous-tr-corner -int 0
    defaults write com.apple.dock wvous-bl-corner -int 0
    defaults write com.apple.dock wvous-br-corner -int 0

    # Disable indexing of Time Machine backup drive
    sudo mdutil -i off /Volumes/ThunderBox

    # Multiple cursors (cmd+click)
    # https://twitter.com/dmartincy/status/988094014804160514
    defaults write com.apple.dt.Xcode PegasusMultipleCursorsEnabled -bool true

    # Show build times - http://stackoverflow.com/questions/1027923/how-to-enable-build-timing-in-xcode#answer-2801156
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES

    # Xcode 13.3 beta 1 Swift compiler new mode that better utilizes available
    # cores, resulting in faster builds for Swift projects.
    defaults write com.apple.dt.XCBuild EnableSwiftBuildSystemIntegration 1

    defaults write com.macromates.TextMate.preview fileBrowserSingleClickToOpen -bool true

    # Disable OSX Mail app auto loading (malicious) remote content in e-mails
    defaults write com.apple.mail-shared DisableURLLoading -bool true

    defaults write com.apple.sidecar.display AllowAllDevices -bool true; defaults write com.apple.sidecar.display hasShownPref -bool true; open /System/Library/PreferencePanes/Sidecar.prefPane

    defaults write com.pixelmatorteam.pixelmator PXCEnableOpenCLCPUBlit -bool no

    # Increase launchpad density
    defaults write com.apple.dock springboard-columns -int 8
    defaults write com.apple.dock springboard-rows -int 6

    # Speed up time machine backups
    sudo sysctl debug.lowpri_throttle_enabled=0

    defaults write -g QLPanelAnimationDuration -float 0

    defaults write com.apple.Safari WebKitInitialTimedLayoutDelay 0.25

    # To improve performance Safari will attempt to prefetch DNS information. In some circumstances this can result in slow or partial webpage loading, or webpage cannot be found errors.
    # If you are experiencing those problems, apply this tweak to disable DNS prefetching.
    #defaults write com.apple.safari WebKitDNSPrefetchingEnabled -boolean false

    defaults write com.apple.CrashReporter UseUNC 1

    # Hide icons on desktop
    defaults write com.apple.finder CreateDesktop -bool FALSE

    defaults write -g NSWindowResizeTime -float 0.001

    # Disable Dashboard
    defaults write com.apple.dashboard mcx-disabled -boolean true

    defaults write NSGlobalDomain NSWindowResizeTime .1

    # Disable Resume
    #defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

    defaults write com.apple.iTunes allow-half-stars -bool true

    defaults write com.apple.dock springboard-show-duration -int 0
    defaults write com.apple.dock springboard-hide-duration -int 0

    defaults write com.apple.finder ProhibitEmptyTrash -bool false

    # Set wallpaper
    osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/path/to/image.jpg"'

# Ensure changes are applied
    for app in "Activity Monitor" \
        "Address Book" \
        "Calendar" \
        "cfprefsd" \
        "Contacts" \
        "Dock" \
        "Finder" \
        "Google Chrome Canary" \
        "Google Chrome" \
        "Firefox" \
        "Mail" \
        "Messages" \
        "Opera" \
        "Photos" \
        "Safari" \
        "SizeUp" \
        "Spectacle" \
        "SystemUIServer" \
        "Terminal" \
        "Transmission" \
        "Tweetbot" \
        "Twitter" \
        "iCal"; do
        killall "${app}" &> /dev/null
    done

# Finishing touches
    echo "Configured your MacOS sucessfully! Some changes may require restart."
    if read -q "choice?Press Y/y to restart now: "; then
        restart
    else
        echo
    fi
}

#brew install progress

defaultsset #& progress -mp $!