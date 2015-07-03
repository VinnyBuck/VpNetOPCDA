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
  // Инициализация критической секции
  InitializeCriticalSection(FCS);

  Priority := tpNormal;
  // Вызов функции из Win32 USER or GDI для для создания очереди сообщений потока
  PeekMessage(msg, 0{NULL}, WM_USER, WM_USER, PM_NOREMOVE);

end;

destructor TVpNetHstCommDriverControlThread.destroy;
begin
  // Удаляем критическую секцию
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
      // Чтение очереди сообщений
      while PeekMessage(CurrMsg, 0, WM_DA_MIN, WM_DA_MAX, PM_REMOVE) do begin
//      iRes := Integer(GetMessage(CurrMsg, 0, WM_DA_MIN, WM_DA_MAX));
      // - Если GetMessage вернула значение <= 0, значит выходим
//      if iRes <= 0 then begin
        // Если GetMessage вернула -1, значит произошла ошибка. Выходим с E_FAIL
//        if iRes = -1 then
//          ReturnValue := E_FAIL;
//        break;
//      end;
      // - Обработак полученного сообщения
        case CurrMsg.message of
          // Сообщение об изменении состояния активности коммуникационного
          WM_DA_HST_DRIVER_ACTIVE_STATE_CHANGED : begin
            // Просто перенаправляем его в главный оток
            PostMessage(Application.MainForm.Handle, CurrMsg.message, CurrMsg.wParam, CurrMsg.lParam);
          end;
          // Команда на создание новой транзакции (добавлении пакета в очередь исходящих сообщений)
          CM_DA_HST_DRIVER_SEND: begin
          end;

          // Сообщение о нормальном завершении транзакции (ответные данные получены)
          WM_DA_HST_DRIVER_RECIEVE_INTERNAL: begin
          end;

          // Сообщение об аварийном завершении транзакции
          WM_DA_HST_DRIVER_ERROR: ;

          else begin
            // Игнорируем неизвестные сообщения
          end;
        end;
      end;

      // Вне зависимости от того, пришло новое сообщение или нет,
      // обрабатываем список накопленных транзакций
{
      if DATransactionList.Count > 0 then begin
        v := 7; //todo: считать реальное ожидаемое количество байтов ответа
        trIndex := 0;
        while trIndex < DATransactionList.Count do begin
          DATransaction := DATransactionList[trIndex];
          // Если очередная транзакция ожидает обработки,
          // обрабатываем ее, и делаем пометку о том,
          // что для данной транзакци ожидаются ответные данные
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
