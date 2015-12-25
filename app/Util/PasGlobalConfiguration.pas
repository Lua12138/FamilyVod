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
    FPythonRoot: string;
    FIni: TIniFile;
    constructor realConstructor;

  const
    iniSelection = 'GlobalConfiguration';
    class var instance: TGlobalConfiguration;
  protected
  public
    // 获得相对于程序路径的url
    function relativePath(path: string): string;
    // 保存配置到硬盘
    procedure save;
    class function getInstance: TGlobalConfiguration; static;
    constructor Create(NoUse: Byte);
    // procedure DoNothing; virtual; abstract;
    property baseUrl: string read FBaseUrl;
    property webRoot: string read FWebRoot;
    property vlcRoot: string read FVlcRoot;
    property youtubedlRoot: string read FYoutubedlRoot;
    property pythonRoot: string read FPythonRoot;
    procedure Free;
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
  // 公共构造方法抛异常，防止调用Tobject.create
  raise Exception.Create('Can not support this operation!');
end;

constructor TGlobalConfiguration.realConstructor;
begin
  // set default values
  Self.FBaseUrl := ExtractFilePath(Application.ExeName);
  Self.FWebRoot := Self.relativePath('dependce/web');
  Self.FVlcRoot := Self.relativePath('dependce/vlc');
  Self.FYoutubedlRoot := Self.relativePath('dependce/youtube-dl.exe');
  Self.FPythonRoot := Self.relativePath('dependce/python/python.exe');
  // read ini file
  Self.FIniRoot := Self.relativePath('dependce/configuration.bmp');
  FIni := TIniFile.Create(Self.FIniRoot);

  Self.FWebRoot := FIni.ReadString(Self.iniSelection, 'webRoot', Self.FWebRoot);
  Self.FVlcRoot := FIni.ReadString(Self.iniSelection, 'vlcRoot', Self.FVlcRoot);
  Self.FYoutubedlRoot := FIni.ReadString(Self.iniSelection, 'youtubedlRoot',
    Self.youtubedlRoot);

end;

procedure TGlobalConfiguration.save;
begin
  try
    FIni.WriteString(Self.iniSelection, 'webRoot', Self.FWebRoot);
    FIni.WriteString(Self.iniSelection, 'vlcRoot', Self.FVlcRoot);
    FIni.WriteString(Self.iniSelection, 'youtubedlRoot', Self.youtubedlRoot);
  except
    on E: Exception do
    begin
      CnDebugger.TraceMsg('Save Err:' + E.ClassName);
      CnDebugger.TraceMsg('Message:' + E.Message);
      CnDebugger.TraceMsg(E.StackTrace);
    end;
  end;
end;
{ *------------------------------------------------------------------------------
  .
  @param path 相对路径
  @return 相对于程序目录的绝对路径
  ------------------------------------------------------------------------------- }

function TGlobalConfiguration.relativePath(path: string): string;
begin
  Result := Self.baseUrl + path;
end;

procedure TGlobalConfiguration.Free;
begin
  if TGlobalConfiguration.instance <> nil then
  begin
    TGlobalConfiguration.instance.save;
    TGlobalConfiguration.instance.FIni.Free;
    FreeAndNil(TGlobalConfiguration.instance);
  end;
end;

end.
