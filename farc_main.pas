{=====(C) Copyright Aug.2009-2014 Jean-Francois Baconnet All rights reserved================

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: core unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2014, Jean-Francois Baconnet

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************************}

unit farc_main;

interface

uses
   Classes,
   Controls,
   Forms,
   Menus,
   Messages,
   StdCtrls,
   SysUtils,
   Windows,

   WSDLBind,

   XMLDoc,

   GR32_Image,

   AdvGroupBox,
   AdvMenus,
   AdvPanel,
   HTMLabel,
   HTMListB,

   o_GTTimer,

   BaseClasses,
   GLAtmosphere,
   GLBitmapFont,
   GLBlur,
   GLCadencer,
   GLCoordinates,
   GLCrossPlatform,
   GLHUDObjects,
   GLNavigator,
   GLObjects,
   GLScene,
   GLSmoothNavigator,
   GLVectorFileObjects,
   GLWin32Viewer,
   GLWindowsFont,
   VectorGeometry,

   OpenGL1x, ComCtrls, htmltv, AdvPageControl, HotSpotImage, ImagingComponents, xmldom,
  XMLIntf, msxmldom, ExtCtrls, AdvCircularProgress, HTMLTreeList, AdvGlowButton, AdvCombo,
  htmlbtns, AdvTrackBar;

