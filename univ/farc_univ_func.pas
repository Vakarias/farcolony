{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: universe - functions unit

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

//==END PUBLIC ENUM=========================================================================

///<summary>
/// record used to retrieve the volumes taken by the gases. Use the internal AtmosphereGases_CalculatePercents method to calculate them
///</summary>
type TFCRufAtmosphereGases=record
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
   procedure CalculatePercents(
      const StarSytem
            ,Star
            ,OrbitalObj
            ,SatelliteObj: integer
      );
end;

type TFCRufRegionLoc=record
   RL_X: integer;
   RL_Y: integer;
end;


///<summary>
///   [1]= star system index, [2]= star index, [3]= orbital object index, [4]= satellite index
///</summary>
type TFCRufStelObj = array[0..4] of integer;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   get the current season token
///</summary>
///    <param name="GCSooIdx">orbital object index</param>
///    <param name="GCSsatIdx">[optional] satellite index</param>
function FCFuF_Ecosph_GetCurSeas(const StarSys, Star, GCSooIdx, GCSsatIdx: integer): string;

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
///   retrieve the current orbital period
///</summary>
///   <param name="StarSys">star system index #</param>
///   <param name="Star">star index #</param>
///   <param name="OrbitalObject">orbital object index #</param>
///   <param name="Satellite">[optional] satellite index #</param>
///   <returns>the current orbital period</returns>
///   <remarks></remarks>
function FCFuF_OrbitalPeriods_GetCurrentPeriod(
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   ): TFCEduOrbitalPeriodTypes;

///<summary>
///   retrieve the current orbital period index
///</summary>
///   <param name="StarSys">star system index #</param>
///   <param name="Star">star index #</param>
///   <param name="OrbitalObject">orbital object index #</param>
///   <param name="Satellite">[optional] satellite index #</param>
///   <returns>the current orbital period index</returns>
///   <remarks></remarks>
function FCFuF_OrbitalPeriods_GetCurrentPeriodIndex(
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   ): integer;

///<summary>
///   get the base temperature of the current orbital period of an orbital object
///</summary>
///    <param name="StarSys">star system index #</param>
///    <param name="Star">star index #</param>
///    <param name="OrbitalObject">orbital object index #</param>
///    <param name="Satellite">[optional] satellite index</param>
function FCFuF_OrbitalPeriods_GetBaseTemperature(
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
      ): extended;

///<summary>
///   get the orbital period index # of a specified type. If the period is intermediate, it gives the first index # of the two
///</summary>
///    <param name="Period">type of orbital period</param>
///    <param name="StarSys">star system index #</param>
///    <param name="Star">star index #</param>
///    <param name="OrbitalObject">orbital object index #</param>
///    <param name="Satellite">[optional] satellite index</param>
///   <returns>the orbital operiod index # of a specified type</returns>
///   <remarks></remarks>
function FCFuF_OrbitalPeriods_GetSpecifiedPeriod(
   const Period: TFCEduOrbitalPeriodTypes;
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
      ): integer;

///<summary>
///   get the mean surface temperature of the orbital periods
///</summary>
///    <param name="StarSys">star system index #</param>
///    <param name="Star">star index #</param>
///    <param name="OrbitalObject">orbital object index #</param>
///    <param name="Satellite">[optional] satellite index</param>
///   <returns>the mean surface temperature of orbital periods</returns>
///   <remarks>not formatted</remarks>
function FCFuF_OrbitalPeriods_GetMeanSurfaceTemperature(
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
      ): extended;

///<summary>
///   get the surface temperature of a specified orbital period
///</summary>
///    <param name="Period">type of orbital period</param>
///    <param name="StarSys">star system index #</param>
///    <param name="Star">star index #</param>
///    <param name="OrbitalObject">orbital object index #</param>
///    <param name="Satellite">[optional] satellite index</param>
///   <returns>the surface temperature of the specified orbital period</returns>
///   <remarks>pre-formatted</remarks>
function FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
   const Period: TFCEduOrbitalPeriodTypes;
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
      ): extended;

///<summary>
///   get the climate token of a choosen region
///</summary>
///    <param name="RGCooIdx">orbital object index</param>
///    <param name="RGCsatIdx">[optional] satellite index</param>
///    <param name="RGCregIdx">region index</param>
function FCFuF_Region_GetClimateString(const StarSys, Star, RGCooIdx, RGCsatIdx, RGCregIdx: integer): string;

