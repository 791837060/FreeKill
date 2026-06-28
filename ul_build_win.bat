@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM FreeKill Windows release build (Qt 6.5.3 MinGW)
REM Can run from normal cmd; sets Qt/MinGW paths automatically.
REM
REM *** git restore 步骤前，建议先在仓库根目录 git commit ***
REM 未提交时 git restore 会还原 Fk/lua 等；步骤 [8/14] 可覆盖本地未提交的 freekill-core。
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

echo [1/14] Remove old build directory...
if exist "%BUILD%" rmdir /s /q "%BUILD%"

echo [2/14] CMake configure...
cmake -DCMAKE_BUILD_TYPE=MinSizeRel -G "MinGW Makefiles" ^
  -DCMAKE_PREFIX_PATH="%QT_ROOT%" ^
  -DCMAKE_C_COMPILER="%MINGW_BIN%/gcc.exe" ^
  -DCMAKE_CXX_COMPILER="%MINGW_BIN%/g++.exe" ^
  -DCMAKE_MAKE_PROGRAM="%MINGW_MAKE%" ^
  -B "%BUILD%" "%ROOT%"
if errorlevel 1 goto :fail

echo [3/14] Compile FreeKill...
cd /d "%BUILD%" || exit /b 1
mingw32-make -j2
if errorlevel 1 goto :fail

echo [4/14] Prepare release directory...
cd /d "%ROOT%" || exit /b 1
if exist "%RELEASE%" rmdir /s /q "%RELEASE%"
mkdir "%RELEASE%"

echo [5/14] Copy FreeKill.exe...
copy /y "%BUILD%\FreeKill.exe" "%RELEASE%\" >nul
if errorlevel 1 goto :fail

echo [6/14] Copy Fk resources...
xcopy "%ROOT%\Fk" "%RELEASE%\Fk\" /E /I /Y /Q >nul
if errorlevel 1 goto :fail

echo [7/14] git restore - sync release tree from last commit...
echo ============================================================
echo  IMPORTANT: git restore 前请先在仓库根目录提交源码！
echo  cd %ROOT%
echo  git add -A ^&^& git commit -m "your message"
echo  未提交时 restore 会用旧版 Fk/QML，release 可能启动失败。
echo  步骤 [8/14] 会用工作区 packages/freekill-core 覆盖 release（已纳入本仓库，overlay 仅用于未提交改动）。
echo ============================================================
cd /d "%RELEASE%" || exit /b 1
if exist "%ROOT%\.git" (
  powershell -NoProfile -Command "Copy-Item -Path '%ROOT%\.git' -Destination '.' -Recurse -Force"
  git restore .
  if errorlevel 1 (
    echo ERROR: git restore failed. Did you commit your changes first?
    goto :fail
  )
) else (
  echo ERROR: .git not found at %ROOT%
  goto :fail
)

echo [8/14] Overlay packages/freekill-core from workspace...
cd /d "%ROOT%" || exit /b 1
if exist "%ROOT%\packages\freekill-core" (
  if not exist "%RELEASE%\packages\freekill-core" mkdir "%RELEASE%\packages\freekill-core"
  xcopy "%ROOT%\packages\freekill-core\*" "%RELEASE%\packages\freekill-core\" /E /I /Y /Q >nul
  if errorlevel 1 goto :fail
) else (
  echo WARN: packages/freekill-core not found, skip overlay.
)

echo [9/14] Remove dev-only folders from release...
cd /d "%RELEASE%" || exit /b 1
for %%D in (.git .github android doc lib lang translations src) do (
  if exist "%%D" rmdir /s /q "%%D"
)
for /f "delims=" %%F in ('dir /b /a:-d .git* 2^>nul') do del /f /q "%%F" 2>nul

echo [10/14] Copy runtime libs (lua/sqlite/git2)...
cd /d "%ROOT%" || exit /b 1
copy /y "%ROOT%\lib\win\*" "%RELEASE%\" >nul

echo [11/14] Copy zh_CN.qm...
if exist "%BUILD%\zh_CN.qm" (
  copy /y "%BUILD%\zh_CN.qm" "%RELEASE%\" >nul
) else if exist "%ROOT%\zh_CN.qm" (
  copy /y "%ROOT%\zh_CN.qm" "%RELEASE%\" >nul
) else (
  echo WARN: zh_CN.qm not found in build or project root.
)

echo [12/14] Copy word audio...
if exist "%ROOT%\audio\word" (
  if not exist "%RELEASE%\audio\word" mkdir "%RELEASE%\audio\word"
  xcopy "%ROOT%\audio\word\*" "%RELEASE%\audio\word\" /E /I /Y /Q >nul
) else (
  echo WARN: word audio not found at %ROOT%\audio\word
)

echo [13/14] Copy Qt/OpenSSL DLLs...
copy /y "%QT_BIN%\li*.dll" "%RELEASE%\" >nul
if exist "%OPENSSL_DLL%" (
  copy /y "%OPENSSL_DLL%" "%RELEASE%\" >nul
) else (
  echo WARN: OpenSSL DLL not found: %OPENSSL_DLL%
)

echo [14/14] Run windeployqt (must match %QT_ROOT%)...
cd /d "%RELEASE%" || exit /b 1
if exist "qml" rmdir /s /q "qml"
if exist "plugins" rmdir /s /q "plugins"
"%QT_BIN%\windeployqt.exe" --no-translations FreeKill.exe
if errorlevel 1 goto :fail

echo [14/14] Done.
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
