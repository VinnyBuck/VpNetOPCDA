unit VpNetDAServerCore;

{$INCLUDE VpNetDA.def}

{$I 'VpNetDADebugDefs.pas'}

interface

uses Winsock, Windows, Classes, SysUtils, Forms, VpNetDARDM_Impl, OPCTypes,
  Dialogs, Variants, DB, VpNetOPCDA_Impl, OPCError, VpNetOPCItem_Impl,
  ActiveX, Messages, OPCDA, VpNetDAClasses, VpNetHstDriverConnection, GUtils,
  VpNetDAConnectionsControlThread;

type

TVpNetDAServerCore = class
private
  FState : TVpNetDAServerState; // Состояние DA-сервера
  FCS : TRTLCriticalSection;  // Критическая секция
  FDBCS : TRTLCriticalSection;  // Критическая секция обращения к базе данных
  FInstanceID : Integer; // Идентификатор экземпляра сервера
  FRDM : TVpNetDARDM; // Модуль доступа к базе данных
  FServerObjects: TThreadList; // Защищенный список COM-объектов-серверов (TVpNetOPCDA)
  FGroupObjects: TThreadList; // Защищенный список COM-объектов-групп (TVpNetOPCGroup)
  FValidDataTypes: TList;
  FValidLocaleIDs : TList;
  FHstServerInfoList : TVpNetHostServerInfoList;
  FHstServerDriverInfoList : TVpNetHostServerDriverInfoList;
  FMinGroupKeepAlive : DWORD;
  FLastTID : DWORD; // Последний выданный идентификатор транзакции DA-сервера
  FLastTIID : DWORD; // Последний выданный идентификатор элемента транзакции DA-сервера
  {$if defined (CHECK_DONGLE) }
  FDongle : TGuardantDongle; // Ключ
  FLicLastChackedTime : TDateTime; // Время последней проверки лицензии
  FLicState : HRESULT;
  {$ifend}
  // 16.10.2009
  FCheckThread: TVpNetDAConnectionsControlThread;
  ///16.10.2009
  function GetState : TVpNetDAServerState;
public
  HstConnections : TVpNetHstDriverConnectionThreadList; // Защищенный список объектов, представляющих соединения с хост-серверами (TVpNetHstDriverConnection)
  property State: TVpNetDAServerState read GetState;
  property RDM : TVpNetDARDM read FRDM; // Модуль доступа к базе данных
  property InstanceId : Integer read FInstanceID;
  property ServerObjects : TThreadList read FServerObjects;
  property GroupObjects : TThreadList read FGroupObjects;
  property ValidDataTypes : TList read FValidDataTypes;
  property ValidLocaleIDs : TList read FValidLocaleIDs;
  property HstServerInfoList : TVpNetHostServerInfoList read FHstServerInfoList;
  property HstServerDriverInfoList : TVpNetHostServerDriverInfoList read FHstServerDriverInfoList;
  property MinGroupKeepAlive: DWORD read FMinGroupKeepAlive;
  property LastTID : DWORD read FLastTID;
  property LastTIID : DWORD read FLastTIID;
  {$if defined (CHECK_DONGLE) }
  property Dongle : TGuardantDongle read FDongle;
  {$ifend}
  constructor Create; // su01
  destructor Destroy; override; // su01
  function Perform(Message: TMessage): Longint; // su01
  procedure Lock; // su01
  procedure Unlock; // su01
  procedure DBLock; // su01
  procedure DBUnlock; // su01
  // Функции работы с группами
  function GetRevisedGroupUpdateRate(aRequestedUpdateRate : DWORD) : DWORD; // su01
//  function GetGroupByName(aGroupName: String) : Pointer;
  // Функции работы с идентификаторами обьектов
  function GetNewServerGroupHandle(out aGroupHandle : OPCHANDLE) : HRESULT; // su01
  function GetServerTagHandle(dwServerID : DWORD; dwServerDriverID : DWORD; dwDeviceID: DWORD; dwTagID : DWORD; out hServer: DWORD):HRESULT; // su01
  function GetNewTID : DWORD; // su01
  function GetNewTIID : DWORD; // su01
  // Функции работы с тегами
  // Проверяем возможность назначения типа ожидаемого (revised) типа данных элементу данных (OPCItem)
  function ValidateDataType(vtCanonical: TVarType; vtNew: TVarType): HRESULT; // su01
  {$if defined (CHECK_DONGLE) }
  // Проверка выполнения лицензионных ограничений
  // result:
  //    S_Ok - Проверка пройдена
  //    S_FALSE - Проверка НЕ пройдена
  //    E_ - Ошибка выполнения проверки
  function ValidateLicense : HRESULT; // su01
  {$ifend}
end;

var
  ServerCore : TVpNetDAServerCore;

implementation

uses VpNetDefs, VpNetDADefs, uOPCUtils, VpNetDADebug, VpNetOPCGroup_Impl, VpNetHst_TLB,
  TypInfo;

//{$I VpNetGuardantCode.pas}

function TVpNetDAServerCore.GetState : TVpNetDAServerState;
begin
  Lock;
  try
    result := FState;
  finally
    Unlock;
  end;    
end;

constructor TVpNetDAServerCore.Create;
var
  hr : HRESULT;
  SInstanceId : String;
  ds : TDataSet;
  CL_Name : String;
  sValue : String;
  vValue : OleVariant;