///<summary>
///   extract a defined region location and put it in an array
///</summary>
function FCFuF_RegionLoc_ExtractNum(
   const OrbObject: TFCRufStelObj;
   const RLEregIdx: integer
   ): TFCRufRegionLoc;


///<summary>
///   extract a defined region location and put it in a string in x;y format or plain text if required
///</summary>
function FCFuF_RegionLoc_ExtractStr(
   const OrbObject: TFCRufStelObj;
   const RLEregIdx: integer
   ): string;

///<summary>
///   calculate the distance between two regions
///</summary>
///   <param name="OrbObject">orbital object numeric location</param>
///   <param name="RegionA">region A index #</param>
///   <param name="RegionB">region B index #</param>
///   <returns>distance in raw numeric value</returns>
///   <remarks>there's no roundto applied to the result</remarks>
function FCFuF_Regions_CalculateDistance(
   const OrbObject: TFCRufStelObj;
   const RegionA
         ,RegionB: integer
   ): extended;

///<summary>
///   get the axial tilt of a satellite, depending it is a satellite or an asteroid in a belt
///</summary>
///    <param name="StarSys">star system index #</param>
///    <param name="Star">star index #</param>
///    <param name="OrbitalObject">orbital object index #</param>
///    <param name="Satellite">satellite index</param>
///   <returns>the satellite axial tilt</returns>
///   <remarks></remarks>
function FCFuF_Satellite_GetAxialTilt(
   const StarSys
         ,Star
         ,OrbitalObject
         ,Satellite: integer
   ): extended;

///<summary>
///   get the distance from the central star of a satellite, depending it is a satellite or an asteroid in a belt
///</summary>
///    <param name="StarSys">star system index #</param>
///    <param name="Star">star index #</param>
///    <param name="OrbitalObject">orbital object index #</param>
///    <param name="Satellite">satellite index</param>
///   <returns>the distance from the central star in AU</returns>
///   <remarks></remarks>
function FCFuF_Satellite_GetDistanceFromStar(
   const StarSys
         ,Star
         ,OrbitalObject
         ,Satellite: integer
   ): extended;

///<summary>
///   get the rotation period of a satellite, depending it is a satellite or an asteroid in a belt
///</summary>
///    <param name="StarSys">star system index #</param>
///    <param name="Star">star index #</param>
///    <param name="OrbitalObject">orbital object index #</param>
///    <param name="Satellite">satellite index</param>
///   <returns>the satellite orbital period</returns>
///   <remarks></remarks>
function FCFuF_Satellite_GetRotationPeriod(
   const StarSys
         ,Star
         ,OrbitalObject
         ,Satellite: integer
   ): extended;

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

