{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: surface panel routines

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
unit farc_ui_surfpanel;

interface

uses
   Controls
   ,Graphics
   ,SysUtils;

///<summary>
///   retrieve the SPcurrentOObjIndex variable value
///</summary>
function FCFuiSP_VarCurrentOObj_Get: integer;

///<summary>
///   retrieve the SPcurrentSatIndex variable value
///</summary>
function FCFuiSP_VarCurrentSat_Get: integer;

///<summary>
///   retrieve the SPregionSelected variable value
///</summary>
function FCFuiSP_VarRegionSelected_Get: integer;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   update the region data and picture
///</summary>
///    <param name="SERUregIdx">targeted region index #</param>
///    <param name="SERUonlyPic">update only the region picture if true</param>
procedure FCMuiSP_RegionDataPicture_Update(
   const SERUregIdx: integer;
   const SERUonlyPic: boolean
   );

///<summary>
///   set and display the Surface / Ecosphere Panel
///</summary>
///    <param name="SESoobjIdx">targeted orbital object index</param>
///    <param name="SESsatIdx">[optional, disable by 0] targeted satellite index</param>
///    <param name="SESinit">init the hotspots</param>
procedure FCMuiSP_SurfaceEcosphere_Set(
   const SESoobjIdx
         ,SESsatIdx: integer;
   const SESinit: boolean
   );

///<summary>
///   reset the SPregionSelected to zero
///</summary>
procedure FCMuiSP_VarRegionSelected_Reset;

implementation

uses
   farc_data_init
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_gfx_core
   ,farc_main
   ,farc_ogl_init
   ,farc_univ_func;

var
   SPcurrentOObjIndex
   ,SPcurrentSatIndex
   ,SPregionSelected: integer;

//===================================================END OF INIT============================

function FCFuiSP_EcoDataAtmosphere_Process(
   const SEAPlist: TFCEatmGasStat;
   const SEAPoobjIdx
         ,SEAPsatIdx: integer
   ): string;
{:Purpose: process the required atmosphere list.
    Additions:
      -2012Jan06- *code: function moved in its proper unit.
}
var
   SAEPres: string;
   SAEPisNxtCol: boolean;
   SEAPgasH2
   ,SEAPgasHe
   ,SEAPgasCH4
   ,SEAPgasNH3
   ,SEAPgasH2O
   ,SEAPgasNe
   ,SEAPgasN2
   ,SEAPgasCO
   ,SEAPgasNO
   ,SEAPgasO2
   ,SEAPgasH2S
   ,SEAPgasAr
   ,SEAPgasCO2
   ,SEAPgasNO2
   ,SEAPgasO3
   ,SEAPgasSO2: TFCEatmGasStat;
begin
   SAEPres:='';
   SAEPisNxtCol:=false;
   if SEAPsatIdx=0
   then
   begin
      SEAPgasH2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasH2;
      SEAPgasHe:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasHe;
      SEAPgasCH4:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasCH4;
      SEAPgasNH3:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasNH3;
      SEAPgasH2O:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasH2O;
      SEAPgasNe:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasNe;
      SEAPgasN2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasN2;
      SEAPgasCO:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasCO;
      SEAPgasNO:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasNO;
      SEAPgasO2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasO2;
      SEAPgasH2S:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasH2S;
      SEAPgasAr:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasAr;
      SEAPgasCO2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasCO2;
      SEAPgasNO2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasNO2;
      SEAPgasO3:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasO3;
      SEAPgasSO2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_atmosph.agasSO2;
   end
   else if SEAPsatIdx>0
   then
   begin
      SEAPgasH2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasH2;
      SEAPgasHe
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasHe;
      SEAPgasCH4
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasCH4;
      SEAPgasNH3
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasNH3;
      SEAPgasH2O
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasH2O;
      SEAPgasNe
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasNe;
      SEAPgasN2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasN2;
      SEAPgasCO
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasCO;
      SEAPgasNO
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasNO;
      SEAPgasO2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasO2;
      SEAPgasH2S
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasH2S;
      SEAPgasAr
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasAr;
      SEAPgasCO2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasCO2;
      SEAPgasNO2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasNO2;
      SEAPgasO3
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasO3;
      SEAPgasSO2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SEAPoobjIdx].OO_satList[SEAPsatIdx].OOS_atmosph.agasSO2;
   end;
   {.for hydrogen}
   if SEAPgasH2=SEAPlist
   then
   begin
      SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasH2');
      SAEPisNxtCol:=true;
   end;
   {.for helium}
   if SEAPgasHe=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasHe');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasHe');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for methane}
   if SEAPgasCH4=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasCH4');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasCH4');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for ammonia}
   if SEAPgasNH3=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasNH3');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasNH3');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for water vapor}
   if SEAPgasH2O=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasH2O');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasH2O');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for neon}
   if SEAPgasNe=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasNe');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasNe');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for nitrogen}
   if SEAPgasN2=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasN2');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasN2');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for carbone monoxide}
   if SEAPgasCO=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasCO');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasCO');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for nitrogen oxide}
   if SEAPgasNO=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasNO');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasNO');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for oxygen}
   if SEAPgasO2=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasO2');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasO2');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for hydrogen sulfide}
   if SEAPgasH2S=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasH2S');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasH2S');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for argon}
   if SEAPgasAr=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasAr');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasAr');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for carbone dioxide}
   if SEAPgasCO2=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasCO2');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasCO2');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for nitrogen dioxide}
   if SEAPgasNO2=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasNO2');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasNO2');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for ozone}
   if SEAPgasO3=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasO3');
         SAEPisNxtCol:=true;
      end
      else if SAEPisNxtCol
      then
      begin
         SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasO3');
         SAEPisNxtCol:=false;
      end;
   end;
   {.for sulfur dioxide}
   if SEAPgasSO2=SEAPlist
   then
   begin
      if not SAEPisNxtCol
      then SAEPres:=SAEPres+'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'gasSO2')
      else if SAEPisNxtCol
      then SAEPres:=SAEPres+FCCFidxRi+FCFdTFiles_UIStr_Get(uistrUI, 'gasSO2');
   end;
   Result:=SAEPres;
