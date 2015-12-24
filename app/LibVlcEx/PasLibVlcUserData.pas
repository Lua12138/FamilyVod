unit PasLibVlcUserData;

interface

uses
  System.SysUtils, System.Classes;

type
  TLibVlcUserData = class
  private
    FSrcUrl: string;
    FLocalUrl: string; // 本地web转发地址
    FLocalPath: string; // 本地缓存的地址
    FReferer: string;
    FTitle: string;
    FPlayStatus: Integer;
    FIndex: Integer; // 所属播放列表序号
  public
    property SrcUrl: string read FSrcUrl write FSrcUrl;
    property LocalUrl: string read FLocalUrl write FLocalUrl;
    property LocalPath: string read FLocalPath write FLocalPath;
    property Referer: string read FReferer write FReferer;
    property Title: string read FTitle write FTitle;
    property PlayStatus: Integer read FPlayStatus write FPlayStatus;
    property Index: Integer read FIndex write FIndex;
    constructor Create;
  end;

implementation

constructor TLibVlcUserData.Create;
begin

end;

end.
