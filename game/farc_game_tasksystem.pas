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
///   initialize the list of the tasks to process to allow the task system to process them
///</summary>
///   <remarks>the procedure reset the TFCDdmtTaskListToProcess array</remarks>
procedure FCMgTS_TaskToProcess_Initialize( const CurrentTimeTick: integer);

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_common_func
   ,farc_data_game
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

procedure FCMgTS_TaskToProcess_Initialize( const CurrentTimeTick: integer);
{:Purpose: initialize the list of the tasks to process to allow the task system to process them.
    Additions:
      -2012Nov04- *add: colonization and interplanetary transit missions - take in account if the space unit isn't in the current 3d view.
                  *fix: interplanetary transit mission - if the space unit is a 3d object in the current 3d view it is updated.
                  *fix: interplanetary transit mission - the popup menu is only updated under certain conditions.
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
                  if FCDdmtTaskListInProcess[TaskIndex].T_tMCorigin=ttSelf
                  then Origin:=Controller
                  else Origin:=FCDdmtTaskListInProcess[TaskIndex].T_tMCoriginIndex;
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_assignedTask:=TaskIndex;
                  FCDdmtTaskListInProcess[TaskIndex].T_tMCphase:=mcpDeceleration;
                  FCDdmtTaskListInProcess[TaskIndex].T_tMCinProcessData.IPD_timeForDeceleration:=FCDdmtTaskListInProcess[TaskIndex].T_duration-FCDdmtTaskListInProcess[TaskIndex].T_tMCfinalTime;
                  FCDdmtTaskListInProcess[TaskIndex].T_tMCinProcessData.IPD_accelerationByTick:=FCFcFunc_Rnd(
                     cfrttpVelkms
                     ,( FCDdgEntities[Entity].E_spaceUnits[Origin].SU_deltaV-FCDdmtTaskListInProcess[TaskIndex].T_tMCfinalVelocity )/FCDdmtTaskListInProcess[TaskIndex].T_tMCinProcessData.IPD_timeForDeceleration
                     );
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_status:=susInFreeSpace;
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewX:=FCDdgEntities[Entity].E_spaceUnits[Origin].SU_locationViewX;
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationViewZ:=FCDdgEntities[Entity].E_spaceUnits[Origin].SU_locationViewZ;
                  Linked3dObject:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_linked3dObject;
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
                  FCDdmtTaskListInProcess[TaskIndex].T_tMITinProcessData.IPD_accelerationByTick:=FCFcFunc_Rnd(
                     cfrttpVelkms
                     ,( FCDdmtTaskListInProcess[TaskIndex].T_tMITcruiseVelocity-FCDdgEntities[Entity].E_spaceUnits[Controller].SU_deltaV )/FCDdmtTaskListInProcess[TaskIndex].T_tMITcruiseTime
                     );
                  FCDdgEntities[Entity].E_spaceUnits[Controller].SU_status:=susInFreeSpace;
                  Universe:=FCFuF_StelObj_GetFullRow(
                     FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationStarSystem
                     ,FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationStar
                     ,FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationOrbitalObject
                     ,FCDdgEntities[Entity].E_spaceUnits[Controller].SU_locationSatellite
                     );
                  Linked3dObject:=FCDdgEntities[Entity].E_spaceUnits[Controller].SU_linked3dObject;
                  if Linked3dObject=0 then
                  begin
                     if FCDdmtTaskListInProcess[TaskIndex].T_tMITorigin=ttOrbitalObject
                     then FCMspuF_Orbits_Process(
                        spufoioRemOrbit
                        ,Universe[1]
                        ,Universe[2]
                        ,Universe[3]
                        ,0
                        ,Entity
                        ,Controller
                        ,false
                        )
                     else if FCDdmtTaskListInProcess[TaskIndex].T_tMITorigin=ttSatellite
                     then FCMspuF_Orbits_Process(
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
                  else if Linked3dObject>0 then
                  begin
                     if FCDdmtTaskListInProcess[TaskIndex].T_tMITorigin=ttOrbitalObject
                     then FCMspuF_Orbits_Process(
                        spufoioRemOrbit
                        ,Universe[1]
                        ,Universe[2]
                        ,Universe[3]
                        ,0
                        ,Entity
                        ,Controller
                        ,true
                        )
                     else if FCDdmtTaskListInProcess[TaskIndex].T_tMITorigin=ttSatellite
                     then FCMspuF_Orbits_Process(
                           spufoioRemOrbit
                           ,Universe[1]
                           ,Universe[2]
                           ,Universe[3]
                           ,Universe[4]
                           ,Entity
                           ,Controller
                           ,true
                           );
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
                  then FCMuiW_FocusPopup_Upd(uiwpkSpUnit);
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
