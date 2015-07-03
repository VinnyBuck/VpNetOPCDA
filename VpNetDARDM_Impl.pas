unit VpNetDARDM_Impl;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Variants, ComServ, ComObj,
  VCLCom, DataBkr, DBClient, VpNetDA_TLB, StdVcl, IBDatabase, DB, IBQuery,
  IBSQL, DateUtils, OPCError{, DBAccess, Ora}, VpNetClasses, VpNetUtils;

type
  TVpNetNodeParamValueList = class;

  TVpNetDARDM = class(TRemoteDataModule, IVpNetDARDM)
    db: TIBDatabase;
    tr: TIBTransaction;
  private
    FCS : TRTLCriticalSection;  // Критическая секция обращения к базе данных
  protected
    class procedure UpdateRegistry(Register: Boolean; const ClassID, ProgID: string); override;
  public
    NodeParams : TVpNetNodeParamValueList;
    bLockDBGlobally : boolean;
    DBType : WORD;
    constructor Create(AOwner: TComponent); override; // su01
    destructor Destroy; override; // su01
    // Методы доступа к базе данных
    procedure Lock; override; //su01
    procedure Unlock; override; // su01
    // VpNet utils
// 29.09.2010
//    function SplitItemID(aItemID : String; out aHostServerTag : String; out aHostServerDriverTag : String; out aDeviceTag : String; out aDeviceTypeTagTag : String) : HRESULT; overload;// su01
    function SplitItemID(aItemID : String; out aHostServerTag : String; out aHostServerDriverTag : String; out aDeviceTag : String; out aDeviceTypeTagTag : String; CheckTagParams : boolean = true) : HRESULT; overload;// su01
///29.09.2010
    function SplitItemID(aItemID : String; out aHostServerID : DWORD; out aHostServerDriverID : DWORD; out aDeviceid : DWORD; out aDeviceTypeTagID : DWORD) : HRESULT; overload; // su01

    function SplitBranch(aBranchID : String; out aHostServerTag : String; out aHostServerDriverTag : String; out aDeviceTag : String) : HRESULT; overload; // su01
    function SplitBranch(aBranchID : String; out aHostServerID : DWORD; out aHostServerDriverID : DWORD; out aDeviceid : DWORD) : HRESULT; overload; // su01

    function GetItemType(aID : String; out dwType : DWORD) : HRESULT; // su01

    function NodeIdToItemId(dwNodeId : DWORD; out aItemID : String): HRESULT; // su01
    function ItemIdToNodeId(aItemID : String; out dwNodeId : DWORD): HRESULT; // su01
    function GetNodeType(dwNodeId : DWORD; out dwNodeType : DWORD): HRESULT; // su01
// 28.03.2010
    function GetNodeParamName(dwNodeId : DWORD; aNodeParam : OleVariant; out aNodeParamName : String) : HRESULT; // su01
    function GetNodeParamId(dwNodeId : DWORD; aNodeParam : OleVariant; out aNodeParamId : DWORD) : HRESULT; // su01
    function IsNodeParamValueInBase(dwNodeId : DWORD; aNodeParam : OleVariant) : boolean; // su01
    function GetNodeParamBySQL(aNodeId : DWORD; aParamName : String; out ADefValue, AValue : Variant): HRESULT; // su01
    function SetNodeParamBySQL(aNodeId : DWORD; aNodeParam : OleVariant; aNodeParamValue : OleVariant) : HRESULT; // su01
    function DeleteNodeParamBySQL(aNodeId : DWORD; aParamName : String) : HRESULT; // su01
    function GetFreeNodeId(aNodeTypeId : DWORD; out aNodeId : DWORD) : HRESULT; // su01
///28.03.2010

    // Database access utils
    function GetQueryDataset(aQuery : String) : TDataset; // su01
    function ExecSQL(aSQL : String) : HRESULT; // su01
    function GetOneCell(aSQL : String) : variant; // su01
    function GetRaw(aSQL : String) : variant; // su01
//    function GetAssignedNodeParams(dwNodeId : DWORD): TStringList;
    // Утилиты конвртации типов IB
    function StrToSQL(aValue : String; Default : String) : String; // su01
    function IntToSQL(aValue : Integer; Default : String) : String; // su01
    function FloatToSQL(aValue : Extended; Default : String; aMinAbsValue : Extended = 1.135E-38; aMaxAbsValue : Extended = 3.402E38) : String; // su01
    function DateToIB(ADate: TDate; Default : String = 'NULL'): String; // su01
    function DateTimeToSQL(aDateTime : TDateTime; Default : String = 'NULL'): String; // su01
    // Утилиты работы со структурой базы данных IB
    function IBGetTablePK(aTableName : String): string; // su01
    function IBTableExists(aTableName : String) : boolean; // su01
    function IBFieldExists(aTableName, aFieldName : String): boolean; // su01
    function IBViewExists(aViewName : String) : boolean; // su01
    function IBIndexExists(aIndexName : String) : boolean; // su01
    function IBProcedureExists(aProcName : String) : Boolean; // su01
    function IBTriggerExists(aTriggerName : String) : Boolean; // su01
    function IBConstraintExists(aConstrName : String) : boolean; // su01
    function IBGeneratorExists(aGeneratorName : String) : boolean; // su01
    function IBDomainExists(aDomainName : String) : boolean; // su01
    function IBObjectExists(aObjectName : String) : Boolean; // su01
  end;

{01.07.2007}
TVpNetNodeParamValue = class
private
// 28.03.2010
  function GetParamValueAssigned : boolean; // su01
  function GetDefaultParamValueAssigned : boolean; // su01
///28.03.2010
public
  NodeId : DWORD;
  ParamName : String;
  NodeTypeId : DWORD;
// 28.03.2010
//  ParamValueAssigned : boolean;
//  ParamValue : String;
  ParamValue : OleVariant;
//  DefaultParamValueAssigned : Boolean;
//  DefaultParamValue : String;
  DefaultParamValue : OleVariant;
///18.03.2010
  ForSendToHst : Boolean;
  OriginParamValue : String;
// 28.03.2010
  property ParamValueAssigned : boolean read GetParamValueAssigned;
  property DefaultParamValueAssigned : boolean read GetDefaultParamValueAssigned;
///28.03.2010
  constructor Create; overload; // su01
//  constructor Create(aNodeId : DWORD; aParamName : String; aParamValue : String); overload;
end;

TVpNetNodeParamValueList = class(TList)
private
  FRDM : TVpNetDARDM;
  function Get(Index: Integer): TVpNetNodeParamValue; // su01
  procedure Put(Index: Integer; const Value: TVpNetNodeParamValue); // su01
public
  constructor Create(aRDM : TVpNetDARDM); virtual; // su01
  destructor destroy; override; // su01
  property Items[Index: Integer]: TVpNetNodeParamValue read Get write Put; default;
  procedure DestroyItems; // su01
// 28.03.2010
//  function Find(aNodeId : DWORD; aParamName : String) : TVpNetNodeParamValue;
  function Find(aNodeId : DWORD; aNodeParam : OleVariant) : TVpNetNodeParamValue; // su01
///28.03.2010
  function NodeInList(aNodeId : DWORD) : boolean; // su01
  function ReadNodeIdParams(dwNodeId : DWORD): HRESULT; // su01
// 28.03.2010
//  function GetNodeParamValue(dwNodeId : DWORD; sParamName : String; out sValue : String): HRESULT; overload;
  function GetNodeParamValue(dwNodeId : DWORD; aNodeParam : OleVariant; out aNodeValue : OleVariant): HRESULT; overload; // su01
///28.03.2010
  function GetFirstFreeNodeId(dwNodeType : DWORD; out dwNodeId : DWORD): HRESULT; // su01
// 26.03.2010
//  function SetNodeParamValue(dwNodeId : DWORD; sParamName : String; sValue : String): HRESULT;
  function SetNodeParamValue(dwNodeId : DWORD; aNodeParam : OleVariant; aNodeValue : OleVariant; aSaveToDB : boolean = true): HRESULT; // su01
///26.03.2010

  function GetNodeParamNames(dwNodeId : DWORD; aList : TStringList): HRESULT; // su01
// 26.03.2010
//  function NodeNameById(dwNodeId : DWORD;
///26.03.2010
end;
{/01.07.2007}

implementation

{$R *.DFM}

uses VpNetDAServerCore, VpNetDefs, VpNetDADebug, uOPCUtils, VpNetHst_TLB, Math;

class procedure TVpNetDARDM.UpdateRegistry(Register: Boolean; const ClassID, ProgID: string);
begin
  try
    if Register then
    begin
      inherited UpdateRegistry(Register, ClassID, ProgID);
      EnableSocketTransport(ClassID);
      EnableWebTransport(ClassID);
    end else
    begin
      DisableSocketTransport(ClassID);
      DisableWebTransport(ClassID);
      inherited UpdateRegistry(Register, ClassID, ProgID);
    end;
  except
  end;
end;

constructor TVpNetDARDM.Create(AOwner: TComponent);
var
  aDBType : String;
  aDBFileName : String;
  aOraServer : String;
  aOraHomeName : String;
begin
  try
    inherited Create (AOwner);
  except on e : Exception do
    PostLogRecordAddMsgNow(70484, e.HelpContext, Integer(AOwner), -1, e.Message);
  end;


  bLockDBGlobally := true;
  try
    // Инициализация критической секции обращения к базе данных
    InitializeCriticalSection(FCS);

    // Создание каша параметров сущностей
    NodeParams := TVpNetNodeParamValueList.Create(self);

    DBType := DBT_NONE;
    // Определяем тип используемой базы данных
    if GetIniValue('DB', 'TYPE', aDBType) = S_OK then begin
      if UpperCase(aDBType) = 'INTERBASE' then begin
        DBType := DBT_INTERBASE;
        if GetIniValue('DB', 'FILENAME', aDBFileName) = S_OK then begin
          db.DatabaseName := aDBFileName;
        end else begin
          PostLogRecordAddMsgNow(70488, -1, -1, -1, 'Нет пути к базе данных');
        end;

        try
          db.Open;
        except on e : Exception do
          PostLogRecordAddMsgNow(70489, e.HelpContext, -1, -1, 'Ошибка открытия базы данных. ' + e.Message);
        end;

{
      end else if UpperCase(aDBType) = 'ORACLE' then begin
        DBType := DBT_ORACLE;
        OraSession.Close;
        if GetIniValue('DB', 'SERVER', aOraServer) = S_OK then begin
          OraSession.Server := aOraServer;
        end else begin
          OraSession.Server := 'XE';
        end;

        if GetIniValue('DB', 'HOME_NAME', aOraServer) = S_OK then begin
          OraSession.HomeName := aOraServer;
        end else begin
          OraSession.HomeName := 'XE';
        end;

        try
          OraSession.Open;
        except
        end;
      end else begin
}
      end else begin
        PostLogRecordAddMsgNow(70487, -1, -1, -1, 'Неправильный тип базы данных');
      end;
    end else begin
      PostLogRecordAddMsgNow(70486, -1, -1, -1, 'Тип базы данных не определен');
    end;
  except on e : Exception do
    PostLogRecordAddMsgNow(70485, e.HelpContext, Integer(AOwner), -1, e.Message);
  end;
end;

