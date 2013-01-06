{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: contains all colonize mission routines and functions

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

unit farc_missions_colonization;

interface

uses
   Math
   ,SysUtils

   ,farc_data_game;

type TFCEmcColonizationMethod=(
   cmDockingList
   ,cmSingleVessel
   );

///<summary>
///   colonize mission - post process
///</summary>
///   <param name=""></param>
///   <param name=""></param>
procedure FCMgC_Colonize_PostProc(
   const CPPfac
         ,CPPspuIdx
         ,CPPssys
         ,CPPstar
         ,CPPobjIdx
         ,CPPsatIdx
         ,CPPregion: integer;
         CPPsettleTp: TFCEdgSettlements;
         CPPname
         ,CPPsettleName: string
   );

///<summary>
///   core colonize mission setup
///</summary>
///   <param name="TFCEgcLVselTp">LV selected mode: by selector or directly in docking list</param>
///   <param name=""></param>
procedure FCMmC_Colonization_Setup(
   const Method: TFCEmcColonizationMethod;
   const SpaceUnit: integer
   );

implementation

uses
   farc_common_func
   ,farc_data_html
   ,farc_data_init
   ,farc_data_missionstasks
   ,farc_data_univ
   ,farc_data_textfiles
   ,farc_game_colony
   ,farc_game_cps
   ,farc_game_infra
   ,farc_game_infraconsys
   ,farc_missions_landing
   ,farc_missions_interplanetarytransit
   ,farc_missions_core
   ,farc_game_spmdata
   ,farc_gfx_core
   ,farc_main
   ,farc_ogl_functions
   ,farc_ui_coldatapanel
   ,farc_ui_coredatadisplay
   ,farc_ui_msges
   ,farc_ui_surfpanel
   ,farc_ui_win
   ,farc_univ_func
   ,farc_win_debug;

//===================================END OF INIT============================================

procedure FCMgC_Colonize_PostProc(
   const CPPfac
         ,CPPspuIdx
         ,CPPssys
         ,CPPstar
         ,CPPobjIdx
         ,CPPsatIdx
         ,CPPregion: integer;
         CPPsettleTp: TFCEdgSettlements;
         CPPname
         ,CPPsettleName: string
   );
{:Purpose: colonize mission - post process.
    Additions:
      -2012Jun03- *mod: the colony panel is correctly updated when a colonization mission is completed and the surface panel is displayed.
      -2011Nov17- *add: update hardcoded resource data w/ updated data structure.
      -2011Oct19- *add: update hardcoded resource data w/ Ore Field specific values.
      -2011Oct11- *add: hardcoded resource spots data.
      -2011Jul24- *rem: the procedure doesn't update the colony data panel, it's already done when required.
      -2011Feb15- *add: update the surface panel if the destination orbital object/satellite is selected.
                  *add: display the settlement icon, if one is created and the surface panel focus on the destination object.
                  *add: if the surface panel is opened and display the destination orbital object, the colony data panel display too.
      -2011Feb12- *add: complete settlement code.
      -2011Feb11- *add: implement a settlement if needed before to add any infrastructure.
      -2010Sep16- *add: entities code.
      -2010Jul02- *add: colony name if set.
      -2010Jun06- *add: show the viability objectives panel when the first colony is created.
      -2010Jun02- *add: completion mission message.
      -2010May19- *add: faction # local data.
}
var
   CPPcolIdx
   ,CPPsettlement
   ,regionttl
   ,surfaceOObj
   ,surfaceSat: integer;

begin
   CPPsettlement:=0;
   {:DEV NOTES: resource survey data, TO REMOVE WHEN REGION SURVEY IS IMPLEMENTED.}
   SetLength(FCVdgPlayer.P_surveyedResourceSpots, 2);
   {:DEV NOTES: END HARCODED SURVEY DATA.}
   if CPPsatIdx=0
   then
   begin
      CPPcolIdx:=FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_colonies[0];
      {:DEV NOTES: resource survey data, TO REMOVE WHEN REGION SURVEY IS IMPLEMENTED.}
      regionttl:=length(FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_regions);
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_orbitalObject_SatelliteToken:=FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_dbTokenId;
      {:DEV NOTES: END HARCODED SURVEY DATA.}
   end
   else if CPPsatIdx>0
   then
   begin
      CPPcolIdx:=FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_satellitesList[CPPsatIdx].OO_colonies[0];
      {:DEV NOTES: resource survey data, TO REMOVE WHEN REGION SURVEY IS IMPLEMENTED.}
      regionttl:=length(FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_satellitesList[CPPsatIdx].OO_regions);
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_orbitalObject_SatelliteToken:=FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_satellitesList[CPPsatIdx].OO_dbTokenId;
      {:DEV NOTES: END HARCODED SURVEY DATA.}
   end;
   {.establish the colony if no one exist}
   if CPPcolIdx=0
   then
   begin
      CPPcolIdx:=FCFgC_Colony_Core(
         gcaEstablished
         ,CPPfac
         ,CPPssys
         ,CPPstar
         ,CPPobjIdx
         ,CPPsatIdx
         );
      FCDdgEntities[CPPfac].E_colonies[CPPcolIdx].C_name:=CPPname;
      CPPsettlement:=FCFgC_Settlement_Add(
         CPPfac
         ,CPPcolIdx
         ,CPPregion
         ,CPPsettleTp
         ,CPPsettleName
         );
      surfaceOObj:=FCFuiSP_VarCurrentOObj_Get;
      surfaceSat:=FCFuiSP_VarCurrentSat_Get;
      if (surfaceOObj=CPPobjIdx)
         and (surfaceSat=CPPsatIdx)
         and (CPPfac=0)
      then FCMgfxC_Settlement_SwitchState(CPPregion);
      {:DEV NOTES: resource survey data, TO REMOVE WHEN REGION SURVEY IS IMPLEMENTED.}
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_starSystem:=CPPssys;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_star:=CPPstar;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_orbitalObject:=CPPobjIdx;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_satellite:=CPPsatIdx;
      setlength(FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions, regionttl);
      setlength(FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots, 2 );
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_meanQualityCoefficient:=0.7;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_spotSizeCurrent:=0;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_spotSizeMax:=50;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_type:=rstOreField;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_tOFiCarbonaceous:=25;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_tOFiMetallic:=25;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_tOFiRare:=25;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_tOFiUranium:=25;
      {:DEV NOTES: END HARCODED SURVEY DATA.}
      FCMuiM_Message_Add(
         mtColonizeWset
         ,0
         ,CPPspuIdx
         ,CPPobjIdx
         ,CPPsatIdx
         ,CPPregion
         );
      FCcps.FCM_ViabObj_Init(true);
      FCcps.CPSisEnabled:=true;
   end
   else
   begin
      CPPsettlement:=FCFgC_Settlement_GetIndexFromRegion(
         CPPfac
         ,CPPcolIdx
         ,CPPregion
         );
      if CPPsettlement=0
      then
      begin
         CPPsettlement:=FCFgC_Settlement_Add(
            CPPfac
            ,CPPcolIdx
            ,CPPregion
            ,CPPsettleTp
            ,CPPsettleName
            );
         surfaceOObj:=FCFuiSP_VarCurrentOObj_Get;
         surfaceSat:=FCFuiSP_VarCurrentSat_Get;
         if (surfaceOObj=CPPobjIdx)
            and (surfaceSat=CPPsatIdx)
            and (CPPfac=0)
         then FCMgfxC_Settlement_SwitchState(CPPregion);
      end;
      FCMuiM_Message_Add(
         mtColonize
         ,0
         ,CPPspuIdx
         ,CPPobjIdx
         ,CPPsatIdx
         ,CPPregion
         );
   end;
   {.convert the LV in a colonization shelter}
   FCMgICS_Conversion_Process(
      CPPfac
      ,CPPspuIdx
      ,CPPcolIdx
      ,CPPsettlement
      );
   FCMgSPMD_Level_Upd(CPPfac);
   surfaceOObj:=FCFuiSP_VarCurrentOObj_Get;
   surfaceSat:=FCFuiSP_VarCurrentSat_Get;
   if (FCWinMain.MVG_SurfacePanel.Visible)
      and (CPPfac=0)
      and (surfaceOObj=CPPobjIdx)
      and (surfaceSat=CPPsatIdx)
   then
   begin
      FCMuiCDD_Colony_Update(
         cdlAll
         ,CPPcolIdx
         ,CPPsettlement
         ,0
         ,false
         ,false
         ,true
         );

//      FCWinMain.FCWM_ColDPanel.Show;
//      FCMuiSP_Panel_Relocate( false );
   end;
end;

procedure FCMmC_Colonization_Setup(
   const Method: TFCEmcColonizationMethod;
   const SpaceUnit: integer
   );
{:Purpose: core colonize mission setup.
    Additions:
      -2012Oct29- *code: end of rewriting.
      -2012Oct21- *add/mod: begin of the complete rewrite of the routine.
                  *add: new parameter to indicate if the space unit is in the player's local view, or not
      -2012Oct14- *rem: the parameter CSsatObjIdx is removed.
      -2010Sep16- *add: entities code.
      -2010Apr27- *add: take in account if the trackbar is disabled/not visible.
}
//var
//   CSmax
//   ,CScnt
//   ,CSspuIdx: integer;
//
//   CSdummy
//   ,CSentVel
//   ,CSdistDecel
//   ,CSfinalVel: extended;
   var
//      SatelliteObjectIndex: integer;
      Count
      ,Max
      ,SatelliteObjectIndex: integer;

      ObjectEscapeVelocity
      ,ProcessData: extended;
begin
   Count:=0;
   Max:=0;
   SatelliteObjectIndex:=0;
   ObjectEscapeVelocity:=0;
   ProcessData:=0;
   {.player's entity is separated from AI's because the system use directly the OpenGL object, since the player obviously use the mission setup interface}
   if FCRmcCurrentMissionCalculations.CMC_entity=0 then
   begin
      if FCRmcCurrentMissionCalculations.CMC_originLocation[4]=0 then
      begin
         if FCRmcCurrentMissionCalculations.CMC_baseDistance=0
         then FCRmcCurrentMissionCalculations.CMC_baseDistance:=FCFoglF_DistanceBetweenTwoObjects_Calculate(
            ttSpaceUnit
            ,FCDdgEntities[FCRmcCurrentMissionCalculations.CMC_entity].E_spaceUnits[SpaceUnit].SU_linked3dObject
            ,ttOrbitalObject
            ,FCRmcCurrentMissionCalculations.CMC_originLocation[3]
            );
         ObjectEscapeVelocity:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]].OO_escapeVelocity;
      end
      else if FCRmcCurrentMissionCalculations.CMC_originLocation[4]>0 then
      begin
         SatelliteObjectIndex:=FCFoglF_Satellite_SearchObject( FCRmcCurrentMissionCalculations.CMC_originLocation[3], FCRmcCurrentMissionCalculations.CMC_originLocation[4] );
         if FCRmcCurrentMissionCalculations.CMC_baseDistance=0
         then FCRmcCurrentMissionCalculations.CMC_baseDistance:=FCFoglF_DistanceBetweenTwoObjects_Calculate(
            ttSpaceUnit
            ,FCDdgEntities[FCRmcCurrentMissionCalculations.CMC_entity].E_spaceUnits[SpaceUnit].SU_linked3dObject
            ,ttSatellite
            ,SatelliteObjectIndex
            );
         ObjectEscapeVelocity:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]].OO_satellitesList[FCRmcCurrentMissionCalculations.CMC_originLocation[4]].OO_escapeVelocity;
      end;
      case Method of
         cmDockingList:
         begin
            if FCRmcCurrentMissionCalculations.CMC_finalDeltaV=0 then
            begin
               ProcessData:=( ObjectEscapeVelocity*7.8 )/11.19;
               FCRmcCurrentMissionCalculations.CMC_finalDeltaV:=FCFcF_Round( rttVelocityKmSec, ProcessData );
            end;
            if not FCWinMain.FCWMS_Grp_MCG_RMassTrack.Visible
            then Max:=1
            else if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Visible
            then Max:=FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position;
            Count:=1;
            while Count<=Max do
            begin
               FCFgMl_Land_Calc(
                  FCRmcCurrentMissionCalculations.CMC_entity
                  ,FCRmcCurrentMissionCalculations.CMC_dockList[Count].DL_spaceUnitIndex
                  ,FCRmcCurrentMissionCalculations.CMC_finalDeltaV
                  );
               FCRmcCurrentMissionCalculations.CMC_dockList[Count].DL_landTime:=FCRmcCurrentMissionCalculations.CMC_landTime;
               FCRmcCurrentMissionCalculations.CMC_dockList[Count].DL_tripTime:=FCRmcCurrentMissionCalculations.CMC_tripTime;
               FCRmcCurrentMissionCalculations.CMC_dockList[Count].DL_usedReactionMass:=FCRmcCurrentMissionCalculations.CMC_usedReactionMassVol;
               inc(Count);
            end; //==END== while CScnt<=CSmax ==//
         end;

         cmSingleVessel:
         begin
            ProcessData:=( ObjectEscapeVelocity*7.8 )/11.19;
            FCRmcCurrentMissionCalculations.CMC_finalDeltaV:=FCFcF_Round( rttVelocityKmSec, ProcessData );
            FCFgMl_Land_Calc(
                  FCRmcCurrentMissionCalculations.CMC_entity
                  ,SpaceUnit
                  ,FCRmcCurrentMissionCalculations.CMC_finalDeltaV
                  );
         end;
      end;
   end //==END== if FCRmcCurrentMissionCalculations.CMC_entity=0 then ==//
   else if FCRmcCurrentMissionCalculations.CMC_entity>0 then
   begin
            {.for the AIs we never consider the AI's spacecraft is in the 3d view, even if it's the case. So the game database data (owned space unit data, FCDduStarSystem for ex.) are used for distance calculations
               instead to use 3d objects data directly. Since obviously the mission user's interface isn't used for AIs, objects positions requires to be calculated in realtime, excepted for space units that
               have always a x and z position
               }
            {:DEV NOTES: will be implemented when the AIs will.}
   end;
end;

end.
