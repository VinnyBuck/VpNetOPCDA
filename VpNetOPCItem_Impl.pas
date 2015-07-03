unit VpNetOPCItem_Impl;

interface

uses Windows, SysUtils, Variants, ActiveX, OPCTypes, OPCDA, OPCError, Classes,
  VpNetDARDM_Impl, DB;

type


TVpNetOPCItem = class
private
  // Server data
  FGroupObj: Pointer; // Ссылка на объект типа (TVpNetOPCGroup)
  FCanonicalDataType : TVarType;
  FhServer: OPCHANDLE;
  FAccessRights: DWORD;
  FReserved: Word;

  FEU_TYPE : OPCEUTYPE; // type of Engineering Unit (EU) Information
  FEU_TYPE_INFO : OleVariant; // Строка, содержащая список значений

  FVHS_ID : DWORD;
  FVHSD_ID : DWORD; // Идентификатор драйвера хост-сервера в базе сервера VpNetOPCDA
  FVD_ID : DWORD;
  FVDTT_ID : DWORD;
  
  // Client data
  FItemId: String;
  FActive: boolean; // Признак активности
  FRequestedDataType: TVarType; // Даданный тип данных
  FhClient: OPCHANDLE;
  FBlobSize: DWORD;
  FpBlob: PByteArray;
  FAccessPath: String;
  FDeadband : Single;
  FDeadbandSetForItem : boolean; // Признак того, что Deadband установлен индивидуально для этого элемента

  // Item sampling settings
  FSamplingRate : DWORD;
  FSamplingRateSet : boolean;
  FLastCacheUpdateTime : TFileTime;

  // Hst-данные
{
  // todo: Инициализированть!
  FHst_DeviceAddress : DWORD; // Адрес устройства в сети (шине) приборов
  FHst_FuncNumber : DWORD; // Номер функции
  FHst_ProtocolId : DWORD; // Идентификатор протокола для входных и выходных данных
  FHst_DataAddress : DWORD; // Адрес данных в устройстве
  FHst_AccessRights : DWORD; // Права доступа к элементу данных в устройстве
  FHst_DataSizeInBytes : WORD; // Размер поля данных в байтах
  FHst_DataFormatId : DWORD; // Идентификатор формата представления данных в устройстве
}

  // Текущее VQT
  FValue: OleVariant;
  FQuality : WORD;
  FTimestamp : TFileTime;

  // Предыдущее VQT
  FPrevValue: OleVariant;
  FPrevQuality : WORD;
  FPrevTimeStamp : TFileTime;

  function Get_rdm: TVpNetDARDM;
  // Возвращает признак того, поддерживает ли элемент Deadband
  function Get_DeadbandSupported : boolean;
