{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: new game core unit for all game and ui process

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

unit farc_game_newg;

interface

uses
  ComCtrls
  ,Forms
  ,Graphics
  ,SysUtils;

{list of actions for factions list of new game setup window}
type TFCEgngFacListAction=(
   {faction list initialization (new game setup window)}
   flacInit
   {faction list selection (new game setup window)}
   ,flacSlct
   {faction list initialization + selection (new game setup window)}
   ,flacInitSlct
   );

///<summary>
///   update colonization mode data and it's corresponding equipment list, using the index.
///</summary>
procedure FCMgNG_ColMode_Upd;

///<summary>commit new game and initialize game interface.</summary>
procedure FCMgNG_Core_Proceed;

///<summary>setup a new game, core routine.</summary>
procedure FCMgNG_Core_Setup;

///<summary>populate and manage selection of faction list.</summary>
procedure FCMgNG_FactionList_Multipurpose(
   const FLMaction: TFCEgngFacListAction;
   const FLMtgtIdx: integer
   );

procedure FCMgNG_GameName_Update( NewName: string );

implementation

uses
   farc_data_3dopengl
   ,farc_data_files
   ,farc_data_game
   ,farc_data_html
   ,farc_data_init
   ,farc_data_missionstasks
   ,farc_data_spm
   ,farc_data_spu
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_game_cps
   ,farc_game_gameflow
   ,farc_game_spm
   ,farc_game_spmdata
   ,farc_gfx_core
   ,farc_main
   ,farc_ogl_init
   ,farc_ogl_ui
   ,farc_ogl_viewmain
   ,farc_spu_functions
   ,farc_ui_msges
   ,farc_ui_surfpanel
   ,farc_ui_win
   ,farc_univ_func
   ,farc_win_debug
   ,farc_win_newgset;

var
   {:DEV NOTES: bd indexes.}
   SelectedColonizationModeIndex: integer;

   SelectedFactionIndex: integer;

   SetGameName: string;


//===================================================END OF INIT============================

procedure FCMgNG_ColMode_Upd;
{:Purpose: update colonization mode data and it's corresponding equipment list, using the index.
    Additions:
      -2012May23- *mod: changed the display for status' viability thresolds.
      -2012May22- *rem: min/max status levels.
                  *add: economic, social and military viability thresholds.
      -2011Apr25- *mod: some adjustments for space unit equipment items, according to the updated changes in the data structure.
                  *add: the framework of the products equipment item display (needs a prerequisite to complete the code, see the dev note below).
      -2010Sep30- *code audit.
                  *add: some text changes for Colonization Politics.
      -2010Sep02- *add: use a local variable for the design #.
      -2010Mar06- *add: colonization politics data display completion.
}
var
   CMUcnt
//   ,CMUcolMode
   ,CMUdesgn
   ,CMUdockStatus:integer;
//   ,CMUfac: integer;

   CMUstrSpU: string;

   CMUnode: TTreeNode;
begin
//   SelectedFactionIndex:=FCWinNewGSetup.FCWNGS_Frm_FactionList.ItemIndex+1;
   SelectedColonizationModeIndex:=FCWinNewGSetup.FCWNGS_Frm_ColMode.ItemIndex+1;   {:DEV NOTES: put these two in parameters.}
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Clear;
   FCWinNewGSetup.FCWNGS_Frm_DPad_SDL_DotList.Items.Clear;
   {.update colonization politics}
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrEncyl, FCDBfactions[SelectedFactionIndex].F_token+'.ColPol'));
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add('<br>----------<br>');
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add(
      FCFdTFiles_UIStr_Get(uistrUI,'FCWNGS_Frm_ColMode')+': <b>'+FCFdTFiles_UIStr_Get(uistrUI,FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_token)+'</b><br>'
      );
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add(
      FCFdTFiles_UIStr_Get(uistrEncyl, FCDBfactions[SelectedFactionIndex].F_token+'.'+FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_token)+'<br><br>'
      );
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add(
      FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'cpsStatus')+FCCFdHeadEnd
         +FCCFdHead
         +FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLcateg')
         +FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'cpsThrDiff')
         +FCCFidxRRRR+FCFdTFiles_UIStr_Get(uistrUI, 'cpsThr')
         +FCCFdHeadEnd
         +FCCFidxL+'<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLecon')+'</b>'
         +FCCFidxRi+FCcps.FCF_Threshold_GetString( FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_cpsVthEconomic)
         +FCCFidxRRRR+IntToStr( FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_cpsVthEconomic )+' %'
         +'<br>'
         +FCCFidxL+'<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLsoc')+'</b>'
         +FCCFidxRi+FCcps.FCF_Threshold_GetString( FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_cpsVthSocial)
         +FCCFidxRRRR+IntToStr( FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_cpsVthSocial )+' %'
         +'<br>'
         +'<b>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLmil')+'</b>'
         +FCCFidxRi+FCcps.FCF_Threshold_GetString( FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_cpsVthSpaceMilitary)
         +FCCFidxRRRR+IntToStr( FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_cpsVthEconomic )+' %'
         +'<br><br>'
      );
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add(
      FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'cpsCr')+FCCFdHeadEnd
         +'<b>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'cpsCrR')+'</b>'
         +FCCFidxRR
         +FCFdTFiles_UIStr_Get(uistrCrRg, FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_cpsCrRg)
         +' '+FCFdTFiles_UIStr_Get(uistrUI, 'acronUC')
         +'<br>'
         +'<b>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'cpsCrIR')+'</b>'
         +FCCFidxRR
         +FCFdTFiles_UIStr_Get(uistrIntRg, FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_cpsCrRg)
         +' %'
      );
   {.equipment list}
   FCWinNewGSetup.FCWNGS_Frm_DPad_SDL_DotList.FullExpand;
   if Length(FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_dotList)>1
   then
   begin
      CMUdockStatus:=0;
      CMUcnt:=1;
      while CMUcnt<= length(FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_dotList)-1 do
      begin
         case FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_dotList[CMUcnt].FCMEI_itemType of
            feitProduct:
            begin
               {:DEV NOTES: will be implemented when equipment modules w/ cargo will be be also implemented...}
            end;
            feitSpaceUnit:
            begin
               CMUdesgn:=FCFspuF_Design_getDB(FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_dotList[CMUcnt].FCMEI_spuDesignToken);
               CMUdockStatus:=FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_dotList[CMUcnt].FCMEI_spuDockInfo;
               CMUstrSpU:='1x '
                  {.space unit design type}
                  +FCFdTFiles_UIStr_Get(dtfscPrprName,FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_dotList[CMUcnt].FCMEI_spuDesignToken)
                  {.space unit own name}
                  +' "'
                  +FCFdTFiles_UIStr_Get(dtfscPrprName,FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_dotList[CMUcnt].FCMEI_spuProperNameToken)
                  +'" ('
                  +FCFdTFiles_UIStr_Get(dtfscSCarchShort,FCDdsuSpaceUnitDesigns[CMUdesgn].SUD_internalStructureClone.IS_architecture)+')';
               if CMUdockStatus=0
               then FCWinNewGSetup.FCWNGS_Frm_DPad_SDL_DotList.Items.AddChild(CMUnode, CMUstrSpU)
               else CMUnode:= FCWinNewGSetup.FCWNGS_Frm_DPad_SDL_DotList.Items.Add(nil, CMUstrSpU);
            end;
         end;
         inc(CMUcnt);
      end; {.while CMUcnt<= length(FCDBfactions[CMUfacIdx].F_facDotList)-1}
      FCWinNewGSetup.FCWNGS_Frm_DPad_SDL_DotList.FullExpand;
   end; {.if Length(FCDBfactions[CMUfacIdx].F_facDotList)>1}
