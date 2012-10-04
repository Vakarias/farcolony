{=====(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved================

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: stellar objects functions (data processing only != FUG units)

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

unit farc_univ_func;

interface

uses
   SysUtils

   ,farc_data_univ;

type TFCEufIdxTp=(
   ufitTemp
   ,ufitWdSpd
   );

type TFCEufStelObj=(
   ufsoSsys
   ,ufsoStar
   ,ufsoOObj
   ,ufsoSat
   );

///<summary>
/// record used to retrieve the volumes taken by the gases. Use the internal AtmosphereGases_CalculatePercents method to calculate them
///</summary>
type TFCRufAtmosphereGasesPercent=record
   AGP_atmosphericPressure: extended;
   AGP_primaryGasPercent: integer;
   AGP_secondaryGasPercent: extended;
   AGP_traceGasPercent: extended;
   ///<summary>
   ///   calculate the percents of total volume taken by secondary and trace gases, the percents are by gases
   ///</summary>
   ///   <param name="StarSytem">star system index #</param>
   ///   <param name="Star">star index #</param>
   ///   <param name="OrbitalObj">orbital object index #</param>
   ///   <param name="SatelliteObj">[optional] satellite index #</param>
   ///   <returns>[format x.xx ] load the AGP_primaryGasPercent/AGP_secondaryGasPercent/AGP_traceGasPercent and AGP_atmosphericPressure data with results</returns>
   ///   <remarks>the procedure reset itself the record's data</remarks>
   procedure AtmosphereGases_CalculatePercents(
      const StarSytem
            ,Star
            ,OrbitalObj
            ,SatelliteObj: integer
      );
end;

///<summary>
///   [1]= star system index, [2]= star index, [3]= orbital object index, [4]= satellite index
///</summary>
type TFCRufStelObj = array[0..4] of integer;

///<summary>
///   get the current season token
///</summary>
///    <param name="GCSooIdx">orbital object index</param>
///    <param name="GCSsatIdx">[optional] satellite index</param>
function FCFuF_Ecosph_GetCurSeas(const GCSooIdx, GCSsatIdx: integer): string;

///<summary>
///   get the environment enum
///</summary>
function FCFuF_Env_Get(
   const EGssys
         ,EGstar
         ,EGoobj
         ,EGsat: integer
   ): TFCEduEnvironmentTypes; overload;

function FCFuF_Env_Get(
   const EGssys
         ,EGstar
         ,EGoobj
         ,EGsat: string
   ): TFCEduEnvironmentTypes; overload;

///<summary>
///   get the environment string
///</summary>
function FCFuF_Env_GetStr(
   const EGSssys
         ,EGSstar
         ,EGSoobj
         ,EGSsat: integer
   ): string; overload;

function FCFuF_Env_GetStr(
   const EGSssys
         ,EGSstar
         ,EGSoobj
         ,EGSsat: string
   ): string; overload;

///<summary>
///   get the requested index of a given value, as for temperature or windspeed for example.
///</summary>
///    <param name=""></param>
function FCFuF_Index_Get(
   const IGtp: TFCEufIdxTp;
   const IGvalue: extended
   ): integer;

///<summary>
///   calculate surface temperate by process the mean value between the 4 orbital periods
///</summary>
///    <param name="OPGMToobjIdx">orbital object index #</param>
///    <param name="OPGMTsatIdx">[optional] satellite index</param>
function FCFuF_OrbPeriod_GetMeanTemp(const OPGMToobjIdx, OPGMTsatIdx: integer): extended;

///<summary>
///   get the climate token of a choosen region
///</summary>
///    <param name="RGCooIdx">orbital object index</param>
///    <param name="RGCsatIdx">[optional] satellite index</param>
///    <param name="RGCregIdx">region index</param>
function FCFuF_Region_GetClim(const RGCooIdx, RGCsatIdx, RGCregIdx: integer): string;

///<summary>
///   extract a defined region location and put it in a string in x;y format or plain text if required
///</summary>
function FCFuF_RegionLoc_Extract(
   const RLEssysIdx
         ,RLEstarIdx
         ,RLEoobjIdx
         ,RLEsatIdx
         ,RLEregIdx: integer
   ): string;

///<summary>
///   calculate the power, in watts / m2, provided by a star in space
///</summary>
///   <param name="SLCPstarLum">star luminosity</param>
///   <param name="SLCPoobjDist">distance (of an orbital object) from the star, in AU</param>
function FCFuF_StarLight_CalcPower(const SLCPstarLum, SLCPoobjDist: extended): extended;

///<summary>
///   retrieve db index number of asked star system, star, orbital object and satellite
///   hierarchy is in this natural order: star system> star> orbital object> satellite
///   it needs hierarchical parent index data for be able to retrieve the desired object
///</summary>
///   <param name="SOGDIobject">type of object to retrieve</param>
///   <param name="SOGDItokenId">token id to retrieve</param>
///   <param name="SOGDIssys">parent star system</param>
///   <param name="SOGDIstar">parent star</param>
///   <param name="SOGDIoobj">parent orbital object</param>
{:DEV NOTES: do a reset on the array's data + returns: detail the array: [1] star system [2] star and so on.}
function FCFuF_StelObj_GetDbIdx(
   const SOGDIobject: TFCEufStelObj;
   const SOGDItokenId: string;
   const SOGDIssys
         ,SOGDIstar
         ,SOGDIoobj: integer
   ): integer;

///<summary>
///   retrieve db index numbers of the complete row (star system, star, orbital object and eventually the satellite)
///</summary>
///   <param name=""></param>
///   <param name=""></param>
{:DEV NOTES: do a reset on the array's data + returns: detail the array: [1] star system [2] star and so on.}
function FCFuF_StelObj_GetFullRow(
   const SOGFRssys
         ,SOGFRstar
         ,SOGFRoobj
         ,SOGFRsat: string
   ): TFCRufStelObj;

{:DEV NOTES: do a reset on the array's data + returns: detail the array: [1] star system [2] star and so on.}
function FCFuF_StelObj_GetStarSystemStar(
   const SOGFRssys
         ,SOGFRstar: string
   ): TFCRufStelObj;
{:Purpose: retrieve db index numbers of the star system and star.
    Additions:
}

function FCFuF_StarMatrix_Null: TFCRufStelObj;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
//   ,farc_data_init
   ,farc_data_textfiles;

//===================================END OF INIT============================================

function FCFuF_Ecosph_GetCurSeas(const GCSooIdx, GCSsatIdx: integer): string;
{:Purpose: get the current season token.
    Additions:
}
var
   GCSrevolIni
   ,GCSorbP1s
   ,GCSorbP1e
   ,GCSorbP2s
   ,GCSorbP2e
   ,GCSorbP3s
   ,GCSorbP3e
   ,GCSorbP4s
   ,GCSorbP4e: integer;

   GCSseasRes: string;

   GCSorbTpRes
   ,GCSorbP1tp
   ,GCSorbP2tp
   ,GCSorbP3tp
   ,GCSorbP4tp: TFCEduOrbitalPeriodTypes;
begin
   GCSorbTpRes:=optClosest;
   GCSseasRes:='';
   if GCSsatIdx=0
   then
   begin
      with FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[GCSooIdx] do
      begin
         GCSrevolIni:=OO_revolutionPeriodInit;
         GCSorbP1s:=OO_orbitalPeriods[1].OOS_dayStart;
         GCSorbP1e:=OO_orbitalPeriods[1].OOS_dayEnd;
         GCSorbP1tp:=OO_orbitalPeriods[1].OOS_orbitalPeriodType;
         GCSorbP2s:=OO_orbitalPeriods[2].OOS_dayStart;
         GCSorbP2e:=OO_orbitalPeriods[2].OOS_dayEnd;
         GCSorbP2tp:=OO_orbitalPeriods[2].OOS_orbitalPeriodType;
         GCSorbP3s:=OO_orbitalPeriods[3].OOS_dayStart;
         GCSorbP3e:=OO_orbitalPeriods[3].OOS_dayEnd;
         GCSorbP3tp:=OO_orbitalPeriods[3].OOS_orbitalPeriodType;
         GCSorbP4s:=OO_orbitalPeriods[4].OOS_dayStart;
         GCSorbP4e:=OO_orbitalPeriods[4].OOS_dayEnd;
         GCSorbP4tp:=OO_orbitalPeriods[4].OOS_orbitalPeriodType;
      end;
   end
   else if GCSsatIdx>0
   then
   begin
      with FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[GCSooIdx].OO_satellitesList[GCSsatIdx] do
      begin
         GCSrevolIni:=OO_revolutionPeriodInit;
         GCSorbP1s:=OO_orbitalPeriods[1].OOS_dayStart;
         GCSorbP1e:=OO_orbitalPeriods[1].OOS_dayEnd;
         GCSorbP1tp:=OO_orbitalPeriods[1].OOS_orbitalPeriodType;
         GCSorbP2s:=OO_orbitalPeriods[2].OOS_dayStart;
         GCSorbP2e:=OO_orbitalPeriods[2].OOS_dayEnd;
         GCSorbP2tp:=OO_orbitalPeriods[2].OOS_orbitalPeriodType;
         GCSorbP3s:=OO_orbitalPeriods[3].OOS_dayStart;
         GCSorbP3e:=OO_orbitalPeriods[3].OOS_dayEnd;
         GCSorbP3tp:=OO_orbitalPeriods[3].OOS_orbitalPeriodType;
         GCSorbP4s:=OO_orbitalPeriods[4].OOS_dayStart;
         GCSorbP4e:=OO_orbitalPeriods[4].OOS_dayEnd;
         GCSorbP4tp:=OO_orbitalPeriods[4].OOS_orbitalPeriodType;
      end;
   end;
   if (GCSrevolIni>=GCSorbP1s)
      and (GCSrevolIni<=GCSorbP1e)
   then GCSorbTpRes:=GCSorbP1tp
   else if (GCSrevolIni>=GCSorbP2s)
      and (GCSrevolIni<=GCSorbP2e)
   then GCSorbTpRes:=GCSorbP2tp
   else if (GCSrevolIni>=GCSorbP3s)
      and (GCSrevolIni<=GCSorbP3e)
   then GCSorbTpRes:=GCSorbP3tp
   else if (GCSrevolIni>=GCSorbP4s)
      and (GCSrevolIni<=GCSorbP4e)
   then GCSorbTpRes:=GCSorbP4tp;
   case GCSorbTpRes of
      optClosest: GCSseasRes:='seasonMin';
      optIntermediary: GCSseasRes:='seasonMid';
      optFarest: GCSseasRes:='seasonMax';
   end;
   Result:=GCSseasRes;
end;

function FCFuF_Env_Get(
   const EGssys
         ,EGstar
         ,EGoobj
         ,EGsat: integer
   ): TFCEduEnvironmentTypes; overload;
{:Purpose: get the environment enum.
    Additions:
}
begin
   Result:=etFreeLiving;
   if EGsat=0
   then Result:=FCDduStarSystem[EGssys].SS_stars[EGstar].S_orbitalObjects[EGoobj].OO_environment
   else if EGsat>0
   then Result:=FCDduStarSystem[EGssys].SS_stars[EGstar].S_orbitalObjects[EGoobj].OO_satellitesList[EGsat].OO_environment;
end;

function FCFuF_Env_Get(
   const EGssys
         ,EGstar
         ,EGoobj
         ,EGsat: string
   ): TFCEduEnvironmentTypes; overload;
{:Purpose: get the environment enum.
    Additions:
}
var
   EGrow: TFCRufStelObj;
begin
   Result:=etFreeLiving;
   EGrow[1]:=EGrow[0];
   EGrow[2]:=EGrow[0];
   EGrow[3]:=EGrow[0];
   EGrow[4]:=EGrow[0];
   EGrow:=FCFuF_StelObj_GetFullRow(
      EGssys
      ,EGstar
      ,EGoobj
      ,EGsat
      );
   if EGsat=''
   then Result:=FCDduStarSystem[EGrow[1]].SS_stars[EGrow[2]].S_orbitalObjects[EGrow[3]].OO_environment
   else if EGsat<>''
   then Result:=FCDduStarSystem[EGrow[1]].SS_stars[EGrow[2]].S_orbitalObjects[EGrow[3]].OO_satellitesList[EGrow[4]].OO_environment;
end;

function FCFuF_Env_GetStr(
   const EGSssys
         ,EGSstar
         ,EGSoobj
         ,EGSsat: integer
   ): string; overload;
{:Purpose: get the environment string.
    Additions:
}
var
   EGSenv: TFCEduEnvironmentTypes;
begin
   if EGSsat=0
   then EGSenv:=FCDduStarSystem[EGSssys].SS_stars[EGSstar].S_orbitalObjects[EGSoobj].OO_environment
   else if EGSsat>0
   then EGSenv:=FCDduStarSystem[EGSssys].SS_stars[EGSstar].S_orbitalObjects[EGSoobj].OO_satellitesList[EGSsat].OO_environment;
   Result:='';
   case EGSenv of
      etFreeLiving: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvFL');
      etRestricted: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvR');
      etSpace: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvS');
   end;
end;

function FCFuF_Env_GetStr(
   const EGSssys
         ,EGSstar
         ,EGSoobj
         ,EGSsat: string
   ): string; overload;
{:Purpose: get the environment string.
    Additions:
}
var
   EGSenv: TFCEduEnvironmentTypes;

   EGSrow: TFCRufStelObj;
begin
   EGSrow[1]:=EGSrow[0];
   EGSrow[2]:=EGSrow[0];
   EGSrow[3]:=EGSrow[0];
   EGSrow[4]:=EGSrow[0];
   EGSrow:=FCFuF_StelObj_GetFullRow(
      EGSssys
      ,EGSstar
      ,EGSoobj
      ,EGSsat
      );
   if EGSrow[4]=0
   then EGSenv:=FCDduStarSystem[EGSrow[1]].SS_stars[EGSrow[2]].S_orbitalObjects[EGSrow[3]].OO_environment
   else if EGSrow[4]>0
   then EGSenv:=FCDduStarSystem[EGSrow[1]].SS_stars[EGSrow[2]].S_orbitalObjects[EGSrow[3]].OO_satellitesList[EGSrow[4]].OO_environment;
   Result:='';
   case EGSenv of
      etFreeLiving: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvFL');
      etRestricted: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvR');
      etSpace: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvS');
   end;
end;

function FCFuF_Index_Get(
   const IGtp: TFCEufIdxTp;
   const IGvalue: extended
   ): integer;
{:Purpose: get the requested index of a given value, as for temperature or windspeed for example.
    Additions:
}
var
  IGidx: integer;
begin
      IGidx:=0;
   case IGtp of
      ufitTemp:
      begin
         {.Stasis Cold}
         if (IGvalue>=0)
            and (IGvalue<30)
         then IGidx:=1
         {.Extreme Cold}
         else if (IGvalue>=30)
            and (IGvalue<88)
         then IGidx:=2
         {.Freeze Cold}
         else if (IGvalue>=88)
            and (IGvalue<208)
         then IGidx:=3
         {.Nordic}
         else if (IGvalue>=208)
            and (IGvalue<268)
         then IGidx:=4
         {.Moderate Cold}
         else if (IGvalue>=268)
            and (IGvalue<285)
         then IGidx:=5
         {.Moderate}
         else if (IGvalue>=285)
            and (IGvalue<297)
         then IGidx:=6
         {.Moderate Warm}
         else if (IGvalue>=297)
            and (IGvalue<304)
         then IGidx:=7
         {.Tropical Warm}
         else if (IGvalue>=304)
            and (IGvalue<318)
         then IGidx:=8
         {.Desert Warm}
         else if (IGvalue>=318)
            and (IGvalue<348)
         then IGidx:=9
         {.Hot Oven}
         else if (IGvalue>=348)
            and (IGvalue<413)
         then IGidx:=10
         {.Venusian}
         else IGidx:=11;
      end; //==END== case ufitTemp ==//
      ufitWdSpd:
      begin
         {.No Wind}
         if IGvalue=0
         then IGidx:=0
         {.Light Winds}
         else if (IGvalue>0)
            and (IGvalue<=3.3)
         then IGidx:=1
         {.Moderate Winds}
         else if (IGvalue>3.3)
            and (IGvalue<=7.9)
         then IGidx:=2
         {.Strong Winds}
         else if (IGvalue>7.9)
            and (IGvalue<=13.8)
         then IGidx:=3
         {.Gale}
         else if (IGvalue>13.8)
            and (IGvalue<=20.7)
         then IGidx:=4
         {.Storms}
         else if (IGvalue>20.7)
            and (IGvalue<=32.6)
         then IGidx:=5
         {.Hurricanes}
         else if (IGvalue>32.6)
            and (IGvalue<=40.8)
         then IGidx:=6
         {.Permanent Danger}
         else IGidx:=7;
      end; //==END== case ufitWdSpd ==//
   end; //==END== case IGtp of ==//
   Result:=IGidx;
end;

function FCFuF_OrbPeriod_GetMeanTemp(const OPGMToobjIdx, OPGMTsatIdx: integer): extended;
{:Purpose: calculate surface temperate by process the mean value between the 4 orbital periods.
    Additions:
      -2010Jan07- *add: satellite calculations.
}
var
   OPGMTdmpT1
   ,OPGMTdmpT2
   ,OPGMTdmpT3
   ,OPGMTdmpT4
   ,OPGMTdmpRes: extended;
begin
   if OPGMTsatIdx=0
   then
   begin
      OPGMTdmpT1:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OPGMToobjIdx].OO_orbitalPeriods[1].OOS_meanTemperature;
      OPGMTdmpT2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OPGMToobjIdx].OO_orbitalPeriods[2].OOS_meanTemperature;
      OPGMTdmpT3:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OPGMToobjIdx].OO_orbitalPeriods[3].OOS_meanTemperature;
      OPGMTdmpT4:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OPGMToobjIdx].OO_orbitalPeriods[4].OOS_meanTemperature;
   end
   else if OPGMTsatIdx>0
   then
   begin
      OPGMTdmpT1
         :=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OPGMToobjIdx].OO_satellitesList[OPGMTsatIdx].OO_orbitalPeriods[1].OOS_meanTemperature;
      OPGMTdmpT2
         :=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OPGMToobjIdx].OO_satellitesList[OPGMTsatIdx].OO_orbitalPeriods[2].OOS_meanTemperature;
      OPGMTdmpT3
         :=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OPGMToobjIdx].OO_satellitesList[OPGMTsatIdx].OO_orbitalPeriods[3].OOS_meanTemperature;
      OPGMTdmpT4
         :=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OPGMToobjIdx].OO_satellitesList[OPGMTsatIdx].OO_orbitalPeriods[4].OOS_meanTemperature;
   end;
   OPGMTdmpRes:=(OPGMTdmpT1+OPGMTdmpT2+OPGMTdmpT3+OPGMTdmpT4)/4;
   Result:=OPGMTdmpRes;
