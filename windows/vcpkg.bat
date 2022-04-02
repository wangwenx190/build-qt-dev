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
title Preparing vcpkg ...
set __repo_root_dir=%~dp0..
set __vcpkg_dir=%__repo_root_dir%\vcpkg
set __vcpkg_triplets=x64-windows-static-md,x86-windows-static-md
:: ZSTD: needed by QtCore & QtNetwork
:: ICU: needed by QtCore & QtCore5Compat & QtWebEngine
:: OpenSSL: needed by QtNetwork (the OpenSSL backend)
:: FFmpeg: needed by QtMultimedia (the FFmpeg backend)
:: Build these libraries as static libraries so that we don't have to
:: distribute a lot of separate dlls along side with Qt.
:: Feel free to change them if you are worried about license issues.
set __qt_deps=zstd openssl icu ffmpeg
set __git_clone_url=https://github.com/microsoft/vcpkg.git
:: Separate the branch name here in case it changes to "main" or
:: some other name in the future.
set __git_clone_branch=master
:: Use shallow clone to reduce the download size and time.
:: We don't need the commit history after all.
set __git_clone_params=clone --depth 1 --branch %__git_clone_branch% --single-branch --no-tags %__git_clone_url%
set __git_fetch_params=fetch --depth=1 --no-tags
set __git_reset_params=reset --hard origin/%__git_clone_branch%
cd /d "%__repo_root_dir%"
if exist "%__vcpkg_dir%" (
    cd "%__vcpkg_dir%"
    git %__git_fetch_params%
    git %__git_reset_params%
    :: Don't execute "git clean" here, otherwise all our build
    :: artifacts will be deleted permanently!
) else (
    git %__git_clone_params%
    cd "%__vcpkg_dir%"
)
:: Always try to get the latest vcpkg tool.
call "%__vcpkg_dir%\bootstrap-vcpkg.bat"
cd /d "%__vcpkg_dir%"
for %%i in (%__vcpkg_triplets%) do vcpkg install %__qt_deps% --triplet=%%i
:: Always try to update the libraries to the latest version.
vcpkg update
:: Without the "--no-dry-run" parameter, vcpkg won't upgrade
:: the installed libraries in reality.
vcpkg upgrade --no-dry-run
cd /d "%__repo_root_dir%"
endlocal
exit /b
