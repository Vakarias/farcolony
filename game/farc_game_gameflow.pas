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
   ,farc_game_micolonize
   ,farc_game_prod
   ,farc_game_spm
   ,farc_main
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
      if FCGcsmPhList[CSMPPcnt].CSMT_tick=FCRplayer.P_timeTick
      then
      begin
         CSMPPtickNew:=FCRplayer.P_timeTick+FCCwkTick;
         CSMPPfacCnt:=0;
         while CSMPPfacCnt<FCCdiFactionsMax do
         begin
            CSMPPsubMax:=length(FCGcsmPhList[CSMPPcnt].CSMT_col[CSMPPfacCnt])-1;
            if CSMPPsubMax>0
            then
            begin
               CSMPPsubcnt:=1;
               while CSMPPsubCnt<=CSMPPsubmax do
               begin
                  CSMPPcol:=FCGcsmPhList[CSMPPcnt].CSMT_col[CSMPPfacCnt, CSMPPsubcnt];
                  FCMgCSM_Phase_Proc(CSMPPfacCnt, CSMPPcol);
                  FCentities[CSMPPfacCnt].E_col[CSMPPcol].COL_csmtime:=CSMPPtickNew;
                  inc(CSMPPsubcnt);
               end;
            end;
            inc(CSMPPfacCnt);
         end;
         FCGcsmPhList[CSMPPcnt].CSMT_tick:=CSMPPtickNew;
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
      FCGtimePhase:=FCRplayer.P_timePhse;
      FCRplayer.P_timePhse:=FSSstate;
   end
   else
   begin
      if FCVdiGameFlowTimer.Enabled=false
      then
      begin
         FCVdiGameFlowTimer.Enabled:=true;
         FCWinMain.FCGLScadencer.Enabled:=true;
         FCRplayer.P_timePhse:=FCGtimePhase;
      end
      else
      begin
         FCRplayer.P_timePhse:=FSSstate;
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
   case FCRplayer.P_timeMth of
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
  ,GTPthreadIdx: integer;

  GTPmove
  ,GTPspUnVel: extended;

  GTPendPh: boolean;