begin
  try
    inherited;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70668, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    // Инициализация основной критической секции
    InitializeCriticalSection(FCS);

    // Инициализируем общей критической секции доступа к базе данных
    InitializeCriticalSection(FDBCS);

    // Устаннавливаем состояние сервера "Запуск"
    FState := vndsCreating;

  except on e : Exception do begin
      PostLogRecordAddMsgNow(70669, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    // Чтение идентификатора экземпляра сервера
    hr := GetIniValue(IniFileCoreSectionName, 'ID', SInstanceId);
    if hr = S_OK then begin
      try
        FInstanceId := StrToInt(SInstanceId);
      except
        PostLogRecordAddMsgNow(70671, FInstanceId, -1, -1, '');
        FInstanceId := UnassignedInstanceIdValue;
      end;
    end else begin
      PostLogRecordAddMsgNow(70672, hr, -1, -1, '');
      FInstanceId := UnassignedInstanceIdValue;
    end;

  except on e : Exception do begin
      PostLogRecordAddMsgNow(70670, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    // Создание модуля доступа к базе данных
    DBLock;
    try
      FRDM := TVpNetDARDM.Create(nil);
    finally
      DBUnlock;
    end;
    FRDM.bLockDBGlobally := false;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70673, e.HelpContext, -1, -1, e.Message);
    end;
  end;


  // Создание объекта-ключа
  {$if defined (CHECK_DONGLE) }
  try
    FDongle := TGuardantDongle.Create(
      {$if defined (CHECK_DONGLE_LOCAL) }
      vnat_Local,
      {$ELSEIF defined (CHECK_DONGLE_NET)}
      vnat_Net,
      {$ELSE}
      error!!!,
      {$IFEND}
      nsf_Nprog + // Искать ключи по номеру программного продукта
      nsf_Mask + // Искать ключи по маске (к примеру по модулю программы)
      nsf_Type + // и по его типу
      nsf_SysAddrMode, // Использовать системную адресацию памяти ключа
      ProgId_VpNet, // Искать ключи для всех программных продуктов Взлет-Прмьер
      0, // не ограничивать поиск по ID ключа
      0, // не ограничивать поиск по серийному номеру
      0, // не ограничивать версии программных продуктов
      MaskID_VpNetDA, // ограничивать поиск по маске для модуля VpNetHST
      nskt_GSII64,  // Будем искать ключи, поддерживающие алгоритм GSII64
      ModuleId_VpNetDA
     );
     // сбрасываем момент последней прверки лицензий для того, чтобы
     // при первом вызове функции ValidateLicense() была произведена первая
     // проверка лицензий.
     FLicLastChackedTime := 0;
     ValidateLicense; // Сразу по создании проверяем лицензию
  except on e : Exception do begin
      FLicLastChackedTime := 0;
      FLicState := S_FALSE;
      PostLogRecordAddMsgNow(70013, e.HelpContext, -1, E_FAIL, 'Ошибка инициализации ключа электронной защиты: '+e.Message);
    end;
  end;
  {$ifend}

  try
    // Заполнение массива допустимых типов данных
    FValidDataTypes := TList.Create();
    ds := rdm.GetQueryDataset('select distinct vdt_var_type from vn_datatypes');
    try
      ds.Open;
      ds.First;
      while not ds.Eof do begin
        FValidDataTypes.add(Pointer(ds.Fields[0].AsInteger));
        ds.Next;
      end;
    finally
      ds.free;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70674, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    // Заполнение массива поддерживаемых Locale
    FValidLocaleIDs := TList.Create();
    ds := rdm.GetQueryDataset(
      'select vl_id, clid, Upper(vl_name collate WIN1251) LOCALE_NAME from vn_locales order by vl_id'
    );
    try
      ds.Open;
      ds.First;
      while not ds.Eof do begin
        if not ds.FieldByName('CLID').IsNull then begin
          // Добавляем CLID
          FValidLocaleIDs.Add(Pointer(ds.FieldByName('CLID').AsInteger));
        end else begin
          // Ищем редопределенные CLID по названиям
          if not ds.FieldByName('LOCALE_NAME').IsNull then begin
            CL_Name := ds.FieldByName('LOCALE_NAME').AsString;
            if AnsiUpperCase(CL_Name) = AnsiUpperCase('LOCALE_SYSTEM_DEFAULT') then
              FValidLocaleIDs.Add(Pointer(LOCALE_SYSTEM_DEFAULT));
            if AnsiUpperCase(CL_Name) = AnsiUpperCase('LOCALE_USER_DEFAULT') then
              FValidLocaleIDs.Add(Pointer(LOCALE_USER_DEFAULT));
          end;
        end;
        ds.Next;
      end;
    finally
      ds.free;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70675, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    FHstServerInfoList := TVpNetHostServerInfoList.Create;
    ds := rdm.GetQueryDataset(
      'select vhs_id, vhs_address, vhs_tag, vhs_text from vn_host_servers order by vhs_id '
    );
    try
      ds.Open;
      ds.First;
      while not ds.Eof do begin
        FHstServerInfoList.Add(TVpNetHostServerInfo.Create(ds.Fields[0].AsInteger, ds.Fields[1].AsString, ds.Fields[2].AsString, ds.Fields[3].AsString));
        ds.Next;
      end;
    finally
      ds.free;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70676, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    FHstServerDriverInfoList := TVpNetHostServerDriverInfoList.Create;
    ds := rdm.GetQueryDataset(
      'select vhsd_id, vhs_id, vhsdt_id, vhsd_tag, vhsd_text ' +
      'from vn_host_server_drivers ' +
      'order by vhsd_id '
    );
    try
      ds.Open;
      ds.First;
      while not ds.Eof do begin
        FHstServerDriverInfoList.Add(TVpNetHostServerDriverInfo.Create(ds.Fields[0].AsInteger, ds.Fields[1].AsInteger, ds.Fields[2].AsInteger, ds.Fields[3].AsString, ds.Fields[4].AsString));
        ds.Next;
      end;
    finally
      ds.free;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70677, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    // MinGroupKeepAlive
    FMinGroupKeepAlive := UnassignedMinGroupKeepAlive;
// 28.03.2010
//    hr := rdm.NodeParams.GetNodeParamValue(InstanceId, 'GROUP_MIN_KEEP_ALIVE_TIME', sValue);
//    if hr >= S_OK then begin
//      FMinGroupKeepAlive := StrToIntDef(sValue, UnassignedMinGroupKeepAlive);
//    end;
    hr := rdm.NodeParams.GetNodeParamValue(InstanceId, 'GROUP_MIN_KEEP_ALIVE_TIME', vValue);
    if hr >= S_OK then begin
      if VarIsOrdinal(vValue) then begin
        FMinGroupKeepAlive := vValue;
      end else begin
        FMinGroupKeepAlive := UnassignedMinGroupKeepAlive;
      end;
    end;
// 28.03.2010
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70678, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  // Восстанавливаем номер последней выданной транзакции DA-сервера
  try
    FLastTID := UnassignedLastTID;

// 28.03.2010
//    hr := rdm.NodeParams.GetNodeParamValue(InstanceId, 'LAST_TID', sValue);
//    if hr >= S_OK then begin
//      FLastTID := StrToIntDef(sValue, UnassignedLastTID);
//    end;
    hr := rdm.NodeParams.GetNodeParamValue(InstanceId, 'LAST_TID', vValue);
    if hr >= S_OK then begin
      if VarIsOrdinal(vValue) then begin
        FLastTID := vValue;
      end else begin
        FLastTID := UnassignedLastTID;
      end;
    end;
///28.03.2010
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70679, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  // Восстанавливаем номер последнего элемента последней выданной транзакции DA-сервера
  try
    FLastTIID := UnassignedLastTIID;
// 28.03.2010
//    hr := rdm.NodeParams.GetNodeParamValue(InstanceId, 'LAST_TIID', sValue);
//    if hr >= S_OK then begin
//      FLastTIID := StrToIntDef(sValue, UnassignedLastTIID);
//    end;
    hr := rdm.NodeParams.GetNodeParamValue(InstanceId, 'LAST_TIID', vValue);
    if hr >= S_OK then begin
      if VarIsOrdinal(vValue) then begin
        FLastTIID := vValue;
      end else begin
        FLastTIID := UnassignedLastTIID;
      end;
    end;
// 28.03.2010
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70680, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    FServerObjects := TThreadList.Create; // Создание защищенного массива ссылок на экземпляры COM-объектов-серверов
    FGroupObjects := TThreadList.Create; // Создание защищенного массива ссылок на экземпляры COM-объектов-групп
    HstConnections := TVpNetHstDriverConnectionThreadList.Create; // Создание защищенного списка соединений с Hst-серверами
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70681, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    // Устаннавливаем состояние сервера "Работа"
    Lock;
    try
      FState := vndsWorking;
    finally
      Unlock;
    end;

    FRDM.bLockDBGlobally := true;

  // 16.10.2009
    FCheckThread := TVpNetDAConnectionsControlThread.Create(1000);
    FCheckThread.Resume;
  ///16.10.2009
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70682, e.HelpContext, -1, -1, e.Message);
    end;
  end;


