Option Explicit
Dim shell, fso, root, launcher, cmd
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
root = fso.GetParentFolderName(WScript.ScriptFullName)
launcher = fso.BuildPath(fso.BuildPath(root, "launcher"), "CrawlBrawlLauncher.ps1")
If Not fso.FileExists(launcher) Then
    MsgBox "Crawl Brawl launcher is incomplete." & vbCrLf & launcher, 16, "Crawl Brawl Launcher"
    WScript.Quit 1
End If
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & launcher & """"
shell.Run cmd, 0, False
