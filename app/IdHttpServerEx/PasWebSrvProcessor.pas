unit PasWebSrvProcessor;

interface

uses
  PasRequestProcessor, IdCustomHTTPServer, System.SysUtils, System.Classes;

type
  TWebSrvProcessor = class(TRequestProcessor)
  protected
    function innerRequested(requestUri: string; requestAction: string): Boolean; override;
    function onGet(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean; override;
  end;

implementation

uses
  CnDebug, PasGlobalConfiguration, IdHTTP, IdGlobalProtocols;

function TWebSrvProcessor.innerRequested(requestUri: string; requestAction: string): Boolean;
begin
  Result := EmptyStr.Equals(requestAction) and not'/update'.Equals(requesturi);
end;

function TWebSrvProcessor.onGet(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
var
  responseStream: TStream;
  responseContentType: string;
  responseCharset: string;
  responseStatus: Integer;
  http: TIdHTTP;
  mime: TIdMimeTable;
  url: string;
begin
  url := requestInfo.Params.Values['url'];
  mime := TIdMimeTable.Create();
  responseStatus := 200;
  try
    responseStream := TMemoryStream.Create;
    if requestInfo.URI.Equals('/') then // 点播页面
    begin
      CnDebugger.TraceMsg('Request HomePage');
      responseContentType := 'text/html';
      responseCharset := 'utf-8';
      TMemoryStream(responseStream).LoadFromFile(TGlobalConfiguration.getInstance.webRoot + '/index.html');
    end
    else if '/services/browser/img'.Equals(requestinfo.URI) then // 图片翻译
    begin
      CnDebugger.TraceMsg('Request Image Transfer');
      http := TIdHTTP.Create();
      try
        responseStream := TMemoryStream.Create;
        http.Get(url, responseStream);
        responseContentType := http.Response.ContentType;
      finally
        http.Free;
      end;
    end
    else // 本地资源
    begin
      if FileExists(TGlobalConfiguration.getInstance.webRoot + requestInfo.URI) then
      begin
        responseStream := TMemoryStream.Create;
        TMemoryStream(responseStream).LoadFromFile(TGlobalConfiguration.getInstance.webRoot + requestInfo.URI);
        responseContentType := mime.GetFileMIMEType(TGlobalConfiguration.getInstance.webRoot + requestInfo.URI);
      end
      else
      begin
        responseStatus := 404;
      end;
      CnDebugger.TraceMsg('Request Local Res:' + requestInfo.URI + ' ,Response Code:' + IntToStr(responseStatus));
    end;
  finally
    mime.free;
  end;

  responseInfo.ContentStream := responseStream;
  responseInfo.ContentType := responseContentType;

  responseInfo.ResponseNo := responseStatus;
  responseInfo.CharSet := responseCharset;
  Result := True;
end;

end.

