{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: manage all missions setup

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

unit farc_game_missioncore;

interface

uses
   Classes
   ,SysUtils

   ,farc_data_game
   ,farc_data_init
   ,farc_data_missionstasks;

type TFCRgmcDckd=record
   GMCD_index: integer;
   GMCD_landTime: integer;
   GMCD_tripTime: integer;
   GMCD_usedRM: extended;
end;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   test key routine for mission setup window.
///</summary>
///   <param="WMSTkeyDump">key number</param>
///   <param="WMSTshftCtrl">shift state</param>
procedure FCMgMC_KeyButtons_Test(
   const WMSTkeyDump: integer;
   const WMSTshftCtrl: TShiftState
   );

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
///   core routine for mission panel closing
///</summary>
procedure FCMgMCore_Mission_ClosePanel;

///<summary>
///   update the destination object and distance.
///</summary>
///   <param name="MDUtripOnly">only update trip data</param>
procedure FCMgMCore_Mission_DestUpd(const MDUtripOnly: boolean);

///<summary>
///   Interplanetary transit mission setup
///</summary>
procedure FCMgMCore_Mission_Setup(
   const MSfac: integer;
   const MSmissType: TFCEdmtTasks
   );

///<summary>
///   update the trackbar.
///</summary>
///   <param name="MTUmission">current mission type</param>
procedure FCMgMCore_Mission_TrackUpd(const MTUmission: TFCEdmtTasks);

var
   GMCfac
   ,GMCtimeA
   ,GMCtimeD
   ,GMCtripTime
   ,GMClandTime
   ,GMCregion
   ,GMCrootOObIdx
   ,GMCrootSatIdx
   ,GMCrootSatObjIdx
   ,GMCrootSsys
   ,GMCrootStar: integer;

   GMCbaseDist,
   GMCfinalDV,
   GMCrmMaxVol,
   GMCreqDV,
   GMCcruiseDV,
   GMCAccelG,
   GMCusedRMvol,
   GMCmaxDV: extended;


   GMCdckd: array of TFCRgmcDckd;


{:DEV NOTE: these constant are only for prototype purposes. It's quick&dirty}
const
   MRMCDVCthrbyvol=0.7;
   MRMCDVCvolOfDrive=3000;
   MRMCDVCloadedMassInTons=100000;
   MRMCDVCrmMass=70;
   GMCCthrN=MRMCDVCthrbyvol*MRMCDVCvolOfDrive*(FCCdiMbySec_In_1G*1000);

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_html
   ,farc_data_spu
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_game_gameflow
   ,farc_game_micolonize
   ,farc_game_mitransit
   ,farc_main
   ,farc_ogl_ui
   ,farc_ogl_viewmain
   ,farc_spu_functions
   ,farc_ui_coldatapanel
   ,farc_ui_keys
   ,farc_ui_msges
   ,farc_ui_surfpanel
   ,farc_ui_win
   ,farc_univ_func;

var
   GMCmother: integer;

   GMCmissTp: TFCEdmtTasks;

//===================================END OF INIT============================================

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgMC_KeyButtons_Test(
   const WMSTkeyDump: integer;
   const WMSTshftCtrl: TShiftState
   );
{:Purpose: test key routine for mission setup window..
    Additions:
      -2012Feb15- *code:  move the procedure into farc_game_missioncore.
                  *mod: link the escape key to the mission_closepanel core routine.
      -2010Jul03- *fix: set correctly the parameters if the mission window is closed.
}
begin
   if (ssAlt in WMSTshftCtrl)
   then FCMuiK_WinMain_Test(WMSTkeyDump, WMSTshftCtrl);
   {.ESCAPE}
   {.close the mission setup window}
   if WMSTkeyDump=27
   then FCMgMCore_Mission_ClosePanel
   else if (WMSTkeyDump<>65)
      and (WMSTkeyDump<>67)
      and (WMSTkeyDump<>27)
   then FCMuiK_WinMain_Test(WMSTkeyDump, WMSTshftCtrl);
end;

procedure FCMgMCore_Mission_Cancel(const MCownSpUidx: integer);
{:Purpose: cancel the mission of a selected space unit.
    Additions:
      -2010Jan08- *mod: change gameflow state method according to game flow changes.
}
var
   MCtaskId
//   ,MCthreadId
   : integer;
begin
   {:DEV NOTES: a complete rewrite will be done for 0.4.0.}
//   MCtaskId:=FCRplayer.P_suOwned[MCownSpUidx].SUO_taskIdx;
//   MCthreadId:=FCGtskListInProc[MCtaskId].TITP_threadIdx;
   try
      FCMgTFlow_FlowState_Set(tphPAUSE);
   finally
//      GGFthrTPU[MCthreadId].TPUphaseTp:=tpTerminated;
      {.unload the current task to the space unit}
//      FCRplayer.P_suOwned[MCownSpUidx].SUO_taskIdx:=0;
//               {.set the remaining reaction mass}
//               FCRplayer.Play_suOwned[TPUownedIdx].SUO_availRMass
//                  :=FCRplayer.Play_suOwned[TPUownedIdx].SUO_availRMass
//                     -FCGtskListInProc[TPUtaskIdx].TITP_usedRMassV;
      {.disable the task and delete it if it's the last in the list}
//      FCGtskListInProc[MCtaskId].T_enabled:=false;
      if MCtaskId=length(FCGtskListInProc)-1
      then SetLength(FCGtskListInProc, length(FCGtskListInProc)-1);
   end;
   FCMgTFlow_FlowState_Set(tphTac);
   FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
//   FCMoglVMain_CameraMain_Target(-1, true);
end;

procedure FCMgMCore_Mission_Commit;
{:DEV NOTES: update also FCMspuF_SpUnit_Remove regarding mission post process configuration.}
{:DEV NOTES: don't forget to update all the required data w/ the new and modified ones! synch w/ a clone of data_missiontasks.}
{:Purpose: commit the mission by creating a task.
    Additions:
      -2011Feb12- add: additional data.
      -2010Sep16- add: entities code.
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
   MCmax
   ,MCcnt
   ,MCtskL: integer;
begin
   case GMCmissTp of
      tMissionColonization:
      begin
         {:DEV NOTES: add code if the LV are selected by the docking list or directly.}
         MCmax:=length(GMCdckd)-1;
         MCcnt:=1;
         while MCcnt<=MCmax do
         begin
            setlength(FCGtskLstToProc, length(FCGtskLstToProc)+1);
            MCtskL:=length(FCGtskLstToProc)-1;
            FCGtskLstToProc[MCtskL].T_type:=tMissionColonization;
//            FCGtskLstToProc[MCtskL].TITP_ctldType:=ttSpaceUnit;
            FCGtskLstToProc[MCtskL].T_entity:=GMCfac;
            FCGtskLstToProc[MCtskL].T_controllerIndex:=GMCdckd[MCcnt].GMCD_index;
            FCGtskLstToProc[MCtskL].T_duration:=GMCdckd[MCcnt].GMCD_tripTime;
            FCGtskLstToProc[MCtskL].T_durationInterval:=1;
            FCGtskLstToProc[MCtskL].T_tMCorigin:=ttSpaceUnitDockedIn;
            FCGtskLstToProc[MCtskL].T_tMCoriginIndex:=GMCmother;
            if GMCrootSatIdx=0
            then
            begin
               FCGtskLstToProc[MCtskL].T_tMCdestination:=ttOrbitalObject;
               FCGtskLstToProc[MCtskL].T_tMCdestinationIndex:=GMCrootOObIdx;
            end
            else if GMCrootSatIdx>0
            then
            begin
               FCGtskLstToProc[MCtskL].T_tMCdestination:=ttSatellite;
               FCGtskLstToProc[MCtskL].T_tMCdestinationIndex:=GMCrootSatObjIdx;
            end;
            FCGtskLstToProc[MCtskL].T_tMCdestinationRegion:=GMCregion;
            FCGtskLstToProc[MCtskL].TITP_velCruise:=0;
            FCGtskLstToProc[MCtskL].TITP_timeToCruise:=0;
            FCGtskLstToProc[MCtskL].TITP_velFinal:=GMCfinalDV;
            FCGtskLstToProc[MCtskL].TITP_timeToFinal:=GMCdckd[MCcnt].GMCD_landTime;
            FCGtskLstToProc[MCtskL].TITP_usedRMassV:=GMCdckd[MCcnt].GMCD_usedRM;
            if FCWinMain.FCWMS_Grp_MCGColName.Text<>FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcolNameNo')
            then FCGtskLstToProc[MCtskL].TITP_str1:=FCWinMain.FCWMS_Grp_MCGColName.Text
            else FCGtskLstToProc[MCtskL].TITP_str1:='';
            if FCWinMain.FCWMS_Grp_MCG_SetName.Visible
            then
            begin
               FCGtskLstToProc[MCtskL].TITP_str2:=FCWinMain.FCWMS_Grp_MCG_SetName.Text;
               FCGtskLstToProc[MCtskL].TITP_int1:=FCWinMain.FCWMS_Grp_MCG_SetType.ItemIndex;
            end
            else
            begin
               FCGtskLstToProc[MCtskL].TITP_str2:='';
               FCGtskLstToProc[MCtskL].TITP_int1:=0;
            end;
            FCMspuF_DockedSpU_Rem(
               GMCfac
               ,GMCmother
               ,GMCdckd[MCcnt].GMCD_index
               );
            inc(MCcnt);
         end; //==END== while MCcnt<=MCmax ==//
         FCWinMain.FCWM_SurfPanel.Hide;
         FCWinMain.FCWM_MissionSettings.Hide;
         if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[GMCmother]
         then
         begin
            FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
            FCMuiW_FocusPopup_Upd(uiwpkSpUnit);
         end;
      end; //==END== case: gmcmnColoniz ==//
      tMissionInterplanetaryTransit:
      begin
         setlength(FCGtskLstToProc, length(FCGtskLstToProc)+1);
         MCtskL:=length(FCGtskLstToProc)-1;
         FCGtskLstToProc[MCtskL].T_type:=tMissionInterplanetaryTransit;
//         FCGtskLstToProc[MCtskL].TITP_ctldType:=ttSpaceUnit;
         FCGtskLstToProc[MCtskL].T_entity:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Tag;
         FCGtskLstToProc[MCtskL].T_controllerIndex:=round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat);
         FCGtskLstToProc[MCtskL].T_duration:=round(GMCtripTime);
         FCGtskLstToProc[MCtskL].T_durationInterval:=1;
         if GMCrootSatIdx=0
         then
         begin
            FCGtskLstToProc[MCtskL].T_tMITorigin:=ttOrbitalObject;
            FCGtskLstToProc[MCtskL].T_tMIToriginIndex:=GMCrootOObIdx;
         end
         else if GMCrootSatIdx>0
         then
         begin
            FCGtskLstToProc[MCtskL].T_tMITorigin:=ttSatellite;
            FCGtskLstToProc[MCtskL].T_tMIToriginIndex:=GMCrootSatObjIdx;
         end;
         if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid]
         then
         begin
            FCGtskLstToProc[MCtskL].T_tMITdestination:=ttOrbitalObject;
            FCGtskLstToProc[MCtskL].T_tMITdestinationIndex:=FC3doglSelectedPlanetAsteroid;
         end
         else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite]
         then
         begin
            FCGtskLstToProc[MCtskL].T_tMITdestination:=ttSatellite;
            FCGtskLstToProc[MCtskL].T_tMITdestinationIndex:=FC3doglSelectedSatellite;
         end;
         FCGtskLstToProc[MCtskL].T_tMCdestinationRegion:=0;
         FCGtskLstToProc[MCtskL].TITP_velCruise:=GMCcruiseDV;
         FCGtskLstToProc[MCtskL].TITP_timeToCruise:=GMCtimeA;
         FCGtskLstToProc[MCtskL].T_tMITinProcessData.IPD_timeToTransfert:=0;
         FCGtskLstToProc[MCtskL].TITP_velFinal:=GMCfinalDV;
         FCGtskLstToProc[MCtskL].TITP_timeToFinal:=GMCtimeD;
         FCGtskLstToProc[MCtskL].TITP_usedRMassV:=GMCusedRMvol;
         FCGtskLstToProc[MCtskL].TITP_str1:='';
         FCGtskLstToProc[MCtskL].TITP_str2:='';
         FCGtskLstToProc[MCtskL].TITP_int1:=0;
         FCWinMain.FCWM_MissionSettings.Hide;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position:=1;
         if GMCrootSatIdx=0
         then FC3doglSelectedPlanetAsteroid:=GMCrootOObIdx
         else if GMCrootSatIdx>0
         then
         begin
            FC3doglSelectedSatellite:=GMCrootSatObjIdx;
            FC3doglSelectedPlanetAsteroid:=round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat);
         end;
         FCMoglVM_CamMain_Target(-1, false);
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
   {.mission configuration data}
   FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Insert
   (
      1
      ,  FCFdTFiles_UIStr_Get(uistrUI,'MCGDatAccel')+' '+FloatToStr(GMCAccelG)
            +' g <br>'
            +FCFdTFiles_UIStr_Get(uistrUI,'MCGDatCruiseDV')+' '+FloatToStr(GMCcruiseDV)
            +' km/s <br>'
            +FCFdTFiles_UIStr_Get(uistrUI,'MCGDatFinalDV')+' '+FloatToStr(GMCfinalDV)
            +' km/s <br>'
            +FCFdTFiles_UIStr_Get(uistrUI,'MCGDatUsdRM')+' '
               +IntToStr
                  (
                     round
                        (
                           GMCusedRMvol*100
                           /FCDdgEntities[GMCfac].E_spaceUnits[round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat)].SU_reactionMass
                        )
                  )
            +' %<br>'
            +FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI,'MCGDatTripTime')+FCCFdHeadEnd
            +FCFcFunc_TimeTick_GetDate(GMCtripTime)
   );
   FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Delete(2);
