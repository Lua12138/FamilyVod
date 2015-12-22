unit PasPlayActionProcessor;

interface

uses
  PasRequestProcessor, IdCustomHTTPServer, System.SysUtils, System.Classes;

type
  TPlayActionProcessor = class(TRequestProcessor)
  protected
    function innerRequested(requestUri: string; requestAction: string): Boolean; override;
    function onGet(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean; override;
  end;

implementation

uses
  CnDebug, PasMessagerHelper, PasGlobalConfiguration, Winapi.Windows, EncdDecd;

function TPlayActionProcessor.innerRequested(requestUri: string; requestAction: string): Boolean;
begin
  Result := 'play'.Equals(requestaction)
end;

function TPlayActionProcessor.onGet(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;

  function RunDosCommand(Command: string): string;
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
    Dest: array[0..ArrayMaxLength] of AnsiChar;
    CmdLine: array[0..512] of Char;
    Avail, ExitCode, wrResult: DWORD;
    osVer: TOSVERSIONINFO;
    tmpstr: AnsiString;
  begin
    Result := '';
    osVer.dwOSVersionInfoSize := sizeof(TOSVERSIONINFO);
    GetVersionEX(osVer);

    if osVer.dwPlatformId = VER_PLATFORM_WIN32_NT then
    begin
    // InitializeSecurityDescriptor(@SD,   SECURITY_DESCRIPTOR_REVISION);
    // SetSecurityDescriptorDacl(@SD,   True,   nil,   False);
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
      if CreateProcess(nil, CmdLine, nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, SI, PI) then
      begin
        ExitCode := 0;
        while ExitCode = 0 do
        begin
          wrResult := WaitForSingleObject(PI.hProcess, 500);
        // if   PeekNamedPipe(hReadPipe,   nil,   0,   nil,   @Avail,   nil)   then
          if PeekNamedPipe(hReadPipe, @Dest[0], ArrayMaxLength, @Avail, nil, nil) then
          begin
            if Avail > 0 then
            begin
              try
                FillChar(Dest, sizeof(Dest), 0);
                ReadFile(hReadPipe, Dest[0], Avail, BytesRead, nil);
                tmpstr := Copy(Dest, 0, BytesRead - 1);
                ;
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

  function SplitString(pString: PChar; psubString: PChar): TStringList;
  var
    nSize, SubStringSize: DWORD;
    intI, intJ, intK: DWORD;
    ts: TStringList;
    curChar: Char;
    strString: string;
    strsearchSubStr: string;
  begin
    nSize := strLen(pString);
    SubStringSize := strLen(psubString);
    ts := TStringList.Create;
    strString := '';
    intI := 0;
    while intI <= (nSize - 1) do
    begin
      if (nSize - intI) >= SubStringSize then
      begin
        if ((pString + intI)^ = psubString^) then
        begin
          intK := intI;
          strsearchSubStr := '';
          curChar := (pString + intK)^;
          strsearchSubStr := strsearchSubStr + curChar;
          intK := intK + 1;
          for intJ := 1 to SubStringSize - 1 do
          begin
            if ((pString + intK)^ = (psubString + intJ)^) then
            begin
              curChar := (pString + intK)^;
              intK := intK + 1;
              strsearchSubStr := strsearchSubStr + curChar;
            end
            else
            begin
              intI := intK;
              strString := strString + strsearchSubStr;
              break; // ��ƥ�� �˳�FOR
            end;
          end;
          if (intJ = SubStringSize) or (SubStringSize = 1) then
          begin
            intI := intK;
            ts.Add(strString);
            strString := '';
          end;
        end
        else
        begin
          curChar := (pString + intI)^;
          strString := strString + curChar;
          intI := intI + 1;
        end;
        if intI = nSize then
        begin
          ts.Add(strString);
          strString := '';
        end;
      end
      else
      begin // ��ʣ�µ��ַ�����Ϊһ���ַ������Ƹ��ַ�������
        strString := strString + string(pString + intI);
        ts.Add(strString);
        intI := nSize;
      end;
    end;
    Result := ts;
  end;

var
  url: string;
  execYoutubedl: string;
  youtubedlResponse: string;
  spliter: tstringlist;
  localPlayUrl: string;
  i: Integer;
  httpResponse: string;
begin
  url := requestInfo.Params.Values['url'];
  if EmptyStr.Equals(url) then
  begin
    // �ָ�����,����ָ�������У�ֱ��ִ��
    CnDebugger.TraceMsg('Resume Play');
    TMessagerHelper.sendMessage(FM_PLAY, 0);
    TMessagerHelper.postMessage(FM_FULL_SCREEN, 0);
    httpResponse := '��������...';
  end
  else
  begin
    // �����ڲ���״̬ ������ʾ
    if TMessagerHelper.sendMessage(FM_PALY_STATUS, 0) <> PS_PLAYING then
    begin
      TMessagerHelper.sendMessage(FM_SPEAK, '���ڲ�ѯ���ŵ�ַ�����Ժ�');
    end;

    // youtube-dl ������
    execYoutubedl := Format('%s -j "%s"', [tglobalconfiguration.getInstance.youtubedlRoot, url]);

    CnDebugger.TraceMsg('exec:' + execYoutubedl);
      // ��ʱ���ܽϳ�
    youtubedlResponse := RunDosCommand(execYoutubedl);

    CnDebugger.TraceMsg('Youtube-dl Response:' + youtubedlResponse);

    spliter := SplitString(PChar(youtubedlResponse), #10);
      // �ж��Ƿ�ִ��ʧ��
    try
      for i := 0 to spliter.Count - 1 do
      begin
        if spliter.Strings[i].Chars[0] <> '{' then // �����жϴ�����Ӧ�ı��
          CnDebugger.TraceMsg('[TestTag] Response Error');
        if Pos('ERROR', spliter.Strings[i]) = 0 then // û�д���
        begin
          CnDebugger.TraceMsg(Format('Response %d of %d : %s', [i, spliter.Count, spliter.Strings[i]]));
          localPlayUrl := '?action=vlc&base64=' + EncdDecd.EncodeString(spliter.Strings[i]).Replace(#10, '').Replace(#13, '');
          CnDebugger.TraceMsg('add item:' + localPlayUrl);
          TMessagerHelper.postMessage(FM_FULL_SCREEN, 0);
          TMessagerHelper.sendMessage(FM_PLAY, localPlayUrl);
          httpResponse := '�Ѽ��벥���б�';
        end
        else
        begin
          CnDebugger.TraceMsg(youtubedlResponse);
          httpResponse := 'L229:�㲥ʧ��';
          // �ǲ���״̬��ʾ
          if TMessagerHelper.sendMessage(FM_PALY_STATUS, 0) <> PS_PLAYING then
            TMessagerHelper.sendMessage(FM_SPEAK, '�㲥ʧ�ܣ����ٴγ��ԣ������ǲ�֧�ָ���Ƶ');
          Break;
        end;
          // player.Play(responseContent);
      end;
    except
      on E: Exception do
      begin
        CnDebugger.TraceMsgError('Url Err:' + E.Message);
        httpResponse := '�㲥ʱ��������';
      end
    end;
    spliter.Free;
  end;
  if TMessagerHelper.sendMessage(FM_PALY_STATUS, 0) <> PS_PLAYING then
  begin
    TMessagerHelper.sendMessage(FM_PLAY, 0);
    TMessagerHelper.postMessage(FM_FULL_SCREEN, 0);
  end;

  responseInfo.ContentText := httpResponse;
  responseInfo.ContentType := 'plain/text';
  responseInfo.CharSet := 'utf-8';
  Result := True;
end;

end.

