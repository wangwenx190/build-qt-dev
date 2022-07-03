:: MIT License
::
:: Copyright (C) 2022 by wangwenx190 (Yuhang Zhao)
::
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
::
:: The above copyright notice and this permission notice shall be included in
:: all copies or substantial portions of the Software.
::
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
:: SOFTWARE.

@echo off
setlocal
title Preparing VCPKG ...
set __repo_root_dir=%~dp0..
set __vcpkg_dir=%__repo_root_dir%\vcpkg
call "%~dp0vcpkg-config.bat"
set __git_clone_url=https://github.com/microsoft/vcpkg.git
:: Separate the branch name here in case it changes to something else
:: in the future.
set __git_clone_branch=master
:: Use shallow clone to reduce the download size and time.
:: We don't need the commit history after all.
set __git_clone_params=clone --depth 1 --branch %__git_clone_branch% --single-branch --no-tags %__git_clone_url%
set __git_fetch_params=fetch --depth=1 --no-tags
set __git_reset_params=reset --hard origin/%__git_clone_branch%
cd /d "%__repo_root_dir%"
if exist "%__vcpkg_dir%" rd /s /q "%__vcpkg_dir%"
git %__git_clone_params%
cd /d "%__vcpkg_dir%"
:: Apply our custom modification to VCPKG.
git apply "%__repo_root_dir%\patches\vcpkg.diff"
:: Always try to get the latest VCPKG tool.
call "%__vcpkg_dir%\bootstrap-vcpkg.bat"
cd /d "%__vcpkg_dir%"
for %%i in (%__vcpkg_triplets%) do vcpkg install %__qt_deps% --triplet=%%i
:: Always try to update the libraries to the latest version.
vcpkg update
:: Without the "--no-dry-run" parameter, VCPKG won't upgrade
:: the installed libraries in reality.
vcpkg upgrade --no-dry-run
:: Cleanup. GitHub Actions's machine doesn't have too much disk space.
rd /s /q "%__vcpkg_dir%\buildtrees"
goto success

:success
cd /d "%__repo_root_dir%"
endlocal
if /i not "%GITHUB_ACTIONS%" == "true" pause
exit /b 0

:fail
cd /d "%__repo_root_dir%"
endlocal
if /i not "%GITHUB_ACTIONS%" == "true" pause
exit /b -1
