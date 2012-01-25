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
   ): TFCEduEnv; overload;

function FCFuF_Env_Get(
   const EGssys
         ,EGstar
         ,EGoobj
         ,EGsat: string
   ): TFCEduEnv; overload;

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
function FCFuF_StelObj_GetFullRow(
   const SOGFRssys
         ,SOGFRstar
         ,SOGFRoobj
         ,SOGFRsat: string
   ): TFCRufStelObj;

implementation

uses
   farc_data_init
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
   ,GCSorbP4tp: TFCEorbPeriodTp;
begin
   GCSorbTpRes:=optClosest;
   GCSseasRes:='';
   if GCSsatIdx=0
   then
   begin
      with FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[GCSooIdx] do
      begin
         GCSrevolIni:=OO_revolInit;
         GCSorbP1s:=OO_orbPeriod[1].OP_dayStart;
         GCSorbP1e:=OO_orbPeriod[1].OP_dayEnd;
         GCSorbP1tp:=OO_orbPeriod[1].OP_type;
         GCSorbP2s:=OO_orbPeriod[2].OP_dayStart;
         GCSorbP2e:=OO_orbPeriod[2].OP_dayEnd;
         GCSorbP2tp:=OO_orbPeriod[2].OP_type;
         GCSorbP3s:=OO_orbPeriod[3].OP_dayStart;
         GCSorbP3e:=OO_orbPeriod[3].OP_dayEnd;
         GCSorbP3tp:=OO_orbPeriod[3].OP_type;
         GCSorbP4s:=OO_orbPeriod[4].OP_dayStart;
         GCSorbP4e:=OO_orbPeriod[4].OP_dayEnd;
         GCSorbP4tp:=OO_orbPeriod[4].OP_type;
      end;
   end
   else if GCSsatIdx>0
   then
   begin
      with FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[GCSooIdx].OO_satList[GCSsatIdx] do
      begin
         GCSrevolIni:=OOS_revolInit;
         GCSorbP1s:=OOS_orbPeriod[1].OP_dayStart;
         GCSorbP1e:=OOS_orbPeriod[1].OP_dayEnd;
         GCSorbP1tp:=OOS_orbPeriod[1].OP_type;
         GCSorbP2s:=OOS_orbPeriod[2].OP_dayStart;
         GCSorbP2e:=OOS_orbPeriod[2].OP_dayEnd;
         GCSorbP2tp:=OOS_orbPeriod[2].OP_type;
         GCSorbP3s:=OOS_orbPeriod[3].OP_dayStart;
         GCSorbP3e:=OOS_orbPeriod[3].OP_dayEnd;
         GCSorbP3tp:=OOS_orbPeriod[3].OP_type;
         GCSorbP4s:=OOS_orbPeriod[4].OP_dayStart;
         GCSorbP4e:=OOS_orbPeriod[4].OP_dayEnd;
         GCSorbP4tp:=OOS_orbPeriod[4].OP_type;
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
      optInterm: GCSseasRes:='seasonMid';
      optFarest: GCSseasRes:='seasonMax';
   end;
   Result:=GCSseasRes;
end;

function FCFuF_Env_Get(
   const EGssys
         ,EGstar
         ,EGoobj
         ,EGsat: integer
   ): TFCEduEnv; overload;
{:Purpose: get the environment enum.
    Additions:
}
begin
   Result:=envfreeLiving;
   if EGsat=0
   then Result:=FCDBsSys[EGssys].SS_star[EGstar].SDB_obobj[EGoobj].OO_envTp
   else if EGsat>0
   then Result:=FCDBsSys[EGssys].SS_star[EGstar].SDB_obobj[EGoobj].OO_satList[EGsat].OOS_envTp;
end;

function FCFuF_Env_Get(
   const EGssys
         ,EGstar
         ,EGoobj
         ,EGsat: string
   ): TFCEduEnv; overload;
{:Purpose: get the environment enum.
    Additions:
}
var
   EGrow: TFCRufStelObj;
begin
   Result:=envfreeLiving;
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
   then Result:=FCDBsSys[EGrow[1]].SS_star[EGrow[2]].SDB_obobj[EGrow[3]].OO_envTp
   else if EGsat<>''
   then Result:=FCDBsSys[EGrow[1]].SS_star[EGrow[2]].SDB_obobj[EGrow[3]].OO_satList[EGrow[4]].OOS_envTp;
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
   EGSenv: TFCEduEnv;