end;

function FCFuF_Region_GetClim(const RGCooIdx, RGCsatIdx, RGCregIdx: integer): string;
{:Purpose: get the climate token of a choosen region.
    Additions:
}
var
   RGCdmpRes: string;
   RGCdmpClim: TFCEduRegionClimates;
begin
   RGCdmpRes:='';
   if RGCsatIdx=0
   then RGCdmpClim:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[RGCooIdx].OO_regions[RGCregIdx].OOR_climate
   else if RGCsatIdx>0
   then RGCdmpClim
      :=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[RGCooIdx].OO_satellitesList[RGCsatIdx].OO_regions[RGCregIdx].OOR_climate;
   case RGCdmpClim of
      rc00VoidNoUse: RGCdmpRes:='climtpVoid';
      rc01VeryHotHumid: RGCdmpRes:='climtpVHotH';
      rc02VeryHotSemiHumid: RGCdmpRes:='climtpVHotSH';
      rc03HotSemiArid: RGCdmpRes:='climtpHotSAr';
      rc04HotArid: RGCdmpRes:='climtpHotAr';
      rc05ModerateHumid: RGCdmpRes:='climtpModH';
      rc06ModerateDry: RGCdmpRes:='climtpModD';
      rc07ColdArid: RGCdmpRes:='climtpColdAr';
      rc08Periarctic: RGCdmpRes:='climtpPeria';
      rc09Arctic: RGCdmpRes:='climtpArc';
      rc10Extreme: RGCdmpRes:='climtpExtr';
   end;
   Result:=RGCdmpRes;
