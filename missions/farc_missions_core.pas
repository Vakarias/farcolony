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
//   CMC_destinationLocation: TFCRufStelObj;
   CMC_dockList: array of record
      DL_spaceUnitIndex: integer;
      DL_landTime: integer;
      DL_tripTime: integer;
      DL_usedReactionMass: extended;
   end;
   CMC_accelerationInG: extended;
   CMC_baseDistance: extended;
   CMC_colonyAlreadyExisting: integer;
   CMC_requiredDeltaV: extended;
   CMC_cruiseDeltaV: extended;
   CMC_maxDeltaV: extended;
   CMC_finalDeltaV: extended;
   CMC_landTime: integer;
   CMC_regionOfDestination: integer;
   CMC_timeAccel: integer;
   CMC_timeDecel: integer;
   CMC_tripTime: integer;
   CMC_reactionMassMaxVol: extended;
   CMC_usedReactionMassVol: extended;

//   CMD_mission: TFCEdmtTasks;
//   GMCtimeA
//   ,GMCtimeD
//: integer;
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
   ,farc_ui_actionpanel
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
      -2012Nov18- *mod: begin of routine rewrite for the interplanetary transit mission.
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
         if length ( FCRmcCurrentMissionCalculations.CMC_dockList )-1<1 then
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
               FCMuiAP_Update_SpaceUnit;
            end;
         end;
      end; //==END== case: tMissionColonization ==//

      tMissionInterplanetaryTransit:
      begin
         setlength(FCDdmtTaskListToProcess, length(FCDdmtTaskListToProcess)+1);
         TaskIndex:=length(FCDdmtTaskListToProcess)-1;
         FCDdmtTaskListToProcess[TaskIndex].T_entity:=FCRmcCurrentMissionCalculations.CMC_entity;
         FCDdmtTaskListToProcess[TaskIndex].T_inProcessData.IPD_isTaskDone:=false;
         FCDdmtTaskListToProcess[TaskIndex].T_inProcessData.IPD_isTaskTerminated:=false;
         FCDdmtTaskListToProcess[TaskIndex].T_inProcessData.IPD_ticksAtTaskStart:=0;
         FCDdmtTaskListToProcess[TaskIndex].T_controllerIndex:=FCDmcCurrentMission[Entity].T_controllerIndex;
         FCDdmtTaskListToProcess[TaskIndex].T_duration:=FCRmcCurrentMissionCalculations.CMC_tripTime;
         FCDdmtTaskListToProcess[TaskIndex].T_durationInterval:=1;
         FCDdmtTaskListToProcess[TaskIndex].T_previousProcessTime:=0;
         FCDdmtTaskListToProcess[TaskIndex].T_type:=tMissionInterplanetaryTransit;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITphase:=mitpAcceleration;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITorigin:=FCDmcCurrentMission[Entity].T_tMITorigin;
         FCDdmtTaskListToProcess[TaskIndex].T_tMIToriginIndex:=FCDmcCurrentMission[Entity].T_tMIToriginIndex;
         FCDdmtTaskListToProcess[TaskIndex].T_tMIToriginSatIndex:=FCDmcCurrentMission[Entity].T_tMIToriginSatIndex;
         {.update the space unit data}
         FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListToProcess[TaskIndex].T_controllerIndex].SU_locationOrbitalObject:='';
         FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListToProcess[TaskIndex].T_controllerIndex].SU_locationSatellite:='';
         FCDdmtTaskListToProcess[TaskIndex].T_tMITdestination:=FCDmcCurrentMission[Entity].T_tMITdestination;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITdestinationIndex:=FCDmcCurrentMission[Entity].T_tMITdestinationIndex;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITdestinationSatIndex:=FCDmcCurrentMission[Entity].T_tMITdestinationSatIndex;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITcruiseVelocity:=FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITcruiseTime:=FCRmcCurrentMissionCalculations.CMC_timeAccel;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITfinalVelocity:=FCRmcCurrentMissionCalculations.CMC_finalDeltaV;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITfinalTime:=FCRmcCurrentMissionCalculations.CMC_timeDecel;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITusedReactionMassVol:=FCRmcCurrentMissionCalculations.CMC_usedReactionMassVol;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITinProcessData.IPD_accelerationByTick:=0;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITinProcessData.IPD_timeForDeceleration:=0;
         FCDdmtTaskListToProcess[TaskIndex].T_tMITinProcessData.IPD_timeToTransfert:=0;
         if Entity=0 then
         begin
            FCMuiMS_Planel_Close;
            if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListToProcess[TaskIndex].T_tMCoriginIndex].SU_linked3dObject] then
            begin
               FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
               FCMuiAP_Update_SpaceUnit;
            end;
         end;
      end; //==END== case: gmcmnItransit ==//
   end; //==END== case GMCmissTp of ==//
   FCVdiGameFlowTimer.Enabled:=true;