end;

destructor TVpNetDAServerCore.Destroy;
var
  LockedGroupList : TList;
  GroupIndex : Integer;
  GroupObj : TVpNetOPCGroup;

  LockedServerList : TList;
  ServerIndex : Integer;
  ServerObj : TVpNetOPCDA;

  LockedHstConnectionList : TList;
  HstDriverConnection : TVpNetHstDriverConnection;
  aNow : TDateTime;
begin
  // Устаннавливаем состояние сервера "Завершение работы"
  try
    Lock;
    try
      FState := vndsDestroing;
    finally
      Unlock;
    end;

    LockedHstConnectionList := HstConnections.LockList;
    try
      while LockedHstConnectionList.Count > 0 do begin
        // Получение очередного удаляемого соединения
        HstDriverConnection := TVpNetHstDriverConnection(LockedHstConnectionList[0]);
        // Удаление соединения из списка
        LockedHstConnectionList.Delete(0);
        // Удаление самого соединения
        HstDriverConnection.Free;
      end;
    finally
      // Снятие блокировки со списка соединений
      HstConnections.UnlockList;
    end;
    // Удаление списка соединений
    HstConnections.Free;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70684, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    // Очистка списка COM-объектов-групп
    LockedGroupList := FGroupObjects.LockList;
    try
      // Последовательно удаляем все сервера
      GroupIndex := LockedGroupList.Count - 1;
      while GroupIndex >= 0 do try
        try
          // Получаем очередной объект
          GroupObj := TVpNetOPCGroup(LockedGroupList[GroupIndex]);
          // Вызываем callback, сообщающий о закрытии сервера
    //          if assigned(GroupObj.Events) then GroupObj.Events.OnClose;
          // Ожидаем отключения клиента в течении 5 секунд...
          aNow:=Now;
          while (GroupObj.RefCount > 0) and ((aNow+5/86400)>Now) do
          begin
            Application.ProcessMessages;
          end;
          // ...и если за это время клиент не отсоединился, убиваем его насильно
          if GroupObj.RefCount > 0 then
            GroupObj.free;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70686, e.HelpContext, -1, -1, e.Message);
          end;
        end;
        // Переходим к следующему объекту
      finally
        GroupIndex := Pred(GroupIndex);
      end;
    finally
      // Разблокируем список COM-объектов-групп
      FGroupObjects.UnlockList;
    end;
    // Удаление списка COM-объектов-групп
    FGroupObjects.Free;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70685, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    // Очистка списка COM-объектов-серверов
    LockedServerList := FServerObjects.LockList;
    try
      // Последовательно удаляем все сервера
      ServerIndex := LockedServerList.Count - 1;
      while ServerIndex >= 0 do try
        try
          // Получаем очередной объект
          ServerObj := TVpNetOPCDA(LockedServerList[ServerIndex]);
          // Вызываем callback, сообщающий о закрытии сервера
          //if assigned(ServerObj.Events) then ServerObj.Events.OnClose;
          if assigned(ServerObj.ShutDownIntf) then
            ServerObj.ShutDownIntf.ShutdownRequest(StringToOleStr('Завершение работы сервера'));
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70688, e.HelpContext, -1, -1, e.Message);
          end;
        end;

        // Ожидаем отключения клиента в течении 5 секунд...
        try
          aNow:=Now;
          while (ServerObj.RefCount > 0) and ((aNow+5/86400)>Now) do
          begin
            Sleep(1);
            Application.ProcessMessages;
          end;
          // ...и если за это время клиент не отсоединился, убиваем его насильно
          if ServerObj.RefCount > 0 then
            ServerObj.free;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70689, e.HelpContext, -1, -1, e.Message);
          end;
        end;
      finally
        // Переходим к следующему объекту
        ServerIndex := Pred(ServerIndex);
      end;
    finally
      // Разблокируем список COM-объектов-серверов
      FServerObjects.UnlockList;
    end;
    // Удаление списка COM-объектов-cсерверов
    FServerObjects.Free;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70687, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  // Сохранение последнего выданного сервером идентификатора элемента DA-транзакции
  try
    rdm.NodeParams.SetNodeParamValue(InstanceId, 'LAST_TIID', IntToStr(FLastTIID));
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70690, e.HelpContext, InstanceId, FLastTIID, e.Message);
    end;
  end;

  // Сохранение последнего выданного сервером идентификатора DA-транзакции
  try
    rdm.NodeParams.SetNodeParamValue(InstanceId, 'LAST_TID', IntToStr(FLastTID));
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70691, e.HelpContext, InstanceId, FLastTID, e.Message);
    end;
  end;

  try
    // Удаление структур с информацией об Hst-драйверах
    FHstServerDriverInfoList.DeleteItems;
    FHstServerDriverInfoList.Free;

    // Удаление структур с информацией об Hst-серверах
    FHstServerInfoList.DeleteItems;
    FHstServerInfoList.free;

    // Удаление списка допустимых LOCALEs
    FValidLocaleIDs.Free;
    // Удаление списка поддерживаемых типов данных
    FValidDataTypes.Free;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70692, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  // Удаление объекта-ключа
  {$if defined (CHECK_DONGLE) }
  try
    FDongle.Free;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70693, e.HelpContext, -1, -1, e.Message);
    end;
  end;
  {$ifend}

  try
    // Освобождение модуля данных
    DBLock;
    try
      FRDM.Free;
    finally
      DBUnlock;
    end;

    // Удаляем общей критической секции доступа к базе данных
    DeleteCriticalSection(FDBCS);
    // Удаляем общую критическую скцию объекта
    DeleteCriticalSection(FCS);
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70694, e.HelpContext, -1, -1, e.Message);
    end;
  end;

  try
    // Выполняем унаследованные действия по деинициализации объекта
    inherited;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70683, e.HelpContext, -1, -1, e.Message);
    end;
  end;
