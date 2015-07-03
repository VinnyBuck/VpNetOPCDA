unit ExpressViewerDll_TLB;

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
// File generated on 08.12.2008 22:36:16 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Program Files\Common Files\Autodesk Shared\DWF Common\AdView.dll (1)
// LIBID: {55523A67-A054-4064-B88D-0070305C9F95}
// LCID: 0
// Helpfile: 
// HelpString: ExpressViewerDll 1.0 Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
// Errors:
//   Hint: Member 'Object' of 'IAdContent2' changed to 'Object_'
//   Error creating palette bitmap of (TCExpressViewerControl) : Error reading control bitmap
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
  ExpressViewerDllMajorVersion = 1;
  ExpressViewerDllMinorVersion = 0;

  LIBID_ExpressViewerDll: TGUID = '{55523A67-A054-4064-B88D-0070305C9F95}';

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
  IID_IPropertyPage: TGUID = '{B196B28D-BAB4-101A-B69C-00AA00341D07}';
  CLASS_CSourcePath: TGUID = '{ADC266C7-B1A9-4187-B2A3-F81A5480B4CD}';
  IID_IPropertyPageSite: TGUID = '{B196B28C-BAB4-101A-B69C-00AA00341D07}';
  CLASS_CExpressViewerControl: TGUID = '{A662DA7E-CCB7-4743-B71A-D817F6D575DF}';
  CLASS_CDwfOLEserver: TGUID = '{928C0C4B-B94A-4A12-93CE-7C4055A856F9}';
  CLASS___Impl_IAdPrivateRelayEvent: TGUID = '{A50E65E9-5273-3443-8153-4DA89B84495E}';
  CLASS___Impl_IAdViewerEvents: TGUID = '{C1FA096D-C442-3B7F-90C9-7299B16A2989}';
  IID_IExpressViewerHtmlUtil: TGUID = '{E18566D5-2856-4F7E-A142-F6390BAC1791}';
  CLASS_CExpressViewerHtmlUtil: TGUID = '{8802116A-1E30-4134-A02A-18B914500EBF}';
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
  IPropertyPage = interface;
  IPropertyPageSite = interface;
  IExpressViewerHtmlUtil = interface;
  IExpressViewerHtmlUtilDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CSourcePath = IPropertyPage;
  CExpressViewerControl = IAdDwfViewer2;
  CDwfOLEserver = IAdViewer;
  __Impl_IAdPrivateRelayEvent = IAdPrivateRelayEvent;
  __Impl_IAdViewerEvents = IUnknown;
  CExpressViewerHtmlUtil = IExpressViewerHtmlUtil;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  wireHWND = ^_RemotableHandle; 
  PWideString1 = ^WideString; {*}
  POleVariant1 = ^OleVariant; {*}
  PWordBool1 = ^WordBool; {*}
  PInteger1 = ^Integer; {*}
  PPUserType1 = ^IAdServiceHandler; {*}
  PIDispatch1 = ^IDispatch; {*}
  PUserType1 = ^tagRECT; {*}
  PIUnknown1 = ^IUnknown; {*}
  PUserType2 = ^tagMSG; {*}

  UINT_PTR = LongWord; 

  __MIDL_IWinTypes_0009 = record
    case Integer of
      0: (hInproc: Integer);
      1: (hRemote: Integer);
  end;

  _RemotableHandle = packed record
    fContext: Integer;
    u: __MIDL_IWinTypes_0009;
  end;

  LONG_PTR = Integer; 

  tagPOINT = packed record
    X: Integer;
    Y: Integer;
  end;

  tagMSG = packed record
    hWnd: wireHWND;
    message: SYSUINT;
    wparam: UINT_PTR;
    lparam: LONG_PTR;
    time: LongWord;
    pt: tagPOINT;
  end;

  tagRECT = packed record
    left: Integer;
    top: Integer;
    right: Integer;
    bottom: Integer;
  end;

  tagSIZE = packed record
    cx: Integer;
    cy: Integer;
  end;

  tagPROPPAGEINFO = packed record
    cb: LongWord;
    pszTitle: PWideChar;
    size: tagSIZE;
    pszDocString: PWideChar;
    pszHelpFile: PWideChar;
    dwHelpContext: LongWord;
  end;


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
// Interface: IPropertyPage
// Flags:     (0)
// GUID:      {B196B28D-BAB4-101A-B69C-00AA00341D07}
// *********************************************************************//
  IPropertyPage = interface(IUnknown)
    ['{B196B28D-BAB4-101A-B69C-00AA00341D07}']
    function SetPageSite(const pPageSite: IPropertyPageSite): HResult; stdcall;
    function Activate(var hWndParent: _RemotableHandle; var pRect: tagRECT; bModal: Integer): HResult; stdcall;
    function Deactivate: HResult; stdcall;
    function GetPageInfo(out pPageInfo: tagPROPPAGEINFO): HResult; stdcall;
    function SetObjects(cObjects: LongWord; var ppUnk: IUnknown): HResult; stdcall;
    function Show(nCmdShow: SYSUINT): HResult; stdcall;
    function Move(var pRect: tagRECT): HResult; stdcall;
    function IsPageDirty: HResult; stdcall;
    function Apply: HResult; stdcall;
    function Help(pszHelpDir: PWideChar): HResult; stdcall;
    function TranslateAccelerator(var pMsg: tagMSG): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPropertyPageSite
