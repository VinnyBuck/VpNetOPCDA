unit VpNetDAClasses;

interface

uses Windows, Classes, ActiveX, SysUtils, SyncObjs, OPCTypes, VpNetOPCItem_Impl,
  VpNetHst_TLB, VpNetDADefs, VpNetDefs, VpNetClasses, Contnrs, VpNetUtils,
  OPCDA, DB;
type

// Предварительные одьявления
TVpNetDATransaction = class;

{09.07.2006}
// Состояние DA-сервера
TVpNetDAServerState = (vndsCreating = 0, vndsWorking = 1, vndsDestroing = 2);
{/09.07.2006}
{11.07.2006}
// Состояние соединения с HST-драйвером
TVpNetHstDriverConnectionState = (vncsCreating = 0, vncsWorking = 1, vncsDestroing = 2);
{/11.07.2006}
// Состояния DA-транзакций
TVpNetDATransactionItemState = (vndtsNone = 0, vndtsWaitingForProcessing = 1, vndtsWaitingForResponse = 2, vndtsComplete = 4);
// Типы DA-транзакций
TVpNetDATransactionType = (vndttNone = 0, vndttRead = 1, vndttWrite = 2);
// Тип синхронности выполнения DA-транзакции
TVpNetDATransactionSyncType = (vndtstNone = 0, vndtstSync = 1, vndtstAsync = 2);
// Тип источника, вызвавшего транзакцию
TVpNetDATransactionInvocationType = (vnditNone = 0, vnditRead = 1, vnditWrite = 2, vnditRefresh = 3, vnditSubscription = 4);

TVpNetOPCItemList = class(TList)
private
  function Get(Index: Integer): TVpNetOPCItem; // su01
  procedure Put(Index: Integer; const Value: TVpNetOPCItem); // su01
public
  property Items[Index: Integer]: TVpNetOPCItem read Get write Put; default;
  function Clone(out aNewItemList: TVpNetOPCItemList): HResult; // su01
  function FindByhServer(ahServer : OPCHANDLE) : TVpNetOPCItem; // su01
end;

// Структура, содержащая информацию об элементе транзакции DA-сервера
TVpNetDATransactionItem = class
public
  // Глобальные свойства элемента DA-транзакции
  DA_Transaction : TVpNetDATransaction; // DA-Транзакция
  DA_TID : DWORD; // Временно идентификатор DA-транзакции
  DA_TIID : DWORD; // Идентификатор элемента транзакции DA-сервера
  DA_ItemId : String; // Идентификатор тега DA-сервера
  DA_hClient : OPCHANDLE; // Клиентский иденитфикатор элемента группы

  // Параметры хода выполнения DA-транзакции
  DA_CreationMoment: TFileTime; // Время создание транзакции DA-сервера
  DA_MaxAge: DWORD; // Максимальное заданное время ожидание ответа
  DA_MaxResponseMoment : TFileTime; // Самый поздний момент времени когда нужно получить ответ
  DA_State : TVpNetDATransactionItemState; // Состояние элемента DA-транзакции
  DA_Type : TVpNetDATransactionType; // Тип DA-транзакции (неопр./чтение/запись)

  DA_SyncType : TVpNetDATransactionSyncType; // Тип синхронизации DA-транзакции (неопр./Sync/Async)
  DA_ControlThreadId : THandle; // Идентификатор потока, управляющего асинхронной транзакцией

  // Данные DA-транзакции
  VQT : OPCITEMVQT;
  // VQT.vDataValue (Значение):
  //   В режиме чтения - значение, прочтенное из устройства (или кеша)
  //   В режиме записи - значение, записываемое в устройство (и кеш)
  // VQT.wQuality (Состояние тега DA-сервера):
  //   В режиме чтения - текущее состояние тега устройства
  //   В режиме записи - состояние тега, записываемое в устройство (и кеш)
  // VQT.ftTimeStamp (Момент времени, на который данные и состояние транзакции были актуальны):
  //   В режиме чтения - момент времени, на который прочитанные данные были актуальны
  //   В режиме записи - момент времени актуальности записанных в тег данных
  // VQT.bQualitySpecified:
  //   В режиме чтения - не используется
  //   В режиме записи:
  //      true - задано wQuality и его необходимо записать
  //      false - wQuality записывать не нужно
  // VQT.bTimeStampSpecified:
  //   В режиме чтения - не используется
  //   В режиме записи:
  //      true - задан ftTimeStamp и его необходимо записать
  //      false - ftTimeStamp записывать не нужно

  // Резултьт выполнения DA-транзакции
  DA_Result : HRESULT;

  // Параметры относящиеся а Hst-серверу
  Hst_ID : DWORD; // Идентификатор Hst-сервера
  Hst_TID : DWORD; // Идентификатор Hst-транзакции
  Hst_DriverID : DWORD; // Идентификатор драйвера Hst-сервера
  Hst_ProtocolId : DWORD; // Идентификатор протокола для входных и выходных данных
  Hst_DeviceId : DWORD; // Идентификатор устройства
  Hst_DeviceAddress : DWORD; // Адрес устройства в сети (шине) приборов
  // Номер функции протокола (например функция 3 протокола Modbus)
  //   В режиме чтения - Номер функции протокола для чтения
  //   В режиме записи - Номер функции протокола для записи
  Hst_FuncNumber : DWORD;
  Hst_DeviceTypeTagId : DWORD; // Идентификатор тега типа устройства
  Hst_DataAddress : DWORD; // Адрес данных в устройстве
  Hst_DataSizeInBytes : WORD; // Размер поля данных в байтах
  Hst_DataFormatId : DWORD; // Идентификатор формата представления данных в устройстве
  Hst_AccessRights : DWORD; // Права доступа к элементу данных в устройстве

  // Резултьт выполнения Hst-транзакции
  Hst_Result : HRESULT;

  constructor Create(aDA_Transaction : TVpNetDATransaction; aDA_TID : DWORD); // su01
  destructor destroy;override; // su01
  procedure SetError(aRrror : HRESULT = E_FAIL); // su01
  procedure SetOk(aValue : OleVariant; aResult : HRESULT = S_OK); // su01
  procedure Complete(aResult : HRESULT = S_OK); // su01
