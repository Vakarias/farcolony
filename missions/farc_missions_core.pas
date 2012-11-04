{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: space units mission - core unit

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
unit farc_missions_core;

interface

uses
   SysUtils

   ,farc_data_init
   ,farc_data_missionstasks
   ,farc_univ_func;

//==END PUBLIC ENUM=========================================================================

type TFCRmcCurrentMissionCalculations=record
   CMC_entity: integer;
   CMC_originLocation: TFCRufStelObj;
   CMC_dockList: array of record
      DL_spaceUnitIndex: integer;
      DL_landTime: integer;
      DL_tripTime: integer;
      DL_usedReactionMass: extended;
   end;
   CMC_accelerationInG: extended;
   CMC_baseDistance: extended;
   CMC_colonyAlreadyExisting: integer;
   CMC_finalDeltaV: extended;
   CMC_landTime: integer;
   CMC_regionOfDestination: integer;
   CMC_tripTime: integer;
   CMC_usedReactionMassVol: extended;

//   CMD_mission: TFCEdmtTasks;
//   GMCtimeA
//   ,GMCtimeD
//: integer;
//
//   GMCrmMaxVol,
//   GMCreqDV,
//   GMCcruiseDV,
//   GMCmaxDV: extended;
end;

type TFCDmcCurrentMission = array[0..FCCdiFactionsMax] of TFCRdmtTask;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
var
   FCDmcCurrentMission: TFCDmcCurrentMission;

   FCRmcCurrentMissionCalculations: TFCRmcCurrentMissionCalculations;
//==END PUBLIC VAR==========================================================================

{:DEV NOTE: these constants are only for prototype purposes. It's quick & dirty and must be removed when the space unit designs are completed.
   it's why these ones are let as it (not audited)
}
const
   MRMCDVCthrbyvol=0.7;
   MRMCDVCvolOfDrive=3000;
   MRMCDVCloadedMassInTons=100000;
   MRMCDVCrmMass=70;
   GMCCthrN=MRMCDVCthrbyvol*MRMCDVCvolOfDrive*(FCCdiMetersBySec_In_1G*1000);

//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   cancel the mission of a selected space unit
///</summary>
///   <param name="MCownSpUidx">owned space unit index</param>
procedure FCMgMCore_Mission_Cancel(const MCownSpUidx: integer);

///<summary>
///   commit the mission by creating a task.
///</summary>
procedure FCMgMCore_Mission_Commit;

///<summary>
///   update the destination object and distance.
///</summary>
///   <param name="MDUtripOnly">only update trip data</param>
procedure FCMgMCore_Mission_DestUpd(const MDUtripOnly: boolean);

///<summary>
///   Interplanetary transit mission setup ///erm... change that...
///</summary>
procedure FCMgMCore_Mission_Setup(
   const Entity
         ,SpaceUnit: integer;
   const MissionType: TFCEdmtTasks;
   const isMustSet3D: boolean
   );

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_game
   ,farc_data_html
   ,farc_data_spu
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_game_gameflow
   ,farc_missions_colonization
   ,farc_missions_interplanetarytransit
   ,farc_main
   ,farc_ogl_functions
   ,farc_ogl_ui
   ,farc_ogl_viewmain
   ,farc_spu_functions
   ,farc_ui_coldatapanel
   ,farc_ui_missionsetup
   ,farc_ui_surfpanel
   ,farc_ui_win
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================



//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var

//==END PRIVATE VAR=========================================================================

//const

//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgMCore_Mission_Cancel(const MCownSpUidx: integer);
{:Purpose: cancel the mission of a selected space unit.
    Additions:
      -2010Jan08- *mod: change gameflow state method according to game flow changes.
}
//var
//   MCtaskId
////   ,MCthreadId
//   : integer;
begin
//   {:DEV NOTES: a complete rewrite will be done for 0.4.0.}
////   MCtaskId:=FCRplayer.P_suOwned[MCownSpUidx].SUO_taskIdx;
////   MCthreadId:=FCGtskListInProc[MCtaskId].TITP_threadIdx;
//   try
//      FCMgTFlow_FlowState_Set(tphPAUSE);
//   finally
////      GGFthrTPU[MCthreadId].TPUphaseTp:=tpTerminated;
//      {.unload the current task to the space unit}
////      FCRplayer.P_suOwned[MCownSpUidx].SUO_taskIdx:=0;
////               {.set the remaining reaction mass}
////               FCRplayer.Play_suOwned[TPUownedIdx].SUO_availRMass
////                  :=FCRplayer.Play_suOwned[TPUownedIdx].SUO_availRMass
////                     -FCGtskListInProc[TPUtaskIdx].TITP_usedRMassV;
//      {.disable the task and delete it if it's the last in the list}
////      FCGtskListInProc[MCtaskId].T_enabled:=false;
//      if MCtaskId=length(FCDdmtTaskListInProcess)-1
//      then SetLength(FCDdmtTaskListInProcess, length(FCDdmtTaskListInProcess)-1);
//   end;
//   FCMgTFlow_FlowState_Set(tphTac);
//   FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
////   FCMoglVMain_CameraMain_Target(-1, true);
end;

procedure FCMgMCore_Mission_Commit;
{:DEV NOTES: update also FCMspuF_SpUnit_Remove regarding mission post process configuration.}
{:DEV NOTES: don't forget to update all the required data w/ the new and modified ones! synch w/ a clone of data_missiontasks.}
{:Purpose: commit the mission by creating a task.
    Additions:
      -2012Oct30- *mod: begin of routine rewrite for the colonization mission.
      -2012Oct04- *add: colonization - test if the controller is docked or not and initialize the origin data accordingly.
      -2011Feb12- *add: additional data.
      -2010Sep16- *add: entities code.
      -2010Jul02- *add: colonization mission: add colony's name if it's set.
      -2010May10- *add: time2xfert data init for interplanetary transit mission.
      -2010May05- *add: targeted region (used only for colonization mission for now).
      -2010Apr22- *mod: for colonization mission, put correctly the satellite object index, if it's the case.
      -2010Apr17- *add: commit for colonization.
                  *mod: apply one code optimization.
      -2009Dec26- *add: satellite. test if origin/destination is a sat or not.
                  *add: TITP_threadIdx initialization.
      -2009Dec01- *focus the space unit instead the orbital object.
      -2009Nov25- *add TITP_usedRMassV.
      -2009Nov22- *doesn't initialize FCRplayer.Play_suOwned[TITP_tgtIdx].SUO_taskIdx here, it's done only when the thread is created.
      -2009Oct31- *fixed a bug by a non transfered data.
}
var
   Count
   ,Entity
   ,Max
   ,TaskIndex
//   ,MCmax
//   ,MCcnt
//   ,MCtskL
   : integer;
begin
   Count:=0;
   Entity:=FCRmcCurrentMissionCalculations.CMC_entity;
   Max:=0;
   TaskIndex:=0;
   case FCDmcCurrentMission[Entity].T_type of
      tMissionColonization:
      begin
         Max:=FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position;
         if Max=0 then
         begin
            setlength( FCDdmtTaskListToProcess, length(FCDdmtTaskListToProcess)+1 );
            TaskIndex:=length(FCDdmtTaskListToProcess)-1;
            FCDdmtTaskListToProcess[TaskIndex].T_entity:=FCRmcCurrentMissionCalculations.CMC_entity;
            FCDdmtTaskListToProcess[TaskIndex].T_inProcessData.IPD_isTaskDone:=false;
            FCDdmtTaskListToProcess[TaskIndex].T_inProcessData.IPD_isTaskTerminated:=false;
            FCDdmtTaskListToProcess[TaskIndex].T_inProcessData.IPD_ticksAtTaskStart:=0;
            FCDdmtTaskListToProcess[TaskIndex].T_controllerIndex:=FCDmcCurrentMission[Entity].T_controllerIndex;
            FCDdmtTaskListToProcess[TaskIndex].T_duration:=FCRmcCurrentMissionCalculations.CMC_tripTime;
            FCDdmtTaskListToProcess[TaskIndex].T_durationInterval:=1;
            FCDdmtTaskListToProcess[TaskIndex].T_previousProcessTime:=0;
            FCDdmtTaskListToProcess[TaskIndex].T_type:=tMissionColonization;
            FCDdmtTaskListToProcess[TaskIndex].T_tMCphase:=mcpDeceleration;
            FCDdmtTaskListToProcess[TaskIndex].T_tMCorigin:=FCDmcCurrentMission[Entity].T_tMCorigin;
            FCDdmtTaskListToProcess[TaskIndex].T_tMCoriginIndex:=FCDmcCurrentMission[Entity].T_tMCoriginIndex;
            {.update the space unit data}
            FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListToProcess[TaskIndex].T_controllerIndex].SU_locationOrbitalObject:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]].OO_dbTokenId;
            if FCRmcCurrentMissionCalculations.CMC_originLocation[4]=0 then
            begin
               FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListToProcess[TaskIndex].T_controllerIndex].SU_locationSatellite:='';
               FCDdmtTaskListToProcess[TaskIndex].T_tMCdestination:=ttOrbitalObject;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCdestinationIndex:=FCRmcCurrentMissionCalculations.CMC_originLocation[3];
            end
            else if FCRmcCurrentMissionCalculations.CMC_originLocation[4]>0 then
            begin
               FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListToProcess[TaskIndex].T_controllerIndex].SU_locationSatellite:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]].OO_satellitesList[FCRmcCurrentMissionCalculations.CMC_originLocation[4]].OO_dbTokenId;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCdestination:=ttSatellite;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCdestinationIndex:=FCRmcCurrentMissionCalculations.CMC_originLocation[4];
            end;
            FCDdmtTaskListToProcess[TaskIndex].T_tMCdestinationRegion:=FCRmcCurrentMissionCalculations.CMC_regionOfDestination;
            if FCWinMain.FCWMS_Grp_MCGColName.Text<>FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcolNameNo')
            then FCDdmtTaskListToProcess[TaskIndex].T_tMCcolonyName:=FCWinMain.FCWMS_Grp_MCGColName.Text
            else FCDdmtTaskListToProcess[TaskIndex].T_tMCcolonyName:='';
            if FCWinMain.FCWMS_Grp_MCG_SetName.Visible then
            begin
               FCDdmtTaskListToProcess[TaskIndex].T_tMCsettlementName:=FCWinMain.FCWMS_Grp_MCG_SetName.Text;
               {:DEV NOTES: change that for the real settlement type.}
               FCDdmtTaskListToProcess[TaskIndex].T_tMCsettlementType:=sSurface;//FCWinMain.FCWMS_Grp_MCG_SetType.ItemIndex;
            end
            else begin
               FCDdmtTaskListToProcess[TaskIndex].T_tMCsettlementName:='';
               {:DEV NOTES: change that for the real settlement type.}
               FCDdmtTaskListToProcess[TaskIndex].T_tMCsettlementType:=sSurface;
            end;
            FCDdmtTaskListToProcess[TaskIndex].T_tMCfinalVelocity:=FCRmcCurrentMissionCalculations.CMC_finalDeltaV;
            FCDdmtTaskListToProcess[TaskIndex].T_tMCfinalTime:=FCRmcCurrentMissionCalculations.CMC_landTime;
            FCDdmtTaskListToProcess[TaskIndex].T_tMCusedReactionMassVol:=FCRmcCurrentMissionCalculations.CMC_usedReactionMassVol;
            FCDdmtTaskListToProcess[TaskIndex].T_tMCinProcessData.IPD_accelerationByTick:=0;
            FCDdmtTaskListToProcess[TaskIndex].T_tMCinProcessData.IPD_timeForDeceleration:=0;
         end //==END== if Max=0 then ==//
         else if Max>0 then
         begin
            Count:=1;
            while Count<=Max do
            begin
               setlength( FCDdmtTaskListToProcess, length(FCDdmtTaskListToProcess)+1 );
               TaskIndex:=length(FCDdmtTaskListToProcess)-1;
               FCDdmtTaskListToProcess[TaskIndex].T_entity:=FCRmcCurrentMissionCalculations.CMC_entity;
               FCDdmtTaskListToProcess[TaskIndex].T_inProcessData.IPD_isTaskDone:=false;
               FCDdmtTaskListToProcess[TaskIndex].T_inProcessData.IPD_isTaskTerminated:=false;
               FCDdmtTaskListToProcess[TaskIndex].T_inProcessData.IPD_ticksAtTaskStart:=0;
               FCDdmtTaskListToProcess[TaskIndex].T_controllerIndex:=FCRmcCurrentMissionCalculations.CMC_dockList[Count].DL_spaceUnitIndex;
               FCDdmtTaskListToProcess[TaskIndex].T_duration:=FCRmcCurrentMissionCalculations.CMC_dockList[Count].DL_tripTime;
               FCDdmtTaskListToProcess[TaskIndex].T_durationInterval:=1;
               FCDdmtTaskListToProcess[TaskIndex].T_previousProcessTime:=0;
               FCDdmtTaskListToProcess[TaskIndex].T_type:=tMissionColonization;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCphase:=mcpDeceleration;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCorigin:=FCDmcCurrentMission[Entity].T_tMCorigin;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCoriginIndex:=FCDmcCurrentMission[Entity].T_tMCoriginIndex;
               {.update the docked space unit data + destination}
               FCDdgEntities[Entity].E_spaceUnits[FCRmcCurrentMissionCalculations.CMC_dockList[Count].DL_spaceUnitIndex].SU_locationOrbitalObject:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]].OO_dbTokenId;
               if FCRmcCurrentMissionCalculations.CMC_originLocation[4]=0 then
               begin
                  FCDdgEntities[Entity].E_spaceUnits[FCRmcCurrentMissionCalculations.CMC_dockList[Count].DL_spaceUnitIndex].SU_locationSatellite:='';
                  FCDdmtTaskListToProcess[TaskIndex].T_tMCdestination:=ttOrbitalObject;
                  FCDdmtTaskListToProcess[TaskIndex].T_tMCdestinationIndex:=FCRmcCurrentMissionCalculations.CMC_originLocation[3];
               end
               else if FCRmcCurrentMissionCalculations.CMC_originLocation[4]>0 then
               begin
                  FCDdgEntities[Entity].E_spaceUnits[FCRmcCurrentMissionCalculations.CMC_dockList[Count].DL_spaceUnitIndex].SU_locationSatellite:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]].OO_satellitesList[FCRmcCurrentMissionCalculations.CMC_originLocation[4]].OO_dbTokenId;
                  FCDdmtTaskListToProcess[TaskIndex].T_tMCdestination:=ttSatellite;
                  FCDdmtTaskListToProcess[TaskIndex].T_tMCdestinationIndex:=FCRmcCurrentMissionCalculations.CMC_originLocation[4];
               end;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCdestinationRegion:=FCRmcCurrentMissionCalculations.CMC_regionOfDestination;
               if FCWinMain.FCWMS_Grp_MCGColName.Text<>FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcolNameNo')
               then FCDdmtTaskListToProcess[TaskIndex].T_tMCcolonyName:=FCWinMain.FCWMS_Grp_MCGColName.Text
               else FCDdmtTaskListToProcess[TaskIndex].T_tMCcolonyName:='';
               if FCWinMain.FCWMS_Grp_MCG_SetName.Visible then
               begin
                  FCDdmtTaskListToProcess[TaskIndex].T_tMCsettlementName:=FCWinMain.FCWMS_Grp_MCG_SetName.Text;
                  {:DEV NOTES: change that for the real settlement type.}
                  FCDdmtTaskListToProcess[TaskIndex].T_tMCsettlementType:=sSurface;//FCWinMain.FCWMS_Grp_MCG_SetType.ItemIndex;
               end
               else begin
                  FCDdmtTaskListToProcess[TaskIndex].T_tMCsettlementName:='';
                  {:DEV NOTES: change that for the real settlement type.}
                  FCDdmtTaskListToProcess[TaskIndex].T_tMCsettlementType:=sSurface;
               end;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCfinalVelocity:=FCRmcCurrentMissionCalculations.CMC_finalDeltaV;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCfinalTime:=FCRmcCurrentMissionCalculations.CMC_dockList[Count].DL_landTime;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCusedReactionMassVol:=FCRmcCurrentMissionCalculations.CMC_dockList[Count].DL_usedReactionMass;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCinProcessData.IPD_accelerationByTick:=0;
               FCDdmtTaskListToProcess[TaskIndex].T_tMCinProcessData.IPD_timeForDeceleration:=0;
               FCMspuF_DockedSpU_Rem(
                  Entity
                  ,FCDdmtTaskListToProcess[TaskIndex].T_tMCoriginIndex
                  ,FCDdmtTaskListToProcess[TaskIndex].T_controllerIndex
                  );
               inc( Count );
            end;
         end; //==END== else if Max>0 then ==//
         if Entity=0 then
         begin
            FCMuiMS_Planel_Close;
            if ( Max>0 )
               and (  FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListToProcess[TaskIndex].T_tMCoriginIndex].SU_linked3dObject] ) then
            begin
               FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
               FCMuiW_FocusPopup_Upd(uiwpkSpUnit);
            end;
         end;
      end; //==END== case: tMissionColonization ==//

      tMissionInterplanetaryTransit:
      begin
