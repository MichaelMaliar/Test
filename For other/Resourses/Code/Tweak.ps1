#
# The script was written by Maliar Michael. Скрипт написал Маляр Михаил. GitHub: https://github.com/MichaelMaliar/Windows-10-Tweak.git
#

# Подавление вывода информации в Windows PowerShell
Get-Process | Out-Null
# Подвление информации об ошибках так как не все удаляемые ниже программы, бывают установлены. Из-за этого окно терминала всё красное
$ErrorActionPreference = 'silentlycontinue'
# ============== Удаление стандартных плиточных Windows говно-приложений
# Почта и календарь
Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage
# Камера
Get-AppxPackage *WindowsCamera* | Remove-AppxPackage
# 3D Builder
Get-AppxPackage *3dbuilder* | Remove-AppxPackage
# Будильник
Get-AppxPackage *WindowsAlarms* | Remove-AppxPackage
# Центр отзывов
Get-AppxPackage *WindowsFeedbackHub* | Remove-AppxPackage
# Карты
Get-AppxPackage *WindowsMaps* | Remove-AppxPackage
# Сообщения
Get-AppxPackage *Messaging* | Remove-AppxPackage
# Микрофон
Get-AppxPackage *soundrecorder* | Remove-AppxPackage
# Средство 3D-просмотра
Get-AppxPackage *Microsoft3DViewer* | Remove-AppxPackage
# Xbox
Get-AppxPackage *XboxApp* | Remove-AppxPackage
Get-AppxPackage *XboxSpeechToTextOverlay* | Remove-AppxPackage
Get-AppxPackage *Microsoft.Xbox.TCUI* | Remove-AppxPackage
Get-AppxPackage *Microsoft.XboxGameOverlay* | Remove-AppxPackage
# Sticky Notes
Get-AppxPackage *MicrosoftStickyNotes* | Remove-AppxPackage
# Paint 3D
Get-AppxPackage *MSPaint* | Remove-AppxPackage
# Office
Get-AppxPackage *Microsoft.MicrosoftOfficeHub* | Remove-AppxPackage
Get-AppxPackage *Office.Sway* | Remove-AppxPackage
# Skype
Get-AppxPackage *Microsoft.SkypeApp* | Remove-AppxPackage
# Музыка Groove
Get-AppxPackage *ZuneMusic* | Remove-AppxPackage
# Кино и ТВ
Get-AppxPackage *ZuneVideo* | Remove-AppxPackage
# Фотографии
Get-AppxPackage *Photos* | Remove-AppxPackage
# Что-то связано с Microsoft Azure
Get-AppxPackage *Appconnector* | Remove-AppxPackage
# Советы
Get-AppxPackage *Getstarted* | Remove-AppxPackage
# Портал смешанной реальности
Get-AppxPackage *Microsoft.MixedReality.Portal* | Remove-AppxPackage
# Ваш телефон
Get-AppxPackage *Microsoft.YourPhone* | Remove-AppxPackage
# Microsoft Solitaire Collection
Get-AppxPackage *MicrosoftSolitaireCollection* | Remove-AppxPackage
# Техническая поддержка
Get-AppxPackage *Microsoft.GetHelp* | Remove-AppxPackage
# Microsoft Pay
Get-AppxPackage *Microsoft.Wallet* | Remove-AppxPackage
# Все программы Bing (News, Weather,)
Get-AppxPackage *bing* | Remove-AppxPackage
# OneNote
Get-AppxPackage *OneNote* | Remove-AppxPackage
# Тарифные планы
Get-AppxPackage *OneConnect* | Remove-AppxPackage
# Print 3D
Get-AppxPackage *Print3D* | Remove-AppxPackage
# Microsoft Wi-Fi
Get-AppxPackage *ConnectivityStore* | Remove-AppxPackage
# Средство просмотра смешанной реальности
Get-AppxPackage *Microsoft3DViewer* | Remove-AppxPackage
# Люди
Get-AppxPackage *People* | Remove-AppxPackage
# Стороннее говно
Get-AppxPackage *king.com.BubbleWitch3Saga* | Remove-AppxPackage
Get-AppxPackage *Asphalt8Airborne* | Remove-AppxPackage
Get-AppxPackage *CandyCrushSodaSaga* | Remove-AppxPackage
Get-AppxPackage *DrawboardPDF* | Remove-AppxPackage
Get-AppxPackage *Facebook* | Remove-AppxPackage
Get-AppxPackage *FarmVille2CountryEscape* | Remove-AppxPackage
Get-AppxPackage *Netflix* | Remove-AppxPackage
Get-AppxPackage *Twitter* | Remove-AppxPackage
Get-AppxPackage *CandyCrushSaga* | Remove-AppxPackage
Get-AppxPackage *fitbitcoach* | Remove-AppxPackage
Get-AppxPackage *CandyCrushFriends* | Remove-AppxPackage
Get-AppxPackage *DolbyAccess* | Remove-AppxPackage
Get-AppxPackage *Yandex.Music* | Remove-AppxPackage
Get-AppxPackage *PolarrPhotoEditorAcademicEdition* | Remove-AppxPackage

