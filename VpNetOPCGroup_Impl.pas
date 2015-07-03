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
    FCS : TRTLCriticalSection; // Критическая секция
    FServObj : Pointer;
    FConnectionPoints: TConnectionPoints;
    FEvents: IVpNetOPCGroupEvents;
    FControlThread : Pointer;
    FRDM : TVpNetDARDM;
    FName : String;
    FActive : LongBool;
    FhClient : OPCHANDLE; // Клиентский идентификатор группы
    FTimeBais : longint; // Временной пояс (UTC = (local time) + TimeBais)
    FUpdateRate : DWORD; // Максимальное время обновление [мс]
    FDeadband : Single;
    FLCID : DWORD; // Идентификатор LOCALE данной группы
    FhServer : OPCHANDLE;
    FItems : TVpNetOPCItemList;
    FKeepAlive : DWORD;
    FOPCDataCallback : IOPCDataCallback; // Клиентский Callback интерфейс
    FTransactions : TVpNetDATransactionList; // Список транзакций
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
            dwSource:                   DWORD; // Источник данных (Device/CACHE)
            pdwMaxAge:                  PDWORDARRAY;
            SyncType:                   TVpNetDATransactionSyncType;
            InvocationType:             TVpNetDATransactionInvocationType; // Тип источника возникновения транзакции
            dwClientTransactionId:      DWORD; // Заданный клиентом идентификатор транзакции
            dwClientCancelId:           DWORD; // Заданный клиентом идентификатор отмены транзакции
      out   phClients:                  POPCHANDLEARRAY; // Клиентские идентификаторы элементов (тегов) транзакции
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
    PostLogRecordAddMsgNow(70166, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message, llErrors);
  end;
end;

constructor TVpNetOPCGroup.Create;
begin
  try
    inherited;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70260, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
    end;
  end;

  try
    // Инициализация критической секции
    InitializeCriticalSection(FCS);
    // Установка начальных (неопределенных) значений свойств группы
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

    // Создание списка элементов группы
    FItems := TVpNetOPCItemList.Create;

    // Список асинхронных DA-транзакций группы
    FTransactions := TVpNetDATransactionList.Create;

    // Создание и запуск обслуживающего потока
    FControlThread := TVpNetOPCGroupControlThread.Create(self, false);

    //--- ConnectionPoints ---
    // Изначально клиентский callback интерфейс не определен
    FOPCDataCallback := nil;

    // Сообщение о добавление группы
    PostMessage(Application.MainForm.Handle, WM_DA_GROUP_CREATED, 0, 0);

  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70261, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
    end;
  end;
end;

constructor TVpNetOPCGroup.Create(aServObj : Pointer; aName : String; aActive : LongBool;
  aUpdateRate : DWORD; ahClient : OPCHANDLE; pTimeBais : PLongint;
  aDeadBand : Single; aLCID : TLCID; ahServer : OPCHANDLE);
begin
  try
    Create;
    // Установка начальных (переданных в конструктор) значений свойств группы
    FServObj := aServObj;
    FName := aName;
    FActive := aActive;
    FUpdateRate := aUpdateRate;
    FhClient := ahClient;
    FTimeBais := ValidateTimeBias(pTimeBais);
    FDeadBand := aDeadBand;
    FLCID := aLCID;
    FhServer := ahServer;
    PostProcessInfoNow(70017, 'Создание группы (hSrv='+IntToStr(FhServer)+'; hClient='+IntToStr(FhClient)+').');
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70262, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
    end;
  end;
end;

procedure TVpNetOPCGroup.Initialize;
begin
  try
    inherited Initialize;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70263, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
    end;
  end;

  try
    // Создание обьекта-контейнера, реализующего интерфейс IConnectionPointContainer
    FConnectionPoints := TConnectionPoints.Create(Self);
    if AutoFactory.EventTypeInfo <> nil then
      FConnectionPoints.CreateConnectionPoint(
        IID_IOPCDataCallback, {AutoFactory.EventIID} //todo: Разобраться
        ckSingle, //ckMulti
        CallBackOnConnect
      );
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70264, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
    end;
  end;
end;

destructor TVpNetOPCGroup.destroy;
var
  Item : TVpNetOPCItem;
