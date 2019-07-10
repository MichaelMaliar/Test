::
:: The main file of the tweak. The tweak was made by Michael Maliar. Главный файл твика. Твик сделал Маляр Михаил. GitHub: https://github.com/MichaelMaliar/Windows-10-Tweak.git
::

@echo off
@title Windows 10 Tweak
:: Включение расширенной обработки команд
SetLocal EnableExtensions
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Проверка административных прав
reg query "HKU\S-1-5-19" 2>nul 1>&2
if %errorlevel% == 1 goto UAC
if %errorlevel% == 0 goto end

:UAC
	:: Создание скрипта, который перезапустит Setup.cmd от имени администратора. Скрипт самоудалится.
	echo CreateObject^("Shell.Application"^).ShellExecute WScript.Arguments^(0^),"1","","runas",1 > %TEMP%\UACPrompt.vbs
	echo. >> %TEMP%\UACPrompt.vbs
	echo 'Self Remove >> %TEMP%\UACPrompt.vbs
	echo discardScript() >> %TEMP%\UACPrompt.vbs
	echo Function discardScript() >> %TEMP%\UACPrompt.vbs
	echo Set objFSO = CreateObject("Scripting.FileSystemObject") >> %TEMP%\UACPrompt.vbs
	echo strScript = Wscript.ScriptFullName >> %TEMP%\UACPrompt.vbs
	echo objFSO.DeleteFile(strScript) >> %TEMP%\UACPrompt.vbs
	echo End Function >> %TEMP%\UACPrompt.vbs
	:: Вызов скрипта
	cscript //Nologo %TEMP%\UACPrompt.vbs "%~f0"
	exit

:end
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Копирование скрипта обновляющего проводник в папку Windows и иконки для его ярлыка
echo F | xcopy "%~dp0Refresh.vbs" %SystemRoot% /Y /C >nul
echo F | xcopy "%~dp0Refresh.ico" %SystemRoot% /Y /C >nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Если на рабочем столе не будет ярлыка Refresh, то это значит что твик запущен из папки, а не exe файлом. Будет создан ярлык с помощью CreateShortCut.js
if not exist %UserProfile%\Desktop\Refresh.lnk cscript //B //Nologo "%~dp0CreateShortCut.js"
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Проверка выключена ли защита от подделки в Windows Defender. Без этого многая часть параметров не применится.
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Features" /v TamperProtection 2>nul 1>&2 | find "0x5" >nul
if %errorlevel% == 1 goto Check
if %errorlevel% == 0 goto Out

goto end

:Check
	reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Features" /v TamperProtection 2>nul 1>&2 | find "0x1" >nul
	if %errorlevel% == 1 goto end2
	if %errorlevel% == 0 goto Out2

	goto end2

	:Out2
		powershell echo `a
		powershell -Nologo -command "Write-Host ' Error: Tamper Protection enabled!' -ForegroundColor Red"
		cscript //Nologo "%~dp0TamperProtection.vbs"
		if exist %SystemRoot%\Windows_10_Tweak rd /Q /S %SystemRoot%\Windows_10_Tweak 2>nul
		exit

	:end2
goto end

:Out
	powershell echo `a
	powershell -Nologo -command "Write-Host ' Error: Tamper Protection enabled!' -ForegroundColor Red"
	cscript //Nologo "%~dp0TamperProtection.vbs"
	if exist %SystemRoot%\Windows_10_Tweak rd /Q /S %SystemRoot%\Windows_10_Tweak 2>nul
	exit

