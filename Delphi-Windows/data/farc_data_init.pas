{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: global data initialization and all core data related functions

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
   Classes,
   SysUtils,
   Windows,

   GLAtmosphere,
   GLObjects,
   GLMaterial,
   GLScene,

   oxLib3dsImports,
   oxLib3dsMeshLoader,

//   GLVectorFileObjects
//   ,GLFile3DSSceneObjects
//,glfile3ds

   o_GTTimer

   ,GR32_Image;

///<summary>
///   initialize all the basic data, test the configuration file and the save games
///   directory.
///</summary>
procedure FCMdInit_Initialize;

   type TFCRtopdef= record
      TD_link: string[20];
      TD_str: string;
   end;
      TFCDBtdef= array of TFCRtopdef;
   //=======================================================================================
   {.core data structures}
   //=======================================================================================

   {.population types, used for all other data structures than colony's population}
   {:DEV NOTES: update infrastrucdb.xml + FCMdF_DBInfra_Read.}
   type TFCEdiPopType=(
      ptColonist
      ,ptOfficer
      ,ptMissSpe
      ,ptBiolog
      ,ptDoctor
      ,ptTechnic
      ,ptEngineer
      ,ptSoldier
      ,ptCommando
      ,ptPhysic
      ,ptAstroph
      ,ptEcolog
      ,ptEcoform
      ,ptMedian
      ,ptRebels
      ,ptMilitia
      );

   //==END ENUM=============================================================================
   //=======================================================================================
   {.space units data}
   //=======================================================================================
   {list of equipment module classes}
   {:DEV NOTES: update scdesignsdb.xml.}
   type TFCEemClass=(
      {compartment}
      emcCompart
      {control as bridge or cockpit}
      ,emcCtrl
      {hull modification as a spinning hull w/ it's mechanism}
      ,emcHullMod
      {powergrid (generators and capacitors)}
      ,emcPwrGrid
      {space drive}
      ,emcSpDrive
      {subsystem}
      ,emcSubSys
      {weapon system}
      ,emcWeapSys
      );
   {.architecture types}
   {:DEV NOTES: update scintstrucdb.xml + FCMdFiles_DBSpaceCrafts_Read.}
   type TFCEscArchTp=(
      {.for internal use only, do not put it in xml}
      scatNone
      {Deep-Space Vehicle}
      ,scarchtpDSV
      {Heavy-Lift Vehicle}
      ,scarchtpHLV
      {Lander Vehicle}
      ,scarchtpLV
      {Lander/Ascent Vehicle}
      ,scarchtpLAV
      {Orbital Multipurpose Vehicle}
      ,scarchtpOMV
      {Stabilized Space Infrastructure}
      ,scarchtpSSI
      {Transatmospheric Vehicle}
      ,scarchtpTAV
      {Beam Sail Vehicle}
      ,scarchtpBSV
      );
   {list of control module types}
   {:DEV NOTES: update scintstrucdb.xml.}
   type TFCEscCtlMdlTp=(
      {cockpit}
      sccmtCockpit
      {control bridge}
      ,sccmtBridge
      {unnamed controls - by an AI}
      ,sccmtUnna
      );
   {list of internal structure general shapes}
   {:DEV NOTE: UPDATE scintstrucdb.xml.}
   type TFCEisShape=(
      {assembled: assembled parts with a central beam or not}
      stAssem
      {composed of modules of SEV shape}
      ,stModul
      {spherical shape}
      ,stSpher
      {cylindrical shape}
      ,stCylin
      {streamlined cylindrical shape}
      ,stCylSt
      {streamlined delta shape}
      ,stDelta
      {box shape}
      ,stBox
      {toroidal shape}
      ,stTorus
      );
   //==END ENUM=============================================================================
   {datastructure of spacecraft's internal structures}
   type TFCRscIntStr = record
      {internal infrastructure db token id}
      SCIS_token: string[20];
      {overall shape of the structure}
      SCIS_shape: TFCEisShape;
      {architecture type}
      SCIS_archTp: TFCEscArchTp;
      {type of control module allowed for the internal structure}
      SCIS_contMdlAllwd: TFCEscCtlMdlTp;
      {overall length in meter [RTO-1]}
      SCIS_length: extended;
      {overall wingsapn in meter [RTO-1]}
      SCIS_wingsp: extended;
      {overall height in meter [RTO-1]}
      SCIS_height: extended;
      {available volume for the design in cubic meter [RTO-1]}
      SCIS_availStrVol: extended;
      {available surface for the design in square meter [RTO-1]}
      SCIS_availStrSur: extended;
      {max volume, of total available, that can be occupied by the spacedrive [RTO-1]}
      SCIS_driveMaxVol: extended;
      {max surface, of total available, that can be occupied by the spacedrive [RTO-1]}
      SCIS_driveMaxSur: extended;
   end;
      {.spacecraft's internal structures dynamic array}
      TFCDBscintStruc = array of TFCRscIntStr;
   type TFCRscEqMdl = record
      SCEM_token: string[20];
      SCEM_emClass: TFCEemClass;
      //SCEM_subDriveData: Tlink to sub datastructure
//       SCEM_thrPerf: double; //rto-1 thrust / cubicmeter of volume of drive
                             {DEV NOTE: will be replaced later by a more
                             expanded structure (for taking in account R&D)}

   end;
      {.equipment modules dynamic array}
      TFCDBscEqMdls = array of TFCRscEqMdl;
   {datastructure of spacecraft's designs}
   {:DEV NOTES: update FCMdFiles_DBSpaceCrafts_Read.}
   type TFCRspUdsgn = record
      {design db token id}
      SUD_token: string[20];
      {data structure clone of the internal structure linked to the design}
      SCD_intStrClone: TFCRscIntStr;
      {used volume out the available volume, in cubic meter [RTO-1}
      SCD_usedVol: extended;
      {used surface out the available surface, in square meter [RTO-1}
      SCD_usedSur: extended;
      {empty mass of the spacecraft, w/o payload & crew [RTO-2]}
      SCD_massEmp: extended;
      {list of installed equipment modules}
      SCD_eqMdlInst: array of TFCRscEqMdl;
      {ISP of installed space drive}
      SCD_spDriveISP: integer;
      {maximum reaction mass volume the spacecraft can carry}
      SCD_spDriveRMassMaxVol: extended;
      {.capabilities. when updated, update too: farc_spu_functions/TFCEsufCapab}
      SUD_capInterstel: boolean;
      SUD_capColoniz: boolean;
      SUD_capPassngr: boolean;
      SUD_capCombat: boolean;
      {DEV NOTE:
         total mass
         drive cloned: token / perf thr/vol of drive / rmass type product token
         total drive thr
      }
  end;
      {.spacecraft's designs dynamic array}
      TFCDBscDesigns = array of TFCRspUdsgn;
   {.settlements pictures}
   type TFCRdiSettlementPic=array[1..30] of TImage32;
   //=======================================================================================
   {.global variables}
   //=======================================================================================
   var
      //==========databases and other data structures pre-init==============================
      FCDBhelpTdef: TFCDBtdef;
      FCDBscDesigns: TFCDBscDesigns;
      FCDBscEqMdls: TFCDBscEqMdls;
      FCDBscIntStruc: TFCDBscintStruc;
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
      //==========3d related================================================================
      {:DEV NOTES: put them in farc_data_ogl.}
      {.material library for standard planetary textures}
      FC3DmatLibSplanT: TGLMaterialLibrary;
      {.objects list for asteroids}
      FC3DobjAster: array of TDGLib3dsStaMesh;
      {.dump asteroid}
      FC3DobjAsterDmp: TDGLib3dsStaMesh;
      {.objects list for atmospheres}
      FC3DobjAtmosph: array of TGLAtmosphere;
      {.objects list for object groups}
      FC3DobjGrp: array of TGLDummyCube;
      {.objects list for gravity well}
      FC3DobjPlanGrav: array of TGLLines;
      {.objects list for orbits}
      FC3DobjPlanOrbit: array of TGLLines;
      {.objects list for planets}
      FC3DobjPlan: array of TGLSphere;
      {.objects list for satellite / asteroids}
      FC3DobjSatAster: array of TDGLib3dsStaMesh;
      {.objects list for satellite atmospheres}
      FC3DobjSatAtmosph: array of TGLAtmosphere;
      {.objects list for object satellite groups}
      FC3DobjSatGrp: array of TGLDummyCube;
      {.objects list for satellite gravity well}
      FC3DobjSatGrav: array of TGLLines;
      {.objects list for satellite orbits}
      FC3DobjSatOrbit: array of TGLLines;
      {.objects list for satellites}
      FC3DobjSat: array of TGLSphere;
      {.objects list for space units, tag= faction id#, tagfloat= owned index}
      FC3DobjSpUnit: array of TDGLib3dsStaMesh;//TGLFile3DSFreeForm;
      {.index which target selected object}
      FCV3DselOobj: integer;
      {.index which target selected satellite}
      FCV3DselSat: integer;
      {.index of targeted space unit}
      FCV3DselSpU: integer;
      {.selected stellar system for 3d view, related to FCRplayer}
      FCV3DselSsys: integer;
      {.selected star for 3d view, related to FCRplayer}
      FCV3DselStar: integer;
      {.total orbital object created in current 3d main view w/o count central star}
      FCV3DttlOobj: integer;
      {.total satellites the linked orbital object have}
      FCV3DttlSat: integer;
      {.total space units created in current 3d main view}
      FCV3DttlSpU: integer;
      {.HR standard map (2048*1024) switch, false= 1024*512}
      FCV3DstdTresHR: boolean;
      {.store data for intial size of a targeted space unit}
      FCV3DspUnSiz: extended;
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