end;

function FCFuF_RegionLoc_Extract(
   const RLEssysIdx
         ,RLEstarIdx
         ,RLEoobjIdx
         ,RLEsatIdx
         ,RLEregIdx: integer
   ): string;
{:Purpose: extract a defined region location and put it in a string in x;y format or plain text if required.
    Additions:
}
var
   RLEmaxReg: integer;
begin
   Result:='';
   if RLEsatIdx=0
   then
   begin
      RLEmaxReg:=length(FCDduStarSystem[RLEssysIdx].SS_stars[RLEstarIdx].S_orbitalObjects[RLEoobjIdx].OO_regions)-1;
   end
   else if RLEsatIdx>0
   then
   begin
      RLEmaxReg:=length(FCDduStarSystem[RLEssysIdx].SS_stars[RLEstarIdx].S_orbitalObjects[RLEoobjIdx].OO_satellitesList[RLEsatIdx].OO_regions)-1;
   end;
   case RLEmaxReg of
      4:
      begin
         case RLEregIdx of
            1: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocNPole');
            2, 3: Result:=IntToStr(RLEregIdx-1)+';2';
            4: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocSPole');
         end;
      end;
      6:
      begin
         case RLEregIdx of
            1: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocNPole');
            2,3: Result:=IntToStr(RLEregIdx-1)+';2';
            4,5: Result:=IntToStr(RLEregIdx-3)+';3';
            6: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocSPole');
         end;
      end;
      8:
      begin
         case RLEregIdx of
            1: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocNPole');
            2..4: Result:=IntToStr(RLEregIdx-1)+';2';
            5..7: Result:=IntToStr(RLEregIdx-4)+';3';
            8: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocSPole');
         end;
      end;
      10:
      begin
         case RLEregIdx of
            1: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocNPole');
            2..5: Result:=IntToStr(RLEregIdx-1)+';2';
            6..9: Result:=IntToStr(RLEregIdx-5)+';3';
            10: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocSPole');
         end;
      end;
      14:
      begin
         case RLEregIdx of
            1: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocNPole');
            2..5: Result:=IntToStr(RLEregIdx-1)+';2';
            6..9: Result:=IntToStr(RLEregIdx-5)+';3';
            10..13: Result:=IntToStr(RLEregIdx-9)+';4';
            14: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocSPole');
         end;
      end;
      18:
      begin
         case RLEregIdx of
            1: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocNPole');
            2..5: Result:=IntToStr(RLEregIdx-1)+';2';
            6..9: Result:=IntToStr(RLEregIdx-5)+';3';
            10..13: Result:=IntToStr(RLEregIdx-9)+';4';
            14..17: Result:=IntToStr(RLEregIdx-13)+';5';
            18: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocSPole');
         end;
      end;
      22:
      begin
         case RLEregIdx of
            1: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocNPole');
            2..6: Result:=IntToStr(RLEregIdx-1)+';2';
            7..11: Result:=IntToStr(RLEregIdx-6)+';3';
            12..16: Result:=IntToStr(RLEregIdx-11)+';4';
            17..21: Result:=IntToStr(RLEregIdx-16)+';5';
            22: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocSPole');
         end;
      end;
      26:
      begin
         case RLEregIdx of
            1: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocNPole');
            2..7: Result:=IntToStr(RLEregIdx-1)+';2';
            8..13: Result:=IntToStr(RLEregIdx-7)+';3';
            14..19: Result:=IntToStr(RLEregIdx-13)+';4';
            20..25: Result:=IntToStr(RLEregIdx-19)+';5';
            26: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocSPole');
         end;
      end;
      30:
      begin
         case RLEregIdx of
            1: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocNPole');
            2..8: Result:=IntToStr(RLEregIdx-1)+';2';
            9..15: Result:=IntToStr(RLEregIdx-8)+';3';
            16..22: Result:=IntToStr(RLEregIdx-15)+';4';
            23..29: Result:=IntToStr(RLEregIdx-22)+';5';
            30: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocSPole');
         end;
      end;
   end;
