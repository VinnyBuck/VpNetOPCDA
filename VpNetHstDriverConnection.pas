unit VpNetHstDriverConnection;

{$I 'VpNetDADebugDefs.pas'}

interface

uses Windows, Classes, SysUtils, Forms, Messages, ActiveX, DB, Math, Variants,
  OPCDA, OPCerror, VpNetHst_TLB, VpNetDefs, VpNetDADefs, VpNetClasses, VpNetDAClasses,
  VpNetUtils, VpNetModbus, VpNetDADebug;

type
// �����, ���������� ��������� �������� ���������� � ��������� ����-�������
TVpNetHstDriverConnection = class // su01
private
  FCS : TRTLCriticalSection; // ����������� ������
  FState : TVpNetHstDriverConnectionState;
  function GetState : TVpNetHstDriverConnectionState;
  procedure SetState(aState : TVpNetHstDriverConnectionState); // su01
  procedure HstCommDriverPropValueChanged(ASender: TObject; vPropId: OleVariant; vPropValue: OleVariant); // su01
  procedure HstCommDriverRecieve(ASender: TObject; Data: OleVariant; TID: Integer); // su01
  procedure HstCommDriverError(ASender: TObject; TID: Integer; ERROR_CODE: Integer; Data: OleVariant); // su01
  procedure HstCommDriverStartTransaction(ASender: TObject; TID: Integer); // su01
public
  DriverId : DWORD;
  Driver: TVpNetHstCommDriver;
  RefCount : DWORD;
  DATransactionItemList : TVpNetDATransactionItemList; // ������� ����������
  Hst_TID : DWORD; // ������� ���������� Hst-�������, �������������� ������ �����������
// 16.10.2009
  Hst_Transaction_Send_Time_MS : TDateTime;
  HstDriverMaxAnswerTimeMS : Integer;
///16.10.2009
//  {8.02.2009}
//  Hst_Transaction_Exists : Boolean; // ������� ������� ���������� ����-�������
//  {/8.02.2009}
  Hst_ProtocolId : Integer; // �������� ���������� Hst-�������
  Hst_OutputData : TByteBuffer; // �������� ������ (������) ���������� Hst-�������
  Hst_InputData : TByteBuffer; // ������� (��������) ������ ���������� Hst-�������
  Hst_SupposedInputDataSize : DWORD; // ��������� ������ ������
  property State : TVpNetHstDriverConnectionState read GetState write SetState;
  constructor Create(sRemoteMachineName : String; aDriverId : Integer); // su01
  destructor Destroy; override; // su01
  procedure Lock; // su01
  procedure Unlock; // su01
  procedure AddTransactionItems(trList : TVpNetDATransactionItemList); // su01
  function AreTransactionItemsCompartible(tr1, tr2 : TVpNetDATransactionItem) : boolean; // su01
  procedure Send; // su01
// 6.04.2010
//  procedure Recieve(var aHstAnswerData: PVpNetHSTAnswerData); // su01
  procedure Recieve(aHstAnswerData: PVpNetHSTAnswerData); // su01
///6.04.2010
  procedure ErrorWithData(aHstTID : DWORD; aHstErrorData: PVpNetHSTErrorData); // su01
// 30.11.2011
  procedure Error(aHstTID : DWORD; aErrorCode : HRESULT); // su01
///30.11.2011
end;

TVpNetHstDriverConnectionList = class(TList)
private
  function Get(Index: Integer): TVpNetHstDriverConnection;
  procedure Put(Index: Integer; const Value: TVpNetHstDriverConnection);
public
  property Items[Index: Integer]: TVpNetHstDriverConnection read Get write Put; default;
  function FindByDriverId(aDriverId : DWORD) : TVpNetHstDriverConnection;
  function FindByCurrHstTID(aHstCurrTID : DWORD) : TVpNetHstDriverConnection;
end;

TVpNetHstDriverConnectionThreadList = class
private
  FList: TVpNetHstDriverConnectionList;
  FLock: TRTLCriticalSection;
public
  constructor Create;
  destructor Destroy; override;
  function  LockList: TVpNetHstDriverConnectionList;
  procedure UnlockList;
{
  procedure Add(aConnection : TVpNetHstDriverConnection);
  procedure Remove(aConnection : TVpNetHstDriverConnection);
  procedure Clear;
}
end;

implementation

uses VpNetOPCGroup_Impl, VpNetOPCGroupControlThread, VpNetDAServerCore,
  VpNetDARDM_Impl, TypInfo;

function TVpNetHstDriverConnection.GetState: TVpNetHstDriverConnectionState;
begin
  Lock;
  try
    result := FState;
  finally
    Unlock;
  end;
end;

procedure TVpNetHstDriverConnection.SetState(aState : TVpNetHstDriverConnectionState);
begin
  try
    Lock;
    try
      FState := aState;
    finally
      Unlock;
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70394, e.HelpContext, Integer(aState), -1, e.Message, llErrors);
  end;
end;

procedure TVpNetHstDriverConnection.HstCommDriverPropValueChanged(ASender: TObject; vPropId: OleVariant; vPropValue: OleVariant);
begin
  try
    PostLogRecordAddMsgNow(70917, -1, -1, -1, 'HstDriver ������ Callback-������� OnPropValueChanged()', llDebug);
  except on e : Exception do
    PostLogRecordAddMsgNow(70918, e.HelpContext, -1, -1, e.Message, llErrors);
  end;
end;

procedure TVpNetHstDriverConnection.HstCommDriverRecieve(ASender: TObject; Data: OleVariant; TID: Integer);
var
  pAnswerData : PVpNetHSTAnswerData;
  hr : HRESULT;
  DataSize : Integer;
  iDataSize : Integer;
begin
  try
    PostLogRecordAddMsgNow(70661, TID, -1, -1, 'HstDriver ������ Callback-������� OnRecieve()', llDebug);
// 02.04.2010
    if not VarIsArray(Data) then begin
      PostLogRecordAddMsgNow(70411, -1, -1, -1, '');
    end;
///02.04.2010
    // �������� ������ ��� ����������� ��������� ������ ������
    GetMem(pAnswerData, sizeof(TVpNetHSTAnswerData));

    pAnswerData^.HstAnswerData := nil;
    pAnswerData^.HstAnswerDataSize := 0;
    iDataSize := pAnswerData^.HstAnswerDataSize;
    hr := VarArrayToMemoryBuffer(Data, pAnswerData^.HstAnswerData, iDataSize);
    pAnswerData^.HstAnswerDataSize := iDataSize;
    PostLogRecordAddMsgNow(70847, Integer(pAnswerData), pAnswerData^.HstAnswerDataSize, iDataSize, '', llDebug);

// 02.04.2010

    if not assigned(pAnswerData^.HstAnswerData) then begin
      PostLogRecordAddMsgNow(70412, -1, -1, -1, '');
    end;
///02.04.2010
    if hr = S_OK then begin
      // �������� ��������� � ���, ��� ���������� ���������, � �������� � ��� ���� ����������
  //    PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_RECIEVE, Integer(HIGH(DWORD)), Integer(pAnswerData));
      PostLogRecordAddMsgNow(70848, Integer(pAnswerData), Integer(pAnswerData^.HstAnswerData), Integer(pAnswerData.HstAnswerDataSize), '', llDebug);
      PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_RECIEVE, TID, Integer(pAnswerData));
    end else begin
      // ������� ������ � �������� ��������� � ���, ��� � Hst-���������� ����������� � ������� E_FAIL
      FreeMem(pAnswerData, sizeof(TVpNetHSTAnswerData));
      PostLogRecordAddMsgNow(70413, hr, TID, -1, '');
      PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, TID, E_FAIL);
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70393, e.HelpContext, TID, -1, e.Message);
  end;
end;

procedure TVpNetHstDriverConnection.HstCommDriverError(ASender: TObject; TID: Integer; ERROR_CODE: Integer; Data: OleVariant); // su01
var
  pErrorData : PVpNetHSTErrorData;
  iDataSize : Integer;
  hr : HRESULT;
begin
  try
//30.11.2011
    PostLogRecordAddMsgNow(70916, TID, ERROR_CODE, -1, 'HstDriver ������ Callback-������� OnError()', llDebug);
    // �������� ������ ��� ������ ���������� ������
    GetMem(pErrorData, sizeof(TVpNetHSTErrorData));
    pErrorData^.ErrorCode := ERROR_CODE;
    pErrorData^.HstAnswerData := nil;
    pErrorData^.HstAnswerDataSize := 0;
    iDataSize := pErrorData^.HstAnswerDataSize;
    hr := VarArrayToMemoryBuffer(Data, pErrorData^.HstAnswerData, iDataSize);
    pErrorData^.HstAnswerDataSize := iDataSize;
    PostLogRecordAddMsgNow(70849, Integer(pErrorData), pErrorData^.HstAnswerDataSize, iDataSize, 'errorCode = '+ IntToStr(pErrorData^.ErrorCode), llDebug);

//    PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, TID, ERROR_CODE);
    PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, TID, Integer(pErrorData));
///30.11.2011
  except on e : Exception do
    PostLogRecordAddMsgNow(70392, e.HelpContext, TID, ERROR_CODE, e.Message);
  end;
end;

procedure TVpNetHstDriverConnection.HstCommDriverStartTransaction(ASender: TObject; TID: Integer);
begin
    PostLogRecordAddMsgNow(70924, TID, -1, -1, 'HstDriver ������ Callback-������� OnStartTransaction()', llDebug);
end;

constructor TVpNetHstDriverConnection.Create(sRemoteMachineName : String; aDriverId : Integer);
var
  vPropId, vPropValue : OleVariant;
  ds : TDataset;
