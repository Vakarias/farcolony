{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: tasks system - core unit

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
unit farc_game_tasksystem;

interface

//uses

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   cleanup the TFCDdmtTaskListInProcess array of terminated tasks, if there's any
///</summary>
///   <remarks>for space units missions, the E_spaceUnits[].SU_assignedTask is updated, if needed</remarks>
procedure FCMgTS_TaskInProcess_Cleanup;

///<summary>
///   process the space units tasks. Replace the multiple threads creation.
///</summary>
procedure FCMgGF_Tasks_Process;

///<summary>
///   initialize the list of the tasks to process to allow the task system to process them
///</summary>
///   <remarks>the procedure reset the TFCDdmtTaskListToProcess array</remarks>
procedure FCMgTS_TaskToProcess_Initialize( const CurrentTimeTick: integer);

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_init
   ,farc_data_missionstasks
   ,farc_data_univ
   ,farc_data_3dopengl
   ,farc_game_gameflow
   ,farc_main
   ,farc_missions_colonization
   ,farc_ogl_ui
   ,farc_ogl_viewmain
   ,farc_spu_functions
   ,farc_ui_actionpanel
   ,farc_ui_msges
   ,farc_ui_win
   ,farc_univ_func
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

procedure FCMgTS_TaskInProcess_Cleanup;
{:Purpose: cleanup the TFCDdmtTaskListInProcess array of terminated tasks, if there's any.
    Additions:
}
   var
      Count
      ,Max
      ,NewCount: integer;

      TaskWorkingArray: array of TFCRdmtTask;
begin
   Count:=1;
   Max:=length( FCDdmtTaskListInProcess );
   NewCount:=0;
   SetLength( TaskWorkingArray, 1 );
   while Count<=Max-1 do
   begin
      if not FCDdmtTaskListInProcess[Count].T_inProcessData.IPD_isTaskTerminated then
      begin
         inc( NewCount );
         SetLength( TaskWorkingArray, NewCount+1 );
         TaskWorkingArray[NewCount]:=FCDdmtTaskListInProcess[Count];
         if ( FCDdmtTaskListInProcess[Count].T_type=tMissionColonization )
            or ( FCDdmtTaskListInProcess[Count].T_type=tMissionInterplanetaryTransit )
         then FCDdgEntities[FCDdmtTaskListInProcess[Count].T_entity].E_spaceUnits[FCDdmtTaskListInProcess[Count].T_controllerIndex].SU_assignedTask:=NewCount;
         {:DEV NOTES: add an entry here for planetary survey.}
      end;
      inc( Count );
   end;
   Setlength( FCDdmtTaskListInProcess, 0 );
   FCDdmtTaskListInProcess:=nil;
   Count:=1;
   Max:=length( TaskWorkingArray );
   Setlength( FCDdmtTaskListInProcess, Max );
   while Count<=Max-1 do
   begin
      FCDdmtTaskListInProcess[Count]:=TaskWorkingArray[Count];
      inc( Count );
   end;
   SetLength( TaskWorkingArray, 0 );
   TaskWorkingArray:=nil;
end;

procedure FCMgGF_Tasks_Process;
{:Purpose: process the space units tasks. Replace the multiple threads creation.
    Additions:
      -2013Jan08- *add/fix: colonization mission - set correctly which 3d object to focus during the atmospheric entry phase.
                  *add/fix: colonization mission - in case where it's the orbital object of origin which is focused, the data about the colony is correctly displayed after the colonization post-processing.
      -2012Dec16- *add: a test is inserted to see if the action panel, for the current space unit, is opened.
      -2012Dec03- *fix: colonization mission - 3d object management is corrected.
      -2011Feb12- *add: tasks extra data for colonization mission.
      -2010Sep05- *fix: colonization mission - post process: change the 2nd destination check with TITP_destType=tttSat as it should be.
      -2010Jul02- *add: colonization mission: add colony name.
      -2010Jun15- *add: use non-3dview-bounded space locations for interplanetary and colonization end of mission.
      -2010Jun02- *rem: remove colony mission completion message.
      -2010May17- *fix: add orbital object data into end of mission message for interplanetary trnasit.
      -2010May12- *add: in interplanetary transit mission, when it's done and the related space unit have docked vessels, the resulting
                        velocity is applied on all docked vessels.
      -2010May11- *add: interplanetary transit mission.
      -2010May10- *add: complete colonization mission.
      -2010May04- *add: colonization mission update.

}
var
  GTPcount
  ,GTPdkcdCnt
  ,GTPdckdIdx
  ,GTPdckdVslMax
  ,GTPfac
  ,GTPmaxDayMonth
  ,GTPnumTaskToProc
  ,GTPnumTaskInProc
  ,GTPnumTTProcIdx
  ,GTPoobjDB
  ,GTPsatDB
  ,GTPssysDB
  ,GTPstarDB
  ,GTPspuOwn
  ,GTPstartTaskAt
  ,GTPstartThrAt
  ,GTPtaskIdx
  ,GTPthreadIdx
  ,IntCalculation1: integer;

  GTPmove
  ,GTPspUnVel: extended;

  GTPendPh: boolean;
begin
   GTPnumTaskInProc:=length(FCDdmtTaskListInProcess)-1;
   if GTPnumTaskInProc>0
   then
   begin
      {:DEV NOTES: put in a function a test with the duration interval. Input: TFCEdmtTasks + T_previousProcessTime /  Output: passed: boolean
         - if previous process = 0, it's the start of the task, so it's passed automatically.
         - if interval=1, return passed automatically

         - for the rest do the test

         don't forget to update the previous process time with the current time tick in this tasks process
      }
      GTPtaskIdx:=1;
      while GTPtaskIdx<=GTPnumTaskInProc do
      begin
         if (not FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_isTaskTerminated)
         then
         begin
            GTPfac:=FCDdmtTaskListInProcess[GTPtaskIdx].T_entity;
            GTPspuOwn:=FCDdmtTaskListInProcess[GTPtaskIdx].T_controllerIndex;
            case FCDdmtTaskListInProcess[GTPtaskIdx].T_type of
               {.mission - colonization}
               tMissionColonization:
               begin
                  {.deceleration phase}
                  if (GGFnewTick>GGFoldTick)
                     and(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCphase=mcpDeceleration)
                  then
                  begin
                     if GGFnewTick>=FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCinProcessData.IPD_timeForDeceleration
                     then
                     begin
                        GTPspUnVel:=FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCfinalVelocity;
                        FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCphase:=mcpAtmosphericEntry;
                     end
                     else if GGFnewTick<FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCinProcessData.IPD_timeForDeceleration
                     then
                     begin
                        GTPspUnVel
                           :=FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV-(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCinProcessData.IPD_accelerationByTick*(GGFnewTick-GGFoldTick));
                        FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV:=FCFcF_Round(
                           rttVelocityKmSec
                           ,GTPspUnVel
                           );
                        GTPmove:=FCFcF_Scale_Conversion(
                           cVelocityKmSecTo3dViewUnits
                           ,FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                           );
                        FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_3dVelocity:=GTPmove;
                     end;
                  end; //==END== if (GGFnewTick>GGFoldTick) and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpDecel) ==//
                  {.atmospheric entry phase}
                  if (GGFnewTick>GGFoldTick)
                     and(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCphase=mcpAtmosphericEntry)
                  then
                  begin
                     if ( FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCorigin=ttSpaceUnitDockedIn )
                        and ( FCDdgEntities[0].E_spaceUnits[FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCoriginIndex].SU_linked3dObject > 0 ) then
                     begin
                        FC3doglSelectedSpaceUnit:=FCDdgEntities[0].E_spaceUnits[FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCoriginIndex].SU_linked3dObject;
                        FCMovM_CameraMain_Target(foSpaceUnit, true)
                     end
                     else begin

                           if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestination=ttOrbitalObject then
                           begin
                              FC3doglSelectedPlanetAsteroid:=FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestinationIndex;
                              FCMovM_CameraMain_Target(foOrbitalObject, true)
                           end
                           else if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestination=ttSatellite
                           then
                           begin
                              FC3doglSelectedSatellite:=FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestinationIndex].Tag;//! review that
                              FCMovM_CameraMain_Target(foSatellite, true);
                           end;