end;

function TVpNetDAServerCore.Perform(Message: TMessage): Longint;
var
  LockedHstConnections : TVpNetHstDriverConnectionList;
  HstConnection : TVpNetHstDriverConnection;
  HstTID : DWORD;
  vRemoteMachineName : Variant;
  trList : TVpNetDATransactionItemList;
  DriverId : DWORD;
  pAnswerData : PVpNetHSTAnswerData;
// 30.11.2011
  pErrorData : PVpNetHSTErrorData;
///30.11.2011
  ErrorCode : HRESULT;
  tr : TVpNetDATransaction;
  grp : TVpNetOPCGroup;
  vhsd_id : Integer;
  HstDriverInfo : TVpNetHostServerDriverInfo;
  HstServerInfo : TVpNetHostServerInfo;
  qRes : HRESULT;
  index : Integer;
  iWaitingTimeMS : Integer;
begin
  result := E_FAIL;
  try
    with Message do begin
      case msg of    
        // Команда на отправку запроса новых данных через драйвер хост-сервера
        CM_DA_HST_DRIVER_ADD_TRANSACTIONS: try
          {$if defined (CHECK_DONGLE) }
          qRes := ValidateLicense;
          if qRes <> S_OK then begin
            PostLogRecordAddMsgNow(70696, qRes, -1, -1, '');
            result := qRes;
            exit;
          end;
          {$ifend}

          // Получаем идентификатор драйвера Hst-сервера
          DriverId := DWORD(WPARAM);
          // Получаем список добавляемых транзакций
          trList := TVpNetDATransactionItemList(Pointer(LPARAM));
          // Блокируем список соединений с Hst-серверами
          LockedHstConnections := HstConnections.LockList;
          try
            // Ищем соединения с драйвером по указанному в trList идентификатору драйвера (DriverId)
            HstConnection := LockedHstConnections.FindByDriverId(DriverId);
//            Без отладчика не находим HstConnection !!!

            // Если нашли такой драйвер, пересылаем туда сообщение
            if assigned(HstConnection) then begin
              HstConnection.AddTransactionItems(trList);
            end else begin
              PostLogRecordAddMsgNow(70345, 3, -1, -1, '');
            end;

          finally
            // Разблокируем список соединений с Hst-серверами
            HstConnections.UnlockList;
          end;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70697, e.HelpContext, -1, -1, e.Message);
          end;
        end;

        CM_DA_HST_DRIVER_SEND: try

          // Получаем идентификатор драйвера Hst-сервера
          DriverId := DWORD(WPARAM);

          // Блокируем список описаний соединений
          LockedHstConnections := HstConnections.LockList;
          try
            // Ищем соединения с драйвером по указанному в WParam идентификатору драйвера DriverId
            HstConnection := LockedHstConnections.FindByDriverId(DriverId);

            // Если нашли такой драйвер, пересылаем туда сообщение
            if assigned(HstConnection) then begin
              HstConnection.Send;
            end else begin
              PostLogRecordAddMsgNow(70664, -1, -1, -1, '');
            end;

          finally
            // Разблокируем список описаний соединений
            HstConnections.UnlockList;
          end;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70320, e.HelpContext, Integer(ServerCore.State), -1, e.Message);
          end;
        end;

        WM_DA_HST_DRIVER_RECIEVE: try
          PostLogRecordAddMsgNow(70935, WParam, LParam, -1, 'WParam='+IntToStr(WParam)+', LParam=' + IntToStr(LParam), llDebug);
          // Получаем идентификатор транзакции HST-сервера
          HstTID := DWORD(WParam);
          PostLogRecordAddMsgNow(70936, WParam, LParam, -1, 'pAnswerData='+IntToStr(Integer(pAnswerData)), llDebug);
          // Получаем структуру с полученными данными
          pAnswerData := PVpNetHSTAnswerData(LParam);
          PostLogRecordAddMsgNow(70937, -1, -1, -1, 'pAnswerData='+IntToStr(Integer(pAnswerData)), llDebug);
          PostLogRecordAddMsgNow(70844, Integer(pAnswerData), Integer(pAnswerData^.HstAnswerData), Integer(pAnswerData^.HstAnswerDataSize), 'Ok. t', llDebug);
          // Блокируем список описаний соединений
          LockedHstConnections := HstConnections.LockList;
          try
            // Ищем соединения с драйвером по указанному в WParam идентификатору транзакции Hst-сервера
            HstConnection := LockedHstConnections.FindByCurrHstTID(HstTID);
            // Если нашли такой драйвер, пересылаем туда сообщение
            if assigned(HstConnection) then begin
              PostLogRecordAddMsgNow(70314, -1, -1, -1, 'Ok. HstConnection.Recieve(' + IntToStr(Integer(pAnswerData)) + '); pAnswerData=('+ IntToStr(pAnswerData^.HstAnswerDataSize) +', ' + IntToStr(Integer(pAnswerData^.HstAnswerData)) + ')', llDebug);
              HstConnection.Recieve(pAnswerData);
              DriverId := HstConnection.DriverId;
            end else begin
              PostLogRecordAddMsgNow(70667, -1, -1, -1, '');
              DriverId := 0;
            end;
          finally
            // Разблокируем список описаний соединений
            HstConnections.UnlockList;
          end;

          // Если драйвер, Hst-сервера, для которого получен ответ найден,
          // посылаем команду на отправку запроса новых данных через этот драйвер
          if DriverId > 0 then begin
            PostLogRecordAddMsgNow(70315, Integer(ServerCore.State), -1, -1, 'Ok. PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_SEND, DriverId, 0);', llDebug);
            PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_SEND, DriverId, 0);
          end else begin
            PostLogRecordAddMsgNow(70665, DriverId, -1, -1, '');
          end;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70698, e.HelpContext, -1, -1, e.Message);
          end;
        end;

        WM_DA_HST_DRIVER_ERROR: try
          PostLogRecordAddMsgNow(70316, Integer(ServerCore.State), -1, -1, 'WM_DA_HST_DRIVER_ERROR');
          // Получаем идентификатор транзакции HST-сервера
          HstTID := DWORD(WParam);
          ErrorCode := Integer(LParam);
          // Блокируем список описаний соединений
          LockedHstConnections := HstConnections.LockList;
          try
            // Ищем соединения с драйвером по указанному в WParam идентификатору транзакции Hst-сервера
            HstConnection := LockedHstConnections.FindByCurrHstTID(HstTID);
            // Если нашли такой драйвер, пересылаем туда сообщение
            if assigned(HstConnection) then begin
              PostLogRecordAddMsgNow(70317, Integer(ServerCore.State), -1, -1, '');
              HstConnection.Error(HstTID, ErrorCode);
              DriverId := HstConnection.DriverId;
            end else begin
              DriverId := 0;
            end;
          finally
            // Разблокируем список описаний соединений
            HstConnections.UnlockList;
          end;
          // Если драйвер, Hst-сервера, для которого получен ответ найден,
          // посылаем команду на отправку запроса новых данных через этот драйвер
          if DriverId > 0 then begin
            PostLogRecordAddMsgNow(70318, Integer(ServerCore.State), -1, -1, '');
            PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_SEND, DriverId, 0);
          end else begin
            PostLogRecordAddMsgNow(70700, DriverId, -1, -1, '');
          end;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70699, e.HelpContext, -1, -1, e.Message);
          end;
        end;

