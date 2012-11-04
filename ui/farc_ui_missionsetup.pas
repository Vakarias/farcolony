{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: space units mission - interface unit

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
unit farc_ui_missionsetup;

interface

uses
   Classes
   ,Math
   ,SysUtils

   ,farc_data_missionstasks;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   retrieve the FCVuimsCurrentColony
///</summary>
///   <returns>the FCVuimsCurrentColony value</returns>
function FCFuiMS_CurrentColony_Get: integer;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   update region selection and update mission configuration
///</summary>
///   <param name="CUregIdx"></param>
procedure FCMuiMS_ColonizationInterface_UpdateRegionSelection(CUregIdx: integer);

///<summary>
///   setup the interface for the colonization mission
///</summary>
procedure FCMuiMS_ColonizationInterface_Setup;

///<summary>
///   load the FCVuimsCurrentColony with a given value
///</summary>
///   <param name="Value">value to load FCVuimsCurrentColony with</param>
procedure FCMuiMS_CurrentColony_Load( const Value: integer );

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
///   core routine for mission panel closing
///</summary>
procedure FCMuiMS_Planel_Close;

///<summary>
///   reset all the interface elements of the mission panel, and set correctly any interface
///   element outside the mission panel
///</summary>
procedure FCMuiMS_Panel_Initialize;

///<summary>
///   update the trackbar.
///</summary>
///   <param name="MTUmission">current mission type</param>
procedure FCMuiMS_TrackBar_Update(const MTUmission: TFCEdmtTasks);

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_html
   ,farc_data_textfiles
   ,farc_data_spu
   ,farc_data_univ
   ,farc_main
   ,farc_missions_core
   ,farc_missions_colonization
   ,farc_spu_functions
   ,farc_ui_keys
   ,farc_ui_msges
   ,farc_ui_surfpanel
   ,farc_univ_func;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   ///<summary>
   ///   colony index # currently loaded in the mission setup interface
   ///</summary>
   FCVuimsCurrentColony: integer;

   FCVuimsIndX: string;

   FCVuimsIsTrackbarProcess: boolean;
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFuiMS_CurrentColony_Get: integer;
{:Purpose: retrieve the FCVuimsCurrentColony.
    Additions:
}
begin
   Result:=FCVuimsCurrentColony;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiMS_ColonizationInterface_UpdateRegionSelection(CUregIdx: integer);
{:Purpose: update region selection and update mission configuration.
    Additions:
      -2012Oct30- *mod: update the routine with the last changes for the alpha 4.
                  *add: the case for not docked space units.
      -2010May03- *fix: fixed a critical bug.
}
var
   CUtimeMin
   ,CUtimeMax
   ,CUmax
   ,CUcnt: integer;
//
   CUregLoc: string;
//
   CUarrTime: array of integer;
begin
   SetLength(CUarrTime, 1);
   CUregLoc:=FCFuF_RegionLoc_Extract(
      FCRmcCurrentMissionCalculations.CMC_originLocation[1]
      ,FCRmcCurrentMissionCalculations.CMC_originLocation[2]
      ,FCRmcCurrentMissionCalculations.CMC_originLocation[3]
      ,FCRmcCurrentMissionCalculations.CMC_originLocation[4]
      ,FCRmcCurrentMissionCalculations.CMC_regionOfDestination
      );
   CUcnt:=1;
   CUmax:=length(FCRmcCurrentMissionCalculations.CMC_dockList)-1;
   if CUmax=0 then
   begin
      CUtimeMin:=FCRmcCurrentMissionCalculations.CMC_landTime+FCRmcCurrentMissionCalculations.CMC_tripTime;
      CUtimeMax:=CUtimeMin;
   end
   else if CUmax>0 then
   begin
      SetLength(CUarrTime, CUmax+1);
      while CUcnt<=CUmax do
      begin
         CUarrTime[CUcnt-1]:=FCRmcCurrentMissionCalculations.CMC_dockList[CUcnt].DL_landTime+FCRmcCurrentMissionCalculations.CMC_dockList[CUcnt].DL_tripTime;
         inc(CUcnt);
      end;
      CUtimeMin:=MinIntValue(CUarrTime);
      CUtimeMax:=MaxIntValue(CUarrTime);
      if CUtimeMin=0
      then CUtimeMin:=CUtimeMax;
   end;
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
      ,FCFdTFiles_UIStr_Get(uistrUI, 'MCGatmEntDV')+' '+FloatToStr(FCRmcCurrentMissionCalculations.CMC_finalDeltaV)+' km/s<br>'
         +FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI,'MCGDatTripTime')+FCCFdHeadEnd
         +FCFdTFiles_UIStr_Get(uistrUI, 'MCGDatMinTime')+' '+FCFcFunc_TimeTick_GetDate(CUtimeMin)
         +'<br>'+FCFdTFiles_UIStr_Get(uistrUI, 'MCGDatMaxTime')+' '+FCFcFunc_TimeTick_GetDate(CUtimeMax)
      );
   FCWinMain.FCWMS_Grp_MCG_MissCfgData.HTMLText.Delete(2);
   if not FCWinMain.FCWMS_ButProceed.Enabled
   then FCWinMain.FCWMS_ButProceed.Enabled:=true;
