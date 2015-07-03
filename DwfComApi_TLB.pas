unit DwfComApi_TLB;

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
// File generated on 08.12.2008 22:34:06 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Program Files\Autodesk\Autodesk Design Review\EComposite\DwfComApi.dll (1)
// LIBID: {44B9DE59-8111-4850-A89C-0AF6B2F46D2B}
// LCID: 0
// Helpfile: 
// HelpString: DesignReview DwfComApi 1.0 Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
// Errors:
//   Hint: Member 'Object' of 'IAdContent2' changed to 'Object_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Error creating palette bitmap of (TCAdApiUtility) : Server C:\Program Files\Autodesk\Autodesk Design Review\EComposite\DwfComApi.dll contains no icons
//   Error creating palette bitmap of (TCAdContent) : Server C:\Program Files\Autodesk\Autodesk Design Review\EComposite\DwfComApi.dll contains no icons
//   Error creating palette bitmap of (TCAdMarkupEditor) : Server C:\Program Files\Autodesk\Autodesk Design Review\EComposite\DwfComApi.dll contains no icons
//   Error creating palette bitmap of (TCAdObject) : Server C:\Program Files\Autodesk\Autodesk Design Review\EComposite\DwfComApi.dll contains no icons
//   Error creating palette bitmap of (TCAdProperty2) : Server C:\Program Files\Autodesk\Autodesk Design Review\EComposite\DwfComApi.dll contains no icons
//   Error creating palette bitmap of (TCPrivateRelayEventContent) : Server C:\Program Files\Autodesk\Autodesk Design Review\EComposite\DwfComApi.dll contains no icons
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

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  DwfComApiMajorVersion = 1;
  DwfComApiMinorVersion = 0;

  LIBID_DwfComApi: TGUID = '{44B9DE59-8111-4850-A89C-0AF6B2F46D2B}';

  IID_IAdViewer: TGUID = '{EECA56CF-BF35-4D80-BC35-488F1B6536A6}';
  DIID_IAdViewerEvents: TGUID = '{A7D421C8-FC4D-488F-AA61-4FEC541A57B8}';
  IID_IAdMarkupEditor: TGUID = '{3ABA218C-860E-41DE-BE78-02A3B906CBDC}';
  IID_IAdMarkupEditor2: TGUID = '{9164A5E6-9383-4204-9DCE-5701DC7AAF37}';
  DIID_IAdMarkupEditorEvents: TGUID = '{194AD7DC-FD2F-46A6-A733-C813EDC8FB91}';
  IID_IAdEventRelayer: TGUID = '{01F01418-83A0-400C-B3AA-D8CC34F38E3F}';
  IID_IAdDwfViewer: TGUID = '{8A5E1971-62C6-4EA0-B943-6F2833F7AC2C}';
  IID_IAdDwfViewer2: TGUID = '{5038F2F6-AE03-453B-966E-0D39A564BEB2}';
  IID_IAdServiceHandler: TGUID = '{BEB61016-3525-441C-ADB9-404C8EDBCC8C}';
  IID_IAdServiceHandler2: TGUID = '{8B47C55C-DE6A-4B42-ADB7-C57328C83904}';
  IID_IAdAboutBox: TGUID = '{0B2286BE-6357-4C1A-972B-18AE722756A6}';
  IID_IAdContent: TGUID = '{01FE3951-5AF6-4C46-9F6D-E0B38D13355E}';
  IID_IAdContent2: TGUID = '{A683A7FB-96D7-424D-8E53-8B973F847D7B}';
  IID_IAdContextMenuListEntry: TGUID = '{B1FB99F1-15FB-4907-B6B3-AE5AAB0E6E6C}';
  IID_IAdContextMenu: TGUID = '{A5180048-6FD7-4AA3-8AE1-005B624E6547}';
  IID_IAdObject: TGUID = '{15388997-D4A8-486C-AA37-21D319112744}';
  IID_IAdObject2: TGUID = '{2199B630-3012-40E4-B255-6236EF73E9FE}';
  IID_IAdViewerEvent_Base: TGUID = '{2A3F3A98-5463-4148-86BC-FC8386664D05}';
  IID_IAdViewerEvent_UpdateUiItem: TGUID = '{63D75159-E513-4EFC-BFDA-4486D736BBB5}';
  IID_IAdViewerEvent_ShowUiItem: TGUID = '{4EF56DDF-B335-4117-B1CF-5960DD29C3D0}';
  IID_ICreateUIMenuItem: TGUID = '{E4554757-B9EB-41A4-90F3-67BB35AAF669}';
  IID_IAdSection: TGUID = '{88D25E7A-B0C7-4DF2-91AD-EF7A1CEF22FD}';
  IID_IAdSectionPrivate: TGUID = '{4FC504B0-45FE-48DA-A0DB-CA0E91BA34C5}';
  IID_IAdSectionPrivate2: TGUID = '{D3056730-81A9-4C5E-8494-D20AE5DC8171}';
  IID_IAdSectionType: TGUID = '{B62082F1-F5C8-4EBC-806A-B3D43EDF0629}';
  IID_IAdSectionTypePrivate: TGUID = '{47C59FE2-CED9-4CAD-8E93-1C34C028799F}';
  IID_IAdComProxy: TGUID = '{FA831959-EB3A-461C-ACA2-50ED2C7B2F64}';
  IID_IAdComProxy2: TGUID = '{A7AEA01B-65E4-4119-B78C-6A7E3E09EEE8}';
  IID_IAdECompositeViewer: TGUID = '{81833E05-B5BD-433A-BAEE-58F46B1261EE}';
  IID_IAdECompositeViewer2: TGUID = '{B73C9E23-0A58-4E18-8E31-AEF5E4003120}';
  IID_IAdECompositeViewerPrivate: TGUID = '{2CC12E7B-254E-4555-9874-7931E5E49260}';
  IID_IAdECompositeViewerPrivate2: TGUID = '{70B89B01-66CA-4097-AB8E-472D6AB56B4D}';
  IID_IAdECompositeViewerPrivate3: TGUID = '{6A588D68-5702-4CD1-ACB7-EF55BF3222DD}';
  IID_IAdECompositeViewerPrivate4: TGUID = '{1FEBB6CC-9588-4513-AB58-E09F42EEAAEC}';
  IID_IAdPageNavigatorCtrl: TGUID = '{43F5A909-56B9-4106-9472-27D9BDE5B745}';
  IID_IAdBookmark: TGUID = '{92ABF954-74B1-410A-AFEF-8FCC53FB9655}';
  IID_IAdUiMediator: TGUID = '{1A49003C-9870-4453-A838-90E086C93F48}';
  IID_IAdUiBandFocusMediator: TGUID = '{0440EE56-C13E-4448-9D0D-7AFB29E7D9F5}';
  DIID_IMarkupEvents: TGUID = '{B719F3CC-3718-422D-9D5E-C6579ED318E5}';
  IID_IAdCommand: TGUID = '{A15A152A-3F26-4C90-BC0F-EEFCD5869652}';
  IID_IAdPaper: TGUID = '{D82B647D-FDCC-45D8-8DC7-841707689D73}';
  IID_IAdDwfImporter: TGUID = '{D59A8E1B-97BB-4887-AF66-58B725CBA693}';
  IID_IAdDwfExporter: TGUID = '{A6285F26-E69F-49CD-BE72-6E80C7A675F4}';
  IID_IAdInstanceTreeNode: TGUID = '{AAE5A642-DE55-479F-B83E-AB7BA6FF29EE}';
  IID_IAdPrivateRelayEvent: TGUID = '{81F93F5A-E932-42B5-99CF-6EFF7C57BE07}';
  IID_IAdPrivateRelayEventContent: TGUID = '{93601283-B854-4145-A8B3-64045EFE95D5}';
  IID_IAdAdvControlGuest: TGUID = '{1222F2F5-36B7-4A5B-A72D-5AA26B032F27}';
  IID_IAdServiceHandlerFinder: TGUID = '{899B70A5-962E-41BA-A5B3-264A6D18B2D2}';
  IID_IAdDwfImportManager: TGUID = '{DF424690-E891-400C-969E-421DA3F95C2E}';
  IID_IAdDwfImportManager2: TGUID = '{D0A650D1-B17B-4109-80E2-FEBBA4FA2A84}';
  IID_IAdDwfExportManager: TGUID = '{3A1596AC-0D1E-4014-930C-5408A58905A0}';
  IID_IAdInstance: TGUID = '{C5E36A54-46E7-4F4F-B21F-A7BCA2117FDC}';
  IID_IAdOptionsTabs: TGUID = '{19EA6C8E-1395-4AF5-B7CD-296D075FD040}';
  IID_IAdStreamLength: TGUID = '{73F4AF60-C28A-4017-934E-18E2FB408A64}';
  IID_IAdUiControlPrivate: TGUID = '{70839354-8F67-4F84-AB07-C85103E2F1A2}';
  IID_IAdApiUtility: TGUID = '{02B244B4-C55F-4BC0-B087-C0B86495F58F}';
  CLASS_CAdApiUtility: TGUID = '{718B86EE-E4D5-423E-A913-72814ADF26D4}';
  CLASS_CAdContent: TGUID = '{2AA8F53C-1EA6-42FE-A708-C5F4D6F6CD32}';
  CLASS_CAdMarkupEditor: TGUID = '{FC28F100-41C5-4E43-B77C-DFB8BB1A1B8D}';
  CLASS_CAdObject: TGUID = '{B8163F08-E4B9-4EB9-9A42-1A38D6440A1F}';
  IID_IAdProperty: TGUID = '{9045091A-0DE5-4588-B0D8-442463A1C788}';
  IID_IAdPropertyPrivate: TGUID = '{6FC55A00-A3E8-493C-A949-A2259C35BE53}';
  CLASS_CAdProperty2: TGUID = '{527424CA-A43F-45DE-BFF8-976954CFC945}';
  CLASS_CPrivateRelayEventContent: TGUID = '{B98405F9-DEBB-490B-901F-1F01E49B146B}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IAdViewer = interface;
  IAdViewerDisp = dispinterface;
  IAdViewerEvents = dispinterface;
  IAdMarkupEditor = interface;
  IAdMarkupEditorDisp = dispinterface;
  IAdMarkupEditor2 = interface;
  IAdMarkupEditor2Disp = dispinterface;
  IAdMarkupEditorEvents = dispinterface;
  IAdEventRelayer = interface;
  IAdEventRelayerDisp = dispinterface;
  IAdDwfViewer = interface;
  IAdDwfViewerDisp = dispinterface;
  IAdDwfViewer2 = interface;
  IAdDwfViewer2Disp = dispinterface;
  IAdServiceHandler = interface;
  IAdServiceHandler2 = interface;
  IAdAboutBox = interface;
  IAdContent = interface;
  IAdContentDisp = dispinterface;
  IAdContent2 = interface;
  IAdContent2Disp = dispinterface;
  IAdContextMenuListEntry = interface;
  IAdContextMenuListEntryDisp = dispinterface;
  IAdContextMenu = interface;
  IAdContextMenuDisp = dispinterface;
  IAdObject = interface;
  IAdObjectDisp = dispinterface;
  IAdObject2 = interface;
  IAdObject2Disp = dispinterface;
  IAdViewerEvent_Base = interface;
  IAdViewerEvent_BaseDisp = dispinterface;
  IAdViewerEvent_UpdateUiItem = interface;
  IAdViewerEvent_UpdateUiItemDisp = dispinterface;
  IAdViewerEvent_ShowUiItem = interface;
  IAdViewerEvent_ShowUiItemDisp = dispinterface;
  ICreateUIMenuItem = interface;
  ICreateUIMenuItemDisp = dispinterface;
  IAdSection = interface;
  IAdSectionDisp = dispinterface;
  IAdSectionPrivate = interface;
  IAdSectionPrivate2 = interface;
  IAdSectionType = interface;
  IAdSectionTypeDisp = dispinterface;
  IAdSectionTypePrivate = interface;
  IAdComProxy = interface;
  IAdComProxy2 = interface;
  IAdECompositeViewer = interface;
  IAdECompositeViewerDisp = dispinterface;
  IAdECompositeViewer2 = interface;
  IAdECompositeViewer2Disp = dispinterface;
  IAdECompositeViewerPrivate = interface;
  IAdECompositeViewerPrivate2 = interface;
  IAdECompositeViewerPrivate3 = interface;
  IAdECompositeViewerPrivate4 = interface;
  IAdPageNavigatorCtrl = interface;
  IAdPageNavigatorCtrlDisp = dispinterface;
  IAdBookmark = interface;
  IAdBookmarkDisp = dispinterface;
  IAdUiMediator = interface;
  IAdUiBandFocusMediator = interface;
  IMarkupEvents = dispinterface;
  IAdCommand = interface;
  IAdCommandDisp = dispinterface;
  IAdPaper = interface;
  IAdPaperDisp = dispinterface;
  IAdDwfImporter = interface;
  IAdDwfExporter = interface;
  IAdInstanceTreeNode = interface;
  IAdPrivateRelayEvent = interface;
  IAdPrivateRelayEventDisp = dispinterface;
  IAdPrivateRelayEventContent = interface;
  IAdPrivateRelayEventContentDisp = dispinterface;
  IAdAdvControlGuest = interface;
  IAdServiceHandlerFinder = interface;
  IAdDwfImportManager = interface;
  IAdDwfImportManager2 = interface;
  IAdDwfExportManager = interface;
  IAdInstance = interface;
  IAdInstanceDisp = dispinterface;
  IAdOptionsTabs = interface;
  IAdStreamLength = interface;
  IAdUiControlPrivate = interface;
  IAdApiUtility = interface;
  IAdApiUtilityDisp = dispinterface;
  IAdProperty = interface;
  IAdPropertyDisp = dispinterface;
  IAdPropertyPrivate = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CAdApiUtility = IAdApiUtility;
  CAdContent = IAdContent2;
  CAdMarkupEditor = IAdMarkupEditor2;
  CAdObject = IAdObject2;
  CAdProperty2 = IAdProperty;
  CPrivateRelayEventContent = IAdPrivateRelayEventContent;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PWideString1 = ^WideString; {*}
  POleVariant1 = ^OleVariant; {*}
  PWordBool1 = ^WordBool; {*}
  PInteger1 = ^Integer; {*}
  PPUserType1 = ^IAdServiceHandler; {*}
  PIDispatch1 = ^IDispatch; {*}


// *********************************************************************//
// Interface: IAdViewer
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EECA56CF-BF35-4D80-BC35-488F1B6536A6}
// *********************************************************************//
  IAdViewer = interface(IDispatch)
    ['{EECA56CF-BF35-4D80-BC35-488F1B6536A6}']
    function Get_BackColor: OLE_COLOR; safecall;
    procedure Set_BackColor(pVal: OLE_COLOR); safecall;
    function Get_EmbedSourceDocument: WordBool; safecall;
    procedure Set_EmbedSourceDocument(pVal: WordBool); safecall;
    function Get_SourcePath: WideString; safecall;
    procedure Set_SourcePath(const pVal: WideString); safecall;
    function Get_Viewer: IDispatch; safecall;
    procedure ShowPrintDialog; safecall;
    procedure NavigateToUrl(const bstrUrl: WideString); safecall;
    procedure ExecuteCommand(const bstrCommand: WideString); safecall;
    procedure DrawToDC(nDc: Integer; nLeft: Integer; nTop: Integer; nRight: Integer; 
                       nBottom: Integer); safecall;
    function Get__ActiveWindow: OleVariant; safecall;
    function Get__ClientWindow: OleVariant; safecall;
    function Get__DocumentParams: WideString; safecall;
    function Get__HistoryParams: WideString; safecall;
    function Get__LocalFilePath: WideString; safecall;
    procedure Set__SourceStream(const Param1: IUnknown); safecall;
    procedure Set__ViewerParams(const pVal: WideString); safecall;
    function Get__ViewerParams: WideString; safecall;
    procedure _GoBack; safecall;
    procedure _GoForward; safecall;
    procedure _SaveHistory; safecall;
    procedure _ShowHelp(const bstrTopic: WideString); safecall;
    function Get_DocumentHandler: IDispatch; safecall;
    function Get_DocumentType: WideString; safecall;
    procedure ExecuteCommandEx(const bstrCommand: WideString; lVal: Integer); safecall;
    function Get_GradientBackgroundColor: OLE_COLOR; safecall;
    procedure Set_GradientBackgroundColor(pVal: OLE_COLOR); safecall;
    function Get_GradientBackgroundEnabled: WordBool; safecall;
    procedure Set_GradientBackgroundEnabled(pVal: WordBool); safecall;
    function Get_ContextMenu: IDispatch; safecall;
    procedure Set_ContextMenu(const pVal: IDispatch); safecall;
    function Get_CanvasEmpty: WordBool; safecall;
    procedure Set_CanvasEmpty(pVal: WordBool); safecall;
    function Get_ReservedProperty05: OleVariant; safecall;
    procedure Set_ReservedProperty05(pVal: OleVariant); safecall;
    function Get_ReservedProperty06: OleVariant; safecall;
    procedure Set_ReservedProperty06(pVal: OleVariant); safecall;
    function Get_ReservedProperty07: OleVariant; safecall;
    procedure Set_ReservedProperty07(pVal: OleVariant); safecall;
    function Get_ReservedProperty08: OleVariant; safecall;
    procedure Set_ReservedProperty08(pVal: OleVariant); safecall;
    function Get_ReservedProperty09: OleVariant; safecall;
    procedure Set_ReservedProperty09(pVal: OleVariant); safecall;
    function Get_ReservedProperty10: OleVariant; safecall;
    procedure Set_ReservedProperty10(pVal: OleVariant); safecall;
    function Get_ReservedProperty11: OleVariant; safecall;
    procedure Set_ReservedProperty11(pVal: OleVariant); safecall;
    function Get_ReservedProperty12: OleVariant; safecall;
    procedure Set_ReservedProperty12(pVal: OleVariant); safecall;
    function Get_ReservedProperty13: OleVariant; safecall;
    procedure Set_ReservedProperty13(pVal: OleVariant); safecall;
    function Get_ReservedProperty14: OleVariant; safecall;
    procedure Set_ReservedProperty14(pVal: OleVariant); safecall;
    function Get_ReservedProperty15: OleVariant; safecall;
    procedure Set_ReservedProperty15(pVal: OleVariant); safecall;
    function Get_ReservedProperty16: OleVariant; safecall;
    procedure Set_ReservedProperty16(pVal: OleVariant); safecall;
    function Get_ReservedProperty17: OleVariant; safecall;
    procedure Set_ReservedProperty17(pVal: OleVariant); safecall;
    function Get_ReservedProperty18: OleVariant; safecall;
    procedure Set_ReservedProperty18(pVal: OleVariant); safecall;
    function Get_ReservedProperty19: OleVariant; safecall;
    procedure Set_ReservedProperty19(pVal: OleVariant); safecall;
    function Get_ReservedProperty20: OleVariant; safecall;
    procedure Set_ReservedProperty20(pVal: OleVariant); safecall;
    procedure _ShowCIPDialog; safecall;
    procedure ReservedMethod02; safecall;
    procedure ReservedMethod03; safecall;
    procedure ReservedMethod04; safecall;
    procedure ReservedMethod05; safecall;
    procedure ReservedMethod06; safecall;
    procedure ReservedMethod07; safecall;
    procedure ReservedMethod08; safecall;
    procedure ReservedMethod09; safecall;
    procedure ReservedMethod10; safecall;
    procedure ReservedMethod11; safecall;
    procedure ReservedMethod12; safecall;
    procedure ReservedMethod13; safecall;
    procedure ReservedMethod14; safecall;
    procedure ReservedMethod15; safecall;
    procedure ReservedMethod16; safecall;
    procedure ReservedMethod17; safecall;
    procedure ReservedMethod18; safecall;
    procedure ReservedMethod19; safecall;
    procedure ReservedMethod20; safecall;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property EmbedSourceDocument: WordBool read Get_EmbedSourceDocument write Set_EmbedSourceDocument;
    property SourcePath: WideString read Get_SourcePath write Set_SourcePath;
    property Viewer: IDispatch read Get_Viewer;
    property _ActiveWindow: OleVariant read Get__ActiveWindow;
    property _ClientWindow: OleVariant read Get__ClientWindow;
    property _DocumentParams: WideString read Get__DocumentParams;
    property _HistoryParams: WideString read Get__HistoryParams;
    property _LocalFilePath: WideString read Get__LocalFilePath;
    property _SourceStream: IUnknown write Set__SourceStream;
    property _ViewerParams: WideString read Get__ViewerParams write Set__ViewerParams;
    property DocumentHandler: IDispatch read Get_DocumentHandler;
    property DocumentType: WideString read Get_DocumentType;
    property GradientBackgroundColor: OLE_COLOR read Get_GradientBackgroundColor write Set_GradientBackgroundColor;
    property GradientBackgroundEnabled: WordBool read Get_GradientBackgroundEnabled write Set_GradientBackgroundEnabled;
    property ContextMenu: IDispatch read Get_ContextMenu write Set_ContextMenu;
    property CanvasEmpty: WordBool read Get_CanvasEmpty write Set_CanvasEmpty;
    property ReservedProperty05: OleVariant read Get_ReservedProperty05 write Set_ReservedProperty05;
    property ReservedProperty06: OleVariant read Get_ReservedProperty06 write Set_ReservedProperty06;
    property ReservedProperty07: OleVariant read Get_ReservedProperty07 write Set_ReservedProperty07;
    property ReservedProperty08: OleVariant read Get_ReservedProperty08 write Set_ReservedProperty08;
    property ReservedProperty09: OleVariant read Get_ReservedProperty09 write Set_ReservedProperty09;
    property ReservedProperty10: OleVariant read Get_ReservedProperty10 write Set_ReservedProperty10;
    property ReservedProperty11: OleVariant read Get_ReservedProperty11 write Set_ReservedProperty11;
    property ReservedProperty12: OleVariant read Get_ReservedProperty12 write Set_ReservedProperty12;
    property ReservedProperty13: OleVariant read Get_ReservedProperty13 write Set_ReservedProperty13;
    property ReservedProperty14: OleVariant read Get_ReservedProperty14 write Set_ReservedProperty14;
    property ReservedProperty15: OleVariant read Get_ReservedProperty15 write Set_ReservedProperty15;
    property ReservedProperty16: OleVariant read Get_ReservedProperty16 write Set_ReservedProperty16;
    property ReservedProperty17: OleVariant read Get_ReservedProperty17 write Set_ReservedProperty17;
    property ReservedProperty18: OleVariant read Get_ReservedProperty18 write Set_ReservedProperty18;
    property ReservedProperty19: OleVariant read Get_ReservedProperty19 write Set_ReservedProperty19;
    property ReservedProperty20: OleVariant read Get_ReservedProperty20 write Set_ReservedProperty20;
  end;

