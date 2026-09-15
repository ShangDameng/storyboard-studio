@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 分镜台 - 推送诊断
set OUT=诊断结果.txt

git config --global --get-all safe.directory 2>nul | findstr /i /c:"%CD%" >nul 2>nul || git config --global --add safe.directory "%CD%" >nul 2>nul

echo 分镜台 推送诊断 %date% %time% > "%OUT%"
echo. >> "%OUT%"

echo ==========================================
echo    诊断（结果同时写入 诊断结果.txt）
echo ==========================================
echo.

echo [1/7] git 版本 >> "%OUT%"
git --version >> "%OUT%" 2>&1

echo [2/7] 当前远程仓库 >> "%OUT%"
git remote -v >> "%OUT%" 2>&1
git remote get-url origin >nul 2>nul
if errorlevel 1 echo   （没有配置远程仓库 —— 说明还没成功执行过「① 第一次用」） >> "%OUT%"

echo [3/7] 提交记录 >> "%OUT%"
git log --oneline -3 >> "%OUT%" 2>&1

echo [4/7] 凭据与代理设置 >> "%OUT%"
echo   credential.helper(系统): >> "%OUT%"
git config --system --get credential.helper >> "%OUT%" 2>&1
echo   credential.helper(本地): >> "%OUT%"
git config --local --get credential.helper >> "%OUT%" 2>&1
echo   http.proxy: >> "%OUT%"
git config --global --get http.proxy >> "%OUT%" 2>&1

echo [5/7] DNS 解析 github.com >> "%OUT%"
nslookup github.com >> "%OUT%" 2>&1

echo [6/7] 连接 github.com:443 >> "%OUT%"
powershell -NoProfile -Command "try { $r = Test-NetConnection github.com -Port 443 -WarningAction SilentlyContinue; 'TcpTestSucceeded=' + $r.TcpTestSucceeded } catch { 'test failed' }" >> "%OUT%" 2>&1

echo [7/7] 尝试访问仓库 / 推送 >> "%OUT%"
git ls-remote origin >> "%OUT%" 2>&1
git push >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo [本地常见代理端口探测] >> "%OUT%"
for %%P in (7890 7897 10809 1080 8080) do (
  powershell -NoProfile -Command "if ((Test-NetConnection 127.0.0.1 -Port %%P -WarningAction SilentlyContinue).TcpTestSucceeded) { 'localhost:%%P 有代理在监听' } else { 'localhost:%%P 未监听' }" >> "%OUT%" 2>&1
)

echo.
echo 诊断完成，结果已写入：
echo   %CD%\%OUT%
echo.
echo 把这个文件的内容发给我，我照着帮你处理。
echo （也可以直接看上面窗口里的 [6/7] 那行：如果不是 True，就是网络连不上 GitHub）
echo.
start "" notepad "%OUT%"
pause
