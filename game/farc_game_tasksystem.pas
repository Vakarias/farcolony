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
///   initialize the list of the tasks to process to allow the task system to process them
///</summary>
///   <remarks>the procedure reset the TFCDdmtTaskListToProcess array</remarks>
procedure FCMgTS_TaskToProcess_Initialize( const CurrentTimeTick: integer);

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_data_game
   ,farc_data_missionstasks
   ,farc_data_3dopengl
   ,farc_main
   ,farc_spu_functions
   ,farc_ui_win
   ,farc_univ_func;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgTS_TaskToProcess_Initialize( const CurrentTimeTick: integer);
{:Purpose: initialize the list of the tasks to process to allow the task system to process them.
    Additions:
      -2012Oct03- *fix: correction of assignation errors for the space units.
                  *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (-)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (o)code optimizations
                     (_)float local variables=> extended (x)case..of reformatting   (-)local methods
                     (_)summary completion               (-)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (-)use of enumindex                 (-)use of StrToFloat( x, FCVdiFormat ) for all float data w/ XML
                     (x)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
}
{:DEV NOTES: apply code audit after that code migration is complete.}
   var
      Controller
      ,Count
      ,Entity
      ,Linked3dObject
      ,Max
      ,StartTaskAtIndex
      ,TaskIndex: integer;

      Universe: TFCRufStelObj;
