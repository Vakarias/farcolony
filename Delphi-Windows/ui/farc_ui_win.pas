{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

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
   ,mwupTextWinMS
   ,mwupTextWinNGS
   ,mwupTextMenu
   ,mwupMenuLang
   ,mwupMenuLoc
   ,mwupMenuWideScr
   ,mwupMenuStex
   ,mwupSecwinAbout
   ,mwupSecwinDebug
   ,mwupSecwinMissSetup
   ,mwupSecWinNewGSetup
   ,mwupFontWinAb
   ,mwupFontWinMS
   ,mwupFontWinNGS
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
function FCMuiW_PercentColorGBad_Generate(const PCGBGpercent: integer): string;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   close the about window.
///</summary>
procedure FCMuiWin_About_Close;

///<summary>
///   show the about window.
///</summary>
procedure FCMuiWin_About_Raise;

///<summary>
///   update the background with the right choosen format.
///</summary>
procedure FCMuiWin_BckgdPic_Upd;

///<summary>
///   get correct font size of a targeted font class following the size of the window.
///</summary>
///    <param name="FGZftClass">font size class</param>
function FCFuiWin_Font_GetSize(const FGZftClass: TFCEuiwFtClass): integer;

///<summary>
///   store current size and location of the main window.
///</summary>
procedure FCMuiWin_MainWindow_StoreLocSiz;

///<summary>
///   update the popup menu of the focused object
///</summary>
///   <param nam="PPOFUtp">type of popup</param>
procedure FCMuiW_FocusPopup_Upd(const PPOFUtp: TFCEuiwPopupKind);

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
///   set and display the Surface / Ecosphere Panel
///</summary>
///    <param name="SESoobjIdx">targeted orbital object index</param>
///    <param name="SESsatIdx">[optional, disable by 0] targeted satellite index</param>
///    <param name="SESinit">init the hotspots</param>
procedure FCMuiWin_SurfEcos_Set(
   const SESoobjIdx
         ,SESsatIdx: integer;
   const SESinit: boolean
   );

///<summary>
///   update the region data and picture
///</summary>
///    <param name="SERUregIdx">targeted region index #</param>
///    <param name="SERUonlyPic">update only the region picture if true</param>
procedure FCMuiWin_SurfEcos_RegUpd(
   const SERUregIdx: integer;
   const SERUonlyPic: boolean
   );

///<summary>
///   initialize the terrains graphic collection
///</summary>
procedure FCMuiWin_TerrGfxColl_Init;

///<summary>
///   update interface for new language
///</summary>
procedure FCMuiWin_UI_LangUpd;

///<summary>
///   update and initialize all user's interface elements of the game.
///</summary>
///    <param name="WUupdKind">target to update.</param>
procedure FCMuiWin_UI_Upd(const UIUtp: TFCEmwinUpdTp);

implementation

uses
   farc_common_func
   ,farc_data_files
   ,farc_data_game
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_data_univ
   ,farc_data_textfiles
   ,farc_game_colony
   ,farc_game_cps
   ,farc_game_csm
   ,farc_game_csmevents
   ,farc_game_gameflow
   ,farc_game_infra
   ,farc_game_spm
   ,farc_game_spmdata
   ,farc_gfx_core
   ,farc_main
   ,farc_ogl_init
   ,farc_ogl_ui
   ,farc_spu_functions
   ,farc_ui_coldatapanel
   ,farc_ui_coredatadisplay
   ,farc_ui_msges
   ,farc_ui_umi
   ,farc_univ_func
   ,farc_win_about
   ,farc_win_debug
   ,farc_win_missset
   ,farc_win_newgset;

//===================================END OF INIT============================================

function FCMuiW_PercentColorGBad_Generate(const PCGBGpercent: integer): string;
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

procedure FCMuiWin_About_Close;
{:Purpose: close the about window.
    Additions:
      -2010Apr06- *add: release the game if needed.
}
begin
   FCWinAbout.Hide;
   FCWinAbout.Enabled:=false;
   if FCWinMain.FCWM_3dMainGrp.Tag=1 then
   begin
      FCMgTFlow_FlowState_Set(tphTac);
      FCWinMain.FCWM_3dMainGrp.Tag:=0;
      FCWinMain.FCWM_3dMainGrp.Show;
   end;
   FCWinMain.Enabled:=true;
end;

procedure FCMuiWin_About_Raise;
{:Purpose: show the about window.
    Additions:
      -2010Apr06- *add: pause the game.
      -2009Dec01- *small fix for always display the about window at the center of FARC
                  window.
}
begin
   FCMuiWin_UI_Upd(mwupSecwinAbout);
   FCWinMain.Enabled:=false;
   if FCWinMain.FCWM_3dMainGrp.Visible then
   begin
      FCMgTFlow_FlowState_Set(tphPAUSE);
      FCWinMain.FCWM_3dMainGrp.Tag:=1;
      FCWinMain.FCWM_3dMainGrp.Hide;
   end;
   FCWinAbout.Enabled:=true;
   FCWinAbout.Show;
   FCWinAbout.BringToFront;
end;

procedure FCMuiWin_BckgdPic_Upd;
{:Purpose: update the background with the right choosen format.
    Additions:
}
begin
   if FCVwinWideScr
   then FCWinMain.FCWM_BckgImage.Bitmap.LoadFromFile(FCVpathRsrc+'pics-ui-' +'desk\puidesk0w.jpg')
   else if not FCVwinWideScr
   then FCWinMain.FCWM_BckgImage.Bitmap.LoadFromFile(FCVpathRsrc+'pics-ui-' +'desk\puidesk0.jpg');
   FCMuiWin_UI_Upd(mwupMenuWideScr);
end;

function FCFuiWin_Font_GetSize(const FGZftClass: TFCEuiwFtClass): integer;
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
         if (FCVwinMsizeW>=1152)
            and (FCVwinMsizeH>=896)
         then Result:=9
         else result:=8;
      end;
      uiwDescText:
      begin
         if (FCVwinMsizeW>=1152)
            and (FCVwinMsizeH>=896)
         then Result:=10
         else result:=9;
      end;
      uiwGrpBox:
      begin
         if (FCVwinMsizeW>=1152)
            and (FCVwinMsizeH>=896)
         then Result:=9
         else result:=8;
      end;
      uiwGrpBoxSec:
      begin
         if (FCVwinMsizeW>=1152)
            and (FCVwinMsizeH>=896)
         then Result:=8
         else result:=7;
      end;
      uiwListItems:
      begin
         if (FCVwinMsizeW>=1152)
            and (FCVwinMsizeH>=896)
         then Result:=9
         else result:=8;
      end;
      uiwPageCtrl:
      begin
         if (FCVwinMsizeW>=1152)
            and (FCVwinMsizeH>=896)
         then Result:=8
         else result:=7;
      end;
      uiwPanelTitle:
      begin
         if (FCVwinMsizeW>=1152)
            and (FCVwinMsizeH>=896)
         then Result:=9
         else result:=8;
      end;
   end; {.case FGZftClass of}
end;

procedure FCMuiWin_MainWindow_StoreLocSiz;
{:Purpose: store current size and location of the main window.
   Additions:
}
begin
   FCVwinMsizeH:=FCWinMain.Height;
   FCVwinMsizeW:=FCWinMain.Width;
   FCVwinMlocL:=FCWinMain.Left;
   FCVwinMlocT:=FCWinMain.Top;
	FCMdF_ConfigFile_Write(false);
end;

procedure FCMuiWin_FocusPopup_Reset;
{:Purpose: reset all subroot items and items display.
    Additions:
      -2010Jun14- *add colony/faction data.
      -2010Apr06- *add Colonization Mission.
}
begin
   FCWinMain.FCWM_PMFOcolfacData.Visible:=false;
   FCWinMain.FCWM_PMFOoobjData.Visible:=false;
   FCWinMain.FCWM_PMFO_DList.Visible:=false;
   FCWinMain.FCWM_PMFO_MissCancel.Visible:=false;
   FCWinMain.FCWM_PMFO_Header_Travel.Visible:=false;
   FCWinMain.FCWM_PMFO_MissITransit.Visible:=false;
   FCWinMain.FCWM_PMFO_HeaderSpecMiss.Visible:=false;
   FCWinMain.FCWM_PMFO_MissColoniz.Visible:=false;
end;

procedure FCMuiW_FocusPopup_Upd(const PPOFUtp: TFCEuiwPopupKind);
{:Purpose: update the popup menu of the focused object.
    Additions:
      -2010Sep19- *add: entities code.
      -2010Jun20- *fix: correct the colonization menu item when no colony is settled and cps is enabled.
      -2010Jun16- *mod: change ecosphere/surface and colony data panel menu items display.
      -2010Jun14- *add colony/faction data.
      -2010Apr26- *add: a condition for colonization menu, the focused space unit must have LVs aboard.
      -2010Mar27- *add: docking list submenu item.
      -2010Mar20- *fix: prevent ecosphere / surface menu item to be displayed when a star is
                  selected.
      -2010Jan21- *add: ecosphere/surface orbital object's menu item.
      -2009Nov26- *code cleanup.
                  *display correctly Travel Missions header.
      -2009Sep29- *hide travel header when an orbital object is focused.
      -2009Sep28- *gather owned spacecraft indexes.
                  *initialize "cancel mission" menu item.
}
var
   FPUcolN
   ,FPUdmpIdx
   ,FPUdmpOldIdx
   ,FPUdmpTaskId
   ,FPUlvNum
   ,FPUspUoobj
   ,FPUspUsat
   ,FPUspUssys
   ,FPUspUstar: integer;

   FPUdmpSpUnStatus: TFCEspUnStatus;
begin
   {.orbital object menu setup}
   if PPOFUtp=uiwpkOrbObj
   then
   begin
      {.menu initialize}
      FCMuiWin_FocusPopup_Reset;
      {.menu main header}
      FCWinMain.FCWM_PMFO_Header_SpUnitOObj.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_PMFO_Header_SpUnitOObj.OObj');
      {.colony/faction data}
      if (
         (FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3DobjGrp[FCV3DselOobj])
         and (FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[FCV3DselOobj].OO_colonies[0]>0)
         )
         or
         (
         (FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3DobjSatGrp[FCV3DselOobj])
         and (FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[FCV3DselOobj].OO_satList[FCV3DselSat].OOS_colonies[0]>0)
         )
      then
      begin
         FCWinMain.FCWM_PMFOcolfacData.Visible:=true;
         FCWinMain.FCWM_PMFOoobjData.Visible:=false;
      end
      else if FCV3DselOobj>0
      then FCWinMain.FCWM_PMFOoobjData.Visible:=true;
   end {.if FPUkind= uiwpkOrbObj}
   {.space unit menu setup}
   else if PPOFUtp=uiwpkSpUnit
   then
   begin
      {.menu initialize and gather owned space unit data}
      FCMuiWin_FocusPopup_Reset;
      FPUdmpIdx:=round(FC3DobjSpUnit[FCV3DselSpU].TagFloat);
      FPUdmpTaskId:=FCentities[0].E_spU[FPUdmpIdx].SUO_taskIdx;
      FPUdmpSpUnStatus:=FCentities[0].E_spU[FPUdmpIdx].SUO_status;
      FPUspUssys:=FCFuF_StelObj_GetDbIdx(
         ufsoSsys
         ,FCentities[0].E_spU[FPUdmpIdx].SUO_starSysLoc
         ,0
         ,0
         ,0
         );
      FPUspUstar:=FCFuF_StelObj_GetDbIdx(
         ufsoStar
         ,FCentities[0].E_spU[FPUdmpIdx].SUO_starLoc
         ,FPUspUssys
         ,0
         ,0
         );
      FPUspUoobj:=FCFuF_StelObj_GetDbIdx(
         ufsoOObj
         ,FCentities[0].E_spU[FPUdmpIdx].SUO_oobjLoc
         ,FPUspUssys
         ,FPUspUstar
         ,0
         );
      if FCentities[0].E_spU[FPUdmpIdx].SUO_satLoc<>''
      then FPUspUsat:=FCFuF_StelObj_GetDbIdx(
         ufsoSat
         ,FCentities[0].E_spU[FPUdmpIdx].SUO_satLoc
         ,FPUspUssys
         ,FPUspUstar
         ,FPUspUoobj
         );
      {.menu main header}
      FCWinMain.FCWM_PMFO_Header_SpUnitOObj.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_PMFO_Header_SpUnitOObj.SpUnit');
      {.docking list}
      if length(FCentities[0].E_spU[FPUdmpIdx].SUO_dockedSU)>1
      then FCWinMain.FCWM_PMFO_DList.Visible:=true;
      {.detailed data subitem}
      {DEV NOTE: to add when i'll implement a detailed data panel.}
      {.cancel current mission subitem}
      if FPUdmpTaskId>0
      then FCWinMain.FCWM_PMFO_MissCancel.Visible:=true;
      {.START POINT OF TRAVEL MISSIONS}
      {.interplanetary transit menu item}
      if (FPUdmpSpUnStatus in [susInFreeSpace..susDocked])
         and(FPUdmpTaskId=0)
      then
      begin
         FCWinMain.FCWM_PMFO_Header_Travel.Visible:=true;
         FCWinMain.FCWM_PMFO_MissITransit.Visible:=true;
      end;
      {.START POINT OF SPECIFIC MISSIONS}
      {.colonization menu item}
      FPUlvNum:=FCFspuF_DockedSpU_GetNum(
         0
         ,FPUdmpIdx
         ,scarchtpLV
         ,sufcAny
         );
      FPUcolN:=length(FCentities[0].E_col)-1;
      if (FPUdmpSpUnStatus=susInOrbit)
         and (FPUlvNum>0)
         {:DEV NOTES: when eq mdl done, change the line below for more complex code testing
      colonization equipment module and/or have docked colonization pods.}
         and (FCentities[0].E_spU[FPUdmpIdx].SUO_nameToken='wrdMUNmov')
         and (
            not assigned(FCcps)
            or (
               assigned(FCcps)
               and (
                     (FPUcolN=0)
                     or
                     (
                        (FPUcolN=1)
                        and(FPUspUsat=0)
                        and (FCDBsSys[FPUspUssys].SS_star[FPUspUstar].SDB_obobj[FPUspUoobj].OO_colonies[0]>0)
                        )
                     or
                     (
                        (FPUcolN=1)
                        and (FPUspUsat>0)
                        and (FCDBsSys[FPUspUssys].SS_star[FPUspUstar].SDB_obobj[FPUspUoobj].OO_satList[FPUspUsat].OOS_colonies[0]>0)
                        )
                     )
                  )
               )
      then
      begin
         FCWinMain.FCWM_PMFO_HeaderSpecMiss.Visible:=true;
         FCWinMain.FCWM_PMFO_MissColoniz.Visible:=true;
      end;
   end; //==END== else if FPUkind= uiwpkSpUnit ==//
end;

function FCFuiWin_SurfEcosAtm_Proc(
   const SEAPlist: TFCEatmGasStat;
   const SEAPoobjIdx
         ,SEAPsatIdx: integer
   ): string;
{:Purpose: process the required atmosphere list.
    Additions:
}
var
   SAEPres: string;
   SAEPisNxtCol: boolean;
   SEAPgasH2
   ,SEAPgasHe
   ,SEAPgasCH4
   ,SEAPgasNH3
   ,SEAPgasH2O
   ,SEAPgasNe
   ,SEAPgasN2
   ,SEAPgasCO
   ,SEAPgasNO
   ,SEAPgasO2
   ,SEAPgasH2S
   ,SEAPgasAr
   ,SEAPgasCO2
   ,SEAPgasNO2
   ,SEAPgasO3
   ,SEAPgasSO2: TFCEatmGasStat;
begin
   SAEPres:='';
   SAEPisNxtCol:=false;
   if SEAPsatIdx=0
   then
   begin
      SEAPgasH2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasH2;
      SEAPgasHe:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasHe;
      SEAPgasCH4:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasCH4;
      SEAPgasNH3:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasNH3;
      SEAPgasH2O:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasH2O;
      SEAPgasNe:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasNe;
      SEAPgasN2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasN2;
      SEAPgasCO:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasCO;
      SEAPgasNO:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasNO;
      SEAPgasO2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasO2;
      SEAPgasH2S:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasH2S;
      SEAPgasAr:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasAr;
      SEAPgasCO2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasCO2;
      SEAPgasNO2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasNO2;
      SEAPgasO3:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasO3;
      SEAPgasSO2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasSO2;
   end
   else if SEAPsatIdx>0
   then
   begin
      SEAPgasH2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasH2;
      SEAPgasHe
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasHe;
      SEAPgasCH4
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasCH4;
      SEAPgasNH3
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasNH3;
      SEAPgasH2O
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasH2O;
      SEAPgasNe
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasNe;
      SEAPgasN2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasN2;
      SEAPgasCO
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasCO;
      SEAPgasNO
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasNO;
      SEAPgasO2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasO2;
      SEAPgasH2S
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasH2S;
      SEAPgasAr
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasAr;
      SEAPgasCO2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasCO2;
      SEAPgasNO2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasNO2;
      SEAPgasO3
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasO3;
      SEAPgasSO2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasSO2;
   end;
   {.for hydrogen}
   if SEAPgasH2=SEAPlist
   then
   begin
      SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasH2');
      SAEPisNxtCol:=true;
   end;
   {.for helium}
   if SEAPgasHe=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasHe');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasHe');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for methane}
   if SEAPgasCH4=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasCH4');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasCH4');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for ammonia}
   if SEAPgasNH3=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasNH3');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasNH3');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for water vapor}
   if SEAPgasH2O=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasH2O');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasH2O');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for neon}
   if SEAPgasNe=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasNe');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasNe');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for nitrogen}
   if SEAPgasN2=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasN2');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasN2');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for carbone monoxide}
   if SEAPgasCO=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasCO');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasCO');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for nitrogen oxide}
   if SEAPgasNO=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasNO');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasNO');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for oxygen}
   if SEAPgasO2=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasO2');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasO2');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for hydrogen sulfide}
   if SEAPgasH2S=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasH2S');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasH2S');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for argon}
   if SEAPgasAr=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasAr');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasAr');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for carbone dioxide}
   if SEAPgasCO2=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasCO2');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasCO2');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for nitrogen dioxide}
   if SEAPgasNO2=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasNO2');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasNO2');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for ozone}
   if SEAPgasO3=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasO3');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasO3');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for sulfur dioxide}
   if SEAPgasSO2=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasSO2')
      else if SAEPisNxtCol
      then SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasSO2');
   end;
   Result:=SAEPres;
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
   SUDUdsgn:=FCFspuF_Design_getDB(FCentities[0].E_spU[SUDUsuIdx].SUO_designId);
   SUDUttl:=length(FCentities[0].E_spU[SUDUsuIdx].SUO_dockedSU)-1;
   FCWinMain.FCWM_DLP_DockList.Items.Add(
      '<p align="center"><img src="file://'+FCVpathRsrc+'pics-ui-scraft\'
      +FCDBscDesigns[SUDUdsgn].SCD_intStrClone.SCIS_token+'_lst.jpg'
      +'" align="middle">'
      );
   FCWinMain.FCWM_DLP_DockList.Items.Add(
      '<p align="center"><img src="file://'+FCVpathRsrc+'pics-ui-misc\arrow.jpg'
      +'" align="middle">'
      );
   SUDUcnt:=1;
   while SUDUcnt<=SUDUttl do
   begin
      SUDUdckIdx:=FCFcFunc_SpUnit_getOwnDB(0, FCentities[0].E_spU[SUDUsuIdx].SUO_dockedSU[SUDUcnt].SUD_dckdToken);
      SUDUdsgn:=FCFspuF_Design_getDB(FCentities[0].E_spU[SUDUdckIdx].SUO_designId);
      FCWinMain.FCWM_DLP_DockList.Items.Add(
         '<img src="file://'+FCVpathRsrc+'pics-ui-scraft\'
         +FCDBscDesigns[SUDUdsgn].SCD_intStrClone.SCIS_token+'_lst.jpg'
         +'" align="middle">'
         +FCFdTFiles_UIStr_Get(dtfscPrprName, FCentities[0].E_spU[SUDUdckIdx].SUO_nameToken)
         );
      inc(SUDUcnt);
   end;
   FCWinMain.FCWM_DockLstPanel.Caption.Text
      :=FCFdTFiles_UIStr_Get(uistrUI, 'spUnDock')+FCFdTFiles_UIStr_Get(dtfscPrprName, FCentities[0].E_spU[SUDUsuIdx].SUO_nameToken);
   FCWinMain.FCWM_DLP_DockList.ItemIndex:=2;
   FCWinMain.FCWM_DLP_DockList.Selected[2]:=true;
   if not FCWinMain.FCWM_DockLstPanel.Visible
   then FCWinMain.FCWM_DockLstPanel.Visible:=true;
