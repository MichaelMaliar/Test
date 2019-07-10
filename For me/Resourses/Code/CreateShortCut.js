// 
// The script was written by Maliar Michael. Скрипт написал Маляр Михаил. GitHub: https://github.com/MichaelMaliar/Windows-10-Tweak.git
// 

// Скрипт создаёт ярлыки. The script creates shortcuts.

var WshShell = WScript.CreateObject("WScript.Shell"); // Формируем ссылку на объект
var fso = new ActiveXObject("Scripting.FileSystemObject"); // Cоздаем ссылку на экземпляр объекта FileSystemObject
var UserProfile = WshShell.ExpandEnvironmentStrings("%UserProfile%"); // <- указание сценарию переменной среды %UserProfile%, которую Microsoft ® WBSH по умолчанию не понимает.
try { fso.DeleteFile(UserProfile + "\\Desktop\\Refresh.lnk", true); } catch (e) {}; // Перед создание ярлыка удалям его, потому что если он уже есть, он не перезапишется. Если у него есть
// свойства которые мы не указываем (например быстрый вызов), они так и останутся. Вывод ошибок отключён.

// Ярлык
var oShellLink = WshShell.CreateShortcut(UserProfile + "\\Desktop\\Refresh.lnk"); // <- Место расположения и название ярлыка
// Параметры ярлыка
oShellLink.TargetPath = "%SystemRoot%\\System32\\wscript.exe"; // <- Здесь сам объект
oShellLink.Arguments = "//B //Nologo %SystemRoot%\\Refresh.vbs"; // <- Здесь аргументы запуска
oShellLink.WindowStyle = 1; // <- Размер окна
oShellLink.Description = "Restart Explorer"; // <- Комментарий
oShellLink.IconLocation = WshShell.ExpandEnvironmentStrings("%SystemRoot%\\Refresh.ico"); // <- Иконка
oShellLink.WorkingDirectory = fso.GetParentFolderName(oShellLink.TargetPath); // <- Рабочая папка
// oShellLink.HotKey = ("CTRL+SHIFT+E"); // <- Клавиши быстрого вызова
oShellLink.Save();