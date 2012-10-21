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
///   load the FCVuimsCurrentColony with a given value
///</summary>
///   <param name="Value">value to load FCVuimsCurrentColony with</param>
procedure FCFuiMS_CurrentColony_Load( const Value: integer );

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
procedure FCMgMCore_Mission_ClosePanel;

///<summary>
///   update the trackbar.
///</summary>
///   <param name="MTUmission">current mission type</param>
procedure FCMgMCore_Mission_TrackUpd(const MTUmission: TFCEdmtTasks);

///<summary>
///   setup the interface for the colonization mission
///</summary>
procedure FCMuiMS_ColonizationInterface_Setup;

///<summary>
///   reset all the interface elements of the mission panel, and set correctly any interface
///   element outside the mission panel
///</summary>
procedure FCMuiMS_Panel_Initialize;

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_html
   ,farc_data_textfiles
   ,farc_data_spu
   ,farc_main
   ,farc_missions_core
   ,farc_spu_functions
   ,farc_ui_keys
   ,farc_ui_msges
   ,farc_ui_surfpanel;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   ///<summary>
   ///   colony index # currently loaded in the mission setup interface
   ///</summary>
   FCVuimsCurrentColony: integer;

   FCVuimsIndX: string;
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

procedure FCFuiMS_CurrentColony_Load( const Value: integer );
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
   then FCMgMCore_Mission_ClosePanel
   else if (WMSTkeyDump<>65)
      and (WMSTkeyDump<>67)
      and (WMSTkeyDump<>27)
   then FCMuiK_WinMain_Test(WMSTkeyDump, WMSTshftCtrl);
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
//   FCVdiGameFlowTimer.Enabled:=true;
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
//var
//   MTUsatObj: integer;
begin
//   case MTUmission of
//      tMissionColonization:
//      begin
//         FCWinMain.FCWMS_Grp_MCG_RMassTrack.TrackLabel.Format:=IntToStr(FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position);
//         if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag=0
//         then
//         begin
//
//            if GMCrootSatIdx>0
//            then MTUsatObj:=FCFoglVM_SatObj_Search(GMCrootOObIdx, GMCrootSatIdx)
//            else MTUsatObj:=0;
//            FCMgC_Colonize_Setup(
//               gclvstBySelector
//               ,GMCmother
//               ,GMCrootSsys
//               ,GMCrootStar
//               ,GMCrootOObIdx
//               ,GMCrootSatIdx
//               ,MTUsatObj
//               );
//         end
//         else if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag=1
//         then FCWinMain.FCWMS_Grp_MCG_RMassTrack.Tag:=0;
//      end;
//      tMissionInterplanetaryTransit:
//      begin
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
//      end;
//   end; //==END== case MTUmission of ==//
//   {.update the trackbar label}
end;

procedure FCMuiMS_ColonizationInterface_Setup;
{:Purpose: setup the interface for the colonization mission
    Additions:
}
   var
      SpaceDesign
      ,SpaceUnit: integer;
begin
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
   FCWinMain.FCWMS_Grp_MSDG_Disp.HTMLText.Add(FloatToStr(FCFcFunc_ScaleConverter(cf3dct3dViewUnitToKm, FCRmcCurrentMissionCalculations.CMC_baseDistance))+' km');
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

end.