// Flags:     (0)
// GUID:      {B196B28C-BAB4-101A-B69C-00AA00341D07}
// *********************************************************************//
  IPropertyPageSite = interface(IUnknown)
    ['{B196B28C-BAB4-101A-B69C-00AA00341D07}']
    function OnStatusChange(dwFlags: LongWord): HResult; stdcall;
    function GetLocaleID(out pLocaleID: LongWord): HResult; stdcall;
    function GetPageContainer(out ppUnk: IUnknown): HResult; stdcall;
    function TranslateAccelerator(var pMsg: tagMSG): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IExpressViewerHtmlUtil
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E18566D5-2856-4F7E-A142-F6390BAC1791}
// *********************************************************************//
  IExpressViewerHtmlUtil = interface(IDispatch)
    ['{E18566D5-2856-4F7E-A142-F6390BAC1791}']
    function Get_Locale: WideString; safecall;
    function Get_Viewer: IDispatch; safecall;
    function Get_SuppressStartupPage: WordBool; safecall;
    procedure Set_SuppressStartupPage(pVal: WordBool); safecall;
    function Get_MRUListItem: WideString; safecall;
    function Get_MRUListItemCompact: WideString; safecall;
    procedure Set_MRUListIndex(Param1: SYSINT); safecall;
    property Locale: WideString read Get_Locale;
    property Viewer: IDispatch read Get_Viewer;
    property SuppressStartupPage: WordBool read Get_SuppressStartupPage write Set_SuppressStartupPage;
    property MRUListItem: WideString read Get_MRUListItem;
    property MRUListItemCompact: WideString read Get_MRUListItemCompact;
    property MRUListIndex: SYSINT write Set_MRUListIndex;
  end;

// *********************************************************************//
// DispIntf:  IExpressViewerHtmlUtilDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E18566D5-2856-4F7E-A142-F6390BAC1791}
// *********************************************************************//
  IExpressViewerHtmlUtilDisp = dispinterface
    ['{E18566D5-2856-4F7E-A142-F6390BAC1791}']
    property Locale: WideString readonly dispid 1;
    property Viewer: IDispatch readonly dispid 2;
    property SuppressStartupPage: WordBool dispid 3;
    property MRUListItem: WideString readonly dispid 4;
    property MRUListItemCompact: WideString readonly dispid 5;
    property MRUListIndex: SYSINT writeonly dispid 6;
  end;

// *********************************************************************//
// The Class CoCSourcePath provides a Create and CreateRemote method to          
// create instances of the default interface IPropertyPage exposed by              
// the CoClass CSourcePath. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCSourcePath = class
    class function Create: IPropertyPage;
    class function CreateRemote(const MachineName: string): IPropertyPage;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TCExpressViewerControl
