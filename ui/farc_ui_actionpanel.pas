{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: action panel - core unit

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
unit farc_ui_actionpanel;

interface

uses
   SysUtils;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   popup the action panel at specified position
///</summary>
///   <param name="positionX">position X</param>
///   <param name="positionY">position Y</param>
procedure FCMuiAP_Panel_PopupAtPos( const positionX, positionY: integer );

///<summary>
///   reset the action panel choices
///</summary>
procedure FCMuiAP_Panel_Reset;

///<summary>
///   resize the action panel according to the number of items
///</summary>
procedure FCMuiAP_Panel_Resize;

///<summary>
///   update the action panel w/ orbital object actions
///</summary>
///<remarks>reset the choices</remarks>
procedure FCMuiAP_Update_OrbitalObject;

///<summary>
///   update the action panel w/ space unit actions
///</summary>
///<remarks>reset the choices</remarks>
procedure FCMuiAP_Update_SpaceUnit;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_game_cps
   ,farc_data_3dopengl
   ,farc_data_game
   ,farc_data_init
   ,farc_data_missionstasks
   ,farc_data_spu
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_main
   ,farc_spu_functions
   ,farc_univ_func
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   ///<summary>
   ///   # of items, by 1 by 1 choice and by 0.5 by separator
   ///</summary>
   FCVuiapItems: extended;
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiAP_Panel_PopupAtPos( const positionX, positionY: integer );
{:Purpose: popup the action panel at specified position.
    Additions:
}
   var
      ValueMaxX
      ,ValueMaxY: integer;
begin
   ValueMaxX:=FCWinMain.FCGLSmainView.Width-2-FCWinMain.WM_ActionPanel.Width;
   ValueMaxY:=FCWinMain.FCGLSmainView.Height-8-FCWinMain.WM_ActionPanel.Height;
   if positionX>ValueMaxX
   then FCWinMain.WM_ActionPanel.Left:=ValueMaxX
   else FCWinMain.WM_ActionPanel.Left:=positionX;
   if positionY<12
   then FCWinMain.WM_ActionPanel.Top:=12
   else if positionY>ValueMaxY
   then FCWinMain.WM_ActionPanel.Top:=ValueMaxY
   else FCWinMain.WM_ActionPanel.Top:=positionY;
   FCWinMain.WM_ActionPanel.Show;
   FCWinMain.WM_ActionPanel.BringToFront;
end;

procedure FCMuiAP_Panel_Reset;
{:Purpose: reset the action panel choices.
    Additions:
      -2012Dec02- *add: AP_OObjData + AP_DetailedData + AP_DockingList.
}
begin
   FCVuiapItems:=0;
   FCWinMain.AP_ColonyData.Hide;
   FCWinMain.AP_OObjData.Hide;
   FCWinMain.AP_DetailedData.Hide;
   FCWinMain.AP_DockingList.Hide;
   FCWinMain.AP_Separator1.Hide;
   FCWinMain.AP_MissionColonization.Hide;
   FCWinMain.AP_MissionInterplanetaryTransit.Hide;
   FCWinMain.AP_MissionCancel.Hide;
end;

procedure FCMuiAP_Panel_Resize;
{:Purpose: resize the action panel according to the number of items.
    Additions:
}
begin
   FCWinMain.WM_ActionPanel.Height:=20+round( FCVuiapItems*16 );
end;

procedure FCMuiAP_Update_OrbitalObject;
{:Purpose: update the action panel w/ orbital object actions.
    Additions:
      -2012Dec02- *add: routine completion.
}
begin
   FCMuiAP_Panel_Reset;
   FCWinMain.WM_ActionPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get(uistrUI,'ActionPanelHeader.OObj')+'</b>';
   if (
      (FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid])
      and (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_colonies[0]>0)
      )
      or
      (
      (FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedPlanetAsteroid])
      and (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_satellitesList[FC3doglSelectedSatellite].OO_colonies[0]>0)
      )
   then
   begin
      FCWinMain.AP_ColonyData.Show;
      FCVuiapItems:=FCVuiapItems+1;
   end
   else if FC3doglSelectedPlanetAsteroid>0 then
   begin
      FCWinMain.AP_OObjData.Show;
      FCVuiapItems:=FCVuiapItems+1;
   end;
   FCMuiAP_Panel_Resize;
end;

procedure FCMuiAP_Update_SpaceUnit;
{:Purpose: update the action panel w/ space unit actions.
    Additions:
      -2012Dec16- *add: mission cancel is expanded w/ conditions.
      -2012Dec09- *add: mission cancel.
      -2012Dec03- *add: routine completion.
}
   var
      Design
      ,DockedSpaceUnits
      ,NumberOfColonies //FPUcolN:=
      ,SpaceUnit: integer; //FPUdmpIdx

      Location: TFCRufStelObj;