//         setlength(FCDdmtTaskListToProcess, length(FCDdmtTaskListToProcess)+1);
//         MCtskL:=length(FCDdmtTaskListToProcess)-1;
//         FCDdmtTaskListToProcess[MCtskL].T_type:=tMissionInterplanetaryTransit;
////         FCGtskLstToProc[MCtskL].TITP_ctldType:=ttSpaceUnit;
//         FCDdmtTaskListToProcess[MCtskL].T_entity:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Tag;
//         FCDdmtTaskListToProcess[MCtskL].T_controllerIndex:=round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat);
//         FCDdmtTaskListToProcess[MCtskL].T_duration:=round(GMCtripTime);
//         FCDdmtTaskListToProcess[MCtskL].T_durationInterval:=1;
//         if GMCrootSatIdx=0
//         then
//         begin
//            FCDdmtTaskListToProcess[MCtskL].T_tMITorigin:=ttOrbitalObject;
//            FCDdmtTaskListToProcess[MCtskL].T_tMIToriginIndex:=GMCrootOObIdx;
//         end
//         else if GMCrootSatIdx>0
//         then
//         begin
//            FCDdmtTaskListToProcess[MCtskL].T_tMITorigin:=ttSatellite;
//            FCDdmtTaskListToProcess[MCtskL].T_tMIToriginIndex:=GMCrootSatObjIdx;
//         end;
//         if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid]
//         then
//         begin
//            FCDdmtTaskListToProcess[MCtskL].T_tMITdestination:=ttOrbitalObject;
//            FCDdmtTaskListToProcess[MCtskL].T_tMITdestinationIndex:=FC3doglSelectedPlanetAsteroid;
//         end
//         else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite]
//         then
//         begin
//            FCDdmtTaskListToProcess[MCtskL].T_tMITdestination:=ttSatellite;
//            FCDdmtTaskListToProcess[MCtskL].T_tMITdestinationIndex:=FC3doglSelectedSatellite;
//         end;
//         FCDdmtTaskListToProcess[MCtskL].T_tMITcruiseVelocity:=GMCcruiseDV;
//         FCDdmtTaskListToProcess[MCtskL].T_tMITcruiseTime:=GMCtimeA;
//         FCDdmtTaskListToProcess[MCtskL].T_tMITinProcessData.IPD_timeToTransfert:=0;
//         FCDdmtTaskListToProcess[MCtskL].T_tMITfinalVelocity:=GMCfinalDV;
//         FCDdmtTaskListToProcess[MCtskL].T_tMITfinalTime:=GMCtimeD;
//         FCDdmtTaskListToProcess[MCtskL].T_tMITusedReactionMassVol:=GMCusedRMvol;
//         FCWinMain.FCWM_MissionSettings.Hide;
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position:=1;
//         if GMCrootSatIdx=0
//         then FC3doglSelectedPlanetAsteroid:=GMCrootOObIdx
//         else if GMCrootSatIdx>0
//         then
//         begin
//            FC3doglSelectedSatellite:=GMCrootSatObjIdx;
//            FC3doglSelectedPlanetAsteroid:=round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat);
//         end;
//         FCMoglVM_CamMain_Target(-1, false);
      end; //==END== case: gmcmnItransit ==//
   end; //==END== case GMCmissTp of ==//
   FCVdiGameFlowTimer.Enabled:=true;
