{======(C) Copyright Aug.2009-2014 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: game flow - core unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2014, Jean-Francois Baconnet

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
type TFCEggfRealTimeAccelerations=(
//addonREM: put x1 / x2 / x5 / x10 perhaps x20 or 100 too (test the load first)
   {tactical, 1secRT eq 10minGT}
   rtaX1
   {management, time accelerated by 2}
   ,rtaX2
   {strategical/historical, time accelerated by 10}
   ,rtaX5
   ,rtaX10
   {game paused}
   ,rtaPause
   {.game paused w/o interface}
   ,rtaPauseWOinterface
   );

type TFCEggfTurnTypes=(
   ttTacticalTurn
   ,ttIndustrialTurn
   ,ttUpkeepTurn
   ,ttColonialTurn
   ,ttHistoricalTurn
   );

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
var
   GGFnewTick
   ,GGFoldTick: integer;

//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================


//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   gametimer flow processing routine
///</summary>
procedure FCMgGF_GameTimer_Process;

///<summary>
///   pause the game flow, if the game is in realtime mode
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgGF_Realtime_Pause;

///<summary>
///   restore the game flow, if the game is in realtime mode
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgGF_RealTime_Restore;

///<summary>
///   switch into realtime
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgGF_RealTime_SwitchTo;

///<summary>
///   set the realtime game flow speed
///</summary>
procedure FCMgGF_RealTimeFlowSpeed_Set;

///<summary>
///   decrement the time speed of turn type, depending if the game is in realtime or turn-based
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgGF_TimeSpeedTurnType_Decrement;

///<summary>
///   increment the time speed of turn type, depending if the game is in realtime or turn-based
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgGF_TimeSpeedTurnType_Increment;

///<summary>
///   core procedure to process one turn, depending of its specified type
///</summary>
///   <param name="TypeOfGameTurnToApply">type of game turn to apply</param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgGF_TurnBasedSubSystem_Process( const TypeOfGameTurnToApply: TFCEggfTurnTypes );

///<summary>
///   switch into turn-based
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgGF_TurnBased_SwitchTo;

///<summary>
///
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgGF_TypeOfTimeFlow_Init;

///<summary>
///
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgGF_TypeOfTimeFlow_SwitchMode;

implementation

uses
   farc_common_func
   ,farc_data_init
   ,farc_game_cps
   ,farc_game_csm
   ,farc_data_game
   ,farc_game_prod
   ,farc_game_spm
   ,farc_game_tasksystem
   ,farc_main
   ,farc_ogl_ui
   ,farc_survey_core
   ,farc_ui_win
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   GGFisSPMphasePassed: boolean;



//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFgGF_DaysInMonth_Get: integer;
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

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgGF_CSMphase_Process(CSMPPmax: integer);
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

procedure FCMgGF_GameTimer_Process;
{:Purpose: gametimer flow processing routine.
    Additions:
      -2013Mar26- *add: add the planetary survey system.
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
      ,isSegment3_PlanetarySurveySwitch
      ,GTPendPh: boolean;
begin
   isProdPhaseSwitch:=false;
   isSegment3_PlanetarySurveySwitch:=false;
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
         isSegment3_PlanetarySurveySwitch:=true;
         GTPmaxDayMonth:=FCFgGF_DaysInMonth_Get;
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
   FCMoglUI_CoreUI_Update(ptuTextsOnly, ttuTimeFlow);
   {.planetary survey}
   if isSegment3_PlanetarySurveySwitch
   then FCMsC_ResourceSurvey_Core;
   {.production phase}
   if isProdPhaseSwitch
   then
   begin
      FCMgP_PhaseCore_Process(isSegment3_PlanetarySurveySwitch);
      isProdPhaseSwitch:=false;
   end;
   {.CSM phase}
   GTPphLmax:=length(FCDdgCSMPhaseSchedule)-1;
   if GTPphLmax>0
   then FCMgGF_CSMphase_Process(GTPphLmax);
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
      FCMoglUI_CoreUI_Update(ptuTextsOnly, ttuCPS);
      if GTPendPh
      then FCcps.FCM_EndPhase_Proc;
   end;
   FCMgTS_TaskInProcess_Cleanup;
   FCMgTS_TaskToProcess_Initialize( GGFnewTick );
end;

procedure FCMgGF_Realtime_Pause;
{:Purpose: pause the game flow, if the game is in realtime mode.
    Additions:
}
begin
   if not FCVdgPlayer.P_isTurnBased then
   begin
      FCVdiGameFlowTimer.Enabled:=false;
      FCWinMain.FCGLScadencer.Enabled:=false;
      FCVdgPlayer.P_currentRealTimeAcceleration:=rtaPause;
   end;
end;

procedure FCMgGF_RealTime_Restore;
{:Purpose: restore the game flow, if the game is in realtime mode.
    Additions:
}
begin
   if not FCVdgPlayer.P_isTurnBased then
   begin
      if not FCVdiGameFlowTimer.Enabled then
      begin
         FCVdiGameFlowTimer.Enabled:=true;
         FCWinMain.FCGLScadencer.Enabled:=true;
      end;
      FCVdgPlayer.P_currentRealTimeAcceleration:=rtaX1;
      FCMgGF_RealTimeFlowSpeed_Set;
   end;
end;

procedure FCMgGF_RealTime_SwitchTo;
{:Purpose: switch into realtime.
    Additions:
}
begin
   FCVdgPlayer.P_isTurnBased:=false;
   FCVdiGameFlowTimer.Enabled:=true;
   FCWinMain.FCGLScadencer.Enabled:=true;
   FCVdgPlayer.P_currentRealTimeAcceleration:=rtaX1;
   FCMgGF_RealTimeFlowSpeed_Set;
end;

procedure FCMgGF_RealTimeFlowSpeed_Set;
{:Purpose: set the realtime game flow speed.
    Additions:
      -2014Feb02- *add/mod: overhaul of the time acceleration.
      -2011Jan06- *add: a reset state for reset the game flow.
      -2010Jul04- *fix: correct the routine when it end the pause.
      -2010Jun10- *mod: FSSstoreState is deprecated + complete routine revamp.
                  *add: take tphPAUSEwo in account.
}
begin
   case FCVdgPlayer.P_currentRealTimeAcceleration of
      rtaX1: FCVdiGameFlowTimer.Interval:=1000;

      rtaX2: FCVdiGameFlowTimer.Interval:=500;

      rtaX5: FCVdiGameFlowTimer.Interval:=200;

      rtaX10: FCVdiGameFlowTimer.Interval:=100;
   end;
end;

procedure FCMgGF_TimeSpeedTurnType_Decrement;
{:Purpose: decrement the time speed of turn type, depending if the game is in realtime or turn-based.
    Additions:
}
begin
   if ( FCVdgPlayer.P_isTurnBased )
      and ( FCVdgPlayer.P_currentTypeOfTurn > ttTacticalTurn ) then
   begin
      dec( FCVdgPlayer.P_currentTypeOfTurn );
      FCMoglUI_CoreUI_Update( ptuTextsOnly, ttuTimeFlow );
   end
   else if ( not FCVdgPlayer.P_isTurnBased )
      and ( FCVdgPlayer.P_currentRealTimeAcceleration > rtaX1 ) then
   begin
      dec( FCVdgPlayer.P_currentRealTimeAcceleration );
      FCMgGF_RealTimeFlowSpeed_Set;
   end;
end;

procedure FCMgGF_TimeSpeedTurnType_Increment;
{:Purpose: increment the time speed of turn type, depending if the game is in realtime or turn-based.
    Additions:
}
begin
   if ( FCVdgPlayer.P_isTurnBased )
      and ( FCVdgPlayer.P_currentTypeOfTurn < ttHistoricalTurn ) then
   begin
      inc( FCVdgPlayer.P_currentTypeOfTurn );
      FCMoglUI_CoreUI_Update( ptuTextsOnly, ttuTimeFlow );
   end
   else if ( not FCVdgPlayer.P_isTurnBased )
      and ( FCVdgPlayer.P_currentRealTimeAcceleration < rtaX10 ) then
   begin
      inc( FCVdgPlayer.P_currentRealTimeAcceleration );
      FCMgGF_RealTimeFlowSpeed_Set;
   end;
end;

procedure FCMgGF_TurnBasedSubSystem_Process( const TypeOfGameTurnToApply: TFCEggfTurnTypes );
{:Purpose: core procedure to process one turn, depending of its specified type.
    Additions:
}
   var
      Count
      ,TicksToProcess: integer;
begin
   Count:=0;
   TicksToProcess:=0;
   case TypeOfGameTurnToApply of
      ttTacticalTurn: TicksToProcess:=1;

      ttIndustrialTurn: TicksToProcess:=6;

      ttUpkeepTurn: TicksToProcess:=144;

      ttColonialTurn: TicksToProcess:=1008;

      ttHistoricalTurn:
      begin
         Count:=FCFgGF_DaysInMonth_Get;
         case Count of
            28: TicksToProcess:=4032;

            30: TicksToProcess:=4320;

            31: TicksToProcess:=4464;
         end;
      end;
   end;
   while TicksToProcess > 0 do
   begin
      FCMgGF_GameTimer_Process;
      dec( TicksToProcess );
   end;
end;

procedure FCMgGF_TurnBased_SwitchTo;
{:Purpose: switch into turn-based.
    Additions:
}
begin
   FCVdgPlayer.P_isTurnBased:=true;
   FCVdiGameFlowTimer.Enabled:=false;
//   FCWinMain.FCGLScadencer.Enabled:=false;
   FCVdgPlayer.P_currentTypeOfTurn:=ttTacticalTurn;
end;

procedure FCMgGF_TypeOfTimeFlow_Init;
{:Purpose: .
    Additions:
}
begin
   if FCVdgPlayer.P_isTurnBased
   then FCMgGF_TurnBased_SwitchTo
   else FCMgGF_RealTime_SwitchTo;
   FCMuiW_UI_Initialize( mwupMenuRTturnBased );
end;

procedure FCMgGF_TypeOfTimeFlow_SwitchMode;
{:Purpose: .
    Additions:
}
begin
   if FCVdgPlayer.P_isTurnBased
   then FCMgGF_RealTime_SwitchTo
   else FCMgGF_TurnBased_SwitchTo;
   FCMuiW_UI_Initialize( mwupMenuRTturnBased );
end;

end.