begin
  try
    inherited Create;
  except on e : Exception do
    PostLogRecordAddMsgNow(70388, e.HelpContext, -1, -1, e.Message);
  end;

  try
    // ������������� ����������� ������
    InitializeCriticalSection(FCS);

    // �������� ������� ����������
    DATransactionItemList := TVpNetDATransactionItemList.Create;

    // �������� ���������� ����������
    Hst_ProtocolId := 0;

    // �������� ��������� (����������) ������ ������ ��� ���������� Hst-�������
    Hst_OutputData := TByteBuffer.Create;
    // �������� �������� (���������) ������ ������ ��� ���������� Hst-�������
    Hst_InputData := TByteBuffer.Create;

    // ��������� ������ ������ ���� ����������
    Hst_SupposedInputDataSize := 0;

    // ������� ���������� �� ���������� ��� ��� �� ���� ���������� ��� �� ��������
  //  {8.02.2009}
    Hst_TID := 0;
  //  Hst_Transaction_Exists := false;
  //  {/8.02.2009}
  // 16.10.2009
    Hst_Transaction_Send_Time_MS := 0;
  ///16.10.2009

    // ���������� �������������� ����������������� ��������
    DriverId := aDriverId;
    // �������� � ������������� ��������
    Driver := TVpNetHstCommDriver.Create(Application);
    // ���������� ������������ �������
    Driver.OnPropValueChanged := HstCommDriverPropValueChanged;
    Driver.OnRecieve := HstCommDriverRecieve;
    Driver.OnError := HstCommDriverError;
    Driver.OnStartTransaction := HstCommDriverStartTransaction;
    // �������������
    Driver.RemoteMachineName := sRemoteMachineName;
  //Driver.DefaultInterface._AddRef;

  ///////////
    Driver.SetCommDriverId(aDriverId);
  ////////
    // C���������
    Driver.Connect;
    vPropId := 'MaxAnswerTimeMS';
    Driver.GetPropValue('DriverMaxAnswerTimeMS', vPropValue);
    if not VarIsNull(vPropValue) then begin
      try
        HstDriverMaxAnswerTimeMS := vPropValue;
      except on e : Exception do
        begin
          HstDriverMaxAnswerTimeMS := 15000; // 15 ���
          PostLogRecordAddMsgNow(70390, e.HelpContext, -1, -1, e.Message);
        end;
      end;
    end else begin
      HstDriverMaxAnswerTimeMS := 15000; // 15 ���
    end;

    // ����� ���������� ������
    RefCount := 0;

  except on e : Exception do
    PostLogRecordAddMsgNow(70389, e.HelpContext, -1, -1, e.Message);
  end;
end;

{04.07.2006}

destructor TVpNetHstDriverConnection.Destroy;
var
  DATransactionItem : TVpNetDATransactionItem;
  TrCount  : Integer;
begin
  try
    // ������������� ��������� ���������� "��������"
    State := vncsDestroing;

    if assigned(DATransactionItemList) then begin
      // ���������� ��������� ��������� ���������� ������������� DA-����������
      TrCount := 1;
      // ���� ���� �������� ����������, ���������� �� ������� � �������� �� ������
      while TrCount > 0 do begin
        Lock;
        try
          if DATransactionItemList.count > 0 then begin
            DATransactionItem := DATransactionItemList[0];
            DATransactionItem.SetError;
            DATransactionItemList.Remove(DATransactionItem);
          end;
          TrCount := DATransactionItemList.count;
        finally
          Unlock;
        end;
        Sleep(1);
        Application.ProcessMessages;
      end;
        //todo: �������� �������
  //      DATransactionItem := DATransactionItemList[0];
  //      if Assigned(DATransactionItem.InputData) then
  //        DATransactionItem.InputData.Size := 0; // �������� ������ ���
  //      if Assigned(DATransactionItem.evtProcessed) then
  //        DATransactionItem.evtProcessed.SetEvent; // ������������� ������� ���������� ��������� ����������
  //      PostThreadMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, 0, E_ABORT);
      DATransactionItemList.Free;
    end;
    Hst_InputData.Free;
    Hst_OutputData.Free;

    // �������� �������� � ����������������� ������ ����������
  //  Driver.Close;
    Driver.Disconnect;
    Driver.Free;

    // ������� ����������� ������
    DeleteCriticalSection(FCS);
  except on e : Exception do
    PostLogRecordAddMsgNow(70386, e.HelpContext, -1, -1, e.Message);
  end;

  try
    inherited;
  except on e : Exception do
    PostLogRecordAddMsgNow(70387, e.HelpContext, -1, -1, e.Message);
  end;
end;
{
destructor TVpNetHstDriverConnection.destroy;
var
  tr : TVpNetDATransactionItem;
  there_are_executing_DATransaction_items : boolean;
begin
  if assigned(DATransactionItemList) then begin
    // ���� ���� �������� ����������, ���� �� ����������
    there_are_executing_DATransaction_items := true;
    while there_are_executing_DATransaction_items do begin
      Lock;
      try
        there_are_executing_DATransaction_items := (DATransactionItemList.Count > 0);
      finally
        Unlock;
      end;
    end;
    DATransactionItemList.Free;
  end;

  Hst_InputData.Free;
  Hst_OutputData.Free;

  // �������� �������� � ����������������� ������ ����������
//  Driver.Close;
  Driver.Disconnect;
  Driver.Free;

  // ������� ����������� ������
  DeleteCriticalSection(FCS);
  inherited;
end;
}
{/04.07.2006}
procedure TVpNetHstDriverConnection.Lock;
begin
  try
    EnterCriticalSection(FCS);
  except on e : Exception do
    PostLogRecordAddMsgNow(70385, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TVpNetHstDriverConnection.Unlock;
begin
  try
    LeaveCriticalSection(FCS);
  except on e : Exception do
    PostLogRecordAddMsgNow(70384, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TVpNetHstDriverConnection.AddTransactionItems(trList : TVpNetDATransactionItemList);
var
  NewTr : TVpNetDATransactionItem;
  trItemX : TVpNetDATransactionItem;
  ExistTrIndex, NewTrIndex : Integer;
  DTimeMS : int64;
  NewTrMaxRespMomentFT : TFileTime;
  XTrMaxRespMomentFT : TFileTime;
begin
  try
    Lock;
    try

      if not assigned(trList) then begin
        PostLogRecordAddMsgNow(70400, Integer(trList), -1, -1, '');
        exit;
      end;

      // ��������� ������ ����������, �������� �� ��� ���������
      // � ������ � ������ ���������� ����������
      NewTrIndex := 0;
      while NewTrIndex < trList.Count do try
        // �������� ����������� ����������
        try
          NewTr := trList[NewTrIndex];
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70401, e.HelpContext, NewTrIndex, -1, e.Message);
            continue;
          end;
        end;

        // �������� �� ��� ���������
        NewTr.DA_State := vndtsWaitingForProcessing;
        // ��������� � ������ ����������
        // ��� ����� �������� �� ������ ������������ ����������,
        // � ������� ����� ����� ���������� �� ������������� ������� ������

        if not assigned(DATransactionItemList) then begin
          PostLogRecordAddMsgNow(70402, Integer(DATransactionItemList), -1, -1, '');
          continue;
        end;

        try
          ExistTrIndex := 0;
          while ExistTrIndex < DATransactionItemList.Count do begin
            // ������� ������� ����� ������������ �������� ������ ����� ����������
            // � ��������� ������������ ����������
// 01.04.20010
//            DTimeMS := FileTimeMinusFileTime(NewTr.DA_MaxResponseMoment, DATransactionItemList[ExistTrIndex].DA_MaxResponseMoment) div 10000;
            // ��������� ���������� �������� �� ������ ���������

            try
              trItemX := DATransactionItemList[ExistTrIndex];
            except on e : Exception do begin
                trItemX := nil;
                PostLogRecordAddMsgNow(70408, e.HelpContext, Integer(trItemX), -1, e.Message);
              end;
            end;

            try
              NewTrMaxRespMomentFT := NewTr.DA_MaxResponseMoment;
            except on e : Exception do begin
                NewTrMaxRespMomentFT.dwLowDateTime := 0;
                NewTrMaxRespMomentFT.dwHighDateTime := 0;
                PostLogRecordAddMsgNow(70409, e.HelpContext, Integer(trItemX), -1, e.Message);
              end;
            end;

            try
              XTrMaxRespMomentFT := trItemX.DA_MaxResponseMoment;
            except on e : Exception do begin
                XTrMaxRespMomentFT.dwLowDateTime := 0;
                XTrMaxRespMomentFT.dwHighDateTime := 0;
                PostLogRecordAddMsgNow(70410, e.HelpContext, Integer(trItemX), -1, e.Message);
              end;
            end;

            try
              DTimeMS := FileTimeMinusFileTimeMS(NewTrMaxRespMomentFT, XTrMaxRespMomentFT);
            except on e : Exception do begin
                DTimeMS := 0;
                PostLogRecordAddMsgNow(70403, e.HelpContext, -1, -1, e.Message);
              end;
            end;
///01.04.20010
            // ���� � ����� ���������� ���� ������ ������, ���������� �����
            if DTimeMS < 0 then break;
            // ��� ��������� � �������� ��������� ������������ ����������
            ExistTrIndex := Succ(ExistTrIndex);
          end;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70402, e.HelpContext, NewTrIndex, -1, e.Message);
            continue;
          end;
        end;


        // ��������� ����� ���������� � ��������� �������
        DATransactionItemList.Insert(ExistTrIndex, NewTr);
        PostLogRecordAddMsgNow(70311, Integer(ServerCore.State), -1, ExistTrIndex, 'Ok. Insert transaction to connection: '+NewTr.DA_ItemId, llDebug);

        // ��������� � ��������� ����������
      finally
        NewTrIndex := Succ(NewTrIndex);
      end;

      // �������� ������� �� �������� ���������� ������� �� ����-������
      // (��� ����� ��� �������� ������� ������� �� ����-������,
      // ����������� ������� ������������ Callback-���������)
      PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_SEND,
        DriverId, // ������������� �������� Hst-�������
        0 // �� ������������
      );
    finally
      Unlock;
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70383, e.HelpContext, -1, -1, e.Message);
  end;
end;


