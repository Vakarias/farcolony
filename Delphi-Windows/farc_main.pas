{=====(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved================

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: core unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2012, Jean-Francois Baconnet

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
      FCWM_MainMenu: TMainMenu;
      FCWM_MMenu_Game: TMenuItem;
      FCWM_MMenu_G_New: TMenuItem;
      FCWM_MMenu_G_Quit: TMenuItem;
      FCWM_MMenu_Options: TMenuItem;
      FCWM_MMenu_O_Lang: TMenuItem;
      FCWM_MMenu_O_L_FR: TMenuItem;
      FCWM_MMenu_Help: TMenuItem;
      FCWM_MMenu_H_About: TMenuItem;
      FCWM_MMenu_O_L_EN: TMenuItem;
      FCWM_BckgImage: TImage32;
      FCWM_3dMainGrp: TAdvGroupBox;
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
      FCWM_PopMenFocusedObj: TAdvPopupMenu;
      FCWM_PMFO_Header_SpUnitOObj: TMenuItem;
      FCWM_PMFO_MissCancel: TMenuItem;
      FCWM_PMFO_MissITransit: TMenuItem;
      FCWM_MenuStyle1: TAdvMenuStyler;
    FCWM_PMFOoobjData: TMenuItem;
      FCWM_PMFO_Header_Travel: TMenuItem;
      FCWM_MsgeBox: TAdvPanel;
      FCWM_MsgeBox_Desc: THTMLabel;
      FCWM_MsgeBox_List: THTMListBox;
      FCGLSHUDgameTimePhase: TGLHUDText;
      FCXMLsave: TXMLDocument;
      FCWM_MMenu_G_Cont: TMenuItem;
      N1: TMenuItem;
      FCWM_MMenu_G_Save: TMenuItem;
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
      FCWM_MMenu_O_WideScr: TMenuItem;
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
      FCWM_HPdPad_KeysTxt: THTMLabel;
      FCWM_MMenu_O_TexR: TMenuItem;
      FCWM_MMenu_O_TR_1024: TMenuItem;
      FCWM_MMenu_O_TR_2048: TMenuItem;
      FCWM_MMenu_H_HPanel: TMenuItem;
      FCWM_SurfPanel: TAdvPanel;
      FCWM_SP_DataSheet: TAdvPageControl;
      FCWM_SPShEcos_Lab: THTMLabel;
      FCWM_SP_Surface: THotSpotImage;
      FCWM_SP_SPicFrm: TAdvGroupBox;
      FCWM_SP_LDatFrm: TAdvGroupBox;
      FCWM_SP_RDatFrm: TAdvGroupBox;
      FCWM_SP_LDat: THTMLabel;
      FCWM_SP_RDat: THTMLabel;
      FCWM_SP_SPic: TImage32;
      FCWM_MMenu_DebTools: TMenuItem;
      FCWM_RegTerrLib: TBitmap32List;
      FCWM_SP_SurfSel: THTMLabel;
      FCWM_SP_ShReg: TAdvTabSheet;
      FCWM_SPShReg_Lab: THTMLabel;
      FCWM_SP_AutoUp: TCheckBox;
      FCGLSHUDcpsCVS: TGLHUDText;
      FCGLSHUDcpsCVSLAB: TGLHUDText;
      FCGLSHUDcpsCredL: TGLHUDText;
      FCGLSFontCPSData: TGLWindowsBitmapFont;
      FCGLSHUDcpsTlft: TGLHUDText;
      FCGLSHUDspunDockd: TGLHUDSprite;
      FCGLSHUDspunDockdDat: TGLHUDText;
      FCWM_PMFO_DList: TMenuItem;
      FCWM_DockLstPanel: TAdvPanel;
    FCWM_DLP_DockList: THTMListBox;
    FCWM_PMFO_HeaderSpecMiss: TMenuItem;
    FCWM_PMFO_MissColoniz: TMenuItem;
    FCXMLdbInfra: TXMLDocument;
    FCWM_MMenu_O_Loc: TMenuItem;
    FCWM_MMenu_O_LocHelp: TMenuItem;
    FCWM_MMenu_O_LocVObj: TMenuItem;
    FCWM_MMenu_DTFUG: TMenuItem;
    FCWM_ColDPanel: TAdvPanel;
    FCWM_CDPinfo: TAdvGroupBox;
    FCWM_CDPinfoText: THTMLabel;
    FCWM_CDPepi: TAdvPageControl;
    FCWM_CDPcsme: TAdvTabSheet;
    FCWM_CDPinfr: TAdvTabSheet;
    FCWM_PMFOcolfacData: TMenuItem;
    FCWM_CDPpopList: THTMLTreeview;
    FCWM_CDPcsmeList: THTMLTreeview;
    FCWM_HPDPhints: TAdvTabSheet;
    FCWM_HDPhintsList: THTMListBox;
    FCWM_HDPhintsText: THTMLabel;
    FCWM_CDPcolName: TLabeledEdit;
    FCGLSHUDcolplyr: TGLHUDSprite;
    FCGLSHUDcolplyrName: TGLHUDText;
    FCXMLdbSPMi: TXMLDocument;
    FCWM_MMenu_G_FlushOld: TMenuItem;
    FCWM_UMI: TAdvPanel;
    FCWM_UMI_TabSh: TAdvPageControl;
    FCWM_UMI_TabShUniv: TAdvTabSheet;
    HTMLabel1: THTMLabel;
    FCWM_UMI_TabShFac: TAdvTabSheet;
    FCWM_UMI_FacData: THTMLabel;
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
    FCWM_MMenu_DTreloadTfiles: TMenuItem;
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
      procedure FormCreate(Sender: TObject);
      procedure FormResize(Sender: TObject);
      procedure FCWM_MMenu_G_QuitClick(Sender: TObject);
      procedure FCWM_MMenu_O_L_FRClick(Sender: TObject);
      procedure FCWM_MMenu_O_L_ENClick(Sender: TObject);
      procedure FCWM_MMenu_G_NewClick(Sender: TObject);
      procedure FCGLScadencerProgress(Sender: TObject; const deltaTime, newTime: Double);
      procedure FCGLSmainViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
      procedure FCGLSmainViewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure FCWM_MsgeBoxCaptionDBlClick(Sender: TObject);
      procedure FCWM_MsgeBox_ListClick(Sender: TObject);
      procedure FCWM_MsgeBox_ListDblClick(Sender: TObject);
      procedure FCWM_MsgeBox_ListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure FCWM_PMFO_MissITransitClick(Sender: TObject);
      procedure FCWM_MMenu_H_AboutClick(Sender: TObject);
      procedure FCWM_MMenu_G_ContClick(Sender: TObject);
      procedure FCWM_PopMenFocusedObjPopup(Sender: TObject);
      procedure FCWM_MMenu_G_SaveClick(Sender: TObject);
      procedure FCGLSmainViewAfterRender(Sender: TObject);
      procedure FCWM_MMenu_O_WideScrClick(Sender: TObject);
      procedure FCWM_PMFO_MissCancelClick(Sender: TObject);
      procedure FCWM_MMenu_O_TR_1024Click(Sender: TObject);
      procedure FCWM_MMenu_O_TR_2048Click(Sender: TObject);
      procedure FCWM_MMenu_H_HPanelClick(Sender: TObject);
      procedure FCWM_PMFOoobjDataClick(Sender: TObject);
      procedure FCWM_SP_SurfaceHotSpotEnter(Sender: TObject; HotSpot: THotSpot);
      procedure FCWM_SP_SurfaceMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure FCWM_SP_SurfSelClick(Sender: TObject);
      procedure FCWM_SP_AutoUpKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure FCWM_PMFO_DListClick(Sender: TObject);
    procedure FCWM_DLP_DockListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWM_DLP_DockListMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FCWM_DLP_DockListClick(Sender: TObject);
    procedure FCWM_PMFO_MissColonizClick(Sender: TObject);
    procedure FCGLSmainViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FCWM_MMenu_O_LocVObjClick(Sender: TObject);
    procedure FCWM_MMenu_O_LocHelpClick(Sender: TObject);
    procedure FCWM_MMenu_DTFUGClick(Sender: TObject);
    procedure FCWM_PMFOcolfacDataClick(Sender: TObject);
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
    procedure FCWM_MMenu_G_FlushOldClick(Sender: TObject);
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
    procedure FCWM_MMenu_DTreloadTfilesClick(Sender: TObject);
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
   ,farc_data_files
   ,farc_data_filesavegame
   ,farc_data_game
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_game_colony
   ,farc_fug_com
   ,farc_game_cps
   ,farc_game_micolonize
   ,farc_game_missioncore
   ,farc_game_contg
   ,farc_game_infra
   ,farc_game_newg
   ,farc_game_gameflow
   ,farc_game_spm
   ,farc_ogl_init
   ,farc_ogl_viewmain
   ,farc_ogl_ui
   ,farc_ui_coldatapanel
   ,farc_ui_html
   ,farc_ui_infrapanel
   ,farc_ui_keys
   ,farc_ui_msges
   ,farc_ui_surfpanel
   ,farc_ui_umi
   ,farc_ui_win
   ,farc_win_missset;

const
   mb_Left = Controls.mbLeft;
   mb_Middle = Controls.mbMiddle;
   mb_Right = Controls.mbRight;
//=======================================END OF INIT========================================

{$R *.dfm}

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
         if (FCGLSCamMainViewGhost.TargetObject=FC3DobjSpUnit[FCV3DselSpU])
            and (FCV3DttlSpU>0)
         then
         begin
            FCGLSCPscaleCoef:=FCV3DspUnSiz*160;//*240;
            FCGLSCPscaleCoef1:=FCV3DspUnSiz*360;//*400;
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
               and (FC3DobjSpUnit[FCV3DselSpU].Scale.X<>FCV3DspUnSiz)
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
         else if FCGLSCamMainViewGhost.TargetObject=FC3DobjSatGrp[FCV3DselSat]
         then
         begin
            FCGLSCPscaleCoef:=FC3DobjSatGrp[FCV3DselSat].CubeSize*(78-sqrt(FC3DobjSatGrp[FCV3DselSat].CubeSize*10000));
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
            FCGLSCPscaleCoef:=FC3DobjGrp[FCV3DselOobj].CubeSize*3;
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
      if FCGtimeFlow.enabled
      then
      begin
         FCMgGFlow_Tasks_Process;
         {.space units moving subroutine}
         FCGLSCPtaskL:=length(FCGtskListInProc);
         if FCGLSCPtaskL>1
         then
         begin
            i:=1;
            while i<=FCGLSCPtaskL-1 do
            begin
               if FCGtskListInProc[i].TITP_phaseTp<>tpTerminated
               then
               begin
                  FCGLSCPspUidx:=FCGtskListInProc[i].TITP_ctldIdx;
                  FCGLSCPobjIdx:=FCentities[0].E_spU[FCGLSCPspUidx].SUO_3dObjIdx;
                  if
                     (
                        (
                           (FCGtskListInProc[i].TITP_actionTp=tatpMissItransit)
                           and
                              (
                                 (FCGtskListInProc[i].TITP_phaseTp=tpAccel)
                                 or
                                 (FCGtskListInProc[i].TITP_phaseTp=tpCruise)
                                 or
                                 (FCGtskListInProc[i].TITP_phaseTp=tpDecel)
                              )
                        )
                        or
                        (
                           (FCGtskListInProc[i].TITP_actionTp=tatpMissColonize)
                              and (FCGtskListInProc[i].TITP_phaseTp=tpDecel)
                              and (FCentities[0].E_spU[FCGLSCPspUidx].SUO_3dObjIdx>0)
                        )
                     )
                  then
                  begin
                     {.set time acceleration}
                     case FCRplayer.P_timePhse of
                        tphTac: FCGLSCPcoefTimeAcc:=1.84;
                        tphMan: FCGLSCPcoefTimeAcc:=3.68;
                        tphSTH: FCGLSCPcoefTimeAcc:=18.4;
                     end;
                     {.set camera focus}
                     if FCGLSCamMainViewGhost.TargetObject=FC3DobjSpUnit[FCGLSCPobjIdx]
                     then
                     begin
                        {.move the space unit}
                        FC3DobjSpUnit[FCGLSCPobjIdx].Move(FCentities[0].E_spU[FCGLSCPspUidx].SUO_3dmove*deltaTime*FCGLSCPcoefTimeAcc);
                        {.put the location in owned space unit datastructure}
                        FCentities[0].E_spU[FCGLSCPspUidx].SUO_locStarX:=FC3DobjSpUnit[FCGLSCPobjIdx].Position.X;
                        FCentities[0].E_spU[FCGLSCPspUidx].SUO_locStarZ:=FC3DobjSpUnit[FCGLSCPobjIdx].Position.Z;
                        {.set the right camera location}
                        case FCRplayer.P_timePhse of
                           tphTac: FCGLSCamMainViewGhost.AdjustDistanceToTarget(0.982-(FCentities[0].E_spU[FCGLSCPspUidx].SUO_3dmove*0.1));
                           tphMan: FCGLSCamMainViewGhost.AdjustDistanceToTarget(0.851-(FCentities[0].E_spU[FCGLSCPspUidx].SUO_3dmove*0.1));
                           tphSTH: FCGLSCamMainViewGhost.AdjustDistanceToTarget(0.72-(FCentities[0].E_spU[FCGLSCPspUidx].SUO_3dmove*0.1));
                        end;
                        FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
                     end {.if FCGLSCamMainViewGhost.TargetObject=FCV3dMVobjSpUnit[FCGLSCPobjIdx]}
                     else FC3DobjSpUnit[FCGLSCPobjIdx].Move(FCentities[0].E_spU[FCGLSCPspUidx].SUO_3dmove*deltaTime*FCGLSCPcoefTimeAcc);
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
            if (FCGLSCamMainViewGhost.TargetObject=FC3DobjSpUnit[FCV3DselSpU])
               and (FCV3DttlSpU>0)
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
   if FCGLSRootMain.Tag=1
   then
   begin
      FCGLSRootMain.Tag:=0;
      {.time frame}
      FCGtimeFlow.Enabled:=true;
      FCWM_MMenu_G_Save.Enabled:=true;
      FCWM_MMenu_G_FlushOld.Enabled:=true;
      FCWM_MMenu_H_HPanel.Enabled:=true;
      FCMuiM_MessageBox_ResetState(true);
      FCMumi_Faction_Upd(uiwAllSection, true);
      FCMgTFlow_FlowState_Set(tphTac);
   end;
end;

procedure TFCWinMain.FCGLSmainViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   VMDpick: TGLCustomSceneObject;
begin
   FCVwinMmousePosDumpX:=x;
   FCVwinMmousePosDumpY:=y;
   {.left mouse button}
   if  Button=mb_Left
   then
   begin
//      if FCWM_PopMenFocusedObj.Tag=1
//      then
//      begin
//         FCWM_PopMenFocusedObj.Tag:=0;
//         FCMgTFlow_FlowState_Set(tphTac);
//      end
//      else if (FCV3DselSpU>0)
//         and (FCGLSCamMainViewGhost.TargetObject=FC3DobjSpUnit[FCV3DselSpU])
//         and (FCentities[0].E_spU[round(FC3DobjSpUnit[FCV3DselSpU].TagFloat)].SUO_3dmove>0)
//      then FCGtimeFlow.Enabled:=false;
      try
         FCGLScadencer.Enabled:=false;
      finally
         try
            VMDpick:=(FCGLSmainView.Buffer.GetPickedObject(x, y) as TGLHUDText);
         except
            VMDpick:=nil;
         end;
      end;
      FCGLScadencer.Enabled:=true;
      if assigned(VMDpick)
      then FCMoglUI_Elem_SelHelp(VMDpick.Tag);
   end;
   {.right mouse button}
   if (Button=mb_Right)
//      and (FCWM_PopMenFocusedObj.Tag=1)
//   then
//   begin
//      FCWM_PopMenFocusedObj.Tag:=0;
//      FCMgTFlow_FlowState_Set(tphTac);
//   end
//   else if (Button=mb_Right)
//      and (FCWM_PopMenFocusedObj.Tag=0)
      and (FCRplayer.P_timePhse<>tphPAUSE)
      and
      (
         (
            (FCV3DselSpU>0)
            and
            (FCGLSCamMainViewGhost.TargetObject=FC3DobjSpUnit[FCV3DselSpU])
         )
         or (
               (FCV3DselSat>0)
               and
               (FCGLSCamMainViewGhost.TargetObject=FC3DobjSatGrp[FCV3DselSat])
            )
         or (FCGLSCamMainViewGhost.TargetObject=FC3DobjGrp[FCV3DselOobj])
         or (FCGLSCamMainViewGhost.TargetObject=FCGLSStarMain)
      )
      and (not FCWinMissSet.Visible)
   then FCWM_PopMenFocusedObj.PopupAtCursor;
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
   if FCWM_PopMenFocusedObj.Tag=1
   then
   begin
      FCWM_PopMenFocusedObj.Tag:=0;
      FCMgTFlow_FlowState_Set(tphTac);
   end;
   if (ssMiddle in shift)
      and (FCGLSmainView.cursor=crSizeNS)
   then
   else FCGLSmainView.cursor:=crCross;
end;

procedure TFCWinMain.FCGLSmainViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if (not FCGtimeFlow.Enabled)
      and (
            (FCV3DselSpU>0)
            and
            (FCGLSCamMainViewGhost.TargetObject=FC3DobjSpUnit[FCV3DselSpU])
            and
            (FCentities[0].E_spU[round(FC3DobjSpUnit[FCV3DselSpU].TagFloat)].SUO_3dmove>0)
            )
   then FCGtimeFlow.Enabled:=true;
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
end;

procedure TFCWinMain.FCWM_CDPinfrAvailAnchorClick(Sender: TObject; Node: TTreeNode;
  anchor: string);
begin
   FCMuiW_HelpTDef_Link(anchor, true);
end;

procedure TFCWinMain.FCWM_CDPinfrAvailKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiCDP_AvailInfra_Test(key, shift);
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
   FCMuiCDP_InfraListKey_Test(key, shift);
end;

procedure TFCWinMain.FCWM_CDPinfrListMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   ILMDinfraIndex: integer;

   ILMDcurrentNode
   ,ILMDrootNode: ttreenode;
begin
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

procedure TFCWinMain.FCWM_ColDPanelClose(Sender: TObject);
begin
   FCWM_SurfPanel.Hide;
end;

procedure TFCWinMain.FCWM_ColDPanelEndMoveSize(Sender: TObject);
begin
   FCMuiCDP_Surface_Relocate;
end;

procedure TFCWinMain.FCWM_ColDPanelMaximize(Sender: TObject);
begin
   FCMuiCDP_Surface_Relocate;
   FCWM_SurfPanel.show;
end;

procedure TFCWinMain.FCWM_ColDPanelMinimize(Sender: TObject);
begin
   FCWM_SurfPanel.Hide;
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

procedure TFCWinMain.FCWM_MMenu_DTFUGClick(Sender: TObject);
begin
   FCMfC_Initialize;
end;

procedure TFCWinMain.FCWM_MMenu_DTreloadTfilesClick(Sender: TObject);
begin
   FCMdTfiles_UIString_Init;
   FCMuiWin_UI_LangUpd;
end;

procedure TFCWinMain.FCWM_MMenu_G_ContClick(Sender: TObject);
begin
   FCMgCG_Core_Proceed;
end;

procedure TFCWinMain.FCWM_MMenu_G_FlushOldClick(Sender: TObject);
begin
   FCMdFSG_Game_SaveAndFlushOther;
end;

procedure TFCWinMain.FCWM_MMenu_G_NewClick(Sender: TObject);
begin
   FCMgNG_Core_Setup;
end;

procedure TFCWinMain.FCWM_MMenu_G_QuitClick(Sender: TObject);
begin
   FCWinMain.Close;
   {.DEV NOTE: add core quit routine}
end;

procedure TFCWinMain.FCWM_MMenu_G_SaveClick(Sender: TObject);
begin
   FCMdFSG_Game_Save;
end;

procedure TFCWinMain.FCWM_MMenu_H_AboutClick(Sender: TObject);
begin
   FCMuiWin_About_Raise;
end;

procedure TFCWinMain.FCWM_MMenu_H_HPanelClick(Sender: TObject);
begin
   if FCWM_HelpPanel.Visible
   then
   begin
      if FCWinMain.FCWM_HelpPanel.Collaps
      then FCWinMain.FCWM_HelpPanel.Collaps:=false
      else if not FCWinMain.FCWM_HelpPanel.Collaps
      then FCWinMain.FCWM_HelpPanel.Collaps:=true;
   end
   else if (FCWinMain.FCWM_3dMainGrp.Visible)
      and (not FCWinMain.FCWM_HelpPanel.Visible)
   then
   begin
      FCWinMain.FCWM_HelpPanel.Show;
      if FCWinMain.FCWM_HelpPanel.Collaps
      then FCWinMain.FCWM_HelpPanel.Collaps:=false;
      FCWinMain.FCWM_HelpPanel.BringToFront;
   end;
end;

procedure TFCWinMain.FCWM_MMenu_O_LocHelpClick(Sender: TObject);
begin
   if FCVwMhelpPstore
   then FCVwMhelpPstore:=false
   else if not FCVwMhelpPstore
   then FCVwMhelpPstore:=true;
   FCMdF_ConfigFile_Write(false);
   FCMuiWin_UI_Upd(mwupMenuLoc);
end;

procedure TFCWinMain.FCWM_MMenu_O_LocVObjClick(Sender: TObject);
begin
   if FCVwMcpsPstore
   then FCVwMcpsPstore:=false
   else if not FCVwMcpsPstore
   then FCVwMcpsPstore:=true;
   FCMdF_ConfigFile_Write(false);
   FCMuiWin_UI_Upd(mwupMenuLoc);
end;

procedure TFCWinMain.FCWM_MMenu_O_L_ENClick(Sender: TObject);
begin
   FCMdTfiles_Lang_Switch('EN');
   FCMuiWin_UI_LangUpd;
end;

procedure TFCWinMain.FCWM_MMenu_O_L_FRClick(Sender: TObject);
begin
   FCMdTfiles_Lang_Switch('FR');
   FCMuiWin_UI_LangUpd;
end;

procedure TFCWinMain.FCWM_MMenu_O_TR_1024Click(Sender: TObject);
begin
   FCMoglInit_StdText_Set(false, false);
end;

procedure TFCWinMain.FCWM_MMenu_O_TR_2048Click(Sender: TObject);
begin
   FCMoglInit_StdText_Set(true, false);
end;

procedure TFCWinMain.FCWM_MMenu_O_WideScrClick(Sender: TObject);
begin
   if FCVwinWideScr
   then FCVwinWideScr:=false
   else if not FCVwinWideScr
   then FCVwinWideScr:=true;
   FCMuiWin_BckgdPic_Upd;
end;

procedure TFCWinMain.FCWM_MsgeBoxCaptionDBlClick(Sender: TObject);
begin
   if not FCWinMissSet.Visible
   then
   begin
      if FCWM_MsgeBox.Collaps
      then
      begin
         FCWM_MsgeBox.Collaps:=false;
         FCWM_MsgeBox.Height:=FCWinMain.Height div 6;
         FCWM_MsgeBox.Top:=FCWM_3dMainGrp.Height-(FCWM_MsgeBox.Height+2);
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

procedure TFCWinMain.FCWM_PMFOcolfacDataClick(Sender: TObject);
begin
   if FCGLSCamMainViewGhost.TargetObject=FC3DobjGrp[FCV3DselOobj]
   then FCMuiCDP_Display_Set(
      FCV3DselSsys
      ,FCV3DselStar
      ,FCV3DselOobj
      ,0
      )
   else if FCGLSCamMainViewGhost.TargetObject=FC3DobjSatGrp[FCV3DselSat]
   then FCMuiCDP_Display_Set(
      FCV3DselSsys
      ,FCV3DselStar
      ,round(FC3DobjSatGrp[FCV3DselSat].TagFloat)
      ,FC3DobjSatGrp[FCV3DselSat].Tag
      );
end;

procedure TFCWinMain.FCWM_PMFOoobjDataClick(Sender: TObject);
var PMFODCdmpOobj: integer;
begin
   if FCWM_ColDPanel.Visible
   then FCWM_ColDPanel.Hide;
   if FCGLSCamMainViewGhost.TargetObject=FC3DobjGrp[FCV3DselOobj]
   then FCMuiSP_SurfaceEcosphere_Set(FCV3DselOobj, 0, false)
   else if FCGLSCamMainViewGhost.TargetObject=FC3DobjSatGrp[FCV3DselSat]
   then
   begin
      PMFODCdmpOobj:=round(FC3DobjSatGrp[FCV3DselSat].TagFloat);
      FCMuiSP_SurfaceEcosphere_Set(PMFODCdmpOobj, FC3DobjSatGrp[FCV3DselSat].Tag, false);
   end;
end;

procedure TFCWinMain.FCWM_PMFO_DListClick(Sender: TObject);
begin
   FCMuiWin_SpUnDck_Upd(round(FC3DobjSpUnit[FCV3DselSpU].TagFloat));
end;

procedure TFCWinMain.FCWM_PMFO_MissCancelClick(Sender: TObject);
var
   PMFOMCCspUnIdx: integer;
begin
   PMFOMCCspUnIdx:=round(FC3DobjSpUnit[FCV3DselSpU].TagFloat);
   FCMgMCore_Mission_Cancel(PMFOMCCspUnIdx);
   FCMgTFlow_FlowState_Set(tphTac);
end;

procedure TFCWinMain.FCWM_PMFO_MissColonizClick(Sender: TObject);
begin
   FCMgMCore_Mission_Setup(0, tatpMissColonize);
end;

procedure TFCWinMain.FCWM_PMFO_MissITransitClick(Sender: TObject);
begin
   FCMgMCore_Mission_Setup(0, tatpMissItransit);
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

procedure TFCWinMain.FCWM_SP_AutoUpKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_WinMain_Test(Key, Shift);
end;

procedure TFCWinMain.FCWM_SP_SurfaceHotSpotEnter(Sender: TObject; HotSpot: THotSpot);
begin
   FCMuiSP_RegionDataPicture_Update(HotSpot.ID, false);
end;

procedure TFCWinMain.FCWM_SP_SurfaceMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   FCWM_SP_SurfSel.Refresh;
end;

procedure TFCWinMain.FCWM_SP_SurfSelClick(Sender: TObject);
var
   SPSSCcurrSettlement: integer;
begin
   SPSSCcurrSettlement:=0;
//   if FCWM_SP_DataSheet.ActivePage<>FCWM_SP_ShReg
//   then
//   begin
//      FCWM_SP_DataSheet.ActivePage:=FCWM_SP_ShReg;
//      FCMuiSP_RegionDataPicture_Update(FCWM_SP_Surface.Tag, false);
//   end;
   if (FCWinMissSet.Visible)
//      and (FCWinMissSet.FCWMS_Grp.Caption=FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet')+FCFdTFiles_UIStr_Get(uistrUI,'Mission.coloniz'))
   then
   begin
      GMCregion:=FCWM_SP_Surface.Tag;
      if not FCWinMissSet.FCWMS_Grp_MCGColName.Visible
      then
      begin
         SPSSCcurrSettlement:=FCFgC_Settlement_GetIndexFromRegion(
            0
            ,FCWinMissSet.FCWMS_Grp_MCGColName.Tag
            ,GMCregion
            );
         if SPSSCcurrSettlement=0
         then
         begin
            FCWinMissSet.FCWMS_Grp_MCG_SetType.Show;
            FCWinMissSet.FCWMS_Grp_MCG_SetName.Show;
         end
         else if SPSSCcurrSettlement>0
         then
         begin
            FCWinMissSet.FCWMS_Grp_MCG_SetType.Hide;
            FCWinMissSet.FCWMS_Grp_MCG_SetName.Hide;
         end;
      end
      else if FCWinMissSet.FCWMS_Grp_MCGColName.Visible
      then
      begin
         FCWinMissSet.FCWMS_Grp_MCG_SetType.Show;
         FCWinMissSet.FCWMS_Grp_MCG_SetName.Show;
      end;
      FCMgMc_Colonize_Upd(GMCregion);
   end;
end;

procedure TFCWinMain.FCWM_UMIFac_ColoniesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_UMIFacCol_Test(Key, shift);
end;

procedure TFCWinMain.FCWM_UMIFac_TabShChange(Sender: TObject);
begin
   FCMumi_Main_Upd;
end;

procedure TFCWinMain.FCWM_UMIFSh_AFlistAnchorClick(Sender: TObject; index: Integer;
  anchor: string);
begin
   FCMuiW_HelpTDef_Link(anchor, true);
end;

procedure TFCWinMain.FCWM_UMIFSh_AFlistClick(Sender: TObject);
begin
   FCMumi_AvailPolList_UpdClick;
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
   FCWM_UMI.Constraints.MinWidth:=FCVwMumiW;
   FCWM_UMI.Constraints.MinHeight:=FCVwMumiH;
end;

procedure TFCWinMain.FCWM_UMIMinimize(Sender: TObject);
begin
   FCWM_UMI.Constraints.MinWidth:=0;
   FCWM_UMI.Constraints.MinHeight:=0;
end;

procedure TFCWinMain.FCWM_UMIResize(Sender: TObject);
begin
   if (FCWM_UMI.Visible)
      and (not FCWM_UMI.Collaps)
   then FCMumi_Faction_Upd(uiwNone, true);
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
   FCMumi_Main_TabSetSize;
   FCMumi_Main_Upd;
end;

procedure TFCWinMain.FormCreate(Sender: TObject);
var
   FClocalPath: widestring;

   FCwide: pWideChar;
begin
   {.core settings}
   FCVisFARCclosing:=false;
   ThousandSeparator:=',';
   Randomize;
   {.set the paths}
   FCVpathGame:=ExtractFilePath(Application.ExeName);
   FCVcfgDir:=FCFcFunc_WinFolders_GetMyDocs(false);
   if DecimalSeparator=','
   then DecimalSeparator:='.';
   RandSeed:=GetTickCount;
   FCVpathCfg:=FCVcfgDir+'config.xml';
   {.initialize some global data and acces to the configuration file}
	FCVpathRsrc:=FCVpathGame+'_RSRC\';
	FCVpathXML:=FCVpathGame+'_XMLD\';
   try
      FCMdInit_Initialize;
   finally
      {.local fonts and user's interface initialization}
      FClocalPath:=FCVpathRsrc+'fnt\DejaVuSans.ttf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
      FClocalPath:=FCVpathRsrc+'fnt\DejaVuSansCondensed.ttf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
      FClocalPath:=FCVpathRsrc+'fnt\disco___.ttf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
      FClocalPath:=FCVpathRsrc+'fnt\Existence-Light.otf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
      FClocalPath:=FCVpathRsrc+'fnt\FrancophilSans.ttf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
      FClocalPath:=FCVpathRsrc+'fnt\Interdimensional.ttf';
      FCwide:=Addr(FClocalPath[1]);
      AddFontResource(FCwide);
      SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
      FCMuiWin_UI_Upd(mwupAll);
	end;
	FCVwinMallowUp:=true;
   {.initialize the game timer}
   FCGtimeFlow:= TgtTimer.Create(Self);
   FCGtimeFlow.OnTimer := InternalOnGameTimer;
   FCGtimeFlow.Interval:=1000;
   FCGtimeFlow.Enabled := False;
end;

procedure TFCWinMain.FormDestroy(Sender: TObject);
var
   FDlocalPath: widestring;

   FDwide: PWideChar;
begin
   {.disable timer and threads}
   FCGLScadencer.Enabled:=false;
   if assigned (FCGtimeFlow)
   then
   begin
      FCGtimeFlow.Enabled:=false;
      FCGtimeFlow.Free;
   end;
   if FCWinMissSet.Visible
   then FCWinMissSet.Close;
   {.windows switchs}
   FCVisFARCclosing:=true;
   FCVwinMallowUp:=false;
   {.store main window location}
	FCMuiWin_MainWindow_StoreLocSiz;
   {.free cps}
   if assigned (FCcps)
   then FCcps.Free;
   {.disable 3d}
   FCGLSmainView.Enabled:=false;
   FCV3DcamTimeSteps:=0;
   SetLength(FC3DobjGrp,0);
   SetLength(FC3DobjPlan,0);
   SetLength(FC3DobjAtmosph,0);
   SetLength(FC3DobjAster,0);
   SetLength(FC3DobjSpUnit,0);
   SetLength(FC3DobjSatGrp,0);
   SetLength(FC3DobjSat,0);
   SetLength(FC3DobjSatAtmosph,0);
   SetLength(FC3DobjSatAster,0);
   FreeAndNil(FCGLSsmthNavMainV);
   FCGLSRootMain.Objects.DeleteChildren;
   if assigned(FC3DmatLibSplanT)
   then FC3DmatLibSplanT.Free;
   {.disable XML components}
   FCXMLcfg.Active:=false;
   FCXMLdbFac.Active:=false;
   FCXMLdbInfra.Active:=false;
   FCXMLdbProducts.Active:=false;
   FCXMLdbSCraft.Active:=false;
   FCXMLdbSPMi.Active:=false;
   FCXMLdbUniv.Active:=false;
   FCXMLsave.Active:=false;
   FCXMLtxtUI.Active:=false;
   FCXMLtxtEncy.Active:=false;
   {.free memory streams}
   FCVmemEncy.Free;
   FCVmemUI.Free;
   FDlocalPath:=FCVpathRsrc+'fnt\DejaVuSans.ttf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
   FDlocalPath:=FCVpathRsrc+'fnt\DejaVuSansCondensed.ttf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
   FDlocalPath:=FCVpathRsrc+'fnt\disco___.ttf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
   FDlocalPath:=FCVpathRsrc+'fnt\Existence-Light.otf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
   FDlocalPath:=FCVpathRsrc+'fnt\FrancophilSans.ttf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
   FDlocalPath:=FCVpathRsrc+'fnt\Interdimensional.ttf';
   FDwide:=Addr(FDlocalPath[1]);
   RemoveFontResource(FDwide);
   SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0) ;
end;

procedure TFCWinMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   FCMuiK_WinMain_Test(Key, Shift);
end;

procedure TFCWinMain.FormResize(Sender: TObject);
{:Purpose: during form resize.
    Additions:
      -2010Apr07- *fix: message box is correctly updated.
      -2009Oct08- *add about window update.
      -2009Oct08- *add mission setup window update.
}
begin
   if not FCVisFARCclosing then UpdUI(false);
end;

procedure TFCWinMain.InternalOnGameTimer(Sender: TObject);
begin
   FCMgGF_GameTimer_Process;
end;

procedure TFCWinMain.WMExitSizeMove(var Message: TMessage) ;
begin
   if not FCVisFARCclosing
   then UpdUI(true);
end;

procedure TFCWinMain.WMMaximized(var Message: TMessage) ;
begin
   if (not FCVisFARCclosing)
      and (FCWM_3dMainGrp.Visible)
   then UpdUI(false);
end;

procedure TFCWinMain.UpdUI(UUIwinOnly: boolean);
begin
   {.save main window location and size}
   if FCVwinMallowUp
   then FCMuiWin_MainWindow_StoreLocSiz;
   {.update mission setup window}
   FCMuiWin_UI_Upd(mwupSecwinMissSetup);
   {.update about window}
   FCMuiWin_UI_Upd(mwupSecwinAbout);
   {.update new game setting window}
   FCMuiWin_UI_Upd(mwupSecWinNewGSetup);
   if not UUIwinOnly
   then
   begin
      {.update font sizes if needed}
      FCMuiWin_UI_Upd(mwupFontAll);
      {.relocate and/or resize the message box}
      FCMuiWin_UI_Upd(mwupMsgeBox);
      {.update 3d main view frame and all childs}
      if FCWM_3dMainGrp.Visible
      then
      begin
         {.set main camera}
         gluPerspective(FCGLSCamMainViewGhost.FocalLength, width/height, 0.001, FCGLSCamMainViewGhost.DepthOfView);
         {.relocate and change font size of all hud user's interface objects}
         FCMoglUI_Main3DViewUI_Update(oglupdtpLocOnly, ogluiutAll);
         FCMuiM_MessageBox_ResetState(true);
      end;
   end;
end;

end.
