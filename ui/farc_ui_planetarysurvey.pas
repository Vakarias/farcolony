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
   SysUtils

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
///   update the list of available vehicles according to the selected expedition type
///</summary>
procedure FCMuiPS_ExpeditionTypeSelect;

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


procedure FCMuiPS_VehiclesSetupBonus;

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
   PSvehiclesListMax: integer;

   PScurrentProducts: array of integer;

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiPS_ExpeditionTypeSelect;
{:Purpose: update the list of available vehicles according to the selected expedition type.
    Additions:
}
   var
      Count
      ,CountProduct: integer;

      CurrentFunction: TFCEdipProductFunctions;
begin
   CurrentFunction:=pfNone;
   case FCWinMain.PSP_TypeOfExpedition.ItemIndex of
      0: CurrentFunction:=pfSurveyGround;

      1: CurrentFunction:=pfSurveyAir;

      2: CurrentFunction:=pfSurveyAntigrav;

      3: CurrentFunction:=pfSurveySwarmAntigrav;

      4: CurrentFunction:=pfSurveySpace;
   end;
   FCWinMain.PSP_ProductsList.Items.Clear;
   Count:=1;
   CountProduct:=0;
   while Count<=PSvehiclesListMax do
   begin
      if FCDsfSurveyVehicles[Count].SV_function=CurrentFunction then
      begin
         FCWinMain.PSP_ProductsList.Items.Add( nil, FCFdTFiles_UIStr_Get( uistrUI, FCDsfSurveyVehicles[Count].SV_token )
         +'  (<a href="tesssstminus"><b>-</b></a> <a href="tesssstbonus"><b>+</b></a> <a href="tesssstmid"><b>=</b></a> <a href="tesssstMax"><b>M</b></a>)    '+inttostr( FCDsfSurveyVehicles[Count].SV_choosenUnits )
         +' / <b>'
         +inttostr( FCDsfSurveyVehicles[Count].SV_storageUnits )+'</b>' );
         inc( CountProduct );
         PScurrentProducts[CountProduct]:=Count;
      end;
      inc( Count );
   end;

end;

procedure FCMuiPS_Panel_InitElements;
{:Purpose: init the elements (size and location) of the panel.
    Additions:
      -2013Feb12- *add: PSP_ProductsList init.
}
begin
   FCWinMain.MVG_PlanetarySurveyPanel.Width:=350;
   FCWinMain.MVG_PlanetarySurveyPanel.Height:=500;
   FCWinMain.PSP_TypeOfExpedition.Width:=( FCWinMain.MVG_PlanetarySurveyPanel.Width shr 3 * 3 )-8;
   FCWinMain.PSP_TypeOfExpedition.Height:=116;
   FCWinMain.PSP_TypeOfExpedition.Left:=4;
   FCWinMain.PSP_TypeOfExpedition.Top:=32;
   FCWinMain.PSP_ProductsList.Width:=FCWinMain.MVG_PlanetarySurveyPanel.Width-8;//FCWinMain.MVG_PlanetarySurveyPanel.Width-FCWinMain.PSP_TypeOfExpedition.Width-12;
   FCWinMain.PSP_ProductsList.Height:=FCWinMain.PSP_TypeOfExpedition.Height;
   FCWinMain.PSP_ProductsList.Left:=4;//FCWinMain.PSP_TypeOfExpedition.Left+FCWinMain.PSP_TypeOfExpedition.Width+4;
   FCWinMain.PSP_ProductsList.Top:=FCWinMain.PSP_TypeOfExpedition.Top+FCWinMain.PSP_TypeOfExpedition.Width+4;
end;

procedure FCMuiPS_Panel_InitFonts;
{:Purpose: init the fonts of the panel.
    Additions:
}
begin
   FCWinMain.MVG_PlanetarySurveyPanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
   FCWinMain.PSP_Label.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
   FCWinMain.PSP_TypeOfExpedition.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
   FCWinMain.PSP_ProductsList.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