:end
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Твик
:: • • • • • • • • Присваивание нужных значений в переменные
:: Редакция Windows
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName') do set "ProductName=%%~b"
:: Язык
for /f "tokens=2*" %%a in ('reg query "HKEY_CURRENT_USER\Control Panel\International" /v LocaleName') do set "Lang=%%~b"
:: Релиз
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ReleaseId') do set "ReleaseId=%%~b"
:: Билд
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "Build=%%~b"
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "UBR"') do set "Build1=%%b"
set /a BuildUBR=%Build1%
:: Разрядность
if %PROCESSOR_ARCHITECTURE% == AMD64 set ARCHITECTURE=x64
if %PROCESSOR_ARCHITECTURE% == x86 set ARCHITECTURE=x32
:: Очитска экрана
cls
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Меню
echo.
echo  ===========================================
echo          Windows 10 Tweak by Michael
echo  ===========================================
echo.
echo  Hi %UserName%! Hello from Russia :)
echo.
:: Версия Windows
powershell -Nologo -command "Write-Host -NoNewline ' Your Windows: %ARCHITECTURE% | %Lang% | %ReleaseId% Build 10.0.%Build%.%BuildUBR% | %ProductName%' -ForegroundColor DarkGray"
echo.
:: Костыть для того чтобы в команде «set /p var= » после равно можно было поставить пробел перед текстом
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set BS=%%A
echo.
pause >nul | set /p var=%BS% Continue...
echo.
echo.
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Выбор пользователем его фирмы CPU
:: Если у вас Windows на русском, украинском, белoрусском, молдавском или казахском языке, то меню будет на русском, для остальных языков — на английском.
:: Присваивание переменной системного языка
for /f "tokens=2*" %%a in ('reg query "HKEY_CURRENT_USER\Control Panel\International" /v LocaleName') do set "Language=%%~b"
:: Выбор CPU
if /i "%Language%" NEQ "ru-RU" if /i "%Language%" NEQ "uk-UA" if /i "%Language%" NEQ "ru-UA" if /i "%Language%" NEQ "be-BY" if /i "%Language%" NEQ "ru-BY" if /i "%Language%" NEQ "kk-KZ" if /i "%Language%" NEQ "ru-KZ" if /i "%Language%" NEQ "ro-MD" if /i "%Language%" NEQ "ru-MD" goto OtherLang
goto CISLang

:OtherLang
		choice /C IA /N /M "%BS% Choose your processor type ( Intel - I / AMD or ARM - A ):"
		if %errorlevel% == 1 (
			set CPU=Intel
			goto end1
		) else (
			set CPU="AMD / ARM"
			goto end1
		)
		:end1
	:: Вывод результата
	echo  Processor: %CPU:"=%
goto end

:CISLang
	:: Смена кодировки на UTF-8 чтобы вместо русских букв не было кракозябр
	chcp 65001 >nul
	:: Вопрос
		choice /C IA /N /M "%BS% Укажите тип своего процессора ( Intel - I / AMD или ARM - A ):"
		if %errorlevel% == 1 (
			set CPU=Intel
			goto end1
		) else (
			set CPU="AMD / ARM"
			goto end1
		)
		:end1
	:: Вывод результата
	echo  Процессор: %CPU:"=%
	:: Возвращение системной кодировки командной строке
	for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\CodePage" /v OEMCP') do set "Encoding=%%~b"
	chcp %Encoding% >nul
goto end

:end
:: Пауза
echo.
pause >nul | set /p var=%BS% Continue...
echo.
echo.
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Получение полного доступа на ключи реестра трёх служб (DPS, WdiSystemHost, WdiServiceHost)
:: Импорт утилиты SubInACL.exe для управления разрешениями. https://www.microsoft.com/en-us/download/details.aspx?id=23510
echo F | xcopy "%~dp0subinacl.exe" %SystemRoot%\System32 /Y /C >nul
:: Получение доступа
reg query "HKEY_CURRENT_USER\Control Panel\International" /v "LocaleName" | find "ru-RU" >nul
if %errorlevel% == 1 goto En
if %errorlevel% == 0 goto Ru

goto end

:En
	:: Diagnostic Policy Service
	SubInACL /keyreg HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DPS /grant=Administrators=f 1>nul 2>&1
	:: Diagnostic Service Host
	SubInACL /keyreg HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdiServiceHost /grant=Administrators=f 1>nul 2>&1
	:: Diagnostic System Host
	SubInACL /keyreg HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdiSystemHost /grant=Administrators=f 1>nul 2>&1
goto end

:Ru
	:: Смена кодировки на UTF-8 чтобы вместо русских букв не было кракозябр
	chcp 65001 >nul
	:: Служба политики диагностики
	SubInACL /keyreg HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DPS /grant=Администраторы=f 1>nul 2>&1
	:: Узел службы диагностики
	SubInACL /keyreg HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdiServiceHost /grant=Администраторы=f 1>nul 2>&1
	:: Узел системы диагностики
	SubInACL /keyreg HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdiSystemHost /grant=Администраторы=f 1>nul 2>&1
	:: Возвращение системной кодировки командной строке
	chcp %Encoding% >nul
