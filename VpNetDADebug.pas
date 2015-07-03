unit VpNetDADebug;
{$INCLUDE VpNetDA.def}
{$I 'VpNetDADebugDefs.pas'}

interface

uses Windows, ActiveX, Forms, Classes, SysUtils, VpNetDADefs;

const
  MaxUsedEventId = 70936;

// Log record section IDs
const
  llUndefined = 128;
  llDebug = 1;
  llErrors = 2;
  llErrors_Level2 = 4;
  llGlobalEvents = 512;

  FLogLevel = llErrors + llGlobalEvents + llUndefined + llDebug;

type
PVpNetDALogRecordDataStruct = ^TVpNetDALogRecordDataStruct;
TVpNetDALogRecordDataStruct = record
  dt : TDateTime; // Момент возникновения ошибки
  VDAE_ID : Integer; // Id события (vdae_id)
  Param1 : Integer; // Параметр 1
  Param2 : Integer; // Параметр 2
  Param3 : Integer; // Параметр 3
  Desc : PChar; // Строка описания ошибки
  SectionMask : Integer; // Маска секций (типов) лог-записей
end;

PVpNetDAProcessInfoDataStruct = ^TVpNetDAProcessInfoDataStruct;
TVpNetDAProcessInfoDataStruct = record
  dt : TDateTime; // Момент возникновения ошибки
  VDAE_ID : Integer; // Id события (vdae_id)
  Desc : PChar; // Строка описания ошибки
end;

var
  DebugCS : TRTLCriticalSection;
  FLogStream : TFileStream;

procedure VpNetDADebugInit;

function PostLogRecordAddMsg(
  adt : TDateTime;
  aVDAE_ID : Integer;
  aParam1 : Integer;
  aParam2 : Integer;
  aParam3 : Integer;
  aDesc : String;
  aSectionMask : Integer = llUndefined
): HRESULT;

function PostLogRecordAddMsgNow(
  aVDAE_ID : Integer;
  aParam1 : Integer;
  aParam2 : Integer;
  aParam3 : Integer;
  aDesc : String;
  aSectionMask : Integer = llUndefined
): HRESULT;

function AddLogRecord(
  adt : TDateTime;
  aVDAE_ID: Integer;
  aParam1 : Integer = -1;
  aParam2 : Integer = -1;
  aParam3 : Integer = -1;
  aDesc : String = '';
  aLogLevel : Integer = llUndefined
): HRESULT; // su02

function PostProcessInfoNow(aVDAE_ID : Integer; aDesc : String) : HRESULT;

implementation

procedure VpNetDADebugInit;
var
  FLogFileName : String;
  hFile : Integer;
begin
  InitializeCriticalSection(DebugCS);
  FLogFileName := ExtractFilePath(ParamStr(0)) + 'VpNetDA.log';
  if not(FileExists(FLogFileName)) then begin
    PostLogRecordAddMsg(now, 72001, -1, -1, -1, 'Файл журнала по указанному пути не обнаружен! Создан новый файл журнала ('+FLogFileName+')');
    hFile := FileCreate(FLogFileName);
    if hFile < 0 then begin
      PostLogRecordAddMsgNow(70014, -1, -1, E_FAIL, 'Ошибка создания файла журнала ('+FLogFileName+')');
    end else begin
      FileClose(hFile);
    end;
  end;

  FLogStream := TFileStream.Create(FLogFileName, fmOpenReadWrite	+ fmShareDenyWrite);
end;


function PostLogRecordAddMsg(
  adt : TDateTime;
  aVDAE_ID : Integer;
  aParam1 : Integer;
  aParam2 : Integer;
  aParam3 : Integer;
  aDesc : String;
  aSectionMask : Integer = llUndefined
): HRESULT;
var
  pcDesc : PChar;
  pcResultRecord : Pointer;
  LogRecordData: PVpNetDALogRecordDataStruct;
begin
  try
    EnterCriticalSection(DebugCS);
    try
      LogRecordData := CoTaskMemAlloc(SizeOf(TVpNetDALogRecordDataStruct));
      LogRecordData^.dt := adt;
      LogRecordData^.VDAE_ID := aVDAE_ID;
      LogRecordData^.Param1 := aParam1;
      LogRecordData^.Param2 := aParam2;
      LogRecordData^.Param3 := aParam3;
      LogRecordData^.SectionMask := aSectionMask;
      pcDesc := PChar(aDesc);
      LogRecordData^.Desc := CoTaskMemAlloc(length(pcDesc) + 1);
      Move(pcDesc^, LogRecordData^.Desc^, length(pcDesc) + 1);
      if assigned(LogRecordData) then begin
        PostMessage(Application.MainForm.Handle, CM_DA_LOG_RECORD_ADD, DWORD(LogRecordData), 0);
      end;
      result := S_OK;
    finally
      LeaveCriticalSection(DebugCS);
    end;
  except
    result := E_FAIL;
  end;