//                     end;
//                        end;
                     end;
                     if GGFnewTick>=FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_duration
                     then FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_isTaskDone:=true;
                  end;
                  if FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_isTaskDone
                  then
                  begin
                     {.unload the current task to the space unit}
                     FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_assignedTask:=0;
                     FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_status:=susLanded;
                     {.set the remaining reaction mass}
                     FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_reactionMass
                        :=FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_reactionMass-FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCusedReactionMassVol;
                     {.colonize mission post-process}
                     {:DEV NOTES: replace these 2 lines with FCFuF_StelObj_GetDbIdx / FCFuF_StelObj_GetFullRow or FCFuF_StelObj_GetStarSystemStar.}
                     GTPssysDB:=FCFuF_StelObj_GetDbIdx(
                           ufsoSsys
                           ,FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_locationStarSystem
                           ,0
                           ,0
                           ,0
                           );
                     GTPstarDB:=FCFuF_StelObj_GetDbIdx(
                        ufsoStar
                        ,FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_locationStar
                        ,GTPssysDB
                        ,0
                        ,0
                        );
                     GTPoobjDB:=0;
                     GTPsatDB:=0;
                     if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestination=ttOrbitalObject
                     then
                     begin
                        GTPoobjDB:=FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestinationIndex;
                        FCMgC_Colonize_PostProc(
                           FCDdmtTaskListInProcess[GTPtaskIdx].T_entity
                           ,GTPspuOwn
                           ,GTPssysDB
                           ,GTPstarDB
                           ,FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestinationIndex
                           ,0
                           ,FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestinationRegion
                           ,FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCsettlementType
                           ,FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCcolonyName
                           ,FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCsettlementName
                           );
                        if ( FCFovM_Focused3dObject_GetType=foOrbitalObject )
                           and ( FCDduStarSystem[GTPssysDB].SS_stars[GTPstarDB].S_token=FCVdgPlayer.P_viewStar )
                           and ( FC3doglSelectedPlanetAsteroid=FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestinationIndex) then
                        begin
                           FCMoglUI_CoreUI_Update(ptuTextsOnly, ttuFocusedObject);
                           FCMuiAP_Update_OrbitalObject;
                        end;
                     end
                     else if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestination=ttSatellite
                     then
                     begin
                        GTPoobjDB:=round(FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestinationIndex].TagFloat); //ERROR:FCGtskListInProc[GTPtaskIdx].T_tMCdestinationIndex doesn't link to the
                        GTPsatDB:=FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestinationIndex].Tag; //satellite 3d object index! use: FCFoglVM_SatObj_Search
                        FCMgC_Colonize_PostProc(
                           FCDdmtTaskListInProcess[GTPtaskIdx].T_entity
                           ,GTPspuOwn
                           ,GTPssysDB
                           ,GTPstarDB
                           ,GTPoobjDB
                           ,GTPsatDB
                           ,FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestinationRegion
                           ,FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCsettlementType
                           ,FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCcolonyName
                           ,FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCsettlementName
                           );
                        if ( FCFovM_Focused3dObject_GetType=foSatellite )
                           and ( FCDduStarSystem[GTPssysDB].SS_stars[GTPstarDB].S_token=FCVdgPlayer.P_viewStar )
                           and ( FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat=GTPoobjDB)
                           and ( FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag=GTPsatDB) then
                        begin
                           FCMoglUI_CoreUI_Update(ptuTextsOnly, ttuFocusedObject);
                           FCMuiAP_Update_OrbitalObject;
                        end;
                     end;


                     FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_isTaskTerminated:=true;
                  end;
               end; //==END== case: tatpMissColonize ==//
               {.mission - interplanetary transit}
               tMissionInterplanetaryTransit:
               begin
                  if (GGFnewTick>GGFoldTick)
                     and(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITphase=mitpAcceleration)
                  then
                  begin
                     if GGFnewTick=FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITcruiseTime
                     then FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITphase:=mitpCruise
                     else if GGFnewTick>FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITcruiseTime
                     then
                     begin
                        FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert
                           :=GGFnewTick-(FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITcruiseTime);
                        GTPspUnVel
                           :=FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                                 +(
                                    FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_accelerationByTick
                                    *(GGFnewTick-GGFoldTick-FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert)
                                    );
                        FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                           :=FCFcF_Round(
                              rttVelocityKmSec
                              ,GTPspUnVel
                              );
                        GTPmove:=FCFcF_Scale_Conversion(
                           cVelocityKmSecTo3dViewUnits
                           ,FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                           );
                        FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_3dVelocity:=GTPmove;
                        FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITphase:=mitpCruise;
                     end
                     else if GGFnewTick<FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITcruiseTime
                     then
                     begin
                        GTPspUnVel
                           :=FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                              +(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_accelerationByTick*(GGFnewTick-GGFoldTick));
                        FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                           :=FCFcF_Round(
                              rttVelocityKmSec
                              ,GTPspUnVel
                              );
                        GTPmove:=FCFcF_Scale_Conversion(
                           cVelocityKmSecTo3dViewUnits
                           ,FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                           );
                        FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_3dVelocity:=GTPmove;
                     end;
                  end; //==END== if (GGFnewTick>GGFoldTick) and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpAccel) ==//
                  if (GGFnewTick>GGFoldTick)
                     and(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITphase=mitpCruise)
                  then
                  begin
                     {.used for calculations of deceleration time to transfert}
                     IntCalculation1:=0;
                     if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert>0 then
                     begin
                        if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert+GGFoldTick
                           =FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITcruiseTime
                              +FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeForDeceleration
                        then
                        begin
                           FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert:=0;
                           {:DEV NOTES: put that line below after :=intcalculation1 because mitpDeleration is the case for EACH OUTCOME OF THE TESTS.}
                           FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITphase:=mitpDeceleration;   //remove
                        end
                        else if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert+GGFoldTick
                           >FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITcruiseTime
                              +FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeForDeceleration
                        then
                        begin
                           IntCalculation1
                              :=(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert+GGFoldTick)
                                 -(FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITcruiseTime
                              +FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeForDeceleration);
                           FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert:=0;
                           FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITphase:=mitpDeceleration;   //remove
                        end;
                     end
                     else if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert=0
                     then
                     begin
                        if GGFnewTick=FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITcruiseTime
                              +FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeForDeceleration
                        then FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITphase:=mitpDeceleration      //remove
                        else if GGFnewTick>FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITcruiseTime
                              +FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeForDeceleration
                        then
                        begin
                           IntCalculation1
                              :=GGFnewTick-(FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITcruiseTime
                              +FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeForDeceleration);
                           FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITphase:=mitpDeceleration;  //remove
                        end;
                     end;
                     FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert:=IntCalculation1;
                  end; //==END== if (GGFnewTick>GGFoldTick) and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpCruise) ==//
                  if (GGFnewTick>GGFoldTick)
                     and(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITphase=mitpDeceleration)
                  then
                  begin
                     if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert>0
                     then
                     begin
                        if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert+GGFoldTick
                           >=FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_duration
                        then
                        begin
                           GTPspUnVel:=FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITfinalVelocity;
                           FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert:=0;
                           {.update data structure}
                           FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                              :=FCFcF_Round(
                                 rttVelocityKmSec
                                 ,GTPspUnVel
                                 );
                           GTPmove:=FCFcF_Scale_Conversion(
                              cVelocityKmSecTo3dViewUnits
                              ,FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                              );
                           FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_3dVelocity:=GTPmove;
                           FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_isTaskDone:=true;
                        end
                        else if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert+GGFoldTick
                           <FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_duration
                        then
                        begin
                           GTPspUnVel
                              :=FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                                 -(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_accelerationByTick*(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert));
                           FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                              :=FCFcF_Round(
                                 rttVelocityKmSec
                                 ,GTPspUnVel
                                 );
                           GTPmove:=FCFcF_Scale_Conversion(
                              cVelocityKmSecTo3dViewUnits
                              ,FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                              );
                           FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_3dVelocity:=GTPmove;
                           FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert:=0;
                        end;
                     end
                     else if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert=0
                     then
                     begin
                        if GGFnewTick>=FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_duration
                        then
                        begin
                           GTPspUnVel:=FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITfinalVelocity;
                           FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                              :=FCFcF_Round(
                                 rttVelocityKmSec
                                 ,GTPspUnVel
                                 );
                           GTPmove:=FCFcF_Scale_Conversion(
                              cVelocityKmSecTo3dViewUnits
                              ,FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                              );
                           FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_3dVelocity:=GTPmove;
                           FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_isTaskDone:=true;
                        end
                        else if GGFnewTick<FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_ticksAtTaskStart+FCDdmtTaskListInProcess[GTPtaskIdx].T_duration
                        then
                        begin
                           GTPspUnVel
                              :=FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                                 -(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_accelerationByTick*(GGFnewTick-GGFoldTick));
                           FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                           :=FCFcF_Round(
                              rttVelocityKmSec
                              ,GTPspUnVel
                              );
                           GTPmove:=FCFcF_Scale_Conversion(
                              cVelocityKmSecTo3dViewUnits
                              ,FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV
                              );
                           FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_3dVelocity:=GTPmove;
                        end;
                     end;
                  end; //==END== if (GGFnewTick>GGFoldTick) and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpDecel) ==//
                  if FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_isTaskDone=true
                  then
                  begin
                     {.unload the current task to the space unit}
                     FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_assignedTask:=0;
                     {.set the remaining reaction mass}
                     FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_reactionMass
                        :=FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_reactionMass-FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITusedReactionMassVol;
                     {.interplanetary transit mission post-process}
                     GTPssysDB:=FCFuF_StelObj_GetDbIdx(
                           ufsoSsys
                           ,FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_locationStarSystem
                           ,0
                           ,0
                           ,0
                           );
                     GTPstarDB:=FCFuF_StelObj_GetDbIdx(
                        ufsoStar
                        ,FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_locationStar
                        ,GTPssysDB
                        ,0
                        ,0
                        );
                     GTPoobjDB:=0;
                     GTPsatDB:=0;
                     {.set orbit data for destination}
                     FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_status:=susInOrbit;
                     if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITdestination=ttOrbitalObject
                     then
                     begin
                        GTPoobjDB:=FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITdestinationIndex;
                        FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_locationOrbitalObject
                           :=FCDduStarSystem[GTPssysDB].SS_stars[GTPstarDB].S_orbitalObjects[FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITdestinationIndex].OO_dbTokenId;
                        FCDdgEntities[GTPfac].E_spaceUnits[FCDdmtTaskListInProcess[GTPtaskIdx].T_controllerIndex].SU_locationSatellite:='';
                        FCMspuF_Orbits_Process(
                           spufoioAddOrbit
                           ,GTPssysDB
                           ,GTPstarDB
                           ,GTPoobjDB
                           ,0
                           ,0
                           ,GTPspuOwn
                           ,true
                           );
                     end
                     else if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITdestination=ttSatellite
                     then
                     begin
                        GTPsatDB:=FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITdestinationIndex].Tag; //ERROR:FCGtskListInProc[GTPtaskIdx].T_tMITdestinationIndex doesn't link to the
                        GTPoobjDB:=round(FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITdestinationIndex].TagFloat); //satellite 3d object index! use: FCFoglVM_SatObj_Search
                        FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_locationOrbitalObject:=FCDduStarSystem[GTPssysDB].SS_stars[GTPstarDB].S_orbitalObjects[GTPoobjDB].OO_dbTokenId;
                        FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_locationSatellite
                           :=FCDduStarSystem[GTPssysDB].SS_stars[GTPstarDB].S_orbitalObjects[GTPoobjDB].OO_satellitesList[GTPsatDB].OO_dbTokenId;
                        FCMspuF_Orbits_Process(
                           spufoioAddOrbit
                           ,GTPssysDB
                           ,GTPstarDB
                           ,GTPoobjDB
                           ,GTPsatDB
                           ,0
                           ,GTPspuOwn
                           ,true
                           );
                     end;
                     GTPdckdVslMax:=length(FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_dockedSpaceUnits);
                     if GTPdckdVslMax>1
                     then
                     begin
                        GTPdkcdCnt:=1;
                        while GTPdkcdCnt<=GTPdckdVslMax-1 do
                        begin
                           GTPdckdIdx:=FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_dockedSpaceUnits[GTPdkcdCnt].SUDL_index;
                           FCDdgEntities[GTPfac].E_spaceUnits[GTPdckdIdx].SU_deltaV:=FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV;
                           inc(GTPdkcdCnt);
                        end;
                     end;
                     FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_3dVelocity:=0;
                     FCMuiM_Message_Add(
                        mtInterplanTransit
                        ,0
                        ,GTPspuOwn
                        ,GTPoobjDB
                        ,GTPsatDB
                        ,0
                        );
                     if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_linked3dObject]
                     then
                     begin
                        FC3doglSelectedSpaceUnit:=FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_linked3dObject;
                        FCMovM_CameraMain_Target(foSpaceUnit, true);
                     end;
                     FCDdmtTaskListInProcess[GTPtaskIdx].T_inProcessData.IPD_isTaskTerminated:=true;
                  end; //==END== if FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpDone ==//
                  FCDdmtTaskListInProcess[GTPtaskIdx].T_tMITinProcessData.IPD_timeToTransfert:=0;
               end; //==END== case: tatpMissItransit ==//
            end; //==END== case FCGtskListInProc[GTPtaskIdx].TITP_actionTp ==//
         end; //==END== if (FCGtskListInProc[GTPtaskIdx].TITP_phaseTp<>tpTerminated) ==//
         inc(GTPtaskIdx);
      end; //==END== while GTPtaskIdx<=GTPnumTaskInProc ==//
   end; //==END== if GTPnumTaskInProc>0 ==//
   GGFoldTick:=GGFnewTick;