end;

procedure FCMgMCore_Mission_Setup(
   const Entity
         ,SpaceUnit: integer;
   const MissionType: TFCEdmtTasks;
   const isMustSet3D: boolean
   );
{:Purpose: Interplanetary transit mission setup.
    Additions:
      -2012Nov04- *fix: setup the interface BEFORE the calculations are processed.
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
   FCRmcCurrentMissionCalculations.CMC_requiredDeltaV:=0;
   FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV:=0;
   FCRmcCurrentMissionCalculations.CMC_maxDeltaV:=0;
   FCRmcCurrentMissionCalculations.CMC_finalDeltaV:=0;
   FCRmcCurrentMissionCalculations.CMC_landTime:=0;
   FCRmcCurrentMissionCalculations.CMC_regionOfDestination:=0;
   FCRmcCurrentMissionCalculations.CMC_timeAccel:=0;
   FCRmcCurrentMissionCalculations.CMC_timeDecel:=0;
   FCRmcCurrentMissionCalculations.CMC_tripTime:=0;
   FCRmcCurrentMissionCalculations.CMC_reactionMassMaxVol:=0;
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
            if Entity=0
            then FCMuiMS_ColonizationInterface_Setup;
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
            if Entity=0
            then FCMuiMS_ColonizationInterface_Setup;
   //         else AI-Colonization Determination(Entity);
            FCMmC_Colonization_Setup(
               cmDockingList
               ,SpaceUnit
               );
         end;
      end; //==END== case: tMissionColonization ==//

      tMissionInterplanetaryTransit:
      begin
         FCDmcCurrentMission[Entity].T_controllerIndex:=SpaceUnit;
         if FCRmcCurrentMissionCalculations.CMC_originLocation[4]=0
         then FCDmcCurrentMission[Entity].T_tMITorigin:=ttOrbitalObject
         else if FCRmcCurrentMissionCalculations.CMC_originLocation[4]>0
         then FCDmcCurrentMission[Entity].T_tMITorigin:=ttSatellite;
         FCDmcCurrentMission[Entity].T_tMIToriginIndex:=FCRmcCurrentMissionCalculations.CMC_originLocation[3];
         FCDmcCurrentMission[Entity].T_tMIToriginSatIndex:=FCRmcCurrentMissionCalculations.CMC_originLocation[4];
         FCDmcCurrentMission[Entity].T_tMITdestination:=ttSelf;
         FCDmcCurrentMission[Entity].T_tMITdestinationIndex:=0;
         FCDmcCurrentMission[Entity].T_tMITdestinationSatIndex:=0;
         FCDmcCurrentMission[Entity].T_tMITcruiseVelocity:=0;
         FCDmcCurrentMission[Entity].T_tMITcruiseTime:=0;
         FCDmcCurrentMission[Entity].T_tMITfinalVelocity:=0;
         FCDmcCurrentMission[Entity].T_tMITfinalTime:=0;
         FCDmcCurrentMission[Entity].T_tMITusedReactionMassVol:=0;
         if Entity=0
         then FCMuiMS_InterplanetaryTransitInterface_Setup;
   //         else AI-Colonization Determination(Entity);
      end;
   end; //==END== case FCDmcCurrentMission[Entity].T_type of ==//
   FCWinMain.FCWM_MissionSettings.Show;
   FCWinMain.FCWM_MissionSettings.BringToFront;
end;

end.