end;

function FCFuiSP_VarCurrentOOBj_Get: integer;
{:Purpose: retrieve the SPcurrentOObjIndex variable value.
    Additions:
}
begin
   Result:=SPcurrentOObjIndex;
end;

function FCFuiSP_VarCurrentSat_Get: integer;
{:Purpose: retrieve the SPcurrentSatIndex variable value.
    Additions:
}
begin
   Result:=SPcurrentSatIndex;
end;

function FCFuiSP_VarRegionSelected_Get: integer;
{:Purpose: retrieve the SPregionSelected variable value.
    Additions:
}
begin
   Result:=SPregionSelected;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiSP_RegionDataPicture_Update(
   const SERUregIdx: integer;
   const SERUonlyPic: boolean
   );
{:Purpose: update the region data and picture .
Tags set: oobjIdx=FCWM_SP_LDat, satIdx=FCWM_SP_RDat
    Additions:
      -2012Jan06- *code: procedure moved in its proper unit.
      -2010Mar20- *add climate, current average temperature, temperature and windspeed indexes.
                  *add: a switch for only update the region picture.
                  *mod: uses FCWM_SPShReg_Lab for region data display.
                  *mod: store current selected region in FCWM_SP_Surface.Tag.
      -2010Mar18- *add: yearly mean precipitations and windspeed.
      -2010Mar15- *add: Terrain Type and current season.
      -2010Mar14- *add: selection frame.
}
var
   SERUtPic
   ,SERUprecip
   ,SERUidxTemp
   ,SERUidxWdSpd: integer;

   SERUwndSpd
   ,SERUtemp: extended;

   SERUrelief
   ,SERUseason
   ,SERUterrain: string;

   SERUdmpRelief: TFCEregRelief;
   SERUdmpTerrTp: TFCEregSoilTp;