begin
   if EGSsat=0
   then EGSenv:=FCDBsSys[EGSssys].SS_star[EGSstar].SDB_obobj[EGSoobj].OO_envTp
   else if EGSsat>0
   then EGSenv:=FCDBsSys[EGSssys].SS_star[EGSstar].SDB_obobj[EGSoobj].OO_satList[EGSsat].OOS_envTp;
   Result:='';
   case EGSenv of
      envfreeLiving: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvFL');
      restrict: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvR');
      space: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvS');
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
   EGSenv: TFCEduEnv;

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
   then EGSenv:=FCDBsSys[EGSrow[1]].SS_star[EGSrow[2]].SDB_obobj[EGSrow[3]].OO_envTp
   else if EGSrow[4]>0
   then EGSenv:=FCDBsSys[EGSrow[1]].SS_star[EGSrow[2]].SDB_obobj[EGSrow[3]].OO_satList[EGSrow[4]].OOS_envTp;
   Result:='';
   case EGSenv of
      envfreeLiving: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvFL');
      restrict: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvR');
      space: Result:=FCFdTFiles_UIStr_Get(uistrUI, 'secpEnvS');
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
      OPGMTdmpT1:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OPGMToobjIdx].OO_orbPeriod[1].OP_meanTemp;
      OPGMTdmpT2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OPGMToobjIdx].OO_orbPeriod[2].OP_meanTemp;
      OPGMTdmpT3:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OPGMToobjIdx].OO_orbPeriod[3].OP_meanTemp;
      OPGMTdmpT4:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OPGMToobjIdx].OO_orbPeriod[4].OP_meanTemp;
   end
   else if OPGMTsatIdx>0
   then
   begin
      OPGMTdmpT1
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OPGMToobjIdx].OO_satList[OPGMTsatIdx].OOS_orbPeriod[1].OP_meanTemp;
      OPGMTdmpT2
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OPGMToobjIdx].OO_satList[OPGMTsatIdx].OOS_orbPeriod[2].OP_meanTemp;
      OPGMTdmpT3
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OPGMToobjIdx].OO_satList[OPGMTsatIdx].OOS_orbPeriod[3].OP_meanTemp;
      OPGMTdmpT4
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OPGMToobjIdx].OO_satList[OPGMTsatIdx].OOS_orbPeriod[4].OP_meanTemp;
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
   RGCdmpClim: TFCEregClimate;
begin
   RGCdmpRes:='';
   if RGCsatIdx=0
   then RGCdmpClim:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[RGCooIdx].OO_regions[RGCregIdx].OOR_climate
   else if RGCsatIdx>0
   then RGCdmpClim
      :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[RGCooIdx].OO_satList[RGCsatIdx].OOS_regions[RGCregIdx].OOR_climate;
   case RGCdmpClim of
      rc00void: RGCdmpRes:='climtpVoid';
      rc01vhotHumid: RGCdmpRes:='climtpVHotH';
      rc02vhotSemiHumid: RGCdmpRes:='climtpVHotSH';
      rc03hotSemiArid: RGCdmpRes:='climtpHotSAr';
      rc04hotArid: RGCdmpRes:='climtpHotAr';
      rc05modHumid: RGCdmpRes:='climtpModH';
      rc06modDry: RGCdmpRes:='climtpModD';
      rc07coldArid: RGCdmpRes:='climtpColdAr';
      rc08periarctic: RGCdmpRes:='climtpPeria';
      rc09arctic: RGCdmpRes:='climtpArc';
      rc10extreme: RGCdmpRes:='climtpExtr';
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
      RLEmaxReg:=length(FCDBsSys[RLEssysIdx].SS_star[RLEstarIdx].SDB_obobj[RLEoobjIdx].OO_regions)-1;
   end
   else if RLEsatIdx>0
   then
   begin
      RLEmaxReg:=length(FCDBsSys[RLEssysIdx].SS_star[RLEstarIdx].SDB_obobj[RLEoobjIdx].OO_satList[RLEsatIdx].OOS_regions)-1;
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
         SOGDImax:=Length(FCDBsSys)-1;
         while SOGDIcnt<=SOGDImax do
         begin
            if FCDBsSys[SOGDIcnt].SS_token=SOGDItokenId
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
            if FCDBsSys[SOGDIssys].SS_star[SOGDIcnt].SDB_token=''
            then break
            else if FCDBsSys[SOGDIssys].SS_star[SOGDIcnt].SDB_token=SOGDItokenId
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
         SOGDImax:=Length(FCDBsSys[SOGDIssys].SS_star[SOGDIstar].SDB_obobj)-1;
         while SOGDIcnt<=SOGDImax do
         begin
            if FCDBsSys[SOGDIssys].SS_star[SOGDIstar].SDB_obobj[SOGDIcnt].OO_token=SOGDItokenId
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
         SOGDImax:=Length(FCDBsSys[SOGDIssys].SS_star[SOGDIstar].SDB_obobj[SOGDIoobj].OO_satList)-1;
         while SOGDIcnt<=SOGDImax do
         begin
            if FCDBsSys[SOGDIssys].SS_star[SOGDIstar].SDB_obobj[SOGDIoobj].OO_satList[SOGDIcnt].OOS_token=SOGDItokenId
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
   Result[1]:=0;
   Result[2]:=0;
   Result[3]:=0;
   Result[4]:=0;
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

end.
