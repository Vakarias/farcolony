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
   farc_common_func
   ,farc_data_3dopengl
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
   ,farc_ogl_functions
   ,farc_ogl_init
   ,farc_ogl_ui
   ,farc_ogl_viewmain
   ,farc_spu_functions
   ,farc_survey_core
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
//   ,CMUdockStatus
   :integer;
//   ,CMUfac: integer;

   CMUstrSpU: string;

   CMUnode: TTreeNode;
begin
//   SelectedFactionIndex:=FCWinNewGSetup.FCWNGS_Frm_FactionList.ItemIndex+1;
   SelectedColonizationModeIndex:=FCWinNewGSetup.FCWNGS_Frm_ColMode.ItemIndex+1;   {:DEV NOTES: put these two in parameters.}
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Clear;
   FCWinNewGSetup.FCWNGS_Frm_DPad_SDL_DotList.Items.Clear;
   {.update colonization politics}
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrEncyl, FCDdgFactions[SelectedFactionIndex].F_token+'.ColPol'));
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add('<br>----------<br>');
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add(
      FCFdTFiles_UIStr_Get(uistrUI,'FCWNGS_Frm_ColMode')+': <b>'+FCFdTFiles_UIStr_Get(uistrUI,FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_token)+'</b><br>'
      );
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add(
      FCFdTFiles_UIStr_Get(uistrEncyl, FCDdgFactions[SelectedFactionIndex].F_token+'.'+FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_token)+'<br><br>'
      );
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add(
      FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'cpsStatus')+FCCFdHeadEnd
         +FCCFdHead
         +FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLcateg')
         +FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'cpsThrDiff')
         +FCCFidxRRRR+FCFdTFiles_UIStr_Get(uistrUI, 'cpsThr')
         +FCCFdHeadEnd
         +FCCFidxL+'<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLecon')+'</b>'
         +FCCFidxRi+FCcps.FCF_Threshold_GetString( FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_cpsViabilityThreshold_Economic)
         +FCCFidxRRRR+IntToStr( FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_cpsViabilityThreshold_Economic )+' %'
         +'<br>'
         +FCCFidxL+'<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLsoc')+'</b>'
         +FCCFidxRi+FCcps.FCF_Threshold_GetString( FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_cpsViabilityThreshold_Social)
         +FCCFidxRRRR+IntToStr( FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_cpsViabilityThreshold_Social )+' %'
         +'<br>'
         +'<b>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLmil')+'</b>'
         +FCCFidxRi+FCcps.FCF_Threshold_GetString( FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_cpsViabilityThreshold_SpaceMilitary)
         +FCCFidxRRRR+IntToStr( FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_cpsViabilityThreshold_Economic )+' %'
         +'<br><br>'
      );
   FCWinNewGSetup.FCWNGS_Frm_DPad_SCol_Text.HTMLText.Add(
      FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'cpsCr')+FCCFdHeadEnd
         +'<b>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'cpsCrR')+'</b>'
         +FCCFidxRR
         +FCFdTFiles_UIStr_Get(uistrCrRg, FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_cpsCreditRange)
         +' '+FCFdTFiles_UIStr_Get(uistrUI, 'acronUC')
         +'<br>'
         +'<b>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'cpsCrIR')+'</b>'
         +FCCFidxRR
         +FCFdTFiles_UIStr_Get(uistrIntRg, FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_cpsCreditRange)
         +' %'
      );
   {.equipment list}
   FCWinNewGSetup.FCWNGS_Frm_DPad_SDL_DotList.FullExpand;
   if Length(FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_equipmentList)>1
   then
   begin
