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
    // ID �������� �� ������� ��������� ����� ���������
    // (��� ��������� �� ��������� ������������ ������� � ������� ����������
    // IOPCBrowseServerAddressSpace)
    FNavigationNodeId : Integer;
    FNavigationNodeDevId : Integer;
    {/21.01.2008}
    FLastClientUpdateTime : TFileTime; //todo: �������� ��������� ����� ����������
//    FBrowsePosID : DWORD;
    function GetLangId : WORD; // su01
    function GetPrimaryLangId : WORD; // su01
    function GetSublangId : WORD; // su01
    function GetPropertyValidStatus(dwVDTT_ID : DWORD; dwPropertyId : DWORD; out wValidStatus : Word): HRESULT; // su01
  protected
    ClientName : String; // ��� �������
    LCID : TLCID; // �������� Locale
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
    // ��������� �������
//    function IsGroupNameUsed(aName : String) : boolean;
//    function GetGroupUniqueName : String;
    // ����� � ������� ������� ����������� Item-� � �������� ItemId
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
    PostLogRecordAddMsgNow(70056, LCID, -1, E_FAIL, '���������� �������: '+e.Message);
  end;
end;

function TVpNetOPCDA.GetPrimaryLangId : WORD;
begin
  try
    result := (LangId and $3FF); // ������� 10 ��� LANGID
  except on e : Exception do
    PostLogRecordAddMsgNow(70057, LangId, -1, E_FAIL, '���������� �������: '+e.Message);
  end;
end;