end;

procedure FCMuiPS_Panel_InitText;
{:Purpose: init the texts of the panel.
    Additions:
}
begin
   FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='';
   FCWinMain.PSP_TypeOfExpedition.Caption:=FCFdTFiles_UIStr_Get( uistrUI, 'psExpedition' );
   FCWinMain.PSP_TypeOfExpedition.Items.Clear;
   FCWinMain.PSP_TypeOfExpedition.Items.Add( FCFdTFiles_UIStr_Get( uistrUI, 'psexpedGround' ) );
   FCWinMain.PSP_TypeOfExpedition.Items.Add( FCFdTFiles_UIStr_Get( uistrUI, 'psexpedAir' ) );
   FCWinMain.PSP_TypeOfExpedition.Items.Add( FCFdTFiles_UIStr_Get( uistrUI, 'psexpedAntigrav' ) );
   FCWinMain.PSP_TypeOfExpedition.Items.Add( FCFdTFiles_UIStr_Get( uistrUI, 'psexpedSwarmAntigrav' ) );
   FCWinMain.PSP_TypeOfExpedition.Items.Add( FCFdTFiles_UIStr_Get( uistrUI, 'psexpedSpace' ) );
end;

procedure FCMuiPS_Panel_Show( const TypeOfSurvey: TFCEdgPlanetarySurveys );
{:Purpose: show the panel.
    Additions:
}
begin
   SetLength( PScurrentProducts, 6 );
   PSvehiclesListMax:=0;
   case TypeOfSurvey of
      psResources: FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psTitleResources' );

      psBiosphere: FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psTitleBiosphere' );

      psFeaturesArtifacts: FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psFeaturesArtifacts' );
   end;
   FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:=FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text+'  Region:'+inttostr( FCFuiSP_VarRegionSelected_Get );
   FCWinMain.MVG_PlanetarySurveyPanel.Left:=FCWinMain.MVG_SurfacePanel.Left+FCWinMain.MVG_SurfacePanel.Width-FCWinMain.SP_RegionSheet.Width;
   FCWinMain.MVG_PlanetarySurveyPanel.Top:=FCWinMain.MVG_SurfacePanel.Top;
   FCWinMain.PSP_Label.HTMLText.Clear;
   FCWinMain.PSP_Label.HTMLText.Add( FCCFdHeadC+'Set up An Expedition'+FCCFdHeadEnd );
   PSvehiclesListMax:=FCFsF_SurveyVehicles_Get(
      0
      ,FCFuiCDP_VarCurrentColony_Get
      ,false
      );
   FCWinMain.PSP_TypeOfExpedition.ItemIndex:=0;



   FCWinMain.MVG_PlanetarySurveyPanel.Show;
   FCWinMain.MVG_PlanetarySurveyPanel.BringToFront;
end;

procedure FCMuiPS_VehiclesSetupBonus;
   var
      CurrentItem: integer;
begin

   CurrentItem:=PScurrentProducts[FCWinMain.PSP_ProductsList.Selected.Index+1];
   {:DEV NOTES: + test if enough crew....}
   if FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits<FCDsfSurveyVehicles[CurrentItem].SV_storageUnits then
   begin
      inc( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits );
      FCWinMain.PSP_ProductsList.Items[ 0 ].Text:=FCFdTFiles_UIStr_Get( uistrUI, FCDsfSurveyVehicles[CurrentItem].SV_token )
      +'  (<a href="tesssstminus"><b>-</b></a> <a href="tesssstbonus"><b>+</b></a> <a href="tesssstmid"><b>=</b></a> <a href="tesssstMax"><b>M</b></a>)   '+inttostr( FCDsfSurveyVehicles[CurrentItem].SV_choosenUnits )
         +'  / <b>'
            +inttostr( FCDsfSurveyVehicles[CurrentItem].SV_storageUnits )+'</b>';
   end;
end;

end.
