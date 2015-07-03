unit VpNetOPCGroupList;

interface

uses Windows, Classes, VpNetOPCGroup_Impl, OPCtypes, SysUtils;

type

TVpNetOPCGroupList = class(TList)
private
  function Get(Index: Integer): TVpNetOPCGroup;
  procedure Put(Index: Integer; const Value: TVpNetOPCGroup);
public
  property Items[Index: Integer]: TVpNetOPCGroup read Get write Put; default;
  function IndexOfName(aName: String) : Integer;
  function IsNameUsed(aName : String) : boolean;
  function GetUniqueName : String;
  function IndexOfServerHandle(ahServer : OPCHANDLE) : Integer;
end;

implementation

function TVpNetOPCGroupList.Get(Index: Integer): TVpNetOPCGroup;
begin
  Result := TVpNetOPCGroup(inherited Get(Index));
end;

procedure TVpNetOPCGroupList.Put(Index: Integer; const Value: TVpNetOPCGroup);
begin
  inherited Put(Index, Value);
end;

function TVpNetOPCGroupList.IndexOfName(aName: String) : Integer;
var
  Index : Integer;
begin
  try
    result := -1;
    Index := 0;
    while Index < Count do begin
      if ANSICompareStr(Items[Index].Name, aName) = 0 then begin
        result := Index;
        break;
      end;
      Index := Index + 1;
    end;
  except
    result := -1;
  end;
end;

function TVpNetOPCGroupList.IsNameUsed(aName : String) : boolean;
begin
  result := (IndexOfName(aName) >= 0);
end;

function TVpNetOPCGroupList.GetUniqueName : String;
var
  TryIndex : Integer;
  sName : String;
begin
  try
    TryIndex := 0;
    repeat
      TryIndex := TryIndex;
      sName := 'grp' + IntToStr(GetTickCount);
      if not IsNameUsed(sName) then begin
        result := sName;
        exit;
      end;
    until (TryIndex >= 10);
    result := EmptyStr;
  except
    result := EmptyStr;
  end;
end;

function TVpNetOPCGroupList.IndexOfServerHandle(ahServer : OPCHANDLE) : Integer;
var
  Index : Integer;
begin
  try
    result := -1;
    Index := 0;
    while Index < Count do begin
      if Items[Index].hServer = ahServer then begin
        result := Index;
        break;
      end;
      Index := Index + 1;
    end;
  except
    result := -1;
  end;
end;

end.