///<summary>
///   set the current temperature, wind speed and rainfall according to the current orbital period
///</summary>
///   <param name="StarSys">star system index #</param>
///   <param name="Star">star index #</param>
///   <param name="OrbitalObject">orbital object index #</param>
///   <param name="Satellite">[optional] satellite index #</param>
procedure FCMuF_Regions_SetCurrentClimateData(
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFuF_Ecosph_GetCurSeas(const StarSys, Star, GCSooIdx, GCSsatIdx: integer): string;
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
      with FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[GCSooIdx] do
      begin
         GCSrevolIni:=OO_revolutionPeriodInit;
         GCSorbP1tp:=OO_orbitalPeriods[1].OOS_orbitalPeriodType;
         GCSorbP1s:=OO_orbitalPeriods[1].OOS_dayStart;
         GCSorbP1e:=OO_orbitalPeriods[1].OOS_dayEnd;
         GCSorbP2tp:=OO_orbitalPeriods[2].OOS_orbitalPeriodType;
         GCSorbP2s:=OO_orbitalPeriods[2].OOS_dayStart;
         GCSorbP2e:=OO_orbitalPeriods[2].OOS_dayEnd;
         GCSorbP3tp:=OO_orbitalPeriods[3].OOS_orbitalPeriodType;
         GCSorbP3s:=OO_orbitalPeriods[3].OOS_dayStart;
         GCSorbP3e:=OO_orbitalPeriods[3].OOS_dayEnd;
         GCSorbP4tp:=OO_orbitalPeriods[4].OOS_orbitalPeriodType;
         GCSorbP4s:=OO_orbitalPeriods[4].OOS_dayStart;
         GCSorbP4e:=OO_orbitalPeriods[4].OOS_dayEnd;
      end;
   end
   else if GCSsatIdx>0
   then
   begin
      with FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[GCSooIdx].OO_satellitesList[GCSsatIdx] do
      begin
         GCSrevolIni:=OO_revolutionPeriodInit;
         GCSorbP1tp:=OO_orbitalPeriods[1].OOS_orbitalPeriodType;
         GCSorbP1s:=OO_orbitalPeriods[1].OOS_dayStart;
         GCSorbP1e:=OO_orbitalPeriods[1].OOS_dayEnd;
         GCSorbP2tp:=OO_orbitalPeriods[2].OOS_orbitalPeriodType;
         GCSorbP2s:=OO_orbitalPeriods[2].OOS_dayStart;
         GCSorbP2e:=OO_orbitalPeriods[2].OOS_dayEnd;
         GCSorbP3tp:=OO_orbitalPeriods[3].OOS_orbitalPeriodType;
         GCSorbP3s:=OO_orbitalPeriods[3].OOS_dayStart;
         GCSorbP3e:=OO_orbitalPeriods[3].OOS_dayEnd;
         GCSorbP4tp:=OO_orbitalPeriods[4].OOS_orbitalPeriodType;
         GCSorbP4s:=OO_orbitalPeriods[4].OOS_dayStart;
         GCSorbP4e:=OO_orbitalPeriods[4].OOS_dayEnd;
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
      optIntermediary: GCSseasRes:='seasonMid';

      optClosest: GCSseasRes:='seasonMin';

      optFarthest: GCSseasRes:='seasonMax';
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

function FCFuF_OrbitalPeriods_GetCurrentPeriod(
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   ): TFCEduOrbitalPeriodTypes;
{:Purpose: retrieve the current orbital period.
    Additions:
}
   var
      Count: integer;
begin
   Result:=optIntermediary;
   Count:=1;
   if Satellite = 0 then
   begin
      while Count <= 4 do
      begin
         if ( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriodCurrent >= FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_dayStart )
            and ( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriodCurrent <= FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_dayEnd ) then
         begin
            Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_orbitalPeriodType;
            break;
         end;
         inc( Count );
      end;
   end
   else if Satellite > 0 then
   begin
      while Count <= 4 do
      begin
         if ( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_revolutionPeriodCurrent >= FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_dayStart )
            and ( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_revolutionPeriodCurrent <= FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_dayEnd ) then
         begin
            Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_orbitalPeriodType;
            break;
         end;
         inc( Count );
      end;
   end;
end;

function FCFuF_OrbitalPeriods_GetCurrentPeriodIndex(
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   ): integer;
{:Purpose: retrieve the current orbital period index.
    Additions:
}
   var
      Count: integer;
begin
   Result:=0;
   Count:=1;
   if Satellite = 0 then
   begin
      while Count <= 4 do
      begin
         if ( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriodCurrent >= FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_dayStart )
            and ( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriodCurrent <= FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_dayEnd ) then
         begin
            Result:=Count;
            break;
         end;
         inc( Count );
      end;
   end
   else if Satellite > 0 then
   begin
      while Count <= 4 do
      begin
         if ( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_revolutionPeriodCurrent >= FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_dayStart )
            and ( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_revolutionPeriodCurrent <= FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_dayEnd ) then
         begin
            Result:=Count;
            break;
         end;
         inc( Count );
      end;
   end;
end;

function FCFuF_OrbitalPeriods_GetBaseTemperature(
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
      ): extended;
{:Purpose: get the base temperature of the current orbital period of an orbital object.
    Additions:
      -2013Jul09- *mod: overhaul: retrieve the current base temperature based on the revolution period.
                  *code: parameters refactoring.
      -2010Jan07- *add: satellite calculations.
}
var
   CurrentOrbitalPeriod: integer;
begin
   Result:=0;
   CurrentOrbitalPeriod:=0;
   CurrentOrbitalPeriod:=FCFuF_OrbitalPeriods_GetCurrentPeriodIndex(
      StarSys
      ,Star
      ,OrbitalObject
      ,Satellite
      );
   if Satellite=0
   then Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[CurrentOrbitalPeriod].OOS_baseTemperature
   else if Satellite>0
   then Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[CurrentOrbitalPeriod].OOS_baseTemperature;
end;

function FCFuF_OrbitalPeriods_GetSpecifiedPeriod(
   const Period: TFCEduOrbitalPeriodTypes;
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
      ): integer;
{:Purpose: get the orbital period index # of a specified type. If the period is intermediate, it gives the first index # of the two.
    Additions:
}
   var
      Count: integer;
begin
   Result:=0;
   Count:=1;
   while Count <= 4 do
   begin
      if ( Satellite = 0 )
         and ( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_orbitalPeriodType = Period ) then
      begin
         Result:=Count;
         break;
      end
      else if ( Satellite > 0 )
         and ( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_orbitalPeriodType = Period ) then
      begin
         Result:=Count;
         break;
      end;
      inc( Count );
   end;
end;

function FCFuF_OrbitalPeriods_GetMeanSurfaceTemperature(
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
      ): extended;
{:Purpose: get the mean surface temperature of the orbital periods.
    Additions:
      -2013Sep07- *fix: bad allocation w/ star system data.
}
   var
      ObjectSurfaceTempClosest
      ,ObjectSurfaceTempFarthest
      ,ObjectSurfaceTempInterm: extended;
begin
   Result:=0;
   ObjectSurfaceTempClosest:=0;
   ObjectSurfaceTempFarthest:=0;
   ObjectSurfaceTempInterm:=0;
   ObjectSurfaceTempClosest:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optClosest
      ,StarSys
      ,Star
      ,OrbitalObject
      );
   ObjectSurfaceTempInterm:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optIntermediary
      ,StarSys
      ,Star
      ,OrbitalObject
      );
   ObjectSurfaceTempFarthest:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optFarthest
      ,StarSys
      ,Star
      ,OrbitalObject
      );
   Result:=( ObjectSurfaceTempClosest + ObjectSurfaceTempFarthest + ObjectSurfaceTempInterm ) / 3;