// *********************************************************************//
// DispIntf:  IAdViewerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EECA56CF-BF35-4D80-BC35-488F1B6536A6}
// *********************************************************************//
  IAdViewerDisp = dispinterface
    ['{EECA56CF-BF35-4D80-BC35-488F1B6536A6}']
    property BackColor: OLE_COLOR dispid -501;
    property EmbedSourceDocument: WordBool dispid 3;
    property SourcePath: WideString dispid 1;
    property Viewer: IDispatch readonly dispid 2;
    procedure ShowPrintDialog; dispid 101;
    procedure NavigateToUrl(const bstrUrl: WideString); dispid 103;
    procedure ExecuteCommand(const bstrCommand: WideString); dispid 104;
    procedure DrawToDC(nDc: Integer; nLeft: Integer; nTop: Integer; nRight: Integer; 
                       nBottom: Integer); dispid 105;
    property _ActiveWindow: OleVariant readonly dispid 200;
    property _ClientWindow: OleVariant readonly dispid 202;
    property _DocumentParams: WideString readonly dispid 203;
    property _HistoryParams: WideString readonly dispid 204;
    property _LocalFilePath: WideString readonly dispid 205;
    property _SourceStream: IUnknown writeonly dispid 206;
    property _ViewerParams: WideString dispid 201;
    procedure _GoBack; dispid 300;
    procedure _GoForward; dispid 301;
    procedure _SaveHistory; dispid 302;
    procedure _ShowHelp(const bstrTopic: WideString); dispid 303;
    property DocumentHandler: IDispatch readonly dispid 106;
    property DocumentType: WideString readonly dispid 107;
    procedure ExecuteCommandEx(const bstrCommand: WideString; lVal: Integer); dispid 108;
    property GradientBackgroundColor: OLE_COLOR dispid 401;
    property GradientBackgroundEnabled: WordBool dispid 402;
    property ContextMenu: IDispatch dispid 403;
    property CanvasEmpty: WordBool dispid 404;
    property ReservedProperty05: OleVariant dispid 405;
    property ReservedProperty06: OleVariant dispid 406;
    property ReservedProperty07: OleVariant dispid 407;
    property ReservedProperty08: OleVariant dispid 408;
    property ReservedProperty09: OleVariant dispid 409;
    property ReservedProperty10: OleVariant dispid 410;
    property ReservedProperty11: OleVariant dispid 411;
    property ReservedProperty12: OleVariant dispid 412;
    property ReservedProperty13: OleVariant dispid 413;
    property ReservedProperty14: OleVariant dispid 414;
    property ReservedProperty15: OleVariant dispid 415;
    property ReservedProperty16: OleVariant dispid 416;
    property ReservedProperty17: OleVariant dispid 417;
    property ReservedProperty18: OleVariant dispid 418;
    property ReservedProperty19: OleVariant dispid 419;
    property ReservedProperty20: OleVariant dispid 420;
    procedure _ShowCIPDialog; dispid 421;
    procedure ReservedMethod02; dispid 422;
    procedure ReservedMethod03; dispid 423;
    procedure ReservedMethod04; dispid 424;
    procedure ReservedMethod05; dispid 425;
    procedure ReservedMethod06; dispid 426;
    procedure ReservedMethod07; dispid 427;
    procedure ReservedMethod08; dispid 428;
    procedure ReservedMethod09; dispid 429;
    procedure ReservedMethod10; dispid 430;
    procedure ReservedMethod11; dispid 431;
    procedure ReservedMethod12; dispid 432;
    procedure ReservedMethod13; dispid 433;
    procedure ReservedMethod14; dispid 434;
    procedure ReservedMethod15; dispid 435;
    procedure ReservedMethod16; dispid 436;
    procedure ReservedMethod17; dispid 437;
    procedure ReservedMethod18; dispid 438;
    procedure ReservedMethod19; dispid 439;
    procedure ReservedMethod20; dispid 440;
  end;

// *********************************************************************//
// DispIntf:  IAdViewerEvents
// Flags:     (4096) Dispatchable
// GUID:      {A7D421C8-FC4D-488F-AA61-4FEC541A57B8}
// *********************************************************************//
  IAdViewerEvents = dispinterface
    ['{A7D421C8-FC4D-488F-AA61-4FEC541A57B8}']
    procedure OnBeginDraw(nReason: Integer; const pRect: IDispatch); dispid 1;
    procedure OnEndDraw(nReason: Integer; vResult: OleVariant); dispid 2;
    procedure OnMouseMove(nButtons: Integer; nX: SYSINT; nY: SYSINT; const pHandled: IDispatch); dispid 3;
    procedure OnLButtonDown(nX: SYSINT; nY: SYSINT; const pHandled: IDispatch); dispid 4;
    procedure OnLButtonUp(nX: SYSINT; nY: SYSINT; const pHandled: IDispatch); dispid 5;
    procedure OnLButtonDblClick(nX: SYSINT; nY: SYSINT; const pHandled: IDispatch); dispid 6;
    procedure OnMButtonDown(nX: SYSINT; nY: SYSINT; const pHandled: IDispatch); dispid 7;
    procedure OnMButtonUp(nX: SYSINT; nY: SYSINT; const pHandled: IDispatch); dispid 8;
    procedure OnMButtonDblClick(nX: SYSINT; nY: SYSINT; const pHandled: IDispatch); dispid 9;
    procedure OnRButtonDown(nX: SYSINT; nY: SYSINT; const pHandled: IDispatch); dispid 10;
    procedure OnRButtonUp(nX: SYSINT; nY: SYSINT; const pHandled: IDispatch); dispid 11;
    procedure OnRButtonDblClick(nX: SYSINT; nY: SYSINT; const pHandled: IDispatch); dispid 12;
    procedure OnMouseWheel(nX: SYSINT; nY: SYSINT; nWheeldelta: SYSINT; const pHandled: IDispatch); dispid 13;
    procedure OnExecuteURL(const pIAdPageLink: IDispatch; nIndex: SYSINT; const pHandled: IDispatch); dispid 14;
    procedure OnOverURL(nX: SYSINT; nY: SYSINT; const pLink: IDispatch; const pHandled: IDispatch); dispid 15;
    procedure OnLeaveURL(nX: SYSINT; nY: SYSINT; const pLink: IDispatch); dispid 16;
    procedure OnKeyDown(wChar: Integer; const pHandled: IDispatch); dispid 17;
    procedure OnKeyUp(wChar: Integer; const pHandled: IDispatch); dispid 18;
    procedure OnOverObject(const pIAdPageObjectNode: IDispatch; const pHandled: IDispatch); dispid 19;
    procedure OnLeaveObject(const pIAdPageObjectNode: IDispatch); dispid 20;
    procedure OnSelectObject(const pIAdPageObjectNode: IDispatch; const pHandled: IDispatch); dispid 21;
    procedure OnBeginLoadItem(const bstrItemType: WideString; vData: OleVariant); dispid 22;
    procedure OnEndLoadItem(const bstrItemName: WideString; vData: OleVariant; vResult: OleVariant); dispid 23;
    procedure OnShowUiItem(const bstrItemName: WideString; vState: OleVariant; vData: OleVariant; 
                           const pHandled: IDispatch); dispid 24;
    procedure OnUpdateUiItem(const bstrItemName: WideString; vState: OleVariant; vData: OleVariant); dispid 25;
    procedure OnCommand(msg: SYSINT; wparam: Integer; lparam: Integer; const pHandled: IDispatch); dispid 26;
    procedure OnInitLoadItem(const bstrItemType: WideString; vState: OleVariant; vData: OleVariant; 
                             const pHandled: IDispatch); dispid 27;
    procedure OnUnloadItem(const bstrItemType: WideString; vState: OleVariant; vData: OleVariant; 
                           const pHandled: IDispatch); dispid 28;
    procedure OnEventGroup(vData: OleVariant); dispid 29;
    procedure OnExecuteCommandEx(const bstrItemType: WideString; vState: OleVariant; 
                                 vData: OleVariant; const pHandled: IDispatch); dispid 30;
    procedure OnOverObjectEx(const bObjectID: WideString; const pHandled: IDispatch); dispid 31;
    procedure OnLeaveObjectEx(const bObjectID: WideString); dispid 32;
    procedure OnSelectObjectEx(const pHandled: IDispatch); dispid 33;
    procedure OnInternalEventGroup(vData: OleVariant); dispid 34;
  end;

// *********************************************************************//
// Interface: IAdMarkupEditor
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3ABA218C-860E-41DE-BE78-02A3B906CBDC}
// *********************************************************************//
  IAdMarkupEditor = interface(IDispatch)
    ['{3ABA218C-860E-41DE-BE78-02A3B906CBDC}']
    function Get_Dirty: WordBool; safecall;
    procedure Set_Dirty(pVal: WordBool); safecall;
    procedure Save; safecall;
    procedure SaveAs(const fileName: WideString); safecall;
    procedure Close; safecall;
    procedure FireOnSaveEvent(var fileName: WideString; const pCancel: IDispatch); safecall;
    procedure FireOnSaveAsEvent(var fileName: WideString; const pCancel: IDispatch); safecall;
    procedure FireOnSaveCompleteEvent(const fileName: WideString; status: WordBool); safecall;
    property Dirty: WordBool read Get_Dirty write Set_Dirty;
  end;

// *********************************************************************//
// DispIntf:  IAdMarkupEditorDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3ABA218C-860E-41DE-BE78-02A3B906CBDC}
// *********************************************************************//
  IAdMarkupEditorDisp = dispinterface
    ['{3ABA218C-860E-41DE-BE78-02A3B906CBDC}']
    property Dirty: WordBool dispid 1;
    procedure Save; dispid 101;
    procedure SaveAs(const fileName: WideString); dispid 102;
    procedure Close; dispid 103;
    procedure FireOnSaveEvent(var fileName: WideString; const pCancel: IDispatch); dispid 105;
    procedure FireOnSaveAsEvent(var fileName: WideString; const pCancel: IDispatch); dispid 106;
    procedure FireOnSaveCompleteEvent(const fileName: WideString; status: WordBool); dispid 107;
  end;

// *********************************************************************//
// Interface: IAdMarkupEditor2
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9164A5E6-9383-4204-9DCE-5701DC7AAF37}
// *********************************************************************//
  IAdMarkupEditor2 = interface(IAdMarkupEditor)
    ['{9164A5E6-9383-4204-9DCE-5701DC7AAF37}']
    function Get_Restricted: WordBool; safecall;
    property Restricted: WordBool read Get_Restricted;
  end;

// *********************************************************************//
// DispIntf:  IAdMarkupEditor2Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9164A5E6-9383-4204-9DCE-5701DC7AAF37}
// *********************************************************************//
  IAdMarkupEditor2Disp = dispinterface
    ['{9164A5E6-9383-4204-9DCE-5701DC7AAF37}']
    property Restricted: WordBool readonly dispid 3;
    property Dirty: WordBool dispid 1;
    procedure Save; dispid 101;
    procedure SaveAs(const fileName: WideString); dispid 102;
    procedure Close; dispid 103;
    procedure FireOnSaveEvent(var fileName: WideString; const pCancel: IDispatch); dispid 105;
    procedure FireOnSaveAsEvent(var fileName: WideString; const pCancel: IDispatch); dispid 106;
    procedure FireOnSaveCompleteEvent(const fileName: WideString; status: WordBool); dispid 107;
  end;

// *********************************************************************//
// DispIntf:  IAdMarkupEditorEvents
// Flags:     (4096) Dispatchable
// GUID:      {194AD7DC-FD2F-46A6-A733-C813EDC8FB91}
// *********************************************************************//
  IAdMarkupEditorEvents = dispinterface
    ['{194AD7DC-FD2F-46A6-A733-C813EDC8FB91}']
    procedure OnSave(var fileName: WideString; const pCancel: IDispatch); dispid 1;
    procedure OnSaveAs(var fileName: WideString; const pCancel: IDispatch); dispid 2;
    procedure OnSaveComplete(const fileName: WideString; status: WordBool); dispid 3;
  end;

// *********************************************************************//
// Interface: IAdEventRelayer
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {01F01418-83A0-400C-B3AA-D8CC34F38E3F}
// *********************************************************************//
  IAdEventRelayer = interface(IDispatch)
    ['{01F01418-83A0-400C-B3AA-D8CC34F38E3F}']
    function Get_DocumentInterface: WideString; safecall;
    procedure SetDocumentHandler(const piHandler: IDispatch); safecall;
    property DocumentInterface: WideString read Get_DocumentInterface;
  end;

// *********************************************************************//
// DispIntf:  IAdEventRelayerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {01F01418-83A0-400C-B3AA-D8CC34F38E3F}
// *********************************************************************//
  IAdEventRelayerDisp = dispinterface
    ['{01F01418-83A0-400C-B3AA-D8CC34F38E3F}']
    property DocumentInterface: WideString readonly dispid 1;
    procedure SetDocumentHandler(const piHandler: IDispatch); dispid 2;
  end;

// *********************************************************************//
// Interface: IAdDwfViewer
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8A5E1971-62C6-4EA0-B943-6F2833F7AC2C}
// *********************************************************************//
  IAdDwfViewer = interface(IAdViewer)
    ['{8A5E1971-62C6-4EA0-B943-6F2833F7AC2C}']
    function Get_IndexPage: WideString; safecall;
    procedure Set_IndexPage(const pVal: WideString); safecall;
    function Get_MarkupEditor: IDispatch; safecall;
    function Get_PreferredDocumentHandler(const DocInterface: WideString): WideString; safecall;
    procedure Set_PreferredDocumentHandler(const DocInterface: WideString; const pVal: WideString); safecall;
    procedure Set__FileName(const Param1: WideString); safecall;
    procedure SaveAs(const newPathName: WideString); safecall;
    procedure _SetDirty; safecall;
    procedure Set_PreferredProduct(const Param1: WideString); safecall;
    function Get_ProductName: WideString; safecall;
    function Get_ProductVersion(const bProduct: WideString): WideString; safecall;
    function Get_DragAndDropEnabled: Integer; safecall;
    procedure Set_DragAndDropEnabled(pVal: Integer); safecall;
    function Get_ECompositeViewer: IDispatch; safecall;
    procedure AddEventRelayer(const piEventRelayer: IAdEventRelayer); safecall;
    property IndexPage: WideString read Get_IndexPage write Set_IndexPage;
    property MarkupEditor: IDispatch read Get_MarkupEditor;
    property PreferredDocumentHandler[const DocInterface: WideString]: WideString read Get_PreferredDocumentHandler write Set_PreferredDocumentHandler;
    property _FileName: WideString write Set__FileName;
    property PreferredProduct: WideString write Set_PreferredProduct;
    property ProductName: WideString read Get_ProductName;
    property ProductVersion[const bProduct: WideString]: WideString read Get_ProductVersion;
    property DragAndDropEnabled: Integer read Get_DragAndDropEnabled write Set_DragAndDropEnabled;
    property ECompositeViewer: IDispatch read Get_ECompositeViewer;
  end;

// *********************************************************************//
// DispIntf:  IAdDwfViewerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8A5E1971-62C6-4EA0-B943-6F2833F7AC2C}
// *********************************************************************//
  IAdDwfViewerDisp = dispinterface
    ['{8A5E1971-62C6-4EA0-B943-6F2833F7AC2C}']
    property IndexPage: WideString dispid 1001;
    property MarkupEditor: IDispatch readonly dispid 1002;
    property PreferredDocumentHandler[const DocInterface: WideString]: WideString dispid 1003;
    property _FileName: WideString writeonly dispid 1004;
    procedure SaveAs(const newPathName: WideString); dispid 1005;
    procedure _SetDirty; dispid 1006;
    property PreferredProduct: WideString writeonly dispid 1007;
    property ProductName: WideString readonly dispid 1008;
    property ProductVersion[const bProduct: WideString]: WideString readonly dispid 1009;
    property DragAndDropEnabled: Integer dispid 1010;
    property ECompositeViewer: IDispatch readonly dispid 1011;
    procedure AddEventRelayer(const piEventRelayer: IAdEventRelayer); dispid 1012;
    property BackColor: OLE_COLOR dispid -501;
    property EmbedSourceDocument: WordBool dispid 3;
    property SourcePath: WideString dispid 1;
    property Viewer: IDispatch readonly dispid 2;
    procedure ShowPrintDialog; dispid 101;
    procedure NavigateToUrl(const bstrUrl: WideString); dispid 103;
    procedure ExecuteCommand(const bstrCommand: WideString); dispid 104;
    procedure DrawToDC(nDc: Integer; nLeft: Integer; nTop: Integer; nRight: Integer; 
                       nBottom: Integer); dispid 105;
    property _ActiveWindow: OleVariant readonly dispid 200;
    property _ClientWindow: OleVariant readonly dispid 202;
    property _DocumentParams: WideString readonly dispid 203;
    property _HistoryParams: WideString readonly dispid 204;
    property _LocalFilePath: WideString readonly dispid 205;
    property _SourceStream: IUnknown writeonly dispid 206;
    property _ViewerParams: WideString dispid 201;
    procedure _GoBack; dispid 300;
    procedure _GoForward; dispid 301;
    procedure _SaveHistory; dispid 302;
    procedure _ShowHelp(const bstrTopic: WideString); dispid 303;
    property DocumentHandler: IDispatch readonly dispid 106;
    property DocumentType: WideString readonly dispid 107;
    procedure ExecuteCommandEx(const bstrCommand: WideString; lVal: Integer); dispid 108;
    property GradientBackgroundColor: OLE_COLOR dispid 401;
    property GradientBackgroundEnabled: WordBool dispid 402;
    property ContextMenu: IDispatch dispid 403;
    property CanvasEmpty: WordBool dispid 404;
    property ReservedProperty05: OleVariant dispid 405;
    property ReservedProperty06: OleVariant dispid 406;
    property ReservedProperty07: OleVariant dispid 407;
    property ReservedProperty08: OleVariant dispid 408;
    property ReservedProperty09: OleVariant dispid 409;
    property ReservedProperty10: OleVariant dispid 410;
    property ReservedProperty11: OleVariant dispid 411;
    property ReservedProperty12: OleVariant dispid 412;
    property ReservedProperty13: OleVariant dispid 413;
    property ReservedProperty14: OleVariant dispid 414;
    property ReservedProperty15: OleVariant dispid 415;
    property ReservedProperty16: OleVariant dispid 416;
    property ReservedProperty17: OleVariant dispid 417;
    property ReservedProperty18: OleVariant dispid 418;
    property ReservedProperty19: OleVariant dispid 419;
    property ReservedProperty20: OleVariant dispid 420;
    procedure _ShowCIPDialog; dispid 421;
    procedure ReservedMethod02; dispid 422;
    procedure ReservedMethod03; dispid 423;
    procedure ReservedMethod04; dispid 424;
    procedure ReservedMethod05; dispid 425;
    procedure ReservedMethod06; dispid 426;
    procedure ReservedMethod07; dispid 427;
    procedure ReservedMethod08; dispid 428;
    procedure ReservedMethod09; dispid 429;
    procedure ReservedMethod10; dispid 430;
    procedure ReservedMethod11; dispid 431;
    procedure ReservedMethod12; dispid 432;
    procedure ReservedMethod13; dispid 433;
    procedure ReservedMethod14; dispid 434;
    procedure ReservedMethod15; dispid 435;
    procedure ReservedMethod16; dispid 436;
    procedure ReservedMethod17; dispid 437;
    procedure ReservedMethod18; dispid 438;
    procedure ReservedMethod19; dispid 439;
    procedure ReservedMethod20; dispid 440;
  end;