// Help String      : ExpressViewerControl Class
// Default Interface: IAdDwfViewer2
// Def. Intf. DISP? : No
// Event   Interface: IAdViewerEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TCExpressViewerControlOnBeginDraw = procedure(ASender: TObject; nReason: Integer; 
                                                                  const pRect: IDispatch) of object;
  TCExpressViewerControlOnEndDraw = procedure(ASender: TObject; nReason: Integer; 
                                                                vResult: OleVariant) of object;
  TCExpressViewerControlOnMouseMove = procedure(ASender: TObject; nButtons: Integer; nX: SYSINT; 
                                                                  nY: SYSINT; 
                                                                  const pHandled: IDispatch) of object;
  TCExpressViewerControlOnLButtonDown = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                    const pHandled: IDispatch) of object;
  TCExpressViewerControlOnLButtonUp = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                  const pHandled: IDispatch) of object;
  TCExpressViewerControlOnLButtonDblClick = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                        const pHandled: IDispatch) of object;
  TCExpressViewerControlOnMButtonDown = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                    const pHandled: IDispatch) of object;
  TCExpressViewerControlOnMButtonUp = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                  const pHandled: IDispatch) of object;
  TCExpressViewerControlOnMButtonDblClick = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                        const pHandled: IDispatch) of object;
  TCExpressViewerControlOnRButtonDown = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                    const pHandled: IDispatch) of object;
  TCExpressViewerControlOnRButtonUp = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                  const pHandled: IDispatch) of object;
  TCExpressViewerControlOnRButtonDblClick = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                        const pHandled: IDispatch) of object;
  TCExpressViewerControlOnMouseWheel = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                   nWheeldelta: SYSINT; 
                                                                   const pHandled: IDispatch) of object;
  TCExpressViewerControlOnExecuteURL = procedure(ASender: TObject; const pIAdPageLink: IDispatch; 
                                                                   nIndex: SYSINT; 
                                                                   const pHandled: IDispatch) of object;
  TCExpressViewerControlOnOverURL = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                const pLink: IDispatch; 
                                                                const pHandled: IDispatch) of object;
  TCExpressViewerControlOnLeaveURL = procedure(ASender: TObject; nX: SYSINT; nY: SYSINT; 
                                                                 const pLink: IDispatch) of object;
  TCExpressViewerControlOnKeyDown = procedure(ASender: TObject; wChar: Integer; 
                                                                const pHandled: IDispatch) of object;
  TCExpressViewerControlOnKeyUp = procedure(ASender: TObject; wChar: Integer; 
                                                              const pHandled: IDispatch) of object;
  TCExpressViewerControlOnOverObject = procedure(ASender: TObject; const pIAdPageObjectNode: IDispatch; 
                                                                   const pHandled: IDispatch) of object;
  TCExpressViewerControlOnLeaveObject = procedure(ASender: TObject; const pIAdPageObjectNode: IDispatch) of object;
  TCExpressViewerControlOnSelectObject = procedure(ASender: TObject; const pIAdPageObjectNode: IDispatch; 
                                                                     const pHandled: IDispatch) of object;
  TCExpressViewerControlOnBeginLoadItem = procedure(ASender: TObject; const bstrItemType: WideString; 
                                                                      vData: OleVariant) of object;
  TCExpressViewerControlOnEndLoadItem = procedure(ASender: TObject; const bstrItemName: WideString; 
                                                                    vData: OleVariant; 
                                                                    vResult: OleVariant) of object;
  TCExpressViewerControlOnShowUiItem = procedure(ASender: TObject; const bstrItemName: WideString; 
                                                                   vState: OleVariant; 
                                                                   vData: OleVariant; 
                                                                   const pHandled: IDispatch) of object;
  TCExpressViewerControlOnUpdateUiItem = procedure(ASender: TObject; const bstrItemName: WideString; 
                                                                     vState: OleVariant; 
                                                                     vData: OleVariant) of object;
  TCExpressViewerControlOnCommand = procedure(ASender: TObject; msg: SYSINT; wparam: Integer; 
                                                                lparam: Integer; 
                                                                const pHandled: IDispatch) of object;
  TCExpressViewerControlOnInitLoadItem = procedure(ASender: TObject; const bstrItemType: WideString; 
                                                                     vState: OleVariant; 
                                                                     vData: OleVariant; 
                                                                     const pHandled: IDispatch) of object;
  TCExpressViewerControlOnUnloadItem = procedure(ASender: TObject; const bstrItemType: WideString; 
                                                                   vState: OleVariant; 
                                                                   vData: OleVariant; 
                                                                   const pHandled: IDispatch) of object;
  TCExpressViewerControlOnEventGroup = procedure(ASender: TObject; vData: OleVariant) of object;
  TCExpressViewerControlOnExecuteCommandEx = procedure(ASender: TObject; const bstrItemType: WideString; 
                                                                         vState: OleVariant; 
                                                                         vData: OleVariant; 
                                                                         const pHandled: IDispatch) of object;
  TCExpressViewerControlOnOverObjectEx = procedure(ASender: TObject; const bObjectID: WideString; 
                                                                     const pHandled: IDispatch) of object;
  TCExpressViewerControlOnLeaveObjectEx = procedure(ASender: TObject; const bObjectID: WideString) of object;
  TCExpressViewerControlOnSelectObjectEx = procedure(ASender: TObject; const pHandled: IDispatch) of object;
  TCExpressViewerControlOnInternalEventGroup = procedure(ASender: TObject; vData: OleVariant) of object;

  TCExpressViewerControl = class(TOleControl)
  private
    FOnBeginDraw: TCExpressViewerControlOnBeginDraw;
    FOnEndDraw: TCExpressViewerControlOnEndDraw;
    FOnMouseMove: TCExpressViewerControlOnMouseMove;
    FOnLButtonDown: TCExpressViewerControlOnLButtonDown;
    FOnLButtonUp: TCExpressViewerControlOnLButtonUp;
    FOnLButtonDblClick: TCExpressViewerControlOnLButtonDblClick;
    FOnMButtonDown: TCExpressViewerControlOnMButtonDown;
    FOnMButtonUp: TCExpressViewerControlOnMButtonUp;
    FOnMButtonDblClick: TCExpressViewerControlOnMButtonDblClick;
    FOnRButtonDown: TCExpressViewerControlOnRButtonDown;
    FOnRButtonUp: TCExpressViewerControlOnRButtonUp;
    FOnRButtonDblClick: TCExpressViewerControlOnRButtonDblClick;
    FOnMouseWheel: TCExpressViewerControlOnMouseWheel;
    FOnExecuteURL: TCExpressViewerControlOnExecuteURL;
    FOnOverURL: TCExpressViewerControlOnOverURL;
    FOnLeaveURL: TCExpressViewerControlOnLeaveURL;
    FOnKeyDown: TCExpressViewerControlOnKeyDown;
    FOnKeyUp: TCExpressViewerControlOnKeyUp;
    FOnOverObject: TCExpressViewerControlOnOverObject;
    FOnLeaveObject: TCExpressViewerControlOnLeaveObject;
    FOnSelectObject: TCExpressViewerControlOnSelectObject;
    FOnBeginLoadItem: TCExpressViewerControlOnBeginLoadItem;
    FOnEndLoadItem: TCExpressViewerControlOnEndLoadItem;
    FOnShowUiItem: TCExpressViewerControlOnShowUiItem;
    FOnUpdateUiItem: TCExpressViewerControlOnUpdateUiItem;
    FOnCommand: TCExpressViewerControlOnCommand;
    FOnInitLoadItem: TCExpressViewerControlOnInitLoadItem;
    FOnUnloadItem: TCExpressViewerControlOnUnloadItem;
    FOnEventGroup: TCExpressViewerControlOnEventGroup;
    FOnExecuteCommandEx: TCExpressViewerControlOnExecuteCommandEx;
    FOnOverObjectEx: TCExpressViewerControlOnOverObjectEx;
    FOnLeaveObjectEx: TCExpressViewerControlOnLeaveObjectEx;
    FOnSelectObjectEx: TCExpressViewerControlOnSelectObjectEx;
    FOnInternalEventGroup: TCExpressViewerControlOnInternalEventGroup;
    FIntf: IAdDwfViewer2;
    function  GetControlInterface: IAdDwfViewer2;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function Get_Viewer: IDispatch;
    function Get__ActiveWindow: OleVariant;
    function Get__ClientWindow: OleVariant;
    procedure Set__SourceStream(const Param1: IUnknown);
    function Get_DocumentHandler: IDispatch;
    function Get_ContextMenu: IDispatch;
    procedure Set_ContextMenu(const pVal: IDispatch);
    function Get_ReservedProperty05: OleVariant;
    procedure Set_ReservedProperty05(pVal: OleVariant);
    function Get_ReservedProperty06: OleVariant;
    procedure Set_ReservedProperty06(pVal: OleVariant);
    function Get_ReservedProperty07: OleVariant;
    procedure Set_ReservedProperty07(pVal: OleVariant);
    function Get_ReservedProperty08: OleVariant;
    procedure Set_ReservedProperty08(pVal: OleVariant);
    function Get_ReservedProperty09: OleVariant;
    procedure Set_ReservedProperty09(pVal: OleVariant);
    function Get_ReservedProperty10: OleVariant;
    procedure Set_ReservedProperty10(pVal: OleVariant);
    function Get_ReservedProperty11: OleVariant;
    procedure Set_ReservedProperty11(pVal: OleVariant);
    function Get_ReservedProperty12: OleVariant;
    procedure Set_ReservedProperty12(pVal: OleVariant);
    function Get_ReservedProperty13: OleVariant;
    procedure Set_ReservedProperty13(pVal: OleVariant);
    function Get_ReservedProperty14: OleVariant;
    procedure Set_ReservedProperty14(pVal: OleVariant);
    function Get_ReservedProperty15: OleVariant;
    procedure Set_ReservedProperty15(pVal: OleVariant);
    function Get_ReservedProperty16: OleVariant;
    procedure Set_ReservedProperty16(pVal: OleVariant);
    function Get_ReservedProperty17: OleVariant;
    procedure Set_ReservedProperty17(pVal: OleVariant);
    function Get_ReservedProperty18: OleVariant;
    procedure Set_ReservedProperty18(pVal: OleVariant);
    function Get_ReservedProperty19: OleVariant;
    procedure Set_ReservedProperty19(pVal: OleVariant);
    function Get_ReservedProperty20: OleVariant;
    procedure Set_ReservedProperty20(pVal: OleVariant);
    function Get_MarkupEditor: IDispatch;
    function Get_PreferredDocumentHandler(const DocInterface: WideString): WideString;
    procedure Set_PreferredDocumentHandler(const DocInterface: WideString; const pVal: WideString);
    function Get_ProductVersion(const bProduct: WideString): WideString;
    function Get_ECompositeViewer: IDispatch;
  public
    procedure ShowPrintDialog;
    procedure NavigateToUrl(const bstrUrl: WideString);
    procedure ExecuteCommand(const bstrCommand: WideString);
    procedure DrawToDC(nDc: Integer; nLeft: Integer; nTop: Integer; nRight: Integer; 
                       nBottom: Integer);
    procedure _GoBack;
    procedure _GoForward;
    procedure _SaveHistory;
    procedure _ShowHelp(const bstrTopic: WideString);
    procedure ExecuteCommandEx(const bstrCommand: WideString; lVal: Integer);
    procedure _ShowCIPDialog;
    procedure ReservedMethod02;
    procedure ReservedMethod03;
    procedure ReservedMethod04;
    procedure ReservedMethod05;
    procedure ReservedMethod06;
    procedure ReservedMethod07;
    procedure ReservedMethod08;
    procedure ReservedMethod09;
    procedure ReservedMethod10;
    procedure ReservedMethod11;
    procedure ReservedMethod12;
    procedure ReservedMethod13;
    procedure ReservedMethod14;
    procedure ReservedMethod15;
    procedure ReservedMethod16;
    procedure ReservedMethod17;
    procedure ReservedMethod18;
    procedure ReservedMethod19;
    procedure ReservedMethod20;
    procedure SaveAs(const newPathName: WideString);
    procedure _SetDirty;
    procedure AddEventRelayer(const piEventRelayer: IAdEventRelayer);
    procedure SaveWorkspaceLayoutFile(const newFilePath: WideString);
    property  ControlInterface: IAdDwfViewer2 read GetControlInterface;
    property  DefaultInterface: IAdDwfViewer2 read GetControlInterface;
    property Viewer: IDispatch index 2 read GetIDispatchProp;
    property _ActiveWindow: OleVariant index 200 read GetOleVariantProp;
    property _ClientWindow: OleVariant index 202 read GetOleVariantProp;
    property _DocumentParams: WideString index 203 read GetWideStringProp;
    property _HistoryParams: WideString index 204 read GetWideStringProp;
    property _LocalFilePath: WideString index 205 read GetWideStringProp;
    property _SourceStream: IUnknown index 206 write SetIUnknownProp;
    property DocumentHandler: IDispatch index 106 read GetIDispatchProp;
    property DocumentType: WideString index 107 read GetWideStringProp;
    property ContextMenu: IDispatch index 403 read GetIDispatchProp write SetIDispatchProp;
    property ReservedProperty05: OleVariant index 405 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty06: OleVariant index 406 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty07: OleVariant index 407 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty08: OleVariant index 408 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty09: OleVariant index 409 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty10: OleVariant index 410 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty11: OleVariant index 411 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty12: OleVariant index 412 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty13: OleVariant index 413 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty14: OleVariant index 414 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty15: OleVariant index 415 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty16: OleVariant index 416 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty17: OleVariant index 417 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty18: OleVariant index 418 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty19: OleVariant index 419 read GetOleVariantProp write SetOleVariantProp;
    property ReservedProperty20: OleVariant index 420 read GetOleVariantProp write SetOleVariantProp;
    property MarkupEditor: IDispatch index 1002 read GetIDispatchProp;
    property PreferredDocumentHandler[const DocInterface: WideString]: WideString read Get_PreferredDocumentHandler write Set_PreferredDocumentHandler;
    property _FileName: WideString index 1004 write SetWideStringProp;
    property PreferredProduct: WideString index 1007 write SetWideStringProp;
    property ProductName: WideString index 1008 read GetWideStringProp;
    property ProductVersion[const bProduct: WideString]: WideString read Get_ProductVersion;
    property ECompositeViewer: IDispatch index 1011 read GetIDispatchProp;
  published
    property Anchors;
    property  ParentColor;
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
    property BackColor: TColor index -501 read GetTColorProp write SetTColorProp stored False;
    property EmbedSourceDocument: WordBool index 3 read GetWordBoolProp write SetWordBoolProp stored False;
    property SourcePath: WideString index 1 read GetWideStringProp write SetWideStringProp stored False;
    property _ViewerParams: WideString index 201 read GetWideStringProp write SetWideStringProp stored False;
    property GradientBackgroundColor: TColor index 401 read GetTColorProp write SetTColorProp stored False;
    property GradientBackgroundEnabled: WordBool index 402 read GetWordBoolProp write SetWordBoolProp stored False;
    property CanvasEmpty: WordBool index 404 read GetWordBoolProp write SetWordBoolProp stored False;
    property IndexPage: WideString index 1001 read GetWideStringProp write SetWideStringProp stored False;
    property DragAndDropEnabled: Integer index 1010 read GetIntegerProp write SetIntegerProp stored False;
    property WorkspaceLayoutFile: WideString index 1013 read GetWideStringProp write SetWideStringProp stored False;
    property CreatNewState: WordBool index 1015 read GetWordBoolProp write SetWordBoolProp stored False;
    property OnBeginDraw: TCExpressViewerControlOnBeginDraw read FOnBeginDraw write FOnBeginDraw;
    property OnEndDraw: TCExpressViewerControlOnEndDraw read FOnEndDraw write FOnEndDraw;
    property OnMouseMove: TCExpressViewerControlOnMouseMove read FOnMouseMove write FOnMouseMove;
    property OnLButtonDown: TCExpressViewerControlOnLButtonDown read FOnLButtonDown write FOnLButtonDown;
    property OnLButtonUp: TCExpressViewerControlOnLButtonUp read FOnLButtonUp write FOnLButtonUp;
    property OnLButtonDblClick: TCExpressViewerControlOnLButtonDblClick read FOnLButtonDblClick write FOnLButtonDblClick;
    property OnMButtonDown: TCExpressViewerControlOnMButtonDown read FOnMButtonDown write FOnMButtonDown;
    property OnMButtonUp: TCExpressViewerControlOnMButtonUp read FOnMButtonUp write FOnMButtonUp;
    property OnMButtonDblClick: TCExpressViewerControlOnMButtonDblClick read FOnMButtonDblClick write FOnMButtonDblClick;
    property OnRButtonDown: TCExpressViewerControlOnRButtonDown read FOnRButtonDown write FOnRButtonDown;
    property OnRButtonUp: TCExpressViewerControlOnRButtonUp read FOnRButtonUp write FOnRButtonUp;
    property OnRButtonDblClick: TCExpressViewerControlOnRButtonDblClick read FOnRButtonDblClick write FOnRButtonDblClick;
    property OnMouseWheel: TCExpressViewerControlOnMouseWheel read FOnMouseWheel write FOnMouseWheel;
    property OnExecuteURL: TCExpressViewerControlOnExecuteURL read FOnExecuteURL write FOnExecuteURL;
    property OnOverURL: TCExpressViewerControlOnOverURL read FOnOverURL write FOnOverURL;
    property OnLeaveURL: TCExpressViewerControlOnLeaveURL read FOnLeaveURL write FOnLeaveURL;
    property OnKeyDown: TCExpressViewerControlOnKeyDown read FOnKeyDown write FOnKeyDown;
    property OnKeyUp: TCExpressViewerControlOnKeyUp read FOnKeyUp write FOnKeyUp;
    property OnOverObject: TCExpressViewerControlOnOverObject read FOnOverObject write FOnOverObject;
    property OnLeaveObject: TCExpressViewerControlOnLeaveObject read FOnLeaveObject write FOnLeaveObject;
    property OnSelectObject: TCExpressViewerControlOnSelectObject read FOnSelectObject write FOnSelectObject;
    property OnBeginLoadItem: TCExpressViewerControlOnBeginLoadItem read FOnBeginLoadItem write FOnBeginLoadItem;
    property OnEndLoadItem: TCExpressViewerControlOnEndLoadItem read FOnEndLoadItem write FOnEndLoadItem;
    property OnShowUiItem: TCExpressViewerControlOnShowUiItem read FOnShowUiItem write FOnShowUiItem;
    property OnUpdateUiItem: TCExpressViewerControlOnUpdateUiItem read FOnUpdateUiItem write FOnUpdateUiItem;
    property OnCommand: TCExpressViewerControlOnCommand read FOnCommand write FOnCommand;
    property OnInitLoadItem: TCExpressViewerControlOnInitLoadItem read FOnInitLoadItem write FOnInitLoadItem;
    property OnUnloadItem: TCExpressViewerControlOnUnloadItem read FOnUnloadItem write FOnUnloadItem;
    property OnEventGroup: TCExpressViewerControlOnEventGroup read FOnEventGroup write FOnEventGroup;
    property OnExecuteCommandEx: TCExpressViewerControlOnExecuteCommandEx read FOnExecuteCommandEx write FOnExecuteCommandEx;
    property OnOverObjectEx: TCExpressViewerControlOnOverObjectEx read FOnOverObjectEx write FOnOverObjectEx;
    property OnLeaveObjectEx: TCExpressViewerControlOnLeaveObjectEx read FOnLeaveObjectEx write FOnLeaveObjectEx;
    property OnSelectObjectEx: TCExpressViewerControlOnSelectObjectEx read FOnSelectObjectEx write FOnSelectObjectEx;
    property OnInternalEventGroup: TCExpressViewerControlOnInternalEventGroup read FOnInternalEventGroup write FOnInternalEventGroup;
  end;

