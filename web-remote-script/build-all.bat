@echo off
echo === Build All Web Services ===
echo.

echo Building dtj-app...
cd /d "..\dtj\dtj-app"
quasar build
cd /d "..\..\web-remote-script"

echo Building tofi-admin...
cd /d "..\tofi-admin"
quasar build
cd /d "..\web-remote-script"

echo Building tofi-meta...
cd /d "..\tofi-meta"
quasar build
cd /d "..\web-remote-script"

echo Building tofi-cube...
cd /d "..\tofi-cube"
quasar build
cd /d "..\web-remote-script"

echo Building tofi-userdata...
cd /d "..\tofi-userdata"
quasar build
cd /d "..\web-remote-script"

echo Building tofi-data...
cd /d "..\tofi-data"
quasar build
cd /d "..\web-remote-script"

echo Building tofi-nsi...
cd /d "..\dtj\tofi-nsi"
quasar build
cd /d "..\..\web-remote-script"

echo.
echo === Build completed ===
pause
pause
echo.