end;

procedure FCMuiWin_SurfEcos_Set(
   const SESoobjIdx, SESsatIdx: integer;
   const SESinit: boolean
   );
{:Purpose: set and display the Surface / Ecosphere Panel.
tags set: FCWM_SurfPanel=FCWM_SurfPanel.Width FCWM_SP_DataSheet:=FCWM_SP_DataSheet.Left
    Additions:
      -2011Feb14- *add: display settlements if a region have one.
                  *mod: some code optimization.
      -2010Jun27- *add: environmnent data.
      -2010Mar21- *mod: code cleanup and optimization.
                  *fix: modify surface map loading to avoid a memory leak.
      -2010Feb21- *add: initialize surface picture tag.
                  *add: store orbital object/satellite indexes in FCWM_SP_LDat/FCWM_SP_RDat.
      -2010Feb06- *add: complete ecosphere display.
      -2010Feb05- *fix: correctly restore panel size after 2 gaseous selected.
      -2010Feb04- *add: atmosphere composition display.
      -2010Feb03- *add: update panel title.
                  *mod: complete surface display.
                  *add: ecosphere data.
      -2010Feb02- *mod: change SESshowIt by SESinit and fully complete the setting.
                  *add/mod: surface display WIP.
      -2010Feb01- *add: switch for display or not the panel.
      -2010Jan31- *add: surface picture for non satellites.
      -2010Jan25- *add: complete surface hotspot initialization.
}
var
   SESdmpTtlReg
   ,SEShots
   ,SEScnt
   ,SESdmpC
   ,SESdmpIdx
   ,SESregSearch
   ,SESregSWdiv3
   ,SESregSWshr1
   ,SESregSWshr2
   ,SESregSHm64shr1
   ,SESregSHm64shr2: integer;

   SESdmpAtmPr
   ,SESdmpCCov
   ,SESdmpHCov: double;

   SESenv
   ,SESdmpToken
   ,SESdmpStrDat: string;

   SESdmpTp: TFCEduOobjTp;
   SESdmpHydr: TFCEhydroTp;