end;

procedure FCMgNG_Core_Proceed;
{:Purpose: commit new game and initialize game interface.
   Additions:
      -2012May24- *add: store the viability thresholds.
      -2012May22- *rem: min/max status levels.
                  *add: economic, social and military viability thresholds.
      -2011Oct10- *add: surveyed regions initialization.
      -2010Dec19- *add: entity's higher hq level present in the faction
      -2010Oct11- *add: player's faction status initialization.
      -2010Oct06- *add: initialize separate policies and memes data.
      -2010Oct03- *rem: transfer FCMdF_DBSPMi_Read to FCMdInit_Initialize.
      -2010Sep30- *add: forgot to load the SPMi database.
                  *fix: add SPMi modifiers in global entity modifiers only if the SPMi is set.
      -2010Sep29- *add: update entities initialization w/ SPM modifiers + Bureaucracy/Corruption calculations.
                  *mod: for player's entity, initialize the equipment list.
      -2010Sep28- *add: initialization for entities.
      -2010Sep16- *add: entities code.
      -2010Jun15- *mod: use local data for space location.
      -2010Jun06- *rem: viability objectives message.
      -2010May17- *add: colonies sub data structure initialization.
      -2010Mar27- *add: set correctly space unit docking sub data structure initialization.
      -2010Mar14- *add: viability objectives message display.
      -2010Mar08- *add: enable and initialize cps.
                  *fix: when more than 1 starting location, prevent to choose 0.
      -2010Mar07- *mod: only space unit in orbit status are in orbit of the concerned
                  orbital object.
                  *add: add the space unit's status defined in equipment item.
      -2010Mar03- *mod: equipment list subroutine regarding the colonization mode
      -2010Feb18- *add: FCMuiWin_TerrGfxColl_Init.
      -2010Feb02- *add: init surface hotspots.
      -2010Jan20- *add: FUG menu visibility.
      -2009Dec20- *add: satellite orbits.
      -2009Dec19- *add: satellite selection.
      -2009Nov12- *initialize GGFtaskProcUnit.
                  *enable FCWM_MMenu_G_Save.
      -2009Nov09- *reduce code by using FCMspuF_Orbits_Process.
      -2009Nov08- *set the continue game menu item.
                  *reset the owned space units sub-data structure.
      -2009Oct28- *set the game time phase.
      -2009Oct20- *set owned space unit current available reaction mass w/ dotation data.
      -2009Oct12- *set owned space unit deltaV and reaction mass.
      -2009Oct04- *set the welcome message.
      -2009Sep29- *initialize the message box.
      -2009Sep28- *initialize SUO_taskIdx for owned space unit.
                  *initialize TFCGtasklistInProc.
      -2009Sep27- *initialize FCGtskLstToProc.
      -2009Sep23- *load space unit proper name, if it don't have one, a generic one is
                  created.
      -2009Sep15- *add starting location.
                  *complete dotation list initialization.
      -2009Sep13- *remove FCMdFiles_DBSpaceCrafts_Read for use it before new game setup.
                  *add dotation list initialization.
      -2009Sep08- *add FCMdFiles_DBSpaceCrafts_Read data initialization.
      -2009Sep03- *disable new game main menu item (until case of new game during a current
                  one will be implemented).
      -2009Sep02- *enable the game timer.
                  *initialize FCRplayer.Play_timeTick.
      -2009Aug15- *close FCWinNewGSetup.
                  *enable the game user's interface.
                  *enable 3d view.
}
var
//   CPcolMidx
//   ,
   CPcount0
   ,CPcount1
   ,CPeqlistMax
   ,CPfacLd
