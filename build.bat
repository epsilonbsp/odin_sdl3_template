@echo off
setlocal EnableDelayedExpansion

set EXE_NAME=odin_sdl3_template.exe
set SDL_VERSION=release-3.4.2

if not exist build mkdir build
if not exist build\output mkdir build\output
if not exist build\vendor mkdir build\vendor

cls

if "%~1" == "get-sdl3" (
    curl -L -o build\output\SDL3.dll https://raw.githubusercontent.com/odin-lang/Odin/master/vendor/sdl3/SDL3.dll
    curl -L -o build\output\SDL3.lib https://raw.githubusercontent.com/odin-lang/Odin/master/vendor/sdl3/SDL3.lib
)

if "%~1" == "build-sdl3" (
    for /f "tokens=*" %%i in ('"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath') do set VS=%%i

    if "!VS!" equ "" (
        echo ERROR: MSVC installation not found
        exit /b 1
    )

    cd build\vendor

    if not exist sld (
        git clone https://github.com/libsdl-org/SDL.git sdl
    )

    cd sdl

    git checkout %SDL_VERSION%
    call "!VS!\Common7\Tools\vsdevcmd.bat" -arch=x64 -host_arch=x64 || exit /b 1
    cmake -S . -B build
    cmake --build build --config Release

    cd ..\..
    copy /Y "vendor\sdl\build\Release\SDL3.dll" "output\SDL3.dll"
    copy /Y "vendor\sdl\build\Release\SDL3.lib" "output\SDL3.lib"
)

if "%~1" == "build" (
    odin build source -out:build\output\%EXE_NAME%
)

if "%~1" == "run" (
    odin run source -out:build\output\%EXE_NAME%
)

if "%~1" == "build-debug" (
    odin build source -out:build\output\%EXE_NAME% -debug
)

if "%~1" == "run-debug" (
    odin run source -out:build\output\%EXE_NAME% -debug
)