end;

PVpNetHSTAnswerData = ^TVpNetHSTAnswerData;
TVpNetHSTAnswerData = packed record
// 6.04.2010
//  HstAnswerDataSize : DWORD;
  HstAnswerDataSize : Integer;
///6.04.2010
  HstAnswerData : Pointer;
end;

// 30.11.2011
PVpNetHSTErrorData = ^TVpNetHSTErrorData;
TVpNetHSTErrorData = packed record
  ErrorCode : Integer;
  HstAnswerDataSize : Integer;
  HstAnswerData : Pointer;
end;
///30.11.2011

// Список элементов транзакции DA-сервера
TVpNetDATransactionItemList = class(TList)
private
  function Get(Index: Integer): TVpNetDATransactionItem; // su01
  procedure Put(Index: Integer; const Value: TVpNetDATransactionItem); // su01
  function GetFirstTrItemDriverId : DWORD; // su01
public
  constructor Create; //overload; // su01
//  constructor Create(aDriverId : DWORD); overload;
  procedure DestroyTransactionItems; // su01
  property Items[Index: Integer]: TVpNetDATransactionItem read Get write Put; default;
  property FirstTrItemDriverId : DWORD read GetFirstTrItemDriverId;
  function FindByHstTID(aHstTID : DWORD) : TVpNetDATransactionItem; // su01
  function FindByItemId(aItemId : String) : TVpNetDATransactionItem; // su01
  function AllComplete : boolean; // su01
end;

// Множество списков элементов транзакции DA-сервера
TVpNetDATransactionItemListSet = class(TList)
private
  function Get(Index: Integer): TVpNetDATransactionItemList; // su01
  procedure Put(Index: Integer; const Value: TVpNetDATransactionItemList); // su01
public
  procedure DestroyTransactionItemLists; // su01
  procedure DestroyTransactionItemListsAndTransactionItems; // su01
  property Items[Index: Integer]: TVpNetDATransactionItemList read Get write Put; default;
  function FindByDriverId(aDriverId : DWORD) : TVpNetDATransactionItemList; // su01
  function AllComplete : boolean; // su01
end;

// DA-транзакция
TVpNetDATransaction = class
public
  SourceObj : Pointer; // Источник транзакции (TVpNetOPCDA или TVpNetOPCGroup)
  TID : DWORD; // Идентификатор транзакции DA-сервера
  TrType : TVpNetDATransactionType; // Типы транзакций (неопр./чтение/запись)
  SyncType : TVpNetDATransactionSyncType; // Тип синхронизации транзакции
  Items : TVpNetDATransactionItemList; // Список элементов транзакции
  InvocationType : TVpNetDATransactionInvocationType; // Тип источника возникновения транзакции
  dwClientTransactionId : DWORD; // Заданный клиентом идентификатор транзакции
  dwClientCancelId : DWORD; // Заданный клиентом идентификатор отмены транзакции
  constructor Create(); // su01
  destructor Destroy; override; //su01
  function Processed : boolean; // su01
  function Quality: HRESULT; // Общее Quality // su01
  function GlobalResult : HRESULT; // Общий результат выполнения транзакции // su01
end;

// Список транзакций
TVpNetDATransactionList = class(TList)
private
  function Get(Index: Integer): TVpNetDATransaction; // su01
  procedure Put(Index: Integer; const Value: TVpNetDATransaction); // su01
