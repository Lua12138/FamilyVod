unit PasPlayerListProcessor;

interface

uses
  PasRequestProcessor, IdCustomHTTPServer, System.SysUtils, System.Classes;

type
  TPlayerListProcessor = class(TRequestProcessor)
  protected
    function innerRequested(requestUri: string; requestAction: string)
      : Boolean; override;
    function onGet(requestInfo: TIdHTTPRequestInfo;
      responseInfo: TIdHTTPResponseInfo): Boolean; override;
  end;

implementation

uses
  PasMessagerHelper, PasLibVlcPlayerUnit, PasLibVlcClassUnit, System.JSON,
  PasLibVlcUserData, PasLibVlcUnit;

function TPlayerListProcessor.innerRequested(requestUri: string;
  requestAction: string): Boolean;
begin
  Result := 'showList'.Equals(requestAction);
end;

function TPlayerListProcessor.onGet(requestInfo: TIdHTTPRequestInfo;
  responseInfo: TIdHTTPResponseInfo): Boolean;
var
  playerList: TPasLibVlcMediaList;
  media: TPasLibVlcMedia;
  userData: TLibVlcUserData;
  returnValue: Cardinal;
  step: Integer;
  jsonResult: TJSONArray;
  jsonElement: TJSONObject;
begin
  returnValue := TMessagerHelper.sendMessage(FM_LIST, 0);
  if returnValue > 0 then
  begin
    playerList := Pointer(returnValue);
    jsonResult := TJSONArray.Create;
    jsonElement := TJSONObject.Create;
    for step := 0 to playerList.Count - 1 do
    begin
      media := playerList.GetMedia(step);
      userData := media.GetUserData;
      jsonElement.AddPair('id', TJSONNumber.Create(step));
      jsonElement.AddPair('title', userData.Title);
      jsonElement.AddPair('playstatus',
        TJSONNumber.Create(userData.PlayStatus));
      jsonResult.AddElement(jsonElement);
      media.Free;
    end;
    responseInfo.ContentText := jsonResult.ToJSON;
    jsonElement.Free;
    jsonResult.Free;
  end;

  responseInfo.ContentType := 'application/json';
  responseInfo.CharSet := 'utf-8';
end;

end.
