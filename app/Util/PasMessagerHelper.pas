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
  FM_PALY_STATUS = WM_FORDREAM + 1; // ��ѯ����״̬
  FM_SPEAK = WM_FORDREAM + 2; // ����tts�ʶ�
  FM_SPEAK_SYNC = WM_FORDREAM + 9; // ͬ������tts
  FM_SPEAK_ASYNC = FM_SPEAK; // �첽����tts
  FM_PLAY = WM_FORDREAM + 3; // �������̲߳���
  FM_FULL_SCREEN = WM_FORDREAM + 4; // ����ȫ��
  FM_NEXT = WM_FORDREAM + 5; // ��һ��
  FM_PAUSE = WM_FORDREAM + 6; // ��ͣ
  FM_STOP = WM_FORDREAM + 7; // ��ֹ
  FM_SHUTDOWN = WM_FORDREAM + 8; // �ػ�
  FM_LIST = WM_FORDREAM + 10; // ��ʾ�����б�
  FM_CLOSE_APP = WM_FORDREAM + 11; // �ر�Ӧ�� for test
  // PS -> Play Status
  PS_WAIT_PLAY = 0; // �ȴ�����
  PS_PLAYING = 1; // ���ڲ���
  PS_PAUSED = 2; // ��ͣ
  PS_OTHER = 3; // ����״̬
  PS_PLAYED = 4; // �Ѳ���
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
