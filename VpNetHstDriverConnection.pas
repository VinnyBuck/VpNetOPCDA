unit VpNetHstDriverConnection;

{$I 'VpNetDADebugDefs.pas'}

interface

uses Windows, Classes, SysUtils, Forms, Messages, ActiveX, DB, Math, Variants,
  OPCDA, OPCerror, VpNetHst_TLB, VpNetDefs, VpNetDADefs, VpNetClasses, VpNetDAClasses,
  VpNetUtils, VpNetModbus, VpNetDADebug;

type
// Класс, содержащий серверное описание соединения с драйвером хост-сервера
TVpNetHstDriverConnection = class // su01
private
  FCS : TRTLCriticalSection; // Критическая секция
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
  DATransactionItemList : TVpNetDATransactionItemList; // Очередь транзакций
  Hst_TID : DWORD; // Текущая транзакция Hst-сервера, инициированная данным соединением
// 16.10.2009
  Hst_Transaction_Send_Time_MS : TDateTime;
  HstDriverMaxAnswerTimeMS : Integer;
///16.10.2009
//  {8.02.2009}
//  Hst_Transaction_Exists : Boolean; // Признак наличия транзакции ност-сервера
//  {/8.02.2009}
  Hst_ProtocolId : Integer; // Протокол транзакции Hst-сервера
  Hst_OutputData : TByteBuffer; // Выходные данные (запрос) транзакции Hst-сервера
  Hst_InputData : TByteBuffer; // Входные (ответные) данные транзакции Hst-сервера
  Hst_SupposedInputDataSize : DWORD; // Ожидаемый размер ответа
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
    PostLogRecordAddMsgNow(70917, -1, -1, -1, 'HstDriver вызвал Callback-функцию OnPropValueChanged()', llDebug);
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
    PostLogRecordAddMsgNow(70661, TID, -1, -1, 'HstDriver вызвал Callback-функцию OnRecieve()', llDebug);
// 02.04.2010
    if not VarIsArray(Data) then begin
      PostLogRecordAddMsgNow(70411, -1, -1, -1, '');
    end;
///02.04.2010
    // Выделяем память для полученного ответного пакета данных
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
      // Посылаем сообщение о том, что транзакция закончена, и передаем с ним саму транзакцию
  //    PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_RECIEVE, Integer(HIGH(DWORD)), Integer(pAnswerData));
      PostLogRecordAddMsgNow(70848, Integer(pAnswerData), Integer(pAnswerData^.HstAnswerData), Integer(pAnswerData.HstAnswerDataSize), '', llDebug);
      PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_RECIEVE, TID, Integer(pAnswerData));
    end else begin
      // Очищаем память и посылаем сообшение о том, что в Hst-транзакция завершилась с ошибкой E_FAIL
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
    PostLogRecordAddMsgNow(70916, TID, ERROR_CODE, -1, 'HstDriver вызвал Callback-функцию OnError()', llDebug);
    // Выделяем память для данных ошибочного ответа
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
    PostLogRecordAddMsgNow(70924, TID, -1, -1, 'HstDriver вызвал Callback-функцию OnStartTransaction()', llDebug);
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
    // Инициализация критической секции
    InitializeCriticalSection(FCS);

    // Создание очереди транзакций
    DATransactionItemList := TVpNetDATransactionItemList.Create;

    // Протокол транзакции неизвестен
    Hst_ProtocolId := 0;

    // Создание выходного (запросного) буфера данных для транзакции Hst-сервера
    Hst_OutputData := TByteBuffer.Create;
    // Создание входного (ответного) буфера данных для транзакции Hst-сервера
    Hst_InputData := TByteBuffer.Create;

    // Ожидаемый размер ответа пока неизвестен
    Hst_SupposedInputDataSize := 0;

    // Текущая транзакция не определена так как ни одна транзакция еще не запущена
  //  {8.02.2009}
    Hst_TID := 0;
  //  Hst_Transaction_Exists := false;
  //  {/8.02.2009}
  // 16.10.2009
    Hst_Transaction_Send_Time_MS := 0;
  ///16.10.2009

    // Сохранение идентификатора коммуникационного драйвера
    DriverId := aDriverId;
    // Создание и инициализация драйвера
    Driver := TVpNetHstCommDriver.Create(Application);
    // Назначение обработчиков событий
    Driver.OnPropValueChanged := HstCommDriverPropValueChanged;
    Driver.OnRecieve := HstCommDriverRecieve;
    Driver.OnError := HstCommDriverError;
    Driver.OnStartTransaction := HstCommDriverStartTransaction;
    // Инициализация
    Driver.RemoteMachineName := sRemoteMachineName;
  //Driver.DefaultInterface._AddRef;

  ///////////
    Driver.SetCommDriverId(aDriverId);
  ////////
    // Cоединение
    Driver.Connect;
    vPropId := 'MaxAnswerTimeMS';
    Driver.GetPropValue('DriverMaxAnswerTimeMS', vPropValue);
    if not VarIsNull(vPropValue) then begin
      try
        HstDriverMaxAnswerTimeMS := vPropValue;
      except on e : Exception do
        begin
          HstDriverMaxAnswerTimeMS := 15000; // 15 сек
          PostLogRecordAddMsgNow(70390, e.HelpContext, -1, -1, e.Message);
        end;
      end;
    end else begin
      HstDriverMaxAnswerTimeMS := 15000; // 15 сек
    end;

    // Сброс количества ссылок
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
    // Устанавливаем состояние соединения "Удаление"
    State := vncsDestroing;

    if assigned(DATransactionItemList) then begin
      // Изначально принимаем ненулевое количество незаконченных DA-транзакций
      TrCount := 1;
      // Если есть активные транзакции, отправляем их обратно с пометкой об ошибке
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
        //todo: Доделать отсылку
  //      DATransactionItem := DATransactionItemList[0];
  //      if Assigned(DATransactionItem.InputData) then
  //        DATransactionItem.InputData.Size := 0; // Ответных данных нет
  //      if Assigned(DATransactionItem.evtProcessed) then
  //        DATransactionItem.evtProcessed.SetEvent; // Устанавливаем событие завершения обработки транзакции
  //      PostThreadMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, 0, E_ABORT);
      DATransactionItemList.Free;
    end;
    Hst_InputData.Free;
    Hst_OutputData.Free;

    // Удаление драйвера и коммуникационного потока соединения
  //  Driver.Close;
    Driver.Disconnect;
    Driver.Free;

    // Удаляем критическую секцию
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
    // Пока есть активные транзакции, ждем их завершения
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

  // Удаление драйвера и коммуникационного потока соединения
