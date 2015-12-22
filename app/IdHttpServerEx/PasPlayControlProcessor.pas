unit PasPlayControlProcessor;

interface

uses
  PasRequestProcessor, System.Classes, System.SysUtils, IdCustomHTTPServer;

type
  TPlayControlProcessor = class(TRequestProcessor)
  protected
    function innerRequested(requestUri: string; requestAction: string): Boolean; override;
    function onGet(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean; override;
  end;

implementation

uses
  PasMessagerHelper;

function TPlayControlProcessor.innerRequested(requestUri: string; requestAction: string): Boolean;
begin
  if 'pause'.Equals(requestAction) then
    Result := True
  else if 'stop'.Equals(requestAction) then
    Result := True
  else if 'next'.Equals(requestAction) then
    Result := True
  else
    Result := False;

end;

function TPlayControlProcessor.onGet(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
var
  requestAction: string;
begin
  requestAction := requestInfo.Params.Values['action'];
  if 'pause'.Equals(requestAction) then
    tmessagerhelper.postMessage(fm_pause, 0)
  else if 'stop'.Equals(requestAction) then
    tmessagerhelper.postMessage(fm_stop, 0)
  else if 'next'.Equals(requestAction) then
    tmessagerhelper.postMessage(fm_next, 0);

  Result := True;
end;

end.