end;

procedure FCMgMCore_Mission_ConfData;
{:Purpose: update the mission configuration data. It's a method for avoid to have to
            duplicate the code in FCMgMCore_Mission_DestUpd.
    Additions:
}
begin
//   {.mission configuration data}
//   FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Insert
//   (
//      1
//      ,  FCFdTFiles_UIStr_Get(uistrUI,'MCGDatAccel')+' '+FloatToStr(GMCAccelG)
//            +' g <br>'
//            +FCFdTFiles_UIStr_Get(uistrUI,'MCGDatCruiseDV')+' '+FloatToStr(GMCcruiseDV)
//            +' km/s <br>'
//            +FCFdTFiles_UIStr_Get(uistrUI,'MCGDatFinalDV')+' '+FloatToStr(GMCfinalDV)
//            +' km/s <br>'
//            +FCFdTFiles_UIStr_Get(uistrUI,'MCGDatUsdRM')+' '
//               +IntToStr
//                  (
//                     round
//                        (
//                           GMCusedRMvol*100
//                           /FCDdgEntities[GMCfac].E_spaceUnits[round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat)].SU_reactionMass
//                        )
//                  )
//            +' %<br>'
//            +FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI,'MCGDatTripTime')+FCCFdHeadEnd
//            +FCFcFunc_TimeTick_GetDate(GMCtripTime)
//   );
//   FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Delete(2);
end;