//  Driver.Close;
  Driver.Disconnect;
  Driver.Free;

  // Удаляем критическую секцию
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

      // Принимаем список транзакций, помечаем их для обработки
      // и вносим в список транзакций соединения
      NewTrIndex := 0;
      while NewTrIndex < trList.Count do try
        // Выделяем добавляемую транзакцию
        try
          NewTr := trList[NewTrIndex];
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70401, e.HelpContext, NewTrIndex, -1, e.Message);
            continue;
          end;
        end;

        // Помечаем ее для обработки
        NewTr.DA_State := vndtsWaitingForProcessing;
        // Добавляем в список транзакций
        // Для этого проходим по списку существующих транзакций,
        // и находим место новой транзакции по Максимальному моменту ответа

        if not assigned(DATransactionItemList) then begin
          PostLogRecordAddMsgNow(70402, Integer(DATransactionItemList), -1, -1, '');
          continue;
        end;

        try
          ExistTrIndex := 0;
          while ExistTrIndex < DATransactionItemList.Count do begin
            // Поучаем разницу между максимальным моментом ответа новой транзакции
            // и очередной существующей транзакции
// 01.04.20010
//            DTimeMS := FileTimeMinusFileTime(NewTr.DA_MaxResponseMoment, DATransactionItemList[ExistTrIndex].DA_MaxResponseMoment) div 10000;
            // Получение очередного элемента из списка соединеия

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
            // Если у новой транзакции этот момент раньше, прекращаем поиск
            if DTimeMS < 0 then break;
            // или переходим к проверке следующей существующей транзакции
            ExistTrIndex := Succ(ExistTrIndex);
          end;
        except on e : Exception do begin
            PostLogRecordAddMsgNow(70402, e.HelpContext, NewTrIndex, -1, e.Message);
            continue;
          end;
        end;


        // вставляем новую транзакцию в найденную позицию
        DATransactionItemList.Insert(ExistTrIndex, NewTr);
        PostLogRecordAddMsgNow(70311, Integer(ServerCore.State), -1, ExistTrIndex, 'Ok. Insert transaction to connection: '+NewTr.DA_ItemId, llDebug);

        // переходим к следующей транзакции
      finally
        NewTrIndex := Succ(NewTrIndex);
      end;

      // Отправка команды на отправку очередного запроса на Хост-сервер
      // (это нужно для отправки первого запроса на Хост-сервер,
      // Последующие запросы инициируются Callback-функциями)
      PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_SEND,
        DriverId, // Идентификатор драйвера Hst-сервера
        0 // Не используется
      );
    finally
      Unlock;
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70383, e.HelpContext, -1, -1, e.Message);
  end;
end;


// Алгоритм работы:
// Определяет, можно ли выполнить обе DA-транзакции одним Hst-запросом
function TVpNetHstDriverConnection.AreTransactionItemsCompartible(tr1, tr2 : TVpNetDATransactionItem) : boolean;
begin
  try
    // Если ...
    if (tr1.DA_Type = tr2.DA_Type) and // транзакции одного типа
       (tr1.Hst_ID = tr2.Hst_ID) and // равны идентификаторы Hst-серверов
       (tr1.Hst_DriverID = tr2.Hst_DriverID) and // равны идентификаторы Hst-драйверов
       (tr1.Hst_ProtocolId = tr2.Hst_ProtocolId) and // равны идентификаторы коммуникационных протоколов
       (tr1.Hst_DeviceId = tr2.Hst_DeviceId) and // равны идентификаторы опрашиваемых устройств
       (tr1.Hst_FuncNumber = tr2.Hst_FuncNumber) // совпадают номера функций протокола
    then
      result := true
    else
      result := false;
  except on e : Exception do
    PostLogRecordAddMsgNow(70382, e.HelpContext, -1, -1, e.Message);
  end;
end;

// Алгоритм работы:
// b. Начальные действия
// 1. Формируем список DA-транзакций, для запроса на Hst-сервер
// 2. Формируем общий Hst-запрос для списка DA-транзакций
// 3. Посылаем запрос на Hst-сервер
// e. Конечные действия
procedure TVpNetHstDriverConnection.Send;
var
  v : OleVariant;
  vArr : OleVariant;
  i : Integer;
  FirstTr : TVpNetDATransactionItem; // Транзакция
  tr : TVpNetDATransactionItem; // Текущая транзакция
  // Список транзакций DA-сервера, данные которых будут запрашиваться
  // текущей (выплоняемой) транзакцией Hst-сервера
//  trForRequest : TVpNetDATransactionItemList;
  trIndex : Integer;
  w : WORD;
  hr : HRESULT;

  // Оптимизация
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
      // Если в данный момент выполняетется запрос к Hst-серверу, выходим
      if not(Hst_TID = 0) then begin
        PostLogRecordAddMsgNow(70319, Integer(ServerCore.State), -1, -1, '', llDebug);
        exit;
      end;

      // Если в списке нет DA-транзакций, выходим
      if DATransactionItemList.Count = 0 then begin
        PostLogRecordAddMsgNow(70322, Integer(ServerCore.State), -1, -1, 'Ok. Обработка hst-транзакций завершена', llDebug);
        exit;
      end;

(*
      {1}
      // Помечаем к обработке первую в очереди DA-транзакцию,
      // т.е. DA-транзакцию с минимальным значанием максимального времени ответа.
      // Она обязательно входит в список обрабатываемых DA-транзакций, так как
      // мы обязаны прежде всего выполнять самые "гарячие" DA-транзакции
      FirstTr := DATransactionItemList[0];
      FirstTr.DA_State := vndtsWaitingForResponse;
*)
      // Ищем самый "горячий" элемент DA-транзакции, ожидающий выполнения.
      // Пока просто ищем элемент, ожидающий выполнения, с минимальным значанием
      // максимального времени ответа (т.е. самую актуальную невыполненную транзакцию)
      trIndex := 0;
      FirstTr := nil;
      while trIndex < DATransactionItemList.Count do begin
        // Идем по нарастанию
        if DATransactionItemList[trIndex].DA_State = vndtsWaitingForProcessing then begin
          FirstTr := DATransactionItemList[trIndex];
          FirstTr.DA_State := vndtsWaitingForResponse;
// 7.04.2010
          // фиксипуем время последней попытки посылки данных
          Hst_Transaction_Send_Time_MS := now;
