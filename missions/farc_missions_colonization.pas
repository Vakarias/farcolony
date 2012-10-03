{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: contains all colonize mission routines and functions

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

unit farc_missions_colonization;

interface

uses
   Math
   ,SysUtils

   ,farc_data_game;

type TFCEgcLVselTp=(
   gclvstBySelector
   ,gclvstByList
   );

///<summary>
///   colonize mission - post process
///</summary>
///   <param name=""></param>
///   <param name=""></param>
procedure FCMgC_Colonize_PostProc(
   const CPPfac
         ,CPPspuIdx
         ,CPPssys
         ,CPPstar
         ,CPPobjIdx
         ,CPPsatIdx
         ,CPPregion: integer;
         CPPsettleTp: TFCEdgSettlements;
         CPPname
         ,CPPsettleName: string
   );

///<summary>
///   core colonize mission setup
///</summary>
///   <param name="TFCEgcLVselTp">LV selected mode: by selector or directly in docking list</param>
///   <param name=""></param>
procedure FCMgC_Colonize_Setup(
   const CSmethod: TFCEgcLVselTp;
   const CSowndMother
         ,CSssys
         ,CSstar
         ,CSoobjIdx
         ,CSsatIdx
         ,CSsatObjIdx: integer
   );

///<summary>
///   update region selection and update mission configuration
///</summary>
///   <param name="CUregIdx"></param>
procedure FCMgMc_Colonize_Upd(CUregIdx: integer);

implementation

uses
   farc_common_func
   ,farc_data_html
   ,farc_data_init
   ,farc_data_univ
   ,farc_data_textfiles
   ,farc_game_colony
   ,farc_game_cps
   ,farc_game_infra
   ,farc_game_infraconsys
   ,farc_missions_landing
   ,farc_missions_interplanetarytransit
   ,farc_missions_core
   ,farc_game_spmdata
   ,farc_gfx_core
   ,farc_main
   ,farc_ui_coldatapanel
   ,farc_ui_coredatadisplay
   ,farc_ui_msges
   ,farc_ui_surfpanel
   ,farc_ui_win
   ,farc_univ_func
   ,farc_win_debug;

//===================================END OF INIT============================================

procedure FCMgC_Colonize_PostProc(
   const CPPfac
         ,CPPspuIdx
         ,CPPssys
         ,CPPstar
         ,CPPobjIdx
         ,CPPsatIdx
         ,CPPregion: integer;
         CPPsettleTp: TFCEdgSettlements;
         CPPname
         ,CPPsettleName: string
   );
{:Purpose: colonize mission - post process.
    Additions:
      -2012Jun03- *mod: the colony panel is correctly updated when a colonization mission is completed and the surface panel is displayed.
      -2011Nov17- *add: update hardcoded resource data w/ updated data structure.
      -2011Oct19- *add: update hardcoded resource data w/ Ore Field specific values.
      -2011Oct11- *add: hardcoded resource spots data.
      -2011Jul24- *rem: the procedure doesn't update the colony data panel, it's already done when required.
      -2011Feb15- *add: update the surface panel if the destination orbital object/satellite is selected.
                  *add: display the settlement icon, if one is created and the surface panel focus on the destination object.
                  *add: if the surface panel is opened and display the destination orbital object, the colony data panel display too.
      -2011Feb12- *add: complete settlement code.
      -2011Feb11- *add: implement a settlement if needed before to add any infrastructure.
      -2010Sep16- *add: entities code.
      -2010Jul02- *add: colony name if set.
      -2010Jun06- *add: show the viability objectives panel when the first colony is created.
      -2010Jun02- *add: completion mission message.
      -2010May19- *add: faction # local data.
}
var
   CPPcolIdx
   ,CPPsettlement
   ,regionttl
   ,surfaceOObj
   ,surfaceSat: integer;

begin
   CPPsettlement:=0;
   {:DEV NOTES: resource survey data, TO REMOVE WHEN REGION SURVEY IS IMPLEMENTED.}
   SetLength(FCVdgPlayer.P_surveyedResourceSpots, 2);
   {:DEV NOTES: END HARCODED SURVEY DATA.}
   if CPPsatIdx=0
   then
   begin
      CPPcolIdx:=FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_colonies[0];
      {:DEV NOTES: resource survey data, TO REMOVE WHEN REGION SURVEY IS IMPLEMENTED.}
      regionttl:=length(FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_regions);
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_orbitalObject_SatelliteToken:=FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_dbTokenId;
      {:DEV NOTES: END HARCODED SURVEY DATA.}
   end
   else if CPPsatIdx>0
   then
   begin
      CPPcolIdx:=FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_satellitesList[CPPsatIdx].OO_colonies[0];
      {:DEV NOTES: resource survey data, TO REMOVE WHEN REGION SURVEY IS IMPLEMENTED.}
      regionttl:=length(FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_satellitesList[CPPsatIdx].OO_regions);
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_orbitalObject_SatelliteToken:=FCDduStarSystem[CPPssys].SS_stars[CPPstar].S_orbitalObjects[CPPobjIdx].OO_satellitesList[CPPsatIdx].OO_dbTokenId;
      {:DEV NOTES: END HARCODED SURVEY DATA.}
   end;
   {.establish the colony if no one exist}
   if CPPcolIdx=0
   then
   begin
      CPPcolIdx:=FCFgC_Colony_Core(
         gcaEstablished
         ,CPPfac
         ,CPPssys
         ,CPPstar
         ,CPPobjIdx
         ,CPPsatIdx
         );
      FCDdgEntities[CPPfac].E_colonies[CPPcolIdx].C_name:=CPPname;
      CPPsettlement:=FCFgC_Settlement_Add(
         CPPfac
         ,CPPcolIdx
         ,CPPregion
         ,CPPsettleTp
         ,CPPsettleName
         );
      surfaceOObj:=FCFuiSP_VarCurrentOObj_Get;
      surfaceSat:=FCFuiSP_VarCurrentSat_Get;
      if (surfaceOObj=CPPobjIdx)
         and (surfaceSat=CPPsatIdx)
         and (CPPfac=0)
      then FCMgfxC_Settlement_SwitchState(CPPregion);
      {:DEV NOTES: resource survey data, TO REMOVE WHEN REGION SURVEY IS IMPLEMENTED.}
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_starSystem:=CPPssys;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_star:=CPPstar;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_orbitalObject:=CPPobjIdx;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_satellite:=CPPsatIdx;
      setlength(FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions, regionttl);
      setlength(FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots, 2 );
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_meanQualityCoefficient:=0.7;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_spotSizeCurrent:=0;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_spotSizeMax:=50;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_type:=rstOreField;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_tOFiCarbonaceous:=25;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_tOFiMetallic:=25;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_tOFiRare:=25;
      FCVdgPlayer.P_surveyedResourceSpots[1].SRS_surveyedRegions[CPPregion].SR_ResourceSpots[1].RS_tOFiUranium:=25;
      {:DEV NOTES: END HARCODED SURVEY DATA.}
      FCMuiM_Message_Add(
         mtColonizeWset
         ,0
         ,CPPspuIdx
         ,CPPobjIdx
         ,CPPsatIdx
         ,CPPregion
         );
      FCcps.FCM_ViabObj_Init(true);
      FCcps.CPSisEnabled:=true;
   end
   else
   begin
      CPPsettlement:=FCFgC_Settlement_GetIndexFromRegion(
         CPPfac
         ,CPPcolIdx
         ,CPPregion
         );
      if CPPsettlement=0
      then
      begin
         CPPsettlement:=FCFgC_Settlement_Add(
            CPPfac
            ,CPPcolIdx
            ,CPPregion
            ,CPPsettleTp
            ,CPPsettleName
            );
         surfaceOObj:=FCFuiSP_VarCurrentOObj_Get;
         surfaceSat:=FCFuiSP_VarCurrentSat_Get;
         if (surfaceOObj=CPPobjIdx)
            and (surfaceSat=CPPsatIdx)
            and (CPPfac=0)
         then FCMgfxC_Settlement_SwitchState(CPPregion);
      end;
      FCMuiM_Message_Add(
         mtColonize
         ,0
         ,CPPspuIdx
         ,CPPobjIdx
         ,CPPsatIdx
         ,CPPregion
         );
   end;
   {.convert the LV in a colonization shelter}
   FCMgICS_Conversion_Process(
      CPPfac
      ,CPPspuIdx
      ,CPPcolIdx
      ,CPPsettlement
      );
   FCMgSPMD_Level_Upd(CPPfac);
   surfaceOObj:=FCFuiSP_VarCurrentOObj_Get;
   surfaceSat:=FCFuiSP_VarCurrentSat_Get;
   if (FCWinMain.FCWM_SurfPanel.Visible)
      and (CPPfac=0)
      and (surfaceOObj=CPPobjIdx)
      and (surfaceSat=CPPsatIdx)
   then
   begin
      FCMuiCDD_Colony_Update(
         cdlAll
         ,CPPcolIdx
         ,CPPsettlement
         ,0
         ,false
         ,false
         ,true
         );

//      FCWinMain.FCWM_ColDPanel.Show;
//      FCMuiSP_Panel_Relocate( false );
   end;
end;

procedure FCMgC_Colonize_Setup(
   const CSmethod: TFCEgcLVselTp;
   const CSowndMother
         ,CSssys
         ,CSstar
         ,CSoobjIdx
         ,CSsatIdx
         ,CSsatObjIdx: integer
   );
{:Purpose: core colonize mission setup.
    Additions:
      -2010Sep16- *add: entities code.
      -2010Apr27- *add: take in account if the trackbar is disabled/not visible.
}
var
   CSmax
   ,CScnt
   ,CSspuIdx: integer;

   CSdummy
   ,CSentVel
   ,CSdistDecel
   ,CSfinalVel: extended;
begin
   setlength(GMCdckd, 1);
   if CSmethod=gclvstBySelector
   then
   begin
      if CSsatIdx=0
      then
      begin
         if GMCbaseDist=0
         then GMCbaseDist:=FCFgMTrans_ObObjInLStar_CalcRng(
            FCDdgEntities[GMCfac].E_spaceUnits[CSowndMother].SU_linked3dObject
            ,CSoobjIdx
            ,gmtltSpUnit
            ,gmtltOrbObj
            ,false
            );
         CSentVel:=FCDduStarSystem[CSssys].SS_stars[CSstar].S_orbitalObjects[CSoobjIdx].OO_escapeVelocity;
      end
      else if CSsatIdx>0
      then
      begin
         if GMCbaseDist=0
         then GMCbaseDist:=FCFgMTrans_ObObjInLStar_CalcRng(
            FCDdgEntities[GMCfac].E_spaceUnits[CSowndMother].SU_linked3dObject
            ,CSsatObjIdx
            ,gmtltSpUnit
            ,gmtltSat
            ,false
            );
         CSentVel:=FCDduStarSystem[CSssys].SS_stars[CSstar].S_orbitalObjects[CSoobjIdx].OO_satellitesList[CSsatIdx].OO_escapeVelocity;
      end;
      {.distance conversion in m}
      CSdistDecel:=GMCbaseDist*CFC3dUnInKm*1000;
      {.begin the docked LV's setup}
      if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Visible
      then CSmax:=FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position
      else if not FCWinMain.FCWMS_Grp_MCG_RMassTrack.Visible
      then CSmax:=1;
      setlength(GMCdckd, CSmax+1);
      CScnt:=1;
      while CScnt<=CSmax do
      begin
         CSspuIdx:=FCDdgEntities[GMCfac].E_spaceUnits[CSowndMother].SU_dockedSpaceUnits[CScnt].SUDL_index;
         if (CScnt=1)
            and (GMCfinalDV=0)
         then
         begin
            CSfinalVel:=(CSentVel*7.8)/11.19;
            GMCfinalDV:=FCFcFunc_Rnd(cfrttpVelkms, CSfinalVel);
         end;
         FCFgMl_Land_Calc(
            GMCfac
            ,CSspuIdx
            ,CSssys
            ,CSstar
            ,CSoobjIdx
            ,CSsatIdx
            ,CSsatObjIdx
            ,CSdistDecel
            ,GMCfinalDV
            ,false
            );
         GMCdckd[CScnt].GMCD_index:=CSspuIdx;
         GMCdckd[CScnt].GMCD_landTime:=GMClandTime;
         GMCdckd[CScnt].GMCD_tripTime:=GMCtripTime;
         GMCdckd[CScnt].GMCD_usedRM:=GMCusedRMvol;
         inc(CScnt);
      end; //==END== while CScnt<=CSmax ==//
   end; //==END== if CSmethod=gclvstBySelector ==//
end;

procedure FCMgMc_Colonize_Upd(CUregIdx: integer);
{:Purpose: update region selection and update mission configuration.
    Additions:
      -2010May03- *fix: fixed a critical bug.
}
var
   CUtimeMin
   ,CUtimeMax
   ,CUmax
   ,CUcnt: integer;

   CUregLoc: string;

   CUarrTime: array of integer;
begin
   CUregLoc:=FCFuF_RegionLoc_Extract(
      GMCrootSsys
      ,GMCrootStar
      ,GMCrootOObIdx
      ,GMCrootSatIdx
      ,CUregIdx
      );
   CUcnt:=1;
   CUmax:=length(GMCdckd)-1;
   SetLength(CUarrTime, CUmax+1);
   while CUcnt<=CUmax do
   begin
      CUarrTime[CUcnt-1]:=GMCdckd[CUcnt].GMCD_landTime+GMCdckd[CUcnt].GMCD_tripTime;
      inc(CUcnt);
   end;
   CUtimeMin:=MinIntValue(CUarrTime);
   CUtimeMax:=MaxIntValue(CUarrTime);
   {.update selected region location idx=3}
   FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Insert(
      3
      ,FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_SP_ShReg')+' ['
      +CUregLoc+']<br>'
      );
   FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Delete(4);
   {.update mission data}
   FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Insert(
      1
      ,FCFdTFiles_UIStr_Get(uistrUI, 'MCGatmEntDV')+' '+FloatToStr(GMCfinalDV)+' km/s<br>'
         +FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI,'MCGDatTripTime')+FCCFdHeadEnd
         +FCFdTFiles_UIStr_Get(uistrUI, 'MCGDatMinTime')+' '+FCFcFunc_TimeTick_GetDate(CUtimeMin)
         +'<br>'+FCFdTFiles_UIStr_Get(uistrUI, 'MCGDatMaxTime')+' '+FCFcFunc_TimeTick_GetDate(CUtimeMax)
      );
   FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Delete(2);
   if not FCWinMain.FCWMS_ButProceed.Enabled
   then FCWinMain.FCWMS_ButProceed.Enabled:=true;
end;

end.