end;

procedure FCMgTS_TaskToProcess_Initialize( const CurrentTimeTick: integer);
{:Purpose: initialize the list of the tasks to process to allow the task system to process them.
    Additions:
      -2012Nov11- *mod: some adjustements for the interplanetary transit mission.
      -2012Nov04- *add: colonization and interplanetary transit missions - take in account if the space unit isn't in the current 3d view.
                  *fix: interplanetary transit mission - if the space unit is a 3d object in the current 3d view it is updated.
                  *fix: interplanetary transit mission - the popup menu is only updated under certain conditions.
                  *fix: colonization mission - set correctly the X/Z locations if it's only needed.
                  *add: colonization mission - if the space unit isn't docked, its orbit of origin is removed.
      -2012Oct04- *code audit: COMPLETION.
      -2012Oct03- *fix: correction of assignation errors for the space units.
                  *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (_)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (x)code optimizations
                     (_)float local variables=> extended (x)case..of reformatting   (_)local methods
                     (_)summary completion               (x)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (-)use of enumindex                 (x)use of StrToFloat( x, FCVdiFormat ) for all float data w/ XML
                     (x)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
}
   var
      Controller
      ,Count
      ,Entity
      ,Linked3dObject
      ,Max
      ,Origin
      ,StartTaskAtIndex
      ,TaskIndex: integer;

      Universe: TFCRufStelObj;