///7.04.2010
          break;
        end;
        trIndex := Succ(trIndex);
      end;

      // Если не нашли подходящего элемента - выходим
      if not(Assigned(FirstTr)) then begin
        PostLogRecordAddMsgNow(70323, Integer(ServerCore.State), -1, -1, '');
        exit;
      end;

      // Если идет обращение к параметру драйвера, выполняем его
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
            // В любом случае в конце обработки обращения к свойству драйвера
            // сбрасывем идентификатор Hst-транзакции, сигнализируя о том, что
            // с этого момента обрабатывемых Hst-транзакций нет
            //Hst_TID := 0;
            bb.free;
            PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_RECIEVE, TID, Integer(Pointer(pAnswerData)));
          end;
        end;
        exit;
      end;

      // Проверяем права доступа
      // Если транзакция читающая, и нет прав на чтение, ...
      if (FirstTr.DA_Type = vndttRead) and ((FirstTr.HST_AccessRights and OPC_READABLE) = 0) then begin
        PostLogRecordAddMsgNow(70326, Integer(ServerCore.State), -1, -1, '');
        // ... имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
        Hst_TID := HIGH(DWORD);
        PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(OPC_E_BADRIGHTS));
        exit;
      end;

      // Если транзакция пишущая, ...
      if (FirstTr.DA_Type = vndttWrite) then begin
        // ... и нет прав на запись, ...
        if ((FirstTr.HST_AccessRights and OPC_WRITEABLE) = 0) then begin
          PostLogRecordAddMsgNow(70328, Integer(ServerCore.State), -1, -1, '');
          // ... имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
          Hst_TID := HIGH(DWORD);
          PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(OPC_E_BADRIGHTS));
          exit;
        end;

        // ... и нужно записывать Quality, а записать его в прибор невозможно,...
        if (FirstTr.VQT.bQualitySpecified) and ((FirstTr.Hst_AccessRights and OPC_QUALITY_WRITABLE) = 0) then begin
          PostLogRecordAddMsgNow(70329, Integer(ServerCore.State), -1, -1, '');
          // ... имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
          Hst_TID := HIGH(DWORD);
          PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(OPC_E_BADRIGHTS));
          exit;
        end;

        // ... и нужно записывать Timestamp, а записать его в прибор невозможно,...
        if (FirstTr.VQT.bTimeStampSpecified) and ((FirstTr.Hst_AccessRights and OPC_TIMESTAMP_WRITABLE) = 0) then begin
          PostLogRecordAddMsgNow(70330, Integer(ServerCore.State), -1, -1, '');
          // ... имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
          Hst_TID := HIGH(DWORD);
          PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(OPC_E_BADRIGHTS));
          exit;
        end;
      end;

{/18.07.2006}

      // Ветвление по протоколу
      case FirstTr.HST_ProtocolId of
        VPModbus : begin // Modbus
          // Получение признака оптимизации запросов Modbus
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

          // Получение максимльной длины запросов при оптимизации запросов Modbus
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
            fnReadHoldingRegisters, // Функция 3: чтение регистров храниния
            fnReadInputRegisters: begin // Функция 4: чтение регистров ввода
              // Начальный регистр
              MinReg := FirstTr.Hst_DataAddress;
              // Кол-во регистров
              RegCount := ((FirstTr.HST_DataSizeInBytes + 1) div 2);
              // Конечный регистр
              MaxReg := MinReg + RegCount - 1;
              // Общий диапазон
              TotalMinReg := MinReg;
              TotalMaxReg := MaxReg;
              TotalRegCount := RegCount;
              if bModbusOptEnabled then begin
                // Алгоритм оптимизации запросов по протоколу Modbus функциями 3 и 4:
                // Проходим по списку всех активных DA-транзакций соединения, и выбираем
                // DA-транзакции, которые можно выполнить совместно с первой ("горячей")
  {18.07.2006}
                trIndex := trIndex + 1;
                // Продолжаем проход по списку элементов
                while trIndex < DATransactionItemList.Count do begin
                  // Очередная транзакция
                  tr := DATransactionItemList[trIndex];
                  // Если DA-транзакции "совместимы"
                  if AreTransactionItemsCompartible(tr, FirstTr) then begin
                    // Начальный регистр
                    MinReg := tr.Hst_DataAddress;
                    // Кол-во регистров
                    RegCount := ((tr.HST_DataSizeInBytes + 1) div 2) and $FFFF;
                    // Конечный регистр
                    MaxReg := MinReg + RegCount - 1;
                    // Присоединяем снизу
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

              Hst_OutputData.Size := 6; // Размер пакета (без CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // Адрес устройства в сети Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // Номер функции = 3,4
              Hst_OutputData[2] := HIBYTE(TotalMinReg);
              Hst_OutputData[3] := LOBYTE(TotalMinReg);
              // Кол-во регистров
              Hst_OutputData[4] := HIBYTE(TotalRegCount);
              Hst_OutputData[5] := LOBYTE(TotalRegCount);

              // Подсчет контрольной суммы (CRC16)
              w := CRC16_2(Hst_OutputData);
              // Добавление контрольной суммы к пакету
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);
              //Вычисляем ожидаемый размер ответного пакета
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // Проверяем результат вычисления размера ответного пакета
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70331, Integer(ServerCore.State), -1, -1, 'Не удалось вычислить предпологаемый размер ответного пакета Modbus');
                exit;
              end;
            end;

            fnForceSingleCoil: begin
              Hst_OutputData.Size := 6; // Размер пакета (без CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // Адрес устройства в сети Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // Номер функции = 5
              Hst_OutputData[2] := HIBYTE(FirstTr.Hst_DataAddress); // Старший байт адреса ячейки
              Hst_OutputData[3] := LOBYTE(FirstTr.Hst_DataAddress); // Млабший байт адреса ячейки

              // Преобразование данных в массив
              qBuf := TByteBuffer.Create;
              try
                hr := EncodeDataByFormat(FirstTr.VQT.vDataValue, FirstTr.Hst_DataFormatId, qBuf);
                // Проверяем результат получения буфера данных
                if (hr <> S_OK) and (hr <> S_FALSE) then begin
                  // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                  Hst_TID := HIGH(DWORD);
//                  {8.02.2009}
//                  Hst_Transaction_Exists := true;
//                  {/8.02.2009}
                  PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                  //todo: Ввести пользовательский код ошибки: "Ошибка преобразования данных"
                  exit;
                end;
                // Проверяем количество байт данных
                if not (qBuf.Size = 2) then begin
                  // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                  Hst_TID := HIGH(DWORD);