begin
   GTPnumTaskInProc:=length(FCGtskListInProc)-1;
   if GTPnumTaskInProc>0
   then
   begin
      GTPtaskIdx:=1;
      while GTPtaskIdx<=GTPnumTaskInProc do
      begin
         if (FCGtskListInProc[GTPtaskIdx].TITP_phaseTp<>tpTerminated)
         then
         begin
            GTPfac:=FCGtskListInProc[GTPtaskIdx].TITP_ctldFac;
            GTPspuOwn:=FCGtskListInProc[GTPtaskIdx].TITP_ctldIdx;
            case FCGtskListInProc[GTPtaskIdx].TITP_actionTp of
               {.mission - colonization}
               tatpMissColonize:
               begin
                  {.deceleration phase}
                  if (GGFnewTick>GGFoldTick)
                     and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpDecel)
                  then
                  begin
                     if GGFnewTick>=FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeDecel
                     then
                     begin
                        GTPspUnVel:=FCGtskListInProc[GTPtaskIdx].TITP_velFinal;
                        FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpAtmEnt;
                     end
                     else if GGFnewTick<FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeDecel
                     then
                     begin
                        GTPspUnVel
                           :=FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV-(FCGtskListInProc[GTPtaskIdx].TITP_accelbyTick*(GGFnewTick-GGFoldTick));
                        FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV:=FCFcFunc_Rnd(
                           cfrttpVelkms
                           ,GTPspUnVel
                           );
                        GTPmove:=FCFcFunc_ScaleConverter(
                           cf3dctVelkmSecTo3dViewUnit
                           ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                           );
                        FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dmove:=GTPmove;
                     end;
                  end; //==END== if (GGFnewTick>GGFoldTick) and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpDecel) ==//
                  {.atmospheric entry phase}
                  if (GGFnewTick>GGFoldTick)
                     and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpAtmEnt)
                  then
                  begin
                     if FC3doglSpaceUnits[FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dObjIdx].Visible
                     then
                     begin
                        FC3doglSpaceUnits[FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dObjIdx].Visible:=false;
                        if FCGtskListInProc[GTPtaskIdx].TITP_orgType=tttSpaceUnit
                        then
                        begin
                           FC3doglSelectedSpaceUnit:=FCGtskListInProc[GTPtaskIdx].TITP_orgIdx;
                           FCMoglVM_CamMain_Target(-1, true);
                        end
                        else if FCGtskListInProc[GTPtaskIdx].TITP_orgType=tttSpace
                        then
                        begin
                           if FCGtskListInProc[GTPtaskIdx].TITP_destType=tttOrbObj
                           then FCMoglVM_CamMain_Target(FCGtskListInProc[GTPtaskIdx].TITP_destIdx, true)
                           else if FCGtskListInProc[GTPtaskIdx].TITP_destType=tttSat
                           then
                           begin
                              FC3doglSelectedSatellite:=FC3doglSatellitesObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx].Tag;
                              FCMoglVM_CamMain_Target(100, true);
                           end
                        end;
                     end;
                     if GGFnewTick>=FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_duration
                     then FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpDone;
                  end;
                  if FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpDone
                  then
                  begin
                     {.unload the current task to the space unit}
                     FCentities[GTPfac].E_spU[GTPspuOwn].SUO_taskIdx:=0;
                     FCentities[GTPfac].E_spU[GTPspuOwn].SUO_status:=susLanded;
                     {.set the remaining reaction mass}
                     FCentities[GTPfac].E_spU[GTPspuOwn].SUO_availRMass
                        :=FCentities[GTPfac].E_spU[GTPspuOwn].SUO_availRMass-FCGtskListInProc[GTPtaskIdx].TITP_usedRMassV;
                     {.colonize mission post-process}
                     GTPssysDB:=FCFuF_StelObj_GetDbIdx(
                           ufsoSsys
                           ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_starSysLoc
                           ,0
                           ,0
                           ,0
                           );
                     GTPstarDB:=FCFuF_StelObj_GetDbIdx(
                        ufsoStar
                        ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_starLoc
                        ,GTPssysDB
                        ,0
                        ,0
                        );
                     GTPoobjDB:=0;
                     GTPsatDB:=0;
                     if FCGtskListInProc[GTPtaskIdx].TITP_destType=tttOrbObj
                     then
                     begin
                        GTPoobjDB:=FCGtskListInProc[GTPtaskIdx].TITP_destIdx;
                        FCMgC_Colonize_PostProc(
                           FCGtskListInProc[GTPtaskIdx].TITP_ctldFac
                           ,GTPspuOwn
                           ,GTPssysDB
                           ,GTPstarDB
                           ,FCGtskListInProc[GTPtaskIdx].TITP_destIdx
                           ,0
                           ,FCGtskListInProc[GTPtaskIdx].TITP_regIdx
                           ,FCGtskListInProc[GTPtaskIdx].TITP_int1
                           ,FCGtskListInProc[GTPtaskIdx].TITP_str1
                           ,FCGtskListInProc[GTPtaskIdx].TITP_str2
                           );
                     end
                     else if FCGtskListInProc[GTPtaskIdx].TITP_destType=tttSat
                     then
                     begin
                        GTPoobjDB:=round(FC3doglSatellitesObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx].TagFloat);
                        GTPsatDB:=FC3doglSatellitesObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx].Tag;
                        FCMgC_Colonize_PostProc(
                           FCGtskListInProc[GTPtaskIdx].TITP_ctldFac
                           ,GTPspuOwn
                           ,GTPssysDB
                           ,GTPstarDB
                           ,GTPoobjDB
                           ,GTPsatDB
                           ,FCGtskListInProc[GTPtaskIdx].TITP_regIdx
                           ,FCGtskListInProc[GTPtaskIdx].TITP_int1
                           ,FCGtskListInProc[GTPtaskIdx].TITP_str1
                           ,FCGtskListInProc[GTPtaskIdx].TITP_str2
                           );
                     end;
                     FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpTerminated;
                  end;
               end; //==END== case: tatpMissColonize ==//
               {.mission - interplanetary transit}
               tatpMissItransit:
               begin
                  if (GGFnewTick>GGFoldTick)
                     and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpAccel)
                  then
                  begin
                     if GGFnewTick=FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise
                     then FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpCruise
                     else if GGFnewTick>FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise
                     then
                     begin
                        FCGtskListInProc[GTPtaskIdx].TITP_time2xfert
                           :=GGFnewTick-(FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise);
                        GTPspUnVel
                           :=FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                                 +(
                                    FCGtskListInProc[GTPtaskIdx].TITP_accelbyTick
                                    *(GGFnewTick-GGFoldTick-FCGtskListInProc[GTPtaskIdx].TITP_time2xfert)
                                    );
                        FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                           :=FCFcFunc_Rnd(
                              cfrttpVelkms
                              ,GTPspUnVel
                              );
                        GTPmove:=FCFcFunc_ScaleConverter(
                           cf3dctVelkmSecTo3dViewUnit
                           ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                           );
                        FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dmove:=GTPmove;
                        FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpCruise;
                     end
                     else if GGFnewTick<FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise
                     then
                     begin
                        GTPspUnVel
                           :=FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                              +(FCGtskListInProc[GTPtaskIdx].TITP_accelbyTick*(GGFnewTick-GGFoldTick));
                        FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                           :=FCFcFunc_Rnd(
                              cfrttpVelkms
                              ,GTPspUnVel
                              );
                        GTPmove:=FCFcFunc_ScaleConverter(
                           cf3dctVelkmSecTo3dViewUnit
                           ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                           );
                        FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dmove:=GTPmove;
                     end;
                  end; //==END== if (GGFnewTick>GGFoldTick) and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpAccel) ==//
                  if (GGFnewTick>GGFoldTick)
                     and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpCruise)
                  then
                  begin
                     if FCGtskListInProc[GTPtaskIdx].TITP_time2xfert>0 then
                     begin
                        FCGtskListInProc[GTPtaskIdx].TITP_time2xfert2decel:=0;
                        if FCGtskListInProc[GTPtaskIdx].TITP_time2xfert+GGFoldTick
                           =FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise
                              +FCGtskListInProc[GTPtaskIdx].TITP_timeDecel
                        then
                        begin
                           FCGtskListInProc[GTPtaskIdx].TITP_time2xfert:=0;
                           FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpDecel;
                        end
                        else if FCGtskListInProc[GTPtaskIdx].TITP_time2xfert+GGFoldTick
                           >FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise
                              +FCGtskListInProc[GTPtaskIdx].TITP_timeDecel
                        then
                        begin
                           FCGtskListInProc[GTPtaskIdx].TITP_time2xfert2decel
                              :=(FCGtskListInProc[GTPtaskIdx].TITP_time2xfert+GGFoldTick)
                                 -(FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise
                              +FCGtskListInProc[GTPtaskIdx].TITP_timeDecel);
                           FCGtskListInProc[GTPtaskIdx].TITP_time2xfert:=0;
                           FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpDecel;
                        end;
                     end
                     else if FCGtskListInProc[GTPtaskIdx].TITP_time2xfert=0
                     then
                     begin
                        if GGFnewTick=FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise
                              +FCGtskListInProc[GTPtaskIdx].TITP_timeDecel
                        then FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpDecel
                        else if GGFnewTick>FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise
                              +FCGtskListInProc[GTPtaskIdx].TITP_timeDecel
                        then
                        begin
                           FCGtskListInProc[GTPtaskIdx].TITP_time2xfert2decel
                              :=GGFnewTick-(FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise
                              +FCGtskListInProc[GTPtaskIdx].TITP_timeDecel);
                           FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpDecel;
                        end;
                     end;
                  end; //==END== if (GGFnewTick>GGFoldTick) and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpCruise) ==//
                  if (GGFnewTick>GGFoldTick)
                     and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpDecel)
                  then
                  begin
                     if FCGtskListInProc[GTPtaskIdx].TITP_time2xfert2decel>0
                     then
                     begin
                        if FCGtskListInProc[GTPtaskIdx].TITP_time2xfert2decel+GGFoldTick
                           >=FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_duration
                        then
                        begin
                           GTPspUnVel:=FCGtskListInProc[GTPtaskIdx].TITP_velFinal;
                           FCGtskListInProc[GTPtaskIdx].TITP_time2xfert2decel:=0;
                           {.update data structure}
                           FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                              :=FCFcFunc_Rnd(
                                 cfrttpVelkms
                                 ,GTPspUnVel
                                 );
                           GTPmove:=FCFcFunc_ScaleConverter(
                              cf3dctVelkmSecTo3dViewUnit
                              ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                              );
                           FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dmove:=GTPmove;
                           FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpDone;
                        end
                        else if FCGtskListInProc[GTPtaskIdx].TITP_time2xfert2decel+GGFoldTick
                           <FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_duration
                        then
                        begin
                           GTPspUnVel
                              :=FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                                 -(FCGtskListInProc[GTPtaskIdx].TITP_accelbyTick*(FCGtskListInProc[GTPtaskIdx].TITP_time2xfert2decel));
                           FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                              :=FCFcFunc_Rnd(
                                 cfrttpVelkms
                                 ,GTPspUnVel
                                 );
                           GTPmove:=FCFcFunc_ScaleConverter(
                              cf3dctVelkmSecTo3dViewUnit
                              ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                              );
                           FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dmove:=GTPmove;
                           FCGtskListInProc[GTPtaskIdx].TITP_time2xfert2decel:=0;
                        end;
                     end
                     else if FCGtskListInProc[GTPtaskIdx].TITP_time2xfert2decel=0
                     then
                     begin
                        if GGFnewTick>=FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_duration
                        then
                        begin
                           GTPspUnVel:=FCGtskListInProc[GTPtaskIdx].TITP_velFinal;
                           FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                              :=FCFcFunc_Rnd(
                                 cfrttpVelkms
                                 ,GTPspUnVel
                                 );
                           GTPmove:=FCFcFunc_ScaleConverter(
                              cf3dctVelkmSecTo3dViewUnit
                              ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                              );
                           FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dmove:=GTPmove;
                           FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpDone;
                        end
                        else if GGFnewTick<FCGtskListInProc[GTPtaskIdx].TITP_timeOrg+FCGtskListInProc[GTPtaskIdx].TITP_duration
                        then
                        begin
                           GTPspUnVel
                              :=FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                                 -(FCGtskListInProc[GTPtaskIdx].TITP_accelbyTick*(GGFnewTick-GGFoldTick));
                           FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                           :=FCFcFunc_Rnd(
                              cfrttpVelkms
                              ,GTPspUnVel
                              );
                           GTPmove:=FCFcFunc_ScaleConverter(
                              cf3dctVelkmSecTo3dViewUnit
                              ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV
                              );
                           FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dmove:=GTPmove;
                        end;
                     end;
                  end; //==END== if (GGFnewTick>GGFoldTick) and(FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpDecel) ==//
                  if FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpDone
                  then
                  begin
                     {.unload the current task to the space unit}
                     FCentities[GTPfac].E_spU[GTPspuOwn].SUO_taskIdx:=0;
                     {.set the remaining reaction mass}
                     FCentities[GTPfac].E_spU[GTPspuOwn].SUO_availRMass
                        :=FCentities[GTPfac].E_spU[GTPspuOwn].SUO_availRMass-FCGtskListInProc[GTPtaskIdx].TITP_usedRMassV;
                     {.interplanetary transit mission post-process}
                     GTPssysDB:=FCFuF_StelObj_GetDbIdx(
                           ufsoSsys
                           ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_starSysLoc
                           ,0
                           ,0
                           ,0
                           );
                     GTPstarDB:=FCFuF_StelObj_GetDbIdx(
                        ufsoStar
                        ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_starLoc
                        ,GTPssysDB
                        ,0
                        ,0
                        );
                     GTPoobjDB:=0;
                     GTPsatDB:=0;
                     {.set orbit data for destination}
                     FCentities[GTPfac].E_spU[GTPspuOwn].SUO_status:=susInOrbit;
                     if FCGtskListInProc[GTPtaskIdx].TITP_destType=tttOrbObj
                     then
                     begin
                        GTPoobjDB:=FCGtskListInProc[GTPtaskIdx].TITP_destIdx;
                        FCentities[GTPfac].E_spU[GTPspuOwn].SUO_oobjLoc
                           :=FCDduStarSystem[GTPssysDB].SS_stars[GTPstarDB].S_orbitalObjects[FCGtskListInProc[GTPtaskIdx].TITP_destIdx].OO_dbTokenId;
                        FCentities[GTPfac].E_spU[FCGtskListInProc[GTPtaskIdx].TITP_ctldIdx].SUO_satLoc:='';
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
                     else if FCGtskListInProc[GTPtaskIdx].TITP_destType=tttSat
                     then
                     begin
                        GTPsatDB:=FC3doglSatellitesObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx].Tag;
                        GTPoobjDB:=round(FC3doglSatellitesObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx].TagFloat);
                        FCentities[GTPfac].E_spU[GTPspuOwn].SUO_oobjLoc:=FCDduStarSystem[GTPssysDB].SS_stars[GTPstarDB].S_orbitalObjects[GTPoobjDB].OO_dbTokenId;
                        FCentities[GTPfac].E_spU[GTPspuOwn].SUO_satLoc
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
                     GTPdckdVslMax:=length(FCentities[GTPfac].E_spU[GTPspuOwn].SUO_dockedSU);
                     if GTPdckdVslMax>1
                     then
                     begin
                        GTPdkcdCnt:=1;
                        while GTPdkcdCnt<=GTPdckdVslMax-1 do
                        begin
                           GTPdckdIdx:=FCFcFunc_SpUnit_getOwnDB(
                              GTPfac
                              ,FCentities[GTPfac].E_spU[GTPspuOwn].SUO_dockedSU[GTPdkcdCnt].SUD_dckdToken
                              );
                           FCentities[GTPfac].E_spU[GTPdckdIdx].SUO_deltaV:=FCentities[GTPfac].E_spU[GTPspuOwn].SUO_deltaV;
                           inc(GTPdkcdCnt);
                        end;
                     end;
                     FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dmove:=0;
                     FCMuiM_Message_Add(
                        mtInterplanTransit
                        ,0
                        ,GTPspuOwn
                        ,GTPoobjDB
                        ,GTPsatDB
                        ,0
                        );
                     if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dObjIdx]
                     then
                     begin
                        FC3doglSelectedSpaceUnit:=FCentities[GTPfac].E_spU[GTPspuOwn].SUO_3dObjIdx;
                        FCMoglVM_CamMain_Target(-1, true);
                     end;
                     FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpTerminated;
                  end; //==END== if FCGtskListInProc[GTPtaskIdx].TITP_phaseTp=tpDone ==//
                  FCGtskListInProc[GTPtaskIdx].TITP_time2xfert:=0;
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
      ,GTPfac
      ,GTPmaxDayMonth
      ,GTPnumTaskToProc
      ,GTPnumTTProcIdx
      ,GTPoriginSatIdx
      ,GTPoriginSatPlanIdx
      ,GTPphLmax
      ,GTPspUidx
      ,GTPspUObjIdx
      ,GTPssys
      ,GTPstar
      ,GTPstartTaskAt
      ,GTPtaskIdx: integer;

      isProdPhaseSwitch
      ,isSegment3Switch
      ,GTPendPh: boolean;