// �������� ������:
// ����������, ����� �� ��������� ��� DA-���������� ����� Hst-��������
function TVpNetHstDriverConnection.AreTransactionItemsCompartible(tr1, tr2 : TVpNetDATransactionItem) : boolean;
begin
  try
    // ���� ...
    if (tr1.DA_Type = tr2.DA_Type) and // ���������� ������ ����
       (tr1.Hst_ID = tr2.Hst_ID) and // ����� �������������� Hst-��������
       (tr1.Hst_DriverID = tr2.Hst_DriverID) and // ����� �������������� Hst-���������
       (tr1.Hst_ProtocolId = tr2.Hst_ProtocolId) and // ����� �������������� ���������������� ����������
       (tr1.Hst_DeviceId = tr2.Hst_DeviceId) and // ����� �������������� ������������ ���������
       (tr1.Hst_FuncNumber = tr2.Hst_FuncNumber) // ��������� ������ ������� ���������
    then
      result := true
    else
      result := false;
  except on e : Exception do
    PostLogRecordAddMsgNow(70382, e.HelpContext, -1, -1, e.Message);
  end;
end;

// �������� ������:
// b. ��������� ��������
// 1. ��������� ������ DA-����������, ��� ������� �� Hst-������
// 2. ��������� ����� Hst-������ ��� ������ DA-����������
// 3. �������� ������ �� Hst-������
// e. �������� ��������
procedure TVpNetHstDriverConnection.Send;
var
  v : OleVariant;
  vArr : OleVariant;
  i : Integer;
  FirstTr : TVpNetDATransactionItem; // ����������
  tr : TVpNetDATransactionItem; // ������� ����������
  // ������ ���������� DA-�������, ������ ������� ����� �������������
  // ������� (�����������) ����������� Hst-�������
//  trForRequest : TVpNetDATransactionItemList;
  trIndex : Integer;
  w : WORD;
  hr : HRESULT;

  // �����������
  MinReg, MaxReg : DWORD;
  RegCount : WORD;
  TotalMinReg, TotalMaxReg : WORD;
  TotalRegCount : WORD;

  qBuf, qBuf2 : TByteBuffer;
  qIndex : Word;

  vPropId, vPropValue : OleVariant;
  pAnswerData : PVpNetHSTAnswerData;
  TID : Integer;

  s : String;
  bb : TByteBuffer;

  slDeviceParamNames : TStringList;
  Index : Integer;
  NodeParamValue : TVpNetNodeParamValue;
  sModbusOptEnabled : String;
  bModbusOptEnabled : Boolean;
  sModbusOptMaxPacketSize : String;
  iModbusOptMaxPacketSize : Word;

  ov : OleVariant;
  sDriverParamName : String;
  sParamValue : String;
  vValue : OleVariant;
begin
  try

    Lock;
    try
      // ���� � ������ ������ ������������� ������ � Hst-�������, �������
      if not(Hst_TID = 0) then begin
        PostLogRecordAddMsgNow(70319, Integer(ServerCore.State), -1, -1, '', llDebug);
        exit;
      end;

      // ���� � ������ ��� DA-����������, �������
      if DATransactionItemList.Count = 0 then begin
        PostLogRecordAddMsgNow(70322, Integer(ServerCore.State), -1, -1, 'Ok. ��������� hst-���������� ���������', llDebug);
        exit;
      end;

(*
      {1}
      // �������� � ��������� ������ � ������� DA-����������,
      // �.�. DA-���������� � ����������� ��������� ������������� ������� ������.
      // ��� ����������� ������ � ������ �������������� DA-����������, ��� ���
      // �� ������� ������ ����� ��������� ����� "�������" DA-����������
      FirstTr := DATransactionItemList[0];
      FirstTr.DA_State := vndtsWaitingForResponse;
*)
      // ���� ����� "�������" ������� DA-����������, ��������� ����������.
      // ���� ������ ���� �������, ��������� ����������, � ����������� ���������
      // ������������� ������� ������ (�.�. ����� ���������� ������������� ����������)
      trIndex := 0;
      FirstTr := nil;
      while trIndex < DATransactionItemList.Count do begin
        // ���� �� ����������
        if DATransactionItemList[trIndex].DA_State = vndtsWaitingForProcessing then begin
          FirstTr := DATransactionItemList[trIndex];
          FirstTr.DA_State := vndtsWaitingForResponse;
// 7.04.2010
          // ��������� ����� ��������� ������� ������� ������
          Hst_Transaction_Send_Time_MS := now;
///7.04.2010
          break;
        end;
        trIndex := Succ(trIndex);
      end;

      // ���� �� ����� ����������� �������� - �������
      if not(Assigned(FirstTr)) then begin
        PostLogRecordAddMsgNow(70323, Integer(ServerCore.State), -1, -1, '');
        exit;
      end;

      // ���� ���� ��������� � ��������� ��������, ��������� ���
// 26.03.2010
//      if (FirstTr.Hst_DeviceId = 0) and (FirstTr.Hst_DeviceTypeTagId > 0) then begin
      PostLogRecordAddMsgNow(70939, FirstTr.Hst_DeviceTypeTagId, FirstTr.Hst_DriverId, FirstTr.Hst_DeviceTypeTagId, 'teg:'+FirstTr.DA_ItemId+'; Hst_DriverId='+IntToStr(FirstTr.Hst_DriverId)+'; ,Hst_DeviceId='+IntToStr(FirstTr.Hst_DeviceId)+'; Hst_DeviceTypeTagId=' + IntToStr(FirstTr.Hst_DeviceTypeTagId), llDebug);
      if (FirstTr.Hst_DeviceTypeTagId > 0) and (FirstTr.Hst_DriverId > 0) and (FirstTr.Hst_DeviceId = 0) then begin
///26.03.2010
        PostLogRecordAddMsgNow(70938, FirstTr.Hst_DeviceTypeTagId, FirstTr.Hst_DriverId, FirstTr.Hst_DeviceTypeTagId, '', llDebug);
        vPropId := FirstTr.Hst_DeviceTypeTagId;
        if Driver.GetNewTID(TID) >= S_OK then begin
          FirstTr.Hst_TID := TID;
          try
            GetMem(pAnswerData, sizeof(TVpNetHSTAnswerData));
            bb := TByteBuffer.Create;
            Hst_TID := TID;

            if FirstTr.DA_Type = vndttRead then begin
// 19.08.2010
//// 28.03.2010
////              hr := Driver.GetPropValue(vPropId, vPropValue);
//              hr := ServerCore.RDM.NodeParams.GetNodeParamValue(FirstTr.Hst_DriverId, vPropId, VPropValue);
/////28.03.2010
              hr := Driver.GetPropValue(vPropId, vPropValue);
///19.08.2010
              try
                s := VPropValue;
                bb.AsString := s;
                pAnswerData^.HstAnswerDataSize := bb.Size;
                GetMem(pAnswerData^.HstAnswerData, pAnswerData^.HstAnswerDataSize);
                move(bb.Data^, pAnswerData^.HstAnswerData^, pAnswerData^.HstAnswerDataSize);
              except
                pAnswerData^.HstAnswerData := nil;
                pAnswerData^.HstAnswerDataSize := 0;
              end;
            end;

            if FirstTr.DA_Type = vndttWrite then begin
              vPropValue := FirstTr.VQT.vDataValue;
              hr := Driver.SetPropValue(vPropId, vPropValue);

// 26.03.2010
              if hr = S_OK then begin
                hr := ServerCore.RDM.NodeParams.SetNodeParamValue(FirstTr.Hst_DriverId, vPropId, vPropValue, false);
//                hr := Driver.SetPropValue(vPropId, vPropValue);
              end;
///26.03.2010

              pAnswerData^.HstAnswerData := nil;
              pAnswerData^.HstAnswerDataSize := 0;
            end;
          finally
            // � ����� ������ � ����� ��������� ��������� � �������� ��������
            // ��������� ������������� Hst-����������, ������������ � ���, ���
            // � ����� ������� ������������� Hst-���������� ���
            //Hst_TID := 0;
            bb.free;
            PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_RECIEVE, TID, Integer(Pointer(pAnswerData)));
          end;
        end;
        exit;
      end;

      // ��������� ����� �������
      // ���� ���������� ��������, � ��� ���� �� ������, ...
      if (FirstTr.DA_Type = vndttRead) and ((FirstTr.HST_AccessRights and OPC_READABLE) = 0) then begin
        PostLogRecordAddMsgNow(70326, Integer(ServerCore.State), -1, -1, '');
        // ... ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
        Hst_TID := HIGH(DWORD);
        PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(OPC_E_BADRIGHTS));
        exit;
      end;

      // ���� ���������� �������, ...
      if (FirstTr.DA_Type = vndttWrite) then begin
        // ... � ��� ���� �� ������, ...
        if ((FirstTr.HST_AccessRights and OPC_WRITEABLE) = 0) then begin
          PostLogRecordAddMsgNow(70328, Integer(ServerCore.State), -1, -1, '');
          // ... ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
          Hst_TID := HIGH(DWORD);
          PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(OPC_E_BADRIGHTS));
          exit;
        end;

        // ... � ����� ���������� Quality, � �������� ��� � ������ ����������,...
        if (FirstTr.VQT.bQualitySpecified) and ((FirstTr.Hst_AccessRights and OPC_QUALITY_WRITABLE) = 0) then begin
          PostLogRecordAddMsgNow(70329, Integer(ServerCore.State), -1, -1, '');
          // ... ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
          Hst_TID := HIGH(DWORD);
          PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(OPC_E_BADRIGHTS));
          exit;
        end;

        // ... � ����� ���������� Timestamp, � �������� ��� � ������ ����������,...
        if (FirstTr.VQT.bTimeStampSpecified) and ((FirstTr.Hst_AccessRights and OPC_TIMESTAMP_WRITABLE) = 0) then begin
          PostLogRecordAddMsgNow(70330, Integer(ServerCore.State), -1, -1, '');
          // ... ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
          Hst_TID := HIGH(DWORD);
          PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(OPC_E_BADRIGHTS));
          exit;
        end;
      end;