end;

function FCFuF_StarLight_CalcPower(const SLCPstarLum, SLCPoobjDist: extended): extended;
{:Purpose: calculate the power, in watts / m2, provided by a star in space.
    Additions:
}
begin
   Result:=SLCPstarLum*1370/sqr(SLCPoobjDist);
end;

function FCFuF_StelObj_GetDbIdx(
   const SOGDIobject: TFCEufStelObj;
   const SOGDItokenId: string;
   const SOGDIssys
         ,SOGDIstar
         ,SOGDIoobj: integer
   ): integer;
{:Purpose: retrieve db index number of asked star system, star, orbital object and satellite.
            hierarchy is in this natural order: star system> star> orbital object> satellite
            it needs hierarchical parent index data for retrieve the desired object..
    Additions:
}
var
   SOGDIcnt
   ,SOGDImax
   ,SOGDIres: integer;
begin
   SOGDIres:=0;
   case SOGDIobject of
      ufsoSsys:
      begin
         SOGDIcnt:=1;
         SOGDImax:=Length(FCDduStarSystem)-1;
         while SOGDIcnt<=SOGDImax do
         begin
            if FCDduStarSystem[SOGDIcnt].SS_token=SOGDItokenId
            then
            begin
               SOGDIres:=SOGDIcnt;
               break;
            end;
            inc(SOGDIcnt);
         end;
      end;
      ufsoStar:
      begin
         SOGDIcnt:=1;
         while SOGDIcnt<=3 do
         begin
            if FCDduStarSystem[SOGDIssys].SS_stars[SOGDIcnt].S_token=''
            then break
            else if FCDduStarSystem[SOGDIssys].SS_stars[SOGDIcnt].S_token=SOGDItokenId
            then
            begin
               SOGDIres:=SOGDIcnt;
               break;
            end;
            inc(SOGDIcnt);
         end;
      end;
      ufsoOObj:
      begin
         SOGDIcnt:=1;
         SOGDImax:=Length(FCDduStarSystem[SOGDIssys].SS_stars[SOGDIstar].S_orbitalObjects)-1;
         while SOGDIcnt<=SOGDImax do
         begin
            if FCDduStarSystem[SOGDIssys].SS_stars[SOGDIstar].S_orbitalObjects[SOGDIcnt].OO_dbTokenId=SOGDItokenId
            then
            begin
               SOGDIres:=SOGDIcnt;
               break;
            end;
            inc(SOGDIcnt);
         end;
      end;
      ufsoSat:
      begin
         SOGDIcnt:=1;
         SOGDImax:=Length(FCDduStarSystem[SOGDIssys].SS_stars[SOGDIstar].S_orbitalObjects[SOGDIoobj].OO_satellitesList)-1;
         while SOGDIcnt<=SOGDImax do
         begin
            if FCDduStarSystem[SOGDIssys].SS_stars[SOGDIstar].S_orbitalObjects[SOGDIoobj].OO_satellitesList[SOGDIcnt].OO_dbTokenId=SOGDItokenId
            then
            begin
               SOGDIres:=SOGDIcnt;
               break;
            end;
            inc(SOGDIcnt);
         end;
      end;
   end; //==END== case SOGDIobject of ==//
   Result:=SOGDIres;