// *********************************************************************//
// Interface: IAdDwfViewer2
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5038F2F6-AE03-453B-966E-0D39A564BEB2}
// *********************************************************************//
  IAdDwfViewer2 = interface(IAdDwfViewer)
    ['{5038F2F6-AE03-453B-966E-0D39A564BEB2}']
    function Get_WorkspaceLayoutFile: WideString; safecall;
    procedure Set_WorkspaceLayoutFile(const pVal: WideString); safecall;
    procedure SaveWorkspaceLayoutFile(const newFilePath: WideString); safecall;
    function Get_CreatNewState: WordBool; safecall;
    procedure Set_CreatNewState(pVal: WordBool); safecall;
    property WorkspaceLayoutFile: WideString read Get_WorkspaceLayoutFile write Set_WorkspaceLayoutFile;
    property CreatNewState: WordBool read Get_CreatNewState write Set_CreatNewState;
  end;

// *********************************************************************//
// DispIntf:  IAdDwfViewer2Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5038F2F6-AE03-453B-966E-0D39A564BEB2}
// *********************************************************************//
  IAdDwfViewer2Disp = dispinterface
    ['{5038F2F6-AE03-453B-966E-0D39A564BEB2}']
    property WorkspaceLayoutFile: WideString dispid 1013;
    procedure SaveWorkspaceLayoutFile(const newFilePath: WideString); dispid 1014;
    property CreatNewState: WordBool dispid 1015;
    property IndexPage: WideString dispid 1001;
    property MarkupEditor: IDispatch readonly dispid 1002;
    property PreferredDocumentHandler[const DocInterface: WideString]: WideString dispid 1003;
    property _FileName: WideString writeonly dispid 1004;
    procedure SaveAs(const newPathName: WideString); dispid 1005;
    procedure _SetDirty; dispid 1006;
    property PreferredProduct: WideString writeonly dispid 1007;
    property ProductName: WideString readonly dispid 1008;
    property ProductVersion[const bProduct: WideString]: WideString readonly dispid 1009;
    property DragAndDropEnabled: Integer dispid 1010;
    property ECompositeViewer: IDispatch readonly dispid 1011;
    procedure AddEventRelayer(const piEventRelayer: IAdEventRelayer); dispid 1012;
    property BackColor: OLE_COLOR dispid -501;
    property EmbedSourceDocument: WordBool dispid 3;
    property SourcePath: WideString dispid 1;
    property Viewer: IDispatch readonly dispid 2;
    procedure ShowPrintDialog; dispid 101;
    procedure NavigateToUrl(const bstrUrl: WideString); dispid 103;
    procedure ExecuteCommand(const bstrCommand: WideString); dispid 104;
    procedure DrawToDC(nDc: Integer; nLeft: Integer; nTop: Integer; nRight: Integer; 
                       nBottom: Integer); dispid 105;
    property _ActiveWindow: OleVariant readonly dispid 200;
    property _ClientWindow: OleVariant readonly dispid 202;
    property _DocumentParams: WideString readonly dispid 203;
    property _HistoryParams: WideString readonly dispid 204;
    property _LocalFilePath: WideString readonly dispid 205;
    property _SourceStream: IUnknown writeonly dispid 206;
    property _ViewerParams: WideString dispid 201;
    procedure _GoBack; dispid 300;
    procedure _GoForward; dispid 301;
    procedure _SaveHistory; dispid 302;
    procedure _ShowHelp(const bstrTopic: WideString); dispid 303;
    property DocumentHandler: IDispatch readonly dispid 106;
    property DocumentType: WideString readonly dispid 107;
    procedure ExecuteCommandEx(const bstrCommand: WideString; lVal: Integer); dispid 108;
    property GradientBackgroundColor: OLE_COLOR dispid 401;
    property GradientBackgroundEnabled: WordBool dispid 402;
    property ContextMenu: IDispatch dispid 403;
    property CanvasEmpty: WordBool dispid 404;
    property ReservedProperty05: OleVariant dispid 405;
    property ReservedProperty06: OleVariant dispid 406;
    property ReservedProperty07: OleVariant dispid 407;
    property ReservedProperty08: OleVariant dispid 408;
    property ReservedProperty09: OleVariant dispid 409;
    property ReservedProperty10: OleVariant dispid 410;
    property ReservedProperty11: OleVariant dispid 411;
    property ReservedProperty12: OleVariant dispid 412;
    property ReservedProperty13: OleVariant dispid 413;
    property ReservedProperty14: OleVariant dispid 414;
    property ReservedProperty15: OleVariant dispid 415;
    property ReservedProperty16: OleVariant dispid 416;
    property ReservedProperty17: OleVariant dispid 417;
    property ReservedProperty18: OleVariant dispid 418;
    property ReservedProperty19: OleVariant dispid 419;
    property ReservedProperty20: OleVariant dispid 420;
    procedure _ShowCIPDialog; dispid 421;
    procedure ReservedMethod02; dispid 422;
    procedure ReservedMethod03; dispid 423;
    procedure ReservedMethod04; dispid 424;
    procedure ReservedMethod05; dispid 425;
    procedure ReservedMethod06; dispid 426;
    procedure ReservedMethod07; dispid 427;
    procedure ReservedMethod08; dispid 428;
    procedure ReservedMethod09; dispid 429;
    procedure ReservedMethod10; dispid 430;
    procedure ReservedMethod11; dispid 431;
    procedure ReservedMethod12; dispid 432;
    procedure ReservedMethod13; dispid 433;
    procedure ReservedMethod14; dispid 434;
    procedure ReservedMethod15; dispid 435;
    procedure ReservedMethod16; dispid 436;
    procedure ReservedMethod17; dispid 437;
    procedure ReservedMethod18; dispid 438;
    procedure ReservedMethod19; dispid 439;
    procedure ReservedMethod20; dispid 440;
  end;

// *********************************************************************//
// Interface: IAdServiceHandler
// Flags:     (0)
// GUID:      {BEB61016-3525-441C-ADB9-404C8EDBCC8C}
// *********************************************************************//
  IAdServiceHandler = interface(IUnknown)
    ['{BEB61016-3525-441C-ADB9-404C8EDBCC8C}']
    function RequestService(usService: Word; var pvArg: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdServiceHandler2
// Flags:     (0)
// GUID:      {8B47C55C-DE6A-4B42-ADB7-C57328C83904}
// *********************************************************************//
  IAdServiceHandler2 = interface(IAdServiceHandler)
    ['{8B47C55C-DE6A-4B42-ADB7-C57328C83904}']
    function RequestService2(usService: Word; var pvArg: OleVariant; index: SYSINT): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdAboutBox
// Flags:     (0)
// GUID:      {0B2286BE-6357-4C1A-972B-18AE722756A6}
// *********************************************************************//
  IAdAboutBox = interface(IUnknown)
    ['{0B2286BE-6357-4C1A-972B-18AE722756A6}']
    function Show(hInst: OleVariant; hWnd: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdContent
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {01FE3951-5AF6-4C46-9F6D-E0B38D13355E}
// *********************************************************************//
  IAdContent = interface(IDispatch)
    ['{01FE3951-5AF6-4C46-9F6D-E0B38D13355E}']
    function Get_Objects(nObjectType: Integer): IDispatch; safecall;
    procedure Set_Objects(nObjectType: Integer; const pVal: IDispatch); safecall;
    function CreateUserCollection: IDispatch; safecall;
    property Objects[nObjectType: Integer]: IDispatch read Get_Objects write Set_Objects;
  end;

// *********************************************************************//
// DispIntf:  IAdContentDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {01FE3951-5AF6-4C46-9F6D-E0B38D13355E}
// *********************************************************************//
  IAdContentDisp = dispinterface
    ['{01FE3951-5AF6-4C46-9F6D-E0B38D13355E}']
    property Objects[nObjectType: Integer]: IDispatch dispid 1;
    function CreateUserCollection: IDispatch; dispid 2;
  end;

// *********************************************************************//
// Interface: IAdContent2
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A683A7FB-96D7-424D-8E53-8B973F847D7B}
// *********************************************************************//
  IAdContent2 = interface(IAdContent)
    ['{A683A7FB-96D7-424D-8E53-8B973F847D7B}']
    function Get_Object_(const bstrObjectId: WideString): IDispatch; safecall;
    function Get_Extents(const pObjects: IDispatch): IDispatch; safecall;
    property Object_[const bstrObjectId: WideString]: IDispatch read Get_Object_;
    property Extents[const pObjects: IDispatch]: IDispatch read Get_Extents;
  end;

// *********************************************************************//
// DispIntf:  IAdContent2Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A683A7FB-96D7-424D-8E53-8B973F847D7B}
// *********************************************************************//
  IAdContent2Disp = dispinterface
    ['{A683A7FB-96D7-424D-8E53-8B973F847D7B}']
    property Object_[const bstrObjectId: WideString]: IDispatch readonly dispid 3;
    property Extents[const pObjects: IDispatch]: IDispatch readonly dispid 4;
    property Objects[nObjectType: Integer]: IDispatch dispid 1;
    function CreateUserCollection: IDispatch; dispid 2;
  end;

// *********************************************************************//
// Interface: IAdContextMenuListEntry
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B1FB99F1-15FB-4907-B6B3-AE5AAB0E6E6C}
// *********************************************************************//
  IAdContextMenuListEntry = interface(IDispatch)
    ['{B1FB99F1-15FB-4907-B6B3-AE5AAB0E6E6C}']
    function Get_Id: WideString; safecall;
    procedure Set_Id(const pbstrId: WideString); safecall;
    function Get_Command: WideString; safecall;
    procedure Set_Command(const pbstrCommand: WideString); safecall;
    function Get_Image: WideString; safecall;
    procedure Set_Image(const pbstrImage: WideString); safecall;
    function Get_Text: WideString; safecall;
    procedure Set_Text(const pbstrText: WideString); safecall;
    function Get_Mnemonic: WideString; safecall;
    procedure Set_Mnemonic(const pbstrMnemonic: WideString); safecall;
    function Get_Shortcut: WideString; safecall;
    procedure Set_Shortcut(const pbstrShortcut: WideString); safecall;
    function Get_Rollover: WideString; safecall;
    procedure Set_Rollover(const pbstrRollover: WideString); safecall;
    function isCascade: WordBool; safecall;
    property Id: WideString read Get_Id write Set_Id;
    property Command: WideString read Get_Command write Set_Command;
    property Image: WideString read Get_Image write Set_Image;
    property Text: WideString read Get_Text write Set_Text;
    property Mnemonic: WideString read Get_Mnemonic write Set_Mnemonic;
    property Shortcut: WideString read Get_Shortcut write Set_Shortcut;
    property Rollover: WideString read Get_Rollover write Set_Rollover;
  end;

// *********************************************************************//
// DispIntf:  IAdContextMenuListEntryDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B1FB99F1-15FB-4907-B6B3-AE5AAB0E6E6C}
// *********************************************************************//
  IAdContextMenuListEntryDisp = dispinterface
    ['{B1FB99F1-15FB-4907-B6B3-AE5AAB0E6E6C}']
    property Id: WideString dispid 1;
    property Command: WideString dispid 2;
    property Image: WideString dispid 3;
    property Text: WideString dispid 4;
    property Mnemonic: WideString dispid 5;
    property Shortcut: WideString dispid 6;
    property Rollover: WideString dispid 7;
    function isCascade: WordBool; dispid 100;
  end;

// *********************************************************************//
// Interface: IAdContextMenu
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A5180048-6FD7-4AA3-8AE1-005B624E6547}
// *********************************************************************//
  IAdContextMenu = interface(IDispatch)
    ['{A5180048-6FD7-4AA3-8AE1-005B624E6547}']
    function Get_Count: Integer; safecall;
    function Get_Item(vIndex: OleVariant): OleVariant; safecall;
    function Get_ItemName(lIndex: Integer): WideString; safecall;
    function Get__Index(const bstrName: WideString): Integer; safecall;
    function Get__RolloverText(lIndex: Integer): WideString; safecall;
    procedure ClearAllItems; safecall;
    procedure InsertItem(lIndex: Integer; const pIAdContextMenuListEntry: IDispatch); safecall;
    procedure InsertNewItem(lIndex: Integer; const Id: WideString; const Command: WideString; 
                            const Image: WideString; const Text: WideString; 
                            const Mnemonic: WideString; const Shortcut: WideString; 
                            const Rollover: WideString); safecall;
    procedure RemoveItem(const bstrId: WideString; lIndex: Integer); safecall;
    procedure Show(lPoint: Integer); safecall;
    procedure SetViewer(const pViewer: IDispatch); safecall;
    property Count: Integer read Get_Count;
    property Item[vIndex: OleVariant]: OleVariant read Get_Item; default;
    property ItemName[lIndex: Integer]: WideString read Get_ItemName;
    property _Index[const bstrName: WideString]: Integer read Get__Index;
    property _RolloverText[lIndex: Integer]: WideString read Get__RolloverText;
  end;

// *********************************************************************//
// DispIntf:  IAdContextMenuDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A5180048-6FD7-4AA3-8AE1-005B624E6547}
// *********************************************************************//
  IAdContextMenuDisp = dispinterface
    ['{A5180048-6FD7-4AA3-8AE1-005B624E6547}']
    property Count: Integer readonly dispid 1;
    property Item[vIndex: OleVariant]: OleVariant readonly dispid 0; default;
    property ItemName[lIndex: Integer]: WideString readonly dispid 3;
    property _Index[const bstrName: WideString]: Integer readonly dispid 4;
    property _RolloverText[lIndex: Integer]: WideString readonly dispid 5;
    procedure ClearAllItems; dispid 100;
    procedure InsertItem(lIndex: Integer; const pIAdContextMenuListEntry: IDispatch); dispid 101;
    procedure InsertNewItem(lIndex: Integer; const Id: WideString; const Command: WideString; 
                            const Image: WideString; const Text: WideString; 
                            const Mnemonic: WideString; const Shortcut: WideString; 
                            const Rollover: WideString); dispid 102;
    procedure RemoveItem(const bstrId: WideString; lIndex: Integer); dispid 103;
    procedure Show(lPoint: Integer); dispid 104;
    procedure SetViewer(const pViewer: IDispatch); dispid 105;
  end;

// *********************************************************************//
// Interface: IAdObject
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {15388997-D4A8-486C-AA37-21D319112744}
// *********************************************************************//
  IAdObject = interface(IDispatch)
    ['{15388997-D4A8-486C-AA37-21D319112744}']
    function Get_Properties: IDispatch; safecall;
    property Properties: IDispatch read Get_Properties;
  end;

// *********************************************************************//
// DispIntf:  IAdObjectDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {15388997-D4A8-486C-AA37-21D319112744}
// *********************************************************************//
  IAdObjectDisp = dispinterface
    ['{15388997-D4A8-486C-AA37-21D319112744}']
    property Properties: IDispatch readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IAdObject2
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2199B630-3012-40E4-B255-6236EF73E9FE}
// *********************************************************************//
  IAdObject2 = interface(IAdObject)
    ['{2199B630-3012-40E4-B255-6236EF73E9FE}']
    function Get_Id: WideString; safecall;
    property Id: WideString read Get_Id;
  end;

// *********************************************************************//
// DispIntf:  IAdObject2Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2199B630-3012-40E4-B255-6236EF73E9FE}
// *********************************************************************//
  IAdObject2Disp = dispinterface
    ['{2199B630-3012-40E4-B255-6236EF73E9FE}']
    property Id: WideString readonly dispid 2;
    property Properties: IDispatch readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IAdViewerEvent_Base
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2A3F3A98-5463-4148-86BC-FC8386664D05}
// *********************************************************************//
  IAdViewerEvent_Base = interface(IDispatch)
    ['{2A3F3A98-5463-4148-86BC-FC8386664D05}']
    function Get_EventType: WideString; safecall;
    property EventType: WideString read Get_EventType;
  end;

// *********************************************************************//
// DispIntf:  IAdViewerEvent_BaseDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2A3F3A98-5463-4148-86BC-FC8386664D05}
// *********************************************************************//
  IAdViewerEvent_BaseDisp = dispinterface
    ['{2A3F3A98-5463-4148-86BC-FC8386664D05}']
    property EventType: WideString readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IAdViewerEvent_UpdateUiItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {63D75159-E513-4EFC-BFDA-4486D736BBB5}
// *********************************************************************//
  IAdViewerEvent_UpdateUiItem = interface(IAdViewerEvent_Base)
    ['{63D75159-E513-4EFC-BFDA-4486D736BBB5}']
    function Get_ItemName: WideString; safecall;
    procedure Set_ItemName(const pVal: WideString); safecall;
    function Get_State: OleVariant; safecall;
    procedure Set_State(pVal: OleVariant); safecall;
    function Get_Data: OleVariant; safecall;
    procedure Set_Data(pVal: OleVariant); safecall;
    property ItemName: WideString read Get_ItemName write Set_ItemName;
    property State: OleVariant read Get_State write Set_State;
    property Data: OleVariant read Get_Data write Set_Data;
  end;

// *********************************************************************//
// DispIntf:  IAdViewerEvent_UpdateUiItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {63D75159-E513-4EFC-BFDA-4486D736BBB5}
// *********************************************************************//
  IAdViewerEvent_UpdateUiItemDisp = dispinterface
    ['{63D75159-E513-4EFC-BFDA-4486D736BBB5}']
    property ItemName: WideString dispid 1002;
    property State: OleVariant dispid 1003;
    property Data: OleVariant dispid 1004;
    property EventType: WideString readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IAdViewerEvent_ShowUiItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4EF56DDF-B335-4117-B1CF-5960DD29C3D0}
// *********************************************************************//
  IAdViewerEvent_ShowUiItem = interface(IAdViewerEvent_Base)
    ['{4EF56DDF-B335-4117-B1CF-5960DD29C3D0}']
    function Get_ItemName: WideString; safecall;
    procedure Set_ItemName(const pVal: WideString); safecall;
    function Get_State: OleVariant; safecall;
    procedure Set_State(pVal: OleVariant); safecall;
    function Get_Data: OleVariant; safecall;
    procedure Set_Data(pVal: OleVariant); safecall;
    function Get_Handled: IDispatch; safecall;
    procedure Set_Handled(const pVal: IDispatch); safecall;
    property ItemName: WideString read Get_ItemName write Set_ItemName;
    property State: OleVariant read Get_State write Set_State;
    property Data: OleVariant read Get_Data write Set_Data;
    property Handled: IDispatch read Get_Handled write Set_Handled;
  end;

// *********************************************************************//
// DispIntf:  IAdViewerEvent_ShowUiItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4EF56DDF-B335-4117-B1CF-5960DD29C3D0}
// *********************************************************************//
  IAdViewerEvent_ShowUiItemDisp = dispinterface
    ['{4EF56DDF-B335-4117-B1CF-5960DD29C3D0}']
    property ItemName: WideString dispid 1002;
    property State: OleVariant dispid 1003;
    property Data: OleVariant dispid 1004;
    property Handled: IDispatch dispid 1005;
    property EventType: WideString readonly dispid 1;
  end;