end;

function FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
   const Period: TFCEduOrbitalPeriodTypes;
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
      ): extended;
{:Purpose: get the surface temperature of a specified orbital period.
    Additions:
}
   var
      Count: integer;
begin
   Result:=0;
   Count:=FCFuF_OrbitalPeriods_GetSpecifiedPeriod(
      Period
      ,StarSys
      ,Star
      ,OrbitalObject
      ,Satellite
      );
   if Satellite = 0
   then Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_surfaceTemperature
   else if Satellite > 0
   then Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_surfaceTemperature;
end;


function FCFuF_Region_GetClimateString(const StarSys, Star, RGCooIdx, RGCsatIdx, RGCregIdx: integer): string;
{:Purpose: get the climate token of a choosen region.
    Additions:
}
var
   RGCdmpRes: string;
   RGCdmpClim: TFCEduRegionClimates;
begin
   RGCdmpRes:='';
   if RGCsatIdx=0
   then RGCdmpClim:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[RGCooIdx].OO_regions[RGCregIdx].OOR_climate
   else if RGCsatIdx>0
   then RGCdmpClim
      :=FCDduStarSystem[Starsys].SS_stars[Star].S_orbitalObjects[RGCooIdx].OO_satellitesList[RGCsatIdx].OO_regions[RGCregIdx].OOR_climate;
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

function FCFuF_RegionLoc_ExtractNum(
   const OrbObject: TFCRufStelObj;
   const RLEregIdx: integer
   ): TFCRufRegionLoc; overload;
{:Purpose: extract a defined region location and put it in an array.
    Additions:
}
   var
      RegionMax: integer;