{/18.07.2006}

      // ��������� �� ���������
      case FirstTr.HST_ProtocolId of
        VPModbus : begin // Modbus
          // ��������� �������� ����������� �������� Modbus
// 28.03.2010
//          if ServerCore.RDM.NodeParams.GetNodeParamValue(FirstTr.Hst_DeviceId, 'ModbusOptEnabled', sModbusOptEnabled) < S_OK then begin
//            sModbusOptEnabled := '0';
//          end;
//          bModbusOptEnabled := not(sModbusOptEnabled = '0');
          if ServerCore.RDM.NodeParams.GetNodeParamValue(FirstTr.Hst_DeviceId, 'ModbusOptEnabled', vValue) >= S_OK then begin
            if not VarIsNull(vValue) then begin
              sModbusOptEnabled := vValue;
              bModbusOptEnabled := not(sModbusOptEnabled = '0');
            end else begin
              bModbusOptEnabled := false;
            end;
          end else begin
            bModbusOptEnabled := false;
          end;

          // ��������� ����������� ����� �������� ��� ����������� �������� Modbus
//          if ServerCore.RDM.NodeParams.GetNodeParamValue(FirstTr.Hst_DeviceId, 'ModbusOptMaxPacketSize', sModbusOptMaxPacketSize) < S_OK then begin
//            sModbusOptMaxPacketSize := '';
//          end;
//          iModbusOptMaxPacketSize := StrToIntDef(sModbusOptMaxPacketSize, 4);
          if ServerCore.RDM.NodeParams.GetNodeParamValue(FirstTr.Hst_DeviceId, 'ModbusOptMaxPacketSize', vValue) >= S_OK then begin
            if not VarIsNull(vValue) then begin
              sModbusOptMaxPacketSize := vValue;
              iModbusOptMaxPacketSize := StrToIntDef(sModbusOptMaxPacketSize, 4);
            end else begin
              iModbusOptMaxPacketSize := 0;
            end;
          end else begin
            iModbusOptMaxPacketSize := 0;
          end;


///28.03.2010

          Hst_ProtocolId := VPModbus;
          case FirstTr.HST_FuncNumber of
            fnReadHoldingRegisters, // ������� 3: ������ ��������� ��������
            fnReadInputRegisters: begin // ������� 4: ������ ��������� �����
              // ��������� �������
              MinReg := FirstTr.Hst_DataAddress;
              // ���-�� ���������
              RegCount := ((FirstTr.HST_DataSizeInBytes + 1) div 2);
              // �������� �������
              MaxReg := MinReg + RegCount - 1;
              // ����� ��������
              TotalMinReg := MinReg;
              TotalMaxReg := MaxReg;
              TotalRegCount := RegCount;
              if bModbusOptEnabled then begin
                // �������� ����������� �������� �� ��������� Modbus ��������� 3 � 4:
                // �������� �� ������ ���� �������� DA-���������� ����������, � ��������
                // DA-����������, ������� ����� ��������� ��������� � ������ ("�������")
  {18.07.2006}
                trIndex := trIndex + 1;
                // ���������� ������ �� ������ ���������
                while trIndex < DATransactionItemList.Count do begin
                  // ��������� ����������
                  tr := DATransactionItemList[trIndex];
                  // ���� DA-���������� "����������"
                  if AreTransactionItemsCompartible(tr, FirstTr) then begin
                    // ��������� �������
                    MinReg := tr.Hst_DataAddress;
                    // ���-�� ���������
                    RegCount := ((tr.HST_DataSizeInBytes + 1) div 2) and $FFFF;
                    // �������� �������
                    MaxReg := MinReg + RegCount - 1;
                    // ������������ �����
                    if MinReg <= TotalMinReg then begin
                      if (TotalMaxReg - MinReg) < iModbusOptMaxPacketSize then begin
                        TotalMinReg := MinReg;
                        tr.DA_State := vndtsWaitingForResponse;
                      end;
                    end else if MaxReg >= TotalMaxReg then begin
                      if (MaxReg - TotalMinReg) < iModbusOptMaxPacketSize then begin
                        TotalMaxReg := MaxReg;
                        tr.DA_State := vndtsWaitingForResponse;
                      end;
                    end else begin
                      tr.DA_State := vndtsWaitingForResponse;
                    end;
                  end;
                  trIndex := Succ(trIndex);
                end;
                TotalRegCount := (TotalMaxReg - TotalMinReg + 1);
              end;

              Hst_OutputData.Size := 6; // ������ ������ (��� CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // ����� ���������� � ���� Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // ����� ������� = 3,4
              Hst_OutputData[2] := HIBYTE(TotalMinReg);
              Hst_OutputData[3] := LOBYTE(TotalMinReg);
              // ���-�� ���������
              Hst_OutputData[4] := HIBYTE(TotalRegCount);
              Hst_OutputData[5] := LOBYTE(TotalRegCount);

              // ������� ����������� ����� (CRC16)
              w := CRC16_2(Hst_OutputData);
              // ���������� ����������� ����� � ������
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);
              //��������� ��������� ������ ��������� ������
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // ��������� ��������� ���������� ������� ��������� ������
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70331, Integer(ServerCore.State), -1, -1, '�� ������� ��������� �������������� ������ ��������� ������ Modbus');
                exit;
              end;
            end;

            fnForceSingleCoil: begin
              Hst_OutputData.Size := 6; // ������ ������ (��� CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // ����� ���������� � ���� Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // ����� ������� = 5
              Hst_OutputData[2] := HIBYTE(FirstTr.Hst_DataAddress); // ������� ���� ������ ������
              Hst_OutputData[3] := LOBYTE(FirstTr.Hst_DataAddress); // ������� ���� ������ ������

              // �������������� ������ � ������
              qBuf := TByteBuffer.Create;
              try
                hr := EncodeDataByFormat(FirstTr.VQT.vDataValue, FirstTr.Hst_DataFormatId, qBuf);
                // ��������� ��������� ��������� ������ ������
                if (hr <> S_OK) and (hr <> S_FALSE) then begin
                  // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                  Hst_TID := HIGH(DWORD);
//                  {8.02.2009}
//                  Hst_Transaction_Exists := true;
//                  {/8.02.2009}
                  PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                  //todo: ������ ���������������� ��� ������: "������ �������������� ������"
                  exit;
                end;
                // ��������� ���������� ���� ������
                if not (qBuf.Size = 2) then begin
                  // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                  Hst_TID := HIGH(DWORD);
//                  {8.02.2009}
//                  Hst_Transaction_Exists := true;
//                  {/8.02.2009}
                  PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                  //todo: ������ ���������������� ��� ������: "������ �������������� ������"
                  exit;
                end;
                // ��������� ���������� ����� � ������� � �������� �����
                Hst_OutputData[4] := qBuf[0];
                Hst_OutputData[5] := qBuf[1];
              finally
                qBuf.Free;
              end;

              // ������� ����������� ����� (CRC16)
              w := CRC16_2(Hst_OutputData);
              // ���������� ����������� ����� � ������
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);

              //��������� ��������� ������ ��������� ������
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // ��������� ��������� ���������� ������� ��������� ������
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70332, Integer(ServerCore.State), -1, -1, '�� ������� ��������� �������������� ������ ��������� ������ Modbus');
                exit;
              end;
            end;

            fnPresetSingleRegister: begin
              Hst_OutputData.Size := 6; // ������ ������ (��� CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // ����� ���������� � ���� Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // ����� ������� = 6
              Hst_OutputData[2] := HIBYTE(FirstTr.Hst_DataAddress);
              Hst_OutputData[3] := LOBYTE(FirstTr.Hst_DataAddress);

              // �������������� ������ � ������
              qBuf := TByteBuffer.Create;
              try
                hr := EncodeDataByFormat(FirstTr.VQT.vDataValue, FirstTr.Hst_DataFormatId, qBuf);
                // ��������� ��������� ��������� ������ ������
                if (hr <> S_OK) and (hr <> S_FALSE) then begin
                  // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                  Hst_TID := HIGH(DWORD);
//                  {8.02.2009}
//                  Hst_Transaction_Exists := true;
//                  {/8.02.2009}
                  PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                  PostLogRecordAddMsgNow(70333, Integer(ServerCore.State), -1, -1, '������ �������������� ������');
                  exit;
                end;
                // ��������� ���������� ���� ������
                if not (qBuf.Size = 2) then begin
                  // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                  Hst_TID := HIGH(DWORD);