public
  property Items[Index: Integer]: TVpNetDATransaction read Get write Put; default;
  procedure DeleteTransactions; // su01
end;


TVpNetHostServerInfo = class;

// Структура информации о драйвере Hst-сервера
TVpNetHostServerDriverInfo = class
public
  HstDriverId : Integer;
  HstServerId : Integer;
  HstDriverTypeId : Integer;
  HstDriverTag : String;
  HstDriverText : String;
  constructor Create(
    aHstDriverId : Integer;
    aHstServerId : Integer;
    aHstDriverTypeId : Integer;
    aHstDriverTag : String;
    aHstDriverText : String
  ); // su01
end;

TVpNetHostServerDriverInfoList = class(TList)
private
  function Get(Index: Integer): TVpNetHostServerDriverInfo; // su01
  procedure Put(Index: Integer; const Value: TVpNetHostServerDriverInfo); // su01
public
  property Items[Index: Integer]: TVpNetHostServerDriverInfo read Get write Put; default;
  function FindByHstDriverId(aHstDriverId : Integer) : TVpNetHostServerDriverInfo; // su01
  procedure DeleteItems; // su01
end;

TVpNetHostServerInfo = class
public
  HstServerId : Integer;
  HstServerAddress : String;
  HstServerTag : String;
  HstServerText : String;
  constructor Create(
    aHstServerId : Integer;
    aHstServerAddress : String;
    aHstServerTag : String;
    aHstServerText : String
  ); // su01
end;

TVpNetHostServerInfoList = class(TList)
private
  function Get(Index: Integer): TVpNetHostServerInfo; // su01
  procedure Put(Index: Integer; const Value: TVpNetHostServerInfo); // su01
public
  property Items[Index: Integer]: TVpNetHostServerInfo read Get write Put; default;
  function FindByHstServerId(aHstServerId : Integer) : TVpNetHostServerInfo; // su01
  procedure DeleteItems; // su01
end;

implementation

uses Math, VarUtils, Variants, VpNetDAServerCore, VpNetModbus,
  VpNetDARDM_Impl, VpNetDADebug;


{TVpNetOPCItemList}
function TVpNetOPCItemList.Get(Index: Integer): TVpNetOPCItem;
begin
  try
    Result := TVpNetOPCItem(inherited Get(Index));
  except on e: Exception do
    PostLogRecordAddMsgNow(70432, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TVpNetOPCItemList.Put(Index: Integer; const Value: TVpNetOPCItem);
begin
  try
    inherited Put(Index, Value);
  except on e: Exception do
    PostLogRecordAddMsgNow(70433, e.HelpContext, -1, -1, e.Message);
  end;
end;

function TVpNetOPCItemList.Clone(out aNewItemList: TVpNetOPCItemList): HResult;
var
  Index : Integer;
  Item : TVpNetOPCItem;
begin
  try
    aNewItemList := TVpNetOPCItemList.Create;
//    aNewItemList.Count := Count;
    Index := 0;
    while Index < Count do begin
      if Assigned(Items[Index]) then begin
        Items[Index].Clone(Items[Index].GroupObj, Item);
{
        Item := TVpNetOPCItem.Create(Items[Index].GroupObj);
        Item.VHS_ID := Items[Index].VHS_ID;
        Item.VD_ID := Items[Index].VD_ID;
        Item.VDTT_ID := Items[Index].VDTT_ID;
        Item.AccessPath := Items[Index].AccessPath;
        Item.ItemId := Items[Index].ItemId;
        Item.Active := Items[Index].Active;
        Item.hClient := Items[Index].hClient;
        Item.hServer := Items[Index].hServer;
        Item.AccessRights := Items[Index].AccessRights;
        Item.CanonicalDataType := Items[Index].CanonicalDataType;
        Item.BlobSize := Items[Index].BlobSize;
        if Item.BlobSize > 0 then begin
          GetMem(Item.pBlob, Items[Index].BlobSize);
          System.move(Items[Index].pBlob[0], Item.pBlob[0], Item.BlobSize);
        end else begin
          Item.pBlob := nil;
        end;
        Item.SetNewRequestedDataType(Items[Index].RequestedDataType);
        Item.Reserved := Items[Index].Reserved;
};
        aNewItemList.Add(Item);
      end;
      Index := Index + 1;
    end;
    result := S_OK;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70434, e.HelpContext, -1, -1, e.Message);
      aNewItemList := nil;
      result := E_FAIL;
    end;  
  end;
end;

function TVpNetOPCItemList.FindByhServer(ahServer : OPCHANDLE) : TVpNetOPCItem;
var
  ItemIndex : Integer;
begin
  try
    result := nil;
    ItemIndex := 0;
    while ItemIndex < Count do begin
      if Items[ItemIndex].hServer = ahServer then begin
        result := Items[ItemIndex];
        break;
      end;
      ItemIndex := succ(ItemIndex);
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70435, e.HelpContext, -1, -1, e.Message);
      result := nil;
    end;
  end;