// *********************************************************************//
// The Class CoCDwfOLEserver provides a Create and CreateRemote method to          
// create instances of the default interface IAdViewer exposed by              
// the CoClass CDwfOLEserver. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCDwfOLEserver = class
    class function Create: IAdViewer;
    class function CreateRemote(const MachineName: string): IAdViewer;
  end;

// *********************************************************************//
// The Class Co__Impl_IAdPrivateRelayEvent provides a Create and CreateRemote method to          
// create instances of the default interface IAdPrivateRelayEvent exposed by              
// the CoClass __Impl_IAdPrivateRelayEvent. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Co__Impl_IAdPrivateRelayEvent = class
    class function Create: IAdPrivateRelayEvent;
    class function CreateRemote(const MachineName: string): IAdPrivateRelayEvent;
  end;

// *********************************************************************//
// The Class Co__Impl_IAdViewerEvents provides a Create and CreateRemote method to          
// create instances of the default interface IUnknown exposed by              
// the CoClass __Impl_IAdViewerEvents. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Co__Impl_IAdViewerEvents = class
    class function Create: IUnknown;
    class function CreateRemote(const MachineName: string): IUnknown;
  end;

// *********************************************************************//
// The Class CoCExpressViewerHtmlUtil provides a Create and CreateRemote method to          
// create instances of the default interface IExpressViewerHtmlUtil exposed by              
// the CoClass CExpressViewerHtmlUtil. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCExpressViewerHtmlUtil = class
    class function Create: IExpressViewerHtmlUtil;
    class function CreateRemote(const MachineName: string): IExpressViewerHtmlUtil;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoCSourcePath.Create: IPropertyPage;
