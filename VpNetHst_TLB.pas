unit VpNetHst_TLB;

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
// File generated on 30.11.2011 16:52:28 from Type Library described below.

// ************************************************************************  //
// Type Lib: E:\VPNet\#distr\VpNetHst\VpNetHst.exe (1)
// LIBID: {F829B4C4-2877-4287-87CF-0A1E27EA8558}
// LCID: 0
// Helpfile: 
// HelpString: VpNetHst Library
// DepndLst: 
//   (1) v1.0 Midas, (C:\WINDOWS\system32\midas.dll)
//   (2) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, Midas, OleServer, StdVCL, Variants;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  VpNetHstMajorVersion = 1;
  VpNetHstMinorVersion = 0;

  LIBID_VpNetHst: TGUID = '{F829B4C4-2877-4287-87CF-0A1E27EA8558}';

  IID_IVpNetHstRDM: TGUID = '{1E89E10C-F65B-4CE1-98A8-3034F0C3EF6C}';
  CLASS_VpNetHstRDM: TGUID = '{347868DC-A8C1-496E-A957-9CB677D423BA}';
  IID_IVpNetHstCommDriver: TGUID = '{EA298CDE-94C5-4A4E-858B-6C0CDEF97651}';
  DIID_IVpNetHstCommDriverEvents: TGUID = '{E2E41F10-B721-4EDD-B78E-CCFE9545BBC7}';
  CLASS_VpNetHstCommDriver: TGUID = '{DA455469-88DB-4E68-AEC0-D977645BDACD}';
  IID_IVpNetHstBrowser: TGUID = '{F76C9D17-9644-4790-AF1F-0A674F9A13BC}';
  DIID_IVpNetHstBrowserEvents: TGUID = '{5F266B2F-3C5C-4D4A-9B3E-2170F2D2ECCF}';
  CLASS_VpNetHstBrowser: TGUID = '{1E402F83-EBD6-4FBA-8136-6229BE7CCE0E}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum VpNetHstBrowseMoveDirection
type
  VpNetHstBrowseMoveDirection = TOleEnum;
const
  HSTBD_UP = $00000005;
  HSTBD_DOWN = $00000006;
  HSTBD_FORWARD = $00000001;
  HSTBD_BACKWARD = $00000002;

// Constants for enum VpNetNodeType
type
  VpNetNodeType = TOleEnum;
const
  VNT_NULL = $00000000;
  VNT_HOST_SERVER = $00000088;
  VNT_HOST_SERVER_PARAM = $0000001A;
  VNT_HOST_SERVER_DRIVER = $00000077;
  VNT_HOST_SERVER_DRIVER_PARAM = $00000079;
  VNT_NODE_PARAM = $000000C6;

// Constants for enum VpNetHstSortAttribute
type
  VpNetHstSortAttribute = TOleEnum;
const
  HSTSA_NONE = $00000000;
  HSTSA_BY_ID = $00000001;
  HSTSA_BY_NAME = $00000002;

// Constants for enum VpNetHstCommDriverActiveState
type
  VpNetHstCommDriverActiveState = TOleEnum;
const
  HSTCDAS_INACTIVE = $00000000;
  HSTCDAS_ACTIVE = $00000001;

// Constants for enum VpNetHstComPortParity
type
  VpNetHstComPortParity = TOleEnum;
const
  HSTCPP_NONE = $00000000;
  HSTCPP_ODD = $00000001;
  HSTCPP_EVEN = $00000002;
  HSTCPP_MARK = $00000003;
  HSTCPP_SPACE = $00000004;

// Constants for enum VpNetHstComPortStopBits
type
  VpNetHstComPortStopBits = TOleEnum;
const
  HSTCPSB_1bit = $00000001;
  HSTCPSB_2bit = $00000002;

// Constants for enum VpNetHstComPortHardwareFlowOptions
type
  VpNetHstComPortHardwareFlowOptions = TOleEnum;
const
  HSTCPFOH_USER_DTR = $00000001;
  HSTCPFOH_USER_RTS = $00000002;
  HSTCPFOH_REQUIRE_DSR = $00000004;
  HSTCPFOH_REQUIRE_CTS = $00000008;

