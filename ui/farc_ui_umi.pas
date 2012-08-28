{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: Unified Management Interface

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

unit farc_ui_umi;

interface

uses
   ComCtrls
   ,SysUtils;

type TFCEuiwUMIfacUpd=(
   uiwAllSection
   ,uiwAllMain
   ,uiwNone
   ,uiwfacLvl
   ,uiwStatEco
   ,uiwStatSoc
   ,uiwStatMil
   ,uiwPolStruc_gvt
   ,uiwPolStruc_bur
   ,uiwPolStruc_cor
   ,uiwPolStruc_eco
   ,uiwPolStruc_hcare
   ,uiwPolStruc_spi
   ,uiwColonies
   ,uiwSPMset
   ,uiwSPMpolEnfList
   ,uiwSPMpolEnfRAP
   ,uiwSPMpolEnfRes
   );

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   update the display regarding the selection in the available policies list
///</summary>
procedure FCMumi_AvailPolList_UpdClick;

///<summary>
///   update the UMI/Faction section
///</summary>
///   <param="UMIUFsec">section to update.</param>
///   <param="UMIUFrelocRetVal">relocation switch OR policy preprocessing result.</param>
procedure FCMumi_Faction_Upd(
   const UMIUFsec: TFCEuiwUMIfacUpd;
   const UMIUFrelocRetVal: boolean=false
   );

///<summary>
///   set default/min UMI size regarding the selected section
///</summary>
procedure FCMumi_Main_TabSetSize;

///<summary>
///   update, if necessary, the UMI
///</summary>
procedure FCMumi_Main_Upd;

implementation

uses
   farc_data_game
   ,farc_data_init
   ,farc_data_html
   ,farc_data_spm
   ,farc_data_textfiles
   ,farc_game_colony
   ,farc_game_cps
   ,farc_game_spm
   ,farc_game_spmdata
   ,farc_main
   ,farc_ui_html
   ,farc_win_debug;

//===================================END OF INIT============================================

//===========================END FUNCTIONS SECTION==========================================

procedure FCMumi_AvailPolList_UpdClick;
{:Purpose: update the display regarding the selection in the available policies list.
    Additions:
      -2012Aug27- *code audit:
                     (-)var formatting + refactoring     (-)if..then reformatting   (-)function/procedure refactoring
                     (-)parameters refactoring           (-) ()reformatting         (o)code optimizations
                     (-)float local variables=> extended (-)case..of reformatting   (-)local methods
                     (-)summary completion               (-)protect all float add/sub w/ FCFcFunc_Rnd
                     (-)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (-)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (-)use of enumindex                 (-)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (-)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
}
var
   TokenRes: string;

   RetVal: boolean;
begin
   if (FCWinMain.FCWM_UMI.Visible)
      and (not FCWinMain.FCWM_UMI.Collaps)
      and (FCWinMain.FCWM_UMI_TabSh.ActivePage=FCWinMain.FCWM_UMI_TabShFac)
      and (FCWinMain.FCWM_UMIFac_TabSh.ActivePage=FCWinMain.FCWM_UMIFac_TabShSPMpol)
   then
   begin
      RetVal:=false;
      TokenRes:=FCFuiHTML_AnchorInAhrefFromQuestionMarkItem_Extract( FCWinMain.FCWM_UMIFSh_AFlist.Items.ValueFromIndex[FCWinMain.FCWM_UMIFSh_AFlist.ItemIndex] );
      RetVal:=FCFgSPM_PolicyEnf_Preproc(0, TokenRes);
      FCMumi_Faction_Upd(uiwSPMpolEnfRAP, RetVal);
   end;
end;

procedure FCMumi_Faction_Upd(
   const UMIUFsec: TFCEuiwUMIfacUpd;
   const UMIUFrelocRetVal: boolean
   );
{:DEV NOTES: redo it completely all is fucked + status location are fucked and require to be consolidated + look the dev notes in this routine + the ones in FCMumi_Main_Upd.}
{:Purpose: update the UMI/Faction section.
    Additions:
      -2012Apr25- *add: apply the new format for encyclopaedia links in the SPM setting and policies enforcement.
                  *add: enforced policies are displayed in green, known memes are displayed in blue.
      -2011Jan31- *mod: relocate correctly the Current Dependence Status title.
      -2011Apr30- *mod: levels display jauge adjustments.
      -2011Jan13- *add: Policy Enforcement - take in account faction's status rules for unique policies.
      -2011Jan11- *add: Policy Enforcement - take in account faction's status rules.
      -2010Dec21- *add: Policy Enforcement - display unique policy text.
                  *mod: government details data - government title name by political system.
                  *add: government details data - economic system + healthcare system + religious system.
                  *add: Policy Enforcement - add the HQ requirement to be able to enforce policies.
      -2010Dec19- *add: uiwSPMpolEnfRAP - display result with correct colors.
      -2010Dec16- *add: uiwSPMpolEnfList - don't display not set policies w/ a duration>0.
      -2010Dec12- *add: Policy Enforcement - display enforcement decisions.
      -2010Dec09- *add: Policy Enforcement - display requirements penalty.
      -2010Dec07- *add: Policy Enforcement - display total applied influence.
      -2010Dec04- *add: Policy Enforcement - Acceptance Probability display.
      -2010Dec02- *add: Policy Enforcement - Available Policies display.
      -2010Dec01- *add: SPM settings trees display - add policies duration.
      -2010Nov28- *add: SPM settings trees display - add memes display.
                  *fix: correctly display the economic level.
      -2010Nov25- *add: SPM settings trees display - add SPMi type + link the names to the help panel topics/definitions.
      -2010Nov16- *add: SPM settings trees display + indicate if policies are set.
      -2010Nov15- *code: regroup relocation code.
                  *add: SPM settings ui elements resizing.
                  *fix: relocate correctly ui elements at the start of the game.
      -2010Nov01- *add: a switch Allmain for only update the main section w/o the secondary tabsheet (w/ Colonies/SPM settings and Policies Enforcement).
                  *fix: correctly update the colonies list if only this subsection is asked.
      -2010Oct28- *add: complete subsections update conversion.
                  *add: government details data: bureaucracy and corruption.
                  *add: colonies list WIP.
      -2010Oct27- *add: put a switch for section update + a boolean for include relocation.
      -2010Oct25- *add: political structure data.
                  *add: update the FCWM_UMIFac_TabSh here.
}
var
   UMIUFcnt
   ,UMIUFecon
   ,UMIUFinfl
   ,UMIUFmargPen
   ,UMIUFmax
   ,UMIUFmil
   ,UMIUFsoc
   ,UMIUFspmTreeW
   ,UMIUFstat
   ,UMIUFwd: integer;

   UMIUFeconLvl
   ,UMIUFeconPos
   ,UMIUFformat
   ,UMIUFmilLvl
   ,UMIUFmilPos
   ,UMIUFoobj
   ,UMIUFpolSet
   ,UMIUFpolToken
   ,UMIUFsocLvl
   ,UMIUFsocPos
   ,UMIUFstatus
   ,UMIUFlvl
   ,UMIUFspmiDesc
   ,UMIUFspmiDur: string;

   UMIUFisFSok
   ,UMIUFisUnique: boolean;

   UMIUFnodeRoot
   ,UMIUFnodeSPMadmin
   ,UMIUFnodeSPMecon
   ,UMIUFnodeSPMmedca
   ,UMIUFnodeSPMsoc
   ,UMIUFnodeSPMspol
   ,UMIUFnodeSPMspi
   ,UMIUFnodeSub: TTreeNode;

   UMIUFpolArea: TFCEdgSPMarea;

   UMIUFcalc:TFCEgspmPolRslt;

   UMIUFspmi: TFCRdgSPMi;
begin
   if (UMIUFsec=uiwAllSection)   {:DEV NOTES: remove all sections....}
      or (UMIUFsec=uiwAllMain)
      or ((UMIUFsec=uiwNone) and (UMIUFrelocRetVal))      {:DEV NOTES: remove these two and replace them by LocationOnly parameter.}
   then
   begin
      UMIUFstat:=(FCWinMain.FCWM_UMI.Width shr 5)*17;
      UMIUFecon:=(UMIUFstat shr 1)+16;
      UMIUFsoc:=UMIUFstat;
      UMIUFmil:=UMIUFsoc+(UMIUFsoc-UMIUFecon);
      UMIUFwd:=FCWinMain.FCWM_UMIFac_Colonies.Width shr 4;
      FCWinMain.FCWM_UMIFac_Colonies.Columns[0].Width:=UMIUFwd*4;
      FCWinMain.FCWM_UMIFac_Colonies.Columns[1].Width:=UMIUFwd*7;
      FCWinMain.FCWM_UMIFac_Colonies.Columns[2].Width:=UMIUFwd*3;
      FCWinMain.FCWM_UMIFac_Colonies.Columns[3].Width:=UMIUFwd*2;
      UMIUFspmTreeW:=FCWinMain.FCWM_UMIFSh_SPMlistTop.Width div 3;
      FCWinMain.FCWM_UMIFSh_SPMadmin.Width:=UMIUFspmTreeW;
      FCWinMain.FCWM_UMIFSh_SPMecon.Width:=UMIUFspmTreeW;
      FCWinMain.FCWM_UMIFSh_SPMmedca.Width:=UMIUFspmTreeW;
      FCWinMain.FCWM_UMIFSh_SPMsoc.Width:=UMIUFspmTreeW;
      FCWinMain.FCWM_UMIFSh_SPMspol.Width:=UMIUFspmTreeW;
      FCWinMain.FCWM_UMIFSh_SPMspi.Width:=UMIUFspmTreeW;
      FCWinMain.FCWM_UMIFSh_SPMlistBottom.Height:=FCWinMain.FCWM_UMIFac_TabSh.Height shr 1;
      FCWinMain.FCWM_UMI_FacData.HTMLText.Clear;
      FCWinMain.FCWM_UMI_FacData.HTMLText.Add(
         FCCFdHeadC
         +'<ind x="'+IntToStr(UMIUFsoc-( ( UMIUFsoc-UMIUFecon ) shr 1 ) )+'">'+FCFdTFiles_UIStr_Get(uistrUI, 'facstat')
         +FCCFdHeadEnd
         );
      {.header, idx=1}
      FCWinMain.FCWM_UMI_FacData.HTMLText.Add(
         FCCFdHeadC
         +'<ind x="'+IntToStr(FCWinMain.FCWM_UMI_FacLvl.Left)+'">'+FCFdTFiles_UIStr_Get(uistrUI, 'faclvl')
         +'<ind x="'+IntToStr(UMIUFecon)+'">'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLecon')
         +'<ind x="'+IntToStr(UMIUFsoc)+'">'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLsoc')
         +'<ind x="'+IntToStr(UMIUFmil)+'">'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLmil')
         +FCCFdHeadEnd
         );
      FCWinMain.FCWM_UMISh_CEFenforce.Left:=(FCWinMain.FCWM_UMISh_CEnfF.Width shr 1)-(FCWinMain.FCWM_UMISh_CEFenforce.Width shr 1);
      FCWinMain.FCWM_UMISh_CEFretire.Top:=FCWinMain.FCWM_UMISh_CEnfF.Height-(FCWinMain.FCWM_UMISh_CEFretire.Height+2);
      FCWinMain.FCWM_UMISh_CEFcommit.Left:=FCWinMain.FCWM_UMISh_CEnfF.Width-FCWinMain.FCWM_UMISh_CEFcommit.Width-2;
      FCWinMain.FCWM_UMISh_CEFcommit.Top:=FCWinMain.FCWM_UMISh_CEFretire.Top;
   end;
   if (UMIUFsec=uiwAllSection)
      or (UMIUFsec=uiwAllMain)
      or (UMIUFsec=uiwfacLvl)
      or ((UMIUFsec=uiwNone) and (UMIUFrelocRetVal))
   then
   begin
      {.faction's level, idx=2}
      FCWinMain.FCWM_UMI_FacLvl.Position:=FCDdgEntities[0].E_factionLevel;
      UMIUFlvl:=IntToStr(FCDdgEntities[0].E_factionLevel);
      if (UMIUFsec=uiwAllSection)
         or (UMIUFsec=uiwAllMain)
         or ((UMIUFsec=uiwNone) and (UMIUFrelocRetVal))
      then FCWinMain.FCWM_UMI_FacData.HTMLText.Add(
         '<br><ind x="'+IntToStr(FCWinMain.FCWM_UMI_FacLvl.Left+11)+'"><b>'+UMIUFlvl
            +'</b><ind x="'+IntToStr(FCWinMain.FCWM_UMI_FacLvl.Left+32)+'">'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl'+UMIUFlvl)
         )
      else if UMIUFsec=uiwfacLvl
      then
      begin
         FCWinMain.FCWM_UMI_FacData.HTMLText.Insert(
            2
            ,'<br><ind x="'+IntToStr(FCWinMain.FCWM_UMI_FacLvl.Left+11)+'"><b>'+UMIUFlvl
               +'</b><ind x="'+IntToStr(FCWinMain.FCWM_UMI_FacLvl.Left+32)+'">'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl'+UMIUFlvl)
            );
         FCWinMain.FCWM_UMI_FacData.HTMLText.Delete(3);
      end;
   end;
   if (UMIUFsec=uiwAllSection)
      or (UMIUFsec=uiwAllMain)
      or (UMIUFsec=uiwStatEco)
      or ((UMIUFsec=uiwNone) and (UMIUFrelocRetVal))
   then
   begin
      {.economic status, idx=3}
      FCWinMain.FCWM_UMI_FacEcon.Left:=UMIUFecon;
      FCWinMain.FCWM_UMI_FacEcon.Position:=Integer(FCVdgPlayer.P_economicStatus);
      UMIUFeconPos:=IntToStr(FCWinMain.FCWM_UMI_FacEcon.Position);
      UMIUFeconLvl:=FCFgSPMD_Level_GetToken(FCVdgPlayer.P_economicStatus);
      if (UMIUFsec=uiwAllSection)
         or (UMIUFsec=uiwAllMain)
         or ((UMIUFsec=uiwNone) and (UMIUFrelocRetVal))
      then FCWinMain.FCWM_UMI_FacData.HTMLText.Add(
         '<ind x="'+IntToStr(UMIUFecon+11)+'"><b>'+UMIUFeconPos
            +'</b><ind x="'+IntToStr(UMIUFecon+32)+'">'+FCFdTFiles_UIStr_Get(uistrUI, UMIUFeconLvl)
         )
      else if UMIUFsec=uiwStatEco
      then
      begin
         FCWinMain.FCWM_UMI_FacData.HTMLText.Insert(
            3
            ,'<ind x="'+IntToStr(UMIUFecon+11)+'"><b>'+UMIUFeconPos
               +'</b><ind x="'+IntToStr(UMIUFecon+32)+'">'+FCFdTFiles_UIStr_Get(uistrUI, UMIUFeconLvl)
            );
         FCWinMain.FCWM_UMI_FacData.HTMLText.Delete(4);
      end;
   end;
   if (UMIUFsec=uiwAllSection)
      or (UMIUFsec=uiwAllMain)
      or (UMIUFsec=uiwStatSoc)
      or ((UMIUFsec=uiwNone) and (UMIUFrelocRetVal))
   then
   begin
      {.social status, idx=4}
      FCWinMain.FCWM_UMI_FacSoc.Left:=UMIUFsoc;
      FCWinMain.FCWM_UMI_FacSoc.Position:=Integer(FCVdgPlayer.P_socialStatus);
      UMIUFsocPos:=IntToStr(FCWinMain.FCWM_UMI_FacSoc.Position);
      UMIUFsocLvl:=FCFgSPMD_Level_GetToken(FCVdgPlayer.P_socialStatus);
      if (UMIUFsec=uiwAllSection)
         or (UMIUFsec=uiwAllMain)
         or ((UMIUFsec=uiwNone) and (UMIUFrelocRetVal))
      then FCWinMain.FCWM_UMI_FacData.HTMLText.Add(
         '<ind x="'+IntToStr(UMIUFsoc+11)+'"><b>'+UMIUFsocPos
            +'</b><ind x="'+IntToStr(FCWinMain.FCWM_UMI_FacSoc.Left+32)+'">'+FCFdTFiles_UIStr_Get(uistrUI,UMIUFsocLvl)
         )
      else if UMIUFsec=uiwStatSoc
      then
      begin
         FCWinMain.FCWM_UMI_FacData.HTMLText.Insert(
            4
            ,'<ind x="'+IntToStr(UMIUFsoc+11)+'"><b>'+UMIUFsocPos
               +'</b><ind x="'+IntToStr(FCWinMain.FCWM_UMI_FacSoc.Left+32)+'">'+FCFdTFiles_UIStr_Get(uistrUI,UMIUFsocLvl)
            );
         FCWinMain.FCWM_UMI_FacData.HTMLText.Delete(5);
      end;
   end;
   if (UMIUFsec=uiwAllSection)
      or (UMIUFsec=uiwAllMain)
      or (UMIUFsec=uiwStatMil)
      or ((UMIUFsec=uiwNone) and (UMIUFrelocRetVal))
   then
   begin
      {.military status, idx=5}
      FCWinMain.FCWM_UMI_FacMil.Left:=UMIUFmil;
      FCWinMain.FCWM_UMI_FacMil.Position:=Integer(FCVdgPlayer.P_militaryStatus);
      UMIUFmilPos:=IntToStr(FCWinMain.FCWM_UMI_FacMil.Position);
      UMIUFmilLvl:=FCFgSPMD_Level_GetToken(FCVdgPlayer.P_militaryStatus);
      if (UMIUFsec=uiwAllSection)
         or (UMIUFsec=uiwAllMain)
         or ((UMIUFsec=uiwNone) and (UMIUFrelocRetVal))
      then FCWinMain.FCWM_UMI_FacData.HTMLText.Add(
         '<ind x="'+IntToStr(UMIUFmil+11)+'"><b>'+UMIUFmilPos
            +'</b><ind x="'+IntToStr(FCWinMain.FCWM_UMI_FacMil.Left+32)+'">'+FCFdTFiles_UIStr_Get(uistrUI,UMIUFmilLvl)
         )
      else if UMIUFsec=uiwStatMil
      then
      begin
         FCWinMain.FCWM_UMI_FacData.HTMLText.Insert(
            5
            ,'<ind x="'+IntToStr(UMIUFmil+11)+'"><b>'+UMIUFmilPos
               +'</b><ind x="'+IntToStr(FCWinMain.FCWM_UMI_FacMil.Left+32)+'">'+FCFdTFiles_UIStr_Get(uistrUI,UMIUFmilLvl)
            );
         FCWinMain.FCWM_UMI_FacData.HTMLText.Delete(6);
      end;
   end;
   {.political structure data}
   if (UMIUFsec=uiwAllSection)
      or (UMIUFsec=uiwAllMain)
      or ((UMIUFsec>=uiwPolStruc_gvt) and (UMIUFsec<=uiwPolStruc_cor))
   then
   begin
      if (UMIUFsec=uiwAllSection)
         or (UMIUFsec=uiwAllMain)
      then
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Clear;
         {.idx=0}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'UMIgvtPolSys')+FCCFdHeadEnd);
         {.idx=1}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgADMIN))+'<br>' );
         {.idx=2}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatBur')+FCCFdHeadEnd);
         {.idx=3}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(IntToStr(FCDdgEntities[0].E_bureaucracy)+' %<br>' );
         {.idx=4}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatCorr')+FCCFdHeadEnd);
         {.idx=5}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(IntToStr(FCDdgEntities[0].E_corruption)+' %<br>' );
         {.idx=6}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'UMIgvtEcoSys')+FCCFdHeadEnd);
         {.idx=7}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgECON))+'<br>' );
         {.idx=8}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'UMIgvtHcareSys')+FCCFdHeadEnd);
         {.idx=9}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgMEDCA))+'<br>' );
         {.idx=10}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'UMIgvtRelSys')+FCCFdHeadEnd);
         {.idx=11}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgSPI))+'<br>' );
      end
      else if UMIUFsec=uiwPolStruc_gvt
      then
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(1, FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgADMIN))+'<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(2);
      end
      else if UMIUFsec=uiwPolStruc_bur
      then
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(3, IntToStr(FCDdgEntities[0].E_bureaucracy)+' %<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(4);
      end
      else if UMIUFsec=uiwPolStruc_cor
      then
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(5, IntToStr(FCDdgEntities[0].E_corruption)+' %<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(6);
      end
      else if UMIUFsec=uiwPolStruc_eco
      then
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(7, FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgECON))+'<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(8);
      end
      else if UMIUFsec=uiwPolStruc_hcare
      then
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(9, FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgMEDCA))+'<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(10);
      end
      else if UMIUFsec=uiwPolStruc_spi
      then
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(11, FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgSPI))+'<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(12);
      end;
   end;
   if (UMIUFsec=uiwAllSection)
      or (UMIUFsec=uiwColonies)
   then
   begin
      UMIUFmax:=length(FCDdgEntities[0].E_colonies)-1;
      FCWinMain.FCWM_UMIFac_Colonies.Items.Clear;
      if UMIUFmax=0
      then FCWinMain.FCWM_UMIFac_Colonies.Items.Add(nil, FCFdTFiles_UIStr_Get(uistrUI, 'UMInocol'))
      else if UMIUFmax>0
      then
      begin
         UMIUFcnt:=1;
         while UMIUFcnt<=UMIUFmax do
         begin
            if FCDdgEntities[0].E_colonies[UMIUFcnt].C_locationSatellite<>''
            then UMIUFoobj:=FCDdgEntities[0].E_colonies[UMIUFcnt].C_locationSatellite
            else UMIUFoobj:=FCDdgEntities[0].E_colonies[UMIUFcnt].C_locationOrbitalObject;
            UMIUFnodeRoot:=FCWinMain.FCWM_UMIFac_Colonies.Items.Add(nil, FCDdgEntities[0].E_colonies[UMIUFcnt].C_name
               +';<p align="center">'+FCFdTFiles_UIStr_Get(dtfscPrprName, UMIUFoobj)
               +'  -(<b>'+FCFdTFiles_UIStr_Get(dtfscPrprName, FCDdgEntities[0].E_colonies[UMIUFcnt].C_locationStar)+'</b>)-'
               +';<p align="center">'+FCFdTFiles_UIStr_Get(uistrUI, FCFgC_HQ_GetStr(0,UMIUFcnt))
               +';<p align="center">'+IntToStr(FCDdgEntities[0].E_colonies[UMIUFcnt].C_cohesion)+' %'
               );
            inc(UMIUFcnt);
         end;
      end;
   end;
   {.SPM settings}
   if (UMIUFsec=uiwAllSection)
      or (UMIUFsec=uiwSPMset)
   then
   begin
      FCWinMain.FCWM_UMIFSh_SPMadmin.Items.Clear;
      FCWinMain.FCWM_UMIFSh_SPMecon.Items.Clear;
      FCWinMain.FCWM_UMIFSh_SPMmedca.Items.Clear;
      FCWinMain.FCWM_UMIFSh_SPMsoc.Items.Clear;
      FCWinMain.FCWM_UMIFSh_SPMspol.Items.Clear;
      FCWinMain.FCWM_UMIFSh_SPMspi.Items.Clear;
      UMIUFmax:=length(FCDdgEntities[0].E_spmSettings)-1;
      UMIUFcnt:=1;
      FCWinMain.FCWM_UMIFSh_SPMadmin.FullExpand;
      FCWinMain.FCWM_UMIFSh_SPMecon.FullExpand;
      FCWinMain.FCWM_UMIFSh_SPMmedca.FullExpand;
      FCWinMain.FCWM_UMIFSh_SPMsoc.FullExpand;
      FCWinMain.FCWM_UMIFSh_SPMspol.FullExpand;
      FCWinMain.FCWM_UMIFSh_SPMspi.FullExpand;
      while UMIUFcnt<=UMIUFmax do
      begin
         UMIUFformat:='';
         UMIUFpolSet:='';
         UMIUFspmiDesc:='';
         UMIUFspmiDur:='';
         UMIUFspmi:=FCFgSPM_SPMIData_Get(FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token);
         if FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_isPolicy
         then
         begin
            if FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_iPtIsSet then
            begin
               UMIUFpolSet:='  ['+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolSet')+' <b>'+IntToStr(FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_iPtAcceptanceProbability)+'</b> %]';
               UMIUFformat:=FCCFcolGreen+FCFdTFiles_UIStr_Get( uistrUI, FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token)+UIHTMLencyBEGIN+FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token+UIHTMLencyEND+FCCFcolGreen+UMIUFpolSet+FCCFcolEND;
               if not UMIUFspmi.SPMI_isUnique2set
               then UMIUFspmiDur:=FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolicyDur')+' [<b>'+IntToStr(FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_duration)+'</b> '
                  +FCFdTFiles_UIStr_Get(uistrUI,'TimeFmonth')+']';
            end
            else if not FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_iPtIsSet then
            begin

               if FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_duration>0 then
               begin
                  UMIUFspmiDur:=FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolicyDurFail')+' [<b>'+IntToStr(FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_duration)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI,'TimeFmonth')+']';
                  UMIUFformat:=FCCFcolRed;
               end;
               UMIUFformat:=UMIUFformat+FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token)+UIHTMLencyBEGIN+FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token+UIHTMLencyEND;
            end;
            if UMIUFspmi.SPMI_isUnique2set
            then UMIUFspmiDesc:=FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolicy'+IntToStr(Integer(UMIUFspmi.SPMI_area)))
            else if not UMIUFspmi.SPMI_isUnique2set
            then UMIUFspmiDesc:=FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolicy');
         end
         else if not FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_isPolicy
         then
         begin
            if FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_iPtBeliefLevel>blUnknown then
            begin
                UMIUFpolSet:=FCCFcolBlueL+FCFdTFiles_UIStr_Get(uistrUI, 'UMImemeSet')+FCCFcolEND;
                UMIUFformat:=FCCFcolBlueL;
            end;
            UMIUFformat:=UMIUFformat+FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token)+UIHTMLencyBEGIN+FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token+UIHTMLencyEND+UMIUFpolSet;
            UMIUFspmiDesc:='  [<a href="SPMiBL">BL</a>: <b>'+FCFdTFiles_UIStr_Get(uistrUI, 'SPMiBL'+IntToStr( Integer( FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_iPtBeliefLevel ) ) )
               +'</b> / <a href="SPMiSV">SV</a>: <b>'+IntToStr(FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_iPtSpreadValue)+'</b> %]';
         end;
         case UMIUFspmi.SPMI_area of
            dgADMIN:
            begin
               if FCWinMain.FCWM_UMIFSh_SPMadmin.Items.Count=0
               then UMIUFnodeSPMadmin:=FCWinMain.FCWM_UMIFSh_SPMadmin.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaADMIN')+'</b>' );
               UMIUFnodeSub:=FCWinMain.FCWM_UMIFSh_SPMadmin.Items.AddChild(
                  UMIUFnodeSPMadmin
                  , UMIUFformat
                  );
               UMIUFnodeSPMadmin.Expand(false);
               UMIUFnodeSPMadmin.Selected:=true;
               FCWinMain.FCWM_UMIFSh_SPMadmin.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDesc
                  );
               if UMIUFspmiDur<>''
               then FCWinMain.FCWM_UMIFSh_SPMadmin.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDur
                  );
            end;
            dgECON:
            begin
               if FCWinMain.FCWM_UMIFSh_SPMecon.Items.Count=0
               then UMIUFnodeSPMecon:=FCWinMain.FCWM_UMIFSh_SPMecon.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaECON')+'</b>' );
               UMIUFnodeSub:=FCWinMain.FCWM_UMIFSh_SPMecon.Items.AddChild(
                  UMIUFnodeSPMecon
                  ,UMIUFformat
                  );
               UMIUFnodeSPMecon.Expand(false);
                FCWinMain.FCWM_UMIFSh_SPMecon.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDesc
                  );
               if UMIUFspmiDur<>''
               then FCWinMain.FCWM_UMIFSh_SPMecon.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDur
                  );
            end;
            dgMEDCA:
            begin
               if FCWinMain.FCWM_UMIFSh_SPMmedca.Items.Count=0
               then UMIUFnodeSPMmedca:=FCWinMain.FCWM_UMIFSh_SPMmedca.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaMEDCA')+'</b>' );
               UMIUFnodeSub:=FCWinMain.FCWM_UMIFSh_SPMmedca.Items.AddChild(
                  UMIUFnodeSPMmedca
                  ,UMIUFformat
                  );
               UMIUFnodeSPMmedca.Expand(false);
                FCWinMain.FCWM_UMIFSh_SPMmedca.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDesc
                  );
               if UMIUFspmiDur<>''
               then FCWinMain.FCWM_UMIFSh_SPMmedca.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDur
                  );
            end;
            dgSOC:
            begin
               if FCWinMain.FCWM_UMIFSh_SPMsoc.Items.Count=0
               then UMIUFnodeSPMsoc:=FCWinMain.FCWM_UMIFSh_SPMsoc.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaSOC')+'</b>' );
               UMIUFnodeSub:=FCWinMain.FCWM_UMIFSh_SPMsoc.Items.AddChild(
                  UMIUFnodeSPMsoc
                  ,UMIUFformat
                  );
               UMIUFnodeSPMsoc.Expand(false);
                FCWinMain.FCWM_UMIFSh_SPMsoc.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDesc
                  );
               if UMIUFspmiDur<>''
               then FCWinMain.FCWM_UMIFSh_SPMsoc.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDur
                  );
            end;
            dgSPOL:
            begin
               if FCWinMain.FCWM_UMIFSh_SPMspol.Items.Count=0
               then UMIUFnodeSPMspol:=FCWinMain.FCWM_UMIFSh_SPMspol.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaSPOL')+'</b>' );
               UMIUFnodeSub:=FCWinMain.FCWM_UMIFSh_SPMspol.Items.AddChild(
                  UMIUFnodeSPMspol
                  ,UMIUFformat
                  );
               UMIUFnodeSPMspol.Expand(false);
                FCWinMain.FCWM_UMIFSh_SPMspol.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDesc
                  );
               if UMIUFspmiDur<>''
               then FCWinMain.FCWM_UMIFSh_SPMspol.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDur
                  );
            end;
            dgSPI:
            begin
               if FCWinMain.FCWM_UMIFSh_SPMspi.Items.Count=0
               then UMIUFnodeSPMspi:=FCWinMain.FCWM_UMIFSh_SPMspi.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaSPI')+'</b>' );
               UMIUFnodeSub:=FCWinMain.FCWM_UMIFSh_SPMspi.Items.AddChild(
                  UMIUFnodeSPMspi
                  ,UMIUFformat
                  );
               UMIUFnodeSPMspi.Expand(false);
                FCWinMain.FCWM_UMIFSh_SPMspi.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDesc
                  );
               if UMIUFspmiDur<>''
               then FCWinMain.FCWM_UMIFSh_SPMspi.Items.AddChild(
                  UMIUFnodeSub
                  ,UMIUFspmiDur
                  );
            end;
         end; //==END== case UMIUFspmi.SPMI_area of ==//
         inc(UMIUFcnt);
      end; //==END== while UMIUFcnt<=UMIUFmax do ==//
   end; //==END== if (UMIUFsec=uiwAllSection) or (UMIUFsec=uiwSPMset) ==//
   {.policy enforcement}
   if (UMIUFsec=uiwAllSection)
      or (UMIUFsec=uiwSPMpolEnfList)
   then
   begin
      {.section initialization}
      FCWinMain.FCWM_UMIFSh_AFlist.Items.Clear;
      FCWinMain.FCWM_UMIFSh_AFlist.Enabled:=true;
      UMIUFisFSok:=FCFgSPMD_PlyrStatus_ApplyRules(gmspmdCanEnfPolicies);
      if FCDdgEntities[0].E_hqHigherLevel=hqsNoHQPresent
      then
      begin
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Clear;
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'UMIhqNoMsg'));
      end
      else if (FCDdgEntities[0].E_hqHigherLevel>=hqsBasicHQ)
         and (UMIUFisFSok)
      then
      begin
         {.section update}
         UMIUFmax:=length(FCDdgEntities[0].E_spmSettings)-1;
         UMIUFcnt:=1;
         while UMIUFcnt<=UMIUFmax do
         begin
            if (FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_isPolicy)
               and (not FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_iPtIsSet)
               and (FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_duration=0)
            then FCWinMain.FCWM_UMIFSh_AFlist.Items.Add(
//               '<a href="'+FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token+'">'+
               FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token)+
