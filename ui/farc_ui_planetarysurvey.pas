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
///   <param name="UpdateOnlyVehicles">only update the vehicles list, used when the panel is already opened</param>
procedure FCMuiPS_Panel_Show( const TypeOfSurvey: TFCEdgPlanetarySurveys; const UpdateOnlyVehicles: boolean );

///<summary>
///   process the add button
///</summary>
///   <param name="TypeOfSurvey">configure the add for a specified type of survey</param>
procedure FCMuiPS_VehiclesSetup_Add( const TypeOfSurvey: TFCEdgPlanetarySurveys );

///<summary>
///   process the addmax button
///</summary>
///   <param name="TypeOfSurvey">configure the addmax for a specified type of survey</param>
procedure FCMuiPS_VehiclesSetup_AddMax( const TypeOfSurvey: TFCEdgPlanetarySurveys );

///<summary>
///   update the current crew available
///</summary>
procedure FCMuiPS_VehiclesSetup_CrewFormat;

///<summary>
///   process the rem button
///</summary>
///   <param name="TypeOfSurvey">configure the rem for a specified type of survey</param>
procedure FCMuiPS_VehiclesSetup_Rem( const TypeOfSurvey: TFCEdgPlanetarySurveys );

///<summary>
///   process the remmax button
///</summary>
///   <param name="TypeOfSurvey">configure the remmax for a specified type of survey</param>
procedure FCMuiPS_VehiclesSetup_RemMax( const TypeOfSurvey: TFCEdgPlanetarySurveys );

///<summary>
///   initialize the unit threshold of a given type of vehicles
///</summary>
///   <param name="VehiclesGroupIndex">index of a vehicles group</param>
procedure FCMuiPS_VehiclesSetupUnitThreshold_Init( const VehiclesGroupIndex: integer );

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

function FCFuiPS_VehiclesGroups_TestIfChoosenPositive: boolean;
{:Purpose: test if one groupe has the choosen value>0.
    Additions:
}
   var
      Count
      ,Max: integer;
begin
   Result:=false;
   Count:=1;
   Max:=length( FCDsfSurveyVehicles )-1;
   while Count<=Max do
   begin
      if FCDsfSurveyVehicles[Count].SV_choosenUnits>0 then
      begin
         Result:=true;
         break;
      end;
      inc( Count );
   end;

end;

//===================================================END OF INIT============================

function FCFuiPS_AvailableCrew_GetValue: integer;
{:Purpose: calculate the available crew for the current expedition setup.
    Additions:
}
begin
   Result:=0;
   Result:=FCDdgEntities[0].E_colonies[FCFuiCDP_VarCurrentColony_Get].C_population.CP_classColonist-FCDdgEntities[0].E_colonies[FCFuiCDP_VarCurrentColony_Get].C_population.CP_classColonistAssigned-PSvehiclesCrewUsed;
end;

function FCFuiPS_VehiclesSetup_EntryFormat( const TypeOfSurvey: TFCEdgPlanetarySurveys; const VehiclesGroupIndex: integer ): string;
{:Purpose: generate an entry line for a vehicle.
    Additions:
      -2013Mar05- *mod: text localization.
      -2013Mar04- *rem: useless parameter have been removed.
}
   var
      RedFormat
      ,RedFormatEnd
      ,VehiclesCapability: string;