begin
   with FCWinMain do
   begin
      if not SESinit
      then
      begin
         FCWM_SPShEcos_Lab.HTMLText.Clear;
         FCWM_SP_SPic.Bitmap.Clear;
         FCWM_SP_LDat.Tag:=SESoobjIdx;
         FCWM_SP_RDat.Tag:=0;
         FCWM_SP_Surface.Tag:=0;
         FCWM_SP_DataSheet.ActivePage:=FCWM_SP_ShEcos;
         FCWM_SP_SurfSel.Width:=0;
         FCWM_SP_SurfSel.Height:=0;
         FCWM_SP_SurfSel.Left:=0;
         FCWM_SP_SurfSel.Top:=0;
         if SESsatIdx=0
         then
         begin
            SESdmpTp:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_type;
            SESdmpTtlReg:=length(FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_regions)-1;
            SESdmpToken:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_token;
            SESdmpAtmPr:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_atmPress;
            SESdmpCCov:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_cloudsCov;
            SESdmpHydr:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_hydrotp;
            SESdmpHCov:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_hydroArea;
            SESenv:=FCFuF_Env_GetStr(
               FCV3DselSsys
               ,FCV3DselStar
               ,SESoobjIdx
               ,0
               );
         end
         else if SESsatIdx>0
         then
         begin
            SESdmpTp:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_type;
            SESdmpTtlReg:=length(FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_regions)-1;
            SESdmpToken:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_token;
            SESdmpAtmPr:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_atmPress;
            SESdmpCCov:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_cloudsCov;
            SESdmpHydr:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_hydrotp;
            SESdmpHCov:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_hydroArea;
            FCWM_SP_RDat.Tag:=SESsatIdx;
            SESenv:=FCFuF_Env_GetStr(
               FCV3DselSsys
               ,FCV3DselStar
               ,SESoobjIdx
               ,SESsatIdx
               );
         end;
         FCWM_SurfPanel.Caption.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_SurfPanel')+FCFdTFiles_UIStr_Get(dtfscPrprName,SESdmpToken);
         {.environment type subsection}
         FCWM_SPShEcos_Lab.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'secpEnv')+'<br>'+FCCFidxL+SESenv+'<br>');
         {.atmosphere subsection}
         FCWM_SPShEcos_Lab.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'secpAtm'));
         if SESdmpAtmPr=0
         then FCWM_SPShEcos_Lab.HTMLText.Add('<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'comNoneP'))
         else if SESdmpAtmPr>0
         then
         begin
            FCWM_SPShEcos_Lab.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'secpGasM'));
            SESdmpStrDat:=FCFuiWin_SurfEcosAtm_Proc(agsMain, SESoobjIdx, SESsatIdx);
            FCWM_SPShEcos_Lab.HTMLText.Add(SESdmpStrDat);
            FCWM_SPShEcos_Lab.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'secpGasS'));
            SESdmpStrDat:=FCFuiWin_SurfEcosAtm_Proc(agsSec, SESoobjIdx, SESsatIdx);
            FCWM_SPShEcos_Lab.HTMLText.Add(SESdmpStrDat);
            FCWM_SPShEcos_Lab.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'secpGasT'));
            SESdmpStrDat:=FCFuiWin_SurfEcosAtm_Proc(agsTrace, SESoobjIdx, SESsatIdx);
            if SESdmpStrDat<>''
            then FCWM_SPShEcos_Lab.HTMLText.Add(SESdmpStrDat)
            else FCWM_SPShEcos_Lab.HTMLText.Add('<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'comNoneP'));
            if SESdmpAtmPr<>1
            then
            begin
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'secpPress')
                  +FCCFidxR+FCFdTFiles_UIStr_Get(uistrUI, 'secpClCov')
                  );
               FCWM_SPShEcos_Lab.HTMLText.Add
                  ('<br>'+FCCFidxL+floattostr(SESdmpAtmPr)+' mbars'+FCCFidxR+floattostr(SESdmpCCov)+' %');
            end;
         end; //==END== else if SESdmpAtmPr>0 ==//
         FCWM_SPShEcos_Lab.HTMLText.Add('<br>'+FCFdTFiles_UIStr_Get(uistrUI, 'secpHydr')+'<br>');
         case SESdmpHydr of
            htNone: FCWM_SPShEcos_Lab.HTMLText.Add(FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'comNoneP'));
            htVapor:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpVap')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
            htLiquid:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpLiq')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
            htIceSheet:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpISh')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
            htCrystal:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpCryst')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
            htLiqNH3:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpLiqNH3')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
            htLiqCH4:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpLiqCH4')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
         end; //==END== case SESdmpHydr ==//
         {.set the ecosphere panel if it's a gaseous planet}
         if (SESdmpTp>oobtpPlan_Icy_CallistoH3H4Atm0)
            and (SESdmpTp<oobtpSat_Aster_Metall)
         then
         begin
            {.set interface}
            FCWM_SP_LDatFrm.Visible:=false;
            FCWM_SP_SPicFrm.Visible:=false;
            FCWM_SP_RDatFrm.Visible:=false;
            FCWM_SP_Surface.Visible:=false;
            if FCWM_SurfPanel.Tag=0
            then FCWM_SurfPanel.Tag:=FCWM_SurfPanel.Width;
            if FCWM_SP_DataSheet.Tag=0
            then FCWM_SP_DataSheet.Tag:=FCWM_SP_DataSheet.Left;
            FCWM_SurfPanel.Width:=232;
            FCWM_SP_DataSheet.Align:=alLeft;
         end //==END== if (SESdmpTp>Icy_CallistoH3H4Atm0) and (<Aster_Metall) ==//
         {.otherwise for non gaseous orbital objects}
         else
         begin
            if FCWM_SurfPanel.Tag>0
            then
            begin
               {.set interface}
               FCWM_SP_LDatFrm.Visible:=true;
               FCWM_SP_SPicFrm.Visible:=true;
               FCWM_SP_RDatFrm.Visible:=true;
               FCWM_SP_Surface.Visible:=true;
               FCWM_SurfPanel.Width:=FCWM_SurfPanel.Tag;
               FCWM_SurfPanel.Tag:=0;
               FCWM_SP_Surface.Tag:=0;
               FCWM_SP_DataSheet.Align:=alCustom;
               FCWM_SP_DataSheet.Left:=FCWM_SP_DataSheet.Tag;
               FCWM_SP_DataSheet.Tag:=0;
            end;
            {.set the hotspots if needed}
            if (SESdmpTtlReg>0)
               and (FCWM_SP_Surface.HotSpots.Count<>SESdmpTtlReg)
            then
            begin
               FCWM_SP_Surface.Enabled:=false;
               FCWM_SP_Surface.HotSpots.Clear;
               SESregSWdiv3:=FCWM_SP_Surface.Width div 3;
               SESregSWshr1:=FCWM_SP_Surface.Width shr 1;
               SESregSWshr2:=FCWM_SP_Surface.Width shr 2;
               SESregSHm64shr1:=(FCWM_SP_Surface.Height-64) shr 1;
               SESregSHm64shr2:=(FCWM_SP_Surface.Height-64) shr 2;
               FCMgfxC_Settlements_Hide;
               SEScnt:=1;
               while SEScnt<=SESdmpTtlReg do
               begin
                  SESdmpC:=SEScnt;
                  SEShots:=SESdmpC-1;
                  FCWM_SP_Surface.HotSpots.Add;
                  FCWM_SP_Surface.HotSpots[SEShots].ID:=SESdmpC;
                  FCWM_SP_Surface.HotSpots[SEShots].Clipped:=false;
                  FCWM_SP_Surface.HotSpots[SEShots].Down:=false;
                  FCWM_SP_Surface.HotSpots[SEShots].HoverColor:=clNone;
                  FCWM_SP_Surface.HotSpots[SEShots].ClickColor:=clNone;
                  case SESdmpC of
                     1:
                     begin
                        FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                        FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                        FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                        FCWM_SP_Surface.HotSpots[SEShots].Y:=0;
                     end;
                     2, 3:
                     begin
                        {.width}
                        case SESdmpTtlReg of
                           4:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr1;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=FCWM_SP_Surface.Height-64;
                           end;
                           6:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr1;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                           end;
                           8:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWdiv3;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                           end;
                           10:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr2;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                           end;
                           14:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr2;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=(FCWM_SP_Surface.Height-64) div 3;
                           end;
                           18:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr2;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                           end;
                           22:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 5;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                           end;
                           26:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 6;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                           end;
                           30:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 7;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                           end;
                        end; //==END== case SESdmpTtlReg ==//
                        {.positions}
                        if SESdmpC=2
                        then FCWM_SP_Surface.HotSpots[SEShots].X:=0
                        else FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SEShots].Width-1;
                        FCWM_SP_Surface.HotSpots[SEShots].Y:=31;
                     end; //==END== 2, 3: ==//
                     4..29:
                     begin
                        case SESdmpTtlReg of
                           4:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                              FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                              FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
                           end;
                           6:
                           begin
                              if SESdmpC=6
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr1;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-3].X;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y
                                    :=FCWM_SP_Surface.HotSpots[1].Y+FCWM_SP_Surface.HotSpots[1].Height;
                              end;
                           end;
                           8:
                           begin
                              if SESdmpC=8
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33;
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWdiv3;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                                 if SESdmpC=4
                                 then
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X
                                       :=FCWM_SP_Surface.HotSpots[3-1].X+FCWM_SP_Surface.HotSpots[3-1].Width;
                                    FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[3-1].Y;
                                 end
                                 else
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-3-1].X;
                                    FCWM_SP_Surface.HotSpots[SEShots].Y
                                       :=FCWM_SP_Surface.HotSpots[2-1].Y+FCWM_SP_Surface.HotSpots[2-1].Height;
                                 end;
                              end;
                           end;
                           10..18:
                           begin
                              if ((SESdmpC=10) and (SESdmpTtlReg=10))
                                 or ((SESdmpC=14) and (SESdmpTtlReg=14))
                                 or ((SESdmpC=18) and (SESdmpTtlReg=18))
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr2;
                                 case SESdmpTtlReg of
                                    10:
                                    begin
                                       FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                                       if (SESdmpC=4)
                                          or (SESdmpC=5)
                                       then
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X
                                             :=FCWM_SP_Surface.HotSpots[SEShots-1].X
                                                +FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                          FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[3-1].Y;
                                       end
                                       else
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-4-1].X;
                                          FCWM_SP_Surface.HotSpots[SEShots].Y
                                             :=FCWM_SP_Surface.HotSpots[2-1].Y+FCWM_SP_Surface.HotSpots[2-1].Height;
                                       end
                                    end;
                                    14:
                                    begin
                                       FCWM_SP_Surface.HotSpots[SEShots].Height:=(FCWM_SP_Surface.Height-64) div 3;
                                       if (SESdmpC=4)
                                          or (SESdmpC=5)
                                       then
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X
                                             :=FCWM_SP_Surface.HotSpots[SEShots-1].X
                                                +FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                          FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[3-1].Y;
                                       end
                                       else
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-4-1].X;
                                          if (SESdmpC>=6)
                                             and (SESdmpC<=9)
                                          then FCWM_SP_Surface.HotSpots[SEShots].Y
                                             :=FCWM_SP_Surface.HotSpots[2-1].Y+FCWM_SP_Surface.HotSpots[2-1].Height
                                          else FCWM_SP_Surface.HotSpots[SEShots].Y
                                             :=FCWM_SP_Surface.HotSpots[6-1].Y+FCWM_SP_Surface.HotSpots[6-1].Height;
                                       end;
                                    end;
                                    18:
                                    begin
                                       FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                                       if (SESdmpC=4)
                                          or (SESdmpC=5)
                                       then
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X
                                             :=FCWM_SP_Surface.HotSpots[SEShots-1].X
                                                +FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                          FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[3-1].Y;
                                       end
                                       else
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-4-1].X;
                                          case SESdmpC of
                                             6..9: FCWM_SP_Surface.HotSpots[SEShots].Y
                                                :=FCWM_SP_Surface.HotSpots[2-1].Y+FCWM_SP_Surface.HotSpots[2-1].Height;
                                             10..13: FCWM_SP_Surface.HotSpots[SEShots].Y
                                                :=FCWM_SP_Surface.HotSpots[6-1].Y+FCWM_SP_Surface.HotSpots[6-1].Height;
                                             14..18: FCWM_SP_Surface.HotSpots[SEShots].Y
                                                :=FCWM_SP_Surface.HotSpots[10-1].Y+FCWM_SP_Surface.HotSpots[10-1].Height;
                                          end;
                                       end;
                                    end;
                                 end; //==END== case SESdmpTtlReg ==//
                              end;
                           end; //==END== 10..18 ==//
                           22:
                           begin
                              if SESdmpC=22
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 5;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                                 if (SESdmpC>=4)
                                    and (SESdmpC<=6)
                                 then
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X
                                       :=FCWM_SP_Surface.HotSpots[SEShots-1].X+FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                    FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[2].Y;
                                 end
                                 else
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-6].X;
                                    case SESdmpC of
                                       7..11: FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[1].Y+FCWM_SP_Surface.HotSpots[1].Height;
                                       12..16: FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[6].Y+FCWM_SP_Surface.HotSpots[6].Height;
                                       else FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[11].Y+FCWM_SP_Surface.HotSpots[11].Height;
                                    end;
                                 end;
                              end;
                           end; //==END== 22 ==//
                           26:
                           begin
                              if SESdmpC=26
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 6;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                                 if (SESdmpC>=4)
                                    and (SESdmpC<=7)
                                 then
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X
                                       :=FCWM_SP_Surface.HotSpots[SEShots-1].X
                                          +FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                    FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[2].Y;
                                 end
                                 else
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-7].X;
                                    case SESdmpC of
                                       8..13: FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[1].Y+FCWM_SP_Surface.HotSpots[1].Height;
                                       14..19: FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[7].Y+FCWM_SP_Surface.HotSpots[7].Height;
                                       else FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[13].Y+FCWM_SP_Surface.HotSpots[13].Height;
                                    end;
                                 end;
                              end;
                           end; //==END== 26 ==//
                           30:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 7;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                              if (SESdmpC>=4)
                                 and (SESdmpC<=8)
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].X
                                    :=FCWM_SP_Surface.HotSpots[SEShots-1].X+FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[2].Y;
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-7-1].X;
                                 case SESdmpC of
                                    9..15: FCWM_SP_Surface.HotSpots[SEShots].Y
                                       :=FCWM_SP_Surface.HotSpots[1].Y+FCWM_SP_Surface.HotSpots[1].Height;
                                    16..22: FCWM_SP_Surface.HotSpots[SEShots].Y
                                       :=FCWM_SP_Surface.HotSpots[8].Y+FCWM_SP_Surface.HotSpots[8].Height;
                                    else FCWM_SP_Surface.HotSpots[SEShots].Y
                                       :=FCWM_SP_Surface.HotSpots[15].Y+FCWM_SP_Surface.HotSpots[15].Height;
                                 end;
                              end;
                           end;
                        end; //==END== case SESdmpTtlReg ==//
                     end; //==END== 4..29 ==//
                     30:
                     begin
                        with FCWM_SP_Surface.HotSpots[SEShots] do
                        begin
                           FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                           FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                           FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                           FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33;
                        end;
                     end;
                  end; //==END== case SESdmpC ==//
