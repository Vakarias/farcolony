{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: planetary survey - user's interface unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2013, Jean-Francois Baconnet

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
unit farc_ui_planetarysurvey;

interface

uses
   ComCtrls
   ,SysUtils

   ,farc_data_game;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   init the elements (size and location) of the panel
///</summary>
procedure FCMuiPS_Panel_InitElements;

///<summary>
///   init the fonts of the panel
///</summary>
procedure FCMuiPS_Panel_InitFonts;

///<summary>
///   init the texts of the panel
///</summary>
procedure FCMuiPS_Panel_InitText;

///<summary>
///   show the panel
///</summary>
///   <param name="TypeOfSurvey">configure the panel for a specified type of survey</param>
procedure FCMuiPS_Panel_Show( const TypeOfSurvey: TFCEdgPlanetarySurveys );

///<summary>
///   process the add button
///</summary>
procedure FCMuiPS_VehiclesSetup_Add;

///<summary>
///   process the addmax button
///</summary>
procedure FCMuiPS_VehiclesSetup_AddMax;

///<summary>
///   update the current crew available
///</summary>
procedure FCMuiPS_VehiclesSetup_CrewFormat;

implementation

uses
   farc_data_html
   ,farc_data_init
   ,farc_data_infrprod
   ,farc_data_planetarysurvey
   ,farc_data_textfiles
   ,farc_main
   ,farc_survey_functions
   ,farc_ui_coldatapanel
   ,farc_ui_surfpanel
   ,farc_ui_win
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================



//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   PSvehiclesCrewUsed: integer;

   PSvehiclesListMax: integer;

   PScurrentProducts: array of integer;

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFuiPS_AvailableCrew_GetValue: integer;
{:Purpose: calculate the available crew for the current expedition setup.
    Additions:
}
begin
   Result:=0;
   Result:=FCDdgEntities[0].E_colonies[FCFuiCDP_VarCurrentColony_Get].C_population.CP_classColonist-FCDdgEntities[0].E_colonies[FCFuiCDP_VarCurrentColony_Get].C_population.CP_classColonistAssigned-PSvehiclesCrewUsed;
end;

function FCFuiPS_VehiclesSetup_EntryFormat(
   const VehicleCapability
         ,Crew
         ,ChoosenUnits
         ,StorageUnits: integer
   ): string;
{:Purpose: generate an entry line for a vehicle.
    Additions:
}
   var
      RedFormat
      ,RedFormatEnd: string;
begin
   RedFormat:='';
   RedFormatEnd:='';
   Result:='';
   if ( Crew>0 )
      and ( FCFuiPS_AvailableCrew_GetValue<Crew ) then
   begin
      RedFormat:=FCCFcolRed;
      RedFormatEnd:=FCCFcolEND
   end;
   Result:='Capability [<b>'+IntToStr( VehicleCapability )+'</b>]  Crew [<b>'+RedFormat+IntToStr( Crew )+RedFormatEnd+'</b>]  Units [<b>'+inttostr( ChoosenUnits )+' / '+inttostr( StorageUnits )+'</b>]';
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiPS_Panel_InitElements;
{:Purpose: init the elements (size and location) of the panel.
    Additions:
      -2013Feb12- *add: PSP_ProductsList init.
}
begin
   FCWinMain.MVG_PlanetarySurveyPanel.Width:=350;
   FCWinMain.MVG_PlanetarySurveyPanel.Height:=500;
   FCWinMain.PSP_ProductsList.Width:=FCWinMain.MVG_PlanetarySurveyPanel.Width-8;
   FCWinMain.PSP_ProductsList.Height:=200;
   FCWinMain.PSP_ProductsList.Left:=4;
   FCWinMain.PSP_ProductsList.Top:=60;
end;

procedure FCMuiPS_Panel_InitFonts;
{:Purpose: init the fonts of the panel.
    Additions:
}
begin
   FCWinMain.MVG_PlanetarySurveyPanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
   FCWinMain.PSP_Label.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
   FCWinMain.PSP_ProductsList.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
end;

procedure FCMuiPS_Panel_InitText;
{:Purpose: init the texts of the panel.
    Additions:
}
begin
   FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='';
end;

procedure FCMuiPS_Panel_Show( const TypeOfSurvey: TFCEdgPlanetarySurveys );
{:Purpose: show the panel.
    Additions:
}
   var
      Count
      ,CountProduct: integer;

      ProductNode: TTreeNode;
begin
   SetLength( PScurrentProducts, 6 );
   PSvehiclesListMax:=0;
   PSvehiclesCrewUsed:=0;
   case TypeOfSurvey of
      psResources:
      begin
         FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psTitleResources' );
         FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:=FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text+'  Region:'+inttostr( FCFuiSP_VarRegionSelected_Get );
         FCWinMain.MVG_PlanetarySurveyPanel.Left:=FCWinMain.MVG_SurfacePanel.Left+FCWinMain.MVG_SurfacePanel.Width-FCWinMain.SP_RegionSheet.Width;
         FCWinMain.MVG_PlanetarySurveyPanel.Top:=FCWinMain.MVG_SurfacePanel.Top;
         FCWinMain.PSP_Label.HTMLText.Clear;
         FCWinMain.PSP_Label.HTMLText.Add( FCCFdHeadC+'Set up An Expedition'+FCCFdHeadEnd );
         FCWinMain.PSP_Label.HTMLText.Add( 'Current Crew Available: '+IntToStr( FCDdgEntities[0].E_colonies[FCFuiCDP_VarCurrentColony_Get].C_population.CP_classColonist-FCDdgEntities[0].E_colonies[FCFuiCDP_VarCurrentColony_Get].C_population.CP_classColonistAssigned-PSvehiclesCrewUsed ) );
         PSvehiclesListMax:=FCFsF_SurveyVehicles_Get(
            0
            ,FCFuiCDP_VarCurrentColony_Get
            ,false
            );
         FCWinMain.PSP_ProductsList.Items.Clear;
         Count:=1;
         CountProduct:=0;
         while Count<=PSvehiclesListMax do
         begin
            if FCDsfSurveyVehicles[Count].SV_function in [pfSurveyAir..pfSurveySwarmAntigrav] then
            begin
               ProductNode:=FCWinMain.PSP_ProductsList.Items.Add( nil,
               '<a href="vehiclesremmax"><img src="file://'+FCVdiPathResourceDir+'pics-ui-resources\remmax.jpg"></a> '
                     +'<a href="vehiclesrem"><img src="file://'+FCVdiPathResourceDir+'pics-ui-resources\rem.jpg"></a> '
                     +'<a href="vehiclesadd"><img src="file://'+FCVdiPathResourceDir+'pics-ui-resources\add.jpg"></a> '
                     +'<a href="vehiclesaddmax"><img src="file://'+FCVdiPathResourceDir+'pics-ui-resources\addmax.jpg"></a>  '+
               FCFdTFiles_UIStr_Get( uistrUI, FCDsfSurveyVehicles[Count].SV_token )
                );
               FCWinMain.PSP_ProductsList.Items.AddChild(
                  ProductNode
                  ,FCFuiPS_VehiclesSetup_EntryFormat(
                     FCDsfSurveyVehicles[Count].SV_capabilityResources
                     ,FCDsfSurveyVehicles[Count].SV_crew
                     ,FCDsfSurveyVehicles[Count].SV_choosenUnits
                     ,FCDsfSurveyVehicles[Count].SV_storageUnits
                     )
                  );
               inc( CountProduct );
               PScurrentProducts[CountProduct]:=Count;
            end;
            inc( Count );
         end;
         FCWinMain.PSP_ProductsList.FullExpand;
      end;

      psBiosphere: FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psTitleBiosphere' );

      psFeaturesArtifacts: FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psFeaturesArtifacts' );
   end;
   FCWinMain.MVG_PlanetarySurveyPanel.Show;
   FCWinMain.MVG_PlanetarySurveyPanel.BringToFront;
end;

procedure FCMuiPS_VehiclesSetup_Add;
{:Purpose: process the add button.
    Additions:
}
   var
      CurrentItem: integer;
begin
   CurrentItem:=PScurrentProducts[FCWinMain.PSP_ProductsList.Selected.Index+1];
   if ( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits<FCDsfSurveyVehicles[CurrentItem].SV_storageUnits )
      and (
         ( FCDsfSurveyVehicles[CurrentItem].SV_crew<0 ) or ( FCDdgEntities[0].E_colonies[FCFuiCDP_VarCurrentColony_Get].C_population.CP_classColonist-FCDdgEntities[0].E_colonies[FCFuiCDP_VarCurrentColony_Get].C_population.CP_classColonistAssigned-PSvehiclesCrewUsed-FCDsfSurveyVehicles[CurrentItem].SV_crew>=0 )
         ) then
   begin
      inc( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits );
      FCWinMain.PSP_ProductsList.Items[ (FCWinMain.PSP_ProductsList.Selected.Index*2)+1 ].Text:=
      FCFuiPS_VehiclesSetup_EntryFormat(
         FCDsfSurveyVehicles[CurrentItem].SV_capabilityResources
         ,FCDsfSurveyVehicles[CurrentItem].SV_crew
         ,FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits
         ,FCDsfSurveyVehicles[CurrentItem].SV_storageUnits
         );
      if FCDsfSurveyVehicles[CurrentItem].SV_crew>0 then
      begin
         PSvehiclesCrewUsed:=PSvehiclesCrewUsed+FCDsfSurveyVehicles[CurrentItem].SV_crew;
         FCMuiPS_VehiclesSetup_CrewFormat;
      end;
   end;
end;

procedure FCMuiPS_VehiclesSetup_AddMax;
{:Purpose: process the addmax button.
    Additions:
}
   var
      CurrentItem
      ,MaxUnit
      ,UnitThreshold: integer;
begin
   CurrentItem:=PScurrentProducts[FCWinMain.PSP_ProductsList.Selected.Index+1];
   if FCDsfSurveyVehicles[CurrentItem].SV_storageUnits<20
   then UnitThreshold:=FCDsfSurveyVehicles[CurrentItem].SV_storageUnits shr 1
   else if FCDsfSurveyVehicles[CurrentItem].SV_storageUnits>=20
   then UnitThreshold:=round( FCDsfSurveyVehicles[CurrentItem].SV_storageUnits * 0.1 );
   if FCDsfSurveyVehicles[CurrentItem].SV_crew<0
   then MaxUnit:=FCDsfSurveyVehicles[CurrentItem].SV_storageUnits
   else if FCDsfSurveyVehicles[CurrentItem].SV_crew>0
   then MaxUnit:=trunc(
      ( FCFuiPS_AvailableCrew_GetValue ) /FCDsfSurveyVehicles[CurrentItem].SV_crew
      );
   if ( MaxUnit>0 )
      and ( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits+UnitThreshold<=MaxUnit ) then
   begin
      FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits:=FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits+UnitThreshold;
      if FCDsfSurveyVehicles[CurrentItem].SV_crew>0 then
      begin
         PSvehiclesCrewUsed:=PSvehiclesCrewUsed+( FCDsfSurveyVehicles[CurrentItem].SV_crew * UnitThreshold );
         FCMuiPS_VehiclesSetup_CrewFormat;
      end;
   end
   else if ( MaxUnit>0 )
      and ( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits+UnitThreshold>MaxUnit ) then
   begin
      FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits:=MaxUnit;
      if FCDsfSurveyVehicles[CurrentItem].SV_crew>0 then
      begin
         PSvehiclesCrewUsed:=PSvehiclesCrewUsed+( FCDsfSurveyVehicles[CurrentItem].SV_crew * MaxUnit-( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits+UnitThreshold ) );
         FCMuiPS_VehiclesSetup_CrewFormat;
      end;
   end;
   FCWinMain.PSP_ProductsList.Items[ (FCWinMain.PSP_ProductsList.Selected.Index*2)+1 ].Text:=
      FCFuiPS_VehiclesSetup_EntryFormat(
         FCDsfSurveyVehicles[CurrentItem].SV_capabilityResources
         ,FCDsfSurveyVehicles[CurrentItem].SV_crew
         ,FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits
         ,FCDsfSurveyVehicles[CurrentItem].SV_storageUnits
         );
end;

procedure FCMuiPS_VehiclesSetup_CrewFormat;
{:Purpose: update the current crew available.
    Additions:
}
begin
   FCWinMain.PSP_Label.HTMLText.Insert(
      1
      ,'Current Crew Available: '+IntToStr( FCFuiPS_AvailableCrew_GetValue )
      );
   FCWinMain.PSP_Label.HTMLText.Delete( 2 );
end;

end.