// Constants for enum VpNetHstComPortSoftwareFlowPotions
type
  VpNetHstComPortSoftwareFlowPotions = TOleEnum;
const
  HSTCPFOS_NONE = $00000000;
  HSTCPFOS_RECEIVE = $00000001;
  HSTCPFOS_TRANSMIT = $00000002;
  HSTCPFOS_BOTH = $00000003;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IVpNetHstRDM = interface;
  IVpNetHstRDMDisp = dispinterface;
  IVpNetHstCommDriver = interface;
  IVpNetHstCommDriverEvents = dispinterface;
  IVpNetHstBrowser = interface;
  IVpNetHstBrowserEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  VpNetHstRDM = IVpNetHstRDM;
  VpNetHstCommDriver = IVpNetHstCommDriver;
  VpNetHstBrowser = IVpNetHstBrowser;


// *********************************************************************//
// Interface: IVpNetHstRDM
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {1E89E10C-F65B-4CE1-98A8-3034F0C3EF6C}
// *********************************************************************//
  IVpNetHstRDM = interface(IAppServer)
    ['{1E89E10C-F65B-4CE1-98A8-3034F0C3EF6C}']
  end;

// *********************************************************************//
// DispIntf:  IVpNetHstRDMDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {1E89E10C-F65B-4CE1-98A8-3034F0C3EF6C}
// *********************************************************************//
  IVpNetHstRDMDisp = dispinterface
    ['{1E89E10C-F65B-4CE1-98A8-3034F0C3EF6C}']
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
// Interface: IVpNetHstCommDriver
// Flags:     (4352) OleAutomation Dispatchable
// GUID:      {EA298CDE-94C5-4A4E-858B-6C0CDEF97651}
// *********************************************************************//
  IVpNetHstCommDriver = interface(IDispatch)
    ['{EA298CDE-94C5-4A4E-858B-6C0CDEF97651}']
    function Send(Data: OleVariant; BytesExpected: OleVariant; out TID: Integer): HResult; stdcall;
    function GetCommDriverId(out Value: LongWord): HResult; stdcall;
    function SetCommDriverId(Value: LongWord): HResult; stdcall;
    function GetPropValue(vPropId: OleVariant; out vPropValue: OleVariant): HResult; stdcall;
    function SetPropValue(vPropId: OleVariant; vPropValue: OleVariant): HResult; stdcall;
    function GetPropNames(out vPropNames: OleVariant): HResult; stdcall;
    function GetNewTID(out TID: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  IVpNetHstCommDriverEvents
// Flags:     (4096) Dispatchable
// GUID:      {E2E41F10-B721-4EDD-B78E-CCFE9545BBC7}
// *********************************************************************//
  IVpNetHstCommDriverEvents = dispinterface
    ['{E2E41F10-B721-4EDD-B78E-CCFE9545BBC7}']
    procedure OnRecieve(Data: OleVariant; TID: Integer); dispid 272;
    procedure OnError(TID: Integer; ERROR_CODE: Integer; Data: OleVariant); dispid 273;
    procedure OnStartTransaction(TID: Integer); dispid 274;
    procedure OnPropValueChanged(vPropId: OleVariant; vPropValue: OleVariant); dispid 275;
  end;

// *********************************************************************//
// Interface: IVpNetHstBrowser
// Flags:     (4352) OleAutomation Dispatchable
// GUID:      {F76C9D17-9644-4790-AF1F-0A674F9A13BC}
// *********************************************************************//
  IVpNetHstBrowser = interface(IDispatch)
    ['{F76C9D17-9644-4790-AF1F-0A674F9A13BC}']
    function ChangePosition(Direction: VpNetHstBrowseMoveDirection): HResult; stdcall;
    function GetSortAttribute(out Value: VpNetHstSortAttribute): HResult; stdcall;
    function SetSortAttribute(Value: VpNetHstSortAttribute): HResult; stdcall;
    function GetNodeType(out Value: VpNetNodeType): HResult; stdcall;
    function GetNodeId(out Value: Integer): HResult; stdcall;
    function GetNodeName(out NodeName: OleVariant): HResult; stdcall;
    function GetReadOnly(out ReadOnly: OleVariant): HResult; stdcall;
    function GetNodeDesc(out NodeDesc: OleVariant): HResult; stdcall;
    function GoToNode(aNodeId: Integer): HResult; stdcall;
    function GetNodeValue(out Value: OleVariant): HResult; stdcall;
    function SetNodeValue(Value: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  IVpNetHstBrowserEvents
// Flags:     (4096) Dispatchable
// GUID:      {5F266B2F-3C5C-4D4A-9B3E-2170F2D2ECCF}
// *********************************************************************//
  IVpNetHstBrowserEvents = dispinterface
    ['{5F266B2F-3C5C-4D4A-9B3E-2170F2D2ECCF}']
    procedure OnDriverPropValueChanged(DriverId: LongWord; vPropId: OleVariant; 
                                       vPropValue: OleVariant); dispid 201;
  end;

// *********************************************************************//
// The Class CoVpNetHstRDM provides a Create and CreateRemote method to          
// create instances of the default interface IVpNetHstRDM exposed by              
// the CoClass VpNetHstRDM. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoVpNetHstRDM = class
    class function Create: IVpNetHstRDM;
    class function CreateRemote(const MachineName: string): IVpNetHstRDM;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TVpNetHstRDM
// Help String      : VpNetHstRDM Object
// Default Interface: IVpNetHstRDM
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TVpNetHstRDMProperties= class;
{$ENDIF}
  TVpNetHstRDM = class(TOleServer)
  private
    FIntf:        IVpNetHstRDM;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TVpNetHstRDMProperties;
    function      GetServerProperties: TVpNetHstRDMProperties;
{$ENDIF}
    function      GetDefaultInterface: IVpNetHstRDM;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IVpNetHstRDM);
    procedure Disconnect; override;
    function AS_ApplyUpdates(const ProviderName: WideString; Delta: OleVariant; MaxErrors: Integer; 
                             out ErrorCount: Integer; var OwnerData: OleVariant): OleVariant;
    function AS_GetRecords(const ProviderName: WideString; Count: Integer; out RecsOut: Integer; 
                           Options: Integer; const CommandText: WideString; var Params: OleVariant; 
                           var OwnerData: OleVariant): OleVariant;
    function AS_DataRequest(const ProviderName: WideString; Data: OleVariant): OleVariant;
    function AS_GetProviderNames: OleVariant;
    function AS_GetParams(const ProviderName: WideString; var OwnerData: OleVariant): OleVariant;
    function AS_RowRequest(const ProviderName: WideString; Row: OleVariant; RequestType: Integer; 
                           var OwnerData: OleVariant): OleVariant;
    procedure AS_Execute(const ProviderName: WideString; const CommandText: WideString; 
                         var Params: OleVariant; var OwnerData: OleVariant);
    property DefaultInterface: IVpNetHstRDM read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TVpNetHstRDMProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TVpNetHstRDM
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TVpNetHstRDMProperties = class(TPersistent)
  private
    FServer:    TVpNetHstRDM;
    function    GetDefaultInterface: IVpNetHstRDM;
    constructor Create(AServer: TVpNetHstRDM);
  protected
  public
    property DefaultInterface: IVpNetHstRDM read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoVpNetHstCommDriver provides a Create and CreateRemote method to          
// create instances of the default interface IVpNetHstCommDriver exposed by              
// the CoClass VpNetHstCommDriver. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoVpNetHstCommDriver = class
    class function Create: IVpNetHstCommDriver;
    class function CreateRemote(const MachineName: string): IVpNetHstCommDriver;
  end;

  TVpNetHstCommDriverOnRecieve = procedure(ASender: TObject; Data: OleVariant; TID: Integer) of object;
  TVpNetHstCommDriverOnError = procedure(ASender: TObject; TID: Integer; ERROR_CODE: Integer; 
                                                           Data: OleVariant) of object;
  TVpNetHstCommDriverOnStartTransaction = procedure(ASender: TObject; TID: Integer) of object;
  TVpNetHstCommDriverOnPropValueChanged = procedure(ASender: TObject; vPropId: OleVariant; 
                                                                      vPropValue: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TVpNetHstCommDriver
// Help String      : VpNetHstCommDriver Object
// Default Interface: IVpNetHstCommDriver
// Def. Intf. DISP? : No
// Event   Interface: IVpNetHstCommDriverEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TVpNetHstCommDriverProperties= class;
{$ENDIF}
  TVpNetHstCommDriver = class(TOleServer)
  private
    FOnRecieve: TVpNetHstCommDriverOnRecieve;
    FOnError: TVpNetHstCommDriverOnError;
    FOnStartTransaction: TVpNetHstCommDriverOnStartTransaction;
    FOnPropValueChanged: TVpNetHstCommDriverOnPropValueChanged;
    FIntf:        IVpNetHstCommDriver;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TVpNetHstCommDriverProperties;
    function      GetServerProperties: TVpNetHstCommDriverProperties;
{$ENDIF}
    function      GetDefaultInterface: IVpNetHstCommDriver;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IVpNetHstCommDriver);
    procedure Disconnect; override;
    function Send(Data: OleVariant; BytesExpected: OleVariant; out TID: Integer): HResult;
    function GetCommDriverId(out Value: LongWord): HResult;
    function SetCommDriverId(Value: LongWord): HResult;
    function GetPropValue(vPropId: OleVariant; out vPropValue: OleVariant): HResult;
    function SetPropValue(vPropId: OleVariant; vPropValue: OleVariant): HResult;
    function GetPropNames(out vPropNames: OleVariant): HResult;
    function GetNewTID(out TID: Integer): HResult;
    property DefaultInterface: IVpNetHstCommDriver read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TVpNetHstCommDriverProperties read GetServerProperties;
{$ENDIF}
    property OnRecieve: TVpNetHstCommDriverOnRecieve read FOnRecieve write FOnRecieve;
    property OnError: TVpNetHstCommDriverOnError read FOnError write FOnError;
    property OnStartTransaction: TVpNetHstCommDriverOnStartTransaction read FOnStartTransaction write FOnStartTransaction;
    property OnPropValueChanged: TVpNetHstCommDriverOnPropValueChanged read FOnPropValueChanged write FOnPropValueChanged;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TVpNetHstCommDriver
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TVpNetHstCommDriverProperties = class(TPersistent)
  private
    FServer:    TVpNetHstCommDriver;
    function    GetDefaultInterface: IVpNetHstCommDriver;
    constructor Create(AServer: TVpNetHstCommDriver);
  protected
  public
    property DefaultInterface: IVpNetHstCommDriver read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoVpNetHstBrowser provides a Create and CreateRemote method to          
// create instances of the default interface IVpNetHstBrowser exposed by              
// the CoClass VpNetHstBrowser. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoVpNetHstBrowser = class
    class function Create: IVpNetHstBrowser;
    class function CreateRemote(const MachineName: string): IVpNetHstBrowser;
  end;

  TVpNetHstBrowserOnDriverPropValueChanged = procedure(ASender: TObject; DriverId: LongWord; 
                                                                         vPropId: OleVariant; 
                                                                         vPropValue: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TVpNetHstBrowser
// Help String      : VpNetHstBrowser Object
// Default Interface: IVpNetHstBrowser
// Def. Intf. DISP? : No
// Event   Interface: IVpNetHstBrowserEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TVpNetHstBrowserProperties= class;
{$ENDIF}
  TVpNetHstBrowser = class(TOleServer)
  private
    FOnDriverPropValueChanged: TVpNetHstBrowserOnDriverPropValueChanged;
    FIntf:        IVpNetHstBrowser;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TVpNetHstBrowserProperties;
    function      GetServerProperties: TVpNetHstBrowserProperties;
{$ENDIF}
    function      GetDefaultInterface: IVpNetHstBrowser;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IVpNetHstBrowser);
    procedure Disconnect; override;
    function ChangePosition(Direction: VpNetHstBrowseMoveDirection): HResult;
    function GetSortAttribute(out Value: VpNetHstSortAttribute): HResult;
    function SetSortAttribute(Value: VpNetHstSortAttribute): HResult;
    function GetNodeType(out Value: VpNetNodeType): HResult;
    function GetNodeId(out Value: Integer): HResult;
    function GetNodeName(out NodeName: OleVariant): HResult;
    function GetReadOnly(out ReadOnly: OleVariant): HResult;
    function GetNodeDesc(out NodeDesc: OleVariant): HResult;
    function GoToNode(aNodeId: Integer): HResult;
    function GetNodeValue(out Value: OleVariant): HResult;
    function SetNodeValue(Value: OleVariant): HResult;
    property DefaultInterface: IVpNetHstBrowser read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TVpNetHstBrowserProperties read GetServerProperties;
{$ENDIF}
    property OnDriverPropValueChanged: TVpNetHstBrowserOnDriverPropValueChanged read FOnDriverPropValueChanged write FOnDriverPropValueChanged;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TVpNetHstBrowser
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TVpNetHstBrowserProperties = class(TPersistent)
  private
    FServer:    TVpNetHstBrowser;
    function    GetDefaultInterface: IVpNetHstBrowser;
    constructor Create(AServer: TVpNetHstBrowser);
  protected
  public
    property DefaultInterface: IVpNetHstBrowser read GetDefaultInterface;
  published
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoVpNetHstRDM.Create: IVpNetHstRDM;
begin
  Result := CreateComObject(CLASS_VpNetHstRDM) as IVpNetHstRDM;
end;

class function CoVpNetHstRDM.CreateRemote(const MachineName: string): IVpNetHstRDM;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_VpNetHstRDM) as IVpNetHstRDM;
end;