goto end

:end
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Возвращение CMD в контекстное меню рабочего стола, папок, дисков.
:: В контекстном меню рабочего стола
"%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal reg delete HKEY_CLASSES_ROOT\Directory\Background\shell\cmd /v HideBasedOnVelocityId /f
:: Контекстном меню папок
"%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal reg delete HKEY_CLASSES_ROOT\Directory\shell\cmd /v HideBasedOnVelocityId /f
:: Контекстном меню дисков
"%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal reg delete HKEY_CLASSES_ROOT\Drive\shell\cmd /v HideBasedOnVelocityId /f
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Если в русской версии Windows среди интернет-адаптеров есть Wi-Fi и Bluetooth, то по-умолчанию они будут называться "Беспроводная сеть" и "Сетевое подключение Bluetooth". Твик переименует их в "Wireless" и "Bluetooth". Применяеся только в русскоязычной Windows
:: Смена кодировки на UTF-8 чтобы вместо русских букв не было кракозябр
chcp 65001 >nul

:: Bluetooth
ipconfig | findstr "Сетевое подключение Bluetooth" >nul
if %errorlevel% == 0 netsh interface set interface name="Сетевое подключение Bluetooth" newname="Bluetooth"
:: Wi-Fi
netsh interface show interface | find "Беспроводная сеть" >nul
if %errorlevel% == 0 netsh interface set interface name="Беспроводная сеть" newname="Wireless"

:: Возвращение системной кодировки командной строке
chcp %Encoding% >nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Если у вас Windows 10 Home, будет восстановлен «Редактор локальных групповых политик» (gpedit.msc)
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "EditionID" | find "Core" >nul
if %errorlevel% == 1 goto end
if %errorlevel% == 0 goto Install

goto end

:Install
	dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~3*.mum > "%~dp0find-gpedit.txt"
	dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~3*.mum >> "%~dp0find-gpedit.txt"
	for /f %%i in ('findstr /i . "%~dp0find-gpedit.txt" 2^>nul') do dism /online /NoRestart /add-package:"%SystemRoot%\servicing\Packages\%%i"
	if exist "%~dp0find-gpedit.txt" del /Q "%~dp0find-gpedit.txt"
goto end