type
   TFCWinMain = class(TForm)
      FCXMLcfg: TXMLDocument;
      FCXMLdbFac: TXMLDocument;
      FCXMLdbUniv: TXMLDocument;
      FCXMLtxtUI: TXMLDocument;
      FCXMLtxtEncy: TXMLDocument;
      WM_MainMenu: TMainMenu;
      MM_GameSection: TMenuItem;
      MMGameSection_New: TMenuItem;
      MMGameSection_Continue: TMenuItem;
      MMGameSection_LoadSaved: TMenuItem;
      MMGameSection_Save: TMenuItem;
      MMGameSection_SaveAndFlush: TMenuItem;
      MMGameSection_Quit: TMenuItem;
      MM_OptionsSection: TMenuItem;
      MMOptionsSection_LanguageSection: TMenuItem;
      MMOptionsSection_LS_EN: TMenuItem;
      MMOptionsSection_LS_FR: TMenuItem;
      MMOptionsSection_LS_SP: TMenuItem;
      MMOptionSection_PanelsLocationSection: TMenuItem;
      MMOptionSection_PLS_LocationHelp: TMenuItem;
      MMOptionSection_PLS_LocationViabilityObjectives: TMenuItem;
      MMOptionSection_WideScreenBckg: TMenuItem;
      MMOptionSection_StandardTexturesSection: TMenuItem;
      MMOptionSection_STS_1024: TMenuItem;
      MMOptionSection_STS_2048: TMenuItem;
      MM_HelpSection: TMenuItem;
      MMHelpSection_HelpPanel: TMenuItem;
      MMHelpSection_About: TMenuItem;
      MMDebugSection: TMenuItem;
      MMDebugSection_FUG: TMenuItem;
      MMDebugSection_ReloadTxtFiles: TMenuItem;




      FCWM_BckgImage: TImage32;
      WM_MainViewGroup: TAdvGroupBox;
      FCGLSRootMain: TGLScene;
      FCGLSmainView: TGLSceneViewer;
      FCGLSCamMainView: TGLCamera;
      FCGLScadencer: TGLCadencer;
      FCGLSStarMain: TGLSprite;
      FCGLSSM_Light: TGLLightSource;
      FCGLSsmthNavMainV: TGLSmoothNavigator;
      FCGLSCamMainViewGhost: TGLCamera;
      FCGLSFontDateTime: TGLWindowsBitmapFont;
      FCGLSHUDgameTime: TGLHUDText;
      FCGLSHUDgameDate: TGLHUDText;
      FCXMLdbSCraft: TXMLDocument;
      FCGLSSM_Blur: TGLBlur;
      FCGLSHUDobjectFocused: TGLHUDText;
      FCGLSFontTitleMain: TGLWindowsBitmapFont;
      FCWM_MsgeBox: TAdvPanel;
      FCWM_MsgeBox_Desc: THTMLabel;
      FCWM_MsgeBox_List: THTMListBox;
      FCGLSHUDgameTimePhase: TGLHUDText;
      FCXMLsave: TXMLDocument;

      N1: TMenuItem;

      FCGLSFontData: TGLWindowsBitmapFont;
      FCGLSHUDstarClassLAB: TGLHUDText;
      FCGLSHUDstarClass: TGLHUDText;
      FCGLSHUDstarTempLAB: TGLHUDText;
      FCGLSHUDstarTemp: TGLHUDText;
      FCGLSFontDataLabel: TGLWindowsBitmapFont;
      FCGLSHUDstarDiamLAB: TGLHUDText;
      FCGLSHUDstarMassLAB: TGLHUDText;
      FCGLSHUDstarLumLAB: TGLHUDText;
      FCGLSHUDstarDiam: TGLHUDText;
      FCGLSHUDstarMass: TGLHUDText;
      FCGLSHUDstarLum: TGLHUDText;

      FCGLSHUDspunDV: TGLHUDText;
      FCGLSHUDspunRMass: TGLHUDText;
      FCGLSHUDspunRMassLAB: TGLHUDText;
      FCGLSHUDspunDvLAB: TGLHUDText;
      FCGLSHUDspunSTATUSLAB: TGLHUDText;
      FCGLSHUDspunMissLAB: TGLHUDText;
      FCGLSHUDspunTaskLAB: TGLHUDText;
      FCGLSHUDspunTask: TGLHUDText;
      FCGLSHUDspunSTATUS: TGLHUDText;
      FCGLSHUDspunMiss: TGLHUDText;
      FCGLSHUDobobjOrbDatHLAB: TGLHUDText;
      FCGLSHUDobobjDistLAB: TGLHUDText;
      FCGLSHUDobobjEccLAB: TGLHUDText;
      FCGLSHUDobobjZoneLAB: TGLHUDText;
      FCGLSHUDobobjRevPerLAB: TGLHUDText;
      FCGLSHUDobobjRotPerLAB: TGLHUDText;
      FCGLSHUDobobjSatLAB: TGLHUDText;
      FCGLSHUDobobjGeophyHLAB: TGLHUDText;
      FCGLSHUDobobjObjTpLAB: TGLHUDText;
      FCGLSHUDobobjDiamLAB: TGLHUDText;
      FCGLSHUDobobjDensLAB: TGLHUDText;
      FCGLSHUDobobjMassLAB: TGLHUDText;
      FCGLSHUDobobjGravLAB: TGLHUDText;
      FCGLSHUDobobjEVelLAB: TGLHUDText;
      FCGLSHUDobobjMagFLAB: TGLHUDText;
      FCGLSHUDobobjAxTiltLAB: TGLHUDText;
      FCGLSHUDobobjAlbeLAB: TGLHUDText;
      FCGLSHUDobobjDist: TGLHUDText;
      FCGLSHUDobobjEcc: TGLHUDText;
      FCGLSHUDobobjZone: TGLHUDText;
      FCGLSHUDobobjRevPer: TGLHUDText;
      FCGLSHUDobobjSat: TGLHUDText;
      FCGLSHUDobobjObjTp: TGLHUDText;
      FCGLSHUDobobjDiam: TGLHUDText;
      FCGLSHUDobobjDens: TGLHUDText;
      FCGLSHUDobobjMass: TGLHUDText;
      FCGLSHUDobobjGrav: TGLHUDText;
      FCGLSHUDobobjEVel: TGLHUDText;
      FCGLSHUDobobjMagF: TGLHUDText;
      FCGLSHUDobobjRotPer: TGLHUDText;
      FCGLSHUDobobjAxTilt: TGLHUDText;
      FCGLSHUDobobjAlbe: TGLHUDText;
      FCGLSFontDataHeader: TGLWindowsBitmapFont;
      FCWM_HelpPanel: TAdvPanel;
      FCWM_HPdataPad: TAdvPageControl;
      FCWM_HPdPad_Keys: TAdvTabSheet;
      FCWM_HPdPad_KeysTxt1: THTMLabel;

      FCWM_RegTerrLib: TBitmap32List;
      {.Surface Panel declarations}
      MVG_SurfacePanel: TAdvPanel;
      {.--}
      SP_FrameLeftNOTDESIGNED: TAdvGroupBox;
      SP_FLND_Label: THTMLabel;
      {.--}
      SP_FrameRegionPicture: TAdvGroupBox;
      SP_FRP_Picture: TImage32;
      {.--}
      SP_EcosphereSheet: THTMLabel;
      {.--}
      SP_AutoUpdateCheck: TCheckBox;
      SP_RegionSheet: THTMLabel;
      {.--}
      SP_FrameRightResources: TAdvGroupBox;
      {.--}
      SP_SurfaceDisplay: THotSpotImage;
      SP_SD_SurfaceSelector: THTMLabel;
      SP_SD_SurfaceSelected: THTMLabel;
      {.}
      FCGLSHUDcpsCVS: TGLHUDText;
      FCGLSHUDcpsCVSLAB: TGLHUDText;
      FCGLSHUDcpsCredL: TGLHUDText;
      FCGLSFontCPSData: TGLWindowsBitmapFont;
      FCGLSHUDcpsTlft: TGLHUDText;
      FCGLSHUDspunDockd: TGLHUDSprite;
      FCGLSHUDspunDockdDat: TGLHUDText;
      FCWM_DockLstPanel: TAdvPanel;
    FCWM_DLP_DockList: THTMListBox;
    FCXMLdbInfra: TXMLDocument;

    FCWM_ColDPanel: TAdvPanel;
    FCWM_CDPinfo: TAdvGroupBox;
    FCWM_CDPinfoText: THTMLabel;
    FCWM_CDPepi: TAdvPageControl;
    FCWM_CDPcsme: TAdvTabSheet;
    FCWM_CDPinfr: TAdvTabSheet;
    FCWM_CDPpopList: THTMLTreeview;
    FCWM_CDPcsmeList: THTMLTreeview;
    FCWM_HPDPhints: TAdvTabSheet;
    FCWM_HDPhintsList: THTMListBox;
    FCWM_HDPhintsText: THTMLabel;
    FCWM_CDPcolName: TLabeledEdit;
    FCGLSHUDcolplyr: TGLHUDSprite;
    FCGLSHUDcolplyrName: TGLHUDText;
    FCXMLdbSPMi: TXMLDocument;

    FCWM_UMI: TAdvPanel;
    FCWM_UMI_TabSh: TAdvPageControl;
    FCWM_UMI_TabShUniv: TAdvTabSheet;
    HTMLabel1: THTMLabel;
    FCWM_UMI_TabShFac: TAdvTabSheet;
    FCWM_UMI_FDEconVal: THTMLabel;
    HTMListBox1: THTMListBox;
    FCWM_UMI_TabShSpU: TAdvTabSheet;
    FCWM_UMI_TabShProd: TAdvTabSheet;
    FCWM_UMI_TabShRDS: TAdvTabSheet;
    FCWM_UMI_FacDatG: TAdvGroupBox;
    FCWM_UMI_FacLvl: TAdvCircularProgress;
    FCWM_UMI_FacEcon: TAdvCircularProgress;
    FCWM_UMI_FacSoc: TAdvCircularProgress;
    FCWM_UMI_FacMil: TAdvCircularProgress;
    FCWM_UMIFac_TabSh: TAdvPageControl;
    FCWM_UMIFac_TabShPol: TAdvTabSheet;
    FCWM_UMIFac_PolGvtDetails: TAdvGroupBox;
    FCWM_UMIFac_PGDdata: THTMLabel;
    FCWM_UMIFac_TabShSPM: TAdvTabSheet;
    FCWM_UMIFac_TabShSPMpol: TAdvTabSheet;
    FCWM_UMIFSh_AFlist: THTMListBox;
    FCWM_UMIFac_Colonies: THTMLTreeList;
    FCWM_UMIFSh_SPMadmin: THTMLTreeview;
    FCWM_UMIFSh_SPMecon: THTMLTreeview;
    FCWM_UMIFSh_SPMmedca: THTMLTreeview;
    FCWM_UMIFSh_SPMsoc: THTMLTreeview;
    FCWM_UMIFSh_SPMspol: THTMLTreeview;
    FCWM_UMIFSh_SPMspi: THTMLTreeview;
    FCWM_UMIFSh_SPMlistTop: TAdvPanel;
    FCWM_UMIFSh_SPMlistBottom: TAdvPanel;
    FCWM_UMIFSh_AvailF: TAdvGroupBox;
    FCWM_UMIFSh_ReqF: TAdvGroupBox;
    FCWM_UMIFSh_RFdisp: THTMLabel;
    FCWM_UMIFSh_CAPF: TAdvGroupBox;
    FCWM_UMIFSh_CAPFlab: THTMLabel;
    FCWM_UMISh_CEnfF: TAdvGroupBox;
    FCWM_UMISh_CEFreslt: THTMLabel;
    FCWM_UMIFSh_CentF: TAdvGroupBox;
    FCWM_UMISh_CEFcommit: TAdvGlowButton;
    FCWM_UMISh_CEFretire: TAdvGlowButton;
    FCWM_UMISh_CEFenforce: TAdvGlowButton;

    FCWM_CDPpopul: TAdvTabSheet;
    FCWM_CDPpopType: THTMLTreeview;
    FCXMLdbProducts: TXMLDocument;
    FCWM_CDPinfrList: THTMLTreeview;
    FCWM_CDPinfrAvail: THTMLTreeview;
    FCWM_CDPwcpAssign: TLabeledEdit;
    FCWM_CDPwcpEquip: TAdvComboBox;
    FCWM_CDPcwpAssignVeh: TLabeledEdit;
    FCWM_InfraPanel: TAdvPanel;
    FCWM_IPlabel: THTMLabel;
    HTMLCheckBox1: THTMLCheckBox;
    FCWM_IPconfirmButton: TAdvGlowButton;
    FCWM_IPinfraKits: THTMLRadioGroup;
    FCXMLdbTechnosciences: TXMLDocument;
    FCWM_CDPstorage: TAdvTabSheet;
    CDPstorageList: THTMLTreeview;
    CDPstorageCapacity: THTMLabel;
    CDPproductionMatrixList: THTMLTreeview;

    FCWM_MissionSettings: TAdvPanel;
    FCWMS_ButCancel: TAdvGlowButton;
    FCWMS_ButProceed: TAdvGlowButton;
    FCWMS_Grp_MSDG: TAdvGroupBox;
    FCWMS_Grp_MSDG_Disp: THTMLabel;
    FCWMS_Grp_MCG: TAdvGroupBox;
    FCWMS_Grp_MCG_DatDisp: THTMLabel;
    FCWMS_Grp_MCG_MissCfgData: THTMLabel;
    FCWMS_Grp_MCG_RMassTrack: TAdvTrackBar;
    FCWMS_Grp_MCGColName: TLabeledEdit;
    FCWMS_Grp_MCG_SetName: TLabeledEdit;
    FCWMS_Grp_MCG_SetType: TAdvComboBox;
    FCWM_CPSreportSet: TAdvPanel;
    FCWM_CPSRSIGscores: THTMLabel;
    FCWM_CPSRSbuttonConfirm: TAdvGlowButton;
    FCWM_CPSRSinfogroup: TAdvGroupBox;
    FCWM_CPSRSIGreport: THTMLabel;
    FCWM_UMI_FDLvlVal: THTMLabel;
    FCWM_UMI_FDMilVal: THTMLabel;
    FCWM_UMI_FDSocVal: THTMLabel;
    FCWM_UMI_FacData: THTMLabel;
    FCWM_UMI_FDEconValDesc: THTMLabel;
    FCWM_UMI_FDLvlValDesc: THTMLabel;
    FCWM_UMI_FDMilValDesc: THTMLabel;
    FCWM_UMI_FDSocValDesc: THTMLabel;
    WM_ActionPanel: TAdvPanel;
    AP_ColonyData: TAdvGlowButton;
    AP_Separator1: TAdvGlowButton;
    AP_OObjData: TAdvGlowButton;
    AP_DetailedData: TAdvGlowButton;
    AP_DockingList: TAdvGlowButton;
    AP_MissionCancel: TAdvGlowButton;
    AP_MissionInterplanetaryTransit: TAdvGlowButton;
    AP_MissionColonization: TAdvGlowButton;
    SP_ResourceSurveyCommit: TAdvGlowButton;
    MVG_PlanetarySurveyPanel: TAdvPanel;
    PSP_Label: THTMLabel;
    FCXMLtxtCredits: TXMLDocument;
    PSP_ProductsList: THTMLTreeview;
    PSP_MissionExt: THTMLRadioGroup;
    PSP_Commit: TAdvGlowButton;
    SP_ResourceSurveyShowDetails: TAdvGlowButton;
    AP_OObjSwitchHeader: TAdvGlowButton;
    AP_OObjSwitch8: TAdvGlowButton;
    AP_OObjSwitch7: TAdvGlowButton;
    AP_OObjSwitch6: TAdvGlowButton;
    AP_OObjSwitch5: TAdvGlowButton;
    AP_OObjSwitch4: TAdvGlowButton;
    AP_OObjSwitch3: TAdvGlowButton;
    AP_OObjSwitch2: TAdvGlowButton;
    AP_OObjSwitch1: TAdvGlowButton;
    AP_OObjSwitch15: TAdvGlowButton;
    AP_OObjSwitch14: TAdvGlowButton;
    AP_OObjSwitch13: TAdvGlowButton;
    AP_OObjSwitch12: TAdvGlowButton;
    AP_OObjSwitch11: TAdvGlowButton;
    AP_OObjSwitch10: TAdvGlowButton;
    AP_OObjSwitch9: TAdvGlowButton;
    MMOptionSection_RealtimeTunrBasedSwitch: TMenuItem;
    FCWM_HPdPad_KeysTxt2: THTMLabel;
    FCWM_HPdPad_KeysTxt3: THTMLabel;

      procedure FormCreate(Sender: TObject);
      procedure FormResize(Sender: TObject);
      procedure MMGameSection_QuitClick(Sender: TObject);
      procedure MMOptionsSection_LS_FRClick(Sender: TObject);
      procedure MMOptionsSection_LS_ENClick(Sender: TObject);
      procedure MMGameSection_NewClick(Sender: TObject);
      procedure FCGLScadencerProgress(Sender: TObject; const deltaTime, newTime: Double);
      procedure FCGLSmainViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure FCGLSmainViewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure FCWM_MsgeBoxCaptionDBlClick(Sender: TObject);
      procedure FCWM_MsgeBox_ListClick(Sender: TObject);
      procedure FCWM_MsgeBox_ListDblClick(Sender: TObject);
      procedure FCWM_MsgeBox_ListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure MMHelpSection_AboutClick(Sender: TObject);
      procedure MMGameSection_ContinueClick(Sender: TObject);
      procedure FCWM_PopMenFocusedObjPopup(Sender: TObject);
      procedure MMGameSection_SaveClick(Sender: TObject);
      procedure FCGLSmainViewAfterRender(Sender: TObject);
      procedure MMOptionSection_WideScreenBckgClick(Sender: TObject);
      procedure MMOptionSection_STS_1024Click(Sender: TObject);
      procedure MMOptionSection_STS_2048Click(Sender: TObject);
      procedure MMHelpSection_HelpPanelClick(Sender: TObject);
      procedure SP_SurfaceDisplayHotSpotEnter(Sender: TObject; HotSpot: THotSpot);
      procedure SP_SurfaceDisplayMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure SP_SD_SurfaceSelectorClick(Sender: TObject);
      procedure SP_AutoUpdateCheckKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWM_DLP_DockListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWM_DLP_DockListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FCWM_DLP_DockListClick(Sender: TObject);
    procedure FCGLSmainViewMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MMOptionSection_PLS_LocationViabilityObjectivesClick(Sender: TObject);
    procedure MMOptionSection_PLS_LocationHelpClick(Sender: TObject);
    procedure MMDebugSection_FUGClick(Sender: TObject);
    procedure FCWM_ColDPanelEndMoveSize(Sender: TObject);
    procedure FCWM_ColDPanelClose(Sender: TObject);
    procedure FCWM_CDPinfrListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FCWM_CDPinfrListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWM_HDPhintsListClick(Sender: TObject);
    procedure FCWM_CDPcsmeListAnchorClick(Sender: TObject; Node: TTreeNode; anchor: string);
    procedure FCWM_CDPcolNameKeyPress(Sender: TObject; var Key: Char);
    procedure FCWM_CDPcolNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWM_ColDPanelMinimize(Sender: TObject);
    procedure FCWM_ColDPanelMaximize(Sender: TObject);
    procedure FCWM_HDPhintsTextAnchorClick(Sender: TObject; Anchor: string);
    procedure MMGameSection_SaveAndFlushClick(Sender: TObject);
    procedure FCWM_HDPhintsListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWM_UMIResize(Sender: TObject);
    procedure FCWM_UMI_TabShChange(Sender: TObject);
    procedure FCWM_UMIFac_ColoniesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FCWM_UMIFSh_SPMadminAnchorClick(Sender: TObject; Node: TTreeNode;
      anchor: string);
    procedure FCWM_UMIFac_TabShChange(Sender: TObject);
    procedure FCWM_UMIFSh_AFlistAnchorClick(Sender: TObject; index: Integer;
      anchor: string);
    procedure FCWM_UMIFSh_AFlistClick(Sender: TObject);
    procedure FCWM_UMIMinimize(Sender: TObject);
    procedure FCWM_UMIMaximize(Sender: TObject);
    procedure FCWM_UMISh_CEFenforceClick(Sender: TObject);
    procedure FCWM_UMISh_CEFretireClick(Sender: TObject);
    procedure FCWM_UMISh_CEFcommitClick(Sender: TObject);
    procedure FCWM_UMIFSh_SPMsocKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWM_UMIFSh_AFlistKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MMDebugSection_ReloadTxtFilesClick(Sender: TObject);
    procedure FCWM_CDPpopListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWM_CDPpopTypeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWM_CDPcsmeListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FCWM_CDPinfrListAnchorClick(Sender: TObject; Node: TTreeNode; anchor: string);
    procedure FCWM_CDPinfrAvailAnchorClick(Sender: TObject; Node: TTreeNode;
      anchor: string);
    procedure FCWM_CDPpopListAnchorClick(Sender: TObject; Node: TTreeNode; anchor: string);
    procedure FCWM_CDPwcpAssignKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWM_CDPpopListRadioClick(Sender: TObject; Node: TTreeNode);
    procedure FCWM_CDPcwpAssignVehKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FCWM_CDPinfrListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FCWM_CDPinfrAvailMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FCWM_CDPinfrAvailKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWM_CDPinfrAvailMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FCWM_IPlabelAnchorClick(Sender: TObject; Anchor: string);
    procedure FCWM_CDPepiChange(Sender: TObject);
    procedure FCWM_IPconfirmButtonClick(Sender: TObject);
    procedure FCWM_IPinfraKitsClick(Sender: TObject);
    procedure FCWM_CDPpopListCollapsed(Sender: TObject; Node: TTreeNode);
    procedure FCWM_CDPpopListExpanded(Sender: TObject; Node: TTreeNode);
    procedure CDPstorageListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure CDPstorageListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDPproductionMatrixListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure CDPproductionMatrixListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MMOptionsSection_LS_SPClick(Sender: TObject);
    procedure FCWM_CDPwcpEquipKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWMS_ButCancelClick(Sender: TObject);
    procedure FCWMS_ButCancelKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWMS_ButProceedClick(Sender: TObject);
    procedure FCWMS_ButProceedKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWMS_Grp_MCGColNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWMS_Grp_MCGColNameKeyPress(Sender: TObject; var Key: Char);
    procedure FCWMS_Grp_MCG_RMassTrackChange(Sender: TObject);
    procedure FCWMS_Grp_MCG_RMassTrackKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWMS_Grp_MCG_SetNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWMS_Grp_MCG_SetNameKeyPress(Sender: TObject; var Key: Char);
    procedure FCWM_MissionSettingsClose(Sender: TObject);
    procedure FCWM_MissionSettingsEndMoveSize(Sender: TObject);
    procedure FCWM_MissionSettingsMaximize(Sender: TObject);
    procedure FCWM_MissionSettingsMinimize(Sender: TObject);
    procedure FCWM_MissionSettingsEndCollapsExpand(Sender: TObject);
    procedure FCWM_ColDPanelEndCollapsExpand(Sender: TObject);
    procedure FCWM_CDPinfoTextAnchorClick(Sender: TObject; Anchor: string);
    procedure FCWM_CPSRSbuttonConfirmClick(Sender: TObject);
    procedure WM_ActionPanelClose(Sender: TObject);
    procedure AP_ColonyDataClick(Sender: TObject);
    procedure AP_OObjDataClick(Sender: TObject);
    procedure AP_DockingListClick(Sender: TObject);
    procedure AP_MissionColonizationClick(Sender: TObject);
    procedure AP_MissionInterplanetaryTransitClick(Sender: TObject);
    procedure AP_MissionCancelClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint; var Handled: Boolean);
    procedure WM_MainMenuChange(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
    procedure SP_SD_SurfaceSelectedMouseEnter(Sender: TObject);
    procedure SP_ResourceSurveyCommitClick(Sender: TObject);
    procedure PSP_ProductsListAnchorClick(Sender: TObject; Node: TTreeNode; anchor: string);
    procedure PSP_ProductsListCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure PSP_CommitClick(Sender: TObject);
    procedure SP_ResourceSurveyShowDetailsClick(Sender: TObject);
    procedure SP_RegionSheetMouseEnter(Sender: TObject);
    procedure MMGameSection_LoadSavedClick(Sender: TObject);
    procedure AP_OObjSwitch1Click(Sender: TObject);
    procedure AP_OObjSwitch10Click(Sender: TObject);
    procedure AP_OObjSwitch11Click(Sender: TObject);
    procedure AP_OObjSwitch12Click(Sender: TObject);
    procedure AP_OObjSwitch13Click(Sender: TObject);
    procedure AP_OObjSwitch14Click(Sender: TObject);
    procedure AP_OObjSwitch15Click(Sender: TObject);
    procedure AP_OObjSwitch2Click(Sender: TObject);
    procedure AP_OObjSwitch3Click(Sender: TObject);
    procedure AP_OObjSwitch4Click(Sender: TObject);
    procedure AP_OObjSwitch5Click(Sender: TObject);
    procedure AP_OObjSwitch6Click(Sender: TObject);
    procedure AP_OObjSwitch7Click(Sender: TObject);
    procedure AP_OObjSwitch8Click(Sender: TObject);
    procedure AP_OObjSwitch9Click(Sender: TObject);
    procedure AP_OObjSwitch3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch10MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch11MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch12MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch13MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch14MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch15MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch5MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch6MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch7MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch8MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AP_OObjSwitch9MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MMOptionSection_RealtimeTunrBasedSwitchClick(Sender: TObject);
//    procedure FormActivate(Sender: TObject);
   private
      { Private declarations }
         {timesteps needed for camera transitions}
      FCV3DcamTimeSteps: extended;
      FCVisFARCclosing: boolean;
      FCVwinMmouseNewPosX: Integer;
      FCVwinMmouseNewPosY: Integer;
      FCVwinMmousePosDumpX: Integer;
      FCVwinMmousePosDumpY: Integer;
      FCVwinMmouseShftState: TShiftState;
      procedure InternalOnGameTimer(Sender : TObject);
      procedure WMExitSizeMove(var Message: TMessage) ; message WM_EXITSIZEMOVE;
      procedure WMMaximized(var Message: TMessage) ; message SW_SHOWMAXIMIZED;
      procedure UpdUI(UUIwinOnly: boolean);
   public
      { Public declarations }
   end;

var
  FCWinMain: TFCWinMain;

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_files
   ,farc_data_filesavegame
   ,farc_data_game
   ,farc_data_html
   ,farc_data_init
   ,farc_data_missionstasks
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_game_colony
   ,farc_fug_com
   ,farc_game_core
   ,farc_game_cps
   ,farc_missions_colonization
   ,farc_missions_core
   ,farc_game_contg
   ,farc_game_infra
   ,farc_game_newg
   ,farc_game_gameflow
   ,farc_game_spm
   ,farc_game_tasksystem
   ,farc_ogl_init
   ,farc_ogl_viewmain
   ,farc_ogl_ui
   ,farc_ui_actionpanel
   ,farc_ui_coldatapanel
   ,farc_ui_coredatadisplay
   ,farc_ui_html
   ,farc_ui_infrapanel
   ,farc_ui_keys
   ,farc_ui_missionsetup
   ,farc_ui_msges
   ,farc_ui_planetarysurvey
   ,farc_ui_surfpanel
   ,farc_ui_umi
   ,farc_ui_umifaction
   ,farc_ui_win, farc_win_debug;

const
   mb_Left = Controls.mbLeft;
   mb_Middle = Controls.mbMiddle;
   mb_Right = Controls.mbRight;
//=======================================END OF INIT========================================

{$R *.dfm}

procedure TFCWinMain.AP_ColonyDataClick(Sender: TObject);
begin
   FCWinMain.WM_ActionPanel.Hide;
   if FCGLSCamMainViewGhost.TargetObject=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid]
   then FCMuiCDP_Display_Set(
      FC3doglCurrentStarSystem
      ,FC3doglCurrentStar
      ,FC3doglSelectedPlanetAsteroid
      ,0
      )
   else if ( FC3doglMainViewTotalSatellites>0 )
      and ( FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite] )
   then FCMuiCDP_Display_Set(
      FC3doglCurrentStarSystem
      ,FC3doglCurrentStar
      ,round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat)
      ,FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag
      );