begin
   with FCWinMain do
   begin
      SERUseason:=FCFuF_Ecosph_GetCurSeas(SPcurrentOObjIndex, SPcurrentSatIndex);
      SPregionSelected:=SERUregIdx;
      {.initialize required data}
      if SPcurrentSatIndex=0
      then
      begin
         with FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SPcurrentOObjIndex].OO_regions[SERUregIdx] do
         begin
            SERUdmpTerrTp:=OOR_soilTp;
            SERUdmpRelief:=OOR_relief;
            SERUwndSpd:=OOR_windSpd;
            SERUprecip:=OOR_precip;
            if SERUseason='seasonMin'
            then SERUtemp:=OOR_meanTdMin
            else if SERUseason='seasonMid'
            then SERUtemp:=OOR_meanTdInt
            else if SERUseason='seasonMax'
            then SERUtemp:=OOR_meanTdMax;
         end;
      end
      else if SPcurrentSatIndex>0
      then
      begin
         with FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SPcurrentOObjIndex].OO_satList[SPcurrentSatIndex] do
         begin
            SERUdmpTerrTp:=OOS_regions[SERUregIdx].OOR_soilTp;
            SERUdmpRelief:=OOS_regions[SERUregIdx].OOR_relief;
            SERUwndSpd:=OOS_regions[SERUregIdx].OOR_windSpd;
            SERUprecip:=OOS_regions[SERUregIdx].OOR_precip;
            if SERUseason='seasonMin'
            then SERUtemp:=OOS_regions[SERUregIdx].OOR_meanTdMin
            else if SERUseason='seasonMid'
            then SERUtemp:=OOS_regions[SERUregIdx].OOR_meanTdInt
            else if SERUseason='seasonMax'
            then SERUtemp:=OOS_regions[SERUregIdx].OOR_meanTdMax;
         end;
      end;
      SERUidxTemp:=FCFuF_Index_Get(ufitTemp, SERUtemp);
      SERUidxWdSpd:=FCFuF_Index_Get(ufitWdSpd, SERUwndSpd);
      {.gather the focused terrain picture and set terrain description data}
      SERUterrain:='';
      SERUrelief:='';
      case SERUdmpTerrTp of
         rst01rockDes:
         begin
            SERUterrain:='terrainRDes';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=0;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=1;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=2;
               end;
            end;
         end;
         rst02sandDes:
         begin
            SERUterrain:='terrainSDes';
            if SERUdmpRelief=rr1plain
            then
            begin
               SERUrelief:='reliefPlain';
               SERUtPic:=3;
            end
            else if SERUdmpRelief=rr4broken
            then
            begin
               SERUrelief:='reliefBrok';
               SERUtPic:=4;
            end;
         end;
         rst03volcanic:
         begin
            SERUterrain:='terrainVol';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=5;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=6;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=7;
               end;
            end;
         end;
         rst04polar:
         begin
            SERUterrain:='terrainPol';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=8;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=9;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=10;
               end;
            end;
         end;
         rst05arid:
         begin
            SERUterrain:='terrainArid';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=11;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=12;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=13;
               end;
            end;
         end;
         rst06fertile:
         begin
            SERUterrain:='terrainFert';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=14;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=15;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=16;
               end;
            end;
         end;
         rst07oceanic:
         begin
            SERUterrain:='terrainOcean';
            SERUtPic:=17;
         end;
         rst08coastRockDes:
         begin
            SERUterrain:='terrainCoastRDes';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=18;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=19;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=20;
               end;
            end;
         end;
         rst09coastSandDes:
         begin
            SERUterrain:='terrainCoastSDes';
            if SERUdmpRelief=rr1plain
            then
            begin
               SERUrelief:='reliefPlain';
               SERUtPic:=21;
            end
            else if SERUdmpRelief=rr4broken
            then
            begin
               SERUrelief:='reliefBrok';
               SERUtPic:=22;
            end;
         end;
         rst10coastVolcanic:
         begin
            SERUterrain:='terrainCoastVol';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=23;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=24;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=25;
               end;
            end;
         end;
         rst11coastPolar:
         begin
            SERUterrain:='terrainCoastPol';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=26;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=27;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=28;
               end;
            end;
         end;
         rst12coastArid:
         begin
            SERUterrain:='terrainCoastArid';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=29;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=30;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=31;
               end;
            end;
         end;
         rst13coastFertile:
         begin
            SERUterrain:='terrainCoastFert';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=32;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=33;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=34;
               end;
            end;
         end;
         rst14barren:
         begin
            SERUterrain:='terrainSter';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=35;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=36;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=37;
               end;
            end;
         end;
         rst15icyBarren:
         begin
            SERUterrain:='terrainIcSter';
            case SERUdmpRelief of
               rr1plain:
               begin
                  SERUrelief:='reliefPlain';
                  SERUtPic:=38;
               end;
               rr4broken:
               begin
                  SERUrelief:='reliefBrok';
                  SERUtPic:=39;
               end;
               rr9mountain:
               begin
                  SERUrelief:='reliefMount';
                  SERUtPic:=40;
               end;
            end;
         end;
      end; //==END== case SERUdmpTerrTp ==//
      FCWM_SP_SPic.Bitmap:=FCWM_RegTerrLib.Bitmap[SERUtPic];
      {.set the selection frame}
      FCWM_SP_SurfSel.Left:=FCWM_SP_Surface.HotSpots[SERUregIdx-1].X;
      FCWM_SP_SurfSel.Top:=FCWM_SP_Surface.HotSpots[SERUregIdx-1].Y;
      FCWM_SP_SurfSel.Width:=FCWM_SP_Surface.HotSpots[SERUregIdx-1].Width;
      FCWM_SP_SurfSel.Height:=FCWM_SP_Surface.HotSpots[SERUregIdx-1].Height;
      if not SERUonlyPic
      then
      begin
         {.terrain type}
         FCWM_SPShReg_Lab.HTMLText.Clear;
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'secpTerrTp')+FCCFdHeadEnd
            +FCFdTFiles_UIStr_Get(uistrUI, SERUrelief)+' '+FCFdTFiles_UIStr_Get(uistrUI, SERUterrain)
            +'<br>'
            );
         {.current season}
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'season')+FCCFdHeadEnd
            +FCFdTFiles_UIStr_Get(uistrUI, SERUseason)
            +'<br>'
            );
         {.climate}
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'climate')+FCCFdHeadEnd
            +FCFdTFiles_UIStr_Get(uistrUI, FCFuF_Region_GetClim(SPcurrentOObjIndex, SPcurrentSatIndex, SERUregIdx))
            +'<br>'
            );
         {.temperature}
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'temp')+FCCFdHeadEnd
            +FloatToStr(SERUtemp)+' K ('
            );
         case SERUidxTemp of
            1, 2: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolWhBL);
            3, 4: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolBlueL);
            5, 6, 7: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolGreen);
            8, 9: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolOrge);
            else FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolRed);
         end;
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCFdTFiles_UIStr_Get(uistrUI, 'tempIdx'+FloatToStr(SERUidxTemp))
            +FCCFcolEND+')'
            +'<br>'
            );
         {.yearly mean precipitations}
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'precip')+FCCFdHeadEnd
            +IntToStr(SERUprecip)+' mm/'+FCFdTFiles_UIStr_Get(uistrUI, 'acronYr')
            +'<br>'
            );
         {.yearly mean windspeed}
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'wndspd')+FCCFdHeadEnd
            +FloatToStr(SERUwndSpd)+' m/s ('
            );
         case SERUidxWdSpd of
            0..2: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolGreen);
            3..4: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolBlue);
            5..6: FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolOrge);
            else FCWM_SPShReg_Lab.HTMLText.Add(FCCFcolRed);
         end;
         FCWM_SPShReg_Lab.HTMLText.Add(
            FCFdTFiles_UIStr_Get(uistrUI, 'wspdIdx'+FloatToStr(SERUidxWdSpd))
            +FCCFcolEND+')'
            +'<br>'
            );
      end; //==END== if not SERUonlyPic ==//
   end; //==END== with FCWinMain ==//