destructor TVpNetDARDM.Destroy;
begin
  try
    // Безопсаное закрытие базы данных
    db.Close;
    // Удаление каша параметров сущностей
    NodeParams.Free;
    // Удаляем критическую скцию обращения к базе данных
    DeleteCriticalSection(FCS);
  except on e : Exception do
    PostLogRecordAddMsgNow(70490, e.HelpContext, -1, -1, e.Message);
  end;

  try
    inherited;
  except on e : Exception do
    PostLogRecordAddMsgNow(70491, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TVpNetDARDM.Lock;
begin
  try
    if bLockDBGlobally then
      ServerCore.DBLock;
    EnterCriticalSection(FCS);
  except on e : Exception do
    PostLogRecordAddMsgNow(70492, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TVpNetDARDM.Unlock;
begin
  try
    LeaveCriticalSection(FCS);
    if bLockDBGlobally then
      ServerCore.DBUnlock;
  except on e : Exception do
    PostLogRecordAddMsgNow(70493, e.HelpContext, -1, -1, e.Message);
  end;
end;

// VpNet utils
// Разбираем ItemID тега на составляющие
//todo: заменить тип аргументов функции SplitItemID() с String на POleStr
function TVpNetDARDM.SplitItemID(aItemID : String; out aHostServerTag : String; out aHostServerDriverTag: String; out aDeviceTag : String; out aDeviceTypeTagTag : String; CheckTagParams : boolean = true) : HRESULT;
var
  sl : TStringList;
begin
  try
    // Очистка результатов
    aHostServerTag := EmptyStr;
    aHostServerDriverTag := EmptyStr;
    aDeviceTag := EmptyStr;
    aDeviceTypeTagTag := EmptyStr;

    // Проверка строки
    result := CheckItemIdSyntax(aItemID);
    if result = OPC_E_INVALIDITEMID then begin
      PostLogRecordAddMsgNow(70495, result, -1, -1, 'aItemID=' + aItemID);
      exit;
    end;

    // Разбор строки
    sl := TStringList.Create;
    try
      sl.Delimiter := '.';
      sl.DelimitedText := aItemID;
      // Получение тега ност-сервера
      if sl.Count > 0 then begin
        aHostServerTag := sl[0];
        sl.Delete(0);
      end;
      // Получение тега драйвера ност-сервера
      if sl.Count > 0 then begin
        aHostServerDriverTag := sl[0];
        sl.Delete(0);
      end;

      // Получение тега устройства
{18.06.2007}
//      if sl.Count > 0 then begin
//        aDeviceTag := sl[0];
//       sl.Delete(0);
//      end;
// 29.09.2010
      if CheckTagParams then begin
///29.09.2010
        if sl.Count > 1 then begin
        // Если здесь имеем больше 1 элемента, то первый - тег устройства,
        // иначе считаем, что мы разбираем тег параметра драйвера
          aDeviceTag := sl[0];
          sl.Delete(0);
        end else begin
           aDeviceTag := '';
        end;
// 29.09.2010
      end else begin
        if sl.Count > 0 then begin
          aDeviceTag := sl[0];
          sl.Delete(0);
        end;
      end;
///29.09.2010
{/18.06.2007}
      // Получение тега єлемента данных устройства (весь остаток строки)
      if sl.Count > 0 then begin
        aDeviceTypeTagTag := sl.DelimitedText;
      end;
    finally
      sl.free;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70494, e.HelpContext, -1, -1, 'aItemID=' + aItemID + '; ' + e.Message);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDARDM.SplitItemID(aItemID : String; out aHostServerID : DWORD; out aHostServerDriverID : DWORD; out aDeviceid : DWORD; out aDeviceTypeTagID : DWORD) : HRESULT;
var
  hr : HRESULT;
  HostServerTag : String;
  HostServerDriverTag : String;
  DeviceTag : String;
  DeviceTypeTagTag : String;
  ds : TDataSet;
begin
  try
    // Очистка результатов
    result := E_FAIL;
    aHostServerID := 0;
    aHostServerDriverID := 0;
    aDeviceID := 0;
    aDeviceTypeTagID := 0;

    // Разбираем идентификатор на составляющие теги
    result := SplitItemID(aItemID, HostServerTag, HostServerDriverTag, DeviceTag, DeviceTypeTagTag);

    // Если не удалось, возвращаем полученную ошибку
    if result < S_OK then begin
      PostLogRecordAddMsgNow(70497, result, -1, -1, 'aItemID=' + aItemID);
      exit;
    end;

    Lock;
    try
{26.01.2008}
      if length(DeviceTag) > 0 then begin
//      if length(HostServerTag) > 0 then begin
{/26.01.2008}
        try
          ds := GetQueryDataset(
            'select vhs.vhs_id, vhsd.vhsd_id, vd.vd_id, vdtt.vdtt_id ' +
            'from vn_host_servers vhs ' +
            'left outer join vn_host_server_drivers vhsd on vhsd.vhs_id = vhs.vhs_id  and vhsd.vhsd_tag = ''' + HostServerDriverTag + ''' ' +
            'left outer join vda_devices vd on vd.vhsd_id = vhsd.vhsd_id and vd.vd_tag = ''' + DeviceTag + ''' ' +
            'left outer join VDA_DEVICE_TYPE_VERSIONS VDTV on vdtv.vdtv_id = vd.vdtv_id ' +
            'left outer join vda_device_type_tags vdtt on vdtt.vdtv_id = vdtv.vdtv_id and vdtt.vdtt_tag = ''' + DeviceTypeTagTag + ''' ' +
            'where vhs.vhs_tag = ''' + HostServerTag + ''' '
          );

          ds.Open;
          if not ds.Eof then begin
            if not ds.FieldByName('vhs_id').IsNull then aHostServerID := ds.FieldByName('vhs_id').AsInteger;
            if not ds.FieldByName('vhsd_id').IsNull then aHostServerDriverID := ds.FieldByName('vhsd_id').AsInteger;
            if not ds.FieldByName('vd_id').IsNull then aDeviceID := ds.FieldByName('vd_id').AsInteger;
    {!!!}   if not ds.FieldByName('vdtt_id').IsNull then aDeviceTypeTagID := ds.FieldByName('vdtt_id').AsInteger;
          end;
        finally
          ds.free;
        end;
{18.06.2007}
      end else begin
        // разбираем параметр драйвера
        try
          ds := GetQueryDataset(
            'select vhs.vhs_id, vhsd.vhsd_id, hdtp.hdtp_id from vn_host_servers vhs ' +
            'left outer join vn_host_server_drivers vhsd on vhsd.vhs_id = vhs.vhs_id ' +
            'left outer join vn_host_server_driver_types vhsdt on vhsdt.vhsdt_id = vhsd.vhsdt_id ' +
            'left outer join hst_driver_type_params hdtp on hdtp.vhsdt_id = vhsdt.vhsdt_id ' +
            'where upper(vhs.vhs_tag) = upper(''' + HostServerTag + ''' collate WIN1251) ' +
            '  and upper(vhsd.vhsd_tag) = upper(''' + HostServerDriverTag + ''' collate WIN1251) ' +
            '  and upper(hdtp.hdtp_short_name collate WIN1251) = upper(''' + DeviceTypeTagTag + ''' collate WIN1251) '
          );
          ds.Open;
          if not ds.Eof then begin
            if not ds.FieldByName('vhs_id').IsNull then aHostServerID := ds.FieldByName('vhs_id').AsInteger;
            if not ds.FieldByName('vhsd_id').IsNull then aHostServerDriverID := ds.FieldByName('vhsd_id').AsInteger;
            aDeviceID := 0;
            if not ds.FieldByName('hdtp_id').IsNull then aDeviceTypeTagID := ds.FieldByName('hdtp_id').AsInteger;
          end;
        finally
          ds.free;
        end;
{/18.06.2007}
      end
    finally
      Unlock;
    end;

    // Если удалось получить идентификаторы всех составляющих ItemID,
    // возвращаем S_OK, иначе возвращаем OPC_E_UNKNOWNITEMID
    if (aHostServerID > 0) and
       (aHostServerDriverID > 0) and
{18.06.2007}
    // При разборе параметра драйвера aDeviceID = 0
//       (aDeviceID > 0) and
{/18.06.2007}
       (aDeviceTypeTagID > 0)
    then
      result := S_OK
    else begin
      PostLogRecordAddMsgNow(70498, -1, -1, -1, 'aItemID=' + aItemID);
      result := S_FALSE;
    end;

  except on e : Exception do begin
      PostLogRecordAddMsgNow(70496, e.HelpContext, -1, -1, 'aItemID=' + aItemID + '; ' + e.Message);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDARDM.SplitBranch(aBranchID : String; out aHostServerTag : String; out aHostServerDriverTag : String; out aDeviceTag : String) : HRESULT;
var
  sl : TStringList;
begin
  try
    // Очистка результатов
    aHostServerTag := EmptyStr;
    aHostServerDriverTag := EmptyStr;
    aDeviceTag := EmptyStr;

    // Проверка строки
    result := CheckItemIdSyntax(aBranchID);
    if result = OPC_E_INVALIDITEMID then begin
      PostLogRecordAddMsgNow(70500, result, -1, -1, '');
      exit;
    end;

    // Разбор строки
    sl := TStringList.Create;
    try
      sl.Delimiter := '.';
      sl.DelimitedText := aBranchID;
      // Получение тега ност-сервера
      if sl.Count > 0 then begin
        aHostServerTag := sl[0];
        sl.Delete(0);
      end;
      // Получение тега драйвера ност-сервера
      if sl.Count > 0 then begin
        aHostServerDriverTag := sl[0];
        sl.Delete(0);
      end;
      if sl.Count > 0 then begin
        aDeviceTag := sl[0];
        sl.Delete(0);
      end;

      result := S_OK;
    finally
      sl.free;
    end;

  except on e : Exception do begin
      PostLogRecordAddMsgNow(70499, e.HelpContext, -1, -1, 'aBranchID=' + aBranchID + '; ' + e.Message);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDARDM.SplitBranch(aBranchID : String; out aHostServerID : DWORD; out aHostServerDriverID : DWORD; out aDeviceid : DWORD) : HRESULT;
var
  hr : HRESULT;
  HostServerTag : String;
  HostServerDriverTag : String;
  DeviceTag : String;
  ds : TDataSet;
begin
  try
    // Очистка результатов
    result := E_FAIL;
    aHostServerID := 0;
    aHostServerDriverID := 0;
    aDeviceID := 0;

    // Разбираем идентификатор на составляющие теги
    result := SplitBranch(aBranchID, HostServerTag, HostServerDriverTag, DeviceTag);

    // Если не удалось, возвращаем полученную ошибку
    if result < S_OK then begin
      PostLogRecordAddMsgNow(70502, result, -1, -1, '');
      exit;
    end;
    Lock;
    try
      ds := GetQueryDataset(
        'select vhs.vhs_id, vhsd.vhsd_id, vd.vd_id ' +
        'from vn_host_servers vhs ' +
        'left outer join vn_host_server_drivers vhsd on vhsd.vhs_id = vhs.vhs_id  and vhsd.vhsd_tag = ''' + HostServerDriverTag + ''' ' +
        'left outer join vda_devices vd on vd.vhsd_id = vhsd.vhsd_id and vd.vd_tag = ''' + DeviceTag + ''' ' +
        'where vhs.vhs_tag = ''' + HostServerTag + ''' '
      );
      ds.Open;
      if not ds.Eof then begin
        if not ds.FieldByName('vhs_id').IsNull then aHostServerID := ds.FieldByName('vhs_id').AsInteger;
        if not ds.FieldByName('vhsd_id').IsNull then aHostServerDriverID := ds.FieldByName('vhsd_id').AsInteger;
        if not ds.FieldByName('vd_id').IsNull then aDeviceID := ds.FieldByName('vd_id').AsInteger;
      end else begin
        PostLogRecordAddMsgNow(70503, -1, -1, -1, '', llErrors_Level2);
      end;

      result := S_OK;
    finally
      ds.free;
      Unlock;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70501, e.HelpContext, -1, -1, 'aBranchID=' + aBranchID + '; ' + e.Message);
      result := E_FAIL;
    end;  
  end;
end;

function TVpNetDARDM.GetItemType(aID : String; out dwType : DWORD) : HRESULT;
var
  sl : TStringList;
  v : OleVariant;
begin
  try
    dwType := 0;

    // Проверка строки
    result := CheckItemIdSyntax(aID);
    if result = OPC_E_INVALIDITEMID then begin
      PostLogRecordAddMsgNow(70505, -1, -1, -1, '');
      exit;
    end;

    sl := TStringList.Create;
    try
      sl.Delimiter := '.';
      sl.DelimitedText := aID;
      if (sl.Count > 0) and (sl.Count < 3) then begin
        dwType := 1;
        exit;
      end else if (sl.Count = 3) then begin
        v := GetOneCell(
          'select vd.vd_id from vn_host_servers vhs, ' +
          'vn_host_server_drivers vhsd, vda_devices vd ' +
          'where vhsd.vhs_id = vhs.vhs_id and ' +
          'vd.vhsd_id = vhsd.vhsd_id ' +
          'and upper(vhs.vhs_tag collate WIN1251) = upper("'+sl[0]+'" collate WIN1251) ' +
          'and upper(vhsd.vhsd_tag collate WIN1251) = upper("'+sl[1]+'" collate WIN1251) ' +
          'and upper(vd.vd_tag collate WIN1251) = upper("'+sl[2]+'" collate WIN1251) '
        );
        if not(varIsNull(v)) then begin
          dwType := 1;
          exit;
        end else begin
          dwType := 2;
          exit;
        end;
      end else if (sl.Count = 4) then begin
        dwType := 2;
        exit;
      end;
    finally
      sl.free;
    end;

    result := S_OK;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70504, e.HelpContext, -1, -1, 'aID=' + aID + '; ' + e.Message);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDARDM.NodeIdToItemId(dwNodeId : DWORD; out aItemID : String): HRESULT;
var
  dwNodeType : DWORD;
  hr : HRESULT;
  v : OleVariant;
(*
VNT_HostServer = 136;
VNT_Device = 125;
VNT_HostServerDriver = 119;
VNT_HostServerDriverParam = 121;
VNT_NodeParam = 198;
VNT_Device_Type_Tag_Group = 123;
VNT_Device_Type_Tag = 130;
VNT_DA_Server = 132;
*)
begin
  try
    result := GetNodeType(dwNodeId, dwNodeType);
    aItemID := EmptyStr;
    if result < S_OK then begin
      PostLogRecordAddMsgNow(70507, result, -1, -1, '');
      exit;
    end;

    if dwNodeType = VNT_DA_Server then begin
      aItemID := '';
      result := S_OK;
    end else if dwNodeType = VNT_HostServer then begin
// 4.04.2010
//      aItemID := GetOneCell('select vhs_tag from vn_host_servers vhs where vhs_id = ' + IntToStr(dwNodeId));
      v := GetOneCell('select vhs_tag from vn_host_servers vhs where vhs_id = ' + IntToStr(dwNodeId));
      if not VarIsNull(v) then begin
        aItemID := v;
      end else begin
        aItemID := EmptyStr;
        PostLogRecordAddMsgNow(70509, -1, -1, -1, '');
      end;
///4.04.2010
      result := S_OK;
    end else if dwNodeType = VNT_HostServerDriver then begin
      v := GetRaw(
        'select vhs.vhs_tag, vhsd.vhsd_tag ' +
        'from vn_host_servers vhs, vn_host_server_drivers vhsd ' +
        'where vhsd.vhs_id = vhs.vhs_id and vhsd.vhsd_id =  ' + IntToStr(dwNodeId)
      );
      if not(VarIsArray(v)) then begin
        PostLogRecordAddMsgNow(70508, -1, -1, -1, '');
        exit;
      end;
      aItemID := v[0] + '.' + v[1];
      result := S_OK;
    end else if dwNodeType = VNT_Device then begin
      v := GetRaw(
        'select vhs.vhs_tag, vhsd.vhsd_tag, vd.vd_tag from ' +
        'vn_host_servers vhs, vn_host_server_drivers vhsd, ' +
        'vda_devices vd where vhsd.vhs_id = vhs.vhs_id and ' +
        'vd.vhsd_id = vhsd.vhsd_id and vd.vd_id = ' + IntToStr(dwNodeId)
      );
      if not(VarIsArray(v)) then begin
        PostLogRecordAddMsgNow(70510, -1, -1, -1, '');
        exit;
      end;
      aItemID := v[0] + '.' + v[1] + '.' + v[2];
      result := S_OK;

    end else if dwNodeType = VNT_Device_Type_Tag then begin
//todo: дописать
      PostLogRecordAddMsgNow(70512, dwNodeType, -1, -1, '');

    end else begin
      PostLogRecordAddMsgNow(70511, dwNodeType, -1, -1, '');
      aItemID := EmptyStr;
      result := E_INVALIDARG;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70506, e.HelpContext, dwNodeId, -1, e.Message);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDARDM.ItemIdToNodeId(aItemID : String; out dwNodeId : DWORD): HRESULT;
var
  aHostServerID : DWORD;
  aHostServerDriverID : DWORD;
  aDeviceid : DWORD;
  aDeviceTypeTagID : DWORD;
  dwItemType : DWORD;
begin
  try
    dwNodeId := 0;
    // Проверка тега
    result := CheckItemIdSyntax(aItemID);
    if result < S_OK then begin
      PostLogRecordAddMsgNow(70514, result, -1, -1, 'aItemID=' + aItemID);
      exit;
    end;

    result := GetItemType(aItemID, dwItemType);
    if result < S_OK then begin
      PostLogRecordAddMsgNow(70515, result, dwItemType, -1, 'aItemID=' + aItemID);
      exit;
    end;

    if dwItemType = 1 {branch} then begin
      aDeviceTypeTagID := 0;
      result := SplitBranch(aItemID, aHostServerID, aHostServerDriverID, aDeviceid);
      if result < S_OK then exit;
    end else if dwItemType = 2 {leaf (tag)} then begin
      result := SplitItemID(aItemID, aHostServerID, aHostServerDriverID, aDeviceid, aDeviceTypeTagID);
      if result < S_OK then exit;
    end else begin
      PostLogRecordAddMsgNow(70516, dwItemType, -1, -1, 'aItemID = ' + aItemID, llErrors_Level2);
      result := E_INVALIDARG;
      exit;
    end;

    if aDeviceTypeTagID > 0 then begin
      dwNodeId := aDeviceTypeTagID;
    end else if aDeviceid > 0 then begin
      dwNodeId := aDeviceid;
    end else if aHostServerDriverID > 0 then begin
      dwNodeId := aHostServerDriverID;
    end else if aHostServerID > 0 then begin
      dwNodeId := aHostServerID;
    end else begin
      PostLogRecordAddMsgNow(70517, -1, -1, -1, 'aItemID=' + aItemID, llErrors_Level2);
      result := OPC_E_UNKNOWNITEMID;
      exit;
    end;
    result := S_OK;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70513, e.HelpContext, -1, -1, e.Message+ '; aItemID=' + aItemID);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDARDM.GetNodeType(dwNodeId : DWORD; out dwNodeType : DWORD): HRESULT;
var
  v : OleVariant;
begin
  try
    v := GetOneCell(
      'select vnt_id from vn_node_id_ranges vnir ' +
      'where (vnir.vnir_min_id <= '+IntToStr(dwNodeId)+') and (vnir.vnir_max_id >= '+IntToStr(dwNodeId)+') '
    );
    if VarIsOrdinal(v) then begin
      try
        dwNodeType := v;
        result := S_OK;
      except on e : Exception do begin
          PostLogRecordAddMsgNow(70520, e.HelpContext, -1, -1, e.Message);
          dwNodeType := 0;
          result := E_UNEXPECTED;
        end;  
      end;
    end else begin
      PostLogRecordAddMsgNow(70519, -1, -1, -1, '');
      dwNodeType := 0;
      result := E_INVALIDARG;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70518, e.HelpContext, dwNodeId, -1, e.Message);
      dwNodeType := 0;
      result := E_FAIL;
    end;  
  end;
end;
// 28.03.2010
function TVpNetDARDM.GetNodeParamName(dwNodeId : DWORD; aNodeParam : OleVariant; out aNodeParamName : String) : HRESULT;
var
  v : OleVariant;
  VNT_ID : DWORD;
  hr : HRESULT;
begin
  try
    aNodeParamName := EmptyStr;
    result := E_UNEXPECTED;
    if VarIsStr(aNodeParam) then begin
      aNodeParamName := aNodeParam;
    end else if VarIsOrdinal(aNodeParam) then begin
      hr := GetNodeType(dwNodeId, VNT_ID);
      if not(hr = S_OK) then begin
        PostLogRecordAddMsgNow(70522, dwNodeId, hr, -1, '');
        Result := E_FAIL;
// 4.04.2010
        exit; // если не смогли определить тпи элемента - выходим с ошибкой
///4.04.2010
      end;
      if VNT_ID = VNT_HostServerDriver then begin
        v := GetOneCell(
          'select HDTP_SHORT_NAME from hst_driver_type_params ' +
          'where VHSDT_ID = ( ' +
          '  select VHSDT_ID from vn_host_server_drivers vhsd ' +
          '  where vhsd.VHSD_ID = ' + IntToStr(dwNodeId) + ' ' +
          ') and HDTP_ID = ' + IntToStr(aNodeParam)
        );
      end else begin
        v := GetOneCell(
          'select VNVP_PARAM_NAME from  VN_NODE_VALID_PARAMS VNVP ' +
          'where VNT_ID = ' + IntToStr(VNT_ID) + ' and VNVP_PARAM_ID = ' + IntToStr(aNodeParam)
        );
      end;
      if VarIsStr(v) then begin
        aNodeParamName := v;
      end else begin
        PostLogRecordAddMsgNow(70523, dwNodeId, -1, -1, '');
        result := E_INVALIDARG;
// 4.04.2010
        exit;
///4.04.2010
      end;
    end else begin
      PostLogRecordAddMsgNow(70524, dwNodeId, -1, -1, '');
      result := E_INVALIDARG;
// 4.04.2010
      exit;
///4.04.2010
    end;
    result := S_OK;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70521, e.HelpContext, dwNodeId, -1, e.Message);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDARDM.GetNodeParamId(dwNodeId : DWORD; aNodeParam : OleVariant; out aNodeParamId : DWORD) : HRESULT;
var
  VNT_ID : DWORD;
  v : OleVariant;
  hr : HRESULT;
begin
  try
    aNodeParamId := 0;
    result := E_UNEXPECTED;
    if VarIsOrdinal(aNodeParam) then begin
      result := aNodeParam;
    end else if VarIsStr(aNodeParam) then begin
      hr := GetNodeType(dwNodeId, VNT_ID);
      if not(hr = S_OK) then begin
        Result := E_FAIL;
        PostLogRecordAddMsgNow(70526, dwNodeId, hr, -1, '');
// 4.04.2010
        exit;
///4.04.2010
      end;
      if VNT_ID = VNT_HostServerDriver then begin
        v := GetOneCell(
          'select HDTP_ID from hst_driver_type_params ' +
          'where VHSDT_ID = ( ' +
          '  select VHSDT_ID from vn_host_server_drivers vhsd + ' +
          '  where vhsd.VHSD_ID = ' + IntToStr(dwNodeId) + ' ' +
          ') and HDTP_ID = ' + IntToStr(aNodeParam)
        );
      end else begin
        v := GetOneCell(
          'select VNVP_PARAM_ID from  VN_NODE_VALID_PARAMS VNVP ' +
          'where VNT_ID = ' + IntToStr(VNT_ID) + ' and VNVP_PARAM_ID = ' + IntToStr(aNodeParam)
        );
      end;
      if VarIsOrdinal(v) then begin
        result := v;
      end else begin
        result := E_INVALIDARG;
        PostLogRecordAddMsgNow(70527, dwNodeId, -1, -1, '');
      end;
    end else begin
      result := E_INVALIDARG;
      PostLogRecordAddMsgNow(70528, dwNodeId, -1, -1, '');
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70525, e.HelpContext, dwNodeId, -1, e.Message);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDARDM.IsNodeParamValueInBase(dwNodeId : DWORD; aNodeParam : OleVariant) : boolean;
var
  v : OleVariant;
  VNT_ID : DWORD;
  NodeParamId : DWORD;
  hr : HRESULT;
begin
  try
    result := false;
    hr := GetNodeParamId(dwNodeId, aNodeParam, NodeParamId);
    if hr < S_OK then begin
      PostLogRecordAddMsgNow(70530, dwNodeId, hr, -1, '');
      exit;
    end;
    hr := GetNodeType(dwNodeId, VNT_ID);
    if hr < S_OK then begin
      PostLogRecordAddMsgNow(70531, dwNodeId, hr, -1, '');
      exit;
    end;
    if VNT_ID = VNT_HostServerDriver then begin
      v := GetOneCell(
        'select count(*) from hstcommdriverparams ' +
        'where vhsd_id = ' + IntToStr(dwNodeId) + ' and hdtp_id = ' + IntToStr(NodeParamId)
      );
      result := (VarIsOrdinal(v) and (v > 0));
      if not result then begin
        PostLogRecordAddMsgNow(70532, dwNodeId, -1, -1, '');
      end;
    end else begin
      v := GetOneCell(
        'select * from vn_node_params ' +
        'where NODE_ID = ' + IntToStr(dwNodeId) + ' and VNVP_ID = ' + IntToStr(NodeParamId)
      );
      result := (VarIsOrdinal(v) and (v > 0));
      if not result then begin
        PostLogRecordAddMsgNow(70533, dwNodeId, -1, -1, '');
      end;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70529, e.HelpContext, dwNodeId, -1, e.Message);
      result := false;
    end;
  end;
end;
function TVpNetDARDM.GetNodeParamBySQL(aNodeId : DWORD; aParamName : String; out ADefValue, AValue : Variant): HRESULT;
var
  NodeTypeId : DWORD;
  v : Variant;
  sSQL : String;
  hr : HRESULT;
begin
  try
    sSQL := '';
    hr := GetNodeType(aNodeId, NodeTypeId);
    if hr >= S_OK then begin
      case NodeTypeId of
        119: begin
          sSQL :=
            'select hdtp.hdtp_default_value, hcdp.hcdp_value ' +
            'from hst_driver_type_params hdtp ' +
            'left outer join hstcommdriverparams hcdp on hcdp.hdtp_id = hdtp.hdtp_id and hcdp.vhsd_id = '+IntToStr(aNodeId) + ' ' +
            'where hdtp.hdtp_short_name = ''' + aParamName + '''';
          v := GetRaw(sSQL);
        end;
        else begin
          sSQL :=
            'select vnvp_default_value default_value, vnp.vnp_value param_value from vn_node_valid_params vnvp ' +
            'left outer join vn_node_params vnp on vnp.vnvp_id = vnvp.vnvp_id and vnp.node_id = '+IntToStr(aNodeId) + ' ' +
            'where vnvp.VNT_ID = ' + IntToStr(NodeTypeId) + ' and vnvp.vnvp_param_name = ''' + aParamName + '''';
          v := GetRaw(sSQL);
        end;
      end;
    end else begin
      PostLogRecordAddMsgNow(70535, aNodeId, hr, -1, 'aParamName=' + aParamName);
      ADefValue := null;
      AValue := null;
      result := E_INVALIDARG;
// 4.04.2010
      exit;
///4.04.2010
    end;
    if VarIsArray(v) then begin
      ADefValue := v[0];
      AValue := v[1];
      result := S_OK;
    end else begin
      PostLogRecordAddMsgNow(70536, aNodeId, -1, -1, 'aParamName=' + aParamName);
      ADefValue := null;
      AValue := null;
      result := E_INVALIDARG;
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70534, e.HelpContext, aNodeId, -1, e.Message + '; aParamName=' + aParamName);
      aNodeId := 0;
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDARDM.SetNodeParamBySQL(aNodeId : DWORD; aNodeParam : OleVariant; aNodeParamValue : OleVariant) : HRESULT;
var
  NodeTypeId : DWORD;
  vNodeParamTypeId : Variant;
  vDefValue, vNodeParamDBValue : Variant;
  NewParamId : DWORD;
  vNodeTypeId : DWORD;
  aParamName : String;
  aParamValue : String;
  hr, hr2 : HRESULT;

begin
  try
    // Если не можем получить имя параметра, выходим с ошибкой
    hr := GetNodeParamName(aNodeId, aNodeParam, aParamName);
    if hr < S_OK then begin
      PostLogRecordAddMsgNow(70539, aNodeId, hr, -1, '');
      result := hr;
      exit;
    end;

    // если не удается получить тип нода или значение его параметра в базе,
    // выходим с ошибкой
    hr := GetNodeType(aNodeId, NodeTypeId);
    hr2 := GetNodeParamBySQL(aNodeId, aParamName, vDefValue, vNodeParamDBValue);
    if (hr < S_OK) or (hr2 < S_OK) then begin
      PostLogRecordAddMsgNow(70540, aNodeId, hr, hr2, '');
      result := E_INVALIDARG;
      exit;
    end;

    // Если новое значение параметра - null удаляем параметр из базы
    if VarIsNull(aNodeParamValue) then begin
      PostLogRecordAddMsgNow(70541, aNodeId, -1, -1, '');
      result := DeleteNodeParamBySQL(aNodeId, aParamName);
      if result <> S_OK then begin
        PostLogRecordAddMsgNow(70542, aNodeId, result, -1, '');
      end;
      exit;
    end;

    // Получаем строковое представление нового значения
    aParamValue := aNodeParamValue;

    if NodeTypeId = VNT_HostServerDriver then begin
      if VarIsNull(vNodeParamDBValue) then begin
        // До этого момента значение параметра НЕБЫЛО определено

        // Пытаемся выделить свободный id параметра драйвера
        hr := GetFreeNodeId(VNT_HostServerDriverParam, NewParamId);
// 4.04.2010
//        if hr < S_OK then begin
        if hr <> S_OK then begin
///4.04.2010
          PostLogRecordAddMsgNow(70543, aNodeId, hr, -1, '');
          result := E_INVALIDARG;
          exit;
        end;

        //Находим id типа параметра
        vNodeTypeId := GetOneCell(
          'select hdtp.hdtp_id from hst_driver_type_params hdtp ' +
          'where hdtp.vhsdt_id = (select vhsdt_id from vn_host_server_drivers vhsd where vhsd_id = '+IntToStr(aNodeId)+' ' +
          ') and hdtp.hdtp_short_name = '''+aParamName+''''
        );

        if VarIsNull(vNodeTypeId) then begin
          PostLogRecordAddMsgNow(70544, aNodeId, -1, -1, '');
          result := E_INVALIDARG;
          exit;
        end;

        if VarIsEmpty(vNodeTypeId) then begin
          PostLogRecordAddMsgNow(70545, aNodeId, -1, -1, '');
          result := E_INVALIDARG;
          exit;
        end;

        // Вставляем запись со значением параметра
        hr := ExecSQL(
          'insert into hstcommdriverparams values ( ' +
          '  '+IntToStr(NewParamId)+', '+IntToStr(aNodeId)+', '+IntToStr(vNodeTypeId)+', '''+aParamValue+'''' +
          ')'
        );
        if hr < S_OK then begin
          PostLogRecordAddMsgNow(70546, aNodeId, hr, -1, '');
          result := hr;
          exit;
        end;

        hr := ExecSQL('commit');
        if hr < S_OK then begin
          PostLogRecordAddMsgNow(70547, aNodeId, hr, -1, '');
          result := hr;
          exit;
        end;
      end else begin
        // До этого момента значение параметра БЫЛО определено
        hr := ExecSQL(
          'update hstcommdriverparams set hcdp_value = '''+aParamValue+''' '+
          'where hdtp_id = ( ' +
          'select hdtp_id from hst_driver_type_params where hdtp_short_name = '''+aParamName+''' and vhsdt_id = (select vhsdt_id from vn_host_server_drivers where vhsd_id = '+IntToStr(aNodeId)+')) and ' +
          'vhsd_id = ' + IntToStr(aNodeId)
        );
        if hr < S_OK then begin
          PostLogRecordAddMsgNow(70548, aNodeId, hr, -1, '');
          result := hr;
          exit;
        end;

        hr := ExecSQL('commit');
        if hr < S_OK then begin
          PostLogRecordAddMsgNow(70549, aNodeId, hr, -1, '');
          result := hr;
          exit;
        end;
      end;
    end else begin
      if VarIsNull(vNodeParamDBValue) then begin
        // До этого момента значение параметра НЕБЫЛО определено

        // Пытаемся выделить свободный id параметра сущности
        hr := GetFreeNodeId(VNT_NodeParam, NewParamId);
// 4.04.2010
//        if hr < S_OK then begin
        if hr <> S_OK then begin
///4.04.2010
          PostLogRecordAddMsgNow(70550, aNodeId, hr, -1, '');
          result := E_INVALIDARG;
          exit;
        end;

        //Находим id типа параметра
        vNodeParamTypeId := GetOneCell(
          'select vnvp.vnvp_id from vn_node_valid_params vnvp ' +
          'where vnvp.vnt_id = '+IntToStr(NodeTypeId)+' and vnvp.vnvp_param_name = ''' + aParamName + ''' '
        );

        if VarIsNull(vNodeTypeId) then begin
          PostLogRecordAddMsgNow(70551, aNodeId, -1, -1, '');
          result := E_INVALIDARG;
          exit;
        end;

        if VarIsEmpty(vNodeTypeId) then begin
          PostLogRecordAddMsgNow(70552, aNodeId, -1, -1, '');
          result := E_INVALIDARG;
          exit;
        end;

        // Вставляем запись со значением параметра
        hr := ExecSQL(
          'insert into vn_node_params values ( ' +
          '  '+IntToStr(NewParamId)+', '+IntToStr(aNodeId)+', '+IntToStr(vNodeParamTypeId)+', '''+aParamValue+''' ' +
          ')'
        );
        if hr < S_OK then begin
          PostLogRecordAddMsgNow(70553, aNodeId, hr, -1, '');
          result := hr;
          exit;
        end;

        hr := ExecSQL('commit');
        if hr < S_OK then begin
          PostLogRecordAddMsgNow(70554, aNodeId, hr, -1, '');
          result := hr;
          exit;
        end;
      end else begin
        // До этого момента значение параметра БЫЛО определено
          hr := ExecSQL(
            'update vn_node_params vnp set vnp_value = '''+aParamValue+''' ' +
            'where vnp.vnvp_id = ( ' +
            '    select vnvp.vnvp_id from vn_node_valid_params vnvp ' +
            '    where vnvp.vnvp_param_name = '''+aParamName+''' and vnt_id = '+IntToStr(NodeTypeId)+' ' +
            '  ) ' +
            '  and node_id = ' + IntToStr(aNodeId)
          );
          if hr < S_OK then begin
            PostLogRecordAddMsgNow(70555, aNodeId, hr, -1, '');
            result := hr;
            exit;
          end;

          hr := ExecSQL('commit');
          if hr < S_OK then begin
            PostLogRecordAddMsgNow(70556, aNodeId, hr, -1, '');
            result := hr;
            exit;
          end;
      end;
    end;
    result := S_OK;
// 4.04.2010
//    exit;
///4.04.2010
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70538, e.HelpContext, aNodeId, -1, e.Message);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDARDM.DeleteNodeParamBySQL(aNodeId : DWORD; aParamName : String) : HRESULT;
var
  NodeTypeId : DWORD;
  hr : HRESULT;
begin
  try
    hr := GetNodeType(aNodeId, NodeTypeId);
    if hr < S_OK then begin
      PostLogRecordAddMsgNow(70558, aNodeId, hr, -1, 'aParamName=' + aParamName);
      result := E_INVALIDARG;
      exit;
    end;
    if NodeTypeId = 119 then begin
      hr := ExecSQL(
        'delete from hstcommdriverparams '+
        'where hdtp_id = (select hdtp_id from hst_driver_type_params where hdtp_short_name = '''+aParamName+''' and vhsdt_id = (select vhsdt_id from vn_host_server_drivers where vhsd_id = '+IntToStr(aNodeId)+')) ' +
        'and vhsd_id = ' + IntToStr(aNodeId)
      );
      if hr < S_OK then begin
        PostLogRecordAddMsgNow(70559, aNodeId, hr, -1, 'aParamName=' + aParamName);
        result := hr;
        exit;
      end;

      hr := ExecSQL('commit');
      if hr < S_OK then begin
        PostLogRecordAddMsgNow(70560, aNodeId, hr, -1, 'aParamName=' + aParamName);
        result := hr;
        exit;
      end;
    end else begin
      hr := ExecSQL(
        'delete from vn_node_params '+
        'where vnvp_id = (select vnvp_id from vn_node_valid_params where vnvp_param_name = '''+aParamName+''' and vnt_id = '+IntToStr(NodeTypeId)+') ' +
        'and node_id = ' + IntToStr(aNodeId)
      );
      if hr < S_OK then begin
        PostLogRecordAddMsgNow(70561, aNodeId, hr, -1, 'aParamName=' + aParamName);
        result := hr;
        exit;
      end;

      hr := ExecSQL('commit');
      if hr < S_OK then begin
        PostLogRecordAddMsgNow(70562, aNodeId, hr, -1, 'aParamName=' + aParamName);
        result := hr;
        exit;
      end;
    end;
// 4.04.2010
    result := S_OK;
///4.04.2010
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70557, e.HelpContext, aNodeId, -1, e.Message + '; aParamName=' + aParamName);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetDARDM.GetFreeNodeId(aNodeTypeId : DWORD; out aNodeId : DWORD) : HRESULT;
var
  dsIdRanges : TDataSet;
  v : Variant;
  TableName : String;
  Prefix : String;
  IdCount : Variant;
begin
  try
    dsIdRanges := GetQueryDataset(
      'select * from vn_node_types vnt, vn_node_id_ranges vnir ' +
      'where vnir.vnt_id = vnt.vnt_id and vnt.vnt_id = ' + IntToStr(aNodeTypeId)
    );

    if not assigned(dsIdRanges) then begin
      PostLogRecordAddMsgNow(70564, aNodeTypeId, -1, -1, '');
    end;

    try
      // Проход по диапазонам id данного типа сущностей
      v := null;
      dsIdRanges.Open;
      while not(VarIsOrdinal(v)) and not(dsIdRanges.Eof) do begin
        TableName := dsIdRanges.FieldByName('VNT_TABLE_NAME').AsString;
        Prefix := dsIdRanges.FieldByName('VNT_TABLE_FIELD_PREFIX').AsString;
        // поиск свободного id в очередном диапазоне


        v := GetOneCell(
          'select max(tbl.'+PREFIX+'_ID+1) from '+TableName+' tbl ' +
          'where ' +
          '  tbl.'+PREFIX+'_id >= (select VNIR_MIN_ID from vn_node_id_ranges where vnir_id = '+IntToStr(dsIdRanges.FieldByName('VNIR_ID').AsInteger)+') and ' +
          '  tbl.'+PREFIX+'_id <= (select VNIR_MAX_ID from vn_node_id_ranges where vnir_id = '+IntToStr(dsIdRanges.FieldByName('VNIR_ID').AsInteger)+') and ' +
          '  (select count(*) from '+TableName+' tbl2 where (tbl2.'+PREFIX+'_ID = (tbl.'+PREFIX+'_ID + 1))) = 0 '

        );

        if not VarIsOrdinal(v) then begin
          IdCount := GetOneCell(
            'select count(*) from '+TableName+' tbl ' +
            'where ' +
            '  tbl.'+PREFIX+'_id >= (select VNIR_MIN_ID from vn_node_id_ranges where vnir_id = '+IntToStr(dsIdRanges.FieldByName('VNIR_ID').AsInteger)+') and ' +
            '  tbl.'+PREFIX+'_id <= (select VNIR_MAX_ID from vn_node_id_ranges where vnir_id = '+IntToStr(dsIdRanges.FieldByName('VNIR_ID').AsInteger)+') '
          );
          if VarIsOrdinal(IdCount) and IdCount = 0 then begin
             v := VarAsType(GetOneCell('select VNIR_MIN_ID from vn_node_id_ranges where vnir_id = '+IntToStr(dsIdRanges.FieldByName('VNIR_ID').AsInteger)), varInteger);
          end
        end;

        dsIdRanges.Next;
      end;
      if VarIsOrdinal(v) then begin
        aNodeId := v;
        result := S_OK;
      end else begin
        PostLogRecordAddMsgNow(70565, aNodeTypeId, -1, -1, '');
        aNodeId := 0;
        result := S_FALSE;
      end;
    finally
      dsIdRanges.Free;
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70563, e.HelpContext, aNodeTypeId, -1, e.Message);
      aNodeId := 0;
      result := E_FAIL;
    end;
  end;
end;
///28.03.2010


// Database access utils
function TVpNetDARDM.GetQueryDataset(aQuery : String) : TDataset;
var
  q : TIBQuery;
begin
  // Для Interbase (Firebird)
  try
    q := TIBQuery.Create(nil);
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70566, e.HelpContext, -1, -1, e.Message);
      result := nil;
      exit;
    end;
  end;

  try
    q.SQL.Text := aQuery;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70567, e.HelpContext, -1, -1, e.Message + '; sql="' + aQuery + '"');
      result := nil;
    end;
  end;

  try
    q.Database := db;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70568, e.HelpContext, -1, -1, e.Message + '; sql="' + aQuery + '"');
      result := nil;
    end;
  end;

  try
    q.Transaction := tr;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70569, e.HelpContext, -1, -1, e.Message);
      result := nil;
    end;
  end;

  try
    result := TDataSet(q);
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70570, e.HelpContext, -1, -1, e.Message);
      result := nil
    end;
  end;
end;

// 4.04.2010
(*
function TVpNetDARDM.ExecSQL(aSQL : String) : HRESULT;
var
  ibsql : TIBSQL;
begin
  // Для Interbase (Firebird)
  try
    Lock;
    try
      ibsql := TIBSQL.Create(nil);
      ibsql.Database := db;
      ibsql.Transaction := tr;
      ibsql.SQL.Text := aSQL;
      try
        ibsql.ExecQuery;
        result := S_OK;
      finally
        ibsql.Free;
      end;
    finally
      Unlock;
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70571, e.HelpContext, -1, -1, e.Message + '; sql="' + aSQL +'"');
      Result := E_FAIL;
    end;
  end;
end;
*)
function TVpNetDARDM.ExecSQL(aSQL : String) : HRESULT;
var
  ibsql : TIBSQL;
begin
  // Для Interbase (Firebird)
  try
    result := E_UNEXPECTED;
    Lock;
    try
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Database := db;
        ibsql.Transaction := tr;
        ibsql.SQL.Text := aSQL;
        ibsql.ExecQuery;
        result := S_OK;
      finally
        ibsql.Free;
      end;
    finally
      Unlock;
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70571, e.HelpContext, -1, -1, e.Message + '; sql="' + aSQL +'"');
      Result := E_FAIL;
    end;
  end;
end;
(*
function TVpNetDARDM.GetOneCell(aSQL : String) : variant;
var
  ds : TDataSet;
begin
  // Для Interbase (Firebird)
  result := Null;
  try
    Lock;
    try
      try
        ds := GetQueryDataset(aSQL);
        ds.Open;
        ds.First;
        if not ds.Eof then
          result := ds.fields[0].AsVariant;
      finally
        ds.free;
      end;
    finally
      Unlock;
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70572, e.HelpContext, -1, -1, e.Message + '; sql="' + aSQL +'"');
      result := null;
    end
  end;
end;
*)
function TVpNetDARDM.GetOneCell(aSQL : String) : variant;
var
  ds : TDataSet;
begin
  // Для Interbase (Firebird)
  try
    result := Null;
    Lock;
    try
      ds := GetQueryDataset(aSQL);
      try
        ds.Open;
        ds.First;
        if ds.Eof then begin
          PostLogRecordAddMsgNow(70573, -1, -1, -1, 'sql="' + aSQL +'"');
          result := null;
          exit;
        end;
        result := ds.fields[0].AsVariant;
      finally
        ds.free;
      end;
    finally
      Unlock;
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70572, e.HelpContext, -1, -1, e.Message + '; sql="' + aSQL +'"');
      result := null;
    end
  end;
end;
(*
function TVpNetDARDM.GetRaw(aSQL : String) : variant;
var
  ds : TDataSet;
  i : Integer;
begin
  // Для Interbase (Firebird)
  try
    result:=null;
    Lock;
    try
      ds := GetQueryDataset(aSQL);
      try
        ds.Open;
        ds.First;
        if not ds.Eof then begin
          result := VarArrayCreate([0, ds.FieldCount-1],varVariant);
          for i := 0 to ds.FieldCount-1 do
            result[i] := ds.Fields[i].AsVariant;
        end;
      finally
        ds.free;
      end;
    finally
      Unlock;
    end;
  except
    result := Null;
  end;
end;
*)
function TVpNetDARDM.GetRaw(aSQL : String) : variant;
var
  ds : TDataSet;
  i : Integer;
begin
  // Для Interbase (Firebird)
  try
    result:=null;
    Lock;
    try
      ds := GetQueryDataset(aSQL);
      try
        ds.Open;
        ds.First;
        if ds.Eof then begin
          PostLogRecordAddMsgNow(70575, -1, -1, -1, 'sql="' + aSQL +'"');
          result := null;
          exit;
        end;
        result := VarArrayCreate([0, ds.FieldCount-1],varVariant);
        for i := 0 to ds.FieldCount-1 do
          result[i] := ds.Fields[i].AsVariant;
      finally
        ds.free;
      end;
    finally
      Unlock;
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70574, e.HelpContext, -1, -1, e.Message + '; sql="' + aSQL +'"');
      result := null;
    end;
  end;
end;

///4.04.2010

{
function TVpNetDARDM.GetFirstFreeNodeId(dwNodeType : DWORD; out dwNodeId : DWORD): HRESULT;
var
  vData : OleVariant;
  vNewId : OleVariant;
  s : String;
begin
  try
    // запрашивем данные, необходимые для вычисления свободного id для данного
    // типа сущности
    vData := GetOneCell(
      'select ' +
      '  vnt_table_name, ' +
      '  vnt_table_field_prefix, ' +
      '  vnir_min_id, ' +
      '  vnir_max_id ' +
      'from ' +
      '  vn_node_types vnt, ' +
      '  vn_node_id_ranges vnir ' +
      'where ' +
      '  vnir.vnt_id = vnt.vnt_id ' +
      '  and vnt.vnt_id = ' + IntToStr(dwNodeType)
    );

    // Проверяем, полчили ли мы даннчые
    if
      not(
        VarIsArray(vData)
        and (not VarIsNull(vData[0]))
        and (not VarIsNull(vData[1]))
        and (not VarIsNull(vData[2]))
        and (not VarIsNull(vData[3]))
      )
    then begin
      //данные не получены возвращаем ошибку
      dwNodeId := 0;
      result := E_NOTIMPL;
      exit;
    end;

    // если получили данные, формируем запрос к таблице данных для получения
    // нового id сущности
    s :=
      'select min(t1.'+vData[1]+'_id) + 1 from '+vData[0]+' t1 ' +
      'where ' +
      '  ( ' +
      '     select t2.'+vData[1]+'_id from '+vData[0]+' t2 ' +
      '     where t2.'+vData[1]+'_id = (t1.'+vData[1]+'_id + 1) ' +
      '  ) is null ' +
      '  and t1.'+vData[1]+'_id >= '+vData[2]+' ' +
      '  and t1.'+vData[1]+'_id < '+vData[3];

    // полученаем новый id сущности
    vNewId := GetOneCell(s);
    // Проверяем, получили ли мы новый id
    if VarIsOrdinal(vNewId) then begin
      // если получили, возвращаем его
      dwNodeId := vNewId;
      result := S_OK;
    end else begin
      // если не получили, берем минимальное значение + 1
      dwNodeId := vData[2];
      result := S_OK;
    end;
  except
    dwNodeId := 0;
    result := E_FAIL;
  end;
end;
}
{
function TVpNetDARDM.GetNodeParamValue(dwNodeId : DWORD; sParamName : String; out sValue : String): HRESULT;
var
  v : Variant;
  NodePramValueObj : TVpNetNodeParamValue;
begin
  sValue := EmptyStr;

  // Поиск значения параметра сущности в кеше
  NodePramValueObj := NodeParams.Find(dwNodeId, sParamName);
  if assigned(NodePramValueObj) then begin
    // Если нашли, возвращаем его
    sValue := NodePramValueObj.ParamValue;
    result := S_OK;
    exit;
  end;

  try
    v := GetRaw(
      'select vnp.vnp_value, vnvp.vnvp_default_value ' +
      'from vn_node_valid_params vnvp ' +
      'left outer join vn_node_params vnp on ' +
      'vnp.vnvp_id = vnvp.vnvp_id and vnp.node_id = ' + IntToStr(dwNodeId) + ' ' +
      'where vnvp.vnt_id = ( ' +
      '  select vnir.vnt_id from VN_NODE_ID_RANGES vnir ' +
      '  where ' +
      '    (' + IntToStr(dwNodeId) + ' >= vnir.vnir_min_id) and ' +
      '    (' + IntToStr(dwNodeId) + ' <= vnir.vnir_max_id) ' +
      '  ) and ' +
      '  upper(vnvp.vnvp_param_name collate WIN1251) = ' +
      '  upper('''+sParamName+''' collate WIN1251)'
    );
    // Проверяем, полчили ли мы массив
    if VarIsArray(v) then begin

      // если данный параметр допустим для данной сущности, сохраняем ее в кеше
      NodePramValueObj := TVpNetNodeParamValue.Create();
      NodePramValueObj.NodeId := dwNodeId;
      NodePramValueObj.ParamName := sParamName;
      NodePramValueObj.DefaultParamValueAssigned := (not VarIsNull(v[1])) and (not VarIsEmpty(v[1]));
      if NodePramValueObj.DefaultParamValueAssigned then begin
        NodePramValueObj.DefaultParamValue := v[1];
      end else begin
        NodePramValueObj.DefaultParamValue := EmptyStr;
      end;
      NodePramValueObj.ParamValueAssigned := (not VarIsNull(v[0])) and (not VarIsEmpty(v[0]));
      if NodePramValueObj.ParamValueAssigned then begin
        NodePramValueObj.ParamValue := v[0];
      end else begin
        NodePramValueObj.ParamValue := EmptyStr;
      end;


      NodeParams.Add(NodePramValueObj);

      if (not VarIsNull(v[0])) and (not VarIsEmpty(v[0])) then begin
        // и возвращаем ее
        sValue := v[0];
        result := S_OK;
      end else if (not VarIsNull(v[1])) and (not VarIsEmpty(v[1])) then begin
        sValue := v[1];
        result := S_FALSE;
      end else begin
        sValue := EmptyStr;
        result := E_INVALIDARG;
      end;
    end else begin
      sValue := EmptyStr;
      result := E_INVALIDARG;
    end;
  except
    sValue := EmptyStr;
    result := E_FAIL;
  end;
end;
}
{
function TVpNetDARDM.SetNodeParamValue(dwNodeId : DWORD; sParamName : String; sValue : String): HRESULT;
var
  vData : OleVariant;
  dwNewNodeParamId : DWORD;
begin
  // Получаем теперешнее значения параметра, значение данного параметра
  // по умолчанию, и проверяем, есть ли для данного параметра запись
  // в таблице параметров сущностей (vn_node_params) и допустим ли данный
  // параметр для данной сущности вообще
  try
    vData := GetRaw(
      'select ' +
      '  vnvp.vnvp_id, ' +
      '  vnvp.vnvp_default_value, ' +
      '  vnp.vnp_id, ' +
      '  vnp.vnp_value, ' +
      '  vnvp.vnt_id ' +
      'from vn_node_valid_params vnvp ' +
      'left outer join vn_node_params vnp on ' +
      'vnp.vnvp_id = vnvp.vnvp_id and vnp.node_id = ' + IntToStr(dwNodeId) + ' ' +
      'where vnvp.vnt_id = ( ' +
      '  select vnir.vnt_id from VN_NODE_ID_RANGES vnir ' +
      '  where ' +
      '    (' + IntToStr(dwNodeId) + ' >= vnir.vnir_min_id) and ' +
      '    (' + IntToStr(dwNodeId) + ' <= vnir.vnir_max_id) ' +
      '  ) and ' +
      '  upper(vnvp.vnvp_param_name collate WIN1251) = ' +
      '  upper('''+sParamName+''' collate WIN1251)'
    );

    // Проверяем, полчили ли мы массив
    if not VarIsArray(vData) then begin
      // запись не нашли, то-есть данный параметр вообе недопустим для данной сущности
      result := E_UNEXPECTED;
      exit;
    end;

    // запись нашли, то-есть данный параметр допустим для данной сущности
    if (not VarIsNull(vData[2])) and (not VarIsEmpty(vData[2])) then begin
      // есть запись в таблице параметров (vn_node_params), обновляем значение
      result := ExecSQL(
        'update vn_node_params vnp ' +
        'set vnp.vnp_value = '''+ sValue +'''' +
        'where ' +
        '  vnp.node_id = ' + IntToStr(dwNodeId) + ' and ' +
        '  vnp.vnvp_id = ( ' +
        '    select vnvp.vnvp_id from VN_NODE_VALID_PARAMS vnvp ' +
        '      where ' +
        '        vnvp.vnt_id = ( ' +
        '          select vnir.vnt_id from VN_NODE_ID_RANGES vnir ' +
        '          where ' +
        '            (' + IntToStr(dwNodeId) + ' >= vnir.vnir_min_id) and ' +
        '            (' + IntToStr(dwNodeId) + ' <= vnir.vnir_max_id) ' +
        '        ) and ' +
        '        upper(vnvp.vnvp_param_name collate WIN1251) = ' +
        '        upper(''' + sParamName + ''' collate WIN1251) ' +
        '  )'
      );
      if result >= S_OK then
        ExecSQL('commit')
      else
        ExecSQL('rollback');
    end else if (not VarIsNull(vData[0])) and (not VarIsEmpty(vData[0])) then begin
      // есть запись только в таблице допустимых параметров (vn_node_valid_params),
      // добавляем значение в таблицу значений параметров
      // Для этого получаем новый id сущности
      if not VarIsOrdinal(vData[4]) or not(VarIsOrdinal(vData[0])) then begin
        // Если нет типа параметра, выходим с ошибкой
        result := E_INVALIDARG;
        exit;
      end;
      if not (GetFirstFreeNodeId(VNT_NODE_PARAM, dwNewNodeParamId) = S_OK) then begin
        // Если не удалось получить новый id параметра сущности,
        // выходим с ошибкой
        result := E_UNEXPECTED;
        exit;
      end;
      result := ExecSQL(
        'insert into vn_node_params values ('+IntToStr(dwNewNodeParamId)+', '+IntToStr(dwNodeId)+', '+vData[0]+', '''+sValue+''')'
      );
      if result >= S_OK then
        ExecSQL('commit')
      else
        ExecSQL('rollback');
    end else begin
      // непредвиденная ситуация, возвращаем ошибку
        result := E_UNEXPECTED;
    end;
  except
    result := E_FAIL;
  end;
end;
}


function TVpNetDARDM.StrToSQL(aValue : String; Default : String) : String;
begin
  try
    result:=Default;
    if length(aValue)=0 then begin
      PostLogRecordAddMsgNow(70577, -1, -1, -1, '');
      result := Default;
      exit;
    end;
    result:=''''+StringReplace(aValue,'''','''''',[rfReplaceAll, rfIgnoreCase])+'''';
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70576, e.HelpContext, -1, -1, e.Message + '; aValue=' + aValue +'; Default='+ Default);
      result := Default;
    end;
  end;
end;

function TVpNetDARDM.IntToSQL(aValue : Integer; Default : String) : String;
begin
  try
    result:=Default;
    if aValue = -1 then begin
      PostLogRecordAddMsgNow(70579, aValue, -1, -1, 'Default='+ Default);
      exit;
    end;
    result:=IntToStr(aValue);
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70578, e.HelpContext, aValue, -1, e.Message + '; Default='+ Default);
      result := Default;
    end;
  end;