//                  FCRdiSettlementPic[SEScnt].Left:=FCWM_SP_Surface.HotSpots[SEShots].X+(FCWM_SP_Surface.HotSpots[SEShots].Width shr 1)-(FCRdiSettlementPic[SEScnt].Width shr 1);
//                  FCRdiSettlementPic[SEScnt].Top:=FCWM_SP_Surface.HotSpots[SEShots].Y+4;

                  if ((SESsatIdx=0) and (FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_regions[SEScnt].OOR_setSet>0))
                     or ((SESsatIdx>0) and (FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_regions[SEScnt].OOR_setSet>0))
                  then FCMgfxC_Settlement_SwitchState(SEScnt);
                  inc(SEScnt);
               end; //==END== while SEScnt<=SESdmpTtlReg ==//;
            end; //==END== if (SESdmpTtlReg>0) and (HotSpots.Count<>SESdmpTtlReg) ==//
            {.load the surface picture}
            case SESdmpTp of
               oobtpAster_Metall: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_metal.jpg');
               oobtpAster_Sili: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_sili.jpg');
               oobtpAster_Carbo:FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_carb.jpg');
               oobtpAster_Icy: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_icy.jpg');
               oobtpPlan_Tellu_EarthH0H1..oobtpPlan_Tellu_VenusH4:
               begin
                  if FileExists(FCVpathRsrc+'pics-ogl-oobj-pers\'+SESdmpToken+'.jpg')
                  then FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-pers\'+SESdmpToken+'.jpg')
                  else FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-pers\_error_map.jpg');
               end;
               oobtpPlan_Tellu_MercuH0..oobtpPlan_Icy_CallistoH3H4Atm0:
               begin
                  try
                     SESdmpIdx:=FCFoglInit_StdTexIdx_Get(FC3DobjPlan[FCV3DselOobj].Material.LibMaterialName);
                     FC3DobjPlan[FCV3DselOobj].Material.MaterialLibrary.Materials[SESdmpIdx].Material.Texture.Image
                        .SaveToFile(FCVpathCfg+'swap.jpg');
                  finally
                     FCWM_SP_Surface.Picture.LoadFromFile(FCVpathCfg+'swap.jpg');
                  end;
               end;
               oobtpSat_Aster_Metall: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_metal.jpg');
               oobtpSat_Aster_Sili: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_sili.jpg');
               oobtpSat_Aster_Carbo: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_carb.jpg');
               oobtpSat_Aster_Icy: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_icy.jpg');
               oobtpSat_Tellu_Titan..oobtpSat_Tellu_Earth:
               begin
                  if FileExists(FCVpathRsrc+'pics-ogl-oobj-pers\'+SESdmpToken+'.jpg')
                  then FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-pers\'+SESdmpToken+'.jpg')
                  else FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-pers\_error_map.jpg');
               end;
               oobtpSat_Tellu_Lunar..oobtpSat_Tellu_Io, oobtpSat_Icy_Pluto..oobtpSat_Icy_Callisto:
               begin
                  try
                     fcwinmain.caption:=inttostr(FCV3DselSat);
                     SESdmpIdx:=FCFoglInit_StdTexIdx_Get(FC3DobjSat[FCV3DselSat].Material.LibMaterialName);
                     FC3DobjSat[FCV3DselSat].Material.MaterialLibrary.Materials[SESdmpIdx].Material.Texture.Image
                        .SaveToFile(FCVpathCfg+'swap.jpg');
                  finally
                     FCWM_SP_Surface.Picture.LoadFromFile(FCVpathCfg+'swap.jpg');
                  end;
               end;
            end; //==END== case SESdmpTp ==//
            FCWM_SP_Surface.Enabled:=True;
            FCWM_SP_Surface.Refresh;
         end; //==END== else not gaseous ==//
         if not FCWM_SurfPanel.Visible
         then FCWM_SurfPanel.Visible:=true;
         if FCWM_SurfPanel.Tag=0
         then FCMuiWin_SurfEcos_RegUpd(1, true);
      end //==END== if not SESinit ==//
      else if SESinit
      then
      begin
         FCWM_SurfPanel.Visible:=false;
         SESdmpTp:=oobtpAster_Metall;
         SESdmpTtlReg:=4;
         FCWM_SurfPanel.Caption.Text:='';
         FCWM_SP_LDat.Tag:=0;
         FCWM_SP_RDat.Tag:=0;
         FCWM_SP_Surface.Tag:=0;
         FCWM_SP_Surface.Enabled:=false;
         FCWM_SP_Surface.HotSpots.Clear;
         SEScnt:=1;
         while SEScnt<=4 do
         begin
            SESdmpC:=SEScnt;
            SEShots:=SESdmpC-1;
            FCWM_SP_Surface.HotSpots.Add;
            FCWM_SP_Surface.HotSpots[SEShots].ID:=SESdmpC;
            FCWM_SP_Surface.HotSpots[SEShots].Clipped:=false;
            FCWM_SP_Surface.HotSpots[SEShots].Down:=false;
            FCWM_SP_Surface.HotSpots[SEShots].HoverColor:=clNone;
            FCWM_SP_Surface.HotSpots[SEShots].ClickColor:=clNone;
            case SESdmpC of
               1:
               begin
                  FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                  FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                  FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                  FCWM_SP_Surface.HotSpots[SEShots].Y:=0;
               end;
               2, 3:
               begin
                  FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width shr 1;
                  FCWM_SP_Surface.HotSpots[SEShots].Height:=FCWM_SP_Surface.Height-64;
                  if SESdmpC=2
                  then FCWM_SP_Surface.HotSpots[SEShots].X:=0
                  else FCWM_SP_Surface.HotSpots[SEShots].X:=Width-1;
                  FCWM_SP_Surface.HotSpots[SEShots].Y:=31;
               end;
               4:
               begin
                  FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                  FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                  FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                  FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
               end;
            end;
            inc(SEScnt)
         end; //==END== while SEScnt<=4 ==//
         FCWM_SP_Surface.Refresh;
         FCWM_SP_Surface.HotSpots.Clear;
      end; //==END== else if SESinit ==//
   end; //==END== with FCWinMain ==//
end;

procedure FCMuiWin_SurfEcos_RegUpd(
   const SERUregIdx: integer;
   const SERUonlyPic: boolean
   );
{:Purpose: update the region data and picture .
Tags set: oobjIdx=FCWM_SP_LDat, satIdx=FCWM_SP_RDat
    Additions:
      -2010Mar20- *add climate, current average temperature, temperature and windspeed indexes.
                  *add: a switch for only update the region picture.
                  *mod: uses FCWM_SPShReg_Lab for region data display.
                  *mod: store current selected region in FCWM_SP_Surface.Tag.
      -2010Mar18- *add: yearly mean precipitations and windspeed.
      -2010Mar15- *add: Terrain Type and current season.
      -2010Mar14- *add: selection frame.
}
var
   SERUtPic
   ,SERUoobjIdx
   ,SERUsatIdx
   ,SERUprecip
   ,SERUidxTemp
   ,SERUidxWdSpd: integer;

   SERUwndSpd
   ,SERUtemp: double;

   SERUrelief
   ,SERUseason
   ,SERUterrain: string;

   SERUdmpRelief: TFCEregRelief;
   SERUdmpTerrTp: TFCEregSoilTp;
begin
   with FCWinMain do
   begin
      SERUoobjIdx:=FCWM_SP_LDat.Tag;
      SERUsatIdx:=FCWM_SP_RDat.Tag;
      SERUseason:=FCFuF_Ecosph_GetCurSeas(SERUoobjIdx, SERUsatIdx);
      FCWM_SP_Surface.Tag:=SERUregIdx;
      {.initialize required data}
      if SERUsatIdx=0
      then
      begin
         with FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SERUoobjIdx].OO_regions[SERUregIdx] do
         begin
            SERUdmpTerrTp:=OOR_soilTp;
            SERUdmpRelief:=OOR_relief;
            SERUwndSpd:=OOR_windSpd;
            SERUprecip:=OOR_precip;
            if SERUseason='seasonMin'
            then SERUtemp:=OOR_meanTdMin
            else if SERUseason='seasonMid'
            then SERUtemp:=OOR_meanTdInt
            else if SERUseason='seasonMax'
            then SERUtemp:=OOR_meanTdMax;
         end;
      end
      else if SERUsatIdx>0
      then
      begin
         with FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SERUoobjIdx].OO_satList[SERUsatIdx] do
         begin
            SERUdmpTerrTp:=OOS_regions[SERUregIdx].OOR_soilTp;
            SERUdmpRelief:=OOS_regions[SERUregIdx].OOR_relief;
            SERUwndSpd:=OOS_regions[SERUregIdx].OOR_windSpd;
            SERUprecip:=OOS_regions[SERUregIdx].OOR_precip;
            if SERUseason='seasonMin'
            then SERUtemp:=OOS_regions[SERUregIdx].OOR_meanTdMin
            else if SERUseason='seasonMid'
            then SERUtemp:=OOS_regions[SERUregIdx].OOR_meanTdInt
            else if SERUseason='seasonMax'
            then SERUtemp:=OOS_regions[SERUregIdx].OOR_meanTdMax;
         end;
      end;
      SERUidxTemp:=FCFuF_Index_Get(ufitTemp, SERUtemp);
      SERUidxWdSpd:=FCFuF_Index_Get(ufitWdSpd, SERUwndSpd);
      {.gather the focused terrain picture and set terrain description data}
      SERUterrain:='';
      SERUrelief:='';
      case SERUdmpTerrTp of
         rst01rockDes:
         begin
            SERUterrain:='terrainRDes';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=0;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=1;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=2;
               end;
            end;
         end;
         rst02sandDes:
         begin
            SERUterrain:='terrainSDes';
            if SERUdmpRelief=rr1plain
            then
            begin
               SERUrelief:='reliefPlain';
               SERUtPic:=3;
            end
            else if SERUdmpRelief=rr4broken
            then
            begin
               SERUrelief:='reliefBrok';
               SERUtPic:=4;
            end;
         end;
         rst03volcanic:
         begin
            SERUterrain:='terrainVol';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=5;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=6;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=7;
               end;
            end;
         end;
         rst04polar:
         begin
            SERUterrain:='terrainPol';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=8;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=9;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=10;
               end;
            end;
         end;
         rst05arid:
         begin
            SERUterrain:='terrainArid';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=11;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=12;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=13;
               end;
            end;
         end;
         rst06fertile:
         begin
            SERUterrain:='terrainFert';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=14;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=15;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=16;
               end;
            end;
         end;
         rst07oceanic:
         begin
            SERUterrain:='terrainOcean';
            SERUtPic:=17;
         end;
         rst08coastRockDes:
         begin
            SERUterrain:='terrainCoastRDes';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=18;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=19;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=20;
               end;
            end;
         end;
         rst09coastSandDes:
         begin
            SERUterrain:='terrainCoastSDes';
            if SERUdmpRelief=rr1plain
            then
            begin
               SERUrelief:='reliefPlain';
               SERUtPic:=21;
            end
            else if SERUdmpRelief=rr4broken
            then
            begin
               SERUrelief:='reliefBrok';
               SERUtPic:=22;
            end;
         end;
         rst10coastVolcanic:
         begin
            SERUterrain:='terrainCoastVol';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=23;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=24;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=25;
               end;
            end;
         end;
         rst11coastPolar:
         begin
            SERUterrain:='terrainCoastPol';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=26;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=27;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=28;
               end;
            end;
         end;
         rst12coastArid:
         begin
            SERUterrain:='terrainCoastArid';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=29;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=30;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=31;
               end;
            end;
         end;
         rst13coastFertile:
         begin
            SERUterrain:='terrainCoastFert';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=32;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=33;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=34;
               end;
            end;
         end;
         rst14barren:
         begin
            SERUterrain:='terrainSter';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=35;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=36;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=37;
               end;
            end;
         end;
         rst15icyBarren:
         begin
            SERUterrain:='terrainIcSter';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=38;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=39;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=40;
               end;
            end;
         end;
      end; //==END== case SERUdmpTerrTp ==//
      FCWM_SP_SPic.Bitmap:=FCWM_RegTerrLib.Bitmap[SERUtPic];
      {.set the selection frame}
      FCWM_SP_SurfSel.Left:=FCWM_SP_Surface.HotSpots[SERUregIdx-1].X;
      FCWM_SP_SurfSel.Top:=FCWM_SP_Surface.HotSpots[SERUregIdx-1].Y;
      FCWM_SP_SurfSel.Width:=FCWM_SP_Surface.HotSpots[SERUregIdx-1].Width;
      FCWM_SP_SurfSel.Height:=FCWM_SP_Surface.HotSpots[SERUregIdx-1].Height;
      if not SERUonlyPic
      then
      begin
         {.terrain type}
         FCWM_SPShReg_Lab.HTMLText.Clear;
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'secpTerrTp')+FCCFdHeadEnd
            +FCFdTFiles_UIStr_Get(uistrUI, SERUrelief)+' '+FCFdTFiles_UIStr_Get(uistrUI, SERUterrain)
            +'<br>'
            );
         {.current season}
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'season')+FCCFdHeadEnd
            +FCFdTFiles_UIStr_Get(uistrUI, SERUseason)
            +'<br>'
            );
         {.climate}
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'climate')+FCCFdHeadEnd
            +FCFdTFiles_UIStr_Get(uistrUI, FCFuF_Region_GetClim(SERUoobjIdx, SERUsatIdx, SERUregIdx))
            +'<br>'
            );
         {.temperature}
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'temp')+FCCFdHeadEnd
            +FloatToStr(SERUtemp)+' K ('
            );
         case SERUidxTemp of
            1, 2: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolWhBL);
            3, 4: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolBlueL);
            5, 6, 7: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolGreen);
            8, 9: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolOrge);
            else FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolRed);
         end;
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCFdTFiles_UIStr_Get(uistrUI, 'tempIdx'+FloatToStr(SERUidxTemp))
            +FCCFcolEND+')'
            +'<br>'
            );
         {.yearly mean precipitations}
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'precip')+FCCFdHeadEnd
            +IntToStr(SERUprecip)+' mm/'+FCFdTFiles_UIStr_Get(uistrUI, 'acronYr')
            +'<br>'
            );
         {.yearly mean windspeed}
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'wndspd')+FCCFdHeadEnd
            +FloatToStr(SERUwndSpd)+' m/s ('
            );
         case SERUidxWdSpd of
            0..2: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolGreen);
            3..4: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolBlue);
            5..6: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolOrge);
            else FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolRed);
         end;
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCFdTFiles_UIStr_Get(uistrUI, 'wspdIdx'+FloatToStr(SERUidxWdSpd))
            +FCCFcolEND+')'
            +'<br>'
            );
      end; //==END== if not SERUonlyPic ==//
   end; //==END== with FCWinMain ==//
