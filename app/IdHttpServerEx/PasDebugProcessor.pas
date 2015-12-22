unit PasDebugProcessor;

interface

uses
  PasRequestProcessor, IdCustomHTTPServer, System.SysUtils, System.Classes;

type
  TDebugProcessor = class(TRequestProcessor)
  protected
    function innerRequested(requestUri: string; requestAction: string): Boolean; override;
    function onPost(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean; override;
    function onGet(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean; override;
  public
    constructor Create;
  end;

implementation

constructor TDebugProcessor.Create;
begin
  //Self.alwaysOnCommand := True;
end;

function TDebugProcessor.innerRequested(requestUri: string; requestAction: string): Boolean;
begin
  Result := True;
end;

function TDebugProcessor.onGet(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
var
  action: string;
begin
  action := requestInfo.Params.Values['action'];
  if 'play'.Equals(action) then
  begin

  end;
  Result := True;
end;

function TDebugProcessor.onPost(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
begin
  Result := True;
end;

end.