//               '</a>'
//               FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token)+
               UIHTMLencyBEGIN+FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token+UIHTMLencyEND
               );
            inc(UMIUFcnt)
         end;
         FCWinMain.FCWM_UMIFSh_AFlist.Sorted:=true;
         FCWinMain.FCWM_UMIFSh_AFlist.SortWithHTML:=true;
         FCWinMain.FCWM_UMIFSh_AFlist.ItemIndex:=0;
         FCMumi_AvailPolList_UpdClick;
      end
      else
      begin
         UMIUFstatus:=FCFgSPMD_Level_GetToken(FCVdgPlayer.P_socialStatus);
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Clear;
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(
            FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfRuleNoEnf1')
            +'[<b>'+IntToStr(Integer(FCVdgPlayer.P_socialStatus))+'</b>]-<b>'+FCFdTFiles_UIStr_Get(uistrUI, UMIUFstatus)+'</b>, '+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfRuleNoEnf2')
            +'[<b>'+IntToStr(Integer(TFCEdgPlayerFactionStatus.pfs2_SemiDependent))+'</b>]-<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsStatSD')+'</b>.<br>'
            );
         if Assigned(FCcps)
         then FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfRuleNoEnf3') )
         else FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfRuleNoEnf4') );
      end;
   end; //==END== if (UMIUFsec=uiwAllSection) or (UMIUFsec=uiwSPMpolEnf) ==//
   {.policy enforcement acceptance probability and enforcement subsection}
   if UMIUFsec=uiwSPMpolEnfRAP
   then
   begin
      {.section initialization}
      FCWinMain.FCWM_UMIFSh_CAPFlab.HTMLText.Clear;
      UMIUFformat:='';
      FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Clear;
      FCWinMain.FCWM_UMISh_CEFcommit.Enabled:=false;
      FCWinMain.FCWM_UMISh_CEFretire.Enabled:=false;
      UMIUFpolArea:=FCFgSPM_EnforcPol_GetArea;
      UMIUFisUnique:=FCFgSPM_EnforcPol_GetUnique;
      if UMIUFisUnique
      then UMIUFisFSok:=FCFgSPMD_PlyrStatus_ApplyRules(gmspmdCanChangeGvt)
      else UMIUFisFSok:=true;
      if UMIUFisFSok
      then
      begin
         {.section update}
         UMIUFstat:=round(FCFgSPM_EnforcData_Get(gspmAccProbability));
         UMIUFinfl:=round(FCFgSPM_EnforcData_Get(gspmInfl));
         UMIUFmargPen:=round(FCFgSPM_EnforcData_Get(gspmMargMod));
         if UMIUFinfl<0
         then UMIUFformat:=FCCFcolRed
         else if UMIUFinfl>0
         then UMIUFformat:=FCCFcolGreen+'+';
         FCWinMain.FCWM_UMIFSh_CAPFlab.HTMLText.Add(
            '<p align="center" valign="center"><font size="20">'+IntToStr(UMIUFstat)+' %</font></p><p align="left"><sub>'
               +FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfInflTtl')+' <b>'+UMIUFformat+IntToStr(UMIUFinfl)+FCCFcolEND+'</b>   '+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqPen')
            );
         if UMIUFmargPen<0
         then UMIUFformat:=FCCFcolRed
         else UMIUFformat:='';
         FCWinMain.FCWM_UMIFSh_CAPFlab.HTMLText.Add(' <b>'+UMIUFformat+IntToStr(UMIUFmargPen)+'</b></sub></p>');
         FCWinMain.FCWM_UMISh_CEFenforce.Visible:=true;
      end
      else FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfRuleNoUnique'));
      if not UMIUFrelocRetVal
      then
      begin
         FCWinMain.FCWM_UMISh_CEFenforce.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMISh_CEFenforceNreq');
         FCWinMain.FCWM_UMISh_CEFenforce.Enabled:=false;
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfNReq'));
      end
      else if (UMIUFrelocRetVal)
         and (UMIUFisFSok)
      then
      begin
         FCWinMain.FCWM_UMISh_CEFenforce.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMISh_CEFenforce');
         FCWinMain.FCWM_UMISh_CEFenforce.Enabled:=true;
         UMIUFcalc:=FCFgSPM_PolicyProc_DoTest(50);
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfYReq1'));
         case UMIUFcalc of
            gspmResMassRjct: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCCFcolRed+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltMassRej')+FCCFcolEND);
            gspmResReject: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCCFcolOrge+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltReject')+FCCFcolEND);
            gspmResFifFifty: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCCFcolYel+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltMitig')+FCCFcolEND);
            gspmResAccept: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCCFcolGreen+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltComplAcc')+FCCFcolEND);
         end;
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfYReq2'));
         UMIUFpolToken:=FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, UMIUFpolArea);
         if (UMIUFisUnique)
            and (UMIUFpolToken<>'')
         then
         begin
            FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add('<br>'+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfUnique')+'<b>'+FCFdTFiles_UIStr_Get(uistrUI, UMIUFpolToken)+'</b> ');
            case UMIUFpolArea of
               dgADMIN: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI, 'UMIgvtPolSys' ) );
               dgECON: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI, 'UMIgvtEcoSys' ) );
               dgMEDCA: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI, 'UMIgvtHcareSys' ) );
               dgSPI: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI, 'UMIgvtRelSys' ) );
            end;
            FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add('.'+FCCFcolEND);
         end;
      end
      else FCWinMain.FCWM_UMISh_CEFenforce.Enabled:=false;
   end; //==END== if UMIUFsec=uiwSPMpolEnfRAP ==//
