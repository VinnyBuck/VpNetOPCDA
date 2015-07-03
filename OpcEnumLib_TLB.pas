unit OpcEnumLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 30.01.2006 0:05:29 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\WINNT\system32\OpcEnum.exe (1)
// LIBID: {13486D43-4821-11D2-A494-3CB306C10000}
// LCID: 0
// Helpfile: 
// HelpString: OpcEnum 1.1 Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\stdole2.tlb)
// Parent TypeLibrary:
//   (0) v1.0 VpNetDA, (E:\vpnet\vpnetda\VpNetDA.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  OpcEnumLibMajorVersion = 1;
  OpcEnumLibMinorVersion = 1;

  LIBID_OpcEnumLib: TGUID = '{13486D43-4821-11D2-A494-3CB306C10000}';

  IID_IOPCServerList2: TGUID = '{9DD0B56C-AD9E-43EE-8305-487F3188BF7A}';
  IID_IOPCServerList: TGUID = '{13486D50-4821-11D2-A494-3CB306C10000}';
  IID_IOPCEnumGUID: TGUID = '{55C382C8-21C7-4E88-96C1-BECFB1E3F483}';
  CLASS_OpcServerList: TGUID = '{13486D51-4821-11D2-A494-3CB306C10000}';
  IID_IEnumGUID: TGUID = '{0002E000-0000-0000-C000-000000000046}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IOPCServerList2 = interface;
  IOPCServerList = interface;
  IOPCEnumGUID = interface;
  IEnumGUID = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  OpcServerList = IOPCServerList2;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PUserType1 = ^TGUID; {*}


// *********************************************************************//
// Interface: IOPCServerList2
// Flags:     (0)
// GUID:      {9DD0B56C-AD9E-43EE-8305-487F3188BF7A}
// *********************************************************************//
  IOPCServerList2 = interface(IUnknown)
    ['{9DD0B56C-AD9E-43EE-8305-487F3188BF7A}']
    function EnumClassesOfCategories(cImplemented: LongWord; var rgcatidImpl: TGUID; 
                                     cRequired: LongWord; var rgcatidReq: TGUID; 
                                     out ppenumClsid: IOPCEnumGUID): HResult; stdcall;
    function GetClassDetails(var clsid: TGUID; out ppszProgID: PWideChar; 
                             out ppszUserType: PWideChar; out ppszVerIndProgID: PWideChar): HResult; stdcall;
    function CLSIDFromProgID(szProgId: PWideChar; out clsid: TGUID): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IOPCServerList
// Flags:     (0)
// GUID:      {13486D50-4821-11D2-A494-3CB306C10000}
// *********************************************************************//
  IOPCServerList = interface(IUnknown)
    ['{13486D50-4821-11D2-A494-3CB306C10000}']
    function EnumClassesOfCategories(cImplemented: LongWord; var rgcatidImpl: TGUID; 
                                     cRequired: LongWord; var rgcatidReq: TGUID; 
                                     out ppenumClsid: IEnumGUID): HResult; stdcall;
    function GetClassDetails(var clsid: TGUID; out ppszProgID: PWideChar; 
                             out ppszUserType: PWideChar): HResult; stdcall;
    function CLSIDFromProgID(szProgId: PWideChar; out clsid: TGUID): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IOPCEnumGUID
// Flags:     (0)
// GUID:      {55C382C8-21C7-4E88-96C1-BECFB1E3F483}
// *********************************************************************//
  IOPCEnumGUID = interface(IUnknown)
    ['{55C382C8-21C7-4E88-96C1-BECFB1E3F483}']
    function Next(celt: LongWord; out rgelt: TGUID; out pceltFetched: LongWord): HResult; stdcall;
    function Skip(celt: LongWord): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IOPCEnumGUID): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IEnumGUID
// Flags:     (0)
// GUID:      {0002E000-0000-0000-C000-000000000046}
// *********************************************************************//
  IEnumGUID = interface(IUnknown)
    ['{0002E000-0000-0000-C000-000000000046}']
    function Next(celt: LongWord; out rgelt: TGUID; out pceltFetched: LongWord): HResult; stdcall;
    function Skip(celt: LongWord): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumGUID): HResult; stdcall;
  end;

// *********************************************************************//
// The Class CoOpcServerList provides a Create and CreateRemote method to          
// create instances of the default interface IOPCServerList2 exposed by              
// the CoClass OpcServerList. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOpcServerList = class
    class function Create: IOPCServerList2;
    class function CreateRemote(const MachineName: string): IOPCServerList2;
  end;

implementation

uses ComObj;

class function CoOpcServerList.Create: IOPCServerList2;
begin
  Result := CreateComObject(CLASS_OpcServerList) as IOPCServerList2;
end;

class function CoOpcServerList.CreateRemote(const MachineName: string): IOPCServerList2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OpcServerList) as IOPCServerList2;
end;

end.