begin
   isProdPhaseSwitch:=false;
   isSegment3Switch:=false;
   {.time updating}
   inc(FCRplayer.P_timeTick);
   GGFnewTick:=FCRplayer.P_timeTick;
   if FCRplayer.P_timeMin<50
   then FCRplayer.P_timeMin:=FCRplayer.P_timeMin+10
   else if FCRplayer.P_timeMin>=50
   then
   begin
      FCRplayer.P_timeMin:=0;
      isProdPhaseSwitch:=true;
      if FCRplayer.P_timeHr<23
      then inc(FCRplayer.P_timeHr)
      else
      begin
         FCRplayer.P_timeHr:=0;
         isSegment3Switch:=true;
         GTPmaxDayMonth:=FCFgTFlow_GameTimer_DayMthGet;
         if FCRplayer.P_timeday<GTPmaxDayMonth
         then inc(FCRplayer.P_timeday)
         else
         begin
            FCRplayer.P_timeday:=1;
            if FCRplayer.P_timeMth<11
            then inc(FCRplayer.P_timeMth)
            else
            begin
               FCRplayer.P_timeMth:=1;
               inc(FCRplayer.P_timeYr);
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
   GTPphLmax:=length(FCGcsmPhList)-1;
   if GTPphLmax>0
   then FCMgTFlow_CSMphase_Proc(GTPphLmax);
   {.SPM phase}
   if (FCRplayer.P_timeday=1)
      and (FCRplayer.P_timeTick>144)
      and (not GGFisSPMphasePassed)
   then
   begin
      FCMgSPM_Phase_Proc;
      GGFisSPMphasePassed:=true;
   end
   else if (FCRplayer.P_timeday>1)
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
   {.delete unused tasks, if it's possible}
   GTPcnt:=length(FCGtskListInProc)-1;
   while GTPcnt>0 do
   begin
      if FCGtskListInProc[GTPcnt].TITP_phaseTp=tpTerminated
      then
      begin
         setlength(FCGtskListInProc, length(FCGtskListInProc)-1);
         dec(GTPcnt);
      end
      else break;
   end;
   {.initialize additional in process tasks if required}
   fcwinmain.FCGLScadencer.Enabled:=false;
   GTPnumTaskToProc:=length(FCGtskLstToProc)-1;
   if GTPnumTaskToProc>0
   then
   begin
      GTPstartTaskAt:=length(FCGtskListInProc)-1;
      SetLength(FCGtskListInProc, length(FCGtskListInProc)+GTPnumTaskToProc);
      GTPnumTTProcIdx:=1;
      try
         while GTPnumTTProcIdx<=GTPnumTaskToProc do
         begin
            GTPtaskIdx:=GTPstartTaskAt+GTPnumTTProcIdx;
            {.update the tasklist in process}
            FCGtskListInProc[GTPtaskIdx]:=FCGtskLstToProc[GTPnumTTProcIdx];
            FCGtskListInProc[GTPtaskIdx].TITP_timeOrg:= GGFnewTick;
            GTPspUidx:=FCGtskListInProc[GTPtaskIdx].TITP_ctldIdx;
            {.update the tasklist in process index inside the owned space unit data structure}
            GTPfac:=FCGtskListInProc[GTPtaskIdx].TITP_ctldFac;
            FCentities[GTPfac].E_spU[FCGtskListInProc[GTPtaskIdx].TITP_ctldIdx].SUO_taskIdx:=GTPtaskIdx;
            {.mission related data init}
            case FCGtskListInProc[GTPtaskIdx].TITP_actionTp of
               tatpMissColonize:
               begin
                  FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpDecel;
                  FCGtskListInProc[GTPtaskIdx].TITP_timeDecel:=FCGtskListInProc[GTPtaskIdx].TITP_duration-FCGtskListInProc[GTPtaskIdx].TITP_timeToFinal;
                  FCGtskListInProc[GTPtaskIdx].TITP_accelbyTick
                     :=(FCentities[GTPfac].E_spU[FCGtskListInProc[GTPtaskIdx].TITP_orgIdx].SUO_deltaV-FCGtskListInProc[GTPtaskIdx].TITP_velFinal)
                        /FCGtskListInProc[GTPtaskIdx].TITP_timeDecel;
                  FCentities[GTPfac].E_spU[GTPspUidx].SUO_oobjLoc:='';
                  FCentities[GTPfac].E_spU[GTPspUidx].SUO_satLoc:='';
                  FCentities[GTPfac].E_spU[GTPspUidx].SUO_status:=susInFreeSpace;
                  FCentities[GTPfac].E_spU[GTPspUidx].SUO_locStarX:=FCentities[GTPfac].E_spU[FCGtskListInProc[GTPtaskIdx].TITP_orgIdx].SUO_locStarX;
                  FCentities[GTPfac].E_spU[GTPspUidx].SUO_locStarZ:=FCentities[GTPfac].E_spU[FCGtskListInProc[GTPtaskIdx].TITP_orgIdx].SUO_locStarZ;
                  GTPspUObjIdx:=FCentities[GTPfac].E_spU[GTPspUidx].SUO_3dObjIdx;
                  FC3doglSpaceUnits[GTPspUObjIdx].Position.X:=FCentities[GTPfac].E_spU[GTPspUidx].SUO_locStarX;
                  FC3doglSpaceUnits[GTPspUObjIdx].Position.Z:=FCentities[GTPfac].E_spU[GTPspUidx].SUO_locStarZ;
                  {.3d initialization}
                  if not FC3doglSpaceUnits[GTPspUObjIdx].Visible
                  then FC3doglSpaceUnits[GTPspUObjIdx].Visible:=true;
                  if FCGtskListInProc[GTPtaskIdx].TITP_destType=tttOrbObj
                  then FC3doglSpaceUnits[GTPspUObjIdx].PointTo
                     (FC3doglObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx],FC3doglObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx].Position.AsVector)
                  else if FCGtskListInProc[GTPtaskIdx].TITP_destType=tttSat
                  then FC3doglSpaceUnits[GTPspUObjIdx].PointTo
                     (FC3doglSatellitesObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx],FC3doglSatellitesObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx].Position.AsVector);
               end; //==END== case: tatpMissColonize: ==//
               tatpMissItransit:
               begin
                  FCGtskListInProc[GTPtaskIdx].TITP_phaseTp:=tpAccel;
                  FCGtskListInProc[GTPtaskIdx].TITP_timeDecel
                     :=FCGtskListInProc[GTPtaskIdx].TITP_duration-(FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise+FCGtskListInProc[GTPtaskIdx].TITP_timeToFinal);
                  FCGtskListInProc[GTPtaskIdx].TITP_accelbyTick
                     :=(FCGtskListInProc[GTPtaskIdx].TITP_velCruise-FCentities[GTPfac].E_spU[FCGtskListInProc[GTPtaskIdx].TITP_orgIdx].SUO_deltaV)
                        /FCGtskListInProc[GTPtaskIdx].TITP_timeToCruise;
                  FCentities[GTPfac].E_spU[GTPspUidx].SUO_oobjLoc:='';
                  FCentities[GTPfac].E_spU[GTPspUidx].SUO_satLoc:='';
                  FCentities[GTPfac].E_spU[GTPspUidx].SUO_status:=susInFreeSpace;
                  GTPssys:=FCFuF_StelObj_GetDbIdx(
                     ufsoSsys
                     ,FCentities[GTPfac].E_spU[GTPspUidx].SUO_starSysLoc
                     ,0
                     ,0
                     ,0
                     );
                  GTPstar:=FCFuF_StelObj_GetDbIdx(
                     ufsoStar
                     ,FCentities[GTPfac].E_spU[GTPspUidx].SUO_starLoc
                     ,GTPssys
                     ,0
                     ,0
                     );
                  if FCGtskListInProc[GTPtaskIdx].TITP_orgType=tttOrbObj
                  then FCMspuF_Orbits_Process(
                     spufoioRemOrbit
                     ,GTPssys
                     ,GTPstar
                     ,FCGtskListInProc[GTPtaskIdx].TITP_orgIdx
                     ,0
                     ,0
                     ,FCGtskListInProc[GTPtaskIdx].TITP_ctldIdx
                     ,true
                     )
                  else if FCGtskListInProc[GTPtaskIdx].TITP_orgType=tttSat
                  then
                  begin
                     GTPoriginSatPlanIdx:=round(FC3doglSatellitesObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_orgIdx].TagFloat);
                     GTPoriginSatIdx:=FC3doglSatellitesObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_orgIdx].Tag;
                     FCMspuF_Orbits_Process(
                        spufoioRemOrbit
                        ,GTPssys
                        ,GTPstar
                        ,GTPoriginSatPlanIdx
                        ,GTPoriginSatIdx
                        ,0
                        ,FCGtskListInProc[GTPtaskIdx].TITP_ctldIdx
                        ,true
                        );
                  end;
                  FCMuiW_FocusPopup_Upd(uiwpkSpUnit);
                  GTPspUObjIdx:=FCentities[GTPfac].E_spU[GTPspUidx].SUO_3dObjIdx;
                  if FCGtskListInProc[GTPtaskIdx].TITP_destType=tttOrbObj
                  then FC3doglSpaceUnits[GTPspUObjIdx].PointTo
                     (FC3doglObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx],FC3doglObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx].Position.AsVector)
                  else if FCGtskListInProc[GTPtaskIdx].TITP_destType=tttSat
                  then FC3doglSpaceUnits[GTPspUObjIdx].PointTo
                     (FC3doglSatellitesObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx],FC3doglSatellitesObjectsGroups[FCGtskListInProc[GTPtaskIdx].TITP_destIdx].Position.AsVector);
               end; //==END== tatpMissItransit ==//
            end; //==END== case FCGtskListInProc[GTPtaskIdx].TITP_actionTp ==//
            inc(GTPnumTTProcIdx);
         end; //==END== while GTPnumTTProcIdx<=GTPnumTaskToProc ==//
      finally
         setlength(FCGtskLstToProc, 1);
      end;
   end; //==END== if GTPnumTaskToProc>0 ==//
   fcwinmain.FCGLScadencer.Enabled:=true;
end;

end.
