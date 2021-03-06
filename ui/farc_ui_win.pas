﻿{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: core game windows interface management

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

unit farc_ui_win;

interface

uses
   Classes
   ,ComCtrls
   ,Controls
   ,Forms
   ,Graphics
   ,sysutils
   ,Windows

   ,AdvPanel
   ,Dialogs
   ,Menus

   ,OpenGL1x;

type TFCEuiwFtClass=(
   uiwButton
   ,uiwDescText
   ,uiwGrpBox
   ,uiwGrpBoxSec
   ,uiwListItems
   ,uiwPageCtrl
   ,uiwPanelTitle
   );

type TFCEmwinUpdTp=(
   mwupAll
   ,mwupMsgeBox
   ,mwupTextWM3dFrame
   ,mwupTextWinMain
   ,mwupTextWinAb
   ,mwupTextWinNGS
   ,mwupTextWinSavedGames
   ,mwupTextMenu
   ,mwupMenuLang
   ,mwupMenuLoc
   ,mwupMenuRTturnBased
   ,mwupMenuWideScr
   ,mwupMenuStex
   ,mwupSecwinAbout
   ,mwupSecwinDebug
   ,mwupSecWinNewGSetup
   ,mwupSecwinSavedGames
   ,mwupFontWinAb
   ,mwupFontWinNGS
   ,mwupFontWinSavedGames
   ,mwupFontAll
   );

type TFCEuiwPopupKind=(
   uiwpkOrbObj,
   uiwpkSpUnit
   );

///<summary>
///   generate colorized index of a percent value from 0%(good) to 100%+(bad). Returns the string
///</summary>
///   <param name="PCGBGpercent">integer percent value</param>
function FCMuiW_PercentColorGoodBad_Generate(const PCGBGpercent: integer): string;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   update the background with the right choosen format.
///</summary>
procedure FCMuiW_BackgroundPicture_Update;

///<summary>
///   get correct font size of a targeted font class following the size of the window.
///</summary>
///    <param name="FGZftClass">font size class</param>
function FCFuiW_Font_GetSize(const FGZftClass: TFCEuiwFtClass): integer;

///<summary>
///   store current size and location of the main window.
///</summary>
procedure FCMuiW_MainWindow_StoreLocSiz;

///<summary>
///   link the help panel / topics-definitions right topic with the asked token
///</summary>
///   <param name="HTDLtoken">topic/definition ui/encyclopaedia.xml token</param>
///   <param name="HTDLupdUI">true= show the ui</param>
procedure FCMuiW_HelpTDef_Link(
   const HTDLtoken: string;
   const HTDLupdUI: boolean
   );

///<summary>
///   update the display of the docking list
///</summary>
///    <param name="SUDUsuIdx">owned space unit index</param>
procedure FCMuiWin_SpUnDck_Upd(const SUDUsuIdx: integer);

///<summary>
///
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMuiW_MainTitleBar_Init;

///<summary>
///   update interface for new language
///</summary>
procedure FCMuiWin_UI_LangUpd;

///<summary>
///   update and initialize all user's interface elements of the game.
///</summary>
///    <param name="WUupdKind">target to update.</param>
procedure FCMuiW_UI_Initialize(const UIUtp: TFCEmwinUpdTp);

///<summary>
///   close the about window.
///</summary>
procedure FCMuiW_WinAbout_Close;

///<summary>
///   show the about window.
///</summary>
procedure FCMuiW_WinAbout_Raise;

///<summary>
///   close the new game window
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMuiW_WinNewGame_Close;

///<summary>
///   show the new game window.
///</summary>
procedure FCMuiW_WinNewGame_Raise;

///<summary>
///   close the saved games window.
///</summary>
procedure FCMuiW_WinSavedGames_Close;

///<summary>
///   show the saved games window.
///</summary>
procedure FCMuiW_WinSavedGames_Raise;

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_files
   ,farc_data_game
   ,farc_data_html
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_data_spu
   ,farc_data_univ
   ,farc_data_textfiles
   ,farc_game_colony
   ,farc_game_cps
   ,farc_game_csm
   ,farc_game_csmevents
   ,farc_game_gameflow
   ,farc_game_infra
   ,farc_game_newg
   ,farc_game_spm
   ,farc_game_spmdata
   ,farc_gfx_core
   ,farc_main
   ,farc_ogl_init
   ,farc_ogl_ui
   ,farc_spu_functions
   ,farc_ui_about
   ,farc_ui_coldatapanel
   ,farc_ui_coredatadisplay
   ,farc_ui_msges
   ,farc_ui_planetarysurvey
   ,farc_ui_savedgames
   ,farc_ui_surfpanel
   ,farc_ui_umi
   ,farc_univ_func
   ,farc_win_about
   ,farc_win_debug
   ,farc_win_newgset
   ,farc_win_savedgames;

//===================================END OF INIT============================================

function FCMuiW_PercentColorGoodBad_Generate(const PCGBGpercent: integer): string;
{:Purpose: generate colorized index of a percent value from 0%(good) to 100%+(bad). Returns the string.
    Additions:
}
begin
   Result:='';
   case PCGBGpercent of
      0..24: Result:=FCCFcolGreen+IntToStr(PCGBGpercent)+FCCFcolEND;

      25..49: Result:=FCCFcolYel+IntToStr(PCGBGpercent)+FCCFcolEND;

      50..74: Result:=FCCFcolOrge+IntToStr(PCGBGpercent)+FCCFcolEND;

      75..999:  Result:=FCCFcolRed+IntToStr(PCGBGpercent)+FCCFcolEND;
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiW_BackgroundPicture_Update;
{:Purpose: update the background with the right choosen format.
    Additions:
}
begin
   if FCVdiWinMainWideScreen
   then FCWinMain.FCWM_BckgImage.Bitmap.LoadFromFile(FCVdiPathResourceDir+'pics-ui-' +'desk\puidesk0w.jpg')
   else if not FCVdiWinMainWideScreen
   then FCWinMain.FCWM_BckgImage.Bitmap.LoadFromFile(FCVdiPathResourceDir+'pics-ui-' +'desk\puidesk0.jpg');
   FCMuiW_UI_Initialize(mwupMenuWideScr);
end;

function FCFuiW_Font_GetSize(const FGZftClass: TFCEuiwFtClass): integer;
{:Purpose: get correct font size of a targeted font class following the size of the window.
   Additions:
      -2010Oct18- *mod: complete refactoring and retooling fo the parameters.
      -2010Oct14- *add: page control font class for the new DejaVuSans font.
      -2009Sep06- *fix of bugs in all case items concerning variable names.
      -2009Sep03- *add description text format.
      -2009Aug07- *add Linux support.
}
begin
   Result:=9;

   case FGZftClass
   of
      uiwButton:
      begin
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then Result:=9
         else result:=8;
      end;
      uiwDescText:
      begin
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then Result:=10
         else result:=9;
      end;
      uiwGrpBox:
      begin
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then Result:=9
         else result:=8;
      end;
      uiwGrpBoxSec:
      begin
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then Result:=8
         else result:=7;
      end;
      uiwListItems:
      begin
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then Result:=9
         else result:=8;
      end;
      uiwPageCtrl:
      begin
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then Result:=8
         else result:=7;
      end;
      uiwPanelTitle:
      begin
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then Result:=9
         else result:=8;
      end;
   end; {.case FGZftClass of}
end;

procedure FCMuiW_MainWindow_StoreLocSiz;
{:Purpose: store current size and location of the main window.
   Additions:
}
begin
   FCVdiWinMainHeight:=FCWinMain.Height;
   FCVdiWinMainWidth:=FCWinMain.Width;
   FCVdiWinMainLeft:=FCWinMain.Left;
   FCVdiWinMainTop:=FCWinMain.Top;
	FCMdF_ConfigurationFile_Save(false);
end;

procedure FCMuiW_HelpTDef_Link(
   const HTDLtoken: string;
   const HTDLupdUI: boolean
   );
{:Purpose: link the help panel / topics-definitions right topic with the asked token.
    Additions:
      -2010Nov27- *add: a parameter HTDLupdUI for show the UI if required.
      -2010Jul18- *fix: update and correction on definitions/topics list behavior.
}
var
   HTDLcnt
   ,HTDLidx
   ,HTDLmax: integer;
begin
   FCWinMain.FCWM_HDPhintsText.HTMLText.Clear;

   HTDLcnt:=1;
   HTDLmax:=length(FCDBhelpTdef)-1;
   while HTDLcnt<=HTDLmax do
   begin
      if HTDLtoken=FCDBhelpTdef[HTDLcnt].TD_link
      then
      begin
         FCWinMain.FCWM_HDPhintsText.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrEncyl, HTDLtoken));
         HTDLidx:=HTDLcnt-1;
         if FCWinMain.FCWM_HDPhintsList.ItemIndex<>HTDLidx
         then
         begin
            FCWinMain.FCWM_HDPhintsList.Selected[FCWinMain.FCWM_HDPhintsList.ItemIndex]:=false;
            FCWinMain.FCWM_HDPhintsList.ItemIndex:=HTDLidx;
            FCWinMain.FCWM_HDPhintsList.Selected[HTDLidx]:=true;
         end;
         break;
      end;
      inc(HTDLcnt);
   end;
   if (HTDLupdUI)
      and (not FCWinMain.FCWM_HelpPanel.Visible)
   then
   begin
      FCWinMain.FCWM_HPdataPad.ActivePage:=FCWinMain.FCWM_HPDPhints;
      FCWinMain.FCWM_HelpPanel.Show;
      FCWinMain.FCWM_HelpPanel.BringToFront;
      FCWinMain.SetFocusedControl(FCWinMain.FCWM_HelpPanel);
   end;
end;