end;

procedure FCMuiMS_ColonizationInterface_Setup;
{:Purpose: setup the interface for the colonization mission
    Additions:
}
   var
      MaxDocked
      ,SpaceDesign
      ,SpaceUnit: integer;

      Environment: TFCEduEnvironmentTypes;
begin
   MaxDocked:=0;
   SpaceDesign:=0;
   SpaceUnit:=0;
   if FCRmcCurrentMissionCalculations.CMC_originLocation[4]=0
   then Environment:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]].OO_environment
   else if FCRmcCurrentMissionCalculations.CMC_originLocation[4]>0
   then Environment:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]].OO_satellitesList[FCRmcCurrentMissionCalculations.CMC_originLocation[4]].OO_environment;
   if FCDmcCurrentMission[0].T_tMCorigin=ttSelf
   then SpaceUnit:=FCDmcCurrentMission[0].T_controllerIndex
   else if FCDmcCurrentMission[0].T_tMCorigin=ttSpaceUnitDockedIn
   then SpaceUnit:=FCDmcCurrentMission[0].T_tMCoriginIndex;
   SpaceDesign:=FCFspuF_Design_getDB( FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_designToken );
   FCWinMain.FCWM_MissionSettings.Caption.Text:=FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet')+FCFdTFiles_UIStr_Get(uistrUI,'Mission.coloniz');
   if ( FCFuiSP_VarCurrentOObj_Get<>FCRmcCurrentMissionCalculations.CMC_originLocation[3] )
      and ( ( FCFuiSP_VarCurrentSat_Get=0 ) or ( ( FCFuiSP_VarCurrentSat_Get>0 ) and ( FCFuiSP_VarCurrentSat_Get<>FCRmcCurrentMissionCalculations.CMC_originLocation[4] ) ) )
   then FCMuiSP_SurfaceEcosphere_Set( FCRmcCurrentMissionCalculations.CMC_originLocation[3], FCRmcCurrentMissionCalculations.CMC_originLocation[4], false)
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
   {.idx=0}
   FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add( FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI,'MSDGmotherSpUnIdStat')+FCCFdHeadEnd );
   {.idx=1}
   FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(
      FCFdTFiles_UIStr_Get(dtfscPrprName, FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_name)+' '
      +FCFdTFiles_UIStr_Get( dtfscSCarchShort, FCDdsuSpaceUnitDesigns[SpaceDesign].SUD_internalStructureClone.IS_architecture)
      +' '+FCFspuF_AttStatus_Get( 0, SpaceUnit )+'<br>'
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
   FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(FCFcFunc_ThSep(FCFcFunc_ScaleConverter(cf3dct3dViewUnitToKm, FCRmcCurrentMissionCalculations.CMC_baseDistance))+' km');
   {.trackbar with docked space units}
   MaxDocked:=length( FCRmcCurrentMissionCalculations.CMC_dockList )-1;
   FCWinMain.FCWMS_Grp_MCG_RMassTrack.Left:=12;
   FCWinMain.FCWMS_Grp_MCG_RMassTrack.Top:=28;
   FCWinMain.FCWMS_Grp_MCG_RMassTrack.Min:=0;
   FCWinMain.FCWMS_Grp_MCG_RMassTrack.Max:=0;
   FCVuimsIsTrackbarProcess:=false;
   FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position:=0;
   if MaxDocked<=0
   then
   begin
      FCWinMain.FCWMS_Grp_MCG_RMassTrack.Visible:=false;
      FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
   end
   else if MaxDocked>0
   then
   begin
      FCWinMain.FCWMS_Grp_MCG_RMassTrack.Min:=1;
      FCWinMain.FCWMS_Grp_MCG_RMassTrack.Max:=MaxDocked;
      FCVuimsIsTrackbarProcess:=true;
      FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position:=1;
      FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Format:=IntToStr(FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position);
   end;
   {.colony name}
   FCWinMain.FCWMS_Grp_MCGColName.Left:=FCWinMain.FCWMS_Grp_MCG_RMassTrack.Left+(FCWinMain.FCWMS_Grp_MCG_RMassTrack.Width shr 1)-(FCWinMain.FCWMS_Grp_MCGColName.Width shr 1);
   FCWinMain.FCWMS_Grp_MCGColName.Top:=FCWinMain.FCWMS_Grp_MCG_RMassTrack.Top+FCWinMain.FCWMS_Grp_MCG_RMassTrack.Height+24;
   if FCVuimsCurrentColony=0
   then
   begin
      FCRmcCurrentMissionCalculations.CMC_colonyAlreadyExisting:=0;
      FCWinMain.FCWMS_Grp_MCGColName.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcolNameNo');
      FCWinMain.FCWMS_Grp_MCGColName.Show;
   end
   else if FCVuimsCurrentColony>0
   then
   begin
      FCRmcCurrentMissionCalculations.CMC_colonyAlreadyExisting:=FCVuimsCurrentColony;
      FCWinMain.FCWMS_Grp_MCGColName.Text:='';
      FCWinMain.FCWMS_Grp_MCGColName.Hide;
   end;
   {.settlement type}
   FCWinMain.FCWMS_Grp_MCG_SetType.Left:=FCWinMain.FCWMS_Grp_MCGColName.Left-4;
   FCWinMain.FCWMS_Grp_MCG_SetType.Top:=FCWinMain.FCWMS_Grp_MCGColName.Top+FCWinMain.FCWMS_Grp_MCGColName.Height+4;
   FCWinMain.FCWMS_Grp_MCG_SetType.ItemIndex:=-1;
   FCWinMain.FCWMS_Grp_MCG_SetType.Items.Clear;
   if Environment<etSpace
   then
   begin
      FCWinMain.FCWMS_Grp_MCG_SetType.Items.Add( FCFdTFiles_UIStr_Get(uistrUI, 'FCWMS_Grp_MCG_SetType0') );
      FCWinMain.FCWMS_Grp_MCG_SetType.Items.Add( FCFdTFiles_UIStr_Get(uistrUI, 'FCWMS_Grp_MCG_SetType2') );
   end
   else if Environment=etSpace
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
end;

procedure FCMuiMS_CurrentColony_Load( const Value: integer );
{:Purpose: load the FCVuimsCurrentColony with a given value.
    Additions:
}
begin
   FCVuimsCurrentColony:=Value;
end;

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
   then FCMuiMS_Planel_Close
   else if (WMSTkeyDump<>65)
      and (WMSTkeyDump<>67)
      and (WMSTkeyDump<>27)
   then FCMuiK_WinMain_Test(WMSTkeyDump, WMSTshftCtrl);
end;

procedure FCMuiMS_Planel_Close;
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
//   FCVdiGameFlowTimer.Enabled:=true;
end;

procedure FCMuiMS_Panel_Initialize;
{:Purpose: reset all the interface elements of the mission panel, and set correctly any interface.
    Additions:
}
begin
   FCWinMain.FCWM_MissionSettings.Enabled:=true;
   FCMuiM_MessageBox_ResetState(true);
   FCWinMain.FCWM_ColDPanel.Hide;
   FCWinMain.FCWM_UMI.Hide;
   FCWinMain.FCWM_MissionSettings.Caption.Text:='';
   FCWinMain.FCWMS_Grp_MCGColName.Text:='';
   FCWinMain.FCWMS_Grp_MCG_SetName.Text:='';
   FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Clear;
   FCWinMain.FCWMS_Grp_MCG_DatDisp.HTMLText.Clear;
   FCVuimsIndX:='<ind x="'+IntToStr(FCWinMain.FCWMS_Grp_MSDG.Width shr 1)+'">';
end;

procedure FCMuiMS_TrackBar_Update(const MTUmission: TFCEdmtTasks);
{:Purpose: update the trackbar.
    Additions:
      -2012Oct30- *mod: complete update of the colonization mission.
      -2010Apr26- *fix: stop the bug of updating for a colonize mission when the trackbar is resetted.
      -2010Apr17- *add: colonization setup data update.
      -2010Apr10- *add: mission type.
                  *add: update for colonization mission.
      -2009Oct24- *update trip data.
                  *prevent update trip data when initializing.
      -2009Oct19- *change the number of levels.
}
begin
   case MTUmission of
      tMissionColonization:
      begin
         FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Format:=IntToStr(FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position);
         if ( not FCVuimsIsTrackbarProcess )
            and (FCWinMain.FCWMS_Grp_MCG_RMassTrack.Visible)
         then FCVuimsIsTrackbarProcess:=true
         else if FCVuimsIsTrackbarProcess
         then FCMmC_Colonization_Setup(
            cmDockingList
            ,FCDmcCurrentMission[0].T_tMCoriginIndex
            );
      end;

      tMissionInterplanetaryTransit:
      begin
//         case FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position of
//            1: FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Format
//               :=FCFdTFiles_UIStr_Get(uistrUI,'FCWMS_Grp_MCG_RMassTrackITransEco');
//            2: FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Format
//               :=FCFdTFiles_UIStr_Get(uistrUI,'FCWMS_Grp_MCG_RMassTrackITransSlow');
//            3: FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Format
//               :=FCFdTFiles_UIStr_Get(uistrUI,'FCWMS_Grp_MCG_RMassTrackITransFast');
//         end;
//         if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag=0
//         then FCMgMCore_Mission_DestUpd(true)
//         else if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag=1
//         then FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag:=0;
      end;
   end; //==END== case MTUmission of ==//
//   {.update the trackbar label}
end;

end.
