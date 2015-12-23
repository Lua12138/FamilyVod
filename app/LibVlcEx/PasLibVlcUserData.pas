unit PasLibVlcUserData;

interface

uses
  System.SysUtils, System.Classes;

type
  TLibVlcUserData = class
  private
    FSrcUrl: string;
    FLocalUrl: string;
    FReferer: string;
    FTitle: string;
    FPlayStatus: Integer;
  public
    property SrcUrl: string read FSrcUrl write FSrcUrl;
    property LocalUrl: string read FLocalUrl write FLocalUrl;
    property Referer: string read FReferer write FReferer;
    property Title: string read FTitle write FTitle;
    property PlayStatus: Integer read FPlayStatus write FPlayStatus;
    constructor Create;
  end;

implementation

constructor TLibVlcUserData.Create;
begin

end;

end.