// *********************************************************************//
// Interface: ICreateUIMenuItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E4554757-B9EB-41A4-90F3-67BB35AAF669}
// *********************************************************************//
  ICreateUIMenuItem = interface(IAdViewerEvent_Base)
    ['{E4554757-B9EB-41A4-90F3-67BB35AAF669}']
    function Get_Id: WideString; safecall;
    function Get_Command: WideString; safecall;
    function Get_Image: WideString; safecall;
    function Get_Text: WideString; safecall;
    function Get_Mnemonic: WideString; safecall;
    function Get_Shortcut: WideString; safecall;
    function Get_Rollover: Integer; safecall;
    function Get_Enabled: Integer; safecall;
    procedure CreateMenuItem(const valId: WideString; const valCommand: WideString; 
                             const valImage: WideString; const valText: WideString; 
                             const valMnemonic: WideString; const valShortcut: WideString; 
                             valRollover: Integer; valEnabled: Integer); safecall;
    property Id: WideString read Get_Id;
    property Command: WideString read Get_Command;
    property Image: WideString read Get_Image;
    property Text: WideString read Get_Text;
    property Mnemonic: WideString read Get_Mnemonic;
    property Shortcut: WideString read Get_Shortcut;
    property Rollover: Integer read Get_Rollover;
    property Enabled: Integer read Get_Enabled;
  end;

// *********************************************************************//
// DispIntf:  ICreateUIMenuItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E4554757-B9EB-41A4-90F3-67BB35AAF669}
// *********************************************************************//
  ICreateUIMenuItemDisp = dispinterface
    ['{E4554757-B9EB-41A4-90F3-67BB35AAF669}']
    property Id: WideString readonly dispid 2;
    property Command: WideString readonly dispid 3;
    property Image: WideString readonly dispid 4;
    property Text: WideString readonly dispid 5;
    property Mnemonic: WideString readonly dispid 6;
    property Shortcut: WideString readonly dispid 7;
    property Rollover: Integer readonly dispid 8;
    property Enabled: Integer readonly dispid 9;
    procedure CreateMenuItem(const valId: WideString; const valCommand: WideString; 
                             const valImage: WideString; const valText: WideString; 
                             const valMnemonic: WideString; const valShortcut: WideString; 
                             valRollover: Integer; valEnabled: Integer); dispid 10;
    property EventType: WideString readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IAdSection
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {88D25E7A-B0C7-4DF2-91AD-EF7A1CEF22FD}
// *********************************************************************//
  IAdSection = interface(IDispatch)
    ['{88D25E7A-B0C7-4DF2-91AD-EF7A1CEF22FD}']
    function Get_Descriptor: WideString; safecall;
    function Get_Href: WideString; safecall;
    function Get_Hyperlinks: IDispatch; safecall;
    function Get_InstanceTree(vReserved: OleVariant): IDispatch; safecall;
    function Get_Loaded: WordBool; safecall;
    function Get_MissingFonts: IDispatch; safecall;
    function Get_Order: Double; safecall;
    function Get_Paper: IDispatch; safecall;
    function Get_Parameters: WideString; safecall;
    procedure Set_Parameters(const pVal: WideString); safecall;
    function Get_Properties: IDispatch; safecall;
    function Get_SectionType: IDispatch; safecall;
    function Get_Title: WideString; safecall;
    function Get_Content: IDispatch; safecall;
    procedure Set_ReservedProperty01(Param1: OleVariant); safecall;
    function Get_ReservedProperty02: OleVariant; safecall;
    procedure Set_ReservedProperty02(pVal: OleVariant); safecall;
    function Get_ReservedProperty03: OleVariant; safecall;
    procedure Set_ReservedProperty03(pVal: OleVariant); safecall;
    function Get_ReservedProperty04: OleVariant; safecall;
    procedure Set_ReservedProperty04(pVal: OleVariant); safecall;
    function Get_ReservedProperty05: OleVariant; safecall;
    procedure Set_ReservedProperty05(pVal: OleVariant); safecall;
    function Get_ReservedProperty06: OleVariant; safecall;
    procedure Set_ReservedProperty06(pVal: OleVariant); safecall;
    function Get_ReservedProperty07: OleVariant; safecall;
    procedure Set_ReservedProperty07(pVal: OleVariant); safecall;
    function Get_ReservedProperty08: OleVariant; safecall;
    procedure Set_ReservedProperty08(pVal: OleVariant); safecall;
    function Get_ReservedProperty09: OleVariant; safecall;
    procedure Set_ReservedProperty09(pVal: OleVariant); safecall;
    function Get_ReservedProperty10: OleVariant; safecall;
    procedure Set_ReservedProperty10(pVal: OleVariant); safecall;
    procedure ReservedMethod01; safecall;
    procedure ReservedMethod02; safecall;
    procedure ReservedMethod03; safecall;
    procedure ReservedMethod04; safecall;
    procedure ReservedMethod05; safecall;
    procedure ReservedMethod06; safecall;
    procedure ReservedMethod07; safecall;
    procedure ReservedMethod08; safecall;
    procedure ReservedMethod09; safecall;
    procedure ReservedMethod10; safecall;
    property Descriptor: WideString read Get_Descriptor;
    property Href: WideString read Get_Href;
    property Hyperlinks: IDispatch read Get_Hyperlinks;
    property InstanceTree[vReserved: OleVariant]: IDispatch read Get_InstanceTree;
    property Loaded: WordBool read Get_Loaded;
    property MissingFonts: IDispatch read Get_MissingFonts;
    property Order: Double read Get_Order;
    property Paper: IDispatch read Get_Paper;
    property Parameters: WideString read Get_Parameters write Set_Parameters;
    property Properties: IDispatch read Get_Properties;
    property SectionType: IDispatch read Get_SectionType;
    property Title: WideString read Get_Title;
    property Content: IDispatch read Get_Content;
    property ReservedProperty01: OleVariant write Set_ReservedProperty01;
    property ReservedProperty02: OleVariant read Get_ReservedProperty02 write Set_ReservedProperty02;
    property ReservedProperty03: OleVariant read Get_ReservedProperty03 write Set_ReservedProperty03;
    property ReservedProperty04: OleVariant read Get_ReservedProperty04 write Set_ReservedProperty04;
    property ReservedProperty05: OleVariant read Get_ReservedProperty05 write Set_ReservedProperty05;
    property ReservedProperty06: OleVariant read Get_ReservedProperty06 write Set_ReservedProperty06;
    property ReservedProperty07: OleVariant read Get_ReservedProperty07 write Set_ReservedProperty07;
    property ReservedProperty08: OleVariant read Get_ReservedProperty08 write Set_ReservedProperty08;
    property ReservedProperty09: OleVariant read Get_ReservedProperty09 write Set_ReservedProperty09;
    property ReservedProperty10: OleVariant read Get_ReservedProperty10 write Set_ReservedProperty10;
  end;

// *********************************************************************//
// DispIntf:  IAdSectionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {88D25E7A-B0C7-4DF2-91AD-EF7A1CEF22FD}
// *********************************************************************//
  IAdSectionDisp = dispinterface
    ['{88D25E7A-B0C7-4DF2-91AD-EF7A1CEF22FD}']
    property Descriptor: WideString readonly dispid 1;
    property Href: WideString readonly dispid 2;
    property Hyperlinks: IDispatch readonly dispid 3;
    property InstanceTree[vReserved: OleVariant]: IDispatch readonly dispid 4;
    property Loaded: WordBool readonly dispid 5;
    property MissingFonts: IDispatch readonly dispid 6;
    property Order: Double readonly dispid 7;
    property Paper: IDispatch readonly dispid 8;
    property Parameters: WideString dispid 9;
    property Properties: IDispatch readonly dispid 10;
    property SectionType: IDispatch readonly dispid 11;
    property Title: WideString readonly dispid 12;
    property Content: IDispatch readonly dispid 13;
    property ReservedProperty01: OleVariant writeonly dispid 101;
    property ReservedProperty02: OleVariant dispid 102;
    property ReservedProperty03: OleVariant dispid 103;
    property ReservedProperty04: OleVariant dispid 104;
    property ReservedProperty05: OleVariant dispid 105;
    property ReservedProperty06: OleVariant dispid 106;
    property ReservedProperty07: OleVariant dispid 107;
    property ReservedProperty08: OleVariant dispid 108;
    property ReservedProperty09: OleVariant dispid 109;
    property ReservedProperty10: OleVariant dispid 110;
    procedure ReservedMethod01; dispid 201;
    procedure ReservedMethod02; dispid 202;
    procedure ReservedMethod03; dispid 203;
    procedure ReservedMethod04; dispid 204;
    procedure ReservedMethod05; dispid 205;
    procedure ReservedMethod06; dispid 206;
    procedure ReservedMethod07; dispid 207;
    procedure ReservedMethod08; dispid 208;
    procedure ReservedMethod09; dispid 209;
    procedure ReservedMethod10; dispid 210;
  end;

// *********************************************************************//
// Interface: IAdSectionPrivate
// Flags:     (0)
// GUID:      {4FC504B0-45FE-48DA-A0DB-CA0E91BA34C5}
// *********************************************************************//
  IAdSectionPrivate = interface(IUnknown)
    ['{4FC504B0-45FE-48DA-A0DB-CA0E91BA34C5}']
    function Set_InstanceTree(vReserved: OleVariant; const Param2: IDispatch): HResult; stdcall;
    function Set_MarkupTree(vReserved: OleVariant; const pVal: IDispatch): HResult; stdcall;
    function Get_MarkupTree(vReserved: OleVariant; out pVal: IDispatch): HResult; stdcall;
    function Get_ThumbnailFile(out pVal: WideString): HResult; stdcall;
    function Get_ThumbnailStream(out pVal: OleVariant): HResult; stdcall;
    function Get_ThumbnailHeight(out pVal: Integer): HResult; stdcall;
    function Get_ThumbnailWidth(out pVal: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdSectionPrivate2
// Flags:     (0)
// GUID:      {D3056730-81A9-4C5E-8494-D20AE5DC8171}
// *********************************************************************//
  IAdSectionPrivate2 = interface(IAdSectionPrivate)
    ['{D3056730-81A9-4C5E-8494-D20AE5DC8171}']
    function Get_PrintState(out bVal: WordBool): HResult; stdcall;
    function Get_MarkupState(out bVal: WordBool): HResult; stdcall;
    function Get_MarkupEditState(out bVal: WordBool): HResult; stdcall;
    function Get_MarkupDeleteState(out bVal: WordBool): HResult; stdcall;
    function Get_DimensionState(out bVal: WordBool): HResult; stdcall;
    function ClearProperties: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdSectionType
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B62082F1-F5C8-4EBC-806A-B3D43EDF0629}
// *********************************************************************//
  IAdSectionType = interface(IDispatch)
    ['{B62082F1-F5C8-4EBC-806A-B3D43EDF0629}']
    function Get_Name: WideString; safecall;
    function Get_Sections: IDispatch; safecall;
    function Get_ObjectHighlightColor: OLE_COLOR; safecall;
    procedure Set_ObjectHighlightColor(pVal: OLE_COLOR); safecall;
    function Get_ObjectHighlightingEnabled: WordBool; safecall;
    procedure Set_ObjectHighlightingEnabled(pVal: WordBool); safecall;
    function Get_ObjectSelectionColor: OLE_COLOR; safecall;
    procedure Set_ObjectSelectionColor(pVal: OLE_COLOR); safecall;
    function Get_ReservedProperty04: OleVariant; safecall;
    procedure Set_ReservedProperty04(pVal: OleVariant); safecall;
    function Get_ReservedProperty05: OleVariant; safecall;
    procedure Set_ReservedProperty05(pVal: OleVariant); safecall;
    function Get_ReservedProperty06: OleVariant; safecall;
    procedure Set_ReservedProperty06(pVal: OleVariant); safecall;
    function Get_ReservedProperty07: OleVariant; safecall;
    procedure Set_ReservedProperty07(pVal: OleVariant); safecall;
    function Get_ReservedProperty08: OleVariant; safecall;
    procedure Set_ReservedProperty08(pVal: OleVariant); safecall;
    function Get_ReservedProperty09: OleVariant; safecall;
    procedure Set_ReservedProperty09(pVal: OleVariant); safecall;
    function Get_ReservedProperty10: OleVariant; safecall;
    procedure Set_ReservedProperty10(pVal: OleVariant); safecall;
    procedure ReservedMethod01; safecall;
    procedure ReservedMethod02; safecall;
    procedure ReservedMethod03; safecall;
    procedure ReservedMethod04; safecall;
    procedure ReservedMethod05; safecall;
    procedure ReservedMethod06; safecall;
    procedure ReservedMethod07; safecall;
    procedure ReservedMethod08; safecall;
    procedure ReservedMethod09; safecall;
    procedure ReservedMethod10; safecall;
    property Name: WideString read Get_Name;
    property Sections: IDispatch read Get_Sections;
    property ObjectHighlightColor: OLE_COLOR read Get_ObjectHighlightColor write Set_ObjectHighlightColor;
    property ObjectHighlightingEnabled: WordBool read Get_ObjectHighlightingEnabled write Set_ObjectHighlightingEnabled;
    property ObjectSelectionColor: OLE_COLOR read Get_ObjectSelectionColor write Set_ObjectSelectionColor;
    property ReservedProperty04: OleVariant read Get_ReservedProperty04 write Set_ReservedProperty04;
    property ReservedProperty05: OleVariant read Get_ReservedProperty05 write Set_ReservedProperty05;
    property ReservedProperty06: OleVariant read Get_ReservedProperty06 write Set_ReservedProperty06;
    property ReservedProperty07: OleVariant read Get_ReservedProperty07 write Set_ReservedProperty07;
    property ReservedProperty08: OleVariant read Get_ReservedProperty08 write Set_ReservedProperty08;
    property ReservedProperty09: OleVariant read Get_ReservedProperty09 write Set_ReservedProperty09;
    property ReservedProperty10: OleVariant read Get_ReservedProperty10 write Set_ReservedProperty10;
  end;

// *********************************************************************//
// DispIntf:  IAdSectionTypeDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B62082F1-F5C8-4EBC-806A-B3D43EDF0629}
// *********************************************************************//
  IAdSectionTypeDisp = dispinterface
    ['{B62082F1-F5C8-4EBC-806A-B3D43EDF0629}']
    property Name: WideString readonly dispid 1;
    property Sections: IDispatch readonly dispid 2;
    property ObjectHighlightColor: OLE_COLOR dispid 101;
    property ObjectHighlightingEnabled: WordBool dispid 102;
    property ObjectSelectionColor: OLE_COLOR dispid 103;
    property ReservedProperty04: OleVariant dispid 104;
    property ReservedProperty05: OleVariant dispid 105;
    property ReservedProperty06: OleVariant dispid 106;
    property ReservedProperty07: OleVariant dispid 107;
    property ReservedProperty08: OleVariant dispid 108;
    property ReservedProperty09: OleVariant dispid 109;
    property ReservedProperty10: OleVariant dispid 110;
    procedure ReservedMethod01; dispid 201;
    procedure ReservedMethod02; dispid 202;
    procedure ReservedMethod03; dispid 203;
    procedure ReservedMethod04; dispid 204;
    procedure ReservedMethod05; dispid 205;
    procedure ReservedMethod06; dispid 206;
    procedure ReservedMethod07; dispid 207;
    procedure ReservedMethod08; dispid 208;
    procedure ReservedMethod09; dispid 209;
    procedure ReservedMethod10; dispid 210;
  end;

// *********************************************************************//
// Interface: IAdSectionTypePrivate
// Flags:     (0)
// GUID:      {47C59FE2-CED9-4CAD-8E93-1C34C028799F}
// *********************************************************************//
  IAdSectionTypePrivate = interface(IUnknown)
    ['{47C59FE2-CED9-4CAD-8E93-1C34C028799F}']
  end;

