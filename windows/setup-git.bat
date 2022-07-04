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

:: We want to see the corresponding commands in the console.
@echo on
:: A common mistake is forgetting to add new files to a commit. Therefore it is recommended to set up git to always show them in git stat and git commit, even if this is somewhat slower (especially on Windows):
git config --global status.showuntrackedfiles all
:: Pre-2.0 git has a somewhat stupid default that git push will push all branches to the upstream repository, which is almost never what you want. To fix this, use:
git config --global push.default tracking
:: Sometimes it is necessary to resolve the same conflicts multiple times. Git has the ability to record and replay conflict resolutions automatically, but - surprise surprise - it is not enabled by default. To fix it, run:
git config --global rerere.enabled true
:: this saves you the git add, but you should verify the result with git diff --staged
git config --global rerere.autoupdate true
:: git pull will show a nice diffstat, so you get an overview of the changes from upstream. git pull --rebase does not do that by default. But you want it:
git config --global rebase.stat true
:: To get nicely colored patches (from git diff, git log -p, git show, etc.), use this:
git config --global color.ui auto
git config --global core.pager "less -FRSX"
:: Let git automatically apply the appropriate line endings for the current platform.
git config --global core.autocrlf true
@echo off
exit /b 0
