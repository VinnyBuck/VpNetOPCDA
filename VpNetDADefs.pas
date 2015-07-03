unit VpNetDADefs;

interface

uses Windows, SysUtils, OPCTypes, VpNetDefs, IniFiles;

// 70935

const
  // Настройки
  IniFileCoreSectionName : String = 'CORE';
  UnassignedInstanceIdValue : Integer  = 0;
  UnassignedGroupHandle : OPCHANDLE = 0;
  UnassignedItemHandle : OPCHANDLE = 0;
  UnassignedGroupUpdateRate : DWORD = 0;
  UnassignedMinGroupKeepAlive : DWORD = 0;
  UnassignedLastTID : DWORD = 0;
  UnassignedLastTIID : DWORD = 0;

// Идентификаторы сущностей
  VNVP_LastAssignedServerGroupId : Integer = 10001;

// Сообщения windows
const
  // Значение: Команда на обновление внешнего вида программы
  // WParam = 0
  // LParam = 0
  CM_DA_UPDATE_STATE   = WM_DA_ + $01;
  WM_DA_HIDE           = WM_DA_ + $02;

  // Значение: Сообщение о создании нового серверного объекта (TVpNetOPCDA)
  // WParam = Созданный объект (TVpNetOPCDA)
  // LParam = 0;
  WM_DA_SERVER_CREATED = WM_DA_ + $11;

  // Значение: Сообщение о начале удаления серверного объекта (TVpNetOPCDA)
  // WParam = удаляемый объект объект (TVpNetOPCDA)
  // LParam = 0;
  WM_DA_SERVER_DESTROING = WM_DA_ + $12;

  // Значение: Сообщение о создании группы
  // WParam = 0
  // LParam = 0;
  WM_DA_GROUP_CREATED = WM_DA_ + $17;

  // Значение: Сообщение об удалении группы
  // WParam = 0
  // LParam = 0;
  WM_DA_GROUP_DESTROYED = WM_DA_ + $18;

  // Значение: Сообщение о выделении нового идентификатора транзакции
  // WParam = 0
  // LParam = TID (Cardinal);
  WM_DA_NEW_TID = WM_DA_ + $19;

  // Значение: Сообщение о добавлении/удалении ссылки на драйвер Host-сервера
  // WParam = Id драйвера Host-сервера (HostServerDriverID)
  // LParam = 0;
  CM_DA_HST_DRIVER_ADD_REF = WM_DA_ + $23;
  CM_DA_HST_DRIVER_RELEASE = WM_DA_ + $24;

  // Значение: Команда добваление новый транзакций  DA-сервера в очередь транзакций драйвера хост-сервера
  // WParam = Идентификатор драйвера Хост-сервера (DriverId)
  // LParam = Ссылка на структуру, содержащую список транзакций DA-сервера (TVpNetDATransactionList) для данного соединения(драйвера)
  CM_DA_HST_DRIVER_ADD_TRANSACTIONS = WM_DA_ + $30;

  // Значение: Команда на отправку запроса новых данных через драйвер хост-сервера
  // WParam = Идентификатор драйвера Хост-сервера (DriverId)
  // LParam = 0
  CM_DA_HST_DRIVER_SEND = WM_DA_ + $31;

  // Значение: Сообщение об изменении состояния активности коммуникационного
  // драйвера хост-сервера
  // WParam = Ссылка на объект, представляющий соединение с драйвером хост-сервера (TVpNetHstDriverConnection)
  // LParam = Новое состояние активности коммуникационного драйвера (VpNetHstCommDriverActiveState)
  WM_DA_HST_DRIVER_ACTIVE_STATE_CHANGED = WM_DA_ + $32;

  // Значение: Сообщение о получении ответа от драйвера хост-сервера
  // WParam = Идентификатор транзакции HST-сервера
  // LParam = Ссылка на структуру с данными полученным (PVpNetHSTAnswerData)
  WM_DA_HST_DRIVER_RECIEVE = WM_DA_ + $33;

  // Значение: Сообщение о получении уведомления об ошибке от драйвера хост-сервера
  // WParam = Hst_TID (Идентификатор транзакции хост-сервера)
  // LParam = ERROR_CODE (идентификатор ошибки)
  WM_DA_HST_DRIVER_ERROR = WM_DA_ + $34;

// 30.11.2011
  // Значение: Сообщение о получении уведомления об ошибке от драйвера хост-сервера
  // WParam = Hst_TID (Идентификатор транзакции хост-сервера)
  //LParam = pErrorData
  WM_DA_HST_DRIVER_ERROR_WITH_DATA = WM_DA_ + $37;
