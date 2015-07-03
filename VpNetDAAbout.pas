unit VpNetDAAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, RzStatus;

type
  TfrmVpNetDAAbout = class(TForm)
    Panel1: TPanel;
    lbProductName: TLabel;
    lbVersion: TLabel;
    VerInfo: TRzVersionInfo;
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState); // su01
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); // su01
    procedure Panel1DblClick(Sender: TObject); // su01
    procedure FormShow(Sender: TObject); // su01
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVpNetDAAbout: TfrmVpNetDAAbout;

implementation

uses VpNetDADebug;

{$R *.dfm}

procedure TfrmVpNetDAAbout.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  try
    Close();
  except on e: Exception do
    PostLogRecordAddMsgNow(70428, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TfrmVpNetDAAbout.FormMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  try
    Close();
  except on e: Exception do
    PostLogRecordAddMsgNow(70429, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TfrmVpNetDAAbout.Panel1DblClick(Sender: TObject);
begin
  try
    Close();
  except on e: Exception do
    PostLogRecordAddMsgNow(70430, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TfrmVpNetDAAbout.FormShow(Sender: TObject);
begin
  try
    lbProductName.Caption := VerInfo.ProductName;
    if Width < lbProductName.ClientWidth + lbProductName.Left * 2 then
      Width := lbProductName.ClientWidth + lbProductName.Left * 2;

    lbVersion.Caption := 'Версия ' + VerInfo.ProductVersion;
  except on e: Exception do
    PostLogRecordAddMsgNow(70431, e.HelpContext, -1, -1, e.Message);
  end;
end;

end.