procedure TVpNetHstRDM.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{347868DC-A8C1-496E-A957-9CB677D423BA}';
    IntfIID:   '{1E89E10C-F65B-4CE1-98A8-3034F0C3EF6C}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TVpNetHstRDM.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IVpNetHstRDM;
  end;
end;

procedure TVpNetHstRDM.ConnectTo(svrIntf: IVpNetHstRDM);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TVpNetHstRDM.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TVpNetHstRDM.GetDefaultInterface: IVpNetHstRDM;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TVpNetHstRDM.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TVpNetHstRDMProperties.Create(Self);
{$ENDIF}
end;

destructor TVpNetHstRDM.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TVpNetHstRDM.GetServerProperties: TVpNetHstRDMProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TVpNetHstRDM.AS_ApplyUpdates(const ProviderName: WideString; Delta: OleVariant; 
                                      MaxErrors: Integer; out ErrorCount: Integer; 
                                      var OwnerData: OleVariant): OleVariant;
begin
  Result := DefaultInterface.AS_ApplyUpdates(ProviderName, Delta, MaxErrors, ErrorCount, OwnerData);
end;

function TVpNetHstRDM.AS_GetRecords(const ProviderName: WideString; Count: Integer; 
                                    out RecsOut: Integer; Options: Integer; 
                                    const CommandText: WideString; var Params: OleVariant; 
                                    var OwnerData: OleVariant): OleVariant;