// 30.11.2011
        WM_DA_HST_DRIVER_ERROR_WITH_DATA: try
          PostLogRecordAddMsgNow(70832, Integer(ServerCore.State), -1, -1, 'WM_DA_HST_DRIVER_ERROR_WITH_DATA');
          // Получаем идентификатор транзакции HST-сервера
          HstTID := DWORD(WParam);
          // Получаем данные
          pErrorData := PVpNetHSTErrorData(LParam);
          // Блокируем список описаний соединений
          LockedHstConnections := HstConnections.LockList;
          try
            // Ищем соединения с драйвером по указанному в WParam идентификатору транзакции Hst-сервера
            HstConnection := LockedHstConnections.FindByCurrHstTID(HstTID);
            // Если нашли такой драйвер, пересылаем туда сообщение
            if assigned(HstConnection) then begin
              PostLogRecordAddMsgNow(70317, Integer(ServerCore.State), -1, -1, '');
              HstConnection.ErrorWithData(HstTID, pErrorData);
              DriverId := HstConnection.DriverId;
            end else begin
              DriverId := 0;
            end;
          finally
            // Разблокируем список описаний соединений
            HstConnections.UnlockList;
          end;
          // Если драйвер, Hst-сервера, для которого получен ответ найден,
          // посылаем команду на отправку запроса новых данных через этот драйвер
          if DriverId > 0 then begin
            PostLogRecordAddMsgNow(70833, Integer(ServerCore.State), -1, -1, '');
            PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_SEND, DriverId, 0);
          end else begin
            PostLogRecordAddMsgNow(70834, DriverId, -1, -1, '');
          end;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70835, e.HelpContext, -1, -1, e.Message);
          end;
        end;
///30.11.2011


        // 16.10.2009
        // Команда на проверку транзакций
        CM_DA_TRANSACTION_CHECK: try
          // Блокируем список описаний соединений
          LockedHstConnections := HstConnections.LockList;
          try
            index := 0;
            while Index < LockedHstConnections.count do try
              HstConnection := LockedHstConnections[index];
              HstConnection.Lock;
              try
// 02.04.2010
//                if (now - HstConnection.Hst_Transaction_Send_Time_MS) > (HstConnection.HstDriverMaxAnswerTimeMS / 86400000) then try
                iWaitingTimeMS := trunc((now - HstConnection.Hst_Transaction_Send_Time_MS)*86400000);
                if iWaitingTimeMS > HstConnection.HstDriverMaxAnswerTimeMS then try
//                  PostLogRecordAddMsgNow(70845, iWaitingTimeMS, HstConnection.HstDriverMaxAnswerTimeMS, LockedHstConnections.count, 'Index='+ IntToStr(Index)+'; Превышено максимальное время ожидания ответа от hst-сервера (now=' + floatToStr(now) + '); HstConnection.Hst_Transaction_Send_Time_MS='+ floatToStr(HstConnection.Hst_Transaction_Send_Time_MS), llDebug);
// 02.04.2010
                  if HstConnection.Hst_TID > 0 then begin
                    PostLogRecordAddMsgNow(70407, iWaitingTimeMS, HstConnection.HstDriverMaxAnswerTimeMS, -1, '', llDebug);
// 30.11.2011
                    //HstConnection.Error(HstConnection.Hst_TID, E_ABORT);

///30.11.2011
                    PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_SEND, HstConnection.DriverId, 0);
                  end;
                except on e : Exception do begin
                    PostLogRecordAddMsgNow(70702, e.HelpContext, -1, -1, e.Message);
                  end;
                end;
              finally
                HstConnection.Unlock;
              end;
            finally
              index := succ(index);
            end;
          finally
            // Разблокируем список описаний соединений
            HstConnections.UnlockList;
          end;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70701, e.HelpContext, -1, -1, e.Message, llErrors);
          end;
        end;
        ///16.10.2009

        WM_DA_TRANSACTION_PROCESSED : try
          // Сообщение о завершении асинхронной транзакции DA-сервера
          // Вызываем метод вызова callback-функции
          grp := TVpNetOPCGroup(WParam);
          tr := TVpNetDATransaction(LParam);
