unit VpNetDADefs;

interface

uses Windows, SysUtils, OPCTypes, VpNetDefs, IniFiles;

// 70935

const
  // ���������
  IniFileCoreSectionName : String = 'CORE';
  UnassignedInstanceIdValue : Integer  = 0;
  UnassignedGroupHandle : OPCHANDLE = 0;
  UnassignedItemHandle : OPCHANDLE = 0;
  UnassignedGroupUpdateRate : DWORD = 0;
  UnassignedMinGroupKeepAlive : DWORD = 0;
  UnassignedLastTID : DWORD = 0;
  UnassignedLastTIID : DWORD = 0;

// �������������� ���������
  VNVP_LastAssignedServerGroupId : Integer = 10001;

// ��������� windows
const
  // ��������: ������� �� ���������� �������� ���� ���������
  // WParam = 0
  // LParam = 0
  CM_DA_UPDATE_STATE   = WM_DA_ + $01;
  WM_DA_HIDE           = WM_DA_ + $02;

  // ��������: ��������� � �������� ������ ���������� ������� (TVpNetOPCDA)
  // WParam = ��������� ������ (TVpNetOPCDA)
  // LParam = 0;
  WM_DA_SERVER_CREATED = WM_DA_ + $11;

  // ��������: ��������� � ������ �������� ���������� ������� (TVpNetOPCDA)
  // WParam = ��������� ������ ������ (TVpNetOPCDA)
  // LParam = 0;
  WM_DA_SERVER_DESTROING = WM_DA_ + $12;

  // ��������: ��������� � �������� ������
  // WParam = 0
  // LParam = 0;
  WM_DA_GROUP_CREATED = WM_DA_ + $17;

  // ��������: ��������� �� �������� ������
  // WParam = 0
  // LParam = 0;
  WM_DA_GROUP_DESTROYED = WM_DA_ + $18;

  // ��������: ��������� � ��������� ������ �������������� ����������
  // WParam = 0
  // LParam = TID (Cardinal);
  WM_DA_NEW_TID = WM_DA_ + $19;

  // ��������: ��������� � ����������/�������� ������ �� ������� Host-�������
  // WParam = Id �������� Host-������� (HostServerDriverID)
  // LParam = 0;
  CM_DA_HST_DRIVER_ADD_REF = WM_DA_ + $23;
  CM_DA_HST_DRIVER_RELEASE = WM_DA_ + $24;

  // ��������: ������� ���������� ����� ����������  DA-������� � ������� ���������� �������� ����-�������
  // WParam = ������������� �������� ����-������� (DriverId)
  // LParam = ������ �� ���������, ���������� ������ ���������� DA-������� (TVpNetDATransactionList) ��� ������� ����������(��������)
  CM_DA_HST_DRIVER_ADD_TRANSACTIONS = WM_DA_ + $30;

  // ��������: ������� �� �������� ������� ����� ������ ����� ������� ����-�������
  // WParam = ������������� �������� ����-������� (DriverId)
  // LParam = 0
  CM_DA_HST_DRIVER_SEND = WM_DA_ + $31;

  // ��������: ��������� �� ��������� ��������� ���������� �����������������
  // �������� ����-�������
  // WParam = ������ �� ������, �������������� ���������� � ��������� ����-������� (TVpNetHstDriverConnection)
  // LParam = ����� ��������� ���������� ����������������� �������� (VpNetHstCommDriverActiveState)
  WM_DA_HST_DRIVER_ACTIVE_STATE_CHANGED = WM_DA_ + $32;

  // ��������: ��������� � ��������� ������ �� �������� ����-�������
  // WParam = ������������� ���������� HST-�������
  // LParam = ������ �� ��������� � ������� ���������� (PVpNetHSTAnswerData)
  WM_DA_HST_DRIVER_RECIEVE = WM_DA_ + $33;

  // ��������: ��������� � ��������� ����������� �� ������ �� �������� ����-�������
  // WParam = Hst_TID (������������� ���������� ����-�������)
  // LParam = ERROR_CODE (������������� ������)
  WM_DA_HST_DRIVER_ERROR = WM_DA_ + $34;