procedure FCMuiWin_SpUnDck_Upd(const SUDUsuIdx: integer);
{:Purpose: update the display of the docking list.
    Additions:
      -2010Sep20- *fix: load correctly the docked space units structures.
      -2010Sep19- *add: entities code.
      -2010Sep02- *add: use a local variable for the design #.
      -2010Mar29- *add: docked space units.
                  *add: set the itemindex.
      -2010Mar28- *add: panel title, mothercraft and the dependency arrow.
}
var
   SUDUcnt
   ,SUDUdsgn
   ,SUDUttl
   ,SUDUdckIdx
   ,SUDUdckDes: integer;
begin
   FCWinMain.FCWM_DLP_DockList.Items.Clear;
   SUDUdsgn:=FCFspuF_Design_getDB(FCDdgEntities[0].E_spaceUnits[SUDUsuIdx].SU_designToken);
   SUDUttl:=length(FCDdgEntities[0].E_spaceUnits[SUDUsuIdx].SU_dockedSpaceUnits)-1;
   FCWinMain.FCWM_DLP_DockList.Items.Add(
      '<p align="center"><img src="file://'+FCVdiPathResourceDir+'pics-ui-scraft\'
      +FCDdsuSpaceUnitDesigns[SUDUdsgn].SUD_internalStructureClone.IS_token+'_lst.jpg'
      +'" align="middle">'
      );
   FCWinMain.FCWM_DLP_DockList.Items.Add(
      '<p align="center"><img src="file://'+FCVdiPathResourceDir+'pics-ui-misc\arrow.jpg'
      +'" align="middle">'
      );
   SUDUcnt:=1;
   while SUDUcnt<=SUDUttl do
   begin
      SUDUdckIdx:=FCDdgEntities[0].E_spaceUnits[SUDUsuIdx].SU_dockedSpaceUnits[SUDUcnt].SUDL_index;
      SUDUdsgn:=FCFspuF_Design_getDB(FCDdgEntities[0].E_spaceUnits[SUDUdckIdx].SU_designToken);
      FCWinMain.FCWM_DLP_DockList.Items.Add(
         '<img src="file://'+FCVdiPathResourceDir+'pics-ui-scraft\'
         +FCDdsuSpaceUnitDesigns[SUDUdsgn].SUD_internalStructureClone.IS_token+'_lst.jpg'
         +'" align="middle">'
         +FCFdTFiles_UIStr_Get(dtfscPrprName, FCDdgEntities[0].E_spaceUnits[SUDUdckIdx].SU_name)
         );
      inc(SUDUcnt);
   end;
   FCWinMain.FCWM_DockLstPanel.Caption.Text
      :=FCFdTFiles_UIStr_Get(uistrUI, 'spUnDock')+FCFdTFiles_UIStr_Get(dtfscPrprName, FCDdgEntities[0].E_spaceUnits[SUDUsuIdx].SU_name);
   FCWinMain.FCWM_DLP_DockList.ItemIndex:=2;
   FCWinMain.FCWM_DLP_DockList.Selected[2]:=true;
   if not FCWinMain.FCWM_DockLstPanel.Visible
   then FCWinMain.FCWM_DockLstPanel.Visible:=true;
end;

procedure FCMuiW_MainTitleBar_Init;
{:Purpose: .
    Additions:
}
begin
   FCWinMain.Caption:='FAR Colony  '+FCFcF_FARCVersion_Get+'  ©2009-2014 J.F. Baconnet aka Farcodev';
end;

procedure FCMuiWin_UI_LangUpd;
{:Purpose: update interface for new language.
    Additions:
      -2013Mar10- add: hide the planetary survey panel if it's visible.
      -2012Aug21- *fix: bugfixes due to the modification of windows initialization.
      -2011Dec21- *mod: integrate the new method to call the colony data panel.
      -2011Jul20- *add: update the Colony Data Panel, especially the data display itself, if needed.
      -2011May24- *add: colony data panel / infrastructure functions private variables initialization.
      -2010Oct31- *fix: UMI/Faction section - display correctly the government status section.
      -2010Oct17- *add: UMI/Faction section.
      -2010Sep19- *add: entities code.
      -2010Apr06- *add: update about text.
      -2009Nov17- *update also the opengl display if needed.
      -2009Oct10- *add mission setup window.
}
var
   colMax: integer;
begin
   FCMdF_ConfigurationFile_Save(false);
   FCMuiW_UI_Initialize(mwupMenuLang);
   FCMuiW_UI_Initialize(mwupTextWinMain);

   if not FCWinMain.MMGameSection_Continue.Enabled then
   begin
      colMax:=Length(FCDdgEntities[0].E_colonies)-1;
      if FCVdi3DViewRunning
      then FCMoglUI_CoreUI_Update(ptuAll, ttuAll);
      if colMax>0 then
      begin
         if assigned(FCcps)
         and (FCcps.CPSisEnabled)
         then FCcps.FCM_ViabObj_Init(false);
      end;
      if FCWinMain.FCWM_ColDPanel.Visible
      then FCMuiCDD_Colony_Update(
         cdlAll
         ,0
         ,0
         ,0
         ,false
         ,false
         ,true
         );

      FCMuiUMI_CurrentTab_Update( false, false );
      if FCWinMain.MVG_PlanetarySurveyPanel.Visible
      then FCWinMain.MVG_PlanetarySurveyPanel.Hide;
   end;



//   FCMumi_Faction_Upd(uiwAllSection, true);
//   FCMuiCDP_FunctionCateg_Initialize;
end;

