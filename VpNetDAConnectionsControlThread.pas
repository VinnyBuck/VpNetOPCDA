unit VpNetDAConnectionsControlThread;

interface

uses Classes, Windows, ActiveX, SysUtils, Forms;

type

TVpNetDAConnectionsControlThread = class(TThread)
private
  FCheckIntervalMS : Integer;
  FdtCheckSendTime : TDateTime;
protected
  procedure Execute; override; // su01
public
  constructor Create(aCheckIntervalMS : Integer); // su01
end;

implementation

uses VpNetDADebug, VpNetDADefs;

procedure TVpNetDAConnectionsControlThread.Execute;
begin
  while not Terminated do try
    if (now - FdtCheckSendTime) > (FCheckIntervalMS / 86400000) then begin
      FdtCheckSendTime := now;
      PostMessage(Application.MainForm.Handle, CM_DA_TRANSACTION_CHECK, 0, 0);
    end;
// 2.04.2010
//    sleep(1);
    sleep(10);
///2.04.2010
  except on e : Exception do
    PostLogRecordAddMsgNow(70019, e.HelpContext, -1, -1, e.Message);
  end;
end;

constructor TVpNetDAConnectionsControlThread.Create(aCheckIntervalMS : Integer);
begin
  try
    inherited create(true);
  except on e : Exception do
    PostLogRecordAddMsgNow(70415, e.HelpContext, aCheckIntervalMS, -1, e.Message);
  end;
  try
    FCheckIntervalMS := aCheckIntervalMS;
    FdtCheckSendTime := 0;
  except on e : Exception do
    PostLogRecordAddMsgNow(70416, e.HelpContext, aCheckIntervalMS, -1, e.Message);
  end;
end;

end.
