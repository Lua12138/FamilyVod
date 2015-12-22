unit PasVideoTransferProcessor;

interface

uses
  PasRequestProcessor, IdCustomHTTPServer, System.SysUtils, System.Classes;

type
  TVideoTransferProcessor = class(TRequestProcessor)
  protected
    function innerRequested(requestUri: string; requestAction: string): Boolean; override;
    function onGet(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean; override;
  end;

implementation

uses
  encddecd, System.JSON, IdHTTP, CnDebug, PasMessagerHelper;

function TVideoTransferProcessor.innerRequested(requestUri: string; requestAction: string): Boolean;
begin
  Result := 'vlc'.Equals(requestAction);
end;

function TVideoTransferProcessor.onGet(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
var
  base64: string;
  objJson: TJSONObject;
  mapJson: TJSONPair;
  url: string;
  http: TIdHTTP;
  httpResponse: TStream;
  fileSize, filePos: Int64;
const
  Block_Size = 1024{Byte/K}   * 1024{K/M}   * 2; // 2MB
begin
  base64 := requestInfo.Params.Values['base64'];
  base64 := encddecd.DecodeString(base64);
  objJson := TJSONObject.ParseJSONValue(base64) as TJSONObject;
  url := objJson.Values['url'].Value; // 播放地址
  objJson := objJson.Values['http_headers'] as TJSONObject; // http headers

  http := TIdHTTP.Create();
  try
    try
      http.HandleRedirects := True;

      TMessagerHelper.sendMessage(FM_SPEAK, '正在缓冲视频，请稍后');
      // 获得文件体积
      http.Head(url);
      fileSize := http.Response.ContentLength;
      responseInfo.ContentLength := fileSize;
      responseInfo.WriteHeader; // 避免客户端关闭连接

      CnDebugger.TraceMsg('File Size:' + IntToStr(fileSize));

      // 添加HTTP头
      for mapJson in objJson do
      begin
        http.Request.CustomHeaders.AddValue(mapJson.JsonString.Value, mapJson.JsonValue.Value);
      end;
      // 分块请求内容
      filePos := 0; // 文件当前位置
      while filePos < fileSize do
      begin
        http.Request.Range := IntToStr(filePos) + '-';
        if filePos + Block_Size < fileSize then
          http.Request.Range := http.Request.Range + IntToStr(filePos + Block_Size);

        CnDebugger.TraceMsg('Request Range:' + http.Request.Range);

        httpResponse := TMemoryStream.Create;
        http.Get(url, httpResponse); // 请求资源
        filePos := filePos + httpResponse.Size;
        responseInfo.ContentType := http.Response.ContentType;
        responseInfo.ContentStream := httpResponse;
        responseInfo.WriteContent; // Response会自动释放responseStream对象
      end;

    except
      on E: Exception do
      begin
        TMessagerHelper.sendMessage(FM_SPEAK, '缓冲意外终止');
        CnDebugger.TraceMsgError(E.ClassName + ':' + E.Message);
        CnDebugger.TraceMsgError(E.StackTrace);
      end;
    end;
  finally
    http.Free;
  end;
  Result := True;
end;

end.