end;

function TVpNetDARDM.FloatToSQL(aValue : Extended; Default : String;
  aMinAbsValue : Extended = 1.135E-38; aMaxAbsValue : Extended = 3.402E38) : String;
var
  OldDS : char;
  qValue : Extended;
begin
  try
    result:=Default;
    qValue := aValue;
    if qValue = -1 then begin
      PostLogRecordAddMsgNow(70581, -1, -1, -1, '');
      exit;
    end;

    // Ограничение минимального модуля
    if abs(qValue) < aMinAbsValue then begin
      PostLogRecordAddMsgNow(70582, -1, -1, -1, '');
      if qValue > 0 then
        qValue := aMinAbsValue
      else if qValue < 0 then
        qValue := - aMinAbsValue
      else
        qValue := 0;
    end;

    // Ограничение максимального модуля
    if abs(qValue) > aMaxAbsValue then begin
      PostLogRecordAddMsgNow(70583, -1, -1, -1, '');
      if qValue > 0 then
        qValue := aMaxAbsValue
      else
        qValue := - aMaxAbsValue;
    end;

    OldDS:=DecimalSeparator;
    DecimalSeparator:='.';
    result:=FloatToStr(qValue);
    DecimalSeparator:=OldDS;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70580, e.HelpContext, -1, -1, e.Message +
      '; aValue=' + FloatToStr(aValue) + '; Default='+ Default +
      '; aMinAbsValue=' + FloatToStr(aMinAbsValue) + '; aMaxAbsValue=' + FloatToStr(aMaxAbsValue));
      result := Default;
    end;
  end;
