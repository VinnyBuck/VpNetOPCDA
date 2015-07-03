unit VpNetOPCDA_Impl;

{$INCLUDE VpNetDA.def}

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  ComObj, ActiveX, AxCtrls, Windows, Classes, VpNetDA_TLB, StdVcl, SysUtils, SyncObjs,
  OPCCOMN, OPCDA, OPCerror, OPCtypes, VpNetDefs, VpNetDAClasses, VpNetDARDM_Impl, RzStatus,
  Forms, uEnumString, uEnumUnknown, Contnrs, Variants, VpNetClasses, VpNetUtils,
  VpNetOPCGroupList, DB, Dialogs;

type
  TVpNetOPCDA = class(TAutoObject, IVpNetOPCDA, IConnectionPointContainer,
    IOPCCommon, IOPCServer, IOPCBrowse, IOPCItemIO, IOPCItemProperties,
    IOPCBrowseServerAddressSpace, IOPCServerPublicGroups{, IPersistFile}) // su01
  private
    FConnectionPoints: TConnectionPoints;
    FShutdownIntf: IOPCShutdown;
    FRDM : TVpNetDARDM;
    FGroups : TVpNetOPCGroupList;
    FPublicGroups : TVpNetOPCGroupList;
    FServerStartTime : TFileTime;
    {21.01.2008}
    // ID элемента на котором находится фокус навигации
    // (для навигации по адресному пространству сервера с помощью интерфейса
    // IOPCBrowseServerAddressSpace)
    FNavigationNodeId : Integer;
    FNavigationNodeDevId : Integer;
    {/21.01.2008}
    FLastClientUpdateTime : TFileTime; //todo: Передать последнее время обновления
//    FBrowsePosID : DWORD;
    function GetLangId : WORD; // su01
    function GetPrimaryLangId : WORD; // su01
    function GetSublangId : WORD; // su01
    function GetPropertyValidStatus(dwVDTT_ID : DWORD; dwPropertyId : DWORD; out wValidStatus : Word): HRESULT; // su01
  protected
    ClientName : String; // Имя клиента
    LCID : TLCID; // Активный Locale
    property LangId : WORD read GetLangId;
    property PrimaryLangId : WORD read GetPrimaryLangId;
    property SubLangId : WORD read GetSubLangId;
    property ConnectionPoints: TConnectionPoints read FConnectionPoints
      implements IConnectionPointContainer;