// *********************************************************************//
// Interface: IAdComProxy
// Flags:     (0)
// GUID:      {FA831959-EB3A-461C-ACA2-50ED2C7B2F64}
// *********************************************************************//
  IAdComProxy = interface(IUnknown)
    ['{FA831959-EB3A-461C-ACA2-50ED2C7B2F64}']
    function Set_Parent(Param1: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdComProxy2
// Flags:     (0)
// GUID:      {A7AEA01B-65E4-4119-B78C-6A7E3E09EEE8}
// *********************************************************************//
  IAdComProxy2 = interface(IAdComProxy)
    ['{A7AEA01B-65E4-4119-B78C-6A7E3E09EEE8}']
    function Get_Parent(out pVal: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdECompositeViewer
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {81833E05-B5BD-433A-BAEE-58F46B1261EE}
// *********************************************************************//
  IAdECompositeViewer = interface(IAdViewer)
    ['{81833E05-B5BD-433A-BAEE-58F46B1261EE}']
    function Get_Bookmarks: IDispatch; safecall;
    function Get_Commands: IDispatch; safecall;
    function Get_DocumentName: WideString; safecall;
    function Get_HyperlinksEnabled: WordBool; safecall;
    procedure Set_HyperlinksEnabled(pVal: WordBool); safecall;
    function Get_HyperlinksHighlightColor: OLE_COLOR; safecall;
    procedure Set_HyperlinksHighlightColor(pVal: OLE_COLOR); safecall;
    function Get_HyperlinksHighlightingEnabled: WordBool; safecall;
    procedure Set_HyperlinksHighlightingEnabled(pVal: WordBool); safecall;
    function Get_HyperlinksSingleClickEnabled: WordBool; safecall;
    procedure Set_HyperlinksSingleClickEnabled(pVal: WordBool); safecall;
    function Get_HyperlinksTooltipsEnabled: WordBool; safecall;
    procedure Set_HyperlinksTooltipsEnabled(pVal: WordBool); safecall;
    function Get_IsClassicDWF: WordBool; safecall;
    function Get_Markups(vReserved: OleVariant): IDispatch; safecall;
    function Get_MarkupsVisible: WordBool; safecall;
    procedure Set_MarkupsVisible(pVal: WordBool); safecall;
    function Get_NavigationBarVisible: WordBool; safecall;
    procedure Set_NavigationBarVisible(pVal: WordBool); safecall;
    function Get_NotifyMissingFonts: WordBool; safecall;
    procedure Set_NotifyMissingFonts(pVal: WordBool); safecall;
    function Get_ObjectHighlightColor: OLE_COLOR; safecall;
    procedure Set_ObjectHighlightColor(pVal: OLE_COLOR); safecall;
    function Get_ObjectHighlightingEnabled: WordBool; safecall;
    procedure Set_ObjectHighlightingEnabled(pVal: WordBool); safecall;
    function Get_ObjectSelectionColor: OLE_COLOR; safecall;
    procedure Set_ObjectSelectionColor(pVal: OLE_COLOR); safecall;
    function Get_ObjectSelectionEnabled: WordBool; safecall;
    procedure Set_ObjectSelectionEnabled(pVal: WordBool); safecall;
    function Get_ObjectsSelected: OleVariant; safecall;
    procedure Set_ObjectsSelected(pVal: OleVariant); safecall;
    function Get_PanIncrement: Integer; safecall;
    procedure Set_PanIncrement(pVal: Integer); safecall;
    function Get_PaperColor: OLE_COLOR; safecall;
    procedure Set_PaperColor(newVal: OLE_COLOR); safecall;
    function Get_PaperColorAsPublished: WordBool; safecall;
    procedure Set_PaperColorAsPublished(pVal: WordBool); safecall;
    function Get_PaperTilesVisible: WordBool; safecall;
    procedure Set_PaperTilesVisible(pVal: WordBool); safecall;
    function Get_PaperVisible: WordBool; safecall;
    procedure Set_PaperVisible(pVal: WordBool); safecall;
    function Get_Section: OleVariant; safecall;
    procedure Set_Section(pVal: OleVariant); safecall;
    function Get_Sections: IDispatch; safecall;
    function Get_SectionTypes: IDispatch; safecall;
    function Get_ToolbarVisible: WordBool; safecall;
    procedure Set_ToolbarVisible(pVal: WordBool); safecall;
    function Get_UserInterfaceEnabled: WordBool; safecall;
    procedure Set_UserInterfaceEnabled(pVal: WordBool); safecall;
    function Get_ZoomIncrement: Integer; safecall;
    procedure Set_ZoomIncrement(pVal: Integer); safecall;
    function Get_ColorMode: Integer; safecall;
    procedure Set_ColorMode(pVal: Integer); safecall;
    procedure WaitForDocumentLoaded; safecall;
    procedure WaitForSectionLoaded; safecall;
    property Bookmarks: IDispatch read Get_Bookmarks;
    property Commands: IDispatch read Get_Commands;
    property DocumentName: WideString read Get_DocumentName;
    property HyperlinksEnabled: WordBool read Get_HyperlinksEnabled write Set_HyperlinksEnabled;
    property HyperlinksHighlightColor: OLE_COLOR read Get_HyperlinksHighlightColor write Set_HyperlinksHighlightColor;
    property HyperlinksHighlightingEnabled: WordBool read Get_HyperlinksHighlightingEnabled write Set_HyperlinksHighlightingEnabled;
    property HyperlinksSingleClickEnabled: WordBool read Get_HyperlinksSingleClickEnabled write Set_HyperlinksSingleClickEnabled;
    property HyperlinksTooltipsEnabled: WordBool read Get_HyperlinksTooltipsEnabled write Set_HyperlinksTooltipsEnabled;
    property IsClassicDWF: WordBool read Get_IsClassicDWF;
    property Markups[vReserved: OleVariant]: IDispatch read Get_Markups;
    property MarkupsVisible: WordBool read Get_MarkupsVisible write Set_MarkupsVisible;
    property NavigationBarVisible: WordBool read Get_NavigationBarVisible write Set_NavigationBarVisible;
    property NotifyMissingFonts: WordBool read Get_NotifyMissingFonts write Set_NotifyMissingFonts;
    property ObjectHighlightColor: OLE_COLOR read Get_ObjectHighlightColor write Set_ObjectHighlightColor;
    property ObjectHighlightingEnabled: WordBool read Get_ObjectHighlightingEnabled write Set_ObjectHighlightingEnabled;
    property ObjectSelectionColor: OLE_COLOR read Get_ObjectSelectionColor write Set_ObjectSelectionColor;
    property ObjectSelectionEnabled: WordBool read Get_ObjectSelectionEnabled write Set_ObjectSelectionEnabled;
    property ObjectsSelected: OleVariant read Get_ObjectsSelected write Set_ObjectsSelected;
    property PanIncrement: Integer read Get_PanIncrement write Set_PanIncrement;
    property PaperColor: OLE_COLOR read Get_PaperColor write Set_PaperColor;
    property PaperColorAsPublished: WordBool read Get_PaperColorAsPublished write Set_PaperColorAsPublished;
    property PaperTilesVisible: WordBool read Get_PaperTilesVisible write Set_PaperTilesVisible;
    property PaperVisible: WordBool read Get_PaperVisible write Set_PaperVisible;
    property Section: OleVariant read Get_Section write Set_Section;
    property Sections: IDispatch read Get_Sections;
    property SectionTypes: IDispatch read Get_SectionTypes;
    property ToolbarVisible: WordBool read Get_ToolbarVisible write Set_ToolbarVisible;
    property UserInterfaceEnabled: WordBool read Get_UserInterfaceEnabled write Set_UserInterfaceEnabled;
    property ZoomIncrement: Integer read Get_ZoomIncrement write Set_ZoomIncrement;
    property ColorMode: Integer read Get_ColorMode write Set_ColorMode;
  end;

// *********************************************************************//
// DispIntf:  IAdECompositeViewerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {81833E05-B5BD-433A-BAEE-58F46B1261EE}
// *********************************************************************//
  IAdECompositeViewerDisp = dispinterface
    ['{81833E05-B5BD-433A-BAEE-58F46B1261EE}']
    property Bookmarks: IDispatch readonly dispid 1001;
    property Commands: IDispatch readonly dispid 1002;
    property DocumentName: WideString readonly dispid 1003;
    property HyperlinksEnabled: WordBool dispid 1004;
    property HyperlinksHighlightColor: OLE_COLOR dispid 1005;
    property HyperlinksHighlightingEnabled: WordBool dispid 1006;
    property HyperlinksSingleClickEnabled: WordBool dispid 1007;
    property HyperlinksTooltipsEnabled: WordBool dispid 1008;
    property IsClassicDWF: WordBool readonly dispid 1009;
    property Markups[vReserved: OleVariant]: IDispatch readonly dispid 1010;
    property MarkupsVisible: WordBool dispid 1011;
    property NavigationBarVisible: WordBool dispid 1012;
    property NotifyMissingFonts: WordBool dispid 1013;
    property ObjectHighlightColor: OLE_COLOR dispid 1014;
    property ObjectHighlightingEnabled: WordBool dispid 1015;
    property ObjectSelectionColor: OLE_COLOR dispid 1016;
    property ObjectSelectionEnabled: WordBool dispid 1017;
    property ObjectsSelected: OleVariant dispid 1018;
    property PanIncrement: Integer dispid 1019;
    property PaperColor: OLE_COLOR dispid 1020;
    property PaperColorAsPublished: WordBool dispid 1021;
    property PaperTilesVisible: WordBool dispid 1022;
    property PaperVisible: WordBool dispid 1023;
    property Section: OleVariant dispid 1024;
    property Sections: IDispatch readonly dispid 1025;
    property SectionTypes: IDispatch readonly dispid 1026;
    property ToolbarVisible: WordBool dispid 1027;
    property UserInterfaceEnabled: WordBool dispid 1028;
    property ZoomIncrement: Integer dispid 1029;
    property ColorMode: Integer dispid 1030;
    procedure WaitForDocumentLoaded; dispid 1031;
    procedure WaitForSectionLoaded; dispid 1032;
    property BackColor: OLE_COLOR dispid -501;
    property EmbedSourceDocument: WordBool dispid 3;
    property SourcePath: WideString dispid 1;
    property Viewer: IDispatch readonly dispid 2;
    procedure ShowPrintDialog; dispid 101;
    procedure NavigateToUrl(const bstrUrl: WideString); dispid 103;
    procedure ExecuteCommand(const bstrCommand: WideString); dispid 104;
    procedure DrawToDC(nDc: Integer; nLeft: Integer; nTop: Integer; nRight: Integer; 
                       nBottom: Integer); dispid 105;
    property _ActiveWindow: OleVariant readonly dispid 200;
    property _ClientWindow: OleVariant readonly dispid 202;
    property _DocumentParams: WideString readonly dispid 203;
    property _HistoryParams: WideString readonly dispid 204;
    property _LocalFilePath: WideString readonly dispid 205;
    property _SourceStream: IUnknown writeonly dispid 206;
    property _ViewerParams: WideString dispid 201;
    procedure _GoBack; dispid 300;
    procedure _GoForward; dispid 301;
    procedure _SaveHistory; dispid 302;
    procedure _ShowHelp(const bstrTopic: WideString); dispid 303;
    property DocumentHandler: IDispatch readonly dispid 106;
    property DocumentType: WideString readonly dispid 107;
    procedure ExecuteCommandEx(const bstrCommand: WideString; lVal: Integer); dispid 108;
    property GradientBackgroundColor: OLE_COLOR dispid 401;
    property GradientBackgroundEnabled: WordBool dispid 402;
    property ContextMenu: IDispatch dispid 403;
    property CanvasEmpty: WordBool dispid 404;
    property ReservedProperty05: OleVariant dispid 405;
    property ReservedProperty06: OleVariant dispid 406;
    property ReservedProperty07: OleVariant dispid 407;
    property ReservedProperty08: OleVariant dispid 408;
    property ReservedProperty09: OleVariant dispid 409;
    property ReservedProperty10: OleVariant dispid 410;
    property ReservedProperty11: OleVariant dispid 411;
    property ReservedProperty12: OleVariant dispid 412;
    property ReservedProperty13: OleVariant dispid 413;
    property ReservedProperty14: OleVariant dispid 414;
    property ReservedProperty15: OleVariant dispid 415;
    property ReservedProperty16: OleVariant dispid 416;
    property ReservedProperty17: OleVariant dispid 417;
    property ReservedProperty18: OleVariant dispid 418;
    property ReservedProperty19: OleVariant dispid 419;
    property ReservedProperty20: OleVariant dispid 420;
    procedure _ShowCIPDialog; dispid 421;
    procedure ReservedMethod02; dispid 422;
    procedure ReservedMethod03; dispid 423;
    procedure ReservedMethod04; dispid 424;
    procedure ReservedMethod05; dispid 425;
    procedure ReservedMethod06; dispid 426;
    procedure ReservedMethod07; dispid 427;
    procedure ReservedMethod08; dispid 428;
    procedure ReservedMethod09; dispid 429;
    procedure ReservedMethod10; dispid 430;
    procedure ReservedMethod11; dispid 431;
    procedure ReservedMethod12; dispid 432;
    procedure ReservedMethod13; dispid 433;
    procedure ReservedMethod14; dispid 434;
    procedure ReservedMethod15; dispid 435;
    procedure ReservedMethod16; dispid 436;
    procedure ReservedMethod17; dispid 437;
    procedure ReservedMethod18; dispid 438;
    procedure ReservedMethod19; dispid 439;
    procedure ReservedMethod20; dispid 440;
  end;

// *********************************************************************//
// Interface: IAdECompositeViewer2
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B73C9E23-0A58-4E18-8E31-AEF5E4003120}
// *********************************************************************//
  IAdECompositeViewer2 = interface(IAdECompositeViewer)
    ['{B73C9E23-0A58-4E18-8E31-AEF5E4003120}']
    function Get_PublishedCoordinateSystemName: WideString; safecall;
    function Get_PublishedCoordinateSystemUnits: WideString; safecall;
    procedure initializeGPSDevice(gpsRefreshInterval: Integer; comPort: Integer); safecall;
    procedure disconnectGPSDevice; safecall;
    procedure setAutoGPSMode(gpsOnOff: WordBool); safecall;
    procedure centerToCoordinates(coordType: Integer; coordX: Double; coordY: Double); safecall;
    procedure PrintSection(pSection: OleVariant; pView: OleVariant; bWhiteBackground: WordBool; 
                           nDc: Integer); safecall;
    property PublishedCoordinateSystemName: WideString read Get_PublishedCoordinateSystemName;
    property PublishedCoordinateSystemUnits: WideString read Get_PublishedCoordinateSystemUnits;
  end;

// *********************************************************************//
// DispIntf:  IAdECompositeViewer2Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B73C9E23-0A58-4E18-8E31-AEF5E4003120}
// *********************************************************************//
  IAdECompositeViewer2Disp = dispinterface
    ['{B73C9E23-0A58-4E18-8E31-AEF5E4003120}']
    property PublishedCoordinateSystemName: WideString readonly dispid 1050;
    property PublishedCoordinateSystemUnits: WideString readonly dispid 1051;
    procedure initializeGPSDevice(gpsRefreshInterval: Integer; comPort: Integer); dispid 1060;
    procedure disconnectGPSDevice; dispid 1061;
    procedure setAutoGPSMode(gpsOnOff: WordBool); dispid 1062;
    procedure centerToCoordinates(coordType: Integer; coordX: Double; coordY: Double); dispid 1063;
    procedure PrintSection(pSection: OleVariant; pView: OleVariant; bWhiteBackground: WordBool; 
                           nDc: Integer); dispid 1064;
    property Bookmarks: IDispatch readonly dispid 1001;
    property Commands: IDispatch readonly dispid 1002;
    property DocumentName: WideString readonly dispid 1003;
    property HyperlinksEnabled: WordBool dispid 1004;
    property HyperlinksHighlightColor: OLE_COLOR dispid 1005;
    property HyperlinksHighlightingEnabled: WordBool dispid 1006;
    property HyperlinksSingleClickEnabled: WordBool dispid 1007;
    property HyperlinksTooltipsEnabled: WordBool dispid 1008;
    property IsClassicDWF: WordBool readonly dispid 1009;
    property Markups[vReserved: OleVariant]: IDispatch readonly dispid 1010;
    property MarkupsVisible: WordBool dispid 1011;
    property NavigationBarVisible: WordBool dispid 1012;
    property NotifyMissingFonts: WordBool dispid 1013;
    property ObjectHighlightColor: OLE_COLOR dispid 1014;
    property ObjectHighlightingEnabled: WordBool dispid 1015;
    property ObjectSelectionColor: OLE_COLOR dispid 1016;
    property ObjectSelectionEnabled: WordBool dispid 1017;
    property ObjectsSelected: OleVariant dispid 1018;
    property PanIncrement: Integer dispid 1019;
    property PaperColor: OLE_COLOR dispid 1020;
    property PaperColorAsPublished: WordBool dispid 1021;
    property PaperTilesVisible: WordBool dispid 1022;
    property PaperVisible: WordBool dispid 1023;
    property Section: OleVariant dispid 1024;
    property Sections: IDispatch readonly dispid 1025;
    property SectionTypes: IDispatch readonly dispid 1026;
    property ToolbarVisible: WordBool dispid 1027;
    property UserInterfaceEnabled: WordBool dispid 1028;
    property ZoomIncrement: Integer dispid 1029;
    property ColorMode: Integer dispid 1030;
    procedure WaitForDocumentLoaded; dispid 1031;
    procedure WaitForSectionLoaded; dispid 1032;
    property BackColor: OLE_COLOR dispid -501;
    property EmbedSourceDocument: WordBool dispid 3;
    property SourcePath: WideString dispid 1;
    property Viewer: IDispatch readonly dispid 2;
    procedure ShowPrintDialog; dispid 101;
    procedure NavigateToUrl(const bstrUrl: WideString); dispid 103;
    procedure ExecuteCommand(const bstrCommand: WideString); dispid 104;
    procedure DrawToDC(nDc: Integer; nLeft: Integer; nTop: Integer; nRight: Integer; 
                       nBottom: Integer); dispid 105;
    property _ActiveWindow: OleVariant readonly dispid 200;
    property _ClientWindow: OleVariant readonly dispid 202;
    property _DocumentParams: WideString readonly dispid 203;
    property _HistoryParams: WideString readonly dispid 204;
    property _LocalFilePath: WideString readonly dispid 205;
    property _SourceStream: IUnknown writeonly dispid 206;
    property _ViewerParams: WideString dispid 201;
    procedure _GoBack; dispid 300;
    procedure _GoForward; dispid 301;
    procedure _SaveHistory; dispid 302;
    procedure _ShowHelp(const bstrTopic: WideString); dispid 303;
    property DocumentHandler: IDispatch readonly dispid 106;
    property DocumentType: WideString readonly dispid 107;
    procedure ExecuteCommandEx(const bstrCommand: WideString; lVal: Integer); dispid 108;
    property GradientBackgroundColor: OLE_COLOR dispid 401;
    property GradientBackgroundEnabled: WordBool dispid 402;
    property ContextMenu: IDispatch dispid 403;
    property CanvasEmpty: WordBool dispid 404;
    property ReservedProperty05: OleVariant dispid 405;
    property ReservedProperty06: OleVariant dispid 406;
    property ReservedProperty07: OleVariant dispid 407;
    property ReservedProperty08: OleVariant dispid 408;
    property ReservedProperty09: OleVariant dispid 409;
    property ReservedProperty10: OleVariant dispid 410;
    property ReservedProperty11: OleVariant dispid 411;
    property ReservedProperty12: OleVariant dispid 412;
    property ReservedProperty13: OleVariant dispid 413;
    property ReservedProperty14: OleVariant dispid 414;
    property ReservedProperty15: OleVariant dispid 415;
    property ReservedProperty16: OleVariant dispid 416;
    property ReservedProperty17: OleVariant dispid 417;
    property ReservedProperty18: OleVariant dispid 418;
    property ReservedProperty19: OleVariant dispid 419;
    property ReservedProperty20: OleVariant dispid 420;
    procedure _ShowCIPDialog; dispid 421;
    procedure ReservedMethod02; dispid 422;
    procedure ReservedMethod03; dispid 423;
    procedure ReservedMethod04; dispid 424;
    procedure ReservedMethod05; dispid 425;
    procedure ReservedMethod06; dispid 426;
    procedure ReservedMethod07; dispid 427;
    procedure ReservedMethod08; dispid 428;
    procedure ReservedMethod09; dispid 429;
    procedure ReservedMethod10; dispid 430;
    procedure ReservedMethod11; dispid 431;
    procedure ReservedMethod12; dispid 432;
    procedure ReservedMethod13; dispid 433;
    procedure ReservedMethod14; dispid 434;
    procedure ReservedMethod15; dispid 435;
    procedure ReservedMethod16; dispid 436;
    procedure ReservedMethod17; dispid 437;
    procedure ReservedMethod18; dispid 438;
    procedure ReservedMethod19; dispid 439;
    procedure ReservedMethod20; dispid 440;
  end;

// *********************************************************************//
// Interface: IAdECompositeViewerPrivate
// Flags:     (0)
// GUID:      {2CC12E7B-254E-4555-9874-7931E5E49260}
// *********************************************************************//
  IAdECompositeViewerPrivate = interface(IUnknown)
    ['{2CC12E7B-254E-4555-9874-7931E5E49260}']
    function Get_CommandEnabled(const Command: WideString; out pVal: WordBool): HResult; stdcall;
    function Set_CommandEnabled(const Command: WideString; pVal: WordBool): HResult; stdcall;
    function Get_CommandState(const Command: WideString; out pVal: Integer): HResult; stdcall;
    function Set_CommandState(const Command: WideString; pVal: Integer): HResult; stdcall;
    function Get_CommandVisible(const Command: WideString; out pVal: WordBool): HResult; stdcall;
    function Set_CommandVisible(const Command: WideString; pVal: WordBool): HResult; stdcall;
    function Get_ViewerState(out pVal: Integer): HResult; stdcall;
    function Get_ViewerState_CObject(out pVal: OleVariant): HResult; stdcall;
    function Get_Presenter_CObject(out pVal: OleVariant): HResult; stdcall;
    function Get_ConfigDir(out pVal: WideString): HResult; stdcall;
    function Get_CObject(out pVal: OleVariant): HResult; stdcall;
    function Set_SelectedInstances(const pInstanceTreeNodes: IDispatch): HResult; stdcall;
    function Get_SelectedInstances(out pInstanceTreeNodes: IDispatch): HResult; stdcall;
    function Get_LocalizedResourceHandle(out pVal: OleVariant): HResult; stdcall;
    function Get_SectionLoaded(out pVal: WordBool): HResult; stdcall;
    function Get_InsideExecutable(out pVal: WordBool): HResult; stdcall;
    function Get_AdSection_CObject(const Href: WideString; out pVal: OleVariant): HResult; stdcall;
    function Set_DocumentName(const Param1: WideString): HResult; stdcall;
    function DoOverURL(X: SYSINT; Y: SYSINT; const iAdPageLink: IDispatch): HResult; stdcall;
    function DoLeaveURL(X: SYSINT; Y: SYSINT; const iAdPageLink: IDispatch): HResult; stdcall;
    function DoExecuteURL(const iAdPageLink: IDispatch; index: Word): HResult; stdcall;
    function ExecuteURL(const url: WideString): HResult; stdcall;
    function SetCommandToggle(const cmd: WideString; State: WordBool): HResult; stdcall;
    function SetObjectCommandStates: HResult; stdcall;
    function Invalidate: HResult; stdcall;
    function Update: HResult; stdcall;
    function LoadSection(var vSection: OleVariant; var vLoader: OleVariant; bThreadedLoad: WordBool): HResult; stdcall;
    function _SetDirty: HResult; stdcall;
    function _doCheckUiMessages: HResult; stdcall;
    function SetSaveHistoryOnLoad(__MIDL_0025: WordBool): HResult; stdcall;
    function SaveDocument(const doc_name: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdECompositeViewerPrivate2
// Flags:     (0)
// GUID:      {70B89B01-66CA-4097-AB8E-472D6AB56B4D}
// *********************************************************************//
  IAdECompositeViewerPrivate2 = interface(IAdECompositeViewerPrivate)
    ['{70B89B01-66CA-4097-AB8E-472D6AB56B4D}']
    function Get_DataSectionCount(out pVal: Integer): HResult; stdcall;
    function Get_Document_CObject(out pVal: OleVariant): HResult; stdcall;
    function Get_Editor_CObject(out pVal: OleVariant): HResult; stdcall;
    function Set_fileName(const Param1: WideString): HResult; stdcall;
    function Get_GraphicSectionCount(out pVal: Integer): HResult; stdcall;
    function Get_IsBatchPrinting(out pVal: WordBool): HResult; stdcall;
    function Set_IsBatchPrinting(pVal: WordBool): HResult; stdcall;
    function Set_IsProcessingHistoryView(pVal: WordBool): HResult; stdcall;
    function Get_IsProcessingHistoryView(out pVal: WordBool): HResult; stdcall;
    function Set_SectionAsynchronous(Param1: OleVariant): HResult; stdcall;
    function Get_SectionsAsynchronous(out pVal: IDispatch): HResult; stdcall;
    function Get_SectionIndex(const vHref: WideString; out pVal: Integer): HResult; stdcall;
    function AddGroupSetData(const sName: WideString; const sCommand: WideString; vData: OleVariant): HResult; stdcall;
    function AddGroupSetUiItem(const sCommand: WideString; vData: OleVariant): HResult; stdcall;
    function AddGroupEnableUiItem(const sCommand: WideString; bEnabled: WordBool): HResult; stdcall;
    function FindPresenter_CObject(const sName: WideString; out pVal: OleVariant): HResult; stdcall;
    function FireEventGroup(vbBlock: WordBool): HResult; stdcall;
    function MeasureCancelled: HResult; stdcall;
    function RegisterDWFAppPackageEncrypted(vDispatcher: OleVariant): HResult; stdcall;
    function RegisterSectionsAdded(vDispatcher: OleVariant): HResult; stdcall;
    function RegisterSectionsDeleted(vDispatcher: OleVariant): HResult; stdcall;
    function RegisterSectionsReordered(vDispatcher: OleVariant): HResult; stdcall;
    function ShellPrint(const bstrPrinter: WideString): HResult; stdcall;
    function StartBatchPrint(const sConfigFileName: WideString; iDwfIndex: SYSINT): HResult; stdcall;
    function UnregisterDWFAppPackageEncrypted(vDispatcher: OleVariant): HResult; stdcall;
    function UpdateNextPreviousUI: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdECompositeViewerPrivate3
// Flags:     (0)
// GUID:      {6A588D68-5702-4CD1-ACB7-EF55BF3222DD}
// *********************************************************************//
  IAdECompositeViewerPrivate3 = interface(IAdECompositeViewerPrivate2)
    ['{6A588D68-5702-4CD1-ACB7-EF55BF3222DD}']
    function Get_GeorefCoordinateSystemFormat(out pVal: Integer): HResult; stdcall;
    function Set_GeorefCoordinateSystemFormat(pVal: Integer): HResult; stdcall;
    function Get_GPSConnection(out nConnected: Integer): HResult; stdcall;
    function Get_GPSStatus(out statusString: WideString): HResult; stdcall;
    function Set_CommandLocked(const cmd: WideString; Param2: WordBool): HResult; stdcall;
    function Get_CompareViewer(out pViewer: IDispatch): HResult; stdcall;
    function Set_CompareViewer(const pViewer: IDispatch): HResult; stdcall;
    function ShowGPSStatusDialog: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdECompositeViewerPrivate4
// Flags:     (0)
// GUID:      {1FEBB6CC-9588-4513-AB58-E09F42EEAAEC}
// *********************************************************************//
  IAdECompositeViewerPrivate4 = interface(IAdECompositeViewerPrivate3)
    ['{1FEBB6CC-9588-4513-AB58-E09F42EEAAEC}']
    function Set_BatchPrintMode(Param1: WordBool): HResult; stdcall;
    function Set_BatchPrintLogFile(const Param1: WideString): HResult; stdcall;
    function Get_ModelRenderingOptions_CObject(out pVal: OleVariant): HResult; stdcall;
    function Set_ModelRenderingOptions_CObject(pVal: OleVariant): HResult; stdcall;
    function SearchDWFFromToolbar(const strSearchText: WideString; bStartSearch: WordBool): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdPageNavigatorCtrl
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {43F5A909-56B9-4106-9472-27D9BDE5B745}
// *********************************************************************//
  IAdPageNavigatorCtrl = interface(IDispatch)
    ['{43F5A909-56B9-4106-9472-27D9BDE5B745}']
    procedure SetViewer(const pVal: IDispatch); safecall;
    procedure ExecuteCommandEx(const bstrVal: WideString; lIndex: Integer); safecall;
  end;

// *********************************************************************//
// DispIntf:  IAdPageNavigatorCtrlDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {43F5A909-56B9-4106-9472-27D9BDE5B745}
// *********************************************************************//
  IAdPageNavigatorCtrlDisp = dispinterface
    ['{43F5A909-56B9-4106-9472-27D9BDE5B745}']
    procedure SetViewer(const pVal: IDispatch); dispid 100;
    procedure ExecuteCommandEx(const bstrVal: WideString; lIndex: Integer); dispid 101;
  end;

// *********************************************************************//
// Interface: IAdBookmark
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {92ABF954-74B1-410A-AFEF-8FCC53FB9655}
// *********************************************************************//
  IAdBookmark = interface(IDispatch)
    ['{92ABF954-74B1-410A-AFEF-8FCC53FB9655}']
    function Get_Children: IDispatch; safecall;
    function Get_Href: WideString; safecall;
    function Get_Name: WideString; safecall;
    procedure Set__Href(const Param1: WideString); safecall;
    procedure Set__Name(const Param1: WideString); safecall;
    procedure Set__Child(const Param1: IDispatch); safecall;
    procedure Set__Children(const Param1: IDispatch); safecall;
    procedure _SetDwfBookmark(pVal: OleVariant); safecall;
    property Children: IDispatch read Get_Children;
    property Href: WideString read Get_Href;
    property Name: WideString read Get_Name;
    property _Href: WideString write Set__Href;
    property _Name: WideString write Set__Name;
    property _Child: IDispatch write Set__Child;
    property _Children: IDispatch write Set__Children;
  end;

// *********************************************************************//
// DispIntf:  IAdBookmarkDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {92ABF954-74B1-410A-AFEF-8FCC53FB9655}
// *********************************************************************//
  IAdBookmarkDisp = dispinterface
    ['{92ABF954-74B1-410A-AFEF-8FCC53FB9655}']
    property Children: IDispatch readonly dispid 1;
    property Href: WideString readonly dispid 2;
    property Name: WideString readonly dispid 3;
    property _Href: WideString writeonly dispid 50;
    property _Name: WideString writeonly dispid 51;
    property _Child: IDispatch writeonly dispid 52;
    property _Children: IDispatch writeonly dispid 53;
    procedure _SetDwfBookmark(pVal: OleVariant); dispid 101;
  end;

// *********************************************************************//
// Interface: IAdUiMediator
// Flags:     (0)
// GUID:      {1A49003C-9870-4453-A838-90E086C93F48}
// *********************************************************************//
  IAdUiMediator = interface(IUnknown)
    ['{1A49003C-9870-4453-A838-90E086C93F48}']
    function FocusBand(const bstrFocusBand: WideString; bFocused: WordBool): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdUiBandFocusMediator
// Flags:     (0)
// GUID:      {0440EE56-C13E-4448-9D0D-7AFB29E7D9F5}
// *********************************************************************//
  IAdUiBandFocusMediator = interface(IAdUiMediator)
    ['{0440EE56-C13E-4448-9D0D-7AFB29E7D9F5}']
  end;

// *********************************************************************//
// DispIntf:  IMarkupEvents
// Flags:     (4096) Dispatchable
// GUID:      {B719F3CC-3718-422D-9D5E-C6579ED318E5}
// *********************************************************************//
  IMarkupEvents = dispinterface
    ['{B719F3CC-3718-422D-9D5E-C6579ED318E5}']
    procedure OnMarkupCreated(const pEPlotInstance: IDispatch; const bstrPageDescriptor: WideString); dispid 1;
    procedure OnDeletingMarkup(const pEPlotInstance: IDispatch; const bstrPageDescriptor: WideString); dispid 2;
    procedure OnMarkupModified(const pEPlotInstance: IDispatch; const bstrPageDescriptor: WideString); dispid 3;
    procedure OnMarkupSelected(const pEPlotInstance: IDispatch; const bstrPageDescriptor: WideString); dispid 4;
  end;

// *********************************************************************//
// Interface: IAdCommand
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A15A152A-3F26-4C90-BC0F-EEFCD5869652}
// *********************************************************************//
  IAdCommand = interface(IDispatch)
    ['{A15A152A-3F26-4C90-BC0F-EEFCD5869652}']
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(pVal: WordBool); safecall;
    function Get_Toggled: WordBool; safecall;
    procedure Set_Toggled(pVal: WordBool); safecall;
    function Get_TriState: WordBool; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(pVal: WordBool); safecall;
    function Get_Restricted: WordBool; safecall;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Toggled: WordBool read Get_Toggled write Set_Toggled;
    property TriState: WordBool read Get_TriState;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Restricted: WordBool read Get_Restricted;
  end;

// *********************************************************************//
// DispIntf:  IAdCommandDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A15A152A-3F26-4C90-BC0F-EEFCD5869652}
// *********************************************************************//
  IAdCommandDisp = dispinterface
    ['{A15A152A-3F26-4C90-BC0F-EEFCD5869652}']
    property Enabled: WordBool dispid 1;
    property Toggled: WordBool dispid 2;
    property TriState: WordBool readonly dispid 3;
    property Visible: WordBool dispid 4;
    property Restricted: WordBool readonly dispid 5;
  end;

// *********************************************************************//
// Interface: IAdPaper
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D82B647D-FDCC-45D8-8DC7-841707689D73}
// *********************************************************************//
  IAdPaper = interface(IDispatch)
    ['{D82B647D-FDCC-45D8-8DC7-841707689D73}']
    function Get_Clip: IDispatch; safecall;
    function Get_Color: OLE_COLOR; safecall;
    function Get_Height: Double; safecall;
    function Get_Units: SYSINT; safecall;
    function Get_Width: Double; safecall;
    property Clip: IDispatch read Get_Clip;
    property Color: OLE_COLOR read Get_Color;
    property Height: Double read Get_Height;
    property Units: SYSINT read Get_Units;
    property Width: Double read Get_Width;
  end;