procedure FCMgMCore_Mission_DestUpd(const MDUtripOnly: boolean);
{DEV NOTE: add switch for calc/disp only trip data.}
{:Purpose: update the destination object and distance.
    Additions:
      -2010Sep16- *add: entities code.
      -2009Dec26- *complete satellite data display.
      -2009Dec25- *add: satellite data display.
      -2009Oct24- *link calculations to FCMgMTrans_MissionCore_Calc.
                  *link to FCMgMTrans_MissionTrip_Calc.
                  *update mission configuration data.
      -2009Oct17- *add distance update.
      -2009Oct14- *add orbital object destination name.
}
//var
//   MDUdmpSatIdx
//   ,MDUdmpPlanSatIdx: integer;
//   MDUdmpTokenName: string;
begin
//   {.calculate all necessary data}
//   if not MDUtripOnly
//   then
//   begin
//      FCMgMiT_ITransit_Setup;
//      FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=true;
//      FCWinMain.FCWMS_ButProceed.Enabled:=true;
//      FCWinMain.FCWMS_Grp_MCG_RMassTrack.Max:=3;
//   end;
//   {.calculate all trip data}
//   if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled
//   then
//   begin
//      FCMgMiT_MissionTrip_Calc
//         (
//            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position
//            ,FCDdgEntities[GMCfac].E_spaceUnits[round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat)].SU_deltaV
//         );
//   end;
//   {.current destination for orbital object}
//   if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid]
//   then
//   begin
//      if (FC3doglSelectedPlanetAsteroid=GMCrootOObIdx)
//         or (not FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled)
//      then
//      begin
//         FCWinMain.FCWMS_ButProceed.Enabled:=false;
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
//         {.current destination}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert(7, FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone')+'<br>');
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(8);
//         {.distance + min deltaV}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert
//         (
//            9
//            ,FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntCdist')
//               +' 0 '
//               +FCFdTFiles_UIStr_Get(uistrUI,'acronAU')
//               +'<ind x="'+IntToStr(FCWinMain.FCWMS_Grp_MSDG_Disp.Width shr 1)+'">'
//               +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdestIntCminDV')
//               +' 0 km/s'
//         );
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(10);
//         {.mission configuration data}
//         if (not FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled)
//            and (FC3doglSelectedPlanetAsteroid<>GMCrootOObIdx)
//         then FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Insert(1, FCFdTFiles_UIStr_Get(uistrUI,'MCGDatNA'))
//         else FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Insert(1, FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone'));
//         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Delete(2);
//      end //==END== if FCV3DoObjSlctd=CFVoobjIdDB or (not FCWMS_Grp_MCG_RMassTrack.Enabled) ==//
//      else if FC3doglSelectedPlanetAsteroid<>GMCrootOObIdx
//      then
//      begin
//         if not MDUtripOnly
//         then
//         begin
//            {.current destination}
//            MDUdmpTokenName:=FCFdTFiles_UIStr_Get(
//               dtfscPrprName
//               ,FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_dbTokenId
//               );
//            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert(7, MDUdmpTokenName+'<br>');
//            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(8);
//            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert
//            (
//               9
//               ,FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntCdist')+' '
//                  +FloatToStr(GMCbaseDist)+' '
//                  +FCFdTFiles_UIStr_Get(uistrUI,'acronAU')
//                  +'<ind x="'+IntToStr(FCWinMain.FCWMS_Grp_MSDG_Disp.Width shr 1)+'">'
//                  +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdestIntCminDV')
//                  +' '+FloatToStr(GMCreqDV)+' km/s'
//            );
//            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(10);
//         end; //==END== if not MDUtripOnly ==//
//         FCMgMCore_Mission_ConfData;
//      end; {.else if FCV3dMVorbObjSlctd<>CFVoobjIdDB}
//   end //==END== if FCGLSCamMainViewGhost.TargetObject=FC3DobjGrp[FCV3DoObjSlctd] ==//
//   {.current destination for satellite}
//   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite]
//   then
//   begin
//      if (GMCrootSatIdx>0)
//         and ((FC3doglSelectedSatellite=GMCrootSatObjIdx) or (not FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled))
//      then
//      begin
//         FCWinMain.FCWMS_ButProceed.Enabled:=false;
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
//         {.current destination}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert(7, FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone')+'<br>');
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(8);
//         {.distance + min deltaV}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert
//         (
//            9
//            ,FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntCdist')
//               +' 0 '
//               +FCFdTFiles_UIStr_Get(uistrUI,'acronAU')
//               +'<ind x="'+IntToStr(FCWinMain.FCWMS_Grp_MSDG_Disp.Width shr 1)+'">'
//               +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdestIntCminDV')
//               +' 0 km/s'
//         );
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(10);
//         {.mission configuration data}
//         if (not FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled)
//            and (FC3doglSelectedSatellite<>GMCrootSatObjIdx)
//         then FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Insert(1, FCFdTFiles_UIStr_Get(uistrUI,'MCGDatNA'))
//         else FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Insert
//            (1, FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone'));
//         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Delete(2);
//      end
//      else if ((GMCrootSatIdx>0) and (FC3doglSelectedSatellite<>GMCrootSatObjIdx))
//         or (GMCrootSatObjIdx=0)
//      then
//      begin
//         {.get satellite data}
//         MDUdmpSatIdx:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag;
//         MDUdmpPlanSatIdx:=round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat);
//         if not MDUtripOnly
//         then
//         begin
//            {.current destination}
//            MDUdmpTokenName:=FCFdTFiles_UIStr_Get(
//               dtfscPrprName
//               ,FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[MDUdmpPlanSatIdx].OO_satellitesList[MDUdmpSatIdx].OO_dbTokenId
//               );
//            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert(7, MDUdmpTokenName+'<br>');
//            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(8);
//            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert(
//               9
//               ,FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntCdist')+' '
//                  +FloatToStr(GMCbaseDist)+' '
//                  +FCFdTFiles_UIStr_Get(uistrUI,'acronAU')
//                  +'<ind x="'+IntToStr(FCWinMain.FCWMS_Grp_MSDG_Disp.Width shr 1)+'">'
//                  +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdestIntCminDV')
//                  +' '+FloatToStr(GMCreqDV)+' km/s'
//               );
//            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(10);
//         end; //==END== if not MDUtripOnly ==//
//         FCMgMCore_Mission_ConfData;
//      end;
//   end; //==END== else FCGLSCamMainViewGhost.TargetObject=FC3DobjSatGrp[FCV3DsatSlctd] ==//
end;