begin
  Result := DefaultInterface.AS_GetRecords(ProviderName, Count, RecsOut, Options, CommandText, 
                                           Params, OwnerData);
end;

function TVpNetHstRDM.AS_DataRequest(const ProviderName: WideString; Data: OleVariant): OleVariant;
begin
  Result := DefaultInterface.AS_DataRequest(ProviderName, Data);
end;

function TVpNetHstRDM.AS_GetProviderNames: OleVariant;
begin
  Result := DefaultInterface.AS_GetProviderNames;
end;

function TVpNetHstRDM.AS_GetParams(const ProviderName: WideString; var OwnerData: OleVariant): OleVariant;
begin
  Result := DefaultInterface.AS_GetParams(ProviderName, OwnerData);
end;

function TVpNetHstRDM.AS_RowRequest(const ProviderName: WideString; Row: OleVariant; 
                                    RequestType: Integer; var OwnerData: OleVariant): OleVariant;
begin
  Result := DefaultInterface.AS_RowRequest(ProviderName, Row, RequestType, OwnerData);
end;

procedure TVpNetHstRDM.AS_Execute(const ProviderName: WideString; const CommandText: WideString; 
                                  var Params: OleVariant; var OwnerData: OleVariant);
begin
  DefaultInterface.AS_Execute(ProviderName, CommandText, Params, OwnerData);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TVpNetHstRDMProperties.Create(AServer: TVpNetHstRDM);
