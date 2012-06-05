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

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//   var
//==END PUBLIC VAR==========================================================================

//   const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================








      type TFCRtopdef= record
      TD_link: string[20];
      TD_str: string;
   end;
      TFCDBtdef= array of TFCRtopdef;
   //=======================================================================================
   {.core data structures}
   //=======================================================================================

   

   //==END ENUM=============================================================================
   //=======================================================================================
   {.space units data}
   //=======================================================================================

   
   //==END ENUM=============================================================================
   
   {.settlements pictures}
   type TFCRdiSettlementPic=array[1..30] of TImage32;
   //=======================================================================================
   {.global variables}
   //=======================================================================================
   var
      //==========databases and other data structures pre-init==============================
      FCDBhelpTdef: TFCDBtdef;
      
      FCRdiSettlementPic: TFCRdiSettlementPic;
      //==========path strings==============================================================
      {.root path for the directory of the data files, /<user>/My Documents/farcolony}
      FCVcfgDir: string;
      {.language token of the game, until now: EN = english FR = french}
      FCVlang: string;
      {.path of the game}
      FCVpathGame: string;
      {.path for the config file}
      FCVpathCfg: string;
      {.path of the resource directory}
		FCVpathRsrc: string;
      {.path of the XML directory - w/ end separator}
		FCVpathXML: string;
      
      //==========main window related=======================================================
      FCVwinMallowUp: boolean = false;
      {.stored left of the main window}
		FCVwinMlocL: integer;
      {.stored top of the main window}
      FCVwinMlocT: integer;
      {.stored height of the main window}
      FCVwinMsizeH: integer;
      {.stored width of the main window}
      FCVwinMsizeW: integer;
      FCVwMumiW: integer=800;
      FCVwMumiH: integer=540;
      {.indicate to use background in wide or 4:3 mode}
      FCVwinWideScr: boolean;
      {.stroe colony/faction panel location}
      FCVwMcolfacPstore: boolean= false;
      {.store cps panel location}
      FCVwMcpsPstore: boolean= false;
      {.store help panel location}
      FCVwMhelpPstore: boolean= false;
      //==========secondary windows related=================================================
      {.switch to block the updating of the about window before it's created.}
      FCVallowUpAbWin: boolean = false;
      {.switch to block the updating of the new game setup window before it's created.}
      FCVallowUpNGSWin: boolean = false;
      //==========message box===============================================================
      {.message counter}
      FCVmsgCount: integer;
      {.array for store message titles}
      FCVmsgStoMsg: array of string;
      {.array for store message text}
      FCVmsgStoTtl: array of string;
      //==========game system===============================================================
      {.debug mode}
      FCGdebug: boolean =false;
      {.threaded game timer}
      FCGtimeFlow : TgtTimer;
      //==========streams and memory management=============================================
      {.memory stream for encyclopaedia.xml}
      FCVmemEncy: TMemoryStream;
      {.memory stream for ui.xml}
      FCVmemUI: TMemoryStream;
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
      {.miniHTML standard formating}
      {:DEV NOTES: put them in ui_html.}
      FCCFdHead='<p align="left" bgcolor="#374A4A00" bgcolorto="#25252500"><b>';
      FCCFdHeadC='<p align="center" bgcolor="#374A4A00" bgcolorto="#25252500"><b>';
      FCCFdHeadEnd='</b></p>';
      FCCFcolBlue='<font color="#3e3eff00">';
      FCCFcolBlueL='<font color="#409FFF00">';
      FCCFcolEND='</font>';
      FCCFcolGreen='<font color="cllime">';
      FCCFcolOrge='<font color="#FF641a00">';
      FCCFcolRed='<font color="#EA000000">';
      FCCFcolWhBL='<font color="#DCEAFA00">';
      FCCFcolYel='<font color="#FFFFCA00">';
      FCCFidxL6='<ind x="6">';
      FCCFidxL='<ind x="14">';
      FCCFidxL2='<ind x="20">';
      FCCFidxR='<ind x="120">';
      FCCFidxRi='<ind x="140">';
      FCCFidxRR='<ind x="180">';
      FCCFidxRRR='<ind x="240">';
      FCCFidxRRRR='<ind x="340">';    {:DEV NOTES: rename them including the spaceX.}
      FCCFpanelTitle=FCCFidxL2+'<b>';

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
   if not FileExists(FCVpathCfg)
   then
   begin
      FCVlang:= 'EN';
      FCVwinMsizeW:= FCWinMain.Width;
      FCVwinMsizeH:= FCWinMain.Height;
      FCVwinMlocL:= FCWinMain.Left;
      FCVwinMlocT:= FCWinMain.Top;
      FCMdF_ConfigFile_Write(false);
   end
   else if FileExists(FCVpathCfg)
   then FCMdF_ConfigFile_Read(false);
   {.saved games directory initialization}
   if not DirectoryExists(FCVcfgDir+'SavedGames')
   then MkDir(FCVcfgDir+'SavedGames');
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