end;

function TVpNetDARDM.DateToIB(ADate: TDate; Default : String): String;
const
  Separ = '-';
  Month: array[1..12] of String[3] = ('JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC');
var
  D,M,Y: Word;
begin
  try
    result:=Default;
    if ADate = 0 then begin
      PostLogRecordAddMsgNow(70585, -1, -1, -1, '');
      exit;
    end;
    DecodeDate(ADate,Y,M,D);
    result:=IntToStr(D)+Separ+Month[M]+Separ+IntToStr(Y);
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70584, e.HelpContext, -1, -1, e.Message);
      result := Default;
    end;
  end;
end;

function TVpNetDARDM.DateTimeToSQL(aDateTime : TDateTime; Default : String = 'NULL'): String;
const
  Separ = '-';
  TimeSepar = ':';
  MonthArr: array[1..12] of String[3] = ('JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC');
var
  Year, Month, Day, Hour, Minute, Second, Millisecond : Word;
begin
  try
    result:=Default;
    if aDateTime = 0 then begin
      PostLogRecordAddMsgNow(70587, -1, -1, -1, 'Default='+Default);
      exit;
    end;
    DecodeDateTime(aDateTime, Year, Month, Day, Hour, Minute, Second, Millisecond);
    result := Format('%2.2d%1s%3s%1s%4.4d %2.2d%1s%2.2d%1s%2.2d', [Day, Separ, MonthArr[Month], Separ, Year, Hour, TimeSepar, Minute, TimeSepar, Second]);
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70586, e.HelpContext, -1, -1, e.Message);
      result := Default;
    end;
  end;
