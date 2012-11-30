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
   farc_data_3dopengl
   ,farc_data_init
   ,farc_data_univ
   ,farc_main
   ,farc_data_textfiles
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
}
begin
   FCVuiapItems:=0;
   FCWinMain.AP_ColonyData.Hide;
   FCWinMain.AP_Separator1.Hide;
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
}
begin
   FCMuiAP_Panel_Reset;
   FCWinMain.WM_ActionPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get(uistrUI,'ActionPanelHeader.OObj')+'</b>';
   {.colony/faction data}
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
//      FCWinMain.AP_Separator1.Show;
//      FCVuiapItems:=FCVuiapItems+0.5
//      FCWinMain.FCWM_PMFOoobjData.Visible:=false;
   end
//   else if FC3doglSelectedPlanetAsteroid>0
//   then FCWinMain.FCWM_PMFOoobjData.Visible:=true
   ;
   FCMuiAP_Panel_Resize;
end;

procedure FCMuiAP_Update_SpaceUnit;
{:Purpose: update the action panel w/ space unit actions.
    Additions:
}
begin
   FCMuiAP_Panel_Reset;
   FCWinMain.WM_ActionPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get(uistrUI,'ActionPanelHeader.SpU')+'</b>';
end;

end.
