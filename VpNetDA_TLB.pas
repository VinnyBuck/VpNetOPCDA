unit VpNetDA_TLB;

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
// File generated on 30.05.2012 21:44:48 from Type Library described below.

// ************************************************************************  //
// Type Lib: E:\vpnet\vpnetda\VpNetDA.tlb (1)
// LIBID: {DB761843-5A84-4E17-A7D9-E2953076CEFB}
// LCID: 0
// Helpfile: 
// HelpString: VpNetDA Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
//   (2) v1.0 Midas, (C:\WINDOWS\system32\midas.dll)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, Midas, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  VpNetDAMajorVersion = 1;
  VpNetDAMinorVersion = 0;

  LIBID_VpNetDA: TGUID = '{DB761843-5A84-4E17-A7D9-E2953076CEFB}';

  IID_IVpNetOPCDA: TGUID = '{34309752-512F-4CE9-BD7A-68393AC2CA74}';
  DIID_IVpNetOPCDAEvents: TGUID = '{527DF317-F92A-4DA4-9DD3-C3D2D95688B0}';
  IID_IVpNetOPCGroup: TGUID = '{F203F744-46B1-470F-9EB3-B4F263339CA0}';
  DIID_IVpNetOPCGroupEvents: TGUID = '{DA4B59FF-6E49-4CF2-81ED-EC732B6761D6}';
  CLASS_VpNetOPCGroup: TGUID = '{19D8476B-57FB-41C0-A0C5-A3698FCADC64}';
  IID_IVpNetDARDM: TGUID = '{8A10C148-B197-4474-A81C-9EE86CB75243}';
  CLASS_VpNetDARDM: TGUID = '{CFEFCD80-66A0-4D11-90DF-08234788DB26}';
  CLASS_VpNetOPCDA: TGUID = '{C81F918A-F2EE-4367-BA86-048BE15A42DD}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IVpNetOPCDA = interface;
  IVpNetOPCDADisp = dispinterface;
  IVpNetOPCDAEvents = dispinterface;
  IVpNetOPCGroup = interface;
  IVpNetOPCGroupDisp = dispinterface;
  IVpNetOPCGroupEvents = dispinterface;
  IVpNetDARDM = interface;
  IVpNetDARDMDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  VpNetOPCGroup = IVpNetOPCGroup;
  VpNetDARDM = IVpNetDARDM;
  VpNetOPCDA = IVpNetOPCDA;


// *********************************************************************//
// Interface: IVpNetOPCDA
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {34309752-512F-4CE9-BD7A-68393AC2CA74}
// *********************************************************************//
  IVpNetOPCDA = interface(IDispatch)
    ['{34309752-512F-4CE9-BD7A-68393AC2CA74}']
  end;

// *********************************************************************//
// DispIntf:  IVpNetOPCDADisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {34309752-512F-4CE9-BD7A-68393AC2CA74}
// *********************************************************************//
  IVpNetOPCDADisp = dispinterface
    ['{34309752-512F-4CE9-BD7A-68393AC2CA74}']
  end;

// *********************************************************************//
// DispIntf:  IVpNetOPCDAEvents
// Flags:     (4096) Dispatchable
// GUID:      {527DF317-F92A-4DA4-9DD3-C3D2D95688B0}
// *********************************************************************//
  IVpNetOPCDAEvents = dispinterface
    ['{527DF317-F92A-4DA4-9DD3-C3D2D95688B0}']
  end;

// *********************************************************************//
// Interface: IVpNetOPCGroup
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F203F744-46B1-470F-9EB3-B4F263339CA0}
// *********************************************************************//
  IVpNetOPCGroup = interface(IDispatch)
    ['{F203F744-46B1-470F-9EB3-B4F263339CA0}']
  end;

// *********************************************************************//
// DispIntf:  IVpNetOPCGroupDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F203F744-46B1-470F-9EB3-B4F263339CA0}
// *********************************************************************//
  IVpNetOPCGroupDisp = dispinterface
    ['{F203F744-46B1-470F-9EB3-B4F263339CA0}']
  end;

