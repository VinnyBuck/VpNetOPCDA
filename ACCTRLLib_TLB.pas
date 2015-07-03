unit ACCTRLLib_TLB;

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
// File generated on 08.12.2008 22:16:29 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Program Files\Common Files\Autodesk Shared\acctrl.dll (1)
// LIBID: {EB54BB24-1CF3-44C9-8978-D1E8E5641775}
// LCID: 0
// Helpfile: 
// HelpString: AcCtrl Component
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, OleServer, StdVCL, Variants;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  ACCTRLLibMajorVersion = 1;
  ACCTRLLibMinorVersion = 0;

  LIBID_ACCTRLLib: TGUID = '{EB54BB24-1CF3-44C9-8978-D1E8E5641775}';

  IID_IAcCtrl: TGUID = '{FA08CFC7-B95C-4195-A3B2-B505DE4F1724}';
  CLASS_AcCtrl: TGUID = '{12490290-02E9-4B5E-BE0A-38E27EB98150}';
  IID_IAcCtrlApplication: TGUID = '{0DF7EE11-3826-11D5-96EB-001083341C20}';
  CLASS_AcCtrlApplication: TGUID = '{261BD07B-7832-49F6-9D6F-D04E02185168}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IAcCtrl = interface;
  IAcCtrlDisp = dispinterface;
  IAcCtrlApplication = interface;
  IAcCtrlApplicationDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  AcCtrl = IAcCtrl;
  AcCtrlApplication = IAcCtrlApplication;


// *********************************************************************//
// Interface: IAcCtrl
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FA08CFC7-B95C-4195-A3B2-B505DE4F1724}
// *********************************************************************//
  IAcCtrl = interface(IDispatch)
    ['{FA08CFC7-B95C-4195-A3B2-B505DE4F1724}']
    function Get_Src: WideString; safecall;
    procedure Set_Src(const pVal: WideString); safecall;
    procedure PostCommand(const bstrCmd: WideString); safecall;
    property Src: WideString read Get_Src write Set_Src;
  end;

// *********************************************************************//
// DispIntf:  IAcCtrlDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FA08CFC7-B95C-4195-A3B2-B505DE4F1724}
// *********************************************************************//
  IAcCtrlDisp = dispinterface
    ['{FA08CFC7-B95C-4195-A3B2-B505DE4F1724}']
    property Src: WideString dispid 1;
    procedure PostCommand(const bstrCmd: WideString); dispid 2;
  end;

// *********************************************************************//
// Interface: IAcCtrlApplication
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0DF7EE11-3826-11D5-96EB-001083341C20}
// *********************************************************************//
  IAcCtrlApplication = interface(IDispatch)
    ['{0DF7EE11-3826-11D5-96EB-001083341C20}']
    function CreateInstanceOnServer(const rclsid: WideString): IDispatch; safecall;
  end;

// *********************************************************************//
// DispIntf:  IAcCtrlApplicationDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0DF7EE11-3826-11D5-96EB-001083341C20}
// *********************************************************************//
  IAcCtrlApplicationDisp = dispinterface
    ['{0DF7EE11-3826-11D5-96EB-001083341C20}']
    function CreateInstanceOnServer(const rclsid: WideString): IDispatch; dispid 1;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TAcCtrl
// Help String      : AcCtrl Class
// Default Interface: IAcCtrl
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TAcCtrl = class(TOleControl)
  private
    FIntf: IAcCtrl;
    function  GetControlInterface: IAcCtrl;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    procedure PostCommand(const bstrCmd: WideString);
    property  ControlInterface: IAcCtrl read GetControlInterface;
    property  DefaultInterface: IAcCtrl read GetControlInterface;
  published
    property Anchors;
    property  TabStop;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  Visible;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property Src: WideString index 1 read GetWideStringProp write SetWideStringProp stored False;
  end;

// *********************************************************************//
// The Class CoAcCtrlApplication provides a Create and CreateRemote method to          
// create instances of the default interface IAcCtrlApplication exposed by              
// the CoClass AcCtrlApplication. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAcCtrlApplication = class
    class function Create: IAcCtrlApplication;
    class function CreateRemote(const MachineName: string): IAcCtrlApplication;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TAcCtrl.InitControlData;
const
  CControlData: TControlData2 = (
    ClassID: '{12490290-02E9-4B5E-BE0A-38E27EB98150}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: nil (*HR:$80004002*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
end;

procedure TAcCtrl.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IAcCtrl;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TAcCtrl.GetControlInterface: IAcCtrl;
begin
  CreateControl;
  Result := FIntf;
end;

procedure TAcCtrl.PostCommand(const bstrCmd: WideString);
begin
  DefaultInterface.PostCommand(bstrCmd);
end;

class function CoAcCtrlApplication.Create: IAcCtrlApplication;
begin
  Result := CreateComObject(CLASS_AcCtrlApplication) as IAcCtrlApplication;
end;

class function CoAcCtrlApplication.CreateRemote(const MachineName: string): IAcCtrlApplication;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_AcCtrlApplication) as IAcCtrlApplication;
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TAcCtrl]);
end;

end.
