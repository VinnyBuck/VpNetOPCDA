program VpNetDA;

{%File 'C:\Program Files\OPC Foundation\Core Components 2.00\Include\opcda.idl'}

uses
  Forms,
  Windows,
  SysUtils,
  main in 'MAIN.PAS' {Form1},
  VpNetDA_TLB in 'VpNetDA_TLB.pas',
  VpNetOPCDA_Impl in 'VpNetOPCDA_Impl.pas' {VpNetOPCDA: CoClass},
  VpNetDAErrors in 'VpNetDAErrors.pas',
  VpNetDARegDereg in 'VpNetDARegDereg.pas',
  VpNetOPCGroup_Impl in 'VpNetOPCGroup_Impl.pas' {VpNetOPCGroup: CoClass},
  VpNetDAClasses in 'VpNetDAClasses.pas',
  VpNetDARDM_Impl in 'VpNetDARDM_Impl.pas' {VpNetDARDM: TRemoteDataModule} {VpNetDARDM: CoClass},
  VpNetDAServerCore in 'VpNetDAServerCore.pas',
  VpNetDADefs in 'VpNetDADefs.pas',
  VpNetOPCItem_Impl in 'VpNetOPCItem_Impl.pas',
  VpNetOPCGroupList in 'VpNetOPCGroupList.pas',
  uEnumOPCItemAttributes in '..\..\units\uEnumOPCItemAttributes.pas',
  uOPCUtils in '..\..\units\uOPCUtils.pas',
  VpNetOPCGroupControlThread in 'VpNetOPCGroupControlThread.pas',
  VpNetDAAbout in 'VpNetDAAbout.pas' {frmVpNetDAAbout},
  VpNetModBus in '..\common\VpNetModbus.pas',
  VpNetHstDriverConnection in 'VpNetHstDriverConnection.pas',
  OPCDA_TLB in '..\VpNetClient\OPCDA_TLB.pas',
  VpNetDADebug in 'VpNetDADebug.pas',
  VpNetUtils in '..\COMMON\VpNetUtils.pas',
  GUtils in '..\..\units\GUARDANT\gutils.pas',
  VpNetDAConnectionsControlThread in 'VpNetDAConnectionsControlThread.pas',
  VpNetHst_TLB in 'VpNetHst_TLB.pas';

{$R *.TLB}

{$R *.res}

begin // su01


  try
    Application.Initialize;
  except on e : Exception do
    PostLogRecordAddMsgNow(70427, e.HelpContext, -1, -1, e.Message);
  end;

  try
//    if not CanStart('VPNETDA.EXE,VpNetDA_Config.exe') then
    if not CanStart('VPNETDA.EXE') then
      exit;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70031, e.HelpContext, -1, -1, e.Message);
      exit;
    end;
  end;

  try
    VpNetDADebugInit;
  except on e: Exception do
    PostLogRecordAddMsgNow(70012, e.HelpContext, -1, -1, e.Message);
  end;

  try
    Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmVpNetDAAbout, frmVpNetDAAbout);
  except on e: Exception do
    PostLogRecordAddMsgNow(70008, e.HelpContext, -1, -1, e.Message);
  end;

  try
    ServerCore := TVpNetDAServerCore.Create;
    PostLogRecordAddMsgNow(70007, -1, -1, S_OK, 'Запуск ядра', llGlobalEvents);
  except on e: Exception do
    PostLogRecordAddMsgNow(70004, e.HelpContext, -1, -1, e.Message);
  end;

  try
    Application.Run;
  except on e: Exception do
    PostLogRecordAddMsgNow(70009, e.HelpContext, -1, -1, e.Message);
  end;

  // Останов ядра
  try
    ServerCore.free;
    PostLogRecordAddMsgNow(70005, -1, -1, S_OK, 'Останов ядра', llGlobalEvents);
  except on e: Exception do
    PostLogRecordAddMsgNow(70006, e.HelpContext, -1, -1, e.Message, llErrors);
  end;
                      
  try
    Application.ProcessMessages;
  except on e :Exception do
    PostLogRecordAddMsgNow(70011, e.HelpContext, -1, -1, e.Message, llErrors);
  end;

  try
    FLogStream.Free;
    DeleteCriticalSection(DebugCS);
  except on e: Exception do
    PostLogRecordAddMsgNow(70010, e.HelpContext, -1, -1, e.Message);
  end;

end.
