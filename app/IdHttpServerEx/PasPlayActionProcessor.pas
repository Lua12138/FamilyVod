unit PasPlayActionProcessor;

interface

uses
  PasRequestProcessor, IdCustomHTTPServer, System.SysUtils, System.Classes;

type
  TPlayActionProcessor = class(TRequestProcessor)
  protected
    function innerRequested(requestUri: string; requestAction: string)
      : Boolean; override;
    function onGet(requestInfo: TIdHTTPRequestInfo;
      responseInfo: TIdHTTPResponseInfo): Boolean; override;
  end;

  TPlayAction2Processor = class(TRequestProcessor)
    function innerRequested(requestUri: string; requestAction: string)
      : Boolean; override;
    function onGet(requestInfo: TIdHTTPRequestInfo;
      responseInfo: TIdHTTPResponseInfo): Boolean; override;
  end;

implementation

uses
  CnDebug, PasMessagerHelper, PasGlobalConfiguration, Winapi.Windows, EncdDecd,
  System.JSON, PasYoutubedlHelper, PasLibVlcUserData;

function TPlayActionProcessor.innerRequested(requestUri: string;
  requestAction: string): Boolean;
begin
  Result := 'play'.Equals(requestAction)
end;

function TPlayActionProcessor.onGet(requestInfo: TIdHTTPRequestInfo;
  responseInfo: TIdHTTPResponseInfo): Boolean;
var
  url: string;
  execYoutubedl: string;
  youtubedlResponse: string;
  spliter: TStringList;
  localPlayUrl: string;
  step: Integer;
  httpResponse: string;
  JSON: TJSONObject;
  videoCount: Integer;
  userData: TLibVlcUserData;
begin
  url := requestInfo.Params.Values['url'];
  if EmptyStr.Equals(url) then
  begin
    // 恢复播放,操作指令不进入队列，直接执行
    CnDebugger.TraceMsg('Resume Play');
    TMessagerHelper.sendMessage(FM_PLAY, 0);
    TMessagerHelper.postMessage(FM_FULL_SCREEN, 0);
    httpResponse := '继续播放...';
  end
  else
  begin
    // 不处于播放状态 语言提示
    if TMessagerHelper.sendMessage(FM_PALY_STATUS, 0) <> PS_PLAYING then
    begin
      TMessagerHelper.sendMessage(FM_SPEAK, '正在查询播放地址，请稍后。');
    end;

    // 查询分段视频数量
    videoCount := TYoutubeDlHelper.GetPlaylistCount(url);

    for step := 1 to videoCount do
    begin
      userData := TLibVlcUserData.Create;
      userData.SrcUrl := url;
      userData.LocalUrl :=
        Format('?action=transVlc&returnUrl=false&block=%d&url=%s',
        [step, EncdDecd.EncodeString(url).Replace(#10, '').Replace(#13, '')]);
      userData.PlayStatus := PS_WAIT_PLAY;
      userData.Index := step;
      TMessagerHelper.sendMessage(FM_PLAY, Cardinal(Pointer(userData)));
    end;

    if videoCount = -1 then
      httpResponse := '添加失败'
    else
      httpResponse := '添加成功';

    TMessagerHelper.sendMessage(FM_SPEAK, httpResponse);
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

function TPlayAction2Processor.innerRequested(requestUri: string;
  requestAction: string): Boolean;
begin
  Result := 'transVlc'.Equals(requestAction);
end;

function TPlayAction2Processor.onGet(requestInfo: TIdHTTPRequestInfo;
  responseInfo: TIdHTTPResponseInfo): Boolean;
var
  returnUrl: Boolean;
  block: Integer;
  url: string;
  youtubedlResponse: string;
begin
  CnDebugger.TraceEnter('onGet', Self.ClassName);
  returnUrl := StrToBoolDef(requestInfo.Params.Values['returnUrl'], False);
  block := StrToIntDef(requestInfo.Params.Values['block'], -1);
  url := requestInfo.Params.Values['url'];

  if block <> -1 then
  begin
    url := EncdDecd.DecodeString(url);
    youtubedlResponse := TYoutubeDlHelper.GetVideoInfo(url, block);
    if (Pos('ERROR', youtubedlResponse) > 0) and
      (youtubedlResponse.Chars[0] = '{') then
    begin
      CnDebugger.TraceMsgWithTag(youtubedlResponse, Self.ClassName);
      responseInfo.ResponseNo := 500; // 让vlc重试
    end
    else
    begin
      if returnUrl then
      begin
        responseInfo.ContentText := youtubedlResponse;
      end
      else
      begin
        responseInfo.ResponseNo := 302; // 告知vlc转向
        responseInfo.Location :=
          Format('/?action=vlc&base64=%s',
          [EncdDecd.EncodeString(youtubedlResponse).Replace(#10,
          '').Replace(#13, '')]);
      end;
    end;
  end;
  Result := True;
  CnDebugger.TraceLeave('onGet', Self.ClassName);
end;

end.
