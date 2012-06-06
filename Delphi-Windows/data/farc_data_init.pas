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
   ,SysUtils

   ,o_GTTimer

   ,GR32_Image;


//==END PUBLIC ENUM=========================================================================

type TFCRdiSettlementPictures=array[1..30] of TImage32;

//==END PUBLIC RECORDS======================================================================

var
   //==========databases and other data structures pre-init=================================
   ///<summary>
   ///   settlements pictures - contains the settlement icons
   ///</summary>
   FCRdiSettlementPictures: TFCRdiSettlementPictures;

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

//   const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================









   var


      
      //==========main window related=======================================================

      //==========message box===============================================================
      {.message counter}
      FCVmsgCount: integer;
      {.array for store message titles}
      FCVmsgStoMsg: array of string;
      {.array for store message text}
      FCVmsgStoTtl: array of string;
      //==========game system===============================================================


      //==========streams and memory management=============================================
      
   const
      {conversion constant 1 AU = 149,597,870 km}
      FCCauInKm=149597870;
      {conversion constant 1 AU = 499 light-seconds}
      FCCauInLsec=499;
      {conversion constant degree to radiant by multiply by this constant}
      FCCdeg2RadM=Pi/180;
      FCCgameNam='FAR Colony';
      FCCalphaNumber='3';
      {conversion contant 1 gee = 9.807 m/s}
      FCCgeesInMS=9.807;
      {gravity constant in astrophysics}
      FCCgravConst=6.67428E-11;
      {conversion constant 1kWh = 3.6MJ}
      FCCkwhInMJ=3.6;
      {conversion constant 1c (light speed index) = 299,792,458m/s}
      FCClightSpdinMS=299792458;
      {conversion constant: mass for asteroids 1unit= 10e20kg }
      FCCmassConvAster=10e20;
      {conversion constant 1 Earth mass = 5.976e24kg used for all planets}
      FCCmassEqEarth=5.976e24;
      {.conversion constant mbar (atmosphere pressure) to atmosphere}
      FCCpress2atmDiv=1013;
      {conversion constant 1 parsec = 3.261633 LY}
      FCCpcInLY=3.261633;
      //FCCcredRL1x=10000000;//20000;
//         FCC_DegToRadDiv=180/Pi


///<summary>
///   initialize all the basic data, test the configuration file and the save games
///   directory.
///</summary>
procedure FCMdInit_Initialize;

implementation

uses
   farc_data_files
	,farc_data_textfiles
	,farc_main
   ,farc_win_debug;

//=============================================END OF INIT==================================

procedure FCMdInit_Initialize;
{purpose: initialize all the basic data, test the configuration file and the save games
directory.
   Additions:
      -2011May05- *add: products database loading.
      -2010Oct03- *add SPMi database loading.
      -2010May18- *add: infrastructures loading.
      -2009Nov05- *test if the SavedGames directory exists, and make it if not.
      -2009Sep13- *add FCMdFiles_DBSpaceCrafts_Read.
      -2009Aug09- *add FCMdFiles_DBFactions_Read.
}
begin
   {.configuration file initialization}
   if not FileExists(FCVdiPathConfigFile)
   then
   begin
      FCVdiLanguage:= 'EN';
      FCVdiWinMainWidth:= FCWinMain.Width;
      FCVdiWinMainHeight:= FCWinMain.Height;
      FCVdiWinMainLeft:= FCWinMain.Left;
      FCVdiWinMainTop:= FCWinMain.Top;
      FCMdF_ConfigFile_Write(false);
   end
   else if FileExists(FCVdiPathConfigFile)
   then FCMdF_ConfigFile_Read(false);
   {.saved games directory initialization}
   if not DirectoryExists(FCVdiPathConfigDir+'SavedGames')
   then MkDir(FCVdiPathConfigDir+'SavedGames');
   {.game databases loading}
   FCMdF_DBProducts_Read;
   FCMdF_DBSPMi_Read;
   FCMdF_DBFactions_Read;
   FCMdF_DBInfra_Read;
   FCMdF_DBSpaceCrafts_Read;
   {.text localization init}
	FCMdTfiles_UIString_Init;
end;

end.

