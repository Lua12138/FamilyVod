unit PasLibVlcPlayerEx;

interface

uses
  PasLibVlcPlayerUnit, PasLibVlcUnit, PasLibVlcClassUnit;

type
  TPasLibVlcMediaListEx = class(TPasLibVlcMediaList)
  public
    procedure Add(mrl: WideString); overload;
    procedure Add(mrl: WideString; title: string); overload;
  end;

implementation

procedure TPasLibVlcMediaListEx.Add(mrl: WideString);
begin
  inherited;
end;

procedure TPasLibVlcMediaListEx.Add(mrl: WideString; title: string);
begin

end;

end.