//                  {8.02.2009}
//                  Hst_Transaction_Exists := true;
//                  {/8.02.2009}
                  PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                  //todo: Ввести пользовательский код ошибки: "Ошибка преобразования данных"
                  exit;
                end;
                // Добавляем полученный буфер с данными в выходной пакет
                Hst_OutputData[4] := qBuf[0];
                Hst_OutputData[5] := qBuf[1];
              finally
                qBuf.Free;
              end;

              // Подсчет контрольной суммы (CRC16)
              w := CRC16_2(Hst_OutputData);
              // Добавление контрольной суммы к пакету
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);

              //Вычисляем ожидаемый размер ответного пакета
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // Проверяем результат вычисления размера ответного пакета
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70332, Integer(ServerCore.State), -1, -1, 'Не удалось вычислить предпологаемый размер ответного пакета Modbus');
                exit;
              end;
            end;

            fnPresetSingleRegister: begin
              Hst_OutputData.Size := 6; // Размер пакета (без CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // Адрес устройства в сети Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // Номер функции = 6
              Hst_OutputData[2] := HIBYTE(FirstTr.Hst_DataAddress);
              Hst_OutputData[3] := LOBYTE(FirstTr.Hst_DataAddress);

              // Преобразование данных в массив
              qBuf := TByteBuffer.Create;
              try
                hr := EncodeDataByFormat(FirstTr.VQT.vDataValue, FirstTr.Hst_DataFormatId, qBuf);
                // Проверяем результат получения буфера данных
                if (hr <> S_OK) and (hr <> S_FALSE) then begin
                  // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                  Hst_TID := HIGH(DWORD);
//                  {8.02.2009}
//                  Hst_Transaction_Exists := true;
//                  {/8.02.2009}
                  PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                  PostLogRecordAddMsgNow(70333, Integer(ServerCore.State), -1, -1, 'Ошибка преобразования данных');
                  exit;
                end;
                // Проверяем количество байт данных
                if not (qBuf.Size = 2) then begin
                  // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                  Hst_TID := HIGH(DWORD);
//                  {8.02.2009}
//                  Hst_Transaction_Exists := true;
//                  {/8.02.2009}
                  PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                  PostLogRecordAddMsgNow(70334, Integer(ServerCore.State), -1, -1, 'Ошибка преобразования данных');
                  exit;
                end;
                // Добавляем полученный буфер с данными в выходной пакет
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

              // Подсчет контрольной суммы (CRC16)
              w := CRC16_2(Hst_OutputData);
              // Добавление контрольной суммы к пакету
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);

              //Вычисляем ожидаемый размер ответного пакета
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // Проверяем результат вычисления размера ответного пакета
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70335, Integer(ServerCore.State), -1, -1, 'Не удалось вычислить предпологаемый размер ответного пакета Modbus');
                exit;
              end;
            end;

            fnReadExceptionStatus: begin
              Hst_OutputData.Size := 2; // Размер пакета (без CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // Адрес устройства в сети Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // Номер функции = 16
              // Подсчет контрольной суммы (CRC16)
              w := CRC16_2(Hst_OutputData);
              // Добавление контрольной суммы к пакету
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);
              //Вычисляем ожидаемый размер ответного пакета
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // Проверяем результат вычисления размера ответного пакета
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70336, Integer(ServerCore.State), -1, -1, 'Не удалось вычислить предпологаемый размер ответного пакета Modbus');
                exit;
              end;
            end;
{15.05.2007}
{
            fnPresetMultipleRegisters: begin
              Hst_OutputData.Size := 7; // Размер пакета (без CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // Адрес устройства в сети Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // Номер функции = 16
              Hst_OutputData[2] := HIBYTE(FirstTr.Hst_DataAddress);
              Hst_OutputData[3] := LOBYTE(FirstTr.Hst_DataAddress);
              // Количество регистров в поле данных
              TotalRegCount := (FirstTr.Hst_DataSizeInBytes + 1) div 2;
              Hst_OutputData[4] := HIBYTE(TotalRegCount);
              Hst_OutputData[5] := LOBYTE(TotalRegCount);
              Hst_OutputData[6] := (TotalRegCount * 2) and $ff; // Переполнение

              // Преобразование данных в массив
              qBuf := TByteBuffer.Create;
              try
                hr := EncodeDataByFormat(FirstTr.VQT.vDataValue, FirstTr.Hst_DataFormatId, qBuf);
                // Проверяем результат получения буфера данных
                if (hr <> S_OK) and (hr <> S_FALSE) then begin
                  // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                  Hst_TID := HIGH(DWORD);
//                  //8.02.2009
//                  Hst_Transaction_Exists := true;
//                  ///8.02.2009
                  PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                  //todo: Ввести пользовательский код ошибки: "Ошибка преобразования данных"
                  exit;
                end;
                // Добавляем полученный буфер с данными в выходной пакет
                Hst_OutputData.Size :=  Hst_OutputData.Size + qBuf.Size;
                qIndex := 0;
                while qIndex < qBuf.Size do begin
                  Hst_OutputData.Bytes[Hst_OutputData.Size - qBuf.Size + qIndex] := qBuf.Bytes[qIndex];
                  qIndex := Succ(qIndex);
                end;


              finally
                qBuf.Free;
              end;
              // Подсчет контрольной суммы (CRC16)
              w := CRC16_2(Hst_OutputData);
              // Добавление контрольной суммы к пакету
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);

              //Вычисляем ожидаемый размер ответного пакета
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // Проверяем результат вычисления размера ответного пакета
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                Hst_TID := HIGH(DWORD);
//                //8.02.2009
//                Hst_Transaction_Exists := true;
//                ///8.02.2009
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                //todo: Ввести пользовательский код ошибки: "Не удалось вычислить предпологаемый размер ответного пакета Modbus"
                exit;
              end;
            end;
}
            fnPresetMultipleRegisters: begin
              Hst_OutputData.Size := 7; // Размер пакета (без CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // Адрес устройства в сети Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // Номер функции = 16

              // Начальный регистр
              MinReg := FirstTr.Hst_DataAddress;
              // Кол-во регистров
              RegCount := ((FirstTr.HST_DataSizeInBytes + 1) div 2);
              // Конечный регистр
              MaxReg := MinReg + RegCount - 1;
              // Общий диапазон
              TotalMinReg := MinReg;
              TotalMaxReg := MaxReg;

              trIndex := trIndex + 1;
                // Продолжаем проход по списку элементов
{/18.07.2006}
              while trIndex < DATransactionItemList.Count do begin
                tr := DATransactionItemList[trIndex];
                // Если DA-транзакции "совместимы"
                if AreTransactionItemsCompartible(tr, FirstTr) then begin
                  // Начальный регистр
                  MinReg := tr.Hst_DataAddress;
                  // Кол-во регистров
                  RegCount := ((tr.HST_DataSizeInBytes + 1) div 2) and $FFFF;
                  // Конечный регистр
                  MaxReg := MinReg + RegCount - 1;
                  // Присоединяем снизу
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
              Hst_OutputData[6] := (TotalRegCount * 2) and $ff; // Переполнение

              // Формирование данных
              qBuf := TByteBuffer.Create;
              qBuf2 := TByteBuffer.Create;
              try
                qBuf.Size := TotalRegCount * 2;
                trIndex := 0;
                // Проходим по всем транзакциям
                while trIndex < DATransactionItemList.Count do begin
                  tr := DATransactionItemList[trIndex];

                  // Если транзакция помечена к выполнению, переносим ее данные в
                  // в поле выходных данных пакета
                  if tr.DA_State = vndtsWaitingForResponse then begin

                    // Получаем выходные данные транзакции в виде массива байтов
                    hr := EncodeDataByFormat(tr.VQT.vDataValue, tr.Hst_DataFormatId, qBuf2);
                    if (hr <> S_OK) and (hr <> S_FALSE) then begin
                      // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                      Hst_TID := HIGH(DWORD);