//      CMUdockStatus:=0;
      CMUcnt:=1;
      while CMUcnt<= length(FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_equipmentList)-1 do
      begin
         case FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_equipmentList[CMUcnt].EL_equipmentItem of
            feitProduct:
            begin
               {:DEV NOTES: will be implemented when equipment modules w/ cargo will be be also implemented...}
            end;
            feitSpaceUnit:
            begin
               CMUdesgn:=FCFspuF_Design_getDB(FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_equipmentList[CMUcnt].EL_eiSUnDesignToken);
               CMUstrSpU:='1x '
                  {.space unit design type}
                  +FCFdTFiles_UIStr_Get(dtfscPrprName,FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_equipmentList[CMUcnt].EL_eiSUnDesignToken)
                  {.space unit own name}
                  +' "'
                  +FCFdTFiles_UIStr_Get(dtfscPrprName,FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_equipmentList[CMUcnt].EL_eiSUnNameToken)
                  +'" ('
                  +FCFdTFiles_UIStr_Get(dtfscSCarchShort,FCDdsuSpaceUnitDesigns[CMUdesgn].SUD_internalStructureClone.IS_architecture)+')';
               if FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_equipmentList[CMUcnt].EL_eiSUnDockStatus=diDockedVessel
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
      -2013Sep11- *add: initialize the quality index for each regions' resource spot of each asteroid/telluric planet.
      -2013Jul10- *add: set the regions' current data.
      -2013Jul08- *add: initialize the current revolution periods.
      -2013Mar10- *add: initialize entity's E_planetarySurveys.
      -2012Dec04- *add: for docked vessels, load the SU_locationDockingMotherCraft.
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
   ,CPowndSCidx
   ,CPspmCnt
   ,CPspmMax
   ,CPspUnMother
   ,Count1
   ,Count2
   ,Count3
   ,Count4
   ,Count5
   ,Count6
   ,Max1
   ,Max2
   ,Max3
   ,Max4
   ,Max5
   ,Max6: integer;

   CPsv: extended;

   CPspmI: TFCRdgSPMi;

   ULoc: TFCRufStelObj;

   function _ResourceSpotQuality_Process(): TFCEduResourceSpotQuality;
      var
         EvalInt: integer;
   begin
      Result:=rsqNone;
      EvalInt:=0;
      EvalInt:=FCFcF_Random_DoInteger( 99 ) + 1;
      case EvalInt of
         1..15: Result:=rsqF_Bad;

         16..35: Result:=rsqE_Poor;

         36..60: Result:=rsqD_FairAverage;

         61..80: Result:=rsqC_Good;

         81..90: Result:=rsqB_Excellent;

         91..100: Result:=rsqA_Perfect;
      end;
   end;

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
   FCMgfxC_Main_Init;
   {DEV NOTE: will be re-enabled in future.}
   FCWinMain.FCWM_MMenu_G_New.Enabled:=false;
   {.data initialization}
