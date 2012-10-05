{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: missions and tasks - data unit

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
unit farc_data_missionstasks;

interface

uses
   farc_data_game;

{:REFERENCES LIST
   - FCFspuF_Mission_GetPhaseName
   - FCMdFiles_Game_Load
   - FCMdFiles_Game_Save
}
///<summary>
///   task phases for the colonization mission
///</summary>
type TFCEdmtTaskPhasesColonization=(
   mcpDeceleration
   ,mcpAtmosphericEntry
   );

{:REFERENCES LIST
   - FCFspuF_Mission_GetPhaseName
   - FCMdFiles_Game_Load
   - FCMdFiles_Game_Save
}
///<summary>
///   task phases for the interplanetary transit mission
///</summary>
type TFCEdmtTaskPhasesInterplanetaryTransit=(
   mitpAcceleration
   ,mitpCruise
   ,mitpDeceleration
   );

{:REFERENCES LIST
   - FCMgMCore_Mission_Commit
   - FCMgMCore_Mission_Setup
   - FCMgMCore_Mission_TrackUpd
   - FCFspuF_Mission_GetMissName
   - FCMspuF_SpUnit_Remove
   - TFCRdmtTask
}
///<summary>
///   tasks
///</summary>
type TFCEdmtTasks=(
   tMissionColonization
   ,tMissionInterplanetaryTransit
   ,tDummy
   );

///<summary>
///   targets
///</summary>
type TFCEdmtTaskTargets=(
//   ttInfrastructure
//   ,
   ttSelf
   ,ttSpaceUnitDockedIn
   ,ttOrbitalObject
   ,ttSatellite
   ,ttSpace
   );

//==END PUBLIC ENUM=========================================================================

{:REFERENCES LIST
   - FCMdFiles_Game_Load
   - FCMdFiles_Game_Save
   - TFCGtasklistToProc: farc_game_missioncore /FCMgMCore_Mission_Commit
   - TFCGtasklistInProc: farc_game_gameflow /FCMgTFlow_GameTimer_Process + FCMgGFlow_Tasks_Process
}
///<summary>
///   task
///</summary>
type TFCRdmtTask = record
   ///<summary>
   ///   entity index # linked to the task
   ///</summary>
   T_entity: integer;
   ///<summary>
   ///   subset of data for the task in process only
   ///</summary>
   T_inProcessData: record
      ///<summary>
      ///   indicate that the task is done
      ///</summary>
      IPD_isTaskDone: boolean;
      ///<summary>
      ///   indicate that the task is terminated and ready to be flushed
      ///</summary>
      IPD_isTaskTerminated: boolean;
      ///<summary>
      ///   current timer ticks at start of the task
      ///</summary>
      IPD_ticksAtTaskStart: integer;
   end;
   ///<summary>
   ///   task controller index. The type of controller is deduced by the type of task
   ///   for missions, the controller is always a space unit. For planetary survey
   ///   for planetary surveys, the controller is always a group of vehicles (called an expedition)
   ///</summary>
   T_controllerIndex: integer;
   ///<summary>
   ///   task duration in the defined scale in the interval, 0= infinite
   ///</summary>
   T_duration: integer;
   ///<summary>
   ///   interval, in clock tick, between 2 running processes of the task
   ///</summary>
   T_durationInterval: integer;
   ///<summary>
   ///   previous process time
   ///</summary>
   T_previousProcessTime: integer;
   case T_type: TFCEdmtTasks of
      tMissionColonization:(
         T_tMCphase: TFCEdmtTaskPhasesColonization;
         T_tMCorigin: TFCEdmtTaskTargets;
         T_tMCoriginIndex: integer;
         T_tMCdestination: TFCEdmtTaskTargets;
         T_tMCdestinationIndex: integer;
         T_tMCdestinationRegion: integer;
         T_tMCcolonyName: string[20];
         T_tMCsettlementName: string[20];
         T_tMCsettlementType: TFCEdgSettlements;
         ///<summary>
         ///   final velocity, if 0 then = cruise velocity
         ///</summary>
         T_tMCfinalVelocity: extended;
         ///<summary>
         ///   deceleration time in ticks
         ///</summary>
         T_tMCfinalTime: integer;
         ///<summary>
         ///   used reaction mass volume for the complete task
         ///</summary>
         T_tMCusedReactionMassVol: extended;

         T_tMCinProcessData: record
            ///<summary>
            ///   acceleration by tick for the current mission
            ///</summary>
            IPD_accelerationByTick: extended;
            ///<summary>
            ///   time in tick for deceleration
            ///</summary>
            IPD_timeForDeceleration: integer;
         end;
         );

      tMissionInterplanetaryTransit:(
         T_tMITphase: TFCEdmtTaskPhasesInterplanetaryTransit;
         T_tMITorigin: TFCEdmtTaskTargets;
         T_tMIToriginIndex: integer;
         T_tMITdestination: TFCEdmtTaskTargets;
         T_tMITdestinationIndex: integer;
         ///<summary>
         ///   cruise velocity to reach , if 0 then =current deltav
         ///</summary>
         T_tMITcruiseVelocity: extended;
         ///<summary>
         ///   time to accelerate to the cruise velocity to reach
         ///</summary>
         T_tMITcruiseTime: integer;
         ///<summary>
         ///   final velocity, if 0 then = cruise velocity
         ///</summary>
         T_tMITfinalVelocity: extended;
         ///<summary>
         ///   deceleration time in ticks
         ///</summary>
         T_tMITfinalTime: integer;
         ///<summary>
         ///   used reaction mass volume for the complete task
         ///</summary>
         T_tMITusedReactionMassVol: extended;

         T_tMITinProcessData: record
            ///<summary>
            ///   acceleration by tick for the current mission
            ///</summary>
            IPD_accelerationByTick: extended;
            ///<summary>
            ///   time in tick for deceleration
            ///</summary>
            IPD_timeForDeceleration: integer;
            ///<summary>
            ///   time to transfert from a phase to an another
            ///</summary>
            IPD_timeToTransfert: integer;
         end;
         );

end; //==END== type TFCRtaskItem = record ==//
   TFCDdmtTaskListInProcess = array of TFCRdmtTask;
   TFCDdmtTaskListToProcess = array of TFCRdmtTask;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
var
   FCDdmtTaskListInProcess: TFCDdmtTaskListInProcess;

   FCDdmtTaskListToProcess: TFCDdmtTaskListToProcess;

//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

implementation

//uses

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

end.