end;

{TVpNetDATransactionData}
constructor TVpNetDATransactionItem.Create(aDA_Transaction : TVpNetDATransaction; aDA_TID : DWORD);
begin
  try
    inherited Create;
  except on e: Exception do
    PostLogRecordAddMsgNow(70436, e.HelpContext, -1, -1, e.Message);
  end;
  try
    // Запоминаем транзакцию DA-сервера, к которой отностися этот элемент
    DA_Transaction := aDA_Transaction;
    DA_TID := aDA_TID;
    // Выделяем новый идентификатор DA-транзакции
    ServerCore.Lock;
    try
      DA_TIID := ServerCore.GetNewTIID;
    finally
      ServerCore.Unlock;
    end;
    // ItemId тега не задан
    DA_ItemId := EmptyStr;

    DA_MaxAge := $FFFFFFFF; // Максимально допустимое время ожидания ответа
    CoFileTimeNow(DA_CreationMoment); // Дата создания транзакции
    LocalFileTimeToFileTime(DA_CreationMoment, DA_CreationMoment); // Переводим локальные дату/время в UTC
    DA_MaxResponseMoment := DA_CreationMoment; // Изначально устанавливаем так
    // Тип DA-транзакции не определен
    DA_Type := vndttNone;
    // Тип синхронизации DA-транзакции не определен
    DA_SyncType := vndtstNone;
    // Идентификатор потока, управляющего асинхронной транзакцией не определен
    DA_ControlThreadId := 0;

    // Состояние DA-транзакции неопределенное
    DA_State := vndtsNone;

    // Данные DA-транзакции не определены
    VQT.vDataValue := null;
    VQT.bQualitySpecified := false;
    VQT.wQuality := OPC_QUALITY_UNCERTAIN;
    VQT.bTimeStampSpecified := false;
    VQT.ftTimeStamp.dwLowDateTime := 0;
    VQT.ftTimeStamp.dwHighDateTime := 0;

    // Результат выполнения DA-транзакции неопредленный
    DA_Result := E_UNEXPECTED;

    // Параметры относящиеся а Hst-серверу не определены
    Hst_ID := 0;
    Hst_TID := 0;
    Hst_DriverID := 0;
    Hst_DeviceId := 0;
    Hst_DeviceTypeTagId := 0;
    Hst_DataFormatId := 0;

    // Свойства, относящиеся к обмену данными с устройством
    Hst_ProtocolId := 0;
    Hst_DeviceAddress := high(DWORD); // Недопустимое значение адреса прибора в сети
    Hst_FuncNumber := high(DWORD); // Недопустимое значение номера функции
    Hst_DataAddress := high(DWORD); // Недопустимое значение адреса данных
    Hst_DataSizeInBytes := high(WORD); // Недопустимое значение раземра поля данных
    Hst_AccessRights := 0; // Нет прав ин на что
    // Результат Hst-транзакции неопределеный
    Hst_Result := E_UNEXPECTED;
  except on e: Exception do
    PostLogRecordAddMsgNow(70437, e.HelpContext, -1, -1, e.Message);
  end;
end;

