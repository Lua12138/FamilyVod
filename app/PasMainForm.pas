unit PasMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  PasLibVlcUnit, PasQrCode, System.Win.ComObj, PasCrcHelper, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, IdGlobalProtocols,
  Generics.Collections, IdBaseComponent, IdComponent, PasMessagerHelper,
  IdCustomTCPServer, IdCustomHTTPServer, PasLibVlcPlayerUnit, IdHTTPServer,
  IdContext, IdServerIOHandler, IdServerIOHandlerSocket, IdServerIOHandlerStack,
  IdSSL, IdSSLOpenSSL, IdTCPConnection, IdTCPClient, IdHTTP, IdIPWatch,
  IdAntiFreezeBase, Vcl.IdAntiFreeze, PasIdHttpServerEx, IdMessageCoder,
  IdMessageCoderMIME;

type
  TfrmMain = class(TForm)
    pslbvlcmdlst1: TPasLibVlcMediaList;
    img1: TImage;
    idpwtch1: TIdIPWatch;
    player: TPasLibVlcPlayer;
    idntfrz1: TIdAntiFreeze;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure playerMediaPlayerStopped(Sender: TObject);
    procedure playerMediaPlayerPaused(Sender: TObject);
    procedure playerMediaPlayerBuffering(Sender: TObject);
    procedure playerMediaPlayerMediaChanged(Sender: TObject; mrl: string);
    procedure playerMediaPlayerNothingSpecial(Sender: TObject);
    procedure playerMediaPlayerPlaying(Sender: TObject);
    procedure playerMediaPlayerForward(Sender: TObject);
    procedure playerMediaPlayerOpening(Sender: TObject);
    procedure pslbvlcmdlst1ItemAdded(Sender: TObject; mrl: WideString; item: Pointer; index: Integer);
    procedure pslbvlcmdlst1ItemDeleted(Sender: TObject; mrl: WideString; item: Pointer; index: Integer);
    procedure pslbvlcmdlst1NextItemSet(Sender: TObject; mrl: WideString; item: Pointer; index: Integer);
    procedure pslbvlcmdlst1Played(Sender: TObject);
    procedure pslbvlcmdlst1Stopped(Sender: TObject);
    procedure pslbvlcmdlst1WillAddItem(Sender: TObject; mrl: WideString; item: Pointer; index: Integer);
    procedure pslbvlcmdlst1WillDeleteItem(Sender: TObject; mrl: WideString; item: Pointer; index: Integer);
    procedure playerMediaPlayerEvent(p_event: libvlc_event_t_ptr; data: Pointer);
    procedure playerMediaPlayerPausableChanged(Sender: TObject; val: Boolean);
    procedure playerMediaPlayerVideoOutChanged(Sender: TObject; video_out: Integer);
    procedure playerMediaPlayerBackward(Sender: TObject);
    procedure playerMediaPlayerEncounteredError(Sender: TObject);
    procedure playerMediaPlayerEndReached(Sender: TObject);
    procedure playerGetSiteInfo(Sender: TObject; DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure playerMediaPlayerLengthChanged(Sender: TObject; time: Int64);
    procedure messageProcessor(var msg: TMessage); message WM_FORDREAM;
  private
    { Private declarations }
    httpSrv: TIdHttpServerEx;
    voice: OleVariant;
    // webRoot: string; // 点播页面绝对路径
    httpServerUri: string; // 本地HTTP服务绝对路径
    procedure drawQrCode; // 绘制点播页面URL 二维码
    procedure speak(text: string; sync: Boolean = False); // TTS朗读
    procedure fullScreen; // 全屏无边框显示窗口

  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  CnDebug, EncdDecd, System.JSON, PasGlobalConfiguration, PasPlayActionProcessor,
  PasVideoTransferProcessor, PasWebSrvProcessor, PasPlayControlProcessor,
  PasUpdateProcessor, PasDebugProcessor;
{$R *.dfm}
// {$DEFINE DEBUG}

procedure TfrmMain.messageProcessor(var msg: TMessage);
var
  str: string;
  pStr: PChar;
begin
  CnDebugger.TraceEnter('messageProcessor', Self.ClassName);
  CnDebugger.TraceMsg('Message:' + IntToStr(msg.WParam - WM_FORDREAM));
  CnDebugger.TraceMsg('Param:' + IntToStr(msg.LParam));
  case msg.WParam of
    FM_SPEAK:
      begin
        pStr := Pointer(msg.LParam);
        cndebugger.TraceMsg('Speak Strings:' + pStr);
        Self.speak(pStr);
      end;
    FM_PALY_STATUS:
      begin
        if pslbvlcmdlst1.IsPlay then
          msg.Result := PS_PLAYING
        else if pslbvlcmdlst1.IsPause then
          msg.Result := PS_PAUSED
        else
          msg.Result := PS_OTHER;
      end;
    FM_PLAY:
      begin
        if msg.LParam = 0 then
          pslbvlcmdlst1.Play
        else
        begin
          pStr := Pointer(msg.LParam);
          pStr := PChar(httpServerUri + pStr);
          CnDebugger.TraceMsg('PlayUrl:' + pStr);
          pslbvlcmdlst1.Add(pStr, '111aaa测试挑剔bbb222');
          pslbvlcmdlst1.Play;
        end;
      end;
    FM_NEXT:
      pslbvlcmdlst1.Next;
    FM_PAUSE:
      pslbvlcmdlst1.Pause;
    FM_STOP:
      pslbvlcmdlst1.Stop;
    FM_FULL_SCREEN:
      fullScreen;
    FM_SHUTDOWN:
      CnDebugger.TraceMsg('准备关机');
  end;
  CnDebugger.TraceLeave('messageProcessor', Self.ClassName);
end;

procedure TfrmMain.fullScreen;
begin
  player.Align := alClient; // 播放器最大化
{$IFNDEF DEBUG}
  Self.BorderStyle := bsNone; // 无边框
  Self.WindowState := wsMaximized; // 最大化
  ClientHeight := Screen.Height;
  ClientWidth := Screen.Width;
{$ELSE}
  CnDebugger.TraceMsg('Debug Mode:Skip FullScreen');
{$ENDIF}
  Refresh;
end;

procedure TfrmMain.drawQrCode;
var
  bitmap: TBitmap;
  qrCode: TDelphiZXingQRCode;
begin
  bitmap := TBitmap.Create;
  qrCode := TDelphiZXingQRCode.Create;
  try

    qrCode.Encoding := TQRCodeEncoding.qrUTF8NoBOM;
    qrCode.data := httpServerUri;

    qrCode.drawQrCode(bitmap);

    img1.Picture.Assign(bitmap);
  finally
    bitmap.Free;
    qrCode.Free;
  end;
end;

procedure TfrmMain.speak(text: string; sync: Boolean = False);
begin
  if sync then
    voice.speak(text, 0) // <- 1 为异步朗读
  else
    voice.speak(text, 1); // <- 1 为异步朗读
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  CnDebugger.StartDebugViewer;
  CnDebugger.DumpToFile := True;
  CnDebugger.TraceEnter('Create');

  TMessagerHelper.initialize(Self.Handle); // 初始化消息对象

  // vlc settings
  player.VLC.Path := TGlobalConfiguration.getInstance.vlcRoot;
  player.EventsEnable;
  player.Align := alNone;
  player.Width := 1;
  player.Height := 1;
  pslbvlcmdlst1.EventsEnable;
  pslbvlcmdlst1.SetPlayModeNormal;
  pslbvlcmdlst1.Clear;

  // web server settings
  httpSrv := TIdHttpServerEx.Create;
  httpSrv.Bindings.Clear;
  Randomize;
{$IFDEF DEBUG}
  with httpSrv.Bindings.Add do
  begin
    IP := '127.0.0.1';
    Port := 80;
  end;
{$ENDIF}
  // random port
  with httpSrv.Bindings.Add do
  begin
    IP := idpwtch1.LocalIP;
{$IFNDEF DEBUG}
    Port := Random(64535) + 1000; // 1000 - 65535
{$ELSE}
    Port := 80;
{$ENDIF}
    idpwtch1.Tag := Port;
    Self.Caption := 'Port:' + IntToStr(Port);
  end;
  // register processor
  {$IFDEF DEBUG}
  httpSrv.registerProcessor(TDebugProcessor.Create);
  {$ENDIF}
  httpSrv.registerProcessor(TPlayControlProcessor.Create);
  httpSrv.registerProcessor(TPlayActionProcessor.Create);
  httpSrv.registerProcessor(TVideoTransferProcessor.Create);
  httpSrv.registerProcessor(TWebSrvProcessor.Create);
  httpSrv.registerProcessor(TUpdateProcessor.Create);

  CnDebugger.TraceMsg('Bind IP:' + idpwtch1.LocalIP);
  CnDebugger.TraceMsg('Bind Port' + IntToStr(idpwtch1.Tag));
  httpSrv.Active := True; // start up

  // 全局路径配置
  if idpwtch1.Tag = 80 then
    httpServerUri := 'http://' + idpwtch1.LocalIP + '/'
  else
    httpServerUri := 'http://' + idpwtch1.LocalIP + ':' + IntToStr(idpwtch1.Tag) + '/';

  CnDebugger.TraceMsg('WebRoot:' + TGlobalConfiguration.getInstance.webRoot);
  CnDebugger.TraceMsg('HttpUri:' + httpServerUri);
  CnDebugger.TraceMsg('VlcPath:' + player.VLC.Path);

  // Quick Code
  img1.Visible := True;
  Self.drawQrCode;
  // tts
  voice := CreateOLEObject('SAPI.SpVoice');
  voice.Volume := 100;

  Self.speak('扫描屏幕二维码，以点播您需要的视频。');
  CnDebugger.TraceLeave('Create');
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if pslbvlcmdlst1.IsPlay then
    pslbvlcmdlst1.Stop;
  httpSrv.Active := False;
  Self.speak('感谢使用', True);
  // selfPlayList.SaveToFile(logPath);
  CnDebugger.TraceMsg('Destroy Application');
  // FreeAndNil(playList);
end;

procedure TfrmMain.playerGetSiteInfo(Sender: TObject; DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
begin
  CnDebugger.TraceEnter('Get Site Info');
  CnDebugger.TraceMsg('InfluenceRect(Width):' + IntToStr(InfluenceRect.Width));
  CnDebugger.TraceMsg('InfluenceRect(Height):' + IntToStr(InfluenceRect.Height));
  CnDebugger.TraceMsg('MousePos:' + IntToStr(MousePos.X) + ' , ' + IntToStr(MousePos.Y));
  CnDebugger.TraceMsg('CanDock:' + BoolToStr(CanDock));
  CnDebugger.TraceLeave('Get Site Info');
end;

procedure TfrmMain.playerMediaPlayerBackward(Sender: TObject);
begin
  CnDebugger.TraceMsg('Backward');
end;

procedure TfrmMain.playerMediaPlayerBuffering(Sender: TObject);
begin
  CnDebugger.TraceMsg('Buffering');
end;

procedure TfrmMain.playerMediaPlayerEncounteredError(Sender: TObject);
begin
  CnDebugger.TraceMsg('EncounteredError');
end;

procedure TfrmMain.playerMediaPlayerEndReached(Sender: TObject);
begin
  CnDebugger.TraceMsg('End Reached');
end;

procedure TfrmMain.playerMediaPlayerEvent(p_event: libvlc_event_t_ptr; data: Pointer);
begin
(*
  CnDebugger.TraceEnter('Player Event');
  CnDebugger.TraceMsg('EventID:' + IntToHex(Ord(p_event.event_type), 4));
  CnDebugger.TracePointer(p_event);
  CnDebugger.TracePointer(data);
  CnDebugger.TraceLeave('Player Event');
  *)
end;

procedure TfrmMain.playerMediaPlayerForward(Sender: TObject);
begin
  CnDebugger.TraceMsg('Forward');
end;

procedure TfrmMain.playerMediaPlayerLengthChanged(Sender: TObject; time: Int64);
begin
  CnDebugger.LogMsg('Length Changed:' + IntToStr(time));
end;

procedure TfrmMain.playerMediaPlayerMediaChanged(Sender: TObject; mrl: string);
begin
  CnDebugger.TraceMsg('Media Changed:' + mrl);
end;

procedure TfrmMain.playerMediaPlayerNothingSpecial(Sender: TObject);
begin
  CnDebugger.TraceMsg('Nothing Special');
end;

procedure TfrmMain.playerMediaPlayerOpening(Sender: TObject);
begin
  CnDebugger.TraceMsg('Opening');
end;

procedure TfrmMain.playerMediaPlayerPausableChanged(Sender: TObject; val: Boolean);
begin
  CnDebugger.TraceMsg('PausableChanged');
end;

procedure TfrmMain.playerMediaPlayerPaused(Sender: TObject);
begin
  CnDebugger.TraceMsg('Paused');
end;

procedure TfrmMain.playerMediaPlayerPlaying(Sender: TObject);
begin
  CnDebugger.TraceMsg('Playing');
end;

procedure TfrmMain.playerMediaPlayerStopped(Sender: TObject);
begin
  CnDebugger.TraceMsg('Stopped');
end;

procedure TfrmMain.playerMediaPlayerVideoOutChanged(Sender: TObject; video_out: Integer);
begin
  CnDebugger.TraceMsg('Video Out Changed:' + IntToStr(video_out));
end;

procedure TfrmMain.pslbvlcmdlst1ItemAdded(Sender: TObject; mrl: WideString; item: Pointer; index: Integer);
begin
  CnDebugger.TraceMsg('PlayList Item Added:' + mrl);
end;

procedure TfrmMain.pslbvlcmdlst1ItemDeleted(Sender: TObject; mrl: WideString; item: Pointer; index: Integer);
begin
  CnDebugger.TraceMsg('PlayList Item Deleted:' + mrl);
end;

procedure TfrmMain.pslbvlcmdlst1NextItemSet(Sender: TObject; mrl: WideString; item: Pointer; index: Integer);
begin
  CnDebugger.TraceMsg('PlayList Next Item Set:' + mrl);
end;

procedure TfrmMain.pslbvlcmdlst1Played(Sender: TObject);
begin
  CnDebugger.TraceMsg('PlayList Played:' + Sender.ClassName);
end;

procedure TfrmMain.pslbvlcmdlst1Stopped(Sender: TObject);
begin
  CnDebugger.TraceMsg('PlayList Stopped:' + Sender.ClassName);
end;

procedure TfrmMain.pslbvlcmdlst1WillAddItem(Sender: TObject; mrl: WideString; item: Pointer; index: Integer);
begin
  CnDebugger.TraceMsg('PlayList Will Add Item:' + mrl);
end;

procedure TfrmMain.pslbvlcmdlst1WillDeleteItem(Sender: TObject; mrl: WideString; item: Pointer; index: Integer);
begin
  CnDebugger.TraceMsg('PlayList Will Delete Item:' + mrl);
end;

end.

