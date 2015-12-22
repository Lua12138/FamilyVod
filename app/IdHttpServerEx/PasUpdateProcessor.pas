unit PasUpdateProcessor;

interface

uses
  PasRequestProcessor, IdCustomHTTPServer, System.SysUtils, System.Classes;

type
  TUpdateProcessor = class(TRequestProcessor)
  protected
    function innerRequested(requestUri: string; requestAction: string): Boolean; override;
    function onPost(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean; override;
  end;

implementation

uses
  CnDebug, IdMultipartFormData, IdMessageCoderMIME, IdMessageCoder, PasCrcHelper,
  PasGlobalConfiguration;

function TUpdateProcessor.innerRequested(requestUri: string; requestAction: string): Boolean;
begin
  Result := '/update'.Equals(requestUri) and 'update'.Equals(requestAction);
end;

function TUpdateProcessor.onPost(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
var
  files: TStringStream;
  updateTo: string;
  srcCrc, desCrc: Cardinal;
begin
  updateTo := requestInfo.Params.Values['to'];
  srcCrc := Cardinal(StrToUInt64Def(requestInfo.Params.Values['crc'], 0));

  CnDebugger.TraceMsg('Update File:' + updateTo);
  CnDebugger.TraceMsg('DesCrc:' + IntToHex(srcCrc, 8));

  files := TStringStream.Create;
  try
    if FileExists(TGlobalConfiguration.getInstance.relativePath(updateTo)) then
    begin
      files.LoadFromFile(TGlobalConfiguration.getInstance.relativePath(updateTo));
      // calc CRC value
      PasCrcHelper.GetCRC32Stream(files, desCrc);

      if srcCrc = desCrc then
      begin
        files.LoadFromStream(requestInfo.PostStream);
        files.SaveToFile(TGlobalConfiguration.getInstance.relativePath(updateTo));
        responseInfo.ContentText := 'Update Okay';
      end
      else
      begin
        CnDebugger.TraceMsg(Format('Crc Err: Src -> %s , Des -> %s', [inttohex(srcCrc, 8), inttohex(desCrc, 8)]));
        responseInfo.ContentText := 'Crc Verified fail.';
      end;
    end
    else
    begin
      responseInfo.ContentText := 'File Not Exists.';
    end;
  finally
    files.Free;
  end;
  Result := False;
end;

end.