// 19.01.2012
          if tr.InvocationType = vnditSubscription then begin
            // источник транзакции - подписка на даные
            PostLogRecordAddMsgNow(70919, Integer(tr.InvocationType), -1, -1, 'Перед Group.DoOnDataChange()', llDebug);
            grp.DoCallOnDataChange(tr);
          end else  if tr.InvocationType = vnditRead then begin
            // источика транзакции - асинхронное чтение
            PostLogRecordAddMsgNow(70920, Integer(tr.InvocationType), -1, -1, 'Вызов DoOnReadCompleted()', llDebug);
            grp.DoCallOnReadCompleted(tr);
          end else begin
            PostLogRecordAddMsgNow(70933, Integer(tr.InvocationType), -1, -1, '', llErrors);
          end;;
///19.01.2012
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70703, e.HelpContext, -1, -1, e.Message, llErrors);
          end;
        end;

        //Сообщение о добавлении ссылки на драйвер Host-сервера
        CM_DA_HST_DRIVER_ADD_REF: try
          // Блокируем список описаний соединений
          LockedHstConnections := HstConnections.LockList;
          try
            // Идентификатор драйвера Host-сервера
            vhsd_id := DWORD(WPARAM);
            // Ищем соединение по указанному в WPARAM идентификатору драйвера (HstId)
            HstConnection := LockedHstConnections.FindByDriverId(vhsd_id);
            if assigned(HstConnection) then begin
              // если соединение найдено, приращаем счетчик ссылок на соединение
              HstConnection.RefCount := Succ(HstConnection.RefCount);
            end else begin
              // если до сих пор такого соединения не было, cоздаем его
              HstDriverInfo := HstServerDriverInfoList.FindByHstDriverId(vhsd_id);
              if assigned(HstDriverInfo) then begin
                HstServerInfo := HstServerInfoList.FindByHstServerId(HstDriverInfo.HstServerId);
              end else begin
                PostLogRecordAddMsgNow(70706, -1, -1, -1, '');
              end;

              if assigned(HstServerInfo) then begin
                vRemoteMachineName := HstServerInfo.HstServerAddress;
{
              vRemoteMachineName := rdm.GetOneCell(
                'select vhs.vhs_address from vn_host_servers vhs ' +
                'where vhs.vhs_id = ( ' +
                '  select vhsd.vhs_id from vn_host_server_drivers vhsd ' +
                '  where vhsd.vhsd_id = ' + rdm.IntToIB(vhsd_id, '-1') + ') '
              );
              if not (VarIsNull(vRemoteMachineName) or VarIsEmpty(vRemoteMachineName)) then begin
}
                {$if defined (ONE_GSM_DEMO)}
                if LockedHstConnections.Count = 0 then begin
                  HstConnection := TVpNetHstDriverConnection.Create(vRemoteMachineName, WPARAM);
                  // Прибавляем одну ссылку в счетчику ссылок Hst-сервера, которая обеспечит
                  // постоянную поддержку соединения, и одну ссылку, которая будет удалена
                  // при обработке парного сообщения CM_DA_HST_DRIVER_RELEASE
                  HstConnection.RefCount := 1 + 1;
                  LockedHstConnections.Add(HstConnection);
                end else begin
                  PostLogRecordAddMsgNow(70708, -1, -1, -1, '');
                end;
                {$ELSE}
                HstConnection := TVpNetHstDriverConnection.Create(vRemoteMachineName, WPARAM);
                // Прибавляем одну ссылку в счетчику ссылок Hst-сервера, которая обеспечит
                // постоянную поддержку соединения, и одну ссылку, которая будет удалена
                // при обработке парного сообщения CM_DA_HST_DRIVER_RELEASE
                HstConnection.RefCount := 1 + 1;
                LockedHstConnections.Add(HstConnection);
                {$ifend}
              end else begin
                PostLogRecordAddMsgNow(70707, -1, -1, -1, '');
                result := E_INVALIDARG;
              end;
            end;
            // Возвращаем S_OK
            result := S_OK;
          finally
            // Разблокируем список описаний соединений
            HstConnections.UnlockList;
          end;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70704, e.HelpContext, -1, -1, e.Message);
          end;
        end;

        //Сообщение об удалении ссылки на драйвер Host-сервера
        CM_DA_HST_DRIVER_RELEASE: try
          // Блокируем список описаний соединений
          LockedHstConnections := HstConnections.LockList;
          try

            // Ищем соединение по указанному в WPARAM идентификатору драйвера (HstId)
            HstConnection := LockedHstConnections.FindByDriverId(DWORD(WPARAM));

            if assigned(HstConnection) then begin
              // если соединение найдено, уменьшаем счетчик ссылок на соединение
              if HstConnection.RefCount > 0 then
                HstConnection.RefCount := Pred(HstConnection.RefCount);

              // Если удалили последнюю ссылку на соединение,
              // удаляем соединение из списка и уничтожаем его
              if HstConnection.RefCount <= 0 then begin
                // Закрываем соединение драйвера
//                result := HstConnection.Driver.Close;
                // Вне зависимости от результата закрытия драйвера
                // удаляем его из списка активных драйверов
                LockedHstConnections.Remove(HstConnection);
                // Удаляем сам драйвер
                HstConnection.Free;
              end;

              // Возвращаем S_OK
              result := S_OK;
            end else begin
              // если до сих пор такого соединения не было, возвращаем E_INVALIDARG
              PostLogRecordAddMsgNow(70846, -1, -1, -1, '', llDebug);
              result :=  E_INVALIDARG
            end;
          finally
            // Разблокируем список описаний соединений
            HstConnections.UnlockList;
          end;
          // Возвращаем S_OK
          result := S_OK;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70708, e.HelpContext, -1, -1, e.Message);
          end;
        end;

        WM_DA_HST_DRIVER_ACTIVE_STATE_CHANGED : begin

        end;

        CM_DA_LOG_RECORD_ADD: try
          with PVpNetDALogRecordDataStruct(pointer(WPARAM))^ do begin
            AddLogRecord(dt, VDAE_ID, Param1, Param2, Param3, Desc, SectionMask);
          end;
          CoTaskMemFree(PVpNetDALogRecordDataStruct(pointer(WPARAM))^.Desc);
          CoTaskMemFree(pointer(WParam));
        except
        end;

      end;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70695, e.HelpContext, -1, -1, e.Message);
    end;
  end;
end;

procedure TVpNetDAServerCore.Lock;
begin
  try
    EnterCriticalSection(FCS);
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70710, e.HelpContext, -1, -1, e.Message);
    end;
  end;
end;

procedure TVpNetDAServerCore.Unlock;
begin
  try
    LeaveCriticalSection(FCS);
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70711, e.HelpContext, -1, -1, e.Message);
    end;
  end;