end;

procedure TFCWinMain.AP_DockingListClick(Sender: TObject);
begin
   FCWinMain.WM_ActionPanel.Hide;
   FCMuiWin_SpUnDck_Upd(round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat));
end;

procedure TFCWinMain.AP_MissionCancelClick(Sender: TObject);
begin
   FCWinMain.WM_ActionPanel.Hide;
   FCMgMCore_Mission_Cancel( 0, round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat) );
end;

procedure TFCWinMain.AP_MissionColonizationClick(Sender: TObject);
begin
   FCWinMain.WM_ActionPanel.Hide;
   FCMgMCore_Mission_Setup(
      0
      ,round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat)
      ,tMissionColonization
      ,false
      );
end;

procedure TFCWinMain.AP_MissionInterplanetaryTransitClick(Sender: TObject);
begin
   FCWinMain.WM_ActionPanel.Hide;
   FCMgMCore_Mission_Setup(
      0
      ,round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat)
      ,tMissionInterplanetaryTransit
      ,false
      );
end;

procedure TFCWinMain.AP_OObjDataClick(Sender: TObject);
begin
   FCWinMain.WM_ActionPanel.Hide;
   if FCWM_ColDPanel.Visible
   then FCWM_ColDPanel.Hide;
   if FCGLSCamMainViewGhost.TargetObject=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid]
   then FCMuiSP_SurfaceEcosphere_Set(FC3doglCurrentStarSystem, FC3doglCurrentStar, FC3doglSelectedPlanetAsteroid, 0, false)
   else if FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite]
   then FCMuiSP_SurfaceEcosphere_Set(FC3doglCurrentStarSystem, FC3doglCurrentStar, round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat), FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag, false);
end;

procedure TFCWinMain.AP_OObjSwitch10Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=10;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 10 );
end;

procedure TFCWinMain.AP_OObjSwitch10MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[10].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 10 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch11Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=11;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 11 );
end;

procedure TFCWinMain.AP_OObjSwitch11MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[11].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 11 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch12Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=12;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 12 );
end;

procedure TFCWinMain.AP_OObjSwitch12MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[12].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 12 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch13Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=13;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 13 );
end;

procedure TFCWinMain.AP_OObjSwitch13MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[13].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 13 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch14Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=14;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 14 );
end;