//                  {8.02.2009}
//                  Hst_Transaction_Exists := true;
//                  {/8.02.2009}
                  PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                  PostLogRecordAddMsgNow(70334, Integer(ServerCore.State), -1, -1, '������ �������������� ������');
                  exit;
                end;
                // ��������� ���������� ����� � ������� � �������� �����
  {
                Hst_OutputData.Size :=  Hst_OutputData.Size + qBuf.Size;
                qIndex := 0;
                while qIndex < qBuf.Size do begin
                  Hst_OutputData.Bytes[Hst_OutputData.Size - qBuf.Size + qIndex] := qBuf.Bytes[qIndex];
                  qIndex := Succ(qIndex);
                end;
  }
                Hst_OutputData[4] := qBuf[0];
                Hst_OutputData[5] := qBuf[1];

              finally
                qBuf.Free;
              end;

              // ������� ����������� ����� (CRC16)
              w := CRC16_2(Hst_OutputData);
              // ���������� ����������� ����� � ������
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);

              //��������� ��������� ������ ��������� ������
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // ��������� ��������� ���������� ������� ��������� ������
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70335, Integer(ServerCore.State), -1, -1, '�� ������� ��������� �������������� ������ ��������� ������ Modbus');
                exit;
              end;
            end;

            fnReadExceptionStatus: begin
              Hst_OutputData.Size := 2; // ������ ������ (��� CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // ����� ���������� � ���� Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // ����� ������� = 16
              // ������� ����������� ����� (CRC16)
              w := CRC16_2(Hst_OutputData);
              // ���������� ����������� ����� � ������
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);
              //��������� ��������� ������ ��������� ������
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // ��������� ��������� ���������� ������� ��������� ������
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70336, Integer(ServerCore.State), -1, -1, '�� ������� ��������� �������������� ������ ��������� ������ Modbus');
                exit;
              end;
            end;
{15.05.2007}
{
            fnPresetMultipleRegisters: begin
              Hst_OutputData.Size := 7; // ������ ������ (��� CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // ����� ���������� � ���� Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // ����� ������� = 16
              Hst_OutputData[2] := HIBYTE(FirstTr.Hst_DataAddress);
              Hst_OutputData[3] := LOBYTE(FirstTr.Hst_DataAddress);
              // ���������� ��������� � ���� ������
              TotalRegCount := (FirstTr.Hst_DataSizeInBytes + 1) div 2;
              Hst_OutputData[4] := HIBYTE(TotalRegCount);
              Hst_OutputData[5] := LOBYTE(TotalRegCount);
              Hst_OutputData[6] := (TotalRegCount * 2) and $ff; // ������������

              // �������������� ������ � ������
              qBuf := TByteBuffer.Create;
              try
                hr := EncodeDataByFormat(FirstTr.VQT.vDataValue, FirstTr.Hst_DataFormatId, qBuf);
                // ��������� ��������� ��������� ������ ������
                if (hr <> S_OK) and (hr <> S_FALSE) then begin
                  // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                  Hst_TID := HIGH(DWORD);
//                  //8.02.2009
//                  Hst_Transaction_Exists := true;
//                  ///8.02.2009
                  PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                  //todo: ������ ���������������� ��� ������: "������ �������������� ������"
                  exit;
                end;
                // ��������� ���������� ����� � ������� � �������� �����
                Hst_OutputData.Size :=  Hst_OutputData.Size + qBuf.Size;
                qIndex := 0;
                while qIndex < qBuf.Size do begin
                  Hst_OutputData.Bytes[Hst_OutputData.Size - qBuf.Size + qIndex] := qBuf.Bytes[qIndex];
                  qIndex := Succ(qIndex);
                end;


              finally
                qBuf.Free;
              end;
              // ������� ����������� ����� (CRC16)
              w := CRC16_2(Hst_OutputData);
              // ���������� ����������� ����� � ������
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);

              //��������� ��������� ������ ��������� ������
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // ��������� ��������� ���������� ������� ��������� ������
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                Hst_TID := HIGH(DWORD);
//                //8.02.2009
//                Hst_Transaction_Exists := true;
//                ///8.02.2009
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                //todo: ������ ���������������� ��� ������: "�� ������� ��������� �������������� ������ ��������� ������ Modbus"
                exit;
              end;
            end;
}
            fnPresetMultipleRegisters: begin
              Hst_OutputData.Size := 7; // ������ ������ (��� CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // ����� ���������� � ���� Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // ����� ������� = 16

              // ��������� �������
              MinReg := FirstTr.Hst_DataAddress;
              // ���-�� ���������
              RegCount := ((FirstTr.HST_DataSizeInBytes + 1) div 2);
              // �������� �������
              MaxReg := MinReg + RegCount - 1;
              // ����� ��������
              TotalMinReg := MinReg;
              TotalMaxReg := MaxReg;

              trIndex := trIndex + 1;
                // ���������� ������ �� ������ ���������
{/18.07.2006}
              while trIndex < DATransactionItemList.Count do begin
                tr := DATransactionItemList[trIndex];
                // ���� DA-���������� "����������"
                if AreTransactionItemsCompartible(tr, FirstTr) then begin
                  // ��������� �������
                  MinReg := tr.Hst_DataAddress;
                  // ���-�� ���������
                  RegCount := ((tr.HST_DataSizeInBytes + 1) div 2) and $FFFF;
                  // �������� �������
                  MaxReg := MinReg + RegCount - 1;
                  // ������������ �����
                  if MinReg <= TotalMinReg then begin
                    if (TotalMaxReg - MinReg) < 125 then begin
                      TotalMinReg := MinReg;
                      tr.DA_State := vndtsWaitingForResponse;
                    end;
                  end else if MaxReg >= TotalMaxReg then begin
                    if (MaxReg - TotalMinReg) < 125 then begin
                      TotalMaxReg := MaxReg;
                      tr.DA_State := vndtsWaitingForResponse;
                    end;
                  end else begin
                    tr.DA_State := vndtsWaitingForResponse;
                  end;
                end;

                trIndex := Succ(trIndex);
              end;

              TotalRegCount := TotalMaxReg - TotalMinReg + 1;
              Hst_OutputData[2] := HIBYTE(TotalMinReg);
              Hst_OutputData[3] := LOBYTE(TotalMinReg);
              Hst_OutputData[4] := HIBYTE(TotalRegCount);
              Hst_OutputData[5] := LOBYTE(TotalRegCount);
              Hst_OutputData[6] := (TotalRegCount * 2) and $ff; // ������������

              // ������������ ������
              qBuf := TByteBuffer.Create;
              qBuf2 := TByteBuffer.Create;
              try
                qBuf.Size := TotalRegCount * 2;
                trIndex := 0;
                // �������� �� ���� �����������
                while trIndex < DATransactionItemList.Count do begin
                  tr := DATransactionItemList[trIndex];

                  // ���� ���������� �������� � ����������, ��������� �� ������ �
                  // � ���� �������� ������ ������
                  if tr.DA_State = vndtsWaitingForResponse then begin

                    // �������� �������� ������ ���������� � ���� ������� ������
                    hr := EncodeDataByFormat(tr.VQT.vDataValue, tr.Hst_DataFormatId, qBuf2);
                    if (hr <> S_OK) and (hr <> S_FALSE) then begin
                      // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                      Hst_TID := HIGH(DWORD);
//                      {8.02.2009}
//                      Hst_Transaction_Exists := true;
//                      {/8.02.2009}
                      PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                      PostLogRecordAddMsgNow(70337, Integer(ServerCore.State), -1, -1, '������ �������������� ������');
                    end;

                    // �������� ������ ���������� � ���� �������� ������ ������
                    qIndex := 0;
                    while qIndex < qBuf2.Size do begin
                      qBuf.Bytes[(tr.Hst_DataAddress - TotalMinReg)*2 + qIndex] := qBuf2[qIndex];
                      qIndex := Succ(qIndex);
                    end;
                  end;

                  trIndex := succ(trIndex);
                end;

                // ��������� ���������� ����� � ������� � �������� �����
                Hst_OutputData.Size :=  Hst_OutputData.Size + qBuf.Size;
                qIndex := 0;
                while qIndex < qBuf.Size do begin
                  Hst_OutputData.Bytes[Hst_OutputData.Size - qBuf.Size + qIndex] := qBuf.Bytes[qIndex];
                  qIndex := Succ(qIndex);
                end;
              finally
                qBuf.Free;
                qBuf2.Free;
              end;

              // ������� ����������� ����� (CRC16)
              w := CRC16_2(Hst_OutputData);
              // ���������� ����������� ����� � ������
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);

              //��������� ��������� ������ ��������� ������
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // ��������� ��������� ���������� ������� ��������� ������
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70338, Integer(ServerCore.State), -1, -1, '�� ������� ��������� �������������� ������ ��������� ������ Modbus');
                exit;
              end;

            end;
{/15.05.2007}
            fnReportSlaveID: begin
              Hst_OutputData.Size := 2; // ������ ������ (��� CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // ����� ���������� � ���� Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // ����� ������� = 16
              // ������� ����������� ����� (CRC16)
              w := CRC16_2(Hst_OutputData);
              // ���������� ����������� ����� � ������
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);
              //��������� ��������� ������ ��������� ������
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // ��������� ��������� ���������� ������� ��������� ������
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70339, Integer(ServerCore.State), -1, -1, '�� ������� ��������� �������������� ������ ��������� ������ Modbus');
                exit;
              end;
            end else begin
              // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
              Hst_TID := HIGH(DWORD);
//              {8.02.2009}
//              Hst_Transaction_Exists := true;
//              {/8.02.2009}
              PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
              PostLogRecordAddMsgNow(70340, Integer(ServerCore.State), -1, -1, '������������ ����� ������� Modbus');
              exit;
            end;
          end;
        end;
        VPHstDriverInterface: begin
          // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ���������� �����������
//          Hst_TID := HIGH(DWORD);
          PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_RECIEVE, Integer(HIGH(DWORD)), Integer(S_OK));
          PostLogRecordAddMsgNow(70341, Integer(ServerCore.State), -1, -1, '�������� �� ��������������');
        end;
        else begin
          // ��������� ���������� Hst-���������� � ������� HIGH(DWORD) � ��������� �����������
          Hst_TID := HIGH(DWORD);
//          {8.02.2009}
//          Hst_Transaction_Exists := true;
//          {/8.02.2009}
          PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
          PostLogRecordAddMsgNow(70342, Integer(ServerCore.State), -1, -1, '�������� �� ��������������');
          exit;
        end;
      end;

      // ��������� ��������� ������� � Hst-�������
      v := Hst_SupposedInputDataSize;
      vArr := Hst_OutputData.AsVarArray;

      // ��������� ������ � HST-�������
      PostLogRecordAddMsgNow(70343, Integer(ServerCore.State), -1, -1, 'Ok. ������ � HST-�������. ������', llDebug);

      slDeviceParamNames := TStringList.create;
      try
        ServerCore.RDM.NodeParams.GetNodeParamNames(FirstTr.Hst_DeviceId, slDeviceParamNames);
        Index := 0;
        while Index < slDeviceParamNames.count do begin
          NodeParamValue := ServerCore.RDM.NodeParams.Find(FirstTr.Hst_DeviceId, slDeviceParamNames[Index]);
          if Assigned(NodeParamValue) and NodeParamValue.ParamValueAssigned and NodeParamValue.ForSendToHst then begin
            vPropId := slDeviceParamNames[Index];
{
            // ���������� ��������� �������� ���������
            hr := Driver.GetPropValue(vPropId, vPropValue);
            if hr = S_OK then begin
              NodeParamValue.OriginParamValue := vPropValue;
            end else begin
              NodeParamValue.OriginParamValue := EmptyStr;
            end;
}
            // ��������� �������� ��� ������� ����������
            vPropValue := NodeParamValue.ParamValue;
            hr := Driver.SetPropValue(vPropId, vPropValue);
          end;
          Index := Succ(Index);
        end;