end;

function FCFuF_StelObj_GetFullRow(
   const SOGFRssys
         ,SOGFRstar
         ,SOGFRoobj
         ,SOGFRsat: string
   ): TFCRufStelObj;
{:Purpose: retrieve db index numbers of the complete row (star system, star, orbital object and eventually the satellite).
    Additions:
      -2012Jan23- *fix: remove a bug w/ satellite retrieving.
}
var
   SOGFRcnt
   ,SOGFRmax: integer;
begin
   Result:=FCFuF_StarMatrix_Null;
   Result[1]:=FCFuF_StelObj_GetDbIdx(
      ufsoSsys
      ,SOGFRssys
      ,0
      ,0
      ,0
      );
   Result[2]:=FCFuF_StelObj_GetDbIdx(
      ufsoStar
      ,SOGFRstar
      ,Result[1]
      ,0
      ,0
      );
   Result[3]:=FCFuF_StelObj_GetDbIdx(
      ufsoOObj
      ,SOGFRoobj
      ,Result[1]
      ,Result[2]
      ,0
      );
   if SOGFRsat<>''
   then Result[4]:=FCFuF_StelObj_GetDbIdx(
      ufsoSat
      ,SOGFRsat
      ,Result[1]
      ,Result[2]
      ,Result[3]
      )
   else Result[4]:=0;