end;

procedure TVpNetDAServerCore.DBLock;
begin
  try
    EnterCriticalSection(FDBCS);
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70712, e.HelpContext, -1, -1, e.Message);
    end;
  end;
end;

procedure TVpNetDAServerCore.DBUnlock;
begin
  try
    LeaveCriticalSection(FDBCS);
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70713, e.HelpContext, -1, -1, e.Message);
    end;
  end;
end;

function TVpNetDAServerCore.GetRevisedGroupUpdateRate(aRequestedUpdateRate : DWORD) : DWORD;
begin
  try
    Lock;
    try
      //todo: Реальное максимальное время обновления (pRevisedUpdateRate) нужно
      // вычислять по данным объектной модели сервера (исходя из количества
      // и типов устройств, описанных в бъектной модели)
      // ...
      result := aRequestedUpdateRate;
    finally
      Unlock;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70714, e.HelpContext, aRequestedUpdateRate, -1, e.Message);
    end;
  end;
end;
{
function TVpNetDAServerCore.GetGroupByName(aGroupName: String) : Pointer;
var
  GrpIndex : Integer;
  llGrp : TList;
begin
  result := nil;
  Lock;
  try
    // Проходим по списку групп
    llGrp := FGroupObjects.LockList;
    try
      GrpIndex := 0;
      while GrpIndex < llGrp.Count do begin
        // сверяем имя группы с заданным
        if
          TVpNetOPCGroup(llGrp[GrpIndex]).Name = aGroupName
        then begin
          result := TVpNetOPCGroup(llGrp[GrpIndex]);
          break;
        end;
        GrpIndex := Succ(GrpIndex);
      end;
    finally
      FGroupObjects.UnlockList;
    end;
  finally
    Unlock;
  end;
end;
}

function TVpNetDAServerCore.GetNewServerGroupHandle(out aGroupHandle : OPCHANDLE) : HRESULT;
var
  sValue : String;
  hr : HRESULT;
  vValue : OleVariant;
begin
  try
    Lock;
    try
      // Чтение текущего значения последнего выданного серверного идентификатора группы
      aGroupHandle := UnassignedGroupHandle;
      try
// 28.03.2010
//        hr := rdm.NodeParams.GetNodeParamValue(InstanceId, 'GROUP_LAST_HANDLE', sValue);
//        if hr >= S_OK then begin
//          aGroupHandle := StrToIntDef(sValue, UnassignedGroupHandle);
//        end else begin
//          result := E_FAIL;
//          exit;
//        end;
        hr := rdm.NodeParams.GetNodeParamValue(InstanceId, 'GROUP_LAST_HANDLE', vValue);
        if hr >= S_OK then begin
          try
            aGroupHandle := vValue;
          except on e : Exception do
            begin
              PostLogRecordAddMsgNow(70718, -1, -1, -1, '', llErrors);
              aGroupHandle := UnassignedGroupHandle;

            end;
          end;
        end else begin
          PostLogRecordAddMsgNow(70717, -1, hr, -1, '', llErrors);
          result := E_FAIL;
          exit;
        end;
///28.03.2010
      except on e : Exception do begin
          PostLogRecordAddMsgNow(70716, e.HelpContext, -1, -1, e.Message);
          result := E_FAIL;
          exit;
        end;
      end;

      // Увеличиваем значение последнего выданного серверного идентификатора
      // группы на 1
      aGroupHandle := aGroupHandle + 1;

      // Записываем измененное значение назад в базу данных
      sValue := IntToStr(aGroupHandle);
      hr := rdm.NodeParams.SetNodeParamValue(InstanceId, 'GROUP_LAST_HANDLE', sValue);

      // Если не удалось изменить значение последнего выданного серверного
      if hr < S_OK then begin
        // идентификатора группы в базе данных, возвращаем E_FAIL
        PostLogRecordAddMsgNow(70719, hr, -1, -1, '');
        aGroupHandle := UnassignedGroupHandle;
        result := E_FAIL;
        exit;
      end;
    finally
      Unlock;
    end;

    result := S_OK;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70715, e.HelpContext, -1, -1, e.Message);
      aGroupHandle := 0;
      result := E_FAIL;
    end;
  end;
end;

// Находим серверный идентификатор тега по HST_ID, VD_ID, VDTT_ID
function TVpNetDAServerCore.GetServerTagHandle(dwServerID : DWORD; dwServerDriverID : DWORD; dwDeviceID: DWORD; dwTagID : DWORD; out hServer: DWORD):HRESULT;
var
  HST_BASE: DWORD;
  HSTD_BASE: DWORD;
  VD_BASE: DWORD;
  VDTT_BASE: DWORD;
  v: Variant;
