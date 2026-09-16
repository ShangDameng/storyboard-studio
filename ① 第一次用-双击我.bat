@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 拉片工坊 - 第一次推送到 GitHub

rem 这个文件夹的 git 仓库可能是别的账号创建的，Git 会因此拒绝操作；按官方建议加个白名单
git config --global --get-all safe.directory 2>nul | findstr /i /c:"%CD%" >nul 2>nul || git config --global --add safe.directory "%CD%" >nul 2>nul

rem ===== 用户名 / 仓库名不对就改这两行 =====
set GH_USER=ShangDameng
set GH_REPO=storyboard-studio

set REPO_URL=https://github.com/%GH_USER%/%GH_REPO%.git
set PAGES_URL=https://%GH_USER%.github.io/%GH_REPO%/
set LOG=推送日志.txt
echo 拉片工坊 推送日志 %date% %time% > "%LOG%"

echo ==========================================
echo    第一次推送（只做一次）
echo ==========================================
echo   GitHub 账号： %GH_USER%
echo   仓库名：      %GH_REPO%
echo.

where git >nul 2>nul
if errorlevel 1 goto nogit

echo 第 1 步：建一个空仓库（只做一次）
echo   马上打开的页面里：
echo     Repository name 填： %GH_REPO%
echo     选 Public
echo     Add a README / .gitignore / license 都不要勾
echo     点绿色的 Create repository
echo.
echo   如果这个仓库你之前已经建过了，直接按任意键继续。
echo.
start "" "https://github.com/new?name=%GH_REPO%&visibility=public"
pause >nul

echo.
echo 第 2 步：检查能不能连上这个仓库...
git config --local credential.helper manager
git ls-remote "%REPO_URL%" > "%TEMP%\lsr.txt" 2>&1
set LSRC=%ERRORLEVEL%
type "%TEMP%\lsr.txt" >> "%LOG%"
if not "%LSRC%"=="0" goto connfail
echo   OK，仓库可以访问。

echo.
echo 第 3 步：提交并推送...
git add -A
git commit -m "拉片工坊 静态站点" >> "%LOG%" 2>&1
git remote remove origin >nul 2>nul
git remote add origin "%REPO_URL%"
git push -u origin main >> "%LOG%" 2>&1
if errorlevel 1 goto pushfail

echo.
echo ==========================================
echo   推送成功！
echo ==========================================
echo.
echo 第 4 步：开启 GitHub Pages（只做一次）
echo   马上打开的页面里：
echo     Source 选 Deploy from a branch
echo     Branch 选 main，右边目录选 / (root)
echo     点 Save
echo.
echo 等 1 分钟，手机 / 平板 / 电脑都能打开：
echo   %PAGES_URL%
echo.
echo 打开后建议在手机上“添加到主屏幕”，以后点图标就用，没网也能用。
start "" "https://github.com/%GH_USER%/%GH_REPO%/settings/pages"
goto end

:connfail
echo.
echo ==========================================
echo   连不上这个仓库，先别急着推送
echo ==========================================
echo.
findstr /i /c:"Repository not found" "%TEMP%\lsr.txt" >nul && (
  echo   原因：仓库不存在，或者用户名 / 仓库名写错了。
  echo         请确认已经打开过 https://github.com/new 建好 “%GH_REPO%”，
  echo         如果仓库名不是这个，用记事本改本文件开头的 GH_REPO= 那行。
) 
findstr /i /c:"Authentication failed" "%TEMP%\lsr.txt" >nul && (
  echo   原因：GitHub 授权失败。关掉登录窗口后重新双击本文件，重新授权一次。
)
findstr /i /c:"could not read Username" "%TEMP%\lsr.txt" >nul && (
  echo   原因：没有弹出 GitHub 登录窗口。双击本文件重试，注意弹出的浏览器授权页。
)
findstr /i /c:"Failed to connect" "%TEMP%\lsr.txt" >nul && goto netfail
findstr /i /c:"Could not resolve" "%TEMP%\lsr.txt" >nul && goto netfail
findstr /i /c:"timed out" "%TEMP%\lsr.txt" >nul && goto netfail
goto diag

:netfail
echo   原因：连不上 github.com（网络问题，国内常见）。
echo         请依次试：
echo           1) 打开你常用的代理软件，或换手机热点再试
echo           2) 有条件的话给 git 配代理，例如 Clash 默认端口：
echo              git config --global http.proxy http://127.0.0.1:7890
echo              git config --global https.proxy http://127.0.0.1:7890
echo           3) 不想折腾网络的话，改用 Cloudflare Pages：
echo              在浏览器打开 https://dash.cloudflare.com 注册后，
echo              Workers ^& Pages 新建 Pages，把本文件夹里除 .bat 之外的文件拖上去即可
goto diag

:pushfail
echo.
echo 推送失败，详细输出已写入 %LOG%。
goto diag

:diag
echo.
echo 详细日志已经保存为： %CD%\%LOG%
echo 需要我帮你判断的话，把这个文件的内容发我。
goto end

:nogit
echo.
echo [X] 没检测到 git，请先装 Git for Windows：https://git-scm.com/download/win
goto end

:end
echo.
pause