begin
  Result := CreateComObject(CLASS_CSourcePath) as IPropertyPage;
end;

class function CoCSourcePath.CreateRemote(const MachineName: string): IPropertyPage;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CSourcePath) as IPropertyPage;
end;

procedure TCExpressViewerControl.InitControlData;
const
  CEventDispIDs: array [0..33] of DWORD = (
    $00000001, $00000002, $00000003, $00000004, $00000005, $00000006,
    $00000007, $00000008, $00000009, $0000000A, $0000000B, $0000000C,
    $0000000D, $0000000E, $0000000F, $00000010, $00000011, $00000012,
    $00000013, $00000014, $00000015, $00000016, $00000017, $00000018,
    $00000019, $0000001A, $0000001B, $0000001C, $0000001D, $0000001E,
    $0000001F, $00000020, $00000021, $00000022);
  CControlData: TControlData2 = (
    ClassID: '{A662DA7E-CCB7-4743-B71A-D817F6D575DF}';
    EventIID: '{A7D421C8-FC4D-488F-AA61-4FEC541A57B8}';
    EventCount: 34;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80004002*);
    Flags: $00000001;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnBeginDraw) - Cardinal(Self);
end;

procedure TCExpressViewerControl.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IAdDwfViewer2;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TCExpressViewerControl.GetControlInterface: IAdDwfViewer2;
begin
  CreateControl;
  Result := FIntf;