:end
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Импорт локальных групповых политик (GPO)
:: Импрот утилиты LGPO.exe для управления GPO, в папку System32. Утилита из набора средств обеспечения соответствия требованиям безопасности "Microsoft Security Compliance Toolkit 1.0" (Ссылка:https://www.microsoft.com/en-us/download/details.aspx?id=55319)
echo F | xcopy "%~dp0LGPO.exe" %SystemRoot%\System32 /Y /C >nul
:: Импорт локальных групповых политик
LGPO.exe /g "%~dp0GPO" 2>nul 1>&2
:: Обновление групповых политик
gpupdate /force
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Разрешение запуска локальных сценариев Powershell на ПК
powershell -Nologo -command "Set-ExecutionPolicy RemoteSigned -erroraction 'silentlycontinue'"
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Импорт файла "Tweak.ps1"
powershell -ExecutionPolicy ByPass -Nologo -command "& '%~dp0Tweak.ps1' -erroraction 'silentlycontinue'"
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Импорт файла "Windpws 10 Tweak.reg"
echo F | xcopy "%~dp0Blank.ico" %SystemRoot% /Y /C >nul
regedit /s "%~dp0Windows 10 Tweak.reg"
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Убиение Windows Defender и дочерних служб c помощью утилиты PowerRun.exe (https://www.sordum.org/9416/powerrun-v1-3-run-with-highest-privileges/), запускающей процессы от имени SYSTEM
:: Утилита точно не может работать в папке System32
:: Антивирусная программа "Защитника Windows"
"%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal net stop WinDefend & "%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend" /v Start /t REG_DWORD /d 4 /f
:: Драйвер загрузки Windows Defender Antivirus
"%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal net stop WdBoot & "%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdBoot" /v Start /t REG_DWORD /d 4 /f
:: Драйвер мини-фильтра Windows Defender Antivirus
"%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal net stop WdFilter & "%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdFilter" /v Start /t REG_DWORD /d 4 /f
:: Служба проверки сети Windows Defender Antivirus
"%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal net stop WdNisSvc & "%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdNisSvc" /v Start /t REG_DWORD /d 4 /f
:: Служба Advanced Threat Protection в Защитнике Windows
"%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal net stop Sense & "%~dp0PowerRun.exe" cmd.exe /q /c start /min /realtime /abovenormal reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Sense" /v Start /t REG_DWORD /d 4 /f
:: SmartScreen
tasklist | find "smartscreen.exe" >nul
if %errorlevel% == 0 taskkill /f /im smartscreen.exe 2>nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Отключение Device / Credential Guard в Windows Defender. Если не выключить эту дрянь, то например, не будут работать Виртуальные машины VMware. После перезашрузки нужно будет подтвердить отключение два раза нажав F3.
:: Oтключение функции безопасности на основе виртуализации в Windows Defender
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} loadoptions DISABLE-LSA-ISO,DISABLE-VBS
bcdedit /set hypervisorlaunchtype off
bcdedit /set vsmlaunchtype off
:: Удаление переменных EFI Credential Guard в Windows Defender с помощью bcdedit.
mountvol X: /s
copy %SystemRoot%\System32\SecConfig.efi X:\EFI\Microsoft\Boot\SecConfig.efi /Y >nul
bcdedit /create {0cb3b571-2f2e-4343-a879-d86a476d7215} /d "DebugTool" /application osloader
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} path "\EFI\Microsoft\Boot\SecConfig.efi"
bcdedit /set {bootmgr} bootsequence {0cb3b571-2f2e-4343-a879-d86a476d7215}
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} loadoptions DISABLE-LSA-ISO
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} device partition=X:
mountvol X: /d
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Создание файла «Update.vbs», который включает обновления для других продуктов Microsoft. Скрипт (https://docs.microsoft.com/ru-ru/windows/desktop/Wua_Sdk/opt-in-to-microsoft-update). Скрипт удалится после выполнения.
echo Set ServiceManager = CreateObject("Microsoft.Update.ServiceManager") > "%~dp0Update.vbs"
echo ServiceManager.ClientApplicationID = "My App" >> "%~dp0Update.vbs"
echo Set NewUpdateService = ServiceManager.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"") >> "%~dp0Update.vbs"
echo. >> "%~dp0Update.vbs"
echo 'Self Remove >> "%~dp0Update.vbs"
echo discardScript() >> "%~dp0Update.vbs"
echo Function discardScript() >> "%~dp0Update.vbs"
echo Set objFSO = CreateObject("Scripting.FileSystemObject") >> "%~dp0Update.vbs"
echo strScript = Wscript.ScriptFullName >> "%~dp0Update.vbs"
echo objFSO.DeleteFile(strScript) >> "%~dp0Update.vbs"
echo End Function >> "%~dp0Update.vbs"
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Импорт файла "Update.vbs"
cscript //B //Nologo "%~dp0Update.vbs"
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Если у вас CPU Intel, будет создана задача удаляющая папку C:\Intel c логами, при каждом входе в систему. Почему её не поместили в Temp?
if %CPU% == Intel (
	schtasks /Create /xml "%~dp0Delete_Intel_folder.xml" /tn "Delete Intel folder" /f
	goto end
) else (
	goto end
)
:end
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Адаптация пункта PHP в меню создать под другие языки
if /i "%Language%" NEQ "ru-RU" if /i "%Language%" NEQ "uk-UA" if /i "%Language%" NEQ "ru-UA" if /i "%Language%" NEQ "be-BY" if /i "%Language%" NEQ "ru-BY" if /i "%Language%" NEQ "kk-KZ" if /i "%Language%" NEQ "ru-KZ" if /i "%Language%" NEQ "ro-MD" if /i "%Language%" NEQ "ru-MD" goto OtherLang
goto CISLang

:OtherLang
reg add "HKEY_CLASSES_ROOT\PHPfile" /ve /t REG_SZ /d "PHP-document" /f
goto end

:CISLang
:: Кодировка UTF-8
chcp 65001 >nul
:: Адаптация
reg add "HKEY_CLASSES_ROOT\PHPfile" /ve /t REG_SZ /d "PHP-документ" /f
:: Возвращение системной кодировки командной строке
chcp %Encoding% >nul
goto end

