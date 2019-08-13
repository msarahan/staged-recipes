:: this corresponds to VS 2017.  We should fix this to be more dynamically detected according to the active env, though.
set platform_toolset=v141

nuget restore vswhere.sln

sed -i 's/<WindowsTargetPlatformVersion>8.1/<WindowsTargetPlatformVersion>%WindowsSDKVer%/g' src\vswhere\vswhere.vcxproj
sed -i 's/<WindowsTargetPlatformVersion>8.1/<WindowsTargetPlatformVersion>%WindowsSDKVer%/g' test\vswhere.test\vswhere.test.vcxproj
sed -i 's/<WindowsTargetPlatformVersion>8.1/<WindowsTargetPlatformVersion>%WindowsSDKVer%/g' src\vswhere.lib\vswhere.lib.vcxproj

:: NOTE: PlatformToolset defaults to v141_xp by default (for max back compat).  That's not 
::    installed with VS by default, so removing it seems wise.  This recipe assumes VS2017 is 
::    installed and in use.
msbuild /p:Configuration=Release /p:Platform=x86 /p:PlatformToolset=%platform_toolset% vswhere.sln 

sed -i 's/<WindowsTargetPlatformVersion>8.1/<WindowsTargetPlatformVersion>%WindowsSDKVer%/g' src\vswhere\vswhere.vcxproj
sed -i 's/<WindowsTargetPlatformVersion>8.1/<WindowsTargetPlatformVersion>%WindowsSDKVer%/g' test\vswhere.test\vswhere.test.vcxproj
sed -i 's/<WindowsTargetPlatformVersion>8.1/<WindowsTargetPlatformVersion>%WindowsSDKVer%/g' src\vswhere.lib\vswhere.lib.vcxproj

msbuild /p:Configuration=Release /p:Platform=x86 /p:PlatformToolset=%platform_toolset% vswhere.sln 
