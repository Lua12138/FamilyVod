unit PasGlobalConfiguration;

interface

uses
  System.SysUtils, System.Classes, System.Rtti, System.IniFiles;

type
  TGlobalConfiguration = class
  private
    appBaseUrl: string;
    appWebRoot: string;
    appVlcRoot: string;
    appYoutubedlRoot: string;
    appIniRoot: string;
    appPythonRoot:string;
    ini: TIniFile;
    constructor realConstructor;
    const
      iniSelection = 'GlobalConfiguration';
    class var
      instance: TGlobalConfiguration;
  protected
  public
    // 获得相对于程序路径的url
    function relativePath(path: string): string;
    // 保存配置到硬盘
    procedure save;
    class function getInstance: TGlobalConfiguration; static;
    constructor Create(NoUse: Byte);
    //procedure DoNothing; virtual; abstract;
    property baseUrl: string read appBaseUrl;
    property webRoot: string read appWebRoot;
    property vlcRoot: string read appVlcRoot;
    property youtubedlRoot: string read appYoutubedlRoot;
    property pythonRoot:string read appPythonRoot;
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
  // 公共构造方法抛异常，防止调用Tobject.create
  raise Exception.Create('Can not support this operation!');
end;

constructor TGlobalConfiguration.realConstructor;
begin
  // set default values
  Self.appBaseUrl := ExtractFilePath(Application.ExeName);
  Self.appWebRoot := Self.relativePath('dependce/web');
  Self.appVlcRoot := Self.relativePath('dependce/vlc');
  Self.appYoutubedlRoot := Self.relativePath('dependce/youtube-dl.exe');
  Self.appPythonRoot:=Self.relativePath('dependce/python/python.exe');
  //read ini file
  Self.appIniRoot := Self.relativePath('dependce/configuration.bmp');
  ini := TIniFile.Create(Self.appIniRoot);

  Self.appWebRoot := ini.ReadString(Self.iniSelection, 'webRoot', Self.appWebRoot);
  Self.appVlcRoot := ini.ReadString(Self.iniSelection, 'vlcRoot', Self.appVlcRoot);
  Self.appYoutubedlRoot := ini.ReadString(Self.iniselection, 'youtubedlRoot', Self.youtubedlRoot);

end;

procedure TGlobalConfiguration.save;
begin
  try
    ini.WriteString(Self.iniSelection, 'webRoot', Self.appWebRoot);
    ini.WriteString(Self.iniSelection, 'vlcRoot', Self.appVlcRoot);
    ini.WriteString(Self.iniselection, 'youtubedlRoot', Self.youtubedlRoot);
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
  @param path 相对路径
  @return 相对于程序目录的绝对路径
  ------------------------------------------------------------------------------- }

function TGlobalConfiguration.relativePath(path: string): string;
begin
  Result := Self.baseUrl + path;
end;

end.