begin
   RedFormat:='';
   RedFormatEnd:='';
   VehiclesCapability:='';
   case TypeOfSurvey of
      psResources: VehiclesCapability:=inttostr( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_capabilityResources );

      psBiosphere: VehiclesCapability:=inttostr( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_capabilityBiosphere );

      psFeaturesArtifacts: VehiclesCapability:=inttostr( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_capabilityFeaturesArtifacts );
   end;
   Result:='';
   if ( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_crew>0 )
      and ( FCFuiPS_AvailableCrew_GetValue<FCDsfSurveyVehicles[VehiclesGroupIndex].SV_crew ) then
   begin
      RedFormat:=FCCFcolRed;
      RedFormatEnd:=FCCFcolEND
   end;
   Result:=FCFdTFiles_UIStr_Get(uistrUI, 'psDatCapability')+' [<b>'+VehiclesCapability+'</b>]  '+FCFdTFiles_UIStr_Get(uistrUI, 'psDatCrew')+' [<b>'+RedFormat+IntToStr( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_crew )+RedFormatEnd+'</b>]  '
      +FCFdTFiles_UIStr_Get(uistrUI, 'psDatUnit')+' [<b>'+inttostr( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_choosenUnits )+' / '+inttostr( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_storageUnits )+'</b>]';
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiPS_Panel_InitElements;
{:Purpose: init the elements (size and location) of the panel.
    Additions:
      -2013Mar10- *add: PSP_MissionExt + PSP_Commit.
      -2013Feb12- *add: PSP_ProductsList init.
}
begin
   FCWinMain.MVG_PlanetarySurveyPanel.Width:=350;
   FCWinMain.MVG_PlanetarySurveyPanel.Height:=500;
   FCWinMain.PSP_ProductsList.Width:=FCWinMain.MVG_PlanetarySurveyPanel.Width-8;
   FCWinMain.PSP_ProductsList.Height:=260;
   FCWinMain.PSP_ProductsList.Left:=4;
   FCWinMain.PSP_ProductsList.Top:=60;
   FCWinMain.PSP_MissionExt.Width:=FCWinMain.PSP_ProductsList.Width;
   FCWinMain.PSP_MissionExt.Height:=120;
   FCWinMain.PSP_MissionExt.Left:=4;
   FCWinMain.PSP_MissionExt.Top:=FCWinMain.PSP_ProductsList.Top+FCWinMain.PSP_ProductsList.Height+4;
   FCWinMain.PSP_Commit.Width:=FCWinMain.MVG_PlanetarySurveyPanel.Width-16;
   FCWinMain.PSP_Commit.Height:=26;
   FCWinMain.PSP_Commit.Left:=8;
   FCWinMain.PSP_Commit.Top:=FCWinMain.PSP_MissionExt.Top+FCWinMain.PSP_MissionExt.Height+8;
end;

procedure FCMuiPS_Panel_InitFonts;
{:Purpose: init the fonts of the panel.
    Additions:
      -2013Mar10- *add: PSP_MissionExt + PSP_Commit.
}
begin
   FCWinMain.MVG_PlanetarySurveyPanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
   FCWinMain.PSP_Label.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
   FCWinMain.PSP_ProductsList.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
   FCWinMain.PSP_MissionExt.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
   FCWinMain.PSP_Commit.Font.Size:=FCFuiW_Font_GetSize(uiwButton);
end;

procedure FCMuiPS_Panel_InitText;
{:Purpose: init the texts of the panel.
    Additions:
      -2013Mar10- *add: PSP_MissionExt + PSP_Commit.
}
begin
   FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='';
   FCWinMain.PSP_MissionExt.Caption:=FCFdTFiles_UIStr_Get( uistrUI, 'psMissionExtension' );
   FCWinMain.PSP_MissionExt.Items.Clear;
   FCWinMain.PSP_MissionExt.Items.Add( FCFdTFiles_UIStr_Get( uistrUI, 'psMissionExtdefault' ) );
   FCWinMain.PSP_MissionExt.Items.Add( FCFdTFiles_UIStr_Get( uistrUI, 'psMissionExtAdj' ) );
   FCWinMain.PSP_MissionExt.Items.Add( FCFdTFiles_UIStr_Get( uistrUI, 'psMissionExtAllCtlNeut' ) );
   FCWinMain.PSP_MissionExt.ItemIndex:=0;
   FCWinMain.PSP_Commit.Caption:=FCFdTFiles_UIStr_Get( uistrUI, 'psCommit' );
end;

procedure FCMuiPS_Panel_Show( const TypeOfSurvey: TFCEdgPlanetarySurveys; const UpdateOnlyVehicles: boolean );
{:Purpose: show the panel.
    Additions:
      -2013Mar10- *add: PSP_Commit button.
                  *fix: update also the available crew when the panel is opened and a new region is clicked.
      -2013Mar06- *mod: end text localizations.
      -2013Mar05- *mod: begin text localizations.
      -2013Mar04- *add: new parameter - UpdateOnlyVehicles.
}
   var
      Count
      ,CountProduct
      ,SelectedRegion: integer;

      isTravelOK: boolean;

      ProductNode: TTreeNode;