end;

procedure FCMuiSP_SurfaceEcosphere_Set(
   const SESoobjIdx, SESsatIdx: integer;
   const SESinit: boolean
   );
{:Purpose: set and display the Surface / Ecosphere Panel.
tags set: FCWM_SurfPanel=FCWM_SurfPanel.Width FCWM_SP_DataSheet:=FCWM_SP_DataSheet.Left
    Additions:
      -2012Jan08- *code: procedure moved in its proper unit.
                  *mod: since the Ecosphere tab doesn't exist, it the region tab that is focused.
                  *add: initialize correctly the region data sheet by load it with data of the first region.
      -2011Feb14- *add: display settlements if a region have one.
                  *mod: some code optimization.
      -2010Jun27- *add: environmnent data.
      -2010Mar21- *mod: code cleanup and optimization.
                  *fix: modify surface map loading to avoid a memory leak.
      -2010Feb21- *add: initialize surface picture tag.
                  *add: store orbital object/satellite indexes in FCWM_SP_LDat/FCWM_SP_RDat.
      -2010Feb06- *add: complete ecosphere display.
      -2010Feb05- *fix: correctly restore panel size after 2 gaseous selected.
      -2010Feb04- *add: atmosphere composition display.
      -2010Feb03- *add: update panel title.
                  *mod: complete surface display.
                  *add: ecosphere data.
      -2010Feb02- *mod: change SESshowIt by SESinit and fully complete the setting.
                  *add/mod: surface display WIP.
      -2010Feb01- *add: switch for display or not the panel.
      -2010Jan31- *add: surface picture for non satellites.
      -2010Jan25- *add: complete surface hotspot initialization.
}
var
   SESdmpTtlReg
   ,SEShots
   ,SEScnt
   ,SESdmpC
   ,SESdmpIdx
   ,SESregSearch
   ,SESregSWdiv3
   ,SESregSWshr1
   ,SESregSWshr2
   ,SESregSHm64shr1
   ,SESregSHm64shr2: integer;

   SESdmpAtmPr
   ,SESdmpCCov
   ,SESdmpHCov: extended;

   SESenv
   ,SESdmpToken
   ,SESdmpStrDat: string;

   SESdmpTp: TFCEduOobjTp;
   SESdmpHydr: TFCEhydroTp;