public

  // Server properties
  property GroupObj : Pointer read FGroupObj;
  property rdm : TVpNetDARDM read Get_rdm;
  property CanonicalDataType : TVarType read FCanonicalDataType;
  property hServer: OPCHANDLE read FhServer;
  property AccessRights : DWORD read FAccessRights;
  property Reserved: Word read FReserved;

  property EU_TYPE : OPCEUTYPE read FEU_TYPE;
  property EU_TYPE_INFO : OleVariant read FEU_TYPE_INFO;
  property DeadbandSupported : boolean read Get_DeadbandSupported;

  property VHS_ID: DWORD read FVHS_ID;
  property VHSD_ID : DWORD read FVHSD_ID;
  property VD_ID: DWORD read FVD_ID;
  property VDTT_ID: DWORD read FVDTT_ID;

  // Client properties
  property ItemId : String read FItemId;
  property Active: boolean read FActive;
  property RequestedDataType: TVarType read FRequestedDataType;
  property hClient : OPCHANDLE read FhClient;
  property BlobSize : DWORD read FBlobSize;
  property pBlob : PByteArray read FpBlob;
  property AccessPath : String read FAccessPath;
  property Deadband : Single read FDeadband;
  property DeadbandSetForItem : boolean read FDeadbandSetForItem;

  // Item sampling settings
  property SamplingRate : DWORD read FSamplingRate write FSamplingRate;
  property SamplingRateSet : boolean read FSamplingRateSet write FSamplingRateSet;
  property LastCacheUpdateTime : TFileTime read FLastCacheUpdateTime write FLastCacheUpdateTime;

  // Hst-данные
{
  property Hst_DeviceAddress : DWORD read FHst_DeviceAddress write FHst_DeviceAddress;
  property Hst_FuncNumber : DWORD read FHst_FuncNumber write FHst_FuncNumber;
  property Hst_ProtocolId : DWORD read FHst_ProtocolId write FHst_ProtocolId;
  property Hst_DataAddress : DWORD read FHst_DataAddress write FHst_DataAddress;
  property Hst_AccessRights : DWORD read FHst_AccessRights write FHst_AccessRights;
  property Hst_DataSizeInBytes : WORD read FHst_DataSizeInBytes write FHst_DataSizeInBytes;
  property Hst_DataFormatId : DWORD read FHst_DataFormatId write FHst_DataFormatId;
}  

  // Data-source properties
  property Value: OleVariant read FValue write FValue;
  property PrevValue: OleVariant read FPrevValue;

  property Quality : WORD read FQuality write FQuality;
  property Timestamp : TFileTime read FTimestamp write FTimestamp;


  // Methods
  constructor Create(aGroupObj : Pointer); overload;
  constructor Create(
    aGroupObj : Pointer;
    aItemId : String;
    aActive : Boolean;
    aRequestedDataType : TVarType;
    ahClient : OPCHANDLE;
    aBlobSize: DWORD;
    apBlob: PByteArray;
    aAccessPath : String;
    aReserved: Word
  );overload;

  procedure Clear();
  function SetItemId(aItemId : String): HRESULT;
  function InitByItemDef(pItemDef : POPCITEMDEF): HRESULT;
  function SetActive(aActive : boolean): HRESULT;
  function SetNewRequestedDataType(aDataType : TVarType): HRESULT;
  function SethClient(ahClient : OPCHANDLE): HRESULT;

  function SetNewVQT(aValue : OleVariant; aQuality : WORD; aTimeStamp : TFileTime): HRESULT;
  function SetNewDeadband(aDeadband : Single): HRESULT;
  function ResetDeadband : HRESULT;
  function Clone(aGroupObj : Pointer; out aDestItem : TVpNetOPCItem): HRESULT;
end;

implementation

uses VpNetDAServerCore, VpNetOPCDA_Impl, VpNetOPCGroup_Impl,
  VpNetDADefs, uOPCUtils;

function TVpNetOPCItem.Get_rdm: TVpNetDARDM;
begin
  result := TVpNetOPCDA(TVpNetOPCGroup(GroupObj).ServObj).rdm;
end;

// Возвращает признак того, поддерживает ли элемент Deadband
function TVpNetOPCItem.Get_DeadbandSupported : boolean;
begin
  if FRequestedDataType in [VarSingle, VarDouble, VarCurrency] then begin
    result := true;
  end else begin
    result := false;
  end;
end;

procedure TVpNetOPCItem.Clear();
begin
  // clear server data
  FCanonicalDataType := varEmpty;
  FhServer := UnassignedGroupHandle;
  FAccessRights := 0;
  FReserved := 0;
  FVHS_ID := 0;
  FVHSD_ID := 0;
  FVD_ID := 0;
  FVDTT_ID := 0;
  FEU_TYPE := OPC_NOENUM;
  FEU_TYPE_INFO := null;

  // clear client data
  FItemId := '';
  FActive := false;
  FRequestedDataType := varEmpty;
  FhClient := 0;
  FBlobSize :=0;
  FpBlob := nil;
  FAccessPath := '';
  FDeadband := 0.;
  FDeadbandSetForItem := false; // Изначально Deadband индивидуально для этого элемента не установлен

  // Item sampling settings
  FSamplingRate := 0;
  FSamplingRateSet := False;
  FLastCacheUpdateTime.dwLowDateTime := 0;
  FLastCacheUpdateTime.dwHighDateTime := 0;

  // Data-source data
  FValue := Unassigned;
  FQuality := OPC_QUALITY_UNCERTAIN;
  FTimestamp.dwHighDateTime := 0;
  FTimestamp.dwLowDateTime := 0;

  FPrevValue := Unassigned;
  FPrevQuality := OPC_QUALITY_UNCERTAIN;
  FPrevTimeStamp.dwHighDateTime := 0;
  FPrevTimeStamp.dwLowDateTime := 0;

end;

