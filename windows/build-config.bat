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
:: Modify this line to suit your own personal needs.
:: Be careful about the dependencies of each repository.
:: qtbase should always be the first one to build.
:: We need the QtTools module for its linguist tools,
:: they are necessary for applications that support i18n.
:: Temporarily removed qtwebengine: doesn't work well with VC-LTL.
set __qt_modules=qtbase,qtshadertools,qtimageformats,qtlanguageserver,qtsvg,qttools,qtdeclarative,qt5compat,qtquicktimeline,qtquick3d,qtquickeffectmaker,qttranslations
:: Supported values: clang-cl, mingw and msvc
set __compiler=msvc
:: Supported values: x64, x86 and arm64
set __arch=x64
:: Supported values: shared and static
set __lib_type=static
:: Supported values: debug, minsizerel, release, relwithdebinfo and debugandrelease
set __build_type=release
exit /b 0