//                      {8.02.2009}
//                      Hst_Transaction_Exists := true;
//                      {/8.02.2009}
                      PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                      PostLogRecordAddMsgNow(70337, Integer(ServerCore.State), -1, -1, 'Ошибка преобразования данных');
                    end;

                    // помещаем данные транзакции в поле выходных данных пакета
                    qIndex := 0;
                    while qIndex < qBuf2.Size do begin
                      qBuf.Bytes[(tr.Hst_DataAddress - TotalMinReg)*2 + qIndex] := qBuf2[qIndex];
                      qIndex := Succ(qIndex);
                    end;
                  end;

                  trIndex := succ(trIndex);
                end;

                // Добавляем полученный буфер с данными в выходной пакет
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

              // Подсчет контрольной суммы (CRC16)
              w := CRC16_2(Hst_OutputData);
              // Добавление контрольной суммы к пакету
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);

              //Вычисляем ожидаемый размер ответного пакета
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // Проверяем результат вычисления размера ответного пакета
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70338, Integer(ServerCore.State), -1, -1, 'Не удалось вычислить предпологаемый размер ответного пакета Modbus');
                exit;
              end;

            end;
{/15.05.2007}
            fnReportSlaveID: begin
              Hst_OutputData.Size := 2; // Размер пакета (без CRC16)
              Hst_OutputData[0] := FirstTr.Hst_DeviceAddress; // Адрес устройства в сети Modbus
              Hst_OutputData[1] := FirstTr.Hst_FuncNumber; // Номер функции = 16
              // Подсчет контрольной суммы (CRC16)
              w := CRC16_2(Hst_OutputData);
              // Добавление контрольной суммы к пакету
              Hst_OutputData.Size := Hst_OutputData.Size + 2;
              Hst_OutputData[Hst_OutputData.Size - 2] := LOBYTE(w);
              Hst_OutputData[Hst_OutputData.Size - 1] := HIBYTE(w);
              //Вычисляем ожидаемый размер ответного пакета
              hr := VpNetModbusSupposedAnswerPaketSize(Hst_OutputData, Hst_SupposedInputDataSize);
              // Проверяем результат вычисления размера ответного пакета
              if (hr <> S_OK) and (hr <> S_FALSE) then begin
                // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
                Hst_TID := HIGH(DWORD);
//                {8.02.2009}
//                Hst_Transaction_Exists := true;
//                {/8.02.2009}
                PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
                PostLogRecordAddMsgNow(70339, Integer(ServerCore.State), -1, -1, 'Не удалось вычислить предпологаемый размер ответного пакета Modbus');
                exit;
              end;
            end else begin
              // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
              Hst_TID := HIGH(DWORD);
//              {8.02.2009}
//              Hst_Transaction_Exists := true;
//              {/8.02.2009}
              PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
              PostLogRecordAddMsgNow(70340, Integer(ServerCore.State), -1, -1, 'Недопустимый номер функции Modbus');
              exit;
            end;
          end;
        end;
        VPHstDriverInterface: begin
          // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с нормальным результатом
//          Hst_TID := HIGH(DWORD);
          PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_RECIEVE, Integer(HIGH(DWORD)), Integer(S_OK));
          PostLogRecordAddMsgNow(70341, Integer(ServerCore.State), -1, -1, 'Протокол не поддерживается');
        end;
        else begin
          // Имитируем выполнение Hst-транзакции с номером HIGH(DWORD) с ошибочным результатом
          Hst_TID := HIGH(DWORD);
//          {8.02.2009}
//          Hst_Transaction_Exists := true;
//          {/8.02.2009}
          PostMessage(Application.MainForm.Handle, WM_DA_HST_DRIVER_ERROR, Integer(HIGH(DWORD)), Integer(E_INVALIDARG));
          PostLogRecordAddMsgNow(70342, Integer(ServerCore.State), -1, -1, 'Протокол не поддерживается');
          exit;
        end;
      end;

      // Формируем параметры запроса к Hst-серверу
      v := Hst_SupposedInputDataSize;
      vArr := Hst_OutputData.AsVarArray;

      // Выполняем запрос к HST-серверу
      PostLogRecordAddMsgNow(70343, Integer(ServerCore.State), -1, -1, 'Ok. Запрос к HST-серверу. Начало', llDebug);

      slDeviceParamNames := TStringList.create;
      try
        ServerCore.RDM.NodeParams.GetNodeParamNames(FirstTr.Hst_DeviceId, slDeviceParamNames);
        Index := 0;
        while Index < slDeviceParamNames.count do begin
          NodeParamValue := ServerCore.RDM.NodeParams.Find(FirstTr.Hst_DeviceId, slDeviceParamNames[Index]);
          if Assigned(NodeParamValue) and NodeParamValue.ParamValueAssigned and NodeParamValue.ForSendToHst then begin
            vPropId := slDeviceParamNames[Index];
{
            // Сохранение исходного значения параметра
            hr := Driver.GetPropValue(vPropId, vPropValue);
            if hr = S_OK then begin
              NodeParamValue.OriginParamValue := vPropValue;
            end else begin
              NodeParamValue.OriginParamValue := EmptyStr;
            end;
}
            // Установка значения для данного устройства
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
            PostLogRecordAddMsgNow(70349, -1, -1, -1, 'Ok. Перед отправкой данных драйверу', llDebug);
            Driver.Send(vArr, v, i);
            PostLogRecordAddMsgNow(70350, -1, -1, -1, 'Ok. После отправкой данных драйверу', llDebug);
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

            // Установка исходного значения параметра устройства
            VPropValue := NodeParamValue.OriginParamValue;
            hr := Driver.SetPropValue(vPropId, VPropValue);
          end;
          Index := Succ(Index);
        end;
        }
      finally
        slDeviceParamNames.free;
      end;

      PostLogRecordAddMsgNow(70348, 6, -1, -1, 'Ok. Запрос к HST-серверу. Конец', llDebug);

      // Запоминаем идентификатор начатой Hst-транзакции
      Hst_TID := DWORD(i);