begin
  try
    try
      PostProcessInfoNow(70018, 'Удаление группы (hSrv='+IntToStr(FhServer)+'; hClient='+IntToStr(FhClient)+').');
      // Блокируем группу
      Lock;
      try
        // Сообщение об удалении группы
        PostMessage(Application.MainForm.Handle, WM_DA_GROUP_DESTROYED, 0, 0);

        // Завершаем обслуживающий поток
        TVpNetOPCGroupControlThread(FControlThread).Terminate;

        // Ожидаем завершения обслуживающего потока
        TVpNetOPCGroupControlThread(FControlThread).WaitFor;

        // Удаление активных транзакций
        Transactions.DeleteTransactions;
        Transactions.Free;

        // Удаляем элементы
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
        // Разблокируем группу
        Unlock;
        // Удаляем критическую секцию
        DeleteCriticalSection(FCS);
      end;
    except
      on e : Exception do begin
        PostLogRecordAddMsgNow(70266, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
      end;
    end;
  finally
    try
      inherited destroy;
    except
      on e : Exception do begin
        PostLogRecordAddMsgNow(70265, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
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
      PostLogRecordAddMsgNow(70267, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
    end;
  end;
end;

procedure TVpNetOPCGroup.Unlock;
begin
  try
    LeaveCriticalSection(FCS);
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70268, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
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
      PostLogRecordAddMsgNow(70269, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
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
      PostLogRecordAddMsgNow(70271, hServer, -1, result, 'Тег не найден');
    end;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70270, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
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
      PostLogRecordAddMsgNow(70273, hServer, -1, result, 'Тег не найден');
    end;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70272, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
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
    PostLogRecordAddMsgNow(70804, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Обнуляем выходные массивы
    ppAddResults := nil;
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70168, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Блокируем группу
    Lock;
    try
      try
        // Проверка количества элементов
        if (dwCount = 0) then begin
          // Если количество элементов неправильное, выходим с E_INVALIDARG
          PostLogRecordAddMsgNow(70866, 0, -1, E_INVALIDARG, '', llErrors);
          result := E_INVALIDARG;
          exit;
        end;

        // Выделение памяти для массива ppAddResults
        ppAddResults := POPCITEMRESULTARRAY(CoTaskMemAlloc(dwCount * sizeof(OPCITEMRESULT)));
        if ppAddResults = nil then begin
          PostLogRecordAddMsgNow(70169, -1, -1, E_OUTOFMEMORY, 'Ошибка выделения памяти', llErrors);
          // Если по каким-то причинам не удалось выделить память для массива ppAddResults,
          // выходим с E_OUTOFMEMORY
          result := E_OUTOFMEMORY;
          exit;
        end;

        // Очищаем содержимое элементов массива ppAddResults
        hr := ClearPOPCITEMRESULTARRAY(ppAddResults, dwCount);
        if hr <> S_OK then begin
          PostLogRecordAddMsgNow(70170, -1, -1, hr, '', llErrors);
          // Если по каким-то причинам не удалось очистить массив,
          // выходим ошибкой, произошедшей в процессе очистки массива
          CoTaskMemFree(ppAddResults);
          ppAddResults := nil;
          result := hr;
          exit;
        end;

        // Выделение памяти для массива ppErrors
        ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
        if ppErrors = nil then begin
          // По каким-то причинам не удалось выделить память для массива ppErrors,
          // поэтому выходим с E_OUTOFMEMORY
          PostLogRecordAddMsgNow(70171, -1, -1, E_OUTOFMEMORY, '', llErrors);
          CoTaskMemFree(ppAddResults);
          ppAddResults := nil;
          result := E_OUTOFMEMORY;
          exit;
        end;

        // Цикл по элементам
        ItemIndex := 0;
        ErrorCount := 0;
        while ItemIndex < dwCount do begin
          // Получаем ссылку на описание элемента
          pItemDef := @pItemArray[ItemIndex];
          // Получаем ссылку на структуру результатов для элемента
          pItemResult := @ppAddResults[ItemIndex];

          // Создаем Item
          Item := TVpNetOPCItem.Create(self);
          // Инициализируем Item по ItemID (pItemDef.szItemID)
          // (заполняем ItemId, VHS_ID, VD_ID, VDTT_ID, ...)

          ppErrors[ItemIndex] := Item.InitByItemDef(pItemDef);
          if ppErrors[ItemIndex] <> S_OK then begin
            Item.free;
            ErrorCount := ErrorCount + 1;
            ItemIndex := ItemIndex + 1;
            continue;
          end;

          // Добавляем Item в список Item-ов группы
          Items.add(Item);

          // Добавляем настройки из Item в структуру ppAddResults[ItemIndex] :
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

        // Если в оприсниях элементов небыло ошибок, возврашаем S_OK,
        // иначе возвращаем S_FALSE
        if ErrorCount = 0 then
          result := S_OK
        else
          result := S_FALSE;
      except on e : Exception do begin
        // В случае непредвиденной ошибки ...
        // ... если память была выделена, освобождаем ее, ...
        PostLogRecordAddMsgNow(70172, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message, llErrors);
        if assigned(ppAddResults) then begin
          CoTaskMemFree(ppAddResults);
          ppAddResults := nil;
        end;
        if Assigned(ppErrors) then begin
          CoTaskMemFree(ppErrors);
          ppErrors := nil;
        end;
        // ... и возвращаем E_FAIL
        result := E_FAIL;
      end;
      end;
    finally
      Unlock;
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70167, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message, llErrors);
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
    PostLogRecordAddMsgNow(70805, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Обнуляем выходные массивы
    ppValidationResults := nil;
    ppErrors := nil;

{09.07.2006}
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70174, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // Проверка количества элементов
    if (dwCount = 0) then begin
      // Если количество элементов неправильное, выходим с E_INVALIDARG
      PostLogRecordAddMsgNow(70175, -1, dwCount, E_INVALIDARG, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // Выделение памяти для массива ppValidationResults
    ppValidationResults := POPCITEMRESULTARRAY(CoTaskMemAlloc(dwCount * sizeof(OPCITEMRESULT)));
    if ppValidationResults = nil then begin
      // По каким-то причинам не удалось выделить память для массива ppValidationResults,
      // поэтому выходим с E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70176, -1, -1, E_OUTOFMEMORY, '', llErrors);
      result := E_OUTOFMEMORY;
      exit;
    end;

    // Очищаем содержимое элементов массива ppValidationResults
    hr := ClearPOPCITEMRESULTARRAY(ppValidationResults, dwCount);
    if hr <> S_OK then begin
      // По каким-то причинам не удалось очистить содержимое массива
      // ppValidationResults, выходим с полученной ошибкой
      PostLogRecordAddMsgNow(70177, -1, -1, hr, '', llErrors);
      CoTaskMemFree(ppValidationResults);
      ppValidationResults := nil;
      result := hr;
      exit;
    end;

    // Выделение памяти для массива ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if ppErrors = nil then begin
      // По каким-то причинам не удалось выделить память для массива ppErrors,
      // поэтому выходим с E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70178, -1, -1, E_OUTOFMEMORY, '', llErrors);
      CoTaskMemFree(ppValidationResults);
      ppValidationResults := nil;
      result := E_OUTOFMEMORY;
      exit;
    end;

    // Блокируем группу
    Lock;
    try
      // Цикл по элементам
      ItemIndex := 0;
      ErrorCount := 0;
      while ItemIndex < dwCount do begin
        // Получаем ссылку на описание элемента
        pItemDef := @pItemArray[ItemIndex];
        // Получаем ссылку на структуру результатов ядл элемента
        pItemResult := @ppValidationResults[ItemIndex];

        // Создаем временный Item
        Item := TVpNetOPCItem.Create(self);
        try
          // Инициализируем Item по ItemID (pItemDef.szItemID)
          // Заполняем параметры:
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

          // Добавляем настройки из Item в структуру ppValidationResults[ItemIndex] :
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
      // Разблокируем группу
      Unlock;
    end;

    // Если в оприсниях элементов небыло ошибок, возврашаем S_OK,
    // иначе возвращаем S_FALSE
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;

  except on e : Exception do begin
    // В случае непредвиденной ошибки ...
    // ... если память была выделена, освобождаем ее, ...
    PostLogRecordAddMsgNow(70173, -1, -1, E_FAIL, e.Message, llErrors);
    if assigned(ppValidationResults) then begin
      CoTaskMemFree(ppValidationResults);
      ppValidationResults := nil;
    end;
    if Assigned(ppErrors) then begin
      CoTaskMemFree(ppErrors);
      ppErrors := nil;
    end;
    // ... и возвращаем E_FAIL
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
    PostLogRecordAddMsgNow(70806, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Обнуляем выходной массив
    ppErrors := nil;

  {09.07.2006}
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70867, -1, Integer(ServerCore.State), E_FAIL, 'Вызов метода', llErrors);
      result := E_FAIL;
      exit;
    end;
  {/09.07.2006}

    // Блокируем группу
    Lock;
    try
      try
        // Проверка количества элементов
        if (dwCount = 0) then begin
          // Если количество элементов неправильное, выходим с E_INVALIDARG
          PostLogRecordAddMsgNow(70868, -1, 0, E_INVALIDARG, '', llErrors);
          result := E_INVALIDARG;
          exit;
        end;

        // Выделение памяти для массива ppErrors
        ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
        if ppErrors = nil then begin
          // Если по каким-то причинам не удалось выделить память для массива ppAddResults,
          // выходим с E_FAIL (поскольку возврат E_OUTOFMEMORY не предусмотрен спецификацией)
          PostLogRecordAddMsgNow(70869, -1, -1, E_FAIL, '', llErrors);
          result := E_FAIL;
          exit;
        end;

        // Цикл по списку удаляемых элементов
        InputArrayIndex := 0;
        ErrorCount := 0;
        while InputArrayIndex < dwCount do begin
          // Находим серверный идент. очередного удаляемого элемента
          hOPC := phServer^[InputArrayIndex];
          // Пытаемся найти по серверному иденту элемент
          hr := FindItemByhServer(hOPC, Item);
          // Анализируем результат поиска
          if hr = S_OK then begin
            // Если нашли, удаляем найденный элемент из списка,...
            Items.Remove(Item);
            // и возвращаем для этого элемента S_OK
            ppErrors[InputArrayIndex] := S_OK;
          end else if hr = OPC_E_INVALIDHANDLE then begin
            // если не нашли, для этого элемента возвращаем OPC_E_INVALIDHANDLE
            PostLogRecordAddMsgNow(70870, -1, hr, OPC_E_INVALIDHANDLE, '', llErrors);
            ppErrors[InputArrayIndex] := OPC_E_INVALIDHANDLE;
          end else begin
            // Если произошла непредвиденная ошибка, если память была выделена, освобождаем ее, ...
            PostLogRecordAddMsgNow(70871, -1, hr, E_FAIL, '', llErrors);
            if Assigned(ppErrors) then begin
              CoTaskMemFree(ppErrors);
              ppErrors := nil;
            end;
            // ... и выходим с E_FAIL
            result := E_FAIL;
            exit;
          end;
          // Переходим к следующему удаляемому элементу
          InputArrayIndex := Succ(InputArrayIndex);
        end;

        // Возвращаем успешный результат
        if ErrorCount = 0 then
          result := S_OK
        else
          result := S_FALSE;

      except on e : Exception do begin
        // В случае непредвиденной ошибки ...
        // ... если память была выделена, освобождаем ее, ...
        PostLogRecordAddMsgNow(70180, -1, -1, E_FAIL, e.Message, llErrors);
        if Assigned(ppErrors) then begin
          CoTaskMemFree(ppErrors);
          ppErrors := nil;
        end;
        // ... и возвращаем E_FAIL
        result := E_FAIL;
      end;
      end;
    finally
      // Разблокируем группу
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
    PostLogRecordAddMsgNow(70807, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Обнуляем выходной массив
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70182, -1, -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Блокируем группу
    Lock;
    try
      try
        // Проверка количества элементов
        if (dwCount = 0) then begin
          // Если количество элементов неправильное, выходим с E_INVALIDARG
          PostLogRecordAddMsgNow(70183, -1, dwCount, E_INVALIDARG, '', llErrors);
          result := E_INVALIDARG;
          exit;
        end;

        // Выделение памяти для массива ppErrors
        ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
        if ppErrors = nil then begin
          // Если по каким-то причинам не удалось выделить память для массива ppAddResults,
          // выходим с E_FAIL (поскольку возврат E_OUTOFMEMORY не предусмотрен спецификацией)
          PostLogRecordAddMsgNow(70184, -1, -1, E_FAIL, '', llErrors);
          result := E_FAIL;
          exit;
        end;

        // Цикл по списку удаляемых элементов
        InputArrayIndex := 0;
        ErrorCount := 0;
        while InputArrayIndex < dwCount do begin
          // Находим серверный идент. очередного элемента заданного списка
          hOPC := phServer^[InputArrayIndex];
          // Пытаемся найти по серверному иденту элемент
          hr := FindItemByhServer(hOPC, Item);
          // Анализируем результат поиска
          if hr = S_OK then begin
            // Если нашли, изменяем состояние актиности найденного элементо на заданное,...
            // и возвращаем для этого элемента результат
            ppErrors[InputArrayIndex] := Item.SetActive(bActive);
          end else if hr = OPC_E_INVALIDHANDLE then begin
            // если не нашли, для этого элемента возвращаем OPC_E_INVALIDHANDLE
            PostLogRecordAddMsgNow(70872, -1, hr, OPC_E_INVALIDHANDLE, '', llErrors);
            ppErrors[InputArrayIndex] := OPC_E_INVALIDHANDLE;
          end else begin
            // Если произошла непредвиденная ошибка, ...
            // ... если память была выделена, освобождаем ее, ...
            PostLogRecordAddMsgNow(70185, -1, hr, E_FAIL, '', llErrors);
            if Assigned(ppErrors) then begin
              CoTaskMemFree(ppErrors);
              ppErrors := nil;
            end;
            // ... и выходим с E_FAIL
            result := E_FAIL;
            exit;
          end;

          // Переходим к следующему удаляемому элементу
          InputArrayIndex := Succ(InputArrayIndex);
        end;

        // Возвращаем успешный результат
        if ErrorCount = 0 then
          result := S_OK
        else
          result := S_FALSE;
      except on e : Exception do begin
        // В случае непредвиденной ошибки ...
        // ... если память была выделена, освобождаем ее, ...
        PostLogRecordAddMsgNow(70186, -1, -1, E_FAIL, e.Message, llErrors);
        if Assigned(ppErrors) then begin
          CoTaskMemFree(ppErrors);
          ppErrors := nil;
        end;
        // ... и возвращаем E_FAIL
        result := E_FAIL;
      end;
      end;
    finally
      // Разблокируем группу
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
    PostLogRecordAddMsgNow(70808, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Обнуляем выходной массив
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70188, -1, -1, E_FAIL, '', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Проверка количества элементов
    if (dwCount = 0) then begin
      // Если количество элементов неправильное, выходим с E_INVALIDARG
      PostLogRecordAddMsgNow(70189, -1, -1, E_INVALIDARG, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // Выделение памяти для массива ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if ppErrors = nil then begin
      // Если по каким-то причинам не удалось выделить память для массива ppAddResults,
      // выходим с E_FAIL (поскольку возврат E_OUTOFMEMORY не предусмотрен спецификацией)
      PostLogRecordAddMsgNow(70190, -1, -1, E_FAIL, '', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Блокируем группу
    Lock;
    try
      // Цикл по списку удаляемых элементов
      InputArrayIndex := 0;
      ErrorCount := 0;
      while InputArrayIndex < dwCount do begin
        // Находим серверный идент. очередного элемента заданного списка
        hOPC := phServer^[InputArrayIndex];
        // Пытаемся найти по серверному иденту элемент
        hr := FindItemByhServer(hOPC, Item);
        // Анализируем результат поиска
        if hr = S_OK then begin
          // Если нашли, изменяем состояние актиности найденного элементо на заданное,...
          // и возвращаем для этого элемента результат
          ppErrors[InputArrayIndex] := Item.SethClient(phClient^[InputArrayIndex]);
        end else if hr = OPC_E_INVALIDHANDLE then begin
          // если не нашли, для этого элемента возвращаем OPC_E_INVALIDHANDLE
          PostLogRecordAddMsgNow(70873, -1, hr, OPC_E_INVALIDHANDLE, '', llErrors);
          ppErrors[InputArrayIndex] := OPC_E_INVALIDHANDLE;
        end else begin
          // Если произошла непредвиденная ошибка, ...
          // ... если память была выделена, освобождаем ее, ...
          if Assigned(ppErrors) then begin
            CoTaskMemFree(ppErrors);
            ppErrors := nil;
          end;
          // ... и выходим с E_FAIL
          PostLogRecordAddMsgNow(70191, hr, -1, E_FAIL, '', llErrors);
          result := E_FAIL;
          exit;
        end;

        // Переходим к следующему удаляемому элементу
        InputArrayIndex := Succ(InputArrayIndex);
      end;
    finally
      // Разблокируем группу
      Unlock;
    end;

    // Возвращаем успешный результат
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;

  except on e : Exception do begin
    // В случае непредвиденной ошибки ...
    // ... если память была выделена, освобождаем ее, ...
    PostLogRecordAddMsgNow(70187, -1, -1, E_FAIL, e.Message, llErrors);
    if Assigned(ppErrors) then begin
      CoTaskMemFree(ppErrors);
      ppErrors := nil;
    end;
    // ... и возвращаем E_FAIL
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
    PostLogRecordAddMsgNow(70809, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Обнуляем выходной массив
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70193, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Проверка количества элементов
    if (dwCount = 0) then begin
      // Если количество элементов неправильное, выходим с E_INVALIDARG
      PostLogRecordAddMsgNow(70194, -1, -1, E_FAIL, '', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // Выделение памяти для массива ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if ppErrors = nil then begin
      // Если по каким-то причинам не удалось выделить память для массива ppAddResults,
      // выходим с E_FAIL (поскольку возврат E_OUTOFMEMORY не предусмотрен спецификацией)
      PostLogRecordAddMsgNow(70195, -1, -1, E_FAIL, '', llErrors);
      result := E_FAIL;
      exit;
    end;

    //Блокируем группу
    Lock;
    try
      // Цикл по списку удаляемых элементов
      InputArrayIndex := 0;
      ErrorCount := 0;
      while InputArrayIndex < dwCount do begin

        // Находим серверный идент. очередного элемента заданного списка
        hOPC := phServer^[InputArrayIndex];
        // Пытаемся найти по серверному иденту элемент
        hr := FindItemByhServer(hOPC, Item);
        // Анализируем результат поиска
        if hr = S_OK then begin
          NewDataType := pRequestedDatatypes^[InputArrayIndex];
          // Если нашли, пытаемся изменить запрашиваемый тип данных найденного элемента (Item.RequestedDataType) на заданный  ,...
          ppErrors[InputArrayIndex] := Item.SetNewRequestedDataType(NewDataType);

          // Если опреация по изменению типа запрашиваемых данны завершилась не успешно,...
          if ppErrors[InputArrayIndex] <> S_OK then begin
            // ...приращаем счетчик ошибок
            ErrorCount := Succ(ErrorCount);
          end;

        end else if hr = OPC_E_INVALIDHANDLE then begin
          // если не нашли, для этого элемента возвращаем OPC_E_INVALIDHANDLE
          PostLogRecordAddMsgNow(70874, hr, -1, OPC_E_INVALIDHANDLE, '', llErrors);
          ppErrors[InputArrayIndex] := OPC_E_INVALIDHANDLE;
          ErrorCount := Succ(ErrorCount);
        end else begin
          // Если произошла непредвиденная ошибка, ...
          // ... если память была выделена, освобождаем ее, ...
          if Assigned(ppErrors) then begin
            CoTaskMemFree(ppErrors);
            ppErrors := nil;
          end;
          // ... и выходим с E_FAIL
          PostLogRecordAddMsgNow(70196, hr, -1, E_FAIL, '', llErrors);
          result := E_FAIL;
          exit;
        end;

        // Переходим к следующему удаляемому элементу
        InputArrayIndex := Succ(InputArrayIndex);
      end;
    finally
      // Разблокируем группу
      Unlock;
    end;

    // Возвращаем успешній результат
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;

  except on e : Exception do begin
    // В случае непредвиденной ошибки ...
    // ... если память была выделена, освобождаем ее, ...
    PostLogRecordAddMsgNow(70192, hr, -1, E_FAIL, e.Message, llErrors);
    if Assigned(ppErrors) then begin
      CoTaskMemFree(ppErrors);
      ppErrors := nil;
    end;
    // ... и возвращаем E_FAIL
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
    PostLogRecordAddMsgNow(70810, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Задаем начальное значение ppUnk;
    ppUnk := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70198, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Если запрошен недопустимый тип перечисления, возвращаем E_INVALIDARG
    if not IsEqualIID(riid, IEnumOPCItemAttributes) then begin
      PostLogRecordAddMsgNow(70199, -1, -1, E_INVALIDARG, 'Запрошен недопустимый тип перечисления', llErrors);
      result := E_INVALIDARG;
      exit;
    end;
    // Блокируем группу
    Lock;
    try
      // Если нечего перечислять, возвращаем S_FALSE
      if (Items.count = 0) then begin
        result := S_FALSE;
        exit;
      end;
      // Создаем перечисление для элементов
//      ppUnk := CreateComObject(IID_IEnumOPCItemAttributes) as IEnumOPCItemAttributes;
//      ppUnk := TVpNetOPCItemAttributesEnumerator.Create(FItems) as IEnumOPCItemAttributes;
      ppUnk := TVpNetOPCItemAttributesEnumerator.Create(FItems);

    finally
      // Разблокируем группу
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
    PostLogRecordAddMsgNow(70811, -1, -1, S_OK, 'Вызов метода', llDebug);

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70201, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
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

    // Блокируем группу
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
      // Разблокируем группу
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
    PostLogRecordAddMsgNow(70812, -1, -1, S_OK, 'Вызов метода', llDebug);

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70203, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      pRevisedUpdateRate := 0;
      result := E_FAIL;
      exit;
    end;

    // Блокируем группу
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
      // Разблокируем группу
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
    PostLogRecordAddMsgNow(70813, -1, -1, S_OK, 'Вызов метода', llDebug);

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70205, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Проверяем заполненность нового имени группы
    if length(szName) = 0 then begin
      PostLogRecordAddMsgNow(70206, -1, -1, E_INVALIDARG, 'Недопустимое имя группы', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // Блокируем группу
    Lock;
    try
//      if TVpNetOPCDA(ServObj).IsGroupNameUsed(szName) then begin
      if TVpNetOPCDA(ServObj).Groups.IsNameUsed(szName) then begin
        PostLogRecordAddMsgNow(70207, -1, -1, OPC_E_DUPLICATENAME, 'Дублирование имя группы', llErrors);
        result := OPC_E_DUPLICATENAME;
        exit;
      end;
      FName := szName;
    finally
      // Разблокируем группу
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
    PostLogRecordAddMsgNow(70814, -1, -1, S_OK, 'Вызов метода', llDebug);
    NewGroup := nil;
    // Начальная инициализация выходных данных
    ppUnk := nil;
    result := E_FAIL;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70209, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Проверяем ИМЯ ГРУППЫ
    sName := szName;
    if sName = EmptyStr then begin
      // если в качестве имени группы передана пустая строка, пытаемся найти уникальное имя...
      sName := TVpNetOPCDA(ServObj).Groups.GetUniqueName;
      if sName = EmptyStr then begin
        // ... и если уникальное имя найти не удалось, выходим с E_FAIL
        PostLogRecordAddMsgNow(70210, -1, -1, E_FAIL, 'Неверное имя группы', llErrors);
        result := E_FAIL;
        exit;
      end;
    end else if ValidateOPCString(sName) <> S_OK then begin
      // если имя группы содержит недопустимые символы, возвращаем E_INVALIDARG
      PostLogRecordAddMsgNow(70211, -1, -1, E_INVALIDARG, 'Неверное имя группы: ' + sName, llErrors);
      result := E_INVALIDARG;
      exit;
    end else if TVpNetOPCDA(ServObj).Groups.IsNameUsed(sName) then begin
      // если имя группы уже используется, возвращаем OPC_E_DUPLICATENAME
      PostLogRecordAddMsgNow(70212, -1, -1, OPC_E_DUPLICATENAME, 'Дублирование имени группы ' + sName, llErrors);
      result := OPC_E_DUPLICATENAME;
      exit;
    end;

    // Получаем новый серверный идентификатор группы
    if ServerCore.GetNewServerGroupHandle(NewhServer) <> S_OK then begin
      // Если не удалось получить новый серверный идентификатор группы, возвращаем E_EAIL
      PostLogRecordAddMsgNow(70213, NewhServer, -1, E_FAIL, 'Не удалось получить новый серверный идентификатор группы', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Блокируем группу
    Lock;
    try
      // Создание объекта
      NewGroup := TVpNetOPCGroup.Create(ServObj, sName, False, UpdateRate,
        hClient, @TimeBais, Deadband, LCID, NewhServer);

      if NewGroup = nil then begin
        // Если не удалось создать объект, возвращаем E_OUTOFMEMORY
        PostLogRecordAddMsgNow(70214, -1, -1, E_OUTOFMEMORY, 'Ошибка выделения памяти', llErrors);
        result := E_OUTOFMEMORY;
        exit;
      end;

      // Запуса служебного потока группы
      TVpNetOPCGroupControlThread(NewGroup.ControlThread).Resume;

      // Копирование элементов данных в новый объект
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
      // Разблокирвание группы
      Unlock;
    end;

    // Получение интерфейса группы
    hr := IUnknown(NewGroup).QueryInterface(riid, ppUnk);
    if hr <> S_Ok then begin
      PostLogRecordAddMsgNow(70216, hr, -1, E_NOINTERFACE, 'Ошибка интерфейса', llErrors);
      NewGroup.Free;
      result := E_NOINTERFACE;
      exit;
    end;

    // Приращаем счетчик ссылок на объект-группу
    IUnknown(NewGroup)._AddRef;

    // Добавляем ссылку на группу в список локальных групп сервера
    //todo: Синхронизация списка групп
    TVpNetOPCDA(ServObj).Groups.Add(Pointer(NewGroup));

    result := S_OK;
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70208, -1, -1, E_FAIL, e.Message, llErrors);
      ppUnk := nil;
      result := E_FAIL;
      //  Если новая группа уже создана,...
      if Assigned(NewGroup) then begin
        // удаляем ее из списка групп (на случай, если она там есть),...
        TVpNetOPCDA(ServObj).Groups.Remove(Pointer(NewGroup));
        // и удаляем сам обьект
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
    PostLogRecordAddMsgNow(70815, -1, -1, S_OK, 'Вызов метода', llDebug);

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70218, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Блокируем группу
    Lock;
    try
      if dwKeepAliveTime = 0 then begin
        // Если задано 0 (KeepAlive отключено), сохраняем 0
        FKeepAlive := 0;
      end else if dwKeepAliveTime < ServerCore.MinGroupKeepAlive then begin
        // Если задано ненулевое значение KeepAlive, меньшее минимально
        // допустимогозначения, сохраняем минимально допустимое значение
        FKeepAlive := ServerCore.MinGroupKeepAlive;
      end else begin
        // иначе сохраняем заданное значение
        FKeepAlive := dwKeepAliveTime;
      end;

      // Возвращаем сохраненное значение параметра с S_OK
      pdwRevisedKeepAliveTime := FKeepAlive;
    finally
      // Разблокируем группу
      Unlock;
    end;

    // Возвращаем S_OK
    result := S_OK;
  except
    on e : Exception do begin
      // В случае ошибки возвращаем 0 с E_FAIL
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
    PostLogRecordAddMsgNow(70816, -1, -1, S_OK, 'Вызов метода', llDebug);

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70220, Integer(ServerCore.State), -1, E_FAIL, 'Неверное остояние сервера', llErrors);
      pdwKeepAliveTime := 0;
      result := E_FAIL;
      exit;
    end;

    // Блокируем группу
    Lock;
    try
      // Возвращаем значение параметра с S_OK
      pdwKeepAliveTime := FKeepAlive;
    finally
      // Разблокируем группк
      Unlock;
    end;
    // Возвращаем S_OK
    result := S_OK;
  except
    on e : Exception do begin
      // В случае ошибки возвращаем 0 с E_FAIL
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
  PostLogRecordAddMsgNow(70736, -1, -1, E_NOTIMPL, 'Вызов метода', llDebug);
  Result := E_NOTIMPL;
end;

function TVpNetOPCGroup.MoveToPublic: HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70737, -1, -1, E_NOTIMPL, 'Вызов метода', llDebug);
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
    PostLogRecordAddMsgNow(70817, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Обнуляем выходные массивы
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70222, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Проверка количества элементов
    if (dwCount = 0) then begin
      // Если количество элементов неправильное, выходим с E_INVALIDARG
      PostLogRecordAddMsgNow(70223, -1, -1, E_INVALIDARG, 'Неверное число элементов', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // Выделение памяти для массива ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if ppErrors = nil then begin
      // По каким-то причинам не удалось выделить память для массива ppErrors,
      // поэтому выходим с E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70224, -1, -1, E_OUTOFMEMORY, 'Ошибка выделения памяти', llErrors);
      result := E_OUTOFMEMORY;
      exit;
    end;

    // Блокируем группу
    Lock;
    try
      // Цикл по элементам
      ItemIndex := 0;
      ErrorCount := 0;
      while ItemIndex < dwCount do begin
        // Ищем элемент в списке лементов группы
        hr := FindItemByhServer(phServer[ItemIndex], Item);
        if (hr = S_OK) and assigned(Item) then begin
          // Если находим, устанавливаем для его Deadband
          hr := Item.SetNewDeadband(pPercentDeadband^[ItemIndex]);

          // В случае непредвиденной ошибки...
          if hr = E_FAIL then begin
            // ... если память была выделена, освобождаем ее, ...
            if Assigned(ppErrors) then
              CoTaskMemFree(ppErrors);
            // и выходим с E_FAIL;
            PostLogRecordAddMsgNow(70225, -1, -1, E_FAIL, 'Внутреннее событие', llErrors);
            result := E_FAIL;
            exit;
          end;

          // Возвращаем результат для данного элемента
          ppErrors[ItemIndex] := hr;
        end else begin
          // Если не находим, Возвращаем для этого злемента OPC_E_INVALIDHANDLE
          PostLogRecordAddMsgNow(70875, -1, hr, E_FAIL, '', llErrors);
          ppErrors[ItemIndex] := OPC_E_INVALIDHANDLE;
        end;

        // Если результат для этого элемента не S_OK, увеличиваем счетчик ошибок элементов
        if ppErrors[ItemIndex] <> S_OK then begin
          ErrorCount := ErrorCount + 1;
        end;

        ItemIndex := Succ(ItemIndex);
      end;
    finally
      // Разблокируем группу
      Unlock;
    end;
    // Если в оприсниях элементов небыло ошибок, возврашаем S_OK,
    // иначе возвращаем S_FALSE
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;
  except
    on e : Exception do begin
      // В случае непредвиденной ошибки ...
      // ... если память была выделена, освобождаем ее, ...
      PostLogRecordAddMsgNow(70221, -1, -1, E_FAIL, e.Message, llErrors);
      if Assigned(ppErrors) then
        CoTaskMemFree(ppErrors);
      // и выходим с E_FAIL;
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
    PostLogRecordAddMsgNow(70818, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Обнуляем выходные массивы
    ppPercentDeadband := nil;
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70227, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Проверка количества элементов
    if (dwCount = 0) then begin
      // Если количество элементов неправильное, выходим с E_INVALIDARG
      PostLogRecordAddMsgNow(70228, -1, dwCount, E_INVALIDARG, 'Неверное число элементов', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // Выделяем память для ppPercentDeadband
    ppPercentDeadband := PSingleArray(CoTaskMemAlloc(dwCount * sizeof(Single)));
    if not assigned(ppPercentDeadband) then begin
      // По каким-то причинам не удалось выделить память для массива ppPercentDeadband,
      // поэтому выходим с E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70229, -1, -1, E_OUTOFMEMORY, 'Ошибка выделения памяти', llErrors);
      result := E_OUTOFMEMORY;
      exit;
    end;

    // Выделение памяти для массива ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if not assigned(ppErrors) then begin
      // По каким-то причинам не удалось выделить память для массива ppErrors,
      // поэтому освобождаем память, ранее выделенную для ppPercentDeadband
      // и выходим с E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70230, -1, -1, E_OUTOFMEMORY, 'Ошибка выделения памяти', llErrors);
      CoTaskMemFree(ppPercentDeadband);
      result := E_OUTOFMEMORY;
      exit;
    end;

    // Блокируем группу
    Lock;
    try
      // Цикл по элементам
      ItemIndex := 0;
      ErrorCount := 0;
      while ItemIndex < dwCount do begin
        // Ищем элемент в списке лементов группы
        hr := FindItemByhServer(phServer[ItemIndex], Item);
        if (hr = S_OK) and assigned(Item) then begin
          // Если нашли элемент, проверяем, поддерживает ли этот элемент Deadband
          if Item.DeadbandSupported then begin
            // Если да, проверяем, был ли индивидуально для него установлен Deadband
            if Item.DeadbandSetForItem then begin
              // если да, то возвращаем Deadband и S_OK
              ppPercentDeadband[ItemIndex] := Item.Deadband;
              ppErrors[ItemIndex] := S_OK;
            end else begin
              // иначе возвращаем Deadband и OPC_E_DEADBANDNOTSET
              ppPercentDeadband[ItemIndex] := Item.Deadband;
              ppErrors[ItemIndex] := OPC_E_DEADBANDNOTSET;
            end;
          end else begin
            // Если не поддерживается, возвращаем 0 с OPC_E_DEADBANDNOTSUPPORTED
            ppPercentDeadband[ItemIndex] := 0;
            ppErrors[ItemIndex] := OPC_E_DEADBANDNOTSUPPORTED;
          end;
        end else begin
          // Если не находим, возвращаем 0 и OPC_E_INVALIDHANDLE
          PostLogRecordAddMsgNow(70876, -1, hr, OPC_E_INVALIDHANDLE, '', llErrors);
          ppErrors[ItemIndex] := OPC_E_INVALIDHANDLE;
          ppPercentDeadband[ItemIndex] := 0;
        end;

        // Если результат для этого элемента не S_OK, увеличиваем счетчик ошибок элементов
        if ppErrors[ItemIndex] <> S_OK then begin
          ErrorCount := ErrorCount + 1;
        end;
        // Переходим к следующему элементу
        ItemIndex := Succ(ItemIndex);
      end;

    finally
      // Разблокируем группу
      Unlock;
    end;
    // Если в оприсниях элементов небыло ошибок, возврашаем S_OK,
    // иначе возвращаем S_FALSE
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;
  except
    on e : Exception do begin
      // В случае непредвиденной ошибки ...
      // ... если память была выделена, освобождаем ее, ...
      PostLogRecordAddMsgNow(70226, -1, -1, E_FAIL, e.Message, llErrors);
      if assigned(ppPercentDeadband) then
        CoTaskMemFree(ppPercentDeadband);
      if Assigned(ppErrors) then
        CoTaskMemFree(ppErrors);
      // и выходим с E_FAIL;
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
    PostLogRecordAddMsgNow(70819, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Обнуляем выходные массивы
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70232, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Проверка количества элементов
    if (dwCount = 0) then begin
      // Если количество элементов неправильное, выходим с E_INVALIDARG
      PostLogRecordAddMsgNow(70233, -1, -1, E_INVALIDARG, 'Неверное число элементов', llErrors);
      result := E_INVALIDARG;
      exit;
    end;

    // Выделение памяти для массива ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    if not assigned(ppErrors) then begin
      // По каким-то причинам не удалось выделить память для массива ppErrors,
      // поэтому освобождаем память, ранее выделенную для ppPercentDeadband
      // и выходим с E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70234, -1, -1, E_OUTOFMEMORY, 'Ошибка выделения памяти', llErrors);
      result := E_OUTOFMEMORY;
      exit;
    end;

    // Блокируем группу
    Lock;
    try
      // Цикл по элементам
      ItemIndex := 0;
      ErrorCount := 0;
      while ItemIndex < dwCount do begin
        // Ищем элемент в списке лементов группы
        hr := FindItemByhServer(phServer[ItemIndex], Item);
        if (hr = S_OK) and assigned(Item) then begin
          // Если нашли элемент, проверяем, поддерживает ли этот элемент Deadband
          if Item.DeadbandSupported then begin
            // Если да, проверяем, был ли индивидуально для него установлен Deadband
            if Item.DeadbandSetForItem then begin
              // если да, сбрасываем Deadband и возвращаем S_OK
              Item.ResetDeadband;
              ppErrors[ItemIndex] := S_OK;
            end else begin
              // иначе сбрасываем Deadband и возвращаем OPC_E_DEADBANDNOTSET
              Item.ResetDeadband;
              ppErrors[ItemIndex] := OPC_E_DEADBANDNOTSET;
            end;
          end else begin
            // Если не поддерживается, возвращаем OPC_E_DEADBANDNOTSUPPORTED
            ppErrors[ItemIndex] := OPC_E_DEADBANDNOTSUPPORTED;
          end;
        end else begin
          // Если не находим, возвращаем OPC_E_INVALIDHANDLE
          PostLogRecordAddMsgNow(70877, -1, hr, OPC_E_INVALIDHANDLE, '', llErrors);
          ppErrors[ItemIndex] := OPC_E_INVALIDHANDLE;
        end;

        // Если результат для этого элемента не S_OK, увеличиваем счетчик ошибок элементов
        if ppErrors[ItemIndex] <> S_OK then begin
          ErrorCount := ErrorCount + 1;
        end;
        // Переходим к следующему элементу
        ItemIndex := Succ(ItemIndex);
      end
    finally
      // Разблокируем группу
      Unlock;
    end;
    // Если в оприсниях элементов небыло ошибок, возврашаем S_OK,
    // иначе возвращаем S_FALSE
    if ErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;
  except
    on e : Exception do begin
      // В случае непредвиденной ошибки если память была выделена, освобождаем ее,...
      PostLogRecordAddMsgNow(70231, -1, -1, E_FAIL, e.Message, llErrors);
      if Assigned(ppErrors) then
        CoTaskMemFree(ppErrors);
      // ..юи выходим с E_FAIL;
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
    PostLogRecordAddMsgNow(70820, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Начальные действия
    ppItemValues := nil;
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70236, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Проверка входных параметров
    if not(dwSource = OPC_DS_CACHE) and
       not(dwSource = OPC_DS_DEVICE)
    then begin
      PostLogRecordAddMsgNow(70237, Integer(dwSource), -1, E_INVALIDARG, 'Внутреннее событие', llErrors);
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

    PostLogRecordAddMsgNow(70927, -1, -1, -1, 'Перед Group._Read()', llDebug);
    // Вызов функции чтения без максимальных времен пригодности итемов (pdwMaxAge = nil)
    result := _Read(dwCount, phServer, dwSource, nil, vndtstSync, vnditRead, 0, 0, phClients, ppvValues, ppwQualities, ppftTimestamps, ppErrors);
    PostLogRecordAddMsgNow(70928, -1, -1, -1, 'После Group._Read()', llDebug);

    // Если чтение завершилось удачно, ...
    if result >= S_OK then try
      // Переносим выходные параметры в с выходную структуру типа POPCITEMSTATEARRAY
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
      // По завершении удаляем ненужные данные
      if assigned(phClients) then begin
        CoTaskMemFree(phClients);
        phClients := nil;
      end;

      if assigned(ppvValues) then begin
        // деинициализируем элементы массива перед удалением
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
        // деинициализируем элементы массива перед удалением
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
    PostLogRecordAddMsgNow(70821, -1, -1, S_OK, 'Вызов метода', llDebug);
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70241, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
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
    PostLogRecordAddMsgNow(70823, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Начальные действия
    ppvValues := nil;
    ppwQualities := nil;
    ppftTimeStamps := nil;
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70243, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состяние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Проверка входных параметров
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

    PostLogRecordAddMsgNow(70929, -1, -1, -1, 'Перед Group._Read()', llDebug);
    // Вызов функции чтения без указания источника данных (dwSource = 0)
    result := _Read(dwCount, phServer, 0, pdwMaxAge, vndtstSync, vnditRead, 0, 0, phClients, ppvValues, ppwQualities, ppftTimestamps, ppErrors);
    PostLogRecordAddMsgNow(70930, -1, -1, -1, 'После Group._Read()', llDebug);

    // Если чтение завершилось удачно, ...
    if result >= S_OK then try
      //todo: дописать...
    finally
      // По завершении удаляем ненужные клиентские хендлы
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
      // По завершении удаляем ненужные данные
      result := E_FAIL;
      if assigned(ppvValues) then begin
        // деинициализируем элементы массива перед удалением
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
    PostLogRecordAddMsgNow(70824, -1, -1, S_OK, 'Вызов метода', llDebug);
    ppErrors := nil;
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
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
    PostLogRecordAddMsgNow(70825, dwTransactionID, -1, S_OK, 'Вызов метода', llDebug);

    // Назначение начальных значений выходным параметрам
    pdwCancelID := 0;
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70248, Integer(ServerCore.State), dwTransactionID, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    // Проверка входных параметров
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

    // Выделение памяти для ppErrors
    ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
    // очищаем ppErrors
    index := 0;
    while index < dwCount do begin
      ppErrors^[index] := E_UNEXPECTED;
      index := succ(index);
    end;

    // Выполнение асинхронного чтения
    try
      PostLogRecordAddMsgNow(70931, dwTransactionID, -1, -1, 'Перед Group._Read()', llDebug);
      read_res := _Read(dwCount, phServer, OPC_DS_DEVICE, nil, vndtstAsync,
      vnditRead, dwTransactionID, 0, phClients, ppvValues, ppwQualities,
      ppftTimeStamps, ppErrors);
      PostLogRecordAddMsgNow(70932, dwTransactionID, -1, -1, 'После Group._Read()', llDebug);
    except
      PostLogRecordAddMsgNow(70843, dwTransactionID, -1, E_NOTIMPL, '', llErrors);
      result := E_FAIL;
      exit;
    end;

    //todo: Разобраться с кодами возварата
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
    PostLogRecordAddMsgNow(70826, -1, -1, S_OK, 'Вызов метода', llDebug);
    ppErrors := nil;
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70250, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    PostLogRecordAddMsgNow(70741, -1, -1, E_NOTIMPL, 'Функция IOPCAsyncIO2::Write() не поддерживается', llErrors);
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
    PostLogRecordAddMsgNow(70827, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70253, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
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
    PostLogRecordAddMsgNow(70828, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70255, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
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
    PostLogRecordAddMsgNow(70829, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70257, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
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
    PostLogRecordAddMsgNow(70830, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70259, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера', llErrors);
      result := E_FAIL;
      exit;
    end;

    PostLogRecordAddMsgNow(70745, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
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
  PostLogRecordAddMsgNow(70754, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
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
  PostLogRecordAddMsgNow(70755, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.Refresh(
        dwConnection:               DWORD;
        dwSource:                   OPCDATASOURCE;
  out   pTransactionID:             DWORD): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70756, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.Cancel(
        dwTransactionID:            DWORD): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70757, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
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
  PostLogRecordAddMsgNow(70746, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
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
  PostLogRecordAddMsgNow(70747, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.RefreshMaxAge(
        dwMaxAge:                   DWORD;
        dwTransactionID:            DWORD;
  out   pdwCancelID:                DWORD): HResult;
begin
  PostLogRecordAddMsgNow(70748, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
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
  PostLogRecordAddMsgNow(70749, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.GetItemSamplingRate(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
  out   ppdwSamplingRate:           PDWORDARRAY;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70750, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.ClearItemSamplingRate(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70751, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.SetItemBufferEnable(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        pbEnable:                   PBOOLARRAY;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70752, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.GetItemBufferEnable(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
  out   ppbEnable:                  PBOOLARRAY;
  out   ppErrors:                   PResultList): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70753, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

// IDataObject
function TVpNetOPCGroup.GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium):
  HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70758, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium):
  HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70759, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.QueryGetData(const formatetc: TFormatEtc): HResult;
  stdcall;
begin
  PostLogRecordAddMsgNow(70760, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.GetCanonicalFormatEtc(const formatetc: TFormatEtc;
  out formatetcOut: TFormatEtc): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70761, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
  fRelease: BOOL): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70762, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
  IEnumFormatEtc): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70763, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.DAdvise(const formatetc: TFormatEtc; advf: Longint;
  const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70764, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.DUnadvise(dwConnection: Longint): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70765, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;

function TVpNetOPCGroup.EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
  stdcall;
begin
  PostLogRecordAddMsgNow(70766, -1, -1, E_NOTIMPL, 'Метод не поддерживается', llErrors);
  result := E_NOTIMPL;
end;




function TVpNetOPCGroup._Read(
        dwCount:                    DWORD;
        phServer:                   POPCHANDLEARRAY;
        dwSource:                   DWORD; // Источник данных (Device/CACHE)
        pdwMaxAge:                  PDWORDARRAY;
        SyncType:                   TVpNetDATransactionSyncType;
        InvocationType:             TVpNetDATransactionInvocationType; // Тип источника возникновения транзакции
        dwClientTransactionId:      DWORD; // Заданный клиентом идентификатор транзакции
        dwClientCancelId:           DWORD; // Заданный клиентом идентификатор отмены транзакции
  out   phClients:                  POPCHANDLEARRAY; // Клиентские идентификаторы элементов (тегов) транзакции
  out   ppvValues:                  POleVariantArray;
  out   ppwQualities:               PWordArray;
  out   ppftTimeStamps:             PFileTimeArray;
  out   ppErrors:                   PResultList): HResult;
var
  ItemIndex : DWORD;
  dwErrorCount : DWORD;
//  CommonTrItemList : TVpNetDATransactionItemList; // Общий (сквозной) список элементов транзакций запроса
  tr : TVpNetDATransaction;
  TrItem : TVpNetDATransactionItem; // Транзакция
  TrItemIndex : Integer; // Номер элемента DA-транзакции
  TrItemList : TVpNetDATransactionItemList; // список транзакций для определенного Соединения(драйвера)
  TrItemListIndex : Integer; // Номер списка элементов транзакций во множестве списков
  TrItemListSet : TVpNetDATransactionItemListSet; // Множество списков транзакций для разных Соединений(драйверов)

  ReferencedHstDriverIDs : TList; // Список идентификаторов драйверов, на которые были добавлены ссылки
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

  AsyncTransaction : TVpNetDATransactionItemList; // Список '

  TID : DWORD;
  bLessThenMaxAge : boolean;
begin
  try
    Lock;
    try
      // Очистка выходных апрпметров
      phClients := nil;
      ppvValues := nil;
      ppwQualities := nil;
      ppftTimeStamps := nil;
      ppErrors := nil;

      // Проверка входных параметров
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

      // Должен быть указан или источник данных или максимальные времена пригодности каждого итема
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

      // Выделение памяти для выходных параметров
      phClients := CoTaskMemAlloc(dwCount * sizeof(OPCHANDLE));
      ppvValues := POleVariantArray(CoTaskMemAlloc(dwCount * sizeof(OleVariant)));
      ppwQualities := PWordArray(CoTaskMemAlloc(dwCount * sizeof(Word)));
      ppftTimeStamps := PFileTimeArray(CoTaskMemAlloc(dwCount * sizeof(TFileTime)));
      ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));

      try
        // Выделяем память для списка идентификаторов драйверов,
        // на которые были добавлены ссылки
        ReferencedHstDriverIDs := TList.Create;
        // Создание пустого множества списков элементов транзакций для разных Соединений(драйверов)
        TrItemListSet := TVpNetDATransactionItemListSet.Create;
  //      // Создание общего (сквозноого) списка элементов транзакций
  //      CommonTrItemList := TVpNetDATransactionItemList.Create;

        // Создание списка итемов (тегов) группы, для которых формируются запросы
        InterestedItems := TList.Create;

        try

          tr := TVpNetDATransaction.Create; // Создаем DA-транзакцию
          tr.SourceObj := self; // Источник DA-транзакции - данная группа
          tr.TID := ServerCore.GetNewTID; // Получаем серверный идентификатор DA-транзакции
          tr.TrType := vndttRead; // Тип транзакции - чтение
          tr.SyncType := SyncType; // Тип синхронизации транзакции  - заданный
          tr.InvocationType := InvocationType; // Тип источника возникновения транзакции - заданный
          tr.dwClientTransactionId := dwClientTransactionId; // Клиентский идентификатор транзакции - заданный
          tr.dwClientCancelId := dwClientCancelId; // Клиентский идентификатор отмены транзакции - заданный

          // Добавление DA-транзакции в список DA-транзакций группы
          Transactions.Add(tr);

          //----------------------------------------------------------------
          // Проходим по элементам, и формируем элементы транзакции запроса для отдельных тегов
          //----------------------------------------------------------------
          ItemIndex := 0;
          dwErrorCount := 0;
          while (ItemIndex < dwCount) do begin
            // бработка очередного элемента:
            // Изначально значения выходных параметров для данного элемента не определены
            phClients^[ItemIndex] := 0;
            ppwQualities^[ItemIndex] := OPC_QUALITY_BAD;
            CoFileTimeNow(ft); // Текущее время в формате _FILETIME
            LocalFileTimeToFileTime(ft, ft); // Перевод текущего локального времени в UTC
            ppftTimeStamps^[ItemIndex] := ft; // запоминаем его
            VariantInit(ppvValues^[ItemIndex]);
            ppErrors^[ItemIndex] := E_UNEXPECTED;

            // Очищаем значение
            ppvValues^[ItemIndex] := Null;
            VariantChangeTypeEx(ppvValues^[ItemIndex], ppvValues^[ItemIndex], LCID, 0, VT_EMPTY);

            // Добавляем "место" для элемента DA-транзакции в общий (сквозной) список элементов DA-транзакций
            tr.Items.Add(nil);

            // Ищем Item (тег) по phServer
            Item := Items.FindByhServer(phServer^[ItemIndex]);

            // Анализ поиска ItemID
            if Assigned(Item) then begin
              // Добавление итема в список итемов, для которых формируются запросы
              InterestedItems.Add(Pointer(Item));
            end else begin
              // Фиксируем ошибку - Item для указанного phServer не найден
              PostLogRecordAddMsgNow(70888, ItemIndex, phServer^[ItemIndex], -1, '', llErrors);
              ppErrors^[ItemIndex] := OPC_E_INVALIDHANDLE; // передаем код ошибки
              dwErrorCount := Succ(dwErrorCount); // увеличиваем количество элементов с ошибками
              ItemIndex := Succ(ItemIndex); // переходим к следующему элементу
              continue;
            end;

            // Получаем определяющие свойства Item-а
            dwHostServerID := Item.VHS_ID;
            dwHostServerDriverID := Item.VHSD_ID;
            dwDeviceID := Item.VD_ID;
            dwDeviceTypeTagID := Item.VDTT_ID;

            // todo: Додумать логику
            if Assigned(pdwMaxAge) then begin
              PostLogRecordAddMsgNow(70889, -1, -1, -1, '', llDebug);
              // Если заданы максимальные времена устаревания тегов, вычисляем
              // способ полученя данных по максимальному времени устаревания
              // (IOPCSyncIO2.ReadMaxAge)

              // Если значение не устарело, возвращаем значение из кеша (предыдущее значение итема)
              CoFileTimeNow(ft); // Текущее время в формате _FILETIME
              LocalFileTimeToFileTime(ft, ft); // Перевод текущего локального времени в UTC
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
                ppErrors^[ItemIndex] := S_OK; // передаем код ошибки
                continue;// Переходим к обработке следующего элемента запроса
              end;
              
            end else begin
              PostLogRecordAddMsgNow(70890, -1, -1, -1, '', llDebug);
              // Если максимальные времена устаревания тегов не заданы, вычисляем
              // способ полученя данных по dwSource и максимальному времени
              // устаревания группы (Group.FUpdateRate)
              // (IOPCSyncIO.Read)

              if (dwSource = OPC_DS_CACHE) then begin
                PostLogRecordAddMsgNow(70892, -1, -1, -1, '', llDebug);
                // Если, при чтении из кеша, группа или итем неактивен
                // возвращаем OPC_QUALITY_OUT_OF_SERVICE
                if not(Active) or not(Item.Active) then begin
                  PostLogRecordAddMsgNow(70894, Integer(Active), Integer(Item.Active), -1, '', llDebug);
                  ppErrors^[ItemIndex] := OPC_QUALITY_OUT_OF_SERVICE; // передаем код ошибки
                  dwErrorCount := Succ(dwErrorCount); // увеличиваем количество элементов с ошибками
                  ItemIndex := Succ(ItemIndex); // переходим к следующему элементу
                  continue;
                end;

                // Если значение не устарело, возвращаем значение из кеша (предыдущее значение итема)
                CoFileTimeNow(ft); // Текущее время в формате _FILETIME
                LocalFileTimeToFileTime(ft, ft); // Перевод текущего локального времени в UTC
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
                  ppErrors^[ItemIndex] := S_OK; // передаем код ошибки
                  continue;// Переходим к обработке следующего элемента запроса
                end;
              end else begin
                PostLogRecordAddMsgNow(70893, -1, -1, -1, '', llDebug);
              end;
            end;

            // Если ссылка на данный драйвер еще не добавлена, ...
            if ReferencedHstDriverIDs.IndexOf(Pointer(dwHostServerDriverID)) = -1 then begin
              PostLogRecordAddMsgNow(70896, -1, -1, -1, '', llDebug);
              // Отправка команды на добавление ссылки на драйвер Host-сервера,
              // и ожидание выполнения команды
  //            hr := SendMessage...
              PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_REF, dwHostServerDriverID, 0);
                // Если удалось добавить ссылку на на драйвер Host-сервера,
                // запоминаем идентификатор драйвера для последующего удаления ссылки
              ReferencedHstDriverIDs.Add(Pointer(dwHostServerDriverID));
  {
              end else begin
                // Если не удалось добавить ссылку на драйвер Host-сервера,
                // возвращаем ошибку для данного элемента
                ppErrors^[ItemIndex] := hr; // передаем код ошибки
                dwErrorCount := Succ(dwErrorCount); // увеличиваем количество элементов с ошибками
                ItemIndex := Succ(ItemIndex); // переходим к следующему элементу
                continue;
              end;
  }
            end else begin
              PostLogRecordAddMsgNow(70897, -1, -1, -1, '', llDebug);
            end;

            // Создаем структуру транзакции DA-сервера
            TrItem := TVpNetDATransactionItem.Create(tr, TID);
            // Клиентский идентификатор элемента группы
            TrItem.DA_hClient := Item.hClient;
            // Задаем ItemId DA-транзакции
            TrItem.DA_ItemId := Item.ItemId;
            // Задаем максимальный приоритет (минимально возможную задержку) для данного элемента
            TrItem.DA_MaxAge := 0;
            // Вычисляем самый поздний момент времени когда нужно получить ответ
            TrItem.DA_MaxResponseMoment := TrItem.DA_CreationMoment;

            // Тип DA-транзакции - чтение
            TrItem.DA_Type := vndttRead;
            // Транзакция синхронная
            TrItem.DA_SyncType := SyncType;
            TrItem.DA_ControlThreadId := GetCurrentThreadId;

            // Параметры относящиеся а Hst-серверу
            TrItem.Hst_ID := dwHostServerID;
            TrItem.Hst_DriverID := dwHostServerDriverID;
            TrItem.Hst_DeviceId := dwDeviceID;
            TrItem.Hst_DeviceTypeTagId := dwDeviceTypeTagID;

            // Если обрабатывем запрос к параметру драйвера, многие параметры не нужны
            if not(dwDeviceID = 0) then begin
              PostLogRecordAddMsgNow(70898, dwDeviceID, -1, -1, '', llDebug);

              // Получаем адрес прибора в сети (шине) приборов
              try
                TrItem.Hst_DeviceAddress := rdm.GetOneCell('select vd_addr from vda_devices where vd_id = ' + rdm.IntToSQL(TrItem.Hst_DeviceId, IntToStr(HIGH(Integer))));
              except on e : Exception do
                begin
                  PostLogRecordAddMsgNow(70879, -1, -1, E_FAIL, '', llErrors);
                  TrItem.Hst_DeviceAddress := HIGH(DWORD);
                end;
              end;

              // Запрашиваем дополнительные данные об Item-е в базе данных
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
                  // Открываем запрос
                  ds.Open;
                  // Обрабатываем возможные ошибки
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
                    TrItem.Free; // Так как не удалось получить все свойства транзакциию удаляем ее
                    ppErrors^[ItemIndex] := OPC_E_UNKNOWNITEMID;
                    dwErrorCount := Succ(dwErrorCount);
                    ItemIndex := Succ(ItemIndex);
                    continue;
                  end;

                  //todo: Взять из Итема
                  // Запоминаем идентификатор протокола
                  TrItem.Hst_ProtocolId := ds.FieldByName('vp_id').AsVariant;
                  // Запоминаем номер функции протокола
                  TrItem.Hst_FuncNumber := ds.FieldByName('func_number').AsVariant;
                  // Запоминаем адрес данных
                  TrItem.Hst_DataAddress := DWORD(ds.FieldByName('data_address').AsInteger);
                  // Запоминаем права доступа к элементу
                  TrItem.Hst_AccessRights := DWORD(ds.FieldByName('access_rights').AsInteger);
                  // Запоминаем размер поля данных в байтах
                  TrItem.Hst_DataSizeInBytes := ds.FieldByName('vdt_size_in_bytes').AsInteger;
                  // Идентификатор формата представления данных в ответе
                  TrItem.Hst_DataFormatId := ds.FieldByName('vdf_id').AsInteger;

                except on e : Exception do begin
                  PostLogRecordAddMsgNow(70881, -1, -1, E_FAIL, e.Message, llErrors);
                  TrItem.Free; // Так как не удалось получить все свойства транзакциию удаляем ее
                  ppErrors^[ItemIndex] := E_FAIL; // Непредвиденная ошибка
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
              // Обмен данными производится с использованием интерфейсов драйвера хост-сервера
              TrItem.Hst_ProtocolId := VPHstDriverInterface;
              // Запоминаем номер функции протокола
              TrItem.Hst_FuncNumber := 0;
              // Запоминаем адрес данных
              TrItem.Hst_DataAddress := 0;
              // Запоминаем права доступа к элементу
              TrItem.Hst_AccessRights := OPC_READABLE + OPC_WRITEABLE;
              // Запоминаем размер поля данных в байтах
              TrItem.Hst_DataSizeInBytes := 0;
              // Идентификатор формата представления данных в ответе
              TrItem.Hst_DataFormatId := 0;
            end;

            // Добавляем транзакцию в общий (сквозной) список транзакций на заранее приготовленное место
            tr.Items[tr.Items.Count - 1] := TrItem;

            // Ищем созданный список транзакций для данного соединения(драйвера)
            TrItemList := TrItemListSet.FindByDriverId(TrItem.Hst_DriverID);
            // Если список для для данного соединения(драйвера) еще не создан,
            // Создаем его, и добавляем во множество списков транзакций
            if not assigned(TrItemList) then begin
              PostLogRecordAddMsgNow(70900, -1, -1, -1, '', llDebug);
  //            trList := TVpNetDATransactionItemList.Create(tr.Hst_DriverID);
              TrItemList := TVpNetDATransactionItemList.Create;
              TrItemListSet.Add(TrItemList);
            end;

            // Добавляем транзакцию в список транзакций для данного соединения(драйвера)
            TrItemList.Add(TrItem);

            // Переход к следующему элементу
            ItemIndex := Succ(ItemIndex);
          end;

          //----------------------------------------------------------------
          // Отправка списков элементов транзакций соединениям(драйверам) для выполнения
          //----------------------------------------------------------------
          TrItemListIndex := 0;
          while (TrItemListIndex < TrItemListSet.Count) do begin
            PostLogRecordAddMsgNow(70344, 2, -1, -1, '2', llDebug);
            // Отправка сообщения со списком транзакций очередному соединению(драйверу)
            PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_TRANSACTIONS,
              // Идентификатор драйвера Hst-сервера
              // (предпологаем, что список однородный по Hst_DriverId);
              TrItemListSet[TrItemListIndex].FirstTrItemDriverId,
              Integer(Pointer(TrItemListSet[TrItemListIndex])), // Список транзакций
            );

            Application.ProcessMessages;
            // Переход к следующему списку
            TrItemListIndex := Succ(TrItemListIndex);
          end;

          case SyncType of
            vndtstSync: begin
              PostLogRecordAddMsgNow(70901, -1, -1, -1, 'Sync', llDebug);
              // Для Синхронного вызова...
              //----------------------------------------------------------------
              // Ожидание завершения ВСЕХ СИНХРОННЫХ транзакций во ВСЕХ соединениях(драйверах)
              //----------------------------------------------------------------
              TrItemIndex := 0;
              while (TrItemIndex < tr.Items.Count) do begin
                // Если для данного элемента запроса транзакции вообще нет - переходим к следующей транзакции
                if (tr.Items[TrItemIndex] = nil) then begin
                  PostLogRecordAddMsgNow(70902, -1, -1, -1, '', llErrors);
                  TrItemIndex := Succ(TrItemIndex);
                  Continue;
                end;

                // или ее обработка завершена - переходим к следующей транзакции
                if tr.Items[TrItemIndex].DA_State = vndtsComplete then begin
                  PostLogRecordAddMsgNow(70903, -1, -1, -1, '', llDebug);
                  TrItemIndex := Succ(TrItemIndex);
                  Continue;
                end;

                Sleep(1);
                Application.ProcessMessages;
              end;

              //----------------------------------------------------------------
              // Проход по списку транзакций и заполнение выходных массивов
              //----------------------------------------------------------------
              ItemIndex := 0;
              dwErrorCount := 0;
              // Проходим по тегам запроса
              while (ItemIndex < dwCount) do begin
                // Берем очередную транзакцию из списка
                TrItem := tr.Items[ItemIndex];
                if assigned(TrItem) then begin
                  // Если на этом месте есть транзакция, инициализируем элементы
                  // выходных массивов значениями из транзакции
                  PostLogRecordAddMsgNow(70904, -1, -1, -1, '', llDebug);
                  ppvValues^[ItemIndex] := TrItem.VQT.vDataValue;
                  ppwQualities^[ItemIndex] := TrItem.VQT.wQuality;
                  ppftTimestamps^[ItemIndex] := TrItem.VQT.ftTimeStamp;
                  ppErrors^[ItemIndex] := TrItem.DA_Result;
                end else begin
                  // Если на этом месте нет транзакции, инициализируем элементы
                  // выходных массивов для данной транзакции как ОШИБОЧНЫЕ
                  PostLogRecordAddMsgNow(70905, -1, -1, -1, '', llErrors);
                  ppErrors^[ItemIndex] := E_FAIL; // Непредвиденная ошибка
                  dwErrorCount := Succ(dwErrorCount); // Увеличиваем счетчик ошибок
                end;

                // Берем итем, для которого выполнялся запрос
                Item := InterestedItems[ItemIndex];
                // Если есть такой итем, обновляем его данные
                if assigned(Item) then begin
                  PostLogRecordAddMsgNow(70906, -1, -1, -1, '', llDebug);
                  Item.Value := ppvValues^[ItemIndex];
                  Item.Quality := ppwQualities^[ItemIndex];
                  Item.Timestamp := ppftTimestamps^[ItemIndex];
                end;
                // Переход к следующему элементу
                ItemIndex := Succ(ItemIndex);
              end;

              // Удаление DA-транзакции из списка транзакций группы, и ее уничтожение
              Transactions.Remove(tr);
              tr.Items.DestroyTransactionItems;
              tr.Items.Free;

              //Удаляем множество списков транзакций (но не сами транзакции)
              // (Отдельные списки транзакций нам не нужны, так как все транзакции есть в
              // общем (сквозном) списке транзакций)
              TrItemListSet.DestroyTransactionItemLists;

            end;

            vndtstAsync: begin
              PostLogRecordAddMsgNow(70907, -1, -1, -1, 'Async', llDebug);
              // Для асинхронного вызова выходные массивы оставляем пустыми
              // результаты будут посланы вызывающему потоку Messege-ми
            end;

            else begin
              PostLogRecordAddMsgNow(70280, Integer(SyncType), -1, E_FAIL, 'Неверный тип синхронизации', llErrors);
            end;
          end;

          //----------------------------------------------------------------
          // Завершающие действия
          //----------------------------------------------------------------
        finally
          // Удаляем ссылки на драйвер Host-сервера
          DriverRefIndex := 0;
          while DriverRefIndex < ReferencedHstDriverIDs.Count do begin
            // Оправляем команду на удалениии ссылки очередной драйвер Host-сервера
            // и ожидание выполнения команды
            PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_RELEASE, DWORD(ReferencedHstDriverIDs[DriverRefIndex]), 0);
            Application.ProcessMessages; //???
            // Переходим к идентификаторй следующего драйвера Host-сервера
            DriverRefIndex := Succ(DriverRefIndex);
          end;

          // Удаление списка итемов, для которых формируются запросы
          if assigned(InterestedItems) then begin
            InterestedItems.Free;
          end else begin
            PostLogRecordAddMsgNow(70908, -1, -1, -1, '', llErrors);
          end;

          // Удаление множества списков транзакций для разных Соединений(драйверов)
          if assigned(TrItemListSet) then begin
            TrItemListSet.Free;
          end else begin
            PostLogRecordAddMsgNow(70909, -1, -1, -1, '', llErrors);
          end;

          // Удаляем список идентификаторов драйверов, на которые были добавлены ссылки
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
          // Если выходим аварийно, очищаем выходные параметры
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
  // Параметры IOPCDataCallback.OnDataChange()
  dwTransid: DWORD;
  hGroup:                     OPCHANDLE;
  hrMasterquality:            HResult; // Общий результат чтения
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

      // Если нет транзакции, возвращаем E_UNEXPECTED
      if not(assigned(tr)) then begin
        PostLogRecordAddMsgNow(70283, -1, -1, E_INVALIDARG, '', llErrors);
        result := E_INVALIDARG;
        exit;
      end;

      // Если проблема с Callback-соединением, возвращаем E_FAIL
      if not(assigned(FOPCDataCallback)) then begin
        PostLogRecordAddMsgNow(70284, -1, -1, E_NOINTERFACE, '', llErrors);
        result := E_NOINTERFACE;
        exit;
      end;



      // Если нет тип источника возникновения транзакции не синхорнное чтение,
      // возващаем ошибку
      if not(tr.InvocationType = vnditSubscription) then begin
        PostLogRecordAddMsgNow(70934, Integer(tr.InvocationType), -1, E_UNEXPECTED, 'Неверный источник транзакции', llErrors);
        result := E_UNEXPECTED;
        exit;
      end;

      // Для чтения по подписке, в качестве клиентской транзакции
      // указывается 0
      dwTransid := 0;

      // Клиентский идентификатор группы
      hGroup := FhClient;

      // Общее Quality
      hrMasterquality := tr.Quality;

      // Если в результате вычисления hrMasterquality произошла ошибка, возвращаем E_FAIL
      if hrMasterquality = E_FAIL then begin
        PostLogRecordAddMsgNow(70286, -1, -1, E_FAIL, '', llErrors);
        result := E_FAIL;
        exit;
      end;

      // Общий результат завершения транзакции
      hrMastererror := tr.GlobalResult;
      // Если в результате вычисления hrMastererror произошла ошибка, возвращаем E_FAIL
      if hrMastererror = E_FAIL then begin
        PostLogRecordAddMsgNow(70287, -1, -1, E_FAIL, '', llErrors);
        result := E_FAIL;
        exit;
      end;

      //todo: Помещать в выходные массивы ТОЛЬКО ИЗМЕНИВШИЕСЯ данные

      // Количество выходных элементов
      dwCount := tr.Items.Count;

      // Выделяем память для массивов данных
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

      // Заполнение выходных массивов
      ItemIndex := 0;
      while ItemIndex < dwCount do begin
        // Клиентский идентификатор элемента
        phClientItems^[ItemIndex] := tr.Items[ItemIndex].DA_hClient;
        pvValues^[ItemIndex] := tr.Items[ItemIndex].VQT.vDataValue;
        pwQualities^[ItemIndex] := tr.Items[ItemIndex].VQT.wQuality;
        pErrors^[ItemIndex] := tr.Items[ItemIndex].DA_Result;
        pftTimeStamps^[ItemIndex] := tr.Items[ItemIndex].VQT.ftTimeStamp;
        ItemIndex := Succ(ItemIndex);
      end;

      // Вызов Callback-функции

      PostLogRecordAddMsgNow(70923, -1, -1, -1, 'Перед OnDataChange()', llDebug);

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

      PostLogRecordAddMsgNow(70924, -1, -1, -1, 'После OnDataChange()', llDebug);

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
  hrMasterquality:            HResult; // Общий результат чтения
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

      // Если нет транзакции, возвращаем E_UNEXPECTED
      if not(assigned(tr)) then begin
        PostLogRecordAddMsgNow(70857, -1, -1, E_INVALIDARG, '', llErrors);
        result := E_INVALIDARG;
        exit;
      end;

      // Если проблема с Callback-соединением, возвращаем E_FAIL
      if not(assigned(FOPCDataCallback)) then begin
        PostLogRecordAddMsgNow(70859, -1, -1, E_NOINTERFACE, '', llErrors);
        result := E_NOINTERFACE;
        exit;
      end;

      // Если нет тип источника возникновения транзакции не ассинхорнное чтение,
      // возващаем ошибку
      if not(tr.InvocationType = vnditRead) then begin
        PostLogRecordAddMsgNow(70860, Integer(tr.InvocationType), -1, E_UNEXPECTED, 'Неверный источник транзакции', llErrors);
        result := E_UNEXPECTED;
        exit;
      end;

      // Для асинхронного чтения, в качестве клиентской транзакции
      // указывается значение, заданное в функции асинхронного чтения
      dwTransid := tr.dwClientTransactionId;

      // Клиентский идентификатор группы
      hGroup := FhClient;

      // Общее Quality
      hrMasterquality := tr.Quality;

      // Если в результате вычисления hrMasterquality произошла ошибка, возвращаем E_FAIL
      if hrMasterquality = E_FAIL then begin
        PostLogRecordAddMsgNow(70861, -1, -1, E_FAIL, '', llErrors);
        result := E_FAIL;
        exit;
      end;

      // Общий результат завершения транзакции
      hrMastererror := tr.GlobalResult;
      // Если в результате вычисления hrMastererror произошла ошибка, возвращаем E_FAIL
      if hrMastererror = E_FAIL then begin
        PostLogRecordAddMsgNow(70862, -1, -1, E_FAIL, '', llErrors);
        result := E_FAIL;
        exit;
      end;



      // Количество выходных элементов
      dwCount := tr.Items.Count;

      // Выделяем память для массивов данных
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

      // Заполнение выходных массивов
      ItemIndex := 0;
      while ItemIndex < dwCount do begin
        // Клиентский идентификатор элемента
        phClientItems^[ItemIndex] := tr.Items[ItemIndex].DA_hClient;
        pvValues^[ItemIndex] := tr.Items[ItemIndex].VQT.vDataValue;
        pwQualities^[ItemIndex] := tr.Items[ItemIndex].VQT.wQuality;
        pErrors^[ItemIndex] := tr.Items[ItemIndex].DA_Result;
        pftTimeStamps^[ItemIndex] := tr.Items[ItemIndex].VQT.ftTimeStamp;
        ItemIndex := Succ(ItemIndex);
      end;

      // Вызов Callback-функции



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

      PostLogRecordAddMsgNow(70865, dwTransId, -1, result, 'Вызван IOPCDataCallback.OnReadComplete()', llErrors);

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