begin
   {:DEV NOTES: WARNING: check all array index assignations!.}
   FCWinMain.FCGLScadencer.Enabled:=false;
   Controller:=0;
   Count:=0;
   Entity:=0;
   Linked3dObject:=0;
   Max:=0;
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
            {.update the tasklist in process}
            FCDdmtTaskListInProcess[TaskIndex]:=FCDdmtTaskListToProcess[Count];
            FCDdmtTaskListInProcess[TaskIndex].T_inProcessData.IPD_ticksAtTaskStart:= CurrentTimeTick;
            Controller:=FCDdmtTaskListInProcess[TaskIndex].T_controllerIndex;
            {.update the tasklist in process index inside the owned space unit data structure}
            Entity:=FCDdmtTaskListInProcess[TaskIndex].T_entity;
            FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListInProcess[TaskIndex].T_controllerIndex].SU_assignedTask:=TaskIndex;
            {.mission related data init}
            case FCDdmtTaskListInProcess[TaskIndex].T_type of
               tMissionColonization:
               begin
                  FCDdmtTaskListInProcess[TaskIndex].T_tMCphase:=mcpDeceleration;
                  FCDdmtTaskListInProcess[TaskIndex].T_tMCinProcessData.IPD_timeForDeceleration:=FCDdmtTaskListInProcess[TaskIndex].T_duration-FCDdmtTaskListInProcess[TaskIndex].T_tMCfinalTime;
                  FCDdmtTaskListInProcess[TaskIndex].T_tMCinProcessData.IPD_accelerationByTick
                     :=( FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListInProcess[TaskIndex].T_tMCoriginIndex].SU_deltaV-FCDdmtTaskListInProcess[TaskIndex].T_tMCfinalVelocity )//assignation error!!!!  E_spaceUnits[FCGtskListInProc[GTPtaskIdx].TITP_orgIdx]
                        /FCDdmtTaskListInProcess[TaskIndex].T_tMCinProcessData.IPD_timeForDeceleration;
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationOrbitalObject:='';
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationSatellite:='';
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_status:=susInFreeSpace;
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewX:=FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListInProcess[TaskIndex].T_tMCoriginIndex].SU_locationViewX; //assignation error!!!!  E_spaceUnits[FCGtskListInProc[GTPtaskIdx].TITP_orgIdx]
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewZ:=FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListInProcess[TaskIndex].T_tMCoriginIndex].SU_locationViewZ; //assignation error!!!!  E_spaceUnits[FCGtskListInProc[GTPtaskIdx].TITP_orgIdx]
                  Linked3dObject:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_linked3dObject;
                  FC3doglSpaceUnits[Linked3dObject].Position.X:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewX;
                  FC3doglSpaceUnits[Linked3dObject].Position.Z:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewZ;
                  {.3d initialization}
                  if not FC3doglSpaceUnits[Linked3dObject].Visible
                  then FC3doglSpaceUnits[Linked3dObject].Visible:=true;
                  if FCDdmtTaskListInProcess[TaskIndex].T_tMCdestination=ttOrbitalObject
                  then FC3doglSpaceUnits[Linked3dObject].PointTo
                     ( FC3doglObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMCdestinationIndex],FC3doglObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMCdestinationIndex].Position.AsVector )
                  else if FCDdmtTaskListInProcess[TaskIndex].T_tMCdestination=ttSatellite
                  then FC3doglSpaceUnits[Linked3dObject].PointTo
                     ( FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMCdestinationIndex],FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMCdestinationIndex].Position.AsVector );
               end; //==END== case: tatpMissColonize: ==//

               tMissionInterplanetaryTransit:
               begin
                  FCDdmtTaskListInProcess[TaskIndex].T_tMITphase:=mitpAcceleration;
                  FCDdmtTaskListInProcess[TaskIndex].T_tMITinProcessData.IPD_timeForDeceleration
                     :=FCDdmtTaskListInProcess[TaskIndex].T_duration-( FCDdmtTaskListInProcess[TaskIndex].T_tMITcruiseTime+FCDdmtTaskListInProcess[TaskIndex].T_tMITfinalTime );
                  FCDdmtTaskListInProcess[TaskIndex].T_tMITinProcessData.IPD_accelerationByTick
                     :=( FCDdmtTaskListInProcess[TaskIndex].T_tMITcruiseVelocity-FCDdgEntities[Entity].E_spaceUnits[FCDdmtTaskListInProcess[TaskIndex].T_tMIToriginIndex].SU_deltaV )  //assignation error!!!!  E_spaceUnits[FCGtskListInProc[GTPtaskIdx].TITP_orgIdx]
                        /FCDdmtTaskListInProcess[TaskIndex].T_tMITcruiseTime;
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationOrbitalObject:='';
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationSatellite:='';
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_status:=susInFreeSpace;
                  Universe:=FCFuF_StelObj_GetStarSystemStar( FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationStarSystem, FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationStar );
                  if FCDdmtTaskListInProcess[TaskIndex].T_tMITorigin=ttOrbitalObject
                  then FCMspuF_Orbits_Process(
                     spufoioRemOrbit
                     ,Universe[1]
                     ,Universe[2]
                     ,FCDdmtTaskListInProcess[TaskIndex].T_tMIToriginIndex
                     ,0
                     ,0
                     ,FCDdmtTaskListInProcess[TaskIndex].T_controllerIndex
                     ,true
                     )
                  else if FCDdmtTaskListInProcess[TaskIndex].T_tMITorigin=ttSatellite
                  then FCMspuF_Orbits_Process(
                        spufoioRemOrbit
                        ,Universe[1]
                        ,Universe[2]
                        ,round( FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMIToriginIndex].TagFloat )
                        ,FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMIToriginIndex].Tag
                        ,0
                        ,FCDdmtTaskListInProcess[TaskIndex].T_controllerIndex
                        ,true
                        );
                  FCMuiW_FocusPopup_Upd(uiwpkSpUnit);
                  Linked3dObject:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_linked3dObject;
                  if FCDdmtTaskListInProcess[TaskIndex].T_tMITdestination=ttOrbitalObject
                  then FC3doglSpaceUnits[Linked3dObject].PointTo
                     ( FC3doglObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMITdestinationIndex],FC3doglObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMITdestinationIndex].Position.AsVector )
                  else if FCDdmtTaskListInProcess[TaskIndex].T_tMITdestination=ttSatellite
                  then FC3doglSpaceUnits[Linked3dObject].PointTo
                     ( FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMITdestinationIndex],FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[TaskIndex].T_tMITdestinationIndex].Position.AsVector );
               end; //==END== tatpMissItransit ==//
            end; //==END== case FCGtskListInProc[GTPtaskIdx].TITP_actionTp ==//
            inc( Count );
         end; //==END== while GTPnumTTProcIdx<=GTPnumTaskToProc ==//
      finally
         setlength( FCDdmtTaskListToProcess, 1 );
      end;
   end; //==END== if GTPnumTaskToProc>0 ==//
   FCWinMain.FCGLScadencer.Enabled:=true;
end;

end.
