unit VpNetDARegDereg;

interface

uses Windows, SysUtils, Registry, Classes, OPCDA, VpNetDA_TLB;

function RegisterTheServer(name : string) : HRESULT; // su01
function UnRegisterTheServer(name : string) : HRESULT; // su01
function CheckServerRegistration(aServerCLSID : TGUID; out bRegistered : boolean): HRESULT; // su01

implementation

uses ComObj, ComCat, VpNetDADebug;

function RegisterTheServer(name:string) : HRESULT;
var
 sCLSID : string;
 aReg : TRegistry;
 hr : HRESULT;
begin
  try
(*
    // Строковое представление идентификатора сервера
    sCLSID := GUIDToString(CLASS_VpNetOPCDA);

    // HKEY_CLASSES_ROOT\<name>\'' = '<...>'
    aReg:= nil;
    try
      aReg := TRegistry.Create;
      aReg.RootKey := HKEY_CLASSES_ROOT;
      aReg.OpenKey(name, true);
      aReg.WriteString('', 'VpNet Data Access Server Version 3.0');
    finally
      aReg.CloseKey;
      aReg.Free;
    end;

    // HKEY_CLASSES_ROOT\<name>\CLSID\'' = '{<sCLSID>}'
    try
      aReg := TRegistry.Create;
      aReg.RootKey := HKEY_CLASSES_ROOT;
      aReg.OpenKey(name+'\Clsid', true);
      aReg.WriteString('', sCLSID);
    finally
      aReg.CloseKey;
      aReg.Free;
    end;

  // Необходимо только для поддержки спецификации Data Access Version 1.0
    // HKEY_CLASSES_ROOT\<name>\OPC
  {
    try
      aReg := TRegistry.Create;
      aReg.RootKey := HKEY_CLASSES_ROOT;
      aReg.OpenKey(name+'\OPC', true);
    finally
      aReg.CloseKey;
      aReg.Free;
    end;
  }

    // HKEY_CLASSES_ROOT\CLSID\<sCLSID>\ProgID\'' = <name>
    try
      aReg := TRegistry.Create;
      aReg.RootKey := HKEY_CLASSES_ROOT;
      aReg.OpenKey('CLSID\'+sCLSID+'\ProgID', true);
      aReg.WriteString('', name);
    finally
      aReg.CloseKey;
      aReg.Free;
    end;


    // Регистрируем категорию серверов OPC Data Access 3.0
    hr := CreateComponentCategory(CATID_OPCDAServer30, 'VpNet OPC Data Access');
    if hr <> S_OK then begin
      PostLogRecordAddMsgNow(70158, -1, -1, E_FAIL, 'Ошибка регистрации сервера');
      result := E_FAIL;
      exit;
    end;
*)
    // Регистрация сервера в категории серверов PC Data Access 2.0
    hr := RegisterCLSIDInCategory(CLASS_VpNetOPCDA, CATID_OPCDAServer20);
    if hr <> S_OK then begin
      PostLogRecordAddMsgNow(70159, -1, -1, E_FAIL, 'Ошибка регистрации сервера');
      result := E_FAIL;
      exit;
    end;
    // Регистрация сервера в категории серверов PC Data Access 3.0
    hr := RegisterCLSIDInCategory(CLASS_VpNetOPCDA, CATID_OPCDAServer30);
    if hr <> S_OK then begin
      PostLogRecordAddMsgNow(70160, -1, -1, E_FAIL, 'Ошибка регистрации сервера');
      result := E_FAIL;
      exit;
    end;

    result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70157, -1, -1, E_FAIL, 'Внутреннее событие: ' + e.Message);
    result := E_FAIL;
  end;
  end;
end;

function UnRegisterTheServer(name:string) : HRESULT;
var
 aReg : TRegistry;
 hr : HRESULT;
 sCLSID : string;
begin
  try
    // Строковое представление идентификатора сервера
    sCLSID := GUIDToString(CLASS_VpNetOPCDA);

    // Удаление ключа HKEY_CLASSES_ROOT\CLSID\<sCLSID>\ProgID\''
    aReg := nil;
    try
      aReg := TRegistry.Create;
      aReg.RootKey := HKEY_CLASSES_ROOT;
      aReg.DeleteKey('CLSID\' + sCLSID + '\ProgID');
    finally
      aReg.CloseKey;
      aReg.Free;
    end;

    // Удаление ключа HKEY_CLASSES_ROOT\CLSID\<sCLSID>
    try
      aReg := TRegistry.Create;
      aReg.RootKey := HKEY_CLASSES_ROOT;
      aReg.DeleteKey('CLSID\' + sCLSID);
    finally
      aReg.CloseKey;
      aReg.Free;
    end;

{
    // Необходимо только для поддержки спецификации Data Access Version 1.0
    // Удаление ключа HKEY_CLASSES_ROOT\<name>\OPC
    try
      aReg := TRegistry.Create;
      aReg.RootKey := HKEY_CLASSES_ROOT;
      aReg.DeleteKey(name + '\OPC');
    finally
      aReg.CloseKey;
      aReg.Free;
    end;
}

    // Удаление ключа HKEY_CLASSES_ROOT\<name>\Clsid
    try
      aReg := TRegistry.Create;
      aReg.RootKey := HKEY_CLASSES_ROOT;
      aReg.DeleteKey(name + '\Clsid');
    finally
      aReg.CloseKey;
      aReg.Free;
    end;

    // Удаление ключа HKEY_CLASSES_ROOT\<name>
    try
      aReg := TRegistry.Create;
      aReg.RootKey := HKEY_CLASSES_ROOT;
      aReg.DeleteKey(name);
    finally
      aReg.CloseKey;
      aReg.Free;
    end;

    // Отмена регистрации сервера в категории OPC Data Access 3.0
    hr := UnRegisterCLSIDInCategory(CLASS_VpNetOPCDA, CATID_OPCDAServer30);
    if hr <> 0 then begin
      PostLogRecordAddMsgNow(70162, -1, -1, E_FAIL, 'Ошибка дерегистрации сервера');
      result := E_FAIL;
      exit;
    end;

    // Удаляем регистрацию категори OPC Data Access 3.0
    hr := UnCreateComponentCategory(CATID_OPCDAServer30, 'VpNet OPC Data Access');
    if hr <> 0 then begin
      PostLogRecordAddMsgNow(70163, -1, -1, E_FAIL, 'Ошибка дерегистрации сервера');
      result := E_FAIL;
      exit;
    end;

    result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70161, -1, -1, E_FAIL, 'Ошибка дерегистрации сервера: ' + e.Message);
    result := E_FAIL;
  end;
  end;
end;

function CheckServerRegistration(aServerCLSID : TGUID; out bRegistered : boolean): HRESULT;
var
  sl : TStringList;
begin
  try
    bRegistered := false;
    sl := TStringList.Create;
    try
      // Проверка регистрации сервера
      result := GetCategoryCLSIDList(CATID_OPCDAServer30, sl);
      if result <> S_OK then begin
        PostLogRecordAddMsgNow(70165, -1, -1, E_FAIL, 'Ошибка проверки регистрации сервера');
        exit;
      end;
      bRegistered := (sl.IndexOf(GUIDToString(aServerCLSID)) >= 0);
    finally
      sl.Free;
    end;
    result := S_OK;
  except on e : Exception do begin
    PostLogRecordAddMsgNow(70164, -1, -1, E_FAIL, 'Ошибка проверки регистрации сервера: ' + e.Message);
    bRegistered := false;
    result := E_FAIL;
  end;
  end;
end;

end.