:end
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Удаление папки Intel
sc query cphs 2>nul 1>&2
if %errorlevel% == 0 net stop cphs 2>nul
if exist %SystemDrive%\Intel rd /Q /S %SystemDrive%\Intel 2>nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Удаление временной папки PerfLogs
if exist %SystemDrive%\PerfLogs rd /Q /S %SystemDrive%\PerfLogs 2>nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Восстановление возможности загрузки в безопасном режиме по F8
bcdedit /set {default} bootmenupolicy legacy
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Переименование компьютера
wmic computersystem where name="%computername%" call rename name="DELLinspiron7567" >nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Удаление ненужного ярлыка Microsoft Edge с рабочего стола
if exist "%UserProfile%\Desktop\Microsoft Edge.lnk" del /Q "%UserProfile%\Desktop\Microsoft Edge.lnk" 2>nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Импорт ярлыков
echo D | xcopy "%~dp0ShortCut\System" "%ProgramData%\Microsoft\Windows\Start Menu\Programs" /E /Y /C >nul
echo D | xcopy "%~dp0ShortCut\SendTo" %UserProfile%\AppData\Roaming\Microsoft\Windows\SendTo /Y /C >nul
echo D | xcopy "%~dp0ShortCut\User" "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" /E /Y /C >nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Испорт VBS скрипта, копирующего мой ключ активации Windows в буфер и открывающего окно смены ключа продукта
echo F | xcopy "%~dp0WinActivation.vbs" %UserProfile%\Desktop\WinActivation.vbs /Y /C >nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Удаление ненужных ярлыков из меню "Отправить"
if exist "%UserProfile%\AppData\Roaming\Microsoft\Windows\SendTo\Mail Recipient.MAPIMail" del /Q "%UserProfile%\AppData\Roaming\Microsoft\Windows\SendTo\Mail Recipient.MAPIMail" 2>nul
if exist "%UserProfile%\AppData\Roaming\Microsoft\Windows\SendTo\Fax Recipient.lnk" del /Q "%UserProfile%\AppData\Roaming\Microsoft\Windows\SendTo\Fax Recipient.lnk" 2>nul
if exist %UserProfile%\AppData\Roaming\Microsoft\Windows\SendTo\Documents.mydocs del /Q %UserProfile%\AppData\Roaming\Microsoft\Windows\SendTo\Documents.mydocs 2>nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Отключение гибернации
powercfg -h off 2>nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Импорт схемы электропитания
powercfg -import "%~dp0powerplan.pow" 2>nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Отключение плановой дефрагментации
schtasks /query /tn "Microsoft\windows\defrag\ScheduledDefrag" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\windows\defrag\ScheduledDefrag" 2>nul
	schtasks /change /tn "Microsoft\windows\defrag\ScheduledDefrag" /disable 2>nul
)
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Получение прав на папку плиточных Windows говно-приложений
if exist "%ProgramFiles%\WindowsApps" takeown /f "%ProgramFiles%\WindowsApps" /a 2>nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Переименование файла, связанного с телеметрией
if exist %SystemRoot%\System32\CompatTelRunner.exe "%~dp0PowerRun.exe" cmd.exe /q /c ren %SystemRoot%\System32\CompatTelRunner.exe *.exe_fucked 2>nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Отключение задачи автоматического создания точек восстановления.
schtasks /query /tn "Microsoft\Windows\SystemRestore\SR" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\SystemRestore\SR" 2>nul
	schtasks /change /tn "Microsoft\Windows\SystemRestore\SR" /disable 2>nul
)
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Отключение телеметрии Nvidia
:: Через планировщик заданий
schtasks /query /tn "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 2>nul
	schtasks /change /tn "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /disable 2>nul
)
schtasks /query /tn "NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" 2>nul
	schtasks /change /tn "NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /disable 2>nul
)
:: Остановка и отключение службы
sc query NvTelemetryContainer 2>nul 1>&2
if %errorlevel% == 0 (
	net stop NvTelemetryContainer 2>nul
	sc config NvTelemetryContainer start=disabled 2>nul
)
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Остановка и удаления задачи обновления OneDrive в планировщике
:: Определение SID пользователя
for /F "tokens=* skip=1" %%n in ('wmic useraccount where "name='%UserName%'" get sid ^| findstr "."') do (set SID=%%n)
:: Удаление пробелов в переменной
set UserSID=%SID: =%
:: Удаление и остановка задачи
schtasks /query /tn "OneDrive Standalone Update Task-%UserSID%" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "OneDrive Standalone Update Task-%UserSID%" 2>nul
	schtasks /delete /tn "OneDrive Standalone Update Task-%UserSID%" /f 2>nul
)
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Отключение автозагрузки OneDrive
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" 2>nul 1>&2 | find "OneDrive" >nul
if %errorlevel% == 0 reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v OneDrive /t REG_BINARY /d 030000004bce3c642e1ed501 /f
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Отключение телеметрии
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\Users\%UserSID%" /v AllowTelemetry /t REG_DWORD /d 0 /f 2>nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Отключение сбора данных через планировщик заданий (Microsoft)
:: Сбор телеметрических данных программы при участии в программе улучшения качества ПО.
schtasks /query /tn "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" 2>nul
	schtasks /change /tn "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /disable 2>nul
)
:: Сбор телеметрических данных программы при участии в программе улучшения качества ПО.
schtasks /query /tn "Microsoft\Windows\Application Experience\ProgramDataUpdater" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\Application Experience\ProgramDataUpdater" 2>nul
	schtasks /change /tn "Microsoft\Windows\Application Experience\ProgramDataUpdater" /disable 2>nul
)
:: Сканирует записи запуска и выводит уведомления для пользователя при наличии большого количества записей запуска.
schtasks /query /tn "Microsoft\Windows\Application Experience\StartupAppTask" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\Application Experience\StartupAppTask" 2>nul
	schtasks /change /tn "Microsoft\Windows\Application Experience\StartupAppTask" /disable 2>nul
)
:: Эта задача собирает и загружает данные SQM при участии в программе улучшения качества программного обеспечения.
schtasks /query /tn "Microsoft\Windows\Autochk\Proxy" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\Autochk\Proxy" 2>nul
	schtasks /change /tn "Microsoft\Windows\Autochk\Proxy" /disable 2>nul
)
:: Cобирает и отправляет сведения о работе программного обеспечения в Майкрософт.
schtasks /query /tn "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" 2>nul
	schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /disable 2>nul
)
:: Осуществляет сбор дополнительных данных о системе, которые затем передаются в корпорацию Майкрософт.
schtasks /query /tn "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" 2>nul
	schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /disable 2>nul
)
:: Полученные сведения используются для повышения надежности, стабильности и общей производительности шины USB в Windows.
schtasks /query /tn "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" 2>nul
	schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /disable 2>nul
)
:: Эта задача автоматически запускается службой политики диагностики при обнаружении ошибки S.M.A.R.T.
schtasks /query /tn "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" 2>nul
	schtasks /change /tn "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /disable 2>nul
)
:: Для пользователей, участвующих в программе контроля качества программного обеспечения, служба диагностики дисков Windows предоставляет общие сведения о дисках и системе в корпорацию Майкрософт.
schtasks /query /tn "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" 2>nul
	schtasks /change /tn "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /disable 2>nul
)
:: Измеряет быстродействие и возможности системы
schtasks /query /tn "Microsoft\Windows\Maintenance\WinSAT" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\Maintenance\WinSAT" 2>nul
	schtasks /change /tn "Microsoft\Windows\Maintenance\WinSAT" /disable 2>nul
)
:: Задача отчетов об ошибках обрабатывает очередь отчетов.
schtasks /query /tn "Microsoft\Windows\Windows Error Reporting\QueueReporting" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\Windows Error Reporting\QueueReporting" 2>nul
	schtasks /change /tn "Microsoft\Windows\Windows Error Reporting\QueueReporting" /disable 2>nul
)
:: SmartScreen
schtasks /query /tn "Microsoft\Windows\AppID\SmartScreenSpecific" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\AppID\SmartScreenSpecific" 2>nul
	schtasks /change /tn "Microsoft\Windows\AppID\SmartScreenSpecific" /disable 2>nul
)
:: Задача программы улучшения качества Bluetooth собирает статистику по Bluetooth, а также сведения о вашем компьютере, и отправляет их в корпорацию Майкрософт.
schtasks /query /tn "Microsoft\Windows\Customer Experience Improvement Program\BthSQM" 2>nul 1>&2
if %errorlevel% == 0 (
	schtasks /end /tn "Microsoft\Windows\Customer Experience Improvement Program\BthSQM" 2>nul
	schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\BthSQM" /disable 2>nul
)
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Запрет кортане доступа в сеть путём добавления правила Брандмауэра
:: Включение брандмауэра
netsh advfirewall set allprofiles state on
:: Отрубание доступа
:: Кодировка UTF-8 (Чтобы в названии нормально отображался смайлик =) )
chcp 65001 >nul
:: Создание правила (если оно уже есть, правило будет перезаписано)
netsh advfirewall firewall show rule name=all | find "Windows 10 Tweak — Cortana 🔎" >nul
if %errorlevel% == 1 goto Add
if %errorlevel% == 0 goto Rewrite