end;

function TVpNetDARDM.IBGetTablePK(aTableName : String): string;
var
  v : variant;
begin
  try
    v:=GetOneCell('select MAX(RDB$CONSTRAINT_NAME) from RDB$RELATION_CONSTRAINTS WHERE (UPPER(RDB$RELATION_NAME) = '''+aTableName+''') AND(RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'')');

    if VarIsEmpty(v) then begin
      result:=EmptyStr;
      PostLogRecordAddMsgNow(70589, -1, -1, -1, 'aTableName='+aTableName);
      exit;
    end;

    if VarIsNull(v) then begin
      result:=EmptyStr;
      PostLogRecordAddMsgNow(70590, -1, -1, -1, 'aTableName='+aTableName);
      exit;
    end;

    result:=v;

  except on e: Exception do begin
      PostLogRecordAddMsgNow(70588, e.HelpContext, -1, -1, e.Message + '; aTableName='+aTableName);
      result := EmptyStr;
    end;
  end;
end;

function TVpNetDARDM.IBTableExists(aTableName : String) : boolean;
var
  v : variant;
begin
  try
    v:=GetOneCell('select count(*) from rdb$relations where UPPER(RDB$RELATION_NAME) = '''+aTableName+'''');

    if VarIsEmpty(v) then begin
      result:=false;
      PostLogRecordAddMsgNow(70592, -1, -1, -1, 'aTableName='+aTableName);
      exit;
    end;

    if VarIsNull(v) then begin
      result:=false;
      PostLogRecordAddMsgNow(70593, -1, -1, -1, 'aTableName='+aTableName);
      exit;
    end;

    result:=(v>0);

  except on e: Exception do begin
      PostLogRecordAddMsgNow(70591, e.HelpContext, -1, -1, e.Message + '; aTableName='+aTableName);
      result := false;
    end;
  end;
end;

function TVpNetDARDM.IBFieldExists(aTableName, aFieldName : String): boolean;
var
  v : Variant;
begin
  try
    v := GetOneCell(
      'select count(*) ' +
      'from rdb$relation_fields ' +
      'where ' +
      'upper(rdb$relation_name) = upper('''+aTableName+''') and ' +
      'upper(rdb$field_name) = upper('''+aFieldName+''')'
    );
    if VarIsEmpty(v) then begin
      result := false;
      PostLogRecordAddMsgNow(70595, -1, -1, -1, 'aTableName='+aTableName+'; aFieldName='+aFieldName);
      exit;
    end;
    if VarIsNull(v) then begin
      result := false;
      PostLogRecordAddMsgNow(70596, -1, -1, -1, 'aTableName='+aTableName+'; aFieldName='+aFieldName);
      exit;
    end;
    result := (v > 0);
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70594, e.HelpContext, -1, -1, e.Message + '; aTableName='+aTableName+'; aFieldName='+aFieldName);
      result := false;
    end;
  end;
end;

function TVpNetDARDM.IBViewExists(aViewName : String) : boolean;
var
  v : variant;
begin
  try
    v:=GetOneCell('select COUNT(*) from RDB$VIEW_RELATIONS WHERE UPPER(RDB$VIEW_NAME) = '''+ANSIUpperCase(aViewName)+'''');

    if VarIsEmpty(v) then begin
      PostLogRecordAddMsgNow(70598, -1, -1, -1, 'aViewName='+aViewName);
      result:=false;
      exit;
    end;

    if VarIsNull(v) then begin
      PostLogRecordAddMsgNow(70599, -1, -1, -1, 'aViewName='+aViewName);
      result:=false;
      exit;
    end;

    result:=(v>0);
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70597, e.HelpContext, -1, -1, e.Message + '; aViewName='+aViewName);
      result := false;
    end;
  end;
end;

function TVpNetDARDM.IBIndexExists(aIndexName : String) : boolean;
var
  v : variant;
begin
  try
    v:=GetOneCell('select count(*) from rdb$indices where upper(RDB$INDEX_NAME) = '''+ANSIUpperCase(aIndexName)+'''');

    if VarIsEmpty(v) then begin
      PostLogRecordAddMsgNow(70601, -1, -1, -1, 'aIndexName='+aIndexName);
      result:=false;
      exit;
    end;

    if VarIsNull(v) then begin
      PostLogRecordAddMsgNow(70602, -1, -1, -1, 'aIndexName='+aIndexName);
      result:=false;
      exit;
    end;

    result:=(v>0);

  except on e: Exception do begin
      PostLogRecordAddMsgNow(70600, e.HelpContext, -1, -1, e.Message + '; aIndexName='+aIndexName);
      result := false;
    end;
  end;
end;

function TVpNetDARDM.IBProcedureExists(aProcName : String) : Boolean;
var
  v : variant;
begin
  try
    v:=GetOneCell('select count(*) from rdb$procedures where upper(RDB$PROCEDURE_NAME) = '''+ANSIUpperCase(aProcName)+'''');

    if VarIsEmpty(v) then begin
      PostLogRecordAddMsgNow(70604, -1, -1, -1, 'aProcName='+aProcName);
      result:=false;
      exit;
    end;

    if VarIsNull(v) then begin
      PostLogRecordAddMsgNow(70605, -1, -1, -1, 'aProcName='+aProcName);
      result:=false;
      exit;
    end;

    result:=(v>0);

  except on e: Exception do begin
      PostLogRecordAddMsgNow(70603, e.HelpContext, -1, -1, e.Message + '; aProcName='+aProcName);
      result := false;
    end;
  end;
end;

function TVpNetDARDM.IBTriggerExists(aTriggerName : String) : Boolean;
var
  v : variant;
begin
  try
    v:=GetOneCell('select count(*) from rdb$triggers where upper(RDB$TRIGGER_NAME) = '''+ANSIUpperCase(aTriggerName)+'''');

    if VarIsEmpty(v) then begin
      PostLogRecordAddMsgNow(70607, -1, -1, -1, 'aTriggerName='+aTriggerName);
      result:=false;
      exit;
    end;

    if VarIsNull(v) then begin
      PostLogRecordAddMsgNow(70608, -1, -1, -1, 'aTriggerName='+aTriggerName);
      result:=false;
      exit;
    end;

    result:=(v>0);

  except on e: Exception do begin
      PostLogRecordAddMsgNow(70606, e.HelpContext, -1, -1, e.Message + '; aTriggerName='+aTriggerName);
      result := false;
    end;
  end;
end;

function TVpNetDARDM.IBConstraintExists(aConstrName : String) : boolean;
var
  v : variant;
begin
  try
    v:=GetOneCell('select count(*) from rdb$relation_constraints where upper(RDB$CONSTRAINT_NAME) = '''+ANSIUpperCase(aConstrName)+'''');

    if VarIsEmpty(v) then begin
      PostLogRecordAddMsgNow(70610, -1, -1, -1, 'aConstrName='+aConstrName);
      result:=false;
      exit;
    end;

    if VarIsNull(v) then begin
      PostLogRecordAddMsgNow(70611, -1, -1, -1, 'aConstrName='+aConstrName);
      result:=false;
      exit;
    end;

    result:=(v>0);
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70609, e.HelpContext, -1, -1, e.Message + '; aConstrName='+aConstrName);
      result := false;
    end;
  end;
end;

function TVpNetDARDM.IBGeneratorExists(aGeneratorName : String) : boolean;
var
  v : Variant;
begin
  try
    v:=GetOneCell('select count(*) from rdb$generators where upper(RDB$GENERATOR_NAME) = '''+ANSIUpperCase(aGeneratorName)+'''');

    if VarIsEmpty(v) then begin
      PostLogRecordAddMsgNow(70613, -1, -1, -1, 'aGeneratorName='+aGeneratorName);
      result:=false;
      exit;
    end;

    if VarIsNull(v) then begin
      PostLogRecordAddMsgNow(70614, -1, -1, -1, 'aGeneratorName='+aGeneratorName);
      result:=false;
      exit;
    end;

    result:=(v>0);

  except on e: Exception do begin
      PostLogRecordAddMsgNow(70612, e.HelpContext, -1, -1, e.Message + '; aGeneratorName='+aGeneratorName);
      result := false;
    end;
  end;
end;

function TVpNetDARDM.IBDomainExists(aDomainName : String) : boolean;
var
  v : Variant;
begin
  try

    v:=GetOneCell('select count(*) from RDB$FIELDS where UPPER(RDB$FIELD_NAME) = '''+ANSIUpperCase(aDomainName)+'''');

    if VarIsEmpty(v) then begin
      PostLogRecordAddMsgNow(70616, -1, -1, -1, 'aDomainName='+aDomainName);
      result:=false;
      exit;
    end;

    if VarIsNull(v) then begin
      PostLogRecordAddMsgNow(70617, -1, -1, -1, 'aDomainName='+aDomainName);
      result:=false;
      exit;
    end;

    result:=(v>0);

  except on e: Exception do begin
      PostLogRecordAddMsgNow(70615, e.HelpContext, -1, -1, e.Message + '; aDomainName='+aDomainName);
      result := false;
    end;
  end;
end;


function TVpNetDARDM.IBObjectExists(aObjectName : String) : Boolean;
begin
  try
    result:= (
               IBTableExists(aObjectName) or
               IBIndexExists(aObjectName) or
               IBConstraintExists(aObjectName) or
               IBProcedureExists(aObjectName) or
               IBTriggerExists(aObjectName) or
               IBDomainExists(aObjectName)
              );
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70618, e.HelpContext, -1, -1, e.Message + '; aObjectName='+aObjectName);
      result := false;
    end;
  end;
end;

{01.07.2007}
//  NodeParams

// 28.03.2010
function TVpNetNodeParamValue.GetParamValueAssigned : boolean;
begin
  try
    result := not(VarIsNull(ParamValue));
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70619, e.HelpContext, -1, -1, e.Message);
      result := false;
    end;
  end;
end;
function TVpNetNodeParamValue.GetDefaultParamValueAssigned : boolean;
begin
  try
    result := not(VarIsNull(DefaultParamValue));
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70620, e.HelpContext, -1, -1, e.Message);
      result := false;
    end;
  end;
end;
///28.03.2010


constructor TVpNetNodeParamValue.Create;
begin
  try
    inherited;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70621, e.HelpContext, -1, -1, e.Message);
      exit;
    end;
  end;

  try
    NodeId := 0;
    ParamName := EmptyStr;
    NodeTypeId := 0;
  // 28.03.2010
  //  DefaultParamValueAssigned := false;
  //  DefaultParamValue := EmptyStr;
    DefaultParamValue := null;
  //  ParamValueAssigned := false;
  //  ParamValue := EmptyStr;
    ParamValue := null;
  ///28.03.2010
    OriginParamValue := EmptyStr;
    ForSendToHst := false;
  except on e: Exception do
    PostLogRecordAddMsgNow(70622, e.HelpContext, -1, -1, e.Message);
  end;
end;

{
constructor TVpNetNodeParamValue.Create(aNodeId : DWORD; aParamName : String; aParamValue : String);
begin
  inherited create;
  NodeId := aNodeId;
  ParamName := aParamName;
  ParamValue := aParamValue;
end;
}

function TVpNetNodeParamValueList.Get(Index: Integer): TVpNetNodeParamValue;
begin
  try
    Result := TVpNetNodeParamValue(inherited Get(Index));
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70623, e.HelpContext, Index, -1, e.Message);
      result := nil;
    end;
  end;
end;

procedure TVpNetNodeParamValueList.Put(Index: Integer; const Value: TVpNetNodeParamValue);
begin
  try
    inherited Put(Index, Value);
  except on e: Exception do
    PostLogRecordAddMsgNow(70624, e.HelpContext, Index, Integer(Value), e.Message);
  end;
end;

constructor TVpNetNodeParamValueList.Create(aRDM : TVpNetDARDM);
begin
  try
    inherited create;
    FRDM := aRDM;
  except on e: Exception do
    PostLogRecordAddMsgNow(70625, e.HelpContext, Integer(aRDM), -1, e.Message);
  end;
end;

destructor TVpNetNodeParamValueList.destroy;
begin
  try
    DestroyItems;
  except on e: Exception do
    PostLogRecordAddMsgNow(70627, e.HelpContext, -1, -1, e.Message);
  end;

  try
    inherited;
  except on e: Exception do
    PostLogRecordAddMsgNow(70626, e.HelpContext, -1, -1, e.Message);
  end;
end;

procedure TVpNetNodeParamValueList.DestroyItems;
var
  ItemIndex : Integer;
begin
  try
    ItemIndex := 0;
    while ItemIndex < Count do begin
      try
        Items[ItemIndex].Free;
      except on e: Exception do
        PostLogRecordAddMsgNow(70629, e.HelpContext, ItemIndex, -1, e.Message);
      end;
      Items[ItemIndex] := nil;
      ItemIndex := Succ(ItemIndex);
    end;
    Clear;
  except on e: Exception do
    PostLogRecordAddMsgNow(70628, e.HelpContext, -1, -1, e.Message);
  end;
end;

// 28.03.2010
//function TVpNetNodeParamValueList.Find(aNodeId : DWORD; aParamName : String) : TVpNetNodeParamValue;
function TVpNetNodeParamValueList.Find(aNodeId : DWORD; aNodeParam : OleVariant) : TVpNetNodeParamValue;
///28.03.2010
var
  ItemIndex : Integer;
  aParamName : String;
  hr : HRESULT;
begin
  try
    result := nil;

// 28.03.2010
    hr := FRDM.GetNodeParamName(aNodeId, aNodeParam, aParamName);
    if hr < S_OK then begin
      PostLogRecordAddMsgNow(70631, aNodeId, hr, -1, '');
      exit;
    end;
///28.03.2010

    ItemIndex := 0;
    while ItemIndex < Count do begin
      try
        if (Items[ItemIndex].NodeId = aNodeId)
          and (ANSIUpperCase(Items[ItemIndex].ParamName) = ANSIUpperCase(aParamName)) then begin
          result := Items[ItemIndex];
          break;
        end;
      except on e: Exception do
        PostLogRecordAddMsgNow(70632, aNodeId, ItemIndex, -1, '');
      end;
      ItemIndex := Succ(ItemIndex);
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70630, e.HelpContext, aNodeId, -1, e.Message);
      result := nil;
    end;
  end;
end;

function TVpNetNodeParamValueList.NodeInList(aNodeId : DWORD) : boolean;
var
  ItemIndex : Integer;
begin
  result := false;
  try
    ItemIndex := 0;
    while ItemIndex < Count do begin
      try
        if (Items[ItemIndex].NodeId = aNodeId) then begin
          result := true;
          break;
        end;
      except on e: Exception do
        PostLogRecordAddMsgNow(70634, e.HelpContext, aNodeId, ItemIndex, e.Message);
      end;
      ItemIndex := Succ(ItemIndex);
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70633, e.HelpContext, aNodeId, -1, e.Message);
      result := false;
    end;
  end;
end;

function TVpNetNodeParamValueList.ReadNodeIdParams(dwNodeId : DWORD): HRESULT;
var
  NodePramValueObj : TVpNetNodeParamValue;
  ds : TDataset;
  dwNodeType : DWORD;
  hr : HRESULT;
begin
  try
    result := E_UNEXPECTED;
    FRDM.Lock;
    try
      hr := FRDM.GetNodeType(dwNodeId, dwNodeType);
      if hr < S_OK then begin
        PostLogRecordAddMsgNow(70636, dwNodeId, hr, -1, '');
        exit;
      end;

      if dwNodeType = VNT_HOST_SERVER_DRIVER then begin
        ds := FRDM.GetQueryDataset(
          'select hdtp.HDTP_SHORT_NAME PARAM_NAME, 119 VNT_ID, hdtp_default_value DEFAULT_VALUE, HCDP_VALUE PARAM_VALUE, 1 FOR_SEND_TO_HST ' +
          'from hst_driver_type_params hdtp ' +
          'left outer join hstcommdriverparams hcdp on hcdp.hdtp_id = hdtp.hdtp_id ' +
          'where ' +
          '  hdtp.vhsdt_id = (select vhsdt_id from vn_host_server_drivers vhsd ' +
          '    where vhsd.vhsd_id = ' + IntToStr(dwNodeId) + ')'
        );
      end else begin
        ds := FRDM.GetQueryDataset(
          'select vnvp.vnvp_param_name PARAM_NAME, vnvp.vnt_id VNT_ID, vnvp.vnvp_default_value DEFAULT_VALUE, vnp.vnp_value PARAM_VALUE, vnvp.vnvp_for_send_to_hst FOR_SEND_TO_HST ' +
          'from vn_node_valid_params vnvp ' +
          'left outer join vn_node_params vnp on ' +
          'vnp.vnvp_id = vnvp.vnvp_id and vnp.node_id = ' + IntToStr(dwNodeId) + ' ' +
          'where vnvp.vnt_id = ( ' +
          '  select vnir.vnt_id from VN_NODE_ID_RANGES vnir ' +
          '  where ' +
          '    (' + IntToStr(dwNodeId) + ' >= vnir.vnir_min_id) and ' +
          '    (' + IntToStr(dwNodeId) + ' <= vnir.vnir_max_id) ' +
          '  )'
        );
      end;

      if not assigned(ds) then begin
        PostLogRecordAddMsgNow(70637, dwNodeId, -1, -1, '');
        result := E_FAIL;
        exit;
      end;

      try
        ds.Open;
      except on e : Exception do
        PostLogRecordAddMsgNow(70639, dwNodeId, -1, -1, '');
      end;

      try
        ds.First;
      except on e : Exception do
        PostLogRecordAddMsgNow(70640, dwNodeId, -1, -1, '');
      end;

      // Если у сущности не может быть ни одного параметра, возвращаем S_FALSE;
      if ds.Eof then begin
        result := S_FALSE;
        exit;
      end;

      while not ds.Eof do begin
        try
          NodePramValueObj := TVpNetNodeParamValue.Create;
          NodePramValueObj.NodeId := dwNodeId;
          NodePramValueObj.ParamName := ds.FieldByName('PARAM_NAME').AsString;
          NodePramValueObj.NodeTypeId := ds.FieldByName('VNT_ID').AsInteger;
  // 28.03.2010
  //        NodePramValueObj.DefaultParamValueAssigned := not ds.FieldByName('DEFAULT_VALUE').IsNull;
  //        NodePramValueObj.DefaultParamValue := ds.FieldByName('DEFAULT_VALUE').AsString;
          NodePramValueObj.DefaultParamValue := ds.FieldByName('DEFAULT_VALUE').AsVariant;
  //        NodePramValueObj.ParamValueAssigned := not ds.FieldByName('PARAM_VALUE').IsNull;
  //        NodePramValueObj.ParamValue := ds.FieldByName('PARAM_VALUE').AsString;
          NodePramValueObj.ParamValue := ds.FieldByName('PARAM_VALUE').AsVariant;
  ///28.03.2010
          NodePramValueObj.ForSendToHst := (ds.FieldByName('FOR_SEND_TO_HST').AsInteger > 0);
          Add(NodePramValueObj);
        except on e : Exception do
          PostLogRecordAddMsgNow(70641, dwNodeId, -1, -1, '');
        end;
        ds.Next;
      end;
    finally
      try
        ds.close;
        ds.Free;
      except on e: Exception do
        PostLogRecordAddMsgNow(70638, e.HelpContext, dwNodeId, -1, e.Message);
      end;
      FRDM.Unlock;
    end;
    result := S_OK;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70635, e.HelpContext, dwNodeId, -1, e.Message);
      result := E_FAIL;
    end;
  end;
end;

// 28.03.2010
//function TVpNetNodeParamValueList.GetNodeParamValue(dwNodeId : DWORD; sParamName : String; out sValue : String): HRESULT;
function TVpNetNodeParamValueList.GetNodeParamValue(dwNodeId : DWORD; aNodeParam : OleVariant; out aNodeValue : OleVariant): HRESULT;
///28.03.2010
var
  NodePramValueObj : TVpNetNodeParamValue;
  ds : TDataset;
  hr : HRESULT;
begin
  try
  // 28.03.2010
  //  sValue := EmptyStr;
    result := E_UNEXPECTED;
    aNodeValue := null;
  ///28.03.2010

    // Если параметры сушности еще не кешировались, кешируем их ..
    if not NodeInList(dwNodeId) then begin
      hr := ReadNodeIdParams(dwNodeId);
      if hr < S_OK then begin
        PostLogRecordAddMsgNow(70646, dwNodeId, hr, -1, '');
      end;
    end;

    // Если параметры сущности уже находятся в кеше ...
    if NodeInList(dwNodeId) then begin
      // ...ищем значение параметра сущности в кеше
  // 28.03.2010
  //    NodePramValueObj := Find(dwNodeId, sParamName);
      NodePramValueObj := Find(dwNodeId, aNodeParam);
  ///28.03.2010
      if assigned(NodePramValueObj) then begin
        // Если нашли, возвращаем его
        if NodePramValueObj.ParamValueAssigned then begin
  // 28.03.2010
  //        sValue := NodePramValueObj.ParamValue;
          aNodeValue := NodePramValueObj.ParamValue;
  ///28.03.2010
          result := S_OK;
        end else if NodePramValueObj.DefaultParamValueAssigned then begin
  // 28.03.2010
  //        sValue := NodePramValueObj.DefaultParamValue;
          aNodeValue := NodePramValueObj.DefaultParamValue;
  ///28.03.2010
          result := S_FALSE;
        end else begin
  // 28.03.2010
  //        sValue := '';
          aNodeValue := null;
  ///28.03.2010
          PostLogRecordAddMsgNow(70643, dwNodeId, -1, -1, '');

          result := E_UNEXPECTED;
        end;
      end else begin
        // Нет параметра сущности с таким именем в кеше, а значит и вообще нет
  // 28.03.2010
  //      sValue := EmptyStr;
        aNodeValue := null;
  ///28.03.2010
        PostLogRecordAddMsgNow(70644, dwNodeId, -1, -1, '');
        result := E_INVALIDARG;
     end;
     exit;
    end else begin
      // у сущности неможет быть параметров вообще!
  // 28.03.2010
  //    sValue := EmptyStr;
      aNodeValue := null;
  ///28.03.2010
      PostLogRecordAddMsgNow(70645, dwNodeId, -1, -1, '');
      result := E_INVALIDARG;
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70642, e.HelpContext, dwNodeId, -1, e.Message);
      result := E_FAIL;
    end;
  end;
end;

function TVpNetNodeParamValueList.GetFirstFreeNodeId(dwNodeType : DWORD; out dwNodeId : DWORD): HRESULT;
var
  vData : OleVariant;
  vNewId : OleVariant;
  s : String;
begin
  try
    // запрашивем данные, необходимые для вычисления свободного id для данного
    // типа сущности
    vData := FRDM.GetOneCell(
      'select ' +
      '  vnt_table_name, ' +
      '  vnt_table_field_prefix, ' +
      '  vnir_min_id, ' +
      '  vnir_max_id ' +
      'from ' +
      '  vn_node_types vnt, ' +
      '  vn_node_id_ranges vnir ' +
      'where ' +
      '  vnir.vnt_id = vnt.vnt_id ' +
      '  and vnt.vnt_id = ' + IntToStr(dwNodeType)
    );

    // Проверяем, полчили ли мы данные
    if
      not(
        VarIsArray(vData)
        and (not VarIsNull(vData[0]))
        and (not VarIsNull(vData[1]))
        and (not VarIsNull(vData[2]))
        and (not VarIsNull(vData[3]))
      )
    then begin
      //данные не получены возвращаем ошибку
      PostLogRecordAddMsgNow(70648, dwNodeType, -1, -1, '');
      dwNodeId := 0;
      result := E_NOTIMPL;
      exit;
    end;

    // если получили данные, формируем запрос к таблице данных для получения
    // нового id сущности
    s :=
      'select min(t1.'+vData[1]+'_id) + 1 from '+vData[0]+' t1 ' +
      'where ' +
      '  ( ' +
      '     select t2.'+vData[1]+'_id from '+vData[0]+' t2 ' +
      '     where t2.'+vData[1]+'_id = (t1.'+vData[1]+'_id + 1) ' +
      '  ) is null ' +
      '  and t1.'+vData[1]+'_id >= '+vData[2]+' ' +
      '  and t1.'+vData[1]+'_id < '+vData[3];

    // полученаем новый id сущности
    vNewId := FRDM.GetOneCell(s);
    // Проверяем, получили ли мы новый id
    if VarIsOrdinal(vNewId) then begin
      // если получили, возвращаем его
      dwNodeId := vNewId;
      result := S_OK;
    end else begin
      // если не получили, берем минимальное значение + 1
      dwNodeId := vData[2];
      result := S_OK;
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70647, e.HelpContext, dwNodeType, -1, e.Message);
      dwNodeId := 0;
      result := E_FAIL;
    end;
  end;
end;

// 28.03.2010
//function TVpNetNodeParamValueList.SetNodeParamValue(dwNodeId : DWORD; sParamName : String; sValue : String): HRESULT;
(*
function TVpNetNodeParamValueList.SetNodeParamValue(dwNodeId : DWORD; aNodeParam : OleVariant; aNodeValue : OleVariant; aSaveToDB : boolean = true): HRESULT;
///28.03.2010
var
  NodePramValueObj : TVpNetNodeParamValue;
  hr : HRESULT;
  vData : OleVariant;
  dwNewNodeParamId : DWORD;
  vVNVP_ID : OleVariant;
  VNVP_ID : Integer;
begin
  try

    // Если параметры сушности еще не кешировались, кешируем их ..
    if not NodeInList(dwNodeId) then begin
      hr := ReadNodeIdParams(dwNodeId);

      // Если не удалось прочитать непустой список допустимых параметров
      // данной сущности, выходим с ошибкой
      if not (hr = S_OK) then begin
        result := E_INVALIDARG;
        exit;
      end;
    end;

    // Если параметров сущности нет в кеше, выходим с ошибкой
    if not NodeInList(dwNodeId) then begin
      result := E_INVALIDARG;
      exit;
    end;

    // Ищем в кеше информацию по данному параметру
// 28.03.2010
//    NodePramValueObj := Find(dwNodeId, sParamName);
    NodePramValueObj := Find(dwNodeId, aNodeParam);
///28.03.2010


    // Если данных по данному парметру нет, значит он недопустим дял данной
    // сущности. Выходим с ошибкой
    if not assigned(NodePramValueObj) then begin
      result := E_INVALIDARG;
      exit;
    end;

// 28.03.2010
//    if NodePramValueObj.ParamValueAssigned then begin
//      // если параметр уже есть в кеше, обновляем его в кеше ...
//      NodePramValueObj.ParamValue := sValue;
//      NodePramValueObj.ParamValueAssigned := true;
      NodePramValueObj.ParamValue := aNodeValue;
//      result := true;
      // ... и, ели нужно, в базе данных
      if aSaveToDB then begin
//        if Assigne(aNodeValue) then begin
        if frdm.IsNodeParamValueInBase(dwNodeId, aNodeParam) then begin
///28.03.2010

          result := FRDM.ExecSQL(
            'update vn_node_params vnp ' +
            'set vnp.vnp_value = '''+ sValue +'''' +
            'where ' +
            '  vnp.node_id = ' + IntToStr(dwNodeId) + ' and ' +
            '  vnp.vnvp_id = ( ' +
            '    select vnvp.vnvp_id from VN_NODE_VALID_PARAMS vnvp ' +
            '      where ' +
            '        vnvp.vnt_id = ( ' +
            '          select vnir.vnt_id from VN_NODE_ID_RANGES vnir ' +
            '          where ' +
            '            (' + IntToStr(dwNodeId) + ' >= vnir.vnir_min_id) and ' +
            '            (' + IntToStr(dwNodeId) + ' <= vnir.vnir_max_id) ' +
            '        ) and ' +
            '        upper(vnvp.vnvp_param_name collate WIN1251) = ' +
            '        upper(''' + sParamName + ''' collate WIN1251) ' +
            '  )'
          );
        end else begin

        end;
  {
        if result >= S_OK then
          FRDM.ExecSQL('commit')
        else
          FRDM.ExecSQL('rollback');
  }
      end;
    end else begin
      // если параметр до этого не был поределен в кеше, обновляем записываем его в кеш ...
      NodePramValueObj.ParamValue := sValue;
      NodePramValueObj.ParamValueAssigned := true;

// 26.03.2010
//      result := true;
      if aSaveToDB then begin
///26.03.2010
        vVNVP_ID := FRDM.GetOneCell(
          '    select vnvp.vnvp_id from VN_NODE_VALID_PARAMS vnvp ' +
          '      where ' +
          '        vnvp.vnt_id = ( ' +
          '          select vnir.vnt_id from VN_NODE_ID_RANGES vnir ' +
          '          where ' +
          '            (' + IntToStr(dwNodeId) + ' >= vnir.vnir_min_id) and ' +
          '            (' + IntToStr(dwNodeId) + ' <= vnir.vnir_max_id) ' +
          '        ) and ' +
          '        upper(vnvp.vnvp_param_name collate WIN1251) = ' +
          '        upper(''' + sParamName + ''' collate WIN1251) '
        );
        VNVP_ID := vVNVP_ID;

        // и в базе данных
        {10.09.2008}
  //      result := FRDM.ExecSQL(
  //        'insert into vn_node_params values ('+IntToStr(dwNewNodeParamId)+', '+IntToStr(dwNodeId)+', '+IntToStr(VNVP_ID)+', '''+sValue+''')'
  //      );
        result := FRDM.ExecSQL(
          'update vn_node_params set vnp_value = ' + ''''+sValue+'''' + ' where node_id = '+IntToStr(dwNodeId)+' and vnvp_id = '+IntToStr(VNVP_ID)
        );
        {/10.09.2008}
  {
        if result >= S_OK then
          FRDM.ExecSQL('commit')
        else
          FRDM.ExecSQL('rollback');
  }
      end;
    end;
  except
    result := E_FAIL;
  end;
end;
*)
function TVpNetNodeParamValueList.SetNodeParamValue(dwNodeId : DWORD; aNodeParam : OleVariant; aNodeValue : OleVariant; aSaveToDB : boolean = true): HRESULT;
var
  NodePramValueObj : TVpNetNodeParamValue;
  hr : HRESULT;
  sNodeParamName : String;
  sNodeParamValue : String;
begin
  try
    // Если параметры сушности еще не кешировались, кешируем их ..
    if not NodeInList(dwNodeId) then begin
      hr := ReadNodeIdParams(dwNodeId);
      // Если не удалось прочитать непустой список допустимых параметров
      // данной сущности, выходим с ошибкой
      if not (hr = S_OK) then begin
        PostLogRecordAddMsgNow(70650, dwNodeId, hr, -1, '');
        result := E_INVALIDARG;
        exit;
      end;
    end;

    // Если параметров сущности нет в кеше, выходим с ошибкой
    if not NodeInList(dwNodeId) then begin
      PostLogRecordAddMsgNow(70651, dwNodeId, -1, -1, '');
      result := E_INVALIDARG;
      exit;
    end;

    // Ищем в кеше информацию по данному параметру
    NodePramValueObj := Find(dwNodeId, aNodeParam);

    // Если данных по данному парметру нет, значит он недопустим дял данной
    // сущности. Выходим с ошибкой
    if not assigned(NodePramValueObj) then begin
      PostLogRecordAddMsgNow(70652, dwNodeId, -1, -1, '');
      result := E_INVALIDARG;
      exit;
    end;
    NodePramValueObj.ParamValue := aNodeValue;

    // если нужно писать параметр в базу - пишем его в базу
    if aSaveToDB then begin
      result := FRDM.SetNodeParamBySQL(dwNodeId, aNodeParam, aNodeValue);
      if result < S_OK then begin
        PostLogRecordAddMsgNow(70653, dwNodeId, result, -1, '');
      end;
    end else begin
      result := S_OK;
    end;

  except on e: Exception do begin
      PostLogRecordAddMsgNow(70649, e.HelpContext, dwNodeId, -1, e.Message);
      result := E_FAIL;
    end;
  end;
end;

///28.03.2010
function TVpNetNodeParamValueList.GetNodeParamNames(dwNodeId : DWORD; aList : TStringList): HRESULT;
var
  ItemIndex : Integer;
  hr : HRESULT;
begin
  try
    if not assigned(aList) then begin
      PostLogRecordAddMsgNow(70655, dwNodeId, -1, -1, '');
      result := E_INVALIDARG;
      exit;
    end;

    if not FRDM.NodeParams.NodeInList(dwNodeId) then begin
      hr := FRDM.NodeParams.ReadNodeIdParams(dwNodeId);
      if hr < S_OK then begin
        PostLogRecordAddMsgNow(70656, dwNodeId, hr, -1, '');
        result := hr;
        exit;
      end;
    end;

    result := S_FALSE;
    ItemIndex := 0;
    while ItemIndex < Count do begin
      try
        if (Items[ItemIndex].NodeId = dwNodeId) then begin
          aList.Add(Items[ItemIndex].ParamName);
          result := S_OK;
        end;
      except on e: Exception do
        PostLogRecordAddMsgNow(70657, e.HelpContext, dwNodeId, ItemIndex, e.Message);
      end;
      ItemIndex := Succ(ItemIndex);
    end;
  except on e: Exception do begin
      PostLogRecordAddMsgNow(70654, e.HelpContext, dwNodeId, -1, e.Message);
      result := E_FAIL;
    end;
  end;
end;

{/01.07.2007}


initialization
  TComponentFactory.Create(ComServer, TVpNetDARDM,
    Class_VpNetDARDM, ciMultiInstance, tmApartment);
end.
