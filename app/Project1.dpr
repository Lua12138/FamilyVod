program Project1;

uses
  Vcl.Forms,
  PasMainForm in 'PasMainForm.pas' {frmMain},
  PasLibVlcClassUnit in 'LibVlcEx\PasLibVlcClassUnit.pas',
  PasLibVlcPlayerUnit in 'LibVlcEx\PasLibVlcPlayerUnit.pas',
  PasLibVlcUnit in 'LibVlcEx\PasLibVlcUnit.pas',
  CnDebug in 'CnDebug\CnDebug.pas',
  CnPropSheetFrm in 'CnDebug\CnPropSheetFrm.pas' {CnPropSheetForm},
  PasQrCode in 'Util\PasQrCode.pas',
  PasCrcHelper in 'Util\PasCrcHelper.pas',
  PasGlobalConfiguration in 'Util\PasGlobalConfiguration.pas',
  PasMessagerHelper in 'Util\PasMessagerHelper.pas',
  PasIdHttpServerEx in 'IdHttpServerEx\PasIdHttpServerEx.pas',
  PasPlayActionProcessor in 'IdHttpServerEx\PasPlayActionProcessor.pas',
  PasPlayControlProcessor in 'IdHttpServerEx\PasPlayControlProcessor.pas',
  PasRequestProcessor in 'IdHttpServerEx\PasRequestProcessor.pas',
  PasVideoTransferProcessor in 'IdHttpServerEx\PasVideoTransferProcessor.pas',
  PasWebSrvProcessor in 'IdHttpServerEx\PasWebSrvProcessor.pas',
  PasUpdateProcessor in 'IdHttpServerEx\PasUpdateProcessor.pas',
  PasDebugProcessor in 'IdHttpServerEx\PasDebugProcessor.pas',
  PasLibVlcMediaMeta in 'LibVlcEx\PasLibVlcMediaMeta.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.