end;

procedure FCMgMCore_Mission_ClosePanel;
{:Purpose: core routine for mission panel closing.
    Additions:
}
begin
   FCWinMain.FCWM_MissionSettings.Hide;
   FCWinMain.FCWM_MissionSettings.Enabled:=False;
   if FCWinMain.FCWM_SurfPanel.Visible
   then
   begin
      FCWinMain.FCWM_SurfPanel.Hide;
      FCWinMain.FCWM_SP_Surface.Enabled:=false;
   end;
   FCVdiGameFlowTimer.Enabled:=true;
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
var
   MDUdmpSatIdx
   ,MDUdmpPlanSatIdx: integer;
   MDUdmpTokenName: string;
begin
   {.calculate all necessary data}
   if not MDUtripOnly
   then
   begin
      FCMgMiT_ITransit_Setup;
      FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=true;
      FCWinMain.FCWMS_ButProceed.Enabled:=true;
      FCWinMain.FCWMS_Grp_MCG_RMassTrack.Max:=3;
   end;
   {.calculate all trip data}
   if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled
   then
   begin
      FCMgMiT_MissionTrip_Calc
         (
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position
            ,FCDdgEntities[GMCfac].E_spaceUnits[round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat)].SU_deltaV
         );
   end;
   {.current destination for orbital object}
   if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid]
   then
   begin
      if (FC3doglSelectedPlanetAsteroid=GMCrootOObIdx)
         or (not FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled)
      then
      begin
         FCWinMain.FCWMS_ButProceed.Enabled:=false;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
         {.current destination}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert(7, FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone')+'<br>');
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(8);
         {.distance + min deltaV}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert
         (
            9
            ,FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntCdist')
               +' 0 '
               +FCFdTFiles_UIStr_Get(uistrUI,'acronAU')
               +'<ind x="'+IntToStr(FCWinMain.FCWMS_Grp_MSDG_Disp.Width shr 1)+'">'
               +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdestIntCminDV')
               +' 0 km/s'
         );
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(10);
         {.mission configuration data}
         if (not FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled)
            and (FC3doglSelectedPlanetAsteroid<>GMCrootOObIdx)
         then FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Insert(1, FCFdTFiles_UIStr_Get(uistrUI,'MCGDatNA'))
         else FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Insert(1, FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone'));
         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Delete(2);
      end //==END== if FCV3DoObjSlctd=CFVoobjIdDB or (not FCWMS_Grp_MCG_RMassTrack.Enabled) ==//
      else if FC3doglSelectedPlanetAsteroid<>GMCrootOObIdx
      then
      begin
         if not MDUtripOnly
         then
         begin
            {.current destination}
            MDUdmpTokenName:=FCFdTFiles_UIStr_Get(
               dtfscPrprName
               ,FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_dbTokenId
               );
            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert(7, MDUdmpTokenName+'<br>');
            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(8);
            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert
            (
               9
               ,FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntCdist')+' '
                  +FloatToStr(GMCbaseDist)+' '
                  +FCFdTFiles_UIStr_Get(uistrUI,'acronAU')
                  +'<ind x="'+IntToStr(FCWinMain.FCWMS_Grp_MSDG_Disp.Width shr 1)+'">'
                  +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdestIntCminDV')
                  +' '+FloatToStr(GMCreqDV)+' km/s'
            );
            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(10);
         end; //==END== if not MDUtripOnly ==//
         FCMgMCore_Mission_ConfData;
      end; {.else if FCV3dMVorbObjSlctd<>CFVoobjIdDB}
   end //==END== if FCGLSCamMainViewGhost.TargetObject=FC3DobjGrp[FCV3DoObjSlctd] ==//
   {.current destination for satellite}
   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite]
   then
   begin
      if (GMCrootSatIdx>0)
         and ((FC3doglSelectedSatellite=GMCrootSatObjIdx) or (not FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled))
      then
      begin
         FCWinMain.FCWMS_ButProceed.Enabled:=false;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
         {.current destination}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert(7, FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone')+'<br>');
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(8);
         {.distance + min deltaV}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert
         (
            9
            ,FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntCdist')
               +' 0 '
               +FCFdTFiles_UIStr_Get(uistrUI,'acronAU')
               +'<ind x="'+IntToStr(FCWinMain.FCWMS_Grp_MSDG_Disp.Width shr 1)+'">'
               +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdestIntCminDV')
               +' 0 km/s'
         );
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(10);
         {.mission configuration data}
         if (not FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled)
            and (FC3doglSelectedSatellite<>GMCrootSatObjIdx)
         then FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Insert(1, FCFdTFiles_UIStr_Get(uistrUI,'MCGDatNA'))
         else FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Insert
            (1, FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone'));
         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Delete(2);
      end
      else if ((GMCrootSatIdx>0) and (FC3doglSelectedSatellite<>GMCrootSatObjIdx))
         or (GMCrootSatObjIdx=0)
      then
      begin
         {.get satellite data}
         MDUdmpSatIdx:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag;
         MDUdmpPlanSatIdx:=round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat);
         if not MDUtripOnly
         then
         begin
            {.current destination}
            MDUdmpTokenName:=FCFdTFiles_UIStr_Get(
               dtfscPrprName
               ,FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[MDUdmpPlanSatIdx].OO_satellitesList[MDUdmpSatIdx].OO_dbTokenId
               );
            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert(7, MDUdmpTokenName+'<br>');
            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(8);
            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert(
               9
               ,FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntCdist')+' '
                  +FloatToStr(GMCbaseDist)+' '
                  +FCFdTFiles_UIStr_Get(uistrUI,'acronAU')
                  +'<ind x="'+IntToStr(FCWinMain.FCWMS_Grp_MSDG_Disp.Width shr 1)+'">'
                  +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdestIntCminDV')
                  +' '+FloatToStr(GMCreqDV)+' km/s'
               );
            FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(10);
         end; //==END== if not MDUtripOnly ==//
         FCMgMCore_Mission_ConfData;
      end;
   end; //==END== else FCGLSCamMainViewGhost.TargetObject=FC3DobjSatGrp[FCV3DsatSlctd] ==//
end;

procedure FCMgMCore_Mission_Setup(
   const MSfac: integer;
   const MSmissType: TFCEdmtTasks
   );
{:Purpose: Interplanetary transit mission setup.
    Additions:
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
var
   MScol
   ,MSdesgn
   ,MSdockedNum
   ,MSownedIdx
   ,surfaceOObj: integer;

   MSdmpStatus
   ,MSdispIdx: string;

   MSenvironment: TFCEduEnvironmentTypes;
begin
   FCVdiGameFlowTimer.Enabled:=false;
   {.pre initialization for all the missions}
   FCWinMain.FCWM_MissionSettings.Enabled:=true;
   FCMuiM_MessageBox_ResetState(true);
   FCWinMain.FCWM_ColDPanel.Hide;
   FCWinMain.FCWMS_Grp_MCGColName.Text:='';
   GMCAccelG:=0;
   GMCbaseDist:=0;
   GMCcruiseDV:=0;
   GMCfac:=MSfac;
   GMCfinalDV:=0;
   GMClandTime:=0;
   GMCmaxDV:=0;
   GMCmother:=0;
   GMCreqDV:=0;
   GMCrmMaxVol:=0;
   GMCrootOObIdx:=0;
   GMCrootSatIdx:=0;
   GMCrootSatObjIdx:=0;
   GMCtimeA:=0;
   GMCtimeD:=0;
   GMCtripTime:=0;
   GMCusedRMvol:=0;
   setlength(GMCdckd, 0);
   {.universal data initialization for all missions}
   GMCmissTp:=MSmissType;
   MSownedIdx:=round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat);
   MSdesgn:=FCFspuF_Design_getDB(FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_designToken);
   MSdispIdx:='<ind x="'+IntToStr(FCWinMain.FCWMS_Grp_MSDG.Width shr 1)+'">';
   {.missions specific settings}
   case MSmissType of
      tMissionColonization:
      begin
         {.set the mission name}
         FCWinMain.FCWM_MissionSettings.Caption.Text:=FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet')+FCFdTFiles_UIStr_Get(uistrUI,'Mission.coloniz');
         {.initialize mission data}
         GMCmother:=MSownedIdx;
         MSdmpStatus:=FCFspuF_AttStatus_Get(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Tag, GMCmother);
         GMCrootSsys:=FCFuF_StelObj_GetDbIdx(
            ufsoSsys
            ,FCDdgEntities[GMCfac].E_spaceUnits[GMCmother].SU_locationStarSystem
            ,0
            ,0
            ,0
            );
         GMCrootStar:=FCFuF_StelObj_GetDbIdx(
            ufsoStar
            ,FCDdgEntities[GMCfac].E_spaceUnits[GMCmother].SU_locationStar
            ,GMCrootSsys
            ,0
            ,0
            );
         GMCrootOObIdx:=FCFuF_StelObj_GetDbIdx(
            ufsoOObj
            ,FCDdgEntities[GMCfac].E_spaceUnits[GMCmother].SU_locationOrbitalObject
            ,GMCrootSsys
            ,GMCrootStar
            ,0
            );
         if FCDdgEntities[GMCfac].E_spaceUnits[GMCmother].SU_locationSatellite<>''
         then
         begin
            GMCrootSatIdx:=FCFuF_StelObj_GetDbIdx(
               ufsoSat
               ,FCDdgEntities[GMCfac].E_spaceUnits[GMCmother].SU_locationSatellite
               ,GMCrootSsys
               ,GMCrootStar
               ,GMCrootOObIdx
               );
            MScol:=FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[GMCrootOObIdx].OO_satellitesList[GMCrootSatObjIdx].OO_colonies[0];
            MSenvironment:=FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[GMCrootOObIdx].OO_satellitesList[GMCrootSatObjIdx].OO_environment;
         end
         else
         begin
            GMCrootSatIdx:=0;
            MScol:=FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[GMCrootOObIdx].OO_colonies[0];
            MSenvironment:=FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[GMCrootOObIdx].OO_environment;
         end;
         MSdockedNum:=FCFspuF_DockedSpU_GetNum(
            0
            ,GMCmother
            ,aNone
            ,sufcColoniz
            );
         if GMCrootSatIdx>0
         then
         begin
            GMCrootSatObjIdx
               :=FCFoglVM_SatObj_Search(
                  GMCrootOObIdx
                  ,GMCrootSatIdx
                  );
            FCMgC_Colonize_Setup(
               gclvstBySelector
               ,GMCmother
               ,GMCrootSsys
               ,GMCrootStar
               ,GMCrootOObIdx
               ,GMCrootSatIdx
               ,GMCrootSatObjIdx
               );
         end
         else if GMCrootSatIdx=0
         then FCMgC_Colonize_Setup(
            gclvstBySelector
            ,GMCmother
            ,GMCrootSsys
            ,GMCrootStar
            ,GMCrootOObIdx
            ,0
            ,0
            );
         {.set the interface elements}
         surfaceOObj:=FCFuiSP_VarCurrentOObj_Get;
         if surfaceOObj<>GMCrootOObIdx
         then FCMuiSP_SurfaceEcosphere_Set(GMCrootOObIdx, GMCrootSatIdx, false)
         else begin
            FCWinMain.FCWM_SurfPanel.Visible:=true;
            fcwinmain.FCWM_SP_Surface.Enabled:=true;
            FCMuiSP_VarRegionSelected_Reset;
            FCWinMain.FCWM_SP_SurfSel.Width:=0;
            FCWinMain.FCWM_SP_SurfSel.Height:=0;
            FCWinMain.FCWM_SP_SurfSel.Left:=0;
            FCWinMain.FCWM_SP_SurfSel.Top:=0;
         end;
         FCMuiSP_Panel_Relocate ( true );
         FCWinMain.FCWM_SP_DataSheet.ActivePage:=FCWinMain.FCWM_SP_ShReg;
         {.mission data display}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Clear;
         {.idx=0}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCCFdHead
            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGmotherSpUnIdStat')
            +FCCFdHeadEnd
            );
         {.idx=1}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCFdTFiles_UIStr_Get(dtfscPrprName, FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_name)+
            ' '
            +FCFdTFiles_UIStr_Get(dtfscSCarchShort, FCDdsuSpaceUnitDesigns[MSdesgn].SUD_internalStructureClone.IS_architecture)
            +' '+MSdmpStatus
            +'<br>'
            );
         {.current destination idx=2}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCCFdHead
            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDest')
            +FCCFdHeadEnd
            );
         {.idx=3}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_SP_ShReg')+
            ' ['
            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurRegDestNone')
               +']<br>'
            );
         {.current destination idx=4}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCCFdHead
            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdistAtm')
            +FCCFdHeadEnd
            );
         {.idx=5}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(FloatToStr(FCFcFunc_ScaleConverter(cf3dct3dViewUnitToKm, GMCbaseDist))+' km');
         {.track bar for number of spacecrafts}
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag:=1;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Left:=12;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Top:=28;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position:=1;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Min:=1;
         if MSdockedNum=1
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Max:=2;
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Visible:=false;
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
         end
         else if MSdockedNum>1
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Max:=MSdockedNum;
            if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag=1
            then FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag:=0;
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Format:=IntToStr(FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position);
         end;
         {.colony name}
         FCWinMain.FCWMS_Grp_MCGColName.Left
            :=FCWinMain.FCWMS_Grp_MCG_RMassTrack.Left+(FCWinMain.FCWMS_Grp_MCG_RMassTrack.Width shr 1)-(FCWinMain.FCWMS_Grp_MCGColName.Width shr 1);
         FCWinMain.FCWMS_Grp_MCGColName.Top:=FCWinMain.FCWMS_Grp_MCG_RMassTrack.Top+FCWinMain.FCWMS_Grp_MCG_RMassTrack.Height+24;
         if MScol=0
         then
         begin
            FCWinMain.FCWMS_Grp_MCGColName.Tag:=0;
            FCWinMain.FCWMS_Grp_MCGColName.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcolNameNo');
            FCWinMain.FCWMS_Grp_MCGColName.Show;
         end
         else if MScol>0
         then
         begin
            FCWinMain.FCWMS_Grp_MCGColName.Tag:=MScol;
            FCWinMain.FCWMS_Grp_MCGColName.Text:='';
            FCWinMain.FCWMS_Grp_MCGColName.Hide;
         end;
         {.settlement type}
         FCWinMain.FCWMS_Grp_MCG_SetType.Left:=FCWinMain.FCWMS_Grp_MCGColName.Left-4;
         FCWinMain.FCWMS_Grp_MCG_SetType.Top:=FCWinMain.FCWMS_Grp_MCGColName.Top+FCWinMain.FCWMS_Grp_MCGColName.Height+4;
         FCWinMain.FCWMS_Grp_MCG_SetType.ItemIndex:=-1;
         FCWinMain.FCWMS_Grp_MCG_SetType.Items.Clear;
         if MSenvironment<etSpace
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_SetType.Items.Add( FCFdTFiles_UIStr_Get(uistrUI, 'FCWMS_Grp_MCG_SetType0') );
            FCWinMain.FCWMS_Grp_MCG_SetType.Items.Add( FCFdTFiles_UIStr_Get(uistrUI, 'FCWMS_Grp_MCG_SetType2') );
         end
         else if MSenvironment=etSpace
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_SetType.Items.Add( FCFdTFiles_UIStr_Get(uistrUI, 'FCWMS_Grp_MCG_SetType1') );
            FCWinMain.FCWMS_Grp_MCG_SetType.Items.Add( FCFdTFiles_UIStr_Get(uistrUI, 'FCWMS_Grp_MCG_SetType2') );
         end;
         FCWinMain.FCWMS_Grp_MCG_SetType.ItemIndex:=0;
         FCWinMain.FCWMS_Grp_MCG_SetType.Hide;
         {.settlement name}
         FCWinMain.FCWMS_Grp_MCG_SetName.Left:=FCWinMain.FCWMS_Grp_MCGColName.Left;
         FCWinMain.FCWMS_Grp_MCG_SetName.Top:=FCWinMain.FCWMS_Grp_MCG_SetType.Top+FCWinMain.FCWMS_Grp_MCG_SetType.Height+19;
         FCWinMain.FCWMS_Grp_MCG_SetName.Hide;
         {.initialize the 2 mission configuration panels}
         FCWinMain.FCWMS_Grp_MCG_DatDisp.HTMLText.Clear;
         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Clear;
         {.mission configuration background panel}
         FCWinMain.FCWMS_Grp_MCG_DatDisp.HTMLText.Add(
            FCCFdHead
            +FCFdTFiles_UIStr_Get(uistrUI,'MCGColCVSel')
            +FCCFdHeadEnd
            );
         {.mission configuration data}
         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Add(
            FCCFdHead
            +FCFdTFiles_UIStr_Get(uistrUI,'MCGDatHead')
            +FCCFdHeadEnd
            );
         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Add( FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurRegDestNone') );
         {.mission configuration proceed button}
         FCWinMain.FCWMS_ButProceed.Enabled:=false;
      end; //==END== case: gmcmnColoniz ==//
      tMissionInterplanetaryTransit:
      begin
         {.initialize mission data}
         MSdmpStatus:=FCFspuF_AttStatus_Get(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Tag, MSownedIdx);
         GMCrootSsys:=FCFuF_StelObj_GetDbIdx(
            ufsoSsys
            ,FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_locationStarSystem
            ,0
            ,0
            ,0
            );
         GMCrootStar:=FCFuF_StelObj_GetDbIdx(
            ufsoStar
            ,FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_locationStar
            ,GMCrootSsys
            ,0
            ,0
            );
         GMCrootOObIdx:=FCFuF_StelObj_GetDbIdx(
            ufsoOObj
            ,FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_locationOrbitalObject
            ,GMCrootSsys
            ,GMCrootStar
            ,0
            );
         if FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_locationSatellite<>''
         then GMCrootSatIdx:=FCFuF_StelObj_GetDbIdx(
            ufsoSat
            ,FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_locationSatellite
            ,GMCrootSsys
            ,GMCrootStar
            ,GMCrootOObIdx
            )
         else GMCrootSatIdx:=0;
         {DEV NOTE: for futur expansion, add the case of a mission assignated on a space unit
         that is not in the current local star system. The only case where it will happens it's
         when a mission is assignated by the faction's properties window.
         For data update, take over this faction's properties window data, test if this win is
         displayed or not}
         {DEV NOTE: the case which follow is just concerning the current system and only the
         player's faction.}
         FC3doglSelectedPlanetAsteroid:=GMCrootOObIdx;
         if GMCrootSatIdx>0
         then
         begin
            GMCrootSatObjIdx:=FCFoglVM_SatObj_Search(GMCrootOObIdx, GMCrootSatIdx);
            FC3doglSelectedSatellite:=GMCrootSatObjIdx;
            FCMoglVM_CamMain_Target(100, false);
         end
         else if GMCrootSatIdx=0
         then FCMoglVM_CamMain_Target(FC3doglSelectedPlanetAsteroid, false);
         {.set user's interface}
         FCWinMain.FCWM_MissionSettings.Caption.Text:=FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet')+FCFdTFiles_UIStr_Get(uistrUI,'Mission.itransit');
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Visible:=true;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
         {.mission data display}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Clear;
         {.idx=0}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI,'MSDGspUnIdStat')+FCCFdHeadEnd
            );
         {.idx=1}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCFdTFiles_UIStr_Get(dtfscPrprName, FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_name)
            +' '
            +FCFdTFiles_UIStr_Get(dtfscSCarchShort, FCDdsuSpaceUnitDesigns[MSdesgn].SUD_internalStructureClone.IS_architecture)
            +' '+MSdmpStatus
            +'<br>'
            );
         {.current deltaV + reaction mass, idx=2}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCCFdHead
            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDV')
            +MSdispIdx
            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGremRMass')
            +FCCFdHeadEnd
            );
         {.idx=3}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FloatToStr(FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_deltaV)+' km/s'
            +MSdispIdx
            +FloatToStr(FCDdgEntities[GMCfac].E_spaceUnits[MSownedIdx].SU_reactionMass)+' m<sup>3</sup>'
            +'<br>'
            );
         {.space drive type and isp, idx=4}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCCFdHead
            +FCFdTFiles_UIStr_Get(uistrUI,'spUnDrvTp')
            +MSdispIdx
            +FCFdTFiles_UIStr_Get(uistrUI,'spUnISPfull')
            +FCCFdHeadEnd
            );
         {.idx=5}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            '(data not implemented yet)'
            +MSdispIdx
            +IntToStr(FCDdsuSpaceUnitDesigns[MSdesgn].SUD_spaceDriveISP)+' sec'
            +'<br>'
            );
         {.current destination idx=6}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCCFdHead
            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDest')
            +FCCFdHeadEnd
            );
         {.idx= 7}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone')+'<br>');
         {.destination intercept course, idx=8}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCCFdHead
            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntC')
            +FCCFdHeadEnd
            );
         {.idx=9}
         FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
            FCFdTFiles_UIStr_Get(uistrUI,'MSDGdesIntCdist')
            +' 0 '
            +FCFdTFiles_UIStr_Get(uistrUI,'acronAU')
            +MSdispIdx
            +FCFdTFiles_UIStr_Get(uistrUI,'MSDGdestIntCminDV')
            +' 0 km/s'
            );
         {.mission configuration proceed button}
         FCWinMain.FCWMS_ButProceed.Enabled:=false;
         {.mission configuration trackbar}
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag:=1;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Left:=24;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Top:=32;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Max:=3;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Min:=1;
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position:=1;
         FCMgMCore_Mission_TrackUpd( tMissionInterplanetaryTransit );
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
         {.initialize the 2 mission configuration panels}
         FCWinMain.FCWMS_Grp_MCG_DatDisp.HTMLText.Clear;
         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Clear;
         {.mission configuration background panel}
         FCWinMain.FCWMS_Grp_MCG_DatDisp.HTMLText.Add(
            FCCFdHead
            +FCFdTFiles_UIStr_Get(uistrUI,'MCGtransSpd')
            +FCCFdHeadEnd
            );
         {.mission configuration data}
         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Add(
            FCCFdHead
            +FCFdTFiles_UIStr_Get(uistrUI,'MCGDatHead')
            +FCCFdHeadEnd
            );
         FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI,'MSDGcurDestNone')+'<br>');
      end; //==END== case: gmcmnItransit ==//
   end; //==END== case MSmissType of ==//
   FCWinMain.FCWM_MissionSettings.Show;
   FCWinMain.FCWM_MissionSettings.BringToFront;