begin
  try
    hServer := 0;
    result := E_FAIL;
    v := rdm.GetOneCell(
      'select VNIR_MIN_ID from vn_node_id_ranges vnir ' +
      'where ' +
      '  vnir.vnir_id = ( ' +
      '    select min(vnir_id) from vn_node_id_ranges vnir2 ' +
      '    where vnir2.vnt_id = ( ' +
      '      select vnt.vnt_id from VN_NODE_TYPES vnt ' +
      '      where upper(vnt.vnt_name collate WIN1251) = ' +
      '      upper(''HostServer'' collate WIN1251) ' +
      '    ) ' +
      '  ) '
    );

    try
      HST_BASE := v;
    except on e : Exception do
      begin
        PostLogRecordAddMsgNow(70721, dwServerID, dwServerDriverID, dwDeviceID, e.Message);
        exit;
      end
    end;

    v := rdm.GetOneCell(
      'select VNIR_MIN_ID from vn_node_id_ranges vnir ' +
      'where ' +
      '  vnir.vnir_id = ( ' +
      '    select min(vnir_id) from vn_node_id_ranges vnir2 ' +
      '    where vnir2.vnt_id = ( ' +
      '      select vnt.vnt_id from VN_NODE_TYPES vnt ' +
      '      where upper(vnt.vnt_name collate WIN1251) = ' +
      '      upper(''HostServerDriver'' collate WIN1251) ' +
      '    ) ' +
      '  ) '
    );

    try
      HSTD_BASE := v
    except  on e : Exception do
      begin
        PostLogRecordAddMsgNow(70722, dwServerID, dwServerDriverID, dwDeviceID, e.Message);
        exit;
      end
    end;

    v := rdm.GetOneCell(
      'select VNIR_MIN_ID from vn_node_id_ranges vnir ' +
      'where ' +
      '  vnir.vnir_id = ( ' +
      '    select min(vnir_id) from vn_node_id_ranges vnir2 ' +
      '    where vnir2.vnt_id = ( ' +
      '      select vnt.vnt_id from VN_NODE_TYPES vnt ' +
      '      where upper(vnt.vnt_name collate WIN1251) = ' +
      '      upper(''Device'' collate WIN1251) ' +
      '    ) ' +
      '  ) '
    );

    try
      VD_BASE := v;
    except  on e : Exception do
      begin
        PostLogRecordAddMsgNow(70863, dwServerID, dwServerDriverID, dwDeviceID, e.Message);
        exit;
      end;
    end;

    v := rdm.GetOneCell(
      'select VNIR_MIN_ID from vn_node_id_ranges vnir ' +
      'where ' +
      '  vnir.vnir_id = ( ' +
      '    select min(vnir_id) from vn_node_id_ranges vnir2 ' +
      '    where vnir2.vnt_id = ( ' +
      '      select vnt.vnt_id from VN_NODE_TYPES vnt ' +
      '      where upper(vnt.vnt_name collate WIN1251) = ' +
      '      upper(''DeviceTypeTag'' collate WIN1251) ' +
      '    ) ' +
      '  ) '
    );

    try
      VDTT_BASE := v;
    except  on e : Exception do
      begin
        PostLogRecordAddMsgNow(70864, dwServerID, dwServerDriverID, dwDeviceID, e.Message);
        exit;
      end;
    end;


    // hServer = 0xhhhhhrrrddddddddddddddtttttttttt
    // h - Host server ID bit
    // r - Host server driver ID bit
    // d - Device ID bit
    // t - Tag ID bit
    hServer := (((dwServerID - HST_BASE) and $1F) shl (3 + 14 + 10)) +
               (((dwServerDriverID - HSTD_BASE) and $7) shl (14 + 10)) +
               (((dwDeviceID - VD_BASE) and $3FFF) shl 10) +
               (
                 (dwTagID - VDTT_BASE) - (((dwTagID - VDTT_BASE) div 1000) * 1000)
               );

    result := S_OK;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70720, dwServerID, dwServerDriverID, dwDeviceID, e.Message+ '; dwTagID' + IntToStr(dwTagID));
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDAServerCore.GetNewTID : DWORD;
begin
  try
    Lock;
    try
      // Если FLastTID достиг максимального значения,
      if FLastTID = $7FFFFFFF then begin
        // обнуляем его
        FLastTID := 0;
      end else begin
        // иначе приращаем его на 1
        FLastTID := Succ(FLastTID);
      end;
      // Возвращаем новый идентификатор транзакции
      result := FLastTID;
    finally
      Unlock;
    end;
    PostMessage(Application.MainForm.Handle, WM_DA_NEW_TID, 0, FLastTID);
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70724, e.HelpContext, -1, -1, e.Message);
      result := 0;
    end;
  end;
end;

function TVpNetDAServerCore.GetNewTIID : DWORD;
begin
  try
    // Если FLastTIID достиг максимального значения,
    if FLastTIID = $7FFFFFFF then begin
      // обнуляем его
      FLastTIID := 0;
    end else begin
      // иначе приращаем его на 1
      FLastTIID := Succ(FLastTIID);
    end;
    // Возвращаем новый идентификатор элемента транзакции
    result := FLastTIID;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70725, e.HelpContext, -1, -1, e.Message);
      result := 0;
    end;
  end;
end;


function TVpNetDAServerCore.ValidateDataType(vtCanonical: TVarType; vtNew: TVarType): HRESULT;
begin
  try
    if FValidDataTypes.IndexOf(Pointer(vtNew)) >= 0 then begin
      result := S_OK
    end else begin
      PostLogRecordAddMsgNow(70727, vtCanonical, vtNew, -1, 'Недопустимый тип данных (OPC_E_BADTYPE)', llErrors);
      result := OPC_E_BADTYPE;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70726, e.HelpContext, vtCanonical, vtNew, e.Message, llErrors);
      result := 0;
    end;
  end;
end;

{$if defined (CHECK_DONGLE) }
// Проверка выполнения лицензионных ограничений
  // result:
  //    S_Ok - Проверка пройдена
  //    S_FALSE - Проверка НЕ пройдена
  //    E_ - Ошибка выполнения проверки
function TVpNetDAServerCore.ValidateLicense : HRESULT;
var
  DBDevCount : Integer;
  wDongleDevCount : WORD;
  res : HRESULT;
begin
  try
    // Значение FLicState не устарело
    if (now - FLicLastChackedTime) < 60/86400 then begin
      result := FLicState;
      exit;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70728, e.HelpContext, -1, -1, e.Message);
      result := 0;
    end;
  end;

  try
    try
      // Если ключ в ненормальном состоянии, считаем, что проверка не пройдена
      if not Dongle.Valid then begin
        FLicState := S_FALSE;
        PostLogRecordAddMsgNow(70729, -1, -1, -1, '');
        exit;
      end;

      // Получение количества приборов
      try
        DBDevCount := RDM.GetOneCell('select count(*) from VDA_DEVICES');
      except on e : Exception do begin
          PostLogRecordAddMsgNow(70730, e.HelpContext, -1, -1, e.Message);
          FLicState := E_FAIL;
          exit;
        end;
      end;

      // Получение максимального числа приборов согласно лицензии
      try
        res := Dongle.ReadWord(sam_vnDADeviceMaxNumber, wDongleDevCount);
        if res <> nse_OK then begin
          FLicState := E_FAIL;
          exit;
        end;
      except on e : Exception do begin
          PostLogRecordAddMsgNow(70731, e.HelpContext, -1, -1, e.Message);
          FLicState := E_FAIL;
          exit;
        end;
      end;

      if DBDevCount > wDongleDevCount then begin
        PostLogRecordAddMsgNow(70732, -1, -1, -1, '');
        FLicState := S_FALSE;
        exit;
      end;

      FLicState := S_OK;
    finally
      FLicLastChackedTime := now; // сброс счетчика времени с момента проверки лицензии
      result := FLicState;
      PostMessage(Application.MainForm.Handle, WM_DA_LICENSE_STATUS, 0, FLicState);
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70728, e.HelpContext, -1, -1, e.Message);
      FLicState := E_UNEXPECTED;
    end;
  end;
end;
{$ifend}


end.
