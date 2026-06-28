@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM FreeKill Windows release build (Qt 6.5.3 MinGW)
REM Can run from normal cmd; sets Qt/MinGW paths automatically.
REM ============================================================

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "BUILD=%ROOT%\build"
set "RELEASE=%ROOT%\FreeKill-release"

set "QT_ROOT=D:\Qt\6.5.3\mingw_64"
set "QT_BIN=%QT_ROOT%\bin"
set "MINGW_BIN=D:\Qt\Tools\mingw1120_64\bin"
set "MINGW_MAKE=%MINGW_BIN%\make.exe"
set "OPENSSL_DLL=C:\Program Files\OpenSSL-Win64\bin\libcrypto-1_1-x64.dll"

set "PATH=%MINGW_BIN%;%QT_BIN%;%PATH%"

if not exist "%QT_BIN%\qmake.exe" (
  echo ERROR: Qt not found at %QT_ROOT%
  exit /b 1
)
if not exist "%MINGW_MAKE%" (
  echo ERROR: mingw make not found at %MINGW_MAKE%
  exit /b 1
)

cd /d "%ROOT%" || exit /b 1

echo [1/13] Remove old build directory...
if exist "%BUILD%" rmdir /s /q "%BUILD%"

echo [2/13] CMake configure...
cmake -DCMAKE_BUILD_TYPE=MinSizeRel -G "MinGW Makefiles" ^
  -DCMAKE_PREFIX_PATH="%QT_ROOT%" ^
  -DCMAKE_C_COMPILER="%MINGW_BIN%/gcc.exe" ^
  -DCMAKE_CXX_COMPILER="%MINGW_BIN%/g++.exe" ^
  -DCMAKE_MAKE_PROGRAM="%MINGW_MAKE%" ^
  -B "%BUILD%" "%ROOT%"
if errorlevel 1 goto :fail

echo [3/13] Compile FreeKill...
cd /d "%BUILD%" || exit /b 1
mingw32-make -j2
if errorlevel 1 goto :fail

echo [4/13] Prepare release directory...
cd /d "%ROOT%" || exit /b 1
if exist "%RELEASE%" rmdir /s /q "%RELEASE%"
mkdir "%RELEASE%"

echo [5/13] Export git tracked files to release...
if not exist "%ROOT%\.git" (
  echo ERROR: .git not found at %ROOT%
  goto :fail
)
git checkout-index -a -f --prefix="FreeKill-release/"
if errorlevel 1 (
  echo ERROR: git checkout-index failed.
  goto :fail
)

echo [6/13] Copy build outputs and workspace overlays...
copy /y "%BUILD%\FreeKill.exe" "%RELEASE%\" >nul
if errorlevel 1 goto :fail
if exist "%ROOT%\Fk" (
  xcopy "%ROOT%\Fk" "%RELEASE%\Fk\" /E /I /Y /Q >nul
  if errorlevel 1 goto :fail
)
if exist "%ROOT%\packages\freekill-core" (
  if not exist "%RELEASE%\packages\freekill-core" mkdir "%RELEASE%\packages\freekill-core"
  xcopy "%ROOT%\packages\freekill-core\*" "%RELEASE%\packages\freekill-core\" /E /I /Y /Q >nul
  if errorlevel 1 goto :fail
)

echo [7/13] Remove dev-only folders from release...
cd /d "%RELEASE%" || exit /b 1
for %%D in (.git .github android doc lib lang translations src) do (
  if exist "%%D" rmdir /s /q "%%D"
)
for /f "delims=" %%F in ('dir /b /a:-d .git* 2^>nul') do del /f /q "%%F" 2>nul
if exist "packages\freekill-core\.git" rmdir /s /q "packages\freekill-core\.git"

echo [8/13] Copy runtime libs (lua sqlite git2)...
cd /d "%ROOT%" || exit /b 1
copy /y "%ROOT%\lib\win\*" "%RELEASE%\" >nul

echo [9/13] Copy zh_CN.qm...
if exist "%BUILD%\zh_CN.qm" (
  copy /y "%BUILD%\zh_CN.qm" "%RELEASE%\" >nul
) else if exist "%ROOT%\zh_CN.qm" (
  copy /y "%ROOT%\zh_CN.qm" "%RELEASE%\" >nul
) else (
  echo WARN: zh_CN.qm not found in build or project root.
)

echo [10/13] Copy word audio...
if exist "%ROOT%\audio\word" (
  if not exist "%RELEASE%\audio\word" mkdir "%RELEASE%\audio\word"
  xcopy "%ROOT%\audio\word\*" "%RELEASE%\audio\word\" /E /I /Y /Q >nul
) else (
  echo WARN: word audio not found at %ROOT%\audio\word
)

echo [11/13] Copy Qt OpenSSL DLLs...
copy /y "%QT_BIN%\li*.dll" "%RELEASE%\" >nul
if exist "%OPENSSL_DLL%" (
  copy /y "%OPENSSL_DLL%" "%RELEASE%\" >nul
) else (
  echo WARN: OpenSSL DLL not found: %OPENSSL_DLL%
)

echo [12/13] Run windeployqt (must match %QT_ROOT%)...
cd /d "%RELEASE%" || exit /b 1
if exist "qml" rmdir /s /q "qml"
if exist "plugins" rmdir /s /q "plugins"
"%QT_BIN%\windeployqt.exe" --no-translations FreeKill.exe
if errorlevel 1 goto :fail

echo [13/13] Done.
echo.
echo ============================================================
echo Build OK: %RELEASE%
echo Run: %RELEASE%\FreeKill.exe
echo ============================================================
exit /b 0

:fail
echo.
echo ERROR: build failed at step above.
exit /b 1