end;

function TCExpressViewerControl.Get_Viewer: IDispatch;
begin
    Result := DefaultInterface.Viewer;
end;

function TCExpressViewerControl.Get__ActiveWindow: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant._ActiveWindow;
end;

function TCExpressViewerControl.Get__ClientWindow: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant._ClientWindow;
end;

procedure TCExpressViewerControl.Set__SourceStream(const Param1: IUnknown);
begin
  DefaultInterface.Set__SourceStream(Param1);
end;

function TCExpressViewerControl.Get_DocumentHandler: IDispatch;
begin
    Result := DefaultInterface.DocumentHandler;
end;

function TCExpressViewerControl.Get_ContextMenu: IDispatch;
begin
    Result := DefaultInterface.ContextMenu;
end;

procedure TCExpressViewerControl.Set_ContextMenu(const pVal: IDispatch);
begin
  DefaultInterface.Set_ContextMenu(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty05: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty05;
end;

procedure TCExpressViewerControl.Set_ReservedProperty05(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty05(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty06: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty06;
end;

procedure TCExpressViewerControl.Set_ReservedProperty06(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty06(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty07: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty07;
end;

procedure TCExpressViewerControl.Set_ReservedProperty07(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty07(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty08: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty08;
end;

procedure TCExpressViewerControl.Set_ReservedProperty08(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty08(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty09: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty09;
end;

procedure TCExpressViewerControl.Set_ReservedProperty09(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty09(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty10: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty10;
end;

procedure TCExpressViewerControl.Set_ReservedProperty10(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty10(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty11: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty11;
end;

procedure TCExpressViewerControl.Set_ReservedProperty11(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty11(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty12: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty12;
end;

procedure TCExpressViewerControl.Set_ReservedProperty12(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty12(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty13: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty13;
end;

procedure TCExpressViewerControl.Set_ReservedProperty13(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty13(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty14: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty14;
end;

procedure TCExpressViewerControl.Set_ReservedProperty14(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty14(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty15: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty15;
end;

procedure TCExpressViewerControl.Set_ReservedProperty15(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty15(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty16: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty16;
end;

procedure TCExpressViewerControl.Set_ReservedProperty16(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty16(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty17: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty17;
end;

procedure TCExpressViewerControl.Set_ReservedProperty17(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty17(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty18: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty18;
end;

procedure TCExpressViewerControl.Set_ReservedProperty18(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty18(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty19: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty19;
end;

procedure TCExpressViewerControl.Set_ReservedProperty19(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty19(pVal);
end;

function TCExpressViewerControl.Get_ReservedProperty20: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ReservedProperty20;
end;

procedure TCExpressViewerControl.Set_ReservedProperty20(pVal: OleVariant);
begin
  DefaultInterface.Set_ReservedProperty20(pVal);
end;

function TCExpressViewerControl.Get_MarkupEditor: IDispatch;
begin
    Result := DefaultInterface.MarkupEditor;
end;

function TCExpressViewerControl.Get_PreferredDocumentHandler(const DocInterface: WideString): WideString;
begin
    Result := DefaultInterface.PreferredDocumentHandler[DocInterface];
end;

procedure TCExpressViewerControl.Set_PreferredDocumentHandler(const DocInterface: WideString; 
                                                              const pVal: WideString);
  { Warning: The property PreferredDocumentHandler has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.PreferredDocumentHandler := pVal;
end;

function TCExpressViewerControl.Get_ProductVersion(const bProduct: WideString): WideString;
begin
    Result := DefaultInterface.ProductVersion[bProduct];
end;

function TCExpressViewerControl.Get_ECompositeViewer: IDispatch;
begin
    Result := DefaultInterface.ECompositeViewer;
end;

procedure TCExpressViewerControl.ShowPrintDialog;
begin
  DefaultInterface.ShowPrintDialog;
end;

procedure TCExpressViewerControl.NavigateToUrl(const bstrUrl: WideString);
begin
  DefaultInterface.NavigateToUrl(bstrUrl);
end;

procedure TCExpressViewerControl.ExecuteCommand(const bstrCommand: WideString);
begin
  DefaultInterface.ExecuteCommand(bstrCommand);
end;

procedure TCExpressViewerControl.DrawToDC(nDc: Integer; nLeft: Integer; nTop: Integer; 
                                          nRight: Integer; nBottom: Integer);
begin
  DefaultInterface.DrawToDC(nDc, nLeft, nTop, nRight, nBottom);
end;

procedure TCExpressViewerControl._GoBack;
begin
  DefaultInterface._GoBack;
end;

procedure TCExpressViewerControl._GoForward;
begin
  DefaultInterface._GoForward;
end;

procedure TCExpressViewerControl._SaveHistory;
begin
  DefaultInterface._SaveHistory;
end;

procedure TCExpressViewerControl._ShowHelp(const bstrTopic: WideString);
begin
  DefaultInterface._ShowHelp(bstrTopic);
end;

procedure TCExpressViewerControl.ExecuteCommandEx(const bstrCommand: WideString; lVal: Integer);
begin
  DefaultInterface.ExecuteCommandEx(bstrCommand, lVal);
end;

procedure TCExpressViewerControl._ShowCIPDialog;
begin
  DefaultInterface._ShowCIPDialog;
end;

procedure TCExpressViewerControl.ReservedMethod02;
begin
  DefaultInterface.ReservedMethod02;
end;

procedure TCExpressViewerControl.ReservedMethod03;
begin
  DefaultInterface.ReservedMethod03;
end;

procedure TCExpressViewerControl.ReservedMethod04;
begin
  DefaultInterface.ReservedMethod04;
end;

procedure TCExpressViewerControl.ReservedMethod05;
begin
  DefaultInterface.ReservedMethod05;
end;

procedure TCExpressViewerControl.ReservedMethod06;
begin
  DefaultInterface.ReservedMethod06;
end;

procedure TCExpressViewerControl.ReservedMethod07;
begin
  DefaultInterface.ReservedMethod07;
end;

procedure TCExpressViewerControl.ReservedMethod08;
begin
  DefaultInterface.ReservedMethod08;
end;

procedure TCExpressViewerControl.ReservedMethod09;
begin
  DefaultInterface.ReservedMethod09;
end;

procedure TCExpressViewerControl.ReservedMethod10;
begin
  DefaultInterface.ReservedMethod10;
end;

procedure TCExpressViewerControl.ReservedMethod11;
begin
  DefaultInterface.ReservedMethod11;
end;

procedure TCExpressViewerControl.ReservedMethod12;
begin
  DefaultInterface.ReservedMethod12;
end;

procedure TCExpressViewerControl.ReservedMethod13;
begin
  DefaultInterface.ReservedMethod13;
end;

procedure TCExpressViewerControl.ReservedMethod14;
begin
  DefaultInterface.ReservedMethod14;
end;

procedure TCExpressViewerControl.ReservedMethod15;
begin
  DefaultInterface.ReservedMethod15;
end;

procedure TCExpressViewerControl.ReservedMethod16;
begin
  DefaultInterface.ReservedMethod16;
end;

procedure TCExpressViewerControl.ReservedMethod17;
begin
  DefaultInterface.ReservedMethod17;
end;

procedure TCExpressViewerControl.ReservedMethod18;
begin
  DefaultInterface.ReservedMethod18;
end;

procedure TCExpressViewerControl.ReservedMethod19;
begin
  DefaultInterface.ReservedMethod19;
end;

procedure TCExpressViewerControl.ReservedMethod20;
begin
  DefaultInterface.ReservedMethod20;
end;

procedure TCExpressViewerControl.SaveAs(const newPathName: WideString);
begin
  DefaultInterface.SaveAs(newPathName);
end;

procedure TCExpressViewerControl._SetDirty;
begin
  DefaultInterface._SetDirty;
end;

procedure TCExpressViewerControl.AddEventRelayer(const piEventRelayer: IAdEventRelayer);
begin
  DefaultInterface.AddEventRelayer(piEventRelayer);
end;

procedure TCExpressViewerControl.SaveWorkspaceLayoutFile(const newFilePath: WideString);
begin
  DefaultInterface.SaveWorkspaceLayoutFile(newFilePath);
end;

class function CoCDwfOLEserver.Create: IAdViewer;
begin
  Result := CreateComObject(CLASS_CDwfOLEserver) as IAdViewer;
end;

class function CoCDwfOLEserver.CreateRemote(const MachineName: string): IAdViewer;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CDwfOLEserver) as IAdViewer;
end;

class function Co__Impl_IAdPrivateRelayEvent.Create: IAdPrivateRelayEvent;
begin
  Result := CreateComObject(CLASS___Impl_IAdPrivateRelayEvent) as IAdPrivateRelayEvent;
end;

class function Co__Impl_IAdPrivateRelayEvent.CreateRemote(const MachineName: string): IAdPrivateRelayEvent;
begin
  Result := CreateRemoteComObject(MachineName, CLASS___Impl_IAdPrivateRelayEvent) as IAdPrivateRelayEvent;
end;

class function Co__Impl_IAdViewerEvents.Create: IUnknown;
begin
  Result := CreateComObject(CLASS___Impl_IAdViewerEvents) as IUnknown;
end;

class function Co__Impl_IAdViewerEvents.CreateRemote(const MachineName: string): IUnknown;
begin
  Result := CreateRemoteComObject(MachineName, CLASS___Impl_IAdViewerEvents) as IUnknown;
end;

class function CoCExpressViewerHtmlUtil.Create: IExpressViewerHtmlUtil;
begin
  Result := CreateComObject(CLASS_CExpressViewerHtmlUtil) as IExpressViewerHtmlUtil;
end;

class function CoCExpressViewerHtmlUtil.CreateRemote(const MachineName: string): IExpressViewerHtmlUtil;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CExpressViewerHtmlUtil) as IExpressViewerHtmlUtil;
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TCExpressViewerControl]);
end;

end.