begin
   Count:=0;
   CountProduct:=0;
   SelectedRegion:=0;
   isTravelOK:=false;
   SetLength( PScurrentProducts, 6 );
   PSvehiclesListMax:=0;
   PSvehiclesCrewUsed:=0;
   case TypeOfSurvey of
      psResources:
      begin
         FCWinMain.PSP_Commit.Enabled:=false;
         SelectedRegion:=FCFuiSP_VarRegionSelected_Get;
         FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psTitleResources' );
         if not UpdateOnlyVehicles then
         begin
            FCWinMain.MVG_PlanetarySurveyPanel.Left:=FCWinMain.MVG_SurfacePanel.Left+FCWinMain.MVG_SurfacePanel.Width-FCWinMain.SP_RegionSheet.Width;
            FCWinMain.MVG_PlanetarySurveyPanel.Top:=FCWinMain.MVG_SurfacePanel.Top;
            FCWinMain.PSP_Label.HTMLText.Clear;
            FCWinMain.PSP_Label.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'psExpeditionSetup' )+FCCFdHeadEnd );
            FCWinMain.PSP_Label.HTMLText.Add(
               FCFdTFiles_UIStr_Get( uistrUI, 'psExpeditionSetupCrew' )+': '
                  +IntToStr( FCDdgEntities[0].E_colonies[FCFuiCDP_VarCurrentColony_Get].C_population.CP_classColonist-FCDdgEntities[0].E_colonies[FCFuiCDP_VarCurrentColony_Get].C_population.CP_classColonistAssigned-PSvehiclesCrewUsed )
               );
         end
         else FCMuiPS_VehiclesSetup_CrewFormat;
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
            if Count=1
            then isTravelOK:=FCFsF_ResourcesSurvey_ProcessTravelSurveyDistance(
               0
               ,FCFuiCDP_VarCurrentColony_Get
               ,SelectedRegion
               ,Count
               ,false
               ,false
               )
            else if Count>1
            then isTravelOK:=FCFsF_ResourcesSurvey_ProcessTravelSurveyDistance(
               0
               ,FCFuiCDP_VarCurrentColony_Get
               ,SelectedRegion
               ,Count
               ,true
               ,false
               );
            if not isTravelOK then
            begin
               ProductNode:=FCWinMain.PSP_ProductsList.Items.Add( nil, FCFdTFiles_UIStr_Get( uistrUI, FCDsfSurveyVehicles[Count].SV_token ) );
               FCWinMain.PSP_ProductsList.Items.AddChild( ProductNode, FCFdTFiles_UIStr_Get( uistrUI, 'psExpeditionSetupTravelFail' ) );
            end
            else begin
               ProductNode:=FCWinMain.PSP_ProductsList.Items.Add( nil,
                  '<a href="vehiclesRESremmax"><img src="file://'+FCVdiPathResourceDir+'pics-ui-resources\remmax.jpg"></a> '
                     +'<a href="vehiclesRESrem"><img src="file://'+FCVdiPathResourceDir+'pics-ui-resources\rem.jpg"></a> '
                     +'<a href="vehiclesRESadd"><img src="file://'+FCVdiPathResourceDir+'pics-ui-resources\add.jpg"></a> '
                     +'<a href="vehiclesRESaddmax"><img src="file://'+FCVdiPathResourceDir+'pics-ui-resources\addmax.jpg"></a>  '
                     +FCFdTFiles_UIStr_Get( uistrUI, FCDsfSurveyVehicles[Count].SV_token )
                  );
               FCWinMain.PSP_ProductsList.Items.AddChild( ProductNode, FCFuiPS_VehiclesSetup_EntryFormat( psResources,Count ) );
            end;
            inc( CountProduct );
            PScurrentProducts[CountProduct]:=Count;
            inc( Count );
         end; //==END== while Count<=PSvehiclesListMax ==//
         FCWinMain.PSP_ProductsList.FullExpand;
      end; //==END== case: psResources ==//

      psBiosphere: FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psTitleBiosphere' );

      psFeaturesArtifacts: FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psFeaturesArtifacts' );
   end; //==END== case TypeOfSurvey of ==//
   FCWinMain.MVG_PlanetarySurveyPanel.Show;
   FCWinMain.MVG_PlanetarySurveyPanel.BringToFront;
end;

procedure FCMuiPS_VehiclesSetup_Add( const TypeOfSurvey: TFCEdgPlanetarySurveys );
{:Purpose: process the add button.
    Additions:
      -2013Mar10- *add: PSP_Commit button state.
}
   var
      CurrentItem: integer;
