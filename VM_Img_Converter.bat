@echo off
Title VM Image Converter
Color A
setlocal enabledelayedexpansion

set desktop_folder=%USERPROFILE%\Desktop\OVA Temp
if not exist "%desktop_folder%" (
    mkdir "%desktop_folder%"
    echo [^+] %desktop_folder% was created, the .img conversion file will be stored here.
) else (
    echo [^!] %desktop_folder% found, the .img conversion file will be stored here.
)

echo [^^!] Warning!
echo [-] Leave this prompt open while following these directions:
echo [^^!] Before proceeding, follow the directions below:
echo.
echo		1.  Open Oracle VirtualBox
echo 	2.  Select "file", and then "Export Appliance"
echo 	3.  Select the VM you want to convert by left single clicking on the VM name
echo 	4.  Click "Next"
echo 	5.  Locate the line "Format"
echo 	6.  Click the down arrow
echo 	7.  Select "Open Virtualization Format 2.0"
echo 	8.  Locate the line "File"
echo 	9.  Click the folder icon next to this line
echo		10. Navigate to Desktop
echo 	11. Select folder named OVA Temp
echo 	12. Click "Open"
echo		13. Click "Save"
echo		14. Uncheck "Write Manifest file"
echo		15. Check "Include ISO image files"
echo 	16. Click "Next"
echo 	17. Click "Finish"
echo.
echo [^^!] Do not proceed until you have completed the above steps, IN ORDER!
echo [-] This program will pause while the above steps are completed
echo [-] Once you have completed the above steps,
echo [-] Press any key to continue
pause >nul

cls
echo [-] Leave this prompt open while following these directions:
echo [-] Proceed to the following steps:
echo.
echo		1. Open the OVA Temp folder on your Desktop
echo		2. Hold shift and right click on the .ova file here
echo		3. Select "copy as path"
echo		4. Paste this path as the answer to the next question
echo.
echo [^^!] Do not proceed until you have completed the above steps, IN ORDER!
echo [-] This program will pause while the above steps are completed
echo [-] Once you have completed the above steps,
echo [-] Press any key to continue
pause >nul

:EnterInfo
cls
set /p ova_location=[?] Enter the location of the .ova file created from the VM Export: 
set /p box_name=[-] Enter the name of the VM: 
set ova_location=!ova_location:"=!
echo [-]
echo [^^!] Are you absolutley sure of the previous answers??
echo [-] Double check the answers
echo [-] Select Y to continue if answers are correct
echo [-] Select N to re-enter answers in case of error
goto CheckAnswers

:CheckAnswers
set /p input="[-] Are your answers correct (y/n)?: "
if not defined input goto CheckAnswers
if /i %input% == y (goto Continue)
if /i %input% == n (goto No) else (goto invalid)

:No
set %input% = ''
set %ova_location% = ''
set %box_name% = ''
goto EnterInfo

:invalid
echo [-] You can only choose y/n
echo [-] Try again
set %input% = ''
goto CheckAnswers

:Continue
echo [-]
timeout /nobreak 1 >nul
echo [-] Checking for .img destination folder...
timeout /nobreak 1 >nul
echo [-]

timeout /nobreak 1 >nul
echo [-] Conversion in process...
cd /d "%desktop_folder%"
tar -xvf "!ova_location!" -C "%desktop_folder%"

set vmdk_file="%desktop_folder%\%box_name%-disk001.vmdk"
for /F "skip=1 tokens=1-6 delims= " %%G in ('wmic Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') do (
    set timestamp=%%L-%%J-%%G_%%K-%%H-%%I
)
set vmdk_destination="%desktop_folder%\%box_name%-%timestamp%.img"

cd "C:\Program Files\Oracle\VirtualBox"
VBoxManage.exe clonehd -format raw %vmdk_file% %vmdk_destination% 2> nul
VBoxManage.exe closemedium disk %vmdk_file%
ren %vmdk_destination% "%box_name%.img"

echo [-]
timeout /nobreak 2 >nul
echo [-] Conversion completed successfully.
echo [-] The converted .img file is located at: %vmdk_destination:---_--=%
echo [-] Press any key when ready to end..
pause >nul
exit