// *********************************************************************//
// DispIntf:  IVpNetOPCGroupEvents
// Flags:     (4096) Dispatchable
// GUID:      {DA4B59FF-6E49-4CF2-81ED-EC732B6761D6}
// *********************************************************************//
  IVpNetOPCGroupEvents = dispinterface
    ['{DA4B59FF-6E49-4CF2-81ED-EC732B6761D6}']
  end;

// *********************************************************************//
// Interface: IVpNetDARDM
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8A10C148-B197-4474-A81C-9EE86CB75243}
// *********************************************************************//
  IVpNetDARDM = interface(IAppServer)
    ['{8A10C148-B197-4474-A81C-9EE86CB75243}']
  end;

// *********************************************************************//
// DispIntf:  IVpNetDARDMDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8A10C148-B197-4474-A81C-9EE86CB75243}
// *********************************************************************//
  IVpNetDARDMDisp = dispinterface
    ['{8A10C148-B197-4474-A81C-9EE86CB75243}']
    function AS_ApplyUpdates(const ProviderName: WideString; Delta: OleVariant; MaxErrors: Integer; 
                             out ErrorCount: Integer; var OwnerData: OleVariant): OleVariant; dispid 20000000;
    function AS_GetRecords(const ProviderName: WideString; Count: Integer; out RecsOut: Integer; 
                           Options: Integer; const CommandText: WideString; var Params: OleVariant; 
                           var OwnerData: OleVariant): OleVariant; dispid 20000001;
    function AS_DataRequest(const ProviderName: WideString; Data: OleVariant): OleVariant; dispid 20000002;
    function AS_GetProviderNames: OleVariant; dispid 20000003;
    function AS_GetParams(const ProviderName: WideString; var OwnerData: OleVariant): OleVariant; dispid 20000004;
    function AS_RowRequest(const ProviderName: WideString; Row: OleVariant; RequestType: Integer; 
                           var OwnerData: OleVariant): OleVariant; dispid 20000005;
    procedure AS_Execute(const ProviderName: WideString; const CommandText: WideString; 
                         var Params: OleVariant; var OwnerData: OleVariant); dispid 20000006;
  end;

// *********************************************************************//
// The Class CoVpNetOPCGroup provides a Create and CreateRemote method to          
// create instances of the default interface IVpNetOPCGroup exposed by              
// the CoClass VpNetOPCGroup. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoVpNetOPCGroup = class
    class function Create: IVpNetOPCGroup;
    class function CreateRemote(const MachineName: string): IVpNetOPCGroup;
  end;

// *********************************************************************//
// The Class CoVpNetDARDM provides a Create and CreateRemote method to          
// create instances of the default interface IVpNetDARDM exposed by              
// the CoClass VpNetDARDM. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoVpNetDARDM = class
    class function Create: IVpNetDARDM;
    class function CreateRemote(const MachineName: string): IVpNetDARDM;
  end;

// *********************************************************************//
// The Class CoVpNetOPCDA provides a Create and CreateRemote method to          
// create instances of the default interface IVpNetOPCDA exposed by              
// the CoClass VpNetOPCDA. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoVpNetOPCDA = class
    class function Create: IVpNetOPCDA;
    class function CreateRemote(const MachineName: string): IVpNetOPCDA;
  end;

implementation

uses ComObj;

class function CoVpNetOPCGroup.Create: IVpNetOPCGroup;
begin
  Result := CreateComObject(CLASS_VpNetOPCGroup) as IVpNetOPCGroup;
end;

class function CoVpNetOPCGroup.CreateRemote(const MachineName: string): IVpNetOPCGroup;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_VpNetOPCGroup) as IVpNetOPCGroup;
end;

class function CoVpNetDARDM.Create: IVpNetDARDM;
begin
  Result := CreateComObject(CLASS_VpNetDARDM) as IVpNetDARDM;
end;

class function CoVpNetDARDM.CreateRemote(const MachineName: string): IVpNetDARDM;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_VpNetDARDM) as IVpNetDARDM;
end;

class function CoVpNetOPCDA.Create: IVpNetOPCDA;
begin
  Result := CreateComObject(CLASS_VpNetOPCDA) as IVpNetOPCDA;
end;

class function CoVpNetOPCDA.CreateRemote(const MachineName: string): IVpNetOPCDA;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_VpNetOPCDA) as IVpNetOPCDA;
end;

end.