function TVpNetOPCDA.GetSublangId : WORD;
begin
  try
    result := (LangId shr 10); // ������� 10 ��� LANGID
  except on e : Exception do
    PostLogRecordAddMsgNow(70058, LangId, -1, E_FAIL, '���������� �������: '+e.Message);
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
      PostLogRecordAddMsgNow(70060, LangId, -1, E_INVALIDARG, '������ ��������� VDT_ID');
      result := E_INVALIDARG;
      exit;
    end;
    dwVDT_ID := vVDT_ID;

    // ��������� ������ ��� ���������� ��������
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

    // ���������, �������� �� �� ���������� ��������
    if not VarIsOrdinal(v) then begin
      PostLogRecordAddMsgNow(70061, LangId, -1, E_INVALIDARG, '���������� �������');
      wValidStatus := 0;
      result := E_INVALIDARG;
      exit;
    end;

    wValidStatus := v;

    result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70059, LangId, -1, E_FAIL, '���������� �������: '+e.Message);
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
    PostLogRecordAddMsgNow(70154, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
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
      // ��������� �����������
      // ...
      // �������� �����������
      if Assigned(pvValues) then CoTaskMemFree(pvValues);
      if Assigned(pwdQualities) then CoTaskMemFree(pwdQualities);
      if Assigned(pftTimeStamps) then CoTaskMemFree(pftTimeStamps);
      if Assigned(pErrors) then CoTaskMemFree(pErrors);


    finally
      // �������� �����������
      CoTaskMemFree(pdwMaxAge);
      CoTaskMemFree(pItemIDs);
    end;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70155, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
    result := E_FAIL;
  end;
  end;
end;


constructor TVpNetOPCDA.Create;
begin
  try
    inherited;
  except on e : Exception do
    PostLogRecordAddMsgNow(70149, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
  end;
end;

procedure TVpNetOPCDA.Initialize;
var
  ObjList : TList;
begin
  try
    inherited Initialize;
  except on e : Exception do
    PostLogRecordAddMsgNow(70150, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
  end;
  // ����������� ���, ���������������� �������� �������
  try
    FConnectionPoints := TConnectionPoints.Create(Self);
  {
    if AutoFactory.EventTypeInfo <> nil then
      FConnectionPoints.CreateConnectionPoint(
        AutoFactory.EventIID, ckSingle, EventConnect);
  }
    // �������� ConnectionPoint ��� ���������� IOPCShutdown
  //  if AutoFactory.EventTypeInfo <> nil then
      FConnectionPoints.CreateConnectionPoint(
        IID_IOPCShutdown, ckSingle, CallBackOnConnect);

    // �������� ����������� � ���� ������
    ServerCore.DBLock;
    try
      FRDM := TVpNetDARDM.Create(Application);
    finally
      ServerCore.DBUnlock;
    end;

    // ����������� COM-������� � �������� ��������� �������
    ObjList := ServerCore.ServerObjects.LockList;
    try
      ObjList.Add(self);
  //    PostMessage(Application.MainForm.Handle, WM_HST_DRIVER_COM_OBJECT_CREATED, Integer(self), Index);
    finally
      ServerCore.ServerObjects.UnlockList;
    end;
    // ��������� �������� Locale
    LCID := LOCALE_SYSTEM_DEFAULT;

    // �������� ������ ����� �����
    FPublicGroups := TVpNetOPCGroupList.Create;

    // �������� ������ ��������� �����
    FGroups := TVpNetOPCGroupList.Create;


    // ������� ����� �������
    ClientName := '';

    // ��������� ��������� ��������� ������� (�� ��������� �������)
    FNavigationNodeId := ServerCore.InstanceId;
    FNavigationNodeDevId := 0;

    // ��������� ������� ������ ������ ���������� �������
    CoFileTimeNow(FServerStartTime);
    LocalFileTimeToFileTime(FServerStartTime, FServerStartTime);

    // �������� ��������� � �������� ������ ���������� �������
    PostMessage(Application.MainForm.Handle, WM_DA_SERVER_CREATED, Integer(self), 0);
    PostProcessInfoNow(70015, '����������� � ������� OPC DA.');

  except on e : Exception do
    PostLogRecordAddMsgNow(70151, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
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
    PostProcessInfoNow(70016, '���������� �� ������� OPC DA.');

    // �������� ��������� �� �������� ���������� �������
    SendMessage(Application.MainForm.Handle, WM_DA_SERVER_DESTROING, Integer(self), 0);

    // ������� ��������� �����
    if assigned(FGroups) then try
      FGroups.Free;
    except
    end;

    // ������� ����� �����
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

    // �������� COM-������� �� �������� ��������� �������
    if assigned(ServerCore) then begin
      ObjList := ServerCore.ServerObjects.LockList;
      try
        ObjList.Remove(self);
      finally
        ServerCore.ServerObjects.UnlockList;
      end;
    end;

    // �������� ����������� � ���� ������
    ServerCore.DBLock;
    try
      FRDM.Free;
    finally
      ServerCore.DBUnlock;
    end;

  except on e : Exception do
    PostLogRecordAddMsgNow(70152, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
  end;

  try
    inherited;
  except on e : Exception do
    PostLogRecordAddMsgNow(70153, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
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
    PostLogRecordAddMsgNow(70062, LangId, -1, E_FAIL, '���������� �������: '+e.Message);
  end;
end;


// IOpcCommon
function TVpNetOPCDA.SetLocaleID(dwLcid: TLCID): HResult;
var
  bLocaleIdIsValid : boolean;
  Index : Integer;
begin
  try
    PostLogRecordAddMsgNow(70781, -1, -1, S_OK, '����� ������', llDebug);
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
      PostLogRecordAddMsgNow(70064, dwLcid, -1, E_FAIL, '������������ �������� ��������� dwLcid');
      result := E_INVALIDARG;
    end;
  except on e : Exception do begin
    result := E_FAIL;
    PostLogRecordAddMsgNow(70063, LangId, -1, E_FAIL, '���������� �������: '+e.Message);
  end;
  end;
end;

function TVpNetOPCDA.GetLocaleID(out   pdwLcid: TLCID): HResult;
begin
  try
    PostLogRecordAddMsgNow(70782, -1, -1, S_OK, '����� ������', llDebug);
    pdwLcid := LCID;
    result := S_OK;
  except on e : Exception do begin
    result := E_FAIL;
    PostLogRecordAddMsgNow(70065, pdwLcid, -1, E_FAIL, '���������� �������: '+e.Message);
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
    PostLogRecordAddMsgNow(70783, -1, -1, S_OK, '����� ������ QueryAvailableLocaleIDs()', llDebug);
    // ��������� ������ ������������� Locale
    {
    if not EnumSystemLocales(addr(cEnumLocalesProc), LCID_SUPPORTED) then begin
      result := E_FAIL;
      exit;
    end;
    }
    // ������������ ��������� ������ Locale
    pdwCount := ServerCore.ValidLocaleIDs.Count;
    if pdwCount > 0 then begin
      // �������� ������ ��� �������� ������
      pdwLcid := PLCIDARRAY(CoTaskMemAlloc(pdwCount*sizeof(LCID)));
      if (pdwLcid = nil) then begin
        // ���� �� ������ �������� ������, ���������� ������
        PostLogRecordAddMsgNow(70067, -1, -1, E_FAIL, '������ ��������� ������');
        result:=E_OUTOFMEMORY;
        Exit;
      end;

      // ��������� �������� ������
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
    PostLogRecordAddMsgNow(70066, pdwCount, -1, E_FAIL, '���������� �������: '+e.Message);
  end;
  end;
end;

function TVpNetOPCDA.GetErrorString(dwError: HResult;out ppString: POleStr): HResult;
begin
  try
    PostLogRecordAddMsgNow(70784, -1, -1, S_OK, '����� ������', llDebug);
    result := OPCErrorCodeToString(LCID, dwError, ppString);
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70068, dwError, -1, E_FAIL, '���������� �������: '+e.Message);
    result := E_FAIL;
  end;
  end;
end;

function TVpNetOPCDA.SetClientName(szName: POleStr): HResult;
begin
  try
    PostLogRecordAddMsgNow(70785, -1, -1, S_OK, '����� ������', llDebug);
    if @szName = nil then begin
      Result:=E_INVALIDARG;
      Exit;
    end;
    clientName:=szName;
    result:=S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70069, -1, -1, E_FAIL, '���������� �������: '+e.Message);
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
    PostLogRecordAddMsgNow(70786, -1, -1, S_OK, '����� ������ OPCDA.AddGroup', llDebug);

    // ��������� ������������� �������� ������
    phServerGroup := UnassignedGroupHandle;
    pRevisedUpdateRate := UnassignedGroupUpdateRate;
    ppUnk := nil;
    result := E_FAIL;


{09.07.2006}
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70072, -1, -1, E_FAIL, '�������� �������� �������');
      exit;
    end;
{/09.07.2006}

    // ��������� ��� ������
    sName := szName;
    if sName = EmptyStr then begin
      // ���� � �������� ����� ������ �������� ������ ������, �������� ����� ���������� ���...
      sName := Groups.GetUniqueName;
      if sName = EmptyStr then begin
        // ... � ���� ���������� ��� ����� �� �������, ������� � E_FAIL
        PostLogRecordAddMsgNow(70073, -1, -1, E_FAIL, '������� ��� ������');
        exit;
      end;
    end else if ValidateOPCString(sName) <> S_OK then begin
      // ���� ��� ������ �������� ������������ �������, ���������� E_INVALIDARG
      PostLogRecordAddMsgNow(70074, -1, -1, E_FAIL, '������� ��� ������');
      result := E_INVALIDARG;
      exit;
    end else if Groups.IsNameUsed(sName) then begin
      // ���� ��� ������ ��� ������������, ���������� OPC_E_DUPLICATENAME
      result := OPC_E_DUPLICATENAME;
      PostLogRecordAddMsgNow(70075, -1, -1, E_FAIL, '������������ ����� ������');
      exit;
    end;

    // ������� ����������
    pRevisedUpdateRate := ServerCore.GetRevisedGroupUpdateRate(dwRequestedUpdateRate);
    //
    if pRevisedUpdateRate <> dwRequestedUpdateRate then begin
      // ���� ��������� ������� ���������� �� ����� �����������,
      // ������������� ��������� ������� ������ OPC_S_UNSUPPORTEDRATE
      result := OPC_S_UNSUPPORTEDRATE;
    end;

    // DEADBAND
    if assigned(pPercentDeadband) then begin
      if (pPercentDeadband^ < 0) or (pPercentDeadband^ > 100) then begin
        PostLogRecordAddMsgNow(70076, -1, -1, E_FAIL, '������� �������� ��������� Deadband = '+ FloatToStr(pPercentDeadband^));
        result := E_INVALIDARG;
        exit;
      end;
      siDeadband := pPercentDeadband^;
    end else begin
      // ���� pPercentDeadband �� ���������, ��������� Deadband = 0
      siDeadband := 0.0;
    end;

    // ���� Deadband ������� �� ���������� ��������, ���������� E_INVALIDARG
    if (siDeadband < 0) or (siDeadband > 100) then begin
      PostLogRecordAddMsgNow(70077, -1, -1, E_INVALIDARG, '������� �������� ��������� Deadband = ' + FloatToStr(siDeadband));
      result := E_INVALIDARG;
      phServerGroup := UnassignedGroupHandle;
      pRevisedUpdateRate := UnassignedGroupUpdateRate;
      ppUnk := nil;
      exit;
    end;

    // LCID
    // ��������� ������������ LCID
    if ServerCore.ValidLocaleIDs.IndexOf(Pointer(dwLCID)) = -1 then begin
      // ���� LCID , ���������� E_INVALIDARG
      PostLogRecordAddMsgNow(70078, dwLCID, -1, E_INVALIDARG, '������� �������� ��������� LCID');
      result := E_INVALIDARG;
      phServerGroup := UnassignedGroupHandle;
      pRevisedUpdateRate := UnassignedGroupUpdateRate;
      ppUnk := nil;
      exit;
    end;

    // SERVER GROUP HANDLE
    if ServerCore.GetNewServerGroupHandle(phServerGroup) <> S_OK then begin
      // ���� �� ������� �������� ����� ��������� ������������� ������,
      // ���������� E_EAIL
      PostLogRecordAddMsgNow(70079, -1, -1, E_FAIL, '������ ��������� �������������� ������');
      result := E_FAIL;
      phServerGroup := UnassignedGroupHandle;
      pRevisedUpdateRate := UnassignedGroupUpdateRate;
      ppUnk := nil;
      exit;
    end;

    // �������� ���������� ������
//    TVpNetOPCGroup.CreateFromFactory();
    grp := TVpNetOPCGroup.Create(self, sName, bActive, pRevisedUpdateRate, hClientGroup, pTimeBias, siDeadband, dwLCID, phServerGroup);
    if grp = nil then begin
      // ���� �� ������� ������� ������, ���������� E_OUTOFMEMORY
      PostLogRecordAddMsgNow(70080, -1, -1, E_OUTOFMEMORY, '������ ��������� ������');
      result := E_OUTOFMEMORY;
      phServerGroup := UnassignedGroupHandle;
      pRevisedUpdateRate := UnassignedGroupUpdateRate;
      ppUnk := nil;
      exit;
    end;
    // ������ ���������� ������ ������
    TVpNetOPCGroupControlThread(grp.ControlThread).Resume;

    // �������� ���������� ������� ������ (ppUnk) �� ��������� (�������� � riid) ������ (grp)
    hr := IUnknown(grp).QueryInterface(riid, ppUnk);
    if hr <> S_OK then begin
      // ���� �� ������� �������� ��������� ���������, ���������� E_NOINTERFACE
      PostLogRecordAddMsgNow(70081, hr, -1, E_NOINTERFACE, '������ ����������');
      grp.Free;
      result := E_NOINTERFACE;
      phServerGroup := UnassignedGroupHandle;
      pRevisedUpdateRate := UnassignedGroupUpdateRate;
      ppUnk := nil;
      exit;
    end;

    // ��������� ������� ������ �� ������-������
    IUnknown(grp)._AddRef;
    // ��������� ������ �� ������ � ������ ��������� ����� �������
    FGroups.Add(grp);

    if result <> OPC_S_UNSUPPORTEDRATE then
      result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70070, -1, -1, E_FAIL, '���������� �������: '+e.Message);
    // � ������ �������������� ������ ���������� E_FAIL
    if assigned(grp) then try
      grp.Free;
    except
      PostLogRecordAddMsgNow(70071, -1, -1, E_FAIL, '���������� �������: '+e.Message);
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
    PostLogRecordAddMsgNow(70787, -1, -1, S_OK, '����� ������', llDebug);
    result := OPCErrorCodeToString(LCID, dwError, ppString);
    //10.09.2005
//    Debug_DoRead();
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70082, dwError, dwLocale, E_FAIL, '���������� �������: ' + e.Message);
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
    PostLogRecordAddMsgNow(70788, -1, -1, S_OK, '����� ������', llDebug);
{09.07.2006}
    // ��������� ��������
    ppUnk := nil;
    result := E_FAIL;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70085, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������');
      exit;
    end;
{/09.07.2006}

    grp := nil;
    sName := szName;
    iGroupIndex := Groups.IndexOfName(sName);
    if iGroupIndex >= 0 then begin
      // ����� ������ � ��������� �������
      grp := Groups[iGroupIndex];
    end;

    if not assigned(grp) then begin
      iGroupIndex := PublicGroups.IndexOfName(sName);
      if iGroupIndex >= 0 then begin
        // ����� ������ � ����� �������
        grp := PublicGroups[iGroupIndex];
      end;
    end;

    // ���� �� ����� ������, ���������� E_INVALIDARG
    if not assigned(grp) then begin
      PostLogRecordAddMsgNow(70086, -1, -1, E_INVALIDARG, '���������� �������');
      result := E_INVALIDARG;
      exit;
    end;

    hr := IUnknown(grp).QueryInterface(riid, ppUnk);
    if hr <> S_OK then begin
      // ���� �� ������� �������� ��������� ���������, ���������� E_NOINTERFACE
      PostLogRecordAddMsgNow(70087, hr, -1, E_NOINTERFACE, '���������� �������');
      result := E_NOINTERFACE;
      exit;
    end;

    // ���������� S_OK
    result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70084, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
    // � ������ �������������� ������ ���������� E_FAIL
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
    PostLogRecordAddMsgNow(70789, -1, -1, S_OK, '����� ������ GetStatus()', llDebug);
{09.07.2006}
    // ��������� ��������
    ppServerStatus := nil;
    result := E_FAIL;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70089, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������');
      exit;
    end;
{/09.07.2006}

    // ���� ��������� �� �����, ���� ����� ���������� ��������� �� ���������,
    // ���������� E_INVALIDARG
    if not assigned(@ppServerStatus) then begin
      PostLogRecordAddMsgNow(70090, -1, -1, E_INVALIDARG, '���������� �������');
      result := E_INVALIDARG;
      exit;
    end;

    ppServerStatus := POPCSERVERSTATUS(CoTaskMemAlloc(sizeof(OPCSERVERSTATUS)));
    // ���� �� ������� �������� ����� ��� ���������, ���������� E_OUTOFMEMORY
    if not assigned(ppServerStatus) then begin
      PostLogRecordAddMsgNow(70091, -1, -1, E_OUTOFMEMORY, '���������� �������');
      result := E_OUTOFMEMORY;
      exit;
    end;

    // ���������� ��������� ������� ...
    ppServerStatus.ftStartTime := FServerStartTime;
    CoFiletimeNow(ppServerStatus.ftCurrentTime);
    LocalFileTimeToFileTime(ppServerStatus.ftCurrentTime, ppServerStatus.ftCurrentTime);
    ppServerStatus.ftLastUpdateTime := FLastClientUpdateTime;
    ppServerStatus.dwServerState := OPC_STATUS_RUNNING;
    ppServerStatus.dwGroupCount := Groups.Count + PublicGroups.Count;

    ppServerStatus.dwBandWidth := 100; //todo: ����������

    // ��������� ������ � ������� ��������
    vInfo := TRzVersionInfo.Create(nil);
    try
      vInfo.FilePath := Application.ExeName;
      // ���������� ������ ��������
      lProductVersion := TStringList.Create;
      try
        lProductVersion.Delimiter := '.';
        lProductVersion.DelimitedText := vInfo.ProductVersion;
        try
          ppServerStatus.wMajorVersion := StrToInt(lProductVersion[0]);
          ppServerStatus.wMinorVersion := StrToInt(lProductVersion[1]);
          ppServerStatus.wBuildNumber := StrToInt(lProductVersion[3]);
        except on e : Exception do begin
          PostLogRecordAddMsgNow(70093, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
          CoTaskMemFree(ppServerStatus);
          result := E_FAIL;
          exit;
        end;
        end;
      finally
        lProductVersion.Free;
      end;

      // ���������� ������ � ��������� �������������
(*
      LangId := aLCID and $FFFF;
      PrimaryLangId := (LangId and $3FF); // ������� 10 ��� LANGID
    if (PrimaryLangId = $009) {English} then
    else if (PrimaryLangId = $019) {Russian} then
      err_ := err_rus
    else
      err_ := err_eng;
*)
      if PrimaryLangId = LANG_RUSSIAN then begin
        sVendorInfo := '�� "��� ���"'; //vInfo.CompanyName
      end else begin
        sVendorInfo := 'NTF MIT';
      end;
      result := VpStringToLPOLESTR(sVendorInfo, ppServerStatus.szVendorInfo);
    finally
      vInfo.Free;
    end;

  except on e : Exception do begin
    // � ������ �������������� ������ ���������� E_FAIL
    PostLogRecordAddMsgNow(70088, -1, -1, E_FAIL, '���������� �������');
    if assigned(ppServerStatus) then try
      CoTaskMemFree(ppServerStatus);
    except on e : Exception do
      PostLogRecordAddMsgNow(70094, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
    end;
    ppServerStatus := nil;
    result := E_FAIL;
  end;
  end;
end;

//todo: ������� �� ���������!
function TVpNetOPCDA.RemoveGroup(
  hServerGroup: OPCHANDLE;
  bForce: BOOL
): HResult; stdcall;
var
  grpIndex : Integer;
  grp : TVpNetOPCGroup;
begin
  try
    PostLogRecordAddMsgNow(70790, -1, -1, S_OK, '����� ������', llDebug);
{09.07.2006}
    // ��������� ��������
    result := E_FAIL;
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70096, Integer(ServerCore.State), -1, OPC_S_INUSE, '�������� ��������� �������');
      result := OPC_S_INUSE;
      exit;
    end;
{/09.07.2006}

    // ��������� ������� ������ � ��������� ��������� HANDLE-��
    grpIndex := Groups.IndexOfServerHandle(hServerGroup);
    if grpIndex < 0 then begin
      // ���� ����� ������ ���, ���������� E_INVALIDARG
      PostLogRecordAddMsgNow(70097, grpIndex, -1, E_INVALIDARG, '�������� ��������� � ������');
      result:=E_INVALIDARG;
      Exit;
    end;

//    release
    // ��������� ����������� �������� ������
    //todo: ��������� ������������ ������� aGrp.RefCount > 2
//    if (grp.RefCount > 2) and not bForce then begin
//      // ���� ������� �� ������, ���������� OPC_S_INUSE
//      result:=OPC_S_INUSE;
//      Exit;
//    end;

    // �������� ������ �� ������
    grp := Groups[grpIndex];
    // �������� ������
    Groups.Delete(grpIndex);

{
    // ��������� ������� ������ �� ������-������
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
    PostLogRecordAddMsgNow(70095, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
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
    PostLogRecordAddMsgNow(70791, -1, -1, S_OK, '����� ������', llDebug);
{09.07.2006}
    // ��������� ��������
    ppUnk := nil;
    result := E_FAIL;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70099, Integer(ServerCore.State), -1, OPC_S_INUSE, '�������� ��������� �������');
      result := OPC_S_INUSE;
      exit;
    end;
{/09.07.2006}

    if IsEqualIID(riid,IEnumString) then begin
      // ���� �������� ��������� IEnumString ...
      try
        // ... ��������� ������ ����� ...
        lStrings := TStringList.Create;
        // ... �, � ����������� �� dwScope, ��������� ��� ����� ...
        case dwScope of
          OPC_ENUM_PRIVATE_CONNECTIONS,OPC_ENUM_PRIVATE: try
            // ... ��������� ����� ...
            AddToStrings(FGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70101, -1, -1, E_FAIL, '���������� �������');
          end;
          OPC_ENUM_PUBLIC_CONNECTIONS,OPC_ENUM_PUBLIC: try
            // ... ����� ����� ...
            AddToStrings(FPublicGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70102, -1, -1, E_FAIL, '���������� �������');
          end;
          OPC_ENUM_ALL_CONNECTIONS,OPC_ENUM_ALL: try
            // ... ��� ���� ����� ...
            AddToStrings(FGroups);
            AddToStrings(FPublicGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70103, -1, -1, E_FAIL, '���������� �������');
          end;
          else begin
            // ...(��� ����������� �������� dwScope ���������� E_INVALIDARG)...
            PostLogRecordAddMsgNow(70104, dwScope, -1, E_INVALIDARG, '���������� �������');
            ppUnk := nil;
            result := E_INVALIDARG;
            exit;
          end;
        end;
        // ..., ����� ��������� StringEnumerator ...
        ppUnk := TVpNetStringEnumerator.Create(lStrings);
        // ... � ���� StringEnumerator �������� ��������, ...
        if lStrings.Count > 0 then begin
          // ... ���������� S_OK ...
          result := S_OK
        end else begin
          // ... ����� ���������� S_FALSE.
          result := S_FALSE;
        end;

      finally
        lStrings.Free;
      end;
    end else if IsEqualIID(riid,IEnumUnknown) then begin
      // ���� �������� ��������� IEnumUnknown ...
      try
        // ... ������� ������ ...
        lUnknowns := TVpNetOPCGroupList.Create;
        // ... �, � ����������� �� dwScope, ��������� ��� �������� �� ...
        case dwScope of
          OPC_ENUM_PRIVATE_CONNECTIONS,OPC_ENUM_PRIVATE: try
            // ... ��������� ������ ...
            AddToUnknowns(FGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70105, -1, -1, E_FAIL, '���������� �������');
          end;
          OPC_ENUM_PUBLIC_CONNECTIONS,OPC_ENUM_PUBLIC: try
            // ... ����� ������ ...
            AddToUnknowns(FPublicGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70106, -1, -1, E_FAIL, '���������� �������');
          end;
          OPC_ENUM_ALL_CONNECTIONS,OPC_ENUM_ALL: try
            // ... ��� ��� ������ ...
            AddToUnknowns(FGroups);
            AddToUnknowns(FPublicGroups);
          except on e : Exception do
            PostLogRecordAddMsgNow(70107, -1, -1, E_FAIL, '���������� �������');
          end;
          else begin
            // ...(��� ����������� �������� dwScope ���������� E_INVALIDARG)...
            PostLogRecordAddMsgNow(70108, dwScope, -1, E_FAIL, '���������� �������');
            ppUnk := nil;
            result := E_INVALIDARG;
            exit;
          end;
        end;
        // ..., ����� ��������� UnknownEnumerator ...
        ppUnk := TVpNetUnknownEnumerator.Create(lUnknowns) as IUnknown;
        // ... � ���� UnknownEnumerator �������� ��������, ...
        if lUnknowns.Count > 0 then begin
          // ... ���������� S_OK ...
          result := S_OK
        end else begin
          // ... ����� ���������� S_FALSE.
          result := S_FALSE;
        end;
      finally
        lUnknowns.Free;
      end;
    end else begin
      // ���� ���������� ����������� ���������, ���������� E_NOINTERFACE
      PostLogRecordAddMsgNow(70100, -1, -1, E_NOINTERFACE, '������ ����������');
      ppUnk := nil;
      result := E_NOINTERFACE;
      exit;
    end;
//    result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70098, -1, -1, E_FAIL, '���������� �������' + e.Message);
    // ��� ������������� �������������� ������, ���������� E_FAIL
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
    PostLogRecordAddMsgNow(70793, -1, -1, S_OK, '����� ������', llDebug);
    // ��������� �������������
    ppItemProperties := nil;

{09.07.2006}
    // ��������� ��������
    result := E_FAIL;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70113, Integer(ServerCore.State), -1, OPC_S_INUSE, '�������� ��������� �������');
      result := OPC_S_INUSE;
      exit;
    end;
{/09.07.2006}


    // ���� ��� ��������� � �������, ������� � S_OK
    if dwItemCount = 0 then begin
      PostLogRecordAddMsgNow(70114, -1, -1, S_OK, '��� ��������� � �������');
      result := S_OK;
      exit;
    end;

    // �������� ������ ��� ppItemProperties
    ppItemProperties := POPCITEMPROPERTIESARRAY(CoTaskMemAlloc(dwItemCount * SizeOf(OPCITEMPROPERTIES)));

    // ���� �� ������� �������� ������, ������� � E_OUTOFMEMORY
    if ppItemProperties = nil then begin
      PostLogRecordAddMsgNow(70115, -1, -1, E_OUTOFMEMORY, '������ ��������� ������');
      RESULT := E_OUTOFMEMORY;
      exit;
    end;

    // �������� �� ������ ����������� �����
    ErrCount := 0; // �������� ������� ������
    ItemIndex := 0;
    while ItemIndex < dwItemCount do begin
      ppItemProperties^[ItemIndex].dwReserved :=0;
      ppItemProperties^[ItemIndex].hrErrorID := rdm.SplitItemID(pszItemIDs^[ItemIndex], HostServerID, HostServerDriverID, DeviceID, DeviceTypeTagID);
      ppItemProperties^[ItemIndex].dwNumProperties :=0;
      ppItemProperties^[ItemIndex].pItemProperties := POPCITEMPROPERTYARRAY(CoTaskMemAlloc(dwPropertyCount * SizeOf(OPCITEMPROPERTY)));
      pItemProps := @(ppItemProperties^[ItemIndex]);

      // ������ ���� �����
      if ppItemProperties^[ItemIndex].hrErrorID <> S_OK then begin
        // ������ ������ ��� ������� �����: ��������� ������ ������ ������� � ���������� �������
        ErrCount := Succ(ErrCount);
      end else if DeviceTypeTagID = 0 then begin
        // ������ 1: ���������� ��������� ��������� �������� ('root')
        //todo: ���������
      end else if HostServerDriverID = 0 then begin
        // ������ 2: ���������� ��������� ����-�������
        //todo: ���������
      end else if DeviceID = 0 then begin
        // ������ 3: ���������� ��������� �������� ����-�������
        //todo: ���������
      end else if DeviceTypeTagID = 0 then begin
        // ������ 4: ���������� ��������� ����������
        //todo: ���������
      end else begin
        // ������ 5: ���������� ��������� ���� ����������
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
            // ����������� �������� ���� ...
            qTags.Open;
            // ��������� pItemProps
            result := FillPOPCITEMPROPERTIES(pItemProps, pszItemIDs^[ItemIndex], bReturnPropertyValues, qTags);
            if result <> S_OK then begin
              PostLogRecordAddMsgNow(70116, -1, -1, result, '���������� �������');
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

    // ���� �������� ���� ���������� �������
    if ErrCount = 0 then
      //� ���� ������ ������ � ���������, ���������� S_OK
      result := S_OK
    else
      //���� ������ � ��������� ����, ���������� S_FALSE
      result := S_FALSE;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70112, result, -1, E_FAIL, '���������� �������: ' + e.Message);
    // � ������ �������������� ������ ...
    // ... ���� ������ ���� ��������, ����������� ��, ...
    if assigned(ppItemProperties) then begin
      CoTaskMemFree(ppItemProperties);
      ppItemProperties := nil;
    end;
    // ... � ���������� E_FAIL
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
  tagHostServer : String; // ��� ����-�������
  tagHostServerDriver : String; // ��� �������� ����-�������
  tagDevice : String; // ��� ����������
  tagDeviceTypeTag : String; // ��� ���� ���� ���������� :)

  sl : TStringList;
  c : Char;
  dsTagParams : TDataSet;
  ds : TDataSet;
  i2 : Integer;
begin
  try
    PostLogRecordAddMsgNow(70792, -1, -1, S_OK, '����� ������ FillPOPCITEMPROPERTIES(szItemID = '+szItemID+')', llDebug);
    // ���������
    result := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag, false);

    // ���� ���� ������� �������, ���������� ���������� ������
    if result <> S_OK then begin
      PostLogRecordAddMsgNow(70110, result, -1, E_FAIL, '������������ ��� ' + szItemId);
      exit;
    end;

    // ��������� ItemPorperties
    pItemProps^.hrErrorID := S_OK; // ������� �������� ������ ������� ��������
    pItemProps^.dwNumProperties := 7; {"����������"}
{28.08.2007}
//    v := rdm.GetOneCell('select count(*) from vn_tag_properties where vdtt_id = ' + rdm.IntToSQL(qTags.FieldByName('vdtt_id').AsInteger, '-1'));
//    if VarIsOrdinal(v) then
//      pItemProps^.dwNumProperties := pItemProps^.dwNumProperties + v{�����������};
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
    pItemProps^.dwNumProperties := pItemProps^.dwNumProperties + DWORD(i2){�����������};
{/28.08.2007}
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70767, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // �������� ����� ��� dwNumProperties �������
    pItemProps^.pItemProperties :=
      POPCITEMPROPERTYARRAY(CoTaskMemAlloc(pItemProps^.dwNumProperties * sizeof(OPCITEMPROPERTY)));
    // ���� �� ������� �������� ������ ��� ������ �������, ������� � �������
    if pItemProps^.pItemProperties = nil then begin
      PostLogRecordAddMsgNow(70111, result, -1, E_FAIL, '���������� �������');
      pItemProps^.hrErrorID := S_FALSE;
      result := E_OUTOFMEMORY;
      exit;
    end;
    pItemProps^.dwReserved := 0;

    // ���� ������� � �������
    hr := FindFirstItemByItemId(szItemID, Pointer(Item));

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70768, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // ������ � ������ "����������" ���������
    // - "Item Canonical data type" ------------------------------------
    pItemProps^.pItemProperties^[0].vtDataType := VT_I2;
    pItemProps^.pItemProperties^[0].wReserved := 0;
    pItemProps^.pItemProperties^[0].dwPropertyID := OPC_PROPERTY_DATATYPE;
    pItemProps^.pItemProperties^[0].szItemID := StringToOleStr(szItemID + '.CAN_DATATYPE');
    pItemProps^.pItemProperties^[0].szDescription := StringToOleStr(OPC_PROPERTY_DESC_DATATYPE);
    VariantInit(pItemProps^.pItemProperties^[0].vValue);
    // ���� ��� ������ �� ������� �������� �������, ...
    if bReturnPropertyValues then begin
      // ���������� �������� �� ���� ������,
      si := qTags.FieldByName('VDT_VAR_TYPE').AsInteger and $7fff;
      pItemProps^.pItemProperties^[0].vValue := VarAsType(si, varSmallint);
    end else begin
      // ���� ������� ������, ���������� Null
      pItemProps^.pItemProperties^[0].vValue := Null;
    end;

    pItemProps^.pItemProperties^[0].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[0].dwReserved := 0;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70769, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
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
    // ���� ��� ������ �� ������� �������� �������, ...
    if bReturnPropertyValues then begin
      // ���� �� ����� ������ ������� � ������ ����� �����,
      if assigned(Item) then
        // ����� �������� ������,
        pItemProps^.pItemProperties^[1].vValue := VarAsType(Item.Value, pItemProps^.pItemProperties^[1].vtDataType)
      else
        // ����� ���������� Unassigned
        pItemProps^.pItemProperties^[1].vValue := Null;
    end else begin
      // ���� ������� ������, ���������� Null
      pItemProps^.pItemProperties^[1].vValue := Null;
    end;
    pItemProps^.pItemProperties^[1].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[1].dwReserved := 0;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70770, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
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
    // ���� ��� ������ �� ������� �������� �������, ...
    if bReturnPropertyValues then begin
      // ���� �� ����� ������ ������� � ������ ����� �����,
      if assigned(Item) then
        // ����� �������� ������,
        pItemProps^.pItemProperties^[2].vValue := VarAsType(Item.Quality, VT_I2)
      else
        // ����� ���������� Unassigned
        pItemProps^.pItemProperties^[2].vValue := Null;
    end else begin
      // ���� ������� ������, ���������� Null
      pItemProps^.pItemProperties^[2].vValue := Null;
    end;
    pItemProps^.pItemProperties^[2].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[2].dwReserved := 0;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70771, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
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
    // ���� ��� ������ �� ������� �������� �������, ...
    if bReturnPropertyValues then begin
      // ���� �� ����� ������ ������� � ������ ����� �����,
      if assigned(Item) then
        // ����� �������� ������,
        pItemProps^.pItemProperties^[3].vValue := VarAsType(FileTimeToDateTime(Item.Timestamp), VT_DATE)
      else
        // ����� ���������� Null
        pItemProps^.pItemProperties^[3].vValue := Null;
    end else begin
      // ���� ������� ������, ���������� Null
      pItemProps^.pItemProperties^[3].vValue := Null;
    end;
    pItemProps^.pItemProperties^[3].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[3].dwReserved := 0;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70772, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
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
    // ���� ��� ������ �� ������� �������� �������, ...
    if bReturnPropertyValues then begin
      // ���� �� ����� ������ ������� � ������ ����� �����,
      if assigned(Item) then begin
        // ����� �������� ������,
        pItemProps^.pItemProperties^[4].vValue := VarAsType(Item.AccessRights, VT_I4);
      end else begin
        // ����� ���������� �������� �� ����
        dw := 0;
        if (qTags.FieldByName('vdtt_access_rights').AsInteger and OPC_READABLE) > 0 then
          dw := dw + OPC_READABLE;
        if (qTags.FieldByName('vdtt_access_rights').AsInteger and OPC_WRITEABLE) > 0 then
          dw := dw + OPC_WRITEABLE;
        pItemProps^.pItemProperties^[4].vValue := VarAsType(dw, VT_I4);
      end;
    end else begin
      // ���� ������� ������, ���������� Null
      pItemProps^.pItemProperties^[4].vValue := Null;
    end;
    pItemProps^.pItemProperties^[4].hrErrorID := S_OK;
    pItemProps^.pItemProperties^[4].dwReserved := 0;

    // - "Server Scan Rate" (�� ��������������)
    //todo: ��������

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70773, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
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
    PostLogRecordAddMsgNow(70774, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
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
    PostLogRecordAddMsgNow(70775, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // ���� ��� ������ �� ������� �������� �������, ...
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
            // ���� ������� �� ������, ������ ����� ���������� VarArray
            pItemProps^.pItemProperties^[6].vtDataType := VT_ARRAY;
            sl := TStringList.Create;
            try
               // ��������� ������ ��������
              while not qEnumValues.Eof do begin
                // ���� ����� �������� ������ 100
                if qEnumValues.FieldByName('vei_value').AsInteger < 100 then begin
                  // ����������� ������ ������� �� ����������� ��������
                  while sl.Count <= qEnumValues.FieldByName('vei_value').AsInteger do sl.Add('');
                  // � ��������� ������� � ��� �������
                  sl[qEnumValues.FieldByName('vei_value').AsInteger] := qEnumValues.FieldByName('vei_text').AsString;
                end;
                qEnumValues.Next;
              end;
              case qTags.FieldByName('VDTT_EU_TYPE').AsInteger of
                OPC_ANALOG: begin
                  // ���������� ��������
                  // ���������� � EUInfo ���������� ������ �������� ���� vt_r8
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
                  // ������������ ��������
                  // ���������� � EUInfo ���������� ������ �����
                  pItemProps^.pItemProperties^[6].vValue := VarArrayCreate([0, sl.Count - 1], varOleStr);
                  i := 0;
                  while i < sl.Count do begin
                    pItemProps^.pItemProperties^[6].vValue[i] := sl[i];
                    i := Succ(i);
                  end;
                end;
                else begin
                  // OPC_NOENUM ��� ������ ��������
                  pItemProps^.pItemProperties^[6].vtDataType := VT_EMPTY;
                  VariantChangeType(pItemProps^.pItemProperties^[6].vValue, pItemProps^.pItemProperties^[6].vValue, 0, VT_EMPTY);
                  pItemProps^.pItemProperties^[6].vValue := NULL;
                end;
              end;
            finally
              sl.Free;
            end;
          end else begin
            // ���� ������� ������, ������ ����� ���������� VT_EMPTY
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
      // ���� ������� ������, ���������� Null
      pItemProps^.pItemProperties^[6].vtDataType := VT_EMPTY;
      VariantChangeType(pItemProps^.pItemProperties^[6].vValue, pItemProps^.pItemProperties^[6].vValue, 0, VT_EMPTY);
      pItemProps^.pItemProperties^[6].vValue := Null;
    end;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70776, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
    result := E_FAIL;
    exit;
  end;
  end;

  try
    // ����������� ��������� ���� �� ���� ������ -----------------------
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
    PostLogRecordAddMsgNow(70109, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
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
  tagHostServer : String; // ��� ����-�������
  tagHostServerDriver : String; // ��� �������� ����-�������
  tagDevice : String; // ��� ����������
  tagDeviceTypeTag : String; // ��� ���� ���� ���������� :)
  hr : HRESULT;
  ds : TDataSet;
  dsTags : TDataSet;
  dwElementCount : DWORD;
  ElementIndex : DWORD;
  sSQL : String;
  pItemProps : POPCITEMPROPERTIES;
begin
  try
    PostLogRecordAddMsgNow(70794, -1, -1, S_OK, '����� ������ Browse(...)', llDebug);
    // ��������� ������������� �������� ������
    pbMoreElements := false; // �� ��������� �������, ������� ��������� ��������
    pdwCount := 0; // �� ��������� �� ���������� ���������
    ppBrowseElements := nil; // �� ��������� �� ���������� ���������
    result := S_OK;

{09.07.2006}
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70118, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������');
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // ��������� szItemId
    //todo: �������� ��� ���������� ������� SplitItemID() � String �� POleStr

// 28.09.2010
//    hr := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag);
    hr := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag, false);
///28.09.2010

// 28.09.2010
//    if hr <> S_OK then begin
    if hr < S_OK then begin
///28.09.2010
      PostLogRecordAddMsgNow(70119, hr, -1, E_FAIL, '������������ ��� "' + szItemId +'"');
      exit;
    end;

    // ������ ����������� szItemId
    if tagHostServer = EmptyStr then begin
      // ������ 1: ����� ��������� �������� ('root')

      // ������� ����� ������� ������ ���� ��������
      sSQL := 'from vn_host_servers vhs ';
      // ���� ��� ������ ContinuationPoint, �� ������� ���������� ���������
      // ����-�������� ������� � ���������� � pszContinuationPoint
      if pszContinuationPoint <> EmptyStr then
        sSQL := sSQL +
          'where vhs.vhs_id >= ( ' +
          'select vhs2.vhs_id from vn_host_servers vhs2 ' +
          'where vhs2.vhs_tag = ''' + pszContinuationPoint + ''') ';

      // �������� ���������� ��������� ����-�������� �������
      dwElementCount := rdm.GetOneCell('select count(*) ' + sSQL);

      // ��������� �� ��������������� ����-��������
      sSQL := sSQL + 'order by vhs.vhs_id ';

      // ���������, ����� �� ���������� ������� ��������� � ���� �� �����������
      // �� ���������� ��������� ������
      if (dwMaxElementsReturned = 0) or (dwElementCount <= dwMaxElementsReturned) then begin
        // ���� ����� ������� ����� ��� �������� (��� ��� �����
        // ���������� �����������), ���������� ��� ��������
        pdwCount := dwElementCount;
        pbMoreElements := false;
      end else begin
        // ����� ���������� ����������� ����������� ���������� ���������
        pdwCount := dwMaxElementsReturned;
        pbMoreElements := true;
      end;

      // ���� ������� ����� ������ ��������� (�� �����) ���������� ������ ������
      if (dwBrowseFilter = OPC_BROWSE_FILTER_ITEMS) then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // ���� ������ szElementNameFilter, ���������� ������ �������
      //todo: ����������� ���������� �� szElementNameFilter
      if szElementNameFilter <> EmptyStr then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // ���� ������ szVendorFilter, ���������� ������ �������
      //todo: ����������� ���������� �� szVendorFilter
      if szVendorFilter <> EmptyStr then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // ���� ���� ��������� ��������,...
      if pdwCount > 0 then begin
        // ... �������� ������ ��� �������� pdwCount ��������� ���� OPCBROWSEELEMENT
        ppBrowseElements := POPCBROWSEELEMENTARRAY(CoTaskMemAlloc(pdwCount * sizeof(OPCBROWSEELEMENT)));

        // ���� ������ �������� �� �������, ������� � �������
        if ppBrowseElements = nil then begin
          PostLogRecordAddMsgNow(70120, hr, -1, E_OUTOFMEMORY, '������ ������');
          pdwCount := 0;
          pbMoreElements := false;
          result := E_OUTOFMEMORY;
          exit;
        end;

        // ������� ������ ��������� ����-�������� �������
        rdm.Lock;
        try
          ds := rdm.GetQueryDataset('select vhs_id, vhs_tag, vhs_text ' + sSQL);
          try
            // ����������� ������ ����-�������� ...
            ds.Open;
            // �������� �� ���������� �������
            ElementIndex := 0;
            ds.First;
            while (not ds.Eof) and (ElementIndex < pdwCount) do begin
              // ��������� ��������� ������
              ppBrowseElements^[ElementIndex].szName := StringToOleStr(ds.FieldByName('vhs_text').AsString);
              ppBrowseElements^[ElementIndex].szItemID := StringToOleStr(ds.FieldByName('vhs_tag').AsString);
              // ������ ������� �������� ������ � �� �������� ��������� ������
              ppBrowseElements^[ElementIndex].dwFlagValue := OPC_BROWSE_HASCHILDREN;
              ppBrowseElements^[ElementIndex].dwReserved := 0;
              // � ���� �������� ������� ���� ��� ����������
              //todo: �������� ��������� ����-�������
              ppBrowseElements^[ElementIndex].ItemProperties.hrErrorID := S_OK;
              ppBrowseElements^[ElementIndex].ItemProperties.dwNumProperties := 0;
              ppBrowseElements^[ElementIndex].ItemProperties.pItemProperties := nil;
              ppBrowseElements^[ElementIndex].ItemProperties.dwReserved :=0;

              // ��������� � ���������� ��������
              ElementIndex := Succ(ElementIndex);
              ds.Next;
            end;
            // ���� ������� �� ���, ���������� ContinuationPoint
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
      // ������ 2: ����� ����-������� (����� ��������� ����-�������)
      // ������� ����� ������� ������ ��������� ���� �������
      sSQL :=
        'from vn_host_server_drivers vhsd ' +
        'where vhs_id = ( ' +
        '  select vhs.vhs_id from vn_host_servers vhs ' +
        '  where vhs.vhs_tag = '''+ tagHostServer +''') ';
      // ���� ��� ������ ContinuationPoint, �� ������� ���������� ���������
      // ��������� ����-������� ������� � ���������� � pszContinuationPoint
      if pszContinuationPoint <> EmptyStr then
        sSQL := sSQL +
        '  and vhsd.vhsd_id >= ( ' +
        '    select vhsd2.vhsd_id from vn_host_server_drivers vhsd2 ' +
        '    where vhsd2.vhsd_tag = ''' + pszContinuationPoint + ''') ';

      // �������� ���������� ��������� ��������� ����-��������
      dwElementCount := rdm.GetOneCell('select count(*) ' + sSQL);

      // ��������� �� ��������������� ��������� ����-�������
      sSQL := sSQL + 'order by vhsd.vhsd_id ';

      // ���������, ����� �� ���������� ������� ��������� � ���� �� ����������� �� ���������� ��������� ������
      if (dwMaxElementsReturned = 0) or (dwElementCount <= dwMaxElementsReturned) then begin
        // ���� ����� ������� ����� ��� �������� (��� ��� ����� ���������� �����������), ��� � ������
        pdwCount := dwElementCount;
        pbMoreElements := false;
      end else begin
        // ����� ����� ���������� ����������� ����������� ���������� ���������
        pdwCount := dwMaxElementsReturned;
        pbMoreElements := true;
      end;

      // ���� ������� ����� ������ ��������� (�� �����) ���������� ������ ������
      if (dwBrowseFilter = OPC_BROWSE_FILTER_ITEMS) then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // ���� ���� ��������� ��������,...
      if pdwCount > 0 then begin
        // ... �������� ������ ��� �������� pdwCount ��������� ���� OPCBROWSEELEMENT
        ppBrowseElements := POPCBROWSEELEMENTARRAY(CoTaskMemAlloc(pdwCount * sizeof(OPCBROWSEELEMENT)));

        // ���� ������ �������� �� �������, ������� � �������
        if ppBrowseElements = nil then begin
          PostLogRecordAddMsgNow(70121, hr, -1, E_OUTOFMEMORY, '������ ������');
          pdwCount := 0;
          pbMoreElements := false;
          result := E_OUTOFMEMORY;
          exit;
        end;

        // ������� ������ ��������� ����-�������� �������
        rdm.Lock;
        try
          ds := rdm.GetQueryDataset('select vhsd.vhsd_id, vhsd.vhsd_tag, vhsd.vhsd_text ' + sSQL);
          try
            // ����������� ������ ����-�������� ...
            ds.Open;
            // �������� �� ���������� �������
            ElementIndex := 0;
            ds.First;
            while (not ds.Eof) and (ElementIndex < pdwCount) do begin
              // ��������� ��������� ������
              ppBrowseElements^[ElementIndex].szName := StringToOleStr(ds.FieldByName('vhsd_text').AsString);
              ppBrowseElements^[ElementIndex].szItemID := StringToOleStr(tagHostServer + '.' + ds.FieldByName('vhsd_tag').AsString);
              // ������ ������� �������� ������ � �� �������� ��������� ������
              ppBrowseElements^[ElementIndex].dwFlagValue := OPC_BROWSE_HASCHILDREN;
              ppBrowseElements^[ElementIndex].dwReserved := 0;
              // ��������� ItemPorperties
              ppBrowseElements^[ElementIndex].ItemProperties.hrErrorID := S_OK; // ������� �������� ������ ������� ��������
              ppBrowseElements^[ElementIndex].ItemProperties.dwNumProperties := 0; // ���� � �������� ����-������� ������� ���.
              ppBrowseElements^[ElementIndex].ItemProperties.pItemProperties := nil;
              ppBrowseElements^[ElementIndex].ItemProperties.dwReserved := 0;
              // ��������� � ���������� ��������
              ElementIndex := Succ(ElementIndex);
              ds.Next;
            end;
            // ���� ������� �� ���, ���������� ContinuationPoint
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
      // ������ 3: ����� �������� ����-������� (����� ��������� �������� ����-�������)
      // ������� ����� ������� ������ ��������� �������� ���� �������
      sSQL :=
        'from vda_devices vd ' +
        'where ' +
        '  vd.vhsd_id = ( ' +
        '    select vhsd.vhsd_id from vn_host_server_drivers vhsd ' +
        '    where vhsd.vhsd_tag = ''' + tagHostServerDriver + ''') ';
      // ���� ��� ������ ContinuationPoint, �� ������� ���������� ���������
      // ��������� �������� ����-������� ������� � ���������� � pszContinuationPoint
      if pszContinuationPoint <> EmptyStr then
        sSQL := sSQL +
          '  and vd.vd_id >= ( ' +
          '    select vd2.vd_id from vda_devices vd2 ' +
          '    where vd2.vd_tag = ''' + pszContinuationPoint + ''') ';

      // �������� ���������� ��������� ��������� �������� ����-�������
      dwElementCount := rdm.GetOneCell('select count(*) ' + sSQL);

      // ��������� �� ��������������� ��������� �������� ����-�������
      sSQL := sSQL + 'order by vd.vd_id ';

      // ���������, ����� �� ���������� ������� ��������� � ���� �� ����������� �� ���������� ��������� ������
      if (dwMaxElementsReturned = 0) or (dwElementCount <= dwMaxElementsReturned) then begin
        // ���� ����� ������� ����� ��� �������� (��� ��� ����� ���������� �����������), ��� � ������
        pdwCount := dwElementCount;
        pbMoreElements := false;
      end else begin
        // ����� ����� ���������� ����������� ����������� ���������� ���������
        pdwCount := dwMaxElementsReturned;
        pbMoreElements := true;
      end;

      // ���� ������� ����� ������ ��������� (�� �����) ���������� ������ ������
      if (dwBrowseFilter = OPC_BROWSE_FILTER_ITEMS) then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // ���� ���� ��������� ��������,...
      if pdwCount > 0 then begin
        // ... �������� ������ ��� �������� pdwCount ��������� ���� OPCBROWSEELEMENT
        ppBrowseElements := POPCBROWSEELEMENTARRAY(CoTaskMemAlloc(pdwCount * sizeof(OPCBROWSEELEMENT)));

        // ���� ������ �������� �� �������, ������� � �������
        if ppBrowseElements = nil then begin
          PostLogRecordAddMsgNow(70122, hr, -1, E_OUTOFMEMORY, '������ ������');
          pdwCount := 0;
          pbMoreElements := false;
          result := E_OUTOFMEMORY;
          exit;
        end;

        // ������� ������ ��������� ���������
        rdm.Lock;
        try
          ds := rdm.GetQueryDataset('select vd.vd_id, vd.vd_tag, vd.vd_text ' + sSQL);
          try
            // ����������� ������ ��������� ...
            ds.Open;
            // �������� �� ���������� �������
            ElementIndex := 0;
            ds.First;
            while (not ds.Eof) and (ElementIndex < pdwCount) do
            with ppBrowseElements^[ElementIndex] do begin
              // ��������� ��������� ������
              szName := StringToOleStr(ds.FieldByName('vd_text').AsString);
              szItemID := StringToOleStr(tagHostServer + '.' + tagHostServerDriver + '.' + ds.FieldByName('vd_tag').AsString);
              // ������ ������� �������� ������ � �� �������� ��������� ������
              dwFlagValue := OPC_BROWSE_HASCHILDREN;
              dwReserved := 0;
              // ��������� ItemPorperties
              ItemProperties.hrErrorID := S_OK; // ������� �������� ������ ������� ��������
              ItemProperties.dwNumProperties := 0; // ���� ������� ���.
              ItemProperties.pItemProperties := nil;
              ItemProperties.dwReserved := 0;
              // ��������� � ���������� ��������
              ElementIndex := Succ(ElementIndex);
              ds.Next;
            end;
            // ���� ������� �� ���, ���������� ContinuationPoint
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
      // ������ 4: ����� ���������� (����� ����� ����������)
      // ������� ����� ������� ������ ����� ����������
      sSQL :=
        'from vda_device_type_tags vdtt ' +
        'left outer join VN_DATATYPES vdt on vdt.vdt_id = vdtt.vdt_id ' +
        'where ' +
        '  vdtt.vdtv_id = ( ' +
        '    select vd.vdtv_id from vda_devices vd ' +
        '    where vd.vd_tag = '''+tagDevice+''') ';
      // ���� ��� ������ ContinuationPoint, �� ������� ���������� ���������
      // ����� ���������� ������� � ���������� � pszContinuationPoint
      if pszContinuationPoint <> EmptyStr then
        sSQL := sSQL +
          '  and vdtt.vdtt_id >= ( ' +
          '    select vdtt2.vdtt_id from vda_device_type_tags vdtt2 ' +
          '    where vdtt2.vdtt_tag = '''+pszContinuationPoint+''') ';

      // �������� ���������� ��������� �����
      dwElementCount := rdm.GetOneCell('select count(*) ' + sSQL);

      // ��������� �� ��������������� ����� ����������
      sSQL := sSQL + 'order by vdtt.vdtt_id ';

      // ���������, ����� �� ���������� ������� ��������� � ���� �� ����������� �� ���������� ��������� ������
      if (dwMaxElementsReturned = 0) or (dwElementCount <= dwMaxElementsReturned) then begin
        // ���� ����� ������� ����� ��� �������� (��� ��� ����� ���������� �����������), ��� � ������
        pdwCount := dwElementCount;
        pbMoreElements := false;
      end else begin
        // ����� ����� ���������� ����������� ����������� ���������� ���������
        pdwCount := dwMaxElementsReturned;
        pbMoreElements := true;
      end;

      // ���� ������� ����� ������ ����� (�� ���������) ���������� ������ ������
      if (dwBrowseFilter = OPC_BROWSE_FILTER_BRANCHES) then begin
        pdwCount := 0;
        pbMoreElements := false;
      end;

      // ���� ���� ��������� ��������,...
      if pdwCount > 0 then begin
        // ... �������� ������ ��� �������� pdwCount ��������� ���� OPCBROWSEELEMENT
        ppBrowseElements := POPCBROWSEELEMENTARRAY(CoTaskMemAlloc(pdwCount * sizeof(OPCBROWSEELEMENT)));

        // ���� ������ �������� �� �������, ������� � �������
        if ppBrowseElements = nil then begin
          PostLogRecordAddMsgNow(70123, hr, -1, E_OUTOFMEMORY, '������ ������');
          pdwCount := 0;
          pbMoreElements := false;
          result := E_OUTOFMEMORY;
          exit;
        end;

        // ������� ������ ��������� ����� ��� ���������� ������� ����
        rdm.Lock;
        try
          dsTags := rdm.GetQueryDataset(
          'select vdtt.vdtt_id, vdtt.vdtt_tag, vdtt.vdtt_name, vdt.VDT_VAR_TYPE, ' +
          'vdtt.vdtt_eu_type, vdtt.vdtt_access_rights ' + sSQL
          );
          try
            // ����������� ������ ����� ...
            dsTags.Open;
            // �������� �� ���������� �������
            ElementIndex := 0;
            dsTags.First;

            while (not dsTags.Eof) and (ElementIndex < pdwCount) do begin

              // �������������� ��������� Item
              ppBrowseElements^[ElementIndex].szName := StringToOleStr(dsTags.FieldByName('vdtt_name').AsString);
              ppBrowseElements^[ElementIndex].szItemID := StringToOleStr(tagHostServer + '.' + tagHostServerDriver + '.' + tagDevice + '.' + dsTags.FieldByName('vdtt_tag').AsString);
              // ������ ������� �������� ��������� ������ � �� �������� ������
              ppBrowseElements^[ElementIndex].dwFlagValue := OPC_BROWSE_ISITEM;
              ppBrowseElements^[ElementIndex].dwReserved := 0;

              // ��������� ������ �� OPCITEMPROPERTIES
              pItemProps := @(ppBrowseElements^[ElementIndex].ItemProperties);
              // ��������� pItemProps
              result := FillPOPCITEMPROPERTIES(pItemProps, ppBrowseElements^[ElementIndex].szItemID, bReturnPropertyValues, dsTags);
              if result <> S_OK then begin
                PostLogRecordAddMsgNow(70124, hr, -1, result, '���������� �������');
                exit;
              end;
              // ��������� � ���������� ��������
              ElementIndex := Succ(ElementIndex);
              dsTags.Next;
            end;
            // ���� ������� �� ���, ���������� ContinuationPoint
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
      // ������ 5: ����� ���� ����������
      pdwCount := 0;
      pbMoreElements := false;
    end;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70117, result, -1, E_FAIL, '���������� �������: ' + e.Message);
    // � ������ �������������� ������ ...
    // ... ���� ������ ���� ��������, ����������� ��, ...
    if assigned(ppBrowseElements) then begin
      CoTaskMemFree(ppBrowseElements);
      ppBrowseElements := nil;
    end;
    // ... � ���������� E_FAIL
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
  TrItem : TVpNetDATransactionItem; // ����������
  TrItemIndex : Integer;
  TrItemList : TVpNetDATransactionItemList; // ������ ��������� ���������� ��� ������������� ����������(��������)
  TrItemListSet : TVpNetDATransactionItemListSet; // ��������� ������� ��������� ���������� ��� ������ ����������(���������)
  trItemListIndex : Integer; // ����� ������ ��������� ���������� �� ��������� �������
  CommonTrItemList : TVpNetDATransactionItemList; // ����� (��������) ������ ���������� �������
  ReferencedHstDriverIDs : TList; // ������ ��������������� ���������, �� ������� ���� ��������� ������
  ds : TDataSet;
  ft : TFileTime;
  DriverRefIndex : Integer;
  TID : DWORD;
  DeviceTypeId : DWORD;
  sq : String;
begin
  //----------------------------------------------------------------
  // ��������� ��������
  //----------------------------------------------------------------
  try
    PostLogRecordAddMsgNow(70795, -1, -1, S_OK, '����� ������', llDebug);
//    PostLogRecordAddMsgNow(70290, Integer(ServerCore.State), -1, -1, 'Ok. TVpNetOPCDA.Read(...)');

    ppvValues := nil;
    ppwQualities := nil;
    ppftTimeStamps := nil;
    ppErrors := nil;

    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70126, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������');
      result := E_FAIL;
      exit;
    end;

    // ���� �� ������� ���������� ���� ������, ������� � E_INVALIDARG
    if dwCount = 0 then begin
      PostLogRecordAddMsgNow(70127, -1, -1, E_INVALIDARG, '���������� �������');
      result := E_INVALIDARG;
      exit;
    end;

    if not assigned(pszItemIDs) then begin
      PostLogRecordAddMsgNow(70128, -1, -1, E_INVALIDARG, '���������� �������');
      result := E_INVALIDARG;
      exit;
    end;

    if not assigned(pdwMaxAge) then begin
      PostLogRecordAddMsgNow(70129, -1, -1, E_INVALIDARG, '���������� �������');
      result := E_INVALIDARG;
      exit;
    end;

    // �������� ������ ��� ������ ��������������� ���������,
    // �� ������� ���� ��������� ������
    ReferencedHstDriverIDs := TList.Create;
    // �������� ������� ��������� ������� ���������� ��� ������ ����������(���������)
    TrItemListSet := TVpNetDATransactionItemListSet.Create;
    // �������� ������ (����������) ������ ����������
    CommonTrItemList := TVpNetDATransactionItemList.Create;

    try
      // �������� ������ ��� �������� ���������
      ppvValues := POleVariantArray(CoTaskMemAlloc(dwCount * sizeof(OleVariant)));
      ItemIndex := 0;
      while ItemIndex < dwCount do begin
        VariantInit(ppvValues^[ItemIndex]);
        ItemIndex := Succ(ItemIndex);
      end;

      ppwQualities := PWordArray(CoTaskMemAlloc(dwCount * sizeof(Word)));
      ppftTimeStamps := PFileTimeArray(CoTaskMemAlloc(dwCount * sizeof(TFileTime)));
      ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));

      // �������� ������������� ����������
      TID := ServerCore.GetNewTID;

      //----------------------------------------------------------------
      // �������� �� ���������, � ��������� ���������� �������� ��� ��������� �����
      //----------------------------------------------------------------
      ItemIndex := 0;
      dwErrorCount := 0;
      while ItemIndex < dwCount do begin

        // �������� ���������� ��������:
        // ���������� �������� �������� ���������� ��� ������� �������� �� ����������
        ppvValues^[ItemIndex] := null;
        ppwQualities^[ItemIndex] := OPC_QUALITY_BAD;
        CoFileTimeNow(ft); // ������� ����� � ������� _FILETIME
        LocalFileTimeToFileTime(ft, ft); // ������� �������� ���������� ������� � UTC
        ppftTimeStamps^[ItemIndex] := ft; // ���������� ���
        ppErrors^[ItemIndex] := E_FAIL;

        // ��������� "�����" ��� ���������� � ����� (��������) ������ ����������
        CommonTrItemList.Add(nil);

        // ������ ItemID � ���������:
        // �������������� ����-������� (dwHostServerID);
        // �������������� �������� ����-������� (dwHostServerDriverID);
        // �������������� ���������� (dwDeviceID);
        // �������������� ���� ���������� ������� ���� (dwDeviceTypeTagID)
        sItemId := pszItemIDs^[ItemIndex];
        // !!!(��������� � ��) !!!
        hr := rdm.SplitItemID(sItemId, dwHostServerID, dwHostServerDriverID, dwDeviceID, dwDeviceTypeTagID);

        // ������ ������� ItemID. �������� ������� ������ � �������� �������
        if hr <> S_OK then begin
          PostLogRecordAddMsgNow(70291, Integer(ServerCore.State), -1, hr, '');
          ppwQualities^[ItemIndex] := OPC_QUALITY_BAD;
          ppErrors^[ItemIndex] := hr; // �������� ��� ������
          dwErrorCount := Succ(dwErrorCount); // ����������� ���������� ��������� � ��������
          ItemIndex := Succ(ItemIndex); // ��������� � ���������� ��������
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
          ppErrors^[ItemIndex] := hr; // �������� ��� ������
          dwErrorCount := Succ(dwErrorCount); // ����������� ���������� ��������� � ��������
          ItemIndex := Succ(ItemIndex); // ��������� � ���������� ��������
          continue;
        end;


        if (DeviceTypeId > 0) and not(DeviceTypeId = 2050) then begin
          ppwQualities^[ItemIndex] := OPC_QUALITY_BAD;
          ppErrors^[ItemIndex] := hr; // �������� ��� ������
          dwErrorCount := Succ(dwErrorCount); // ����������� ���������� ��������� � ��������
          ItemIndex := Succ(ItemIndex); // ��������� � ���������� ��������
          continue;
        end;
        {$ifend}
///01.03.2010

        // ���� ������ �� ������ ������� ��� �� ���������, ...
        if ReferencedHstDriverIDs.IndexOf(Pointer(dwHostServerDriverID)) = -1 then begin
          // �������� ������� �� ���������� ������ �� ������� Host-�������,
          // � �������� ���������� �������
          hr := SendMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_REF, dwHostServerDriverID, 0);
          if (hr = S_OK) then begin
            // ���� ������� �������� ������ �� �� ������� Host-�������,
            // ���������� ������������� �������� ��� ������������ �������� ������
            ReferencedHstDriverIDs.Add(Pointer(dwHostServerDriverID));
          end else begin
            PostLogRecordAddMsgNow(70293, DeviceTypeId, -1, -1, '');
            // ���� �� ������� �������� ������ �� ������� Host-�������,
            // ���������� ������ ��� ������� ��������
            ppErrors^[ItemIndex] := hr; // �������� ��� ������
            dwErrorCount := Succ(dwErrorCount); // ����������� ���������� ��������� � ��������
            ItemIndex := Succ(ItemIndex); // ��������� � ���������� ��������
            continue;
          end;
        end;

        // ������� ��������� ���������� DA-�������
        TrItem := TVpNetDATransactionItem.Create(nil, TID);
        // ������ ItemId DA-����������
        TrItem.DA_ItemId := sItemId;
        // ���������� ������������� �������� ������
        TrItem.DA_hClient := 0; // �����������
        // ��������� ����������� ��������� �������� ��� ������� ��������
        TrItem.DA_MaxAge := pdwMaxAge^[ItemIndex];
        // ��������� ����� ������� ������ ������� ����� ����� �������� �����
        {26.09.2007}
        //todo: ���������, ������������� �� ����� ����� �������� TrItem.DA_MaxAge
        // �� ����� Hst-�������?
        {/26.09.2007}
        TrItem.DA_MaxResponseMoment := FileTimePlusMS(TrItem.DA_CreationMoment, TrItem.DA_MaxAge);

        // ��� DA-���������� - ������
        TrItem.DA_Type := vndttRead;
        // ��� ������������� DA-���������� - Sync
        TrItem.DA_SyncType := vndtstSync;

        // ��������� ����������� � Hst-�������
        TrItem.Hst_ID := dwHostServerID;
        TrItem.Hst_DriverID := dwHostServerDriverID;
        TrItem.Hst_DeviceId := dwDeviceID;
        TrItem.Hst_DeviceTypeTagId := dwDeviceTypeTagID;

        // ���� ����������� ������ � ��������� ��������, ������ ��������� ���������� ��������
        if not(dwDeviceID = 0) then begin
          // �������� ����� ������� � ���� (����) ��������
          try
            // !!!(��������� � ��) !!!
            TrItem.Hst_DeviceAddress := rdm.GetOneCell('select vd_addr from vda_devices where vd_id = ' + rdm.IntToSQL(TrItem.Hst_DeviceId, IntToStr(HIGH(Integer))));
          except
            PostLogRecordAddMsgNow(70299, Integer(ServerCore.State), -1, -1, '');
            TrItem.Hst_DeviceAddress := HIGH(DWORD);
          end;

          // ����������� �������������� ������ �� Item-� � ���� ������
          // !!!(��������� � ��) !!!
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
                // ��������� ������
                ds.Open;
                // ������������ ��������� ������
                if ds.eof or
                   ds.FieldByName('vp_id').IsNull or
                   ds.FieldByName('func_number').IsNull or
                   ds.FieldByName('data_address').IsNull or
                   ds.FieldByName('access_rights').IsNull or
                   ds.FieldByName('access_rights').IsNull or
                   (TrItem.Hst_DeviceAddress = DWORD(high(Integer)))
                then begin
                  PostLogRecordAddMsgNow(70294, DeviceTypeId, -1, -1, '');
                  TrItem.Free; // ��� ��� �� ������� �������� ��� �������� ����������� ������� ��
                  ppErrors^[ItemIndex] := OPC_E_UNKNOWNITEMID;
                  dwErrorCount := Succ(dwErrorCount);
                  ItemIndex := Succ(ItemIndex);
                  continue;
                end;

                // ���������� ������������� ���������
                TrItem.Hst_ProtocolId := ds.FieldByName('vp_id').AsVariant;
                // ���������� ����� ������� ���������
                TrItem.Hst_FuncNumber := ds.FieldByName('func_number').AsVariant;
                // ���������� ����� ������
                TrItem.Hst_DataAddress := DWORD(ds.FieldByName('data_address').AsInteger);
                // ���������� ����� ������� � ��������
                TrItem.Hst_AccessRights := DWORD(ds.FieldByName('access_rights').AsInteger);
                // ���������� ������ ���� ������ � ������
                TrItem.Hst_DataSizeInBytes := ds.FieldByName('vdt_size_in_bytes').AsInteger;
                // ������������� ������� ������������� ������ � ������
                TrItem.Hst_DataFormatId := ds.FieldByName('vdf_id').AsInteger;

              except
                PostLogRecordAddMsgNow(70130, -1, -1, E_FAIL, '���������� �������');
                TrItem.Free; // ��� ��� �� ������� �������� ��� �������� ����������� ������� ��
                ppErrors^[ItemIndex] := E_FAIL; // �������������� ������
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
          // ���� ����������� ������ � ��������� ��������, ...
          TrItem.Hst_DeviceAddress := 1;
          // ������������� ��������������� ��� ���������
          TrItem.Hst_ProtocolId := VPHstDriverInterface;
          // ����� ������� �� ������������ (������������� = 0)
          TrItem.Hst_FuncNumber := 0;
          // ���������� ����� ������
          TrItem.Hst_DataAddress := 0;
          // ���������� ����� ������� � ��������
          // todo: ���� ����� �������� ����� ������� � ��������� ��������
          TrItem.Hst_AccessRights := OPC_READABLE + OPC_WRITEABLE;
          // �� ������������ (������������� = 0)
          TrItem.Hst_DataSizeInBytes := 0;
          // �� ������������ (������������� = VDF_DRECT)
          TrItem.Hst_DataFormatId := VDF_DRECT;

        end;
{/19.06.2007}

        // ��������� ���������� � ����� (��������) ������ ���������� �� ������� �������������� �����
        CommonTrItemList[CommonTrItemList.Count - 1] := TrItem;

        // ���� ��������� ������ ���������� ��� ������� ����������(��������)
        TrItemList := TrItemListSet.FindByDriverId(TrItem.Hst_DriverID);
        // ���� ������ ��� ��� ������� ����������(��������) ��� �� ������,
        // ������� ���, � ��������� �� ��������� ������� ����������
        if not assigned(TrItemList) then begin
//          TrItemList := TVpNetDATransactionItemList.Create(TrItem.Hst_DriverID);
          TrItemList := TVpNetDATransactionItemList.Create;
          TrItemListSet.Add(TrItemList);
        end;

        // ��������� ���������� � ������ ���������� ��� ������� ����������(��������)
        TrItemList.Add(TrItem);

        // ������� � ���������� ��������
        ItemIndex := Succ(ItemIndex);
      end;

      //----------------------------------------------------------------
      // �������� ������� ���������� �����������(���������) ��� ����������
      //----------------------------------------------------------------
      trItemListIndex := 0;
      while trItemListIndex < TrItemListSet.Count do begin

        // �������� ��������� �� ������� ���������� ���������� ����������(��������)
        SendMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_TRANSACTIONS,
          // ������������� �������� Hst-�������
          // (������������, ��� ������ ���������� �� Hst_DriverId);
          TrItemListSet[trItemListIndex].FirstTrItemDriverId,
          // ������ ����������
          Integer(Pointer(TrItemListSet[trItemListIndex])),
        );
        // ������� � ���������� ������
        trItemListIndex := Succ(trItemListIndex);
      end;

      //----------------------------------------------------------------
      // �������� ���������� ���� ������������ ���������� �� ���� �����������(���������)
      //----------------------------------------------------------------
      TrItemIndex := 0;
      while TrItemIndex < CommonTrItemList.Count do begin
        // ���� ��� ������� �������� ������� ���������� ������ ���
        if (CommonTrItemList[TrItemIndex] = nil)then begin
          // ...��������� � ��������� ����������
          PostLogRecordAddMsgNow(70658, TrItemIndex, -1, -1, '');
          TrItemIndex := Succ(TrItemIndex);
          Continue;
        end;

        // ��� ��������� ���������� ��������� ...
        if (CommonTrItemList[TrItemIndex].DA_State = vndtsComplete) then begin
          // ...��������� � ��������� ����������
          PostLogRecordAddMsgNow(70659, TrItemIndex, -1, -1, 'Ok. Item... vndtsComplete');
          TrItemIndex := Succ(TrItemIndex);
          Continue;
        end;

{28.06.2007}
{ TODO :
������ �������� �������� DA-����������.
�������: �������� �� �������������� DriverConnection }

        CoFileTimeNow(ft); // ���� �������� ����������
        LocalFileTimeToFileTime(ft, ft); // ��������� ��������� ����/����� � UTC

        TrItem := CommonTrItemList[TrItemIndex];
        if
          assigned(TrItem) and
          (ft.dwHighDateTime > TrItem.DA_MaxResponseMoment.dwHighDateTime)
        then begin
          // ...��������� � ��������� ����������
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
          // ...��������� � ��������� ����������
          PostLogRecordAddMsgNow(70660, Integer(ServerCore.State), -1, -1, '��������� ���� ����� ������ ��� �������� '+TrItem.DA_ItemId);
          CommonTrItemList[TrItemIndex].DA_State := vndtsComplete;
          TrItemIndex := Succ(TrItemIndex);
          Continue;
        end;
{/28.06.2007}

        Sleep(1);
        Application.ProcessMessages;
      end;

      //������� ��������� ������� ���������� (�� �� ���� ����������)
      // (��������� ������ ���������� ��� �� �����, ��� ��� ��� ���������� ���� �
      // ����� (��������) ������ ����������)
      TrItemListSet.DestroyTransactionItemLists;

      //----------------------------------------------------------------
      // ������ �� ������ ���������� � ���������� �������� ��������
      //----------------------------------------------------------------
      ItemIndex := 0;
      dwErrorCount := 0;
      // �������� �� ����� �������
      while ItemIndex < dwCount do begin
        // ����� ��������� ���������� �� ������
        TrItem := CommonTrItemList[ItemIndex];
        if assigned(TrItem) then begin
          // ���� �� ���� ����� ���� ����������, �������������� ��������
          // �������� �������� ���������� �� ����������
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
          // ���� �� ���� ����� ��� ����������, �������������� ��������
          // �������� �������� ��� ������ ���������� ��� ���������
          ppErrors^[ItemIndex] := E_FAIL; // �������������� ������
          dwErrorCount := Succ(dwErrorCount); // ����������� ������� ������
        end;

        // ������� � ���������� ��������
        ItemIndex := Succ(ItemIndex);
      end;

      // ������� ��� ���������� � ����� (��������) ������ ����������
      CommonTrItemList.DestroyTransactionItems;

      //----------------------------------------------------------------
      // ����������� ��������
      //----------------------------------------------------------------
    finally
      // ������� ������ �� ������� Host-�������
      DriverRefIndex := 0;
      while DriverRefIndex < ReferencedHstDriverIDs.Count do begin
        // ��������� ������� �� ��������� ������ ��������� ������� Host-�������
        // � �������� ���������� �������
        Application.ProcessMessages; //???
        SendMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_RELEASE, DWORD(ReferencedHstDriverIDs[DriverRefIndex]), 0);
        // ��������� � �������������� ���������� �������� Host-�������
        DriverRefIndex := Succ(DriverRefIndex);
      end;

      // �������� ������ (����������) ������ ����������
      if assigned(CommonTrItemList) then
        CommonTrItemList.Free;

      // �������� ��������� ������� ���������� ��� ������ ����������(���������)
      if assigned(TrItemListSet) then
        TrItemListSet.Free;

      // ������� ������ ��������������� ���������, �� ������� ���� ��������� ������
      if assigned(ReferencedHstDriverIDs) then
        ReferencedHstDriverIDs.Free;
    end;

    if dwErrorCount = 0 then
      result := S_OK
    else
      result := S_FALSE;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70125, hr, -1, E_FAIL, '���������� �������: '+ e.Message);
    // ���� ������� ��������, ������� �������� ���������
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
  ReferencedHstDriverIDs : TList; // ������ ��������������� ���������, �� ������� ���� ��������� ������
  TrItemListSet : TVpNetDATransactionItemListSet; // ��������� ������� ��������� ���������� ��� ������ ����������(���������)
  CommonTrItemList : TVpNetDATransactionItemList; // ����� (��������) ������ ��������� ���������� �������
  TrItemListIndex : Integer; // ����� ������ ��������� ���������� �� ��������� �������
  TrItemList : TVpNetDATransactionItemList; // ������ ��������� ���������� ��� ������������� ����������(��������)
  TrItemIndex : Integer; // ����� �������� DA-���������� � ������
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
    PostLogRecordAddMsgNow(70796, -1, -1, S_OK, '����� ������', llDebug);
    ppErrors := nil;
{09.07.2006}
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70020, -1, -1, E_FAIL, '���������� ������� (ServerCore.State='+IntToStr(Integer(ServerCore.State))+')');
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // ���� �� ������� ���������� ���� ������, ������� � E_INVALIDARG
    if dwCount = 0 then begin
      PostLogRecordAddMsgNow(70021, -1, -1, E_FAIL, '�������� ���������� ����� (dwCount = 0)');
      result := E_INVALIDARG;
      exit;
    end;

    // ���� �� ������� ���������� ���� ������, ������� � E_INVALIDARG
    if not assigned(pszItemIDs) then begin
      PostLogRecordAddMsgNow(70045, -1, -1, E_FAIL, '�������� ������ �����');
      result := E_INVALIDARG;
      exit;
    end;

    // ���� �� ������� ���������� ���� ������, ������� � E_INVALIDARG
    if not assigned(pItemVQT) then begin
      PostLogRecordAddMsgNow(70046, -1, -1, E_FAIL, '�������� ������ VQT');
      result := E_INVALIDARG;
      exit;
    end;

    // �������� ������ ��� ������ ��������������� ���������,
    // �� ������� ���� ��������� ������
    ReferencedHstDriverIDs := TList.Create;
    // �������� ������� ��������� ������� ���������� ��� ������ ����������(���������)
    TrItemListSet := TVpNetDATransactionItemListSet.Create;
    // �������� ������ (����������) ������ ����������
    CommonTrItemList := TVpNetDATransactionItemList.Create;

    // �������� ������������� ����������
    TID := ServerCore.GetNewTID;

    try
      // �������� ������ ��� ������� ����������� �� ���������
      ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)));
      //----------------------------------------------------------------
      // �������� �� ���������, � ��������� ���������� ������ ��������� �����
      //----------------------------------------------------------------
      ItemIndex := 0;
      dwErrorCount := 0;
      while (ItemIndex < dwCount) do begin

        // �������� ���������� ����:
        // ���������� �������� ���������� ��� ���� - E_FAIL
        ppErrors^[ItemIndex] := E_FAIL;

        // ��������� "�����" ��� ���������� � ����� (��������) ������ ����������
        CommonTrItemList.Add(nil);

        // ������ ItemID � ���������:
        // �������������� ����-������� (dwHostServerID);
        // �������������� �������� ����-������� (dwHostServerDriverID);
        // �������������� ���������� (dwDeviceID);
        // �������������� ���� ���������� ������� ���� (dwDeviceTypeTagID)
        sItemId := pszItemIDs^[ItemIndex];
        hr := rdm.SplitItemID(sItemId, dwHostServerID, dwHostServerDriverID, dwDeviceID, dwDeviceTypeTagID);

        // ������ ������� ItemID. �������� ������� ������ � �������� �������
        if hr <> S_OK then begin
          ItemIndex := Succ(ItemIndex); // ��������� � ���������� ��������
          continue;
        end;

        // ���� ������ �� ������ ������� ��� �� ���������, ...
        if ReferencedHstDriverIDs.IndexOf(Pointer(dwHostServerDriverID)) = -1 then begin
          // �������� ������� �� ���������� ������ �� ������� Host-�������,
          // � �������� ���������� �������
          hr := SendMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_REF, dwHostServerDriverID, 0);
          if (hr = S_OK) then begin
            // ���� ������� �������� ������ �� �� ������� Host-�������,
            // ���������� ������������� �������� ��� ������������ �������� ������
            ReferencedHstDriverIDs.Add(Pointer(dwHostServerDriverID));
          end else begin
            // ���� �� ������� �������� ������ �� ������� Host-�������,
            // ���������� ������ ��� ������� ��������
            ppErrors^[ItemIndex] := hr; // �������� ��� ������
            dwErrorCount := Succ(dwErrorCount); // ����������� ���������� ��������� � ��������
            ItemIndex := Succ(ItemIndex); // ��������� � ���������� ��������
            continue;
          end;
        end;

        // ������� ��������� ���������� DA-�������
        TrItem := TVpNetDATransactionItem.Create(nil, TID);
        // ���������� ������������� �������� ������
        TrItem.DA_hClient := 0; // �����������
        // ������ ItemId DA-����������
        TrItem.DA_ItemId := sItemId;
        // ����������� ��������� �������� ��� ������� �������� ������������� ������ 0
        // ����� ������� ������ ��������� ������ ��� �������
        TrItem.DA_MaxAge := 0;
        // ��������� ����� ������� ������ ������� ����� ����� �������� �����
        TrItem.DA_MaxResponseMoment := TrItem.DA_CreationMoment;

        // ��� DA-���������� - ������
        TrItem.DA_Type := vndttWrite;
        // ��� ������������� DA-���������� - Sync
        TrItem.DA_SyncType := vndtstSync;

        // ������ ������ DA-����������
        TrItem.VQT := pItemVQT^[ItemIndex];

        // ��������� ����������� � Hst-�������
        TrItem.Hst_ID := dwHostServerID;
        TrItem.Hst_DriverID := dwHostServerDriverID;
        TrItem.Hst_DeviceId := dwDeviceID;
        TrItem.Hst_DeviceTypeTagId := dwDeviceTypeTagID;

{21.06.2007}
        // ���� ����������� ������ � ��������� ��������, ������ ��������� �� �����
        if not(dwDeviceID = 0) then begin
{/21.06.2007}

          // �������� ����� ������� � ���� (����) ��������
          try
            TrItem.Hst_DeviceAddress := rdm.GetOneCell('select vd_addr from vda_devices where vd_id = ' + rdm.IntToSQL(TrItem.Hst_DeviceId, IntToStr(HIGH(Integer))));
          except on e : Exception do begin
            PostLogRecordAddMsgNow(70022, -1, -1, E_FAIL, '���������� �������: '+e.Message);
            TrItem.Hst_DeviceAddress := HIGH(DWORD);
          end;
          end;

          // ����������� �������������� ������ �� Item-� � ���� ������
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
                // ��������� ������
                ds.Open;
                // ������������ ��������� ������
                if ds.eof or
                   ds.FieldByName('vp_id').IsNull or
                   ds.FieldByName('func_number').IsNull or
                   ds.FieldByName('data_address').IsNull or
                   ds.FieldByName('access_rights').IsNull or
                   ds.FieldByName('access_rights').IsNull or
                   (TrItem.Hst_DeviceAddress = DWORD(high(Integer)))
                then begin
                  TrItem.Free; // ��� ��� �� ������� �������� ��� �������� ����������� ������� ��
                  ppErrors^[ItemIndex] := OPC_E_UNKNOWNITEMID;
                  dwErrorCount := Succ(dwErrorCount);
                  ItemIndex := Succ(ItemIndex);
                  continue;
                end;

                // ���������� ������������� ���������
                TrItem.Hst_ProtocolId := ds.FieldByName('vp_id').AsVariant;
                // ���������� ����� ������� ���������
                TrItem.Hst_FuncNumber := ds.FieldByName('func_number').AsVariant;
                // ���������� ����� ������
                TrItem.Hst_DataAddress := DWORD(ds.FieldByName('data_address').AsInteger);
                // ���������� ����� ������� � ��������
                TrItem.Hst_AccessRights := DWORD(ds.FieldByName('access_rights').AsInteger);
                // ���������� ������ ���� ������ � ������
                TrItem.Hst_DataSizeInBytes := ds.FieldByName('vdt_size_in_bytes').AsInteger;
                // ������������� ������� ������������� ������ � ������
                TrItem.Hst_DataFormatId := ds.FieldByName('vdf_id').AsInteger;

              except on e : Exception do begin
                PostLogRecordAddMsgNow(70023, -1, -1, E_FAIL, '���������� �������: '+e.Message);
                TrItem.Free; // ��� ��� �� ������� �������� ��� �������� ����������� ������� ��
                ppErrors^[ItemIndex] := E_FAIL; // �������������� ������
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

        // ��������� ���������� � ����� (��������) ������ ���������� �� ������� �������������� �����
        CommonTrItemList[CommonTrItemList.Count - 1] := TrItem;

        // ���� ��������� ������ ���������� ��� ������� ����������(��������)
        TrItemList := TrItemListSet.FindByDriverId(TrItem.Hst_DriverID);
        // ���� ������ ��� ��� ������� ����������(��������) ��� �� ������,
        // ������� ���, � ��������� �� ��������� ������� ����������
        if not assigned(TrItemList) then begin
//          TrItemList := TVpNetDATransactionItemList.Create(TrItem.Hst_DriverID);
          TrItemList := TVpNetDATransactionItemList.Create;
          TrItemListSet.Add(TrItemList);
        end;

        // ��������� ���������� � ������ ���������� ��� ������� ����������(��������)
        TrItemList.Add(TrItem);

        // ������� � ���������� ��������
        ItemIndex := Succ(ItemIndex);
      end;

      //----------------------------------------------------------------
      // �������� ������� ���������� �����������(���������) ��� ����������
      //----------------------------------------------------------------
      TrItemListIndex := 0;
      while (TrItemListIndex < TrItemListSet.Count) do begin

        // �������� ��������� �� ������� ���������� ���������� ����������(��������)
        PostMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_ADD_TRANSACTIONS,
          // ������������� �������� Hst-�������
          // (������������, ��� ������ ���������� �� Hst_DriverId);
          TrItemListSet[trItemListIndex].FirstTrItemDriverId,
          Integer(Pointer(TrItemListSet[TrItemListIndex])), // ������ ����������
        );
        // ������� � ���������� ������
        TrItemListIndex := Succ(TrItemListIndex);
      end;

      //----------------------------------------------------------------
      // �������� ���������� ���� ������������ ���������� �� ���� �����������(���������)
      //----------------------------------------------------------------
      //todo: ����� ����� ������������ ���������� ���������
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
        if (CommonTrItemList[TrItemIndex] = nil) or // ���� ��� ������� �������� ������� ���������� ������ ���
           (CommonTrItemList[TrItemIndex].DA_State = vndtsComplete) // ��� ��������� ���������� ��������� ...
        then begin
          // ...��������� � ��������� ����������
          TrItemIndex := Succ(TrItemIndex);
          Continue;
        end;
        Sleep(1);
        Application.ProcessMessages;
      end;

      //������� ��������� ������� ���������� (�� �� ���� ����������)
      // (��������� ������ ���������� ��� �� �����, ��� ��� ��� ���������� ���� �
      // ����� (��������) ������ ����������)
      TrItemListSet.DestroyTransactionItemLists;

      //----------------------------------------------------------------
      // ������ �� ������ ���������� � ���������� �����������
      //----------------------------------------------------------------
      ItemIndex := 0;
      dwErrorCount := 0;
      // �������� �� ����� �������
      while (ItemIndex < dwCount) do begin
        // ����� ��������� ���������� �� ������
        TrItem := CommonTrItemList[ItemIndex];
        if assigned(TrItem) then begin
          // ���� �� ���� ����� ���� ����������, ��������� ������� ��������� �������
          // ����������� ���������� ���������� ��������� �� ����������
          ppErrors^[ItemIndex] := TrItem.DA_Result;
        end else begin
          // ���� �� ���� ����� ��� ����������, �������� � ������� ��������� �������
          // ����������� ���������� ���������� E_FAIL
          ppErrors^[ItemIndex] := E_FAIL; // �������������� ������
          PostLogRecordAddMsgNow(70024, -1, -1, E_FAIL, '���������� �������');
          dwErrorCount := Succ(dwErrorCount); // ����������� ������� ������
        end;

        // ������� � ���������� ��������
        ItemIndex := Succ(ItemIndex);
      end;

      // ������� ��� ���������� � ����� (��������) ������ ����������
      CommonTrItemList.DestroyTransactionItems;

      //----------------------------------------------------------------
      // ����������� ��������
      //----------------------------------------------------------------
    finally
      // ������� ������ �� ������� Host-�������
      DriverRefIndex := 0;
      while (DriverRefIndex < ReferencedHstDriverIDs.Count) do begin
        // ��������� ������� �� ��������� ������ ��������� ������� Host-�������
        // � �������� ���������� �������
        Application.ProcessMessages; //???
        SendMessage(Application.MainForm.Handle, CM_DA_HST_DRIVER_RELEASE, DWORD(ReferencedHstDriverIDs[DriverRefIndex]), 0);
        // ��������� � �������������� ���������� �������� Host-�������
        DriverRefIndex := Succ(DriverRefIndex);
      end;

      // �������� ������ (����������) ������ ����������
      if assigned(CommonTrItemList) then
        CommonTrItemList.Free;

      // �������� ��������� ������� ���������� ��� ������ ����������(���������)
      if assigned(TrItemListSet) then
        TrItemListSet.Free;

      // ������� ������ ��������������� ���������, �� ������� ���� ��������� ������
      if assigned(ReferencedHstDriverIDs) then
        ReferencedHstDriverIDs.Free;

    end;

    if dwErrorCount = 0 then
      result := S_OK
    else begin
      PostLogRecordAddMsgNow(70025, dwErrorCount, -1, E_FAIL, '���������� �������');
      result := S_FALSE;
    end;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70026, -1, -1, E_FAIL, '���������� �������');
    // ���� ������� ��������, ������� �������� ���������
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
  tagHostServer : DWORD; // ��� ����-�������
  tagHostServerDriver : DWORD; // ��� �������� ����-�������
  tagDevice : DWORD; // ��� ����������
  tagDeviceTypeTag : DWORD; // ��� ���� ���� ���������� :)
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
    PostLogRecordAddMsgNow(70797, -1, -1, S_OK, '����� ������', llDebug);
    // ������������� ����������
    pdwCount := 0;
    ppPropertyIDs := nil;
    ppDescriptions := nil;
    ppvtDataTypes := nil;
    result := E_FAIL;

{09.07.2006}
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70132, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������');
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // ��������� szItemId
    //todo: �������� ��� ���������� ������� SplitItemID() � String �� POleStr
    result := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag);
    // ���� ���� ������� �������, ���������� ���������� ������
    if result <> S_OK then begin
      PostLogRecordAddMsgNow(70132, -1, -1, result, '���������� �������');
      exit;
    end;

    // ������� ��������� �������
    lPropertyIDs := TList.Create;
    slDescriptions := TStringList.Create;
    lDataTypes := TList.Create;
    // ����������� �������� ����
    rdm.Lock;
    try
      dsTagProperties := rdm.GetQueryDataset('select * from vn_tag_property_ids vtpi');
      try
        // ������ �� ���� ��������� ��������� �����
        dsTagProperties.Open;
        dsTagProperties.First;
        while not dsTagProperties.Eof do try
          // �������� ������ valid-����� ������� �������� ����
          hr := GetPropertyValidStatus(tagDeviceTypeTag, dsTagProperties.FieldByName('vtpi_property_id').AsInteger, wValidStatus);
          // ��������� ���������� ���������� ��������
          if hr <> S_OK then
            Continue; // ��� ������ ��������� � ���������� ��������
          // ��������� ����������� ��������
          if wValidStatus < 1 then
            Continue; // ���� �������� ����������, ��������� � ���������� ��������

          // �������� ��� ������
          v := rdm.GetOneCell('select vdt_var_type from VN_DATATYPES VDT where VDT.VDT_ID = ' + IntToStr(dsTagProperties.FieldByName('vdt_id').AsInteger));
          if not VarIsOrdinal(v) then
            Continue; // ��� ������ ��������� � ���������� ��������
          VDT_VAR_TYPE := v;

          // ���� ��� �������� �������� ������� ��� � ������
          if v >= 1 then begin
            lPropertyIDs.Add(Pointer(dsTagProperties.FieldByName('VTPI_PROPERTY_ID').AsInteger));
            slDescriptions.Add(dsTagProperties.FieldByName('VTPI_TEXT').AsString);
            lDataTypes.Add(Pointer(VDT_VAR_TYPE));
          end;

        finally
          dsTagProperties.Next;
        end;

        // ���������� �������� ��������
        pdwCount := lPropertyIDs.Count;
        // ���� ���������� �������� ���� �������, ���������� ��, ����� ���������� ������ ������
        if pdwCount > 0 then begin
          ppPropertyIDs := CoTaskMemAlloc(pdwCount * sizeof(DWORD));
          ppDescriptions := CoTaskMemAlloc(pdwCount * sizeof(POleStr));
          ppvtDataTypes := CoTaskMemAlloc(pdwCount * sizeof(TVarType));
          // ��������� ��������� ������
          if not(assigned(ppPropertyIDs)) or
          not(assigned(ppDescriptions)) or
          not(assigned(ppvtDataTypes)) then begin
            PostLogRecordAddMsgNow(70133, -1, -1, result, '������ ������');
            result := E_OUTOFMEMORY;
            raise EOutOfMemory.Create('OutOfMemory');
          end;

          Index := 0;
          while Index < lPropertyIDs.Count do begin
            ppPropertyIDs^[Index] := DWORD(lPropertyIDs[Index]);
            result := VpStringToLPOLESTR(slDescriptions[Index], ppDescriptions^[Index]);
            if result <> S_OK then begin
              PostLogRecordAddMsgNow(70134, -1, -1, result, '���������� �������');
              exit;
            end;
            ppvtDataTypes^[Index] := TVarType(Integer(lDataTypes[Index]));
            Index := Succ(Index);
          end;
        end;
      finally
        dsTagProperties.Free;
        // ������� ��������� �������
        lPropertyIDs.Free;
        slDescriptions.Free;
        lDataTypes.Free;
      end;
    finally
      rdm.Unlock;
    end;
    result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70131, -1, -1, result, '���������� �������: ' + e.Message);
    // ���� ������� ��������, ������� �������� ���������
    if assigned(ppPropertyIDs) then begin
      CoTaskMemFree(ppPropertyIDs);
      ppPropertyIDs := nil;
    end;

    if Assigned(ppDescriptions) then begin
      // ����������� ������, ���������� ��� �������� �������
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
  tagHostServer : DWORD; // ��� ����-�������
  tagHostServerDriver : DWORD; // ��� �������� ����-�������
  tagDevice : DWORD; // ��� ����������
  tagDeviceTypeTag : DWORD; // ��� ���� ���� ���������� :)
  dsValuesQuery : TDataSet;
  PropertyIndex : DWORD;
  v : Variant;
  vt : WORD;
begin
  try
    PostLogRecordAddMsgNow(70798, -1, -1, S_OK, '����� ������ GetItemProperties(...)', llDebug);
    ppvData := nil;
    ppErrors := nil;
    result := E_FAIL;

{09.07.2006}
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70136, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������');
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // ��������� szItemId
    //todo: �������� ��� ���������� ������� SplitItemID() � String �� POleStr
    result := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag);
    // ���� ���� ������� �������, ���������� ���������� ������
    if result <> S_OK then begin
      PostLogRecordAddMsgNow(70137, -1, -1, result, '���������� �������');
      exit;
    end;

    // ��������� ������ ��� �������� �������
    if dwCount > 0 then begin
      ppvData := POleVariantArray(CoTaskMemAlloc(dwCount * sizeof(OleVariant)));
      ppErrors := PResultList(CoTaskMemAlloc(dwCount * sizeof(HRESULT)))
    end;

    // �������� ��������� ������ ��� �������� �������
    if not(assigned(ppvData)) or not(assigned(ppErrors)) then begin
      PostLogRecordAddMsgNow(70138, -1, -1, result, '���������� �������');
      result := E_OUTOFMEMORY;
      raise EOutOfMemory.Create('OutOfMemory');
    end;

    // ������ �� ������ �������
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
          //todo: ��������� ����������� �������� �� ������� vn_valid_tag_properties
          // ��������� ������ �������� ��������� ����
          dsValuesQuery.Open;

          VariantInit(ppvData^[PropertyIndex]);
          // ��������� ������� �������� � ���� ������
          if not(dsValuesQuery.Eof) and
          not(dsValuesQuery.FieldByName('vtp_value').IsNull) and
          not(dsValuesQuery.FieldByName('vdt_var_type').IsNull) then begin
            // ���� �������� � ��� ������
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
            // �� ��������
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
    PostLogRecordAddMsgNow(70135, -1, -1, result, '���������� �������: ' + e.Message);

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
  tagHostServer : DWORD; // ��� ����-�������
  tagHostServerDriver : DWORD; // ��� �������� ����-�������
  tagDevice : DWORD; // ��� ����������
  tagDeviceTypeTag : DWORD; // ��� ���� ���� ���������� :)
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
    PostLogRecordAddMsgNow(70799, -1, -1, S_OK, '����� ������', llDebug);
    ppszNewItemIDs := nil;
    ppErrors := nil;
    result := E_FAIL;

{09.07.2006}
    // ��������� ��������� �������, � ���� ������ ��������� � ��������� ���������,
    // ������ �� ������ � ���������� ������
    if not(ServerCore.State = vndsWorking) then begin
      PostLogRecordAddMsgNow(70140, Integer(ServerCore.State), -1, E_FAIL, '�������� ��������� �������');
      result := E_FAIL;
      exit;
    end;
{/09.07.2006}

    // ��������� szItemId
    result := rdm.SplitItemID(szItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag);
    if result <> S_OK then begin
      PostLogRecordAddMsgNow(70141, -1, -1, result, '������������ ��� ' + szItemId);
      exit; // ���� ���� ������� �������, ���������� ���������� ������
    end;

    // ��������� ������ ��� �������� ��������
    ppszNewItemIDs := CoTaskMemAlloc(dwCount * sizeof(POleStr));
    ppErrors := CoTaskMemAlloc(dwCount * sizeof(HRESULT));

    // ������ �� ������ ������� ����
    PropIndex :=0;
    ErrCount := 0;
    while PropIndex < dwCount do try
      // ��������� valid-����� �������� ��� ������� ����
      hr := GetPropertyValidStatus(tagDeviceTypeTag, pdwPropertyIDs^[PropIndex], wValidStatus);
      // ��������� ���������� ���������� ��������
      if hr <> S_OK then begin
        ppszNewItemIDs^[PropIndex] := nil;
        ppErrors^[PropIndex] := E_FAIL;
        ErrCount := Succ(ErrCount);
        continue;
      end;

      // ���� �������� ���������� - ������
      if wValidStatus < 1 then begin
        ppszNewItemIDs^[PropIndex] := nil;
        ppErrors^[PropIndex] := OPC_E_INVALID_PID;
        ErrCount := Succ(ErrCount);
        continue;
      end;

      // �������� �����. ��������
      v := rdm.GetOneCell('select vtpi_tag from vn_tag_property_ids vtpi where vtpi_property_id = ' + rdm.IntToSQL(pdwPropertyIDs^[PropIndex], '-1'));
      // ���� �� ������ - ������
      if not(VarIsStr(v)) then begin
        ppszNewItemIDs^[PropIndex] := nil;
        ppErrors^[PropIndex] := E_FAIL;
        ErrCount := Succ(ErrCount);
        continue;
      end;

      // ��������� ItemID ��������
      sPropId := v;
      sItemID := szItemID;
      sPropItemId := sItemID + '.' + sPropId;

      // ���������� ItemID �������� � �������� ������
      hr := VpStringToLPOLESTR(sPropItemId, ppszNewItemIDs^[PropIndex]);
      // ���� �� ������ - ������
      if (hr <> S_OK) then begin
        ppszNewItemIDs^[PropIndex] := nil;
        ppErrors^[PropIndex] := E_FAIL;
        ErrCount := Succ(ErrCount);
        continue;
      end;

      // ������� ���������� ��������� �������� ������ �������
      ppErrors^[PropIndex] := S_OK;

    finally
      PropIndex := Succ(PropIndex);
    end;

    if ErrCount = 0 then
      result := S_OK
    else
      result := S_FALSE;

  except on e : Exception do begin
    PostLogRecordAddMsgNow(70139, -1, -1, result, '���������� �������: ' + e.Message);
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
    PostLogRecordAddMsgNow(70800, -1, -1, S_OK, '����� ������', llDebug);
    pNameSpaceType := OPC_NS_HIERARCHIAL;
    Result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70142, -1, -1, E_FAIL, '���������� ������� ' + e.Message);
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
    PostLogRecordAddMsgNow(70801, -1, -1, S_OK, '����� ������', llDebug);
    // ��������� �������������� ��������
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

    // ���� �� ������� ���������� ��� �������� ��������, ������� � �������
    result := rdm.GetNodeType(FNavigationNodeId, dwNodeType);
    if result < S_OK then begin
      PostLogRecordAddMsgNow(70144, -1, -1, result, '���������� �������');
      exit;
    end;

    // �������� ������������ ��������� dwBrowseDirection
    // (����� ��������� BROWSE_TO ���� �� ������������)
    if not(dwBrowseDirection = OPC_BROWSE_UP) and not(dwBrowseDirection = OPC_BROWSE_DOWN) then begin
      PostLogRecordAddMsgNow(70145, Integer(dwBrowseDirection), -1, E_INVALIDARG, '���������� �������');
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
    PostLogRecordAddMsgNow(70143, -1, -1, result, '���������� �������: ' + e.Message);
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
    PostLogRecordAddMsgNow(70802, -1, -1, S_OK, '����� ������', llDebug);
    result := rdm.GetNodeType(FNavigationNodeId, dwNodeType);
    if result < S_OK then begin
      PostLogRecordAddMsgNow(70147, result, -1, E_FAIL, '���������� �������');
      exit;
    end;

    ds := nil;
    lStrings := TStringList.Create;
    try
      // ������ ������ ���������
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

      // ������������ ��������� ������ ���������
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
      // ... � ���� StringEnumerator �������� ��������, ...
      if lStrings.Count > 0 then begin
        // ... ���������� S_OK ...
        result := S_OK
      end else begin
        // ... ����� ���������� S_FALSE.
        result := S_FALSE;
      end;

    finally
      lStrings.Free;
    end;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70146, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
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
    PostLogRecordAddMsgNow(70803, -1, -1, S_OK, '����� ������', llDebug);
    szItemID := '';
    result := rdm.NodeIdToItemId(FNavigationNodeId, sItemId);
    if result < S_OK then exit;
    sItemId := sItemId + '.' + szItemDataID;
    result := VpStringToLPOLESTR(sItemId, szItemID);
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70148, -1, -1, E_FAIL, '���������� �������: ' + e.Message);
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
      PostLogRecordAddMsgNow(70289, -1, -1, E_UNEXPECTED, '���������� �������: ' + e.Message);
    end;
  end;
end.