end;

function FCFuF_StelObj_GetStarSystemStar(
   const SOGFRssys
         ,SOGFRstar: string
   ): TFCRufStelObj;
{:Purpose: retrieve db index numbers of the star system and star.
    Additions:
}
var
   SOGFRcnt
   ,SOGFRmax: integer;
begin
   Result:=FCFuF_StarMatrix_Null;
   Result[1]:=FCFuF_StelObj_GetDbIdx(
      ufsoSsys
      ,SOGFRssys
      ,0
      ,0
      ,0
      );
   Result[2]:=FCFuF_StelObj_GetDbIdx(
      ufsoStar
      ,SOGFRstar
      ,Result[1]
      ,0
      ,0
      );
end;

function FCFuF_StarMatrix_Null: TFCRufStelObj;
{:Purpose: provide an empty star matrix.
    Additions:
}
begin
   Result[1]:=0;
   Result[2]:=0;
   Result[3]:=0;
   Result[4]:=0;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure TFCRufAtmosphereGasesPercent.AtmosphereGases_CalculatePercents(
   const StarSytem
         ,Star
         ,OrbitalObj
         ,SatelliteObj: integer
   );
{:Purpose: calculate the percents of total volume taken by secondary and trace gases, the percents are by gases.
    Additions:
}
   var
      RestOfGasVolume
      ,SecondaryGasesCount
      ,TraceGasesCount: integer;

      TotalPercentForSecondaryGases
      ,TotalPercentForTraceGases: extended;