// 7.04.2010
//// 16.10.2009
//      // фиксипуем время последней попытки посылки данных
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
  DATransaction : TVpNetDATransaction; // DA-транзакция
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
  AttachedDATransactionList : TVpNetDATransactionList; // Список затронутых DA-транзакций
  TrIndex : Integer; // Номер DA-транзакции в списке
  gr : TVpNetOPCGroup; // гуппа
  grThread : TVpNetOPCGroupControlThread;
  ThereAreProcessedItems : boolean;
begin
  try
    PostLogRecordAddMsgNow(70850, -1, -1, -1, 'Ok. t', llDebug);

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70351, Integer(ServerCore.State), -1, -1, '');
      exit;
    end;

    Lock;
    try
      AttachedDATransactionList := TVpNetDATransactionList.Create;

      // Сохранение входных (ответных) данных в свойстве соединения
      Hst_InputData.Clear;

      // Переносим данные из входного параметра во входной буфер
      if Assigned(aHstAnswerData) then begin
        if Assigned(aHstAnswerData^.HstAnswerData) then begin
          Hst_InputData.Size := aHstAnswerData.HstAnswerDataSize;
          move(aHstAnswerData.HstAnswerData^, Hst_InputData.Data^, aHstAnswerData.HstAnswerDataSize);
          // Очищаем поле данных пришедшей структуры
          FreeMem(aHstAnswerData^.HstAnswerData);
        end else begin
          PostLogRecordAddMsgNow(70353, -1, -1, -1, '', llErrors);
        end;
        // Удаляем пришедшую структуру
        FreeMem(aHstAnswerData);
      end else begin
        PostLogRecordAddMsgNow(70352, -1, -1, -1, '');
      end;

      //-------------------------------------------------------
      //Обработка
      //-------------------------------------------------------

      // Если текущая транзакция Hst-сервера имеет протокол Modbus,
      // проверяем правильность контрольной суммы ответного пакета
      if Hst_ProtocolId = VPModbus then begin
        // Проверка правильности контрольной суммы ответного пакета
        ModbusResponseCRCCorrect := CheckPacketCRC(Hst_InputData);
      end;

      // Проходим по списку элементов DA-транзакций соединения
      DATransactionItemIndex := 0;
      while DATransactionItemIndex < DATransactionItemList.Count do begin

        // Проверяем, ожидает ли этот элемент DA-транзакции ответа в данной
        // Hst-транзакции
        if DATransactionItemList[DATransactionItemIndex].DA_State = vndtsWaitingForResponse then begin
          // если ожидает, начинаем процесс получения ответа для данного
          // элемента DA-транзакции. Выбираем элемент DA-транзакции
          DATransactionItem := DATransactionItemList[DATransactionItemIndex];
        end else begin
          // если не ожидает, переходим к следующему элементу DA-транзакции
          // соединения (приращаем номер элемента DA-транзакции)
          DATransactionItemIndex := Succ(DATransactionItemIndex);
          // Переходим к следующему элементу DA-транзакции
          continue;
        end;

        // Если это элемент асинхронной транзакции, добавляем в список транзакцию,
        // к которой отностися данный элемент
        if (DATransactionItem.DA_SyncType = vndtstAsync) and
        (AttachedDATransactionList.IndexOf(DATransactionItem.DA_Transaction) = -1) then begin
          AttachedDATransactionList.Add(DATransactionItem.DA_Transaction);
        end;

        // Удаляем завершенный элемент DA-транзакции из списка
        DATransactionItemList.Remove(DATransactionItem);

        try

{21.06.2007}
          // Если элемент DA-транзакции содердит ответ на запрос параметра
          // драйвера hst-сервера, возвращаем параметр и переходим к следующему
          //
          if DATransactionItem.Hst_DeviceId = 0 then begin