procedure FCMuiW_UI_Initialize(const UIUtp: TFCEmwinUpdTp);
{:Purpose: update and initialize all user's interface elements of the game.
   Additions:
      -2014Feb16- *mod: rework how the 'help panel / shortcut keys' is displayed.
      -2013Nov18- *add: main menu - load saved game.
      -2013Mar26- *add: SP_ResourceSurveyShowDetails.
      -2013Feb03- *add: planetary survey panel.
      -2013Jan29- *add: surface panel - add a SP_ResourceSurveyCommit.
      -2013Jan28- *rem: surface panel - tabsheet is removed, SP_RegionSheet is a panel by itself.
      -2013Jan09- *mod: adjustment of ActionPanel width for french language.
      -2012Dec02- *add: action panel - orbital object data + AP_DetailedData + AP_DockingList + AP_MissionColonization + AP_MissionInterplanetaryTransit + AP_MissionCancel buttons.
      -2012Nov29- *add: action panel.
      -2012Sep09- *add: UMI - Faction - Dependencies Circular Progress - linked description label.
      -2012Sep08- *add: UMI - Faction - Dependencies Circular Progress - linked label.
      -2012May27- *add: FCWM_CPSreport.
                  *fix: infrastructure panel - forgot to size correctly the text of FCWM_IPconfirmButton.
      -2012Mar13- *fix: clear the FCWM_IPconfirmButton's caption text with the useless anchors.
      -2012Feb02- *mod: FCWM_CDPwcpEquip size is adjusted correctly.
      -2012Jan29- *add: update language submenu for Spanish.
      -2012Jan29- *add: main menu / options / language / spanish.
      -2012Jan25- *add: production matrix font initialization.
      -2012Jan15- *add: storage list font and size changes.
                  *add: CDPstorageCapacity initialization.
                  *add: tab is relocated and its text is localized.
                  *add: CDPproductionMatrixList initialization.
      -2012Jan08- *mod: year change for the main title.
                  *mod: change the size of the colony data panel.
                  *add: surface panel - complete rework in size/positions and for the ecosphere data sheet.
                  *rem: surface panel - Ecosphere tab.
      -2012Jan05- *mod: adjust FCWM_CDPwcpEquip location.
                  *mod: set the correct active page of the FCWM_CDPepi.
      -2011Jun29- *add: infrastructure panel - FCWM_IPinfraKits initialization.
      -2011Jun06- *add: infrastructure panel - initialize the commit button.
                  *mod: infrastructure panel - refine the panel size.
      -2011Jun06- *mod: infrastructure panel - refine the panel size.
      -2011May26- *add: infrastructure panel - FCWM_IPlabel initialization.
      -2011May23: *add: infrastructure panel initialization.
      -2011May08- *add: colony data panel - population - construction workforce - FCWM_CDPcwpAssignVeh initialization.
      -2011May06- *mod: size refinments for the Help Panel.
      -2011May01- *add: colony FCWM_CDPepidata panel - population - construction workforce - initialize equipment list + number edit font.
      -2011Apr29- *add: colony data panel - population - construction workforce - initialize the number edit.
      -2011Apr17- *add: colony data panel - infrastructures available list - font initialization.
      -2011Apr14- *add: colony data panel - infrastructures tree list/available list - sizes initialization.
      -2011Apr13- *mod: change colony data panel starting position to also fit in 1024*768 resolution.
      -2011Apr10- *mod: colony data panel - infrastructures tree list - correction of the font size.
      -2011Feb12- *add: mission setup - settlement setup.
      -2011Jan21- *add: colony panel - UI changes.
      -2011Jan16- *add: Maine Menu/Debug Tools/Reload Text Files.
      -2010Dec12- *add: UMI/Faction/Policy Enforcement - Enforcement Decisions.
      -2010Dec05- *add: UMI/Faction/Policy Enforcement - Requirements list initialization.
      -2010Dec04- *add: UMI/Faction/Policy Enforcement - Acceptance Probability subsection initialization.
      -2010Dec02- *add: UMI/Faction/Policy Enforcement - available policies list initialization.
      -2010Nov27- *mod: help panel - size change.
                  *mod: help panel - topics/definitions - fix the list scrollbar behavior.
      -2010Nov25- *mod: help panel - topics/definitions - some change for sub-panels size.
      -2010Nov16- *add: UMI/Faction - SPMi trees initialization.
      -2010Oct28- *add: Colonies List texts and fonts initialization.
      -2010Oct25- *add: UMI/faction - Government Details and Colonies List initialization.
                  *rem: tabsheet Colonies.
      -2010Oct24- *add: UMI/faction - political structure and SPM tab sheet initialization.
      -2010Oct23- *add: UMI - set the correct initial page.
      -2010Oct18- *add: UMI/faction section - SPM group + tabsheet initialization.
      -2010Oct17- *add: UMI/faction section - faction level + economic/social/military status progress initialization.
      -2010Oct14- *mod: help panel / topics-definitions initialization correction.
                  *add: UMI fonts + faction data groupbox initialization.
      -2010Oct12- *add: UMI tabs text.
      -2010Oct11- *add: cleanup older files menu item.
      -2010Oct03- *mod: society tab, for new game panel, is used now for SPM tab.
                  *rem: foreign relations tab, for new game panel, is removed.
      -2010Jul02- *add: FCWMS_Grp_MCGColName init.
      -2010Jul01- *add: colony data panel / colony name.
      -2010Jun29- *add: help panel / topic-definition
      -2010Jun28- *add: colony data panel infrastructures.
      -2010Jun27- *add: colony data panel CSM events list.
      -2010Jun18- *add: colony data panel font init.
      -2010Jun14- *add: colony data panel.
                  *add: popup menu item FCWM_PMFOspuData.
      -2010Jun09- *add: FUG debug tool submenu.
      -2010Jun08- *add: cps and help panel location menu init.
      -2010Jun06- *add: viability objectives panel init.
      -2010May18- *add: debug console init.
      -2010Apr07- *mod: change mission setting window and children settings.
                  *mod: some code optimization (reduce calculations load).
      -2010Apr06- *add: focused obj popup menu: Specific Missions and Colonization.
      -2010Mar28- *add: docking list panel.
      -2010Mar27- *add: docking list popup sub menu item and import static text
                  initializations from FocusPopup_Upd.
      -2010Mar20- *add: FCWM_SPShReg_Lab.
                  *add FCWM_SP_AutoUp.
      -2010Mar02- *add: FCWNGS_Frm_ColMode.
      -2010Feb05- *add: FCWM_SPShEcos_Lab font setting.
      -2010Jan20- *add: FCWM_SP_Surface, FCWM_SP_DataSheet, FCWM_SP_ShEcos, FCWM_SP_RDatFrm.
                  *add: FCWM_SP_SPic.
                  *add: FCWM_MMenu_FUG.
      -2010Jan19- *add: FCWM_SurfPanel.
      -2010Jan18- *add: FCWM_MMenu_H_HPanel.
      -2010Jan09- *add: FCWM_MMenu_O_TexR, FCWM_MMenu_O_TR_1024, FCWM_MMenu_O_TR_2048.
                  *add: FCWM_MMenu_O_TR_1024/FCWM_MMenu_O_TR_2048 submenu check system.
      -2009Dec20- *mod: changed FCWM_HelpPanel height.
      -2009Dec02- *initialize help panel.
      -2009Nov18- *update options/ widescreen sub menu.
      -2009Nov12- *add FCWM_MMenu_G_Save.
      -2009Nov08- *add FCWM_MMenu_G_Cont.
                  *enable/disable continue game item menu folllowing there's a current game
                  or not.
      -2009Nov04- *add FCWNGS_Frm_ButtCancel.
      -2009Nov03- *add FCWA_ButDown/FCWA_ButUp.
      -2009Nov02- *add FCWA_Frm_Header init.
                  *add FCWA_Frm_Creds.init
      -2009Nov01- *add about window initialization.
      -2009Oct25- *add button configuration for mission configuration window.
      -2009Oct19- *add mission configuration data panel.
      -2009Oct18- *add mission configuration components.
      -2009Oct11- *add mission setup window labels initialization.
      -2009Oct10- *add mission setup window components initialization.
                  *add mission steup window components text.
      -2009Oct08- *add mission setup initialization.
      -2009Sep30- *messagebox intialization change.
      -2009Sep29- *add a switch for only update the message box.
                  *add FCWM_MsgeBox initialization + font size.
                  *add FCWM_MsgeBox_List initialization + font size.
                  *add FCWM_MsgeBox_Desc initialization + font size.
      -2009Sep12- *add FCWNGS_Frm_DPad_SheetDotList.
                  *add FCWNGS_Frm_DPad_SDL_DotList.
                  *resize the proceed button of WNGS for fix a problem w/ french language.
      -2009Sep03- *add font size settings for displaying texts of datapad.
      -2009Aug15- *add FCWM_3dMainGrp.
      -2009Aug10- *font choices are directly in the lcl.
                  *code cleanup.
      -2009Aug09- *FCWNGS_Frames_CommitButt init.
                  *completion of font init for datapad pages.
      -2009Aug08- *complete new game setup window settings.
      -2009Aug07- *add font setup for Linux system (Bitstream Charter for Humanist
                  replacement and Bitstream Vera Sans for Zurich replacement).
      -2009Aug06- *completion of font setup subcode.
                  *add FCVallowUpNGSWin switch to prevent the New Game Setup window to be
                  updated before it's created.
      -2009Aug05- *completion of new game setup window (80%).
                  *add a new switch for font set.
      -2009Aug04- *add linux/windows conditional compilation directives, for set the fonts
                  and other elements.
                  *add the new game setup window.
                  *some modifications in the switches.
      -2009Aug02- *add localization for main menu items.
                  *initialize language submenu with english/french submenu items.
                  *move the double buffered of main window here.
                  *set font.
                  *change procedure switchs.
                  *correction in language sub menu item selection.
      -2009Aug01- *load the bitmap of the background.
}
var
   UIUcnt
   ,UIUmainW2
   ,UIUmainH2
   ,UIUmax: integer;