begin
   FCWinMain.FCGLScadencer.Enabled:=false;
   Controller:=0;
   Count:=0;
   Entity:=0;
   Linked3dObject:=0;
   Max:=0;
   Origin:=0;
   StartTaskAtIndex:=0;
   Max:=length( FCDdmtTaskListToProcess )-1;
   if Max>0 then
   begin
      StartTaskAtIndex:=length( FCDdmtTaskListInProcess )-1;
      SetLength( FCDdmtTaskListInProcess, length( FCDdmtTaskListInProcess )+Max );
      Count:=1;
      try
         while Count<=Max do
         begin
            TaskIndex:=StartTaskAtIndex+Count;
            FCDdmtTaskListInProcess[TaskIndex]:=FCDdmtTaskListToProcess[Count];
            Entity:=FCDdmtTaskListInProcess[TaskIndex].T_entity;
            Controller:=FCDdmtTaskListInProcess[TaskIndex].T_controllerIndex;
            FCDdmtTaskListInProcess[TaskIndex].T_inProcessData.IPD_ticksAtTaskStart:=CurrentTimeTick;
            case FCDdmtTaskListInProcess[TaskIndex].T_type of
               tMissionColonization:
               begin
                  Linked3dObject:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_linked3dObject;
                  Universe:=FCFuF_StelObj_GetFullRow(
                     FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationStarSystem
                     ,FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationStar
                     ,FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationOrbitalObject
                     ,FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationSatellite
                     );
                  if FCDdmtTaskListInProcess[TaskIndex].T_tMCorigin=ttSelf then
                  begin
                     Origin:=Controller;
                     FCMspuF_Orbits_Process(
                        spufoioRemOrbit
                        ,Universe[1]
                        ,Universe[2]
                        ,Universe[3]
                        ,Universe[4]
                        ,Entity
                        ,Controller
                        ,false
                        );
                  end
                  else begin
                     Origin:=FCDdmtTaskListInProcess[TaskIndex].T_tMCoriginIndex;
                     FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewX:=FCDdgEntities[Entity].E_spaceUnits[Origin].SU_locationViewX;
                     FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewZ:=FCDdgEntities[Entity].E_spaceUnits[Origin].SU_locationViewZ;
                  end;
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_assignedTask:=TaskIndex;
                  FCDdmtTaskListInProcess[TaskIndex].T_tMCphase:=mcpDeceleration;
                  FCDdmtTaskListInProcess[TaskIndex].T_tMCinProcessData.IPD_timeForDeceleration:=FCDdmtTaskListInProcess[TaskIndex].T_duration-FCDdmtTaskListInProcess[TaskIndex].T_tMCfinalTime;
                  FCDdmtTaskListInProcess[TaskIndex].T_tMCinProcessData.IPD_accelerationByTick:=FCFcF_Round(
                     rttVelocityKmSec
                     ,( FCDdgEntities[Entity].E_spaceUnits[Origin].SU_deltaV-FCDdmtTaskListInProcess[TaskIndex].T_tMCfinalVelocity )/FCDdmtTaskListInProcess[TaskIndex].T_tMCinProcessData.IPD_timeForDeceleration
                     );
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_status:=susInFreeSpace;
                  if Linked3dObject>0 then
                  begin
                     FC3doglSpaceUnits[Linked3dObject].Position.X:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewX;
                     FC3doglSpaceUnits[Linked3dObject].Position.Z:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewZ;
                     if not FC3doglSpaceUnits[Linked3dObject].Visible
                     then FC3doglSpaceUnits[Linked3dObject].Visible:=true;
                     if FCDdmtTaskListInProcess[TaskIndex].T_tMCdestination=ttOrbitalObject
                     then FC3doglSpaceUnits[Linked3dObject].PointTo
                        ( FC3doglObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMCdestinationIndex],FC3doglObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMCdestinationIndex].Position.AsVector )
                     else if FCDdmtTaskListInProcess[TaskIndex].T_tMCdestination=ttSatellite
                     then FC3doglSpaceUnits[Linked3dObject].PointTo
                        ( FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMCdestinationIndex],FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMCdestinationIndex].Position.AsVector );
                  end;
               end; //==END== case: tMissionColonization: ==//

               tMissionInterplanetaryTransit:
               begin
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_assignedTask:=TaskIndex;
                  FCDdmtTaskListInProcess[TaskIndex].T_tMITphase:=mitpAcceleration;
                  FCDdmtTaskListInProcess[TaskIndex].T_tMITinProcessData.IPD_timeForDeceleration:=
                     FCDdmtTaskListInProcess[TaskIndex].T_duration-( FCDdmtTaskListInProcess[TaskIndex].T_tMITcruiseTime+FCDdmtTaskListInProcess[TaskIndex].T_tMITfinalTime );
                  FCDdmtTaskListInProcess[TaskIndex].T_tMITinProcessData.IPD_accelerationByTick:=FCFcF_Round(
                     rttVelocityKmSec
                     ,( FCDdmtTaskListInProcess[TaskIndex].T_tMITcruiseVelocity-FCDdgEntities[Entity].E_spaceUnits[Controller].SU_deltaV )/FCDdmtTaskListInProcess[TaskIndex].T_tMITcruiseTime
                     );
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_status:=susInFreeSpace;
                  Universe:=FCFuF_StelObj_GetStarSystemStar(
                     FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationStarSystem
                     ,FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationStar
                     );
                  Linked3dObject:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_linked3dObject;
                  FCMspuF_Orbits_Process(
                     spufoioRemOrbit
                     ,Universe[1]
                     ,Universe[2]
                     ,FCDdmtTaskListInProcess[TaskIndex].T_tMIToriginIndex
                     ,FCDdmtTaskListInProcess[TaskIndex].T_tMIToriginSatIndex
                     ,Entity
                     ,Controller
                     ,false
                     );
                  if Linked3dObject>0 then
                  begin
                     FC3doglSpaceUnits[Linked3dObject].Position.X:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewX;
                     FC3doglSpaceUnits[Linked3dObject].Position.Z:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewZ;
                     if not FC3doglSpaceUnits[Linked3dObject].Visible
                     then FC3doglSpaceUnits[Linked3dObject].Visible:=true;
                     if FCDdmtTaskListInProcess[TaskIndex].T_tMITdestination=ttOrbitalObject
                     then FC3doglSpaceUnits[Linked3dObject].PointTo
                        ( FC3doglObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMITdestinationIndex],FC3doglObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMITdestinationIndex].Position.AsVector )
                     else if FCDdmtTaskListInProcess[TaskIndex].T_tMITdestination=ttSatellite
                     then FC3doglSpaceUnits[Linked3dObject].PointTo
                        ( FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMITdestinationIndex],FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMITdestinationIndex].Position.AsVector );
                  end;
                  if ( Entity=0 )
                     and ( FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Tag=Entity )
                     and ( round( FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat )=Controller )
                  then FCMuiAP_Update_SpaceUnit;
               end; //==END== case: tMissionInterplanetaryTransit ==//
            end; //==END== case FCDdmtTaskListInProcess[TaskIndex].T_type ==//
            inc( Count );
         end; //==END== while Count<=Max do ==//
      finally
         setlength( FCDdmtTaskListToProcess, 1 );
      end;
   end; //==END== if Max>0 ==//
   FCWinMain.FCGLScadencer.Enabled:=true;
end;

end.