begin
   with FCWinMain do
   begin
      if not SESinit
      then
      begin
         FCWM_SPShEcos_Lab.HTMLText.Clear;
         FCWM_SP_SPic.Bitmap.Clear;
         SPcurrentOObjIndex:=SESoobjIdx;
         SPcurrentSatIndex:=0;
         SPregionSelected:=0;
         FCWM_SP_DataSheet.ActivePage:=FCWM_SP_ShReg;
         FCWM_SP_SurfSel.Width:=0;
         FCWM_SP_SurfSel.Height:=0;
         FCWM_SP_SurfSel.Left:=0;
         FCWM_SP_SurfSel.Top:=0;
         if SESsatIdx=0
         then
         begin
            SESdmpTp:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_type;
            SESdmpTtlReg:=length(FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_regions)-1;
            SESdmpToken:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_token;
            SESdmpAtmPr:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_atmPress;
            SESdmpCCov:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_cloudsCov;
            SESdmpHydr:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_hydrotp;
            SESdmpHCov:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_hydroArea;
            SESenv:=FCFuF_Env_GetStr(
               FCV3DselSsys
               ,FCV3DselStar
               ,SESoobjIdx
               ,0
               );
         end
         else if SESsatIdx>0
         then
         begin
            SESdmpTp:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_type;
            SESdmpTtlReg:=length(FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_regions)-1;
            SESdmpToken:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_token;
            SESdmpAtmPr:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_atmPress;
            SESdmpCCov:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_cloudsCov;
            SESdmpHydr:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_hydrotp;
            SESdmpHCov:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_hydroArea;
            SPcurrentSatIndex:=SESsatIdx;
            SESenv:=FCFuF_Env_GetStr(
               FCV3DselSsys
               ,FCV3DselStar
               ,SESoobjIdx
               ,SESsatIdx
               );
         end;
         FCWM_SurfPanel.Caption.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_SurfPanel')+FCFdTFiles_UIStr_Get(dtfscPrprName,SESdmpToken);
         {.environment type subsection}
         FCWM_SPShEcos_Lab.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'secpEnv')+'<br>'+FCCFidxL+SESenv+'<br>');
         {.atmosphere subsection}
         FCWM_SPShEcos_Lab.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'secpAtm'));
         if SESdmpAtmPr=0
         then FCWM_SPShEcos_Lab.HTMLText.Add('<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'comNoneP'))
         else if SESdmpAtmPr>0
         then
         begin
            FCWM_SPShEcos_Lab.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'secpGasM'));
            SESdmpStrDat:=FCFuiSP_EcoDataAtmosphere_Process(agsMain, SESoobjIdx, SESsatIdx);
            FCWM_SPShEcos_Lab.HTMLText.Add(SESdmpStrDat);
            FCWM_SPShEcos_Lab.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'secpGasS'));
            SESdmpStrDat:=FCFuiSP_EcoDataAtmosphere_Process(agsSec, SESoobjIdx, SESsatIdx);
            FCWM_SPShEcos_Lab.HTMLText.Add(SESdmpStrDat);
            FCWM_SPShEcos_Lab.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'secpGasT'));
            SESdmpStrDat:=FCFuiSP_EcoDataAtmosphere_Process(agsTrace, SESoobjIdx, SESsatIdx);
            if SESdmpStrDat<>''
            then FCWM_SPShEcos_Lab.HTMLText.Add(SESdmpStrDat)
            else FCWM_SPShEcos_Lab.HTMLText.Add('<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'comNoneP'));
            if SESdmpAtmPr<>1
            then
            begin
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'secpPress')
                  +FCCFidxR+FCFdTFiles_UIStr_Get(uistrUI, 'secpClCov')
                  );
               FCWM_SPShEcos_Lab.HTMLText.Add
                  ('<br>'+FCCFidxL+floattostr(SESdmpAtmPr)+' mbars'+FCCFidxR+floattostr(SESdmpCCov)+' %');
            end;
         end; //==END== else if SESdmpAtmPr>0 ==//
         FCWM_SPShEcos_Lab.HTMLText.Add('<br>'+FCFdTFiles_UIStr_Get(uistrUI, 'secpHydr')+'<br>');
         case SESdmpHydr of
            htNone: FCWM_SPShEcos_Lab.HTMLText.Add(FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'comNoneP'));
            htVapor:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpVap')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
            htLiquid:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpLiq')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
            htIceSheet:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpISh')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
            htCrystal:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpCryst')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
            htLiqNH3:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpLiqNH3')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
            htLiqCH4:
               FCWM_SPShEcos_Lab.HTMLText.Add(
                  FCCFidxL
                  +FCFdTFiles_UIStr_Get(uistrUI, 'specpHtpLiqCH4')
                  +FCFdTFiles_UIStr_Get(uistrUI, 'secpCov')+floattostr(SESdmpHCov)+' %)'
                  );
         end; //==END== case SESdmpHydr ==//
         {.set the ecosphere panel if it's a gaseous planet}
         if (SESdmpTp>oobtpPlan_Icy_CallistoH3H4Atm0)
            and (SESdmpTp<oobtpSat_Aster_Metall)
         then
         begin
            {.set interface}
            FCWM_SP_LDatFrm.Visible:=false;
            FCWM_SP_SPicFrm.Visible:=false;
            FCWM_SP_RDatFrm.Visible:=false;
            FCWM_SP_Surface.Visible:=false;
            if FCWM_SurfPanel.Tag=0
            then FCWM_SurfPanel.Tag:=FCWM_SurfPanel.Width;
            if FCWM_SP_DataSheet.Tag=0
            then FCWM_SP_DataSheet.Tag:=FCWM_SP_DataSheet.Left;
            FCWM_SurfPanel.Width:=232;
            FCWM_SP_DataSheet.Align:=alLeft;
         end //==END== if (SESdmpTp>Icy_CallistoH3H4Atm0) and (<Aster_Metall) ==//
         {.otherwise for non gaseous orbital objects}
         else
         begin
            if FCWM_SurfPanel.Tag>0
            then
            begin
               {.set interface}
               FCWM_SP_LDatFrm.Visible:=true;
               FCWM_SP_SPicFrm.Visible:=true;
               FCWM_SP_RDatFrm.Visible:=true;
               FCWM_SP_Surface.Visible:=true;
               FCWM_SurfPanel.Width:=FCWM_SurfPanel.Tag;
               FCWM_SurfPanel.Tag:=0;
               SPregionSelected:=0;
               FCWM_SP_DataSheet.Align:=alCustom;
               FCWM_SP_DataSheet.Left:=FCWM_SP_DataSheet.Tag;
               FCWM_SP_DataSheet.Tag:=0;
            end;
            {.set the hotspots if needed}
            if (SESdmpTtlReg>0)
               and (FCWM_SP_Surface.HotSpots.Count<>SESdmpTtlReg)
            then
            begin
               FCWM_SP_Surface.Enabled:=false;
               FCWM_SP_Surface.HotSpots.Clear;
               SESregSWdiv3:=FCWM_SP_Surface.Width div 3;
               SESregSWshr1:=FCWM_SP_Surface.Width shr 1;
               SESregSWshr2:=FCWM_SP_Surface.Width shr 2;
               SESregSHm64shr1:=(FCWM_SP_Surface.Height-64) shr 1;
               SESregSHm64shr2:=(FCWM_SP_Surface.Height-64) shr 2;
               FCMgfxC_Settlements_Hide;
               SEScnt:=1;
               while SEScnt<=SESdmpTtlReg do
               begin
                  SESdmpC:=SEScnt;
                  SEShots:=SESdmpC-1;
                  FCWM_SP_Surface.HotSpots.Add;
                  FCWM_SP_Surface.HotSpots[SEShots].ID:=SESdmpC;
                  FCWM_SP_Surface.HotSpots[SEShots].Clipped:=false;
                  FCWM_SP_Surface.HotSpots[SEShots].Down:=false;
                  FCWM_SP_Surface.HotSpots[SEShots].HoverColor:=clNone;
                  FCWM_SP_Surface.HotSpots[SEShots].ClickColor:=clNone;
                  case SESdmpC of
                     1:
                     begin
                        FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                        FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                        FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                        FCWM_SP_Surface.HotSpots[SEShots].Y:=0;
                     end;
                     2, 3:
                     begin
                        {.width}
                        case SESdmpTtlReg of
                           4:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr1;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=FCWM_SP_Surface.Height-64;
                           end;
                           6:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr1;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                           end;
                           8:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWdiv3;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                           end;
                           10:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr2;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                           end;
                           14:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr2;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=(FCWM_SP_Surface.Height-64) div 3;
                           end;
                           18:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr2;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                           end;
                           22:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 5;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                           end;
                           26:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 6;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                           end;
                           30:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 7;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                           end;
                        end; //==END== case SESdmpTtlReg ==//
                        {.positions}
                        if SESdmpC=2
                        then FCWM_SP_Surface.HotSpots[SEShots].X:=0
                        else FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SEShots].Width-1;
                        FCWM_SP_Surface.HotSpots[SEShots].Y:=31;
                     end; //==END== 2, 3: ==//
                     4..29:
                     begin
                        case SESdmpTtlReg of
                           4:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                              FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                              FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
                           end;
                           6:
                           begin
                              if SESdmpC=6
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr1;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-3].X;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y
                                    :=FCWM_SP_Surface.HotSpots[1].Y+FCWM_SP_Surface.HotSpots[1].Height;
                              end;
                           end;
                           8:
                           begin
                              if SESdmpC=8
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33;
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWdiv3;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                                 if SESdmpC=4
                                 then
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X
                                       :=FCWM_SP_Surface.HotSpots[3-1].X+FCWM_SP_Surface.HotSpots[3-1].Width;
                                    FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[3-1].Y;
                                 end
                                 else
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-3-1].X;
                                    FCWM_SP_Surface.HotSpots[SEShots].Y
                                       :=FCWM_SP_Surface.HotSpots[2-1].Y+FCWM_SP_Surface.HotSpots[2-1].Height;
                                 end;
                              end;
                           end;
                           10..18:
                           begin
                              if ((SESdmpC=10) and (SESdmpTtlReg=10))
                                 or ((SESdmpC=14) and (SESdmpTtlReg=14))
                                 or ((SESdmpC=18) and (SESdmpTtlReg=18))
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=SESregSWshr2;
                                 case SESdmpTtlReg of
                                    10:
                                    begin
                                       FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr1;
                                       if (SESdmpC=4)
                                          or (SESdmpC=5)
                                       then
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X
                                             :=FCWM_SP_Surface.HotSpots[SEShots-1].X
                                                +FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                          FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[3-1].Y;
                                       end
                                       else
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-4-1].X;
                                          FCWM_SP_Surface.HotSpots[SEShots].Y
                                             :=FCWM_SP_Surface.HotSpots[2-1].Y+FCWM_SP_Surface.HotSpots[2-1].Height;
                                       end
                                    end;
                                    14:
                                    begin
                                       FCWM_SP_Surface.HotSpots[SEShots].Height:=(FCWM_SP_Surface.Height-64) div 3;
                                       if (SESdmpC=4)
                                          or (SESdmpC=5)
                                       then
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X
                                             :=FCWM_SP_Surface.HotSpots[SEShots-1].X
                                                +FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                          FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[3-1].Y;
                                       end
                                       else
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-4-1].X;
                                          if (SESdmpC>=6)
                                             and (SESdmpC<=9)
                                          then FCWM_SP_Surface.HotSpots[SEShots].Y
                                             :=FCWM_SP_Surface.HotSpots[2-1].Y+FCWM_SP_Surface.HotSpots[2-1].Height
                                          else FCWM_SP_Surface.HotSpots[SEShots].Y
                                             :=FCWM_SP_Surface.HotSpots[6-1].Y+FCWM_SP_Surface.HotSpots[6-1].Height;
                                       end;
                                    end;
                                    18:
                                    begin
                                       FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                                       if (SESdmpC=4)
                                          or (SESdmpC=5)
                                       then
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X
                                             :=FCWM_SP_Surface.HotSpots[SEShots-1].X
                                                +FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                          FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[3-1].Y;
                                       end
                                       else
                                       begin
                                          FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-4-1].X;
                                          case SESdmpC of
                                             6..9: FCWM_SP_Surface.HotSpots[SEShots].Y
                                                :=FCWM_SP_Surface.HotSpots[2-1].Y+FCWM_SP_Surface.HotSpots[2-1].Height;
                                             10..13: FCWM_SP_Surface.HotSpots[SEShots].Y
                                                :=FCWM_SP_Surface.HotSpots[6-1].Y+FCWM_SP_Surface.HotSpots[6-1].Height;
                                             14..18: FCWM_SP_Surface.HotSpots[SEShots].Y
                                                :=FCWM_SP_Surface.HotSpots[10-1].Y+FCWM_SP_Surface.HotSpots[10-1].Height;
                                          end;
                                       end;
                                    end;
                                 end; //==END== case SESdmpTtlReg ==//
                              end;
                           end; //==END== 10..18 ==//
                           22:
                           begin
                              if SESdmpC=22
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 5;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                                 if (SESdmpC>=4)
                                    and (SESdmpC<=6)
                                 then
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X
                                       :=FCWM_SP_Surface.HotSpots[SEShots-1].X+FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                    FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[2].Y;
                                 end
                                 else
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-6].X;
                                    case SESdmpC of
                                       7..11: FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[1].Y+FCWM_SP_Surface.HotSpots[1].Height;
                                       12..16: FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[6].Y+FCWM_SP_Surface.HotSpots[6].Height;
                                       else FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[11].Y+FCWM_SP_Surface.HotSpots[11].Height;
                                    end;
                                 end;
                              end;
                           end; //==END== 22 ==//
                           26:
                           begin
                              if SESdmpC=26
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 6;
                                 FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                                 if (SESdmpC>=4)
                                    and (SESdmpC<=7)
                                 then
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X
                                       :=FCWM_SP_Surface.HotSpots[SEShots-1].X
                                          +FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                    FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[2].Y;
                                 end
                                 else
                                 begin
                                    FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-7].X;
                                    case SESdmpC of
                                       8..13: FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[1].Y+FCWM_SP_Surface.HotSpots[1].Height;
                                       14..19: FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[7].Y+FCWM_SP_Surface.HotSpots[7].Height;
                                       else FCWM_SP_Surface.HotSpots[SEShots].Y
                                          :=FCWM_SP_Surface.HotSpots[13].Y+FCWM_SP_Surface.HotSpots[13].Height;
                                    end;
                                 end;
                              end;
                           end; //==END== 26 ==//
                           30:
                           begin
                              FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width div 7;
                              FCWM_SP_Surface.HotSpots[SEShots].Height:=SESregSHm64shr2;
                              if (SESdmpC>=4)
                                 and (SESdmpC<=8)
                              then
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].X
                                    :=FCWM_SP_Surface.HotSpots[SEShots-1].X+FCWM_SP_Surface.HotSpots[SEShots-1].Width;
                                 FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.HotSpots[2].Y;
                              end
                              else
                              begin
                                 FCWM_SP_Surface.HotSpots[SEShots].X:=FCWM_SP_Surface.HotSpots[SESdmpC-7-1].X;
                                 case SESdmpC of
                                    9..15: FCWM_SP_Surface.HotSpots[SEShots].Y
                                       :=FCWM_SP_Surface.HotSpots[1].Y+FCWM_SP_Surface.HotSpots[1].Height;
                                    16..22: FCWM_SP_Surface.HotSpots[SEShots].Y
                                       :=FCWM_SP_Surface.HotSpots[8].Y+FCWM_SP_Surface.HotSpots[8].Height;
                                    else FCWM_SP_Surface.HotSpots[SEShots].Y
                                       :=FCWM_SP_Surface.HotSpots[15].Y+FCWM_SP_Surface.HotSpots[15].Height;
                                 end;
                              end;
                           end;
                        end; //==END== case SESdmpTtlReg ==//
                     end; //==END== 4..29 ==//
                     30:
                     begin
                        with FCWM_SP_Surface.HotSpots[SEShots] do
                        begin
                           FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                           FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                           FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                           FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33;
                        end;
                     end;
                  end; //==END== case SESdmpC ==//