// 30.11.2011
  // ��������: ��������� � ��������� ����������� �� ������ �� �������� ����-�������
  // WParam = Hst_TID (������������� ���������� ����-�������)
  //LParam = pErrorData
  WM_DA_HST_DRIVER_ERROR_WITH_DATA = WM_DA_ + $37;
///30.11.2011


  // ��������: ��������� � ��������� ����������� � ������ ���������� ��������� ����-�������
  // WParam = Hst_TID (������������� ���������� ����-�������)
  // LParam = 0
  WM_DA_HST_DRIVER_START_TRANSACTION = WM_DA_ + $35;

  // ��������: ������� �� �������� ���������� ������� (���������� ���������)
  // WParam = 0
  // LParam = 0
  CM_DA_TRANSACTION_CHECK = WM_DA_ + $36;

  // ��������: ��������� �� ��������� ������ ��� ����� ��������� ���������� DA-�������
  // WParam = ���������� DA-������� (TVpNetDATransaction)
  // LParam = 0
  WM_DA_TRANSACTION_ITEMS_PROCESSED = WM_DA_ + $40;

  // ��������: ��������� � ���������� ����������� ���������� DA-�������
  // WParam = ������ DA-������� (TVpNetOPCGroup)
  // LParam = ���������� DA-������� (TVpNetDATransaction)
  WM_DA_TRANSACTION_PROCESSED = WM_DA_ + $41;

  // ��������: ��������� � ���������� �������� ��������
  // WParam = 0
  // LParam = LicState (HRESULT)
  WM_DA_LICENSE_STATUS = WM_DA_ + $49;

  // ��������: �������� �� ���������� ������ � ����
  // WParam - ������ �� ������ (TVpNetDALogRecordDataStruct)
  // LParam - 0
  CM_DA_LOG_RECORD_ADD = WM_DA_ + $97;

  // ��������: �������� ����������� ���������� � ������ �������
  // WParam - ���������� � ������ ������� (TVpNetDAProcessInfoStruct)
  // LParam - 0
  CM_DW_PROCESS_INFO_DISPLAY = WM_DA_ + $99;

// ���������-�������������� ������� Host-�������
// �������� �������� 72000..73999
// ��������� �������� ���: 72009
const
  vdae_None = 72000; // �����������, �� ������������ � �.�.

// su01 - ������� ����, ��� ���������� ����������/����������� �01 ��� ��������� ���� ���������
//        ���� ����������:
//          ���������� ����� ���� ��������� � ���� ��� ��������� ������ try...except
//          ����� ��������� ��� ���� ������� � Log-����

// su02 - ������� ����, ��� ���������� ����������/����������� �02 ��� ��������� ���� ���������
//        ���� ����������:
//          ���������� ��������� ��� ���� ������� �� ����:
//          llDebug - ���������� ���������
//          llErrors - ��������� �� ������� � ����
//        ����� ������ ����� ��������� � VpNetDADebug.FLogLevel

// ��������� �������
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
    // ����������
    ErrValue := IntToStr(GetTickCount);
    sAppName := ParamStr(0);
    sIniFileName := ExtractFilePath(sAppName) + Copy(ExtractFileName(sAppName), 1, length(ExtractFileName(sAppName)) - 4)  + '.ini';
    IniFile := TIniFile.Create(sIniFileName);
    // �������� ������� �����
    if not IniFile.ValueExists(aSection, aKey) then begin
      PostLogRecordAddMsgNow(70482, -1, -1, E_INVALIDARG, aSection + '.' + aKey);
      aValue := '';
      result := E_INVALIDARG;
      exit;
    end;
    // ������ �������� �����
    aValue := IniFile.ReadString(aSection, aKey, ErrValue);
    if aValue = ErrValue then begin
      // ���� �� ������� ��������� ��������� ��������, ���������� E_INVALIDARG
      PostLogRecordAddMsgNow(70483, -1, -1, E_INVALIDARG, aSection + '.' + aKey + '=' + aValue);
      aValue := '';
      result := E_INVALIDARG;
      exit;
    end else begin
      // ���� ��� ���������, ���������� S_OK
      result := S_OK;
      exit;
    end;
  except on e : Exception do begin
      PostLogRecordAddMsgNow(70481, e.HelpContext, -1, -1, e.Message + '; ' + aSection + '.' + aKey);
      // ���� ��������� �������������� ������, ���������� E_FAIL
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