begin
   FCMuiAP_Panel_Reset;
   FCWinMain.WM_ActionPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get(uistrUI,'ActionPanelHeader.SpU')+'</b>';
   Design:=0;
   DockedSpaceUnits:=0;
   NumberOfColonies:=0;
   SpaceUnit:=round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat);
   Location:=FCFuF_StelObj_GetFullRow(
      FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_locationStarSystem
      ,FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_locationStar
      ,FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_locationOrbitalObject
      ,FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_locationSatellite
      );
   {.detailed data}
   {DEV NOTE: to add when i'll implement a detailed data panel.}
   FCWinMain.AP_DetailedData.Show;
   FCWinMain.AP_DetailedData.Top:=999;
   FCVuiapItems:=FCVuiapItems+1;
   {.docking list}
   if length(FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_dockedSpaceUnits)>1 then
   begin
      FCWinMain.AP_DockingList.Show;
      FCWinMain.AP_DockingList.Top:=999;
      FCVuiapItems:=FCVuiapItems+1;
   end;
   if FCVuiapItems>0 then
   begin
      FCWinMain.AP_Separator1.Show;
      FCWinMain.AP_Separator1.Top:=999;
      FCVuiapItems:=FCVuiapItems+0.75;
   end;
   {.missions}
   if FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_reactionMass>0 then
   begin
      {.colonization mission}
      {:DEV NOTES: include the possibility when there's no docked spu but the focused spu has colonization capability.}
      DockedSpaceUnits:=FCFspuF_DockedSpU_GetNum(
         0
         ,SpaceUnit
         ,aLV
         ,sufcColoniz
         );
      NumberOfColonies:=length(FCDdgEntities[0].E_colonies)-1;
      {:DEV NOTES: if = 0, test if focused spu has capability
         FCFspuF_Capability_HasIt
         when eq mdl done, change the line below for more complex code testing
         colonization equipment module and/or have docked colonization pods
      .}
      if ( ( DockedSpaceUnits>0 ) and ( FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_name='wrdMUNmov' ) )
      {:DEV NOTES: new ione must be if ( ( DockedSpaceUnits>0 ) or ( FCFspuF_Capability_HasIt ) ).}
         and (FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_status=susInOrbit)
         and (
            not assigned(FCcps)
               or (
                  assigned(FCcps)
                  and (
                     (NumberOfColonies=0)
                        or ( (NumberOfColonies=1) and(Location[4]=0) and (FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_colonies[0]>0) )
                        or ( (NumberOfColonies=1) and (Location[4]>0) and (FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_satellitesList[Location[4]].OO_colonies[0]>0) )
                     )
                  )
               )
      then
      begin
         FCWinMain.AP_MissionColonization.Show;
         FCWinMain.AP_MissionColonization.Top:=999;
         FCVuiapItems:=FCVuiapItems+1;
      end;
      {.interplanetary transit mission}
      if (FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_status in [susInFreeSpace..susDocked])
         and (FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask=0)
      then
      begin
         FCWinMain.AP_MissionInterplanetaryTransit.Show;
         FCWinMain.AP_MissionInterplanetaryTransit.Top:=999;
         FCVuiapItems:=FCVuiapItems+1;
      end;
      {.cancel current mission}
      if ( FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask>0 ) then
      begin
         case FCDdmtTaskListInProcess[FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask].T_type of
            tMissionColonization:
            begin
               Design:=FCFspuF_Design_getDB( FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_designToken );
               if ( FCDdmtTaskListInProcess[FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask].T_tMCphase=mcpDeceleration )
                  and ( FCDdsuSpaceUnitDesigns[Design].SUD_internalStructureClone.IS_architecture<>aLV ) then
               begin
                  FCWinMain.AP_MissionCancel.Show;
                  FCWinMain.AP_MissionCancel.Top:=999;
                  FCVuiapItems:=FCVuiapItems+1;
               end;
            end;

            tMissionInterplanetaryTransit:
            begin
               if ( FCDdmtTaskListInProcess[FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask].T_tMITphase=mitpAcceleration )
                  and ( FCVdgPlayer.P_currentTimeTick<=FCDdmtTaskListInProcess[FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask].T_inProcessData.IPD_ticksAtTaskStart+( FCDdmtTaskListInProcess[FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask].T_tMITcruiseTime*0.5 ) )
                  and ( FCDdmtTaskListInProcess[FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask].T_tMIToriginIndex<>FCDdmtTaskListInProcess[FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask].T_tMITdestinationIndex )
                  and (
                     ( FCDdmtTaskListInProcess[FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask].T_tMITdestinationSatIndex=0)
                     or (
                        ( FCDdmtTaskListInProcess[FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask].T_tMITdestinationSatIndex>0)
                           and ( FCDdmtTaskListInProcess[FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask].T_tMIToriginSatIndex<>FCDdmtTaskListInProcess[FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_assignedTask].T_tMITdestinationSatIndex )
                        )
                     ) then
               begin
                  FCWinMain.AP_MissionCancel.Show;
                  FCWinMain.AP_MissionCancel.Top:=999;
                  FCVuiapItems:=FCVuiapItems+1;
               end;
            end;
         end;
      end;
   end; //==END== if ( FCVuiapItems>0 ) and ( FCDdgEntities[0].E_spaceUnits[SpaceUnit].SU_reactionMass>0 ) ==//
   FCMuiAP_Panel_Resize;
end;

end.