//            DATransactionItem.VQT.vDataValue := Hst_InputData.AsString;
            DATransactionItem.SetOk(Hst_InputData.AsString);
            continue;
          end;
{/21.06.2007}

          // Если ожидаемая длина ответного сообщения известна,
          // и длина ответного сообщения не соответствует ожидаемой,
          // помечаем этот элемент транзакции как завершенный ошибочно,
          // и переходим к следующему
          if (Hst_SupposedInputDataSize > 0) and not(DWORD(Hst_InputData.Size) = Hst_SupposedInputDataSize) then begin
            // Устанавливаем ошибку
            DATransactionItem.SetError;
            // Переходим к следующей DA-транзакции
            PostLogRecordAddMsgNow(70354, Hst_SupposedInputDataSize, Hst_InputData.Size, -1, '');
            continue;
          end;

          // Проотокол...
          case DATransactionItem.Hst_ProtocolId of
            VPModbus: begin // Modbus
              // Если контрольная сумм всего ответного пакета неправильная,
              // все DA-транзакции по протоколу Modbus завершаем ошибкой
              if not ModbusResponseCRCCorrect then begin
                DATransactionItem.SetError;
                PostLogRecordAddMsgNow(70355, -1, -1, -1, '');
                continue;
              end;
              case DATransactionItem.HST_FuncNumber of
                fnReadHoldingRegisters, // Функция 3: чтение регистров храниния
                fnReadInputRegisters // Функция 4: чтение регистров ввода
                : begin
                  // Разбираем пришедший пакет для функций 3 и 4 протокола Modbus:
                  // Проверка правильности номера устройства
                  if not(DATransactionItem.Hst_DeviceAddress = Hst_InputData.Bytes[0]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70356, DATransactionItem.Hst_DeviceAddress, Hst_InputData.Bytes[0], -1, '');
                    continue;
                  end;

                  // Проверяем номер функции в ответном пекете
                  if not(DATransactionItem.Hst_FuncNumber = Hst_InputData.Bytes[1]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70357, DATransactionItem.Hst_FuncNumber, Hst_InputData.Bytes[1], -1, '');
                    continue;
                  end;

                  // Получение характеристик запроса
                  ModbusRequestStartReg := (Hst_OutputData.Bytes[2] shl 8) + Hst_OutputData.Bytes[3];
                  ModbusRequestRegCount := (Hst_OutputData.Bytes[4] shl 8) + Hst_OutputData.Bytes[5];

                  // Получение характеристик ответа
                  ModbusResponseByteCount := Hst_InputData.Bytes[2];

                  // Проверка правильности общей длины поля данных ответа
                  if not(ModbusRequestRegCount * 2 = ModbusResponseByteCount) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70358, ModbusRequestRegCount, ModbusResponseByteCount, -1, '');
                    continue;
                  end;
                  // Создание буфера с данными для данной транзакцииж
                  buf := TByteBuffer.Create;
                  try
                    // Размер поля данных округленный до размера регистра вверх
                    buf.Size := ((DATransactionItem.Hst_DataSizeInBytes + 1) div 2) * 2;
                    ByteIndex := 0;
                    while ByteIndex < buf.Size do begin
                      buf[ByteIndex] := Hst_InputData.Bytes[3 + (DATransactionItem.Hst_DataAddress - ModbusRequestStartReg) * 2 + DWORD(ByteIndex)];
                      ByteIndex := Succ(ByteIndex);
                    end;
                    // разбор самих данных и преобразование их в Variant по какой-то схеме
                    hr := DecodeDataByFormat(buf, DATransactionItem.Hst_DataFormatId, v);
                    if hr = S_OK then begin
                    // Нормальное завершение операции
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
                  // Разбираем пришедший пакет для функции 5 протокола Modbus:
                  // В случае успешного выполнения функции ответное сообщение
                  // идентично запросу
                  if not(Hst_OutputData.Size = Hst_InputData.Size) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70360, Hst_OutputData.Size, Hst_InputData.Size, -1, '');
                    continue;
                  end;
                  // Выполняем побайтовое сравнение пакетов
                  ByteIndex := 0;
                  while ByteIndex < Hst_InputData.Size do begin
                    if not (Hst_OutputData.Bytes[ByteIndex] = Hst_InputData.Bytes[ByteIndex]) then begin
                      DATransactionItem.SetError;
                      PostLogRecordAddMsgNow(70361, ByteIndex, Hst_OutputData.Bytes[ByteIndex], Hst_InputData.Bytes[ByteIndex], '');
                      continue;
                    end;
                    ByteIndex := Succ(ByteIndex);
                  end;
                  // Завершение DA-транзакции с S_OK
                  DATransactionItem.Complete(S_OK);
                end;

                fnPresetSingleRegister: begin
                  // Разбираем пришедший пакет для функции 6 протокола Modbus:
                  // В случае успешного выполнения функции ответное сообщение
                  // идентично запросу
                  if not(Hst_OutputData.Size = Hst_InputData.Size) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70362, Hst_OutputData.Size, Hst_InputData.Size, -1, '');
                    continue;
                  end;
                  // Выполняем побайтовое сравнение пакетов
                  ByteIndex := 0;
                  while ByteIndex < Hst_InputData.Size do begin
                    if not (Hst_OutputData.Bytes[ByteIndex] = Hst_InputData.Bytes[ByteIndex]) then begin
                      DATransactionItem.SetError;
                      PostLogRecordAddMsgNow(70363, ByteIndex, Hst_OutputData.Bytes[ByteIndex], Hst_InputData.Bytes[ByteIndex], '');
                      continue;
                    end;
                    ByteIndex := Succ(ByteIndex);
                  end;
                  // Завершение DA-транзакции с S_OK
                  DATransactionItem.Complete(S_OK);
                end;
  {/21.06.2006}
  {23.06.2006}
                fnReadExceptionStatus: begin
                  // Разбираем пришедший пакет для функции 7 протокола Modbus:
                  // Проверка правильности номера устройства
                  if not(DATransactionItem.Hst_DeviceAddress = Hst_InputData.Bytes[0]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70364, DATransactionItem.Hst_DeviceAddress, Hst_InputData.Bytes[0], -1, '');
                    continue;
                  end;

                  // Проверяем номер функции в ответном пекете
                  if not(DATransactionItem.Hst_FuncNumber = Hst_InputData.Bytes[1]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70365, DATransactionItem.Hst_FuncNumber, Hst_InputData.Bytes[1], -1, '');
                    continue;
                  end;

                  // Провепрка контрольной суммы ответного пакета
                  if not CheckPacketCRC(Hst_InputData) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70366, -1, -1, -1, '');
                    continue;
                  end;

                  // Создание буфера с данными для данной транзакцииж
                  buf := TByteBuffer.Create;
                  try
                    // Размер поля данных = 1 байт
                    buf.Size := 1;
                    buf[0] := Hst_InputData.Bytes[2];
                    // разбор самих данных и преобразование их в Variant по какой-то схеме
                    hr := DecodeDataByFormat(buf, DATransactionItem.Hst_DataFormatId, v);
                    if hr = S_OK then begin
                    // Нормальное завершение операции
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
                  // Разбираем пришедший пакет для функции 16 протокола Modbus:
                  // Проверка правильности номера устройства
                  if not(DATransactionItem.Hst_DeviceAddress = Hst_InputData.Bytes[0]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70368, DATransactionItem.Hst_DeviceAddress, Hst_InputData.Bytes[0], -1, '');
                    continue;
                  end;

                  // Проверка соответствия входного и выходного пакетов
                  if not CompareMem(Hst_OutputData.Data, Hst_InputData.Data, 6) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70369, -1, -1, -1, '');
                    continue;
                  end;

                  // Провепрка контрольной суммы ответного пакета
                  if not CheckPacketCRC(Hst_InputData) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70370, -1, -1, -1, '');
                    continue;
                  end;

                  // Завершение DA-транзакции с S_OK
                  DATransactionItem.Complete(S_OK);
  {24.06.2006}
                end;
                fnReportSlaveID: begin
                  // Разбираем пришедший пакет для функции 7 протокола Modbus:
                  // Проверка правильности номера устройства
                  if not(DATransactionItem.Hst_DeviceAddress = Hst_InputData.Bytes[0]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70371, DATransactionItem.Hst_DeviceAddress, Hst_InputData.Bytes[0], -1, '');
                    continue;
                  end;

                  // Проверяем номер функции в ответном пекете
                  if not(DATransactionItem.Hst_FuncNumber = Hst_InputData.Bytes[1]) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70372, DATransactionItem.Hst_FuncNumber, Hst_InputData.Bytes[1], -1, '');
                    continue;
                  end;

                  // Провепрка контрольной суммы ответного пакета
                  if not CheckPacketCRC(Hst_InputData) then begin
                    DATransactionItem.SetError;
                    PostLogRecordAddMsgNow(70373, -1, -1, -1, '');
                    continue;
                  end;

                  // Создание буфера с данными для данной транзакцииж
                  buf := TByteBuffer.Create;
                  try
                    // Размер поля данных неизвестен
                    buf.Size := Hst_InputData.Size - 3 - 2;
                    ByteIndex := 0;
                    while ByteIndex < buf.Size do begin
                      buf[ByteIndex] := Hst_InputData[ByteIndex + 3];
                      ByteIndex := Succ(ByteIndex);
                    end;

                    // разбор самих данных и преобразование их в Variant по какой-то схеме
                    hr := DecodeDataByFormat(buf, DATransactionItem.Hst_DataFormatId, v);
                    if hr = S_OK then begin
                    // Нормальное завершение операции
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
                  // Если использовалась неизвестная функция протокола Modbus, завершаем ее с ошибкой
                  DATransactionItem.SetError;
                  PostLogRecordAddMsgNow(70375, DATransactionItem.HST_FuncNumber, -1, -1, '');
                  continue;
                end;
              end;
            end;
            else begin
              // Если у транзакции неизвестный протокол, завершаем ее с ошибкой
              DATransactionItem.SetError;
              PostLogRecordAddMsgNow(70376, DATransactionItem.Hst_ProtocolId, -1, -1, '');
              // Посылаем сообщение об ошибке обработки DA-транзакции
              //PostMessage(...
              // Переходим к следующей DA-транзакции
              continue;
            end;
          end;
        finally
          // Посылаем сообщения об обработке элементов сулжебному потоку каждой
          // затронутой асинхронной DA-транзакции (или основному потоку)
          // (Если транзакция синхронная, то ее завершение контролирует
          // пославший метод)
          trIndex := 0;
