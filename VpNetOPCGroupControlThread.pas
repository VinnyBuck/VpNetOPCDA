unit VpNetOPCGroupControlThread;

interface

uses Classes, Windows, ActiveX, Forms, SysUtils, OPCDA, OPCtypes,
  VpNetOPCGroup_Impl, VpNetOPCItem_Impl, VpNetDefs, VpNetDADefs, VpNetUtils,
  VpNetDAClasses;

type
  TVpNetOPCGroupControlThread = class(TThread)
  private
    FOPCGroup : TVpNetOPCGroup;
  protected
    procedure Execute; override;
  public
    property OPCGroup : TVpNetOPCGroup read FOPCGroup;
    constructor Create(aOPCGroup : TVpNetOPCGroup; CreateSuspended: Boolean);
  end;

implementation

uses VpNetDAServerCore, Variants, Math, VpNetDADebug;

constructor TVpNetOPCGroupControlThread.Create(aOPCGroup : TVpNetOPCGroup; CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FOPCGroup := aOPCGroup;
end;

procedure TVpNetOPCGroupControlThread.Execute;
var
  ItemIndex : DWORD;
  Item : TVpNetOPCItem;
  ftCurrTime : TFileTime; // Текущее время (UTC)
  CacheUpdateIntervalMS : DWORD;
  ItemsToUpdate : TList;
  dwCount : DWORD;
  phServer: POPCHANDLEARRAY;
  dwSource: DWORD;
  phClients:                  POPCHANDLEARRAY;
  ppvValues:                  POleVariantArray;
  ppwQualities:               PWordArray;
  ppftTimeStamps:             PFileTimeArray;
  ppErrors:                   PResultList;
  hr : HRESULT;
  //
  Msg : TMsg;
  MsgRes: Integer;
  MsgFound : Boolean;

  tr : TVpNetDATransaction;
  bMoreThenMaxAge : boolean;
begin
  ItemsToUpdate := TList.Create;
  try
    ReturnValue := S_OK;
    while not Terminated do try
      // Проверяем очередь входящих сообщений
      try
        MsgRes := Integer(PeekMessage(Msg, 0 {NULL}, WM_DA_MIN, WM_DA_MAX, PM_REMOVE));
      except
        MsgRes := -1;
      end;
      MsgFound := not((MsgRes = 0){ or (MsgRes = -1)});

      // Если есть новое сообщение, обрабатываем его
      if MsgFound then begin
        case Msg.message of
          // Сообщение об обработке элементров асинхронной транзакции
          WM_DA_TRANSACTION_ITEMS_PROCESSED: begin
            // Выделяем транзакцию один или более элементов которой обработаны
            tr := TVpNetDATransaction(Msg.wParam);
            // Если все элементы транзакции обработаны, ...
            if tr.Processed then begin
              PostLogRecordAddMsgNow(70921, tr.dwClientTransactionId, -1, -1, 'Отправка WM_DA_TRANSACTION_PROCESSED', llDebug);
              PostMessage(Application.MainForm.Handle, WM_DA_TRANSACTION_PROCESSED, Integer(OPCGroup), Integer(tr));
//              // Вызываем Callback-функцию OnDataChange()
//              OPCGroup.DoCallOnDataChange(tr);

            end;

          end;
        end;
      end else begin
        // Если при последней проверке входящих сообщений небыло,
        // то выполняем ожидание новых пакетов
        sleep(1);
      end;

      // Обслуживание группы
{09.07.2006}
//      if OPCGroup.Active then begin
      // Выполняем обслуживание тегов группы, если группа активна,
      // и DA-сервер находится в рабочем состоянии
      if OPCGroup.Active and (ServerCore.State = vndsWorking) then begin
{/09.07.2006}


{19.09.2007}
        CoFileTimeNow(ftCurrTime);
        LocalFileTimeToFileTime(ftCurrTime, ftCurrTime);
{/19.09.2007}


        ItemsToUpdate.Clear;
        // Если группа активна
        ItemIndex := 0;
        while not(Terminated) and (ItemIndex < DWORD(OPCGroup.Items.Count)) do begin
          Item := OPCGroup.Items[ItemIndex];
          // Если итем активен
          if Item.Active then begin
            // Определяем SamplingRate итема:
            // Если SamplingRate для этого итема установлен, берем его
            if Item.SamplingRateSet then begin
              CacheUpdateIntervalMS := Item.SamplingRate;
            end else begin
              // Иначе берем UpdateRate группы
              CacheUpdateIntervalMS := TVpNetOPCGroup(Item.GroupObj).UpdateRate;
            end;

{19.09.2007}
            { TODO :
Вынести получение текущего времени из цикла и вычислять
ее 1 раз для всего цикла }
            // Получение текущего времени (UTC)
//            CoFileTimeNow(ftCurrTime);
//            LocalFileTimeToFileTime(ftCurrTime, ftCurrTime);
{19.09.2007}
            // Проверка необходимости чтения нового значения с прибора
            // (чтения нового значения с прибора необходимо при привышении SamplingRate итема)

// 02.04.2010
//            if FileTimeMinusFileTimeMS(ftCurrTime, Item.LastCacheUpdateTime) >= CacheUpdateIntervalMS then begin
            try
              bMoreThenMaxAge := (FileTimeMinusFileTimeMS(ftCurrTime, Item.LastCacheUpdateTime) >= CacheUpdateIntervalMS);
            except on e : Exception do begin
                bMoreThenMaxAge := true;
                PostLogRecordAddMsgNow(70406, e.HelpContext, -1, -1, e.Message);
              end;
            end;

            if bMoreThenMaxAge then begin
///02.04.2010
              // Добавляем нуждающийся в обновлении итем в список себе подобных
              ItemsToUpdate.Add(Item);
              // Фиксируем момент формирования задания на чтение Item-а
              Item.LastCacheUpdateTime := ftCurrTime;
            end;
          end;
          ItemIndex := Succ(ItemIndex);
        end;
        // Отсылаем запрос на чтение списка итемов, нуждающихся в обновлении
        //todo: Сделать примерно то же, что и в IOPCItemIO.Read (_SyncRead)

        // Если есть итемы для чтения, выполняем чтение
        if ItemsToUpdate.Count > 0 then begin
          dwCount := ItemsToUpdate.Count;
          // Заполняем
          try
            phServer := CoTaskMemAlloc(dwCount * sizeof(OPCHANDLE));
//            dwSource := OPC_DS_DEVICE;
            // Заполнение входных массивов
            ItemIndex := 0;
            while not(Terminated) and (ItemIndex < dwCount) do begin
              phServer^[ItemIndex] := TVpNetOPCItem(ItemsToUpdate[ItemIndex]).hServer;
              ItemIndex := Succ(ItemIndex);
            end;

            {$IFDEF DEBUG_METHOD_CALLS}
            OutputDebugString(PChar('1'));
            {$ENDIF}

            // Вызов функции чтения
            PostLogRecordAddMsgNow(70925, -1, -1, -1, 'Перед Group._Read()', llDebug);
            hr := FOPCGroup._Read(
              dwCount,
              phServer,
              OPC_DS_DEVICE,
              nil, // pdwMaxAge
              vndtstAsync,
              vnditSubscription,
              0{[1] стр.131}, //dwClientTransactionId
              0, // dwClientCancelId
              phClients,
              ppvValues,
              ppwQualities,
              ppftTimestamps,
              ppErrors
            );
            PostLogRecordAddMsgNow(70926, -1, -1, -1, 'После Group._Read()', llDebug);

            // Если чтение завершилось удачно, ...
            if hr >= S_OK then try
              // Обработка полученных данных
              // ..
            finally

              // По завершении удаляем ненужные данные
              if assigned(phClients) then begin
                CoTaskMemFree(phClients);
                phClients := nil;
              end;

              if assigned(ppvValues) then begin
                // деинициализируем элементы массива перед удалением
                ItemIndex := 0;
                while not(Terminated) and (ItemIndex < dwCount) do begin
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
            end;

          finally
            CoTaskMemFree(phServer);
          end;
        end;
      end;

      Sleep(1);
//      Application.ProcessMessages;
    except
      ReturnValue := E_FAIL;
      break;
    end;
  finally
    ItemsToUpdate.Free;
  end;
end;

end.