end;

procedure FCMgMCore_Mission_TrackUpd(const MTUmission: TFCEdmtTasks);
{:Purpose: update the trackbar.
    Additions:
      -2010Apr26- *fix: stop the bug of updating for a colonize mission when the trackbar is resetted.
      -2010Apr17- *add: colonization setup data update.
      -2010Apr10- *add: mission type.
                  *add: update for colonization mission.
      -2009Oct24- *update trip data.
                  *prevent update trip data when initializing.
      -2009Oct19- *change the number of levels.
}
var
   MTUsatObj: integer;
begin
   case MTUmission of
      tMissionColonization:
      begin
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Format:=IntToStr(FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position);
         if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag=0
         then
         begin

            if GMCrootSatIdx>0
            then MTUsatObj:=FCFoglVM_SatObj_Search(GMCrootOObIdx, GMCrootSatIdx)
            else MTUsatObj:=0;
            FCMgC_Colonize_Setup(
               gclvstBySelector
               ,GMCmother
               ,GMCrootSsys
               ,GMCrootStar
               ,GMCrootOObIdx
               ,GMCrootSatIdx
               ,MTUsatObj
               );
         end
         else if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag=1
         then FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag:=0;
      end;
      tMissionInterplanetaryTransit:
      begin
         case FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position of
            1: FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Format
               :=FCFdTFiles_UIStr_Get(uistrUI,'FCWMS_Grp_MCG_RMassTrackITransEco');
            2: FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Format
               :=FCFdTFiles_UIStr_Get(uistrUI,'FCWMS_Grp_MCG_RMassTrackITransSlow');
            3: FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Format
               :=FCFdTFiles_UIStr_Get(uistrUI,'FCWMS_Grp_MCG_RMassTrackITransFast');
         end;
         if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag=0
         then FCMgMCore_Mission_DestUpd(true)
         else if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag=1
         then FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag:=0;
      end;
   end; //==END== case MTUmission of ==//
   {.update the trackbar label}
end;

end.