procedure FCMgMCore_Mission_Setup(
   const Entity
         ,SpaceUnit: integer;
   const MissionType: TFCEdmtTasks;
   const isMustSet3D: boolean
   );
{:Purpose: Interplanetary transit mission setup.
    Additions:
      -2012Oct14- *add: a new parameter to indicate if the 3d view must be set up before. True is used in the case when the mission is triggered by the UMI, in future implementation.
      -2012Oct09- *code: start of the complete rewrite of the procedure logic, including the last required updates concerning the user's interface.
                  *add: a new parameter indicate the concerned space unit. It's now required because it can come from multiple sources (3d view and UMI).
                  *code: audit: start
                     (o)var formatting + refactoring     (-)if..then reformatting   (-)function/procedure refactoring
                     (o)parameters refactoring           (-) ()reformatting         (-)code optimizations
                     (-)float local variables=> extended (-)case..of reformatting   (-)local methods
                     (-)summary completion               (-)protect all float add/sub w/ FCFcFunc_Rnd
                     (o)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (-)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (-)use of enumindex                 (-)use of StrToFloat( x, FCVdiFormat ) for all float data w/ XML
                     (-)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
      -2012Jun03- *add: close the colony data panel.
      -2011Feb12- *add: settlements initialization.
                  *mod: adjust location of colonization mission interface elements.
                  *mod: for the interplanetary transit mission, fix the trackbar label to correctly display the part of used reaction mass.
      -2010Sep16- *add: a faction # parameter.
                  *entities code.
      -2010Sep02- *add: use a local variable for the design #.
      -2010Jul02- *add: FCWMS_Grp_MCGColName init.
                  *fix: correct a window display freeze.
      -2010Jun15- *mod: use the new space locator.
      -2010May12- *fix: for colonization mission, get the mother vessel location (forgot to add FCMcFunc_Universe_GetDB.
						*fix: for colonization mission, correctly store the GMCmissTp.
      -2010Apr27- *fix: crash remove w/ trackbar setting for colonization mission.
      -2010Apr05- *add: begin colonization mission.
      -2009Dec21- *add: begin implementation of satellite for departure/arrival.
      -2009Dec18- *add: get satellite data for departure.
      -2009Oct25- *add FCWinMissSet.FCWMS_ButProceed configuration.
      -2009Oct24- *add spacedrive type (at least the header) and isp.
      -2009Oct19- *add mission configuration data.
      -2009Oct18- *add mission configuration components.
      -2009Oct14- *complete destination intercept course values.
      -2009Oct13- *localize current deltaV + reaction mass.
                  *add current destination initial value.
                  *add destination intercept course initial value.
      -2009Oct12- *mission status completion.
                  *add current deltaV + reaction mass.
      -2009Oct11- *focus the 3d view on the space unit's orbital object.
                  *add mission status.
      -2009Oct08- *change message box behavior.
}
//var
//   MScol
//   ,MSdesgn
//   ,surfaceOObj: integer;
//
//   MSdmpStatus: string;
//
   var
      Count
      ,Count1
//      ,Count2
//      ,Count3
      ,Max: integer;

      DockListIndexes: TFCRspufIndexes;
begin
   {.pre initialization for all the missions}
   {:DEV NOTES: for the 0.5.5, change the line below to a decelerated time.}
   FCVdiGameFlowTimer.Enabled:=false;
   {:DEV NOTES: end change.}
   {:DEV NOTES: expand this part only when the space units tab will be implemented.}
//   if isMustSet3D then
//    0/ store the current player's location (will be restored after the mission setup)
//   1/ trigger the right star system
//   2/ focus the right space unit 3d object
   {:DEV NOTES: end change.}
   FCMuiMS_Panel_Initialize;
   Count:=0;
   Count1:=0;
   Max:=0;
   SetLength( DockListIndexes, 1 );
   FCRmcCurrentMissionCalculations.CMC_entity:=Entity;
   FCRmcCurrentMissionCalculations.CMC_originLocation:=FCFuF_StelObj_GetFullRow(
      FCDdgEntities[Entity].E_spaceUnits[spaceUnit].SU_locationStarSystem
      ,FCDdgEntities[Entity].E_spaceUnits[spaceUnit].SU_locationStar
      ,FCDdgEntities[Entity].E_spaceUnits[spaceUnit].SU_locationOrbitalObject
      ,FCDdgEntities[Entity].E_spaceUnits[spaceUnit].SU_locationSatellite
      );
   SetLength( FCRmcCurrentMissionCalculations.CMC_dockList, 0 );
   FCRmcCurrentMissionCalculations.CMC_accelerationInG:=0;
   FCRmcCurrentMissionCalculations.CMC_baseDistance:=0;
   FCRmcCurrentMissionCalculations.CMC_colonyAlreadyExisting:=0;
   FCRmcCurrentMissionCalculations.CMC_finalDeltaV:=0;
   FCRmcCurrentMissionCalculations.CMC_landTime:=0;
   FCRmcCurrentMissionCalculations.CMC_regionOfDestination:=0;
   FCRmcCurrentMissionCalculations.CMC_tripTime:=0;
   FCRmcCurrentMissionCalculations.CMC_usedReactionMassVol:=0;
   FCDmcCurrentMission[Entity].T_controllerIndex:=0;
   FCDmcCurrentMission[Entity].T_duration:=0;
   FCDmcCurrentMission[Entity].T_durationInterval:=0;
   FCDmcCurrentMission[Entity].T_previousProcessTime:=0;
   FCDmcCurrentMission[Entity].T_type:=MissionType;
   case FCDmcCurrentMission[Entity].T_type of
      tMissionColonization:
      begin
         FCDmcCurrentMission[Entity].T_tMCorigin:=ttSelf;
         FCDmcCurrentMission[Entity].T_tMCoriginIndex:=0;
         FCDmcCurrentMission[Entity].T_tMCdestination:=ttSelf;
         FCDmcCurrentMission[Entity].T_tMCdestinationIndex:=0;
         FCDmcCurrentMission[Entity].T_tMCdestinationRegion:=0;
         FCDmcCurrentMission[Entity].T_tMCcolonyName:='';
         FCDmcCurrentMission[Entity].T_tMCsettlementName:='';
         FCDmcCurrentMission[Entity].T_tMCsettlementType:=sSurface;
         FCDmcCurrentMission[Entity].T_tMCfinalVelocity:=0;
         FCDmcCurrentMission[Entity].T_tMCfinalTime:=0;
         FCDmcCurrentMission[Entity].T_tMCusedReactionMassVol:=0;
         if FCRmcCurrentMissionCalculations.CMC_originLocation[4]=0
         then FCMuiMS_CurrentColony_Load(
            FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]]
               .OO_colonies[0]
            )
         else FCMuiMS_CurrentColony_Load(
            FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]]
               .OO_satellitesList[FCRmcCurrentMissionCalculations.CMC_originLocation[4]].OO_colonies[Entity]
            );
         {.# of docked space units}
         Count:=0;
         DockListIndexes:=FCFspuF_DockedSpU_GetIndexList(
            Entity
            ,SpaceUnit
            ,aNone
            ,sufcColoniz
            );
         Count:=length( DockListIndexes )-1;
         if Count=0 then
         begin
            FCDmcCurrentMission[Entity].T_controllerIndex:=SpaceUnit;
            FCMmC_Colonization_Setup(
               cmSingleVessel
               ,SpaceUnit
               );
         end
         else if Count>0 then
         begin
            FCDmcCurrentMission[Entity].T_tMCorigin:=ttSpaceUnitDockedIn;
            FCDmcCurrentMission[Entity].T_tMCoriginIndex:=SpaceUnit;
            SetLength( FCRmcCurrentMissionCalculations.CMC_dockList, Count+1 );
            {.docklist index}
            Count1:=1;
            while Count1<=Count do
            begin
               FCRmcCurrentMissionCalculations.CMC_dockList[Count1].DL_spaceUnitIndex:=DockListIndexes[Count1];
               FCRmcCurrentMissionCalculations.CMC_dockList[Count1].DL_landTime:=0;
               FCRmcCurrentMissionCalculations.CMC_dockList[Count1].DL_tripTime:=0;
               FCRmcCurrentMissionCalculations.CMC_dockList[Count1].DL_usedReactionMass:=0;
               inc( Count1 );
            end;
            FCMmC_Colonization_Setup(
               cmDockingList
               ,SpaceUnit
               );
         end;

         if Entity=0
         then FCMuiMS_ColonizationInterface_Setup;
//         else AI-Colonization Determination(Entity);
      end; //==END== case: tMissionColonization ==//

      tMissionInterplanetaryTransit:
      begin
         FCDmcCurrentMission[Entity].T_tMITorigin:=ttSelf;
         FCDmcCurrentMission[Entity].T_tMIToriginIndex:=0;
         FCDmcCurrentMission[Entity].T_tMITdestination:=ttSelf;
         FCDmcCurrentMission[Entity].T_tMITdestinationIndex:=0;
         FCDmcCurrentMission[Entity].T_tMITcruiseVelocity:=0;
         FCDmcCurrentMission[Entity].T_tMITcruiseTime:=0;
         FCDmcCurrentMission[Entity].T_tMITfinalVelocity:=0;
         FCDmcCurrentMission[Entity].T_tMITfinalTime:=0;
         FCDmcCurrentMission[Entity].T_tMITusedReactionMassVol:=0;
      end;
   end; //==END== case FCDmcCurrentMission[Entity].T_type of ==//
   FCWinMain.FCWM_MissionSettings.Show;
   FCWinMain.FCWM_MissionSettings.BringToFront;


//=================================old code

//   GMCAccelG:=0;
//   GMCcruiseDV:=0;
//   GMCfac:=Entity;
//   GMCfinalDV:=0;
//   GMClandTime:=0;
//   GMCmaxDV:=0;
//   GMCreqDV:=0;
//   GMCrmMaxVol:=0;
//   GMCtimeA:=0;
//   GMCtimeD:=0;
//   GMCtripTime:=0;
//   GMCusedRMvol:=0;

//   {.universal data initialization for all missions}

//      end; //==END== case: gmcmnColoniz ==//



//      tMissionInterplanetaryTransit:
//      begin
//         {.initialize mission data}
//         MSdmpStatus:=FCFspuF_AttStatus_Get(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Tag, MSownedIdx);
//         GMCrootSsys:=FCFuF_StelObj_GetDbIdx(
//            ufsoSsys
//            ,FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_locationStarSystem
//            ,0
//            ,0
//            ,0
//            );
//         GMCrootStar:=FCFuF_StelObj_GetDbIdx(
//            ufsoStar
//            ,FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_locationStar
//            ,GMCrootSsys
//            ,0
//            ,0
//            );
//         GMCrootOObIdx:=FCFuF_StelObj_GetDbIdx(
//            ufsoOObj
//            ,FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_locationOrbitalObject
//            ,GMCrootSsys
//            ,GMCrootStar
//            ,0
//            );
//         if FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_locationSatellite<>''
//         then GMCrootSatIdx:=FCFuF_StelObj_GetDbIdx(
//            ufsoSat
//            ,FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_locationSatellite
//            ,GMCrootSsys
//            ,GMCrootStar
//            ,GMCrootOObIdx
//            )
//         else GMCrootSatIdx:=0;
//         {DEV NOTE: for futur expansion, add the case of a mission assignated on a space unit
//         that is not in the current local star system. The only case where it will happens it's
//         when a mission is assignated by the faction's properties window.
//         For data update, take over this faction's properties window data, test if this win is
//         displayed or not}
//         {DEV NOTE: the case which follow is just concerning the current system and only the
//         player's faction.}
//         FC3doglSelectedPlanetAsteroid:=GMCrootOObIdx;
//         if GMCrootSatIdx>0
//         then
//         begin
//            GMCrootSatObjIdx:=FCFoglVM_SatObj_Search(GMCrootOObIdx, GMCrootSatIdx);
//            FC3doglSelectedSatellite:=GMCrootSatObjIdx;
//            FCMoglVM_CamMain_Target(100, false);
//         end
//         else if GMCrootSatIdx=0
//         then FCMoglVM_CamMain_Target(FC3doglSelectedPlanetAsteroid, false);
//         {.set user's interface}
//         FCWinMain.FCWM_MissionSettings.Caption.Text:=FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet')+FCFdTFiles_UIStr_Get(uistrUI,'Mission.itransit');
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Visible:=true;
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
//         {.mission data display}
//         {.idx=0}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
//            FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI,'MSDGspUnIdStat')+FCCFdHeadEnd
//            );
//         {.idx=1}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
//            FCFdTFiles_UIStr_Get(dtfscPrprName, FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_name)
//            +' '
//            +FCFdTFiles_UIStr_Get(dtfscSCarchShort, FCDdsuSpaceUnitDesigns[MSdesgn].SUD_internalStructureClone.IS_architecture)
//            +' '+MSdmpStatus
//            +'<br>'
//            );
//         {.current deltaV + reaction mass, idx=2}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
//            FCCFdHead
//            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDV')
//            +MSdispIdx
//            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGremRMass')
//            +FCCFdHeadEnd
//            );
//         {.idx=3}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
//            FloatToStr(FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_deltaV)+' km/s'
//            +MSdispIdx
//            +FloatToStr(FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_reactionMass)+' m<sup>3</sup>'
//            +'<br>'
//            );
//         {.space drive type and isp, idx=4}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
//            FCCFdHead
//            +FCFdTFiles_UIStr_Get(uistrUI,'spUnDrvTp')
//            +MSdispIdx
//            +FCFdTFiles_UIStr_Get(uistrUI,'spUnISPfull')
//            +FCCFdHeadEnd
//            );
//         {.idx=5}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
//            '(data not implemented yet)'
//            +MSdispIdx
//            +IntToStr(FCDdsuSpaceUnitDesigns[MSdesgn].SUD_spaceDriveISP)+' sec'
//            +'<br>'
//            );
//         {.current destination idx=6}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
//            FCCFdHead
//            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDest')
//            +FCCFdHeadEnd
//            );
//         {.idx= 7}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone')+'<br>');
//         {.destination intercept course, idx=8}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
//            FCCFdHead
//            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntC')
//            +FCCFdHeadEnd
//            );
//         {.idx=9}
//         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
//            FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntCdist')
//            +' 0 '
//            +FCFdTFiles_UIStr_Get(uistrUI,'acronAU')
//            +MSdispIdx
//            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdestIntCminDV')
//            +' 0 km/s'
//            );
//         {.mission configuration proceed button}
//         FCWinMain.FCWMS_ButProceed.Enabled:=false;
//         {.mission configuration trackbar}
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag:=1;
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Left:=24;
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Top:=32;
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Max:=3;
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Min:=1;
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position:=1;
//         FCMgMCore_Mission_TrackUpd( tMissionInterplanetaryTransit );
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
//         {.initialize the 2 mission configuration panels}

//         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Clear;
//         {.mission configuration background panel}
//         FCWinMain.FCWMS_Grp_MCG_DatDisp.HTMLText.Add(
//            FCCFdHead
//            +FCFdTFiles_UIStr_Get(uistrUI,'MCGtransSpd')
//            +FCCFdHeadEnd
//            );
//         {.mission configuration data}
//         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Add(
//            FCCFdHead
//            +FCFdTFiles_UIStr_Get(uistrUI,'MCGDatHead')
//            +FCCFdHeadEnd
//            );
//         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone')+'<br>');
//      end; //==END== case: gmcmnItransit ==//
//   end; //==END== case MSmissType of ==//

end;

end.