//   CPfacIdx:=FCWinNewGSetup.FCWNGS_Frm_FactionList.ItemIndex+1;
   SetLength(FCDdmtTaskListToProcess, 1);
   SetLength(FCDdmtTaskListInProcess, 1);
   FCMdG_Entities_Clear;
   FCMdF_DBStarSystems_Load;
   {.initialize player's data structure}
   FCVdgPlayer.P_gameName:=SetGameName;// FCWinNewGSetup.FCWNGS_Frm_GNameEdit.Text;
   FCVdgPlayer.P_allegianceFaction:=FCDdgFactions[SelectedFactionIndex].F_token;
//   CPcolMidx:=FCWinNewGSetup.FCWNGS_Frm_ColMode.ItemIndex+1;
   FCVdgPlayer.P_economicStatus:=pfs1_FullyDependent;
   FCVdgPlayer.P_economicViabilityThreshold:=FCDdgFactions[SelectedFactionIndex].F_colonizationModes[ SelectedColonizationModeIndex ].CM_cpsViabilityThreshold_Economic;
   FCVdgPlayer.P_socialStatus:=pfs1_FullyDependent;
   FCVdgPlayer.P_socialViabilityThreshold:=FCDdgFactions[SelectedFactionIndex].F_colonizationModes[ SelectedColonizationModeIndex ].CM_cpsViabilityThreshold_Social;
   FCVdgPlayer.P_militaryStatus:=pfs1_FullyDependent;
   FCVdgPlayer.P_militaryViabilityThreshold:=FCDdgFactions[SelectedFactionIndex].F_colonizationModes[ SelectedColonizationModeIndex ].CM_cpsViabilityThreshold_SpaceMilitary;
   {DEV NOTE: the following code will be changed later with choice of planet following choosen faction.}
   {.determine starting location, regarding starting location list}
   CPcount1:=length(FCDdgFactions[SelectedFactionIndex].F_startingLocations)-1;
   if CPcount1=1 then
   begin
      FCVdgPlayer.P_viewStarSystem:=FCDdgFactions[SelectedFactionIndex].F_startingLocations[1].SL_stellarSystem;
      FCVdgPlayer.P_viewStar:=FCDdgFactions[SelectedFactionIndex].F_startingLocations[1].SL_star;
      FCVdgPlayer.P_viewOrbitalObject:=FCDdgFactions[SelectedFactionIndex].F_startingLocations[1].SL_orbitalObject;
   end
   else if CPcount1>1 then
   begin
      CPcount0:=Random(CPcount1)+1;
      FCVdgPlayer.P_viewStarSystem:=FCDdgFactions[SelectedFactionIndex].F_startingLocations[CPcount0].SL_stellarSystem;
      FCVdgPlayer.P_viewStar:=FCDdgFactions[SelectedFactionIndex].F_startingLocations[CPcount0].SL_star;
      FCVdgPlayer.P_viewOrbitalObject:=FCDdgFactions[SelectedFactionIndex].F_startingLocations[CPcount0].SL_orbitalObject;
   end;
   {.initialize FARC's universe}
   FCMdF_DBStarOrbitalObjects_Load( FCVdgPlayer.P_viewStarSystem, FCVdgPlayer.P_viewStar );
   {.initialize/reset the current orbital periods}
   Max1:=length( FCDduStarSystem ) - 1;
   Count1:=1;
   while Count1 <= Max1 do
   begin
      Max2:=length( FCDduStarSystem[Count1].SS_stars ) - 1;
      Count2:=1;
      while Count2 <= Max2 do
      begin
         Max3:=length( FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects ) - 1;
         Count3:=1;
         while Count3 <= Max3 do
         begin
            FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects[Count3].OO_revolutionPeriodCurrent:=FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects[Count3].OO_revolutionPeriodInit;
            FCMuF_Regions_SetCurrentClimateData(
               Count1
               ,Count2
               ,Count3
               );
            Max5:=length( FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects[Count3].OO_regions ) - 1;
            Count5:=1;
            while Count5 <= Max5 do
            begin
               Max6:=length( FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects[Count3].OO_regions[Count5].OOR_resourceSpot ) - 1;
               Count6:=1;
               while Count6 <= Max6 do
               begin
                  FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects[Count3].OO_regions[Count5].OOR_resourceSpot[Count6].RRS_quality:=_ResourceSpotQuality_Process;
                  inc( Count6 );
               end;
               inc( Count5 );
            end;
            Max4:=length( FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects[Count3].OO_satellitesList ) - 1;
            Count4:=1;
            while Count4 <= Max4 do
            begin
               FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects[Count3].OO_satellitesList[Count4].OO_revolutionPeriodCurrent:=FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects[Count3].OO_satellitesList[Count4].OO_revolutionPeriodInit;
               FCMuF_Regions_SetCurrentClimateData(
                  Count1
                  ,Count2
                  ,Count3
                  ,Count4
                  );
               Max5:=length( FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects[Count3].OO_satellitesList[Count4].OO_regions ) - 1;
               Count5:=1;
               while Count5 <= Max5 do
               begin
                  Max6:=length( FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects[Count3].OO_satellitesList[Count4].OO_regions[Count5].OOR_resourceSpot ) - 1;
                  Count6:=1;
                  while Count6 <= Max6 do
                  begin
                     FCDduStarSystem[Count1].SS_stars[Count2].S_orbitalObjects[Count3].OO_satellitesList[Count4].OO_regions[Count5].OOR_resourceSpot[Count6].RRS_quality:=_ResourceSpotQuality_Process;
                     inc( Count6 );
                  end;
                  inc( Count5 );
               end;
               inc( Count4 );
            end;
            inc( Count3);
         end;
         inc( Count2 );
      end;
      inc( Count1 );
   end;
   ULoc:=FCFuF_StelObj_GetFullRow(
      FCVdgPlayer.P_viewStarSystem
      ,FCVdgPlayer.P_viewStar
      ,FCVdgPlayer.P_viewOrbitalObject
      ,FCVdgPlayer.P_viewSatellite
      );
   {.set the time frame}
   FCVdgPlayer.P_currentTimeTick:=0;
   FCVdgPlayer.P_currentTimeMinut:=0;
   FCVdgPlayer.P_currentTimeHour:=0;
   FCVdgPlayer.P_currentTimeDay:=1;
   FCVdgPlayer.P_currentTimeMonth:=1;
   FCVdgPlayer.P_currentTimeYear:=2250;
   {.entities main loop}
   CPent:=0;
   while CPent<=FCCdiFactionsMax do
   begin
      SetLength(FCDdgEntities[CPent].E_spaceUnits, 1);
      SetLength(FCDdgEntities[CPent].E_colonies, 1);
      SetLength(FCDdgEntities[CPent].E_spmSettings, 1);
      if CPent>0
      then
      begin
         CPfacLd:=CPent;
         FCDdgEntities[CPent].E_token:=FCDdgFactions[CPfacLd].F_token;
         FCDdgEntities[CPent].E_factionLevel:=FCDdgFactions[CPfacLd].F_level;
         {:DEV NOTES: add space unit and colonies initialization for AI under this line.}
      end
      else if CPent=0
      then
      begin
         CPfacLd:=SelectedFactionIndex;
         FCDdgEntities[CPent].E_token:='';
         FCDdgEntities[CPent].E_factionLevel:=0;
         {.apply faction's equipment list}
         CPspUnMother:=0;
         CPcount0:=1;
         with FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex] do
         begin
            CPeqlistMax:=length(CM_equipmentList)-1;
            while CPcount0<=CPeqlistMax do
            begin
               {.spacecraft item}
               if CM_equipmentList[CPcount0].EL_equipmentItem=feitSpaceUnit
               then
               begin
                  {.init}
                  SetLength(FCDdgEntities[CPent].E_spaceUnits, length(FCDdgEntities[CPent].E_spaceUnits)+1);
                  CPowndSCidx:=length(FCDdgEntities[CPent].E_spaceUnits)-1;
                  {.unique item name for internal identification}
                  FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_token:='plyrSpUn'+IntToStr(CPowndSCidx);
                  {.determine proper name of the item if it's a space unit}
                  if CM_equipmentList[CPcount0].EL_eiSUnNameToken<>''
                  then FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_name:=CM_equipmentList[CPcount0].EL_eiSUnNameToken
                  else FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_name:='*'+FCFdTFiles_UIStr_Get(uistrUI, 'spUnOvGenName')+' #'+IntToStr(CPowndSCidx);
                  {.link the vessel design}
                  FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_designToken:=CM_equipmentList[CPcount0].EL_eiSUnDesignToken;
                  {.location}
                  FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_locationStarSystem:=FCVdgPlayer.P_viewStarSystem;
                  FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_locationStar:=FCVdgPlayer.P_viewStar;
                  FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_locationSatellite:=FCVdgPlayer.P_viewSatellite;
                  FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_locationDockingMotherCraft:=0;
                  FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_locationViewX:=0;
                  FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_locationViewZ:=0;
                  FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_assignedTask:=0 ;
                  {.status + current deltaV}
                  if CM_equipmentList[CPcount0].EL_eiSUnStatus=susInFreeSpace
                  then
                  begin
                     FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_status:=susInFreeSpace;
                     FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_deltaV:=0;
                     if CM_equipmentList[CPcount0].EL_eiSUnDockStatus=diNotDocked
                     then CPspUnMother:=0;
                  end
                  else if CM_equipmentList[CPcount0].EL_eiSUnStatus = susInOrbit then
                  begin
                     FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_status:=susInOrbit;
                     FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_deltaV:=FCFspuF_DeltaV_GetFromOrbit(
                        ULoc[1]
                        ,ULoc[2]
                        ,ULoc[3]
                        ,ULoc[4]
                        );
                     {.update the orbit sub-data structure of the related orbital object}
                     FCMspuF_Orbits_Process(
                        spufoioAddOrbit
                        ,ULoc[1]
                        ,ULoc[2]
                        ,ULoc[3]
                        ,ULoc[4]
                        ,0
                        ,CPowndSCidx
                        ,false
                        );
                     if CM_equipmentList[CPcount0].EL_eiSUnDockStatus=diMotherVessel
                     then
                     begin
                        CPspUnMother:=CPowndSCidx;
                        setlength(FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_dockedSpaceUnits, 1);
                     end
                     else if CM_equipmentList[CPcount0].EL_eiSUnDockStatus=diNotDocked
                     then CPspUnMother:=0;
                  end
                  else if CM_equipmentList[CPcount0].EL_eiSUnStatus=susLanded
                  then
                  begin
                     FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_status:=susLanded;
                     FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_deltaV:=0;
                     if CM_equipmentList[CPcount0].EL_eiSUnDockStatus=diNotDocked
                     then CPspUnMother:=0;
                  end
                  else if CM_equipmentList[CPcount0].EL_eiSUnStatus=susDocked
                  then
                  begin
                     FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_status:=susDocked;
                     setlength(
                        FCDdgEntities[CPent].E_spaceUnits[CPspUnMother].SU_dockedSpaceUnits
                        ,length(FCDdgEntities[CPent].E_spaceUnits[CPspUnMother].SU_dockedSpaceUnits)+1
                        );
                     FCDdgEntities[CPent].E_spaceUnits[CPspUnMother].SU_dockedSpaceUnits[length(FCDdgEntities[CPent].E_spaceUnits[CPspUnMother].SU_dockedSpaceUnits)-1]
                        .SUDL_index:=CPowndSCidx;
                     FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_deltaV:=FCDdgEntities[CPent].E_spaceUnits[CPspUnMother].SU_deltaV;
                     FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_locationDockingMotherCraft:=CPspUnMother;
                  end;
                  {.available reaction mass}
                  FCDdgEntities[CPent].E_spaceUnits[CPowndSCidx].SU_reactionMass:=CM_equipmentList[CPcount0].EL_eiSUnReactionMass;
               end; //==END== if FCM_dotList[CPcount0].FDI_itemTp=facdtpSpaceCraft ==//
               inc(CPcount0);
            end; //==END== while CPcount0<= length(FCM_dotList)-1 ==//
         end; //==END== with FCDBfactions[CPfacIdx].F_facCmode[CPcolMidx] ==//
      end; //==END== else if CPent=0 ==//
      CPspmMax:=length(FCDdgSPMi);
      SetLength(FCDdgEntities[CPent].E_spmSettings, CPspmMax);
      CPspmCnt:=1;
      while CPspmCnt<=CPspmMax-1 do
      begin
         FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_token:=FCDdgSPMi[CPspmCnt].SPMI_token;
         FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_duration:=FCDdgFactions[CPfacLd].F_spm[CPspmCnt].SPMS_duration;
         FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_ucCost:=0;
         FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_isPolicy:=FCDdgSPMi[CPspmCnt].SPMI_isPolicy;
         if FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_isPolicy
         then
         begin
            FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_iPtIsSet:=FCDdgFactions[CPfacLd].F_spm[CPspmCnt].SPMS_iPtIsSet;
            FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_iPtAcceptanceProbability:=FCDdgFactions[CPfacLd].F_spm[CPspmCnt].SPMS_iPtAcceptanceProbability;
            if FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_iPtIsSet
            then
            begin
               CPspmI:=FCFgSPM_SPMIData_Get(FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_token);
               FCDdgEntities[CPent].E_spmMod_Cohesion:=FCDdgEntities[CPent].E_spmMod_Cohesion+CPspmI.SPMI_modCohes;
               FCDdgEntities[CPent].E_spmMod_Tension:=FCDdgEntities[CPent].E_spmMod_Tension+CPspmI.SPMI_modTens;
               FCDdgEntities[CPent].E_spmMod_Security:=FCDdgEntities[CPent].E_spmMod_Security+CPspmI.SPMI_modSec;
               FCDdgEntities[CPent].E_spmMod_Education:=FCDdgEntities[CPent].E_spmMod_Education+CPspmI.SPMI_modEdu;
               FCDdgEntities[CPent].E_spmMod_Natality:=FCDdgEntities[CPent].E_spmMod_Natality+CPspmI.SPMI_modNat;
               FCDdgEntities[CPent].E_spmMod_Health:=FCDdgEntities[CPent].E_spmMod_Health+CPspmI.SPMI_modHeal;
               FCDdgEntities[CPent].E_spmMod_Bureaucracy:=FCDdgEntities[CPent].E_spmMod_Bureaucracy+CPspmI.SPMI_modBur;
               FCDdgEntities[CPent].E_spmMod_Corruption:=FCDdgEntities[CPent].E_spmMod_Corruption+CPspmI.SPMI_modCorr;
               {:DEV NOTES: add SPMi custom effects application here.}
            end;
         end
         else if not FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_isPolicy
         then
         begin
            FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_iPfBeliefLevel:=FCDdgFactions[CPfacLd].F_spm[CPspmCnt].SPMS_iPfBeliefLevel;
            FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_iPfSpreadValue:=FCDdgFactions[CPfacLd].F_spm[CPspmCnt].SPMS_iPfSpreadValue;
            if FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_iPfBeliefLevel>=blFleeting
            then
            begin
               CPsv:=FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_iPfSpreadValue*0.01;
               CPspmI:=FCFgSPM_SPMIData_Get(FCDdgEntities[CPent].E_spmSettings[CPspmCnt].SPMS_token);
               FCDdgEntities[CPent].E_spmMod_Cohesion:=FCDdgEntities[CPent].E_spmMod_Cohesion+round(CPspmI.SPMI_modCohes*CPsv);
               FCDdgEntities[CPent].E_spmMod_Tension:=FCDdgEntities[CPent].E_spmMod_Tension+round(CPspmI.SPMI_modTens*CPsv);
               FCDdgEntities[CPent].E_spmMod_Security:=FCDdgEntities[CPent].E_spmMod_Security+round(CPspmI.SPMI_modSec*CPsv);
               FCDdgEntities[CPent].E_spmMod_Education:=FCDdgEntities[CPent].E_spmMod_Education+round(CPspmI.SPMI_modEdu*CPsv);
               FCDdgEntities[CPent].E_spmMod_Natality:=FCDdgEntities[CPent].E_spmMod_Natality+round(CPspmI.SPMI_modNat*CPsv);
               FCDdgEntities[CPent].E_spmMod_Health:=FCDdgEntities[CPent].E_spmMod_Health+round(CPspmI.SPMI_modHeal*CPsv);
               FCDdgEntities[CPent].E_spmMod_Bureaucracy:=FCDdgEntities[CPent].E_spmMod_Bureaucracy+round(CPspmI.SPMI_modBur*CPsv);
               FCDdgEntities[CPent].E_spmMod_Corruption:=FCDdgEntities[CPent].E_spmMod_Corruption+round(CPspmI.SPMI_modCorr*CPsv);
               {:DEV NOTES: add SPMi custom effects application here.}
            end;
         end;
         inc(CPspmCnt);
      end;
      FCDdgEntities[CPent].E_bureaucracy:=FCFgSPMD_Bureaucracy_Init(CPent);
      FCDdgEntities[CPent].E_corruption:=FCFgSPMD_Corruption_Init(CPent);
      if CPent=0
      then FCDdgEntities[CPent].E_hqHigherLevel:=hqsNoHQPresent
      else if CPent>0
      then FCDdgEntities[CPent].E_hqHigherLevel:=hqsPrimaryUniqueHQ;
//      setlength( FCDdgEntities[CPent].E_planetarySurveys, 1 );
      inc(CPent);
   end; //==END== while CPent<=FCCfacMax do ==//
   {.set the game user's interface}
   FCVdi3DViewToInitialize:=true;
   try
      FCWinMain.WM_MainViewGroup.Show;
      FCMoglInit_Initialize;
      FCVdi3DViewRunning:=true;
   finally
      FC3doglSelectedPlanetAsteroid:=ULoc[3];
      FCMovM_3DView_Update(
         FCVdgPlayer.P_viewStarSystem
         ,FCVdgPlayer.P_viewStar
         ,false
         ,true
         );
      if ULoc[4]>0
      then FC3doglSelectedSatellite:=FCFoglF_Satellite_SearchObject(ULoc[3], ULoc[4])
      else if (ULoc[4]=0)
         and (FC3doglMainViewTotalSatellites>0)
      then
      begin
         FC3doglSelectedSatellite:=1;
      end;
   end;
   {.cps initialization}
   FCcps:=TFCcps.Create(
      FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_cpsCreditRange
      ,FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_cpsInterestRange
      ,FCDdgFactions[SelectedFactionIndex].F_colonizationModes[SelectedColonizationModeIndex].CM_cpsViabilityObjectives
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
      setlength(FCDdgFactions[CPcount0].F_colonizationModes,1);
      setlength(FCDdgFactions[CPcount0].F_startingLocations,1);
      inc(CPcount0);
   end;
   FCMuiSP_SurfaceEcosphere_Set(0, 0, 0, 0, true);
   FCWinMain.caption:=FCWinMain.caption+'   ['+FCFdTFiles_UIStr_Get(uistrUI,'comCurGame')+FCVdgPlayer.P_gameName+']';
   FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutCPS);
end;

procedure FCMgNG_Core_Setup;
{:Purpose: setup a new game, core routine.
   Additions:
      -2012Aug21- *fix: update the windows texts each time to reflect the case of a change in the language.
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

   end;
   finally
{.DEV NOTES: it's only in the case of a new game at the start of FAR Colony, there'll be some changes and
            in the case of a new game during a current one.}
//   with FCWinNewGSetup do
//   begin

FCMuiW_UI_Initialize(mwupTextWinNGS);
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
      while FLMcnt<= Length(FCDdgFactions)-1 do
      begin
         FCWinNewGSetup.FCWNGS_Frm_FactionList.Items.Add(FCFdTFiles_UIStr_Get(uistrUI,FCDdgFactions[FLMcnt].F_token));
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
      FCWinNewGSetup.FCWNGS_Frm_DPad_SHisto_Text.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrEncyl, FCDdgFactions[SelectedFactionIndex].F_token+'.Hist'));
      FCWinNewGSetup.FCWNGS_Frm_DPad_SHisto_Text.HTMLText.Add('<br><br>');
      FCWinNewGSetup.FCWNGS_Frm_DPad_SHisto_Text.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrEncyl, FCDdgFactions[SelectedFactionIndex].F_token+'.Soc'));
      {.SPMi list}
      FCWinNewGSetup.FCWNGS_Frm_DPad_SDL_DotList.FullExpand;
      FLMmax:=Length(FCDdgFactions[SelectedFactionIndex].F_spm)-1;
      if FLMmax>0
      then
      begin
         FLMcnt:=1;
         FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.Items.Clear;
         FLMsetNode:=FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.Items.AddChild(nil, '<b>SPMi set</b>');
         FLMnsetNode:=FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.Items.AddChild(nil, '<b>SPMi not set</b>');
         while FLMcnt<=FLMmax do
         begin
            FLMspmi:=FCDdgSPMi[0];
            FLMspmi:=FCFgSPM_SPMIData_Get(FCDdgFactions[SelectedFactionIndex].F_spm[FLMcnt].SPMS_token);
            FLMspmStr:=FCFdTFiles_UIStr_Get(uistrUI, FCDdgFactions[SelectedFactionIndex].F_spm[FLMcnt].SPMS_token);
            if not FLMspmi.SPMI_isPolicy
            then FLMspmStr:=FLMspmStr+' ['+IntToStr(FCDdgFactions[SelectedFactionIndex].F_spm[FLMcnt].SPMS_iPtAcceptanceProbability)+' %]';
            if FCDdgFactions[SelectedFactionIndex].F_spm[FLMcnt].SPMS_iPtIsSet
            then FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.Items.AddChild(FLMsetNode, FLMspmStr)
            else if not FCDdgFactions[SelectedFactionIndex].F_spm[FLMcnt].SPMS_iPtIsSet
            then FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.Items.AddChild(FLMnsetNode, FLMspmStr);
            inc(FLMcnt);
         end;
         FCWinNewGSetup.FCWNGS_FDPad_ShSPM_SPMList.FullExpand;
      end;
      {.display the faction's flag}
      FCWinNewGSetup.FCWNGS_Frm_FactionFlag.Bitmap.LoadFromFile(FCVdiPathResourceDir+'pics-ui-faction\FAC_'+FCDdgFactions[SelectedFactionIndex].F_token+'_flag.jpg');
      {.set colonization modes}
      FCWinNewGSetup.FCWNGS_Frm_ColMode.Items.Clear;
      FLMmax:=length(FCDdgFactions[SelectedFactionIndex].F_colonizationModes)-1;
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