//   ,CPfacIdx
   ,CPinOrbIdx
   ,CPent
   ,CPoobj
   ,CPowndSCidx
   ,CPsat
   ,CPspmCnt
   ,CPspmMax
   ,CPspUnMother
   ,CPsSys
   ,CPstar: integer;

   CPsv: extended;

   CPspmI: TFCRdgSPMi;
begin
{.DEV NOTES: it's only in the case of a new game at the start of FAR Colony, there'll be some changes and
            in the case of a new game during a current one.}
   {.set some user's interface}
//   if FCWinNewGSetup.Visible
//   then
FCWinNewGSetup.Close;
//FCWinNewGSetup.Enabled:=false;
//FreeAndNil(FCWinNewGSetup);
//FCWinNewGSetup.Free;
//   FCWinMain.Enabled:= true;
   FCWinMain.FCWM_MMenu_G_Cont.Enabled:=false;
   if FCWinMain.FCWM_MMenu_DebTools.Visible
   then FCWinMain.FCWM_MMenu_DebTools.Visible:=false;
   FCMgfxC_TerrainsCollection_Init;
   if not Assigned(FCRdiSettlementPictures[1])
   then FCMgfxC_Settlements_Init;
   {DEV NOTE: will be re-enabled in future.}
   FCWinMain.FCWM_MMenu_G_New.Enabled:=false;
   {.data initialization}
//   CPfacIdx:=FCWinNewGSetup.FCWNGS_Frm_FactionList.ItemIndex+1;
   SetLength(FCGtskLstToProc, 1);
   SetLength(FCGtskListInProc, 1);
   FCMdG_Entities_Clear;
   FCMdF_DBStarSystems_Load;
   {.initialize player's data structure}
   FCRplayer.P_gameName:=SetGameName;// FCWinNewGSetup.FCWNGS_Frm_GNameEdit.Text;
   FCRplayer.P_facAlleg:=FCDBFactions[SelectedFactionIndex].F_token;
//   CPcolMidx:=FCWinNewGSetup.FCWNGS_Frm_ColMode.ItemIndex+1;
   FCRplayer.P_ecoStat:=pfs1_FullyDependent;
   FCRplayer.P_viabThrEco:=FCDBFactions[SelectedFactionIndex].F_facCmode[ SelectedColonizationModeIndex ].FCM_cpsVthEconomic;
   FCRplayer.P_socStat:=pfs1_FullyDependent;
   FCRplayer.P_viabThrSoc:=FCDBFactions[SelectedFactionIndex].F_facCmode[ SelectedColonizationModeIndex ].FCM_cpsVthSocial;
   FCRplayer.P_milStat:=pfs1_FullyDependent;
   FCRplayer.P_viabThrSpMil:=FCDBFactions[SelectedFactionIndex].F_facCmode[ SelectedColonizationModeIndex ].FCM_cpsVthSpaceMilitary;
   {DEV NOTE: the following code will be changed later with choice of planet following choosen faction.}
   {.determine starting location, regarding starting location list}
   CPcount1:=length(FCDBFactions[SelectedFactionIndex].F_facStartLocList)-1;
   if CPcount1=1 then
   begin
      FCRplayer.P_starSysLoc:=FCDBFactions[SelectedFactionIndex].F_facStartLocList[1].FSL_locSSys;
      FCRplayer.P_starLoc:=FCDBFactions[SelectedFactionIndex].F_facStartLocList[1].FSL_locStar;
      FCRplayer.P_oObjLoc:=FCDBFactions[SelectedFactionIndex].F_facStartLocList[1].FSL_locObObj;
   end
   else if CPcount1>1 then
   begin
      CPcount0:=Random(CPcount1)+1;
      FCRplayer.P_starSysLoc:=FCDBFactions[SelectedFactionIndex].F_facStartLocList[CPcount0].FSL_locSSys;
      FCRplayer.P_starLoc:=FCDBFactions[SelectedFactionIndex].F_facStartLocList[CPcount0].FSL_locStar;
      FCRplayer.P_oObjLoc:=FCDBFactions[SelectedFactionIndex].F_facStartLocList[CPcount0].FSL_locObObj;
   end
   else
   begin
      FCRplayer.P_starSysLoc:='stelsysACent';
      FCRplayer.P_starLoc:='starACentA';
      FCRplayer.P_oObjLoc:='orbobjAcentA2';
      FCRplayer.P_satLoc:='';
   end;
   {:DEV NOTES: load the planetary system here.}
   FCMdF_DBStarOrbitalObjects_Load( FCRplayer.P_starSysLoc, FCRplayer.P_starLoc );
   CPsSys:=FCFuF_StelObj_GetDbIdx(
      ufsoSsys
      ,FCRplayer.P_starSysLoc
      ,0
      ,0
      ,0
      );
   CPstar:=FCFuF_StelObj_GetDbIdx(
      ufsoStar
      ,FCRplayer.P_starLoc
      ,CPsSys
      ,0
      ,0
      );
   CPoobj:=FCFuF_StelObj_GetDbIdx(
      ufsoOObj
      ,FCRplayer.P_oObjLoc
      ,CPsSys
      ,CPstar
      ,0
      );
   if FCRplayer.P_satLoc<>''
   then CPsat:=FCFuF_StelObj_GetDbIdx(
      ufsoSat
      ,FCRplayer.P_satLoc
      ,CPsSys
      ,CPstar
      ,CPoobj
      )
   else CPsat:=0;
   {.set the time frame}
   FCRplayer.P_timeTick:=0;
   FCRplayer.P_timeMin:=0;
   FCRplayer.P_timeHr:=0;
   FCRplayer.P_timeday:=1;
   FCRplayer.P_timeMth:=1;
   FCRplayer.P_timeYr:=2250;
   {.surveyed region initialization}
   {:DEV NOTES: it's important to put it BEFORE the entities main loop, because future faction's data will include already surveyed regions data.}
   SetLength(FCRplayer.P_surveyedSpots, 1);
   {.entities main loop}
   CPent:=0;
   while CPent<=FCCdiFactionsMax do
   begin
      SetLength(FCentities[CPent].E_spU, 1);
      SetLength(FCentities[CPent].E_col, 1);
      SetLength(FCentities[CPent].E_spm, 1);
      if CPent>0
      then
      begin
         CPfacLd:=CPent;
         FCentities[CPent].E_token:=FCDBfactions[CPfacLd].F_token;
         FCentities[CPent].E_facLvl:=FCDBfactions[CPfacLd].F_lvl;
         {:DEV NOTES: add space unit and colonies initialization for AI under this line.}
      end
      else if CPent=0
      then
      begin
         CPfacLd:=SelectedFactionIndex;
         FCentities[CPent].E_token:='';
         FCentities[CPent].E_facLvl:=0;
         {.apply faction's equipment list}
         CPspUnMother:=0;
         CPcount0:=1;
         with FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex] do
         begin
            CPeqlistMax:=length(FCM_dotList)-1;
            while CPcount0<=CPeqlistMax do
            begin
               {.spacecraft item}
               if FCM_dotList[CPcount0].FCMEI_itemType=feitSpaceUnit
               then
               begin
                  {.init}
                  SetLength(FCentities[CPent].E_spU, length(FCentities[CPent].E_spU)+1);
                  CPowndSCidx:=length(FCentities[CPent].E_spU)-1;
                  {.unique item name for internal identification}
                  FCentities[CPent].E_spU[CPowndSCidx].SUO_spUnToken:='plyrSpUn'+IntToStr(CPowndSCidx);
                  {.determine proper name of the item if it's a space unit}
                  if FCM_dotList[CPcount0].FCMEI_spuProperNameToken<>''
                  then FCentities[CPent].E_spU[CPowndSCidx].SUO_nameToken:=FCM_dotList[CPcount0].FCMEI_spuProperNameToken
                  else FCentities[CPent].E_spU[CPowndSCidx].SUO_nameToken:='*'+FCFdTFiles_UIStr_Get(uistrUI, 'spUnOvGenName')+' #'+IntToStr(CPowndSCidx);
                  {.link the vessel design}
                  FCentities[CPent].E_spU[CPowndSCidx].SUO_designId:=FCM_dotList[CPcount0].FCMEI_spuDesignToken;
                  {.location}
                  FCentities[CPent].E_spU[CPowndSCidx].SUO_starSysLoc:=FCRplayer.P_starSysLoc;
                  FCentities[CPent].E_spU[CPowndSCidx].SUO_starLoc:=FCRplayer.P_starLoc;
                  FCentities[CPent].E_spU[CPowndSCidx].SUO_satLoc:=FCRplayer.P_satLoc;
                  FCentities[CPent].E_spU[CPowndSCidx].SUO_locStarX:=0;
                  FCentities[CPent].E_spU[CPowndSCidx].SUO_locStarZ:=0;
                  FCentities[CPent].E_spU[CPowndSCidx].SUO_taskIdx:=0 ;
                  {.status + current deltaV}
                  if FCM_dotList[CPcount0].FCMEI_spuStatus=susInFreeSpace
                  then
                  begin
                     FCentities[CPent].E_spU[CPowndSCidx].SUO_status:=susInFreeSpace;
                     FCentities[CPent].E_spU[CPowndSCidx].SUO_deltaV:=0;
                     if FCM_dotList[CPcount0].FCMEI_spuDockInfo=-1
                     then CPspUnMother:=0;
                  end
                  else if FCM_dotList[CPcount0].FCMEI_spuStatus=susInOrbit
                  then
                  begin
                     FCentities[CPent].E_spU[CPowndSCidx].SUO_status:=susInOrbit;
                     FCentities[CPent].E_spU[CPowndSCidx].SUO_deltaV
                        :=FCFspuF_DeltaV_GetFromOrbit(
                           CPsSys
                           ,CPstar
                           ,CPoobj
                           ,CPsat
                           );
                     {.update the orbit sub-data structure of the related orbital object}
                     FCMspuF_Orbits_Process(
                        spufoioAddOrbit
                        ,CPsSys
                        ,CPstar
                        ,CPoobj
                        ,CPsat
                        ,0
                        ,CPowndSCidx
                        ,false
                        );
                     if FCM_dotList[CPcount0].FCMEI_spuDockInfo=1
                     then
                     begin
                        CPspUnMother:=CPowndSCidx;
                        setlength(FCentities[CPent].E_spU[CPowndSCidx].SUO_dockedSU, 1);
                     end
                     else if FCM_dotList[CPcount0].FCMEI_spuDockInfo=-1
                     then CPspUnMother:=0;
                  end
                  else if FCM_dotList[CPcount0].FCMEI_spuStatus=susLanded
                  then
                  begin
                     FCentities[CPent].E_spU[CPowndSCidx].SUO_status:=susLanded;
                     FCentities[CPent].E_spU[CPowndSCidx].SUO_deltaV:=0;
                     if FCM_dotList[CPcount0].FCMEI_spuDockInfo=-1
                     then CPspUnMother:=0;
                  end
                  else if FCM_dotList[CPcount0].FCMEI_spuStatus=susDocked
                  then
                  begin
                     FCentities[CPent].E_spU[CPowndSCidx].SUO_status:=susDocked;
                     setlength(
                        FCentities[CPent].E_spU[CPspUnMother].SUO_dockedSU
                        ,length(FCentities[CPent].E_spU[CPspUnMother].SUO_dockedSU)+1
                        );
                     FCentities[CPent].E_spU[CPspUnMother].SUO_dockedSU[length(FCentities[CPent].E_spU[CPspUnMother].SUO_dockedSU)-1]
                        .SUD_dckdToken:=FCentities[CPent].E_spU[CPowndSCidx].SUO_spUnToken;
                     FCentities[CPent].E_spU[CPowndSCidx].SUO_deltaV:=FCentities[CPent].E_spU[CPspUnMother].SUO_deltaV;
                  end;
                  {.available reaction mass}
                  FCentities[CPent].E_spU[CPowndSCidx].SUO_availRMass:=FCM_dotList[CPcount0].FCMEI_spuAvailEnRM;
               end; //==END== if FCM_dotList[CPcount0].FDI_itemTp=facdtpSpaceCraft ==//
               inc(CPcount0);
            end; //==END== while CPcount0<= length(FCM_dotList)-1 ==//
         end; //==END== with FCDBfactions[CPfacIdx].F_facCmode[CPcolMidx] ==//
      end; //==END== else if CPent=0 ==//
      CPspmMax:=length(FCDBdgSPMi);
      SetLength(FCentities[CPent].E_spm, CPspmMax);
      CPspmCnt:=1;
      while CPspmCnt<=CPspmMax-1 do
      begin
         FCentities[CPent].E_spm[CPspmCnt].SPMS_token:=FCDBdgSPMi[CPspmCnt].SPMI_token;
         FCentities[CPent].E_spm[CPspmCnt].SPMS_duration:=FCDBfactions[CPfacLd].F_spm[CPspmCnt].SPMS_duration;
         FCentities[CPent].E_spm[CPspmCnt].SPMS_ucCost:=0;
         FCentities[CPent].E_spm[CPspmCnt].SPMS_isPolicy:=FCDBdgSPMi[CPspmCnt].SPMI_isPolicy;
         if FCentities[CPent].E_spm[CPspmCnt].SPMS_isPolicy
         then
         begin
            FCentities[CPent].E_spm[CPspmCnt].SPMS_isSet:=FCDBfactions[CPfacLd].F_spm[CPspmCnt].SPMS_isSet;
            FCentities[CPent].E_spm[CPspmCnt].SPMS_aprob:=FCDBfactions[CPfacLd].F_spm[CPspmCnt].SPMS_aprob;
            if FCentities[CPent].E_spm[CPspmCnt].SPMS_isSet
            then
            begin
               CPspmI:=FCFgSPM_SPMIData_Get(FCentities[CPent].E_spm[CPspmCnt].SPMS_token);
               FCentities[CPent].E_spmMcohes:=FCentities[CPent].E_spmMcohes+CPspmI.SPMI_modCohes;
               FCentities[CPent].E_spmMtens:=FCentities[CPent].E_spmMtens+CPspmI.SPMI_modTens;
               FCentities[CPent].E_spmMsec:=FCentities[CPent].E_spmMsec+CPspmI.SPMI_modSec;
               FCentities[CPent].E_spmMedu:=FCentities[CPent].E_spmMedu+CPspmI.SPMI_modEdu;
               FCentities[CPent].E_spmMnat:=FCentities[CPent].E_spmMnat+CPspmI.SPMI_modNat;
               FCentities[CPent].E_spmMhealth:=FCentities[CPent].E_spmMhealth+CPspmI.SPMI_modHeal;
               FCentities[CPent].E_spmMBur:=FCentities[CPent].E_spmMBur+CPspmI.SPMI_modBur;
               FCentities[CPent].E_spmMCorr:=FCentities[CPent].E_spmMCorr+CPspmI.SPMI_modCorr;
               {:DEV NOTES: add SPMi custom effects application here.}
            end;
         end
         else if not FCentities[CPent].E_spm[CPspmCnt].SPMS_isPolicy
         then
         begin
            FCentities[CPent].E_spm[CPspmCnt].SPMS_bLvl:=FCDBfactions[CPfacLd].F_spm[CPspmCnt].SPMS_bLvl;
            FCentities[CPent].E_spm[CPspmCnt].SPMS_sprdVal:=FCDBfactions[CPfacLd].F_spm[CPspmCnt].SPMS_sprdVal;
            if FCentities[CPent].E_spm[CPspmCnt].SPMS_bLvl>=blFleeting
            then
            begin
               CPsv:=FCentities[CPent].E_spm[CPspmCnt].SPMS_sprdVal*0.01;
               CPspmI:=FCFgSPM_SPMIData_Get(FCentities[CPent].E_spm[CPspmCnt].SPMS_token);
               FCentities[CPent].E_spmMcohes:=FCentities[CPent].E_spmMcohes+round(CPspmI.SPMI_modCohes*CPsv);
               FCentities[CPent].E_spmMtens:=FCentities[CPent].E_spmMtens+round(CPspmI.SPMI_modTens*CPsv);
               FCentities[CPent].E_spmMsec:=FCentities[CPent].E_spmMsec+round(CPspmI.SPMI_modSec*CPsv);
               FCentities[CPent].E_spmMedu:=FCentities[CPent].E_spmMedu+round(CPspmI.SPMI_modEdu*CPsv);
               FCentities[CPent].E_spmMnat:=FCentities[CPent].E_spmMnat+round(CPspmI.SPMI_modNat*CPsv);
               FCentities[CPent].E_spmMhealth:=FCentities[CPent].E_spmMhealth+round(CPspmI.SPMI_modHeal*CPsv);
               FCentities[CPent].E_spmMBur:=FCentities[CPent].E_spmMBur+round(CPspmI.SPMI_modBur*CPsv);
               FCentities[CPent].E_spmMCorr:=FCentities[CPent].E_spmMCorr+round(CPspmI.SPMI_modCorr*CPsv);
               {:DEV NOTES: add SPMi custom effects application here.}
            end;
         end;
         inc(CPspmCnt);
      end;
      FCentities[CPent].E_bureau:=FCFgSPMD_Bureaucracy_Init(CPent);
      FCentities[CPent].E_corrupt:=FCFgSPMD_Corruption_Init(CPent);
      if CPent=0
      then FCentities[CPent].E_hqHigherLvl:=hqsNoHQPresent
      else if CPent>0
      then FCentities[CPent].E_hqHigherLvl:=hqsPrimaryUniqueHQ;
      inc(CPent);
   end; //==END== while CPent<=FCCfacMax do ==//
   {.set the game user's interface}
   FCWinMain.FCGLSRootMain.Tag:=1;
   try
      FCWinMain.FCWM_3dMainGrp.Show;
      FCMoglInit_Initialize;
   finally
      FC3doglSelectedPlanetAsteroid:=CPoobj;
      FCMoglVM_MView_Upd(
         FCRplayer.P_starSysLoc
         ,FCRplayer.P_starLoc
         ,false
         ,true
         );
      if CPsat>0
      then FC3doglSelectedSatellite:=FCFoglVM_SatObj_Search(CPoobj, CPsat)
      else if (CPsat=0)
         and (FC3doglTotalSatellites>0)
      then
      begin
         FC3doglSelectedSatellite:=1;
      end;
   end;
   {.cps initialization}
   FCcps:=TFCcps.Create(
      FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_cpsCrRg
      ,FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_cpsIntRg
      ,FCDBfactions[SelectedFactionIndex].F_facCmode[SelectedColonizationModeIndex].FCM_cpsViabObj
      );
   {.set the messages}
   FCMuiM_Messages_Reset;
   FCMuiM_Message_Add(
      mtWelcome
      ,SelectedFactionIndex
      ,SelectedColonizationModeIndex
      ,0
      ,0
      ,0
      );
   {.free useless data}
   CPcount0:=1;
   while CPcount0<=1 do
   begin
      setlength(FCDBfactions[CPcount0].F_facCmode,1);
      setlength(FCDBfactions[CPcount0].F_facStartLocList,1);
      inc(CPcount0);
   end;
   FCMuiSP_SurfaceEcosphere_Set(0, 0, true);
   FCWinMain.caption:=FCWinMain.caption+'   ['+FCFdTFiles_UIStr_Get(uistrUI,'comCurGame')+FCRplayer.P_gameName+']';
   FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutCPS);
end;

procedure FCMgNG_Core_Setup;
{:Purpose: setup a new game, core routine.
   Additions:
      -2009Oct05- *relocate correctly the new game setup window in the case of the main window has moved.
      -2009Aug10- *initialize proceed button state.
                  *populate the faction list.
}
var
   CStestDmp: integer;
begin
{:DEV NOTES: put the data loading in a proc and load it also for a continue game(one time loading).}
   if length( FCDdsuSpaceUnitDesigns )<=1 then begin
FCMdF_DBProducts_Load;
   FCMdF_DBSPMitems_Load;
   FCMdF_DBFactions_Load;
   FCMdF_DBInfrastructures_Load;
   FCMdF_DBSpaceUnits_Load;
   end;
   try
   if FCWinNewGSetup=nil
   then  begin
   FCWinNewGSetup:=TFCWinNewGSetup.Create(Application);
      FCMuiW_UI_Initialize(mwupSecWinNewGSetup);
   FCMuiW_UI_Initialize(mwupFontWinNGS);
   FCMuiW_UI_Initialize(mwupTextWinNGS);
   end;
   finally
{.DEV NOTES: it's only in the case of a new game at the start of FAR Colony, there'll be some changes and
            in the case of a new game during a current one.}
//   with FCWinNewGSetup do
//   begin
      SetGameName:='';
      FCWinMain.Enabled:= false;
      FCWinNewGSetup.Enabled:= true;
      FCWinNewGSetup.FCWNGS_Frm_ButtProceed.Enabled:= false;
      CStestDmp:=FCWinMain.Left+(FCWinMain.Width shr 1)-(FCWinNewGSetup.Width shr 1);
      if FCWinNewGSetup.Left<>CStestDmp
      then FCWinNewGSetup.Left:=CStestDmp;
      CStestDmp:=FCWinMain.Top+(FCWinMain.Height shr 1)-(FCWinNewGSetup.Height shr 1)+40;
      if FCWinNewGSetup.Top<>CStestDmp
      then FCWinNewGSetup.Top:=CStestDmp;
      FCWinNewGSetup.Show;
      FCWinNewGSetup.BringToFront;
      FCWinNewGSetup.FCWNGS_Frm_GNameEdit.EditLabel.Font.Color:=clRed;
      FCWinNewGSetup.FCWNGS_Frm_GNameEdit.Text:= '';
      if FCWinNewGSetup.FCWNGS_Frm_FactionList.Count=0
      then FCMgNG_FactionList_Multipurpose(flacInitSlct,0);
//   end; {.with FCWinNewGSetup}
   end;
end;


procedure FCMgNG_FactionList_Multipurpose(
   const FLMaction: TFCEgngFacListAction;
   const FLMtgtIdx: integer
   );
{:Purpose: populate and manage selection of faction list.
   Additions:
      -2010Oct03- *mod: display faction society text under history text.
                  *add: SPMi list.
      -2010Mar03- *add: set FCWNGS_Frm_ColMode.
      -2010Mar01- *mod: change history display.
                  *add: display society description text.
      -2009Sep23- *display space unit proper name in dotation list.
      -2009Sep13- *complete dotation list display.
      -2009Sep12- *add faction's dotation list display.
      -2009Aug11- *add flag loading.
                  *work for any faction token now.
}
var
   FLMcnt
//   ,FLMfac
   ,FLMmax: integer;

   FLMspmStr: string;

   FLMsetNode
   ,FLMnsetNode: TTreeNode;

   FLMspmi: TFCRdgSPMi;
begin
   {.initialization}
   if (FLMaction=flacInitSlct)
      or (FLMaction=flacInit)
   then
   begin
      FLMcnt:= 1;
      FCWinNewGSetup.FCWNGS_Frm_FactionList.Items.Clear;
      FCWinNewGSetup.FCWNGS_Frm_DPad_SDL_DotList.Items.Clear;
      SelectedFactionIndex:=1;
      while FLMcnt<= Length(FCDBfactions)-1 do
      begin
         FCWinNewGSetup.FCWNGS_Frm_FactionList.Items.Add(FCFdTFiles_UIStr_Get(uistrUI,FCDBfactions[FLMcnt].F_token));
         inc(FLMcnt);
      end;
   end;
   {.selection}
   if (FLMaction=flacInitSlct)
      or (FLMaction=flacSlct)
   then
   begin
      FCWinNewGSetup.FCWNGS_Frm_FactionList.ItemIndex:=FLMtgtIdx;
      SelectedFactionIndex:=FLMtgtIdx+1;
      {.update description}
      FCWinNewGSetup.FCWNGS_Frm_DPad_SHisto_Text.HTMLText.Clear;
      FCWinNewGSetup.FCWNGS_Frm_DPad_SHisto_Text.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrEncyl, FCDBfactions[SelectedFactionIndex].F_token+'.Hist'));
      FCWinNewGSetup.FCWNGS_Frm_DPad_SHisto_Text.HTMLText.Add('<br><br>');
      FCWinNewGSetup.FCWNGS_Frm_DPad_SHisto_Text.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrEncyl, FCDBfactions[SelectedFactionIndex].F_token+'.Soc'));
      {.SPMi list}
      FCWinNewGSetup.FCWNGS_Frm_DPad_SDL_DotList.FullExpand;
      FLMmax:=Length(FCDBfactions[SelectedFactionIndex].F_spm)-1;
      if FLMmax>0
      then
      begin
         FLMcnt:=1;
         FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.Items.Clear;
         FLMsetNode:=FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.Items.AddChild(nil, '<b>SPMi set</b>');
         FLMnsetNode:=FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.Items.AddChild(nil, '<b>SPMi not set</b>');
         while FLMcnt<=FLMmax do
         begin
            FLMspmi:=FCDBdgSPMi[0];
            FLMspmi:=FCFgSPM_SPMIData_Get(FCDBfactions[SelectedFactionIndex].F_spm[FLMcnt].SPMS_token);
            FLMspmStr:=FCFdTFiles_UIStr_Get(uistrUI, FCDBfactions[SelectedFactionIndex].F_spm[FLMcnt].SPMS_token);
            if not FLMspmi.SPMI_isPolicy
            then FLMspmStr:=FLMspmStr+' ['+IntToStr(FCDBfactions[SelectedFactionIndex].F_spm[FLMcnt].SPMS_aprob)+' %]';
            if FCDBfactions[SelectedFactionIndex].F_spm[FLMcnt].SPMS_isSet
            then FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.Items.AddChild(FLMsetNode, FLMspmStr)
            else if not FCDBfactions[SelectedFactionIndex].F_spm[FLMcnt].SPMS_isSet
            then FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.Items.AddChild(FLMnsetNode, FLMspmStr);
            inc(FLMcnt);
         end;
         FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.FullExpand;
      end;
      {.display the faction's flag}
      FCWinNewGSetup.FCWNGS_Frm_FactionFlag.Bitmap.LoadFromFile(FCVdiPathResourceDir+'pics-ui-faction\FAC_'+FCDBfactions[SelectedFactionIndex].F_token+'_flag.jpg');
      {.set colonization modes}
      FCWinNewGSetup.FCWNGS_Frm_ColMode.Items.Clear;
      FLMmax:=length(FCDBfactions[SelectedFactionIndex].F_facCmode)-1;
      FLMcnt:=1;
      while FLMcnt<=FLMmax do
      begin
         FCWinNewGSetup.FCWNGS_Frm_ColMode.Items.Add(FCFdTFiles_UIStr_Get(uistrUI, 'munCmodARC'));
         inc(FLMcnt);
      end;
      FCWinNewGSetup.FCWNGS_Frm_ColMode.ItemIndex:=0;
      SelectedColonizationModeIndex:=1;
      FCMgNG_ColMode_Upd;
   end;
end;


procedure FCMgNG_GameName_Update( NewName: string );
{:Purpose: .
    Additions:
}
begin
   SetGameName:=NewName;
end;

end.
