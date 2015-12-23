unit PasIdHttpServerEx;

interface

uses
  IdHTTPServer, PasRequestProcessor, System.Generics.Collections, IdContext,
  IdCustomHTTPServer, System.SysUtils;

type
  TIdHttpServerEx = class(TIdHTTPServer)
  protected
    FChainList: TObjectList<TRequestProcessor>;
    procedure commandDispatcher(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure DoCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo); override;
    procedure DoCommandOther(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo); override;
  public
    constructor Create;
    destructor Destroy;
    // ע���´������������ظô����������ü���
    function registerProcessor(processor: TRequestProcessor): Boolean;
    // �Ƴ�ָ���������������ظô����������ü���
    function removeProcessor(processor: TRequestProcessor): Boolean; overload;
    function removeProcessor(processorClassName: string): Boolean; overload;
    procedure Free;
  end;

implementation

uses
  CnDebug;

constructor TIdHttpServerEx.Create;
begin
  inherited Create;
  //Self.processorLinkList := TObjectDictionary<TRequestProcessor, Integer>.Create();
  Self.FChainList := TObjectList<TRequestProcessor>.Create();
end;

destructor TIdHttpServerEx.Destroy;
begin
  Self.FChainList.Free;
  inherited;
end;
{*------------------------------------------------------------------------------
  ע��һ��������

  @param processor ������
  @return ע����
-------------------------------------------------------------------------------}
function TIdHttpServerEx.registerProcessor(processor: TRequestProcessor): Boolean;
var
  pro: TRequestProcessor;
  refCount: Integer;
  step: Integer;
begin
  CnDebugger.TraceEnter('registerProcessor', Self.ClassName);
  if processor = nil then
  begin
    CnDebugger.TraceMsg('Null Pointer');
    raise Exception.Create('Null Pointer');
  end;

  //for pro in Self.processorLinkList.Keys do
  for step := 0 to Self.FChainList.Count - 1 do
  begin
    pro := Self.FChainList.Items[step];
    if pro.ClassName.Equals(processor.ClassName) then
    begin
      CnDebugger.TraceMsg('Processor exsit');
      if pro <> processor then
      begin
        CnDebugger.TraceMsg('Free Input Processor');
        processor.Free;
      end;
      //processor := pro; // ��������Ѵ��ڣ��Ҳ�Ϊ֮ǰ�Ķ������ͷ��¶������þɵĶ���
      processor := nil;
      Break;
    end;
  end;
  //
  if processor <> nil then
  begin
    Self.FChainList.Add(processor);
    CnDebugger.TraceMsg('Register:' + processor.ClassName);
    Result := True;
  end
  else
  begin
    CnDebugger.TraceMsg('Skip Register');
    Result := False
  end;

  CnDebugger.TraceLeave('registerProcessor', Self.ClassName);
end;

function TIdHttpServerEx.removeProcessor(processor: TRequestProcessor): Boolean;
begin
  if processor = nil then
  begin
    CnDebugger.TraceMsg('removeProcessor(TRequestProcessor) -> Null Pointer');
    raise Exception.Create('Null Pointer');
  end;
  Result := Self.removeProcessor(processor.ClassName);
end;

function TIdHttpServerEx.removeProcessor(processorClassName: string): Boolean;
var
  pro: TRequestProcessor;
  regCount: Integer;
  step: Integer;
begin
  CnDebugger.TraceEnter('removeProcessor', Self.ClassName);
  CnDebugger.TraceMsg('remove:' + processorClassName);
  //for pro in Self.processorLinkList.Keys do
  for step := 0 to Self.FChainList.Count - 1 do
  begin
    pro := Self.FChainList.Items[step];
    if pro.ClassName.Equals(processorClassName) then
    begin
      CnDebugger.TraceMsg('Find Processor');
      Break;
    end;
    pro := nil;
  end;

  if (pro <> nil) and pro.ClassName.Equals(processorClassName) then
  begin
    Self.FChainList.Remove(pro);
    FreeAndNil(pro);
    Result := True;
  end
  else
  begin
    Result := False;
  end;
  CnDebugger.TraceMsg('Result :' + BoolToStr(Result));
  CnDebugger.TraceLeave('removeProcessor', Self.ClassName);
end;

procedure TIdHttpServerEx.commandDispatcher(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  eachProcessor: TRequestProcessor;
  uri, action: string;
begin
  CnDebugger.TraceMsgWithTag('Enter:CommandDispatcher', Self.ClassName);
  uri := ARequestInfo.uri;
  action := ARequestInfo.Params.Values['action'];
  // ����
  for eachProcessor in Self.FChainList do
  begin
    if eachProcessor.requested(uri, action) then
    begin
      CnDebugger.TraceMsg('Processor Invoked:' + eachProcessor.ClassName);
      if not eachProcessor.onCommand(AContext, ARequestInfo, AResponseInfo) then
        Break;
    end;
  end;
  CnDebugger.TraceMsgWithTag('Leave:CommandDispatcher', Self.ClassName);
end;

procedure TIdHttpServerEx.DoCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  Self.commandDispatcher(AContext, ARequestInfo, AResponseInfo);
end;

procedure TIdHttpServerEx.DoCommandOther(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  Self.commandDispatcher(AContext, ARequestInfo, AResponseInfo);
end;

procedure TIdHttpServerEx.Free;
var
  processor: TRequestProcessor;
begin
  // release processor
  for processor in Self.FChainList do
  begin
    Self.FChainList.Remove(processor);
    //processor.Free;
  end;
  // release list
  Self.FChainList.Free;
  inherited Free;
end;

end.