//    procedure EventSinkChanged(const EventSink: IUnknown); override;
    procedure CallBackOnConnect(const Sink: IUnknown; Connecting: Boolean); // su01
    // IOPCCommon
    function SetLocaleID(dwLcid: TLCID): HResult; stdcall; // su01, su02
    function GetLocaleID(out pdwLcid: TLCID): HResult; stdcall; // su01, su02
    function QueryAvailableLocaleIDs(out   pdwCount: UINT; out pdwLcid: PLCIDARRAY): HResult; stdcall; // su01, su02
    function GetErrorString( dwError: HResult; out ppString: POleStr): HResult; overload; stdcall; // su01, su02
    function SetClientName(szName: POleStr): HResult; stdcall; // su01, su02
    // IOPCServer
    function AddGroup(
            szName:                     POleStr;
            bActive:                    BOOL;
            dwRequestedUpdateRate:      DWORD;
            hClientGroup:               OPCHANDLE;
            pTimeBias:                  PLongint;
            pPercentDeadband:           PSingle;
            dwLCID:                     DWORD;
      out   phServerGroup:              OPCHANDLE;
      out   pRevisedUpdateRate:         DWORD;
      const riid:                       TIID;
      out   ppUnk:                      IUnknown): HResult; stdcall; // su01, su02
    function GetErrorString(
            dwError:                    HResult;
            dwLocale:                   TLCID;
      out   ppString:                   POleStr): HResult; overload; stdcall; // su01, su02
    function GetGroupByName(
            szName:                     POleStr;
      const riid:                       TIID;
      out   ppUnk:                      IUnknown): HResult; stdcall; // su01, su02
    function GetStatus(
      out   ppServerStatus:             POPCSERVERSTATUS): HResult; stdcall; // su01, su02
    function RemoveGroup(
            hServerGroup:               OPCHANDLE;
            bForce:                     BOOL): HResult; stdcall; // su01, su02
    function CreateGroupEnumerator(
            dwScope:                    OPCENUMSCOPE;
      const riid:                       TIID;
      out   ppUnk:                      IUnknown): HResult; stdcall; // su01, su02

    // IOPCBrowse
    function FillPOPCITEMPROPERTIES(pItemProps : POPCITEMPROPERTIES; szItemID : POleStr; bReturnPropertyValues : BOOL; qTags : TDataSet): HRESULT; // su01, su02
    function GetProperties(
            dwItemCount:                DWORD;
            pszItemIDs:                 POleStrList;
            bReturnPropertyValues:      BOOL;
            dwPropertyCount:            DWORD;
            pdwPropertyIDs:             PDWORDARRAY;
      out   ppItemProperties:           POPCITEMPROPERTIESARRAY):
            HResult; stdcall; // su01, su02
    function Browse(
            szItemID:                   POleStr;
     var   pszContinuationPoint:       POleStr;
            dwMaxElementsReturned:      DWORD;
            dwBrowseFilter:             OPCBROWSEFILTER;
            szElementNameFilter:        POleStr;
            szVendorFilter:             POleStr;
            bReturnAllProperties:       BOOL;
            bReturnPropertyValues:      BOOL;
            dwPropertyCount:            DWORD;
            pdwPropertyIDs:             PDWORDARRAY;
      out   pbMoreElements:             BOOL;
      out   pdwCount:                   DWORD;
      out   ppBrowseElements:           POPCBROWSEELEMENTARRAY):
            HResult; stdcall; // su01, su02

    // IOPCItemIO
    function Read(
            dwCount:                    DWORD;
            pszItemIDs:                 POleStrList;
            pdwMaxAge:                  PDWORDARRAY;
      out   ppvValues:                  POleVariantArray;
      out   ppwQualities:               PWordArray;
      out   ppftTimeStamps:             PFileTimeArray;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02
    function WriteVQT(
            dwCount:                    DWORD;
            pszItemIDs:                 POleStrList;
            pItemVQT:                   POPCITEMVQTARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02

    // IOPCItemProperties
    function QueryAvailableProperties(
            szItemID:                   POleStr;
      out   pdwCount:                   DWORD;
      out   ppPropertyIDs:              PDWORDARRAY;
      out   ppDescriptions:             POleStrList;
      out   ppvtDataTypes:              PVarTypeList): HResult; stdcall; // su01, su02
    function GetItemProperties(
            szItemID:                   POleStr;
            dwCount:                    DWORD;
            pdwPropertyIDs:             PDWORDARRAY;
      out   ppvData:                    POleVariantArray;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02
    function LookupItemIDs(
            szItemID:                   POleStr;
            dwCount:                    DWORD;
            pdwPropertyIDs:             PDWORDARRAY;
      out   ppszNewItemIDs:             POleStrList;
      out   ppErrors:                   PResultList): HResult; stdcall; // su01, su02

    // IOPCBrowseServerAddressSpace
    function QueryOrganization(
      out   pNameSpaceType:             OPCNAMESPACETYPE): HResult; stdcall; // su01, su02
    function ChangeBrowsePosition(
            dwBrowseDirection:          OPCBROWSEDIRECTION;
            szString:                   POleStr): HResult; stdcall; // su01, su02
    function BrowseOPCItemIDs(
            dwBrowseFilterType:         OPCBROWSETYPE;
            szFilterCriteria:           POleStr;
            vtDataTypeFilter:           TVarType;
            dwAccessRightsFilter:       DWORD;
      out   ppIEnumString:              IEnumString): HResult; stdcall; // su01, su02
    function GetItemID(
            szItemDataID:               POleStr;
      out   szItemID:                   POleStr): HResult; stdcall; // su01, su02
    function BrowseAccessPaths(
            szItemID:                   POleStr;
      out   ppIEnumString:              IEnumString): HResult; stdcall; // su02
    // IOPCServerPublicGroups
    function GetPublicGroupByName(
            szName:                     POleStr;
      const riid:                       TIID;
      out   ppUnk:                      IUnknown): HResult; stdcall; // su02
    function RemovePublicGroup(
            hServerGroup:               OPCHANDLE;
            bForce:                     BOOL): HResult; stdcall; // su02
    // IPersistFile
    function IsDirty: HResult; stdcall; // su02
    function Load(pszFileName: POleStr; dwMode: Longint): HResult; stdcall; // su02
    function Save(pszFileName: POleStr; fRemember: BOOL): HResult; stdcall; // su02
    function SaveCompleted(pszFileName: POleStr): HResult; stdcall; // su02
    function GetCurFile(out pszFileName: POleStr): HResult; stdcall; // su02
  public
    property Groups : TVpNetOPCGroupList read FGroups;
    property PublicGroups : TVpNetOPCGroupList read FPublicGroups;
    property ShutdownIntf : IOPCShutdown read FShutdownIntf;
    property rdm : TVpNetDARDM read FRDM;
    constructor Create; virtual; // su01
    procedure Initialize; override; // su01
    destructor Destroy; override; // su01
    // Сервисные функции
//    function IsGroupNameUsed(aName : String) : boolean;
//    function GetGroupUniqueName : String;
    // Поиск в группах первого попавшегося Item-а с заданным ItemId
    function FindFirstItemByItemId(aItemId : String; out Item : Pointer): HRESULT; // su01
    // Debug
    function Debug_DoRead: HRESULT; // su01
  end;

implementation

uses ComServ, VpNetDAErrors, VpNetDAServerCore, VpNetOPCGroup_Impl, VpNetOPCGroupControlThread,
  VpNetDADefs, uOPCUtils, VpNetOPCItem_Impl, VpNetModbus, Math, TypInfo, VpNetDADebug;

function TVpNetOPCDA.GetLangId : WORD;
begin
  try
    result := LCID and $FFFF;
  except on e : Exception do
    PostLogRecordAddMsgNow(70056, LCID, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
  end;
end;

function TVpNetOPCDA.GetPrimaryLangId : WORD;
begin
  try
    result := (LangId and $3FF); // Младшие 10 бит LANGID
  except on e : Exception do
    PostLogRecordAddMsgNow(70057, LangId, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
  end;
end;

function TVpNetOPCDA.GetSublangId : WORD;
begin
  try
    result := (LangId shr 10); // Младшие 10 бит LANGID
  except on e : Exception do
    PostLogRecordAddMsgNow(70058, LangId, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
  end;
end;

function TVpNetOPCDA.GetPropertyValidStatus(dwVDTT_ID : DWORD; dwPropertyId : DWORD; out wValidStatus : Word): HRESULT;
var
  vVDT_ID : Variant;
  dwVDT_ID : DWORD;
  v : Variant;
begin
  try
    vVDT_ID := rdm.GetOneCell('select vdt_id from vda_device_type_tags where vdtt_id = ' + IntToStr(dwVDTT_ID));
    if not VarIsOrdinal(vVDT_ID) then begin
      PostLogRecordAddMsgNow(70060, LangId, -1, E_INVALIDARG, 'Ошибка параметра VDT_ID');
      result := E_INVALIDARG;
      exit;
    end;
    dwVDT_ID := vVDT_ID;

    // Поулчение правил для очередного свойства
    v := rdm.GetOneCell(
      'select vvtp2.vvtp_enabled from vn_valid_tag_properties vvtp2 ' +
      'where ' +
      '  vvtp2.vvtp_id = ( ' +
      '  select max(vvtp.vvtp_id) from vn_valid_tag_properties vvtp ' +
      '  where ' +
      '  ((vvtp.vtpi_id = (select vtpi_id from vn_tag_property_ids where vtpi_property_id = ' + rdm.IntToSQL(dwPropertyId, '0') + ')) or (vvtp.vtpi_id = -1)) and ' +
      '  ((vvtp.vdtt_id = ' + rdm.IntToSQL(dwVDTT_ID, '0') + ') or (vvtp.vdtt_id = -1)) and ' +
      '  ((vvtp.vdt_id = ' + rdm.IntToSQL(dwVDT_ID, '0') + ') or (vvtp.vdt_id = -1) ' +
      '  ) ' +
      ') ');

    // Проверяем, получили ли мы правильное значение
    if not VarIsOrdinal(v) then begin
      PostLogRecordAddMsgNow(70061, LangId, -1, E_INVALIDARG, 'Внутреннее событие');
      wValidStatus := 0;
      result := E_INVALIDARG;
      exit;
    end;

    wValidStatus := v;

    result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70059, LangId, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
    wValidStatus := 0;
    result := E_FAIL;
  end;
  end;
end;

{
function TVpNetOPCDA.IsGroupNameUsed(aName : String) : boolean;
begin
  try
    result := (Groups.IndexOfName(aName) >= 0) or (PublicGroups.IndexOfName(aName) >= 0)
  except
    result := false;
  end;
end;
}
{
function TVpNetOPCDA.GetGroupUniqueName : String;
var
  TryIndex : Integer;
  sName : String;
begin
  try
    TryIndex := 0;
    repeat
      TryIndex := TryIndex;
      sName := 'group_' + IntToStr(GetTickCount);
      if not IsGroupNameUsed(sName) then begin
        result := sName;
        exit;
      end;
    until (TryIndex >= 10);
    result := EmptyStr;
  except
    result := EmptyStr;
  end;
end;
}
function TVpNetOPCDA.FindFirstItemByItemId(aItemId : String; out Item : Pointer): HRESULT;
var
  GroupIndex : Integer;
  hr : HRESULT;
begin
  try
    result := OPC_E_UNKNOWNITEMID;
    Item := nil;
    if Assigned(FGroups) then begin
      GroupIndex := 0;
      while GroupIndex < FGroups.Count do begin
        hr := FGroups[GroupIndex].FindItemByItemId(aItemId, TVpNetOPCItem(Item));
        if (hr = S_OK) and assigned(Item) then begin
          result := S_OK;
          exit;
        end;
        GroupIndex := Succ(GroupIndex);
      end;
    end;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70154, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    Item := nil;
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.Debug_DoRead: HRESULT;
var
  dwCount : DWORD;
  pItemIDs : POleStrList;
  pdwMaxAge : PDWORDARRAY;
  pvValues : POleVariantArray;
  pwdQualities : PWordArray;
  pftTimeStamps : PFileTimeArray;
  pErrors : PResultList;
begin
  try
    // debug !!!
    dwCount := 1;
    pItemIDs := CoTaskMemAlloc(dwCount * sizeof(POleStr));
    pdwMaxAge := CoTaskMemAlloc(dwCount * sizeof(DWORD));
    try
      pItemIDs^[0] := StringToOleStr('hst_local.drv_COM1.dev1.T20011058');
      pdwMaxAge^[0] := 1000;
      result := Read(dwCount, pItemIDs, pdwMaxAge, pvValues, pwdQualities, pftTimeStamps, pErrors);
      // Обработка результатов
      // ...
      // Удаление результатов
      if Assigned(pvValues) then CoTaskMemFree(pvValues);
      if Assigned(pwdQualities) then CoTaskMemFree(pwdQualities);
      if Assigned(pftTimeStamps) then CoTaskMemFree(pftTimeStamps);
      if Assigned(pErrors) then CoTaskMemFree(pErrors);


    finally
      // Удаление результатов
      CoTaskMemFree(pdwMaxAge);
      CoTaskMemFree(pItemIDs);
    end;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70155, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
  end;
  end;
end;


constructor TVpNetOPCDA.Create;
begin
  try
    inherited;
  except on e : Exception do
    PostLogRecordAddMsgNow(70149, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
  end;
end;

procedure TVpNetOPCDA.Initialize;
var
  ObjList : TList;
begin
  try
    inherited Initialize;
  except on e : Exception do
    PostLogRecordAddMsgNow(70150, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
  end;
  // Стандартный код, инициализирующий механизм событий
  try
    FConnectionPoints := TConnectionPoints.Create(Self);
  {
    if AutoFactory.EventTypeInfo <> nil then
      FConnectionPoints.CreateConnectionPoint(
        AutoFactory.EventIID, ckSingle, EventConnect);
  }
    // Создание ConnectionPoint для интерфейса IOPCShutdown
  //  if AutoFactory.EventTypeInfo <> nil then
      FConnectionPoints.CreateConnectionPoint(
        IID_IOPCShutdown, ckSingle, CallBackOnConnect);

    // Создание подключения к базе данных
    ServerCore.DBLock;
    try
      FRDM := TVpNetDARDM.Create(Application);
    finally
      ServerCore.DBUnlock;
    end;

    // Регистрация COM-объекта в корневой структуре сервера
    ObjList := ServerCore.ServerObjects.LockList;
    try
      ObjList.Add(self);
  //    PostMessage(Application.MainForm.Handle, WM_HST_DRIVER_COM_OBJECT_CREATED, Integer(self), Index);
    finally
      ServerCore.ServerObjects.UnlockList;
    end;
    // Установка текущего Locale
    LCID := LOCALE_SYSTEM_DEFAULT;

    // Создание списка общих групп
    FPublicGroups := TVpNetOPCGroupList.Create;

    // Создание списка локальных групп
    FGroups := TVpNetOPCGroupList.Create;


    // Очистка имени клиента
    ClientName := '';

    // Установка указателя навигации вкорень (на єкземпляр сервера)
    FNavigationNodeId := ServerCore.InstanceId;
    FNavigationNodeDevId := 0;

    // Установка времени начала работы серверного объекта
    CoFileTimeNow(FServerStartTime);
    LocalFileTimeToFileTime(FServerStartTime, FServerStartTime);

    // Отправка сообщения о создании нового серверного объекта
    PostMessage(Application.MainForm.Handle, WM_DA_SERVER_CREATED, Integer(self), 0);
    PostProcessInfoNow(70015, 'Подключение к серверу OPC DA.');

  except on e : Exception do
    PostLogRecordAddMsgNow(70151, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
  end;
end;

destructor TVpNetOPCDA.Destroy;
var
  Index : Integer;
  ObjList : TList;
  obj : TComObject;
  ShIntf : IOPCShutdown;
begin
  try
    PostProcessInfoNow(70016, 'Отключение от сервера OPC DA.');

    // Отправка сообщения об удалении серверного объекта
    SendMessage(Application.MainForm.Handle, WM_DA_SERVER_DESTROING, Integer(self), 0);

    // Очистка локальных групп
    if assigned(FGroups) then try
      FGroups.Free;
    except
    end;

    // Очистка общих групп
    if assigned(FPublicGroups) then try
  {
      Index := 0;
      while Index < FPublicGroups.Count do begin
        FPublicGroups.Items[Index].Free;
        Index := Index + 1;
      end;
  }
      FPublicGroups.Free;
    except
    end;

    // Удаление COM-объекта из корневой структуры сервера
    if assigned(ServerCore) then begin
      ObjList := ServerCore.ServerObjects.LockList;
      try
        ObjList.Remove(self);
      finally
        ServerCore.ServerObjects.UnlockList;
      end;
    end;

    // Удаление подключения к базе данных
    ServerCore.DBLock;
    try
      FRDM.Free;
    finally
      ServerCore.DBUnlock;
    end;

  except on e : Exception do
    PostLogRecordAddMsgNow(70152, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
  end;

  try
    inherited;
  except on e : Exception do
    PostLogRecordAddMsgNow(70153, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
  end;

end;
{
procedure TVpNetOPCDA.EventSinkChanged(const EventSink: IUnknown);
begin
  FShutdownIntf := EventSink as IOPCShutdown;
end;
}

procedure TVpNetOPCDA.CallBackOnConnect(const Sink: IUnknown; Connecting: Boolean);
begin
 try
   if connecting then
     FShutdownIntf := Sink as IOPCShutdown
   else
     FShutdownIntf := nil;
  except on e : Exception do
    PostLogRecordAddMsgNow(70062, LangId, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
  end;
end;


// IOpcCommon
function TVpNetOPCDA.SetLocaleID(dwLcid: TLCID): HResult;
var
  bLocaleIdIsValid : boolean;
  Index : Integer;
begin
  try
    PostLogRecordAddMsgNow(70781, -1, -1, S_OK, 'Вызов метода', llDebug);
{
    if not IsValidLocale(dwLcid, LCID_INSTALLED) then begin
      result := E_INVALIDARG;
      exit;
    end;
    LCID := dwLcid;
}

    bLocaleIdIsValid := false;
    Index := 0;
    while Index < ServerCore.ValidLocaleIDs.Count do begin
      if ServerCore.ValidLocaleIDs.IndexOf(Pointer(dwLcid)) >=0 then begin
        bLocaleIdIsValid := true;
        break;
      end;
      Index := Index + 1;
    end;

    if bLocaleIdIsValid then begin
      LCID := dwLcid;
      result := S_OK;
    end else begin
      PostLogRecordAddMsgNow(70064, dwLcid, -1, E_FAIL, 'Неправильное значение параметра dwLcid');
      result := E_INVALIDARG;
    end;
  except on e : Exception do begin
    result := E_FAIL;
    PostLogRecordAddMsgNow(70063, LangId, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
  end;
  end;
end;

function TVpNetOPCDA.GetLocaleID(out   pdwLcid: TLCID): HResult;
begin
  try
    PostLogRecordAddMsgNow(70782, -1, -1, S_OK, 'Вызов метода', llDebug);
    pdwLcid := LCID;
    result := S_OK;
  except on e : Exception do begin
    result := E_FAIL;
    PostLogRecordAddMsgNow(70065, pdwLcid, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
  end;
  end;
end;

function TVpNetOPCDA.QueryAvailableLocaleIDs(out   pdwCount: UINT; out pdwLcid: PLCIDARRAY): HResult; stdcall;
var
  dwIndex : DWORD;
{
  function cEnumLocalesProc(lpLocaleString : PChar) : Boolean;
  var
    qLocaleId : DWORD;
  begin
    qLocaleId := StrToIntDef(lpLocaleString, 0);
    if qLocaleId > 0 then begin
      FValidLocaleIDs.Add(Pointer(qLocaleId));
      result := true;
    end else begin
      result := false;
    end;
  end;
}
begin
  try
    PostLogRecordAddMsgNow(70783, -1, -1, S_OK, 'Вызов метода QueryAvailableLocaleIDs()', llDebug);
    // Получение списка установленных Locale
    {
    if not EnumSystemLocales(addr(cEnumLocalesProc), LCID_SUPPORTED) then begin
      result := E_FAIL;
      exit;
    end;
    }
    // Формирование выходного списка Locale
    pdwCount := ServerCore.ValidLocaleIDs.Count;
    if pdwCount > 0 then begin
      // Выделяем память под выходной массив
      pdwLcid := PLCIDARRAY(CoTaskMemAlloc(pdwCount*sizeof(LCID)));
      if (pdwLcid = nil) then begin
        // Если не смогли выделить память, возвращаем ошибку
        PostLogRecordAddMsgNow(70067, -1, -1, E_FAIL, 'ОШибка выделения памчти');
        result:=E_OUTOFMEMORY;
        Exit;
      end;

      // Заполняем выходной массив
      dwIndex := 0;
      while dwIndex < pdwCount do begin
        pdwLcid[dwIndex]:= TLCID(Integer(ServerCore.ValidLocaleIDs[dwIndex]));
        dwIndex := dwIndex + 1;
      end;
      result := S_OK;
    end else begin
      pdwLcid := nil;
      result := S_OK;
      exit;
    end;
  except on e : Exception do begin
    result := E_FAIL;
    PostLogRecordAddMsgNow(70066, pdwCount, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
  end;
  end;
end;

function TVpNetOPCDA.GetErrorString(dwError: HResult;out ppString: POleStr): HResult;
begin
  try
    PostLogRecordAddMsgNow(70784, -1, -1, S_OK, 'Вызов метода', llDebug);
    result := OPCErrorCodeToString(LCID, dwError, ppString);
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70068, dwError, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.SetClientName(szName: POleStr): HResult;
begin
  try
    PostLogRecordAddMsgNow(70785, -1, -1, S_OK, 'Вызов метода', llDebug);
    if @szName = nil then begin
      Result:=E_INVALIDARG;
      Exit;
    end;
    clientName:=szName;
    result:=S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70069, -1, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
    result := E_FAIL;
  end;
  end;
end;

// IOpcServer
function TVpNetOPCDA.AddGroup(
        szName:                     POleStr;
        bActive:                    BOOL;
        dwRequestedUpdateRate:      DWORD;
        hClientGroup:               OPCHANDLE;
        pTimeBias:                  PLongint;
        pPercentDeadband:           PSingle;
        dwLCID:                     DWORD;
  out   phServerGroup:              OPCHANDLE;
  out   pRevisedUpdateRate:         DWORD;
  const riid:                       TIID;
  out   ppUnk:                      IUnknown): HResult;
var
  sName : String;
  grp : TVpNetOPCGroup;
  siDeadband : Single;
  hr : HRESULT;
begin
  grp := nil;
  try
    PostLogRecordAddMsgNow(70786, -1, -1, S_OK, 'Вызов метода OPCDA.AddGroup', llDebug);

    // Начальная инициализация выходных данных
    phServerGroup := UnassignedGroupHandle;
    pRevisedUpdateRate := UnassignedGroupUpdateRate;
    ppUnk := nil;
    result := E_FAIL;


{09.07.2006}
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70072, -1, -1, E_FAIL, 'Неверное состяние сервера');
      exit;
    end;
{/09.07.2006}

    // Проверяем ИМЯ ГРУППЫ
    sName := szName;
    if sName = EmptyStr then begin
      // если в качестве имени группы передана пустая строка, пытаемся найти уникальное имя...
      sName := Groups.GetUniqueName;
      if sName = EmptyStr then begin
        // ... и если уникальное имя найти не удалось, выходим с E_FAIL
        PostLogRecordAddMsgNow(70073, -1, -1, E_FAIL, 'Невеное имя группы');
        exit;
      end;
    end else if ValidateOPCString(sName) <> S_OK then begin
      // если имя группы содержит недопустимые символы, возвращаем E_INVALIDARG
      PostLogRecordAddMsgNow(70074, -1, -1, E_FAIL, 'Невеное имя группы');
      result := E_INVALIDARG;
      exit;
    end else if Groups.IsNameUsed(sName) then begin
      // если имя группы уже используется, возвращаем OPC_E_DUPLICATENAME
      result := OPC_E_DUPLICATENAME;
      PostLogRecordAddMsgNow(70075, -1, -1, E_FAIL, 'Дублирование имени группы');
      exit;
    end;

    // ЧАСТОТА ОБНОВЛЕНИЯ
    pRevisedUpdateRate := ServerCore.GetRevisedGroupUpdateRate(dwRequestedUpdateRate);
    //
    if pRevisedUpdateRate <> dwRequestedUpdateRate then begin
      // Если возможная частота обновления не равна запрошенной,
      // устанавливаем результат функции равным OPC_S_UNSUPPORTEDRATE
      result := OPC_S_UNSUPPORTEDRATE;
    end;

    // DEADBAND
    if assigned(pPercentDeadband) then begin
      if (pPercentDeadband^ < 0) or (pPercentDeadband^ > 100) then begin
        PostLogRecordAddMsgNow(70076, -1, -1, E_FAIL, 'Невеное значение параметра Deadband = '+ FloatToStr(pPercentDeadband^));
        result := E_INVALIDARG;
        exit;
      end;
      siDeadband := pPercentDeadband^;
    end else begin
      // Если pPercentDeadband не определен, принимаем Deadband = 0
      siDeadband := 0.0;
    end;

    // Если Deadband выходит за допустимые значения, возвращаем E_INVALIDARG
    if (siDeadband < 0) or (siDeadband > 100) then begin
      PostLogRecordAddMsgNow(70077, -1, -1, E_INVALIDARG, 'Невеное значение параметра Deadband = ' + FloatToStr(siDeadband));
      result := E_INVALIDARG;
      phServerGroup := UnassignedGroupHandle;
      pRevisedUpdateRate := UnassignedGroupUpdateRate;
      ppUnk := nil;
      exit;
    end;

    // LCID
    // Проверяем допустимость LCID
    if ServerCore.ValidLocaleIDs.IndexOf(Pointer(dwLCID)) = -1 then begin
      // Если LCID , возвращаем E_INVALIDARG
      PostLogRecordAddMsgNow(70078, dwLCID, -1, E_INVALIDARG, 'Невеное значение параметра LCID');
      result := E_INVALIDARG;
      phServerGroup := UnassignedGroupHandle;
      pRevisedUpdateRate := UnassignedGroupUpdateRate;
      ppUnk := nil;
      exit;
    end;

    // SERVER GROUP HANDLE
    if ServerCore.GetNewServerGroupHandle(phServerGroup) <> S_OK then begin
      // Если не удалось получить новый серверный идентификатор группы,
      // возвращаем E_EAIL
      PostLogRecordAddMsgNow(70079, -1, -1, E_FAIL, 'Ошибка получения идентификатора группы');
      result := E_FAIL;
      phServerGroup := UnassignedGroupHandle;
      pRevisedUpdateRate := UnassignedGroupUpdateRate;
      ppUnk := nil;
      exit;
    end;

    // Создание экземпляра группы
//    TVpNetOPCGroup.CreateFromFactory();
    grp := TVpNetOPCGroup.Create(self, sName, bActive, pRevisedUpdateRate, hClientGroup, pTimeBias, siDeadband, dwLCID, phServerGroup);
    if grp = nil then begin
      // Если не удалось создать объект, возвращаем E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70080, -1, -1, E_OUTOFMEMORY, 'Ошибка выделения памяти');
      result := E_OUTOFMEMORY;
      phServerGroup := UnassignedGroupHandle;
      pRevisedUpdateRate := UnassignedGroupUpdateRate;
      ppUnk := nil;
      exit;
    end;
    // Запуса служебного потока группы
    TVpNetOPCGroupControlThread(grp.ControlThread).Resume;

    // передача вызывающей функции ссылки (ppUnk) на интерфейс (заданный в riid) группы (grp)
    hr := IUnknown(grp).QueryInterface(riid, ppUnk);
    if hr <> S_OK then begin
      // если не удалось получить указанный интерфейс, возвращаем E_NOINTERFACE
      PostLogRecordAddMsgNow(70081, hr, -1, E_NOINTERFACE, 'Ошибка интерфейса');
      grp.Free;
      result := E_NOINTERFACE;
      phServerGroup := UnassignedGroupHandle;
      pRevisedUpdateRate := UnassignedGroupUpdateRate;
      ppUnk := nil;
      exit;
    end;

    // Приращаем счетчик ссылок на объект-группу
    IUnknown(grp)._AddRef;
    // Добавляем ссылку на группу в список локальных групп сервера
    FGroups.Add(grp);

    if result <> OPC_S_UNSUPPORTEDRATE then
      result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70070, -1, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
    // В случае непредвиденной ошибки возвращаем E_FAIL
    if assigned(grp) then try
      grp.Free;
    except
      PostLogRecordAddMsgNow(70071, -1, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
    end;
    result := E_FAIL;
    phServerGroup := UnassignedGroupHandle;
    pRevisedUpdateRate := UnassignedGroupUpdateRate;
    ppUnk := nil;
  end;
  end;
end;

function TVpNetOPCDA.GetErrorString(
        dwError:                    HResult;
        dwLocale:                   TLCID;
  out   ppString:                   POleStr): HResult; stdcall;
begin
  try
    PostLogRecordAddMsgNow(70787, -1, -1, S_OK, 'Вызов метода', llDebug);
    result := OPCErrorCodeToString(LCID, dwError, ppString);
    //10.09.2005
//    Debug_DoRead();
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70082, dwError, dwLocale, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.GetGroupByName(
        szName:                     POleStr;
  const riid:                       TIID;
  out   ppUnk:                      IUnknown): HResult; stdcall;
var
  sName : String;
  iGroupIndex : Integer;
  grp : TVpNetOPCGroup;
  hr : HRESULT;
begin
  try
    PostLogRecordAddMsgNow(70788, -1, -1, S_OK, 'Вызов метода', llDebug);
{09.07.2006}
    // Начальные действия
    ppUnk := nil;
    result := E_FAIL;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70085, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера');
      exit;
    end;
{/09.07.2006}

    grp := nil;
    sName := szName;
    iGroupIndex := Groups.IndexOfName(sName);
    if iGroupIndex >= 0 then begin
      // Нашли группу в локальных группах
      grp := Groups[iGroupIndex];
    end;

    if not assigned(grp) then begin
      iGroupIndex := PublicGroups.IndexOfName(sName);
      if iGroupIndex >= 0 then begin
        // Нашли группу в общих группах
        grp := PublicGroups[iGroupIndex];
      end;
    end;

    // Если не нашли группу, возвращаем E_INVALIDARG
    if not assigned(grp) then begin
      PostLogRecordAddMsgNow(70086, -1, -1, E_INVALIDARG, 'Внутреннее событие');
      result := E_INVALIDARG;
      exit;
    end;

    hr := IUnknown(grp).QueryInterface(riid, ppUnk);
    if hr <> S_OK then begin
      // если не удалось получить указанный интерфейс, возвращаем E_NOINTERFACE
      PostLogRecordAddMsgNow(70087, hr, -1, E_NOINTERFACE, 'Внутреннее событие');
      result := E_NOINTERFACE;
      exit;
    end;

    // Возвращаем S_OK
    result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70084, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    // В случае непредвиденной ошибки возвращаем E_FAIL
    ppUnk := nil;
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.GetStatus(
  out   ppServerStatus:             POPCSERVERSTATUS): HResult; stdcall;
var
 vInfo : TRzVersionInfo;
 lProductVersion : TStringList;
 sVendorInfo : String;
begin
  try
    PostLogRecordAddMsgNow(70789, -1, -1, S_OK, 'Вызов метода GetStatus()', llDebug);
{09.07.2006}
    // Начальные действия
    ppServerStatus := nil;
    result := E_FAIL;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70089, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера');
      exit;
    end;
{/09.07.2006}

    // Если указатель на место, куда нужно передавать структуру не определен,
    // возвращаем E_INVALIDARG
    if not assigned(@ppServerStatus) then begin
      PostLogRecordAddMsgNow(70090, -1, -1, E_INVALIDARG, 'Внутреннее событие');
      result := E_INVALIDARG;
      exit;
    end;

    ppServerStatus := POPCSERVERSTATUS(CoTaskMemAlloc(sizeof(OPCSERVERSTATUS)));
    // Если не удалось выделить место под структуру, возвращаем E_OUTOFMEMORY
    if not assigned(ppServerStatus) then begin
      PostLogRecordAddMsgNow(70091, -1, -1, E_OUTOFMEMORY, 'Внутреннее событие');
      result := E_OUTOFMEMORY;
      exit;
    end;

    // Возвращаем параметры сервера ...
    ppServerStatus.ftStartTime := FServerStartTime;
    CoFiletimeNow(ppServerStatus.ftCurrentTime);
    LocalFileTimeToFileTime(ppServerStatus.ftCurrentTime, ppServerStatus.ftCurrentTime);
    ppServerStatus.ftLastUpdateTime := FLastClientUpdateTime;
    ppServerStatus.dwServerState := OPC_STATUS_RUNNING;
    ppServerStatus.dwGroupCount := Groups.Count + PublicGroups.Count;

    ppServerStatus.dwBandWidth := 100; //todo: Рассчитать

    // Получение строки с версией продукта
    vInfo := TRzVersionInfo.Create(nil);
    try
      vInfo.FilePath := Application.ExeName;
      // Возвращаем версию продукта
      lProductVersion := TStringList.Create;
      try
        lProductVersion.Delimiter := '.';
        lProductVersion.DelimitedText := vInfo.ProductVersion;
        try
          ppServerStatus.wMajorVersion := StrToInt(lProductVersion[0]);
          ppServerStatus.wMinorVersion := StrToInt(lProductVersion[1]);
          ppServerStatus.wBuildNumber := StrToInt(lProductVersion[3]);
        except on e : Exception do begin
          PostLogRecordAddMsgNow(70093, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
          CoTaskMemFree(ppServerStatus);
          result := E_FAIL;
          exit;
        end;
        end;
      finally
        lProductVersion.Free;
      end;

      // Возвращаем строку с названием производителя
(*
      LangId := aLCID and $FFFF;
      PrimaryLangId := (LangId and $3FF); // Младшие 10 бит LANGID
    if (PrimaryLangId = $009) {English} then
    else if (PrimaryLangId = $019) {Russian} then
      err_ := err_rus
    else
      err_ := err_eng;
*)
      if PrimaryLangId = LANG_RUSSIAN then begin
        sVendorInfo := 'ПП "НТФ МИТ"'; //vInfo.CompanyName
      end else begin
        sVendorInfo := 'NTF MIT';
      end;
      result := VpStringToLPOLESTR(sVendorInfo, ppServerStatus.szVendorInfo);
    finally
      vInfo.Free;
    end;

  except on e : Exception do begin
    // В случае непредвиденной ошибки возвращаем E_FAIL
    PostLogRecordAddMsgNow(70088, -1, -1, E_FAIL, 'Внутреннее событие');
    if assigned(ppServerStatus) then try
      CoTaskMemFree(ppServerStatus);
    except on e : Exception do
      PostLogRecordAddMsgNow(70094, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    end;
    ppServerStatus := nil;
    result := E_FAIL;
  end;
  end;
end;

//todo: Функция не проверена!
function TVpNetOPCDA.RemoveGroup(
  hServerGroup: OPCHANDLE;
  bForce: BOOL
): HResult; stdcall;
var
  grpIndex : Integer;
  grp : TVpNetOPCGroup;
begin
  try
    PostLogRecordAddMsgNow(70790, -1, -1, S_OK, 'Вызов метода', llDebug);
{09.07.2006}
    // Начальные действия
    result := E_FAIL;
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70096, Integer(ServerCore.State), -1, OPC_S_INUSE, 'Неверное состояние сервера');
      result := OPC_S_INUSE;
      exit;
    end;
{/09.07.2006}

    // Проверяем наличие группы с указанным серверным HANDLE-ом
    grpIndex := Groups.IndexOfServerHandle(hServerGroup);
    if grpIndex < 0 then begin
      // если такой группы нет, возвращаем E_INVALIDARG
      PostLogRecordAddMsgNow(70097, grpIndex, -1, E_INVALIDARG, 'Неверное обращение к группе');
      result:=E_INVALIDARG;
      Exit;
    end;

//    release
    // Проверяем возможность удаления группы
    //todo: Проверить правильность условия aGrp.RefCount > 2
//    if (grp.RefCount > 2) and not bForce then begin
//      // Если удалять ее нельзя, возвращаем OPC_S_INUSE
//      result:=OPC_S_INUSE;
//      Exit;
//    end;

    // Получаем ссылку на группу
    grp := Groups[grpIndex];
    // Удаление группы
    Groups.Delete(grpIndex);

{
    // Уменьшаем счетчик ссылок на объект-группу
    if grp.RefCount > 1 then begin
      IUnknown(grp)._Release;
      result := CoDisconnectObject(IUnknown(grp), 0);
    end else if grp.RefCount = 1 then begin
      IUnknown(grp)._Release;
      result := S_OK;
    end;
}
    result := CoDisconnectObject(IUnknown(grp), 0);
    grp.Free;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70095, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.CreateGroupEnumerator(
        dwScope:                    OPCENUMSCOPE;
  const riid:                       TIID;
  out   ppUnk:                      IUnknown): HResult; stdcall;
var
  lStrings : TStringList;
  lUnknowns : TVpNetOPCGroupList;

  procedure AddToUnknowns(inList : TVpNetOPCGroupList);
//  var
//    atuIndex : Integer;
//    Obj : Pointer;
  begin
    lUnknowns.Assign(inList, laOr);
//    atuIndex := 0;
//    while atuIndex < inList.count do begin
//      Obj:=nil;
//      IUnknown(TVpNetOPCGroup(inList[atuIndex])).QueryInterface(IUnknown,Obj);
//      if Assigned(Obj) then
//        lUnknowns.Add(Obj);
//      atuIndex := atuIndex + 1;
//    end;
  end;

  procedure AddToStrings(inList : TList);
  var
    atsIndex : integer;
  begin
    atsIndex := 0;
    while atsIndex < inList.Count do begin
      lStrings.Add(TVpNetOPCGroup(inList[atsIndex]).Name);
      atsIndex := atsIndex + 1;
    end;
  end;


begin
  try
    PostLogRecordAddMsgNow(70791, -1, -1, S_OK, 'Вызов метода', llDebug);
{09.07.2006}
    // Начальные действия
    ppUnk := nil;
    result := E_FAIL;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70099, Integer(ServerCore.State), -1, OPC_S_INUSE, 'Неверное состояние сервера');
      result := OPC_S_INUSE;
      exit;
    end;
{/09.07.2006}

    if IsEqualIID(riid,IEnumString) then begin
      // Если запрошен интерфейс IEnumString ...
      try
        // ... Формируем список строк ...
        lStrings := TStringList.Create;
        // ... и, в зависимости от dwScope, заполняем его имена ...
        case dwScope of
          OPC_ENUM_PRIVATE_CONNECTIONS,OPC_ENUM_PRIVATE: try
            // ... локальных групп ...
            AddToStrings(FGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70101, -1, -1, E_FAIL, 'Внутреннее событие');
          end;
          OPC_ENUM_PUBLIC_CONNECTIONS,OPC_ENUM_PUBLIC: try
            // ... общих групп ...
            AddToStrings(FPublicGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70102, -1, -1, E_FAIL, 'Внутреннее событие');
          end;
          OPC_ENUM_ALL_CONNECTIONS,OPC_ENUM_ALL: try
            // ... или всех групп ...
            AddToStrings(FGroups);
            AddToStrings(FPublicGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70103, -1, -1, E_FAIL, 'Внутреннее событие');
          end;
          else begin
            // ...(при неизвестном значении dwScope возвращаем E_INVALIDARG)...
            PostLogRecordAddMsgNow(70104, dwScope, -1, E_INVALIDARG, 'Внутреннее событие');
            ppUnk := nil;
            result := E_INVALIDARG;
            exit;
          end;
        end;
        // ..., затем формируем StringEnumerator ...
        ppUnk := TVpNetStringEnumerator.Create(lStrings);
        // ... и если StringEnumerator содержит элементы, ...
        if lStrings.Count > 0 then begin
          // ... возвращаем S_OK ...
          result := S_OK
        end else begin
          // ... иначе возвращаем S_FALSE.
          result := S_FALSE;
        end;

      finally
        lStrings.Free;
      end;
    end else if IsEqualIID(riid,IEnumUnknown) then begin
      // Если запрошен интерфейс IEnumUnknown ...
      try
        // ... создаем список ...
        lUnknowns := TVpNetOPCGroupList.Create;
        // ... и, в зависимости от dwScope, заполняем его ссылками на ...
        case dwScope of
          OPC_ENUM_PRIVATE_CONNECTIONS,OPC_ENUM_PRIVATE: try
            // ... локальные группы ...
            AddToUnknowns(FGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70105, -1, -1, E_FAIL, 'Внутреннее событие');
          end;
          OPC_ENUM_PUBLIC_CONNECTIONS,OPC_ENUM_PUBLIC: try
            // ... общие группы ...
            AddToUnknowns(FPublicGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70106, -1, -1, E_FAIL, 'Внутреннее событие');
          end;
          OPC_ENUM_ALL_CONNECTIONS,OPC_ENUM_ALL: try
            // ... или все группы ...
            AddToUnknowns(FGroups);
            AddToUnknowns(FPublicGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70107, -1, -1, E_FAIL, 'Внутреннее событие');
          end;
          else begin
            // ...(при неизвестном значении dwScope возвращаем E_INVALIDARG)...
            PostLogRecordAddMsgNow(70108, dwScope, -1, E_FAIL, 'Внутреннее событие');
            ppUnk := nil;
            result := E_INVALIDARG;
            exit;
          end;
        end;
        // ..., затем формируем UnknownEnumerator ...
        ppUnk := TVpNetUnknownEnumerator.Create(lUnknowns) as IUnknown;
        // ... и если UnknownEnumerator содержит элементы, ...
        if lUnknowns.Count > 0 then begin
          // ... возвращаем S_OK ...
          result := S_OK
        end else begin
          // ... иначе возвращаем S_FALSE.
          result := S_FALSE;
        end;
      finally
        lUnknowns.Free;
      end;
    end else begin
      // Если затребован неизвестный интерфейс, возвращаем E_NOINTERFACE
      PostLogRecordAddMsgNow(70100, -1, -1, E_NOINTERFACE, 'Ошибка интерфейса');
      ppUnk := nil;
      result := E_NOINTERFACE;
      exit;
    end;
//    result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70098, -1, -1, E_FAIL, 'Внутреннее событие' + e.Message);
    // При возникновении непредвиденной ошибки, возвращаем E_FAIL
    ppUnk := nil;
    result := E_FAIL;
  end;
  end;
end;

//IOPCBrowse = interface(IUnknown)
function TVpNetOPCDA.GetProperties(
        dwItemCount:                DWORD;
        pszItemIDs:                 POleStrList;
        bReturnPropertyValues:      BOOL;
        dwPropertyCount:            DWORD;
        pdwPropertyIDs:             PDWORDARRAY;
  out   ppItemProperties:           POPCITEMPROPERTIESARRAY): HResult;
var
  ItemIndex : DWORD;
  ErrCount : Integer;
//  hr : HRESULT;
  HostServerID,
  HostServerDriverID,
  DeviceID,
  DeviceTypeTagID : DWORD;
  pItemProps : POPCITEMPROPERTIES;
  qTags : TDataSet;
begin
  try
    PostLogRecordAddMsgNow(70793, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Начальная инициализация
    ppItemProperties := nil;

{09.07.2006}
    // Начальные действия
    result := E_FAIL;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70113, Integer(ServerCore.State), -1, OPC_S_INUSE, 'Неверное состояние сервера');
      result := OPC_S_INUSE;
      exit;
    end;
{/09.07.2006}


    // Если нет элементов в запросе, выходим с S_OK
    if dwItemCount = 0 then begin
      PostLogRecordAddMsgNow(70114, -1, -1, S_OK, 'Нет элементов в запросе');
      result := S_OK;
      exit;
    end;

    // Выделяем память для ppItemProperties
    ppItemProperties := POPCITEMPROPERTIESARRAY(CoTaskMemAlloc(dwItemCount * SizeOf(OPCITEMPROPERTIES)));

    // Если не удалось выделить память, выходим с E_OUTOFMEMORY
    if ppItemProperties = nil then begin
      PostLogRecordAddMsgNow(70115, -1, -1, E_OUTOFMEMORY, 'Ошибка выделения памяти');
      RESULT := E_OUTOFMEMORY;
      exit;
    end;

    // Проходим по списку запрошенных тегов
    ErrCount := 0; // Обнуляем счетчик ошибок
    ItemIndex := 0;
    while ItemIndex < dwItemCount do begin
      ppItemProperties^[ItemIndex].dwReserved :=0;
      ppItemProperties^[ItemIndex].hrErrorID := rdm.SplitItemID(pszItemIDs^[ItemIndex], HostServerID, HostServerDriverID, DeviceID, DeviceTypeTagID);
      ppItemProperties^[ItemIndex].dwNumProperties :=0;
      ppItemProperties^[ItemIndex].pItemProperties := POPCITEMPROPERTYARRAY(CoTaskMemAlloc(dwPropertyCount * SizeOf(OPCITEMPROPERTY)));
      pItemProps := @(ppItemProperties^[ItemIndex]);

      // Анализ типа итема
      if ppItemProperties^[ItemIndex].hrErrorID <> S_OK then begin
        // Случай ошибки при разборе итема: Оставляем пустой список свойств с полученной ошибкой
        ErrCount := Succ(ErrCount);
      end else if DeviceTypeTagID = 0 then begin
        // Случай 1: Возвращаем параметры корневого элемента ('root')
        //todo: Параметры
      end else if HostServerDriverID = 0 then begin
        // Случай 2: Возвращаем параметры хост-сервера
        //todo: Параметры
      end else if DeviceID = 0 then begin
        // Случай 3: Возвращаем параметры драйвера хост-сервера
        //todo: Параметры
      end else if DeviceTypeTagID = 0 then begin
        // Случай 4: Возвращаем параметры устройства
        //todo: Параметры
      end else begin
        // Случай 5: Возвращаем параметры тега устройства
//      pItemProps^.hrErrorID

        rdm.Lock;
        try
          qTags := rdm.GetQueryDataset(
            'select vdtt.vdtt_id, vdtt.vdtt_tag, vdtt.vdtt_name, vdt.VDT_VAR_TYPE, ' +
            'vdtt.vdtt_eu_type, vdtt.vdtt_access_rights ' +
            'from vda_device_type_tags vdtt ' +
            'left outer join vn_datatypes vdt on vdtt.vdt_id = vdt.vdt_id ' +
            'where vdtt.vdtt_id = ' + rdm.IntToSQL(DeviceTypeTagID, '0')
          );
          try
            // Запрашиваем совйства тега ...
            qTags.Open;
            // Заполняем pItemProps
            result := FillPOPCITEMPROPERTIES(pItemProps, pszItemIDs^[ItemIndex], bReturnPropertyValues, qTags);
            if result <> S_OK then begin
              PostLogRecordAddMsgNow(70116, -1, -1, result, 'Внутреннее событие');
              exit;
            end;
          finally
            qTags.Free;
          end;
        finally
          rdm.Unlock;
        end;
      end;

      ItemIndex := Succ(ItemIndex);
    end;

    // Если основной цикл завершился успешно
    if ErrCount = 0 then
      //и если небыло ошибок в элементах, возвращаем S_OK
      result := S_OK
    else
      //если ошибик в элементах были, возвращаем S_FALSE
      result := S_FALSE;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70112, result, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    // В случае непредвиденной ошибки ...
    // ... если память была выделена, освобождаем ее, ...
    if assigned(ppItemProperties) then begin
      CoTaskMemFree(ppItemProperties);
      ppItemProperties := nil;
    end;
    // ... и возвращаем E_FAIL
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.FillPOPCITEMPROPERTIES(
  pItemProps : POPCITEMPROPERTIES;
  szItemID : POleStr;
  bReturnPropertyValues : BOOL;
  qTags : TDataSet
): HRESULT;
var
  v : Variant;
  Item : TVpNetOPCItem;
  si : SmallInt;
  dw : DWORD;
  i : Integer;
  qEnumValues : TDataSet;
  hr : HRESULT;
  s : String;
  tagHostServer : String; // Тег Хост-сервера
  tagHostServerDriver : String; // Тег драйвера хост-сервера
  tagDevice : String; // Тег устройства
  tagDeviceTypeTag : String; // Тег тега типа устройства :)

  sl : TStringList;
  c : Char;
  dsTagParams : TDataSet;
  ds : TDataSet;
  i2 : Integer;
begin
  try
    PostLogRecordAddMsgNow(70792, -1, -1, S_OK, 'Вызов метода FillPOPCITEMPROPERTIES(szItemID = '+szItemID+')', llDebug);
    // Разбираем
    result := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag, false);

    // Если есть ошибкти разбора, возвращаем полученную ошибку
    if result <> S_OK then begin
      PostLogRecordAddMsgNow(70110, result, -1, E_FAIL, 'Неправильный тег ' + szItemId);
      exit;
    end;

    // Заполняем ItemPorperties
    pItemProps^.hrErrorID := S_OK; // Признак состяния списка свойств элемента
    pItemProps^.dwNumProperties := 7; {"встроенных"}
{28.08.2007}
//    v := rdm.GetOneCell('select count(*) from vn_tag_properties where vdtt_id = ' + rdm.IntToSQL(qTags.FieldByName('vdtt_id').AsInteger, '-1'));
//    if VarIsOrdinal(v) then
//      pItemProps^.dwNumProperties := pItemProps^.dwNumProperties + v{Стандартных};
    ds := rdm.GetQueryDataset(
      'select vtp2.vdtt_id, vtp2.vtpi_id, count(vtp2.vd_id) from vn_tag_properties vtp2 ' +
      'where vtp2.vdtt_id = ' + rdm.IntToSQL(qTags.FieldByName('vdtt_id').AsInteger, '-1') + ' ' +
      'group by vtp2.vdtt_id, vtp2.vtpi_id '
    );
    try
      ds.Open;
      i2 := ds.RecordCount;
    finally
      ds.free;
    end;
    pItemProps^.dwNumProperties := pItemProps^.dwNumProperties + DWORD(i2){Стандартных};
{/28.08.2007}
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70767, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // Выделяем место для dwNumProperties свойств
    pItemProps^.pItemProperties :=
      POPCITEMPROPERTYARRAY(CoTaskMemAlloc(pItemProps^.dwNumProperties * sizeof(OPCITEMPROPERTY)));
    // Если не удалось выделить память для списка свойств, выходим с ошибкой
    if pItemProps^.pItemProperties = nil then begin
      PostLogRecordAddMsgNow(70111, result, -1, E_FAIL, 'Внутреннее событие');
      pItemProps^.hrErrorID := S_FALSE;
      result := E_OUTOFMEMORY;
      exit;
    end;
    pItemProps^.dwReserved := 0;

    // Ищем элемент в группах
    hr := FindFirstItemByItemId(szItemID, Pointer(Item));

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70768, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // Вносим в список "встроенные" параметры
    // - "Item Canonical data type" ------------------------------------
    pItemProps^.pItemProperties^[0].vtDataType := VT_I2;
    pItemProps^.pItemProperties^[0].wReserved := 0;
    pItemProps^.pItemProperties^[0].dwPropertyID := OPC_PROPERTY_DATATYPE;
    pItemProps^.pItemProperties^[0].szItemID := StringToOleStr(szItemID + '.CAN_DATATYPE');
    pItemProps^.pItemProperties^[0].szDescription := StringToOleStr(OPC_PROPERTY_DESC_DATATYPE);
    VariantInit(pItemProps^.pItemProperties^[0].vValue);
    // Если был запрос на возврат значений свойств, ...
    if bReturnPropertyValues then begin
      // возвращаем значение из базы данных,
      si := qTags.FieldByName('VDT_VAR_TYPE').AsInteger and $7fff;
      pItemProps^.pItemProperties^[0].vValue := VarAsType(si, varSmallint);
    end else begin
      // если запроса небыло, возвращаем Null
      pItemProps^.pItemProperties^[0].vValue := Null;
    end;

    pItemProps^.pItemProperties^[0].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[0].dwReserved := 0;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70769, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // - "Value" -------------------------------------------------------
    pItemProps^.pItemProperties^[1].vtDataType := qTags.FieldByName('VDT_VAR_TYPE').AsInteger;
    pItemProps^.pItemProperties^[1].wReserved := 0;
    pItemProps^.pItemProperties^[1].dwPropertyID := OPC_PROPERTY_VALUE;
    pItemProps^.pItemProperties^[1].szItemID := StringToOleStr(szItemID + '.VALUE');
    pItemProps^.pItemProperties^[1].szDescription := StringToOleStr(OPC_PROPERTY_DESC_VALUE);
    VariantInit(pItemProps^.pItemProperties^[1].vValue);
    // Если был запрос на возврат значений свойств, ...
    if bReturnPropertyValues then begin
      // Если мы нашли данный элемент в списке тегов групп,
      if assigned(Item) then
        // берем значение оттуда,
        pItemProps^.pItemProperties^[1].vValue := VarAsType(Item.Value, pItemProps^.pItemProperties^[1].vtDataType)
      else
        // иначе возвращаем Unassigned
        pItemProps^.pItemProperties^[1].vValue := Null;
    end else begin
      // если щапроса небыло, возвращаем Null
      pItemProps^.pItemProperties^[1].vValue := Null;
    end;
    pItemProps^.pItemProperties^[1].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[1].dwReserved := 0;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70770, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // - "Item Quality" ------------------------------------------------
    pItemProps^.pItemProperties^[2].vtDataType := VT_I2;
    pItemProps^.pItemProperties^[2].wReserved := 0;
    pItemProps^.pItemProperties^[2].dwPropertyID := OPC_PROPERTY_QUALITY;
    pItemProps^.pItemProperties^[2].szItemID := StringToOleStr(szItemID + '.QUALITY');
    pItemProps^.pItemProperties^[2].szDescription := StringToOleStr(OPC_PROPERTY_DESC_QUALITY);
    VariantInit(pItemProps^.pItemProperties^[2].vValue);
    // Если был запрос на возврат значений свойств, ...
    if bReturnPropertyValues then begin
      // Если мы нашли данный элемент в списке тегов групп,
      if assigned(Item) then
        // берем значение оттуда,
        pItemProps^.pItemProperties^[2].vValue := VarAsType(Item.Quality, VT_I2)
      else
        // иначе возвращаем Unassigned
        pItemProps^.pItemProperties^[2].vValue := Null;
    end else begin
      // если щапроса небыло, возвращаем Null
      pItemProps^.pItemProperties^[2].vValue := Null;
    end;
    pItemProps^.pItemProperties^[2].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[2].dwReserved := 0;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70771, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // - "Item timestamp" ----------------------------------------------
    pItemProps^.pItemProperties^[3].vtDataType := VT_DATE;
    pItemProps^.pItemProperties^[3].wReserved := 0;
    pItemProps^.pItemProperties^[3].dwPropertyID := OPC_PROPERTY_TIMESTAMP;
    pItemProps^.pItemProperties^[3].szItemID := StringToOleStr(szItemID + '.TIMESTANP');
    pItemProps^.pItemProperties^[3].szDescription := StringToOleStr(OPC_PROPERTY_DESC_TIMESTAMP);
    VariantInit(pItemProps^.pItemProperties^[3].vValue);
    // Если был запрос на возврат значений свойств, ...
    if bReturnPropertyValues then begin
      // Если мы нашли данный элемент в списке тегов групп,
      if assigned(Item) then
        // берем значение оттуда,
        pItemProps^.pItemProperties^[3].vValue := VarAsType(FileTimeToDateTime(Item.Timestamp), VT_DATE)
      else
        // иначе возвращаем Null
        pItemProps^.pItemProperties^[3].vValue := Null;
    end else begin
      // если щапроса небыло, возвращаем Null
      pItemProps^.pItemProperties^[3].vValue := Null;
    end;
    pItemProps^.pItemProperties^[3].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[3].dwReserved := 0;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70772, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // - "Item access rights" ------------------------------------------
    pItemProps^.pItemProperties^[4].vtDataType := VT_I4;
    pItemProps^.pItemProperties^[4].wReserved := 0;
    pItemProps^.pItemProperties^[4].dwPropertyID := OPC_PROPERTY_ACCESS_RIGHTS;
    pItemProps^.pItemProperties^[4].szItemID := StringToOleStr(szItemID + '.ACCESS_RIGHTS');
    pItemProps^.pItemProperties^[4].szDescription := StringToOleStr(OPC_PROPERTY_DESC_ACCESS_RIGHTS);
    VariantInit(pItemProps^.pItemProperties^[4].vValue);
    // Если был запрос на возврат значений свойств, ...
    if bReturnPropertyValues then begin
      // Если мы нашли данный элемент в списке тегов групп,
      if assigned(Item) then begin
        // берем значение оттуда,
        pItemProps^.pItemProperties^[4].vValue := VarAsType(Item.AccessRights, VT_I4);
      end else begin
        // иначе возвращаем значения из базы
        dw := 0;
        if (qTags.FieldByName('vdtt_access_rights').AsInteger and OPC_READABLE) > 0 then
          dw := dw + OPC_READABLE;
        if (qTags.FieldByName('vdtt_access_rights').AsInteger and OPC_WRITEABLE) > 0 then
          dw := dw + OPC_WRITEABLE;
        pItemProps^.pItemProperties^[4].vValue := VarAsType(dw, VT_I4);
      end;
    end else begin
      // если щапроса небыло, возвращаем Null
      pItemProps^.pItemProperties^[4].vValue := Null;
    end;
    pItemProps^.pItemProperties^[4].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[4].dwReserved := 0;

    // - "Server Scan Rate" (Не поддерживается)
    //todo: Доделать

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70773, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // - "Item EU Type" -----------------------------------------------------------
    pItemProps^.pItemProperties^[5].vtDataType := VT_I4;
    pItemProps^.pItemProperties^[5].wReserved := 0;
    pItemProps^.pItemProperties^[5].dwPropertyID := OPC_PROPERTY_EU_TYPE;
    pItemProps^.pItemProperties^[5].szItemID := StringToOleStr(szItemID + '.EU_TYPE');
    pItemProps^.pItemProperties^[5].szDescription := StringToOleStr(OPC_PROPERTY_DESC_EU_TYPE);
    pItemProps^.pItemProperties^[5].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[5].dwReserved := 0;
    VariantInit(pItemProps^.pItemProperties^[5].vValue);
    pItemProps^.pItemProperties^[5].vValue := VarAsType(qTags.FieldByName('VDTT_EU_TYPE').AsInteger, VT_I4);

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70774, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // - "Item EU Info" -----------------------------------------------------------
    pItemProps^.pItemProperties^[6].vtDataType := VT_I4;
    pItemProps^.pItemProperties^[6].wReserved := 0;
    pItemProps^.pItemProperties^[6].dwPropertyID := OPC_PROPERTY_EU_INFO;
    pItemProps^.pItemProperties^[6].szItemID := StringToOleStr(szItemID + '.EU_INFO');
    pItemProps^.pItemProperties^[6].szDescription := StringToOleStr(OPC_PROPERTY_DESC_EU_INFO);
    pItemProps^.pItemProperties^[6].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[6].dwReserved := 0;
    VariantInit(pItemProps^.pItemProperties^[6].vValue);

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70775, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // Если был запрос на возврат значений свойств, ...
    if bReturnPropertyValues then begin
      rdm.Lock;
      try
        qEnumValues := rdm.GetQueryDataset(
          'select vei.vei_mask, vei.vei_value, vei.vei_text from vn_eu_info vei ' +
          'where ( ' +
          '        (vei.vd_id is null) or ' +
          '        (vei.vd_id = ( ' +
          '            select vd.vd_id ' +
          '            from vn_host_servers vhs, vn_host_server_drivers vhsd, vda_devices vd ' +
          '            where vhsd.vhs_id = vhs.vhs_id and vd.vhsd_id = vhsd.vhsd_id and ' +
          '            vhs.vhs_tag = ''' + tagHostServer + ''' and ' +
          '            vhsd.vhsd_tag = ''' + tagHostServerDriver + ''' and ' +
          '            vd.vd_tag = ''' + tagDevice + ''' ' +
          '          ) ' +
          '        ) ' +
          '      ) and ' +
          '      (vei.vdtt_id = ' + rdm.IntToSQL(qTags.FieldByName('VDTT_ID').AsInteger, '-1') + ') ' +
          'order by vei.vei_value '
        );
        try
          qEnumValues.Open;
          if not qEnumValues.Eof then begin
            // Если выборка не пустая, значит будем возвращать VarArray
            pItemProps^.pItemProperties^[6].vtDataType := VT_ARRAY;
            sl := TStringList.Create;
            try
               // заполняем список значений
              while not qEnumValues.Eof do begin
                // если номер элемента меньше 100
                if qEnumValues.FieldByName('vei_value').AsInteger < 100 then begin
                  // увеличиваем размер массива до необходимой величины
                  while sl.Count <= qEnumValues.FieldByName('vei_value').AsInteger do sl.Add('');
                  // и сохраняем элемент с его номером
                  sl[qEnumValues.FieldByName('vei_value').AsInteger] := qEnumValues.FieldByName('vei_text').AsString;
                end;
                qEnumValues.Next;
              end;
              case qTags.FieldByName('VDTT_EU_TYPE').AsInteger of
                OPC_ANALOG: begin
                  // Аналоговое значение
                  // записываем в EUInfo вариантный массив значений типа vt_r8
                  pItemProps^.pItemProperties^[6].vValue := VarArrayCreate([0, sl.Count - 1], varDouble);
                  i := 0;
                  while i < sl.Count do begin
    //                                      GetLocaleFormatSettings(LCID, FmtSets);
    //                                      FmtSets.DecimalSeparator := '.';
                    c := DecimalSeparator;
                    DecimalSeparator := '.';
                    pItemProps^.pItemProperties^[6].vValue[i] := StrToFloatDef(sl[i], 0.{, FmtSets});
                    DecimalSeparator := c;
                    i := Succ(i);
                  end;
                end;
                OPC_ENUMERATED: begin
                  // Перечислимое значение
                  // записываем в EUInfo вариантный массив строк
                  pItemProps^.pItemProperties^[6].vValue := VarArrayCreate([0, sl.Count - 1], varOleStr);
                  i := 0;
                  while i < sl.Count do begin
                    pItemProps^.pItemProperties^[6].vValue[i] := sl[i];
                    i := Succ(i);
                  end;
                end;
                else begin
                  // OPC_NOENUM или другое значение
                  pItemProps^.pItemProperties^[6].vtDataType := VT_EMPTY;
                  VariantChangeType(pItemProps^.pItemProperties^[6].vValue, pItemProps^.pItemProperties^[6].vValue, 0, VT_EMPTY);
                  pItemProps^.pItemProperties^[6].vValue := NULL;
                end;
              end;
            finally
              sl.Free;
            end;
          end else begin
            // Если выборка пустая, значит будем возвращать VT_EMPTY
            pItemProps^.pItemProperties^[6].vtDataType := VT_EMPTY;
            VariantChangeType(pItemProps^.pItemProperties^[6].vValue, pItemProps^.pItemProperties^[6].vValue, 0, VT_EMPTY);
            pItemProps^.pItemProperties^[6].vValue := NULL;
          end;
        finally
          qEnumValues.Free;
        end;
      finally
        rdm.Unlock;
      end;
    end else begin
      // если запроса небыло, возвращаем Null
      pItemProps^.pItemProperties^[6].vtDataType := VT_EMPTY;
      VariantChangeType(pItemProps^.pItemProperties^[6].vValue, pItemProps^.pItemProperties^[6].vValue, 0, VT_EMPTY);
      pItemProps^.pItemProperties^[6].vValue := Null;
    end;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70776, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // Стандартные параметры тега из базы данных -----------------------
    rdm.Lock;
    try
      dsTagParams := rdm.GetQueryDataset(
        'select ' +
        'vdt.vdt_var_type, ' +
        'vtpi.vtpi_property_id, ' +
        'vtpi.VTPI_TAG, ' +
        'vtpi.VTPI_TEXT, ' +
        'vtp.vtp_value ' +
        'from vn_tag_properties vtp ' +
        'left outer join vn_tag_property_ids vtpi on vtpi.vtpi_id = vtp.vtpi_id ' +
        'left outer join vn_datatypes vdt on vdt.vdt_id = vtpi.vdt_id ' +
        'where vtp.vdtt_id = ' + rdm.IntToSQL(qTags.FieldByName('VDTT_ID').AsInteger, '-1') + ' ' +
        'order by vtpi.vtpi_property_id '
      );
      try
        dsTagParams.Open;
        dw := 7;
        while not dsTagParams.Eof do begin
          pItemProps^.pItemProperties^[dw].vtDataType := dsTagParams.FieldByName('vdt_var_type').AsInteger;
          pItemProps^.pItemProperties^[dw].wReserved := 0;
          pItemProps^.pItemProperties^[dw].dwPropertyID := dsTagParams.FieldByName('vtpi_property_id').AsInteger;
          s := szItemID;
          pItemProps^.pItemProperties^[dw].szItemID := StringToOleStr(s +  '.' + dsTagParams.FieldByName('VTPI_TAG').AsString);
          pItemProps^.pItemProperties^[dw].szDescription := StringToOleStr(dsTagParams.FieldByName('VTPI_TEXT').AsString);
          pItemProps^.pItemProperties^[dw].hrErrorID := S_OK;
          pItemProps^.pItemProperties^[dw].dwReserved := 0;
          VariantInit(pItemProps^.pItemProperties^[dw].vValue);
          c := DecimalSeparator;
          DecimalSeparator := '.';
          try
            pItemProps^.pItemProperties^[dw].vValue := VarAsType(dsTagParams.FieldByName('vtp_value').AsString, dsTagParams.FieldByName('vdt_var_type').AsInteger);
          except
            pItemProps^.pItemProperties^[dw].vValue := null;
          end;
          DecimalSeparator := c;
          dw := Succ(dw);
          dsTagParams.Next;
        end;
      finally
        dsTagParams.Free;
      end;
    finally
      rdm.Unlock;
    end;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70109, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.Browse(
        szItemID:                   POleStr;
  var   pszContinuationPoint:       POleStr;
        dwMaxElementsReturned:      DWORD;
        dwBrowseFilter:             OPCBROWSEFILTER;
        szElementNameFilter:        POleStr;
        szVendorFilter:             POleStr;
        bReturnAllProperties:       BOOL;
        bReturnPropertyValues:      BOOL;
        dwPropertyCount:            DWORD;
        pdwPropertyIDs:             PDWORDARRAY;
  out   pbMoreElements:             BOOL;
  out   pdwCount:                   DWORD;
  out   ppBrowseElements:           POPCBROWSEELEMENTARRAY):
        HResult;
var
  tagHostServer : String; // Тег Хост-сервера
  tagHostServerDriver : String; // Тег драйвера хост-сервера
  tagDevice : String; // Тег устройства
  tagDeviceTypeTag : String; // Тег тега типа устройства :)
  hr : HRESULT;
  ds : TDataSet;
  dsTags : TDataSet;
  dwElementCount : DWORD;
  ElementIndex : DWORD;
  sSQL : String;
  pItemProps : POPCITEMPROPERTIES;
begin
  try
    PostLogRecordAddMsgNow(70794, -1, -1, S_OK, 'Вызов метода Browse(...)', llDebug);
    // Начальная инициализация выходных данных
    pbMoreElements := false; // По умолчанию считаем, возврат элементов закончен
    pdwCount := 0; // По умолчанию не возвращаем элементов
    ppBrowseElements := nil; // По умолчанию не возвращаем элементов
    result := S_OK;

{09.07.2006}
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70118, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера');
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // разбираем szItemId
    //todo: заменить тип аргументов функции SplitItemID() с String на POleStr

// 28.09.2010
//    hr := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag);
    hr := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag, false);
///28.09.2010

// 28.09.2010
//    if hr <> S_OK then begin
    if hr < S_OK then begin
///28.09.2010
      PostLogRecordAddMsgNow(70119, hr, -1, E_FAIL, 'Неправильный тег "' + szItemId +'"');
      exit;
    end;

    // Анализ компонентов szItemId
    if tagHostServer = EmptyStr then begin
      // Случай 1: Обзор корневого элемента ('root')

      // Готовим маску запроса списка хост серверов
      sSQL := 'from vn_host_servers vhs ';
      // Если был указан ContinuationPoint, то считаем количество доступных
      // хост-серверов начиная с указанного в pszContinuationPoint
      if pszContinuationPoint <> EmptyStr then
        sSQL := sSQL +
          'where vhs.vhs_id >= ( ' +
          'select vhs2.vhs_id from vn_host_servers vhs2 ' +
          'where vhs2.vhs_tag = ''' + pszContinuationPoint + ''') ';

      // Получаем количество доступных хост-серверов сервера
      dwElementCount := rdm.GetOneCell('select count(*) ' + sSQL);

      // Сортируем по идентификаторам хост-серверов
      sSQL := sSQL + 'order by vhs.vhs_id ';

      // Проверяем, можно ли возвращать столько элементов и есть ли ограничения
      // на количество элементов вообще
      if (dwMaxElementsReturned = 0) or (dwElementCount <= dwMaxElementsReturned) then begin
        // если можно вернуть сразу все элементы (или нет таких
        // клиентских ограничений), возвращаем вес элементы
        pdwCount := dwElementCount;
        pbMoreElements := false;
      end else begin
        // иначе возвращаем максимально разрешенное количество элементов
        pdwCount := dwMaxElementsReturned;
        pbMoreElements := true;
      end;

      // Если ведется поиск только элементов (не веток) возвращаем пустой список
      if (dwBrowseFilter = OPC_BROWSE_FILTER_ITEMS) then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // Если указан szElementNameFilter, возвращаем пустую выборку
      //todo: Реализовать фильтрацию по szElementNameFilter
      if szElementNameFilter <> EmptyStr then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // Если указан szVendorFilter, возвращаем пустую выборку
      //todo: Реализовать фильтрацию по szVendorFilter
      if szVendorFilter <> EmptyStr then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // Если есть доступные элементы,...
      if pdwCount > 0 then begin
        // ... выделяем память для передачи pdwCount элементов типа OPCBROWSEELEMENT
        ppBrowseElements := POPCBROWSEELEMENTARRAY(CoTaskMemAlloc(pdwCount * sizeof(OPCBROWSEELEMENT)));

        // Если память выделить не удалось, выходим с ошибкой
        if ppBrowseElements = nil then begin
          PostLogRecordAddMsgNow(70120, hr, -1, E_OUTOFMEMORY, 'Ошибка памяти');
          pdwCount := 0;
          pbMoreElements := false;
          result := E_OUTOFMEMORY;
          exit;
        end;

        // Готовим список доступных хост-серверов сервера
        rdm.Lock;
        try
          ds := rdm.GetQueryDataset('select vhs_id, vhs_tag, vhs_text ' + sSQL);
          try
            // Запрашиваем список хост-серверов ...
            ds.Open;
            // Проходим по полученным записям
            ElementIndex := 0;
            ds.First;
            while (not ds.Eof) and (ElementIndex < pdwCount) do begin
              // добавляем очередную запись
              ppBrowseElements^[ElementIndex].szName := StringToOleStr(ds.FieldByName('vhs_text').AsString);
              ppBrowseElements^[ElementIndex].szItemID := StringToOleStr(ds.FieldByName('vhs_tag').AsString);
              // Данный элемент является веткой и не является элементом данных
              ppBrowseElements^[ElementIndex].dwFlagValue := OPC_BROWSE_HASCHILDREN;
              ppBrowseElements^[ElementIndex].dwReserved := 0;
              // У хост серверов сервера пока нет параметров
              //todo: Получить параметры хост-сервера
              ppBrowseElements^[ElementIndex].ItemProperties.hrErrorID := S_OK;
              ppBrowseElements^[ElementIndex].ItemProperties.dwNumProperties := 0;
              ppBrowseElements^[ElementIndex].ItemProperties.pItemProperties := nil;
              ppBrowseElements^[ElementIndex].ItemProperties.dwReserved :=0;

              // Переходим к следующему элементу
              ElementIndex := Succ(ElementIndex);
              ds.Next;
            end;
            // Если вернули не все, возвращаем ContinuationPoint
            if not ds.Eof then begin
              pszContinuationPoint := StringToOleStr(ds.FieldByName('vhs_tag').AsString);
            end;
          finally
            ds.free;
          end;
        finally
          rdm.Unlock;
        end;
      end;
    end else if tagHostServerDriver = EmptyStr then begin
      // Случай 2: Обзор хост-сервера (обзор драйверов хост-сервера)
      // Готовим маску запроса списка драйверов хост сервера
      sSQL :=
        'from vn_host_server_drivers vhsd ' +
        'where vhs_id = ( ' +
        '  select vhs.vhs_id from vn_host_servers vhs ' +
        '  where vhs.vhs_tag = '''+ tagHostServer +''') ';
      // Если был указан ContinuationPoint, то считаем количество доступных
      // драйверов хост-сервера начиная с указанного в pszContinuationPoint
      if pszContinuationPoint <> EmptyStr then
        sSQL := sSQL +
        '  and vhsd.vhsd_id >= ( ' +
        '    select vhsd2.vhsd_id from vn_host_server_drivers vhsd2 ' +
        '    where vhsd2.vhsd_tag = ''' + pszContinuationPoint + ''') ';

      // Получаем количество доступных драйверов хост-серверов
      dwElementCount := rdm.GetOneCell('select count(*) ' + sSQL);

      // Сортируем по идентификаторам драйверов хост-сервера
      sSQL := sSQL + 'order by vhsd.vhsd_id ';

      // Проверяем, можно ли возвращать столько элементов и есть ли ограничения на количество элементов вообще
      if (dwMaxElementsReturned = 0) or (dwElementCount <= dwMaxElementsReturned) then begin
        // если можно вернуть сразу все элементы (или нет таких клиентских ограничений), так и делаем
        pdwCount := dwElementCount;
        pbMoreElements := false;
      end else begin
        // иначе будем возвращать максимально разрешенное количество элементов
        pdwCount := dwMaxElementsReturned;
        pbMoreElements := true;
      end;

      // Если ведется поиск только элементов (не веток) возвращаем пустой список
      if (dwBrowseFilter = OPC_BROWSE_FILTER_ITEMS) then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // Если есть доступные элементы,...
      if pdwCount > 0 then begin
        // ... выделяем память для передачи pdwCount элементов типа OPCBROWSEELEMENT
        ppBrowseElements := POPCBROWSEELEMENTARRAY(CoTaskMemAlloc(pdwCount * sizeof(OPCBROWSEELEMENT)));

        // Если память выделить не удалось, выходим с ошибкой
        if ppBrowseElements = nil then begin
          PostLogRecordAddMsgNow(70121, hr, -1, E_OUTOFMEMORY, 'Ошибка памяти');
          pdwCount := 0;
          pbMoreElements := false;
          result := E_OUTOFMEMORY;
          exit;
        end;

        // Готовим список доступных хост-серверов сервера
        rdm.Lock;
        try
          ds := rdm.GetQueryDataset('select vhsd.vhsd_id, vhsd.vhsd_tag, vhsd.vhsd_text ' + sSQL);
          try
            // Запрашиваем список хост-серверов ...
            ds.Open;
            // Проходим по полученным записям
            ElementIndex := 0;
            ds.First;
            while (not ds.Eof) and (ElementIndex < pdwCount) do begin
              // добавляем очередную запись
              ppBrowseElements^[ElementIndex].szName := StringToOleStr(ds.FieldByName('vhsd_text').AsString);
              ppBrowseElements^[ElementIndex].szItemID := StringToOleStr(tagHostServer + '.' + ds.FieldByName('vhsd_tag').AsString);
              // Данный элемент является веткой и не является элементом данных
              ppBrowseElements^[ElementIndex].dwFlagValue := OPC_BROWSE_HASCHILDREN;
              ppBrowseElements^[ElementIndex].dwReserved := 0;
              // Заполняем ItemPorperties
              ppBrowseElements^[ElementIndex].ItemProperties.hrErrorID := S_OK; // Признак состяния списка свойств элемента
              ppBrowseElements^[ElementIndex].ItemProperties.dwNumProperties := 0; // Пока у драйвера хост-сервера свойств нет.
              ppBrowseElements^[ElementIndex].ItemProperties.pItemProperties := nil;
              ppBrowseElements^[ElementIndex].ItemProperties.dwReserved := 0;
              // Переходим к следующему элементу
              ElementIndex := Succ(ElementIndex);
              ds.Next;
            end;
            // Если вернули не все, возвращаем ContinuationPoint
            if not ds.Eof then begin
              pszContinuationPoint := StringToOleStr(ds.FieldByName('vhsd_tag').AsString);
            end;
          finally
            ds.free;
          end;
        finally
          rdm.Unlock;
        end;
      end;
    end else if tagDevice = EmptyStr then begin
      // Случай 3: Обзор драйвера хост-сервера (обзор устройств драйвера хост-сервера)
      // Готовим маску запроса списка устройств драйвера хост сервера
      sSQL :=
        'from vda_devices vd ' +
        'where ' +
        '  vd.vhsd_id = ( ' +
        '    select vhsd.vhsd_id from vn_host_server_drivers vhsd ' +
        '    where vhsd.vhsd_tag = ''' + tagHostServerDriver + ''') ';
      // Если был указан ContinuationPoint, то считаем количество доступных
      // устройств драйвера хост-сервера начиная с указанного в pszContinuationPoint
      if pszContinuationPoint <> EmptyStr then
        sSQL := sSQL +
          '  and vd.vd_id >= ( ' +
          '    select vd2.vd_id from vda_devices vd2 ' +
          '    where vd2.vd_tag = ''' + pszContinuationPoint + ''') ';

      // Получаем количество доступных устройств драйвера хост-сервера
      dwElementCount := rdm.GetOneCell('select count(*) ' + sSQL);

      // Сортируем по идентификаторам устройств драйвера хост-сервера
      sSQL := sSQL + 'order by vd.vd_id ';

      // Проверяем, можно ли возвращать столько элементов и есть ли ограничения на количество элементов вообще
      if (dwMaxElementsReturned = 0) or (dwElementCount <= dwMaxElementsReturned) then begin
        // если можно вернуть сразу все элементы (или нет таких клиентских ограничений), так и делаем
        pdwCount := dwElementCount;
        pbMoreElements := false;
      end else begin
        // иначе будем возвращать максимально разрешенное количество элементов
        pdwCount := dwMaxElementsReturned;
        pbMoreElements := true;
      end;

      // Если ведется поиск только элементов (не веток) возвращаем пустой список
      if (dwBrowseFilter = OPC_BROWSE_FILTER_ITEMS) then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // Если есть доступные элементы,...
      if pdwCount > 0 then begin
        // ... выделяем память для передачи pdwCount элементов типа OPCBROWSEELEMENT
        ppBrowseElements := POPCBROWSEELEMENTARRAY(CoTaskMemAlloc(pdwCount * sizeof(OPCBROWSEELEMENT)));

        // Если память выделить не удалось, выходим с ошибкой
        if ppBrowseElements = nil then begin
          PostLogRecordAddMsgNow(70122, hr, -1, E_OUTOFMEMORY, 'Ошибка памяти');
          pdwCount := 0;
          pbMoreElements := false;
          result := E_OUTOFMEMORY;
          exit;
        end;

        // Готовим список доступных устройств
        rdm.Lock;
        try
          ds := rdm.GetQueryDataset('select vd.vd_id, vd.vd_tag, vd.vd_text ' + sSQL);
          try
            // Запрашиваем список устройств ...
            ds.Open;
            // Проходим по полученным записям
            ElementIndex := 0;
            ds.First;
            while (not ds.Eof) and (ElementIndex < pdwCount) do
            with ppBrowseElements^[ElementIndex] do begin
              // добавляем очередную запись
              szName := StringToOleStr(ds.FieldByName('vd_text').AsString);
              szItemID := StringToOleStr(tagHostServer + '.' + tagHostServerDriver + '.' + ds.FieldByName('vd_tag').AsString);
              // Данный элемент является веткой и не является элементом данных
              dwFlagValue := OPC_BROWSE_HASCHILDREN;
              dwReserved := 0;
              // Заполняем ItemPorperties
              ItemProperties.hrErrorID := S_OK; // Признак состяния списка свойств элемента
              ItemProperties.dwNumProperties := 0; // Пока свойств нет.
              ItemProperties.pItemProperties := nil;
              ItemProperties.dwReserved := 0;
              // Переходим к следующему элементу
              ElementIndex := Succ(ElementIndex);
              ds.Next;
            end;
            // Если вернули не все, возвращаем ContinuationPoint
            if not ds.Eof then begin
              pszContinuationPoint := StringToOleStr(ds.FieldByName('vd_tag').AsString);
            end;
          finally
            ds.free;
          end;
        finally
          rdm.Unlock;
        end;
      end;
    end else if tagDeviceTypeTag = EmptyStr then begin
      // Случай 4: Обзор устройства (Обзор тегов устройства)
      // Готовим маску запроса списка тегов устройства
      sSQL :=
        'from vda_device_type_tags vdtt ' +
        'left outer join VN_DATATYPES vdt on vdt.vdt_id = vdtt.vdt_id ' +
        'where ' +
        '  vdtt.vdtv_id = ( ' +
        '    select vd.vdtv_id from vda_devices vd ' +
        '    where vd.vd_tag = '''+tagDevice+''') ';
      // Если был указан ContinuationPoint, то считаем количество доступных
      // тегов устройства начиная с указанного в pszContinuationPoint
      if pszContinuationPoint <> EmptyStr then
        sSQL := sSQL +
          '  and vdtt.vdtt_id >= ( ' +
          '    select vdtt2.vdtt_id from vda_device_type_tags vdtt2 ' +
          '    where vdtt2.vdtt_tag = '''+pszContinuationPoint+''') ';

      // Получаем количество доступных тегов
      dwElementCount := rdm.GetOneCell('select count(*) ' + sSQL);

      // Сортируем по идентификаторам тегов устройства
      sSQL := sSQL + 'order by vdtt.vdtt_id ';

      // Проверяем, можно ли возвращать столько элементов и есть ли ограничения на количество элементов вообще
      if (dwMaxElementsReturned = 0) or (dwElementCount <= dwMaxElementsReturned) then begin
        // если можно вернуть сразу все элементы (или нет таких клиентских ограничений), так и делаем
        pdwCount := dwElementCount;
        pbMoreElements := false;
      end else begin
        // иначе будем возвращать максимально разрешенное количество элементов
        pdwCount := dwMaxElementsReturned;
        pbMoreElements := true;
      end;

      // Если ведется поиск только веток (не элементов) возвращаем пустой список
      if (dwBrowseFilter = OPC_BROWSE_FILTER_BRANCHES) then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // Если есть доступные элементы,...
      if pdwCount > 0 then begin
        // ... выделяем память для передачи pdwCount элементов типа OPCBROWSEELEMENT
        ppBrowseElements := POPCBROWSEELEMENTARRAY(CoTaskMemAlloc(pdwCount * sizeof(OPCBROWSEELEMENT)));

        // Если память выделить не удалось, выходим с ошибкой
        if ppBrowseElements = nil then begin
          PostLogRecordAddMsgNow(70123, hr, -1, E_OUTOFMEMORY, 'Ошибка памяти');
          pdwCount := 0;
          pbMoreElements := false;
          result := E_OUTOFMEMORY;
          exit;
        end;

        // Готовим список доступных тегов для устройства данного типа
        rdm.Lock;
        try
          dsTags := rdm.GetQueryDataset(
          'select vdtt.vdtt_id, vdtt.vdtt_tag, vdtt.vdtt_name, vdt.VDT_VAR_TYPE, ' +
          'vdtt.vdtt_eu_type, vdtt.vdtt_access_rights ' + sSQL
          );
          try
            // Запрашиваем список тегов ...
            dsTags.Open;
            // Проходим по полученным записям
            ElementIndex := 0;
            dsTags.First;

            while (not dsTags.Eof) and (ElementIndex < pdwCount) do begin

              // инициализируем очередной Item
              ppBrowseElements^[ElementIndex].szName := StringToOleStr(dsTags.FieldByName('vdtt_name').AsString);
              ppBrowseElements^[ElementIndex].szItemID := StringToOleStr(tagHostServer + '.' + tagHostServerDriver + '.' + tagDevice + '.' + dsTags.FieldByName('vdtt_tag').AsString);
              // Данный элемент является элементом данных и не является веткой
              ppBrowseElements^[ElementIndex].dwFlagValue := OPC_BROWSE_ISITEM;
              ppBrowseElements^[ElementIndex].dwReserved := 0;

              // Получение ссылки на OPCITEMPROPERTIES
              pItemProps := @(ppBrowseElements^[ElementIndex].ItemProperties);
              // Заполняем pItemProps
              result := FillPOPCITEMPROPERTIES(pItemProps, ppBrowseElements^[ElementIndex].szItemID, bReturnPropertyValues, dsTags);
              if result <> S_OK then begin
                PostLogRecordAddMsgNow(70124, hr, -1, result, 'Внутреннее событие');
                exit;
              end;
              // Переходим к следующему элементу
              ElementIndex := Succ(ElementIndex);
              dsTags.Next;
            end;
            // Если вернули не все, возвращаем ContinuationPoint
            if not dsTags.Eof then begin
              pszContinuationPoint := StringToOleStr(dsTags.FieldByName('vdtt_tag').AsString);
            end;
          finally
            dsTags.free;
          end;
        finally
          rdm.Unlock;
        end;
      end
    end else begin
      // Случай 5: Обзор тега устройства
      pdwCount := 0;
      pbMoreElements := false;
    end;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70117, result, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    // В случае непредвиденной ошибки ...
    // ... если память была выделена, освобождаем ее, ...
    if assigned(ppBrowseElements) then begin
      CoTaskMemFree(ppBrowseElements);
      ppBrowseElements := nil;
    end;
    // ... и возвращаем E_FAIL
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.Read(
        dwCount:                    DWORD;
        pszItemIDs:                 POleStrList;
        pdwMaxAge:                  PDWORDARRAY;
  out   ppvValues:                  POleVariantArray;
  out   ppwQualities:               PWordArray;
  out   ppftTimeStamps:             PFileTimeArray;
  out   ppErrors:                   PResultList): HResult; stdcall;
var
  ItemIndex : DWORD;
  sItemId : String;
  dwHostServerID,
  dwHostServerDriverID,
  dwDeviceID,
  dwDeviceTypeTagID : DWORD;
  hr : HRESULT;
  dwErrorCount : DWORD;
  TrItem : TVpNetDATransactionItem; // Транзакция
  TrItemIndex : Integer;
  TrItemList : TVpNetDATransactionItemList; // список элементов транзакций для определенного Соединения(драйвера)
  TrItemListSet : TVpNetDATransactionItemListSet; // Множество списков элементов транзакций для разных Соединений(драйверов)
  trItemListIndex : Integer; // Номер списка элементов транзакций во множестве списков
  CommonTrItemList : TVpNetDATransactionItemList; // Общий (сквозной) список транзакций запроса
  ReferencedHstDriverIDs : TList; // Список идентификаторов драйверов, на которые были добавлены ссылки
  ds : TDataSet;
  ft : TFileTime;
  DriverRefIndex : Integer;
  TID : DWORD;
  DeviceTypeId : DWORD;
  sq : String;
begin
  //----------------------------------------------------------------
  // Начальные действия
  //----------------------------------------------------------------
  try
    PostLogRecordAddMsgNow(70795, -1, -1, S_OK, 'Вызов метода', llDebug);
//    PostLogRecordAddMsgNow(70290, Integer(ServerCore.State), -1, -1, 'Ok. TVpNetOPCDA.Read(...)');

    ppvValues := nil;
    ppwQualities := nil;
    ppftTimeStamps := nil;
    ppErrors := nil;

    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70126, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера');
      result := E_FAIL;
      exit;
    end;

    // Если во входных параметрах есть ошибка, выходим с E_INVALIDARG
    if dwCount = 0 then begin
      PostLogRecordAddMsgNow(70127, -1, -1, E_INVALIDARG, 'Внутреннее событие');
      result := E_INVALIDARG;
      exit;
    end;

    if not assigned(pszItemIDs) then begin
      PostLogRecordAddMsgNow(70128, -1, -1, E_INVALIDARG, 'Внутреннее событие');
      result := E_INVALIDARG;
      exit;
    end;

    if not assigned(pdwMaxAge) then begin
      PostLogRecordAddMsgNow(70129, -1, -1, E_INVALIDARG, 'Внутреннее событие');
      result := E_INVALIDARG;
      exit;
    end;

    // Выделяем память для списка идентификаторов драйверов,
    // на которые были добавлены ссылки
    ReferencedHstDriverIDs := TList.Create;
    // Создание пустого множества списков транзакций для разных Соединений(драйверов)
    TrItemListSet := TVpNetDATransactionItemListSet.Create;
    // Создание общего (сквозноого) списка транзакций
    CommonTrItemList := TVpNetDATransactionItemList.Create;

    try
      // Выделяем память для выходных элементов
      ppvValues := POleVariantArray(CoTaskMemAlloc(dwCount * sizeof(OleVariant)));
      ItemIndex := 0;
      while ItemIndex < dwCount do begin
        VariantInit(ppvValues^[ItemIndex]);
        ItemIndex := Succ(ItemIndex);
      end;

      ppwQualities := PWordArray(CoTaskMemAlloc(dwCount * sizeof(Word)));
      ppftTimeStamps := PFileTimeArray(CoTaskMemAlloc(dwCount * sizeof(TFileTime)));
      ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));

      // Получаем идентификатор транзакции
      TID := ServerCore.GetNewTID;

      //----------------------------------------------------------------
      // Проходим по элементам, и формируем транзакции запросов для отдельных тегов
      //----------------------------------------------------------------
      ItemIndex := 0;
      dwErrorCount := 0;
      while ItemIndex < dwCount do begin

        // бработка очередного элемента:
        // Изначально значения выходных параметров для данного элемента не определены
        ppvValues^[ItemIndex] := null;
        ppwQualities^[ItemIndex] := OPC_QUALITY_BAD;
        CoFileTimeNow(ft); // Текущее время в формате _FILETIME
        LocalFileTimeToFileTime(ft, ft); // Перевод текущего локального времени в UTC
        ppftTimeStamps^[ItemIndex] := ft; // запоминаем его
        ppErrors^[ItemIndex] := E_FAIL;

        // Добавляем "место" для транзакции в общий (сквозной) список транзакций
        CommonTrItemList.Add(nil);

        // Разбор ItemID и получение:
        // идентификатора хост-сервера (dwHostServerID);
        // идентификатора драйвера хост-сервера (dwHostServerDriverID);
        // иденитфикатора устройства (dwDeviceID);
        // идентификатора тега устройства данного типа (dwDeviceTypeTagID)
        sItemId := pszItemIDs^[ItemIndex];
        // !!!(обращение к БД) !!!
        hr := rdm.SplitItemID(sItemId, dwHostServerID, dwHostServerDriverID, dwDeviceID, dwDeviceTypeTagID);

        // Анализ разбора ItemID. Проверка наличия ошибок в процессе разбора
        if hr <> S_OK then begin
          PostLogRecordAddMsgNow(70291, Integer(ServerCore.State), -1, hr, '');
          ppwQualities^[ItemIndex] := OPC_QUALITY_BAD;
          ppErrors^[ItemIndex] := hr; // передаем код ошибки
          dwErrorCount := Succ(dwErrorCount); // увеличиваем количество элементов с ошибками
          ItemIndex := Succ(ItemIndex); // переходим к следующему элементу
          continue;
        end;

// 01.03.2010
        {$if defined (ONE_GSM_DEMO)}
        if dwDeviceID > 0 then try
          DeviceTypeId := rdm.GetOneCell(
            'select vdt_id from vda_device_type_versions where vdtv_id = ( ' +
            'select vdtv_id from vda_devices where vd_id = '+IntToStr(dwDeviceID)+')'
          );
        except
          DeviceTypeId := 0;
        end;

        if DeviceTypeId <= 0 then begin
          PostLogRecordAddMsgNow(70292, DeviceTypeId, -1, -1, '');
          ppwQualities^[ItemIndex] := OPC_QUALITY_BAD;
          ppErrors^[ItemIndex] := hr; // передаем код ошибки
          dwErrorCount := Succ(dwErrorCount); // увеличиваем количество элементов с ошибками
          ItemIndex := Succ(ItemIndex); // переходим к следующему элементу
          continue;
        end;


        if (DeviceTypeId > 0) and not(DeviceTypeId = 2050) then begin
          ppwQualities^[ItemIndex] := OPC_QUALITY_BAD;
          ppErrors^[ItemIndex] := hr; // передаем код ошибки
          dwErrorCount := Succ(dwErrorCount); // увеличиваем количество элементов с ошибками
          ItemIndex := Succ(ItemIndex); // переходим к следующему элементу
          continue;
        end;
        {$ifend}
///01.03.2010

        // Если ссылка на данный драйвер еще не добавлена, ...
        if ReferencedHstDriverIDs.IndexOf(Pointer(dwHostServerDriverID)) = -1 then begin
          // Отправка команды на добавление ссылки на драйвер Host-сервера,
          // и ожидание выполнения команды
          hr := SendMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_REF, dwHostServerDriverID, 0);
          if (hr = S_OK) then begin
            // Если удалось добавить ссылку на на драйвер Host-сервера,
            // запоминаем идентификатор драйвера для последующего удаления ссылки
            ReferencedHstDriverIDs.Add(Pointer(dwHostServerDriverID));
          end else begin
            PostLogRecordAddMsgNow(70293, DeviceTypeId, -1, -1, '');
            // Если не удалось добавить ссылку на драйвер Host-сервера,
            // возвращаем ошибку для данного элемента
            ppErrors^[ItemIndex] := hr; // передаем код ошибки
            dwErrorCount := Succ(dwErrorCount); // увеличиваем количество элементов с ошибками
            ItemIndex := Succ(ItemIndex); // переходим к следующему элементу
            continue;
          end;
        end;

        // Создаем структуру транзакции DA-сервера
        TrItem := TVpNetDATransactionItem.Create(nil, TID);
        // Задаем ItemId DA-транзакции
        TrItem.DA_ItemId := sItemId;
        // Клиентский идентификатор элемента группы
        TrItem.DA_hClient := 0; // Неопределен
        // Вычисляем максимально возможную задержку для данного элемента
        TrItem.DA_MaxAge := pdwMaxAge^[ItemIndex];
        // Вычисляем самый поздний момент времени когда нужно получить ответ
        {26.09.2007}
        //todo: Проверить, действительно ли нудно ждать максимум TrItem.DA_MaxAge
        // мс ответ Hst-сервера?
        {/26.09.2007}
        TrItem.DA_MaxResponseMoment := FileTimePlusMS(TrItem.DA_CreationMoment, TrItem.DA_MaxAge);

        // Тип DA-транзакции - чтение
        TrItem.DA_Type := vndttRead;
        // Тип синхронизации DA-транзакции - Sync
        TrItem.DA_SyncType := vndtstSync;

        // Параметры относящиеся а Hst-серверу
        TrItem.Hst_ID := dwHostServerID;
        TrItem.Hst_DriverID := dwHostServerDriverID;
        TrItem.Hst_DeviceId := dwDeviceID;
        TrItem.Hst_DeviceTypeTagId := dwDeviceTypeTagID;

        // Если обрабатывем запрос к параметру драйвера, многие параметры определяем отдельно
        if not(dwDeviceID = 0) then begin
          // Получаем адрес прибора в сети (шине) приборов
          try
            // !!!(обращение к БД) !!!
            TrItem.Hst_DeviceAddress := rdm.GetOneCell('select vd_addr from vda_devices where vd_id = ' + rdm.IntToSQL(TrItem.Hst_DeviceId, IntToStr(HIGH(Integer))));
          except
            PostLogRecordAddMsgNow(70299, Integer(ServerCore.State), -1, -1, '');
            TrItem.Hst_DeviceAddress := HIGH(DWORD);
          end;

          // Запрашиваем дополнительные данные об Item-е в базе данных
          // !!!(обращение к БД) !!!
          rdm.Lock;
          try
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
                   ds.FieldByName('access_rights').IsNull or
                   (TrItem.Hst_DeviceAddress = DWORD(high(Integer)))
                then begin
                  PostLogRecordAddMsgNow(70294, DeviceTypeId, -1, -1, '');
                  TrItem.Free; // Так как не удалось получить все свойства транзакциию удаляем ее
                  ppErrors^[ItemIndex] := OPC_E_UNKNOWNITEMID;
                  dwErrorCount := Succ(dwErrorCount);
                  ItemIndex := Succ(ItemIndex);
                  continue;
                end;

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

              except
                PostLogRecordAddMsgNow(70130, -1, -1, E_FAIL, 'Внутреннее событие');
                TrItem.Free; // Так как не удалось получить все свойства транзакциию удаляем ее
                ppErrors^[ItemIndex] := E_FAIL; // Непредвиденная ошибка
                dwErrorCount := Succ(dwErrorCount);
                ItemIndex := Succ(ItemIndex);
                continue;
              end;
            finally
              ds.free;
            end;
          finally
            rdm.Unlock;
          end;
{19.06.2007}
        end else begin
          // Если обрабатывем запрос к параметру драйвера, ...
          TrItem.Hst_DeviceAddress := 1;
          // устанавливаем соответствующий тип протокола
          TrItem.Hst_ProtocolId := VPHstDriverInterface;
          // номер функции не используется (устанавливаем = 0)
          TrItem.Hst_FuncNumber := 0;
          // Запоминаем адрес данных
          TrItem.Hst_DataAddress := 0;
          // Запоминаем права доступа к элементу
          // todo: Сюда нужно вставить права доступа к параметру драйвера
          TrItem.Hst_AccessRights := OPC_READABLE + OPC_WRITEABLE;
          // не используется (устанавливаем = 0)
          TrItem.Hst_DataSizeInBytes := 0;
          // не используется (устанавливаем = VDF_DRECT)
          TrItem.Hst_DataFormatId := VDF_DRECT;

        end;
{/19.06.2007}

        // Добавляем транзакцию в общий (сквозной) список транзакций на заранее приготовленное место
        CommonTrItemList[CommonTrItemList.Count - 1] := TrItem;

        // Ищем созданный список транзакций для данного соединения(драйвера)
        TrItemList := TrItemListSet.FindByDriverId(TrItem.Hst_DriverID);
        // Если список для для данного соединения(драйвера) еще не создан,
        // Создаем его, и добавляем во множество списков транзакций
        if not assigned(TrItemList) then begin
//          TrItemList := TVpNetDATransactionItemList.Create(TrItem.Hst_DriverID);
          TrItemList := TVpNetDATransactionItemList.Create;
          TrItemListSet.Add(TrItemList);
        end;

        // Добавляем транзакцию в список транзакций для данного соединения(драйвера)
        TrItemList.Add(TrItem);

        // Переход к следующему элементу
        ItemIndex := Succ(ItemIndex);
      end;

      //----------------------------------------------------------------
      // Отправка списков транзакций соединениям(драйверам) для выполнения
      //----------------------------------------------------------------
      trItemListIndex := 0;
      while trItemListIndex < TrItemListSet.Count do begin

        // Отправка сообщения со списком транзакций очередному соединению(драйверу)
        SendMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_TRANSACTIONS,
          // Идентификатор драйвера Hst-сервера
          // (предпологаем, что список однородный по Hst_DriverId);
          TrItemListSet[trItemListIndex].FirstTrItemDriverId,
          // Список транзакций
          Integer(Pointer(TrItemListSet[trItemListIndex])),
        );
        // Переход к следующему списку
        trItemListIndex := Succ(trItemListIndex);
      end;

      //----------------------------------------------------------------
      // Ожидание выполнения ВСЕХ отправленных транзакций во ВСЕХ соединениях(драйверах)
      //----------------------------------------------------------------
      TrItemIndex := 0;
      while TrItemIndex < CommonTrItemList.Count do begin
        // Если для данного элемента запроса транзакции вообще нет
        if (CommonTrItemList[TrItemIndex] = nil)then begin
          // ...переходим к следующей транзакции
          PostLogRecordAddMsgNow(70658, TrItemIndex, -1, -1, '');
          TrItemIndex := Succ(TrItemIndex);
          Continue;
        end;

        // или обработка транзакции завершена ...
        if (CommonTrItemList[TrItemIndex].DA_State = vndtsComplete) then begin
          // ...переходим к следующей транзакции
          PostLogRecordAddMsgNow(70659, TrItemIndex, -1, -1, 'Ok. Item... vndtsComplete');
          TrItemIndex := Succ(TrItemIndex);
          Continue;
        end;

{28.06.2007}
{ TODO :
Иногда зависают элементы DA-транзакции.
Причина: элементы не обрабатываются DriverConnection }

        CoFileTimeNow(ft); // Дата создания транзакции
        LocalFileTimeToFileTime(ft, ft); // Переводим локальные дату/время в UTC

        TrItem := CommonTrItemList[TrItemIndex];
        if
          assigned(TrItem) and
          (ft.dwHighDateTime > TrItem.DA_MaxResponseMoment.dwHighDateTime)
        then begin
          // ...переходим к следующей транзакции
          PostLogRecordAddMsgNow(70310, Integer(ServerCore.State), -1, -1, '');
          CommonTrItemList[TrItemIndex].DA_State := vndtsComplete;
          TrItemIndex := Succ(TrItemIndex);
          Continue;
        end;

        if
          assigned(TrItem) and
          (
              (ft.dwHighDateTime = TrItem.DA_MaxResponseMoment.dwHighDateTime) and
              (ft.dwLowDateTime >= TrItem.DA_MaxResponseMoment.dwLowDateTime)
          )
        then begin
          // ...переходим к следующей транзакции
          PostLogRecordAddMsgNow(70660, Integer(ServerCore.State), -1, -1, 'Превышено макс время ответа для элемента '+TrItem.DA_ItemId);
          CommonTrItemList[TrItemIndex].DA_State := vndtsComplete;
          TrItemIndex := Succ(TrItemIndex);
          Continue;
        end;
{/28.06.2007}

        Sleep(1);
        Application.ProcessMessages;
      end;

      //Удаляем множество списков транзакций (но не сами транзакции)
      // (Отдельные списки транзакций нам не нужны, так как все транзакции есть в
      // общем (сквозном) списке транзакций)
      TrItemListSet.DestroyTransactionItemLists;

      //----------------------------------------------------------------
      // Проход по списку транзакций и заполнение выходных массивов
      //----------------------------------------------------------------
      ItemIndex := 0;
      dwErrorCount := 0;
      // Проходим по тегам запроса
      while ItemIndex < dwCount do begin
        // Берем очередную транзакцию из списка
        TrItem := CommonTrItemList[ItemIndex];
        if assigned(TrItem) then begin
          // Если на этом месте есть транзакция, инициализируем элементы
          // выходных массивов значениями из транзакции
          ppvValues^[ItemIndex] := TrItem.VQT.vDataValue;
          ppwQualities^[ItemIndex] := TrItem.VQT.wQuality;
          ppftTimeStamps^[ItemIndex] := TrItem.VQT.ftTimeStamp;
          ppErrors^[ItemIndex] := TrItem.DA_Result;

          if VarIsNull(TrItem.VQT.vDataValue) then begin
            sq := 'null';
          end else begin
            sq := TrItem.VQT.vDataValue;
          end;
        end else begin
          PostLogRecordAddMsgNow(70295, -1, -1, -1, '');
          // Если на этом месте нет транзакции, инициализируем элементы
          // выходных массивов для данной транзакции как ОШИБОЧНЫЕ
          ppErrors^[ItemIndex] := E_FAIL; // Непредвиденная ошибка
          dwErrorCount := Succ(dwErrorCount); // Увеличиваем счетчик ошибок
        end;

        // Переход к следующему элементу
        ItemIndex := Succ(ItemIndex);
      end;

      // Удаляем все транзакции в общем (сквозном) списке транзакций
      CommonTrItemList.DestroyTransactionItems;

      //----------------------------------------------------------------
      // Завершающие действия
      //----------------------------------------------------------------
    finally
      // Удаляем ссылки на драйвер Host-сервера
      DriverRefIndex := 0;
      while DriverRefIndex < ReferencedHstDriverIDs.Count do begin
        // Оправляем команду на удалениии ссылки очередной драйвер Host-сервера
        // и ожидание выполнения команды
        Application.ProcessMessages; //???
        SendMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_RELEASE, DWORD(ReferencedHstDriverIDs[DriverRefIndex]), 0);
        // Переходим к идентификаторй следующего драйвера Host-сервера
        DriverRefIndex := Succ(DriverRefIndex);
      end;

      // Удаление общего (сквозноого) списка транзакций
      if assigned(CommonTrItemList) then
        CommonTrItemList.Free;

      // Удаление множества списков транзакций для разных Соединений(драйверов)
      if assigned(TrItemListSet) then
        TrItemListSet.Free;

      // Удаляем список идентификаторов драйверов, на которые были добавлены ссылки
      if assigned(ReferencedHstDriverIDs) then
        ReferencedHstDriverIDs.Free;
    end;

    if dwErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70125, hr, -1, E_FAIL, 'Внутреннее событие: '+ e.Message);
    // Если выходим аварийно, очищаем выходные параметры
    result := E_FAIL;

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
end;

function TVpNetOPCDA.WriteVQT(
        dwCount:                    DWORD;
        pszItemIDs:                 POleStrList;
        pItemVQT:                   POPCITEMVQTARRAY;
  out   ppErrors:                   PResultList): HResult; stdcall;
var
  ReferencedHstDriverIDs : TList; // Список идентификаторов драйверов, на которые были добавлены ссылки
  TrItemListSet : TVpNetDATransactionItemListSet; // Множество списков элементов транзакций для разных Соединений(драйверов)
  CommonTrItemList : TVpNetDATransactionItemList; // Общий (сквозной) список элементов транзакций запроса
  TrItemListIndex : Integer; // Номер списка элементов транзакций во множестве списков
  TrItemList : TVpNetDATransactionItemList; // список элементов транзакций для определенного Соединения(драйвера)
  TrItemIndex : Integer; // Номер элемента DA-транзакции в списке
  DriverRefIndex : Integer;
  dwErrorCount : DWORD;
  ItemIndex : DWORD;
  sItemId : String;
  hr : HRESULT;
  dwHostServerID,
  dwHostServerDriverID,
  dwDeviceID,
  dwDeviceTypeTagID : DWORD;
  TrItem : TVpNetDATransactionItem;
  ds : TDataSet;
  TID : DWORD;
  dt : TDateTime;
begin
  try
    PostLogRecordAddMsgNow(70796, -1, -1, S_OK, 'Вызов метода', llDebug);
    ppErrors := nil;
{09.07.2006}
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70020, -1, -1, E_FAIL, 'Внутреннее событие (ServerCore.State='+IntToStr(Integer(ServerCore.State))+')');
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // Если во входных параметрах есть ошибка, выходим с E_INVALIDARG
    if dwCount = 0 then begin
      PostLogRecordAddMsgNow(70021, -1, -1, E_FAIL, 'Неверное количество тегов (dwCount = 0)');
      result := E_INVALIDARG;
      exit;
    end;

    // Если во входных параметрах есть ошибка, выходим с E_INVALIDARG
    if not assigned(pszItemIDs) then begin
      PostLogRecordAddMsgNow(70045, -1, -1, E_FAIL, 'Неверный список тегов');
      result := E_INVALIDARG;
      exit;
    end;

    // Если во входных параметрах есть ошибка, выходим с E_INVALIDARG
    if not assigned(pItemVQT) then begin
      PostLogRecordAddMsgNow(70046, -1, -1, E_FAIL, 'Неверный список VQT');
      result := E_INVALIDARG;
      exit;
    end;

    // Выделяем память для списка идентификаторов драйверов,
    // на которые были добавлены ссылки
    ReferencedHstDriverIDs := TList.Create;
    // Создание пустого множества списков транзакций для разных Соединений(драйверов)
    TrItemListSet := TVpNetDATransactionItemListSet.Create;
    // Создание общего (сквозноого) списка транзакций
    CommonTrItemList := TVpNetDATransactionItemList.Create;

    // Получаем идентификатор транзакции
    TID := ServerCore.GetNewTID;

    try
      // Выделяем память для массива результатов по элементам
      ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
      //----------------------------------------------------------------
      // Проходим по элементам, и формируем транзакции записи отдельных тегов
      //----------------------------------------------------------------
      ItemIndex := 0;
      dwErrorCount := 0;
      while (ItemIndex < dwCount) do begin

        // бработка очередного тега:
        // Изначально значения результата для тега - E_FAIL
        ppErrors^[ItemIndex] := E_FAIL;

        // Добавляем "место" для транзакции в общий (сквозной) список транзакций
        CommonTrItemList.Add(nil);

        // Разбор ItemID и получение:
        // идентификатора хост-сервера (dwHostServerID);
        // идентификатора драйвера хост-сервера (dwHostServerDriverID);
        // иденитфикатора устройства (dwDeviceID);
        // идентификатора тега устройства данного типа (dwDeviceTypeTagID)
        sItemId := pszItemIDs^[ItemIndex];
        hr := rdm.SplitItemID(sItemId, dwHostServerID, dwHostServerDriverID, dwDeviceID, dwDeviceTypeTagID);

        // Анализ разбора ItemID. Проверка наличия ошибок в процессе разбора
        if hr <> S_OK then begin
          ItemIndex := Succ(ItemIndex); // переходим к следующему элементу
          continue;
        end;

        // Если ссылка на данный драйвер еще не добавлена, ...
        if ReferencedHstDriverIDs.IndexOf(Pointer(dwHostServerDriverID)) = -1 then begin
          // Отправка команды на добавление ссылки на драйвер Host-сервера,
          // и ожидание выполнения команды
          hr := SendMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_REF, dwHostServerDriverID, 0);
          if (hr = S_OK) then begin
            // Если удалось добавить ссылку на на драйвер Host-сервера,
            // запоминаем идентификатор драйвера для последующего удаления ссылки
            ReferencedHstDriverIDs.Add(Pointer(dwHostServerDriverID));
          end else begin
            // Если не удалось добавить ссылку на драйвер Host-сервера,
            // возвращаем ошибку для данного элемента
            ppErrors^[ItemIndex] := hr; // передаем код ошибки
            dwErrorCount := Succ(dwErrorCount); // увеличиваем количество элементов с ошибками
            ItemIndex := Succ(ItemIndex); // переходим к следующему элементу
            continue;
          end;
        end;

        // Создаем структуру транзакции DA-сервера
        TrItem := TVpNetDATransactionItem.Create(nil, TID);
        // Клиентский идентификатор элемента группы
        TrItem.DA_hClient := 0; // Неопределен
        // Задаем ItemId DA-транзакции
        TrItem.DA_ItemId := sItemId;
        // Максимально возможную задержку для данного элемента устанавливаем равной 0
        // таким образом задаем приоритет записи над чтением
        TrItem.DA_MaxAge := 0;
        // Вычисляем самый поздний момент времени когда нужно получить ответ
        TrItem.DA_MaxResponseMoment := TrItem.DA_CreationMoment;

        // Тип DA-транзакции - запись
        TrItem.DA_Type := vndttWrite;
        // Тип синхронизации DA-транзакции - Sync
        TrItem.DA_SyncType := vndtstSync;

        // Задаем данные DA-транзакции
        TrItem.VQT := pItemVQT^[ItemIndex];

        // Параметры относящиеся а Hst-серверу
        TrItem.Hst_ID := dwHostServerID;
        TrItem.Hst_DriverID := dwHostServerDriverID;
        TrItem.Hst_DeviceId := dwDeviceID;
        TrItem.Hst_DeviceTypeTagId := dwDeviceTypeTagID;

{21.06.2007}
        // Если обрабатывем запрос к параметру драйвера, многие параметры не нужны
        if not(dwDeviceID = 0) then begin
{/21.06.2007}

          // Получаем адрес прибора в сети (шине) приборов
          try
            TrItem.Hst_DeviceAddress := rdm.GetOneCell('select vd_addr from vda_devices where vd_id = ' + rdm.IntToSQL(TrItem.Hst_DeviceId, IntToStr(HIGH(Integer))));
          except on e : Exception do begin
            PostLogRecordAddMsgNow(70022, -1, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
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
              'left outer join VN_MODBUS_FUNCTIONS vmf on vmf.vmf_id = vdtt.VDTT_MODBUS_WRITE_FUNC_ID ' + // !!!! VDTT_MODBUS_WRITE_FUNC_ID !!!!
              'left outer join vn_datatypes vdt on vdt.vdt_id = vdtt.vdt_id ' +
              'where vdtt.vdtt_id = ' + rdm.IntToSQL(dwDeviceTypeTagID, '-1')
            );
            try
              try
                // Открываем запрос
                ds.Open;
                // Обрабатываем возможные ошибки
                if ds.eof or
                   ds.FieldByName('vp_id').IsNull or
                   ds.FieldByName('func_number').IsNull or
                   ds.FieldByName('data_address').IsNull or
                   ds.FieldByName('access_rights').IsNull or
                   ds.FieldByName('access_rights').IsNull or
                   (TrItem.Hst_DeviceAddress = DWORD(high(Integer)))
                then begin
                  TrItem.Free; // Так как не удалось получить все свойства транзакциию удаляем ее
                  ppErrors^[ItemIndex] := OPC_E_UNKNOWNITEMID;
                  dwErrorCount := Succ(dwErrorCount);
                  ItemIndex := Succ(ItemIndex);
                  continue;
                end;

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
                PostLogRecordAddMsgNow(70023, -1, -1, E_FAIL, 'Внутреннее событие: '+e.Message);
                TrItem.Free; // Так как не удалось получить все свойства транзакциию удаляем ее
                ppErrors^[ItemIndex] := E_FAIL; // Непредвиденная ошибка
                dwErrorCount := Succ(dwErrorCount);
                ItemIndex := Succ(ItemIndex);
                continue;
              end;
              end;
            finally
              ds.free;
            end;
          finally
            rdm.Unlock;
          end;
{21.06.2007}
        end else begin
          TrItem.Hst_AccessRights := OPC_READABLE + OPC_WRITEABLE;
          TrItem.Hst_ProtocolId := VPHstDriverInterface;
        end;
{/21.06.2007}

        // Добавляем транзакцию в общий (сквозной) список транзакций на заранее приготовленное место
        CommonTrItemList[CommonTrItemList.Count - 1] := TrItem;

        // Ищем созданный список транзакций для данного соединения(драйвера)
        TrItemList := TrItemListSet.FindByDriverId(TrItem.Hst_DriverID);
        // Если список для для данного соединения(драйвера) еще не создан,
        // Создаем его, и добавляем во множество списков транзакций
        if not assigned(TrItemList) then begin
//          TrItemList := TVpNetDATransactionItemList.Create(TrItem.Hst_DriverID);
          TrItemList := TVpNetDATransactionItemList.Create;
          TrItemListSet.Add(TrItemList);
        end;

        // Добавляем транзакцию в список транзакций для данного соединения(драйвера)
        TrItemList.Add(TrItem);

        // Переход к следующему элементу
        ItemIndex := Succ(ItemIndex);
      end;

      //----------------------------------------------------------------
      // Отправка списков транзакций соединениям(драйверам) для выполнения
      //----------------------------------------------------------------
      TrItemListIndex := 0;
      while (TrItemListIndex < TrItemListSet.Count) do begin

        // Отправка сообщения со списком транзакций очередному соединению(драйверу)
        PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_TRANSACTIONS,
          // Идентификатор драйвера Hst-сервера
          // (предпологаем, что список однородный по Hst_DriverId);
          TrItemListSet[trItemListIndex].FirstTrItemDriverId,
          Integer(Pointer(TrItemListSet[TrItemListIndex])), // Список транзакций
        );
        // Переход к следующему списку
        TrItemListIndex := Succ(TrItemListIndex);
      end;

      //----------------------------------------------------------------
      // Ожидание выполнения ВСЕХ отправленных транзакций во ВСЕХ соединениях(драйверах)
      //----------------------------------------------------------------
      //todo: Здесь висим приаварийном завершении программы
      TrItemIndex := 0;
      {26.09.2007}
//      while (TrItemIndex < CommonTrItemList.Count) do begin
      dt := now;
      while
        (
          (TrItemIndex < CommonTrItemList.Count) and
          (now <= (dt + 15/86400))
        )
      do begin
      {/26.09.2007}
        if (CommonTrItemList[TrItemIndex] = nil) or // Если для данного элемента запроса транзакции вообще нет
           (CommonTrItemList[TrItemIndex].DA_State = vndtsComplete) // или обработка транзакции завершена ...
        then begin
          // ...переходим к следующей транзакции
          TrItemIndex := Succ(TrItemIndex);
          Continue;
        end;
        Sleep(1);
        Application.ProcessMessages;
      end;

      //Удаляем множество списков транзакций (но не сами транзакции)
      // (Отдельные списки транзакций нам не нужны, так как все транзакции есть в
      // общем (сквозном) списке транзакций)
      TrItemListSet.DestroyTransactionItemLists;

      //----------------------------------------------------------------
      // Проход по списку транзакций и заполнение результатов
      //----------------------------------------------------------------
      ItemIndex := 0;
      dwErrorCount := 0;
      // Проходим по тегам запроса
      while (ItemIndex < dwCount) do begin
        // Берем очередную транзакцию из списка
        TrItem := CommonTrItemList[ItemIndex];
        if assigned(TrItem) then begin
          // Если на этом месте есть транзакция, заполняем элемент выходного массива
          // результатов выполнения транзакций значением из транзакции
          ppErrors^[ItemIndex] := TrItem.DA_Result;
        end else begin
          // Если на этом месте нет транзакции, помещаем в элемент выходного массива
          // результатов выполнения транзакций E_FAIL
          ppErrors^[ItemIndex] := E_FAIL; // Непредвиденная ошибка
          PostLogRecordAddMsgNow(70024, -1, -1, E_FAIL, 'Внутреннее событие');
          dwErrorCount := Succ(dwErrorCount); // Увеличиваем счетчик ошибок
        end;

        // Переход к следующему элементу
        ItemIndex := Succ(ItemIndex);
      end;

      // Удаляем все транзакции в общем (сквозном) списке транзакций
      CommonTrItemList.DestroyTransactionItems;

      //----------------------------------------------------------------
      // Завершающие действия
      //----------------------------------------------------------------
    finally
      // Удаляем ссылки на драйвер Host-сервера
      DriverRefIndex := 0;
      while (DriverRefIndex < ReferencedHstDriverIDs.Count) do begin
        // Оправляем команду на удалениии ссылки очередной драйвер Host-сервера
        // и ожидание выполнения команды
        Application.ProcessMessages; //???
        SendMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_RELEASE, DWORD(ReferencedHstDriverIDs[DriverRefIndex]), 0);
        // Переходим к идентификаторй следующего драйвера Host-сервера
        DriverRefIndex := Succ(DriverRefIndex);
      end;

      // Удаление общего (сквозноого) списка транзакций
      if assigned(CommonTrItemList) then
        CommonTrItemList.Free;

      // Удаление множества списков транзакций для разных Соединений(драйверов)
      if assigned(TrItemListSet) then
        TrItemListSet.Free;

      // Удаляем список идентификаторов драйверов, на которые были добавлены ссылки
      if assigned(ReferencedHstDriverIDs) then
        ReferencedHstDriverIDs.Free;

    end;

    if dwErrorCount = 0 then
      result := S_OK
    else begin
      PostLogRecordAddMsgNow(70025, dwErrorCount, -1, E_FAIL, 'Внутреннее событие');
      result := S_FALSE;
    end;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70026, -1, -1, E_FAIL, 'Внутреннее событие');
    // Если выходим аварийно, очищаем выходные параметры
    if assigned(ppErrors) then begin
      CoTaskMemFree(ppErrors);
      ppErrors := nil;
    end;
    result := E_FAIL;
  end;
  end;
end;


// IOPCItemProperties
function TVpNetOPCDA.QueryAvailableProperties(
        szItemID:                   POleStr;
  out   pdwCount:                   DWORD;
  out   ppPropertyIDs:              PDWORDARRAY;
  out   ppDescriptions:             POleStrList;
  out   ppvtDataTypes:              PVarTypeList): HResult; stdcall;
var
  tagHostServer : DWORD; // Тег Хост-сервера
  tagHostServerDriver : DWORD; // Тег драйвера хост-сервера
  tagDevice : DWORD; // Тег устройства
  tagDeviceTypeTag : DWORD; // Тег тега типа устройства :)
  dsTagProperties : TDataSet;
  v : OleVariant;
  lPropertyIDs : TList;
  slDescriptions : TStringList;
  lDataTypes : TList;
  VDT_VAR_TYPE : DWORD;
  Index : Integer;
  wValidStatus : WORD;
  hr : HRESULT;
begin
  try
    PostLogRecordAddMsgNow(70797, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Инициализация переменных
    pdwCount := 0;
    ppPropertyIDs := nil;
    ppDescriptions := nil;
    ppvtDataTypes := nil;
    result := E_FAIL;

{09.07.2006}
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70132, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера');
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // разбираем szItemId
    //todo: заменить тип аргументов функции SplitItemID() с String на POleStr
    result := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag);
    // Если есть ошибкти разбора, возвращаем полученную ошибку
    if result <> S_OK then begin
      PostLogRecordAddMsgNow(70132, -1, -1, result, 'Внутреннее событие');
      exit;
    end;

    // Создаем временные массивы
    lPropertyIDs := TList.Create;
    slDescriptions := TStringList.Create;
    lDataTypes := TList.Create;
    // Запрашиваем свойства тега
    rdm.Lock;
    try
      dsTagProperties := rdm.GetQueryDataset('select * from vn_tag_property_ids vtpi');
      try
        // Проход по всем возможным свойствам тегов
        dsTagProperties.Open;
        dsTagProperties.First;
        while not dsTagProperties.Eof do try
          // Получаем статус valid-ности данного свойства тега
          hr := GetPropertyValidStatus(tagDeviceTypeTag, dsTagProperties.FieldByName('vtpi_property_id').AsInteger, wValidStatus);
          // Проверяем успешность выполнения операции
          if hr <> S_OK then
            Continue; // При ошибке переходим к следующему свойству
          // Проверяем доступность свойства
          if wValidStatus < 1 then
            Continue; // Если свойство недоступно, переходим к следующему свойству

          // Получаем тип данных
          v := rdm.GetOneCell('select vdt_var_type from VN_DATATYPES VDT where VDT.VDT_ID = ' + IntToStr(dsTagProperties.FieldByName('vdt_id').AsInteger));
          if not VarIsOrdinal(v) then
            Continue; // При ошибке переходим к следующему свойству
          VDT_VAR_TYPE := v;

          // Если это свойство доступно заносим его в список
          if v >= 1 then begin
            lPropertyIDs.Add(Pointer(dsTagProperties.FieldByName('VTPI_PROPERTY_ID').AsInteger));
            slDescriptions.Add(dsTagProperties.FieldByName('VTPI_TEXT').AsString);
            lDataTypes.Add(Pointer(VDT_VAR_TYPE));
          end;

        finally
          dsTagProperties.Next;
        end;

        // Заполнение выходных массивов
        pdwCount := lPropertyIDs.Count;
        // Если допустимые свойства тега найдены, возвращаем их, иначе возвращаем пустые списки
        if pdwCount > 0 then begin
          ppPropertyIDs := CoTaskMemAlloc(pdwCount * sizeof(DWORD));
          ppDescriptions := CoTaskMemAlloc(pdwCount * sizeof(POleStr));
          ppvtDataTypes := CoTaskMemAlloc(pdwCount * sizeof(TVarType));
          // Проверяем выделение памяти
          if not(assigned(ppPropertyIDs)) or
          not(assigned(ppDescriptions)) or
          not(assigned(ppvtDataTypes)) then begin
            PostLogRecordAddMsgNow(70133, -1, -1, result, 'Ошибка памяти');
            result := E_OUTOFMEMORY;
            raise EOutOfMemory.Create('OutOfMemory');
          end;

          Index := 0;
          while Index < lPropertyIDs.Count do begin
            ppPropertyIDs^[Index] := DWORD(lPropertyIDs[Index]);
            result := VpStringToLPOLESTR(slDescriptions[Index], ppDescriptions^[Index]);
            if result <> S_OK then begin
              PostLogRecordAddMsgNow(70134, -1, -1, result, 'Внутреннее событие');
              exit;
            end;
            ppvtDataTypes^[Index] := TVarType(Integer(lDataTypes[Index]));
            Index := Succ(Index);
          end;
        end;
      finally
        dsTagProperties.Free;
        // Удаляем временные массивы
        lPropertyIDs.Free;
        slDescriptions.Free;
        lDataTypes.Free;
      end;
    finally
      rdm.Unlock;
    end;
    result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70131, -1, -1, result, 'Внутреннее событие: ' + e.Message);
    // Если выходим аварийно, очищаем выходные параметры
    if assigned(ppPropertyIDs) then begin
      CoTaskMemFree(ppPropertyIDs);
      ppPropertyIDs := nil;
    end;

    if Assigned(ppDescriptions) then begin
      // Освобождаем память, выделенную под названия свойств
      while pdwCount > 0 do begin
        try
          CoTaskMemFree(Pointer(ppDescriptions[0]^));
        except
        end;
        pdwCount := Pred(pdwCount);
      end;
      CoTaskMemFree(ppDescriptions);
      ppDescriptions := nil;
    end;

    if Assigned(ppvtDataTypes) then begin
      CoTaskMemFree(ppvtDataTypes);
      ppvtDataTypes := nil;
    end;
  end;
  end;
end;

function TVpNetOPCDA.GetItemProperties(
        szItemID:                   POleStr;
        dwCount:                    DWORD;
        pdwPropertyIDs:             PDWORDARRAY;
  out   ppvData:                    POleVariantArray;
  out   ppErrors:                   PResultList): HResult; stdcall;
var
  ErrCount : Integer;
  tagHostServer : DWORD; // Тег Хост-сервера
  tagHostServerDriver : DWORD; // Тег драйвера хост-сервера
  tagDevice : DWORD; // Тег устройства
  tagDeviceTypeTag : DWORD; // Тег тега типа устройства :)
  dsValuesQuery : TDataSet;
  PropertyIndex : DWORD;
  v : Variant;
  vt : WORD;
begin
  try
    PostLogRecordAddMsgNow(70798, -1, -1, S_OK, 'Вызов метода GetItemProperties(...)', llDebug);
    ppvData := nil;
    ppErrors := nil;
    result := E_FAIL;

{09.07.2006}
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70136, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера');
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // разбираем szItemId
    //todo: заменить тип аргументов функции SplitItemID() с String на POleStr
    result := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag);
    // Если есть ошибкти разбора, возвращаем полученную ошибку
    if result <> S_OK then begin
      PostLogRecordAddMsgNow(70137, -1, -1, result, 'Внутреннее событие');
      exit;
    end;

    // Выделение памяти под выходные массивы
    if dwCount > 0 then begin
      ppvData := POleVariantArray(CoTaskMemAlloc(dwCount * sizeof(OleVariant)));
      ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)))
    end;

    // Проверка выделения памяти под выходные массивы
    if not(assigned(ppvData)) or not(assigned(ppErrors)) then begin
      PostLogRecordAddMsgNow(70138, -1, -1, result, 'Внутреннее событие');
      result := E_OUTOFMEMORY;
      raise EOutOfMemory.Create('OutOfMemory');
    end;

    // Проход по списку свойств
    rdm.Lock;
    try
      dsValuesQuery := rdm.GetQueryDataset(
        'select vtp.vtp_value, vdt.vdt_var_type from vn_tag_properties vtp ' +
        'left outer join vn_tag_property_ids vtpi on vtpi.vtpi_id = vtp.vtpi_id ' +
        'left outer join vn_datatypes vdt on vdt.vdt_id = vtpi.vdt_id ' +
{28.08.2007}
//        'where (vtp.vd_id = ' + IntToStr(tagDevice) + ') and ' +
        'where ((vtp.vd_id = ' + IntToStr(tagDevice) + ') or (vtp.vd_id = -1)) and ' +
{/28.08.2007}
        '(vdtt_id = ' + IntToStr(tagDeviceTypeTag) + ') and ' +
        '(vtpi.vtpi_property_id = ' + IntToStr(pdwPropertyIDs^[PropertyIndex]) + ') '
      );
      try
        ErrCount := 0;
        PropertyIndex := 0;
        while PropertyIndex < dwCount do begin
          //todo: Проверить доустимость свойства по таблице vn_valid_tag_properties
          // формируем запрос значения параметра тега
          dsValuesQuery.Open;

          VariantInit(ppvData^[PropertyIndex]);
          // Проверяем наличие значения и типа данных
          if not(dsValuesQuery.Eof) and
          not(dsValuesQuery.FieldByName('vtp_value').IsNull) and
          not(dsValuesQuery.FieldByName('vdt_var_type').IsNull) then begin
            // есть знвчение и тип данных
            try
              v := dsValuesQuery.FieldByName('vtp_value').AsVariant;
              vt := (dsValuesQuery.FieldByName('vdt_var_type').AsInteger and $FFFF);
              ppvData^[PropertyIndex] := VarAsType(v, vt);
            except
              ppvData^[PropertyIndex] := null;
              ppErrors^[PropertyIndex] := E_UNEXPECTED;
              ErrCount := Succ(ErrCount);
            end;
            ppErrors^[PropertyIndex] := S_OK;
          end else begin
            // не значения
            ppvData^[PropertyIndex] := null;
            ppErrors^[PropertyIndex] := OPC_E_NOINFO; //OPC_E_INVALID_PID;
            ErrCount := Succ(ErrCount);
          end;

          PropertyIndex := Succ(PropertyIndex);
        end;
      finally
        dsValuesQuery.Free;
      end;
    finally
      rdm.Unlock;
    end;

    if ErrCount = 0 then
      result := S_OK
    else
      result := S_FALSE;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70135, -1, -1, result, 'Внутреннее событие: ' + e.Message);

    if assigned(ppvData) then begin
      CoTaskMemFree(ppvData);
      ppvData := nil;
    end;

    if assigned(ppErrors) then begin
      CoTaskMemFree(ppErrors);
      ppErrors := nil;
    end;
  end;
  end;
end;

function TVpNetOPCDA.LookupItemIDs(
        szItemID:                   POleStr;
        dwCount:                    DWORD;
        pdwPropertyIDs:             PDWORDARRAY;
  out   ppszNewItemIDs:             POleStrList;
  out   ppErrors:                   PResultList): HResult; stdcall;
var
  tagHostServer : DWORD; // Тег Хост-сервера
  tagHostServerDriver : DWORD; // Тег драйвера хост-сервера
  tagDevice : DWORD; // Тег устройства
  tagDeviceTypeTag : DWORD; // Тег тега типа устройства :)
  PropIndex : DWORD;
  hr : HRESULT;
  wValidStatus : WORD;
  ErrCount : DWORD;
  sPropItemId : String;
  v : variant;
  sPropID : String;
  sItemID : String;
begin
  try
    PostLogRecordAddMsgNow(70799, -1, -1, S_OK, 'Вызов метода', llDebug);
    ppszNewItemIDs := nil;
    ppErrors := nil;
    result := E_FAIL;

{09.07.2006}
    // Проверяем состояние сервера, и если сервер находится в нерабочем состоянии,
    // ничего не делаем и возвращаем ошибку
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70140, Integer(ServerCore.State), -1, E_FAIL, 'Неверное состояние сервера');
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // разбираем szItemId
    result := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag);
    if result <> S_OK then begin
      PostLogRecordAddMsgNow(70141, -1, -1, result, 'Неправильный тег ' + szItemId);
      exit; // Если есть ошибкти разбора, возвращаем полученную ошибку
    end;

    // Выделение памяти для выходных массивов
    ppszNewItemIDs := CoTaskMemAlloc(dwCount * sizeof(POleStr));
    ppErrors := CoTaskMemAlloc(dwCount * sizeof(HRESULT));

    // Проход по списку свойств тега
    PropIndex :=0;
    ErrCount := 0;
    while PropIndex < dwCount do try
      // Проверяем valid-ность свойства для данного тега
      hr := GetPropertyValidStatus(tagDeviceTypeTag, pdwPropertyIDs^[PropIndex], wValidStatus);
      // Проверяем успешность выполнения операции
      if hr <> S_OK then begin
        ppszNewItemIDs^[PropIndex] := nil;
        ppErrors^[PropIndex] := E_FAIL;
        ErrCount := Succ(ErrCount);
        continue;
      end;

      // Если свойство недоступно - ошибка
      if wValidStatus < 1 then begin
        ppszNewItemIDs^[PropIndex] := nil;
        ppErrors^[PropIndex] := OPC_E_INVALID_PID;
        ErrCount := Succ(ErrCount);
        continue;
      end;

      // получаем идент. свойства
      v := rdm.GetOneCell('select vtpi_tag from vn_tag_property_ids vtpi where vtpi_property_id = ' + rdm.IntToSQL(pdwPropertyIDs^[PropIndex], '-1'));
      // если не смогли - ошибка
      if not(VarIsStr(v)) then begin
        ppszNewItemIDs^[PropIndex] := nil;
        ppErrors^[PropIndex] := E_FAIL;
        ErrCount := Succ(ErrCount);
        continue;
      end;

      // Формируем ItemID свойства
      sPropId := v;
      sItemID := szItemID;
      sPropItemId := sItemID + '.' + sPropId;

      // Записываем ItemID свойства в выходной массив
      hr := VpStringToLPOLESTR(sPropItemId, ppszNewItemIDs^[PropIndex]);
      // если не смогли - ошибка
      if (hr <> S_OK) then begin
        ppszNewItemIDs^[PropIndex] := nil;
        ppErrors^[PropIndex] := E_FAIL;
        ErrCount := Succ(ErrCount);
        continue;
      end;

      // Признак нормальной обработки элемента списка свойств
      ppErrors^[PropIndex] := S_OK;

    finally
      PropIndex := Succ(PropIndex);
    end;

    if ErrCount = 0 then
      result := S_OK
    else
      result := S_FALSE;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70139, -1, -1, result, 'Внутреннее событие: ' + e.Message);
    if assigned(ppszNewItemIDs) then begin
      PropIndex := 0;
      while PropIndex < dwCount do begin
        if assigned(ppszNewItemIDs^[PropIndex]) then begin
          CoTaskMemFree(ppszNewItemIDs^[PropIndex]);
          ppszNewItemIDs^[PropIndex] := nil;
        end;
        PropIndex := Succ(PropIndex);
      end;
      CoTaskMemFree(ppszNewItemIDs);
      ppszNewItemIDs := nil;
    end;
    if assigned(ppErrors) then begin
      CoTaskMemFree(ppErrors);
      ppErrors := nil;
    end;
  end;
  end;
end;


function TVpNetOPCDA.QueryOrganization(
  out   pNameSpaceType:             OPCNAMESPACETYPE): HResult; stdcall;
begin
  try
    PostLogRecordAddMsgNow(70800, -1, -1, S_OK, 'Вызов метода', llDebug);
    pNameSpaceType := OPC_NS_HIERARCHIAL;
    Result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70142, -1, -1, E_FAIL, 'Внутреннее событие ' + e.Message);
    Result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.ChangeBrowsePosition(
        dwBrowseDirection:          OPCBROWSEDIRECTION;
        szString:                   POleStr): HResult; stdcall;
var
  dwNodeType : DWORD;
  dwNodeID : DWORD;
  hr : HRESULT;
  v : OleVariant;
  sItemId : String;
begin
  try
    PostLogRecordAddMsgNow(70801, -1, -1, S_OK, 'Вызов метода', llDebug);
    // Получение идентификатора элемента
(*
    result := rdm.NodeIdToItemId(FNavigationNodeId, sItemId);
    if result >= S_OK then begin
      if sItemId = EmptyStr then begin
        result := rdm.ItemIdToNodeId(szString, dwNodeID);
      end else begin
        result := rdm.ItemIdToNodeId(sItemId + '.' + szString, dwNodeID);
      end;
    end;
*)
(*
    result := rdm.ItemIdToNodeId(szString, dwNodeID);
    if result < S_OK then begin
      exit;
    end;
*)

//    FNavigationNodeId := dwNodeID;

    // Если не удалось определить тип текущего элемента, выходим с ошибкой
    result := rdm.GetNodeType(FNavigationNodeId, dwNodeType);
    if result < S_OK then begin
      PostLogRecordAddMsgNow(70144, -1, -1, result, 'Внутреннее событие');
      exit;
    end;

    // Проверка правильности аргумента dwBrowseDirection
    // (метод навигации BROWSE_TO пока не поддердиваем)
    if not(dwBrowseDirection = OPC_BROWSE_UP) and not(dwBrowseDirection = OPC_BROWSE_DOWN) then begin
      PostLogRecordAddMsgNow(70145, Integer(dwBrowseDirection), -1, E_INVALIDARG, 'Внутреннее событие');
      result := E_INVALIDARG;
      exit;
    end;

    if (rdm.ItemIdToNodeId(szString, dwNodeID) >= S_OK) then begin
      FNavigationNodeId := dwNodeID;
      result := S_OK;
      exit;
    end;

    v := null;
    if dwNodeType = VNT_DA_Server then begin
      if dwBrowseDirection = OPC_BROWSE_UP then begin
        result := E_INVALIDARG;
        exit;

      end else if dwBrowseDirection = OPC_BROWSE_DOWN then begin
        v := rdm.GetOneCell(
          'select VHS_ID from vn_host_servers where VHS_TAG = '''+szString+''''
        );
      end;

    end else if dwNodeType = VNT_HostServer then begin
      if dwBrowseDirection = OPC_BROWSE_UP then begin
        FNavigationNodeId := ServerCore.InstanceId;
      end else if dwBrowseDirection = OPC_BROWSE_DOWN then begin
        v := rdm.GetOneCell(
          'select vhsd_id from vn_host_server_drivers where vhs_id = ' + IntToStr(FNavigationNodeId) + ' and VHSD_TAG = '''+szString+''''
        );
      end;

    end else if dwNodeType = VNT_HostServerDriver then begin
      if dwBrowseDirection = OPC_BROWSE_UP then begin
        v := rdm.GetOneCell(
          'select vhs_id from vn_host_server_drivers where vhsd_id = ' + IntToStr(FNavigationNodeId)
        );
      end else if dwBrowseDirection = OPC_BROWSE_DOWN then begin
        v := rdm.GetOneCell(
          'select min(vd_id) from  vda_devices where vhsd_id = ' + IntToStr(FNavigationNodeId) + ' and VD_TAG = '''+szString+''''
        );
      end;

    end else if dwNodeType = VNT_Device then begin
      if dwBrowseDirection = OPC_BROWSE_UP then begin
        v := rdm.GetOneCell(
          'select vhsd_id from vda_devices where vd_id = ' + IntToStr(FNavigationNodeId)
        );
      end else if dwBrowseDirection = OPC_BROWSE_DOWN then begin
        v := rdm.GetOneCell(
          'select min(vdtt.vdtt_id) from vda_device_type_tags vdtt ' +
          'where vdtt.vdtv_id = ( ' +
          '      select vd.vdtv_id from vda_devices vd ' +
          '      where vd.vd_id = ' + IntToStr(FNavigationNodeId) +
           ') and vdtt.vdtt_tag = '''+szString+''''

//        v := rdm.GetOneCell(
//          'select min(vdttg_id) from vda_device_type_tag_groups vdttg ' +
//          'where vdtv_id = ( ' +
//          '      select vd.vdtv_id from vda_devices vd ' +
//          '      where vd.vd_id =  ' + IntToStr(FNavigationNodeId) + ')'
        );
        FNavigationNodeDevId := FNavigationNodeId;
      end;

//    end else if dwNodeType = VNT_Device_Type_Tag_Group then begin
//      if dwBrowseDirection = OPC_BROWSE_UP then begin
//        v := rdm.GetOneCell(
//          'select vd_id from vda_device_type_tag_groups ' +
//          'where vdttg_id = ' + IntToStr(FNavigationNodeId)
//        );
//      end else if dwBrowseDirection = OPC_BROWSE_DOWN then begin
//        v := rdm.GetOneCell(
//          'select min(vdtt_id) from vda_device_type_tags ' +
//          'where vdttg_id = ' + IntToStr(FNavigationNodeId)
//        );
//      end;

    end else if dwNodeType = VNT_Device_Type_Tag then begin
      if dwBrowseDirection = OPC_BROWSE_UP then begin
        v := FNavigationNodeDevId;
        FNavigationNodeDevId := 0;
      end;
    end;

    if VarIsOrdinal(v) then begin
      FNavigationNodeId := v;
      result := S_OK;
    end else begin
      result := S_FALSE;
      exit;
    end;

  except on e : exception do
    PostLogRecordAddMsgNow(70143, -1, -1, result, 'Внутреннее событие: ' + e.Message);
  end;
end;

function TVpNetOPCDA.BrowseOPCItemIDs(
        dwBrowseFilterType:         OPCBROWSETYPE;
        szFilterCriteria:           POleStr;
        vtDataTypeFilter:           TVarType;
        dwAccessRightsFilter:       DWORD;
  out   ppIEnumString:              IEnumString): HResult; stdcall;
var
  lStrings : TStringList;
  dwNodeType : DWORD;
  ds : TDataSet;
begin
  try
    PostLogRecordAddMsgNow(70802, -1, -1, S_OK, 'Вызов метода', llDebug);
    result := rdm.GetNodeType(FNavigationNodeId, dwNodeType);
    if result < S_OK then begin
      PostLogRecordAddMsgNow(70147, result, -1, E_FAIL, 'Внутреннее событие');
      exit;
    end;

    ds := nil;
    lStrings := TStringList.Create;
    try
      // Запрос списка элементов
      if dwNodeType = VNT_DA_Server then begin
        if dwBrowseFilterType = OPC_BRANCH then begin
          ds := rdm.GetQueryDataset('select VHS_TAG item_name from vn_host_servers');
        end;
      end else if dwNodeType = VNT_HostServer then begin
        if dwBrowseFilterType = OPC_BRANCH then begin
          ds := rdm.GetQueryDataset('select VHSD_TAG item_name from vn_host_server_drivers where vhs_id = ' + IntToStr(FNavigationNodeId));
        end;
      end else if dwNodeType = VNT_HostServerDriver then begin
        if dwBrowseFilterType = OPC_BRANCH then begin
          ds := rdm.GetQueryDataset('select VD_TAG item_name from vda_devices where vhsd_id = ' + IntToStr(FNavigationNodeId));
        end;
      end else if dwNodeType = VNT_Device then begin
        if dwBrowseFilterType = OPC_LEAF then begin
          ds := rdm.GetQueryDataset(
            'select vdtt.vdtt_TAG item_name from vda_device_type_tags vdtt ' +
            'where vdtt.vdtv_id = ( ' +
            '      select vd.vdtv_id from vda_devices vd ' +
            '      where vd.vd_id = ' + IntToStr(FNavigationNodeId) + ')'
//            'select vdttg_name item_name from vda_device_type_tag_groups vdttg ' +
//            'where vdtv_id = ( ' +
//            '      select vd.vdtv_id from vda_devices vd ' +
//            '      where vd.vd_id =  ' + IntToStr(FNavigationNodeId) + ')'
          );
        end;
//      end else if dwNodeType = VNT_Device_Type_Tag_Group then begin
//        if dwBrowseFilterType = OPC_LEAF then begin
//          ds := rdm.GetQueryDataset(
//          'select vdtt_name from vda_device_type_tags vdtt where vdttg_id = ' + IntToStr(FNavigationNodeId)
//          );
//        end;

      end else if dwNodeType = VNT_Device_Type_Tag then begin

      end;

      // Формирование выходного списка элементов
      if assigned(ds) then begin
        try
          ds.Open;
          while not ds.Eof do begin
            lStrings.Add(ds.FieldByName('item_name').AsString);
            ds.Next;
          end;
        finally
            ds.Free;
        end;
      end;
      ppIEnumString := TVpNetStringEnumerator.Create(lStrings);
      // ... и если StringEnumerator содержит элементы, ...
      if lStrings.Count > 0 then begin
        // ... возвращаем S_OK ...
        result := S_OK
      end else begin
        // ... иначе возвращаем S_FALSE.
        result := S_FALSE;
      end;

    finally
      lStrings.Free;
    end;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70146, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.GetItemID(
        szItemDataID:               POleStr;
  out   szItemID:                   POleStr): HResult; stdcall;
var
  sItemId : String;
begin
  try
    PostLogRecordAddMsgNow(70803, -1, -1, S_OK, 'Вызов метода', llDebug);
    szItemID := '';
    result := rdm.NodeIdToItemId(FNavigationNodeId, sItemId);
    if result < S_OK then exit;
    sItemId := sItemId + '.' + szItemDataID;
    result := VpStringToLPOLESTR(sItemId, szItemID);
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70148, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.BrowseAccessPaths(
        szItemID:                   POleStr;
  out   ppIEnumString:              IEnumString): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70735, -1, -1, E_NOTIMPL, 'szItemID: ' + szItemID, llDebug);
  result := E_NOTIMPL;
end;

// IOPCServerPublicGroups
function TVpNetOPCDA.GetPublicGroupByName(
        szName:                     POleStr;
  const riid:                       TIID;
  out   ppUnk:                      IUnknown): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70733, -1, -1, E_NOTIMPL, 'szName: ' + szName, llDebug);
  result := E_NOTIMPL;
end;

function TVpNetOPCDA.RemovePublicGroup(
        hServerGroup:               OPCHANDLE;
        bForce:                     BOOL): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70734, -1, -1, E_NOTIMPL, 'hServerGroup: ' + IntToStr(hServerGroup), llDebug);
  result := E_NOTIMPL;
end;

// IPersistFile
function TVpNetOPCDA.IsDirty: HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70769, -1, -1, E_NOTIMPL, '', llDebug);
  result := E_NOTIMPL;
end;

function TVpNetOPCDA.Load(pszFileName: POleStr; dwMode: Longint): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70777, -1, -1, E_NOTIMPL, '', llDebug);
  result := E_NOTIMPL;
end;

function TVpNetOPCDA.Save(pszFileName: POleStr; fRemember: BOOL): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70778, -1, -1, E_NOTIMPL, '', llDebug);
  result := E_NOTIMPL;
end;

function TVpNetOPCDA.SaveCompleted(pszFileName: POleStr): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70779, -1, -1, E_NOTIMPL, '', llDebug);
  result := E_NOTIMPL;
end;

function TVpNetOPCDA.GetCurFile(out pszFileName: POleStr): HResult; stdcall;
begin
  PostLogRecordAddMsgNow(70780, -1, -1, E_NOTIMPL, '', llDebug);
  result := E_NOTIMPL;
end;

initialization
  try
    TAutoObjectFactory.Create(ComServer, TVpNetOPCDA, Class_VpNetOPCDA,
      ciMultiInstance, tmApartment);
  except
    on e : Exception do begin
      PostLogRecordAddMsgNow(70289, -1, -1, E_UNEXPECTED, 'Внутреннее событие: ' + e.Message);
    end;
  end;
end.
