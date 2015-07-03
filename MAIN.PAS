unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ImgList, ActiveX, RzTray, RzButton, RzStatus, VpNetDADefs,
  StdCtrls, Menus, VpNetDA_TLB, RzPanel;

type
  TForm1 = class(TForm) // su01
    TrayIcon: TRzTrayIcon;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    miServer: TMenuItem;
    N2: TMenuItem;
    miServerRegister: TMenuItem;
    miServerUnregister: TMenuItem;
    pmTray: TPopupMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    RzStatusBar1: TRzStatusBar;
    RzGlyphStatus1: TRzGlyphStatus;
    gsDongle: TRzGlyphStatus;
    ImageList2: TImageList;
    mProcessInfo: TMemo;
    gsClientCount: TRzStatusPane;
    gsGroupCount: TRzStatusPane;
    gsTID: TRzStatusPane;
    procedure FormShow(Sender: TObject); // su01
    procedure miServerRegisterClick(Sender: TObject); // su01
    procedure miServerUnregisterClick(Sender: TObject); // su01
    procedure miServerClick(Sender: TObject); // su01
    procedure N2Click(Sender: TObject); // su01
    procedure TrayIconLButtonDblClick(Sender: TObject); // su01
    procedure FormClose(Sender: TObject; var Action: TCloseAction); // su01
    procedure N4Click(Sender: TObject); // su01
  private
    FCloseAction : TCloseAction;
    ClientCount : Integer;
    GroupCount : Integer;
    LastDATID : Cardinal;
  public
    constructor Create(AOwner: TComponent); override; // su01
    procedure WndProc(var Message: TMessage); override; // su01
    procedure UpdateState(); // su01
  end;

var
  Form1: TForm1;

implementation
{$R *.dfm}

uses ComCat, VpNetDARegDereg, VpNetDAAbout, VpNetDAServerCore, VpNetDefs,
  VpNetDADebug, StrUtils;

const
 serverName = 'VpNet.DA';