begin
   //=======================================================================================
   {.****WARNING**** DO NOT FORGET TO ADD REFERENCES OF NEW LANGUAGES TO
   FCWM_MainMenu_Options_Lang_[lang]Click IN _MAIN}
   {.this section concern only all texts of main window}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupTextWinMain)
   then
   begin
      {.main title bar}
      FCMuiW_MainTitleBar_Init;
		{.main menu - game section}
		FCWinMain.MM_GameSection.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Game');
		FCWinMain.MMGameSection_New.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Game_New');
      FCWinMain.MMGameSection_Continue.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Game_Cont');
      FCWinMain.MMGameSection_LoadSaved.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'MMGame_LoadSaved');
      FCWinMain.MMGameSection_Save.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_G_Save');
      FCWinMain.MMGameSection_SaveAndFlush.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_G_FlushOld');
		FCWinMain.MMGameSection_Quit.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Game_Quit');
		{.main menu - options section}
		FCWinMain.MM_OptionsSection.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Options');
		FCWinMain.MMOptionsSection_LanguageSection.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Options_Lang');
		FCWinMain.MMOptionsSection_LS_EN.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Options_Lang_EN');
		FCWinMain.MMOptionsSection_LS_FR.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Options_Lang_FR');
      FCWinMain.MMOptionsSection_LS_SP.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Options_Lang_SP');
      FCWinMain.MMOptionSection_PanelsLocationSection.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_O_Loc');
      FCWinMain.MMOptionSection_PLS_LocationHelp.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_O_LocHelp');
      FCWinMain.MMOptionSection_PLS_LocationViabilityObjectives.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_O_LocVObj');
      FCWinMain.MMOptionSection_WideScreenBckg.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_O_WideScr');
      FCWinMain.MMOptionSection_StandardTexturesSection.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_O_TexR');
      FCWinMain.MMOptionSection_STS_1024.Caption:='1024*512';
      FCWinMain.MMOptionSection_STS_2048.Caption:='2048*1024';
      {.main menu - debug tools}
      FCWinMain.MMDebugSection.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_DebTools');
      FCWinMain.MMDebugSection_FUG.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_DTFUG');
      FCWinMain.MMDebugSection_ReloadTxtFiles.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_DTreloadTfiles');
		{.main menu - help section}
      FCWinMain.MM_HelpSection.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_Help');
      FCWinMain.MMHelpSection_HelpPanel.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_H_HPanel');
		FCWinMain.MMHelpSection_About.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_H_About');
	end;
   if (((UIUtp=mwupAll) or (UIUtp=mwupTextWinMain)) and (FCVdi3DViewRunning))
      or (UIUtp=mwupTextWM3dFrame)
   then
   begin
      {:DEV NOTES: put .main 3d view frame in a separated procedure and remove the mwupTextWM3dFrame switch.}
      {.main 3d view frame}
      FCWinMain.WM_MainViewGroup.Caption
         :=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_3dMainGrp.SSys')
            +' '+FCFdTFiles_UIStr_Get(dtfscPrprName,FCDduStarSystem[FC3doglCurrentStarSystem].SS_token)
            +']  '
            +FCFdTFiles_UIStr_Get(uistrUI,'FCWM_3dMainGrp.Star')
            +' '
            +FCFdTFiles_UIStr_Get(dtfscPrprName, FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_token)
            +']';
      {.help panel}
      FCWinMain.FCWM_HelpPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get(uistrUI,'FCWM_HelpPanel')+'</b>';
      FCWinMain.FCWM_HPdPad_Keys.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_HPdPad_Keys');
      FCWinMain.FCWM_HPdPad_KeysTxt1.HTMLText.Clear;
      FCWinMain.FCWM_HPdPad_KeysTxt1.HTMLText.Add(
         FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysRT' )+FCCFdHeadEnd
            +DHTMLalignLeft+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key less than ,.bmp">'+'  '+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysRT_speeddec' )+'<br>'
            +DHTMLalignLeft+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key more than ..bmp">'+'  '+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysRT_speedinc' )+'<br>'
            +DHTMLalignLeft+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key P.bmp">'+'  '+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysRT_pause' )+'<br>'
            +DHTMLalignLeft+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key enter.bmp">'+'  '+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysRT_reset' )+'<br>'
            +FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysTB' )+FCCFdHeadEnd
            +DHTMLalignLeft+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key less than ,.bmp">'+'  '+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysTB_turntypedec' )+'<br>'
            +DHTMLalignLeft+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key more than ..bmp">'+'  '+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysTB_turntypeinc' )+'<br>'
            +DHTMLalignLeft+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key enter.bmp">'+'  '+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysTB_endturntac' )+'<br>'
            +DHTMLalignLeft+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key shift.bmp">'+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key enter.bmp">'+'  '+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysTB_forcendindus' )+'<br>'
            +DHTMLalignLeft+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key control.bmp">'+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key enter.bmp">'+'  '+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysTB_forcendupkeep' )+'<br>'
            +DHTMLalignLeft+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key alt.bmp">'+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key enter.bmp">'+'  '+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysTB_forcendcolonial' )+'<br>'
            +DHTMLalignLeft+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key control.bmp">'+'<img src="file://'+FCVdiPathResourceDir+'pics-ui-keys\key space.bmp">'+'  '+FCFdTFiles_UIStr_Get( uistrUI, 'HelpKeysTB_forcendhistoric' )+'<br>'
         );
      FCWinMain.FCWM_HPdPad_KeysTxt2.HTMLText.Clear;
      FCWinMain.FCWM_HPdPad_KeysTxt3.HTMLText.Clear;
      FCWinMain.FCWM_HPDPhints.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_HPDPhints');
      FCDBhelpTdef:=nil;
      FCMdF_HelpTDef_Load;
      FCWinMain.FCWM_HDPhintsList.Items.Clear;
      UIUcnt:=1;
      UIUmax:=length(FCDBhelpTdef)-1;
      while UIUcnt<=UIUmax do
      begin
         FCWinMain.FCWM_HDPhintsList.Items.Add(FCDBhelpTdef[UIUcnt].TD_str);
         inc(UIUcnt);
      end;
      FCWinMain.FCWM_HDPhintsList.ItemIndex:=FCWinMain.FCWM_HDPhintsList.Items.Count-1;
      FCWinMain.FCWM_HDPhintsList.ItemIndex:=0;
      FCWinMain.FCWM_HDPhintsList.Selected[0]:=true;
      FCMuiW_HelpTDef_Link(FCDBhelpTdef[FCWinMain.FCWM_HDPhintsList.ItemIndex+1].TD_link, false);
      {.surface panel}
      FCWinMain.MVG_SurfacePanel.Caption.Text:='';
      FCWinMain.SP_AutoUpdateCheck.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'SP_AutoUpdateCheck');
      FCWinMain.SP_ResourceSurveyCommit.Caption:=FCFdTFiles_UIStr_Get( uistrUI, 'SP_ResourceSurveyCommit' );
      FCWinMain.SP_ResourceSurveyShowDetails.Caption:=FCFdTFiles_UIStr_Get( uistrUI, 'SP_ResourceSurveyDetails' );
      {.viability objectives panel}
      if Assigned(FCcps)
      then FCcps.CPSobjPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get(uistrUI, 'CPSobjPanel')+'</b>';
      {.colony data panel}
      FCWinMain.FCWM_ColDPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_ColDPanel')+'</b>';
      FCWinMain.FCWM_CDPcsme.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcsme');
      FCWinMain.FCWM_CDPinfr.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPinfr');
      FCWinMain.FCWM_CDPpopul.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPpopul');
      FCWinMain.FCWM_CDPstorage.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPstorage');
      FCWinMain.FCWM_CDPcolName.EditLabel.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcolName');
      {.UMI}
      FCWinMain.FCWM_UMI.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMI')+'</b>';
      FCWinMain.FCWM_UMI_TabShFac.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMI_TabShFac');
      FCWinMain.FCWM_UMI_TabShProd.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMI_TabShProd');
      FCWinMain.FCWM_UMI_TabShRDS.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMI_TabShRDS');
      FCWinMain.FCWM_UMI_TabShSpU.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMI_TabShSpU');
      FCWinMain.FCWM_UMI_TabShUniv.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMI_TabShUniv');
      FCWinMain.FCWM_UMI_FacDatG.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMI_FacDatG');
      FCWinMain.FCWM_UMIFac_TabShPol.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMIFac_TabShPol');
      FCWinMain.FCWM_UMIFac_PolGvtDetails.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMIFac_PolGvtDetails');
      FCWinMain.FCWM_UMIFac_TabShSPM.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMIFac_TabShSPM');
      FCWinMain.FCWM_UMIFac_TabShSPMpol.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMIFac_TabShSPMpol');
      FCWinMain.FCWM_UMIFac_Colonies.Columns[0].Header:='<p align="center">'+FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMIFac_Colonies0');
      FCWinMain.FCWM_UMIFac_Colonies.Columns[1].Header:='<p align="center">'+FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMIFac_Colonies1');
      FCWinMain.FCWM_UMIFac_Colonies.Columns[2].Header:='<p align="center">'+FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMIFac_Colonies2');
      FCWinMain.FCWM_UMIFac_Colonies.Columns[3].Header:='<p align="center">'+FCFdTFiles_UIStr_Get(uistrUI, 'colDcohes');
      FCWinMain.FCWM_UMIFSh_AvailF.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfAvail');
      FCWinMain.FCWM_UMIFSh_CAPF.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfAProb');
      FCWinMain.FCWM_UMIFSh_ReqF.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqL');
      FCWinMain.FCWM_UMISh_CEnfF.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMISh_CEnfF');
      FCWinMain.FCWM_UMISh_CEFcommit.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMISh_CEFcommit');
      FCWinMain.FCWM_UMISh_CEFretire.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMISh_CEFretire');
      FCWinMain.FCWM_UMISh_CEFenforce.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMISh_CEFenforce');
      {.infrastructure panel}
      FCWinMain.FCWM_IPconfirmButton.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_IPconfirmButton');
      FCWinMain.FCWM_IPinfraKits.Caption:='Available Infrastructure Kits (choose one)';
      {.missions panel}
      FCWinMain.FCWMS_Grp_MSDG.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWMS_Grp_MSDG');
      FCWinMain.FCWMS_Grp_MCG.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWMS_Grp_MCG');
      FCWinMain.FCWMS_ButProceed.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'ButtProceed');
      FCWinMain.FCWMS_ButCancel.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'ButtCancel');
      FCWinMain.FCWMS_Grp_MCGColName.EditLabel.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcolName');
      FCWinMain.FCWMS_Grp_MCG_SetName.EditLabel.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMS_Grp_MCG_SetName');
      {.CPS report and settings}
      FCWinMain.FCWM_CPSreportSet.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'CPSrepSetTitle' )+'</b>';
      FCWinMain.FCWM_CPSRSbuttonConfirm.Caption:='OK';
      {.action panel}
      FCWinMain.AP_ColonyData.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'AP_ColonyData');
      FCWinMain.AP_OObjData.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'AP_OObjData');
      FCWinMain.AP_DetailedData.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'AP_DetailedData');
      FCWinMain.AP_DockingList.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'AP_DockingList');
      FCWinMain.AP_Separator1.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'AP_Missions');
      FCWinMain.AP_MissionColonization.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'AP_MissionColonization');
      FCWinMain.AP_MissionInterplanetaryTransit.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'AP_MissionInterplanetaryTransit');
      FCWinMain.AP_MissionCancel.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'AP_MissionCancel');
      {.planetary survey panel}
      FCMuiPS_Panel_InitText;
   end;
   //=======================================================================================
   {.this section concern only all texts of about window}
   if UIUtp=mwupTextWinAb
   then FCMuiA_Panel_InitText;
   //=======================================================================================
   {.this section concern only all texts of new game setup window}
   if UIUtp=mwupTextWinNGS
   then
   begin
      {.new game setup - groupbox}
      FCWinNewGSetup.FCWNGS_Frame.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWNGS_Frame');
      FCWinNewGSetup.FCWNGS_Frm_GNameEdit.EditLabel.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWNGS_Frm_GNameEditEditLabel');
      FCWinNewGSetup.FCWNGS_Frm_ColMode.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWNGS_Frm_ColMode');
      FCWinNewGSetup.FCWNGS_Frm_DPad_SheetHisto.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWNGS_Frm_DPad_SheetHisto');
      FCWinNewGSetup.FCWNGS_Frm_DPad_SheetSPM.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWNGS_Frm_DPad_SheetSPM');
      FCWinNewGSetup.FCWNGS_Frm_DPad_SheetCol.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWNGS_Frm_DPad_SheetCol');
      FCWinNewGSetup.FCWNGS_Frm_DPad_SheetDotList.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWNGS_Frm_DPad_SheetDotList');
      {.button proceed}
      FCWinNewGSetup.FCWNGS_Frm_ButtProceed.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'ButtProceed');
      {.button cancel}
      FCWinNewGSetup.FCWNGS_Frm_ButtCancel.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'ButtCancel');
      {:DEV NOTES: upd the faction list}
   end;
   //=======================================================================================
   {.this section concern only all texts of saved games window}
   if UIUtp=mwupTextWinSavedGames
   then FCMuiSG_Panel_InitText;
   //=======================================================================================
   {.this section concern all graphical elements of main window w/o text
   initialization/update}
   if UIUtp=mwupAll
   then
   begin
      {.main window and descendants}
      FCWinMain.Constraints.MinWidth:=800;
      FCWinMain.Constraints.MinHeight:=600;
      FCWinMain.Width:=FCVdiWinMainWidth;
      FCWinMain.Height:=FCVdiWinMainHeight;
      FCWinMain.Left:=FCVdiWinMainLeft;
      FCWinMain.Top:=FCVdiWinMainTop;
      FCWinMain.DoubleBuffered:=true;
      UIUmainW2:=FCWinMain.Width shr 1;
      UIUmainH2:=FCWinMain.Height shr 1;
      {.background image}
      FCMuiW_BackgroundPicture_Update;
      {.continue game menu item}
      if FCVdgPlayer.P_gameName=''
      then FCWinMain.MMGameSection_Continue.Enabled:=false
      else FCWinMain.MMGameSection_Continue.Enabled:=true;
      {.save game menu item}
      FCWinMain.MMGameSection_Save.Enabled:=false;
      FCWinMain.MMGameSection_SaveAndFlush.Enabled:=false;
      {.debug menu item + console}
      if FCVdiDebugMode
      then
      begin
         FCWinMain.MMDebugSection.Visible:=true;
         FCWinDebug:=TFCWinDebug.Create(Application);
         FCWinDebug.Visible:=true;
      end
      else FCWinMain.MMDebugSection.Visible:=false;
      {.docking list panel}
      FCWinMain.FCWM_DockLstPanel.Width:=200;
      FCWinMain.FCWM_DockLstPanel.Height:=450;
      {.help panel}
      FCWinMain.FCWM_HelpPanel.Width:=840;
      FCWinMain.FCWM_HelpPanel.Height:=440;
      FCWinMain.FCWM_HPdPad_KeysTxt1.Width:=( FCWinMain.FCWM_HelpPanel.Width div 3 ) - 6;
      FCWinMain.FCWM_HPdPad_KeysTxt2.Width:=FCWinMain.FCWM_HPdPad_KeysTxt1.Width;
      FCWinMain.FCWM_HPdPad_KeysTxt3.Width:=FCWinMain.FCWM_HPdPad_KeysTxt1.Width;
      FCWinMain.FCWM_HDPhintsList.Width:=(FCWinMain.FCWM_HelpPanel.Width shr 5*14)-5;
      FCWinMain.FCWM_HDPhintsText.Width:=(FCWinMain.FCWM_HelpPanel.Width shr 5*18);
      {.surface panel}
      FCMuiSP_Panel_InitElements;
      {.colony data panel}
      FCWinMain.FCWM_ColDPanel.Width:=1024;//784;
      FCWinMain.FCWM_ColDPanel.Height:=350;
      FCWinMain.FCWM_CDPinfo.Width:=260;
      FCWinMain.FCWM_CDPinfo.Height:=229;
      FCWinMain.FCWM_CDPinfo.Left:=1;
      FCWinMain.FCWM_CDPinfo.Top:=0;
      FCWinMain.FCWM_CDPcolName.Width:=150;
      FCWinMain.FCWM_CDPcolName.Height:=20;
      FCWinMain.FCWM_CDPcolName.Left:=(FCWinMain.FCWM_CDPinfo.Width shr 1)-(FCWinMain.FCWM_CDPcolName.Width shr 1)+1;
      FCWinMain.FCWM_CDPcolName.Top:=36;
      FCWinMain.FCWM_CDPepi.Width:=FCWinMain.FCWM_ColDPanel.Width-FCWinMain.FCWM_CDPinfo.Width-FCWinMain.FCWM_CDPinfo.Left-2;
      FCWinMain.FCWM_CDPepi.Height:=269;
      FCWinMain.FCWM_CDPepi.Left:=FCWinMain.FCWM_CDPinfo.Left+FCWinMain.FCWM_CDPinfo.Width+2;
      FCWinMain.FCWM_CDPepi.Top:=19;
      FCWinMain.FCWM_CDPepi.ActivePage:=FCWinMain.FCWM_CDPpopul;
      FCWinMain.FCWM_CDPpopList.Width:=(FCWinMain.FCWM_CDPepi.Width shr 1)-2;
      FCWinMain.FCWM_CDPpopType.Width:=FCWinMain.FCWM_CDPpopList.Width;
      FCWinMain.FCWM_CDPinfrList.Width:=FCWinMain.FCWM_CDPepi.Width shr 1;
      FCWinMain.FCWM_CDPinfrAvail.Width:=FCWinMain.FCWM_CDPinfrList.Width-2;
      FCWinMain.FCWM_CDPwcpAssign.Width:=64;
      FCWinMain.FCWM_CDPwcpAssign.Height:=16;
      FCWinMain.FCWM_CDPwcpAssign.Left:=162;
      FCWinMain.FCWM_CDPwcpAssign.Top:=198;
      FCWinMain.FCWM_CDPwcpAssign.Visible:=false;
      FCWinMain.FCWM_CDPcwpAssignVeh.Width:=FCWinMain.FCWM_CDPwcpAssign.Width;
      FCWinMain.FCWM_CDPcwpAssignVeh.Height:=FCWinMain.FCWM_CDPwcpAssign.Height;
      FCWinMain.FCWM_CDPcwpAssignVeh.Left:=FCWinMain.FCWM_CDPwcpAssign.Left;
      FCWinMain.FCWM_CDPcwpAssignVeh.Top:=FCWinMain.FCWM_CDPwcpAssign.Top;
      FCWinMain.FCWM_CDPcwpAssignVeh.Visible:=false;
      FCWinMain.FCWM_CDPwcpEquip.Width:=192;
      FCWinMain.FCWM_CDPwcpEquip.Height:=20;
      FCWinMain.FCWM_CDPwcpEquip.Left:=162-134;
      FCWinMain.FCWM_CDPwcpEquip.Top:=216+24;
      FCWinMain.CDPstorageList.Width:=( FCWinMain.FCWM_CDPepi.Width div 15 * 6 )-2;
      FCWinMain.CDPstorageCapacity.Width:=( FCWinMain.FCWM_CDPepi.Width div 15 * 3 )-2;
      FCWinMain.CDPproductionMatrixList.Width:=FCWinMain.FCWM_CDPepi.Width-FCWinMain.CDPstorageList.Width-FCWinMain.CDPstorageCapacity.Width-8;
      {.UMI}
      FCWinMain.FCWM_UMI.Width:=FCVdiUMIconstraintWidth;
      FCWinMain.FCWM_UMI.Height:=FCVdiUMIconstraintHeight;
      FCWinMain.FCWM_UMI.Left:=UIUmainW2-(FCWinMain.FCWM_UMI.Width shr 1);
      FCWinMain.FCWM_UMI.Top:=UIUmainH2-(FCWinMain.FCWM_UMI.Height shr 1);
      FCWinMain.FCWM_UMI_TabSh.ActivePage:=FCWinMain.FCWM_UMI_TabShUniv;
      FCWinMain.FCWM_UMI_FacDatG.Height:=96;
      FCWinMain.FCWM_UMI_FacLvl.Width:=32;
      FCWinMain.FCWM_UMI_FacLvl.Height:=32;
      FCWinMain.FCWM_UMI_FacLvl.Top:=56;
      FCWinMain.FCWM_UMI_FacLvl.Max:=10;
      FCWinMain.FCWM_UMI_FacLvl.Segments:=10;
      FCWinMain.FCWM_UMI_FacLvl.Position:=0;
      FCWinMain.FCWM_UMI_FDLvlVal.Width:=( FCWinMain.FCWM_UMI_FacLvl.Width shr 4 * 5 )-3;
      FCWinMain.FCWM_UMI_FDLvlVal.Height:=FCWinMain.FCWM_UMI_FacLvl.Height shr 4 * 5;
      FCWinMain.FCWM_UMI_FDLvlVal.Top:=FCWinMain.FCWM_UMI_FacLvl.Top+( FCWinMain.FCWM_UMI_FacLvl.Height shr 1)-( FCWinMain.FCWM_UMI_FDLvlVal.Height shr 1);
      FCWinMain.FCWM_UMI_FDLvlValDesc.Width:=FCWinMain.FCWM_UMI_FDLvlVal.Width;
      FCWinMain.FCWM_UMI_FDLvlValDesc.Height:=FCWinMain.FCWM_UMI_FacLvl.Height shr 1;
      FCWinMain.FCWM_UMI_FDLvlValDesc.Top:=FCWinMain.FCWM_UMI_FacLvl.Top+( FCWinMain.FCWM_UMI_FacLvl.Height shr 1)-( FCWinMain.FCWM_UMI_FDLvlValDesc.Height shr 1);
      FCWinMain.FCWM_UMI_FacEcon.Width:=FCWinMain.FCWM_UMI_FacLvl.Width;
      FCWinMain.FCWM_UMI_FacEcon.Height:=FCWinMain.FCWM_UMI_FacLvl.Height;
      FCWinMain.FCWM_UMI_FacEcon.Top:=FCWinMain.FCWM_UMI_FacLvl.Top;
      FCWinMain.FCWM_UMI_FacEcon.Max:=3;
      FCWinMain.FCWM_UMI_FacEcon.Segments:=3;
      FCWinMain.FCWM_UMI_FacEcon.Position:=0;
      FCWinMain.FCWM_UMI_FDEconVal.Width:=FCWinMain.FCWM_UMI_FDLvlVal.Width;
      FCWinMain.FCWM_UMI_FDEconVal.Height:=FCWinMain.FCWM_UMI_FDLvlVal.Height;
      FCWinMain.FCWM_UMI_FDEconVal.Top:=FCWinMain.FCWM_UMI_FDLvlVal.Top;
      FCWinMain.FCWM_UMI_FDEconValDesc.Width:=FCWinMain.FCWM_UMI_FDLvlVal.Width;
      FCWinMain.FCWM_UMI_FDEconValDesc.Height:=FCWinMain.FCWM_UMI_FDLvlValDesc.Height;
      FCWinMain.FCWM_UMI_FDEconValDesc.Top:=FCWinMain.FCWM_UMI_FDLvlValDesc.Top;
      FCWinMain.FCWM_UMI_FacSoc.Width:=FCWinMain.FCWM_UMI_FacLvl.Width;
      FCWinMain.FCWM_UMI_FacSoc.Height:=FCWinMain.FCWM_UMI_FacLvl.Height;
      FCWinMain.FCWM_UMI_FacSoc.Top:=FCWinMain.FCWM_UMI_FacLvl.Top;
      FCWinMain.FCWM_UMI_FacSoc.Max:=3;//FCWinMain.FCWM_UMI_FacEcon.Max;
      FCWinMain.FCWM_UMI_FacSoc.Segments:=3;//FCWinMain.FCWM_UMI_FacEcon.Segments;
      FCWinMain.FCWM_UMI_FacSoc.Position:=FCWinMain.FCWM_UMI_FacEcon.Position;
      FCWinMain.FCWM_UMI_FDSocVal.Width:=FCWinMain.FCWM_UMI_FDLvlVal.Width;
      FCWinMain.FCWM_UMI_FDSocVal.Height:=FCWinMain.FCWM_UMI_FDLvlVal.Height;
      FCWinMain.FCWM_UMI_FDSocVal.Top:=FCWinMain.FCWM_UMI_FDLvlVal.Top;
      FCWinMain.FCWM_UMI_FDSocValDesc.Width:=FCWinMain.FCWM_UMI_FDLvlVal.Width;
      FCWinMain.FCWM_UMI_FDSocValDesc.Height:=FCWinMain.FCWM_UMI_FDLvlValDesc.Height;
      FCWinMain.FCWM_UMI_FDSocValDesc.Top:=FCWinMain.FCWM_UMI_FDLvlValDesc.Top;
      FCWinMain.FCWM_UMI_FacMil.Width:=FCWinMain.FCWM_UMI_FacLvl.Width;
      FCWinMain.FCWM_UMI_FacMil.Height:=FCWinMain.FCWM_UMI_FacLvl.Height;
      FCWinMain.FCWM_UMI_FacMil.Top:=FCWinMain.FCWM_UMI_FacLvl.Top;
      FCWinMain.FCWM_UMI_FacMil.Max:=3;//FCWinMain.FCWM_UMI_FacEcon.Max;
      FCWinMain.FCWM_UMI_FacMil.Segments:=3;//FCWinMain.FCWM_UMI_FacEcon.Segments;
      FCWinMain.FCWM_UMI_FacMil.Position:=FCWinMain.FCWM_UMI_FacEcon.Position;
      FCWinMain.FCWM_UMI_FDMilVal.Width:=FCWinMain.FCWM_UMI_FDLvlVal.Width;
      FCWinMain.FCWM_UMI_FDMilVal.Height:=FCWinMain.FCWM_UMI_FDLvlVal.Height;
      FCWinMain.FCWM_UMI_FDMilVal.Top:=FCWinMain.FCWM_UMI_FDLvlVal.Top;
      FCWinMain.FCWM_UMI_FDMilValDesc.Width:=FCWinMain.FCWM_UMI_FDLvlVal.Width;
      FCWinMain.FCWM_UMI_FDMilValDesc.Height:=FCWinMain.FCWM_UMI_FDLvlValDesc.Height;
      FCWinMain.FCWM_UMI_FDMilValDesc.Top:=FCWinMain.FCWM_UMI_FDLvlValDesc.Top;
      FCWinMain.FCWM_UMIFac_TabSh.Height:=FCWinMain.FCWM_UMI_TabShFac.Height-FCWinMain.FCWM_UMI_FacDatG.Height-8;
      FCWinMain.FCWM_UMIFac_TabSh.ActivePage:=FCWinMain.FCWM_UMIFac_TabShPol;
      FCWinMain.FCWM_UMIFac_PolGvtDetails.Width:=150;
      FCWinMain.FCWM_UMISh_CEFcommit.Width:=140;
      FCWinMain.FCWM_UMISh_CEFcommit.Height:=26;
      FCWinMain.FCWM_UMISh_CEFcommit.Enabled:=false;
      FCWinMain.FCWM_UMISh_CEFenforce.Width:=FCWinMain.FCWM_UMISh_CEFcommit.Width;
      FCWinMain.FCWM_UMISh_CEFenforce.Height:=FCWinMain.FCWM_UMISh_CEFcommit.Height;
      FCWinMain.FCWM_UMISh_CEFenforce.Enabled:=false;
      FCWinMain.FCWM_UMISh_CEFretire.Width:=FCWinMain.FCWM_UMISh_CEFcommit.Width;
      FCWinMain.FCWM_UMISh_CEFretire.Height:=FCWinMain.FCWM_UMISh_CEFcommit.Height;
      FCWinMain.FCWM_UMISh_CEFretire.Left:=2;
      FCWinMain.FCWM_UMISh_CEFretire.Enabled:=false;
      {.infrastructure panel}
      FCWinMain.FCWM_InfraPanel.Width:=370;
      FCWinMain.FCWM_InfraPanel.Height:=250;
      FCWinMain.FCWM_IPconfirmButton.Left:=(FCWinMain.FCWM_InfraPanel.Width shr 1)-(FCWinMain.FCWM_IPconfirmButton.Width shr 1);
      FCWinMain.FCWM_IPconfirmButton.Top:=FCWinMain.FCWM_InfraPanel.Height-FCWinMain.FCWM_IPconfirmButton.Height-8;
      FCWinMain.FCWM_IPinfraKits.Width:=330;
      FCWinMain.FCWM_IPinfraKits.Height:=20;
      FCWinMain.FCWM_IPinfraKits.Left:=20;
      FCWinMain.FCWM_IPinfraKits.Top:=84;
      {.missions panel}
      FCWinMain.FCWM_MissionSettings.Width:=FCWinMain.MVG_SurfacePanel.Width;//800;
      FCWinMain.FCWM_MissionSettings.Height:=280;
      FCWinMain.FCWM_MissionSettings.Left:=12;
      FCWinMain.FCWM_MissionSettings.Top:=20;
      {.mission data group}
      FCWinMain.FCWMS_Grp_MSDG.Width:=(FCWinMain.FCWM_MissionSettings.Width shr 1)-6;
      FCWinMain.FCWMS_Grp_MSDG.Height:=FCWinMain.FCWM_MissionSettings.Height-24;
      FCWinMain.FCWMS_Grp_MSDG.Left:=4;
      FCWinMain.FCWMS_Grp_MSDG.Top:=24;
      {.mission configuration group}
      FCWinMain.FCWMS_Grp_MCG.Width:=FCWinMain.FCWMS_Grp_MSDG.Width;
      FCWinMain.FCWMS_Grp_MCG.Height:=FCWinMain.FCWMS_Grp_MSDG.Height;
      FCWinMain.FCWMS_Grp_MCG.Left:=FCWinMain.FCWMS_Grp_MSDG.Left+FCWinMain.FCWMS_Grp_MSDG.Width+4;
      FCWinMain.FCWMS_Grp_MCG.Top:=FCWinMain.FCWMS_Grp_MSDG.Top;
      {.mission configuration background panel}
      FCWinMain.FCWMS_Grp_MCG_DatDisp.Width:=FCWinMain.FCWMS_Grp_MCG.Width shr 1;
      {.mission configuration data panel}
      FCWinMain.FCWMS_Grp_MCG_MissCfgData.Width:=FCWinMain.FCWMS_Grp_MCG_DatDisp.Width;
      {.mission configuration trackbar}
      FCWinMain.FCWMS_Grp_MCG_RMassTrack.Width:=170;
      FCWinMain.FCWMS_Grp_MCG_RMassTrack.Height:=50;
      {.cancel button}
      FCWinMain.FCWMS_ButCancel.Width:=116;
      FCWinMain.FCWMS_ButCancel.Height:=26;
      FCWinMain.FCWMS_ButCancel.Left:=8;
      FCWinMain.FCWMS_ButCancel.Top:=FCWinMain.FCWMS_Grp_MCG.Height-FCWinMain.FCWMS_ButCancel.Height-8;
      {.proceed button}
      FCWinMain.FCWMS_ButProceed.Width:=FCWinMain.FCWMS_ButCancel.Width;
      FCWinMain.FCWMS_ButProceed.Height:=FCWinMain.FCWMS_ButCancel.Height;
      FCWinMain.FCWMS_ButProceed.Left:=FCWinMain.FCWMS_Grp_MCG.Width-FCWinMain.FCWMS_ButProceed.Width-8;
      FCWinMain.FCWMS_ButProceed.Top:=FCWinMain.FCWMS_ButCancel.Top;
      {.CPS report and settings}
      FCWinMain.FCWM_CPSreportSet.Width:=560;
      FCWinMain.FCWM_CPSreportSet.Height:=330;
      FCWinMain.FCWM_CPSRSIGscores.Width:=180;
      FCWinMain.FCWM_CPSRSinfogroup.Width:=FCWinMain.FCWM_CPSreportSet.Width-8-FCWinMain.FCWM_CPSRSIGscores.Width;
      {.action panel}
      FCWinMain.WM_ActionPanel.Width:=197;
      {.planetary survey panel}
      FCMuiPS_Panel_InitElements;
   end;
   if UIUtp<>mwupAll
   then
   begin
      {.optimization}
      UIUmainW2:=FCWinMain.Width shr 1;
      UIUmainH2:=FCWinMain.Height shr 1;
   end;
   //=======================================================================================
   {.this section concern all graphical elements of message box w/o text
   initialization/update}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupMsgeBox)
   then
   begin
      {.message box}
      FCWinMain.FCWM_MsgeBox.Width:=430;
      FCWinMain.FCWM_MsgeBox.Height:=FCWinMain.Height div 6;
      FCWinMain.FCWM_MsgeBox.Left:=UIUmainW2-(FCWinMain.FCWM_MsgeBox.Width shr 1);
      FCWinMain.FCWM_MsgeBox.Top:=FCWinMain.Height-FCWinMain.FCWM_MsgeBox.Height-48;
      FCWinMain.FCWM_MsgeBox.Tag:=0;
      {.message box - messages list}
      FCWinMain.FCWM_MsgeBox_List.Width:=FCWinMain.FCWM_MsgeBox.Width-4;
      FCWinMain.FCWM_MsgeBox_List.Height:=(FCWinMain.FCWM_MsgeBox.Height)-22;
      FCWinMain.FCWM_MsgeBox_List.Left:=2;
      FCWinMain.FCWM_MsgeBox_List.Top:=20;
      {.message box - message description}
      FCWinMain.FCWM_MsgeBox_Desc.Width:=FCWinMain.FCWM_MsgeBox_List.Width;
      FCWinMain.FCWM_MsgeBox_Desc.Height:=FCWinMain.FCWM_MsgeBox.Height-(FCWinMain.FCWM_MsgeBox_List.Height+22);
      FCWinMain.FCWM_MsgeBox_Desc.Left:=FCWinMain.FCWM_MsgeBox_List.Left;
      FCWinMain.FCWM_MsgeBox_Desc.Top:=FCWinMain.FCWM_MsgeBox_List.Top+FCWinMain.FCWM_MsgeBox_List.Height;
      FCWinMain.FCWM_MsgeBox_Desc.Visible:=false;
      FCWinMain.FCWM_MsgeBox_Desc.Align:=alBottom;
   end;
   //=======================================================================================
   {.this section concern all graphical elements of about window w/o text initialization/update}
   if (UIUtp=mwupSecwinAbout)
      and (FCVdiWinAboutAllowUpdate)
   then FCMuiA_Panel_InitElements;
   //=======================================================================================
   {.this section concern all graphical elements of new game setup window w/o text initialization/update}
   if (UIUtp=mwupSecWinNewGSetup)
      and (FCVdiWinNewGameAllowUpdate)
   then
   begin
      {.new game setup window}
      with FCWinNewGSetup do
      begin
         FCWinNewGSetup.Width:=760;
         FCWinNewGSetup.Height:=462;
         FCWinNewGSetup.Left:=FCWinMain.Left+UIUmainW2-(FCWinNewGSetup.Width shr 1);
         FCWinNewGSetup.Top:=FCWinMain.Top+UIUmainH2-(FCWinNewGSetup.Height shr 1)+40;
         FCWinNewGSetup.DoubleBuffered:=true;
         {.groupbox interface root}
	      {.game name input}
         FCWNGS_Frm_GNameEdit.Width:=240;
         FCWNGS_Frm_GNameEdit.Left:=4;
         FCWNGS_Frm_GNameEdit.Top:=32;
         {.colonization mode}
         FCWNGS_Frm_ColMode.Width:=FCWNGS_Frm_GNameEdit.Width;
         FCWNGS_Frm_ColMode.Left:=FCWNGS_Frm_GNameEdit.Left;
         FCWNGS_Frm_ColMode.Top:=FCWNGS_Frm_GNameEdit.Top+FCWNGS_Frm_GNameEdit.Height+8;
	      {.faction list}
         FCWNGS_Frm_FactionList.Width:=FCWNGS_Frm_GNameEdit.Width;
	      FCWNGS_Frm_FactionList.Height:=FCWinNewGSetup.Height-(FCWNGS_Frm_GNameEdit.Top+FCWNGS_Frm_GNameEdit.Height+FCWNGS_Frm_ColMode.Height+26);
	      FCWNGS_Frm_FactionList.Left:=FCWNGS_Frm_GNameEdit.Left;
         FCWNGS_Frm_FactionList.Top:=FCWNGS_Frm_ColMode.Top+FCWNGS_Frm_ColMode.Height+8;
		   {.faction data pad}
         FCWNGS_Frm_DataPad.Width:=Width-4-FCWNGS_Frm_GNameEdit.Width-8;
			FCWNGS_Frm_DataPad.Height:=FCWNGS_Frm_FactionList.Height+FCWNGS_Frm_ColMode.Height-8;
			FCWNGS_Frm_DataPad.Left:=FCWNGS_Frm_FactionList.Left+FCWNGS_Frm_FactionList.Width+4;
         FCWNGS_Frm_DataPad.Top:=82;
         FCWNGS_Frm_DataPad.ActivePageIndex:=0;
		   {.faction flag}
         FCWNGS_Frm_FactionFlag.Width:=100;
			FCWNGS_Frm_FactionFlag.Height:=66;
			FCWNGS_Frm_FactionFlag.Left
            :=FCWNGS_Frm_DataPad.Left+((FCWNGS_Frm_DataPad.Width shr 1)-(FCWNGS_Frm_FactionFlag.Width shr 1));
         FCWNGS_Frm_FactionFlag.Top:=12;
         {.commit button}
         FCWNGS_Frm_ButtProceed.Width:=116;
         FCWNGS_Frm_ButtProceed.Height:=26;
         FCWNGS_Frm_ButtProceed.Left:=FCWNGS_Frame.Width-FCWNGS_Frm_ButtProceed.Width-4;
         FCWNGS_Frm_ButtProceed.Top:=16;
         {.cancel button}
         FCWNGS_Frm_ButtCancel.Width:=FCWNGS_Frm_ButtProceed.Width;
         FCWNGS_Frm_ButtCancel.Height:=FCWNGS_Frm_ButtProceed.Height;
         FCWNGS_Frm_ButtCancel.Left:=FCWNGS_Frm_ButtProceed.Left;
         FCWNGS_Frm_ButtCancel.Top:=FCWNGS_Frm_ButtProceed.Top+FCWNGS_Frm_ButtProceed.Height+4;
      end; //==END== with FCWinNewGSetup ==//
   end; //==END== if (WUupdKind=mwupSecWinNewGSetup) and (FCVallowUpNGSWin) ==//
   //=======================================================================================
   {.this section concern all graphical elements of saved games window w/o text initialization/update}
   if (UIUtp=mwupSecwinSavedGames)
      and (FCVdiWinSavedGamesAllowUpdate)
   then FCMuiSG_Panel_InitElements;
   //=======================================================================================================
   {.this section update language submenus}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupMenuLang)
   then
   begin
      {.check status of language submenu items}
      if FCVdiLanguage='EN'
      then
      begin
         FCWinMain.MMOptionsSection_LS_EN.Checked:=true;
         FCWinMain.MMOptionsSection_LS_FR.Checked:=false;
         FCWinMain.MMOptionsSection_LS_SP.Checked:=false;
      end
      else if FCVdiLanguage='FR'
      then
      begin
         FCWinMain.MMOptionsSection_LS_EN.Checked:=false;
         FCWinMain.MMOptionsSection_LS_FR.Checked:=true;
         FCWinMain.MMOptionsSection_LS_SP.Checked:=false;
      end
      else if FCVdiLanguage='SP'
      then
      begin
         FCWinMain.MMOptionsSection_LS_EN.Checked:=false;
         FCWinMain.MMOptionsSection_LS_FR.Checked:=false;
         FCWinMain.MMOptionsSection_LS_SP.Checked:=true;
      end;
   end;
   //=======================================================================================================
   {.this section update panel locations submenus}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupMenuLoc)
   then
   begin
      if FCVdiLocStoreCPSobjPanel
      then FCWinMain.MMOptionSection_PLS_LocationViabilityObjectives.Checked:=true
      else if not FCVdiLocStoreCPSobjPanel
      then FCWinMain.MMOptionSection_PLS_LocationViabilityObjectives.Checked:=false;
      if FCVdiLocStoreHelpPanel
      then FCWinMain.MMOptionSection_PLS_LocationHelp.Checked:=true
      else if not FCVdiLocStoreHelpPanel
      then FCWinMain.MMOptionSection_PLS_LocationHelp.Checked:=false;
   end;
   //=======================================================================================================
   {.this section update widescreen submenu}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupMenuWideScr)
   then
   begin
      {.check status of language submenu items}
      if FCVdiWinMainWideScreen
      then FCWinMain.MMOptionSection_WideScreenBckg.Checked:=true
      else if not FCVdiWinMainWideScreen
      then FCWinMain.MMOptionSection_WideScreenBckg.Checked:=false;
   end;
   //=======================================================================================================
   {.this section update standard resolution submenus}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupMenuStex)
   then
   begin
      {.check status of standard texture resolution submenu items}
      if not FC3doglHRstandardTextures
      then
      begin
         FCWinMain.MMOptionSection_STS_1024.Checked:=true;
         FCWinMain.MMOptionSection_STS_2048.Checked:=false;
      end
      else if FC3doglHRstandardTextures
      then
      begin
         FCWinMain.MMOptionSection_STS_1024.Checked:=false;
         FCWinMain.MMOptionSection_STS_2048.Checked:=true;
      end;
   end;
   //=======================================================================================================
   {.this section update realtime/turn-based submenu}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupMenuRTturnBased)
   then
   begin
      if FCVdgPlayer.P_isTurnBased
      then FCWinMain.MMOptionSection_RealtimeTunrBasedSwitch.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'MMOptionSection_RealtimeTunrBasedSwitchTB')
      else FCWinMain.MMOptionSection_RealtimeTunrBasedSwitch.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'MMOptionSection_RealtimeTunrBasedSwitchRT');
   end;
   //=======================================================================================================
   {.this section concern all font setup}
   {:DEV NOTES: MWUPFONTALL MUST N O T BE USED IN APPLICATION INIT, USE IT FOR SIZE CHANGE}
   {.for main window}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupFontAll)
   then
   begin
      FCWinMain.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.WM_MainViewGroup.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBox);
      {.message box}
      FCWinMain.FCWM_MsgeBox.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_MsgeBox_List.Font.Size:=FCFuiW_Font_GetSize(uiwListItems);
      FCWinMain.FCWM_MsgeBox_Desc.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      {.docking list panel}
      FCWinMain.FCWM_DockLstPanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_DLP_DockList.Font.Size:=FCFuiW_Font_GetSize(uiwListItems);
      {.help panel}
      FCWinMain.FCWM_HelpPanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_HPdataPad.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_HPdPad_Keys.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_HPdPad_KeysTxt1.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_HPDPhints.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_HDPhintsList.Font.Size:=FCFuiW_Font_GetSize(uiwListItems);
      FCWinMain.FCWM_HDPhintsText.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      {.surface panel}
      FCWinMain.SP_AutoUpdateCheck.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.MVG_SurfacePanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
      FCWinMain.SP_RegionSheet.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.SP_EcosphereSheet.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.SP_RegionSheet.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.SP_FLND_Label.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      {.viability objectives panel}
      if Assigned(FCcps)
      then
      begin
         FCcps.CPSobjPanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
         FCcps.CPSobjP_List.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      end;
      {.colony data panel}
      FCWinMain.FCWM_ColDPanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_CDPinfo.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBox);
      FCWinMain.FCWM_CDPinfoText.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPpopList.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPpopType.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPepi.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_CDPpopul.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_CDPcsme.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_CDPcsmeList.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPinfr.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_CDPinfrList.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPinfrAvail.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPcolName.EditLabel.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPcolName.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPwcpAssign.EditLabel.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPwcpAssign.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPcwpAssignVeh.EditLabel.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPcwpAssignVeh.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPwcpEquip.Font.Size:=FCFuiW_Font_GetSize(uiwListItems);
      FCWinMain.FCWM_CDPwcpEquip.LabelFont.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.CDPstorageList.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.CDPstorageCapacity.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.CDPproductionMatrixList.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      {.UMI}
      FCWinMain.FCWM_UMI.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_UMI_TabSh.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_TabShUniv.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_TabShFac.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_TabShSpU.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_TabShProd.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_TabShRDS.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_FacDatG.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMIFac_TabSh.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMIFac_TabShPol.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMIFac_PolGvtDetails.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMIFac_PGDdata.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_Colonies.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_Colonies.HeaderSettings.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMIFac_Colonies.Columns[0].Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_Colonies.Columns[1].Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_Colonies.Columns[2].Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_Colonies.Columns[3].Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_TabShSPM.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMIFac_TabShSPMpol.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMIFSh_SPMadmin.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_SPMecon.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_SPMmedca.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_SPMsoc.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_SPMspol.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_SPMspi.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_AvailF.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMIFSh_AFlist.Font.Size:=FCFuiW_Font_GetSize(uiwListItems);
      FCWinMain.FCWM_UMIFSh_CAPF.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMIFSh_CAPFlab.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_ReqF.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMIFSh_RFdisp.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMISh_CEnfF.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMISh_CEFreslt.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMISh_CEFcommit.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      FCWinMain.FCWM_UMISh_CEFenforce.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      FCWinMain.FCWM_UMISh_CEFretire.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      FCWinMain.FCWM_UMI_FDLvlVal.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMI_FDLvlValDesc.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMI_FDEconVal.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMI_FDEconValDesc.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMI_FDMilVal.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMI_FDMilValDesc.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMI_FDSocVal.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMI_FDSocValDesc.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      {.infrastructure panel}
      FCWinMain.FCWM_InfraPanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_IPlabel.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_IPinfraKits.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_IPconfirmButton.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      {.missions panel}
      FCWinMain.FCWM_MissionSettings.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_MissionSettings.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWMS_Grp_MSDG.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWMS_Grp_MSDG_Disp.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWMS_Grp_MCG.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWMS_Grp_MCG_DatDisp.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWMS_Grp_MCGColName.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWMS_Grp_MCG_MissCfgData.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWMS_ButCancel.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      FCWinMain.FCWMS_ButProceed.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      FCWinMain.FCWMS_Grp_MCG_SetName.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWMS_Grp_MCG_SetType.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBoxSec);
      {.CPS report and settings}
      FCWinMain.FCWM_CPSreportSet.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_CPSRSIGscores.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CPSRSinfogroup.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_CPSRSIGreport.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CPSRSbuttonConfirm.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      {.action panel}
      FCWinMain.WM_ActionPanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
      FCWinMain.AP_ColonyData.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      FCWinMain.AP_OObjData.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      FCWinMain.AP_DetailedData.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      FCWinMain.AP_DockingList.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      FCWinMain.AP_MissionColonization.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      FCWinMain.AP_MissionInterplanetaryTransit.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      FCWinMain.AP_MissionCancel.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      {.planetary survey panel}
      FCMuiPS_Panel_InitFonts;
   end; //==END== if (UIUtp=mwupAll) or (UIUtp=mwupFontAll) ==//
   {.for about window}
   if ((UIUtp=mwupFontWinAb) or (UIUtp=mwupFontAll))
      and (FCVdiWinAboutAllowUpdate)
   then
   begin
      FCWinAbout.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      {.frame}
      FCWinAbout.WA_Frame.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBox);
      {.header}
      FCWinAbout.F_Header.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      {.main section}
      FCWinAbout.F_Credits.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
   end;
   {.for new game setup window}
   if ((UIUtp=mwupFontWinNGS) or (UIUtp=mwupFontAll))
      and (FCVdiWinNewGameAllowUpdate)
   then
   begin
      with FCWinNewGSetup do
      begin
         Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
         FCWNGS_Frame.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBox);
         {.game name edit}
         FCWNGS_Frm_GNameEdit.EditLabel.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
         FCWNGS_Frm_GNameEdit.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
         {.colonization mode}
         FCWNGS_Frm_ColMode.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
         {.faction's list}
         FCWNGS_Frm_FactionList.Font.Size:=FCFuiW_Font_GetSize(uiwListItems);
         {.data pad}
         FCWNGS_Frm_DataPad.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
         FCWNGS_Frm_DPad_SheetHisto.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
         FCWNGS_Frm_DPad_SHisto_Text.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
         FCWNGS_Frm_DPad_SheetSPM.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
         FCWNGS_FDPad_ShSPM_SPMList.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
         FCWNGS_Frm_DPad_SheetCol.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
         FCWNGS_Frm_DPad_SCol_Text.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
         FCWNGS_Frm_DPad_SheetDotList.Font.Size:=FCFuiW_Font_GetSize(uiwPageCtrl);
         FCWNGS_Frm_DPad_SDL_DotList.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
         {.buttons}
         FCWNGS_Frm_ButtProceed.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
         FCWNGS_Frm_ButtCancel.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
      end; {.with FCWinNewGSetup do}
   end;
   {.for saved games window}
   if ((UIUtp=mwupFontWinSavedGames) or (UIUtp=mwupFontAll))
      and (FCVdiWinSavedGamesAllowUpdate)
   then
   begin
      FCWinSavedGames.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      {.frame}
      FCWinSavedGames.WSG_Frame.Font.Size:=FCFuiW_Font_GetSize(uiwGrpBox);
      {.header}
      FCWinSavedGames.F_SavedGamesHeader.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
      {.main section}
      FCWinSavedGames.F_SavedGamesList.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
   end;
end;

procedure FCMuiW_WinAbout_Close;
{:Purpose: close the about window.
    Additions:
      -2010Apr06- *add: release the game if needed.
}
begin
   if FCVdi3DViewRunning
      and not FCVdi3DViewToInitialize then
   begin
      FCMgGF_Realtime_Restore;
      FCWinMain.WM_MainViewGroup.Show;
      FCVdi3DViewRunning:=true;
      FCWinMain.MMOptionSection_RealtimeTunrBasedSwitch.Enabled:=true;
   end;
   FCWinMain.Enabled:=true;
end;

procedure FCMuiW_WinAbout_Raise;
{:Purpose: show the about window.
    Additions:
      -2010Apr06- *add: pause the game.
      -2009Dec01- *small fix for always display the about window at the center of FARC
                  window.
}
begin
   if not Assigned( FCWinAbout ) then
   begin
      FCWinAbout:=TFCWinAbout.Create(Application);
      FCMuiW_UI_Initialize(mwupSecwinAbout);
      FCMuiW_UI_Initialize(mwupFontWinAb);
      FCMuiW_UI_Initialize(mwupTextWinAb);
   end;

   FCWinMain.Enabled:=false;
   if FCWinMain.WM_MainViewGroup.Visible then
   begin
      FCMgGF_Realtime_Pause;
      FCWinMain.WM_MainViewGroup.Hide;
   end;
   FCWinAbout.Enabled:=true;
   FCWinAbout.Show;
   FCWinAbout.BringToFront;
end;

procedure FCMuiW_WinNewGame_Close;
{:Purpose: close the new game window.
    Additions:
}
begin
   if FCVdi3DViewRunning
      and not FCVdi3DViewToInitialize then
   begin
      FCMgGF_Realtime_Restore;
      FCWinMain.WM_MainViewGroup.Show;
      FCVdi3DViewRunning:=true;
      FCWinMain.MMOptionSection_RealtimeTunrBasedSwitch.Enabled:=true;
   end;
   FCWinMain.Enabled:=true;
end;

procedure FCMuiW_WinNewGame_Raise;
{:Purpose: show the new game window.
    Additions:
}
begin
   if not Assigned( FCWinNewGSetup ) then
   begin
      FCWinNewGSetup:=TFCWinNewGSetup.Create(Application);
      FCMuiW_UI_Initialize(mwupSecWinNewGSetup);
      FCMuiW_UI_Initialize(mwupFontWinNGS);
   end;
   FCMuiW_UI_Initialize(mwupTextWinNGS);

   FCWinMain.Enabled:=false;
   if FCWinMain.WM_MainViewGroup.Visible then
   begin
      FCMgGF_Realtime_Pause;
      FCWinMain.WM_MainViewGroup.Hide;
   end;
   FCWinNewGSetup.Enabled:=true;
   FCWinNewGSetup.Show;
   FCWinNewGSetup.BringToFront;
   FCMgNG_Core_Setup;
end;

procedure FCMuiW_WinSavedGames_Close;
{:Purpose: close the saved games window.
    Additions:
}
begin
   if FCVdi3DViewRunning
      and not FCVdi3DViewToInitialize then
   begin
      FCMgGF_RealTime_Restore;
      FCWinMain.WM_MainViewGroup.Show;
      FCVdi3DViewRunning:=true;
      FCWinMain.MMOptionSection_RealtimeTunrBasedSwitch.Enabled:=true;
   end;
   FCWinMain.Enabled:=true;
end;

procedure FCMuiW_WinSavedGames_Raise;
{:Purpose: show the saved games window.
    Additions:
}
begin
   if not Assigned( FCWinSavedGames ) then
   begin
      FCWinSavedGames:=TFCWinSavedGames.Create(Application);
      FCMuiW_UI_Initialize(mwupSecwinSavedGames);
      FCMuiW_UI_Initialize(mwupFontWinSavedGames);
      FCMuiW_UI_Initialize(mwupTextWinSavedGames);
   end;

   FCWinMain.Enabled:=false;
   if FCWinMain.WM_MainViewGroup.Visible then
   begin
      FCMgGF_Realtime_Pause;
      FCWinMain.WM_MainViewGroup.Hide;
   end;
   FCMuiSG_SavedGamesList_Update;
   FCWinSavedGames.Enabled:=true;
   FCWinSavedGames.Show;
   FCWinSavedGames.BringToFront;
end;

end.