destructor TVpNetDATransactionItem.destroy;
begin
//  try
//    OutputData.Free;
//    InputData.Free;
//  except
//  end;
  try
    inherited;
  except on e: Exception do
    PostLogRecordAddMsgNow(70438, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TVpNetDATransactionItem.SetError(aRrror : HRESULT = E_FAIL);
var
  ft : TFileTime;
begin
  try
    VQT.vDataValue := null; // Нет данных
  except on e: Exception do
    PostLogRecordAddMsgNow(70439, e.HelpContext, aRrror, -1, e.Message);
  end;

  try
    VQT.wQuality := OPC_QUALITY_BAD; // Cостояние OPC_QUALITY_BAD
  except on e: Exception do
    PostLogRecordAddMsgNow(70831, e.HelpContext, aRrror, -1, e.Message);
  end;

  try
    CoFileTimeNow(ft); // Текущее время завершения DA-транзакции в формате _FILETIME
  except on e: Exception do
    PostLogRecordAddMsgNow(70832, e.HelpContext, aRrror, -1, e.Message);
  end;

  try
    LocalFileTimeToFileTime(ft, ft); // Перевод текущего локального времени в UTC
  except on e: Exception do
    PostLogRecordAddMsgNow(70833, e.HelpContext, aRrror, -1, e.Message);
  end;

  try
    VQT.ftTimeStamp := ft; // запоминаем его
  except on e: Exception do
    PostLogRecordAddMsgNow(70834, e.HelpContext, aRrror, -1, e.Message);
  end;

  try
    VQT.bTimeStampSpecified := true;
  except on e: Exception do
    PostLogRecordAddMsgNow(70835, e.HelpContext, aRrror, -1, e.Message);
  end;

  try
    VQT.bQualitySpecified := true;
  except on e: Exception do
    PostLogRecordAddMsgNow(70836, e.HelpContext, aRrror, -1, e.Message);
  end;

  try
    Complete(aRrror);
  except on e: Exception do
    PostLogRecordAddMsgNow(70837, e.HelpContext, aRrror, -1, e.Message);
  end;

end;

procedure TVpNetDATransactionItem.SetOk(aValue : OleVariant; aResult : HRESULT = S_OK);
var
  ft : TFileTime;
begin
  try
    VQT.vDataValue := aValue;
    VQT.wQuality := OPC_QUALITY_GOOD;
    CoFileTimeNow(ft); // Текущее время завершения DA-ТРАНЗАКЦИИ в формате _FILETIME
    LocalFileTimeToFileTime(ft, ft); // Перевод текущего локального времени в UTC
    VQT.ftTimeStamp := ft; // запоминаем его
    VQT.bTimeStampSpecified := true;
    VQT.bQualitySpecified := true;
    Complete(S_OK);
  except on e: Exception do
    PostLogRecordAddMsgNow(70440, e.HelpContext, aResult, -1, e.Message);
  end;
end;

procedure TVpNetDATransactionItem.Complete(aResult : HRESULT = S_OK);
begin
  try
    DA_Result := aResult;
    DA_State := vndtsComplete;
  except on e: Exception do
    PostLogRecordAddMsgNow(70441, e.HelpContext, aResult, -1, e.Message);
  end;
end;


{TVpNetDATransactionList}
function TVpNetDATransactionItemList.Get(Index: Integer): TVpNetDATransactionItem;
begin
  try
    Result := TVpNetDATransactionItem(inherited Get(Index));
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70442, e.HelpContext, Index, -1, e.Message);
      result := nil;
    end;
  end;
end;

procedure TVpNetDATransactionItemList.Put(Index: Integer; const Value: TVpNetDATransactionItem);
begin
  try
    inherited Put(Index, Value);
  except on e: Exception do
    PostLogRecordAddMsgNow(70443, e.HelpContext, Index, -1, e.Message);
  end;
end;

function TVpNetDATransactionItemList.GetFirstTrItemDriverId : DWORD;
var
  TrIndex : DWORD;
begin
  try
    // Ищем DriverId превого нормального элемента DA-транзакции
    result := 0;
    TrIndex := 0;
    while TrIndex < DWORD(count) do begin
      if Assigned(Items[TrIndex]) then begin
        result := Items[TrIndex].Hst_DriverID;
        break;
      end;
      TrIndex := Succ(TrIndex);
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70444, e.HelpContext, -1, -1, e.Message);
      result := 0;
    end;
  end;
end;

constructor TVpNetDATransactionItemList.Create;
begin
  try
    inherited;
  except on e: Exception do
    PostLogRecordAddMsgNow(70445, e.HelpContext, -1, -1, e.Message);
  end;
end;
{
constructor TVpNetDATransactionItemList.Create(aDriverId : DWORD);
begin
  inherited Create;
//  DriverId := aDriverId;
end;
}

procedure TVpNetDATransactionItemList.DestroyTransactionItems;
var
  trIndex : Integer;
begin
  try
    trIndex := 0;
    while trIndex < Count do begin
      try
        Items[trIndex].Free;
      except on e: Exception do
        PostLogRecordAddMsgNow(70447, e.HelpContext, trIndex, -1, e.Message);
      end;
      Items[trIndex] := nil;
      trIndex := Succ(trIndex);
    end;
    Clear;
  except on e: Exception do
    PostLogRecordAddMsgNow(70446, e.HelpContext, -1, -1, e.Message);
  end;
end;

function TVpNetDATransactionItemList.FindByHstTID(aHstTID : DWORD) : TVpNetDATransactionItem;
var
  Index : Integer;
begin
  try
    result := nil;
    Index := 0;
    while Index < Count do begin
      if Items[Index].Hst_TID = aHstTID then begin
        Result := Items[Index];
        break;
      end;
      Index := Succ(Index);
    end;
  except on e: Exception do
    PostLogRecordAddMsgNow(70448, e.HelpContext, aHstTID, -1, e.Message);
  end;
end;

function TVpNetDATransactionItemList.FindByItemId(aItemId : String) : TVpNetDATransactionItem;
var
  Index : Integer;
begin
  try
    result := nil;
    Index := 0;
    while Index < Count do begin
      if AnsiUpperCase(Items[Index].DA_ItemId) = AnsiUpperCase(aItemId) then begin
        Result := Items[Index];
        break;
      end;
      Index := Succ(Index);
    end;
  except on e: Exception do
    PostLogRecordAddMsgNow(70449, e.HelpContext, -1, -1, e.Message + '; aItemId = ' + aItemId);
  end;