begin
   CurrentItem:=PScurrentProducts[FCWinMain.PSP_ProductsList.Selected.Index+1];
   if ( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits<FCDsfSurveyVehicles[CurrentItem].SV_storageUnits )
      and (
         ( FCDsfSurveyVehicles[CurrentItem].SV_crew<0 ) or ( FCFuiPS_AvailableCrew_GetValue-FCDsfSurveyVehicles[CurrentItem].SV_crew>=0 )
         ) then
   begin
      inc( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits );
      FCWinMain.PSP_ProductsList.Items[ (FCWinMain.PSP_ProductsList.Selected.Index*2)+1 ].Text:=FCFuiPS_VehiclesSetup_EntryFormat( TypeOfSurvey, CurrentItem );
      if FCDsfSurveyVehicles[CurrentItem].SV_crew>0 then
      begin
         PSvehiclesCrewUsed:=PSvehiclesCrewUsed+FCDsfSurveyVehicles[CurrentItem].SV_crew;
         FCMuiPS_VehiclesSetup_CrewFormat;
      end;
      if not FCWinMain.PSP_Commit.Enabled
      then FCWinMain.PSP_Commit.Enabled:=true;
   end;
end;

procedure FCMuiPS_VehiclesSetup_AddMax( const TypeOfSurvey: TFCEdgPlanetarySurveys );
{:Purpose: process the addmax button.
    Additions:
      -2013Mar10- *fix: remove a bug during the calculations of MaxUnit.
                  *add: PSP_Commit button state.
}
   var
      CurrentItem
      ,MaxUnit: integer;
begin
   CurrentItem:=PScurrentProducts[FCWinMain.PSP_ProductsList.Selected.Index+1];
   FCMuiPS_VehiclesSetupUnitThreshold_Init( CurrentItem );
   if FCDsfSurveyVehicles[CurrentItem].SV_crew<0
   then MaxUnit:=FCDsfSurveyVehicles[CurrentItem].SV_storageUnits
   else if FCDsfSurveyVehicles[CurrentItem].SV_crew>0 then
   begin
      MaxUnit:=trunc( ( FCFuiPS_AvailableCrew_GetValue ) /FCDsfSurveyVehicles[CurrentItem].SV_crew );
      if MaxUnit>FCDsfSurveyVehicles[CurrentItem].SV_storageUnits
      then MaxUnit:=FCDsfSurveyVehicles[CurrentItem].SV_storageUnits;
   end;
   if MaxUnit>0 then
   begin
      if FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits+FCDsfSurveyVehicles[CurrentItem].SV_unitThreshold<MaxUnit then
      begin
         FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits:=FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits+FCDsfSurveyVehicles[CurrentItem].SV_unitThreshold;
         if FCDsfSurveyVehicles[CurrentItem].SV_crew>0 then
         begin
            PSvehiclesCrewUsed:=PSvehiclesCrewUsed+( FCDsfSurveyVehicles[CurrentItem].SV_crew * FCDsfSurveyVehicles[CurrentItem].SV_unitThreshold );
            FCMuiPS_VehiclesSetup_CrewFormat;
         end;
      end
      else if FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits+FCDsfSurveyVehicles[CurrentItem].SV_unitThreshold=MaxUnit then
      begin
         FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits:=MaxUnit;
         if FCDsfSurveyVehicles[CurrentItem].SV_crew>0 then
         begin
            PSvehiclesCrewUsed:=PSvehiclesCrewUsed+( FCDsfSurveyVehicles[CurrentItem].SV_crew * FCDsfSurveyVehicles[CurrentItem].SV_unitThreshold );
            FCMuiPS_VehiclesSetup_CrewFormat;
         end;
      end
      else if ( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits+FCDsfSurveyVehicles[CurrentItem].SV_unitThreshold>MaxUnit )
         and (FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits<MaxUnit ) then
      begin
         if FCDsfSurveyVehicles[CurrentItem].SV_crew>0 then
         begin
            PSvehiclesCrewUsed:=PSvehiclesCrewUsed+( FCDsfSurveyVehicles[CurrentItem].SV_crew * ( MaxUnit - FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits ) );
            FCMuiPS_VehiclesSetup_CrewFormat;
         end;
         FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits:=MaxUnit;
      end;
      FCWinMain.PSP_ProductsList.Items[ (FCWinMain.PSP_ProductsList.Selected.Index*2)+1 ].Text:=FCFuiPS_VehiclesSetup_EntryFormat( TypeOfSurvey, CurrentItem );
      if not FCWinMain.PSP_Commit.Enabled
      then FCWinMain.PSP_Commit.Enabled:=true;
   end;
end;

