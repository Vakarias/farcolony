{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: data that doesn't fit to any other farc_data_xxx unit

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

unit farc_data_init;

interface

uses
   Classes
   ,dialogs
   ,SysUtils

   ,o_GTTimer

   ,GR32_Image;


//==END PUBLIC ENUM=========================================================================

type TFCRdiSettlementPictures=array[1..30] of TImage32;

//==END PUBLIC RECORDS======================================================================

var
   //==========3d view management===========================================================

   ///<summary>
   ///   indicate two thing: if a game is running and if the 3d view is initialized. That also indicate that WM_MainViewGroup is visible
   ///</summary>
   FCVdi3DViewRunning: boolean = false;

   FCVdi3DViewToInitialize: boolean = false;

   //==========databases and other data structures pre-init=================================
   ///<summary>
   ///   settlements pictures - contains the settlement icons
   ///</summary>
   FCRdiSettlementPictures: TFCRdiSettlementPictures;

   ///<summary>
   ///   format setting for the internal decimal separator configuration
   ///</summary>
   FCVdiFormat: TFormatSettings;

   //==========game core====================================================================
   ///<summary>
   ///   [true=]debug mode
   ///</summary>
   FCVdiDebugMode: boolean =false;

   ///<summary>
   ///   threaded game timer declaration
   ///</summary>
   FCVdiGameFlowTimer : TgtTimer;

   ///<summary>
   ///   language token of the game, until now: EN = english FR = french SP = spanish
   ///</summary>
   FCVdiLanguage: string;

   ///<summary>
   ///   [true=]override any limitation rules in FARC
   ///</summary>
   FCVdiOverrideRules: boolean =false;

   //==========panels location storing switch===============================================
   ///<summary>
   ///   [true=]store colony panel location
   ///</summary>
   FCVdiLocStoreColonyPanel: boolean= false;


   ///<summary>
   ///   [true=]store CPS objectives panel location
   ///</summary>
   FCVdiLocStoreCPSobjPanel: boolean= false;

   ///<summary>
   ///   [true=]store help panel location
   ///</summary>
   FCVdiLocStoreHelpPanel: boolean= false;

   //==========path strings=================================================================
   ///<summary>
   ///   root path for the directory of the data files, /<user>/My Documents/farcolony
   ///</summary>
   FCVdiPathConfigDir: string;

   ///<summary>
   ///   path for the configuration file
   ///</summary>
   FCVdiPathConfigFile: string;

   ///<summary>
   ///   path of the game
   ///</summary>
   FCVdiPathGame: string;

   ///<summary>
   ///   path of the resource directory
   ///</summary>
   FCVdiPathResourceDir: string;

   ///<summary>
   ///   path of the XML directory - include end separator slash
   ///</summary>
   FCVdiPathXML: string;

   //==========UMI related==================================================================
   ///<summary>
   ///   UMI height constraint
   ///</summary>
   FCVdiUMIconstraintHeight: integer=540;

   ///<summary>
   ///   UMI width constraint
   ///</summary>
   FCVdiUMIconstraintWidth: integer=800;

   //==========windows related==============================================================
   ///<summary>
   ///   updating switch for the about window
   ///</summary>
   FCVdiWinAboutAllowUpdate: boolean = false;

   ///<summary>
   ///   updating switch for the main window
   ///</summary>
   FCVdiWinMainAllowUpdate: boolean = false;

   ///<summary>
   ///   store data for height size of the main window
   ///</summary>
   FCVdiWinMainHeight: integer;

   ///<summary>
   ///   store data for left position of the main window
   ///</summary>
   FCVdiWinMainLeft: integer;

   ///<summary>
   ///   store data for top position of the main window
   ///</summary>
   FCVdiWinMainTop: integer;

   ///<summary>
   ///   indicate to use background in [true=]wide or [false=]4:3 mode
   ///</summary>
   FCVdiWinMainWideScreen: boolean;

   ///<summary>
   ///   store data for width size of the main window
   ///</summary>
   FCVdiWinMainWidth: integer;

   ///<summary>
   ///   updating switch for the new game setting window
   ///</summary>
   FCVdiWinNewGameAllowUpdate: boolean = false;

//==END PUBLIC VAR==========================================================================

const

   //==========conversion / physics constants=========================================================
   ///<summary>
   ///   degrees to radian, this constant is a multiplier
   ///</summary>
   FCCdiDegrees_To_Radian=Pi/180;

   ///<summary>
   ///   density equivalent for any orbital object, relative to Earth, 1 unit=5515kg/m3
   ///</summary>
   FCCdiDensityEqEarth=5515;

   ///<summary>
   ///   gravitational constant in astrophysics
   ///</summary>
   FCCdiGravitationalConst=6.67428E-11;

   ///<summary>
   ///   # of kilometers in one Astronomical Unit
   ///</summary>
   FCCdiKm_In_1AU=149597870;

   ///<summary>
   ///   Gees to km/s
   ///</summary>
   FCCdiKmBySec_In_1G=0.009807;

   ///<summary>
   ///   # of light-seconds in one Astonomical Unit
   ///</summary>
   FCCdiLightSec_In_1AU=499;

   ///<summary>
   ///   # of Light-Years in one parsec (pc)
   ///</summary>
   FCCdiLY_In_1pc=3.261633;

   ///<summary>
   ///   mass equivalent for any orbital object, in Earth mass, 1 unit=5.976e24kg
   ///</summary>
   FCCdiMassEqEarth=5.976e24;

   ///<summary>
   ///   mass equivalent for any star, in Sun mass, 1 unit=1.99e30kg
   ///</summary>
   FCCdiMassEqSun=1.9884e30;

   ///<summary>
   ///   # of millibars in one atmosphere
   ///</summary>
   FCCdiMbars_In_1atmosphere=1013;

   ///<summary>
   ///   # of meters by seconds in 1c (light speed index)
   ///</summary>
   FCCdiMetersBySec_In_1c=299792458;

   ///<summary>
   ///   # of meters by second in 1g
   ///</summary>
   FCCdiMetersBySec_In_1G=9.807;

   ///<summary>
   ///   # of MegaJoules in 1 kWh
   ///</summary>
   FCCdiMJ_In_1kWh=3.6;

   FCCdiPiDouble=2*pi;

   //==========game core====================================================================
   ///<summary>
   ///   current alpha # for FARC
   ///</summary>
   FCCdiAlphaNumber='8';

   ///<summary>
   ///   maximum of factions in the game (player one is #0)
   ///</summary>
   FCCdiFactionsMax=1;


   FCCdiMatrixItemsMax=20;

   CFC3dUnInKm=14959.787;     {conversion constant 1 3d unit = 14959.787km}
   CFC3dAstConv=CFC3dUnInKm*30.59789;
   CFC3dUnInAU=FCCdiKm_In_1AU/CFC3dUnInKm;

//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   initialize all the basic data, test the configuration file and the save games directory
///</summary>
procedure FCMdi_Data_Initialization;

implementation

uses
   farc_data_files
	,farc_data_textfiles
	,farc_main
   ,farc_win_debug;

//=============================================END OF INIT==================================

procedure FCMdi_Data_Initialization;
{purpose: initialize all the basic data, test the configuration file and the save games directory.
   Additions:
      -2012Jun06- *code audit:
                  (_)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                  (_)parameters refactoring           (x) ()reformatting         (-)code optimizations
                  (_)float local variables=> extended (_)case..of reformatting   (x)local methods
                  (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
      -2011May05- *add: products database loading.
      -2010Oct03- *add SPMi database loading.
      -2010May18- *add: infrastructures loading.
      -2009Nov05- *test if the SavedGames directory exists, and make it if not.
      -2009Sep13- *add FCMdFiles_DBSpaceCrafts_Read.
      -2009Aug09- *add FCMdFiles_DBFactions_Read.
}
begin
   {.configuration file initialization}
   if not FileExists( FCVdiPathConfigFile ) then
   begin
      FCVdiLanguage:= 'EN';
      FCVdiWinMainWidth:= FCWinMain.Width;
      FCVdiWinMainHeight:= FCWinMain.Height;
      FCVdiWinMainLeft:= FCWinMain.Left;
      FCVdiWinMainTop:= FCWinMain.Top;
      FCMdF_ConfigurationFile_Save(false);
   end
   else if FileExists( FCVdiPathConfigFile )
   then FCMdF_ConfigurationFile_Load( false );
   {.saved games directory initialization}
   if not DirectoryExists( FCVdiPathConfigDir+'SavedGames' )
   then MkDir( FCVdiPathConfigDir+'SavedGames' );
   {.text localization init}
	FCMdTfiles_UIString_Init;
end;

end.