constructor TForm1.Create(AOwner: TComponent);
begin
  try
    inherited;
  except on e : Exception do
    PostLogRecordAddMsgNow(70040, e.HelpContext, -1, -1, e.Message);
  end;

  try
    FCloseAction := caNone;
    ClientCount := 0;
    GroupCount := 0;
    LastDATID := 0;
    mProcessInfo.Lines.Clear;
  except on e : Exception do
    PostLogRecordAddMsgNow(70041, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  try
    UpdateState();
  except on e : Exception do
    PostLogRecordAddMsgNow(70032, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TForm1.WndProc(var Message: TMessage);
var
  s : String;
begin
  try
    if (Message.Msg >= WM_DA_MIN) and (Message.Msg <= WM_DA_MAX) then begin
      with Message do begin
        case Msg of
          CM_DA_UPDATE_STATE: try
            UpdateState();
          except on e : Exception do
            PostLogRecordAddMsgNow(70043, e.HelpContext, -1, -1, e.Message);
          end;

          WM_DA_HIDE: try
            Hide;
          except on e : Exception do
            PostLogRecordAddMsgNow(70044, e.HelpContext, -1, -1, e.Message);
          end;

          WM_DA_SERVER_CREATED: try
            // При создании нового серверного объекта, ...
            ClientCount := Succ(ClientCount);
            // Обновляем внешний вид сервера
            UpdateState();
          except on e : Exception do
            PostLogRecordAddMsgNow(70047, e.HelpContext, -1, -1, e.Message);
          end;

          WM_DA_SERVER_DESTROING: try
            // При при удалении серверного объекта, ...
            ClientCount := Pred(ClientCount);
            // Обновляем внешний вид сервера
            UpdateState();
          except on e : Exception do
            PostLogRecordAddMsgNow(70048, e.HelpContext, -1, -1, e.Message);
          end;

          WM_DA_GROUP_CREATED: try
            GroupCount := GroupCount + 1;
            UpdateState;
          except on e : Exception do
            PostLogRecordAddMsgNow(70049, e.HelpContext, -1, -1, e.Message);
          end;

          WM_DA_GROUP_DESTROYED: try
            if GroupCount > 0 then
              GroupCount := GroupCount - 1;
            UpdateState;
          except on e : Exception do
            PostLogRecordAddMsgNow(70050, e.HelpContext, -1, -1, e.Message);
          end;

          WM_DA_NEW_TID: try
            LastDATID := LParam;
            UpdateState;
          except on e : Exception do
            PostLogRecordAddMsgNow(70051, e.HelpContext, -1, -1, e.Message);
          end;

          WM_DA_LICENSE_STATUS: try
            if LParam = S_OK then begin
              gsDongle.ImageIndex := 0;
            end else begin
              gsDongle.ImageIndex := 1;
            end;
          except on e : Exception do
            PostLogRecordAddMsgNow(70052, e.HelpContext, -1, -1, e.Message);
          end;

          CM_DW_PROCESS_INFO_DISPLAY: try
            with PVpNetDAProcessInfoDataStruct(pointer(WPARAM))^ do begin
              s := DateTimeToStr(dt) + ';' + 'eID:' + IntToStr(VDAE_ID) + ';';
              s := s + Desc + '.';
              if mProcessInfo.Lines.Count = 100 then
                mProcessInfo.Lines.Delete(0);
              mProcessInfo.Lines.Add(s);
              mProcessInfo.Text := LeftStr(mProcessInfo.Text, length(mProcessInfo.Text) - 1);
            end;
            CoTaskMemFree(PVpNetDAProcessInfoDataStruct(pointer(WPARAM))^.Desc);
            CoTaskMemFree(pointer(WParam));
          except on e : Exception do
            PostLogRecordAddMsgNow(70054, e.HelpContext, -1, -1, e.Message);
          end;

          else begin
            ServerCore.Perform(Message);
          end;
        end;
      end;
      // Ретранслируем сообщения, спицифичные для сервера в ServerCore
  //    ServerCore.Perform(Message);
    end else begin
      // Иначе выполняем унаследованные функции
      inherited;
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70042, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TForm1.UpdateState();
begin
  try
    gsClientCount.Caption := 'Клиенты:' + IntToStr(ClientCount);
    gsGroupCount.Caption := 'Группы:' + IntToStr(GroupCount);
    gsTID.Caption := 'TID:' + IntToStr(LastDATID);
  except on e : Exception do
    PostLogRecordAddMsgNow(70055, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TForm1.miServerRegisterClick(Sender: TObject);
var
  hr : HRESULT;
begin
  try
    hr := RegisterTheServer(serverName);
    if hr = S_OK then begin
      showMessage('Сервер успешно зарегистрирован' + #13#10 +
                  'в категории OPC DataAccess Server 3.0');
    end else begin
      PostLogRecordAddMsgNow(70417, hr, -1, -1, '');
      showMessage('Ошибка регистрации сервера');
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70033, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TForm1.miServerUnregisterClick(Sender: TObject);
var
  hr : HRESULT;
begin
  try
    hr := UnRegisterTheServer(serverName);
    if hr = S_OK then begin
      showMessage('Регистрация сервера в категории' + #13#10 +
                  'OPC DataAccess Server 3.0' + #13#10 +
                  'успешно отменена');
    end else begin
      PostLogRecordAddMsgNow(70418, hr, -1, -1, '');
      showMessage('Ошибка отмены регистрации сервера');
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70034, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TForm1.miServerClick(Sender: TObject);
var
  sl : TStringList;
  bRegistered : boolean;
begin
  try
    // Проверка регистрации сервера
    sl := TStringList.Create;
    try
  //    if CheckServerRegistration(CLASS_VpNetOPCDA, bRegistered) = S_OK then begin
  //      miServerRegister.Enabled := not bRegistered;
  //      miServerUnregister.Enabled := bRegistered;
  //    end else begin
  //      miServerRegister.Enabled := false;
  //      miServerUnregister.Enabled := false;
  //    end;
    finally
      sl.Free;
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70035, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
  try
    if not frmVpNetDAAbout.Visible then
      frmVpNetDAAbout.ShowModal;
  except on e : Exception do
    PostLogRecordAddMsgNow(70036, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TForm1.TrayIconLButtonDblClick(Sender: TObject);
begin
  try
    Show;
  except on e : Exception do
    PostLogRecordAddMsgNow(70037, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
//    Action := FCloseAction;
//    PostMessage(Application.MainForm.Handle, WM_DA_HIDE, 0, 0);
  except on e : Exception do
    PostLogRecordAddMsgNow(70038, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TForm1.N4Click(Sender: TObject);
begin
  try
    FCloseAction := caFree;
    Close;
  except on e : Exception do
    PostLogRecordAddMsgNow(70039, e.HelpContext, -1, -1, e.Message);
  end;
end;

end.
