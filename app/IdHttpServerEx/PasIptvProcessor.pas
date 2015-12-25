unit PasIptvProcessor;

interface

uses
  PasRequestProcessor, IdCustomHTTPServer, System.SysUtils, System.Classes;

type
  TIPTVProcessor = class(TRequestProcessor)
  protected
    function innerRequested(requestUri: string; requestAction: string)
      : Boolean; override;
    function onGet(requestInfo: TIdHTTPRequestInfo;
      responseInfo: TIdHTTPResponseInfo): Boolean; override;
  end;

implementation

uses PasMessagerHelper;

function TIPTVProcessor.innerRequested(requestUri: string;
  requestAction: string): Boolean;
begin
  Result := 'iptv'.Equals(requestAction);
end;

function TIPTVProcessor.onGet(requestInfo: TIdHTTPRequestInfo;
  responseInfo: TIdHTTPResponseInfo): Boolean;
var
  url: string;
begin
  url := requestInfo.Params.Values['url'];

  if EmptyStr.Equals(url) then
    responseInfo.ContentText := '播放地址不能为空'
  else
  begin
    TMessagerHelper.sendMessage(FM_IPTV, url);
    responseInfo.ContentText := '即将开始播放';
  end;
  responseInfo.ContentType := 'plain/text';
  responseInfo.CharSet := 'utf-8';
  Result := False;
end;

end.