{
        hr := Driver.GetPropValue('IMEI', ov);
        if
          (hr = S_OK) and
          not(
//            (ov =355632000330911) or
            (ov =355632006126842) or
            (ov =355632006130497) or
            (ov =355632006134663) or
            (ov =355632006126917) or
            (ov =355632006136155) or
            (ov =355632006137146) or
            (ov =355632006136866) or
            (ov =355632006133772) or
            (ov =355632006134010) or
            (ov =355632006136072) or
            (ov =355632005208641) or
            (ov =355632006137112) or
            (ov =355632006126859) or
            (ov =355632005203360) or
            (ov =355632006136213) or
            (ov =355632006134747) or
            (ov =355632006134788) or
            (ov =355632006137658) or
            (ov =355632006126909) or
            (ov =355632006137120) or

            (ov =355632006137120)
          ) then begin
            PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Hst_TID, Integer(E_INVALIDARG));
          end else begin
            //======================
}
            PostLogRecordAddMsgNow(70349, -1, -1, -1, 'Ok. ����� ��������� ������ ��������', llDebug);
            Driver.Send(vArr, v, i);
            PostLogRecordAddMsgNow(70350, -1, -1, -1, 'Ok. ����� ��������� ������ ��������', llDebug);
{
            //======================
          end;
}
        {
        Index := 0;
        while Index < slDeviceParamNames.count do begin
          NodeParamValue := ServerCore.RDM.NodeParams.Find(FirstTr.Hst_DeviceId, slDeviceParamNames[Index]);
          if Assigned(NodeParamValue) and NodeParamValue.ParamValueAssigned and NodeParamValue.ForSendToHst then begin
            vPropId := slDeviceParamNames[Index];

            // ��������� ��������� �������� ��������� ����������
            VPropValue := NodeParamValue.OriginParamValue;
            hr := Driver.SetPropValue(vPropId, VPropValue);
          end;
          Index := Succ(Index);
        end;
        }
      finally
        slDeviceParamNames.free;
      end;

      PostLogRecordAddMsgNow(70348, 6, -1, -1, 'Ok. ������ � HST-�������. �����', llDebug);

      // ���������� ������������� ������� Hst-����������
      Hst_TID := DWORD(i);

// 7.04.2010
//// 16.10.2009
//      // ��������� ����� ��������� ������� ������� ������
//      Hst_Transaction_Send_Time_MS := now;
/////16.10.2009
///7.04.2010

//      {8.02.2009}
//      Hst_Transaction_Exists := true;
//      {/8.02.2009}

    finally
      Unlock;
    end;
  except
    PostLogRecordAddMsgNow(70324, Integer(ServerCore.State), -1, -1, '');
  end;
end;

// 6.04.2010
//procedure TVpNetHstDriverConnection.Recieve(var aHstAnswerData: PVpNetHSTAnswerData);
procedure TVpNetHstDriverConnection.Recieve(aHstAnswerData: PVpNetHSTAnswerData);
///6.04.2010
var
  DATransaction : TVpNetDATransaction; // DA-����������
  DATransactionItemIndex : Integer;
  DATransactionItem : TVpNetDATransactionItem;
  ModbusRequestStartReg : WORD;
  ModbusRequestRegCount : WORD;
  ModbusResponseByteCount : BYTE;
  ModbusResponseCRCCorrect : boolean;
  buf : TByteBuffer;
  ByteIndex : Integer;
  v : OleVariant;
  hr : HRESULT;
  AttachedDATransactionList : TVpNetDATransactionList; // ������ ���������� DA-����������
  TrIndex : Integer; // ����� DA-���������� � ������
  gr : TVpNetOPCGroup; // �����
  grThread : TVpNetOPCGroupControlThread;
  ThereAreProcessedItems : boolean;
begin
  try
    PostLogRecordAddMsgNow(70850, -1, -1, -1, 'Ok. t', llDebug);

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70351, Integer(ServerCore.State), -1, -1, '');
      exit;
    end;

    Lock;
    try
      AttachedDATransactionList := TVpNetDATransactionList.Create;

      // ���������� ������� (��������) ������ � �������� ����������
      Hst_InputData.Clear;

      // ��������� ������ �� �������� ��������� �� ������� �����
      if Assigned(aHstAnswerData) then begin
        if Assigned(aHstAnswerData^.HstAnswerData) then begin
          Hst_InputData.Size := aHstAnswerData.HstAnswerDataSize;
          move(aHstAnswerData.HstAnswerData^, Hst_InputData.Data^, aHstAnswerData.HstAnswerDataSize);
          // ������� ���� ������ ��������� ���������
          FreeMem(aHstAnswerData^.HstAnswerData);
        end else begin
          PostLogRecordAddMsgNow(70353, -1, -1, -1, '', llErrors);
        end;
        // ������� ��������� ���������
        FreeMem(aHstAnswerData);
      end else begin
        PostLogRecordAddMsgNow(70352, -1, -1, -1, '');
      end;

      //-------------------------------------------------------
      //���������
      //-------------------------------------------------------

      // ���� ������� ���������� Hst-������� ����� �������� Modbus,
      // ��������� ������������ ����������� ����� ��������� ������
      if Hst_ProtocolId = VPModbus then begin
        // �������� ������������ ����������� ����� ��������� ������
        ModbusResponseCRCCorrect := CheckPacketCRC(Hst_InputData);
      end;

      // �������� �� ������ ��������� DA-���������� ����������
      DATransactionItemIndex := 0;
      while DATransactionItemIndex < DATransactionItemList.Count do begin

        // ���������, ������� �� ���� ������� DA-���������� ������ � ������
        // Hst-����������
        if DATransactionItemList[DATransactionItemIndex].DA_State = vndtsWaitingForResponse then begin
          // ���� �������, �������� ������� ��������� ������ ��� �������
          // �������� DA-����������. �������� ������� DA-����������
          DATransactionItem := DATransactionItemList[DATransactionItemIndex];
        end else begin
          // ���� �� �������, ��������� � ���������� �������� DA-����������
          // ���������� (��������� ����� �������� DA-����������)
          DATransactionItemIndex := Succ(DATransactionItemIndex);
          // ��������� � ���������� �������� DA-����������
          continue;
        end;

        // ���� ��� ������� ����������� ����������, ��������� � ������ ����������,
        // � ������� ��������� ������ �������
        if (DATransactionItem.DA_SyncType = vndtstAsync) and
        (AttachedDATransactionList.IndexOf(DATransactionItem.DA_Transaction) = -1) then begin
          AttachedDATransactionList.Add(DATransactionItem.DA_Transaction);
        end;

        // ������� ����������� ������� DA-���������� �� ������
        DATransactionItemList.Remove(DATransactionItem);

        try

{21.06.2007}
          // ���� ������� DA-���������� �������� ����� �� ������ ���������
          // �������� hst-�������, ���������� �������� � ��������� � ����������
          //
          if DATransactionItem.Hst_DeviceId = 0 then begin
