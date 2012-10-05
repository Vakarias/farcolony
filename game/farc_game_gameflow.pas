{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: game timer flow processing

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

unit farc_game_gameflow;

interface

uses
   SysUtils;

    {time phases}
   type TFCEtimePhases=(
      {.null data}
      tphNull
      {.reset the time flow}
//      ,tphRESET
      {tactical, 1secRT eq 10minGT}
      ,tphTac
      {management, time accelerated by 2}
      ,tphMan
      {strategical/historical, time accelerated by 10}
      ,tphSTH
      {game paused}
      ,tphPAUSE
      {.game paused w/o interface}
      ,tphPAUSEwo
      );

///<summary>
///   process the space units tasks. Replace the multiple threads creation.
///</summary>
procedure FCMgGFlow_Tasks_Process;

///<summary>
///   set the game flow speed
///</summary>
///    <param name="FSSstate">flow state type</param>
procedure FCMgTFlow_FlowState_Set(FSSstate: TFCEtimePhases);

///<summary>
///   gametimer flow processing routine
///</summary>
procedure FCMgGF_GameTimer_Process;

var
   GGFnewTick
   ,GGFoldTick: integer;

implementation



uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_init
   ,farc_data_missionstasks
   ,farc_data_univ
   ,farc_game_cps
   ,farc_game_csm
   ,farc_data_game
   ,farc_game_prod
   ,farc_game_spm
   ,farc_game_tasksystem
   ,farc_main
   ,farc_missions_colonization
   ,farc_ogl_viewmain
   ,farc_ogl_ui
   ,farc_spu_functions
   ,farc_ui_coldatapanel
   ,farc_ui_msges
   ,farc_ui_win
   ,farc_univ_func
   ,farc_win_debug;



var
   {:DEV NOTES: put these in method's data.}
//   GGFisProdPhaseSwitch
//   ,
   GGFisSPMphasePassed: boolean;



//=============================================END OF INIT==================================

procedure FCMgTFlow_CSMphase_Proc(CSMPPmax: integer);
{:Purpose: process the CSM phase list
   Additions:
      -2011Jul24- *rem: the colony data display update is removed because it's already updated if needed (useless).
      -2011May24- *mod: use a private variable instead of a tag for the colony index.
      -2011Jan25- *fix: correctly update the colony data panel, if it display the current colony, after the CSM phase process.
      -2010Sep16- *add: entities code.
      -2010Aug30- *add: update the COL_csmtime + the CSMT_tick when colonies of all factions of a specified tick are all processed.
}
var
   CSMPPcnt
   ,CSMPPcol
   ,CSMPPfacCnt
   ,CSMPPsubCnt
   ,CSMPPsubMax
   ,CSMPPtickNew: integer;
begin
   FCWinMain.FCGLScadencer.Enabled:=false;
   CSMPPcnt:=1;
   while CSMPPcnt<=CSMPPmax do
   begin
      if FCDdgCSMPhaseSchedule[CSMPPcnt].CSMPS_ProcessAtTick=FCVdgPlayer.P_currentTimeTick
      then
      begin
         CSMPPtickNew:=FCVdgPlayer.P_currentTimeTick+FCCdgWeekInTicks;
         CSMPPfacCnt:=0;
         while CSMPPfacCnt<FCCdiFactionsMax do
         begin
            CSMPPsubMax:=length(FCDdgCSMPhaseSchedule[CSMPPcnt].CSMPS_colonies[CSMPPfacCnt])-1;
            if CSMPPsubMax>0
            then
            begin
               CSMPPsubcnt:=1;
               while CSMPPsubCnt<=CSMPPsubmax do
               begin
                  CSMPPcol:=FCDdgCSMPhaseSchedule[CSMPPcnt].CSMPS_colonies[CSMPPfacCnt, CSMPPsubcnt];
                  FCMgCSM_Phase_Proc(CSMPPfacCnt, CSMPPcol);
                  FCDdgEntities[CSMPPfacCnt].E_colonies[CSMPPcol].C_nextCSMsessionInTick:=CSMPPtickNew;
                  inc(CSMPPsubcnt);
               end;
            end;
            inc(CSMPPfacCnt);
         end;
         FCDdgCSMPhaseSchedule[CSMPPcnt].CSMPS_ProcessAtTick:=CSMPPtickNew;
         break;
      end //==END== if FCGcsmPhList[CSMPPcnt].CSMT_tick=FCRplayer.P_timeTick ==//
      else inc(CSMPPcnt);
   end; //==END== while CSMPPcnt<=CSMPPmax do ==//
   FCWinMain.FCGLScadencer.Enabled:=true;
end;

procedure FCMgTFlow_FlowState_Set(FSSstate: TFCEtimePhases);
{:Purpose: set the game flow speed.
    Additions:
      -2011Jan06- *add: a reset state for reset the game flow.
      -2010Jul04- *fix: correct the routine when it end the pause.
      -2010Jun10- *mod: FSSstoreState is deprecated + complete routine revamp.
                  *add: take tphPAUSEwo in account.
}
begin
//   if FSSstate=tphRESET
//   then
//   begin
//      GGFisSPMphasePassed:=false;
//      FSSstate:=tphTac;
//   end;
   if (FSSstate=tphPAUSE)
      or (FSSstate=tphPAUSEwo)
   then
   begin
      FCVdiGameFlowTimer.Enabled:=false;
      FCWinMain.FCGLScadencer.Enabled:=false;
      FCVdgTimePhase:=FCVdgPlayer.P_currentTimePhase;
      FCVdgPlayer.P_currentTimePhase:=FSSstate;
   end
   else
   begin
      if FCVdiGameFlowTimer.Enabled=false
      then
      begin
         FCVdiGameFlowTimer.Enabled:=true;
         FCWinMain.FCGLScadencer.Enabled:=true;
         FCVdgPlayer.P_currentTimePhase:=FCVdgTimePhase;
      end
      else
      begin
         FCVdgPlayer.P_currentTimePhase:=FSSstate;
         case FSSstate of
            tphTac: FCVdiGameFlowTimer.Interval:=1000;
            tphMan: FCVdiGameFlowTimer.Interval:=500;
            tphSTH: FCVdiGameFlowTimer.Interval:=100;
         end;
      end;
   end;
end;

function FCFgTFlow_GameTimer_DayMthGet: integer;
{:Purpose: give the maximum number of days regarding the current month.
    Additions:
}
begin
   case FCVdgPlayer.P_currentTimeMonth of
      1: Result:=31;
      2: Result:=28;
      3: Result:=31;
      4: Result:=30;
      5: Result:=31;
      6: Result:=30;
      7: Result:=31;
      8: Result:=31;
      9: Result:=30;
      10: Result:=31;
      11: Result:=30;
      12: Result:=31;
   end;
end;

procedure FCMgGFlow_Tasks_Process;
{:Purpose: process the space units tasks. Replace the multiple threads creation.
    Additions:
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
                        FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_deltaV:=FCFcFunc_Rnd(
                           cfrttpVelkms
                           ,GTPspUnVel
                           );
                        GTPmove:=FCFcFunc_ScaleConverter(
                           cf3dctVelkmSecTo3dViewUnit
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
                     if FC3doglSpaceUnits[FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_linked3dObject].Visible
                     then
                     begin
                        FC3doglSpaceUnits[FCDdgEntities[GTPfac].E_spaceUnits[GTPspuOwn].SU_linked3dObject].Visible:=false;
                        if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCorigin=ttSpaceUnitDockedIn
                        then
                        begin
                           FC3doglSelectedSpaceUnit:=FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCoriginIndex;
                           FCMoglVM_CamMain_Target(-1, true);
                        end
                        else if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCorigin=ttSpace
                        then
                        begin
                           if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestination=ttOrbitalObject
                           then FCMoglVM_CamMain_Target(FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestinationIndex, true)
                           else if FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestination=ttSatellite
                           then
                           begin
                              FC3doglSelectedSatellite:=FC3doglSatellitesObjectsGroups[FCDdmtTaskListInProcess[GTPtaskIdx].T_tMCdestinationIndex].Tag;
                              FCMoglVM_CamMain_Target(100, true);
                           end
                        end;
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
                           :=FCFcFunc_Rnd(
                              cfrttpVelkms
                              ,GTPspUnVel
                              );
                        GTPmove:=FCFcFunc_ScaleConverter(
                           cf3dctVelkmSecTo3dViewUnit
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
                           :=FCFcFunc_Rnd(
                              cfrttpVelkms
                              ,GTPspUnVel
                              );
                        GTPmove:=FCFcFunc_ScaleConverter(
                           cf3dctVelkmSecTo3dViewUnit
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
                              :=FCFcFunc_Rnd(
                                 cfrttpVelkms
                                 ,GTPspUnVel
                                 );
                           GTPmove:=FCFcFunc_ScaleConverter(
                              cf3dctVelkmSecTo3dViewUnit
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
                              :=FCFcFunc_Rnd(
                                 cfrttpVelkms
                                 ,GTPspUnVel
                                 );
                           GTPmove:=FCFcFunc_ScaleConverter(
                              cf3dctVelkmSecTo3dViewUnit
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
                              :=FCFcFunc_Rnd(
                                 cfrttpVelkms
                                 ,GTPspUnVel
                                 );
                           GTPmove:=FCFcFunc_ScaleConverter(
                              cf3dctVelkmSecTo3dViewUnit
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
                           :=FCFcFunc_Rnd(
                              cfrttpVelkms
                              ,GTPspUnVel
                              );
                           GTPmove:=FCFcFunc_ScaleConverter(
                              cf3dctVelkmSecTo3dViewUnit
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
                        FCMoglVM_CamMain_Target(-1, true);
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

procedure FCMgGF_GameTimer_Process;
{:Purpose: gametimer flow processing routine.
    Additions:
      -2012Oct03- *mod: put the code about the initialization of the list of tasks to process into its proper unit.
      -2012May21- *add: trigger the segment 3 of the production phase only when a day passed.
      -2011Jul06- *code: put the CSM phase before the SPM phase.
                  *add: production phase link and activation.
      -2011Apr20- *fix: update the CPS only if it's enabled.
      -2010Jan06- *add: a watchdog to avoid to trigger the SPM phase multiple times in day 1 of each month.
      -2010Dec28- *add: SPM phase.
      -2010Jul23- *add: CSM phase.
      -2010Jun15- *mod: set non-bounded stellar system/star location.
      -2010Jun11- *add: delete terminated tasks.
      -2010Jun10- *add: trigger FCM_EndPhase_Proc when CPS reach the end.
      -2010May11- *fix: fix a calculation bug for interplanetary transit mission.
      -2010May10- *add: interplanetary transit mission initialization.
      -2010May04- *rem: delete critical section for time updating
                  *add: complete colonization mission initialization
      -2010May03- *fix/mod: remove any thread initialization/termination code.
                  *add: initialize colonization mission task (taken from the thread code.
      -2010Apr28- *fix/mod: thread termination and cleanup.
      -2010Apr19- *fix: when initialize a new task, put the correct mission type.
      -2010Mar23- *add: update CPS time left if required.
      -2010Jan08- *mod: change gameflow state method according to game flow changes.
      -2009Nov30- *task processing: add thread index in FCGtskListInProc.
      -2009Nov04- *free terminated threads from the array by a crude but safe method.
      -2009Oct28- *take FCGTimePhase / time phases in account.
      -2009Oct26- *update the thread creation by including time tick at creation.
      -2009Oct25- *change the basic time frame in accordance to the last update.
                  *process new task.
      -2009Oct15- *implement a test time acceleration.
      -2009Sep27- *implement a test thread.
      -2009Sep24- *include critical section for protect data, because the  game timer is
                  threaded.
}
   var
      GTPcnt

      ,GTPmaxDayMonth

      ,GTPphLmax


      ,GTPssys
      ,GTPstar

      : integer;

      isProdPhaseSwitch
      ,isSegment3Switch
      ,GTPendPh: boolean;
begin
   isProdPhaseSwitch:=false;
   isSegment3Switch:=false;
   {.time updating}
   inc(FCVdgPlayer.P_currentTimeTick);
   GGFnewTick:=FCVdgPlayer.P_currentTimeTick;
   if FCVdgPlayer.P_currentTimeMinut<50
   then FCVdgPlayer.P_currentTimeMinut:=FCVdgPlayer.P_currentTimeMinut+10
   else if FCVdgPlayer.P_currentTimeMinut>=50
   then
   begin
      FCVdgPlayer.P_currentTimeMinut:=0;
      isProdPhaseSwitch:=true;
      if FCVdgPlayer.P_currentTimeHour<23
      then inc(FCVdgPlayer.P_currentTimeHour)
      else
      begin
         FCVdgPlayer.P_currentTimeHour:=0;
         isSegment3Switch:=true;
         GTPmaxDayMonth:=FCFgTFlow_GameTimer_DayMthGet;
         if FCVdgPlayer.P_currentTimeDay<GTPmaxDayMonth
         then inc(FCVdgPlayer.P_currentTimeDay)
         else
         begin
            FCVdgPlayer.P_currentTimeDay:=1;
            if FCVdgPlayer.P_currentTimeMonth<11
            then inc(FCVdgPlayer.P_currentTimeMonth)
            else
            begin
               FCVdgPlayer.P_currentTimeMonth:=1;
               inc(FCVdgPlayer.P_currentTimeYear);
            end;
         end;
      end;
   end;
   FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutTime);
   {.production phase}
   if isProdPhaseSwitch
   then
   begin
      FCMgP_PhaseCore_Process(isSegment3Switch);
      isProdPhaseSwitch:=false;
   end;
   {.CSM phase}
   GTPphLmax:=length(FCDdgCSMPhaseSchedule)-1;
   if GTPphLmax>0
   then FCMgTFlow_CSMphase_Proc(GTPphLmax);
   {.SPM phase}
   if (FCVdgPlayer.P_currentTimeDay=1)
      and (FCVdgPlayer.P_currentTimeTick>144)
      and (not GGFisSPMphasePassed)
   then
   begin
      FCMgSPM_Phase_Proc;
      GGFisSPMphasePassed:=true;
   end
   else if (FCVdgPlayer.P_currentTimeDay>1)
      and (GGFisSPMphasePassed)
   then GGFisSPMphasePassed:=false;
   {.update CPS time left and process the end of colonization phase if needed}
   if Assigned(FCcps)
      and (FCcps.CPSisEnabled)
   then
   begin
      GTPendPh:=FCcps.FCF_TimeLeft_Upd;
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutCPS);
      if GTPendPh
      then FCcps.FCM_EndPhase_Proc;
   end;
   FCMgTS_TaskInProcess_Cleanup;
   FCMgTS_TaskToProcess_Initialize( GGFnewTick );
end;

end.