end;

function TVpNetDATransactionItemList.AllComplete : boolean;
var
  trIndex: Integer;
begin
  try
    result := True;
    trIndex := 0;
    while trIndex < Count do begin
      if not (Items[trIndex].DA_State = vndtsComplete) then begin
        Result := false;
        break;
      end;
      trIndex := Succ(trIndex);
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70450, e.HelpContext, -1, -1, e.Message);
      result := true;
    end;
  end;
end;

{TVpNetDATransactionItemListSet}
function TVpNetDATransactionItemListSet.Get(Index: Integer): TVpNetDATransactionItemList;
begin
  try
    Result := TVpNetDATransactionItemList(inherited Get(Index));
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70451, e.HelpContext, Index, -1, e.Message);
      result := nil;
    end;
  end;
end;

procedure TVpNetDATransactionItemListSet.Put(Index: Integer; const Value: TVpNetDATransactionItemList);
begin
  try
    inherited Put(Index, Value);
  except on e: Exception do
    PostLogRecordAddMsgNow(70452, e.HelpContext, Index, Integer(Value), e.Message);
  end;
end;

procedure TVpNetDATransactionItemListSet.DestroyTransactionItemLists;
var
//  trList : TVpNetDATransactionItemList;
  trListIndex : Integer;
begin
  try
    trListIndex := 0;
    while trListIndex < Count do begin
      try
        Items[trListIndex].Free;
      except on e: Exception do
        PostLogRecordAddMsgNow(70454, e.HelpContext, trListIndex, -1, e.Message);
      end;
      Items[trListIndex] := nil;
      trListIndex := Succ(trListIndex);
    end;
    Clear;
  except on e: Exception do
    PostLogRecordAddMsgNow(70453, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TVpNetDATransactionItemListSet.DestroyTransactionItemListsAndTransactionItems;
var
//  trList : TVpNetDATransactionItemList;
  trListIndex : Integer;
begin
  try
    trListIndex := 0;
    while trListIndex < Count do begin
      try
        Items[trListIndex].DestroyTransactionItems;
        Items[trListIndex].Free;
      except on e: Exception do
        PostLogRecordAddMsgNow(70456, e.HelpContext, trListIndex, -1, e.Message);
      end;
      Items[trListIndex] := nil;
      trListIndex := Succ(trListIndex);
    end;
    Clear;
  except on e: Exception do
    PostLogRecordAddMsgNow(70455, e.HelpContext, -1, -1, e.Message);
  end;
end;

function TVpNetDATransactionItemListSet.FindByDriverId(aDriverId : DWORD) : TVpNetDATransactionItemList;
var
  Index : Integer;
begin
  try
    result := nil;
    Index := 0;
    while Index < Count do begin
      if Items[Index].FirstTrItemDriverId = aDriverId then begin
        Result := Items[Index];
        break;
      end;
      Index := Succ(Index);
    end;
  except on e: Exception do
    PostLogRecordAddMsgNow(70457, e.HelpContext, aDriverId, -1, e.Message);
  end;
end;

function TVpNetDATransactionItemListSet.AllComplete : boolean;
var
  trListIndex: Integer;
begin
  try
    result := True;
    trListIndex := 0;
    while trListIndex < Count do begin
      if not Items[trListIndex].AllComplete then begin
        Result := false;
        break;
      end;
      trListIndex := Succ(trListIndex);
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70458, e.HelpContext, -1, -1, e.Message);
    end;
  end;
end;

{TVpNetDATransaction - DA-транзакция}
constructor TVpNetDATransaction.Create();
begin
  try
    inherited Create;
  except on e: Exception do
    PostLogRecordAddMsgNow(70459, e.HelpContext, -1, -1, e.Message);
  end;

  try
    SourceObj := nil; // Неопределено
    TID := 0; // Неопределено
    TrType := vndttNone; // Неопределено
    SyncType := vndtstNone; // Неопределено
    InvocationType := vnditNone; // Неопрелено
    dwClientTransactionId := 0; // Неопределено
    dwClientCancelId := 0; // Неорпределено
    Items := TVpNetDATransactionItemList.Create;
  except on e: Exception do
    PostLogRecordAddMsgNow(70460, e.HelpContext, -1, -1, e.Message);
  end;
end;

destructor TVpNetDATransaction.Destroy;
begin
  try
    Items.Free;
  except on e: Exception do
    PostLogRecordAddMsgNow(70461, e.HelpContext, -1, -1, e.Message);
  end;

  try
    inherited;
  except on e: Exception do
    PostLogRecordAddMsgNow(70462, e.HelpContext, -1, -1, e.Message);
  end;
end;

function TVpNetDATransaction.Processed : boolean;
var
  trItemIndex : Integer;