procedure TFCWinMain.AP_OObjSwitch14MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[14].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 14 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch15Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=15;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 15 );
end;

procedure TFCWinMain.AP_OObjSwitch15MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[15].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 15 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch1Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=1;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 1 );
end;

procedure TFCWinMain.AP_OObjSwitch1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[1].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 1 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch2Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=2;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 2 );
end;

procedure TFCWinMain.AP_OObjSwitch2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[2].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 2 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch3Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=3;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 3 );
end;

procedure TFCWinMain.AP_OObjSwitch3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[3].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 3 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch4Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=4;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 4 );
end;

procedure TFCWinMain.AP_OObjSwitch4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[4].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 4 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch5Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=5;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 5 );
end;

procedure TFCWinMain.AP_OObjSwitch5MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[5].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 5 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch6Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=6;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 6 );
end;

procedure TFCWinMain.AP_OObjSwitch6MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[6].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 6 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch7Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=7;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 7 );
end;

procedure TFCWinMain.AP_OObjSwitch7MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[7].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 7 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch8Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=8;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 8 );
end;

procedure TFCWinMain.AP_OObjSwitch8MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[8].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 8 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.AP_OObjSwitch9Click(Sender: TObject);
begin
   if FCVdiActionPanelSatMode = 0 then
   begin
      FC3doglSelectedPlanetAsteroid:=9;
      FCMovM_OObj_SwitchTo;
   end
   else FCMovM_Sat_SwitchTo( 9 );
end;

procedure TFCWinMain.AP_OObjSwitch9MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode = 0 )
      and ( length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[9].OO_satellitesList ) > 1 )
   then FCMuiAP_Update_Satellites( 9 )
   else if ( Button = mb_Right )
      and ( FCVdiActionPanelSatMode > 0 )
   then FCMuiAP_Update_OrbitalObject;
end;

procedure TFCWinMain.CDPproductionMatrixListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiCDP_KeyProductionMatrixList_Test( Key, Shift );
end;

procedure TFCWinMain.CDPproductionMatrixListMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
   FocusControl(CDPproductionMatrixList);
end;

procedure TFCWinMain.CDPstorageListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiCDP_KeyStorageList_Test( Key, Shift );
end;

procedure TFCWinMain.CDPstorageListMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   FocusControl(CDPstorageList);
end;

procedure TFCWinMain.FCGLScadencerProgress(Sender: TObject; const deltaTime,
  newTime: Double);
var
   i,
   FCGLSCPobjIdx
   ,FCGLSCPtaskL
   ,FCGLSCPspUidx: integer;

   FCGLSCPscaleCoef
   ,FCGLSCPscaleCoef1
   ,FCGLSCPscaleCoefCur
   ,FCGLSCPcoefTimeAcc: double;
begin
   FCGLSmainView.Invalidate;
   try
      if ssLeft in FCVwinMmouseShftState then
      begin
         FCGLSsmthNavMainV.MoveAroundTarget(
            FCVwinMmousePosDumpY - FCVwinMmouseNewPosY
            ,FCVwinMmousePosDumpX - FCVwinMmouseNewPosX
            ,DelTaTime
            );
         FCGLSsmthNavMainV.AdjustDistanceToTarget(0, DelTaTime);
      end
      else if ssMiddle in FCVwinMmouseShftState
      then
      begin
         {.space unit zoom/unzoom}
         if (FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit])
            and (FC3doglMainViewTotalSpaceUnits>0)
         then
         begin
            FCGLSCPscaleCoef:=FC3doglSpaceUnitSize*240;//160;//*240;
            FCGLSCPscaleCoef1:=FC3doglSpaceUnitSize*400;//360;//*400;
            {.zoom}
            if FCGLSCamMainViewGhost.DistanceToTarget>FCGLSCPscaleCoef
            then FCGLSsmthNavMainV.AdjustDistanceToTarget(FCVwinMmousePosDumpY - FCVwinMmouseNewPosY, DelTaTime)
            {.unzoom}
            else if (FCGLSCamMainViewGhost.DistanceToTarget<FCGLSCPscaleCoef)
            and (FCVwinMmouseNewPosY>FCVwinMmousePosDumpY)
            then FCGLSsmthNavMainV.AdjustDistanceToTarget(FCVwinMmousePosDumpY - FCVwinMmouseNewPosY, DelTaTime);
            if (FCGLSCamMainViewGhost.DistanceToTarget<=FCGLSCPscaleCoef1)
               and (FCGLSCamMainViewGhost.DistanceToTarget>FCGLSCPscaleCoef)
            then FCMoglVM_SpUn_SetZoomScale;
            if (FCGLSCamMainViewGhost.DistanceToTarget>FCGLSCPscaleCoef1)
               and (FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X<>FC3doglSpaceUnitSize)
            then FCMoglVMain_SpUnits_SetInitSize(false);
         end
         {.star sprite zoom/unzoom}
         else if FCGLSCamMainViewGhost.TargetObject=FCGLSStarMain
         then
         begin
            FCGLSCPscaleCoef:=FCGLSCamMainViewGhost.TargetObject.Scale.X*3;
            if FCGLSCamMainViewGhost.DistanceToTarget>FCGLSCPscaleCoef
            then FCGLSsmthNavMainV.AdjustDistanceToTarget(FCVwinMmousePosDumpY - FCVwinMmouseNewPosY, DelTaTime)
            else if (FCGLSCamMainViewGhost.DistanceToTarget<FCGLSCPscaleCoef)
               and (FCVwinMmouseNewPosY>FCVwinMmousePosDumpY)
            then FCGLSsmthNavMainV.AdjustDistanceToTarget(FCVwinMmousePosDumpY - FCVwinMmouseNewPosY, DelTaTime);
         end
         {.satellites zoom/unzoom}
         else if ( FC3doglMainViewTotalSatellites>0 )
            and ( FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite] )
         then
         begin
            FCGLSCPscaleCoef:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].CubeSize*(78-sqrt(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].CubeSize*10000));
            if FCGLSCamMainViewGhost.DistanceToTarget>FCGLSCPscaleCoef
            then FCGLSsmthNavMainV.AdjustDistanceToTarget(FCVwinMmousePosDumpY - FCVwinMmouseNewPosY, DelTaTime)
            else if (FCGLSCamMainViewGhost.DistanceToTarget<FCGLSCPscaleCoef)
               and (FCVwinMmouseNewPosY>FCVwinMmousePosDumpY)
            then FCGLSsmthNavMainV.AdjustDistanceToTarget(FCVwinMmousePosDumpY - FCVwinMmouseNewPosY, DelTaTime);
         end
         {.all the rest zoom/unzoom}
         else if FCGLSCamMainViewGhost.TargetObject<>FCGLSStarMain
         then
         begin
            FCGLSCPscaleCoef:=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].CubeSize*3;
            if FCGLSCamMainViewGhost.DistanceToTarget>FCGLSCPscaleCoef
            then FCGLSsmthNavMainV.AdjustDistanceToTarget(FCVwinMmousePosDumpY - FCVwinMmouseNewPosY, DelTaTime)
            else if (FCGLSCamMainViewGhost.DistanceToTarget<FCGLSCPscaleCoef)
               and (FCVwinMmouseNewPosY>FCVwinMmousePosDumpY)
            then FCGLSsmthNavMainV.AdjustDistanceToTarget(FCVwinMmousePosDumpY - FCVwinMmouseNewPosY, DelTaTime);
         end;
      end
      else
      begin
         FCGLSsmthNavMainV.MoveAroundTarget(0, 0, DelTaTime);
         FCGLSsmthNavMainV.AdjustDistanceToTarget(0, DelTaTime);
      end;
      FCVwinMmousePosDumpX:=FCVwinMmouseNewPosX;
      FCVwinMmousePosDumpY:=FCVwinMmouseNewPosY;
      if FCVdiGameFlowTimer.enabled
      then
      begin
         FCMgGF_Tasks_Process;
         {.space units moving subroutine}
         FCGLSCPtaskL:=length(FCDdmtTaskListInProcess);
         if FCGLSCPtaskL>1
         then
         begin
            i:=1;
            while i<=FCGLSCPtaskL-1 do
            begin
               if not FCDdmtTaskListInProcess[i].T_inProcessData.IPD_isTaskTerminated
               then
               begin
                  FCGLSCPspUidx:=FCDdmtTaskListInProcess[i].T_controllerIndex;
                  FCGLSCPobjIdx:=FCDdgEntities[0].E_spaceUnits[FCGLSCPspUidx].SU_linked3dObject;
                  if
                     (
                        (
                           (FCDdmtTaskListInProcess[i].T_type=tMissionInterplanetaryTransit)
                           and
                              (
                                 (FCDdmtTaskListInProcess[i].T_tMITphase=mitpAcceleration)
                                 or
                                 (FCDdmtTaskListInProcess[i].T_tMITphase=mitpCruise)
                                 or
                                 (FCDdmtTaskListInProcess[i].T_tMITphase=mitpDeceleration)
                              )
                        )
                        or
                        (
                           (FCDdmtTaskListInProcess[i].T_type=tMissionColonization)
                              and (FCDdmtTaskListInProcess[i].T_tMCphase=mcpDeceleration)
                              and (FCDdgEntities[0].E_spaceUnits[FCGLSCPspUidx].SU_linked3dObject>0)
                        )
                     )
                  then
                  begin
                     {.set time acceleration}
                     case FCVdgPlayer.P_currentRealTimeAcceleration of
                        rtaX1: FCGLSCPcoefTimeAcc:=1.84;

                        rtaX2: FCGLSCPcoefTimeAcc:=3.68;

                        rtaX5: FCGLSCPcoefTimeAcc:=9.2;

                        rtaX10: FCGLSCPcoefTimeAcc:=18.4;
                     end;
                     {.set camera focus}
                     if FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FCGLSCPobjIdx]
                     then
                     begin
                        {.move the space unit}
                        FC3doglSpaceUnits[FCGLSCPobjIdx].Move(FCDdgEntities[0].E_spaceUnits[FCGLSCPspUidx].SU_3dVelocity*deltaTime*FCGLSCPcoefTimeAcc);
                        {.put the location in owned space unit datastructure}
                        FCDdgEntities[0].E_spaceUnits[FCGLSCPspUidx].SU_locationViewX:=FC3doglSpaceUnits[FCGLSCPobjIdx].Position.X;
                        FCDdgEntities[0].E_spaceUnits[FCGLSCPspUidx].SU_locationViewZ:=FC3doglSpaceUnits[FCGLSCPobjIdx].Position.Z;
                        {.set the right camera location}
                        case FCVdgPlayer.P_currentRealTimeAcceleration of
                           rtaX1: FCGLSCamMainViewGhost.AdjustDistanceToTarget(0.982-(FCDdgEntities[0].E_spaceUnits[FCGLSCPspUidx].SU_3dVelocity*0.1));

                           rtaX2: FCGLSCamMainViewGhost.AdjustDistanceToTarget(0.895-(FCDdgEntities[0].E_spaceUnits[FCGLSCPspUidx].SU_3dVelocity*0.1)); //0.851

                           rtaX5: FCGLSCamMainViewGhost.AdjustDistanceToTarget(0.807-(FCDdgEntities[0].E_spaceUnits[FCGLSCPspUidx].SU_3dVelocity*0.1));

                           rtaX10: FCGLSCamMainViewGhost.AdjustDistanceToTarget(0.72-(FCDdgEntities[0].E_spaceUnits[FCGLSCPspUidx].SU_3dVelocity*0.1));
                        end;
                        FCMoglUI_CoreUI_Update(ptuTextsOnly, ttuFocusedObject);
                     end {.if FCGLSCamMainViewGhost.TargetObject=FCV3dMVobjSpUnit[FCGLSCPobjIdx]}
                     else FC3doglSpaceUnits[FCGLSCPobjIdx].Move(FCDdgEntities[0].E_spaceUnits[FCGLSCPspUidx].SU_3dVelocity*deltaTime*FCGLSCPcoefTimeAcc);
                     FCMoglVM_OObjSpUn_ChgeScale(FCGLSCPobjIdx);
                  end; {.if (FCGtskListInProc[i].TITP_actionTp=tatpMissItransit) and (FCGtskListInProc[i].TITP_enabled)}
               end; //==END== if FCGtskListInProc[i].TITP_phaseTp<>tpTerminated ==//
               inc(i);
            end; //==END== while i<=length(FCGtskListInProc)-1 ==//
         end; {.if length(FCGtasklistInProc)>1}
      end;
   finally
      {.smooth camera transitions}
      FCV3DcamTimeSteps:=FCV3DcamTimeSteps+deltaTime;
      while FCV3DcamTimeSteps>0.005 do
      begin
         try
            if FCGLSCamMainView.TargetObject<>FCGLSCamMainViewGhost.TargetObject
            then FCGLSCamMainView.TargetObject:=FCGLSCamMainViewGhost.TargetObject;
            FCGLSCamMainView.Position.AsVector:=VectorLerp
               (
                  FCGLSCamMainView.Position.AsVector
                  ,FCGLSCamMainViewGhost.Position.AsVector
                  ,0.032 //diminish this value for a more inertial fx - initial value 0.05
                  {DEV NOTE: change this value following targeted object less than 0.05 for
                  planet 0.05 to 0.2 for aster and.}
               );
         finally
            if (FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit])
               and (FC3doglMainViewTotalSpaceUnits>0)
            then FCV3DcamTimeSteps:=FCV3DcamTimeSteps-0.001
            else FCV3DcamTimeSteps:=FCV3DcamTimeSteps-0.005;
         end;
      end;
   end;
