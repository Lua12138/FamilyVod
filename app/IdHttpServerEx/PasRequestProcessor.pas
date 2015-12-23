unit PasRequestProcessor;

interface

uses
  IdCustomHTTPServer, System.SysUtils, IdContext, Winapi.Windows;

type
  { *------------------------------------------------------------------------------

    @author  forDream
    @version 2015/12/19 1.0 Initial revision.
    @todo
    @comment
    ------------------------------------------------------------------------------- }
  TRequestProcessor = class(TObject)
  private
    alwaysDoOnCommand: Boolean; // ������ζ�����onCommand����
  protected
    function innerRequested(requestUri: string; requestAction: string): Boolean;
      virtual; abstract;
    function onGet(requestInfo: TIdHTTPRequestInfo;
      responseInfo: TIdHTTPResponseInfo): Boolean; virtual;
    function onPost(requestInfo: TIdHTTPRequestInfo;
      responseInfo: TIdHTTPResponseInfo): Boolean; virtual;
    function onCommand(requestInfo: TIdHTTPRequestInfo;
      responseInfo: TIdHTTPResponseInfo): Boolean; overload; virtual;
    property alwaysOnCommand: Boolean read alwaysDoOnCommand
      write alwaysDoOnCommand;
  public
    constructor Create;
    // �������Ƿ�������󣬴�����true
    function requested(requestUri: string; requestAction: string): Boolean;
    // �Ƿ񴫵ݸ���һ�����������жϴ���������false
    function onCommand(context: TIdContext; requestInfo: TIdHTTPRequestInfo;
      responseInfo: TIdHTTPResponseInfo): Boolean; overload;
  end;

implementation

uses
  CnDebug, Vcl.Forms;

constructor TRequestProcessor.Create;
begin
  Self.alwaysDoOnCommand := False;
end;

function TRequestProcessor.requested(requestUri: string;
  requestAction: string): Boolean;
begin
  Result := Self.innerRequested(requestUri, requestAction);
  if Result then
  begin
    CnDebugger.TraceMsgWithTag('Enter:Requested', Self.ClassName);
    CnDebugger.TraceMsg('Uri:' + requestUri);
    CnDebugger.TraceMsg('Action:' + requestAction);
    CnDebugger.TraceMsgWithTag('Leave:Requested', Self.ClassName);
  end;
end;

function TRequestProcessor.onCommand(context: TIdContext;
  requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
begin
  CnDebugger.TraceMsgWithTag('onCommand', Self.ClassName);
  CnDebugger.TraceMsg('Command:' + requestInfo.Command);
  if requestInfo.CommandType = hcGET then
    Result := Self.onGet(requestInfo, responseInfo)
  else if requestInfo.CommandType = hcPOST then
    Result := Self.onPost(requestInfo, responseInfo)
  else
    Result := Self.onCommand(requestInfo, responseInfo);

  // always invoked onCommand Method.
  if not(requestInfo.CommandType in [hcGET, hcPOST]) and Self.alwaysOnCommand
  then
    Result := Self.onCommand(requestInfo, responseInfo);
  CnDebugger.TraceMsgWithTag('onCommand', Self.ClassName);
end;

function TRequestProcessor.onGet(requestInfo: TIdHTTPRequestInfo;
  responseInfo: TIdHTTPResponseInfo): Boolean;
begin
  Result := True;
end;

function TRequestProcessor.onPost(requestInfo: TIdHTTPRequestInfo;
  responseInfo: TIdHTTPResponseInfo): Boolean;
begin
  Result := True;
end;

function TRequestProcessor.onCommand(requestInfo: TIdHTTPRequestInfo;
  responseInfo: TIdHTTPResponseInfo): Boolean;
begin
  Result := True;
end;

end.