begin
  try
    result := true;
    trItemIndex := 0;
    while trItemIndex < Items.count do begin
      if not(assigned(Items[trItemIndex])) then begin
        PostLogRecordAddMsgNow(70913, trItemIndex, -1, -1, '', llErrors);
        result := false;
        break;
      end;

      if not(Items[trItemIndex].DA_State = vndtsComplete) then begin
        result := false;
        break;
      end;
      trItemIndex := Succ(trItemIndex);
    end;
  except on e: Exception do begin
      result := false;
      PostLogRecordAddMsgNow(70463, e.HelpContext, -1, -1, e.Message);
    end;
  end;
end;

function TVpNetDATransaction.Quality: HRESULT;
var
  trItemIndex : Integer;
begin
  try
    result := S_OK;
    trItemIndex := 0;
    while trItemIndex < Items.Count do begin
      if not(assigned(Items[trItemIndex])) then begin
        PostLogRecordAddMsgNow(70914, trItemIndex, -1, -1, '', llErrors);
      end;

      if assigned(Items[trItemIndex]) and not(Items[trItemIndex].VQT.wQuality = OPC_QUALITY_GOOD) then begin
        result := S_FALSE;
        break;
      end;
      trItemIndex := Succ(trItemIndex);
    end;
  except on e: Exception do begin
      result := E_FAIL;
      PostLogRecordAddMsgNow(70464, e.HelpContext, -1, -1, e.Message);
    end;
  end;
end;

function TVpNetDATransaction.GlobalResult : HRESULT;
var
  trItemIndex : Integer;
begin
  try
    result := S_OK;
    trItemIndex := 0;
    while trItemIndex < Items.Count do begin
      if not(assigned(Items[trItemIndex])) then begin
        PostLogRecordAddMsgNow(70915, trItemIndex, -1, -1, '', llErrors);
      end;

      if assigned(Items[trItemIndex]) and not(Items[trItemIndex].DA_Result = S_OK) then begin
        result := S_FALSE;
        break;
      end;
      trItemIndex := Succ(trItemIndex);
    end;
  except on e: Exception do begin
      result := E_FAIL;
      PostLogRecordAddMsgNow(70465, e.HelpContext, -1, -1, e.Message);
    end;
  end;
end;


// Список транзакций
{TVpNetDATransactionList}
function TVpNetDATransactionList.Get(Index: Integer): TVpNetDATransaction;
begin
  try
    Result := TVpNetDATransaction(inherited Get(Index));
  except on e: Exception do begin
      result := nil;
      PostLogRecordAddMsgNow(70466, e.HelpContext, -1, -1, e.Message);
    end;
  end;
end;

procedure TVpNetDATransactionList.Put(Index: Integer; const Value: TVpNetDATransaction);
begin
  try
    inherited Put(Index, Value);
  except on e: Exception do
    PostLogRecordAddMsgNow(70467, e.HelpContext, Index, Integer(Value), e.Message);
  end;
end;

procedure TVpNetDATransactionList.DeleteTransactions;
var
  tr : TVpNetDATransaction;
begin
  try
    while Count > 0 do begin
      tr := Items[Count - 1];
      Delete(Count - 1);
      tr.Free;
    end;
  except on e: Exception do
    PostLogRecordAddMsgNow(70468, e.HelpContext, -1, -1, e.Message);
  end;
end;

{TVpNetHostServerDriverInfo}
constructor TVpNetHostServerDriverInfo.Create(
  aHstDriverId : Integer;
  aHstServerId : Integer;
  aHstDriverTypeId : Integer;
  aHstDriverTag : String;
  aHstDriverText : String
);
var
  vRaw : OleVariant;
  rdm : TVpNetDARDM;
begin
  try
    inherited Create();
  except on e: Exception do
    PostLogRecordAddMsgNow(70469, aHstDriverTypeId, aHstDriverId, aHstServerId, e.Message + '; aHstDriverTag:'+aHstDriverTag+'; aHstDriverText:'+aHstDriverText);
  end;
  try
    HstDriverId := aHstDriverId;
    HstServerId := aHstServerId;
    HstDriverTypeId := aHstDriverTypeId;
    HstDriverTag := aHstDriverTag;
    HstDriverText := aHstDriverText;
  except on e: Exception do
    PostLogRecordAddMsgNow(70470, aHstDriverTypeId, aHstDriverId, aHstServerId, e.Message + '; aHstDriverTag:'+aHstDriverTag+'; aHstDriverText:'+aHstDriverText);
  end;
end;



// Список информационных обьектов о драйверах Hst-сервера
{TVpNetHostServerDriverInfoList}
function TVpNetHostServerDriverInfoList.Get(Index: Integer): TVpNetHostServerDriverInfo;
begin
  try
    Result := TVpNetHostServerDriverInfo(inherited Get(Index));
  except on e: Exception do begin
      result := nil;
      PostLogRecordAddMsgNow(70471, e.HelpContext, Index, -1, e.Message);
    end;
  end;