//          ThereAreProcessedItems := false;
          while trIndex < AttachedDATransactionList.Count do begin
            try
              DATransaction := AttachedDATransactionList[trIndex];
              // Если владельцем данной транзакции является группа,
              {VNE-0001}
              if assigned(DATransaction) and ((TObject(DATransaction.SourceObj)) is TVpNetOPCGroup) then begin
                gr := TVpNetOPCGroup(DATransaction.SourceObj);
                // и если служебный поток группы определен
                if assigned(gr.ControlThread) then begin
                  grThread := TVpNetOPCGroupControlThread(gr.ControlThread);
                  // Посылаем сообщение о завершении выполнения DA-транзакции этому потоку
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


      // Очищаем ссылку на текущую транзакцию
//      {8.02.2009}
      // Сигнализирует о том, что нет запущенной транзакции HST-сервера
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
      // Если Hst-транзакция до этого момента не была начата, выходим без обработки
      if Hst_TID = 0 then begin
        PostLogRecordAddMsgNow(70378, -1, -1, -1, 'Ошибка HST-транзакции. Транзакция не выполнялась');
        exit;
      end;

      // Сохранение входных (ответных) данных в свойстве соединения
      try
        Hst_InputData.Clear;
      except on e : Exception do
        PostLogRecordAddMsgNow(70395, e.HelpContext, -1, -1, e.Message);
      end;

      // Проходим по списку DA-транзакций соединения
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
          // Если эта DA-транзакция ожидает ответа в данной Hat-транзакции, ...
          if trItem.DA_State = vndtsWaitingForResponse then begin
            // Получаем транзакцию

            // Удаляем завершенную DA-транзакцию из списка
            DATransactionItemList.Remove(trItem);
            // потому, что в конце этого прохода по циклу все равно будет trItemIndex := Succ(trItemIndex)
            // а поскольку мы выденули элемент из списка, нам приращение в этот проход делать не нужно.
            trItemIndex := trItemIndex - 1;

            // завершаем ее с ошибкой
            trItem.SetError;

            PostLogRecordAddMsgNow(70885, Integer(trItem.DA_State), Integer(vndtsWaitingForResponse), -1, 'Элемент транзакции завершен с ошибкой');
          end;

        except on e : Exception do
          PostLogRecordAddMsgNow(70886, e.HelpContext, -1, -1, e.Message);
        end;

      finally
        // Приращаем номер транзакции
        trItemIndex := Succ(trItemIndex);
      end;

      // Очищаем ссылку на текущую транзакцию
      // Сигнализирует о том, что нет запущенной транзакции HST-сервера
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
      // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
      // ничего не делаем
      if not(ServerCore.State = vndsWorking) then begin
        PostLogRecordAddMsgNow(70838, Integer(ServerCore.State), -1, -1, '');
        exit;
      end;

      // Если Hst-транзакция до этого момента не была начата, выходим без обработки
      if Hst_TID = 0 then begin
        PostLogRecordAddMsgNow(70839, -1, -1, -1, 'Ошибка HST-транзакции. Транзакция не выполнялась');
        exit;
      end;

      // Сохранение входных (ответных) данных в свойстве соединения
      try
        Hst_InputData.Clear;
       Hst_InputData.Size := aHstErrorData^.HstAnswerDataSize;

       Move(aHstErrorData^.HstAnswerData, Hst_InputData.Data, Hst_InputData.Size);

      except on e : Exception do
        PostLogRecordAddMsgNow(70840, e.HelpContext, -1, -1, e.Message);
      end;


      // Проходим по списку DA-транзакций соединения
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
          // Если эта DA-транзакция ожидает ответа в данной Hat-транзакции, ...
          if trItem.DA_State = vndtsWaitingForResponse then begin
            // Получаем транзакцию

            // Удаляем завершенную DA-транзакцию из списка
            DATransactionItemList.Remove(trItem);
            // потому, что в конце этого прохода по циклу все равно будет trItemIndex := Succ(trItemIndex)
            // а поскольку мы выденули элемент из списка, нам приращение в этот проход делать не нужно.
            trItemIndex := trItemIndex - 1;

            // завершаем ее с ошибкой
            trItem.SetError;

            PostLogRecordAddMsgNow(70380, Integer(trItem.DA_State), Integer(vndtsWaitingForResponse), -1, 'Элемент транзакции завершен с ошибкой');
          end;

        except on e : Exception do
          PostLogRecordAddMsgNow(70399, e.HelpContext, -1, -1, e.Message);
        end;

      finally
        // Приращаем номер транзакции
        trItemIndex := Succ(trItemIndex);
      end;

      // Очищаем ссылку на текущую транзакцию
      // Сигнализирует о том, что нет запущенной транзакции HST-сервера
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

// Функция поиска соединения по идентификатору драйвера Hst-сервера
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

// Функция поиска соединения по текущей транзакции Hst-сервера,
// инициированной данным соединением
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