end;

function PostLogRecordAddMsgNow(
  aVDAE_ID : Integer;
  aParam1 : Integer;
  aParam2 : Integer;
  aParam3 : Integer;
  aDesc : String;
  aSectionMask : Integer = llUndefined
): HRESULT;
begin
  PostLogRecordAddMsg(Now, aVDAE_ID, aParam1, aParam2, aParam3, aDesc, aSectionMask);
end;


function AddLogRecord(
  adt : TDateTime;
  aVDAE_ID: Integer;
  aParam1 : Integer = -1;
  aParam2 : Integer = -1;
  aParam3 : Integer = -1;
  aDesc : String = '';
  aLogLevel : Integer = llUndefined
): HRESULT; // su02
var
  s : String;
  buf : Pointer;
  pc : PChar;
  sLevel : String;
  LevelIndex : Integer;
begin
  try
    if ((aLogLevel and FLogLevel) > 0) then begin
      if Assigned(FLogStream) then begin
        s := DateTimeToStr(adt) + '; ' + 'VDAE_ID:' + IntToStr(aVDAE_ID) + '; ';

        if (aLogLevel and llDebug) = llDebug then begin
          s := s + '    '
        end else if (aLogLevel and llErrors) = llErrors then begin
          s := s + '!   '
        end else if (aLogLevel and llErrors_Level2) = llErrors_Level2 then begin
          s := s + '!!  '
        end else if (aLogLevel and llUndefined) = llUndefined then begin
          s := s + '?   '
        end else if (aLogLevel and llGlobalEvents) = llGlobalEvents then begin
          s := s + ' G  '
        end else if (aLogLevel = 0) then begin
          s := s + '    '
        end else begin
          s := s + '???('+IntToStr(aLogLevel)+') '
        end;

        s := s + 'P1:' + IntToStr(aParam1) + '; ';
        s := s + 'P2:' + IntToStr(aParam2) + '; ';
        s := s + 'P3:' + IntToStr(aParam3) + '; ';
        s := s + aDesc + '; ' + #13 + #10;
        pc := PChar(s);
        {$if defined (CHECK_DONGLE) }
        OutputDebugString(pc);
        {$ifend}
        FLogStream.Seek(0, soFromEnd);
        FLogStream.Write(pc^, length(pc));
      end;
      result := S_OK;
    end else begin
      result := S_FALSE;
    end;
  except on e: Exception do begin
      try
        FLogStream.Seek(0, soFromEnd);
        pc := PChar('70002: Ошибка вывода в лог файл: ' + e.Message + #13 + #10);
        FLogStream.Write(pc^, length(pc));
      except
      end;
      result := E_FAIL;
    end;
  end;
end;

function PostProcessInfoNow(aVDAE_ID : Integer; aDesc : String) : HRESULT;
var
  pcDesc : PChar;
  ProcessInfoStruct : PVpNetDAProcessInfoDataStruct;
begin
  try
    EnterCriticalSection(DebugCS);
    try
      ProcessInfoStruct := CoTaskMemAlloc(SizeOf(TVpNetDAProcessInfoDataStruct));
      ProcessInfoStruct^.dt := now;
      ProcessInfoStruct^.VDAE_ID := aVDAE_ID;
      pcDesc := PChar(aDesc);
      ProcessInfoStruct^.Desc := CoTaskMemAlloc(length(pcDesc) + 1);
      Move(pcDesc^, ProcessInfoStruct^.Desc^, length(pcDesc) + 1);
      if assigned(ProcessInfoStruct) then begin
        PostMessage(Application.MainForm.Handle, CM_DW_PROCESS_INFO_DISPLAY, DWORD(ProcessInfoStruct), 0);
      end;
      result := S_OK;
    finally
      LeaveCriticalSection(DebugCS);
    end;
  except
    result := E_FAIL;
  end;
end;

initialization
//  VpNetDADebugInit;

finalization
//  FLogStream.Free;
//  DeleteCriticalSection(DebugCS);

end.