//                  FCRdiSettlementPic[SEScnt].Left:=FCWM_SP_Surface.HotSpots[SEShots].X+(FCWM_SP_Surface.HotSpots[SEShots].Width shr 1)-(FCRdiSettlementPic[SEScnt].Width shr 1);
//                  FCRdiSettlementPic[SEScnt].Top:=FCWM_SP_Surface.HotSpots[SEShots].Y+4;

                  if ((SESsatIdx=0) and (FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_regions[SEScnt].OOR_setSet>0))
                     or ((SESsatIdx>0) and (FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SESoobjIdx].OO_satList[SESsatIdx].OOS_regions[SEScnt].OOR_setSet>0))
                  then FCMgfxC_Settlement_SwitchState(SEScnt);
                  inc(SEScnt);
               end; //==END== while SEScnt<=SESdmpTtlReg ==//;
            end; //==END== if (SESdmpTtlReg>0) and (HotSpots.Count<>SESdmpTtlReg) ==//
            {.load the surface picture}
            case SESdmpTp of
               oobtpAster_Metall: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_metal.jpg');
               oobtpAster_Sili: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_sili.jpg');
               oobtpAster_Carbo:FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_carb.jpg');
               oobtpAster_Icy: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_icy.jpg');
               oobtpPlan_Tellu_EarthH0H1..oobtpPlan_Tellu_VenusH4:
               begin
                  if FileExists(FCVpathRsrc+'pics-ogl-oobj-pers\'+SESdmpToken+'.jpg')
                  then FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-pers\'+SESdmpToken+'.jpg')
                  else FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-pers\_error_map.jpg');
               end;
               oobtpPlan_Tellu_MercuH0..oobtpPlan_Icy_CallistoH3H4Atm0:
               begin
                  try
                     SESdmpIdx:=FCFoglInit_StdTexIdx_Get(FC3DobjPlan[FCV3DselOobj].Material.LibMaterialName);
                     FC3DobjPlan[FCV3DselOobj].Material.MaterialLibrary.Materials[SESdmpIdx].Material.Texture.Image
                        .SaveToFile(FCVpathCfg+'swap.jpg');
                  finally
                     FCWM_SP_Surface.Picture.LoadFromFile(FCVpathCfg+'swap.jpg');
                  end;
               end;
               oobtpSat_Aster_Metall: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_metal.jpg');
               oobtpSat_Aster_Sili: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_sili.jpg');
               oobtpSat_Aster_Carbo: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_carb.jpg');
               oobtpSat_Aster_Icy: FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-std\aster_icy.jpg');
               oobtpSat_Tellu_Titan..oobtpSat_Tellu_Earth:
               begin
                  if FileExists(FCVpathRsrc+'pics-ogl-oobj-pers\'+SESdmpToken+'.jpg')
                  then FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-pers\'+SESdmpToken+'.jpg')
                  else FCWM_SP_Surface.Picture.LoadFromFile(FCVpathRsrc+'pics-ogl-oobj-pers\_error_map.jpg');
               end;
               oobtpSat_Tellu_Lunar..oobtpSat_Tellu_Io, oobtpSat_Icy_Pluto..oobtpSat_Icy_Callisto:
               begin
                  try
                     fcwinmain.caption:=inttostr(FCV3DselSat);
                     SESdmpIdx:=FCFoglInit_StdTexIdx_Get(FC3DobjSat[FCV3DselSat].Material.LibMaterialName);
                     FC3DobjSat[FCV3DselSat].Material.MaterialLibrary.Materials[SESdmpIdx].Material.Texture.Image
                        .SaveToFile(FCVpathCfg+'swap.jpg');
                  finally
                     FCWM_SP_Surface.Picture.LoadFromFile(FCVpathCfg+'swap.jpg');
                  end;
               end;
            end; //==END== case SESdmpTp ==//
            FCWM_SP_Surface.Enabled:=True;
            FCWM_SP_Surface.Refresh;
         end; //==END== else not gaseous ==//
         if not FCWM_SurfPanel.Visible
         then FCWM_SurfPanel.Visible:=true;
         if FCWM_SurfPanel.Tag=0
         then FCMuiSP_RegionDataPicture_Update(1, false);
      end //==END== if not SESinit ==//
      else if SESinit
      then
      begin
         FCWM_SurfPanel.Visible:=false;
         SESdmpTp:=oobtpAster_Metall;
         SESdmpTtlReg:=4;
         FCWM_SurfPanel.Caption.Text:='';
         SPcurrentOObjIndex:=0;
         SPcurrentSatIndex:=0;
         SPregionSelected:=0;
         FCWM_SP_Surface.Enabled:=false;
         FCWM_SP_Surface.HotSpots.Clear;
         SEScnt:=1;
         while SEScnt<=4 do
         begin
            SESdmpC:=SEScnt;
            SEShots:=SESdmpC-1;
            FCWM_SP_Surface.HotSpots.Add;
            FCWM_SP_Surface.HotSpots[SEShots].ID:=SESdmpC;
            FCWM_SP_Surface.HotSpots[SEShots].Clipped:=false;
            FCWM_SP_Surface.HotSpots[SEShots].Down:=false;
            FCWM_SP_Surface.HotSpots[SEShots].HoverColor:=clNone;
            FCWM_SP_Surface.HotSpots[SEShots].ClickColor:=clNone;
            case SESdmpC of
               1:
               begin
                  FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                  FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                  FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                  FCWM_SP_Surface.HotSpots[SEShots].Y:=0;
               end;
               2, 3:
               begin
                  FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width shr 1;
                  FCWM_SP_Surface.HotSpots[SEShots].Height:=FCWM_SP_Surface.Height-64;
                  if SESdmpC=2
                  then FCWM_SP_Surface.HotSpots[SEShots].X:=0
                  else FCWM_SP_Surface.HotSpots[SEShots].X:=Width-1;
                  FCWM_SP_Surface.HotSpots[SEShots].Y:=31;
               end;
               4:
               begin
                  FCWM_SP_Surface.HotSpots[SEShots].Width:=FCWM_SP_Surface.Width;
                  FCWM_SP_Surface.HotSpots[SEShots].Height:=32;
                  FCWM_SP_Surface.HotSpots[SEShots].X:=0;
                  FCWM_SP_Surface.HotSpots[SEShots].Y:=FCWM_SP_Surface.Height-33
               end;
            end;
            inc(SEScnt)
         end; //==END== while SEScnt<=4 ==//
         FCWM_SP_Surface.Refresh;
         FCWM_SP_Surface.HotSpots.Clear;
      end; //==END== else if SESinit ==//
   end; //==END== with FCWinMain ==//
end;

procedure FCMuiSP_VarRegionSelected_Reset;
{:Purpose: reset the SPregionSelected to zero.
    Additions:
}
begin
   SPregionSelected:=0;
end;

end.