begin
   Result.RL_X:=0;
   Result.RL_Y:=0;

   if OrbObject[4]=0
   then
   begin
      RegionMax:=length(FCDduStarSystem[OrbObject[1]].SS_stars[OrbObject[2]].S_orbitalObjects[OrbObject[3]].OO_regions)-1;
   end
   else if OrbObject[4]>0
   then
   begin
      RegionMax:=length(FCDduStarSystem[OrbObject[1]].SS_stars[OrbObject[2]].S_orbitalObjects[OrbObject[3]].OO_satellitesList[OrbObject[4]].OO_regions)-1;
   end;
   case RegionMax of
      4:
      begin
         case RLEregIdx of
            1:
            begin
               Result.RL_X:=1;
               Result.RL_Y:=1;
            end;

            2, 3:
            begin
               Result.RL_X:=RLEregIdx-1;
               Result.RL_Y:=2;
            end;

            4:
            begin
               Result.RL_X:=1;
               Result.RL_Y:=3;
            end;
         end;
      end;

      6:
      begin
         case RLEregIdx of
            1:
            begin
               Result.RL_X:=1;
               Result.RL_Y:=1;
            end;

            2,3:
            begin
               Result.RL_X:=RLEregIdx-1;
               Result.RL_Y:=2;
            end;

            4,5:
            begin
               Result.RL_X:=RLEregIdx-3;
               Result.RL_Y:=3;
            end;

            6:
            begin
               Result.RL_X:=1;
               Result.RL_Y:=4;
            end;
         end;
      end;

      8:
      begin
         case RLEregIdx of
            1:
            begin
               Result.RL_X:=2;
               Result.RL_Y:=1;
            end;

            2..4:
            begin
               Result.RL_X:=RLEregIdx-1;
               Result.RL_Y:=2;
            end;

            5..7:
            begin
               Result.RL_X:=RLEregIdx-4;
               Result.RL_Y:=3;
            end;

            8:
            begin
               Result.RL_X:=2;
               Result.RL_Y:=4;
            end;
         end;
      end;

      10:
      begin
         case RLEregIdx of
            1:
            begin
               Result.RL_X:=2;
               Result.RL_Y:=1;
            end;

            2..5:
            begin
               Result.RL_X:=RLEregIdx-1;
               Result.RL_Y:=2;
            end;

            6..9:
            begin
               Result.RL_X:=RLEregIdx-5;
               Result.RL_Y:=3;
            end;

            10:
            begin
               Result.RL_X:=2;
               Result.RL_Y:=4;
            end;
         end;
      end;

      14:
      begin
         case RLEregIdx of
            1:
            begin
               Result.RL_X:=2;
               Result.RL_Y:=1;
            end;

            2..5:
            begin
               Result.RL_X:=RLEregIdx-1;
               Result.RL_Y:=2;
            end;

            6..9:
            begin
               Result.RL_X:=RLEregIdx-5;
               Result.RL_Y:=3;
            end;

            10..13:
            begin
               Result.RL_X:=RLEregIdx-9;
               Result.RL_Y:=4;
            end;

            14:
            begin
               Result.RL_X:=2;
               Result.RL_Y:=5;
            end;
         end;
      end;

      18:
      begin
         case RLEregIdx of
            1:
            begin
               Result.RL_X:=2;
               Result.RL_Y:=1;
            end;

            2..5:
            begin
               Result.RL_X:=RLEregIdx-1;
               Result.RL_Y:=2;
            end;

            6..9:
            begin
               Result.RL_X:=RLEregIdx-5;
               Result.RL_Y:=3;
            end;

            10..13:
            begin
               Result.RL_X:=RLEregIdx-9;
               Result.RL_Y:=4;
            end;

            14..17:
            begin
               Result.RL_X:=RLEregIdx-13;
               Result.RL_Y:=5;
            end;

            18:
            begin
               Result.RL_X:=2;
               Result.RL_Y:=6;
            end;
         end;
      end;

      22:
      begin
         case RLEregIdx of
            1:
            begin
               Result.RL_X:=3;
               Result.RL_Y:=1;
            end;

            2..6:
            begin
               Result.RL_X:=RLEregIdx-1;
               Result.RL_Y:=2;
            end;

            7..11:
            begin
               Result.RL_X:=RLEregIdx-6;
               Result.RL_Y:=3;
            end;

            12..16:
            begin
               Result.RL_X:=RLEregIdx-11;
               Result.RL_Y:=4;
            end;

            17..21:
            begin
               Result.RL_X:=RLEregIdx-16;
               Result.RL_Y:=5;
            end;

            22:
            begin
               Result.RL_X:=3;
               Result.RL_Y:=6;
            end;
         end;
      end;

      26:
      begin
         case RLEregIdx of
            1:
            begin
               Result.RL_X:=3;
               Result.RL_Y:=1;
            end;

            2..7:
            begin
               Result.RL_X:=RLEregIdx-1;
               Result.RL_Y:=2;
            end;

            8..13:
            begin
               Result.RL_X:=RLEregIdx-7;
               Result.RL_Y:=3;
            end;

            14..19:
            begin
               Result.RL_X:=RLEregIdx-13;
               Result.RL_Y:=4;
            end;

            20..25:
            begin
               Result.RL_X:=RLEregIdx-19;
               Result.RL_Y:=5;
            end;

            26:
            begin
               Result.RL_X:=3;
               Result.RL_Y:=6;
            end;
         end;
      end;

      30:
      begin
         case RLEregIdx of
            1:
            begin
               Result.RL_X:=4;
               Result.RL_Y:=1;
            end;

            2..8:
            begin
               Result.RL_X:=RLEregIdx-1;
               Result.RL_Y:=2;
            end;

            9..15:
            begin
               Result.RL_X:=RLEregIdx-8;
               Result.RL_Y:=3;
            end;

            16..22:
            begin
               Result.RL_X:=RLEregIdx-15;
               Result.RL_Y:=4;
            end;

            23..29:
            begin
               Result.RL_X:=RLEregIdx-22;
               Result.RL_Y:=5;
            end;

            30:
            begin
               Result.RL_X:=4;
               Result.RL_Y:=6;
            end;
         end;
      end;
   end; //==END== case RegionMax of ==//