// *********************************************************************//
// DispIntf:  IAdPaperDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D82B647D-FDCC-45D8-8DC7-841707689D73}
// *********************************************************************//
  IAdPaperDisp = dispinterface
    ['{D82B647D-FDCC-45D8-8DC7-841707689D73}']
    property Clip: IDispatch readonly dispid 1;
    property Color: OLE_COLOR readonly dispid 2;
    property Height: Double readonly dispid 3;
    property Units: SYSINT readonly dispid 4;
    property Width: Double readonly dispid 5;
  end;

// *********************************************************************//
// Interface: IAdDwfImporter
// Flags:     (0)
// GUID:      {D59A8E1B-97BB-4887-AF66-58B725CBA693}
// *********************************************************************//
  IAdDwfImporter = interface(IUnknown)
    ['{D59A8E1B-97BB-4887-AF66-58B725CBA693}']
    function Get_SelfManaged(var pVal: WordBool): HResult; stdcall;
    function ImportDwf(vImport: OleVariant; const bExport: WideString; const pParent: IUnknown; 
                       var pbError: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdDwfExporter
// Flags:     (0)
// GUID:      {A6285F26-E69F-49CD-BE72-6E80C7A675F4}
// *********************************************************************//
  IAdDwfExporter = interface(IUnknown)
    ['{A6285F26-E69F-49CD-BE72-6E80C7A675F4}']
    function Get_SelfManaged(var pVal: WordBool): HResult; stdcall;
    function ExportDwf(vExport: OleVariant; const bExport: WideString; 
                       const bOutputPassword: WideString; const pParent: IUnknown; 
                       var pbError: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdInstanceTreeNode
// Flags:     (0)
// GUID:      {AAE5A642-DE55-479F-B83E-AB7BA6FF29EE}
// *********************************************************************//
  IAdInstanceTreeNode = interface(IUnknown)
    ['{AAE5A642-DE55-479F-B83E-AB7BA6FF29EE}']
    function Get_Children(out ppChildren: IDispatch): HResult; stdcall;
    function Get_Instance(out ppInstance: IDispatch): HResult; stdcall;
    function Get_Level(var pnLevel: Integer): HResult; stdcall;
    function Get_Parent(out ppParent: IDispatch): HResult; stdcall;
    function _CreateTreeNode(pInstanceTreeNode: OleVariant; out ppITreeNode: IAdInstanceTreeNode): HResult; stdcall;
    function Set__Parent(const Param1: IAdInstanceTreeNode): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdPrivateRelayEvent
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {81F93F5A-E932-42B5-99CF-6EFF7C57BE07}
// *********************************************************************//
  IAdPrivateRelayEvent = interface(IDispatch)
    ['{81F93F5A-E932-42B5-99CF-6EFF7C57BE07}']
    procedure _OnPrivateRelayEvent(const piPrivateRelayEventContent: IDispatch); safecall;
  end;

// *********************************************************************//
// DispIntf:  IAdPrivateRelayEventDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {81F93F5A-E932-42B5-99CF-6EFF7C57BE07}
// *********************************************************************//
  IAdPrivateRelayEventDisp = dispinterface
    ['{81F93F5A-E932-42B5-99CF-6EFF7C57BE07}']
    procedure _OnPrivateRelayEvent(const piPrivateRelayEventContent: IDispatch); dispid 1;
  end;

// *********************************************************************//
// Interface: IAdPrivateRelayEventContent
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {93601283-B854-4145-A8B3-64045EFE95D5}
// *********************************************************************//
  IAdPrivateRelayEventContent = interface(IDispatch)
    ['{93601283-B854-4145-A8B3-64045EFE95D5}']
    function Get_EventID: SYSINT; safecall;
    procedure Set_EventID(pVal: SYSINT); safecall;
    function Get_Arg1: OleVariant; safecall;
    procedure Set_Arg1(pvArg: OleVariant); safecall;
    function Get_Arg2: OleVariant; safecall;
    procedure Set_Arg2(pvArg: OleVariant); safecall;
    function Get_Arg3: OleVariant; safecall;
    procedure Set_Arg3(pvArg: OleVariant); safecall;
    function Get_Arg4: OleVariant; safecall;
    procedure Set_Arg4(pvArg: OleVariant); safecall;
    function Get_Arg5: OleVariant; safecall;
    procedure Set_Arg5(pvArg: OleVariant); safecall;
    function Get_Arg6: OleVariant; safecall;
    procedure Set_Arg6(pvArg: OleVariant); safecall;
    function Get_Arg7: OleVariant; safecall;
    procedure Set_Arg7(pvArg: OleVariant); safecall;
    function Get_Arg8: OleVariant; safecall;
    procedure Set_Arg8(pvArg: OleVariant); safecall;
    function Get_Arg9: OleVariant; safecall;
    procedure Set_Arg9(pvArg: OleVariant); safecall;
    function Get_Arg10: OleVariant; safecall;
    procedure Set_Arg10(pvArg: OleVariant); safecall;
    property EventID: SYSINT read Get_EventID write Set_EventID;
    property Arg1: OleVariant read Get_Arg1 write Set_Arg1;
    property Arg2: OleVariant read Get_Arg2 write Set_Arg2;
    property Arg3: OleVariant read Get_Arg3 write Set_Arg3;
    property Arg4: OleVariant read Get_Arg4 write Set_Arg4;
    property Arg5: OleVariant read Get_Arg5 write Set_Arg5;
    property Arg6: OleVariant read Get_Arg6 write Set_Arg6;
    property Arg7: OleVariant read Get_Arg7 write Set_Arg7;
    property Arg8: OleVariant read Get_Arg8 write Set_Arg8;
    property Arg9: OleVariant read Get_Arg9 write Set_Arg9;
    property Arg10: OleVariant read Get_Arg10 write Set_Arg10;
  end;

// *********************************************************************//
// DispIntf:  IAdPrivateRelayEventContentDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {93601283-B854-4145-A8B3-64045EFE95D5}
// *********************************************************************//
  IAdPrivateRelayEventContentDisp = dispinterface
    ['{93601283-B854-4145-A8B3-64045EFE95D5}']
    property EventID: SYSINT dispid 1;
    property Arg1: OleVariant dispid 2;
    property Arg2: OleVariant dispid 3;
    property Arg3: OleVariant dispid 4;
    property Arg4: OleVariant dispid 5;
    property Arg5: OleVariant dispid 6;
    property Arg6: OleVariant dispid 7;
    property Arg7: OleVariant dispid 8;
    property Arg8: OleVariant dispid 9;
    property Arg9: OleVariant dispid 10;
    property Arg10: OleVariant dispid 11;
  end;

// *********************************************************************//
// Interface: IAdAdvControlGuest
// Flags:     (0)
// GUID:      {1222F2F5-36B7-4A5B-A72D-5AA26B032F27}
// *********************************************************************//
  IAdAdvControlGuest = interface(IUnknown)
    ['{1222F2F5-36B7-4A5B-A72D-5AA26B032F27}']
    function Get_HostAdvControl(out pVal: IUnknown): HResult; stdcall;
    function Set_HostAdvControl(const pVal: IUnknown): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdServiceHandlerFinder
// Flags:     (0)
// GUID:      {899B70A5-962E-41BA-A5B3-264A6D18B2D2}
// *********************************************************************//
  IAdServiceHandlerFinder = interface(IUnknown)
    ['{899B70A5-962E-41BA-A5B3-264A6D18B2D2}']
    function GetHandler(var ppiHandler: IAdServiceHandler): HResult; stdcall;
    function SetHandler(const piHandler: IAdServiceHandler): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdDwfImportManager
// Flags:     (0)
// GUID:      {DF424690-E891-400C-969E-421DA3F95C2E}
// *********************************************************************//
  IAdDwfImportManager = interface(IUnknown)
    ['{DF424690-E891-400C-969E-421DA3F95C2E}']
    function Get_ImporterClsid(const bImport: WideString; var pVal: WideString): HResult; stdcall;
    function Get_ImportDialogFilter(var pVal: WideString): HResult; stdcall;
    function Get_ImportParent(var pVal: IDispatch): HResult; stdcall;
    function Set_ImportProgress(Param1: Integer): HResult; stdcall;
    function ImportDwf(const pViewer: IDispatch; const bImporter: WideString; 
                       vImportSrc: OleVariant; const bImportDst: WideString; 
                       const bImportPath: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdDwfImportManager2
// Flags:     (0)
// GUID:      {D0A650D1-B17B-4109-80E2-FEBBA4FA2A84}
// *********************************************************************//
  IAdDwfImportManager2 = interface(IAdDwfImportManager)
    ['{D0A650D1-B17B-4109-80E2-FEBBA4FA2A84}']
    function Get_OpenDialogFilter(var pVal: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdDwfExportManager
// Flags:     (0)
// GUID:      {3A1596AC-0D1E-4014-930C-5408A58905A0}
// *********************************************************************//
  IAdDwfExportManager = interface(IUnknown)
    ['{3A1596AC-0D1E-4014-930C-5408A58905A0}']
    function Get_ExporterClsid(const bImport: WideString; var pVal: WideString): HResult; stdcall;
    function Get_ExportDialogFilter(var pVal: WideString): HResult; stdcall;
    function Get_SaveAsDialogFilter(var pVal: WideString): HResult; stdcall;
    function Get_ExportParent(var pVal: IDispatch): HResult; stdcall;
    function Set_ExportProgress(Param1: Integer): HResult; stdcall;
    function ExportFile(const pViewer: IDispatch; const bImporter: WideString; 
                        vImportSrc: OleVariant; const bImportDst: WideString; 
                        const bImportPath: WideString; const bOutputPassword: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdInstance
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C5E36A54-46E7-4F4F-B21F-A7BCA2117FDC}
// *********************************************************************//
  IAdInstance = interface(IDispatch)
    ['{C5E36A54-46E7-4F4F-B21F-A7BCA2117FDC}']
    function Get_Id: WideString; safecall;
    function Get_Properties: IDispatch; safecall;
    function Get_Nodes: OleVariant; safecall;
    function Get_ParentResourceId: WideString; safecall;
    property Id: WideString read Get_Id;
    property Properties: IDispatch read Get_Properties;
    property Nodes: OleVariant read Get_Nodes;
    property ParentResourceId: WideString read Get_ParentResourceId;
  end;

// *********************************************************************//
// DispIntf:  IAdInstanceDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C5E36A54-46E7-4F4F-B21F-A7BCA2117FDC}
// *********************************************************************//
  IAdInstanceDisp = dispinterface
    ['{C5E36A54-46E7-4F4F-B21F-A7BCA2117FDC}']
    property Id: WideString readonly dispid 1;
    property Properties: IDispatch readonly dispid 2;
    property Nodes: OleVariant readonly dispid 3;
    property ParentResourceId: WideString readonly dispid 4;
  end;

// *********************************************************************//
// Interface: IAdOptionsTabs
// Flags:     (0)
// GUID:      {19EA6C8E-1395-4AF5-B7CD-296D075FD040}
// *********************************************************************//
  IAdOptionsTabs = interface(IUnknown)
    ['{19EA6C8E-1395-4AF5-B7CD-296D075FD040}']
    function Get_OptionsTabs(out pOptionsTabs: IDispatch): HResult; stdcall;
    function UpdateOptions: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdStreamLength
// Flags:     (0)
// GUID:      {73F4AF60-C28A-4017-934E-18E2FB408A64}
// *********************************************************************//
  IAdStreamLength = interface(IUnknown)
    ['{73F4AF60-C28A-4017-934E-18E2FB408A64}']
    function Get__StreamLength(out ulBytes: OleVariant): HResult; stdcall;
    function Set__StreamLength(ulBytes: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdUiControlPrivate
// Flags:     (0)
// GUID:      {70839354-8F67-4F84-AB07-C85103E2F1A2}
// *********************************************************************//
  IAdUiControlPrivate = interface(IUnknown)
    ['{70839354-8F67-4F84-AB07-C85103E2F1A2}']
    function SetViewer(const pVal: IDispatch): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAdApiUtility
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {02B244B4-C55F-4BC0-B087-C0B86495F58F}
// *********************************************************************//
  IAdApiUtility = interface(IDispatch)
    ['{02B244B4-C55F-4BC0-B087-C0B86495F58F}']
    procedure Set_Viewer(const Param1: IDispatch); safecall;
    procedure AddToolBarCommand(const bstrToolBarName: WideString; 
                                const bstrCommandName: WideString; nInsertionIndex: Integer); safecall;
    procedure RemoveToolBarCommand(const bstrToolBarName: WideString; 
                                   const bstrCommandName: WideString); safecall;
    property Viewer: IDispatch write Set_Viewer;
  end;

// *********************************************************************//
// DispIntf:  IAdApiUtilityDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {02B244B4-C55F-4BC0-B087-C0B86495F58F}
// *********************************************************************//
  IAdApiUtilityDisp = dispinterface
    ['{02B244B4-C55F-4BC0-B087-C0B86495F58F}']
    property Viewer: IDispatch writeonly dispid 1;
    procedure AddToolBarCommand(const bstrToolBarName: WideString; 
                                const bstrCommandName: WideString; nInsertionIndex: Integer); dispid 2;
    procedure RemoveToolBarCommand(const bstrToolBarName: WideString; 
                                   const bstrCommandName: WideString); dispid 3;
  end;

// *********************************************************************//
// Interface: IAdProperty
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9045091A-0DE5-4588-B0D8-442463A1C788}
// *********************************************************************//
  IAdProperty = interface(IDispatch)
    ['{9045091A-0DE5-4588-B0D8-442463A1C788}']
    function Get_Name: WideString; safecall;
    procedure Set_Name(const pVal: WideString); safecall;
    function Get_Value: WideString; safecall;
    procedure Set_Value(const pVal: WideString); safecall;
    function Get_type_: WideString; safecall;
    procedure Set_type_(const pVal: WideString); safecall;
    function Get_Units: WideString; safecall;
    procedure Set_Units(const pVal: WideString); safecall;
    function Get_Category: WideString; safecall;
    procedure Set_Category(const pVal: WideString); safecall;
    function Get__DwfProperty: OleVariant; safecall;
    procedure Set__DwfProperty(pVal: OleVariant); safecall;
    property Name: WideString read Get_Name write Set_Name;
    property Value: WideString read Get_Value write Set_Value;
    property type_: WideString read Get_type_ write Set_type_;
    property Units: WideString read Get_Units write Set_Units;
    property Category: WideString read Get_Category write Set_Category;
    property _DwfProperty: OleVariant read Get__DwfProperty write Set__DwfProperty;
  end;

// *********************************************************************//
// DispIntf:  IAdPropertyDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9045091A-0DE5-4588-B0D8-442463A1C788}
// *********************************************************************//
  IAdPropertyDisp = dispinterface
    ['{9045091A-0DE5-4588-B0D8-442463A1C788}']
    property Name: WideString dispid 1;
    property Value: WideString dispid 2;
    property type_: WideString dispid 3;
    property Units: WideString dispid 4;
    property Category: WideString dispid 5;
    property _DwfProperty: OleVariant dispid 6;
  end;

// *********************************************************************//
// Interface: IAdPropertyPrivate
// Flags:     (0)
// GUID:      {6FC55A00-A3E8-493C-A949-A2259C35BE53}
// *********************************************************************//
  IAdPropertyPrivate = interface(IUnknown)
    ['{6FC55A00-A3E8-493C-A949-A2259C35BE53}']
    function Set__DwfPropertyCopy(Param1: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// The Class CoCAdApiUtility provides a Create and CreateRemote method to          
// create instances of the default interface IAdApiUtility exposed by              
// the CoClass CAdApiUtility. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCAdApiUtility = class
    class function Create: IAdApiUtility;
    class function CreateRemote(const MachineName: string): IAdApiUtility;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCAdApiUtility
// Help String      : CAdApiUtility Class
// Default Interface: IAdApiUtility
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TCAdApiUtilityProperties= class;
{$ENDIF}
  TCAdApiUtility = class(TOleServer)
  private
    FIntf:        IAdApiUtility;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TCAdApiUtilityProperties;
    function      GetServerProperties: TCAdApiUtilityProperties;
{$ENDIF}
    function      GetDefaultInterface: IAdApiUtility;
  protected
    procedure InitServerData; override;
    procedure Set_Viewer(const Param1: IDispatch);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IAdApiUtility);
    procedure Disconnect; override;
    procedure AddToolBarCommand(const bstrToolBarName: WideString; 
                                const bstrCommandName: WideString; nInsertionIndex: Integer);
    procedure RemoveToolBarCommand(const bstrToolBarName: WideString; 
                                   const bstrCommandName: WideString);
    property DefaultInterface: IAdApiUtility read GetDefaultInterface;
    property Viewer: IDispatch write Set_Viewer;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TCAdApiUtilityProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TCAdApiUtility
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TCAdApiUtilityProperties = class(TPersistent)
  private
    FServer:    TCAdApiUtility;
    function    GetDefaultInterface: IAdApiUtility;
    constructor Create(AServer: TCAdApiUtility);
  protected
    procedure Set_Viewer(const Param1: IDispatch);
  public
    property DefaultInterface: IAdApiUtility read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoCAdContent provides a Create and CreateRemote method to          
// create instances of the default interface IAdContent2 exposed by              
// the CoClass CAdContent. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCAdContent = class
    class function Create: IAdContent2;
    class function CreateRemote(const MachineName: string): IAdContent2;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCAdContent
// Help String      : CAdContent Class
// Default Interface: IAdContent2
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TCAdContentProperties= class;
{$ENDIF}
  TCAdContent = class(TOleServer)
  private
    FIntf:        IAdContent2;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TCAdContentProperties;
    function      GetServerProperties: TCAdContentProperties;
{$ENDIF}
    function      GetDefaultInterface: IAdContent2;
  protected
    procedure InitServerData; override;
    function Get_Objects(nObjectType: Integer): IDispatch;
    procedure Set_Objects(nObjectType: Integer; const pVal: IDispatch);
    function Get_Object_(const bstrObjectId: WideString): IDispatch;
    function Get_Extents(const pObjects: IDispatch): IDispatch;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IAdContent2);
    procedure Disconnect; override;
    function CreateUserCollection: IDispatch;
    property DefaultInterface: IAdContent2 read GetDefaultInterface;
    property Objects[nObjectType: Integer]: IDispatch read Get_Objects write Set_Objects;
    property Object_[const bstrObjectId: WideString]: IDispatch read Get_Object_;
    property Extents[const pObjects: IDispatch]: IDispatch read Get_Extents;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TCAdContentProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TCAdContent
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TCAdContentProperties = class(TPersistent)
  private
    FServer:    TCAdContent;
    function    GetDefaultInterface: IAdContent2;
    constructor Create(AServer: TCAdContent);
  protected
    function Get_Objects(nObjectType: Integer): IDispatch;
    procedure Set_Objects(nObjectType: Integer; const pVal: IDispatch);
    function Get_Object_(const bstrObjectId: WideString): IDispatch;
    function Get_Extents(const pObjects: IDispatch): IDispatch;
  public
    property DefaultInterface: IAdContent2 read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoCAdMarkupEditor provides a Create and CreateRemote method to          
// create instances of the default interface IAdMarkupEditor2 exposed by              
// the CoClass CAdMarkupEditor. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCAdMarkupEditor = class
    class function Create: IAdMarkupEditor2;
    class function CreateRemote(const MachineName: string): IAdMarkupEditor2;
  end;

  TCAdMarkupEditorOnSave = procedure(ASender: TObject; var fileName: WideString; 
                                                       const pCancel: IDispatch) of object;
  TCAdMarkupEditorOnSaveAs = procedure(ASender: TObject; var fileName: WideString; 
                                                         const pCancel: IDispatch) of object;
  TCAdMarkupEditorOnSaveComplete = procedure(ASender: TObject; const fileName: WideString; 
                                                               status: WordBool) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCAdMarkupEditor
// Help String      : CAdMarkupEditor Class
// Default Interface: IAdMarkupEditor2
// Def. Intf. DISP? : No
// Event   Interface: IAdMarkupEditorEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TCAdMarkupEditorProperties= class;
{$ENDIF}
  TCAdMarkupEditor = class(TOleServer)
  private
    FOnSave: TCAdMarkupEditorOnSave;
    FOnSaveAs: TCAdMarkupEditorOnSaveAs;
    FOnSaveComplete: TCAdMarkupEditorOnSaveComplete;
    FIntf:        IAdMarkupEditor2;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TCAdMarkupEditorProperties;
    function      GetServerProperties: TCAdMarkupEditorProperties;
{$ENDIF}
    function      GetDefaultInterface: IAdMarkupEditor2;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function Get_Dirty: WordBool;
    procedure Set_Dirty(pVal: WordBool);
    function Get_Restricted: WordBool;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IAdMarkupEditor2);
    procedure Disconnect; override;
    procedure Save;
    procedure SaveAs(const fileName: WideString);
    procedure Close;
    procedure FireOnSaveEvent(var fileName: WideString; const pCancel: IDispatch);
    procedure FireOnSaveAsEvent(var fileName: WideString; const pCancel: IDispatch);
    procedure FireOnSaveCompleteEvent(const fileName: WideString; status: WordBool);
    property DefaultInterface: IAdMarkupEditor2 read GetDefaultInterface;
    property Restricted: WordBool read Get_Restricted;
    property Dirty: WordBool read Get_Dirty write Set_Dirty;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TCAdMarkupEditorProperties read GetServerProperties;
{$ENDIF}
    property OnSave: TCAdMarkupEditorOnSave read FOnSave write FOnSave;
    property OnSaveAs: TCAdMarkupEditorOnSaveAs read FOnSaveAs write FOnSaveAs;
    property OnSaveComplete: TCAdMarkupEditorOnSaveComplete read FOnSaveComplete write FOnSaveComplete;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TCAdMarkupEditor
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TCAdMarkupEditorProperties = class(TPersistent)
  private
    FServer:    TCAdMarkupEditor;
    function    GetDefaultInterface: IAdMarkupEditor2;
    constructor Create(AServer: TCAdMarkupEditor);
  protected
    function Get_Dirty: WordBool;
    procedure Set_Dirty(pVal: WordBool);
    function Get_Restricted: WordBool;
  public
    property DefaultInterface: IAdMarkupEditor2 read GetDefaultInterface;
  published
    property Dirty: WordBool read Get_Dirty write Set_Dirty;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoCAdObject provides a Create and CreateRemote method to          
// create instances of the default interface IAdObject2 exposed by              
// the CoClass CAdObject. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCAdObject = class
    class function Create: IAdObject2;
    class function CreateRemote(const MachineName: string): IAdObject2;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCAdObject
// Help String      : CAdObject Class
// Default Interface: IAdObject2
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TCAdObjectProperties= class;
{$ENDIF}
  TCAdObject = class(TOleServer)
  private
    FIntf:        IAdObject2;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TCAdObjectProperties;
    function      GetServerProperties: TCAdObjectProperties;
{$ENDIF}
    function      GetDefaultInterface: IAdObject2;
  protected
    procedure InitServerData; override;
    function Get_Properties: IDispatch;
    function Get_Id: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IAdObject2);
    procedure Disconnect; override;
    property DefaultInterface: IAdObject2 read GetDefaultInterface;
    property Properties: IDispatch read Get_Properties;
    property Id: WideString read Get_Id;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TCAdObjectProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TCAdObject
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TCAdObjectProperties = class(TPersistent)
  private
    FServer:    TCAdObject;
    function    GetDefaultInterface: IAdObject2;
    constructor Create(AServer: TCAdObject);
  protected
    function Get_Properties: IDispatch;
    function Get_Id: WideString;
  public
    property DefaultInterface: IAdObject2 read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoCAdProperty2 provides a Create and CreateRemote method to          
// create instances of the default interface IAdProperty exposed by              
// the CoClass CAdProperty2. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCAdProperty2 = class
    class function Create: IAdProperty;
    class function CreateRemote(const MachineName: string): IAdProperty;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCAdProperty2
// Help String      : AdProperty2 Class
// Default Interface: IAdProperty
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TCAdProperty2Properties= class;
{$ENDIF}
  TCAdProperty2 = class(TOleServer)
  private
    FIntf:        IAdProperty;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TCAdProperty2Properties;
    function      GetServerProperties: TCAdProperty2Properties;
{$ENDIF}
    function      GetDefaultInterface: IAdProperty;
  protected
    procedure InitServerData; override;
    function Get_Name: WideString;
    procedure Set_Name(const pVal: WideString);
    function Get_Value: WideString;
    procedure Set_Value(const pVal: WideString);
    function Get_type_: WideString;
    procedure Set_type_(const pVal: WideString);
    function Get_Units: WideString;
    procedure Set_Units(const pVal: WideString);
    function Get_Category: WideString;
    procedure Set_Category(const pVal: WideString);
    function Get__DwfProperty: OleVariant;
    procedure Set__DwfProperty(pVal: OleVariant);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IAdProperty);
    procedure Disconnect; override;
    property DefaultInterface: IAdProperty read GetDefaultInterface;
    property _DwfProperty: OleVariant read Get__DwfProperty write Set__DwfProperty;
    property Name: WideString read Get_Name write Set_Name;
    property Value: WideString read Get_Value write Set_Value;
    property type_: WideString read Get_type_ write Set_type_;
    property Units: WideString read Get_Units write Set_Units;
    property Category: WideString read Get_Category write Set_Category;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TCAdProperty2Properties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TCAdProperty2
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TCAdProperty2Properties = class(TPersistent)
  private
    FServer:    TCAdProperty2;
    function    GetDefaultInterface: IAdProperty;
    constructor Create(AServer: TCAdProperty2);
  protected
    function Get_Name: WideString;
    procedure Set_Name(const pVal: WideString);
    function Get_Value: WideString;
    procedure Set_Value(const pVal: WideString);
    function Get_type_: WideString;
    procedure Set_type_(const pVal: WideString);
    function Get_Units: WideString;
    procedure Set_Units(const pVal: WideString);
    function Get_Category: WideString;
    procedure Set_Category(const pVal: WideString);
    function Get__DwfProperty: OleVariant;
    procedure Set__DwfProperty(pVal: OleVariant);
  public
    property DefaultInterface: IAdProperty read GetDefaultInterface;
  published
    property Name: WideString read Get_Name write Set_Name;
    property Value: WideString read Get_Value write Set_Value;
    property type_: WideString read Get_type_ write Set_type_;
    property Units: WideString read Get_Units write Set_Units;
    property Category: WideString read Get_Category write Set_Category;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoCPrivateRelayEventContent provides a Create and CreateRemote method to          