///30.11.2011


  // Значение: Сообщение о получении уведомления о начале транзакции драйвером хост-сервера
  // WParam = Hst_TID (Идентификатор транзакции хост-сервера)
  // LParam = 0
  WM_DA_HST_DRIVER_START_TRANSACTION = WM_DA_ + $35;

  // Значение: Команда на проверку транзакций сервера (устранение зависаний)
  // WParam = 0
  // LParam = 0
  CM_DA_TRANSACTION_CHECK = WM_DA_ + $36;

  // Значение: Сообщение об боработке одного или более элементов транзакции DA-сервера
  // WParam = Транзакция DA-сервера (TVpNetDATransaction)
  // LParam = 0
  WM_DA_TRANSACTION_ITEMS_PROCESSED = WM_DA_ + $40;

  // Значение: Сообщение о завершении асинхронной транзакции DA-сервера
  // WParam = Группа DA-сервера (TVpNetOPCGroup)
  // LParam = Транзакция DA-сервера (TVpNetDATransaction)
  WM_DA_TRANSACTION_PROCESSED = WM_DA_ + $41;

  // Значение: Сообщение о результате проверки лицензии
  // WParam = 0
  // LParam = LicState (HRESULT)
  WM_DA_LICENSE_STATUS = WM_DA_ + $49;

  // Значение: Комманда на сохранение записи в логе
  // WParam - Данные об ошибке (TVpNetDALogRecordDataStruct)
  // LParam - 0
  CM_DA_LOG_RECORD_ADD = WM_DA_ + $97;

  // Значение: Комманда отображение информации о работе сервера
  // WParam - Информация о работе сервера (TVpNetDAProcessInfoStruct)
  // LParam - 0
  CM_DW_PROCESS_INFO_DISPLAY = WM_DA_ + $99;

// Константы-идентификаторы событий Host-сервера
// диапазон значений 72000..73999
// последний выданный код: 72009
const
  vdae_None = 72000; // Отсутствует, не используется и т.д.

// su01 - признак того, что обновление надежности/безопсности №01 для фрагмента кода выполнено
//        Суть обновления:
//          Заключение всего кода фрагмента в один или несколько блоков try...except
//          Вывод сообщений обо всех ошибках в Log-файл

// su02 - признак того, что обновление надежности/безопсности №02 для фрагмента кода выполнено
//        Суть обновления:
//          Разделение сообщений обо всех ошибках на типы:
//          llDebug - Отладочные сообщения
//          llErrors - Сообщения об ошибках в коде
//        Флаги вывода типов сообщений в VpNetDADebug.FLogLevel

// Сервисные функции
function GetIniValue(aSection: String; aKey : String; out aValue: String) : HResult; // su01
//function DataTimeToOPCTime(cTime : TDateTime; var OPCTime : TFileTime) : HRESULT;

implementation

uses VpNetDADebug;

function GetIniValue(aSection: String; aKey : String; out aValue: String) : HResult;
var
  sAppName : String;
  sIniFileName : String;
  IniFile : TIniFile;
  ErrValue : String;
begin
  try
    // Подготовка
    ErrValue := IntToStr(GetTickCount);
    sAppName := ParamStr(0);
    sIniFileName := ExtractFilePath(sAppName) + Copy(ExtractFileName(sAppName), 1, length(ExtractFileName(sAppName)) - 4)  + '.ini';
    IniFile := TIniFile.Create(sIniFileName);
    // Проверка наличия ключа
    if not IniFile.ValueExists(aSection, aKey) then begin
      PostLogRecordAddMsgNow(70482, -1, -1, E_INVALIDARG, aSection + '.' + aKey);
      aValue := '';
      result := E_INVALIDARG;
      exit;
    end;
    // Чтение значения ключа
    aValue := IniFile.ReadString(aSection, aKey, ErrValue);
    if aValue = ErrValue then begin
      // Если не удалось нормально прочитать значение, возвращаем E_INVALIDARG
      PostLogRecordAddMsgNow(70483, -1, -1, E_INVALIDARG, aSection + '.' + aKey + '=' + aValue);
      aValue := '';
      result := E_INVALIDARG;
      exit;
    end else begin
      // Если все нормально, возвращаем S_OK
      result := S_OK;
      exit;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70481, e.HelpContext, -1, -1, e.Message + '; ' + aSection + '.' + aKey);
      // Если произошла непредвиденная ошибка, возврашаем E_FAIL
      aValue := '';
      result := E_FAIL;
    end;
  end;
end;

{
function DataTimeToOPCTime(cTime : TDateTime; var OPCTime : TFileTime) : HRESULT;
var
 sTime:TSystemTime;
 FileTime : TFileTime;
begin
 try
   DateTimeToSystemTime(cTime, sTime);

   if not SystemTimeToFileTime(sTime, FileTime) then begin
     result := E_FAIL;
     exit;
   end;

   if not LocalFileTimeToFileTime(FileTime, OPCTime) then begin
     result := E_FAIL;
     exit;
   end;

   result := S_OK;
 except
   result := E_FAIL;
 end;
end;
}

initialization
{$DEFINE DEBUG_METHOD_CALLS}
end.