end;

procedure FCMumi_Main_TabSetSize;
{:Purpose: set default/min UMI size regarding the selected section.
    Additions:
      -2010Nov28- *fix: correctly resize the UMI by puting the constraints before width and height loading.
                  *add: only resize the panel if it's dimensions are < to the minimal values.
      -2010Nov15- *add: min size constraints.
      -2010Oct25- *add: include also height.
}
begin
   case FCWinMain.FCWM_UMI_TabSh.ActivePageIndex of
      {.universe tab}
      0:
      begin
         FCVdiUMIconstraintWidth:=810;
         FCVdiUMIconstraintHeight:=540;
      end;
      {.faction tab}
      1:
      begin
         FCVdiUMIconstraintWidth:=901;
         FCVdiUMIconstraintHeight:=580;
      end;
      {.space units tab}
      2:
      begin
         FCVdiUMIconstraintWidth:=810;
         FCVdiUMIconstraintHeight:=540;
      end;
      {.production tab}
      3:
      begin
         FCVdiUMIconstraintWidth:=810;
         FCVdiUMIconstraintHeight:=540;
      end;
      {.research & development tab}
      4:
      begin
         FCVdiUMIconstraintWidth:=1000;
         FCVdiUMIconstraintHeight:=540;
      end;
   end;
   FCWinMain.FCWM_UMI.Constraints.MinWidth:=FCVdiUMIconstraintWidth;
   if FCWinMain.FCWM_UMI.Width<FCVdiUMIconstraintWidth
   then FCWinMain.FCWM_UMI.Width:=FCVdiUMIconstraintWidth;
   FCWinMain.FCWM_UMI.Constraints.MinHeight:=FCVdiUMIconstraintHeight;
   if FCWinMain.FCWM_UMI.Height<FCVdiUMIconstraintHeight
   then FCWinMain.FCWM_UMI.Height:=FCVdiUMIconstraintHeight;
