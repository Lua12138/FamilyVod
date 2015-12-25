unit PasMessagerHelper;

interface

uses
  Winapi.Windows, Winapi.Messages;

type
  TMessagerHelper = class
  private
    class var applicationHandle: HWND;
  public
    class procedure initialize(applicationHandle: HWND);
    class function sendMessage(msg: DWORD; param: DWORD): DWORD; overload;
    class function sendMessage(msg: DWORD; param: string): DWORD; overload;
    class function postMessage(msg: DWORD; param: DWORD): BOOL;
  end;

const
  WM_FORDREAM = WM_USER + 7;
  // FM -> forDream Message
  FM_PALY_STATUS = WM_FORDREAM + 1; // 查询播放状态
  FM_SPEAK = WM_FORDREAM + 2; // 请求tts朗读
  FM_SPEAK_SYNC = WM_FORDREAM + 9; // 同步请求tts
  FM_SPEAK_ASYNC = FM_SPEAK; // 异步请求tts
  FM_PLAY = WM_FORDREAM + 3; // 请求主线程播放
  FM_FULL_SCREEN = WM_FORDREAM + 4; // 请求全屏
  FM_NEXT = WM_FORDREAM + 5; // 下一首
  FM_PAUSE = WM_FORDREAM + 6; // 暂停
  FM_STOP = WM_FORDREAM + 7; // 终止
  FM_SHUTDOWN = WM_FORDREAM + 8; // 关机
  FM_LIST = WM_FORDREAM + 10; // 显示播放列表
  FM_CLOSE_APP = WM_FORDREAM + 11; // 关闭应用 for test
  FM_IPTV = WM_FORDREAM + 12; // IPTV
  // PS -> Play Status
  PS_WAIT_PLAY = 0; // 等待播放
  PS_PLAYING = 1; // 正在播放
  PS_PAUSED = 2; // 暂停
  PS_OTHER = 3; // 其他状态
  PS_PLAYED = 4; // 已播放
  /// ///////////////////

implementation

class procedure TMessagerHelper.initialize(applicationHandle: HWND);
begin
  TMessagerHelper.applicationHandle := applicationHandle;
end;

class function TMessagerHelper.sendMessage(msg: Cardinal;
  param: Cardinal): DWORD;
begin
  Result := Winapi.Windows.sendMessage(applicationHandle, WM_FORDREAM,
    msg, param);
end;

class function TMessagerHelper.sendMessage(msg: Cardinal; param: string): DWORD;
begin
  Result := TMessagerHelper.sendMessage(msg, Cardinal(@param[1]));
end;

class function TMessagerHelper.postMessage(msg: Cardinal;
  param: Cardinal): BOOL;
begin
  Result := Winapi.Windows.postMessage(applicationHandle, WM_FORDREAM,
    msg, param);
end;

end.