end;

procedure TFCWinMain.FCGLSmainViewAfterRender(Sender: TObject);
var
   cpttl,
   cpcount,
   cptaskid,
   cpTPUidx: integer;
begin
   if FCVdi3DViewToInitialize
   then
   begin
      FCVdi3DViewToInitialize:=false;
      {.time frame}
      FCMgGF_TypeOfTimeFlow_Init;
      MMGameSection_Save.Enabled:=true;
      MMGameSection_SaveAndFlush.Enabled:=true;
      MMHelpSection_HelpPanel.Enabled:=true;
      FCMuiM_MessageBox_ResetState(true);
      FCMoglUI_CoreUI_Update( ptuTextsOnly, ttuTimeFlow );
//      FCMumi_Faction_Upd(uiwAllSection, true);
   end;
end;

procedure TFCWinMain.FCGLSmainViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   VMDpick: TGLCustomSceneObject;
begin
   if FCWinMain.WM_ActionPanel.Visible
   then FCWinMain.WM_ActionPanel.Hide;
   FCVwinMmousePosDumpX:=x;
   FCVwinMmousePosDumpY:=y;
   {.left mouse button}
   if  Button=mb_Left
   then
   begin
      if FCWinMain.WM_ActionPanel.Visible
      then FCWinMain.WM_ActionPanel.Hide;
      try
         FCGLScadencer.Enabled:=false;
      finally
         try
            VMDpick:=(FCGLSmainView.Buffer.GetPickedObject(x, y) as TGLHUDText);

         except
            VMDpick:=nil;
         end;
         if VMDpick<>nil then FCMoglUI_Elem_SelHelp(VMDpick.Tag);

      end;
      FCGLScadencer.Enabled:=true;
   end;
   {.right mouse button}
   if (Button=mb_Right)
      and (FCVdgPlayer.P_currentRealTimeAcceleration<>rtaPause)
      and (not FCWinMain.FCWM_CPSreportSet.Visible)
      and
      (
         (
            (FC3doglSelectedSpaceUnit>0)
            and
            (FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit])
         )
         or (
               ( FC3doglMainViewTotalSatellites>0 )
               and
               (FC3doglSelectedSatellite>0)
               and
               (FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite])
            )
         or (FCGLSCamMainViewGhost.TargetObject=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid])
         or (FCGLSCamMainViewGhost.TargetObject=FC3doglMainViewListMainOrbits[FC3doglSelectedPlanetAsteroid])
         or (FCGLSCamMainViewGhost.TargetObject=FCGLSStarMain)
      )
      and (not FCWM_MissionSettings.Visible)
   then FCMuiAP_Panel_PopupAtPos( X, Y );
   {.middle mouse button}
   if (Button=mb_Middle)
     and (FCGLSmainView.cursor=crCross)
   then FCGLSmainView.cursor:=crSizeNS
   else if (Button<>mb_Middle)
      and (FCGLSmainView.cursor=crSizeNS)
   then FCGLSmainView.cursor:=crCross;
end;

procedure TFCWinMain.FCGLSmainViewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   FCVwinMmouseShftState:=Shift;
   FCVwinMmouseNewPosX:=X;
   FCVwinMmouseNewPosY:=Y;
//   if FCWinMain.WM_ActionPanel.Visible
//   then FCWinMain.WM_ActionPanel.Hide;
   if (ssMiddle in shift)
      and (FCGLSmainView.cursor=crSizeNS)
   then
   else FCGLSmainView.cursor:=crCross;
end;

procedure TFCWinMain.FCGLSmainViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if (not FCVdiGameFlowTimer.Enabled)
      and (
            (FC3doglSelectedSpaceUnit>0)
            and
            (FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit])
            and
            (FCDdgEntities[0].E_spaceUnits[round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat)].SU_3dVelocity>0)
            )
   then FCVdiGameFlowTimer.Enabled:=true;
end;

procedure TFCWinMain.FCWMS_ButCancelClick(Sender: TObject);
begin
   FCMuiMS_Planel_Close;
end;

procedure TFCWinMain.FCWMS_ButCancelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMgMC_KeyButtons_Test(Key, Shift);
end;

procedure TFCWinMain.FCWMS_ButProceedClick(Sender: TObject);
begin
   FCMgMCore_Mission_Commit;
end;

procedure TFCWinMain.FCWMS_ButProceedKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMgMC_KeyButtons_Test(Key, Shift);
end;

procedure TFCWinMain.FCWMS_Grp_MCGColNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_MissionColonyName_Test(Key, Shift);
end;