begin
  inherited Create;
  FServer := AServer;
end;

function TVpNetHstRDMProperties.GetDefaultInterface: IVpNetHstRDM;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

class function CoVpNetHstCommDriver.Create: IVpNetHstCommDriver;
begin
  Result := CreateComObject(CLASS_VpNetHstCommDriver) as IVpNetHstCommDriver;
end;

class function CoVpNetHstCommDriver.CreateRemote(const MachineName: string): IVpNetHstCommDriver;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_VpNetHstCommDriver) as IVpNetHstCommDriver;
end;

procedure TVpNetHstCommDriver.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{DA455469-88DB-4E68-AEC0-D977645BDACD}';
    IntfIID:   '{EA298CDE-94C5-4A4E-858B-6C0CDEF97651}';
    EventIID:  '{E2E41F10-B721-4EDD-B78E-CCFE9545BBC7}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TVpNetHstCommDriver.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IVpNetHstCommDriver;
  end;
end;

procedure TVpNetHstCommDriver.ConnectTo(svrIntf: IVpNetHstCommDriver);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TVpNetHstCommDriver.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TVpNetHstCommDriver.GetDefaultInterface: IVpNetHstCommDriver;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TVpNetHstCommDriver.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TVpNetHstCommDriverProperties.Create(Self);
{$ENDIF}
end;