// create instances of the default interface IAdPrivateRelayEventContent exposed by              
// the CoClass CPrivateRelayEventContent. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCPrivateRelayEventContent = class
    class function Create: IAdPrivateRelayEventContent;
    class function CreateRemote(const MachineName: string): IAdPrivateRelayEventContent;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCPrivateRelayEventContent
// Help String      : CAdMarkupEditor Class
// Default Interface: IAdPrivateRelayEventContent
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TCPrivateRelayEventContentProperties= class;
{$ENDIF}
  TCPrivateRelayEventContent = class(TOleServer)
  private
    FIntf:        IAdPrivateRelayEventContent;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TCPrivateRelayEventContentProperties;
    function      GetServerProperties: TCPrivateRelayEventContentProperties;
{$ENDIF}
    function      GetDefaultInterface: IAdPrivateRelayEventContent;
  protected
    procedure InitServerData; override;
    function Get_EventID: SYSINT;
    procedure Set_EventID(pVal: SYSINT);
    function Get_Arg1: OleVariant;
    procedure Set_Arg1(pvArg: OleVariant);
    function Get_Arg2: OleVariant;
    procedure Set_Arg2(pvArg: OleVariant);
    function Get_Arg3: OleVariant;
    procedure Set_Arg3(pvArg: OleVariant);
    function Get_Arg4: OleVariant;
    procedure Set_Arg4(pvArg: OleVariant);
    function Get_Arg5: OleVariant;
    procedure Set_Arg5(pvArg: OleVariant);
    function Get_Arg6: OleVariant;
    procedure Set_Arg6(pvArg: OleVariant);
    function Get_Arg7: OleVariant;
    procedure Set_Arg7(pvArg: OleVariant);
    function Get_Arg8: OleVariant;
    procedure Set_Arg8(pvArg: OleVariant);
    function Get_Arg9: OleVariant;
    procedure Set_Arg9(pvArg: OleVariant);
    function Get_Arg10: OleVariant;
    procedure Set_Arg10(pvArg: OleVariant);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IAdPrivateRelayEventContent);
    procedure Disconnect; override;
    property DefaultInterface: IAdPrivateRelayEventContent read GetDefaultInterface;
    property Arg1: OleVariant read Get_Arg1 write Set_Arg1;
    property Arg2: OleVariant read Get_Arg2 write Set_Arg2;
    property Arg3: OleVariant read Get_Arg3 write Set_Arg3;
    property Arg4: OleVariant read Get_Arg4 write Set_Arg4;
    property Arg5: OleVariant read Get_Arg5 write Set_Arg5;
    property Arg6: OleVariant read Get_Arg6 write Set_Arg6;
    property Arg7: OleVariant read Get_Arg7 write Set_Arg7;
    property Arg8: OleVariant read Get_Arg8 write Set_Arg8;
    property Arg9: OleVariant read Get_Arg9 write Set_Arg9;
    property Arg10: OleVariant read Get_Arg10 write Set_Arg10;
    property EventID: SYSINT read Get_EventID write Set_EventID;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TCPrivateRelayEventContentProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TCPrivateRelayEventContent
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TCPrivateRelayEventContentProperties = class(TPersistent)
  private
    FServer:    TCPrivateRelayEventContent;
    function    GetDefaultInterface: IAdPrivateRelayEventContent;
    constructor Create(AServer: TCPrivateRelayEventContent);
  protected
    function Get_EventID: SYSINT;
    procedure Set_EventID(pVal: SYSINT);
    function Get_Arg1: OleVariant;
    procedure Set_Arg1(pvArg: OleVariant);
    function Get_Arg2: OleVariant;
    procedure Set_Arg2(pvArg: OleVariant);
    function Get_Arg3: OleVariant;
    procedure Set_Arg3(pvArg: OleVariant);
    function Get_Arg4: OleVariant;
    procedure Set_Arg4(pvArg: OleVariant);
    function Get_Arg5: OleVariant;
    procedure Set_Arg5(pvArg: OleVariant);
    function Get_Arg6: OleVariant;
    procedure Set_Arg6(pvArg: OleVariant);
    function Get_Arg7: OleVariant;
    procedure Set_Arg7(pvArg: OleVariant);
    function Get_Arg8: OleVariant;
    procedure Set_Arg8(pvArg: OleVariant);
    function Get_Arg9: OleVariant;
    procedure Set_Arg9(pvArg: OleVariant);
    function Get_Arg10: OleVariant;
    procedure Set_Arg10(pvArg: OleVariant);
  public
    property DefaultInterface: IAdPrivateRelayEventContent read GetDefaultInterface;
  published
    property EventID: SYSINT read Get_EventID write Set_EventID;
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoCAdApiUtility.Create: IAdApiUtility;
begin
  Result := CreateComObject(CLASS_CAdApiUtility) as IAdApiUtility;