begin
   RestOfGasVolume:=0;
   SecondaryGasesCount:=0;
   TraceGasesCount:=0;
   TotalPercentForSecondaryGases:=0;
   TotalPercentForTraceGases:=0;
   AGP_atmosphericPressure:=0;
   if SatelliteObj=0 then
   begin
      AGP_atmosphericPressure:=FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphericPressure;
      AGP_primaryGasPercent:=FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_primaryGasVolumePerc;
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceH2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceH2=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceHe=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceHe=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceCH4=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceCH4=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceNH3=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceNH3=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceH2O=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceH2O=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceNe=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceNe=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceN2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceN2=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceCO=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceCO=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceNO=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceNO=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceO2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceO2=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceH2S=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceH2S=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceAr=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceAr=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceCO2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceCO2=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceNO2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceNO2=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceO3=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceO3=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceSO2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_atmosphere.AC_gasPresenceSO2=agsSecondary
      then inc( SecondaryGasesCount );
   end //==END== if SatelliteObj=0 then ==//
   else if SatelliteObj>0 then
   begin
      AGP_atmosphericPressure:=FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphericPressure;
      AGP_primaryGasPercent:=FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_primaryGasVolumePerc;
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceH2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceH2=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceHe=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceHe=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceCH4=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceCH4=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceNH3=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceNH3=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceH2O=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceH2O=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceNe=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceNe=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceN2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceN2=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceCO=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceCO=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceNO=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceNO=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceO2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceO2=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceH2S=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceH2S=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceAr=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceAr=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceCO2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceCO2=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceNO2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceNO2=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceO3=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceO3=agsSecondary
      then inc( SecondaryGasesCount );
      if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceSO2=agsTrace
      then inc( TraceGasesCount )
      else if FCDduStarSystem[ StarSytem ].SS_stars[ Star ].S_orbitalObjects[ OrbitalObj ].OO_satellitesList[ SatelliteObj ].OO_atmosphere.AC_gasPresenceSO2=agsSecondary
      then inc( SecondaryGasesCount );
   end; //==END== else if SatelliteObj>0 then ==//
   AGP_secondaryGasPercent:=0;
   AGP_traceGasPercent:=0;
   RestOfGasVolume:=100-AGP_primaryGasPercent;
   TotalPercentForTraceGases:=( RestOfGasVolume * TraceGasesCount ) / 200;
   TotalPercentForSecondaryGases:=RestOfGasVolume - TotalPercentForTraceGases;
   AGP_secondaryGasPercent:=TotalPercentForSecondaryGases / SecondaryGasesCount;
   AGP_secondaryGasPercent:=FCFcFunc_Rnd( cfrttp2dec, AGP_secondaryGasPercent );
   AGP_traceGasPercent:=TotalPercentForTraceGases / TraceGasesCount;
   AGP_traceGasPercent:=FCFcFunc_Rnd( cfrttp2dec, AGP_traceGasPercent );
end;

end.