end;

procedure TVpNetHostServerDriverInfoList.Put(Index: Integer; const Value: TVpNetHostServerDriverInfo);
begin
  try
    inherited Put(Index, Value);
  except on e: Exception do
    PostLogRecordAddMsgNow(70472, e.HelpContext, Index,  Integer(Value), e.Message);
  end;
end;

function TVpNetHostServerDriverInfoList.FindByHstDriverId(aHstDriverId : Integer) : TVpNetHostServerDriverInfo;
var
  Index : Integer;
begin
  try
    result := nil;
    Index := 0;
    while Index < count do begin
      if Items[Index].HstDriverId = aHstDriverId then begin
        result := Items[Index];
        break;
      end;
      Index := Succ(Index);
    end;
  except on e: Exception do begin
      result := nil;
      PostLogRecordAddMsgNow(70473, e.HelpContext, aHstDriverId, -1, e.Message);
    end;
  end;
end;

procedure TVpNetHostServerDriverInfoList.DeleteItems;
var
  Item : TVpNetHostServerDriverInfo;
begin
  try
    while count > 0 do begin
      Item := Items[count - 1];
      delete(count - 1);
      Item.free;
    end;
  except on e: Exception do
    PostLogRecordAddMsgNow(70474, e.HelpContext, -1, -1, e.Message);
  end;
end;

{TVpNetHostServerInfo}
constructor TVpNetHostServerInfo.Create(
  aHstServerId : Integer;
  aHstServerAddress : String;
  aHstServerTag : String;
  aHstServerText : String
);
var
  ds : TDataSet;
  v : Variant;
begin
  try
    inherited Create;
  except on e: Exception do
    PostLogRecordAddMsgNow(70475, e.HelpContext, aHstServerId, -1, e.Message + '; aHstServerAddress:' + aHstServerAddress +'; aHstServerTag:' + aHstServerTag + '; aHstServerText:' + aHstServerText);
  end;

  try
    HstServerId := aHstServerId;
    HstServerAddress := aHstServerAddress;
    HstServerTag := aHstServerTag;
    HstServerText := aHstServerText;
  {
    try
      // Заполнение массива для драйверов
      ds := TVpNetDAServerCore(aCore).rdm.GetQueryDataset(
        'select vhsd_id, vhsdt_id, vhsd_tag, vhsd_text from vn_host_server_drivers ' +
        'where vhs_id = ' + TVpNetDAServerCore(aCore).RDM.IntToSQL(HstServerId, '-1')
      );
      try
        ds.Open;
        while not ds.Eof do begin
          HstDriverInfos.Add(TVpNetHostServerDriverInfo.Create(self, ds.Fields[0].AsInteger, ds.Fields[1].AsInteger, ds.Fields[2].AsString, ds.Fields[3].AsString));
          ds.Next;
        end;
      finally
        ds.Free;
      end;
    except
    end;
  }
  except on e: Exception do
    PostLogRecordAddMsgNow(70476, e.HelpContext, aHstServerId, -1, e.Message + '; aHstServerAddress:' + aHstServerAddress +'; aHstServerTag:' + aHstServerTag + '; aHstServerText:' + aHstServerText);
  end;
end;

{TVpNetHostServerInfoList}
function TVpNetHostServerInfoList.Get(Index: Integer): TVpNetHostServerInfo;
begin
  try
    Result := TVpNetHostServerInfo(inherited Get(Index));
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70477, e.HelpContext, Index, -1, e.Message);
      result := nil;
    end;
  end;
end;

procedure TVpNetHostServerInfoList.Put(Index: Integer; const Value: TVpNetHostServerInfo);
begin
  try
    inherited Put(Index, Value);
  except on e: Exception do
    PostLogRecordAddMsgNow(70478, e.HelpContext, Index, Integer(Value), e.Message);
  end;
end;

function TVpNetHostServerInfoList.FindByHstServerId(aHstServerId : Integer) : TVpNetHostServerInfo;
var
  Index : Integer;
begin
  try
    result := nil;
    Index := 0;
    while Index < count do begin
      if Items[Index].HstServerId = aHstServerId then begin
        result := Items[Index];
        break;
      end;
      Index := Succ(Index);
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70479, e.HelpContext, aHstServerId, -1, e.Message);
      result := nil;
    end;
  end;
end;

procedure TVpNetHostServerInfoList.DeleteItems;
var
  Item : TVpNetHostServerInfo;
begin
  try
    while count > 0 do begin
      Item := Items[count - 1];
      delete(count - 1);
      Item.free;
    end;
  except on e: Exception do
    PostLogRecordAddMsgNow(70480, e.HelpContext, -1, -1, e.Message);
  end;
end;

end.
