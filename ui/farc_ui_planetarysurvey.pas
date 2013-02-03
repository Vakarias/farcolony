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
   farc_data_game;

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

implementation

uses
   farc_data_textfiles
   ,farc_main
   ,farc_ui_win;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiPS_Panel_InitElements;
{:Purpose: init the elements (size and location) of the panel.
    Additions:
}
begin
   FCWinMain.MVG_PlanetarySurveyPanel.Width:=350;
   FCWinMain.MVG_PlanetarySurveyPanel.Height:=500;
   FCWinMain.PSP_TypeOfExpedition.Width:=FCWinMain.MVG_PlanetarySurveyPanel.Width-8;
   FCWinMain.PSP_TypeOfExpedition.Height:=70;
end;

procedure FCMuiPS_Panel_InitFonts;
{:Purpose: init the fonts of the panel.
    Additions:
}
begin
   FCWinMain.MVG_PlanetarySurveyPanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
   FCWinMain.PSP_TypeOfExpedition.Font.Size:=FCFuiW_Font_GetSize(uiwDescText);
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
   case TypeOfSurvey of
      psResources: FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psTitleResources' );

      psBiosphere: FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psTitleBiosphere' );

      psFeaturesArtifacts: FCWinMain.MVG_PlanetarySurveyPanel.Caption.Text:='<p align="center"><b>'+FCFdTFiles_UIStr_Get( uistrUI, 'psMainTitle' )+FCFdTFiles_UIStr_Get( uistrUI, 'psFeaturesArtifacts' );
   end;
   FCWinMain.MVG_PlanetarySurveyPanel.Show;
   FCWinMain.MVG_PlanetarySurveyPanel.BringToFront;
end;

end.
