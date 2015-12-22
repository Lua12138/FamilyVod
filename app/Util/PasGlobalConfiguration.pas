unit PasGlobalConfiguration;

interface

uses
  System.SysUtils, System.Classes, System.Rtti, System.IniFiles;

type
  TGlobalConfiguration = class
  private
    FBaseUrl: string;
    FWebRoot: string;
    FVlcRoot: string;
    FYoutubedlRoot: string;
    FIniRoot: string;
    FPythonRoot:string;
    FIni: TIniFile;
    constructor realConstructor;
    const
      iniSelection = 'GlobalConfiguration';
    class var
      instance: TGlobalConfiguration;
  protected
  public
    // �������ڳ���·����url
    function relativePath(path: string): string;
    // �������õ�Ӳ��
    procedure save;
    class function getInstance: TGlobalConfiguration; static;
    constructor Create(NoUse: Byte);
    //procedure DoNothing; virtual; abstract;
    property baseUrl: string read FBaseUrl;
    property webRoot: string read FWebRoot;
    property vlcRoot: string read FVlcRoot;
    property youtubedlRoot: string read FYoutubedlRoot;
    property pythonRoot:string read FPythonRoot;
    const
      sss = 'sss';
  end;

implementation

{$M+}

uses
  Vcl.Forms, CnDebug;

class function TGlobalConfiguration.getInstance: TGlobalConfiguration;
begin
  if TGlobalConfiguration.instance = nil then
  begin
    TGlobalConfiguration.instance := TGlobalConfiguration.realConstructor;
  end;
  Result := TGlobalConfiguration.instance;
end;

constructor TGlobalConfiguration.Create(NoUse: Byte);
begin
  // �������췽�����쳣����ֹ����Tobject.create
  raise Exception.Create('Can not support this operation!');
end;

constructor TGlobalConfiguration.realConstructor;
begin
  // set default values
  Self.FBaseUrl := ExtractFilePath(Application.ExeName);
  Self.FWebRoot := Self.relativePath('dependce/web');
  Self.FVlcRoot := Self.relativePath('dependce/vlc');
  Self.FYoutubedlRoot := Self.relativePath('dependce/youtube-dl.exe');
  Self.FPythonRoot:=Self.relativePath('dependce/python/python.exe');
  //read ini file
  Self.FIniRoot := Self.relativePath('dependce/configuration.bmp');
  FIni := TIniFile.Create(Self.FIniRoot);

  Self.FWebRoot := FIni.ReadString(Self.iniSelection, 'webRoot', Self.FWebRoot);
  Self.FVlcRoot := FIni.ReadString(Self.iniSelection, 'vlcRoot', Self.FVlcRoot);
  Self.FYoutubedlRoot := FIni.ReadString(Self.iniselection, 'youtubedlRoot', Self.youtubedlRoot);

end;

procedure TGlobalConfiguration.save;
begin
  try
    FIni.WriteString(Self.iniSelection, 'webRoot', Self.FWebRoot);
    FIni.WriteString(Self.iniSelection, 'vlcRoot', Self.FVlcRoot);
    FIni.WriteString(Self.iniselection, 'youtubedlRoot', Self.youtubedlRoot);
  except
    on E: Exception do
    begin
      CnDebugger.TraceMsg('Save Err:' + e.ClassName);
      CnDebugger.TraceMsg('Message:' + e.Message);
      CnDebugger.TraceMsg(E.StackTrace);
    end;
  end;
end;
{ *------------------------------------------------------------------------------
  .
  @param path ���·��
  @return ����ڳ���Ŀ¼�ľ���·��
  ------------------------------------------------------------------------------- }

function TGlobalConfiguration.relativePath(path: string): string;
begin
  Result := Self.baseUrl + path;
end;

end.

