; NSIS-Installer fuer Kst (64 bit)
; Aufruf: makensis /DVERSION=2.1 /DSRCDIR=C:\pfad\Kst-2.1 /DOUTFILE=Kst-2.1-win64-setup.exe [/DEXE=kst.exe /DAPPID=Kst3] kst-installer.nsi

Unicode true
!include "MUI2.nsh"
!include "x64.nsh"

!ifndef VERSION
  !define VERSION "2.1"
!endif
!ifndef SRCDIR
  !error "SRCDIR muss gesetzt sein"
!endif
!ifndef EXE
  !define EXE "kst2.exe"
!endif
!ifndef APPID
  !define APPID "Kst2"
!endif
!ifndef OUTFILE
  !define OUTFILE "Kst-${VERSION}-win64-setup.exe"
!endif

!define APPNAME "Kst"
!define UNINSTKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}"

Name "${APPNAME} ${VERSION}"
OutFile "${OUTFILE}"
InstallDir "$PROGRAMFILES64\Kst ${VERSION}"
InstallDirRegKey HKLM "Software\${APPID}" "InstallDir"
RequestExecutionLevel admin
SetCompressor /SOLID lzma

!define MUI_ICON "${SRCDIR}\kst.ico"
!define MUI_UNICON "${SRCDIR}\kst.ico"
!define MUI_FINISHPAGE_RUN "$INSTDIR\bin\${EXE}"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${SRCDIR}\COPYING.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "English"

Function .onInit
  ${IfNot} ${RunningX64}
    MessageBox MB_ICONSTOP "Kst ${VERSION} benoetigt 64-bit Windows."
    Abort
  ${EndIf}
  SetRegView 64
FunctionEnd

Section "Kst" SecMain
  SectionIn RO
  SetOutPath "$INSTDIR"
  File /r "${SRCDIR}\*.*"

  WriteRegStr HKLM "Software\${APPID}" "InstallDir" "$INSTDIR"
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  CreateDirectory "$SMPROGRAMS\Kst ${VERSION}"
  CreateShortCut "$SMPROGRAMS\Kst ${VERSION}\Kst.lnk" "$INSTDIR\bin\${EXE}" "" "$INSTDIR\kst.ico"
  CreateShortCut "$SMPROGRAMS\Kst ${VERSION}\Kst deinstallieren.lnk" "$INSTDIR\Uninstall.exe"

  WriteRegStr   HKLM "${UNINSTKEY}" "DisplayName"     "Kst ${VERSION}"
  WriteRegStr   HKLM "${UNINSTKEY}" "DisplayVersion"  "${VERSION}"
  WriteRegStr   HKLM "${UNINSTKEY}" "Publisher"       "The Kst Team"
  WriteRegStr   HKLM "${UNINSTKEY}" "DisplayIcon"     "$INSTDIR\kst.ico"
  WriteRegStr   HKLM "${UNINSTKEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegDWORD HKLM "${UNINSTKEY}" "NoModify" 1
  WriteRegDWORD HKLM "${UNINSTKEY}" "NoRepair" 1
SectionEnd

Section "Desktop-Verknuepfung" SecDesktop
  CreateShortCut "$DESKTOP\Kst.lnk" "$INSTDIR\bin\${EXE}" "" "$INSTDIR\kst.ico"
SectionEnd

Section "Dateizuordnung .kst" SecAssoc
  WriteRegStr HKCR ".kst" "" "${APPID}.Session"
  WriteRegStr HKCR "${APPID}.Session" "" "Kst Session"
  WriteRegStr HKCR "${APPID}.Session\DefaultIcon" "" "$INSTDIR\kst.ico"
  WriteRegStr HKCR "${APPID}.Session\shell\open\command" "" '"$INSTDIR\bin\${EXE}" "%1"'
SectionEnd

Function un.onInit
  SetRegView 64
FunctionEnd

Section "Uninstall"
  Delete "$DESKTOP\Kst.lnk"
  RMDir /r "$SMPROGRAMS\Kst ${VERSION}"
  ReadRegStr $0 HKCR ".kst" ""
  StrCmp $0 "${APPID}.Session" 0 +3
    DeleteRegKey HKCR ".kst"
    DeleteRegKey HKCR "${APPID}.Session"
  DeleteRegKey HKLM "${UNINSTKEY}"
  DeleteRegKey HKLM "Software\${APPID}"
  RMDir /r "$INSTDIR"
SectionEnd

