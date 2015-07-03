unit VpNetOPCGroup_Impl;
                               
{$WARN SYMBOL_PLATFORM OFF}
{$I 'VpNetDADebugDefs.pas'}
                                                                                                      
interface

uses
  ComObj, ActiveX, AxCtrls, Windows, Classes, Forms, VpNetDA_TLB, StdVcl, 
  OPCTypes, OPCDA, VpNetUtils, OPCerror, VpNetDAClasses, VpNetOPCItem_Impl,
  VpNetDARDM_Impl, SysUtils, DB, VpNetDefs;

type
  TVpNetOPCGroup = class(TAutoObject, IConnectionPointContainer, IVpNetOPCGroup,
    IOPCItemMgt, IOPCGroupStateMgt, IOPCGroupStateMgt2, IOPCPublicGroupStateMgt,
    IOPCItemDeadbandMgt, IOPCSyncIO, IOPCSyncIO2, IOPCAsyncIO2, IOPCAsyncIO,
    IOPCAsyncIO3, IOPCItemSamplingMgt, IDataObject)
  private
    FCS : TRTLCriticalSection; // ����������� ������
    FServObj : Pointer;
    FConnectionPoints: TConnectionPoints;
    FEvents: IVpNetOPCGroupEvents;
    FControlThread : Pointer;
    FRDM : TVpNetDARDM;
    FName : String;
    FActive : LongBool;
    FhClient : OPCHANDLE; // ���������� ������������� ������
    FTimeBais : longint; // ��������� ���� (UTC = (local time) + TimeBais)
    FUpdateRate : DWORD; // ������������ ����� ���������� [��]
    FDeadband : Single;
    FLCID : DWORD; // ������������� LOCALE ������ ������
    FhServer : OPCHANDLE;
    FItems : TVpNetOPCItemList;
    FKeepAlive : DWORD;
    FOPCDataCallback : IOPCDataCallback; // ���������� Callback ���������
    FTransactions : TVpNetDATransactionList; // ������ ����������
  protected
    property ConnectionPoints: TConnectionPoints read FConnectionPoints
      implements IConnectionPointContainer;
    procedure EventSinkChanged(const EventSink: IUnknown); override; // su01, su02

    // IOPCItemMgt
    function AddItems(
            dwCount:                    DWORD;
            pItemArray:                 POPCITEMDEFARRAY;
      out   ppAddResults:               POPCITEMRESULTARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02
    function ValidateItems(
            dwCount:                    DWORD;
            pItemArray:                 POPCITEMDEFARRAY;
            bBlobUpdate:                BOOL;
      out   ppValidationResults:        POPCITEMRESULTARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02
    function RemoveItems(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02
    function SetActiveState(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            bActive:                    BOOL;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02
    function SetClientHandles(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            phClient:                   POPCHANDLEARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02
    function SetDatatypes(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            pRequestedDatatypes:        PVarTypeList;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02
    function CreateEnumerator(
      const riid:                       TIID;
      out   ppUnk:                      IUnknown): HResult; stdcall; // su01, su02

    // IOPCGroupStateMgt
    function GetState(
      out   pUpdateRate:                DWORD;
      out   pActive:                    BOOL;
      out   ppName:                     POleStr;
      out   pTimeBias:                  Longint;
      out   pPercentDeadband:           Single;
      out   pLCID:                      TLCID;
      out   phClientGroup:              OPCHANDLE;
      out   phServerGroup:              OPCHANDLE): HResult; overload; stdcall; // su01, su02
    function SetState(
            pRequestedUpdateRate:       PDWORD;
      out   pRevisedUpdateRate:         DWORD;
            pActive:                    PBOOL;
            pTimeBias:                  PLongint;
            pPercentDeadband:           PSingle;
            pLCID:                      PLCID;
            phClientGroup:              POPCHANDLE): HResult; stdcall; // su01, su02
    function SetName(
            szName:                     POleStr): HResult; stdcall; // su01, su02
    function CloneGroup(
            szName:                     POleStr;
      const riid:                       TIID;
      out   ppUnk:                      IUnknown): HResult; stdcall; // su01, su02

    // IOPCGroupStateMgt2
    function SetKeepAlive(
            dwKeepAliveTime:            DWORD;
      out   pdwRevisedKeepAliveTime:    DWORD): HResult; stdcall; // su01, su02
    function GetKeepAlive(
      out   pdwKeepAliveTime:           DWORD): HResult; stdcall; // su01, su02

    // IOPCPublicGroupStateMgt
    function GetState(
      out   pPublic:                    BOOL): HResult; overload; stdcall; // su02
    function MoveToPublic: HResult; stdcall; // su02

    // IOPCItemDeadbandMgt
    function SetItemDeadband(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            pPercentDeadband:           PSingleArray;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02
    function GetItemDeadband(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
      out   ppPercentDeadband:          PSingleArray;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02
    function ClearItemDeadband(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02

    // IOPCSyncIO
    function Read(
            dwSource:                   OPCDATASOURCE;
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
      out   ppItemValues:               POPCITEMSTATEARRAY;
      out   ppErrors:                   PResultList): HResult; overload; stdcall; // su01, su02
    function Write(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            pItemValues:                POleVariantArray;
      out   ppErrors:                   PResultList): HResult; overload; stdcall; // su01, su02

    // IOPCSyncIO2
    function ReadMaxAge(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            pdwMaxAge:                  PDWORDARRAY;
      out   ppvValues:                  POleVariantArray;
      out   ppwQualities:               PWordArray;
      out   ppftTimeStamps:             PFileTimeArray;
      out   ppErrors:                   PResultList): HResult; overload; stdcall; // su01, su02
    function WriteVQT(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            pItemVQT:                   POPCITEMVQTARRAY;
      out   ppErrors:                   PResultList): HResult; overload; stdcall; // su01, su02

    // IOPCAsyncIO2
    function Read(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            dwTransactionID:            DWORD;
      out   pdwCancelID:                DWORD;
      out   ppErrors:                   PResultList): HResult; overload; stdcall; // su01, su02

    function Write(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            pItemValues:                POleVariantArray;
            dwTransactionID:            DWORD;
      out   pdwCancelID:                DWORD;
      out   ppErrors:                   PResultList): HResult; overload; stdcall; // su01, su02

    function Refresh2(
            dwSource:                   OPCDATASOURCE;
            dwTransactionID:            DWORD;
      out   pdwCancelID:                DWORD): HResult; stdcall; // su01, su02

    function Cancel2(
            dwCancelID:                 DWORD): HResult; stdcall; // su01, su02

    function SetEnable(
            bEnable:                    BOOL): HResult; stdcall; // su01, su02

    function GetEnable(
      out   pbEnable:                   BOOL): HResult; stdcall; // su01, su02

    // IOPCAsyncIO
    function Read(
            dwConnection:               DWORD;
            dwSource:                   OPCDATASOURCE;
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
      out   pTransactionID:             DWORD;
      out   ppErrors:                   PResultList): HResult; overload; stdcall; // su02
    function Write(
            dwConnection:               DWORD;
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            pItemValues:                POleVariantArray;
      out   pTransactionID:             DWORD;
      out   ppErrors:                   PResultList): HResult; overload; stdcall; // su02
    function Refresh(
            dwConnection:               DWORD;
            dwSource:                   OPCDATASOURCE;
      out   pTransactionID:             DWORD): HResult; stdcall; // su02
    function Cancel(
            dwTransactionID:            DWORD): HResult; stdcall; // su02

    //IOPCAsyncIO3
    function ReadMaxAge(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            pdwMaxAge:                  PDWORDARRAY;
            dwTransactionID:            DWORD;
      out   pdwCancelID:                DWORD;
      out   ppErrors:                   PResultList): HResult; overload; stdcall; // su02
    function WriteVQT(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            pItemVQT:                   POPCITEMVQTARRAY;
            dwTransactionID:            DWORD;
      out   pdwCancelID:                DWORD;
      out   ppErrors:                   PResultList): HResult; overload; stdcall; // su02
    function RefreshMaxAge(
            dwMaxAge:                   DWORD;
            dwTransactionID:            DWORD;
      out   pdwCancelID:                DWORD): HResult; stdcall; // su02

//IOPCItemSamplingMgt
    function SetItemSamplingRate(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            pdwRequestedSamplingRate:   PDWORDARRAY;
      out   ppdwRevisedSamplingRate:    PDWORDARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall; // su02
    function GetItemSamplingRate(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
      out   ppdwSamplingRate:           PDWORDARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall; // su02
    function ClearItemSamplingRate(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall; // su02
    function SetItemBufferEnable(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            pbEnable:                   PBOOLARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall; // su02
    function GetItemBufferEnable(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
      out   ppbEnable:                  PBOOLARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall; // su02

    // IDataObject
    function GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium):
      HResult; stdcall; // su02
    function GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium):
      HResult; stdcall; // su02
    function QueryGetData(const formatetc: TFormatEtc): HResult;
      stdcall; // su02
    function GetCanonicalFormatEtc(const formatetc: TFormatEtc;
      out formatetcOut: TFormatEtc): HResult; stdcall; // su02
    function SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
      fRelease: BOOL): HResult; stdcall; // su02
    function EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
      IEnumFormatEtc): HResult; stdcall; // su02
    function DAdvise(const formatetc: TFormatEtc; advf: Longint;
      const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall; // su02
    function DUnadvise(dwConnection: Longint): HResult; stdcall; // su02
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
      stdcall; // su02

  public
    property ServObj : Pointer read FServObj;
    property ControlThread : Pointer read FControlThread;
    property rdm : TVpNetDARDM read FRDM;
    property Name : String read FName;
    property Active : LongBool read FActive;
    property UpdateRate : DWORD read FUpdateRate;
    property hClient : OPCHANDLE read FhClient;
    property hServer : OPCHANDLE read FhServer;
    property TimeBais : longint read FTimeBais;
    property Deadband : Single read FDeadband;
    property LCID : DWORD read FLCID;
    property KeepAlive: DWORD read FKeepAlive;
    property Items : TVpNetOPCItemList read FItems write FItems;
    property Transactions : TVpNetDATransactionList read FTransactions;

    constructor Create;overload; // su01
    constructor Create(aServObj : Pointer; aName : String; aActive : LongBool;
      aUpdateRate : DWORD; ahClient : OPCHANDLE; pTimeBais : PLongint;
      aDeadBand : Single; aLCID : TLCID; ahServer : OPCHANDLE); overload; // su01
    procedure Initialize; override; // su01
    destructor destroy;override; // su01
    procedure Lock; // su01
    procedure Unlock; // su01
    function ValidateTimeBias(pTimeBias : PLongint) : longint; // su01
    function FindItemByhServer(hServer : OPCHANDLE; out Item : TVpNetOPCItem): HRESULT; // su01
    function FindItemByItemId(aItemId : String; out Item : TVpNetOPCItem): HRESULT; // su01

    function _Read(
            dwCount:                    DWORD;
            phServer:                   POPCHANDLEARRAY;
            dwSource:                   DWORD; // �������� ������ (Device/CACHE)
            pdwMaxAge:                  PDWORDARRAY;
            SyncType:                   TVpNetDATransactionSyncType;
            InvocationType:             TVpNetDATransactionInvocationType; // ��� ��������� ������������� ����������
            dwClientTransactionId:      DWORD; // �������� �������� ������������� ����������
            dwClientCancelId:           DWORD; // �������� �������� ������������� ������ ����������
      out   phClients:                  POPCHANDLEARRAY; // ���������� �������������� ��������� (�����) ����������
      out   ppvValues:                  POleVariantArray;
      out   ppwQualities:               PWordArray;
      out   ppftTimeStamps:             PFileTimeArray;
      out   ppErrors:                   PResultList
    ): HResult; stdcall; // su01

    procedure CallBackOnConnect(const Sink: IUnknown; Connecting: Boolean); // su01
    function DoCallOnDataChange(tr : TVpNetDATransaction) : HRESULT; // su01
    function DoCallOnReadCompleted(tr : TVpNetDATransaction) : HRESULT; // su01
  end;

implementation

uses ComServ, VpNetDADefs, VpNetDAServerCore, Math, uEnumOPCItemAttributes,
  uOPCUtils, VpNetOPCDA_Impl, VpNetOPCGroupControlThread, Variants, VpNetDADebug;

procedure TVpNetOPCGroup.EventSinkChanged(const EventSink: IUnknown);
begin
  try
    FEvents := EventSink as IVpNetOPCGroupEvents;
  except on e : Exception do
    PostLogRecordAddMsgNow(70166, -1, -1, E_FAIL, '���������� �������: ' + e.Message, llErrors);
  end;
end;

constructor TVpNetOPCGroup.Create;
begin
  try
    inherited;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70260, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
    end;
  end;

  try
    // ������������� ����������� ������
    InitializeCriticalSection(FCS);
    // ��������� ��������� (��������������) �������� ������� ������
    FServObj := nil;

    ServerCore.DBLock;
    try
      FRDM := TVpNetDARDM.Create(nil);
    finally
      ServerCore.DBUnlock;
    end;

    FName := '';
    FActive := false;
    FUpdateRate := 0;
    FhClient := UnassignedGroupHandle;
    FTimeBais := ValidateTimeBias(nil);
    FDeadBand := 0;
    FLCID := LOCALE_SYSTEM_DEFAULT;
    FhServer := UnassignedGroupHandle;
    FKeepAlive := 0;

    // �������� ������ ��������� ������
    FItems := TVpNetOPCItemList.Create;

    // ������ ����������� DA-���������� ������
    FTransactions := TVpNetDATransactionList.Create;

    // �������� � ������ �������������� ������
    FControlThread := TVpNetOPCGroupControlThread.Create(self, false);

    //--- ConnectionPoints ---
    // ���������� ���������� callback ��������� �� ���������
    FOPCDataCallback := nil;

    // ��������� � ���������� ������
    PostMessage(Application.MainForm.Handle, WM_DA_GROUP_CREATED, 0, 0);

  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70261, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
    end;
  end;
end;

constructor TVpNetOPCGroup.Create(aServObj : Pointer; aName : String; aActive : LongBool;
  aUpdateRate : DWORD; ahClient : OPCHANDLE; pTimeBais : PLongint;
  aDeadBand : Single; aLCID : TLCID; ahServer : OPCHANDLE);
begin
  try
    Create;
    // ��������� ��������� (���������� � �����������) �������� ������� ������
    FServObj := aServObj;
    FName := aName;
    FActive := aActive;
    FUpdateRate := aUpdateRate;
    FhClient := ahClient;
    FTimeBais := ValidateTimeBias(pTimeBais);
    FDeadBand := aDeadBand;
    FLCID := aLCID;
    FhServer := ahServer;
    PostProcessInfoNow(70017, '�������� ������ (hSrv='+IntToStr(FhServer)+'; hClient='+IntToStr(FhClient)+').');
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70262, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
    end;
  end;
end;

procedure TVpNetOPCGroup.Initialize;
begin
  try
    inherited Initialize;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70263, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
    end;
  end;

  try
    // �������� �������-����������, ������������ ��������� IConnectionPointContainer
    FConnectionPoints := TConnectionPoints.Create(Self);
    if AutoFactory.EventTypeInfo <> nil then
      FConnectionPoints.CreateConnectionPoint(
        IID_IOPCDataCallback, {AutoFactory.EventIID} //todo: �����������
        ckSingle, //ckMulti
        CallBackOnConnect
      );
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70264, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
    end;
  end;
end;

destructor TVpNetOPCGroup.destroy;
var
  Item : TVpNetOPCItem;
begin
  try
    try
      PostProcessInfoNow(70018, '�������� ������ (hSrv='+IntToStr(FhServer)+'; hClient='+IntToStr(FhClient)+').');
      // ��������� ������
      Lock;
      try
        // ��������� �� �������� ������
        PostMessage(Application.MainForm.Handle, WM_DA_GROUP_DESTROYED, 0, 0);

        // ��������� ������������� �����
        TVpNetOPCGroupControlThread(FControlThread).Terminate;

        // ������� ���������� �������������� ������
        TVpNetOPCGroupControlThread(FControlThread).WaitFor;

        // �������� �������� ����������
        Transactions.DeleteTransactions;
        Transactions.Free;

        // ������� ��������
        while FItems.Count > 0 do begin
          Item := FItems[0];
          FItems.Delete(0);
          Item.Free;
        end;
        FItems.Free;

        ServerCore.DBLock;
        try
          FRDM.Free;
        finally
          ServerCore.DBUnlock;
        end;
      finally
        // ������������ ������
        Unlock;
        // ������� ����������� ������
        DeleteCriticalSection(FCS);
      end;
    except
      on e : Exception do begin
        PostLogRecordAddMsgNow(70266, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
      end;
    end;
  finally
    try
      inherited destroy;
    except
      on e : Exception do begin
        PostLogRecordAddMsgNow(70265, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
      end;
    end;
  end;
end;

procedure TVpNetOPCGroup.Lock;
begin
  try
    EnterCriticalSection(FCS);
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70267, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
    end;
  end;
end;

procedure TVpNetOPCGroup.Unlock;
begin
  try
    LeaveCriticalSection(FCS);
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70268, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
    end;
  end;
end;

function TVpNetOPCGroup.ValidateTimeBias(pTimeBias : PLongint) : longint;
var
 timeZoneRec:TTimeZoneInformation;
begin
  try
    if assigned(pTimeBias) then begin
      result := pTimeBias^;
    end else begin
      GetTimeZoneInformation(timeZoneRec);
      result := timeZoneRec.bias;
    end;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70269, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
    end;
  end;
end;

function TVpNetOPCGroup.FindItemByhServer(hServer : OPCHANDLE; out Item : TVpNetOPCItem): HRESULT;
var
  ItemIndex : Integer;
begin
  try
    ItemIndex := 0;
    Item := nil;
    result := OPC_E_INVALIDHANDLE;
    while ItemIndex < Items.Count do begin
      if Items[ItemIndex].hServer = hServer then begin
        Item := Items[ItemIndex];
        result := S_OK;
        break;
      end;
      ItemIndex := Succ(ItemIndex);
    end;
    if not(result = S_OK) then begin
      PostLogRecordAddMsgNow(70271, hServer, -1, result, '��� �� ������');
    end;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70270, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetOPCGroup.FindItemByItemId(aItemId : String; out Item : TVpNetOPCItem): HRESULT;
var
  ItemIndex : Integer;
begin
  try
    ItemIndex := 0;
    Item := nil;
    result := OPC_E_UNKNOWNITEMID;
    while ItemIndex < Items.Count do begin
      if Items[ItemIndex].ItemId = aItemId then begin
        Item := Items[ItemIndex];
        result := S_OK;
        break;
      end;
      ItemIndex := Succ(ItemIndex);
    end;
    if not(result = S_OK) then begin
      PostLogRecordAddMsgNow(70273, hServer, -1, result, '��� �� ������');
    end;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70272, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
      result := E_FAIL;
    end;
  end;
end;


// IOPCItemMgt
function TVpNetOPCGroup.AddItems(
        dwCount:                    DWORD;
        pItemArray:                 POPCITEMDEFARRAY;
  out   ppAddResults:               POPCITEMRESULTARRAY;
  out   ppErrors:                   PResultList): HResult;
var
  ItemIndex : DWORD;
  ErrorCount : DWORD;
  pItemDef : POPCITEMDEF;
  pItemResult : POPCITEMRESULT;
  Item : TVpNetOPCItem;
  hr : HResult;
begin
  try
    PostLogRecordAddMsgNow(70804, -1, -1, S_OK, '����� ������', llDebug);
    // �������� �������� �������
    ppAddResults := nil;
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70168, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      try
        // �������� ���������� ���������
        if (dwCount = 0) then begin
          // ���� ���������� ��������� ������������, ������� � E_INVALIDARG
          PostLogRecordAddMsgNow(70866, 0, -1, E_INVALIDARG, '', llErrors);
          result := E_INVALIDARG;
          exit;
        end;

        // ��������� ������ ��� ������� ppAddResults
        ppAddResults := POPCITEMRESULTARRAY(CoTaskMemAlloc(dwCount * sizeof(OPCITEMRESULT)));
        if ppAddResults = nil then begin
          PostLogRecordAddMsgNow(70169, -1, -1, E_OUTOFMEMORY, '������ ��������� ������', llErrors);
          // ���� �� �����-�� �������� �� ������� �������� ������ ��� ������� ppAddResults,
          // ������� � E_OUTOFMEMORY
          result := E_OUTOFMEMORY;
          exit;
        end;

        // ������� ���������� ��������� ������� ppAddResults
        hr := ClearPOPCITEMRESULTARRAY(ppAddResults, dwCount);
        if hr <> S_OK then begin
          PostLogRecordAddMsgNow(70170, -1, -1, hr, '', llErrors);
          // ���� �� �����-�� �������� �� ������� �������� ������,
          // ������� �������, ������������ � �������� ������� �������
          CoTaskMemFree(ppAddResults);
          ppAddResults := nil;
          result := hr;
          exit;
        end;

        // ��������� ������ ��� ������� ppErrors
        ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
        if ppErrors = nil then begin
          // �� �����-�� �������� �� ������� �������� ������ ��� ������� ppErrors,
          // ������� ������� � E_OUTOFMEMORY
          PostLogRecordAddMsgNow(70171, -1, -1, E_OUTOFMEMORY, '', llErrors);
          CoTaskMemFree(ppAddResults);
          ppAddResults := nil;
          result := E_OUTOFMEMORY;
          exit;
        end;

        // ���� �� ���������
        ItemIndex := 0;
        ErrorCount := 0;
        while ItemIndex < dwCount do begin
          // �������� ������ �� �������� ��������
          pItemDef := @pItemArray[ItemIndex];
          // �������� ������ �� ��������� ����������� ��� ��������
          pItemResult := @ppAddResults[ItemIndex];

          // ������� Item
          Item := TVpNetOPCItem.Create(self);
          // �������������� Item �� ItemID (pItemDef.szItemID)
          // (��������� ItemId, VHS_ID, VD_ID, VDTT_ID, ...)

          ppErrors[ItemIndex] := Item.InitByItemDef(pItemDef);
          if ppErrors[ItemIndex] <> S_OK then begin
            Item.free;
            ErrorCount := ErrorCount + 1;
            ItemIndex := ItemIndex + 1;
            continue;
          end;

          // ��������� Item � ������ Item-�� ������
          Items.add(Item);

          // ��������� ��������� �� Item � ��������� ppAddResults[ItemIndex] :
          pItemResult.hServer := Item.hServer;
          pItemResult.dwAccessRights := Item.AccessRights;
          pItemResult.vtCanonicalDataType := Item.CanonicalDataType;
          pItemResult.dwBlobSize := Item.BlobSize;
          if Item.BlobSize > 0 then begin
            pItemResult.pBlob := CoTaskMemAlloc(Item.BlobSize);
            if pItemResult.pBlob <> nil then begin
              try
                move(Item.pBlob, pItemResult.pBlob, Item.BlobSize);
              except
                CoTaskMemFree(pItemResult.pBlob);
                pItemResult.pBlob := nil;
                pItemResult.dwBlobSize := 0;
                ppErrors[ItemIndex] := E_FAIL;
              end;
            end else begin
              pItemResult.dwBlobSize := 0;
              ppErrors[ItemIndex] := E_OUTOFMEMORY;
            end;
          end;

          ItemIndex := ItemIndex + 1;
        end;

        // ���� � ��������� ��������� ������ ������, ���������� S_OK,
        // ����� ���������� S_FALSE
        if ErrorCount = 0 then
          result := S_OK
        else
          result := S_FALSE;
      except on e : Exception do begin
        // � ������ �������������� ������ ...
        // ... ���� ������ ���� ��������, ����������� ��, ...
        PostLogRecordAddMsgNow(70172, -1, -1, E_FAIL, '���������� �������: ' + e.Message, llErrors);
        if assigned(ppAddResults) then begin
          CoTaskMemFree(ppAddResults);
          ppAddResults := nil;
        end;
        if Assigned(ppErrors) then begin
          CoTaskMemFree(ppErrors);
          ppErrors := nil;
        end;
        // ... � ���������� E_FAIL
        result := E_FAIL;
      end;
      end;
    finally
      Unlock;
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70167, -1, -1, E_FAIL, '���������� �������: ' + e.Message, llErrors);
  end;
end;

function TVpNetOPCGroup.ValidateItems(
        dwCount:                    DWORD;
        pItemArray:                 POPCITEMDEFARRAY;
        bBlobUpdate:                BOOL;
  out   ppValidationResults:        POPCITEMRESULTARRAY;
  out   ppErrors:                   PResultList): HResult;
var
  ItemIndex : DWORD;
  ErrorCount : DWORD;
  pItemDef : POPCITEMDEF;
  pItemResult : POPCITEMRESULT;
//  VDTT_ID : Integer;
  Item : TVpNetOPCItem;
  hr : HRESULT;
begin
  try
    PostLogRecordAddMsgNow(70805, -1, -1, S_OK, '����� ������', llDebug);
    // �������� �������� �������
    ppValidationResults := nil;
    ppErrors := nil;

{09.07.2006}
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70174, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // �������� ���������� ���������
    if (dwCount = 0) then begin
      // ���� ���������� ��������� ������������, ������� � E_INVALIDARG
      PostLogRecordAddMsgNow(70175, -1, dwCount, E_INVALIDARG, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // ��������� ������ ��� ������� ppValidationResults
    ppValidationResults := POPCITEMRESULTARRAY(CoTaskMemAlloc(dwCount * sizeof(OPCITEMRESULT)));
    if ppValidationResults = nil then begin
      // �� �����-�� �������� �� ������� �������� ������ ��� ������� ppValidationResults,
      // ������� ������� � E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70176, -1, -1, E_OUTOFMEMORY, '', llErrors);
      result := E_OUTOFMEMORY;
      exit;
    end;

    // ������� ���������� ��������� ������� ppValidationResults
    hr := ClearPOPCITEMRESULTARRAY(ppValidationResults, dwCount);
    if hr <> S_OK then begin
      // �� �����-�� �������� �� ������� �������� ���������� �������
      // ppValidationResults, ������� � ���������� �������
      PostLogRecordAddMsgNow(70177, -1, -1, hr, '', llErrors);
      CoTaskMemFree(ppValidationResults);
      ppValidationResults := nil;
      result := hr;
      exit;
    end;

    // ��������� ������ ��� ������� ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if ppErrors = nil then begin
      // �� �����-�� �������� �� ������� �������� ������ ��� ������� ppErrors,
      // ������� ������� � E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70178, -1, -1, E_OUTOFMEMORY, '', llErrors);
      CoTaskMemFree(ppValidationResults);
      ppValidationResults := nil;
      result := E_OUTOFMEMORY;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      // ���� �� ���������
      ItemIndex := 0;
      ErrorCount := 0;
      while ItemIndex < dwCount do begin
        // �������� ������ �� �������� ��������
        pItemDef := @pItemArray[ItemIndex];
        // �������� ������ �� ��������� ����������� ��� ��������
        pItemResult := @ppValidationResults[ItemIndex];

        // ������� ��������� Item
        Item := TVpNetOPCItem.Create(self);
        try
          // �������������� Item �� ItemID (pItemDef.szItemID)
          // ��������� ���������:
          // - ItemId,
          // - VHS_ID,
          // - VD_ID,
          // - VDTT_ID,
          // - AccessRights
          // - CanonicalDatatype
          ppErrors[ItemIndex] := Item.InitByItemDef(pItemDef);
          if ppErrors[ItemIndex] <> S_OK then begin
            Item.free;
            ErrorCount := ErrorCount + 1;
            ItemIndex := ItemIndex + 1;
            continue;
          end;

          // ��������� ��������� �� Item � ��������� ppValidationResults[ItemIndex] :
          pItemResult.hServer := Item.hServer;
          pItemResult.dwAccessRights := Item.AccessRights;
          pItemResult.vtCanonicalDataType := Item.CanonicalDataType;
          pItemResult.dwBlobSize := Item.BlobSize;
          if Item.BlobSize > 0 then begin
            pItemResult.pBlob := CoTaskMemAlloc(Item.BlobSize);
            if pItemResult.pBlob <> nil then begin
              try
                move(Item.pBlob, pItemResult.pBlob, Item.BlobSize);
              except
                CoTaskMemFree(pItemResult.pBlob);
                pItemResult.pBlob := nil;
                pItemResult.dwBlobSize := 0;
                ppErrors[ItemIndex] := E_FAIL;
              end;
            end else begin
              pItemResult.dwBlobSize := 0;
              ppErrors[ItemIndex] := E_OUTOFMEMORY;
            end;
          end;
        finally
          Item.free;
        end;
        ItemIndex := ItemIndex + 1;
      end;
    finally
      // ������������ ������
      Unlock;
    end;

    // ���� � ��������� ��������� ������ ������, ���������� S_OK,
    // ����� ���������� S_FALSE
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;

  except on e : Exception do begin
    // � ������ �������������� ������ ...
    // ... ���� ������ ���� ��������, ����������� ��, ...
    PostLogRecordAddMsgNow(70173, -1, -1, E_FAIL, e.Message, llErrors);
    if assigned(ppValidationResults) then begin
      CoTaskMemFree(ppValidationResults);
      ppValidationResults := nil;
    end;
    if Assigned(ppErrors) then begin
      CoTaskMemFree(ppErrors);
      ppErrors := nil;
    end;
    // ... � ���������� E_FAIL
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCGroup.RemoveItems(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
  out   ppErrors:                   PResultList): HResult;
var
  InputArrayIndex : DWORD;
  ErrorCount : DWORD;
  hOPC : OPCHANDLE;
  hr : HRESULT;
  Item : TVpNetOPCItem;
begin
  try
    PostLogRecordAddMsgNow(70806, -1, -1, S_OK, '����� ������', llDebug);
    // �������� �������� ������
    ppErrors := nil;

  {09.07.2006}
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70867, -1, Integer(ServerCore.State), E_FAIL, '����� ������', llErrors);
      result := E_FAIL;
      exit;
    end;
  {/09.07.2006}

    // ��������� ������
    Lock;
    try
      try
        // �������� ���������� ���������
        if (dwCount = 0) then begin
          // ���� ���������� ��������� ������������, ������� � E_INVALIDARG
          PostLogRecordAddMsgNow(70868, -1, 0, E_INVALIDARG, '', llErrors);
          result := E_INVALIDARG;
          exit;
        end;

        // ��������� ������ ��� ������� ppErrors
        ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
        if ppErrors = nil then begin
          // ���� �� �����-�� �������� �� ������� �������� ������ ��� ������� ppAddResults,
          // ������� � E_FAIL (��������� ������� E_OUTOFMEMORY �� ������������ �������������)
          PostLogRecordAddMsgNow(70869, -1, -1, E_FAIL, '', llErrors);
          result := E_FAIL;
          exit;
        end;

        // ���� �� ������ ��������� ���������
        InputArrayIndex := 0;
        ErrorCount := 0;
        while InputArrayIndex < dwCount do begin
          // ������� ��������� �����. ���������� ���������� ��������
          hOPC := phServer^[InputArrayIndex];
          // �������� ����� �� ���������� ������ �������
          hr := FindItemByhServer(hOPC, Item);
          // ����������� ��������� ������
          if hr = S_OK then begin
            // ���� �����, ������� ��������� ������� �� ������,...
            Items.Remove(Item);
            // � ���������� ��� ����� �������� S_OK
            ppErrors[InputArrayIndex] := S_OK;
          end else if hr = OPC_E_INVALIDHANDLE then begin
            // ���� �� �����, ��� ����� �������� ���������� OPC_E_INVALIDHANDLE
            PostLogRecordAddMsgNow(70870, -1, hr, OPC_E_INVALIDHANDLE, '', llErrors);
            ppErrors[InputArrayIndex] := OPC_E_INVALIDHANDLE;
          end else begin
            // ���� ��������� �������������� ������, ���� ������ ���� ��������, ����������� ��, ...
            PostLogRecordAddMsgNow(70871, -1, hr, E_FAIL, '', llErrors);
            if Assigned(ppErrors) then begin
              CoTaskMemFree(ppErrors);
              ppErrors := nil;
            end;
            // ... � ������� � E_FAIL
            result := E_FAIL;
            exit;
          end;
          // ��������� � ���������� ���������� ��������
          InputArrayIndex := Succ(InputArrayIndex);
        end;

        // ���������� �������� ���������
        if ErrorCount = 0 then
          result := S_OK
        else
          result := S_FALSE;

      except on e : Exception do begin
        // � ������ �������������� ������ ...
        // ... ���� ������ ���� ��������, ����������� ��, ...
        PostLogRecordAddMsgNow(70180, -1, -1, E_FAIL, e.Message, llErrors);
        if Assigned(ppErrors) then begin
          CoTaskMemFree(ppErrors);
          ppErrors := nil;
        end;
        // ... � ���������� E_FAIL
        result := E_FAIL;
      end;
      end;
    finally
      // ������������ ������
      Unlock;
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70179, -1, -1, E_FAIL, e.Message, llErrors);
  end;
end;

function TVpNetOPCGroup.SetActiveState(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        bActive:                    BOOL;
  out   ppErrors:                   PResultList): HResult;
var
  InputArrayIndex : DWORD;
  ErrorCount : DWORD;
  hOPC : OPCHANDLE;
  hr : HRESULT;
  Item : TVpNetOPCItem;
begin
  try
    PostLogRecordAddMsgNow(70807, -1, -1, S_OK, '����� ������', llDebug);
    // �������� �������� ������
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70182, -1, -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      try
        // �������� ���������� ���������
        if (dwCount = 0) then begin
          // ���� ���������� ��������� ������������, ������� � E_INVALIDARG
          PostLogRecordAddMsgNow(70183, -1, dwCount, E_INVALIDARG, '', llErrors);
          result := E_INVALIDARG;
          exit;
        end;

        // ��������� ������ ��� ������� ppErrors
        ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
        if ppErrors = nil then begin
          // ���� �� �����-�� �������� �� ������� �������� ������ ��� ������� ppAddResults,
          // ������� � E_FAIL (��������� ������� E_OUTOFMEMORY �� ������������ �������������)
          PostLogRecordAddMsgNow(70184, -1, -1, E_FAIL, '', llErrors);
          result := E_FAIL;
          exit;
        end;

        // ���� �� ������ ��������� ���������
        InputArrayIndex := 0;
        ErrorCount := 0;
        while InputArrayIndex < dwCount do begin
          // ������� ��������� �����. ���������� �������� ��������� ������
          hOPC := phServer^[InputArrayIndex];
          // �������� ����� �� ���������� ������ �������
          hr := FindItemByhServer(hOPC, Item);
          // ����������� ��������� ������
          if hr = S_OK then begin
            // ���� �����, �������� ��������� ��������� ���������� �������� �� ��������,...
            // � ���������� ��� ����� �������� ���������
            ppErrors[InputArrayIndex] := Item.SetActive(bActive);
          end else if hr = OPC_E_INVALIDHANDLE then begin
            // ���� �� �����, ��� ����� �������� ���������� OPC_E_INVALIDHANDLE
            PostLogRecordAddMsgNow(70872, -1, hr, OPC_E_INVALIDHANDLE, '', llErrors);
            ppErrors[InputArrayIndex] := OPC_E_INVALIDHANDLE;
          end else begin
            // ���� ��������� �������������� ������, ...
            // ... ���� ������ ���� ��������, ����������� ��, ...
            PostLogRecordAddMsgNow(70185, -1, hr, E_FAIL, '', llErrors);
            if Assigned(ppErrors) then begin
              CoTaskMemFree(ppErrors);
              ppErrors := nil;
            end;
            // ... � ������� � E_FAIL
            result := E_FAIL;
            exit;
          end;

          // ��������� � ���������� ���������� ��������
          InputArrayIndex := Succ(InputArrayIndex);
        end;

        // ���������� �������� ���������
        if ErrorCount = 0 then
          result := S_OK
        else
          result := S_FALSE;
      except on e : Exception do begin
        // � ������ �������������� ������ ...
        // ... ���� ������ ���� ��������, ����������� ��, ...
        PostLogRecordAddMsgNow(70186, -1, -1, E_FAIL, e.Message, llErrors);
        if Assigned(ppErrors) then begin
          CoTaskMemFree(ppErrors);
          ppErrors := nil;
        end;
        // ... � ���������� E_FAIL
        result := E_FAIL;
      end;
      end;
    finally
      // ������������ ������
      Unlock;
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70181, -1, -1, E_FAIL, e.Message, llErrors);
  end;
end;

function TVpNetOPCGroup.SetClientHandles(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        phClient:                   POPCHANDLEARRAY;
  out   ppErrors:                   PResultList): HResult;
var
  InputArrayIndex : DWORD;
  ErrorCount : DWORD;
  hOPC : OPCHANDLE;
  hr : HRESULT;
  Item : TVpNetOPCItem;
begin
  try
    PostLogRecordAddMsgNow(70808, -1, -1, S_OK, '����� ������', llDebug);
    // �������� �������� ������
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70188, -1, -1, E_FAIL, '', llErrors);
      result := E_FAIL;
      exit;
    end;

    // �������� ���������� ���������
    if (dwCount = 0) then begin
      // ���� ���������� ��������� ������������, ������� � E_INVALIDARG
      PostLogRecordAddMsgNow(70189, -1, -1, E_INVALIDARG, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // ��������� ������ ��� ������� ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if ppErrors = nil then begin
      // ���� �� �����-�� �������� �� ������� �������� ������ ��� ������� ppAddResults,
      // ������� � E_FAIL (��������� ������� E_OUTOFMEMORY �� ������������ �������������)
      PostLogRecordAddMsgNow(70190, -1, -1, E_FAIL, '', llErrors);
      result := E_FAIL;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      // ���� �� ������ ��������� ���������
      InputArrayIndex := 0;
      ErrorCount := 0;
      while InputArrayIndex < dwCount do begin
        // ������� ��������� �����. ���������� �������� ��������� ������
        hOPC := phServer^[InputArrayIndex];
        // �������� ����� �� ���������� ������ �������
        hr := FindItemByhServer(hOPC, Item);
        // ����������� ��������� ������
        if hr = S_OK then begin
          // ���� �����, �������� ��������� ��������� ���������� �������� �� ��������,...
          // � ���������� ��� ����� �������� ���������
          ppErrors[InputArrayIndex] := Item.SethClient(phClient^[InputArrayIndex]);
        end else if hr = OPC_E_INVALIDHANDLE then begin
          // ���� �� �����, ��� ����� �������� ���������� OPC_E_INVALIDHANDLE
          PostLogRecordAddMsgNow(70873, -1, hr, OPC_E_INVALIDHANDLE, '', llErrors);
          ppErrors[InputArrayIndex] := OPC_E_INVALIDHANDLE;
        end else begin
          // ���� ��������� �������������� ������, ...
          // ... ���� ������ ���� ��������, ����������� ��, ...
          if Assigned(ppErrors) then begin
            CoTaskMemFree(ppErrors);
            ppErrors := nil;
          end;
          // ... � ������� � E_FAIL
          PostLogRecordAddMsgNow(70191, hr, -1, E_FAIL, '', llErrors);
          result := E_FAIL;
          exit;
        end;

        // ��������� � ���������� ���������� ��������
        InputArrayIndex := Succ(InputArrayIndex);
      end;
    finally
      // ������������ ������
      Unlock;
    end;

    // ���������� �������� ���������
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;

  except on e : Exception do begin
    // � ������ �������������� ������ ...
    // ... ���� ������ ���� ��������, ����������� ��, ...
    PostLogRecordAddMsgNow(70187, -1, -1, E_FAIL, e.Message, llErrors);
    if Assigned(ppErrors) then begin
      CoTaskMemFree(ppErrors);
      ppErrors := nil;
    end;
    // ... � ���������� E_FAIL
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCGroup.SetDatatypes(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pRequestedDatatypes:        PVarTypeList;
  out   ppErrors:                   PResultList): HResult;
var
  InputArrayIndex : DWORD;
  ErrorCount : DWORD;
  hOPC : OPCHANDLE;
  hr : HRESULT;
  Item : TVpNetOPCItem;
  NewDataType : TVarType;
begin
  try
    PostLogRecordAddMsgNow(70809, -1, -1, S_OK, '����� ������', llDebug);
    // �������� �������� ������
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70193, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // �������� ���������� ���������
    if (dwCount = 0) then begin
      // ���� ���������� ��������� ������������, ������� � E_INVALIDARG
      PostLogRecordAddMsgNow(70194, -1, -1, E_FAIL, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // ��������� ������ ��� ������� ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if ppErrors = nil then begin
      // ���� �� �����-�� �������� �� ������� �������� ������ ��� ������� ppAddResults,
      // ������� � E_FAIL (��������� ������� E_OUTOFMEMORY �� ������������ �������������)
      PostLogRecordAddMsgNow(70195, -1, -1, E_FAIL, '', llErrors);
      result := E_FAIL;
      exit;
    end;

    //��������� ������
    Lock;
    try
      // ���� �� ������ ��������� ���������
      InputArrayIndex := 0;
      ErrorCount := 0;
      while InputArrayIndex < dwCount do begin

        // ������� ��������� �����. ���������� �������� ��������� ������
        hOPC := phServer^[InputArrayIndex];
        // �������� ����� �� ���������� ������ �������
        hr := FindItemByhServer(hOPC, Item);
        // ����������� ��������� ������
        if hr = S_OK then begin
          NewDataType := pRequestedDatatypes^[InputArrayIndex];
          // ���� �����, �������� �������� ������������� ��� ������ ���������� �������� (Item.RequestedDataType) �� ��������  ,...
          ppErrors[InputArrayIndex] := Item.SetNewRequestedDataType(NewDataType);

          // ���� �������� �� ��������� ���� ������������� ����� ����������� �� �������,...
          if ppErrors[InputArrayIndex] <> S_OK then begin
            // ...��������� ������� ������
            ErrorCount := Succ(ErrorCount);
          end;

        end else if hr = OPC_E_INVALIDHANDLE then begin
          // ���� �� �����, ��� ����� �������� ���������� OPC_E_INVALIDHANDLE
          PostLogRecordAddMsgNow(70874, hr, -1, OPC_E_INVALIDHANDLE, '', llErrors);
          ppErrors[InputArrayIndex] := OPC_E_INVALIDHANDLE;
          ErrorCount := Succ(ErrorCount);
        end else begin
          // ���� ��������� �������������� ������, ...
          // ... ���� ������ ���� ��������, ����������� ��, ...
          if Assigned(ppErrors) then begin
            CoTaskMemFree(ppErrors);
            ppErrors := nil;
          end;
          // ... � ������� � E_FAIL
          PostLogRecordAddMsgNow(70196, hr, -1, E_FAIL, '', llErrors);
          result := E_FAIL;
          exit;
        end;

        // ��������� � ���������� ���������� ��������
        InputArrayIndex := Succ(InputArrayIndex);
      end;
    finally
      // ������������ ������
      Unlock;
    end;

    // ���������� ������� ���������
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;

  except on e : Exception do begin
    // � ������ �������������� ������ ...
    // ... ���� ������ ���� ��������, ����������� ��, ...
    PostLogRecordAddMsgNow(70192, hr, -1, E_FAIL, e.Message, llErrors);
    if Assigned(ppErrors) then begin
      CoTaskMemFree(ppErrors);
      ppErrors := nil;
    end;
    // ... � ���������� E_FAIL
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCGroup.CreateEnumerator(
  const riid:                       TIID;
  out   ppUnk:                      IUnknown): HResult;
//var
//  pOPCItemAttr : POPCITEMATTRIBUTES;
//  Index : Integer;
//  q : Integer;
begin
  try
    PostLogRecordAddMsgNow(70810, -1, -1, S_OK, '����� ������', llDebug);
    // ������ ��������� �������� ppUnk;
    ppUnk := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70198, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // ���� �������� ������������ ��� ������������, ���������� E_INVALIDARG
    if not IsEqualIID(riid, IEnumOPCItemAttributes) then begin
      PostLogRecordAddMsgNow(70199, -1, -1, E_INVALIDARG, '�������� ������������ ��� ������������', llErrors);
      result := E_INVALIDARG;
      exit;
    end;
    // ��������� ������
    Lock;
    try
      // ���� ������ �����������, ���������� S_FALSE
      if (Items.count = 0) then begin
        result := S_FALSE;
        exit;
      end;
      // ������� ������������ ��� ���������
//      ppUnk := CreateComObject(IID_IEnumOPCItemAttributes) as IEnumOPCItemAttributes;
//      ppUnk := TVpNetOPCItemAttributesEnumerator.Create(FItems) as IEnumOPCItemAttributes;
      ppUnk := TVpNetOPCItemAttributesEnumerator.Create(FItems);

    finally
      // ������������ ������
      Unlock;
    end;
    result := S_OK;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70197, -1, -1, E_FAIL, e.Message, llErrors);
      ppUnk := nil;
      result := E_FAIL;
    end;
  end;
end;

// IOPCGroupStateMgt
function TVpNetOPCGroup.GetState(
  out   pUpdateRate:                DWORD;
  out   pActive:                    BOOL;
  out   ppName:                     POleStr;
  out   pTimeBias:                  Longint;
  out   pPercentDeadband:           Single;
  out   pLCID:                      TLCID;
  out   phClientGroup:              OPCHANDLE;
  out   phServerGroup:              OPCHANDLE): HResult;
begin
  try
    PostLogRecordAddMsgNow(70811, -1, -1, S_OK, '����� ������', llDebug);

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70201, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      pUpdateRate := FUpdateRate;
      pActive := FActive;
      pTimeBias := FTimeBais;
      pPercentDeadband := FDeadBand;
      pLCID := FLCID;
      phClientGroup := FhClient;
      phServerGroup := FhServer;
      result := E_FAIL;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      pUpdateRate := FUpdateRate;
      pActive := FActive;
      pTimeBias := FTimeBais;
      pPercentDeadband := FDeadBand;
      pLCID := FLCID;
      phClientGroup := FhClient;
      phServerGroup := FhServer;
      result := VpStringToLPOLESTR(FName, ppName);
    finally
      // ������������ ������
      Unlock;
    end;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70200, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetOPCGroup.SetState(
        pRequestedUpdateRate:       PDWORD;
  out   pRevisedUpdateRate:         DWORD;
        pActive:                    PBOOL;
        pTimeBias:                  PLongint;
        pPercentDeadband:           PSingle;
        pLCID:                      PLCID;
        phClientGroup:              POPCHANDLE): HResult;
begin
  try
    PostLogRecordAddMsgNow(70812, -1, -1, S_OK, '����� ������', llDebug);

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70203, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      pRevisedUpdateRate := 0;
      result := E_FAIL;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      if assigned(pRequestedUpdateRate) then begin
        pRevisedUpdateRate := ServerCore.GetRevisedGroupUpdateRate(pRequestedUpdateRate^);
        FUpdateRate := pRevisedUpdateRate;
      end;

      if assigned(pActive) then
        FActive := pActive^;

      if assigned(pTimeBias) then
        FTimeBais := pTimeBias^;

      if assigned(pPercentDeadband) then begin
        if (pPercentDeadband^ < 0) or (pPercentDeadband^ > 100) then begin
          FDeadBand := 0;
          result := E_INVALIDARG;
          exit;
        end;
        FDeadBand := pPercentDeadband^;
      end;

      if (assigned(pLCID)) and (ServerCore.ValidLocaleIDs.IndexOf(Pointer(pLCID^)) >= 0) then begin
        FLCID := pLCID^;
      end;

      if assigned(phClientGroup) then
        FhClient := phClientGroup^;

    finally
      // ������������ ������
      Unlock;
    end;
    result := S_OK;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70202, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetOPCGroup.SetName(
        szName:                     POleStr): HResult;
begin
  try
    PostLogRecordAddMsgNow(70813, -1, -1, S_OK, '����� ������', llDebug);

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70205, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // ��������� ������������� ������ ����� ������
    if length(szName) = 0 then begin
      PostLogRecordAddMsgNow(70206, -1, -1, E_INVALIDARG, '������������ ��� ������', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // ��������� ������
    Lock;
    try
//      if TVpNetOPCDA(ServObj).IsGroupNameUsed(szName) then begin
      if TVpNetOPCDA(ServObj).Groups.IsNameUsed(szName) then begin
        PostLogRecordAddMsgNow(70207, -1, -1, OPC_E_DUPLICATENAME, '������������ ��� ������', llErrors);
        result := OPC_E_DUPLICATENAME;
        exit;
      end;
      FName := szName;
    finally
      // ������������ ������
      Unlock;
    end;
    result := S_OK;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70204, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetOPCGroup.CloneGroup(
  szName: POleStr;
  const riid: TIID;
  out ppUnk: IUnknown
): HResult;
var
  NewGroup : TVpNetOPCGroup;
  sName : String;
  NewhServer: OPCHANDLE;
  ItemIndex : DWORD;
  hr : HRESULT;
  NewItem : TVpNetOPCItem;
begin
  try
    PostLogRecordAddMsgNow(70814, -1, -1, S_OK, '����� ������', llDebug);
    NewGroup := nil;
    // ��������� ������������� �������� ������
    ppUnk := nil;
    result := E_FAIL;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70209, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // ��������� ��� ������
    sName := szName;
    if sName = EmptyStr then begin
      // ���� � �������� ����� ������ �������� ������ ������, �������� ����� ���������� ���...
      sName := TVpNetOPCDA(ServObj).Groups.GetUniqueName;
      if sName = EmptyStr then begin
        // ... � ���� ���������� ��� ����� �� �������, ������� � E_FAIL
        PostLogRecordAddMsgNow(70210, -1, -1, E_FAIL, '�������� ��� ������', llErrors);
        result := E_FAIL;
        exit;
      end;
    end else if ValidateOPCString(sName) <> S_OK then begin
      // ���� ��� ������ �������� ������������ �������, ���������� E_INVALIDARG
      PostLogRecordAddMsgNow(70211, -1, -1, E_INVALIDARG, '�������� ��� ������: ' + sName, llErrors);
      result := E_INVALIDARG;
      exit;
    end else if TVpNetOPCDA(ServObj).Groups.IsNameUsed(sName) then begin
      // ���� ��� ������ ��� ������������, ���������� OPC_E_DUPLICATENAME
      PostLogRecordAddMsgNow(70212, -1, -1, OPC_E_DUPLICATENAME, '������������ ����� ������ ' + sName, llErrors);
      result := OPC_E_DUPLICATENAME;
      exit;
    end;

    // �������� ����� ��������� ������������� ������
    if ServerCore.GetNewServerGroupHandle(NewhServer) <> S_OK then begin
      // ���� �� ������� �������� ����� ��������� ������������� ������, ���������� E_EAIL
      PostLogRecordAddMsgNow(70213, NewhServer, -1, E_FAIL, '�� ������� �������� ����� ��������� ������������� ������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      // �������� �������
      NewGroup := TVpNetOPCGroup.Create(ServObj, sName, False, UpdateRate,
        hClient, @TimeBais, Deadband, LCID, NewhServer);

      if NewGroup = nil then begin
        // ���� �� ������� ������� ������, ���������� E_OUTOFMEMORY
        PostLogRecordAddMsgNow(70214, -1, -1, E_OUTOFMEMORY, '������ ��������� ������', llErrors);
        result := E_OUTOFMEMORY;
        exit;
      end;

      // ������ ���������� ������ ������
      TVpNetOPCGroupControlThread(NewGroup.ControlThread).Resume;

      // ����������� ��������� ������ � ����� ������
      ItemIndex := 0;
      while ItemIndex < DWORD(Items.Count) do begin
        hr := Items[ItemIndex].Clone(NewGroup, NewItem);
        if (hr <> S_OK) or (not assigned(NewItem)) then begin
          PostLogRecordAddMsgNow(70215, Integer(NewItem), -1, hr, '', llErrors);
          NewGroup.Free;
          result := hr;
          exit;
        end;
        NewGroup.Items.Add(NewItem);
        ItemIndex := Succ(ItemIndex);
      end;
    finally
      // �������������� ������
      Unlock;
    end;

    // ��������� ���������� ������
    hr := IUnknown(NewGroup).QueryInterface(riid, ppUnk);
    if hr <> S_Ok then begin
      PostLogRecordAddMsgNow(70216, hr, -1, E_NOINTERFACE, '������ ����������', llErrors);
      NewGroup.Free;
      result := E_NOINTERFACE;
      exit;
    end;

    // ��������� ������� ������ �� ������-������
    IUnknown(NewGroup)._AddRef;

    // ��������� ������ �� ������ � ������ ��������� ����� �������
    //todo: ������������� ������ �����
    TVpNetOPCDA(ServObj).Groups.Add(Pointer(NewGroup));

    result := S_OK;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70208, -1, -1, E_FAIL, e.Message, llErrors);
      ppUnk := nil;
      result := E_FAIL;
      //  ���� ����� ������ ��� �������,...
      if Assigned(NewGroup) then begin
        // ������� �� �� ������ ����� (�� ������, ���� ��� ��� ����),...
        TVpNetOPCDA(ServObj).Groups.Remove(Pointer(NewGroup));
        // � ������� ��� ������
        NewGroup.Free;
      end;
    end;
  end;
end;

// IOPCGroupStateMgt2
function TVpNetOPCGroup.SetKeepAlive(
  dwKeepAliveTime: DWORD;
  out pdwRevisedKeepAliveTime: DWORD): HResult;
begin
  try
    PostLogRecordAddMsgNow(70815, -1, -1, S_OK, '����� ������', llDebug);

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70218, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      if dwKeepAliveTime = 0 then begin
        // ���� ������ 0 (KeepAlive ���������), ��������� 0
        FKeepAlive := 0;
      end else if dwKeepAliveTime < ServerCore.MinGroupKeepAlive then begin
        // ���� ������ ��������� �������� KeepAlive, ������� ����������
        // �������������������, ��������� ���������� ���������� ��������
        FKeepAlive := ServerCore.MinGroupKeepAlive;
      end else begin
        // ����� ��������� �������� ��������
        FKeepAlive := dwKeepAliveTime;
      end;

      // ���������� ����������� �������� ��������� � S_OK
      pdwRevisedKeepAliveTime := FKeepAlive;
    finally
      // ������������ ������
      Unlock;
    end;

    // ���������� S_OK
    result := S_OK;
  except
    on e : Exception do begin
      // � ������ ������ ���������� 0 � E_FAIL
      PostLogRecordAddMsgNow(70217, -1, -1, E_FAIL, e.Message, llErrors);
      pdwRevisedKeepAliveTime := 0;
      result := E_FAIL;
    end;
  end;
end;

function TVpNetOPCGroup.GetKeepAlive(
  out pdwKeepAliveTime: DWORD
): HResult;
begin
  try
    PostLogRecordAddMsgNow(70816, -1, -1, S_OK, '����� ������', llDebug);

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70220, Integer(ServerCore.State), -1, E_FAIL, '�������� �������� �������', llErrors);
      pdwKeepAliveTime := 0;
      result := E_FAIL;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      // ���������� �������� ��������� � S_OK
      pdwKeepAliveTime := FKeepAlive;
    finally
      // ������������ ������
      Unlock;
    end;
    // ���������� S_OK
    result := S_OK;
  except
    on e : Exception do begin
      // � ������ ������ ���������� 0 � E_FAIL
      PostLogRecordAddMsgNow(70219, -1, -1, E_FAIL, e.Message, llErrors);
      pdwKeepAliveTime := 0;
      result := E_FAIL;
    end;
  end;
end;

// IOPCPublicGroupStateMgt
function TVpNetOPCGroup.GetState(
  out   pPublic:                    BOOL): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70736, -1, -1, E_NOTIMPL, '����� ������', llDebug);
  Result := E_NOTIMPL;
end;

function TVpNetOPCGroup.MoveToPublic: HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70737, -1, -1, E_NOTIMPL, '����� ������', llDebug);
  Result := E_NOTIMPL;
end;

// IOPCItemDeadbandMgt
function TVpNetOPCGroup.SetItemDeadband(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pPercentDeadband:           PSingleArray;
  out   ppErrors:                   PResultList): HResult;
var
  ItemIndex : DWORD;
  ErrorCount : DWORD;
  Item : TVpNetOPCItem;
  hr : HRESULT;
begin
  try
    PostLogRecordAddMsgNow(70817, -1, -1, S_OK, '����� ������', llDebug);
    // �������� �������� �������
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70222, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // �������� ���������� ���������
    if (dwCount = 0) then begin
      // ���� ���������� ��������� ������������, ������� � E_INVALIDARG
      PostLogRecordAddMsgNow(70223, -1, -1, E_INVALIDARG, '�������� ����� ���������', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // ��������� ������ ��� ������� ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if ppErrors = nil then begin
      // �� �����-�� �������� �� ������� �������� ������ ��� ������� ppErrors,
      // ������� ������� � E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70224, -1, -1, E_OUTOFMEMORY, '������ ��������� ������', llErrors);
      result := E_OUTOFMEMORY;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      // ���� �� ���������
      ItemIndex := 0;
      ErrorCount := 0;
      while ItemIndex < dwCount do begin
        // ���� ������� � ������ �������� ������
        hr := FindItemByhServer(phServer[ItemIndex], Item);
        if (hr = S_OK) and assigned(Item) then begin
          // ���� �������, ������������� ��� ��� Deadband
          hr := Item.SetNewDeadband(pPercentDeadband^[ItemIndex]);

          // � ������ �������������� ������...
          if hr = E_FAIL then begin
            // ... ���� ������ ���� ��������, ����������� ��, ...
            if Assigned(ppErrors) then
              CoTaskMemFree(ppErrors);
            // � ������� � E_FAIL;
            PostLogRecordAddMsgNow(70225, -1, -1, E_FAIL, '���������� �������', llErrors);
            result := E_FAIL;
            exit;
          end;

          // ���������� ��������� ��� ������� ��������
          ppErrors[ItemIndex] := hr;
        end else begin
          // ���� �� �������, ���������� ��� ����� �������� OPC_E_INVALIDHANDLE
          PostLogRecordAddMsgNow(70875, -1, hr, E_FAIL, '', llErrors);
          ppErrors[ItemIndex] := OPC_E_INVALIDHANDLE;
        end;

        // ���� ��������� ��� ����� �������� �� S_OK, ����������� ������� ������ ���������
        if ppErrors[ItemIndex] <> S_OK then begin
          ErrorCount := ErrorCount + 1;
        end;

        ItemIndex := Succ(ItemIndex);
      end;
    finally
      // ������������ ������
      Unlock;
    end;
    // ���� � ��������� ��������� ������ ������, ���������� S_OK,
    // ����� ���������� S_FALSE
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;
  except
    on e : Exception do begin
      // � ������ �������������� ������ ...
      // ... ���� ������ ���� ��������, ����������� ��, ...
      PostLogRecordAddMsgNow(70221, -1, -1, E_FAIL, e.Message, llErrors);
      if Assigned(ppErrors) then
        CoTaskMemFree(ppErrors);
      // � ������� � E_FAIL;
      result := E_FAIL;
    end;
  end;
end;

function TVpNetOPCGroup.GetItemDeadband(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
  out   ppPercentDeadband:          PSingleArray;
  out   ppErrors:                   PResultList): HResult;
var
  ItemIndex : DWORD;
  ErrorCount : DWORD;
  Item : TVpNetOPCItem;
  hr : HRESULT;
begin
  try
    PostLogRecordAddMsgNow(70818, -1, -1, S_OK, '����� ������', llDebug);
    // �������� �������� �������
    ppPercentDeadband := nil;
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70227, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // �������� ���������� ���������
    if (dwCount = 0) then begin
      // ���� ���������� ��������� ������������, ������� � E_INVALIDARG
      PostLogRecordAddMsgNow(70228, -1, dwCount, E_INVALIDARG, '�������� ����� ���������', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // �������� ������ ��� ppPercentDeadband
    ppPercentDeadband := PSingleArray(CoTaskMemAlloc(dwCount * sizeof(Single)));
    if not assigned(ppPercentDeadband) then begin
      // �� �����-�� �������� �� ������� �������� ������ ��� ������� ppPercentDeadband,
      // ������� ������� � E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70229, -1, -1, E_OUTOFMEMORY, '������ ��������� ������', llErrors);
      result := E_OUTOFMEMORY;
      exit;
    end;

    // ��������� ������ ��� ������� ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if not assigned(ppErrors) then begin
      // �� �����-�� �������� �� ������� �������� ������ ��� ������� ppErrors,
      // ������� ����������� ������, ����� ���������� ��� ppPercentDeadband
      // � ������� � E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70230, -1, -1, E_OUTOFMEMORY, '������ ��������� ������', llErrors);
      CoTaskMemFree(ppPercentDeadband);
      result := E_OUTOFMEMORY;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      // ���� �� ���������
      ItemIndex := 0;
      ErrorCount := 0;
      while ItemIndex < dwCount do begin
        // ���� ������� � ������ �������� ������
        hr := FindItemByhServer(phServer[ItemIndex], Item);
        if (hr = S_OK) and assigned(Item) then begin
          // ���� ����� �������, ���������, ������������ �� ���� ������� Deadband
          if Item.DeadbandSupported then begin
            // ���� ��, ���������, ��� �� ������������� ��� ���� ���������� Deadband
            if Item.DeadbandSetForItem then begin
              // ���� ��, �� ���������� Deadband � S_OK
              ppPercentDeadband[ItemIndex] := Item.Deadband;
              ppErrors[ItemIndex] := S_OK;
            end else begin
              // ����� ���������� Deadband � OPC_E_DEADBANDNOTSET
              ppPercentDeadband[ItemIndex] := Item.Deadband;
              ppErrors[ItemIndex] := OPC_E_DEADBANDNOTSET;
            end;
          end else begin
            // ���� �� ��������������, ���������� 0 � OPC_E_DEADBANDNOTSUPPORTED
            ppPercentDeadband[ItemIndex] := 0;
            ppErrors[ItemIndex] := OPC_E_DEADBANDNOTSUPPORTED;
          end;
        end else begin
          // ���� �� �������, ���������� 0 � OPC_E_INVALIDHANDLE
          PostLogRecordAddMsgNow(70876, -1, hr, OPC_E_INVALIDHANDLE, '', llErrors);
          ppErrors[ItemIndex] := OPC_E_INVALIDHANDLE;
          ppPercentDeadband[ItemIndex] := 0;
        end;

        // ���� ��������� ��� ����� �������� �� S_OK, ����������� ������� ������ ���������
        if ppErrors[ItemIndex] <> S_OK then begin
          ErrorCount := ErrorCount + 1;
        end;
        // ��������� � ���������� ��������
        ItemIndex := Succ(ItemIndex);
      end;

    finally
      // ������������ ������
      Unlock;
    end;
    // ���� � ��������� ��������� ������ ������, ���������� S_OK,
    // ����� ���������� S_FALSE
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;
  except
    on e : Exception do begin
      // � ������ �������������� ������ ...
      // ... ���� ������ ���� ��������, ����������� ��, ...
      PostLogRecordAddMsgNow(70226, -1, -1, E_FAIL, e.Message, llErrors);
      if assigned(ppPercentDeadband) then
        CoTaskMemFree(ppPercentDeadband);
      if Assigned(ppErrors) then
        CoTaskMemFree(ppErrors);
      // � ������� � E_FAIL;
      result := E_FAIL;
    end;
  end;
end;

function TVpNetOPCGroup.ClearItemDeadband(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
  out   ppErrors:                   PResultList): HResult;
var
  ItemIndex : DWORD;
  ErrorCount : DWORD;
  Item : TVpNetOPCItem;
  hr : HRESULT;
begin
  try
    PostLogRecordAddMsgNow(70819, -1, -1, S_OK, '����� ������', llDebug);
    // �������� �������� �������
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70232, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // �������� ���������� ���������
    if (dwCount = 0) then begin
      // ���� ���������� ��������� ������������, ������� � E_INVALIDARG
      PostLogRecordAddMsgNow(70233, -1, -1, E_INVALIDARG, '�������� ����� ���������', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // ��������� ������ ��� ������� ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if not assigned(ppErrors) then begin
      // �� �����-�� �������� �� ������� �������� ������ ��� ������� ppErrors,
      // ������� ����������� ������, ����� ���������� ��� ppPercentDeadband
      // � ������� � E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70234, -1, -1, E_OUTOFMEMORY, '������ ��������� ������', llErrors);
      result := E_OUTOFMEMORY;
      exit;
    end;

    // ��������� ������
    Lock;
    try
      // ���� �� ���������
      ItemIndex := 0;
      ErrorCount := 0;
      while ItemIndex < dwCount do begin
        // ���� ������� � ������ �������� ������
        hr := FindItemByhServer(phServer[ItemIndex], Item);
        if (hr = S_OK) and assigned(Item) then begin
          // ���� ����� �������, ���������, ������������ �� ���� ������� Deadband
          if Item.DeadbandSupported then begin
            // ���� ��, ���������, ��� �� ������������� ��� ���� ���������� Deadband
            if Item.DeadbandSetForItem then begin
              // ���� ��, ���������� Deadband � ���������� S_OK
              Item.ResetDeadband;
              ppErrors[ItemIndex] := S_OK;
            end else begin
              // ����� ���������� Deadband � ���������� OPC_E_DEADBANDNOTSET
              Item.ResetDeadband;
              ppErrors[ItemIndex] := OPC_E_DEADBANDNOTSET;
            end;
          end else begin
            // ���� �� ��������������, ���������� OPC_E_DEADBANDNOTSUPPORTED
            ppErrors[ItemIndex] := OPC_E_DEADBANDNOTSUPPORTED;
          end;
        end else begin
          // ���� �� �������, ���������� OPC_E_INVALIDHANDLE
          PostLogRecordAddMsgNow(70877, -1, hr, OPC_E_INVALIDHANDLE, '', llErrors);
          ppErrors[ItemIndex] := OPC_E_INVALIDHANDLE;
        end;

        // ���� ��������� ��� ����� �������� �� S_OK, ����������� ������� ������ ���������
        if ppErrors[ItemIndex] <> S_OK then begin
          ErrorCount := ErrorCount + 1;
        end;
        // ��������� � ���������� ��������
        ItemIndex := Succ(ItemIndex);
      end
    finally
      // ������������ ������
      Unlock;
    end;
    // ���� � ��������� ��������� ������ ������, ���������� S_OK,
    // ����� ���������� S_FALSE
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;
  except
    on e : Exception do begin
      // � ������ �������������� ������ ���� ������ ���� ��������, ����������� ��,...
      PostLogRecordAddMsgNow(70231, -1, -1, E_FAIL, e.Message, llErrors);
      if Assigned(ppErrors) then
        CoTaskMemFree(ppErrors);
      // ..�� ������� � E_FAIL;
      result := E_FAIL;
    end;  
  end;
end;

// IOPCSyncIO
function TVpNetOPCGroup.Read(
        dwSource:                   OPCDATASOURCE;
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
  out   ppItemValues:               POPCITEMSTATEARRAY;
  out   ppErrors:                   PResultList): HResult;
var
  ItemIndex : DWORD;
  phClients:                  POPCHANDLEARRAY;
  ppvValues:                  POleVariantArray;
  ppwQualities:               PWordArray;
  ppftTimeStamps:             PFileTimeArray;
begin
  try
    PostLogRecordAddMsgNow(70820, -1, -1, S_OK, '����� ������', llDebug);
    // ��������� ��������
    ppItemValues := nil;
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70236, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // �������� ������� ����������
    if not(dwSource = OPC_DS_CACHE) and
       not(dwSource = OPC_DS_DEVICE)
    then begin
      PostLogRecordAddMsgNow(70237, Integer(dwSource), -1, E_INVALIDARG, '���������� �������', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    if dwCount = 0 then begin
      PostLogRecordAddMsgNow(70238, 0, -1, E_INVALIDARG, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    if not(assigned(phServer)) then begin
      PostLogRecordAddMsgNow(70239, -1, -1, E_INVALIDARG, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    PostLogRecordAddMsgNow(70927, -1, -1, -1, '����� Group._Read()', llDebug);
    // ����� ������� ������ ��� ������������ ������ ����������� ������ (pdwMaxAge = nil)
    result := _Read(dwCount, phServer, dwSource, nil, vndtstSync, vnditRead, 0, 0, phClients, ppvValues, ppwQualities, ppftTimestamps, ppErrors);
    PostLogRecordAddMsgNow(70928, -1, -1, -1, '����� Group._Read()', llDebug);

    // ���� ������ ����������� ������, ...
    if result >= S_OK then try
      // ��������� �������� ��������� � � �������� ��������� ���� POPCITEMSTATEARRAY
      ppItemValues := CoTaskMemAlloc(dwCount * sizeof(OPCITEMSTATE));

      ItemIndex := 0;
      while ItemIndex < dwCount do begin
        ppItemValues^[ItemIndex].hClient := phClients^[ItemIndex];
        VariantInit(ppItemValues^[ItemIndex].vDataValue);
        ppItemValues^[ItemIndex].vDataValue := ppvValues^[ItemIndex];
        VariantClear(ppvValues^[ItemIndex]);
        ppItemValues^[ItemIndex].wQuality := ppwQualities^[ItemIndex];
        ppItemValues^[ItemIndex].ftTimeStamp := ppftTimestamps^[ItemIndex];
        ItemIndex := Succ(ItemIndex);
      end;

    finally
      // �� ���������� ������� �������� ������
      if assigned(phClients) then begin
        CoTaskMemFree(phClients);
        phClients := nil;
      end;

      if assigned(ppvValues) then begin
        // ���������������� �������� ������� ����� ���������
        ItemIndex := 0;
        while ItemIndex < dwCount do begin
          VariantClear(ppvValues^[ItemIndex]);
          ItemIndex := succ(ItemIndex);
        end;
        CoTaskMemFree(ppvValues);
        ppvValues := nil;
      end;

      if assigned(ppwQualities) then begin
        CoTaskMemFree(ppwQualities);
        ppwQualities := nil;
      end;

      if assigned(ppftTimestamps) then begin
        CoTaskMemFree(ppftTimestamps);
        ppftTimestamps := nil;
      end;
    end else begin
      PostLogRecordAddMsgNow(70240, -1, -1, result, '', llErrors);
    end;

  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70235, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL;
      if assigned(ppErrors) then begin
        CoTaskMemFree(ppErrors);
        ppErrors := nil;
      end;

      if assigned(ppItemValues) then begin
        // ���������������� �������� ������� ����� ���������
        ItemIndex := 0;
        while ItemIndex < dwCount do begin
          VariantClear(ppItemValues^[ItemIndex].vDataValue);
          ItemIndex := succ(ItemIndex);
        end;
        CoTaskMemFree(ppItemValues);
        ppItemValues := nil;
      end;
    end;
  end;
end;

function TVpNetOPCGroup.Write(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pItemValues:                POleVariantArray;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  try
    PostLogRecordAddMsgNow(70821, -1, -1, S_OK, '����� ������', llDebug);
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70241, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    PostLogRecordAddMsgNow(70738, -1, -1, E_NOTIMPL, '', llErrors);
    RESULT := E_NOTIMPL;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70822, -1, -1, E_FAIL, e.Message, llErrors);
    end;
  end;
end;

// IOPCSyncIO2
function TVpNetOPCGroup.ReadMaxAge(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pdwMaxAge:                  PDWORDARRAY;
  out   ppvValues:                  POleVariantArray;
  out   ppwQualities:               PWordArray;
  out   ppftTimeStamps:             PFileTimeArray;
  out   ppErrors:                   PResultList): HResult;
var
  phClients: POPCHANDLEARRAY;
  ItemIndex : Integer;
begin
  try
    PostLogRecordAddMsgNow(70823, -1, -1, S_OK, '����� ������', llDebug);
    // ��������� ��������
    ppvValues := nil;
    ppwQualities := nil;
    ppftTimeStamps := nil;
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70243, Integer(ServerCore.State), -1, E_FAIL, '�������� �������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // �������� ������� ����������
    if dwCount = 0 then begin
      PostLogRecordAddMsgNow(70244, 0, -1, E_INVALIDARG, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    if not(assigned(phServer)) then begin
      PostLogRecordAddMsgNow(70245, -1, -1, E_INVALIDARG, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    PostLogRecordAddMsgNow(70929, -1, -1, -1, '����� Group._Read()', llDebug);
    // ����� ������� ������ ��� �������� ��������� ������ (dwSource = 0)
    result := _Read(dwCount, phServer, 0, pdwMaxAge, vndtstSync, vnditRead, 0, 0, phClients, ppvValues, ppwQualities, ppftTimestamps, ppErrors);
    PostLogRecordAddMsgNow(70930, -1, -1, -1, '����� Group._Read()', llDebug);

    // ���� ������ ����������� ������, ...
    if result >= S_OK then try
      //todo: ��������...
    finally
      // �� ���������� ������� �������� ���������� ������
      if assigned(phClients) then begin
        CoTaskMemFree(phClients);
        phClients := nil;
      end;
    end else begin
      PostLogRecordAddMsgNow(70246, -1, -1, result, '', llErrors);
    end;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70242, -1, -1, E_FAIL, e.Message, llErrors);
      // �� ���������� ������� �������� ������
      result := E_FAIL;
      if assigned(ppvValues) then begin
        // ���������������� �������� ������� ����� ���������
        ItemIndex := 0;
        while ItemIndex < dwCount do begin
          VariantClear(ppvValues^[ItemIndex]);
          ItemIndex := succ(ItemIndex);
        end;
        CoTaskMemFree(ppvValues);
        ppvValues := nil;
      end;

      if assigned(ppwQualities) then begin
        CoTaskMemFree(ppwQualities);
        ppwQualities := nil;
      end;

      if assigned(ppftTimestamps) then begin
        CoTaskMemFree(ppftTimestamps);
        ppftTimestamps := nil;
      end;

      if assigned(ppErrors) then begin
        CoTaskMemFree(ppErrors);
        ppErrors := nil;
      end;
    end;
  end;
end;

function TVpNetOPCGroup.WriteVQT(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pItemVQT:                   POPCITEMVQTARRAY;
  out   ppErrors:                   PResultList): HResult;
begin
  try
    PostLogRecordAddMsgNow(70824, -1, -1, S_OK, '����� ������', llDebug);
    ppErrors := nil;
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70029, -1, -1, E_FAIL, '', llErrors);
      result := E_FAIL;
      exit;
    end;

    PostLogRecordAddMsgNow(70739, -1, -1, E_NOTIMPL, '', llErrors);
    result := E_NOTIMPL;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70247, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL
    end;
  end;
end;

// IOPCAsyncIO2
function TVpNetOPCGroup.Read(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        dwTransactionID:            DWORD;
  out   pdwCancelID:                DWORD;
  out   ppErrors:                   PResultList): HResult;
var
  index : Integer;
  read_res : HRESULT;
  ItemIndex : DWORD;
  phClients: POPCHANDLEARRAY;
  ppvValues: POleVariantArray;
  ppwQualities: PWordArray;
  ppftTimeStamps: PFileTimeArray;
begin
  try
    PostLogRecordAddMsgNow(70825, dwTransactionID, -1, S_OK, '����� ������', llDebug);

    // ���������� ��������� �������� �������� ����������
    pdwCancelID := 0;
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70248, Integer(ServerCore.State), dwTransactionID, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    // �������� ������� ����������
    if dwCount = 0 then begin
      PostLogRecordAddMsgNow(70841, dwTransactionID, -1, E_INVALIDARG, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    if not(assigned(phServer)) then begin
      PostLogRecordAddMsgNow(70842, dwTransactionID, -1, E_INVALIDARG, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // ��������� ������ ��� ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    // ������� ppErrors
    index := 0;
    while index < dwCount do begin
      ppErrors^[index] := E_UNEXPECTED;
      index := succ(index);
    end;

    // ���������� ������������ ������
    try
      PostLogRecordAddMsgNow(70931, dwTransactionID, -1, -1, '����� Group._Read()', llDebug);
      read_res := _Read(dwCount, phServer, OPC_DS_DEVICE, nil, vndtstAsync,
      vnditRead, dwTransactionID, 0, phClients, ppvValues, ppwQualities,
      ppftTimeStamps, ppErrors);
      PostLogRecordAddMsgNow(70932, dwTransactionID, -1, -1, '����� Group._Read()', llDebug);
    except
      PostLogRecordAddMsgNow(70843, dwTransactionID, -1, E_NOTIMPL, '', llErrors);
      result := E_FAIL;
      exit;
    end;

    //todo: ����������� � ������ ���������
    result := read_res;

    PostLogRecordAddMsgNow(70740, dwTransactionID, -1, read_res, '', llDebug);
//    result := E_NOTIMPL;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70249, dwTransactionID, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL
    end;
  end;
end;

function TVpNetOPCGroup.Write(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pItemValues:                POleVariantArray;
        dwTransactionID:            DWORD;
  out   pdwCancelID:                DWORD;
  out   ppErrors:                   PResultList): HResult;
begin
  try
    PostLogRecordAddMsgNow(70826, -1, -1, S_OK, '����� ������', llDebug);
    ppErrors := nil;
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70250, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    PostLogRecordAddMsgNow(70741, -1, -1, E_NOTIMPL, '������� IOPCAsyncIO2::Write() �� ��������������', llErrors);
    result := E_NOTIMPL;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70251, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL
    end;
  end;
end;

function TVpNetOPCGroup.Refresh2(
        dwSource:                   OPCDATASOURCE;
        dwTransactionID:            DWORD;
  out   pdwCancelID:                DWORD): HResult;
begin
  try
    PostLogRecordAddMsgNow(70827, -1, -1, S_OK, '����� ������', llDebug);
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70253, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    PostLogRecordAddMsgNow(70742, -1, -1, E_NOTIMPL, '', llErrors);
    result := E_NOTIMPL;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70252, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL
    end;
  end;
end;

function TVpNetOPCGroup.Cancel2(
  dwCancelID:                 DWORD
): HResult;
begin
  try
    PostLogRecordAddMsgNow(70828, -1, -1, S_OK, '����� ������', llDebug);
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70255, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    PostLogRecordAddMsgNow(70743, -1, -1, E_NOTIMPL, '', llErrors);
    result := E_NOTIMPL;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70254, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL
    end;
  end;
end;

function TVpNetOPCGroup.SetEnable(
  bEnable: BOOL
): HResult;
begin
  try
    PostLogRecordAddMsgNow(70829, -1, -1, S_OK, '����� ������', llDebug);
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70257, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    PostLogRecordAddMsgNow(70744, -1, -1, E_NOTIMPL, '', llErrors);
    result := E_NOTIMPL;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70256, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL
    end;
  end;
end;

function TVpNetOPCGroup.GetEnable(
  out   pbEnable:                   BOOL
): HResult;
begin
  try
    PostLogRecordAddMsgNow(70830, -1, -1, S_OK, '����� ������', llDebug);
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70259, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������', llErrors);
      result := E_FAIL;
      exit;
    end;

    PostLogRecordAddMsgNow(70745, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
    result := E_NOTIMPL;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70258, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL
    end;
  end;
end;

// IOPCAsyncIO
function TVpNetOPCGroup.Read(
        dwConnection:               DWORD;
        dwSource:                   OPCDATASOURCE;
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
  out   pTransactionID:             DWORD;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70754, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.Write(
        dwConnection:               DWORD;
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pItemValues:                POleVariantArray;
  out   pTransactionID:             DWORD;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70755, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.Refresh(
        dwConnection:               DWORD;
        dwSource:                   OPCDATASOURCE;
  out   pTransactionID:             DWORD): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70756, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.Cancel(
        dwTransactionID:            DWORD): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70757, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

//IOPCAsyncIO3
function TVpNetOPCGroup.ReadMaxAge(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pdwMaxAge:                  PDWORDARRAY;
        dwTransactionID:            DWORD;
  out   pdwCancelID:                DWORD;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70746, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.WriteVQT(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pItemVQT:                   POPCITEMVQTARRAY;
        dwTransactionID:            DWORD;
  out   pdwCancelID:                DWORD;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70747, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.RefreshMaxAge(
        dwMaxAge:                   DWORD;
        dwTransactionID:            DWORD;
  out   pdwCancelID:                DWORD): HResult;
begin
  PostLogRecordAddMsgNow(70748, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

//IOPCItemSamplingMgt
function TVpNetOPCGroup.SetItemSamplingRate(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pdwRequestedSamplingRate:   PDWORDARRAY;
  out   ppdwRevisedSamplingRate:    PDWORDARRAY;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70749, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.GetItemSamplingRate(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
  out   ppdwSamplingRate:           PDWORDARRAY;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70750, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.ClearItemSamplingRate(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70751, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.SetItemBufferEnable(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pbEnable:                   PBOOLARRAY;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70752, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.GetItemBufferEnable(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
  out   ppbEnable:                  PBOOLARRAY;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70753, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

// IDataObject
function TVpNetOPCGroup.GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium):
  HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70758, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium):
  HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70759, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.QueryGetData(const formatetc: TFormatEtc): HResult;
  stdcall;
begin
  PostLogRecordAddMsgNow(70760, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.GetCanonicalFormatEtc(const formatetc: TFormatEtc;
  out formatetcOut: TFormatEtc): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70761, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
  fRelease: BOOL): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70762, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
  IEnumFormatEtc): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70763, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.DAdvise(const formatetc: TFormatEtc; advf: Longint;
  const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70764, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.DUnadvise(dwConnection: Longint): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70765, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
  stdcall;
begin
  PostLogRecordAddMsgNow(70766, -1, -1, E_NOTIMPL, '����� �� ��������������', llErrors);
  result := E_NOTIMPL;
end;




function TVpNetOPCGroup._Read(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        dwSource:                   DWORD; // �������� ������ (Device/CACHE)
        pdwMaxAge:                  PDWORDARRAY;
        SyncType:                   TVpNetDATransactionSyncType;
        InvocationType:             TVpNetDATransactionInvocationType; // ��� ��������� ������������� ����������
        dwClientTransactionId:      DWORD; // �������� �������� ������������� ����������
        dwClientCancelId:           DWORD; // �������� �������� ������������� ������ ����������
  out   phClients:                  POPCHANDLEARRAY; // ���������� �������������� ��������� (�����) ����������
  out   ppvValues:                  POleVariantArray;
  out   ppwQualities:               PWordArray;
  out   ppftTimeStamps:             PFileTimeArray;
  out   ppErrors:                   PResultList): HResult;
var
  ItemIndex : DWORD;
  dwErrorCount : DWORD;
//  CommonTrItemList : TVpNetDATransactionItemList; // ����� (��������) ������ ��������� ���������� �������
  tr : TVpNetDATransaction;
  TrItem : TVpNetDATransactionItem; // ����������
  TrItemIndex : Integer; // ����� �������� DA-����������
  TrItemList : TVpNetDATransactionItemList; // ������ ���������� ��� ������������� ����������(��������)
  TrItemListIndex : Integer; // ����� ������ ��������� ���������� �� ��������� �������
  TrItemListSet : TVpNetDATransactionItemListSet; // ��������� ������� ���������� ��� ������ ����������(���������)

  ReferencedHstDriverIDs : TList; // ������ ��������������� ���������, �� ������� ���� ��������� ������
  DriverRefIndex : Integer;
  Item : TVpNetOPCItem;
  ft : TFileTime;
  dwHostServerID,
  dwHostServerDriverID,
  dwDeviceID,
  dwDeviceTypeTagID : DWORD;
  hr : HRESULT;
  ds : TDataSet;
  InterestedItems : TList;

  AsyncTransaction : TVpNetDATransactionItemList; // ������ '

  TID : DWORD;
  bLessThenMaxAge : boolean;
begin
  try
    Lock;
    try
      // ������� �������� ����������
      phClients := nil;
      ppvValues := nil;
      ppwQualities := nil;
      ppftTimeStamps := nil;
      ppErrors := nil;

      // �������� ������� ����������
      if dwCount = 0 then begin
        PostLogRecordAddMsgNow(70275, 0, -1, E_INVALIDARG, '', llErrors);
        result := E_INVALIDARG;
        exit;
      end;

      if not(assigned(phServer)) then begin
        PostLogRecordAddMsgNow(70276, -1, -1, E_INVALIDARG, '', llErrors);
        result := E_INVALIDARG;
        exit;
      end;

      // ������ ���� ������ ��� �������� ������ ��� ������������ ������� ����������� ������� �����
      if (
            not(dwSource = OPC_DS_CACHE) and
            not(dwSource = OPC_DS_DEVICE)
         ) and (
            not(Assigned(pdwMaxAge))
         )
      then begin
        PostLogRecordAddMsgNow(70278, Integer(dwSource), Integer(pdwMaxAge), E_INVALIDARG, '', llErrors);
        result := E_INVALIDARG;
        exit;
      end;

      if not(SyncType = vndtstSync) and not(SyncType = vndtstAsync) then begin
        PostLogRecordAddMsgNow(70277, Integer(SyncType), -1, E_INVALIDARG, '', llErrors);
        result := E_INVALIDARG;
        exit;
      end;

      // ��������� ������ ��� �������� ����������
      phClients := CoTaskMemAlloc(dwCount * sizeof(OPCHANDLE));
      ppvValues := POleVariantArray(CoTaskMemAlloc(dwCount * sizeof(OleVariant)));
      ppwQualities := PWordArray(CoTaskMemAlloc(dwCount * sizeof(Word)));
      ppftTimeStamps := PFileTimeArray(CoTaskMemAlloc(dwCount * sizeof(TFileTime)));
      ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));

      try
        // �������� ������ ��� ������ ��������������� ���������,
        // �� ������� ���� ��������� ������
        ReferencedHstDriverIDs := TList.Create;
        // �������� ������� ��������� ������� ��������� ���������� ��� ������ ����������(���������)
        TrItemListSet := TVpNetDATransactionItemListSet.Create;
  //      // �������� ������ (����������) ������ ��������� ����������
  //      CommonTrItemList := TVpNetDATransactionItemList.Create;

        // �������� ������ ������ (�����) ������, ��� ������� ����������� �������
        InterestedItems := TList.Create;

        try

          tr := TVpNetDATransaction.Create; // ������� DA-����������
          tr.SourceObj := self; // �������� DA-���������� - ������ ������
          tr.TID := ServerCore.GetNewTID; // �������� ��������� ������������� DA-����������
          tr.TrType := vndttRead; // ��� ���������� - ������
          tr.SyncType := SyncType; // ��� ������������� ����������  - ��������
          tr.InvocationType := InvocationType; // ��� ��������� ������������� ���������� - ��������
          tr.dwClientTransactionId := dwClientTransactionId; // ���������� ������������� ���������� - ��������
          tr.dwClientCancelId := dwClientCancelId; // ���������� ������������� ������ ���������� - ��������

          // ���������� DA-���������� � ������ DA-���������� ������
          Transactions.Add(tr);

          //----------------------------------------------------------------
          // �������� �� ���������, � ��������� �������� ���������� ������� ��� ��������� �����
          //----------------------------------------------------------------
          ItemIndex := 0;
          dwErrorCount := 0;
          while (ItemIndex < dwCount) do begin
            // �������� ���������� ��������:
            // ���������� �������� �������� ���������� ��� ������� �������� �� ����������
            phClients^[ItemIndex] := 0;
            ppwQualities^[ItemIndex] := OPC_QUALITY_BAD;
            CoFileTimeNow(ft); // ������� ����� � ������� _FILETIME
            LocalFileTimeToFileTime(ft, ft); // ������� �������� ���������� ������� � UTC
            ppftTimeStamps^[ItemIndex] := ft; // ���������� ���
            VariantInit(ppvValues^[ItemIndex]);
            ppErrors^[ItemIndex] := E_UNEXPECTED;

            // ������� ��������
            ppvValues^[ItemIndex] := Null;
            VariantChangeTypeEx(ppvValues^[ItemIndex], ppvValues^[ItemIndex], LCID, 0, VT_EMPTY);

            // ��������� "�����" ��� �������� DA-���������� � ����� (��������) ������ ��������� DA-����������
            tr.Items.Add(nil);

            // ���� Item (���) �� phServer
            Item := Items.FindByhServer(phServer^[ItemIndex]);

            // ������ ������ ItemID
            if Assigned(Item) then begin
              // ���������� ����� � ������ ������, ��� ������� ����������� �������
              InterestedItems.Add(Pointer(Item));
            end else begin
              // ��������� ������ - Item ��� ���������� phServer �� ������
              PostLogRecordAddMsgNow(70888, ItemIndex, phServer^[ItemIndex], -1, '', llErrors);
              ppErrors^[ItemIndex] := OPC_E_INVALIDHANDLE; // �������� ��� ������
              dwErrorCount := Succ(dwErrorCount); // ����������� ���������� ��������� � ��������
              ItemIndex := Succ(ItemIndex); // ��������� � ���������� ��������
              continue;
            end;

            // �������� ������������ �������� Item-�
            dwHostServerID := Item.VHS_ID;
            dwHostServerDriverID := Item.VHSD_ID;
            dwDeviceID := Item.VD_ID;
            dwDeviceTypeTagID := Item.VDTT_ID;

            // todo: �������� ������
            if Assigned(pdwMaxAge) then begin
              PostLogRecordAddMsgNow(70889, -1, -1, -1, '', llDebug);
              // ���� ������ ������������ ������� ����������� �����, ���������
              // ������ �������� ������ �� ������������� ������� �����������
              // (IOPCSyncIO2.ReadMaxAge)

              // ���� �������� �� ��������, ���������� �������� �� ���� (���������� �������� �����)
              CoFileTimeNow(ft); // ������� ����� � ������� _FILETIME
              LocalFileTimeToFileTime(ft, ft); // ������� �������� ���������� ������� � UTC
              try
                bLessThenMaxAge := (FileTimeMinusFileTimeMS(ft, Item.Timestamp) < pdwMaxAge^[ItemIndex]);
              except on e : Exception do begin
                  bLessThenMaxAge := false;
                  PostLogRecordAddMsgNow(70404, e.HelpContext, -1, -1, e.Message, llErrors);
                end;
              end;

              if bLessThenMaxAge then begin
                PostLogRecordAddMsgNow(70891, -1, -1, -1, '', llDebug);
                phClients^[ItemIndex] := Item.hClient;
                ppvValues^[ItemIndex] := Item.Value;
                ppwQualities^[ItemIndex] := Item.Quality;
                ppftTimeStamps^[ItemIndex] := Item.Timestamp;
                ppErrors^[ItemIndex] := S_OK; // �������� ��� ������
                continue;// ��������� � ��������� ���������� �������� �������
              end;
              
            end else begin
              PostLogRecordAddMsgNow(70890, -1, -1, -1, '', llDebug);
              // ���� ������������ ������� ����������� ����� �� ������, ���������
              // ������ �������� ������ �� dwSource � ������������� �������
              // ����������� ������ (Group.FUpdateRate)
              // (IOPCSyncIO.Read)

              if (dwSource = OPC_DS_CACHE) then begin
                PostLogRecordAddMsgNow(70892, -1, -1, -1, '', llDebug);
                // ����, ��� ������ �� ����, ������ ��� ���� ���������
                // ���������� OPC_QUALITY_OUT_OF_SERVICE
                if not(Active) or not(Item.Active) then begin
                  PostLogRecordAddMsgNow(70894, Integer(Active), Integer(Item.Active), -1, '', llDebug);
                  ppErrors^[ItemIndex] := OPC_QUALITY_OUT_OF_SERVICE; // �������� ��� ������
                  dwErrorCount := Succ(dwErrorCount); // ����������� ���������� ��������� � ��������
                  ItemIndex := Succ(ItemIndex); // ��������� � ���������� ��������
                  continue;
                end;

                // ���� �������� �� ��������, ���������� �������� �� ���� (���������� �������� �����)
                CoFileTimeNow(ft); // ������� ����� � ������� _FILETIME
                LocalFileTimeToFileTime(ft, ft); // ������� �������� ���������� ������� � UTC
                try
                  bLessThenMaxAge := (FileTimeMinusFileTimeMS(ft, Item.Timestamp) < FUpdateRate);
                except on e : Exception do begin
                    bLessThenMaxAge := false;
                    PostLogRecordAddMsgNow(70405, e.HelpContext, -1, -1, e.Message, llErrors);
                  end;
                end;

                if bLessThenMaxAge then begin
                  PostLogRecordAddMsgNow(70895, -1, -1, -1, '', llDebug);
                  phClients^[ItemIndex] := Item.hClient;
                  ppvValues^[ItemIndex] := Item.Value;
                  ppwQualities^[ItemIndex] := Item.Quality;
                  ppftTimeStamps^[ItemIndex] := Item.Timestamp;
                  ppErrors^[ItemIndex] := S_OK; // �������� ��� ������
                  continue;// ��������� � ��������� ���������� �������� �������
                end;
              end else begin
                PostLogRecordAddMsgNow(70893, -1, -1, -1, '', llDebug);
              end;
            end;

            // ���� ������ �� ������ ������� ��� �� ���������, ...
            if ReferencedHstDriverIDs.IndexOf(Pointer(dwHostServerDriverID)) = -1 then begin
              PostLogRecordAddMsgNow(70896, -1, -1, -1, '', llDebug);
              // �������� ������� �� ���������� ������ �� ������� Host-�������,
              // � �������� ���������� �������
  //            hr := SendMessage...
              PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_REF, dwHostServerDriverID, 0);
                // ���� ������� �������� ������ �� �� ������� Host-�������,
                // ���������� ������������� �������� ��� ������������ �������� ������
              ReferencedHstDriverIDs.Add(Pointer(dwHostServerDriverID));
  {
              end else begin
                // ���� �� ������� �������� ������ �� ������� Host-�������,
                // ���������� ������ ��� ������� ��������
                ppErrors^[ItemIndex] := hr; // �������� ��� ������
                dwErrorCount := Succ(dwErrorCount); // ����������� ���������� ��������� � ��������
                ItemIndex := Succ(ItemIndex); // ��������� � ���������� ��������
                continue;
              end;
  }
            end else begin
              PostLogRecordAddMsgNow(70897, -1, -1, -1, '', llDebug);
            end;

            // ������� ��������� ���������� DA-�������
            TrItem := TVpNetDATransactionItem.Create(tr, TID);
            // ���������� ������������� �������� ������
            TrItem.DA_hClient := Item.hClient;
            // ������ ItemId DA-����������
            TrItem.DA_ItemId := Item.ItemId;
            // ������ ������������ ��������� (���������� ��������� ��������) ��� ������� ��������
            TrItem.DA_MaxAge := 0;
            // ��������� ����� ������� ������ ������� ����� ����� �������� �����
            TrItem.DA_MaxResponseMoment := TrItem.DA_CreationMoment;

            // ��� DA-���������� - ������
            TrItem.DA_Type := vndttRead;
            // ���������� ����������
            TrItem.DA_SyncType := SyncType;
            TrItem.DA_ControlThreadId := GetCurrentThreadId;

            // ��������� ����������� � Hst-�������
            TrItem.Hst_ID := dwHostServerID;
            TrItem.Hst_DriverID := dwHostServerDriverID;
            TrItem.Hst_DeviceId := dwDeviceID;
            TrItem.Hst_DeviceTypeTagId := dwDeviceTypeTagID;

            // ���� ����������� ������ � ��������� ��������, ������ ��������� �� �����
            if not(dwDeviceID = 0) then begin
              PostLogRecordAddMsgNow(70898, dwDeviceID, -1, -1, '', llDebug);

              // �������� ����� ������� � ���� (����) ��������
              try
                TrItem.Hst_DeviceAddress := rdm.GetOneCell('select vd_addr from vda_devices where vd_id = ' + rdm.IntToSQL(TrItem.Hst_DeviceId, IntToStr(HIGH(Integer))));
              except on e : Exception do
                begin
                  PostLogRecordAddMsgNow(70879, -1, -1, E_FAIL, '', llErrors);
                  TrItem.Hst_DeviceAddress := HIGH(DWORD);
                end;
              end;

              // ����������� �������������� ������ �� Item-� � ���� ������
              rdm.Lock;
              try
                ds := rdm.GetQueryDataset(
                  'select ' +
                  'vp.vp_id, ' +
                  'vmf.vmf_func_number as func_number, ' +
                  'vdtt.VDTT_MODBUS_READ_ADDRESS as data_address, ' +
                  'vdtt.VDTT_ACCESS_RIGHTS as access_rights, ' +
                  'vdt.vdt_size_in_bytes, ' +
                  'vdtt.vdf_id ' +
                  'from vda_device_type_tags vdtt ' +
                  'left outer join vda_device_type_versions vdtv on vdtv.vdtv_id = vdtt.vdtv_id ' +
                  'left outer join vn_protocols vp on vp.vp_id = vdtv.vp_id ' +
                  'left outer join VN_MODBUS_FUNCTIONS vmf on vmf.vmf_id = vdtt.VDTT_MODBUS_READ_FUNC_ID ' + // !!!! VDTT_MODBUS_READ_FUNC_ID !!!!
                  'left outer join vn_datatypes vdt on vdt.vdt_id = vdtt.vdt_id ' +
                  'where vdtt.vdtt_id = ' + rdm.IntToSQL(dwDeviceTypeTagID, '-1')
                );
                try
                  // ��������� ������
                  ds.Open;
                  // ������������ ��������� ������
                  if ds.eof or
                     ds.FieldByName('vp_id').IsNull or
                     ds.FieldByName('func_number').IsNull or
                     ds.FieldByName('data_address').IsNull or
                     ds.FieldByName('access_rights').IsNull or
                     ds.FieldByName('vdt_size_in_bytes').IsNull or
                     ds.FieldByName('vdf_id').IsNull or
                     (TrItem.Hst_DeviceAddress = DWORD(high(Integer)))
                  then begin
                    PostLogRecordAddMsgNow(70899, -1, -1, -1, '', llErrors);
                    TrItem.Free; // ��� ��� �� ������� �������� ��� �������� ����������� ������� ��
                    ppErrors^[ItemIndex] := OPC_E_UNKNOWNITEMID;
                    dwErrorCount := Succ(dwErrorCount);
                    ItemIndex := Succ(ItemIndex);
                    continue;
                  end;

                  //todo: ����� �� �����
                  // ���������� ������������� ���������
                  TrItem.Hst_ProtocolId := ds.FieldByName('vp_id').AsVariant;
                  // ���������� ����� ������� ���������
                  TrItem.Hst_FuncNumber := ds.FieldByName('func_number').AsVariant;
                  // ���������� ����� ������
                  TrItem.Hst_DataAddress := DWORD(ds.FieldByName('data_address').AsInteger);
                  // ���������� ����� ������� � ��������
                  TrItem.Hst_AccessRights := DWORD(ds.FieldByName('access_rights').AsInteger);
                  // ���������� ������ ���� ������ � ������
                  TrItem.Hst_DataSizeInBytes := ds.FieldByName('vdt_size_in_bytes').AsInteger;
                  // ������������� ������� ������������� ������ � ������
                  TrItem.Hst_DataFormatId := ds.FieldByName('vdf_id').AsInteger;

                except on e : Exception do begin
                  PostLogRecordAddMsgNow(70881, -1, -1, E_FAIL, e.Message, llErrors);
                  TrItem.Free; // ��� ��� �� ������� �������� ��� �������� ����������� ������� ��
                  ppErrors^[ItemIndex] := E_FAIL; // �������������� ������
                  dwErrorCount := Succ(dwErrorCount);
                  ItemIndex := Succ(ItemIndex);
                  continue;
                end;
                end;
              finally
                ds.free;
                rdm.Unlock;
              end;

            end else begin
              TrItem.Hst_DeviceAddress := HIGH(DWORD);
              // ����� ������� ������������ � �������������� ����������� �������� ����-�������
              TrItem.Hst_ProtocolId := VPHstDriverInterface;
              // ���������� ����� ������� ���������
              TrItem.Hst_FuncNumber := 0;
              // ���������� ����� ������
              TrItem.Hst_DataAddress := 0;
              // ���������� ����� ������� � ��������
              TrItem.Hst_AccessRights := OPC_READABLE + OPC_WRITEABLE;
              // ���������� ������ ���� ������ � ������
              TrItem.Hst_DataSizeInBytes := 0;
              // ������������� ������� ������������� ������ � ������
              TrItem.Hst_DataFormatId := 0;
            end;

            // ��������� ���������� � ����� (��������) ������ ���������� �� ������� �������������� �����
            tr.Items[tr.Items.Count - 1] := TrItem;

            // ���� ��������� ������ ���������� ��� ������� ����������(��������)
            TrItemList := TrItemListSet.FindByDriverId(TrItem.Hst_DriverID);
            // ���� ������ ��� ��� ������� ����������(��������) ��� �� ������,
            // ������� ���, � ��������� �� ��������� ������� ����������
            if not assigned(TrItemList) then begin
              PostLogRecordAddMsgNow(70900, -1, -1, -1, '', llDebug);
  //            trList := TVpNetDATransactionItemList.Create(tr.Hst_DriverID);
              TrItemList := TVpNetDATransactionItemList.Create;
              TrItemListSet.Add(TrItemList);
            end;

            // ��������� ���������� � ������ ���������� ��� ������� ����������(��������)
            TrItemList.Add(TrItem);

            // ������� � ���������� ��������
            ItemIndex := Succ(ItemIndex);
          end;

          //----------------------------------------------------------------
          // �������� ������� ��������� ���������� �����������(���������) ��� ����������
          //----------------------------------------------------------------
          TrItemListIndex := 0;
          while (TrItemListIndex < TrItemListSet.Count) do begin
            PostLogRecordAddMsgNow(70344, 2, -1, -1, '2', llDebug);
            // �������� ��������� �� ������� ���������� ���������� ����������(��������)
            PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_TRANSACTIONS,
              // ������������� �������� Hst-�������
              // (������������, ��� ������ ���������� �� Hst_DriverId);
              TrItemListSet[TrItemListIndex].FirstTrItemDriverId,
              Integer(Pointer(TrItemListSet[TrItemListIndex])), // ������ ����������
            );

            Application.ProcessMessages;
            // ������� � ���������� ������
            TrItemListIndex := Succ(TrItemListIndex);
          end;

          case SyncType of
            vndtstSync: begin
              PostLogRecordAddMsgNow(70901, -1, -1, -1, 'Sync', llDebug);
              // ��� ����������� ������...
              //----------------------------------------------------------------
              // �������� ���������� ���� ���������� ���������� �� ���� �����������(���������)
              //----------------------------------------------------------------
              TrItemIndex := 0;
              while (TrItemIndex < tr.Items.Count) do begin
                // ���� ��� ������� �������� ������� ���������� ������ ��� - ��������� � ��������� ����������
                if (tr.Items[TrItemIndex] = nil) then begin
                  PostLogRecordAddMsgNow(70902, -1, -1, -1, '', llErrors);
                  TrItemIndex := Succ(TrItemIndex);
                  Continue;
                end;

                // ��� �� ��������� ��������� - ��������� � ��������� ����������
                if tr.Items[TrItemIndex].DA_State = vndtsComplete then begin
                  PostLogRecordAddMsgNow(70903, -1, -1, -1, '', llDebug);
                  TrItemIndex := Succ(TrItemIndex);
                  Continue;
                end;

                Sleep(1);
                Application.ProcessMessages;
              end;

              //----------------------------------------------------------------
              // ������ �� ������ ���������� � ���������� �������� ��������
              //----------------------------------------------------------------
              ItemIndex := 0;
              dwErrorCount := 0;
              // �������� �� ����� �������
              while (ItemIndex < dwCount) do begin
                // ����� ��������� ���������� �� ������
                TrItem := tr.Items[ItemIndex];
                if assigned(TrItem) then begin
                  // ���� �� ���� ����� ���� ����������, �������������� ��������
                  // �������� �������� ���������� �� ����������
                  PostLogRecordAddMsgNow(70904, -1, -1, -1, '', llDebug);
                  ppvValues^[ItemIndex] := TrItem.VQT.vDataValue;
                  ppwQualities^[ItemIndex] := TrItem.VQT.wQuality;
                  ppftTimestamps^[ItemIndex] := TrItem.VQT.ftTimeStamp;
                  ppErrors^[ItemIndex] := TrItem.DA_Result;
                end else begin
                  // ���� �� ���� ����� ��� ����������, �������������� ��������
                  // �������� �������� ��� ������ ���������� ��� ���������
                  PostLogRecordAddMsgNow(70905, -1, -1, -1, '', llErrors);
                  ppErrors^[ItemIndex] := E_FAIL; // �������������� ������
                  dwErrorCount := Succ(dwErrorCount); // ����������� ������� ������
                end;

                // ����� ����, ��� �������� ���������� ������
                Item := InterestedItems[ItemIndex];
                // ���� ���� ����� ����, ��������� ��� ������
                if assigned(Item) then begin
                  PostLogRecordAddMsgNow(70906, -1, -1, -1, '', llDebug);
                  Item.Value := ppvValues^[ItemIndex];
                  Item.Quality := ppwQualities^[ItemIndex];
                  Item.Timestamp := ppftTimestamps^[ItemIndex];
                end;
                // ������� � ���������� ��������
                ItemIndex := Succ(ItemIndex);
              end;

              // �������� DA-���������� �� ������ ���������� ������, � �� �����������
              Transactions.Remove(tr);
              tr.Items.DestroyTransactionItems;
              tr.Items.Free;

              //������� ��������� ������� ���������� (�� �� ���� ����������)
              // (��������� ������ ���������� ��� �� �����, ��� ��� ��� ���������� ���� �
              // ����� (��������) ������ ����������)
              TrItemListSet.DestroyTransactionItemLists;

            end;

            vndtstAsync: begin
              PostLogRecordAddMsgNow(70907, -1, -1, -1, 'Async', llDebug);
              // ��� ������������ ������ �������� ������� ��������� �������
              // ���������� ����� ������� ����������� ������ Messege-��
            end;

            else begin
              PostLogRecordAddMsgNow(70280, Integer(SyncType), -1, E_FAIL, '�������� ��� �������������', llErrors);
            end;
          end;

          //----------------------------------------------------------------
          // ����������� ��������
          //----------------------------------------------------------------
        finally
          // ������� ������ �� ������� Host-�������
          DriverRefIndex := 0;
          while DriverRefIndex < ReferencedHstDriverIDs.Count do begin
            // ��������� ������� �� ��������� ������ ��������� ������� Host-�������
            // � �������� ���������� �������
            PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_RELEASE, DWORD(ReferencedHstDriverIDs[DriverRefIndex]), 0);
            Application.ProcessMessages; //???
            // ��������� � �������������� ���������� �������� Host-�������
            DriverRefIndex := Succ(DriverRefIndex);
          end;

          // �������� ������ ������, ��� ������� ����������� �������
          if assigned(InterestedItems) then begin
            InterestedItems.Free;
          end else begin
            PostLogRecordAddMsgNow(70908, -1, -1, -1, '', llErrors);
          end;

          // �������� ��������� ������� ���������� ��� ������ ����������(���������)
          if assigned(TrItemListSet) then begin
            TrItemListSet.Free;
          end else begin
            PostLogRecordAddMsgNow(70909, -1, -1, -1, '', llErrors);
          end;

          // ������� ������ ��������������� ���������, �� ������� ���� ��������� ������
          if assigned(ReferencedHstDriverIDs) then begin
            ReferencedHstDriverIDs.Free;
          end else begin
            PostLogRecordAddMsgNow(70910, -1, -1, -1, '', llErrors);
          end;

        end;

        if dwErrorCount = 0 then begin
          PostLogRecordAddMsgNow(70911, -1, -1, -1, '', llDebug);
          result := S_OK
        end else begin
          PostLogRecordAddMsgNow(70912, dwErrorCount, -1, -1, '', llErrors);
          result := S_FALSE;
        end;

      except
        on e : Exception do begin
          PostLogRecordAddMsgNow(70279, -1, -1, E_FAIL, e.Message, llErrors);
          // ���� ������� ��������, ������� �������� ���������
          result := E_FAIL;

          if assigned(phClients) then begin
            CoTaskMemFree(phClients);
            phClients := nil;
          end;

          if assigned(ppvValues) then begin
            CoTaskMemFree(ppvValues);
            ppvValues := nil;
          end;

          if assigned(ppwQualities) then begin
            CoTaskMemFree(ppwQualities);
            ppwQualities := nil;
          end;

          if assigned(ppftTimeStamps) then begin
            CoTaskMemFree(ppftTimeStamps);
            ppftTimeStamps := nil;
          end;

          if assigned(ppErrors) then begin
            CoTaskMemFree(ppErrors);
            ppErrors := nil;
          end;
        end;
      end;
    finally
      Unlock;
    end;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70274, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL
    end;
  end;
end;

// Callback initialization
procedure TVpNetOPCGroup.CallBackOnConnect(const Sink: IUnknown; Connecting: Boolean);
begin
  try
  if connecting then
    FOPCDataCallback := Sink as IOPCDataCallback
  else
    FOPCDataCallback := nil;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70281, -1, -1, E_UNEXPECTED, e.Message, llErrors);
    end;
  end;
end;

function TVpNetOPCGroup.DoCallOnDataChange(tr : TVpNetDATransaction) : HRESULT;
var
  ItemIndex : DWORD;
  // ��������� IOPCDataCallback.OnDataChange()
  dwTransid: DWORD;
  hGroup:                     OPCHANDLE;
  hrMasterquality:            HResult; // ����� ��������� ������
  hrMastererror:              HResult;
  dwCount:                    DWORD;
  phClientItems:              POPCHANDLEARRAY;
  pvValues:                   POleVariantArray;
  pwQualities:                PWordArray;
  pftTimeStamps:              PFileTimeArray;
  pErrors:                    PResultList;
begin
  try
    Lock;
    try
      PostLogRecordAddMsgNow(70922, -1, -1, -1, 'DoOnDataChange()', llDebug);

      result := E_UNEXPECTED;

      // ���� ��� ����������, ���������� E_UNEXPECTED
      if not(assigned(tr)) then begin
        PostLogRecordAddMsgNow(70283, -1, -1, E_INVALIDARG, '', llErrors);
        result := E_INVALIDARG;
        exit;
      end;

      // ���� �������� � Callback-�����������, ���������� E_FAIL
      if not(assigned(FOPCDataCallback)) then begin
        PostLogRecordAddMsgNow(70284, -1, -1, E_NOINTERFACE, '', llErrors);
        result := E_NOINTERFACE;
        exit;
      end;



      // ���� ��� ��� ��������� ������������� ���������� �� ���������� ������,
      // ��������� ������
      if not(tr.InvocationType = vnditSubscription) then begin
        PostLogRecordAddMsgNow(70934, Integer(tr.InvocationType), -1, E_UNEXPECTED, '�������� �������� ����������', llErrors);
        result := E_UNEXPECTED;
        exit;
      end;

      // ��� ������ �� ��������, � �������� ���������� ����������
      // ����������� 0
      dwTransid := 0;

      // ���������� ������������� ������
      hGroup := FhClient;

      // ����� Quality
      hrMasterquality := tr.Quality;

      // ���� � ���������� ���������� hrMasterquality ��������� ������, ���������� E_FAIL
      if hrMasterquality = E_FAIL then begin
        PostLogRecordAddMsgNow(70286, -1, -1, E_FAIL, '', llErrors);
        result := E_FAIL;
        exit;
      end;

      // ����� ��������� ���������� ����������
      hrMastererror := tr.GlobalResult;
      // ���� � ���������� ���������� hrMastererror ��������� ������, ���������� E_FAIL
      if hrMastererror = E_FAIL then begin
        PostLogRecordAddMsgNow(70287, -1, -1, E_FAIL, '', llErrors);
        result := E_FAIL;
        exit;
      end;

      //todo: �������� � �������� ������� ������ ������������ ������

      // ���������� �������� ���������
      dwCount := tr.Items.Count;

      // �������� ������ ��� �������� ������
      phClientItems := POPCHANDLEARRAY(CoTaskMemAlloc(dwCount * sizeof(OPCHANDLE)));
      pvValues := POleVariantArray(CoTaskMemAlloc(dwCount * sizeof(OleVariant)));
      ItemIndex := 0;
      while ItemIndex < dwCount do begin
        VariantInit(pvValues^[ItemIndex]);
        ItemIndex := Succ(ItemIndex);
      end;
      pwQualities := PWordArray(CoTaskMemAlloc(dwCount * sizeof(Word)));
      pftTimeStamps := PFileTimeArray(CoTaskMemAlloc(dwCount * sizeof(TFileTime)));
      pErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));

      // ���������� �������� ��������
      ItemIndex := 0;
      while ItemIndex < dwCount do begin
        // ���������� ������������� ��������
        phClientItems^[ItemIndex] := tr.Items[ItemIndex].DA_hClient;
        pvValues^[ItemIndex] := tr.Items[ItemIndex].VQT.vDataValue;
        pwQualities^[ItemIndex] := tr.Items[ItemIndex].VQT.wQuality;
        pErrors^[ItemIndex] := tr.Items[ItemIndex].DA_Result;
        pftTimeStamps^[ItemIndex] := tr.Items[ItemIndex].VQT.ftTimeStamp;
        ItemIndex := Succ(ItemIndex);
      end;

      // ����� Callback-�������

      PostLogRecordAddMsgNow(70923, -1, -1, -1, '����� OnDataChange()', llDebug);

      result := FOPCDataCallback.OnDataChange(
        dwTransId,
        hGroup,
        hrMasterquality,
        hrMastererror,
        dwCount,
        phClientItems,
        pvValues,
        pwQualities,
        pftTimeStamps,
        pErrors
      );

      PostLogRecordAddMsgNow(70924, -1, -1, -1, '����� OnDataChange()', llDebug);

    finally
      Unlock;
    end;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70282, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetOPCGroup.DoCallOnReadCompleted(tr : TVpNetDATransaction) : HRESULT;
var
  dwTransid: DWORD;
  hGroup:                     OPCHANDLE;
  hrMasterquality:            HResult; // ����� ��������� ������
  hrMastererror:              HResult;
  dwCount:                    DWORD;
  phClientItems:              POPCHANDLEARRAY;
  pvValues:                   POleVariantArray;
  pwQualities:                PWordArray;
  pftTimeStamps:              PFileTimeArray;
  pErrors:                    PResultList;
  ItemIndex : Integer;
begin
  try
    Lock;
    try


      result := E_UNEXPECTED;

      // ���� ��� ����������, ���������� E_UNEXPECTED
      if not(assigned(tr)) then begin
        PostLogRecordAddMsgNow(70857, -1, -1, E_INVALIDARG, '', llErrors);
        result := E_INVALIDARG;
        exit;
      end;

      // ���� �������� � Callback-�����������, ���������� E_FAIL
      if not(assigned(FOPCDataCallback)) then begin
        PostLogRecordAddMsgNow(70859, -1, -1, E_NOINTERFACE, '', llErrors);
        result := E_NOINTERFACE;
        exit;
      end;

      // ���� ��� ��� ��������� ������������� ���������� �� ������������ ������,
      // ��������� ������
      if not(tr.InvocationType = vnditRead) then begin
        PostLogRecordAddMsgNow(70860, Integer(tr.InvocationType), -1, E_UNEXPECTED, '�������� �������� ����������', llErrors);
        result := E_UNEXPECTED;
        exit;
      end;

      // ��� ������������ ������, � �������� ���������� ����������
      // ����������� ��������, �������� � ������� ������������ ������
      dwTransid := tr.dwClientTransactionId;

      // ���������� ������������� ������
      hGroup := FhClient;

      // ����� Quality
      hrMasterquality := tr.Quality;

      // ���� � ���������� ���������� hrMasterquality ��������� ������, ���������� E_FAIL
      if hrMasterquality = E_FAIL then begin
        PostLogRecordAddMsgNow(70861, -1, -1, E_FAIL, '', llErrors);
        result := E_FAIL;
        exit;
      end;

      // ����� ��������� ���������� ����������
      hrMastererror := tr.GlobalResult;
      // ���� � ���������� ���������� hrMastererror ��������� ������, ���������� E_FAIL
      if hrMastererror = E_FAIL then begin
        PostLogRecordAddMsgNow(70862, -1, -1, E_FAIL, '', llErrors);
        result := E_FAIL;
        exit;
      end;



      // ���������� �������� ���������
      dwCount := tr.Items.Count;

      // �������� ������ ��� �������� ������
      phClientItems := POPCHANDLEARRAY(CoTaskMemAlloc(dwCount * sizeof(OPCHANDLE)));
      pvValues := POleVariantArray(CoTaskMemAlloc(dwCount * sizeof(OleVariant)));
      ItemIndex := 0;
      while ItemIndex < dwCount do begin
        VariantInit(pvValues^[ItemIndex]);
        ItemIndex := Succ(ItemIndex);
      end;
      pwQualities := PWordArray(CoTaskMemAlloc(dwCount * sizeof(Word)));
      pftTimeStamps := PFileTimeArray(CoTaskMemAlloc(dwCount * sizeof(TFileTime)));
      pErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));

      // ���������� �������� ��������
      ItemIndex := 0;
      while ItemIndex < dwCount do begin
        // ���������� ������������� ��������
        phClientItems^[ItemIndex] := tr.Items[ItemIndex].DA_hClient;
        pvValues^[ItemIndex] := tr.Items[ItemIndex].VQT.vDataValue;
        pwQualities^[ItemIndex] := tr.Items[ItemIndex].VQT.wQuality;
        pErrors^[ItemIndex] := tr.Items[ItemIndex].DA_Result;
        pftTimeStamps^[ItemIndex] := tr.Items[ItemIndex].VQT.ftTimeStamp;
        ItemIndex := Succ(ItemIndex);
      end;

      // ����� Callback-�������



      result := FOPCDataCallback.OnReadComplete(
        dwTransId,
        hGroup,
        hrMasterquality,
        hrMastererror,
        dwCount,
        phClientItems,
        pvValues,
        pwQualities,
        pftTimeStamps,
        pErrors
      );

      PostLogRecordAddMsgNow(70865, dwTransId, -1, result, '������ IOPCDataCallback.OnReadComplete()', llErrors);

    finally
      Unlock;
    end;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70858, -1, -1, E_FAIL, e.Message, llErrors);
      result := E_FAIL;
    end;
  end;
end;

initialization
  try
    TAutoObjectFactory.Create(ComServer, TVpNetOPCGroup, Class_VpNetOPCGroup,
      ciMultiInstance, tmApartment);
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70288, -1, -1, E_UNEXPECTED, e.Message, llErrors);
    end;
  end;
end.