function TVpNetOPCItem.SetItemId(aItemId : String): HRESULT;
var
  tagHostServer : String; // Тег Хост-сервера
  tagHostServerDriver : String; // Тег драйвера хост-сервера
  tagDevice : String; // Тег устройства
  tagDeviceTypeTag : String; // Тег тега типа устройства :)
  v : Variant;
  hr : HRESULT;
  ds : TDataSet;
  sl : TStringList;
  EU_INFO_Index : DWORD;
begin
  try
    FItemId := aItemId;
{07.07.2007}
{
    // Разбираем ItemID
    hr := rdm.SplitItemID(FItemId, tagHostServer, tagHostServerDriver, tagDevice, tagDeviceTypeTag);
    if hr <> S_OK then begin
      result := OPC_E_INVALIDITEMID;
      exit;
    end;

    // Получаем идентификатор Хост-Сервера (VHS_ID)
    v := rdm.GetOneCell(
      'select vhs.vhs_id from vn_host_servers vhs ' +
      'where upper(vhs_tag collate WIN1251) = upper(''' + tagHostServer +''' collate WIN1251)'
    );
    if not VarIsOrdinal(v) then begin
      result := OPC_E_UNKNOWNITEMID;
      exit;
    end;
    FVHS_ID := v;

    // Получаем дентификатор драйвера Хост-Сервера (VHSD_ID)
    v := rdm.GetOneCell(
      'select vhsd_id from vn_host_server_drivers ' +
      'where upper(vhsd_tag collate WIN1251) = upper(''' + tagHostServerDriver +''')  '
    );
    if not(VarIsOrdinal(v)) then begin
      result := OPC_E_UNKNOWNITEMID;
      exit;
    end;
    FVHSD_ID := v;

    // Получаем идентификатор устройства (VD_ID)
    if length(tagDevice) > 0 then begin
      v := rdm.GetOneCell(
        'SELECT VD.VD_ID FROM VDA_DEVICES VD ' +
        'WHERE ' +
        '  VD.VHSD_ID = ' + IntToStr(FVHSD_ID) + ' AND ' +
        '  (UPPER(VD.VD_TAG COLLATE WIN1251) = UPPER(''' + tagDevice +''' COLLATE WIN1251)) '
      );
      if not VarIsOrdinal(v) then begin
        result := OPC_E_UNKNOWNITEMID;
        exit;
      end;
    end else begin
      result := OPC_E_UNKNOWNITEMID;
    end;
    FVD_ID := v;

    // Получаем идентификатор тега (VDTT_ID) для данного типа устройства
    // и разрешения на чтение и запись по его текстовому представлению
    v := rdm.GetRaw(
      'SELECT VDTT.VDTT_ID, VDTT.vdtt_access_rights, vdt.vdt_var_type, ' +
      'VDTT.VDTT_EU_TYPE ' +
      'FROM VDA_DEVICE_TYPE_TAGS VDTT ' +
      'left outer join VN_DATATYPES VDT on vdt.vdt_id = vdtt.vdt_id ' +
      'WHERE ' +
      '  VDTT.VDTV_ID = ( ' +
      '    SELECT VD.VDTV_ID FROM VDA_DEVICES VD ' +
      '    WHERE ' +
      '      VD.VD_ID = ' + IntToStr(FVD_ID) + ' ' +
      '  ) AND ' +
      '  (UPPER(VDTT.VDTT_TAG COLLATE WIN1251) = UPPER(''' + tagDeviceTypeTag + ''' COLLATE WIN1251)) '
    );
    if not VarIsArray(v) then begin
      result := OPC_E_UNKNOWNITEMID;
      exit;
    end;
    FVDTT_ID := v[0];
}

    hr := rdm.SplitItemID(FItemId, FVHS_ID, FVHSD_ID, FVD_ID, FVDTT_ID);
    if hr <> S_OK then begin
      result := OPC_E_INVALIDITEMID;
      exit;
    end;

    // если это тег устройства, заполняем совйства и выходим
    if (FVD_ID = 0) or (FVDTT_ID = 0) then begin
      FAccessRights := OPC_READABLE + OPC_WRITEABLE;
      FCanonicalDataType := VT_BSTR;
      { TODO : Добавить описание EU параметров драйвера }
      FEU_TYPE := OPC_NOENUM;
      FEU_TYPE_INFO := null;
      result := S_OK;
      exit;
    end;



    // Получаем идентификатор тега (VDTT_ID) для данного типа устройства
    // и разрешения на чтение и запись по его текстовому представлению
    v := rdm.GetRaw(
      'SELECT VDTT.VDTT_ID, VDTT.vdtt_access_rights, vdt.vdt_var_type, ' +
      'VDTT.VDTT_EU_TYPE ' +
      'FROM VDA_DEVICE_TYPE_TAGS VDTT ' +
      'left outer join VN_DATATYPES VDT on vdt.vdt_id = vdtt.vdt_id ' +
      'WHERE VDTT.VDTT_ID = ' + IntToStr(FVDTT_ID)
    );
{/07.07.2007}

    // Права на чтение/запись
    if VarIsArray(v) then begin
      if VarIsOrdinal(v[1]) then
        FAccessRights := v[1]
      else
        FAccessRights := 0;

      // Тип данных
      if VarIsOrdinal(v[2]) then begin
        FCanonicalDataType := v[2];
      end else begin
        FCanonicalDataType := VT_EMPTY;
      end;

      // EU_TYPE
      if VarIsOrdinal(v[3]) then begin
        FEU_TYPE := OPCEUTYPE(v[3]);
      end else begin
        FEU_TYPE := OPC_NOENUM;
      end;
      FEU_TYPE_INFO := null;
      case FEU_TYPE of
        OPC_ANALOG, OPC_ENUMERATED : begin
          ds := rdm.GetQueryDataset(
            'select vei_text from VN_EU_INFO ' +
            'where ((vd_id is null) or (vd_id = ' + rdm.IntToSQL(FVD_ID, '-1') + ')) ' +
            'and (vdtt_id = ' + rdm.IntToSQL(FVDTT_ID, '-1') + ') ' +
            'order by vei_value'
          );
          try
            ds.Open;
            if not ds.Eof then begin
              sl := TStringList.Create;
              try
                while not ds.Eof do begin
                  sl.Add(ds.Fields[0].AsString);
                  ds.Next;
                end;
                if FEU_TYPE = OPC_ANALOG then
                  FEU_TYPE_INFO := VarArrayCreate([0, sl.Count - 1], varDouble)
                else
                  FEU_TYPE_INFO := VarArrayCreate([0, sl.Count - 1], varOleStr);
                EU_INFO_Index := 0;
                while EU_INFO_Index < DWORD(sl.Count) do begin
                  FEU_TYPE_INFO[EU_INFO_Index] := sl[EU_INFO_Index];
                  EU_INFO_Index := EU_INFO_Index + 1;
                end;
              finally
                sl.Free;
              end;
            end;
          finally
            ds.Free;
          end;
        end;
      end;
    end else begin
      FAccessRights := OPC_READABLE + OPC_WRITEABLE;
      FCanonicalDataType := VT_BSTR;
      { TODO : Добавить описание EU параметров драйвера }
      FEU_TYPE := OPC_NOENUM;
      FEU_TYPE_INFO := null;
    end;


    // Вычисляем серверный идентификатор (hServer)
    hr := ServerCore.GetServerTagHandle(FVHS_ID, FVHSD_ID, FVD_ID, FVDTT_ID, FhServer);
    if hr <> S_OK then begin
      result := OPC_E_UNKNOWNITEMID;
      exit;
    end;

    result := S_OK;

  except
    result := E_FAIL;
  end;
end;

{
function TVpNetOPCItem.SetItemId(aItemId : String): HRESULT;
var
  hr : HRESULT;
begin
  try
    FItemId := aItemId;
    // Разбираем ItemID
    hr := rdm.SplitItemID(FItemId, FVHS_ID, FVHSD_ID, FVD_ID, FVDTT_ID);
    if hr <> S_OK then begin
      Clear;
      result := OPC_E_INVALIDITEMID;
      exit;
    end;


  except
    result := E_FAIL;
  end;
end;
}
// Заполняем свойства объекта основываясь на данных из структуры OPCITEMDEF
function TVpNetOPCItem.InitByItemDef(pItemDef : POPCITEMDEF): HRESULT;
var
  hr : HRESULT;
begin
  try
    // Проверяем ссылку на pItemDef. Если  она неправильная,
    if not(assigned(pItemDef)) then begin
      // выходим с E_INVALIDARG
      result := E_INVALIDARG;
      exit;
    end;

    // Устанавливаем ItemId из pItemDef, ...
    hr := SetItemId(pItemDef.szItemID);
    if hr <> S_OK then begin
      // выходим с OPC_E_INVALIDITEMID
      result := OPC_E_INVALIDITEMID;
    end;

    // - Active
    FActive := pItemDef.bActive;

    // - hClient
    FhClient := pItemDef.hClient;

    // - BlobSize
    FBlobSize := pItemDef.dwBlobSize;

    // - pBlob
    //todo: Разобраться с получением и хранением Blob
    FpBlob := pItemDef.pBlob;

    // - RequestedDataType

    hr := SetNewRequestedDataType(pItemDef.vtRequestedDataType);
    if hr <> S_OK then begin
      result := OPC_E_BADTYPE;
      exit;
    end;

    // - Reserved
    FReserved := pItemDef.wReserved;

    // - AccessPath
    hr := ValidateOPCString(pItemDef.szAccessPath);
    if hr = S_OK then begin
      FAccessPath := pItemDef.szAccessPath;
    end else begin
      FAccessPath := EmptyStr;
      result := OPC_E_INVALIDITEMID;
      exit;
    end;

    result := S_OK;
  except
    result := E_FAIL;
  end;
end;

function TVpNetOPCItem.SetActive(aActive : boolean): HRESULT;
begin
  //todo: Выполнить необходимые действия при изменении состояния активности элемента
  FActive := aActive;
  result := S_OK;
end;

constructor TVpNetOPCItem.Create(aGroupObj : Pointer);
begin
  inherited Create(); // Унаследовнные действия
  FGroupObj := aGroupObj; // Назначение группы
  Clear(); // Очистка данных
end;

constructor TVpNetOPCItem.Create(
  aGroupObj : Pointer;
  aItemId : String;
  aActive : Boolean;
  aRequestedDataType : TVarType;
  ahClient : OPCHANDLE;
  aBlobSize: DWORD;
  apBlob: PByteArray;
  aAccessPath : String;
  aReserved: Word
);
var
  hr : HRESULT;
begin
  inherited Create(); // Унаследовнные действия
  FGroupObj := aGroupObj; // Назначение группы
  Clear(); // Очистка данных

  // Инициализация серверных данных
  hr := SetItemId(aItemId);
  if  hr <> S_OK then begin
    // Если не удалось установить ItemId, очищаем данные и выходим
    Clear();
    exit;
  end;

  // Инициализация клиентских данных
  FActive := aActive;
  SetNewRequestedDataType(aRequestedDataType);
  FhClient := ahClient;
  FBlobSize := aBlobSize;
  if FBlobSize > 0 then begin
    GetMem(FpBlob, FBlobSize);
    System.move(FpBlob[0], apBlob[0], FBlobSize);
  end else begin
    FpBlob := nil;
  end;
  FAccessPath := aAccessPath;
  if Assigned(FGroupObj) then begin
    FDeadband := TVpNetOPCGroup(FGroupObj).DeadBand;
    FDeadbandSetForItem := false; // Индивидуально Deadband для этого элемента все еще не установлен
  end;

  // Инициализация данных
  FValue := unassigned;
  FPrevValue := unassigned;
end;

function TVpNetOPCItem.SetNewVQT(aValue : OleVariant; aQuality : WORD; aTimeStamp : TFileTime): HRESULT;
var
  vNewValue : OleVariant;
  vt : TVarType;
begin
  // Установка времени обновления данных в CASHE (UTC)
  CoFileTimeNow(FLastCacheUpdateTime);
  LocalFileTimeToFileTime(FLastCacheUpdateTime, FLastCacheUpdateTime);

  // Сдвиг данных
  FPrevValue := FValue;
  FPrevQuality := FQuality;
  FPrevTimeStamp := FTimestamp;

  // Очистка новых значений
  FValue := Unassigned;
  FQuality := OPC_QUALITY_UNCERTAIN;
  FTimestamp.dwHighDateTime := 0;
  FTimestamp.dwLowDateTime := 0;
  try
    // Получаем тип данных нового значения
    vt := VarType(aValue);
    // Присваиваем элементу (FValue) новое значение, приведя его к
    // предопределенном типу данных для данного элемента  (CanonicalDataType)
    result := VariantChangeTypeEx(vNewValue, aValue, TVpNetOPCGroup(FGroupObj).LCID, 0, CanonicalDataType);
    // Если результат положительный,
    if result = S_OK then begin
      //todo: Выполнить необходимые действия при изменении значения элемента
      FValue := vNewValue;
      FQuality := aQuality;
      FTimestamp := aTimeStamp;
    end;
  except
    result := E_FAIL;
  end;

end;

function TVpNetOPCItem.SetNewDeadband(aDeadband : Single): HRESULT;
begin
  try
    // Если Deadband не поддерживается элементом, возвращаем OPC_E_DEADBANDNOTSUPPORTED
    if not DeadbandSupported then begin
      result := OPC_E_DEADBANDNOTSUPPORTED;
      exit;
    end;

    // Если получено недопустимое значение, возвращаем E_INVALIDARG
    if (aDeadband < 0.0) or (aDeadband > 100.0) then begin
      result := E_INVALIDARG;
      exit;
    end;

    //Присваиваем новое значение Deadband
    FDeadband := aDeadband;
    // Устанавливаем признак того, индивидуально для этого элемента установлен Deadband
    FDeadbandSetForItem := true;

    // Возвращаем S_OK
    result := S_OK;
  except
    // В случае непредвиденной ошибки возвращаем E_FAIL
    result := E_FAIL;
  end;
end;

function TVpNetOPCItem.ResetDeadband : HRESULT;
begin
  try
    // Если Deadband не поддерживается элементом, возвращаем OPC_E_DEADBANDNOTSUPPORTED
    if not DeadbandSupported then begin
      result := OPC_E_DEADBANDNOTSUPPORTED;
      exit;
    end;

    //Присваиваем значение Deadband группы
    FDeadband := TVpNetOPCGroup(GroupObj).Deadband;
    // Устанавливаем признак того, индивидуально для этого элемента Deadband более не установлен
    FDeadbandSetForItem := false;

    // Возвращаем S_OK
    result := S_OK;

  except
    // В случае непредвиденной ошибки возвращаем E_FAIL
    result := E_FAIL;
  end;
end;

function TVpNetOPCItem.SetNewRequestedDataType(aDataType : TVarType): HRESULT;
var
  hr : HRESULT;
  vNewValue : OleVariant;
  vNewPrevValue : OleVariant;
begin
  try
    // Проверяем заданный тип данных на вхождение в список допустимых типов данных сервера
    hr := ServerCore.ValidateDataType(CanonicalDataType, aDataType);
    if hr <> S_OK then begin
      result := hr;
      exit;
    end;

    // Пытаемся изменить тип текущего значения на заданный
    result := VariantChangeTypeEx(vNewValue, FValue, TVpNetOPCGroup(FGroupObj).LCID, 0, aDataType);
    if result <> S_OK then begin
      // Если не удалось, выходим с ошибкой
      exit;
    end;

    // Пытаемся изменить тип предыдущего значения на заданный
    result := VariantChangeTypeEx(vNewPrevValue, FPrevValue, TVpNetOPCGroup(FGroupObj).LCID, 0, aDataType);
    if result <> S_OK then begin
      // Если не удалось, выходим с ошибкой
      exit;
    end;

//    // Если все удалось, присваиваем новые значения
//    FValue := vNewValue;
//    FPrevValue := vNewPrevValue;

    // Запоминаем новый запрашиваемый тип данных
    FRequestedDataType := aDataType;

    // выходим с S_OK
    result := S_OK;
  except
    result := E_FAIL;
  end;
end;

function TVpNetOPCItem.SethClient(ahClient : OPCHANDLE): HRESULT;
begin
  FhClient := ahClient;
  result := S_OK;
end;


function TVpNetOPCItem.Clone(aGroupObj : Pointer; out aDestItem : TVpNetOPCItem): HRESULT;
begin
  try
    aDestItem := TVpNetOPCItem.Create(
      TVpNetOPCGroup(aGroupObj),
      ItemId,
      Active,
      RequestedDataType,
      hClient,
      BlobSize,
      pBlob,
      AccessPath,
      Reserved
    );
    result := S_OK;
  except
    if assigned(aDestItem) then begin
      aDestItem.Free;
      aDestItem := nil;
    end;
    result := E_FAIL;
  end;
end;

end.

