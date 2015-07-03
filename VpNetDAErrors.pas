unit VpNetDAErrors;

interface

uses Windows, ActiveX, ComObj, SysUtils, OPCError, VpNetUtils;

function OPCErrorCodeToString(aLCID : TLCID; hr: HResult; out ppString: POleStr): HRESULT; // su01

implementation

uses VpNetDADebug;

function OPCErrorCodeToString(aLCID : TLCID; hr: HResult; out ppString: POleStr): HRESULT;
var
  err_eng: String;
  err_rus: String;
  err_ : String;
  PrimaryLangId : Word;
  LangId : Word;
  buf : array[0..255] of char;
  len : integer;
begin
  try
    case hr of
      S_OK : begin
        err_eng := 'The operation succeeded.';
        err_rus := 'Опрерация выполненя успешно.';
      end;
      S_FALSE: begin
        err_eng := 'Operation did not produce a useful result.';
        err_rus := 'Операция не привела к ожидаемому результату.';
      end;
      E_FAIL: begin
        err_eng := 'The operation failed.';
        err_rus := 'Привыполнении опреации произошла ошибка.';
      end;
      E_OUTOFMEMORY: begin
        err_eng := 'Out of memory.';
        err_rus := 'Недостаточно памяти для выплонения опрерации.';
      end;
      E_INVALIDARG: begin
        err_eng := 'One or more arguments are invalid.';
        err_rus := 'Недопустимое значение одного или нескольких рагументов.';
      end;
      E_NOINTERFACE: begin
        err_eng := 'No such interface supported.';
        err_rus := 'Интерфейс не поддерживается.';
      end;
      OPC_E_INVALIDHANDLE: begin
        err_eng := 'The value of the handle is invalid.';
        err_rus := 'Недопустимое значение дескриптора';
      end;
      OPC_E_BADTYPE: begin
        err_eng := 'The server cannot convert the data between the requested data type and the canonical data type.';
        err_rus := 'Сервер не может конвертировать данные между указанным и стандартным типами.';
      end;
      OPC_E_PUBLIC: begin
        err_eng := 'The requested operation cannot be done on a public group.';
        err_rus := 'Данное действие не может быть выполнено для общей группы.';
      end;
      OPC_E_BADRIGHTS: begin
        err_eng := 'The Items AccessRights do not allow the operation.';
        err_rus := 'Права доступа (AccessRights) элемента не не позволяют выполнить опреацию.';
      end;
      OPC_E_UNKNOWNITEMID: begin
        err_eng := 'The item is no longer available in the server address space.';
        err_rus := 'Элемент более не доступен в адресном пространстве сервера.';
      end;
      OPC_E_INVALIDITEMID: begin
        err_eng := 'The item definition does not conform to the server''s syntax.';
        err_rus := 'Определение элемент не соответствует требованиям синтаксиса сервера.';
      end;
      OPC_E_INVALIDFILTER: begin
        err_eng := 'The filter string was not valid.';
        err_rus := 'Была указана неправльная строка фильтра';
      end;
      OPC_E_UNKNOWNPATH: begin
        err_eng := 'The item''s access path is not known to the server.';
        err_rus := 'Путь доступа к элементу не известен на вервере.';
      end;
      OPC_E_RANGE: begin
        err_eng := 'The value was out of range.';
        err_rus := 'Значение вне допустимого диапазона.';
      end;
      OPC_E_DUPLICATENAME: begin
        err_eng := 'Duplicate name not allowed.';
        err_rus := 'Повтроное исползавание имени не допускается.';
      end;
      OPC_S_UNSUPPORTEDRATE: begin
        err_eng := 'The server does not support the requested data rate but will use the closest available rate.';
        err_rus := 'Сервер не поддерживает указанную частоту обновления данных. Будет использоваться ближайшая к указанной доступная частота обновления.';
      end;
      OPC_S_CLAMP: begin
        err_eng := 'A value passed to WRITE was accepted but the output was clamped.';
        err_rus := 'Значение переданное в метод WRITE было принято, но небыло сохранено.';
      end;
      OPC_S_INUSE: begin
        err_eng := 'The operation cannot be completed because the object still has references that exist.';
        err_rus := 'Операция не может быть завершена, из-за наличия ссылок на объект.';
      end;
      OPC_E_INVALIDCONFIGFILE: begin
        err_eng := 'The server''s configuration file is an invalid format.';
        err_rus := 'Файл конфигурации сервера находится в поврежденном состоянии.';
      end;
      OPC_E_NOTFOUND: begin
        err_eng := 'The server could not locate the requested object.';
        err_rus := 'Сервер не может найти указанный объект.';
      end;
      OPC_E_INVALID_PID: begin
        err_eng := 'The server does not recognise the passed property ID or an area name.';
        err_rus := 'Сервер не может распознать переданный идентификатор свойства (property ID) или имя области.';
      end;
//      OPC_E_INVALIDBRANCHNAME: begin
//        err_eng := 'The string was not recognized as an area name.';
//        err_rus := 'Строка не является именем области.';
//      end;
      OPC_S_ALREADYACKED: begin
        err_eng := 'The condition has already been acknowleged.';
        err_rus := 'Условие было учтено ранее.';
      end;
      OPC_S_INVALIDBUFFERTIME: begin
        err_eng := 'The buffer time parameter was invalid.';
        err_rus := 'Указан неправильный параметр buffer time.';
      end;
      OPC_S_INVALIDMAXSIZE: begin
        err_eng := 'The max size parameter was invalid.';
        err_rus := 'Указан неправильный параметр max size.';
      end;
      OPC_E_INVALIDTIME: begin
        err_eng := 'The time does not match the latest active time.';
        err_rus := 'Время не совпадает с последним временем активности (latest active time).';
      end;
      OPC_E_BUSY: begin
        err_eng := 'A refresh is currently in progress.';
        err_rus := 'Выполняестя обновление.';
      end;
      OPC_E_NOINFO: begin
        err_eng := 'Information is not available.';
        err_rus := 'Данные недоступны.';
      end;
      OPC_E_INVALIDCONTINUATIONPOINT : begin
        err_eng := 'The continuation point is not valid.';
        err_rus := 'Неправильная точка продолжения операции.';
      end;
      OPC_E_NOTSUPPORTED: begin
        err_eng := 'The server does not support writing of quality and/or timestamp.';
        err_rus := 'Сервер не поддерживает запись состояния и/или метки времени.';
      end
      else begin
        // Если неизвестная ошибка, возвращаем стандартное описание
        len := FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ARGUMENT_ARRAY,
          nil, longword(hr), 0, buf, sizeOf(buf), nil);
        while (len > 0) and (buf[len - 1] in [#0..#32, '.']) do
        Dec(len);
        SetString(err_eng, buf, len);
        err_rus := err_eng;
      end;
    end;

    LangId := aLCID and $FFFF;
    PrimaryLangId := (LangId and $3FF); // Младшие 10 бит LANGID
    if (PrimaryLangId = $009) {English} then
    else if (PrimaryLangId = $019) {Russian} then
      err_ := err_rus
    else
      err_ := err_eng;

    result := VpStringToLPOLESTR(err_, ppString);
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70156, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
      ppString := nil;
      result := E_FAIL;
    end;
  end;
end;

end.
