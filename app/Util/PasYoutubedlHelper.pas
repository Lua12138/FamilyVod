unit PasYoutubedlHelper;

interface

uses Winapi.Windows, System.SysUtils, System.Classes;

type
  TYoutubeDlHelper = class
  protected
    class function RunDosCommand(Command: string): string;
    class var youtubedl: string;

  const
    COMMAND_PLAYLIST_COUNT = '%s --get-id "%s"';
    COMMAND_PLAYLIST_JSON = '%s -j "%s"';
    COMMAND_PLAYLIST_JSON_INDEX =
      '%s --playlist-start %d --playlist-end %d -j "%s"';
  public
    class function GetPlaylistCount(url: string): Integer; // 获得播放列表的分段视频数
    // 获得播放列表指定序号视频json
    class function GetVideoInfo(url: string; index: Integer): string; overload;
    class function GetVideoInfo(url: string): string; overload;
  end;

implementation

uses PasGlobalConfiguration, CnDebug;

class function TYoutubeDlHelper.GetPlaylistCount(url: string): Integer;
var
  Command: string;
  commandResult: string;
  chr: Char;
begin
  Command := Format(COMMAND_PLAYLIST_COUNT, [youtubedl, url]);
  commandResult := RunDosCommand(Command);
  if Pos('ERROR', commandResult) > 0 then
  begin
    CnDebugger.TraceMsgWithTag(commandResult, Self.ClassName);
    Result := -1;
    Exit;
  end;
  Result := 0;
  for chr in commandResult do
    if chr = #13 then
      Inc(Result);
end;

class function TYoutubeDlHelper.GetVideoInfo(url: string;
  index: Integer): string;
var
  Command: string;
begin
  Command := Format(COMMAND_PLAYLIST_JSON_INDEX,
    [youtubedl, index, index, url]);

  Result := RunDosCommand(Command);
end;

class function TYoutubeDlHelper.GetVideoInfo(url: string): string;
var
  Command: string;
begin
  Command := Format(COMMAND_PLAYLIST_JSON, [youtubedl, url]);
  Result := RunDosCommand(Command);
end;

class function TYoutubeDlHelper.RunDosCommand(Command: string): string;
const
  ArrayMaxLength = 4096;
var
  hReadPipe: THandle;
  hWritePipe: THandle;
  SI: TStartupInfo;
  PI: TProcessInformation;
  sa: TSecurityAttributes;
  // SD   :   TSecurityDescriptor;
  BytesRead: DWORD;
  Dest: array [0 .. ArrayMaxLength] of AnsiChar;
  CmdLine: array [0 .. 512] of Char;
  Avail, ExitCode, wrResult: DWORD;
  osVer: TOSVERSIONINFO;
  tmpstr: AnsiString;
begin
  Result := '';
  osVer.dwOSVersionInfoSize := sizeof(TOSVERSIONINFO);
  GetVersionEX(osVer);

  if osVer.dwPlatformId = VER_PLATFORM_WIN32_NT then
  begin
    sa.nLength := sizeof(sa);
    sa.lpSecurityDescriptor := nil; // @SD;
    sa.bInheritHandle := True;
    CreatePipe(hReadPipe, hWritePipe, @sa, 0);
  end
  else
    CreatePipe(hReadPipe, hWritePipe, nil, 1024);
  try
    FillChar(SI, sizeof(SI), 0);
    SI.cb := sizeof(TStartupInfo);
    SI.wShowWindow := SW_HIDE;
    SI.dwFlags := STARTF_USESHOWWINDOW;
    SI.dwFlags := SI.dwFlags or STARTF_USESTDHANDLES;
    SI.hStdOutput := hWritePipe;
    SI.hStdError := hWritePipe;
    StrPCopy(CmdLine, Command);
    if CreateProcess(nil, CmdLine, nil, nil, True, NORMAL_PRIORITY_CLASS, nil,
      nil, SI, PI) then
    begin
      ExitCode := 0;
      while ExitCode = 0 do
      begin
        wrResult := WaitForSingleObject(PI.hProcess, 500);

        if PeekNamedPipe(hReadPipe, @Dest[0], ArrayMaxLength, @Avail, nil, nil)
        then
        begin
          if Avail > 0 then
          begin
            try
              FillChar(Dest, sizeof(Dest), 0);
              ReadFile(hReadPipe, Dest[0], Avail, BytesRead, nil);
              tmpstr := Copy(Dest, 0, BytesRead - 1);
              Result := Result + tmpstr;
            finally
            end;
          end;
        end;
        if wrResult <> WAIT_TIMEOUT then
          ExitCode := 1;
      end;
      GetExitCodeProcess(PI.hProcess, ExitCode);
      CloseHandle(PI.hProcess);
      CloseHandle(PI.hThread);
    end;
  finally
    CloseHandle(hReadPipe);
    CloseHandle(hWritePipe);
  end;
end;

initialization

TYoutubeDlHelper.youtubedl := TGlobalConfiguration.getInstance.youtubedlRoot;

end.