goto end

:Add
	:: Добавление правила
	netsh advfirewall firewall add rule name="Windows 10 Tweak — Cortana 🔎" dir=out action=block program="%SystemRoot%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\SearchUI.exe" interfacetype=ANY profile=ANY protocol=ANY enable=yes description="Ban of Internet access for Cortana"
	:: Возвращение системной кодировки командной строке
	chcp %Encoding% >nul
goto end

:Rewrite
	:: Удаление правила
	netsh advfirewall firewall delete rule name="Windows 10 Tweak — Cortana 🔎"
	:: Добавление правила
	netsh advfirewall firewall add rule name="Windows 10 Tweak — Cortana 🔎" dir=out action=block program="%SystemRoot%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\SearchUI.exe" interfacetype=ANY profile=ANY protocol=ANY enable=yes description="Ban of Internet access for Cortana"
	:: Возвращение системной кодировки командной строке
	chcp %Encoding% >nul
goto end

:end
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Удаление шпионских модулей и уже собранных данных
:: DiagTrack
sc query DiagTrack 2>nul 1>&2
if %errorlevel% == 0 (
	net stop DiagTrack 2>nul 1>&2
	sc delete DiagTrack 2>nul 1>&2
)
:: dmwappushservice
sc query dmwappushservice 2>nul 1>&2
if %errorlevel% == 0 (
	net stop dmwappushservice 2>nul 1>&2
	sc delete dmwappushservice 2>nul 1>&2
)
:: Удаление уже собранных данных
if exist %ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl echo "" > %ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl 2>nul 1>&2
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Отключение шпионских и небезопасных служб
:: Служба публикации сбора данных
sc query DcpSvc 2>nul 1>&2
if %errorlevel% == 0 (
	net stop DcpSvc 2>nul
	sc config DcpSvc start=disabled 2>nul
)
:: Служба политики диагностики
sc query DPS 2>nul 1>&2
if %errorlevel% == 0 (
	net stop DPS 2>nul
	sc config DPS start=disabled 2>nul
)
:: Узел системы диагностики
sc query WdiSystemHost 2>nul 1>&2
if %errorlevel% == 0 (
	net stop WdiSystemHost 2>nul
	sc config WdiSystemHost start=disabled 2>nul
)
:: Узел службы диагностики
sc query WdiServiceHost 2>nul 1>&2
if %errorlevel% == 0 (
	net stop WdiServiceHost 2>nul
	sc config WdiServiceHost start=disabled 2>nul
)
:: Отключение сбора и обработки данных Журнала Cобытий Windows
sc query diagnosticshub.standardcollector.service 2>nul 1>&2
if %errorlevel% == 0 (
	net stop diagnosticshub.standardcollector.service 2>nul
	sc config diagnosticshub.standardcollector.service start=disabled 2>nul
)
:: Служба регистрации ошибок Windows
sc query WerSvc 2>nul 1>&2
if %errorlevel% == 0 (
	net stop WerSvc 2>nul
	sc config WerSvc start=disabled 2>nul
)
:: Служба помошника по совместимости программ
sc query PcaSvc 2>nul 1>&2
if %errorlevel% == 0 (
	net stop PcaSvc 2>nul
	sc config PcaSvc start=disabled 2>nul
)
:: Служба общих сетевых ресурсов проигрывателя Windows Media (эта служба исчезнет после отключения Windows Media Player)
sc query WMPNetworkSvc 2>nul 1>&2
if %errorlevel% == 0 (
	net stop WMPNetworkSvc 2>nul
	sc config WMPNetworkSvc start=disabled 2>nul
)
:: Служба пользователя платформы подключенных устройств
sc query CDPUserSvc 2>nul 1>&2
if %errorlevel% == 0 (
	net stop CDPUserSvc 2>nul
	sc config CDPUserSvc start=disabled 2>nul
)
:: Удалённый реестр
sc query RemoteRegistry 2>nul 1>&2
if %errorlevel% == 0 (
	net stop RemoteRegistry 2>nul
	sc config RemoteRegistry start=disabled 2>nul
)
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Отключение повторного открытия программ после перезагрузки (Параметры\Учётные записи\Варианты входа)
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\%UserSID%" /v OptOut /t REG_DWORD /d 1 /f
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Исправление залипания NumLock
reg add "HKEY_USERS\%UserSID%\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2 /f
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Настройка файла подкачки
:: Отключение пункта "Автоматически выбирать объём файла подкачки"
wmic computersystem set AutomaticManagedPagefile=False >nul
:: Отключение пункта "Автоматически выбирать объём файла подкачки"
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False >nul
:: Установление размера файла подкачки 4Gb
wmic pagefileset where name="%SystemDrive%\\pagefile.sys" set InitialSize=4096,MaximumSize=4096 >nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Включение компонентов Windows
:: DirectPlay (Для поддержки старых игор. Например S.T.A.L.K.E.R.)
echo.
echo.
powershell -Nologo -command "Write-Host -NoNewline 'DirectPlay' -ForegroundColor DarkGray"
dism -online -enable-feature:DirectPlay -All -NoRestart 2>nul
:: .NET Framework 3.5 (Нужен для работы программ)
echo.
echo.
powershell -Nologo -command "Write-Host -NoNewline '.NET Framework 3.5' -ForegroundColor DarkGray"
dism -online -enable-feature:NetFx3 -NoRestart 2>nul
:: Windows SandBox
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "EditionID" | find "Core" >nul
if %errorlevel% NEQ 0 (
	echo.
	echo.
	powershell -Nologo -command "Write-Host -NoNewline 'Windows SandBox' -ForegroundColor DarkGray"
	dism -online -enable-feature:Containers-DisposableClientVM -All -NoRestart 2>nul
)
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Отключение ненужных компонентов Windows
:: Internet Explorer 11
echo.
echo.
powershell -Nologo -command "Write-Host -NoNewline 'Internet Explorer 11' -ForegroundColor DarkGray"
dism -online -disable-feature:Internet-Explorer-Optional-amd64 -NoRestart 2>nul
::"Компоненты для работы с мультимедиа". Отключает бесполезный "Windows Media Player"
echo.
echo.
powershell -Nologo -command "Write-Host -NoNewline 'Windows Media Player' -ForegroundColor DarkGray"
dism -online -disable-feature:MediaPlayback -NoRestart 2>nul
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Импорт на рабочий стол списка параметров, которые надо выключить вручную
reg query "HKEY_CURRENT_USER\Control Panel\International" /v "LocaleName" | find "ru-RU" >nul
if %errorlevel% == 1 goto OtherLang
if %errorlevel% == 0 goto Ru

goto end

:OtherLang
	echo F | xcopy "%~dp0Settings.txt" "%UserProfile%\Desktop\Manual setting.txt" /Y /C >nul
goto end

:Ru
	:: Смена кодировки на UTF-8 чтобы вместо русских букв не было кракозябр
	chcp 65001 >nul
	:: Копирование
	echo F | xcopy "%~dp0Settings.txt" "%UserProfile%\Desktop\Ручная настройка.txt" /Y /C >nul
	:: Возвращение системной кодировки командной строке
	chcp %Encoding% >nul
goto end

:end
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Перезагрузка проводника и очитска кэша иконок
cscript //B //Nologo "%~dp0Refresh.vbs"
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • VBS cообщение:"Часть изменений вступит в силу только после перезагрузки." или "Part of the changes will take effect only after a reboot."
powershell echo `a
cscript //Nologo "%~dp0done.vbs"
:: • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • Удаление импортированных файлов и подчистка за собой
if exist %SystemRoot%\Windows_10_Tweak rd /Q /S %SystemRoot%\Windows_10_Tweak 2>nul