end;

procedure FCMumi_Main_Upd;
{:Purpose: update, if necessary, the UMI.
    Additions:
      -2012Aug21  *add: faction tab - the dependence status are updated.
                  *add: faction tab - page 0 - the government details are also updated.
      -2010Dec16- *add: update the enforcement list only if it's enabled.
      -2010Dec02- *add: enable the Policy Enforcement update for the faction tab.
      -2010Nov16- *add: enable the SPMi settings update for the faction tab.
}
begin
   if FCWinMain.FCWM_UMI.Visible
   then
   begin
      case FCWinMain.FCWM_UMI_TabSh.ActivePageIndex of
         {.universe}
         0:
         begin

         end;
         {.faction}
         1:
         begin

            {:DEV NOTES: do the same with the dependence status !!!!.}
            FCMumi_Faction_Upd(uiwStatEco, false);
            FCMumi_Faction_Upd(uiwStatSoc, false);
            FCMumi_Faction_Upd(uiwStatMil, false);
            FCMumi_Faction_Upd(uiwNone, true);
            case FCWinMain.FCWM_UMIFac_TabSh.ActivePageIndex of
               0:
               begin
                  {:DEV NOTES: put a new paramt PoliticalStructureALL !!! and remove the useless calls.}
                  FCMumi_Faction_Upd(uiwPolStruc_gvt, false);
                  FCMumi_Faction_Upd(uiwPolStruc_bur, false);
                  FCMumi_Faction_Upd(uiwPolStruc_cor, false);
                  FCMumi_Faction_Upd(uiwPolStruc_eco, false);
                  FCMumi_Faction_Upd(uiwPolStruc_hcare, false);
                  FCMumi_Faction_Upd(uiwPolStruc_spi, false);

                  FCMumi_Faction_Upd(uiwColonies, false);
               end;

               1: FCMumi_Faction_Upd(uiwSPMset, false);
               2:
               begin
                  if FCWinMain.FCWM_UMIFSh_AFlist.Enabled
                  then FCMumi_Faction_Upd(uiwSPMpolEnfList, false);
               end;
            end;
         end;
         2:
         begin

         end;
         3:
         begin

         end;
         4:
         begin

         end;
      end;
   end;
end;

end.
