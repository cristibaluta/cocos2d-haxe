There are 2 ways to compile a cocos2d project

1. use the build.hxml file to compile for flash:

haxe build.hxml


2. use the build.nmml file to compile with NME:

Commands used to build your project:

nme test "build.nmml" flash
nme test "build.nmml" ios -simulator
nme test "build.nmml" ios -device
nme test "build.nmml" webos
nme test "build.nmml" android
nme test "build.nmml" windows
nme test "build.nmml" mac
nme test "build.nmml" linux
nme test "build.nmml" html5

Some targets may require additional setup, always check NME website http://www.haxenme.org/developers/get-started

For more information on what commands and flags are supported, run "nme help"

*NME can publish directly to the iOS simulator, but cannot install to devices 
after making a device build. To test on an iOS device, you can use "update" or "build", 
then install using the XCode organizer, or open and build the generated XCode project manually.


nme setup windows
nme setup linux
nme setup android
nme setup webos