end;

procedure FCMuiWin_TerrGfxColl_Init;
{:Purpose: initialize the terrains graphic collection.
    Additions:
}
var
   TGCIcnt
   ,TGCIdmp: integer;
   TGCIfile: string;
begin
   if FCWinMain.FCWM_RegTerrLib.Bitmaps.Count>0
   then FCWinMain.FCWM_RegTerrLib.Bitmaps.Clear;
   TGCIcnt:=0;
   while TGCIcnt<=41 do
   begin
      TGCIdmp:=TGCIcnt;
      FCWinMain.FCWM_RegTerrLib.Bitmaps.Add;
      case TGCIcnt of
         0: TGCIfile:='rst01rockDes_plain.jpg';
         1: TGCIfile:='rst01rockDes_brok.jpg';
         2: TGCIfile:='rst01rockDes_moun.jpg';
         3: TGCIfile:='rst02sandDes_plain.jpg';
         4: TGCIfile:='rst02sandDes_brok.jpg';
         5: TGCIfile:='rst03volcanic_plain.jpg';
         6: TGCIfile:='rst03volcanic_brok.jpg';
         7: TGCIfile:='rst03volcanic_moun.jpg';
         8: TGCIfile:='rst04polar_plain.jpg';
         9: TGCIfile:='rst04polar_brok.jpg';
         10: TGCIfile:='rst04polar_moun.jpg';
         11: TGCIfile:='rst05arid_plain.jpg';
         12: TGCIfile:='rst05arid_brok.jpg';
         13: TGCIfile:='rst05arid_moun.jpg';
         14: TGCIfile:='rst06fertile_plain.jpg';
         15: TGCIfile:='rst06fertile_brok.jpg';
         16: TGCIfile:='rst06fertile_moun.jpg';
         17: TGCIfile:='rst07oceanic.jpg';
         18: TGCIfile:='rst08coastRockDes_plain.jpg';
         19: TGCIfile:='rst08coastRockDes_brok.jpg';
         20: TGCIfile:='rst08coastRockDes_moun.jpg';
         21: TGCIfile:='rst09coastSandDes_plain.jpg';
         22: TGCIfile:='rst09coastSandDes_brok.jpg';
         23: TGCIfile:='rst10coastVolcanic_plain.jpg';
         24: TGCIfile:='rst10coastVolcanic_brok.jpg';
         25: TGCIfile:='rst10coastVolcanic_moun.jpg';
         26: TGCIfile:='rst11coastPolar_plain.jpg';
         27: TGCIfile:='rst11coastPolar_brok.jpg';
         28: TGCIfile:='rst11coastPolar_moun.jpg';
         29: TGCIfile:='rst12coastArid_plain.jpg';
         30: TGCIfile:='rst12coastArid_brok.jpg';
         31: TGCIfile:='rst12coastArid_moun.jpg';
         32: TGCIfile:='rst13coastFertile_plain.jpg';
         33: TGCIfile:='rst13coastFertile_brok.jpg';
         34: TGCIfile:='rst13coastFertile_moun.jpg';
         35: TGCIfile:='rst14barren_plain.jpg';
         36: TGCIfile:='rst14barren_brok.jpg';
         37: TGCIfile:='rst14barren_moun.jpg';
         38: TGCIfile:='rst15icyBarren_plain.jpg';
         39: TGCIfile:='rst15icyBarren_brok.jpg';
         40: TGCIfile:='rst15icyBarren_moun.jpg';
      end; //==END== case TGCIcnt ==//
      FCWinMain.FCWM_RegTerrLib.Bitmap[TGCIdmp].LoadFromFile(FCVpathRsrc+'pics-ui-terrain\'+TGCIfile);
      inc(TGCIcnt);
   end; //==END== while TGCIcnt<=41 ==//
end;

procedure FCMuiWin_UI_LangUpd;
{:Purpose: update interface for new language.
    Additions:
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
begin
   FCMdF_ConfigFile_Write(false);
   FCMuiWin_UI_Upd(mwupTextWinMain);
   FCMuiWin_UI_Upd(mwupTextWinAb);
   FCMuiWin_UI_Upd(mwupTextWinNGS);
   FCMuiWin_UI_Upd(mwupTextWinMS);
   FCMuiWin_UI_Upd(mwupMenuLang);
   if FCWinMain.FCWM_3dMainGrp.Visible
   then FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutAll);
   if assigned(FCcps)
      and (FCcps.CPSisEnabled)
//      and (Length(FCentities[0].E_col)>1)
   then FCcps.FCM_ViabObj_Init(false);
   FCMumi_Faction_Upd(uiwAllSection, true);
   FCMuiCDP_FunctionCateg_Initialize;
   FCMuiCDD_Colony_Update(
      cdlColonyAll
      ,0
      ,0
      ,false
      ,false
      );
end;

procedure FCMuiWin_UI_Upd(const UIUtp: TFCEmwinUpdTp);
{:Purpose: update and initialize all user's interface elements of the game.
   Additions:
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
		FCWinMain.Caption:=FCCgameNam+'  ['+FCFcFunc_FARCVersion_Get+']  ©2009-2011 J.F. Baconnet';
		{.main menu - game section}
		FCWinMain.FCWM_MMenu_Game.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Game');
		FCWinMain.FCWM_MMenu_G_New.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Game_New');
      FCWinMain.FCWM_MMenu_G_Cont.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Game_Cont');
      FCWinMain.FCWM_MMenu_G_Save.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_G_Save');
      FCWinMain.FCWM_MMenu_G_FlushOld.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_G_FlushOld');
		FCWinMain.FCWM_MMenu_G_Quit.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Game_Quit');
		{.main menu - options section}
		FCWinMain.FCWM_MMenu_Options.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Options');
		FCWinMain.FCWM_MMenu_O_Lang.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Options_Lang');
		FCWinMain.FCWM_MMenu_O_L_EN.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Options_Lang_EN');
		FCWinMain.FCWM_MMenu_O_L_FR.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MainMenu_Options_Lang_FR');
      FCWinMain.FCWM_MMenu_O_Loc.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_O_Loc');
      FCWinMain.FCWM_MMenu_O_LocHelp.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_O_LocHelp');
      FCWinMain.FCWM_MMenu_O_LocVObj.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_O_LocVObj');
      FCWinMain.FCWM_MMenu_O_WideScr.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_O_WideScr');
      FCWinMain.FCWM_MMenu_O_TexR.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_O_TexR');
      FCWinMain.FCWM_MMenu_O_TR_1024.Caption:='1024*512';
      FCWinMain.FCWM_MMenu_O_TR_2048.Caption:='2048*1024';
      {.main menu - debug tools}
      FCWinMain.FCWM_MMenu_DebTools.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_DebTools');
      FCWinMain.FCWM_MMenu_DTFUG.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_DTFUG');
      FCWinMain.FCWM_MMenu_DTreloadTfiles.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_DTreloadTfiles');
		{.main menu - help section}
      FCWinMain.FCWM_MMenu_Help.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_Help');
      FCWinMain.FCWM_MMenu_H_HPanel.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_H_HPanel');
		FCWinMain.FCWM_MMenu_H_About.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_H_About');
      {.focused object popup menu - static texts}
      FCWinMain.FCWM_PMFOoobjData.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_PMFO_Data.OObj');
      FCWinMain.FCWM_PMFOcolfacData.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_PMFOcolfacData');
	end;
   if (((UIUtp=mwupAll) or (UIUtp=mwupTextWinMain)) and (FCWinMain.FCWM_3dMainGrp.Visible))
      or (UIUtp=mwupTextWM3dFrame)
   then
   begin
      {:DEV NOTES: put .main 3d view frame in a separated procedure and remove the mwupTextWM3dFrame switch.}
      {.main 3d view frame}
      FCWinMain.FCWM_3dMainGrp.Caption
         :=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_3dMainGrp.SSys')
            +' '+FCFdTFiles_UIStr_Get(dtfscPrprName,FCDBsSys[FCV3DselSsys].SS_token)
            +']  '
            +FCFdTFiles_UIStr_Get(uistrUI,'FCWM_3dMainGrp.Star')
            +' '
            +FCFdTFiles_UIStr_Get(dtfscPrprName, FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_token)
            +']';
      {.help panel}
      FCWinMain.FCWM_HelpPanel.Caption.Text:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_HelpPanel');
      FCWinMain.FCWM_HPdPad_Keys.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_HPdPad_Keys');
      FCWinMain.FCWM_HPdPad_KeysTxt.HTMLText.Clear;
      FCWinMain.FCWM_HPdPad_KeysTxt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI,'HPKeys'));
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
      {.popup menu - focused object}
      FCWinMain.FCWM_PMFO_DList.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_PMFO_DList');
      FCWinMain.FCWM_PMFO_Header_Travel.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_PMFO_Header_Travel');
      FCWinMain.FCWM_PMFO_MissITransit.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_PMFO_MissITransit');
      FCWinMain.FCWM_PMFO_MissCancel.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_PMFO_MissCancel');
      FCWinMain.FCWM_PMFO_HeaderSpecMiss.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_PMFO_HeaderSpecMiss');
      FCWinMain.FCWM_PMFO_MissColoniz.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_PMFO_MissColoniz');
      {.surface panel}
      FCWinMain.FCWM_SurfPanel.Caption.Text:='';
      FCWinMain.FCWM_SP_AutoUp.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_SP_AutoUp');
      FCWinMain.FCWM_SP_ShEcos.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_SP_ShEcos');
      FCWinMain.FCWM_SP_ShReg.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_SP_ShReg');
      {.viability objectives panel}
      if Assigned(FCcps)
      then FCcps.CPSobjPanel.Caption.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'CPSobjPanel');
      {.colony data panel}
      FCWinMain.FCWM_ColDPanel.Caption.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_ColDPanel');
      FCWinMain.FCWM_CDPcsme.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcsme');
      FCWinMain.FCWM_CDPinfr.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPinfr');
      FCWinMain.FCWM_CDPpopul.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPpopul');
      FCWinMain.FCWM_CDPcolName.EditLabel.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcolName');
      {.UMI}
      FCWinMain.FCWM_UMI.Caption.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMI');
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
   end;
   //=======================================================================================
   {.this section concern only all texts of about window}
   if UIUtp=mwupTextWinAb
   then
   begin
      {.main frame}
      FCWinAbout.FCWA_Frame.Caption
         :=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_H_About')+' '+FCCgameNam+' '+FCFcFunc_FARCVersion_Get;
      {.header}
      FCWinAbout.FCWA_Frm_Header.HTMLText.Clear;
      FCWinAbout.FCWA_Frm_Header.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI,'FCWA_Frm_Header'));
      FCWinAbout.FCWA_Frm_Creds.HTMLText.Clear;
      FCWinAbout.FCWA_Frm_Creds.HTMLText.Add(
         FCFdTFiles_UIStr_Get(uistrUI,'FCWA_Frm_CredsHead')
            +FCFdTFiles_UIStr_Get(uistrUI,'FCWA_Frm_CredsAuth')
            +FCFdTFiles_UIStr_Get(uistrUI,'FCWA_Frm_CredsSrcComp')
            +FCFdTFiles_UIStr_Get(uistrUI,'FCWA_Frm_CredsContrib')
            +FCFdTFiles_UIStr_Get(uistrUI,'FCWA_Frm_CredsOthrSrc')
            +FCFdTFiles_UIStr_Get(uistrUI,'FCWA_Frm_CredsInspSrc')
         );
   end;
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
   {.this section concern only all texts of mission setup window}
   if UIUtp=mwupTextWinMS
   then
   begin
      FCWinMissSet.FCWMS_Grp_MSDG.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWMS_Grp_MSDG');
      FCWinMissSet.FCWMS_Grp_MCG.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWMS_Grp_MCG');
      FCWinMissSet.FCWMS_ButProceed.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'ButtProceed');
      FCWinMissSet.FCWMS_ButCancel.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'ButtCancel');
      FCWinMissSet.FCWMS_Grp_MCGColName.EditLabel.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcolName');
      FCWinMissSet.FCWMS_Grp_MCG_SetName.EditLabel.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMS_Grp_MCG_SetName');
   end;
   //=======================================================================================
   {.this section concern all graphical elements of main window w/o text
   initialization/update}
   if UIUtp=mwupAll
   then
   begin
      {.main window and descendants}
      FCWinMain.Constraints.MinWidth:=800;
      FCWinMain.Constraints.MinHeight:=600;
      FCWinMain.Width:=FCVwinMsizeW;
      FCWinMain.Height:=FCVwinMsizeH;
      FCWinMain.Left:=FCVwinMlocL;
      FCWinMain.Top:=FCVwinMlocT;
      FCWinMain.DoubleBuffered:=true;
      UIUmainW2:=FCWinMain.Width shr 1;
      UIUmainH2:=FCWinMain.Height shr 1;
      {.background image}
      FCMuiWin_BckgdPic_Upd;
      {.continue game menu item}
      if FCRplayer.P_gameName=''
      then FCWinMain.FCWM_MMenu_G_Cont.Enabled:=false
      else FCWinMain.FCWM_MMenu_G_Cont.Enabled:=true;
      {.save game menu item}
      FCWinMain.FCWM_MMenu_G_Save.Enabled:=false;
      FCWinMain.FCWM_MMenu_G_FlushOld.Enabled:=false;
      {.debug menu item + console}
      if FCGdebug
      then
      begin
         FCWinMain.FCWM_MMenu_DebTools.Visible:=true;
         FCWinDebug:=TFCWinDebug.Create(Application);
         FCWinDebug.Visible:=true;
      end
      else FCWinMain.FCWM_MMenu_DebTools.Visible:=false;
      {.docking list panel}
      FCWinMain.FCWM_DockLstPanel.Width:=200;
      FCWinMain.FCWM_DockLstPanel.Height:=450;
      {.help panel}
      FCWinMain.FCWM_HelpPanel.Width:=780;
      FCWinMain.FCWM_HelpPanel.Height:=440;
      FCWinMain.FCWM_HDPhintsList.Width:=FCWinMain.FCWM_HelpPanel.Width shr 5*15;
      FCWinMain.FCWM_HDPhintsText.Width:=(FCWinMain.FCWM_HelpPanel.Width shr 5*17)-8;
      {.surface panel}
      FCWinMain.FCWM_SurfPanel.Width:=784;
      FCWinMain.FCWM_SurfPanel.Height:=375;
      FCWinMain.FCWM_SurfPanel.Left:=(UIUmainW2)-(FCWinMain.FCWM_SurfPanel.Width shr 1);
      FCWinMain.FCWM_SurfPanel.Top:=(UIUmainH2)-(FCWinMain.FCWM_SurfPanel.Height shr 1);
      FCWinMain.FCWM_SP_AutoUp.Width:=82;
      FCWinMain.FCWM_SP_AutoUp.Left:=FCWinMain.FCWM_SurfPanel.Width-25-FCWinMain.FCWM_SP_AutoUp.Width;
      FCWinMain.FCWM_SP_AutoUp.Top:=1;
      {.surface panel - surface hotspot}
      FCWinMain.FCWM_SP_Surface.Width:=512;
      FCWinMain.FCWM_SP_Surface.Height:=256;
      FCWinMain.FCWM_SP_Surface.Left:=1;
      FCWinMain.FCWM_SP_Surface.Top:=19;
      {.surface panel - left data}
      FCWinMain.FCWM_SP_LDatFrm.Width:=111;
      FCWinMain.FCWM_SP_LDatFrm.Height:=99;
      FCWinMain.FCWM_SP_LDatFrm.Left:=0;
      FCWinMain.FCWM_SP_LDatFrm.Top:=FCWinMain.FCWM_SP_Surface.Top+FCWinMain.FCWM_SP_Surface.Height+1;
      {.surface panel - region picture}
      FCWinMain.FCWM_SP_SPicFrm.Width:=292;
      FCWinMain.FCWM_SP_SPicFrm.Height:=99;
      FCWinMain.FCWM_SP_SPicFrm.Left:=FCWinMain.FCWM_SP_LDatFrm.Left+FCWinMain.FCWM_SP_LDatFrm.Width;
      FCWinMain.FCWM_SP_SPicFrm.Top:=FCWinMain.FCWM_SP_LDatFrm.Top;
      FCWinMain.FCWM_SP_SPic.Width:=FCWinMain.FCWM_SP_SPicFrm.Width-2;
      FCWinMain.FCWM_SP_SPic.Height:=FCWinMain.FCWM_SP_SPicFrm.Height-3;
      FCWinMain.FCWM_SP_SPic.Left:=1;
      FCWinMain.FCWM_SP_SPic.Top:=2;
      {.surface panel - right data}
      FCWinMain.FCWM_SP_RDatFrm.Width:=FCWinMain.FCWM_SP_LDatFrm.Width;
      FCWinMain.FCWM_SP_RDatFrm.Height:=FCWinMain.FCWM_SP_LDatFrm.Height;
      FCWinMain.FCWM_SP_RDatFrm.Left:=FCWinMain.FCWM_SP_SPicFrm.Left+FCWinMain.FCWM_SP_SPicFrm.Width;
      FCWinMain.FCWM_SP_RDatFrm.Top:=FCWinMain.FCWM_SP_SPicFrm.Top;
      {.surface panel - data sheet}
      FCWinMain.FCWM_SP_DataSheet.Width:=270;
      FCWinMain.FCWM_SP_DataSheet.Height:=FCWinMain.FCWM_SurfPanel.Height-19;
      FCWinMain.FCWM_SP_DataSheet.Left:=FCWinMain.FCWM_SP_Surface.Left+FCWinMain.FCWM_SP_Surface.Width+1;
      FCWinMain.FCWM_SP_DataSheet.Top:=FCWinMain.FCWM_SP_Surface.Top;
      {.colony data panel}
      FCWinMain.FCWM_ColDPanel.Width:=784;
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
      FCWinMain.FCWM_CDPwcpEquip.Width:=92;
      FCWinMain.FCWM_CDPwcpEquip.Height:=20;
      FCWinMain.FCWM_CDPwcpEquip.Left:=162-134;
      FCWinMain.FCWM_CDPwcpEquip.Top:=216+24;
      {.UMI}
      FCWinMain.FCWM_UMI.Width:=FCVwMumiW;
      FCWinMain.FCWM_UMI.Height:=FCVwMumiH;
      FCWinMain.FCWM_UMI.Left:=UIUmainW2-(FCWinMain.FCWM_UMI.Width shr 1);
      FCWinMain.FCWM_UMI.Top:=UIUmainH2-(FCWinMain.FCWM_UMI.Height shr 1);
      FCWinMain.FCWM_UMI_TabSh.ActivePage:=FCWinMain.FCWM_UMI_TabShUniv;
      FCWinMain.FCWM_UMI_FacDatG.Height:=90;
      FCWinMain.FCWM_UMI_FacLvl.Width:=32;
      FCWinMain.FCWM_UMI_FacLvl.Height:=32;
      FCWinMain.FCWM_UMI_FacLvl.Left:=14;
      FCWinMain.FCWM_UMI_FacLvl.Top:=48;
      FCWinMain.FCWM_UMI_FacLvl.Max:=10;
      FCWinMain.FCWM_UMI_FacLvl.Segments:=10;
      FCWinMain.FCWM_UMI_FacLvl.Position:=0;
      FCWinMain.FCWM_UMI_FacEcon.Width:=FCWinMain.FCWM_UMI_FacLvl.Width;
      FCWinMain.FCWM_UMI_FacEcon.Height:=FCWinMain.FCWM_UMI_FacLvl.Height;
      FCWinMain.FCWM_UMI_FacEcon.Top:=FCWinMain.FCWM_UMI_FacLvl.Top;
      FCWinMain.FCWM_UMI_FacEcon.Max:=3;
      FCWinMain.FCWM_UMI_FacEcon.Segments:=3;
      FCWinMain.FCWM_UMI_FacEcon.Position:=0;
      FCWinMain.FCWM_UMI_FacSoc.Width:=FCWinMain.FCWM_UMI_FacLvl.Width;
      FCWinMain.FCWM_UMI_FacSoc.Height:=FCWinMain.FCWM_UMI_FacLvl.Height;
      FCWinMain.FCWM_UMI_FacSoc.Top:=FCWinMain.FCWM_UMI_FacLvl.Top;
      FCWinMain.FCWM_UMI_FacSoc.Max:=3;//FCWinMain.FCWM_UMI_FacEcon.Max;
      FCWinMain.FCWM_UMI_FacSoc.Segments:=3;//FCWinMain.FCWM_UMI_FacEcon.Segments;
      FCWinMain.FCWM_UMI_FacSoc.Position:=FCWinMain.FCWM_UMI_FacEcon.Position;
      FCWinMain.FCWM_UMI_FacMil.Width:=FCWinMain.FCWM_UMI_FacLvl.Width;
      FCWinMain.FCWM_UMI_FacMil.Height:=FCWinMain.FCWM_UMI_FacLvl.Height;
      FCWinMain.FCWM_UMI_FacMil.Top:=FCWinMain.FCWM_UMI_FacLvl.Top;
      FCWinMain.FCWM_UMI_FacMil.Max:=3;//FCWinMain.FCWM_UMI_FacEcon.Max;
      FCWinMain.FCWM_UMI_FacMil.Segments:=3;//FCWinMain.FCWM_UMI_FacEcon.Segments;
      FCWinMain.FCWM_UMI_FacMil.Position:=FCWinMain.FCWM_UMI_FacEcon.Position;
      FCWinMain.FCWM_UMIFac_TabSh.Height:=FCWinMain.FCWM_UMI_TabShFac.Height-FCWinMain.FCWM_UMI_FacDatG.Height-8;
      FCWinMain.FCWM_UMIFac_TabSh.ActivePage:=FCWinMain.FCWM_UMIFac_TabShPol;
      FCWinMain.FCWM_UMIFac_PolGvtDetails.Width:=150;
      FCWinMain.FCWM_UMISh_CEFcommit.Width:=140;
      FCWinMain.FCWM_UMISh_CEFcommit.Height:=26;
      FCWinMain.FCWM_UMISh_CEFcommit.Enabled:=false;
      FCWinMain.FCWM_UMISh_CEFenforce.Width:=FCWinMain.FCWM_UMISh_CEFcommit.Width;
      FCWinMain.FCWM_UMISh_CEFenforce.Height:=FCWinMain.FCWM_UMISh_CEFcommit.Height;
      FCWinMain.FCWM_UMISh_CEFenforce.Top:=(FCWinMain.FCWM_UMISh_CEnfF.Height shr 3*4);
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
   {.this section concern all graphical elements of about window w/o text
   initialization/update}
   if (UIUtp=mwupSecwinAbout)
      and (FCVallowUpAbWin)
   then
   begin
      FCWinAbout.Width:=400;
      FCWinAbout.Height:=FCWinMain.Height shr 3*5;
      FCWinAbout.Left:=FCWinMain.Left+UIUmainW2-(FCWinAbout.Width shr 1);
      FCWinAbout.Top:=FCWinMain.Top+UIUmainH2-(FCWinAbout.Height shr 1);
      {.header}
      FCWinAbout.FCWA_Frm_Header.Height:=FCWinAbout.Height shr 3*2;
      {.credits label}
      FCWinAbout.FCWA_Frm_Creds.Height:=FCWinAbout.Height shr 3 *6;
   end;
   //=======================================================================================
   {.this section concern all graphical elements of new game setup window w/o text
   initialization/update}
   if (UIUtp=mwupSecWinNewGSetup)
      and (FCVallowUpNGSWin)
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
   {.this section concern all graphical elements of mission setup window w/o text
   initialization/update}
   if (UIUtp=mwupSecwinMissSetup)
      and (FCVallowUpMSWin)
   then
   begin
      FCWinMissSet.Width:=800;
      FCWinMissSet.Height:=217;
      FCWinMissSet.Left:=FCWinMain.Left+4;
      FCWinMissSet.Top:=FCWinMain.Top+98;
      {.mission data group}
      FCWinMissSet.FCWMS_Grp_MSDG.Width:=(FCWinMissSet.Width shr 1)-6;
      FCWinMissSet.FCWMS_Grp_MSDG.Height:=FCWinMissSet.Height-24;
      FCWinMissSet.FCWMS_Grp_MSDG.Left:=4;
      FCWinMissSet.FCWMS_Grp_MSDG.Top:=12;
      {.mission configuration group}
      FCWinMissSet.FCWMS_Grp_MCG.Width:=FCWinMissSet.FCWMS_Grp_MSDG.Width;
      FCWinMissSet.FCWMS_Grp_MCG.Height:=FCWinMissSet.FCWMS_Grp_MSDG.Height;
      FCWinMissSet.FCWMS_Grp_MCG.Left:=FCWinMissSet.FCWMS_Grp_MSDG.Left+FCWinMissSet.FCWMS_Grp_MSDG.Width+4;
      FCWinMissSet.FCWMS_Grp_MCG.Top:=FCWinMissSet.FCWMS_Grp_MSDG.Top;
      {.mission configuration background panel}
      FCWinMissSet.FCWMS_Grp_MCG_DatDisp.Width:=FCWinMissSet.FCWMS_Grp_MCG.Width shr 1;
      {.mission configuration data panel}
      FCWinMissSet.FCWMS_Grp_MCG_MissCfgData.Width:=FCWinMissSet.FCWMS_Grp_MCG_DatDisp.Width;
      {.mission configuration trackbar}
      FCWinMissSet.FCWMS_Grp_MCG_RMassTrack.Width:=170;
      FCWinMissSet.FCWMS_Grp_MCG_RMassTrack.Height:=50;
      {.cancel button}
      FCWinMissSet.FCWMS_ButCancel.Width:=116;
      FCWinMissSet.FCWMS_ButCancel.Height:=26;
      FCWinMissSet.FCWMS_ButCancel.Left:=8;
      FCWinMissSet.FCWMS_ButCancel.Top:=FCWinMissSet.Height-FCWinMissSet.FCWMS_ButCancel.Height;
      {.proceed button}
      FCWinMissSet.FCWMS_ButProceed.Width:=FCWinMissSet.FCWMS_ButCancel.Width;
      FCWinMissSet.FCWMS_ButProceed.Height:=FCWinMissSet.FCWMS_ButCancel.Height;
      FCWinMissSet.FCWMS_ButProceed.Left:=FCWinMissSet.Width-FCWinMissSet.FCWMS_ButProceed.Width-8;
      FCWinMissSet.FCWMS_ButProceed.Top:=FCWinMissSet.FCWMS_ButCancel.Top;
   end; {.if (WUupdKind=mwupSecwinMissSetup) and (FCVallowUpMSWin)}
   //=======================================================================================================
   {.this section update language submenus}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupMenuLang)
   then
   begin
      {.check status of language submenu items}
      if FCVlang='EN'
      then
      begin
         FCWinMain.FCWM_MMenu_O_L_EN.Checked:=true;
         FCWinMain.FCWM_MMenu_O_L_FR.Checked:=false;
      end
      else if FCVlang='FR'
      then
      begin
         FCWinMain.FCWM_MMenu_O_L_EN.Checked:=false;
         FCWinMain.FCWM_MMenu_O_L_FR.Checked:=true;
      end;
   end;
   //=======================================================================================================
   {.this section update panel locations submenus}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupMenuLoc)
   then
   begin
      if FCVwMcpsPstore
      then FCWinMain.FCWM_MMenu_O_LocVObj.Checked:=true
      else if not FCVwMcpsPstore
      then FCWinMain.FCWM_MMenu_O_LocVObj.Checked:=false;
      if FCVwMhelpPstore
      then FCWinMain.FCWM_MMenu_O_LocHelp.Checked:=true
      else if not FCVwMhelpPstore
      then FCWinMain.FCWM_MMenu_O_LocHelp.Checked:=false;
   end;
   //=======================================================================================================
   {.this section update widescreen submenu}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupMenuWideScr)
   then
   begin
      {.check status of language submenu items}
      if FCVwinWideScr
      then FCWinMain.FCWM_MMenu_O_WideScr.Checked:=true
      else if not FCVwinWideScr
      then FCWinMain.FCWM_MMenu_O_WideScr.Checked:=false;
   end;
   //=======================================================================================================
   {.this section update standard resolution submenus}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupMenuStex)
   then
   begin
      {.check status of standard texture resolution submenu items}
      if not FCV3DstdTresHR
      then
      begin
         FCWinMain.FCWM_MMenu_O_TR_1024.Checked:=true;
         FCWinMain.FCWM_MMenu_O_TR_2048.Checked:=false;
      end
      else if FCV3DstdTresHR
      then
      begin
         FCWinMain.FCWM_MMenu_O_TR_1024.Checked:=false;
         FCWinMain.FCWM_MMenu_O_TR_2048.Checked:=true;
      end;
   end;
   //=======================================================================================================
   {.this section concern all font setup}
   {:DEV NOTES: MWUPFONTALL MUST N O T BE USED IN APPLICATION INIT, USE IT FOR SIZE CHANGE}
   {.for main window}
   if (UIUtp=mwupAll)
      or (UIUtp=mwupFontAll)
   then
   begin
      FCWinMain.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_3dMainGrp.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBox);
      {.message box}
      FCWinMain.FCWM_MsgeBox.Caption.Font.Size:=FCFuiWin_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_MsgeBox_List.Font.Size:=FCFuiWin_Font_GetSize(uiwListItems);
      FCWinMain.FCWM_MsgeBox_Desc.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      {.docking list panel}
      FCWinMain.FCWM_DockLstPanel.Caption.Font.Size:=FCFuiWin_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_DLP_DockList.Font.Size:=FCFuiWin_Font_GetSize(uiwListItems);
      {.help panel}
      FCWinMain.FCWM_HelpPanel.Caption.Font.Size:=FCFuiWin_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_HPdataPad.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_HPdPad_Keys.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_HPdPad_KeysTxt.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_HPDPhints.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_HDPhintsList.Font.Size:=FCFuiWin_Font_GetSize(uiwListItems);
      FCWinMain.FCWM_HDPhintsText.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      {.surface panel}
      FCWinMain.FCWM_SP_AutoUp.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_SurfPanel.Caption.Font.Size:=FCFuiWin_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_SP_DataSheet.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_SPShEcos_Lab.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_SPShReg_Lab.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_SP_LDat.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_SP_RDat.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      {.viability objectives panel}
      if Assigned(FCcps)
      then
      begin
         FCcps.CPSobjPanel.Caption.Font.Size:=FCFuiWin_Font_GetSize(uiwPanelTitle);
         FCcps.CPSobjP_List.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      end;
      {.colony data panel}
      FCWinMain.FCWM_ColDPanel.Caption.Font.Size:=FCFuiWin_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_CDPinfo.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBox);
      FCWinMain.FCWM_CDPinfoText.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPpopList.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPpopType.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPepi.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_CDPpopul.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_CDPcsme.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_CDPcsmeList.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPinfr.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_CDPinfrList.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPinfrAvail.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPcolName.EditLabel.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPcolName.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPwcpAssign.EditLabel.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPwcpAssign.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPcwpAssignVeh.EditLabel.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPcwpAssignVeh.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_CDPwcpEquip.Font.Size:=FCFuiWin_Font_GetSize(uiwListItems);
      FCWinMain.FCWM_CDPwcpEquip.LabelFont.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      {.UMI}
      FCWinMain.FCWM_UMI.Caption.Font.Size:=FCFuiWin_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_UMI_TabSh.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_TabShUniv.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_TabShFac.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_TabShSpU.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_TabShProd.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_TabShRDS.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMI_FacDatG.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMIFac_TabSh.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMIFac_TabShPol.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMIFac_PolGvtDetails.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMIFac_PGDdata.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_Colonies.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_Colonies.HeaderSettings.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMIFac_Colonies.Columns[0].Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_Colonies.Columns[1].Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_Colonies.Columns[2].Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_Colonies.Columns[3].Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFac_TabShSPM.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMIFac_TabShSPMpol.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
      FCWinMain.FCWM_UMIFSh_SPMadmin.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_SPMecon.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_SPMmedca.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_SPMsoc.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_SPMspol.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_SPMspi.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_AvailF.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMIFSh_AFlist.Font.Size:=FCFuiWin_Font_GetSize(uiwListItems);
      FCWinMain.FCWM_UMIFSh_CAPF.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMIFSh_CAPFlab.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMIFSh_ReqF.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMIFSh_RFdisp.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMISh_CEnfF.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBoxSec);
      FCWinMain.FCWM_UMISh_CEFreslt.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_UMISh_CEFcommit.Font.Size:=FCFuiWin_Font_GetSize(uiwButton);
      FCWinMain.FCWM_UMISh_CEFenforce.Font.Size:=FCFuiWin_Font_GetSize(uiwButton);
      FCWinMain.FCWM_UMISh_CEFretire.Font.Size:=FCFuiWin_Font_GetSize(uiwButton);
      {.infrastructure panel}
      FCWinMain.FCWM_InfraPanel.Caption.Font.Size:=FCFuiWin_Font_GetSize(uiwPanelTitle);
      FCWinMain.FCWM_IPlabel.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      FCWinMain.FCWM_IPinfraKits.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
   end; //==END== if (UIUtp=mwupAll) or (UIUtp=mwupFontAll) ==//
   {.for about window}
   if ((UIUtp=mwupFontWinAb) or (UIUtp=mwupFontAll))
      and (FCVallowUpAbWin)
   then
   begin
      FCWinAbout.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      {.frame}
      FCWinAbout.FCWA_Frame.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBox);
      {.header}
      FCWinAbout.FCWA_Frm_Header.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
      {.main section}
      FCWinAbout.FCWA_Frm_Creds.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
   end;
   {.for new game setup window}
   if ((UIUtp=mwupFontWinNGS) or (UIUtp=mwupFontAll))
      and (FCVallowUpNGSWin)
   then
   begin
      with FCWinNewGSetup do
      begin
         Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWNGS_Frame.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBox);
         {.game name edit}
         FCWNGS_Frm_GNameEdit.EditLabel.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWNGS_Frm_GNameEdit.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         {.colonization mode}
         FCWNGS_Frm_ColMode.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         {.faction's list}
         FCWNGS_Frm_FactionList.Font.Size:=FCFuiWin_Font_GetSize(uiwListItems);
         {.data pad}
         FCWNGS_Frm_DataPad.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
         FCWNGS_Frm_DPad_SheetHisto.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
         FCWNGS_Frm_DPad_SHisto_Text.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWNGS_Frm_DPad_SheetSPM.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
         FCWNGS_FDPad_ShSPM_SPMList.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWNGS_Frm_DPad_SheetCol.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
         FCWNGS_Frm_DPad_SCol_Text.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWNGS_Frm_DPad_SheetDotList.Font.Size:=FCFuiWin_Font_GetSize(uiwPageCtrl);
         FCWNGS_Frm_DPad_SDL_DotList.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         {.buttons}
         FCWNGS_Frm_ButtProceed.Font.Size:=FCFuiWin_Font_GetSize(uiwButton);
         FCWNGS_Frm_ButtCancel.Font.Size:=FCFuiWin_Font_GetSize(uiwButton);
      end; {.with FCWinNewGSetup do}
   end;
   {.for mission setup window}
   if ((UIUtp=mwupFontWinMS) or (UIUtp=mwupFontAll))
      and (FCVallowUpMSWin)
   then
   begin
      with FCWinMissSet do
      begin
         Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWMS_Grp.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBox);
         FCWMS_Grp_MSDG.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBoxSec);
         FCWMS_Grp_MSDG_Disp.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWMS_Grp_MCG.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBoxSec);
         FCWMS_Grp_MCG_DatDisp.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWMS_Grp_MCGColName.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWMS_Grp_MCG_MissCfgData.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWMS_Grp_MCG_RMassTrack.TrackLabel.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWMS_ButCancel.Font.Size:=FCFuiWin_Font_GetSize(uiwButton);
         FCWMS_ButProceed.Font.Size:=FCFuiWin_Font_GetSize(uiwButton);
         FCWMS_Grp_MCG_SetName.Font.Size:=FCFuiWin_Font_GetSize(uiwDescText);
         FCWMS_Grp_MCG_SetType.Font.Size:=FCFuiWin_Font_GetSize(uiwGrpBoxSec);
      end;
   end;
end;

end.