end;

function FCFuF_RegionLoc_ExtractStr(
   const OrbObject: TFCRufStelObj;
   const RLEregIdx: integer
   ): string;
{:Purpose: extract a defined region location and put it in a string in x;y format or plain text if required.
    Additions:
}
var
   RLEmaxReg: integer;

   RegionLocation: TFCRufRegionLoc;
begin
   Result:='';
   RegionLocation.RL_X:=0;
   RegionLocation.RL_Y:=0;
   RegionLocation:=FCFuF_RegionLoc_ExtractNum( OrbObject, RLEregIdx );
   if RegionLocation.RL_Y=1
   then Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocNPole')
   else if RegionLocation.RL_Y>1 then
   begin
      if OrbObject[4]=0
      then
      begin
         RLEmaxReg:=length(FCDduStarSystem[OrbObject[1]].SS_stars[OrbObject[2]].S_orbitalObjects[OrbObject[3]].OO_regions)-1;
      end
      else if OrbObject[4]>0
      then
      begin
         RLEmaxReg:=length(FCDduStarSystem[OrbObject[1]].SS_stars[OrbObject[2]].S_orbitalObjects[OrbObject[3]].OO_satellitesList[OrbObject[4]].OO_regions)-1;
      end;
      if ( ( RLEmaxReg=4 ) and ( RegionLocation.RL_Y=3 ) )
         or ( ( RLEmaxReg in [6..10] ) and ( RegionLocation.RL_Y=4 ) )
         or ( ( RLEmaxReg=14 ) and ( RegionLocation.RL_Y=5 ) )
         or ( ( RLEmaxReg in [18..30] ) and ( RegionLocation.RL_Y=6 ) )
      then Result:=FCFdTFiles_UIStr_Get(uistrUI, 'reglocSPole')
      else Result:=IntToStr( RegionLocation.RL_X )+';'+IntToStr( RegionLocation.RL_Y );
   end;
end;

function FCFuF_Regions_CalculateDistance(
   const OrbObject: TFCRufStelObj;
   const RegionA
         ,RegionB: integer
   ): extended;
{:Purpose: calculate the distance between two regions.
    Additions:
}
   var
      CalcX
      ,CalcY: extended;

      LocRegionA
      ,LocRegionB: TFCRufRegionLoc;
begin
   Result:=0;
   LocRegionA:=FCFuF_RegionLoc_ExtractNum( OrbObject, RegionA );
   LocRegionB:=FCFuF_RegionLoc_ExtractNum( OrbObject, RegionB );
   CalcX:=sqr( LocRegionB.RL_X-LocRegionA.RL_X );
   CalcY:=sqr( LocRegionB.RL_Y-LocRegionA.RL_Y );
   Result:=sqrt( CalcX+CalcY );
end;