//            DATransactionItem.VQT.vDataValue := Hst_InputData.AsString;
            DATransactionItem.SetOk(Hst_InputData.AsString);
            continue;
          end;
{/21.06.2007}

          // ���� ��������� ����� ��������� ��������� ��������,
          // � ����� ��������� ��������� �� ������������� ���������,
          // �������� ���� ������� ���������� ��� ����������� ��������,
          // � ��������� � ����������
          if (Hst_SupposedInputDataSize > 0) and not(DWORD(Hst_InputData.Size) = Hst_SupposedInputDataSize) then begin
            // ������������� ������
            DATransactionItem.SetError;
            // ��������� � ��������� DA-����������
            PostLogRecordAddMsgNow(70354, Hst_SupposedInputDataSize, Hst_InputData.Size, -1, '');
            continue;
          end;

          // ���������...
          case DATransactionItem.Hst_ProtocolId of
            VPModbus: begin // Modbus
              // ���� ����������� ���� ����� ��������� ������ ������������,
              // ��� DA-���������� �� ��������� Modbus ��������� �������
              if not ModbusResponseCRCCorrect then begin
                DATransactionItem.SetError;
                PostLogRecordAddMsgNow(70355, -1, -1, -1, '');
                continue;
              end;
              case DATransactionItem.HST_FuncNumber of
                fnReadHoldingRegisters, // ������� 3: ������ ��������� ��������
                fnReadInputRegisters // ������� 4: ������ ��������� �����
                : begin
                  // ��������� ��������� ����� ��� ������� 3 � 4 ��������� Modbus:
                  // �������� ������������ ������ ����������
                  if not(DATransactionItem.Hst_DeviceAddress = Hst_InputData.Bytes[0]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70356, DATransactionItem.Hst_DeviceAddress, Hst_InputData.Bytes[0], -1, '');
                    continue;
                  end;

                  // ��������� ����� ������� � �������� ������
                  if not(DATransactionItem.Hst_FuncNumber = Hst_InputData.Bytes[1]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70357, DATransactionItem.Hst_FuncNumber, Hst_InputData.Bytes[1], -1, '');
                    continue;
                  end;

                  // ��������� ������������� �������
                  ModbusRequestStartReg := (Hst_OutputData.Bytes[2] shl 8) + Hst_OutputData.Bytes[3];
                  ModbusRequestRegCount := (Hst_OutputData.Bytes[4] shl 8) + Hst_OutputData.Bytes[5];

                  // ��������� ������������� ������
                  ModbusResponseByteCount := Hst_InputData.Bytes[2];

                  // �������� ������������ ����� ����� ���� ������ ������
                  if not(ModbusRequestRegCount * 2 = ModbusResponseByteCount) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70358, ModbusRequestRegCount, ModbusResponseByteCount, -1, '');
                    continue;
                  end;
                  // �������� ������ � ������� ��� ������ �����������
                  buf := TByteBuffer.Create;
                  try
                    // ������ ���� ������ ����������� �� ������� �������� �����
                    buf.Size := ((DATransactionItem.Hst_DataSizeInBytes + 1) div 2) * 2;
                    ByteIndex := 0;
                    while ByteIndex < buf.Size do begin
                      buf[ByteIndex] := Hst_InputData.Bytes[3 + (DATransactionItem.Hst_DataAddress - ModbusRequestStartReg) * 2 + DWORD(ByteIndex)];
                      ByteIndex := Succ(ByteIndex);
                    end;
                    // ������ ����� ������ � �������������� �� � Variant �� �����-�� �����
                    hr := DecodeDataByFormat(buf, DATransactionItem.Hst_DataFormatId, v);
                    if hr = S_OK then begin
                    // ���������� ���������� ��������
                      DATransactionItem.VQT.vDataValue := v;
                      DATransactionItem.SetOk(v);
                    end else begin
                      PostLogRecordAddMsgNow(70359, hr, -1, -1, '');
                      DATransactionItem.SetError;
                    end;
                  finally
                    buf.Free;
                  end;
                end;

  {21.06.2006}
                fnForceSingleCoil: begin
                  // ��������� ��������� ����� ��� ������� 5 ��������� Modbus:
                  // � ������ ��������� ���������� ������� �������� ���������
                  // ��������� �������
                  if not(Hst_OutputData.Size = Hst_InputData.Size) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70360, Hst_OutputData.Size, Hst_InputData.Size, -1, '');
                    continue;
                  end;
                  // ��������� ���������� ��������� �������
                  ByteIndex := 0;
                  while ByteIndex < Hst_InputData.Size do begin
                    if not (Hst_OutputData.Bytes[ByteIndex] = Hst_InputData.Bytes[ByteIndex]) then begin
                      DATransactionItem.SetError;
                      PostLogRecordAddMsgNow(70361, ByteIndex, Hst_OutputData.Bytes[ByteIndex], Hst_InputData.Bytes[ByteIndex], '');
                      continue;
                    end;
                    ByteIndex := Succ(ByteIndex);
                  end;
                  // ���������� DA-���������� � S_OK
                  DATransactionItem.Complete(S_OK);
                end;

                fnPresetSingleRegister: begin
                  // ��������� ��������� ����� ��� ������� 6 ��������� Modbus:
                  // � ������ ��������� ���������� ������� �������� ���������
                  // ��������� �������
                  if not(Hst_OutputData.Size = Hst_InputData.Size) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70362, Hst_OutputData.Size, Hst_InputData.Size, -1, '');
                    continue;
                  end;
                  // ��������� ���������� ��������� �������
                  ByteIndex := 0;
                  while ByteIndex < Hst_InputData.Size do begin
                    if not (Hst_OutputData.Bytes[ByteIndex] = Hst_InputData.Bytes[ByteIndex]) then begin
                      DATransactionItem.SetError;
                      PostLogRecordAddMsgNow(70363, ByteIndex, Hst_OutputData.Bytes[ByteIndex], Hst_InputData.Bytes[ByteIndex], '');
                      continue;
                    end;
                    ByteIndex := Succ(ByteIndex);
                  end;
                  // ���������� DA-���������� � S_OK
                  DATransactionItem.Complete(S_OK);
                end;
  {/21.06.2006}
  {23.06.2006}
                fnReadExceptionStatus: begin
                  // ��������� ��������� ����� ��� ������� 7 ��������� Modbus:
                  // �������� ������������ ������ ����������
                  if not(DATransactionItem.Hst_DeviceAddress = Hst_InputData.Bytes[0]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70364, DATransactionItem.Hst_DeviceAddress, Hst_InputData.Bytes[0], -1, '');
                    continue;
                  end;

                  // ��������� ����� ������� � �������� ������
                  if not(DATransactionItem.Hst_FuncNumber = Hst_InputData.Bytes[1]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70365, DATransactionItem.Hst_FuncNumber, Hst_InputData.Bytes[1], -1, '');
                    continue;
                  end;

                  // ��������� ����������� ����� ��������� ������
                  if not CheckPacketCRC(Hst_InputData) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70366, -1, -1, -1, '');
                    continue;
                  end;

                  // �������� ������ � ������� ��� ������ �����������
                  buf := TByteBuffer.Create;
                  try
                    // ������ ���� ������ = 1 ����
                    buf.Size := 1;
                    buf[0] := Hst_InputData.Bytes[2];
                    // ������ ����� ������ � �������������� �� � Variant �� �����-�� �����
                    hr := DecodeDataByFormat(buf, DATransactionItem.Hst_DataFormatId, v);
                    if hr = S_OK then begin
                    // ���������� ���������� ��������
                      DATransactionItem.VQT.vDataValue := v;
                      DATransactionItem.SetOk(v);
                    end else begin
                      DATransactionItem.SetError;
                      PostLogRecordAddMsgNow(70367, hr, -1, -1, '');
                    end;
                  finally
                    buf.Free;
                  end;

                end;
  {/23.06.2006}
                fnPresetMultipleRegisters: begin
                  // ��������� ��������� ����� ��� ������� 16 ��������� Modbus:
                  // �������� ������������ ������ ����������
                  if not(DATransactionItem.Hst_DeviceAddress = Hst_InputData.Bytes[0]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70368, DATransactionItem.Hst_DeviceAddress, Hst_InputData.Bytes[0], -1, '');
                    continue;
                  end;

                  // �������� ������������ �������� � ��������� �������
                  if not CompareMem(Hst_OutputData.Data, Hst_InputData.Data, 6) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70369, -1, -1, -1, '');
                    continue;
                  end;

                  // ��������� ����������� ����� ��������� ������
                  if not CheckPacketCRC(Hst_InputData) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70370, -1, -1, -1, '');
                    continue;
                  end;

                  // ���������� DA-���������� � S_OK
                  DATransactionItem.Complete(S_OK);
  {24.06.2006}
                end;
                fnReportSlaveID: begin
                  // ��������� ��������� ����� ��� ������� 7 ��������� Modbus:
                  // �������� ������������ ������ ����������
                  if not(DATransactionItem.Hst_DeviceAddress = Hst_InputData.Bytes[0]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70371, DATransactionItem.Hst_DeviceAddress, Hst_InputData.Bytes[0], -1, '');
                    continue;
                  end;

                  // ��������� ����� ������� � �������� ������
                  if not(DATransactionItem.Hst_FuncNumber = Hst_InputData.Bytes[1]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70372, DATransactionItem.Hst_FuncNumber, Hst_InputData.Bytes[1], -1, '');
                    continue;
                  end;

                  // ��������� ����������� ����� ��������� ������
                  if not CheckPacketCRC(Hst_InputData) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70373, -1, -1, -1, '');
                    continue;
                  end;

                  // �������� ������ � ������� ��� ������ �����������
                  buf := TByteBuffer.Create;
                  try
                    // ������ ���� ������ ����������
                    buf.Size := Hst_InputData.Size - 3 - 2;
                    ByteIndex := 0;
                    while ByteIndex < buf.Size do begin
                      buf[ByteIndex] := Hst_InputData[ByteIndex + 3];
                      ByteIndex := Succ(ByteIndex);
                    end;

                    // ������ ����� ������ � �������������� �� � Variant �� �����-�� �����
                    hr := DecodeDataByFormat(buf, DATransactionItem.Hst_DataFormatId, v);
                    if hr = S_OK then begin
                    // ���������� ���������� ��������
                      DATransactionItem.VQT.vDataValue := v;
                      DATransactionItem.SetOk(v);
                    end else begin
                      DATransactionItem.SetError;
                      PostLogRecordAddMsgNow(70374, hr, -1, -1, '');
                    end;
                  finally
                    buf.Free;
                  end;
  {/24.06.2006}
                end else begin
                  // ���� �������������� ����������� ������� ��������� Modbus, ��������� �� � �������
                  DATransactionItem.SetError;
                  PostLogRecordAddMsgNow(70375, DATransactionItem.HST_FuncNumber, -1, -1, '');
                  continue;
                end;
              end;
            end;
            else begin
              // ���� � ���������� ����������� ��������, ��������� �� � �������
              DATransactionItem.SetError;
              PostLogRecordAddMsgNow(70376, DATransactionItem.Hst_ProtocolId, -1, -1, '');
              // �������� ��������� �� ������ ��������� DA-����������
              //PostMessage(...
              // ��������� � ��������� DA-����������
              continue;
            end;
          end;
        finally
          // �������� ��������� �� ��������� ��������� ���������� ������ ������
          // ���������� ����������� DA-���������� (��� ��������� ������)
          // (���� ���������� ����������, �� �� ���������� ������������
          // ��������� �����)
          trIndex := 0;
//          ThereAreProcessedItems := false;
          while trIndex < AttachedDATransactionList.Count do begin
            try
              DATransaction := AttachedDATransactionList[trIndex];
              // ���� ���������� ������ ���������� �������� ������,
              {VNE-0001}
              if assigned(DATransaction) and ((TObject(DATransaction.SourceObj)) is TVpNetOPCGroup) then begin
                gr := TVpNetOPCGroup(DATransaction.SourceObj);
                // � ���� ��������� ����� ������ ���������
                if assigned(gr.ControlThread) then begin
                  grThread := TVpNetOPCGroupControlThread(gr.ControlThread);
                  // �������� ��������� � ���������� ���������� DA-���������� ����� ������
//{21.09.2007}
                  PostThreadMessage(grThread.ThreadId, WM_DA_TRANSACTION_ITEMS_PROCESSED, Integer(DATransaction), 0);
                  Application.ProcessMessages;
//                  ThereAreProcessedItems := true;
{/21.09.2007}
                end;
              end;
            except on e : Exception do
              PostLogRecordAddMsgNow(70379, -1, -1, -1, e.Message);
            end;
            Application.ProcessMessages;
//            sleep(1);
            trIndex := Succ(trIndex);
          end;
{21.09.2007}
//          if ThereAreProcessedItems then begin
//            PostThreadMessage(grThread.ThreadId, WM_DA_TRANSACTION_ITEMS_PROCESSED, Integer(DATransaction), 0);
//            ThereAreProcessedItems := false;
//          end;
{/21.09.2007}
        end;
        sleep(1);
      end;


      // ������� ������ �� ������� ����������
//      {8.02.2009}
      // ������������� � ���, ��� ��� ���������� ���������� HST-�������
      Hst_TID := 0;
//      Hst_Transaction_Exists := false;
//      {/8.02.2009}
    finally
      AttachedDATransactionList.Free;
      Unlock;
    end;

  except on e : Exception do
    PostLogRecordAddMsgNow(70377, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TVpNetHstDriverConnection.Error(aHstTID : DWORD; aErrorCode : HRESULT);
var
  trItemIndex : Integer;
  trItem : TVpNetDATransactionItem;
begin
  try
    Lock;
    try
      // ���� Hst-���������� �� ����� ������� �� ���� ������, ������� ��� ���������
      if Hst_TID = 0 then begin
        PostLogRecordAddMsgNow(70378, -1, -1, -1, '������ HST-����������. ���������� �� �����������');
        exit;
      end;

      // ���������� ������� (��������) ������ � �������� ����������
      try
        Hst_InputData.Clear;
      except on e : Exception do
        PostLogRecordAddMsgNow(70395, e.HelpContext, -1, -1, e.Message);
      end;

      // �������� �� ������ DA-���������� ����������
      trItemIndex := 0;
      while trItemIndex < DATransactionItemList.Count do try

        try
          if not Assigned(DATransactionItemList) then begin
            PostLogRecordAddMsgNow(70398, -1, -1, -1, '');
            continue;
          end;

          trItem := DATransactionItemList[trItemIndex];

          if not Assigned(trItem) then begin
            PostLogRecordAddMsgNow(70883, trItemIndex, DATransactionItemList.Count, -1, '');
            continue;
          end;

        except on e : Exception do
          begin
            PostLogRecordAddMsgNow(70884, e.HelpContext, -1, -1, e.Message);
            continue;
          end;
        end;

        try
          // ���� ��� DA-���������� ������� ������ � ������ Hat-����������, ...
          if trItem.DA_State = vndtsWaitingForResponse then begin
            // �������� ����������

            // ������� ����������� DA-���������� �� ������
            DATransactionItemList.Remove(trItem);
            // ������, ��� � ����� ����� ������� �� ����� ��� ����� ����� trItemIndex := Succ(trItemIndex)
            // � ��������� �� �������� ������� �� ������, ��� ���������� � ���� ������ ������ �� �����.
            trItemIndex := trItemIndex - 1;

            // ��������� �� � �������
            trItem.SetError;

            PostLogRecordAddMsgNow(70885, Integer(trItem.DA_State), Integer(vndtsWaitingForResponse), -1, '������� ���������� �������� � �������');
          end;

        except on e : Exception do
          PostLogRecordAddMsgNow(70886, e.HelpContext, -1, -1, e.Message);
        end;

      finally
        // ��������� ����� ����������
        trItemIndex := Succ(trItemIndex);
      end;

      // ������� ������ �� ������� ����������
      // ������������� � ���, ��� ��� ���������� ���������� HST-�������
      Hst_TID := 0;
    finally
      Unlock;
    end;

  except on e : Exception do
    PostLogRecordAddMsgNow(70887, e.HelpContext, -1, -1, e.Message);
  end;
end;

// 30.11.2011
procedure TVpNetHstDriverConnection.ErrorWithData(aHstTID : DWORD; aHstErrorData: PVpNetHSTErrorData);
var
  trItemIndex : Integer;
  trItem : TVpNetDATransactionItem;
begin
  try
    Lock;
    try
      // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
      // ������ �� ������
      if not(ServerCore.State = vndsWorking) then begin
        PostLogRecordAddMsgNow(70838, Integer(ServerCore.State), -1, -1, '');
        exit;
      end;

      // ���� Hst-���������� �� ����� ������� �� ���� ������, ������� ��� ���������
      if Hst_TID = 0 then begin
        PostLogRecordAddMsgNow(70839, -1, -1, -1, '������ HST-����������. ���������� �� �����������');
        exit;
      end;

      // ���������� ������� (��������) ������ � �������� ����������
      try
        Hst_InputData.Clear;
       Hst_InputData.Size := aHstErrorData^.HstAnswerDataSize;

       Move(aHstErrorData^.HstAnswerData, Hst_InputData.Data, Hst_InputData.Size);

      except on e : Exception do
        PostLogRecordAddMsgNow(70840, e.HelpContext, -1, -1, e.Message);
      end;


      // �������� �� ������ DA-���������� ����������
      trItemIndex := 0;
      while trItemIndex < DATransactionItemList.Count do try

        try
          if not Assigned(DATransactionItemList) then begin
            PostLogRecordAddMsgNow(70882, -1, -1, -1, '');
            continue;
          end;

          trItem := DATransactionItemList[trItemIndex];

          if not Assigned(trItem) then begin
            PostLogRecordAddMsgNow(70397, trItemIndex, DATransactionItemList.Count, -1, '');
            continue;
          end;

        except on e : Exception do
          begin
            PostLogRecordAddMsgNow(70396, e.HelpContext, -1, -1, e.Message);
            continue;
          end;
        end;

        try
          // ���� ��� DA-���������� ������� ������ � ������ Hat-����������, ...
          if trItem.DA_State = vndtsWaitingForResponse then begin
            // �������� ����������

            // ������� ����������� DA-���������� �� ������
            DATransactionItemList.Remove(trItem);
            // ������, ��� � ����� ����� ������� �� ����� ��� ����� ����� trItemIndex := Succ(trItemIndex)
            // � ��������� �� �������� ������� �� ������, ��� ���������� � ���� ������ ������ �� �����.
            trItemIndex := trItemIndex - 1;

            // ��������� �� � �������
            trItem.SetError;

            PostLogRecordAddMsgNow(70380, Integer(trItem.DA_State), Integer(vndtsWaitingForResponse), -1, '������� ���������� �������� � �������');
          end;

        except on e : Exception do
          PostLogRecordAddMsgNow(70399, e.HelpContext, -1, -1, e.Message);
        end;

      finally
        // ��������� ����� ����������
        trItemIndex := Succ(trItemIndex);
      end;

      // ������� ������ �� ������� ����������
      // ������������� � ���, ��� ��� ���������� ���������� HST-�������
      Hst_TID := 0;
    finally
      Unlock;
    end;

  except on e : Exception do
    PostLogRecordAddMsgNow(70381, e.HelpContext, -1, -1, e.Message);
  end;
end;
///30.11.2011

{TVpNetHstDriverConnectionList}
function TVpNetHstDriverConnectionList.Get(Index: Integer): TVpNetHstDriverConnection;
begin
  Result := TVpNetHstDriverConnection(inherited Get(Index));
end;

procedure TVpNetHstDriverConnectionList.Put(Index: Integer; const Value: TVpNetHstDriverConnection);
begin
  inherited Put(Index, Value);
end;

// ������� ������ ���������� �� �������������� �������� Hst-�������
function TVpNetHstDriverConnectionList.FindByDriverId(aDriverId : DWORD) : TVpNetHstDriverConnection;
var
  Index : Integer;
  Conn : TVpNetHstDriverConnection;
begin
  result := nil;
  Index := 0;
  while Index < Count do begin
    Conn := Items[Index];
    if Conn.DriverId = aDriverId then begin
      result := Conn;
      break;
    end;
    Index := Succ(Index);
  end;
end;

// ������� ������ ���������� �� ������� ���������� Hst-�������,
// �������������� ������ �����������
function TVpNetHstDriverConnectionList.FindByCurrHstTID(aHstCurrTID : DWORD) : TVpNetHstDriverConnection;
var
  Index : Integer;
begin
  result := nil;
  Index := 0;
  while Index < Count do begin
    result := Items[Index];
    if result.Hst_TID = aHstCurrTID then begin
      break;
    end;
    Index := Succ(Index);
    result := nil;
  end;
end;

{TVpNetHstDriverConnectionThreadList}
constructor TVpNetHstDriverConnectionThreadList.Create;
begin
  inherited;
  InitializeCriticalSection(FLock);
  FList := TVpNetHstDriverConnectionList.Create;
end;

destructor TVpNetHstDriverConnectionThreadList.Destroy;
begin
  LockList;    // Make sure nobody else is inside the list.
  try
    FList.Free;
    inherited Destroy;
  finally
    UnlockList;
    DeleteCriticalSection(FLock);
  end;
end;

function  TVpNetHstDriverConnectionThreadList.LockList: TVpNetHstDriverConnectionList;
begin
  EnterCriticalSection(FLock);
  Result := FList;
end;

procedure TVpNetHstDriverConnectionThreadList.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;

{
procedure TVpNetHstDriverConnectionThreadList.Add(aConnection : TVpNetHstDriverConnection);
begin
  LockList;
  try
    FList.Add(aConnection);
  finally
    UnlockList;
  end;
end;

procedure TVpNetHstDriverConnectionThreadList.Remove(aConnection : TVpNetHstDriverConnection);
begin
  LockList;
  try
    FList.Remove(aConnection);
  finally
    UnlockList;
  end;
end;

procedure TVpNetHstDriverConnectionThreadList.Clear;
begin
  LockList;
  try
    FList.Clear
end;
}

end.