# ============== Переименование локальных дисков
# Диск C (Новое имя диска — "OS")
Set-Volume -DriveLetter C -NewFileSystemLabel OS -erroraction 'silentlycontinue'
# Диск D (Новое имя диска — "Local")
Set-Volume -DriveLetter D -NewFileSystemLabel Local -erroraction 'silentlycontinue'
# Диск E (Новое имя диска — "Virtual")
Set-Volume -DriveLetter E -NewFileSystemLabel Virtual -erroraction 'silentlycontinue'

# ============== Отключение и удаления всех точек восстановления
# # Удаление
# cmd.exe /c vssadmin delete shadows /all /quiet>nul
# Отключение, но не удаление (предыдущие точки останутся, но новые автоматически создаваться не будут.)
Disable-ComputerRestore -Drive C:\ -confirm:$false

# ============== Отключение «Сохранить мой журнал активности на этом устройстве» и «Отправить мой журнал активности в Microsoft» в Параметры\Конфиденциальность\Журнал действий
# $env:USERPROFILE = %UserProfile%, потому что Powershell не понимает %UserProfile%
(Get-Content "$env:USERPROFILE\AppData\Local\ConnectedDevicesPlatform\CDPGlobalSettings.cdp") | ForEach-Object { $_ -replace '"PublishUserActivity" : 0,', '"PublishUserActivity" : 1,' } | Set-Content "$env:USERPROFILE\AppData\Local\ConnectedDevicesPlatform\CDPGlobalSettings.cdp"
(Get-Content "$env:USERPROFILE\AppData\Local\ConnectedDevicesPlatform\CDPGlobalSettings.cdp") | ForEach-Object { $_ -replace '"UploadUserActivity" : 0', '"UploadUserActivity" : 1' } | Set-Content "$env:USERPROFILE\AppData\Local\ConnectedDevicesPlatform\CDPGlobalSettings.cdp"

# ============== Отключение "Показывать недавно добавленные приложения" в меню Пуск (Параметры\Персонализация\Пуск)
# Назначение переменной, содержащей в себе путь к директории, в которой находится скрипт
$ScriptPath = Split-Path -Parent $PSCommandPath
# Экспорт нужной ветки реестра в папку cо скриптом
cmd.exe /c reg export HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount $ScriptPath\RecentApps.txt /y
# Поиск в файле отрывка нужной строки, но будет получена вся строка с уникальным CLSID
Select-String "windows.data.unifiedtile.startglobalproperties" $ScriptPath\RecentApps.txt | Select-Object -ExpandProperty line | Out-File $ScriptPath\CLSIDstring.txt
# Удаление больше ненужного файла RecentApps.txt
Remove-Item $ScriptPath\RecentApps.txt -Force
# Создание файла реестра DisableRecentApps.reg
# Очистка содержимого DisableRecentApps.reg чтобы внутри не было каши, на тот случай, если скрипт был заверщён раньше времени и вновь запущен. Информация об ошибках игнорируется.
Clear-content $ScriptPath\DisableRecentApps.reg -Force -erroraction 'silentlycontinue'
Add-Content -Path $ScriptPath\DisableRecentApps.reg -Value 'Windows Registry Editor Version 5.00' -Force
Add-Content -Path $ScriptPath\DisableRecentApps.reg -Value '' -Force
Add-Content -Path $ScriptPath\DisableRecentApps.reg -Value '' -Force
Add-Content -Path $ScriptPath\DisableRecentApps.reg -Value '"Data"=hex:02,00,00,00,94,1c,28,0f,63,f5,d4,01,00,00,00,00,43,42,01,00,c2,14,\' -Force
Add-Content -Path $ScriptPath\DisableRecentApps.reg -Value '  01,cb,32,0a,03,05,ce,ab,d3,e9,02,24,da,f4,03,44,c3,8a,01,66,82,e5,8b,b1,ae,\' -Force
Add-Content -Path $ScriptPath\DisableRecentApps.reg -Value '  fd,fd,bb,3c,00,05,a0,8f,fc,c1,03,24,8a,d0,03,44,80,99,01,66,b0,b5,99,dc,cd,\' -Force
Add-Content -Path $ScriptPath\DisableRecentApps.reg -Value '  b0,97,de,4d,00,05,86,91,cc,93,05,24,aa,a3,01,44,c3,84,01,66,9f,f7,9d,b1,87,\' -Force
Add-Content -Path $ScriptPath\DisableRecentApps.reg -Value '  cb,d1,ac,d4,01,00,c2,3c,01,c5,5a,01,00' -Force
# Cтрока 2 с уникальным CLSID из файла CLSIDstring.txt будет копирована на место третьей строки файла DisableRecentApps.reg (в PowerShell — номер нужной строки -1)
$a = Get-Content $ScriptPath\CLSIDstring.txt
$b = Get-Content $ScriptPath\DisableRecentApps.reg

$b[2] = $a[1]

$b | Set-Content $ScriptPath\DisableRecentApps.reg
# Удаление ненужного файла CLSIDstring.txt
Remove-Item $ScriptPath\CLSIDstring.txt -Force
# Импорт файла DisableRecentApps.reg
cmd.exe /c REGEDIT /S $ScriptPath\DisableRecentApps.reg
# Удаление DisableRecentApps.reg
Remove-Item $ScriptPath\DisableRecentApps.reg -Force