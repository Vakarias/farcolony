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

//uses

{task action type list}
   {:DEV NOTES: update: FCMgMCore_Mission_Setup + FCMgMCore_Mission_Commit + FCMgMCore_Mission_TrackUpd + FCMspuF_SpUnit_Remove.}
   {:DEV NOTES: update: FCFspuF_Mission_GetMissName.}
   type TFCEtaskActionTp=(
      {space unit - mission - colonization}
      tatpMissColonize
      {space unit - mission - interplanetary transit}
      ,tatpMissItransit
      ,tatpDummy
      );
   {.task phases}
   {:DEV NOTES: update: FCFspuF_Mission_GetPhaseName.}
   type TFCEtaskPhase=(
      tpAccel
      ,tpCruise
      ,tpDecel
      ,tpAtmEnt
      ,tpDone
      ,tpTerminated
      );
   {task target type list}
   type TFCEtaskTargetTp=(
      {infrastructure}
      tttInfrast
      {space unit}
      ,tttSpaceUnit
      {orbital object}
      ,tttOrbObj
      ,tttSat
      ,tttSpace
      );

//==END PUBLIC ENUM=========================================================================

{.task item data structure}
   {DEV NOTE: for TFCGtasklistToProc don't forget to update farc_game_missioncore /FCMgMCore_Mission_Commit.}
   {DEV NOTE: for TFCGtasklistInProc don't forget to update farc_game_gameflow /FCMgTFlow_GameTimer_Process + FCMgGFlow_Tasks_Process.}
   {DEV NOTE: don't forget to update farc_data_files / FCMdFiles_Game_Save/Load.}
   type TFCRdgTask = record
      {indicate that the task is in processing }
      {:DEV NOTES: TO DEL.}
      TITP_enabled: boolean;
      {type of action}
      TITP_actionTp: TFCEtaskActionTp;
      {current phase}
      TITP_phaseTp: TFCEtaskPhase;
      {controlled target type}
      TITP_ctldType: TFCEtaskTargetTp;
      {controlled target's faction number, 0=player}
      TITP_ctldFac: integer;
      {controlled target's index in subdata structure}
      TITP_ctldIdx: integer;
      {.timer tick at start of the mission}
      {:DEV NOTES: taskinprocONLY.}
      TITP_timeOrg: integer;
      {task duration in ticks, 0= infinite}
      TITP_duration: integer;
      {interval, in clock tick, between 2 running processes in same thread}
      TITP_interval: integer;
      {kind of origin}
      TITP_orgType: TFCEtaskTargetTp;
      {origin index (OBJECT)}
      TITP_orgIdx: integer;
      {kind of destination}
      TITP_destType: TFCEtaskTargetTp;
      {destination index (OBJECT)}
      TITP_destIdx: integer;
      {.targeted region #}
      TITP_regIdx: integer;
      {cruise velocity to reach , if 0 then =current deltav}
      TITP_velCruise: extended;
      {acceleration time in ticks}
      TITP_timeToCruise: integer;
      {.time in tick for deceleration}
      {:DEV NOTES: taskinprocONLY.}
      TITP_timeDecel: integer;
      {.time to transfert}
      {:DEV NOTES: taskinprocONLY.}
      TITP_time2xfert: integer;
      {.time to transfert to decel}
      {:DEV NOTES: taskinprocONLY.}
      TITP_time2xfert2decel: integer;
      {final velocity, if 0 then = cruise vel}
      TITP_velFinal: extended;
      {deceleration time in ticks}
      TITP_timeToFinal: integer;
      {.acceleration by tick for the current mission}
      {:DEV NOTES: taskinprocONLY.}
      TITP_accelbyTick: extended;
      {used reaction mass volume for the complete task}
      TITP_usedRMassV: extended;
      {.data string 1 for needed data transferts}
      TITP_str1: string;
      {.data string 2 for needed data transferts}
      TITP_str2: string;
      {.data integer 1 for needed data transferts}
      TITP_int1: integer;
   end; //==END== type TFCRtaskItem = record ==//
      {.tasklist to process dynamic array}
      TFCGtasklistToProc = array of TFCRdgTask;
      {.current tasklit dynamic array}
      TFCGtasklistInProc = array of TFCRdgTask;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
var
   {.tasklist in process}
      FCGtskListInProc: TFCGtasklistInProc;
      {.tasklist to process}
      FCGtskLstToProc: TFCGtaskListToProc;

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
