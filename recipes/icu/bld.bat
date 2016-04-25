rem ROBOCOPY include %LIBRARY_inc% * /E

rem if %ERRORLEVEL% LSS 8 exit 0
cd source

:: MSYS includes a link.exe that is not MSVC's linker.  Hide it.
MOVE %LIBRARY_PREFIX%\usr\bin\link.exe %LIBRARY_PREFIX%\usr\bin\link.exe.backup

where bash

bash -c "echo $PATH"
bash -c "echo $(which link.exe)"
bash runConfigureICU MSYS/MSVC --prefix=%LIBRARY_PREFIX% --enable-static
if errorlevel 1 exit 1
make
if errorlevel 1 exit 1
make install
if errorlevel 1 exit 1

:: Restore MSYS' link.exe
MOVE %LIBRARY_PREFIX%\usr\bin\link.exe.backup %LIBRARY_PREFIX%\usr\bin\link.exe
exit 0