destructor TVpNetHstCommDriver.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TVpNetHstCommDriver.GetServerProperties: TVpNetHstCommDriverProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TVpNetHstCommDriver.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
    272: if Assigned(FOnRecieve) then
         FOnRecieve(Self,
                    Params[0] {OleVariant},
                    Params[1] {Integer});
    273: if Assigned(FOnError) then
         FOnError(Self,
                  Params[0] {Integer},
                  Params[1] {Integer},
                  Params[2] {OleVariant});
    274: if Assigned(FOnStartTransaction) then
         FOnStartTransaction(Self, Params[0] {Integer});
    275: if Assigned(FOnPropValueChanged) then
         FOnPropValueChanged(Self,
                             Params[0] {OleVariant},
                             Params[1] {OleVariant});
  end; {case DispID}
end;

function TVpNetHstCommDriver.Send(Data: OleVariant; BytesExpected: OleVariant; out TID: Integer): HResult;
begin
  Result := DefaultInterface.Send(Data, BytesExpected, TID);
end;

function TVpNetHstCommDriver.GetCommDriverId(out Value: LongWord): HResult;
begin
  Result := DefaultInterface.GetCommDriverId(Value);
end;

function TVpNetHstCommDriver.SetCommDriverId(Value: LongWord): HResult;
begin
  Result := DefaultInterface.SetCommDriverId(Value);
end;

function TVpNetHstCommDriver.GetPropValue(vPropId: OleVariant; out vPropValue: OleVariant): HResult;
begin
  Result := DefaultInterface.GetPropValue(vPropId, vPropValue);
end;

function TVpNetHstCommDriver.SetPropValue(vPropId: OleVariant; vPropValue: OleVariant): HResult;
begin
  Result := DefaultInterface.SetPropValue(vPropId, vPropValue);
end;

function TVpNetHstCommDriver.GetPropNames(out vPropNames: OleVariant): HResult;
begin
  Result := DefaultInterface.GetPropNames(vPropNames);
end;

function TVpNetHstCommDriver.GetNewTID(out TID: Integer): HResult;
begin
  Result := DefaultInterface.GetNewTID(TID);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TVpNetHstCommDriverProperties.Create(AServer: TVpNetHstCommDriver);