procedure FCMuiPS_VehiclesSetup_CrewFormat;
{:Purpose: update the current crew available.
    Additions:
      -2013Mar06- *mod: text localization.
}
begin
   FCWinMain.PSP_Label.HTMLText.Insert(
      1
      ,FCFdTFiles_UIStr_Get( uistrUI, 'psExpeditionSetupCrew' )+': '+IntToStr( FCFuiPS_AvailableCrew_GetValue )
      );
   FCWinMain.PSP_Label.HTMLText.Delete( 2 );
end;

procedure FCMuiPS_VehiclesSetup_Rem( const TypeOfSurvey: TFCEdgPlanetarySurveys );
{:Purpose: process the rem button.
    Additions:
      -2013Mar10- *add: PSP_Commit button state.
}
   var
      CurrentItem: integer;
begin
   CurrentItem:=PScurrentProducts[FCWinMain.PSP_ProductsList.Selected.Index+1];
   if ( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits>0 ) then
   begin
      dec( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits );
      FCWinMain.PSP_ProductsList.Items[ (FCWinMain.PSP_ProductsList.Selected.Index*2)+1 ].Text:=FCFuiPS_VehiclesSetup_EntryFormat( TypeOfSurvey, CurrentItem );
      if FCDsfSurveyVehicles[CurrentItem].SV_crew>0 then
      begin
         PSvehiclesCrewUsed:=PSvehiclesCrewUsed-FCDsfSurveyVehicles[CurrentItem].SV_crew;
         FCMuiPS_VehiclesSetup_CrewFormat;
      end;
      if ( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits=0 )
         and ( not FCFuiPS_VehiclesGroups_TestIfChoosenPositive )
      then FCWinMain.PSP_Commit.Enabled:=false;
   end;
end;

procedure FCMuiPS_VehiclesSetup_RemMax( const TypeOfSurvey: TFCEdgPlanetarySurveys );
{:Purpose: process the remmax button.
    Additions:
      -2013Mar10- *add: PSP_Commit button state.
}
   var
      CurrentItem
      ,MaxUnit: integer;
begin
   CurrentItem:=PScurrentProducts[FCWinMain.PSP_ProductsList.Selected.Index+1];
   FCMuiPS_VehiclesSetupUnitThreshold_Init( CurrentItem );
   if FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits>0 then
   begin
      if FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits-FCDsfSurveyVehicles[CurrentItem].SV_unitThreshold<=0 then
      begin
         if FCDsfSurveyVehicles[CurrentItem].SV_crew>0
         then PSvehiclesCrewUsed:=PSvehiclesCrewUsed-( FCDsfSurveyVehicles[CurrentItem].SV_crew * FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits );
         FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits:=0;
      end
      else if FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits-FCDsfSurveyVehicles[CurrentItem].SV_unitThreshold>0 then
      begin
         if FCDsfSurveyVehicles[CurrentItem].SV_crew>0
         then PSvehiclesCrewUsed:=PSvehiclesCrewUsed-( FCDsfSurveyVehicles[CurrentItem].SV_crew * FCDsfSurveyVehicles[CurrentItem].SV_unitThreshold );
         FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits:=FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits-FCDsfSurveyVehicles[CurrentItem].SV_unitThreshold;
      end;
      FCMuiPS_VehiclesSetup_CrewFormat;
      FCWinMain.PSP_ProductsList.Items[ (FCWinMain.PSP_ProductsList.Selected.Index*2)+1 ].Text:=FCFuiPS_VehiclesSetup_EntryFormat( TypeOfSurvey, CurrentItem );
      if not FCFuiPS_VehiclesGroups_TestIfChoosenPositive
      then FCWinMain.PSP_Commit.Enabled:=false;
   end;
end;

procedure FCMuiPS_VehiclesSetupUnitThreshold_Init( const VehiclesGroupIndex: integer );
{:Purpose: initialize the unit threshold of a given type of vehicles.
    Additions:
}
begin
   if ( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_unitThreshold=0 )
      and ( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_storageUnits<20 )
   then FCDsfSurveyVehicles[VehiclesGroupIndex].SV_unitThreshold:=FCDsfSurveyVehicles[VehiclesGroupIndex].SV_storageUnits shr 1
   else if ( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_unitThreshold=0 )
      and ( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_storageUnits>=20 )
   then FCDsfSurveyVehicles[VehiclesGroupIndex].SV_unitThreshold:=round( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_storageUnits * 0.1 );
end;

end.