procedure TFCWinMain.FCWMS_Grp_MCGColNameKeyPress(Sender: TObject; var Key: Char);
begin
   If sender is TLabeledEdit then
   begin
      if Key in [#8, #13, #32, #39, 'a'..'z', 'A'..'Z', '0'..'9']
      then exit
      else Key:=#0;
   end;
end;

procedure TFCWinMain.FCWMS_Grp_MCG_RMassTrackChange(Sender: TObject);
   var
      RMTCmiss: string;
begin
   if (FCWinMain.FCWM_MissionSettings.Visible)
      and ( not FCVuimsIsTrackbarProcess )
   then FCVuimsIsTrackbarProcess:=true
   else if (FCWinMain.FCWM_MissionSettings.Visible)
      and ( FCVuimsIsTrackbarProcess )
   then
   begin
      RMTCmiss:=FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet');
      if FCWinMain.FCWM_MissionSettings.Caption.Text=RMTCmiss+FCFdTFiles_UIStr_Get(uistrUI,'Mission.itransit')
      then FCMuiMS_TrackBar_Update(tMissionInterplanetaryTransit)
      else if FCWinMain.FCWM_MissionSettings.Caption.Text=RMTCmiss+FCFdTFiles_UIStr_Get(uistrUI,'Mission.coloniz')
      then FCMuiMS_TrackBar_Update(tMissionColonization);
   end;
end;

procedure TFCWinMain.FCWMS_Grp_MCG_RMassTrackKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMgMC_KeyButtons_Test(Key, Shift);
end;

procedure TFCWinMain.FCWMS_Grp_MCG_SetNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_MissionSettleName_Test(Key, Shift);
end;

procedure TFCWinMain.FCWMS_Grp_MCG_SetNameKeyPress(Sender: TObject; var Key: Char);
begin
   If sender is TLabeledEdit then
   begin
      if Key in [#8, #13, #32, #39, 'a'..'z', 'A'..'Z', '0'..'9']
      then exit
      else Key:=#0;
   end;
end;

procedure TFCWinMain.FCWM_CDPcolNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_ColName_Test(Key, Shift);
end;

procedure TFCWinMain.FCWM_CDPcolNameKeyPress(Sender: TObject; var Key: Char);
begin
   If sender is TLabeledEdit then
   begin
      if Key in [#8, #13, #32, #39, 'a'..'z', 'A'..'Z', '0'..'9']
      then exit
      else Key:=#0;
   end;
end;

procedure TFCWinMain.FCWM_CDPcsmeListAnchorClick(Sender: TObject; Node: TTreeNode;
  anchor: string);
begin
   FCMuiW_HelpTDef_Link(anchor, true);
end;

procedure TFCWinMain.FCWM_CDPcsmeListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_ColCSMev_Test(Key, Shift);
end;

procedure TFCWinMain.FCWM_CDPcwpAssignVehKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiCDP_CWPAssignVehKey_Test(Key, Shift);
end;

procedure TFCWinMain.FCWM_CDPepiChange(Sender: TObject);
begin
   if FCWinMain.FCWM_InfraPanel.Visible
   then FCWinMain.FCWM_InfraPanel.Hide;
   if FCWM_CDPepi.ActivePage=FCWM_CDPpopul
   then FCMuiCDD_Colony_Update(
      cdlDataPopulation
      ,0
      ,0
      ,0
      ,false
      ,false
      ,false
      )
   else if FCWM_CDPepi.ActivePage=FCWM_CDPstorage then
   begin
      FCMuiCDD_Colony_Update(
         cdlStorageAll
         ,0
         ,0
         ,0
         ,false
         ,false
         ,false
         );
      FCMuiCDD_Production_Update(
         plProdMatrixAll
         ,0
         ,0
         ,0
         );
   end
   else if FCWM_CDPepi.ActivePage=FCWM_CDPinfr
   then FCMuiCDD_Colony_Update(
      cdlInfrastructuresAll
      ,0
      ,0
      ,0
      ,false
      ,false
      ,false
      )
   else if FCWM_CDPepi.ActivePage=FCWM_CDPcsme
   then FCMuiCDD_Colony_Update(
      cdlCSMevents
      ,0
      ,0
      ,0
      ,false
      ,false
      ,false
      );
end;

procedure TFCWinMain.FCWM_CDPinfoTextAnchorClick(Sender: TObject; Anchor: string);
begin
   FCMuiW_HelpTDef_Link(anchor, true);
end;

procedure TFCWinMain.FCWM_CDPinfrAvailAnchorClick(Sender: TObject; Node: TTreeNode;
  anchor: string);
begin
   FCMuiW_HelpTDef_Link(anchor, true);
end;

procedure TFCWinMain.FCWM_CDPinfrAvailKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiCDP_KeyAvailInfra_Test(key, shift);
end;

procedure TFCWinMain.FCWM_CDPinfrAvailMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   IAMDinfraToken: string;

   IAMDcurrentNode
   ,IAMDrootNode: ttreenode;
begin
   IAMDinfraToken:='';
   if Button=mb_Right
   then
   begin
      IAMDcurrentNode:=THTMLTreeview(sender).Selected;
      if not IAMDcurrentNode.IsFirstNode
      then
      begin
         IAMDrootNode:=IAMDcurrentNode.Parent;
         if not IAMDrootNode.IsFirstNode
         then IAMDinfraToken:=FCFuiHTML_AnchorInAhref_Extract(IAMDcurrentNode.Text);
         FCMuiIP_AvailInfra_Setup(
            IAMDinfraToken
            ,X
            ,Y
            );
      end
      else FCMuiIP_AvailInfra_Setup(
         ''
         ,X
         ,Y
         );
   end;
end;

procedure TFCWinMain.FCWM_CDPinfrAvailMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   FocusControl(FCWM_CDPinfrAvail);
end;

procedure TFCWinMain.FCWM_CDPinfrListAnchorClick(Sender: TObject; Node: TTreeNode;
  anchor: string);
begin
   FCMuiW_HelpTDef_Link(anchor, true);
end;

procedure TFCWinMain.FCWM_CDPinfrListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiCDP_KeyInfraList_Test(key, shift);
end;

procedure TFCWinMain.FCWM_CDPinfrListMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   ILMDinfraIndex: integer;

   ILMDcurrentNode
   ,ILMDrootNode: ttreenode;
begin
{:DEV NOTES: will be reactivated in future alpha.}
   ILMDinfraIndex:=0;
   if Button=mb_Right
   then
   begin
      ILMDcurrentNode:=THTMLTreeview(sender).Selected;
      if not ILMDcurrentNode.IsFirstNode
      then
      begin
         ILMDrootNode:=ILMDcurrentNode.Parent;
         if not ILMDrootNode.IsFirstNode
         then ILMDinfraIndex:=FCFuiCDP_ListInfra_RetrieveIndex( ILMDrootNode.text, ILMDcurrentNode.Index+1);
         FCMuiIP_InfraList_Setup(
            ILMDinfraIndex
            ,X
            ,Y
            );
      end
      else FCMuiIP_InfraList_Setup(
         0
         ,X
         ,Y
         );
   end;
end;

procedure TFCWinMain.FCWM_CDPinfrListMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   FocusControl(FCWM_CDPinfrList);
end;

procedure TFCWinMain.FCWM_CDPpopListAnchorClick(Sender: TObject; Node: TTreeNode;
  anchor: string);
begin
   FCMuiW_HelpTDef_Link(anchor, true);
end;

procedure TFCWinMain.FCWM_CDPpopListCollapsed(Sender: TObject; Node: TTreeNode);
begin
   if Node.Index=1 then
   begin
      FCWM_CDPwcpEquip.Hide;
      FCWM_CDPwcpAssign.Hide;
      FCWM_CDPcwpAssignVeh.Hide;
   end;
end;

procedure TFCWinMain.FCWM_CDPpopListExpanded(Sender: TObject; Node: TTreeNode);
begin
   if Node.Index=1 then
   begin
      FCMuiCDP_WCPradio_Click(false);
      FCWM_CDPwcpEquip.Show;
   end;
end;

procedure TFCWinMain.FCWM_CDPpopListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_ColPopulation_Test(Key, Shift);
end;

procedure TFCWinMain.FCWM_CDPpopListRadioClick(Sender: TObject; Node: TTreeNode);
begin
   FCMuiCDP_WCPradio_Click(false);
end;

procedure TFCWinMain.FCWM_CDPpopTypeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_ColPopulation_Test(Key, Shift);
end;

procedure TFCWinMain.FCWM_CDPwcpAssignKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiCDP_CWPAssignKey_Test(Key, Shift);
end;

procedure TFCWinMain.FCWM_CDPwcpEquipKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiCDP_KeyCWPEquipmentList_Test( Key, Shift );
end;

procedure TFCWinMain.FCWM_ColDPanelClose(Sender: TObject);
begin
   MVG_SurfacePanel.Hide;
end;

procedure TFCWinMain.FCWM_ColDPanelEndCollapsExpand(Sender: TObject);
begin
   FCMuiSP_Panel_Relocate( false );
end;

procedure TFCWinMain.FCWM_ColDPanelEndMoveSize(Sender: TObject);
begin
   if MVG_SurfacePanel.Visible
   then FCMuiSP_Panel_Relocate( false );
end;

procedure TFCWinMain.FCWM_ColDPanelMaximize(Sender: TObject);
begin
   MVG_SurfacePanel.show;
end;

procedure TFCWinMain.FCWM_ColDPanelMinimize(Sender: TObject);
begin
   MVG_SurfacePanel.Hide;
end;

procedure TFCWinMain.FCWM_CPSRSbuttonConfirmClick(Sender: TObject);
begin
   FCMgCore_GameOver_Process( gfrCPSendOfPhase );
end;

procedure TFCWinMain.FCWM_DLP_DockListClick(Sender: TObject);
begin
   if FCWM_DLP_DockList.ItemIndex<2
   then
   begin
      FCWM_DLP_DockList.ClearSelection;
      FCWM_DLP_DockList.ItemIndex:=2;
      FCWM_DLP_DockList.Selected[2]:=true;
   end;
end;

procedure TFCWinMain.FCWM_DLP_DockListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_DockLst_Test(key, shift);
end;

procedure TFCWinMain.FCWM_DLP_DockListMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   FocusControl(FCWM_DLP_DockList);
end;

procedure TFCWinMain.FCWM_HDPhintsListClick(Sender: TObject);
begin
   FCWM_HelpPanel.BringToFront;
   FCWM_HDPhintsText.HTMLText.Clear;
   FCWM_HDPhintsText.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrEncyl, FCDBhelpTdef[FCWM_HDPhintsList.ItemIndex+1].TD_link));
end;

procedure TFCWinMain.FCWM_HDPhintsListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_HintsLst_Test(Key, Shift);
end;

procedure TFCWinMain.FCWM_HDPhintsTextAnchorClick(Sender: TObject; Anchor: string);
begin
   FCMuiW_HelpTDef_Link(anchor, true);
end;

procedure TFCWinMain.FCWM_IPconfirmButtonClick(Sender: TObject);
begin
   FCMuiIP_CABMode_Switch;
end;

procedure TFCWinMain.FCWM_IPinfraKitsClick(Sender: TObject);
begin
   FCMuiIP_InfrastructureKit_Select;
end;

procedure TFCWinMain.FCWM_IPlabelAnchorClick(Sender: TObject; Anchor: string);
begin
   FCMuiW_HelpTDef_Link(anchor, true);
end;

procedure TFCWinMain.WM_MainMenuChange(Sender: TObject; Source: TMenuItem;
  Rebuild: Boolean);
begin
   if FCWinMain.WM_ActionPanel.Visible
   then FCWinMain.WM_ActionPanel.Hide;
end;

procedure TFCWinMain.FCWM_MissionSettingsClose(Sender: TObject);
begin
   FCMuiMS_Planel_Close;
end;

procedure TFCWinMain.FCWM_MissionSettingsEndCollapsExpand(Sender: TObject);
begin
   FCMuiSP_Panel_Relocate( true );
end;

procedure TFCWinMain.FCWM_MissionSettingsEndMoveSize(Sender: TObject);
begin
   if MVG_SurfacePanel.Visible
   then FCMuiSP_Panel_Relocate( true );
end;

procedure TFCWinMain.FCWM_MissionSettingsMaximize(Sender: TObject);
begin
   MVG_SurfacePanel.show;
end;

procedure TFCWinMain.FCWM_MissionSettingsMinimize(Sender: TObject);
begin
   MVG_SurfacePanel.Hide;
end;

procedure TFCWinMain.MMDebugSection_FUGClick(Sender: TObject);
begin
   FCMfC_Initialize( true );
end;

procedure TFCWinMain.MMDebugSection_ReloadTxtFilesClick(Sender: TObject);
begin
   FCMdTfiles_UIString_Init;
   FCMuiWin_UI_LangUpd;
end;

procedure TFCWinMain.MMGameSection_ContinueClick(Sender: TObject);
begin
   FCMgCG_Core_Proceed;
end;

procedure TFCWinMain.MMGameSection_SaveAndFlushClick(Sender: TObject);
begin
   FCMdFSG_Game_SaveAndFlushOther;
end;

procedure TFCWinMain.MMGameSection_LoadSavedClick(Sender: TObject);
begin
   FCMuiW_WinSavedGames_Raise;
end;

procedure TFCWinMain.MMGameSection_NewClick(Sender: TObject);
begin
   FCMuiW_WinNewGame_Raise;
end;

procedure TFCWinMain.MMGameSection_QuitClick(Sender: TObject);
begin
   FCWinMain.Close;
   {.DEV NOTE: add core quit routine}
end;

procedure TFCWinMain.MMGameSection_SaveClick(Sender: TObject);
begin
   {.prevent the game save if the tasks to process are initialized ( fcwinmain.FCGLScadencer.Enabled=false).}
   if fcwinmain.FCGLScadencer.Enabled
   then FCMdFSG_Game_Save;
end;

procedure TFCWinMain.MMHelpSection_AboutClick(Sender: TObject);
begin
   FCMuiW_WinAbout_Raise;
end;

procedure TFCWinMain.MMHelpSection_HelpPanelClick(Sender: TObject);
begin
   if FCWM_HelpPanel.Visible
   then
   begin
      if FCWinMain.FCWM_HelpPanel.Collaps
      then FCWinMain.FCWM_HelpPanel.Collaps:=false
      else if not FCWinMain.FCWM_HelpPanel.Collaps
      then FCWinMain.FCWM_HelpPanel.Collaps:=true;
   end
   else if (FCWinMain.WM_MainViewGroup.Visible)
      and (not FCWinMain.FCWM_HelpPanel.Visible)
   then
   begin
      FCWinMain.FCWM_HelpPanel.Show;
      if FCWinMain.FCWM_HelpPanel.Collaps
      then FCWinMain.FCWM_HelpPanel.Collaps:=false;
      FCWinMain.FCWM_HelpPanel.BringToFront;
   end;
end;

procedure TFCWinMain.MMOptionSection_PLS_LocationHelpClick(Sender: TObject);
begin
   if FCVdiLocStoreHelpPanel
   then FCVdiLocStoreHelpPanel:=false
   else if not FCVdiLocStoreHelpPanel
   then FCVdiLocStoreHelpPanel:=true;
   FCMdF_ConfigurationFile_Save(false);
   FCMuiW_UI_Initialize(mwupMenuLoc);
end;

procedure TFCWinMain.MMOptionSection_PLS_LocationViabilityObjectivesClick(Sender: TObject);
begin
   if FCVdiLocStoreCPSobjPanel
   then FCVdiLocStoreCPSobjPanel:=false
   else if not FCVdiLocStoreCPSobjPanel
   then FCVdiLocStoreCPSobjPanel:=true;
   FCMdF_ConfigurationFile_Save(false);
   FCMuiW_UI_Initialize(mwupMenuLoc);
end;

procedure TFCWinMain.MMOptionSection_RealtimeTunrBasedSwitchClick(Sender: TObject);
begin
   FCMgGF_TypeOfTimeFlow_SwitchMode;
end;

procedure TFCWinMain.MMOptionsSection_LS_ENClick(Sender: TObject);
begin
   if FCVdiLanguage<>'EN' then
   begin
      FCVdiLanguage:='EN';
      FCMuiWin_UI_LangUpd;
   end;
end;

procedure TFCWinMain.MMOptionsSection_LS_FRClick(Sender: TObject);
begin
   if FCVdiLanguage<>'FR' then
   begin
      FCVdiLanguage:='FR';
      FCMuiWin_UI_LangUpd;
   end;
end;

procedure TFCWinMain.MMOptionsSection_LS_SPClick(Sender: TObject);
begin
   if FCVdiLanguage<>'SP' then
   begin
      FCVdiLanguage:='SP';
      FCMuiWin_UI_LangUpd;
   end;
end;

procedure TFCWinMain.MMOptionSection_STS_1024Click(Sender: TObject);
begin
   FCMoglInit_StdText_Set(false, false);
end;

procedure TFCWinMain.MMOptionSection_STS_2048Click(Sender: TObject);
begin
   FCMoglInit_StdText_Set(true, false);
end;

procedure TFCWinMain.MMOptionSection_WideScreenBckgClick(Sender: TObject);
begin
   if FCVdiWinMainWideScreen
   then FCVdiWinMainWideScreen:=false
   else if not FCVdiWinMainWideScreen
   then FCVdiWinMainWideScreen:=true;
   FCMuiW_BackgroundPicture_Update;
end;

procedure TFCWinMain.FCWM_MsgeBoxCaptionDBlClick(Sender: TObject);
begin
   if not FCWinMain.FCWM_MissionSettings.Visible
   then
   begin
      if FCWM_MsgeBox.Collaps
      then
      begin
         FCWM_MsgeBox.Collaps:=false;
         FCWM_MsgeBox.Height:=FCWinMain.Height div 6;
         FCWM_MsgeBox.Top:=WM_MainViewGroup.Height-(FCWM_MsgeBox.Height+2);
      end
      else if not FCWM_MsgeBox.Collaps
      then FCMuiM_MessageBox_ResetState(true);
   end;
end;

procedure TFCWinMain.FCWM_MsgeBox_ListClick(Sender: TObject);
begin
   FCMuiM_MessageDesc_Upd;
end;

procedure TFCWinMain.FCWM_MsgeBox_ListDblClick(Sender: TObject);
begin
   if FCWM_MsgeBox.Tag=0
   then FCFuiM_MessageBox_Expand
   else if FCWM_MsgeBox.Tag=1
   then
   begin
      FCWM_MsgeBox_Desc.Visible:=False;
      FCMuiM_MessageBox_ResetState(true);
   end;
end;

procedure TFCWinMain.FCWM_MsgeBox_ListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_MsgBoxList_Test(Key, Shift);
end;

procedure TFCWinMain.FCWM_PopMenFocusedObjPopup(Sender: TObject);
begin
//   if  FCWM_PopMenFocusedObj.Tag=1
//   then
//   begin
//      FCWM_PopMenFocusedObj.Tag:=0;
//      FCMgTFlow_FlowState_Set(tphTac);
//   end
//   else if  FCWM_PopMenFocusedObj.Tag=0
//   then
//   begin
//      FCWM_PopMenFocusedObj.Tag:=1;
//      FCMgTFlow_FlowState_Set(tphPAUSE);
//   end;
end;

procedure TFCWinMain.SP_AutoUpdateCheckKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_WinMain_Test(Key, Shift);
end;

procedure TFCWinMain.SP_RegionSheetMouseEnter(Sender: TObject);
   var
      Region: integer;
begin
   Region:=FCFuiSP_VarRegionSelected_Get;
   if Region>0 then
   begin
      FCMuiSP_RegionDataPicture_Update( Region, false );
      FCWinMain.SP_SD_SurfaceSelected.BringToFront
   end;
end;

procedure TFCWinMain.SP_ResourceSurveyCommitClick(Sender: TObject);
begin
   FCMuiPS_Panel_Show( psResources, false );
end;

procedure TFCWinMain.SP_ResourceSurveyShowDetailsClick(Sender: TObject);
begin
   FCMuiPS_Panel_ShowDetails;
end;

procedure TFCWinMain.SP_SurfaceDisplayHotSpotEnter(Sender: TObject; HotSpot: THotSpot);
begin
   FCMuiSP_RegionDataPicture_Update(HotSpot.ID, false);
end;

procedure TFCWinMain.SP_SurfaceDisplayMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   SP_SD_SurfaceSelector.Refresh;
end;

procedure TFCWinMain.SP_SD_SurfaceSelectedMouseEnter(Sender: TObject);
begin
   SP_SD_SurfaceSelector.BringToFront;
   FCMuiSP_RegionDataPicture_Update(FCFuiSP_VarRegionSelected_Get, false);
end;

procedure TFCWinMain.SP_SD_SurfaceSelectorClick(Sender: TObject);
var
   SPSSCcurrSettlement: integer;
begin
   SPSSCcurrSettlement:=0;
   if (FCWinMain.FCWM_MissionSettings.Visible)
      and (FCDmcCurrentMission[0].T_type=tMissionColonization) then
   begin
      FCMuiSP_VarRegionSelected_Update;
      FCRmcCurrentMissionCalculations.CMC_regionOfDestination:=FCFuiSP_VarRegionSelected_Get;
      if not FCWinMain.FCWMS_Grp_MCGColName.Visible
      then
      begin
         SPSSCcurrSettlement:=FCFgC_Settlement_GetIndexFromRegion(
            0
            ,FCRmcCurrentMissionCalculations.CMC_colonyAlreadyExisting
            ,FCRmcCurrentMissionCalculations.CMC_regionOfDestination
            );
         if SPSSCcurrSettlement=0
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_SetType.Show;
            FCWinMain.FCWMS_Grp_MCG_SetName.Show;
         end
         else if SPSSCcurrSettlement>0
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_SetType.Hide;
            FCWinMain.FCWMS_Grp_MCG_SetName.Hide;
         end;
      end
      else if FCWinMain.FCWMS_Grp_MCGColName.Visible
      then
      begin
         FCWinMain.FCWMS_Grp_MCG_SetType.Show;
         FCWinMain.FCWMS_Grp_MCG_SetName.Show;
      end;
      FCMuiMS_ColonizationInterface_UpdateRegionSelection(FCRmcCurrentMissionCalculations.CMC_regionOfDestination);
   end
   {:DEV NOTES: update FCMuiCDD_Colony_Update in accordance.}
   else if ( FCWinMain.FCWM_ColDPanel.Visible )
      and ( FCFuiSP_VarIsResourcesSurveyOK_Get ) then
   begin
      FCMuiSP_VarRegionSelected_Update;
      FCMuiSP_SurfaceSelected_Update( true );
//      FCWinMain.SP_ResourceSurveyCommit.Show.;
      if ( FCWinMain.MVG_PlanetarySurveyPanel.Visible )
         and ( FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psTitleResources' ) )
      then FCMuiPS_Panel_Show( psResources, true )
      else if ( FCWinMain.MVG_PlanetarySurveyPanel.Visible )
      then FCMuiPS_Panel_Show( psResources, false );
   end
   else if ( FCWinMain.FCWM_ColDPanel.Visible )
      and ( FCFuiSP_VarIsResourcesSurveyInProcess_Get ) then
   begin
      FCMuiSP_VarRegionSelected_Update;
      FCMuiSP_SurfaceSelected_Update( true );
      if FCWinMain.MVG_PlanetarySurveyPanel.Visible
      then FCMuiPS_Panel_ShowDetails;
   end
   else if FCWinMain.MVG_PlanetarySurveyPanel.Visible
   then FCWinMain.MVG_PlanetarySurveyPanel.Hide;
end;

procedure TFCWinMain.FCWM_UMIFac_ColoniesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_UMIFacCol_Test(Key, shift);
end;

procedure TFCWinMain.FCWM_UMIFac_TabShChange(Sender: TObject);
begin
   FCMuiUMI_CurrentTab_Update( true, true );
end;

procedure TFCWinMain.FCWM_UMIFSh_AFlistAnchorClick(Sender: TObject; index: Integer;
  anchor: string);
begin
   FCMuiW_HelpTDef_Link(anchor, true);
end;

procedure TFCWinMain.FCWM_UMIFSh_AFlistClick(Sender: TObject);
begin
   {.these conditions are only for additional security and avoid to trigger calculations when it's not required}
   if (FCWinMain.FCWM_UMI.Visible)
      and (not FCWinMain.FCWM_UMI.Collaps)
      and (FCWinMain.FCWM_UMI_TabSh.ActivePage=FCWinMain.FCWM_UMI_TabShFac)
      and (FCWinMain.FCWM_UMIFac_TabSh.ActivePage=FCWinMain.FCWM_UMIFac_TabShSPMpol)
   then FCMuiUMIF_PolicyEnforcement_Update;
end;

procedure TFCWinMain.FCWM_UMIFSh_AFlistKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_UMIFacAFL_Test(Key, Shift);
end;

procedure TFCWinMain.FCWM_UMIFSh_SPMadminAnchorClick(Sender: TObject; Node: TTreeNode;
  anchor: string);
begin
   FCMuiW_HelpTDef_Link(anchor, true);
end;

procedure TFCWinMain.FCWM_UMIFSh_SPMsocKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_UMIFacSPM_Test(Key, Shift);
end;

procedure TFCWinMain.FCWM_UMIMaximize(Sender: TObject);
begin
   FCWM_UMI.Constraints.MinWidth:=FCVdiUMIconstraintWidth;
   FCWM_UMI.Constraints.MinHeight:=FCVdiUMIconstraintHeight;
end;

procedure TFCWinMain.FCWM_UMIMinimize(Sender: TObject);
begin
   FCWM_UMI.Constraints.MinWidth:=0;
   FCWM_UMI.Constraints.MinHeight:=0;
end;

procedure TFCWinMain.FCWM_UMIResize(Sender: TObject);
begin
   if ( FCWM_UMI.Visible )
      and ( not FCWM_UMI.Collaps )
   then FCMuiUMI_CurrentTab_Update( false, true );
end;

procedure TFCWinMain.FCWM_UMISh_CEFcommitClick(Sender: TObject);
begin
   FCMgSPM_PolicyEnf_Confirm;
end;

procedure TFCWinMain.FCWM_UMISh_CEFenforceClick(Sender: TObject);
begin
   FCMgSPM_PolicyEnf_Process(0);
end;

procedure TFCWinMain.FCWM_UMISh_CEFretireClick(Sender: TObject);
begin
   FCMgSPM_PolicyEnf_Retire;
end;

procedure TFCWinMain.FCWM_UMI_TabShChange(Sender: TObject);
begin
   FCMuiUMI_CurrentTab_Update( true, true );
end;

procedure TFCWinMain.FormCreate(Sender: TObject);
var
   FClocalPath: widestring;
   FCwide: pWideChar;
   FCansi: PAnsiChar;
   hours, mins, secs, milliSecs : Word;
begin
   {.core settings}
   FCVisFARCclosing:=false;
   FCVdiFormat.DecimalSeparator:='.';
   Randomize;
   {.set the paths}
   FCVdiPathGame:=ExtractFilePath(Application.ExeName);
   FCVdiPathConfigDir:=FCFcFunc_WinFolders_GetMyDocs(false);
   FCVdiPathConfigFile:=FCVdiPathConfigDir+'config.xml';
   {.initialize some global data and acces to the configuration file}
	FCVdiPathResourceDir:=FCVdiPathGame+'_RSRC\';
	FCVdiPathXML:=FCVdiPathGame+'_XMLD\';
   try
      FCMdi_Data_Initialization;
   finally
      {.local fonts and user's interface initialization}
      FClocalPath:=FCVdiPathResourceDir+'fnt\DejaVuSans.ttf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;

      FClocalPath:=FCVdiPathResourceDir+'fnt\DejaVuSansCondensed.ttf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;

      FClocalPath:=FCVdiPathResourceDir+'fnt\disco___.ttf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;

      FClocalPath:=FCVdiPathResourceDir+'fnt\Existence-Light.otf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;

      FClocalPath:=FCVdiPathResourceDir+'fnt\FrancophilSans.ttf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;

      FClocalPath:=FCVdiPathResourceDir+'fnt\Interdimensional.ttf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;

      FCMuiW_UI_Initialize(mwupAll);
	end;
	FCVdiWinMainAllowUpdate:=true;
   {.initialize the game timer}
   FCVdiGameFlowTimer:= TgtTimer.Create(Self);
   FCVdiGameFlowTimer.OnTimer := InternalOnGameTimer;
   FCVdiGameFlowTimer.Interval:=1000;
   FCVdiGameFlowTimer.Enabled := False;
   WM_MainViewGroup.Visible:=false;
end;

procedure TFCWinMain.FormDestroy(Sender: TObject);
var
   FDlocalPath: widestring;

   FDwide: PWideChar;
begin
   {.disable timer and threads}
   FCGLScadencer.Enabled:=false;
   if assigned (FCVdiGameFlowTimer)
   then
   begin
      FCVdiGameFlowTimer.Enabled:=false;
      FCVdiGameFlowTimer.Free;
   end;
   {.windows switchs}
   FCVisFARCclosing:=true;
   FCVdiWinMainAllowUpdate:=false;
   {.store main window location}
	FCMuiW_MainWindow_StoreLocSiz;
   {.free cps}
   if assigned (FCcps) //to remove, duplicate code with free()
   then FCcps.Free;
   {.disable 3d}
   FCGLSmainView.Enabled:=false;
   FCV3DcamTimeSteps:=0;
   SetLength(FC3doglObjectsGroups,0);
   SetLength(FC3doglPlanets,0);
   SetLength(FC3doglAtmospheres,0);
   SetLength(FC3doglAsteroids,0);
   SetLength(FC3doglSpaceUnits,0);
   SetLength(FC3doglSatellitesObjectsGroups,0);
   SetLength(FC3doglSatellitesPlanet,0);
   SetLength(FC3doglSatellitesAtmospheres,0);
   SetLength(FC3doglSatellitesAsteroids,0);
   FreeAndNil(FCGLSsmthNavMainV);
   FCGLSRootMain.Objects.DeleteChildren;
   if assigned(FC3doglMaterialLibraryStandardPlanetTextures)  //to remove, duplicate code with free()
   then FC3doglMaterialLibraryStandardPlanetTextures.Free;
   {.disable XML components}
   FCXMLcfg.Active:=false;
   FCXMLdbFac.Active:=false;
   FCXMLdbInfra.Active:=false;
   FCXMLdbProducts.Active:=false;
   FCXMLdbSCraft.Active:=false;
   FCXMLdbSPMi.Active:=false;
   FCXMLdbTechnosciences.Active:=false;
   FCXMLdbUniv.Active:=false;
   FCXMLsave.Active:=false;
   FCXMLtxtCredits.Active:=false;
   FCXMLtxtUI.Active:=false;
   FCXMLtxtEncy.Active:=false;
   {.free memory streams}
   FCMdTF_MemoryStreams_free;
   FDlocalPath:=FCVdiPathResourceDir+'fnt\DejaVuSans.ttf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
   FDlocalPath:=FCVdiPathResourceDir+'fnt\DejaVuSansCondensed.ttf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
   FDlocalPath:=FCVdiPathResourceDir+'fnt\disco___.ttf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
   FDlocalPath:=FCVdiPathResourceDir+'fnt\Existence-Light.otf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
   FDlocalPath:=FCVdiPathResourceDir+'fnt\FrancophilSans.ttf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
   FDlocalPath:=FCVdiPathResourceDir+'fnt\Interdimensional.ttf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   PostMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
end;

procedure TFCWinMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   FCMuiK_WinMain_Test(Key, Shift);
end;

procedure TFCWinMain.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
   if FCWinMain.WM_ActionPanel.Visible
   then FCWinMain.WM_ActionPanel.Hide;
   FCGLSCamMainViewGhost.AdjustDistanceToTarget(Power(1.5, WheelDelta/-120));
end;

procedure TFCWinMain.FormResize(Sender: TObject);
{:Purpose: during form resize.
    Additions:
      -2012Dec16- *add: hide the action panel if it is visible.
      -2010Apr07- *fix: message box is correctly updated.
      -2009Oct08- *add about window update.
      -2009Oct08- *add mission setup window update.
}
var test: integer;
begin
   if not FCVisFARCclosing then UpdUI(false);
   if FCWinMain.WM_ActionPanel.Visible
   then FCWinMain.WM_ActionPanel.Hide;
   test:=FCWM_UMI_TabSh.ActivePageIndex;
   FCWM_UMI_TabSh.ActivePageIndex:=1;
   FCWM_UMI_TabSh.ActivePageIndex:=test;
//   GLCamera1.FocalLength:=ClientWidth*0.25;
end;

procedure TFCWinMain.InternalOnGameTimer(Sender: TObject);
begin
   FCMgGF_GameTimer_Process;
end;

procedure TFCWinMain.PSP_CommitClick(Sender: TObject);
begin
   FCMuiPS_ExpeditionCommit;
end;

procedure TFCWinMain.PSP_ProductsListAnchorClick(Sender: TObject; Node: TTreeNode;
  anchor: string);
begin
   if anchor='vehiclesRESremmax'
   then FCMuiPS_VehiclesSetup_RemMax( psResources )
   else if anchor='vehiclesRESrem'
   then FCMuiPS_VehiclesSetup_Rem( psResources )
   else if anchor='vehiclesRESadd'
   then FCMuiPS_VehiclesSetup_Add( psResources )
   else if anchor='vehiclesRESaddmax'
   then FCMuiPS_VehiclesSetup_AddMax( psResources );
end;

procedure TFCWinMain.PSP_ProductsListCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
begin
   AllowCollapse:=false;
end;

procedure TFCWinMain.WMExitSizeMove(var Message: TMessage) ;
begin
   if FCWinMain.WM_ActionPanel.Visible
   then FCWinMain.WM_ActionPanel.Hide;
   if not FCVisFARCclosing then UpdUI(false);
//   if not FCVisFARCclosing
//   then UpdUI(true);
end;

procedure TFCWinMain.WMMaximized(var Message: TMessage) ;
begin
end;

procedure TFCWinMain.WM_ActionPanelClose(Sender: TObject);
begin
   WM_ActionPanel.Hide;
end;

procedure TFCWinMain.UpdUI(UUIwinOnly: boolean);
begin
   {.save main window location and size}
   if FCVdiWinMainAllowUpdate
   then FCMuiW_MainWindow_StoreLocSiz;
   {.update about window}
//   FCMuiW_UI_Initialize(mwupSecwinAbout);
   {.update new game setting window}
//   FCMuiW_UI_Initialize(mwupSecWinNewGSetup);
   if not UUIwinOnly
   then
   begin
      {.update font sizes if needed}
      FCMuiW_UI_Initialize(mwupFontAll);

      {.update 3d main view frame and all childs}
      if FCVdi3DViewRunning //WM_MainViewGroup.Visible
      then
      begin
         {.relocate and/or resize the message box}
      FCMuiW_UI_Initialize(mwupMsgeBox);
         {.set main camera}
         gluPerspective(FCGLSCamMainViewGhost.FocalLength, width/height, 0.001, FCGLSCamMainViewGhost.DepthOfView);
         {.relocate and change font size of all hud user's interface objects}
         FCMoglUI_CoreUI_Update(ptuLocationsOnly, ttuAll);
         FCMuiM_MessageBox_ResetState(true);
      end;
   end;
end;

end.
