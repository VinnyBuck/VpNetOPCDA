unit VpNetHstCommDriverControlThread;

interface

uses
  Classes, Windows, Forms, Messages, Variants, VpNetDefs, VpNetDADefs,
  VpNetDAClasses, VpNetHst_TLB, ActiveX, VpNetUtils;

type
  TVpNetHstCommDriverControlThread = class(TThread)
  private
    FCS : TRTLCriticalSection;
  public
    constructor Create(CreateSuspended: Boolean; aDriver : TVpNetHstCommDriver);virtual;
    destructor destroy;override;
    procedure Execute; override;
  end;

implementation

constructor TVpNetHstCommDriverControlThread.Create(CreateSuspended: Boolean; aDriver : TVpNetHstCommDriver);
var
  Msg : TMsg;
begin
  inherited Create(CreateSuspended);
  // ������������� ����������� ������
  InitializeCriticalSection(FCS);

  Priority := tpNormal;
  // ����� ������� �� Win32 USER or GDI ��� ��� �������� ������� ��������� ������
  PeekMessage(msg, 0{NULL}, WM_USER, WM_USER, PM_NOREMOVE);

end;

destructor TVpNetHstCommDriverControlThread.destroy;
begin
  // ������� ����������� ������
  DeleteCriticalSection(FCS);
  inherited;
end;

procedure TVpNetHstCommDriverControlThread.Execute;
var
  iRes : Integer;
  CurrMsg : TMsg;
  DATransaction : TVpNetDATransaction;
  v : OleVariant;
  i : Integer;
  trIndex : DWORD;
  hr : HRESULT;
begin
  ReturnValue := S_OK;
  while not Terminated do begin
    try
      // ������ ������� ���������
      while PeekMessage(CurrMsg, 0, WM_DA_MIN, WM_DA_MAX, PM_REMOVE) do begin
//      iRes := Integer(GetMessage(CurrMsg, 0, WM_DA_MIN, WM_DA_MAX));
      // - ���� GetMessage ������� �������� <= 0, ������ �������
//      if iRes <= 0 then begin
        // ���� GetMessage ������� -1, ������ ��������� ������. ������� � E_FAIL
//        if iRes = -1 then
//          ReturnValue := E_FAIL;
//        break;
//      end;
      // - ��������� ����������� ���������
        case CurrMsg.message of
          // ��������� �� ��������� ��������� ���������� �����������������
          WM_DA_HST_DRIVER_ACTIVE_STATE_CHANGED : begin
            // ������ �������������� ��� � ������� ����
            PostMessage(Application.MainForm.Handle, CurrMsg.message, CurrMsg.wParam, CurrMsg.lParam);
          end;
          // ������� �� �������� ����� ���������� (���������� ������ � ������� ��������� ���������)
          CM_DA_HST_DRIVER_SEND: begin
          end;

          // ��������� � ���������� ���������� ���������� (�������� ������ ��������)
          WM_DA_HST_DRIVER_RECIEVE_INTERNAL: begin
          end;

          // ��������� �� ��������� ���������� ����������
          WM_DA_HST_DRIVER_ERROR: ;

          else begin
            // ���������� ����������� ���������
          end;
        end;
      end;

      // ��� ����������� �� ����, ������ ����� ��������� ��� ���,
      // ������������ ������ ����������� ����������
{
      if DATransactionList.Count > 0 then begin
        v := 7; //todo: ������� �������� ��������� ���������� ������ ������
        trIndex := 0;
        while trIndex < DATransactionList.Count do begin
          DATransaction := DATransactionList[trIndex];
          // ���� ��������� ���������� ������� ���������,
          // ������������ ��, � ������ ������� � ���,
          // ��� ��� ������ ��������� ��������� �������� ������
          if DATransaction.State = vndtsWaitingForProcessing then begin
            DATransaction.State := vndtsWaitingForResponse;
//            DATransaction.HST_TID := Driver.Send(DATransaction.OutputData.AsVarArray, v, i);
            DATransaction.HST_TID := i;
          end;
          trIndex := Succ(trIndex);
        end;
      end;
}
    except
      ReturnValue := E_FAIL;
      break;
    end;
  end;
end;

end.