end;

class function CoCAdApiUtility.CreateRemote(const MachineName: string): IAdApiUtility;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CAdApiUtility) as IAdApiUtility;
end;

procedure TCAdApiUtility.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{718B86EE-E4D5-423E-A913-72814ADF26D4}';
    IntfIID:   '{02B244B4-C55F-4BC0-B087-C0B86495F58F}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCAdApiUtility.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IAdApiUtility;
  end;
end;

procedure TCAdApiUtility.ConnectTo(svrIntf: IAdApiUtility);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TCAdApiUtility.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TCAdApiUtility.GetDefaultInterface: IAdApiUtility;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TCAdApiUtility.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TCAdApiUtilityProperties.Create(Self);
{$ENDIF}
end;

destructor TCAdApiUtility.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TCAdApiUtility.GetServerProperties: TCAdApiUtilityProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TCAdApiUtility.Set_Viewer(const Param1: IDispatch);
begin
  DefaultInterface.Set_Viewer(Param1);
end;

procedure TCAdApiUtility.AddToolBarCommand(const bstrToolBarName: WideString; 
                                           const bstrCommandName: WideString; 
                                           nInsertionIndex: Integer);
begin
  DefaultInterface.AddToolBarCommand(bstrToolBarName, bstrCommandName, nInsertionIndex);
end;

procedure TCAdApiUtility.RemoveToolBarCommand(const bstrToolBarName: WideString; 
                                              const bstrCommandName: WideString);
begin
  DefaultInterface.RemoveToolBarCommand(bstrToolBarName, bstrCommandName);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TCAdApiUtilityProperties.Create(AServer: TCAdApiUtility);
begin
  inherited Create;
  FServer := AServer;
end;

function TCAdApiUtilityProperties.GetDefaultInterface: IAdApiUtility;
begin
  Result := FServer.DefaultInterface;
end;

procedure TCAdApiUtilityProperties.Set_Viewer(const Param1: IDispatch);
begin
  DefaultInterface.Set_Viewer(Param1);
end;

{$ENDIF}

class function CoCAdContent.Create: IAdContent2;
begin
  Result := CreateComObject(CLASS_CAdContent) as IAdContent2;
end;

class function CoCAdContent.CreateRemote(const MachineName: string): IAdContent2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CAdContent) as IAdContent2;
end;

procedure TCAdContent.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{2AA8F53C-1EA6-42FE-A708-C5F4D6F6CD32}';
    IntfIID:   '{A683A7FB-96D7-424D-8E53-8B973F847D7B}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCAdContent.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IAdContent2;
  end;
end;

procedure TCAdContent.ConnectTo(svrIntf: IAdContent2);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TCAdContent.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TCAdContent.GetDefaultInterface: IAdContent2;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TCAdContent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TCAdContentProperties.Create(Self);
{$ENDIF}
end;

destructor TCAdContent.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TCAdContent.GetServerProperties: TCAdContentProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TCAdContent.Get_Objects(nObjectType: Integer): IDispatch;
begin
    Result := DefaultInterface.Objects[nObjectType];
end;

procedure TCAdContent.Set_Objects(nObjectType: Integer; const pVal: IDispatch);
begin
  DefaultInterface.Objects[nObjectType] := pVal;
end;

function TCAdContent.Get_Object_(const bstrObjectId: WideString): IDispatch;
begin
    Result := DefaultInterface.Object_[bstrObjectId];
end;

function TCAdContent.Get_Extents(const pObjects: IDispatch): IDispatch;
begin
    Result := DefaultInterface.Extents[pObjects];
end;

function TCAdContent.CreateUserCollection: IDispatch;
begin
  Result := DefaultInterface.CreateUserCollection;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TCAdContentProperties.Create(AServer: TCAdContent);
begin
  inherited Create;
  FServer := AServer;
end;

function TCAdContentProperties.GetDefaultInterface: IAdContent2;
begin
  Result := FServer.DefaultInterface;
end;

function TCAdContentProperties.Get_Objects(nObjectType: Integer): IDispatch;
begin
    Result := DefaultInterface.Objects[nObjectType];
end;

procedure TCAdContentProperties.Set_Objects(nObjectType: Integer; const pVal: IDispatch);
begin
  DefaultInterface.Objects[nObjectType] := pVal;
end;

function TCAdContentProperties.Get_Object_(const bstrObjectId: WideString): IDispatch;
begin
    Result := DefaultInterface.Object_[bstrObjectId];
end;

function TCAdContentProperties.Get_Extents(const pObjects: IDispatch): IDispatch;
begin
    Result := DefaultInterface.Extents[pObjects];
end;

{$ENDIF}

class function CoCAdMarkupEditor.Create: IAdMarkupEditor2;
begin
  Result := CreateComObject(CLASS_CAdMarkupEditor) as IAdMarkupEditor2;
end;

class function CoCAdMarkupEditor.CreateRemote(const MachineName: string): IAdMarkupEditor2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CAdMarkupEditor) as IAdMarkupEditor2;
end;

procedure TCAdMarkupEditor.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{FC28F100-41C5-4E43-B77C-DFB8BB1A1B8D}';
    IntfIID:   '{9164A5E6-9383-4204-9DCE-5701DC7AAF37}';
    EventIID:  '{194AD7DC-FD2F-46A6-A733-C813EDC8FB91}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCAdMarkupEditor.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IAdMarkupEditor2;
  end;
end;

procedure TCAdMarkupEditor.ConnectTo(svrIntf: IAdMarkupEditor2);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TCAdMarkupEditor.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TCAdMarkupEditor.GetDefaultInterface: IAdMarkupEditor2;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TCAdMarkupEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TCAdMarkupEditorProperties.Create(Self);
{$ENDIF}
end;

destructor TCAdMarkupEditor.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TCAdMarkupEditor.GetServerProperties: TCAdMarkupEditorProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TCAdMarkupEditor.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
    1: if Assigned(FOnSave) then
         FOnSave(Self,
                 WideString((TVarData(Params[0]).VPointer)^) {var WideString},
                 Params[1] {const IDispatch});
    2: if Assigned(FOnSaveAs) then
         FOnSaveAs(Self,
                   WideString((TVarData(Params[0]).VPointer)^) {var WideString},
                   Params[1] {const IDispatch});
    3: if Assigned(FOnSaveComplete) then
         FOnSaveComplete(Self,
                         Params[0] {const WideString},
                         Params[1] {WordBool});
  end; {case DispID}
end;

function TCAdMarkupEditor.Get_Dirty: WordBool;
begin
    Result := DefaultInterface.Dirty;
end;

procedure TCAdMarkupEditor.Set_Dirty(pVal: WordBool);
begin
  DefaultInterface.Set_Dirty(pVal);
end;

function TCAdMarkupEditor.Get_Restricted: WordBool;
begin
    Result := DefaultInterface.Restricted;
end;

procedure TCAdMarkupEditor.Save;
begin
  DefaultInterface.Save;
end;

procedure TCAdMarkupEditor.SaveAs(const fileName: WideString);
begin
  DefaultInterface.SaveAs(fileName);
end;

procedure TCAdMarkupEditor.Close;
begin
  DefaultInterface.Close;
end;

procedure TCAdMarkupEditor.FireOnSaveEvent(var fileName: WideString; const pCancel: IDispatch);
begin
  DefaultInterface.FireOnSaveEvent(fileName, pCancel);
end;

procedure TCAdMarkupEditor.FireOnSaveAsEvent(var fileName: WideString; const pCancel: IDispatch);
begin
  DefaultInterface.FireOnSaveAsEvent(fileName, pCancel);
end;

procedure TCAdMarkupEditor.FireOnSaveCompleteEvent(const fileName: WideString; status: WordBool);
begin
  DefaultInterface.FireOnSaveCompleteEvent(fileName, status);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TCAdMarkupEditorProperties.Create(AServer: TCAdMarkupEditor);
begin
  inherited Create;
  FServer := AServer;
end;

function TCAdMarkupEditorProperties.GetDefaultInterface: IAdMarkupEditor2;
begin
  Result := FServer.DefaultInterface;
end;

function TCAdMarkupEditorProperties.Get_Dirty: WordBool;
begin
    Result := DefaultInterface.Dirty;
end;

procedure TCAdMarkupEditorProperties.Set_Dirty(pVal: WordBool);
begin
  DefaultInterface.Set_Dirty(pVal);
end;

function TCAdMarkupEditorProperties.Get_Restricted: WordBool;
begin
    Result := DefaultInterface.Restricted;
end;

{$ENDIF}

class function CoCAdObject.Create: IAdObject2;
begin
  Result := CreateComObject(CLASS_CAdObject) as IAdObject2;
end;

class function CoCAdObject.CreateRemote(const MachineName: string): IAdObject2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CAdObject) as IAdObject2;
end;

procedure TCAdObject.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{B8163F08-E4B9-4EB9-9A42-1A38D6440A1F}';
    IntfIID:   '{2199B630-3012-40E4-B255-6236EF73E9FE}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCAdObject.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IAdObject2;
  end;
end;

procedure TCAdObject.ConnectTo(svrIntf: IAdObject2);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TCAdObject.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TCAdObject.GetDefaultInterface: IAdObject2;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TCAdObject.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TCAdObjectProperties.Create(Self);
{$ENDIF}
end;

destructor TCAdObject.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TCAdObject.GetServerProperties: TCAdObjectProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TCAdObject.Get_Properties: IDispatch;
begin
    Result := DefaultInterface.Properties;
end;

function TCAdObject.Get_Id: WideString;
begin
    Result := DefaultInterface.Id;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TCAdObjectProperties.Create(AServer: TCAdObject);
begin
  inherited Create;
  FServer := AServer;
end;

function TCAdObjectProperties.GetDefaultInterface: IAdObject2;
begin
  Result := FServer.DefaultInterface;
end;

function TCAdObjectProperties.Get_Properties: IDispatch;
begin
    Result := DefaultInterface.Properties;
end;

function TCAdObjectProperties.Get_Id: WideString;
begin
    Result := DefaultInterface.Id;
end;

{$ENDIF}

class function CoCAdProperty2.Create: IAdProperty;
begin
  Result := CreateComObject(CLASS_CAdProperty2) as IAdProperty;
end;

class function CoCAdProperty2.CreateRemote(const MachineName: string): IAdProperty;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CAdProperty2) as IAdProperty;
end;

procedure TCAdProperty2.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{527424CA-A43F-45DE-BFF8-976954CFC945}';
    IntfIID:   '{9045091A-0DE5-4588-B0D8-442463A1C788}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCAdProperty2.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IAdProperty;
  end;
end;

procedure TCAdProperty2.ConnectTo(svrIntf: IAdProperty);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TCAdProperty2.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TCAdProperty2.GetDefaultInterface: IAdProperty;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TCAdProperty2.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TCAdProperty2Properties.Create(Self);
{$ENDIF}
end;

destructor TCAdProperty2.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TCAdProperty2.GetServerProperties: TCAdProperty2Properties;
begin
  Result := FProps;
end;
{$ENDIF}

function TCAdProperty2.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

procedure TCAdProperty2.Set_Name(const pVal: WideString);
  { Warning: The property Name has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Name := pVal;
end;

function TCAdProperty2.Get_Value: WideString;
begin
    Result := DefaultInterface.Value;
end;

procedure TCAdProperty2.Set_Value(const pVal: WideString);
  { Warning: The property Value has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Value := pVal;
end;

function TCAdProperty2.Get_type_: WideString;
begin
    Result := DefaultInterface.type_;
end;

procedure TCAdProperty2.Set_type_(const pVal: WideString);
  { Warning: The property type_ has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.type_ := pVal;
end;

function TCAdProperty2.Get_Units: WideString;
begin
    Result := DefaultInterface.Units;
end;

procedure TCAdProperty2.Set_Units(const pVal: WideString);
  { Warning: The property Units has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Units := pVal;
end;

function TCAdProperty2.Get_Category: WideString;
begin
    Result := DefaultInterface.Category;
end;

procedure TCAdProperty2.Set_Category(const pVal: WideString);
  { Warning: The property Category has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Category := pVal;
end;

function TCAdProperty2.Get__DwfProperty: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant._DwfProperty;
end;

procedure TCAdProperty2.Set__DwfProperty(pVal: OleVariant);
begin
  DefaultInterface.Set__DwfProperty(pVal);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TCAdProperty2Properties.Create(AServer: TCAdProperty2);
begin
  inherited Create;
  FServer := AServer;
end;

function TCAdProperty2Properties.GetDefaultInterface: IAdProperty;
begin
  Result := FServer.DefaultInterface;
end;

function TCAdProperty2Properties.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

procedure TCAdProperty2Properties.Set_Name(const pVal: WideString);
  { Warning: The property Name has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Name := pVal;
end;

function TCAdProperty2Properties.Get_Value: WideString;
begin
    Result := DefaultInterface.Value;
end;

procedure TCAdProperty2Properties.Set_Value(const pVal: WideString);
  { Warning: The property Value has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Value := pVal;
end;

function TCAdProperty2Properties.Get_type_: WideString;
begin
    Result := DefaultInterface.type_;
end;

procedure TCAdProperty2Properties.Set_type_(const pVal: WideString);
  { Warning: The property type_ has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.type_ := pVal;
end;

function TCAdProperty2Properties.Get_Units: WideString;
begin
    Result := DefaultInterface.Units;
end;

procedure TCAdProperty2Properties.Set_Units(const pVal: WideString);
  { Warning: The property Units has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Units := pVal;
end;

function TCAdProperty2Properties.Get_Category: WideString;
begin
    Result := DefaultInterface.Category;
end;

procedure TCAdProperty2Properties.Set_Category(const pVal: WideString);
  { Warning: The property Category has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Category := pVal;
end;

function TCAdProperty2Properties.Get__DwfProperty: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant._DwfProperty;
end;

procedure TCAdProperty2Properties.Set__DwfProperty(pVal: OleVariant);
begin
  DefaultInterface.Set__DwfProperty(pVal);
end;

{$ENDIF}

class function CoCPrivateRelayEventContent.Create: IAdPrivateRelayEventContent;
begin
  Result := CreateComObject(CLASS_CPrivateRelayEventContent) as IAdPrivateRelayEventContent;
end;

class function CoCPrivateRelayEventContent.CreateRemote(const MachineName: string): IAdPrivateRelayEventContent;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CPrivateRelayEventContent) as IAdPrivateRelayEventContent;
end;

procedure TCPrivateRelayEventContent.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{B98405F9-DEBB-490B-901F-1F01E49B146B}';
    IntfIID:   '{93601283-B854-4145-A8B3-64045EFE95D5}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCPrivateRelayEventContent.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IAdPrivateRelayEventContent;
  end;
end;

procedure TCPrivateRelayEventContent.ConnectTo(svrIntf: IAdPrivateRelayEventContent);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TCPrivateRelayEventContent.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TCPrivateRelayEventContent.GetDefaultInterface: IAdPrivateRelayEventContent;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TCPrivateRelayEventContent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TCPrivateRelayEventContentProperties.Create(Self);
{$ENDIF}
end;

destructor TCPrivateRelayEventContent.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TCPrivateRelayEventContent.GetServerProperties: TCPrivateRelayEventContentProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TCPrivateRelayEventContent.Get_EventID: SYSINT;
begin
    Result := DefaultInterface.EventID;
end;

procedure TCPrivateRelayEventContent.Set_EventID(pVal: SYSINT);
begin
  DefaultInterface.Set_EventID(pVal);
end;

function TCPrivateRelayEventContent.Get_Arg1: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg1;
end;

procedure TCPrivateRelayEventContent.Set_Arg1(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg1(pvArg);
end;

function TCPrivateRelayEventContent.Get_Arg2: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg2;
end;

procedure TCPrivateRelayEventContent.Set_Arg2(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg2(pvArg);
end;

function TCPrivateRelayEventContent.Get_Arg3: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg3;
end;

procedure TCPrivateRelayEventContent.Set_Arg3(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg3(pvArg);
end;

function TCPrivateRelayEventContent.Get_Arg4: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg4;
end;

procedure TCPrivateRelayEventContent.Set_Arg4(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg4(pvArg);
end;

function TCPrivateRelayEventContent.Get_Arg5: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg5;
end;

procedure TCPrivateRelayEventContent.Set_Arg5(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg5(pvArg);
end;

function TCPrivateRelayEventContent.Get_Arg6: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg6;
end;

procedure TCPrivateRelayEventContent.Set_Arg6(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg6(pvArg);
end;

function TCPrivateRelayEventContent.Get_Arg7: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg7;
end;

procedure TCPrivateRelayEventContent.Set_Arg7(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg7(pvArg);
end;

function TCPrivateRelayEventContent.Get_Arg8: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg8;
end;

procedure TCPrivateRelayEventContent.Set_Arg8(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg8(pvArg);
end;

function TCPrivateRelayEventContent.Get_Arg9: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg9;
end;

procedure TCPrivateRelayEventContent.Set_Arg9(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg9(pvArg);
end;

function TCPrivateRelayEventContent.Get_Arg10: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg10;
end;

procedure TCPrivateRelayEventContent.Set_Arg10(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg10(pvArg);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TCPrivateRelayEventContentProperties.Create(AServer: TCPrivateRelayEventContent);
begin
  inherited Create;
  FServer := AServer;
end;

function TCPrivateRelayEventContentProperties.GetDefaultInterface: IAdPrivateRelayEventContent;
begin
  Result := FServer.DefaultInterface;
end;

function TCPrivateRelayEventContentProperties.Get_EventID: SYSINT;
begin
    Result := DefaultInterface.EventID;
end;

procedure TCPrivateRelayEventContentProperties.Set_EventID(pVal: SYSINT);
begin
  DefaultInterface.Set_EventID(pVal);
end;

function TCPrivateRelayEventContentProperties.Get_Arg1: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg1;
end;

procedure TCPrivateRelayEventContentProperties.Set_Arg1(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg1(pvArg);
end;

function TCPrivateRelayEventContentProperties.Get_Arg2: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg2;
end;

procedure TCPrivateRelayEventContentProperties.Set_Arg2(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg2(pvArg);
end;

function TCPrivateRelayEventContentProperties.Get_Arg3: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg3;
end;

procedure TCPrivateRelayEventContentProperties.Set_Arg3(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg3(pvArg);
end;

function TCPrivateRelayEventContentProperties.Get_Arg4: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg4;
end;

procedure TCPrivateRelayEventContentProperties.Set_Arg4(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg4(pvArg);
end;

function TCPrivateRelayEventContentProperties.Get_Arg5: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg5;
end;

procedure TCPrivateRelayEventContentProperties.Set_Arg5(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg5(pvArg);
end;

function TCPrivateRelayEventContentProperties.Get_Arg6: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg6;
end;

procedure TCPrivateRelayEventContentProperties.Set_Arg6(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg6(pvArg);
end;

function TCPrivateRelayEventContentProperties.Get_Arg7: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg7;
end;

procedure TCPrivateRelayEventContentProperties.Set_Arg7(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg7(pvArg);
end;

function TCPrivateRelayEventContentProperties.Get_Arg8: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg8;
end;

procedure TCPrivateRelayEventContentProperties.Set_Arg8(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg8(pvArg);
end;

function TCPrivateRelayEventContentProperties.Get_Arg9: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg9;
end;

procedure TCPrivateRelayEventContentProperties.Set_Arg9(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg9(pvArg);
end;

function TCPrivateRelayEventContentProperties.Get_Arg10: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Arg10;
end;

procedure TCPrivateRelayEventContentProperties.Set_Arg10(pvArg: OleVariant);
begin
  DefaultInterface.Set_Arg10(pvArg);
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TCAdApiUtility, TCAdContent, TCAdMarkupEditor, TCAdObject, 
    TCAdProperty2, TCPrivateRelayEventContent]);
end;

end.