function FCFuF_Satellite_GetAxialTilt(
   const StarSys
         ,Star
         ,OrbitalObject
         ,Satellite: integer
   ): extended;
{:Purpose: get the axial tilt of a satellite, depending it is a satellite or an asteroid in a belt.
    Additions:
}
begin
   Result:=0;
   if FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type = ootAsteroidsBelt
   then Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_isSat_asterInBelt_axialTilt
   else Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_axialTilt;
end;

function FCFuF_Satellite_GetDistanceFromStar(
   const StarSys
         ,Star
         ,OrbitalObject
         ,Satellite: integer
   ): extended;
{:Purpose: get the distance from the central star of a satellite, depending it is a satellite or an asteroid in a belt.
   Additions:
}
begin
   Result:=0;
   if FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type = ootAsteroidsBelt
   then Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar
   else Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
end;

function FCFuF_Satellite_GetRotationPeriod(
   const StarSys
         ,Star
         ,OrbitalObject
         ,Satellite: integer
   ): extended;
{:Purpose: get the rotation period of a satellite, depending it is a satellite or an asteroid in a belt.
   Additions:
}
begin
   Result:=0;
   if FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type = ootAsteroidsBelt
   then Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_isSat_asterInBelt_rotationPeriod
   else Result:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_revolutionPeriod * 24;
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

procedure TFCRufAtmosphereGases.CalculatePercents(
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
   AGP_secondaryGasPercent:=FCFcF_Round( rttCustom2Decimal, AGP_secondaryGasPercent );
   AGP_traceGasPercent:=TotalPercentForTraceGases / TraceGasesCount;
   AGP_traceGasPercent:=FCFcF_Round( rttCustom2Decimal, AGP_traceGasPercent );
end;

procedure FCMuF_Regions_SetCurrentClimateData(
   const StarSys
         ,Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: set the current temperature, wind speed and rainfall for each region according to the current orbital period.
   Additions:
      -2013Sep07- *fix: removed satellite sub-index where it wasn't needed.
}
   var
      Count
      ,Max: integer;

      CurrentOrbitalPeriod: TFCEduOrbitalPeriodTypes;
begin
   Count:=1;
   Max:=0;
   CurrentOrbitalPeriod:=optIntermediary;
   CurrentOrbitalPeriod:=FCFuF_OrbitalPeriods_GetCurrentPeriod(
         StarSys
         ,Star
         ,OrbitalObject
         ,Satellite
         );
   if Satellite = 0
   then Max:=length( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions ) - 1
   else if Satellite > 0
   then Max:=length( FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions ) - 1;
   case CurrentOrbitalPeriod of
      optIntermediary:
      begin
         while Count <= Max do
         begin
            if Satellite = 0 then
            begin
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_currentTemperature:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonIntermediate.OP_meanTemperature;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_currentWindspeed:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonIntermediate.OP_windspeed;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_currentRainfall:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonIntermediate.OP_rainfall;
            end
            else if Satellite > 0 then
            begin
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_currentTemperature:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonIntermediate.OP_meanTemperature;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_currentWindspeed:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonIntermediate.OP_windspeed;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_currentRainfall:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonIntermediate.OP_rainfall;
            end;
            inc( Count );
         end;
      end;

      optClosest:
      begin
         while Count <= Max do
         begin
            if Satellite = 0 then
            begin
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_currentTemperature:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonClosest.OP_meanTemperature;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_currentWindspeed:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonClosest.OP_windspeed;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_currentRainfall:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonClosest.OP_rainfall;
            end
            else if Satellite > 0 then
            begin
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_currentTemperature:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonClosest.OP_meanTemperature;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_currentWindspeed:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonClosest.OP_windspeed;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_currentRainfall:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonClosest.OP_rainfall;
            end;
            inc( Count );
         end;
      end;

      optFarthest:
      begin
         while Count <= Max do
         begin
            if Satellite = 0 then
            begin
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_currentTemperature:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonFarthest.OP_meanTemperature;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_currentWindspeed:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonFarthest.OP_windspeed;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_currentRainfall:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonFarthest.OP_rainfall;
            end
            else if Satellite > 0 then
            begin
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_currentTemperature:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonFarthest.OP_meanTemperature;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_currentWindspeed:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonFarthest.OP_windspeed;
               FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_currentRainfall:=FCDduStarSystem[StarSys].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonFarthest.OP_rainfall;
            end;
            inc( Count );
         end;
      end;
   end;
end;

end.