begin
  inherited Create;
  FServer := AServer;
end;

function TVpNetHstCommDriverProperties.GetDefaultInterface: IVpNetHstCommDriver;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

class function CoVpNetHstBrowser.Create: IVpNetHstBrowser;
begin
  Result := CreateComObject(CLASS_VpNetHstBrowser) as IVpNetHstBrowser;
end;

class function CoVpNetHstBrowser.CreateRemote(const MachineName: string): IVpNetHstBrowser;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_VpNetHstBrowser) as IVpNetHstBrowser;
end;

procedure TVpNetHstBrowser.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{1E402F83-EBD6-4FBA-8136-6229BE7CCE0E}';
    IntfIID:   '{F76C9D17-9644-4790-AF1F-0A674F9A13BC}';
    EventIID:  '{5F266B2F-3C5C-4D4A-9B3E-2170F2D2ECCF}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TVpNetHstBrowser.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IVpNetHstBrowser;
  end;
end;

procedure TVpNetHstBrowser.ConnectTo(svrIntf: IVpNetHstBrowser);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TVpNetHstBrowser.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TVpNetHstBrowser.GetDefaultInterface: IVpNetHstBrowser;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TVpNetHstBrowser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TVpNetHstBrowserProperties.Create(Self);
{$ENDIF}
end;

destructor TVpNetHstBrowser.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TVpNetHstBrowser.GetServerProperties: TVpNetHstBrowserProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TVpNetHstBrowser.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
    201: if Assigned(FOnDriverPropValueChanged) then
         FOnDriverPropValueChanged(Self,
                                   Params[0] {LongWord},
                                   Params[1] {OleVariant},
                                   Params[2] {OleVariant});
  end; {case DispID}
end;

function TVpNetHstBrowser.ChangePosition(Direction: VpNetHstBrowseMoveDirection): HResult;
begin
  Result := DefaultInterface.ChangePosition(Direction);
end;

function TVpNetHstBrowser.GetSortAttribute(out Value: VpNetHstSortAttribute): HResult;
begin
  Result := DefaultInterface.GetSortAttribute(Value);
end;

function TVpNetHstBrowser.SetSortAttribute(Value: VpNetHstSortAttribute): HResult;
begin
  Result := DefaultInterface.SetSortAttribute(Value);
end;

function TVpNetHstBrowser.GetNodeType(out Value: VpNetNodeType): HResult;
begin
  Result := DefaultInterface.GetNodeType(Value);
end;

function TVpNetHstBrowser.GetNodeId(out Value: Integer): HResult;
begin
  Result := DefaultInterface.GetNodeId(Value);
end;

function TVpNetHstBrowser.GetNodeName(out NodeName: OleVariant): HResult;
begin
  Result := DefaultInterface.GetNodeName(NodeName);
end;

function TVpNetHstBrowser.GetReadOnly(out ReadOnly: OleVariant): HResult;
begin
  Result := DefaultInterface.GetReadOnly(ReadOnly);
end;

function TVpNetHstBrowser.GetNodeDesc(out NodeDesc: OleVariant): HResult;
begin
  Result := DefaultInterface.GetNodeDesc(NodeDesc);
end;

function TVpNetHstBrowser.GoToNode(aNodeId: Integer): HResult;
begin
  Result := DefaultInterface.GoToNode(aNodeId);
end;

function TVpNetHstBrowser.GetNodeValue(out Value: OleVariant): HResult;
begin
  Result := DefaultInterface.GetNodeValue(Value);
end;

function TVpNetHstBrowser.SetNodeValue(Value: OleVariant): HResult;
begin
  Result := DefaultInterface.SetNodeValue(Value);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TVpNetHstBrowserProperties.Create(AServer: TVpNetHstBrowser);
begin
  inherited Create;
  FServer := AServer;
end;

function TVpNetHstBrowserProperties.GetDefaultInterface: IVpNetHstBrowser;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TVpNetHstRDM, TVpNetHstCommDriver, TVpNetHstBrowser]);
end;

end.
