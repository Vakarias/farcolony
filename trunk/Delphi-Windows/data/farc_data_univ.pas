{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: universe related datastructures

============================================================================================
********************************************************************************************
Copyright (c) 2009-2011, Jean-Francois Baconnet

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

unit farc_data_univ;

interface

   const
      FCDUorbits=100;

   //=======================================================================================
   {.stars and orbital objects datastructures}
   //=======================================================================================
   {.companion 2 orbit type}
   {:DEV NOTES : update universe.xml + FCMdFiles_DBstarSys_Process.}
   type TFCEduCompOrb=(
      {.around main-companion 1 stars}
      coAroundCenter
      {.around companion 1 star only}
      ,coAroundComp
      {.around gravity center of main-companion 1 star}
      ,coAroundGravC
      );
   {.environment type}
   {:DEV NOTES: update universe.xml + FCMdFiles_DBstarSys_Process.}
   type TFCEduEnv=(
      envAny
      ,envfreeLiving
      ,restrict
      ,space
      ,gaseous
      );
   {.orbital zones}
   type TFCEduHabZone=(
      {.inner zone}
      zoneInner
      {.intermediate zone}
      ,zoneInterm
      {.outer zone}
      ,zoneOuter
      );
   {.orbital object type list, derived from previous FARC}
   type TFCEduOobjTp=(
      {.protoplanetary disk, old num=1}
      oobtpProtoDisk
      {.old num=2}
      ,oobtpAsterBelt_Metall
      {.old num=3}
      ,oobtpAsterBelt_Sili
      {.old num=4}
      ,oobtpAsterBelt_Carbo
      {.old num=5}
      ,oobtpAsterBelt_Icy
      {.old num=6}
      ,oobtpAster_Metall
      {.old num=7}
      ,oobtpAster_Sili
      {.old num=8}
      ,oobtpAster_Carbo
      {.old num=9}
      ,oobtpAster_Icy
      {.old num=11}
      ,oobtpPlan_Tellu_EarthH0H1
      {.old num=12}
      ,oobtpPlan_Tellu_EarthH2
      {.old num=13}
      ,oobtpPlan_Tellu_EarthH3
      {.old num=14}
      ,oobtpPlan_Tellu_EarthH4
      {.old num=15}
      ,oobtpPlan_Tellu_MarsH0H1
      {.old num=16}
      ,oobtpPlan_Tellu_MarsH2
      {.old num=17}
      ,oobtpPlan_Tellu_MarsH3
      {.old num=18}
      ,oobtpPlan_Tellu_MarsH4
      {.old num=19}
      ,oobtpPlan_Tellu_VenusH0H1
      {.old num=20}
      ,oobtpPlan_Tellu_VenusH2
      {.old num=21}
      ,oobtpPlan_Tellu_VenusH3
      {.old num=22}
      ,oobtpPlan_Tellu_VenusH4
      {.old num=23}
      ,oobtpPlan_Tellu_MercuH0
      {.old num=24}
      ,oobtpPlan_Tellu_MercuH3
      {.old num=25}
      ,oobtpPlan_Tellu_MercuH4
      {.old num=28}
      ,oobtpPlan_Icy_PlutoH3
      {.old num=29}
      ,oobtpPlan_Icy_EuropeH4
      {.old num=30}
      ,oobtpPlan_Icy_CallistoH3H4Atm0
      {.old num=31}
      ,oobtpPlan_Gas_Uranus
      {.old num=32}
      ,oobtpPlan_Gas_Neptun
      {.old num=33}
      ,oobtpPlan_Gas_Saturn
      //                    TL_Plan_Gas_Other    //old num=34
      {.old num=35}
      ,oobtpPlan_Jovian_Jupiter
      //                    TL_Plan_Jovian_Other //old num=36
      {.old num=37}
      ,oobtpPlan_Supergiant1
      //                    TL_Plan_Supergiant2  //old num=38
      {.old num=39}
      ,oobtpSat_Aster_Metall
      {.old num=40}
      ,oobtpSat_Aster_Sili
      {.old num=41}
      ,oobtpSat_Aster_Carbo
      {.old num=42}
      ,oobtpSat_Aster_Icy
      //                    TL_Sat_Tellu_Mercu   //old num=43
      {.old num=44}
      ,oobtpSat_Tellu_Lunar
      {.old num=45}
      ,oobtpSat_Tellu_Io
      {.old num=46}
      ,oobtpSat_Tellu_Titan
      {.old num=47}
      ,oobtpSat_Tellu_Earth
      {.old num=48}
      ,oobtpSat_Icy_Pluto
      {.old num=49}
      ,oobtpSat_Icy_Europe
      {.old num=50}
      ,oobtpSat_Icy_Callisto
      {.old num=100}
      ,oobtpRing_Metall
      {.old num=101}
      ,oobtpRing_Sili
      {.old num=102}
      ,oobtpRing_Carbo
      {.old num=103}
      ,oobtpRing_Icy
      );

   {.resource quality}
   type TFCEduRsrcQuality=(
      rqNone
      ,rqFbad
      ,rqEpoor
      ,rqDfairavg
      ,rqCgood
      ,rqBexcellent
      ,rqAperfect
      );

   {.resource rarity}
   type TFCEduRsrcRarity=(
      rrRich
      ,rrAbundant
      ,rrCommon
      ,rrPresent
      ,rrUncommon
      ,rrRare
      ,rrAbsent
      );

   {.types of resource spot}
   type TFCEduRsrcSpotType=(
      rstGasField
      ,rstHydroWell
      ,rstIcyOreField
      ,rstOreField
      ,rstUnderWater
      );

   {.list of all star classes used in FARC}
   type TFCEduStarClass=(
      {super giant blue Ia/Ib}
      cB5, cB6, cB7, cB8, cB9
      {super giant white}
      ,cA0, cA1, cA2, cA3, cA4, cA5, cA6, cA7, cA8, cA9
      {super giant orange}
      ,cK0, cK1, cK2, cK3, cK4, cK5, cK6, cK7, cK8, cK9
      {super giant red}
      ,cM0, cM1, cM2, cM3, cM4, cM5
      {giant yellow-white III}
      ,gF0, gF1, gF2, gF3, gF4, gF5, gF6, gF7, gF8, gF9
      {giant yellow}
      ,gG0, gG1, gG2, gG3, gG4, gG5, gG6, gG7, gG8, gG9
      {giant orange}
      ,gK0, gK1, gK2, gK3, gK4, gK5, gK6, gK7, gK8, gK9
      {giant red}
      ,gM0, gM1, gM2, gM3, gM4, gM5
      {main sequence blue dwarf }
      ,O5, O6, O7, O8, O9
      {main sequence blue-white dwarf}
      ,B0, B1, B2, B3, B4, B5, B6, B7, B8, B9
      {main sequence white dwarf}
      ,A0, A1, A2, A3, A4, A5, A6, A7, A8, A9
      {main sequence yellow-white dwarf}
      ,F0, F1, F2, F3, F4, F5, F6, F7, F8, F9
      {main sequence yellow dwarf}
      ,G0, G1, G2, G3, G4, G5, G6, G7, G8, G9
      {main sequence orange dwarf}
      ,K0, K1, K2, K3, K4, K5, K6, K7, K8, K9
      {main sequence red dwarf}
      ,M0, M1, M2, M3, M4, M5, M6, M7, M8, M9
      {white dwarf}
      ,WD0, WD1, WD2, WD3, WD4, WD5, WD6, WD7, WD8, WD9
      {pulsar}
      ,PSR
      {black hole}
      ,BH
      );
   //==END ENUM=============================================================================

   {:DEV NOTES: ****you need to update FARC.main.odt when updating this data structure****}
   type TFCEatmGasStat= {atmosphere gas status}
      (
         agsNotPr,      {gas not present}
         agsTrace,      {trace gas}
         agsSec,        {secondary gas}
         agsMain        {main gas}
      );

   {:DEV NOTES: ****you need to update FARC.main.odt when updating this data structure****}
      {atmospheric composition data structure}
   type TFCRatmComp = record
         {hydrogen}
      agasH2: TFCEatmGasStat;
         {helium}
      agasHe: TFCEatmGasStat;
         {methane}
      agasCH4: TFCEatmGasStat;
         {ammonia}
      agasNH3: TFCEatmGasStat;
         {water vapor}
      agasH2O: TFCEatmGasStat;
         {neon}
      agasNe: TFCEatmGasStat;
         {nitrogen}
      agasN2: TFCEatmGasStat;
         {carbon monoxyde}
      agasCO: TFCEatmGasStat;
         {nitric oxyde / nitrogen}
      agasNO: TFCEatmGasStat;
         {oxygen}
      agasO2: TFCEatmGasStat;
         {hydrogen sulfide}
      agasH2S: TFCEatmGasStat;
         {argon}
      agasAr: TFCEatmGasStat;
         {carbon dioxide}
      agasCO2: TFCEatmGasStat;
         {nitrogen dioxide}
      agasNO2: TFCEatmGasStat;
         {ozone}
      agasO3: TFCEatmGasStat;
         {sulfur dioxide}
      agasSO2: TFCEatmGasStat;
   end;

   {.sub datastructure about units in orbit (space units only)}
   type TFCRorbitUnit = record
      {.unit's faction id #}
      OU_faction: integer;
      {.unit's owned index}
      OU_spUn: integer;
   end;
   {:DEV NOTES: ****you need to update FARC.main.odt when updating this data structure****}
      {.orbital period types}
   type TFCEorbPeriodTp=
      (
         optClosest
         ,optInterm
         ,optFarest
      );
   {:DEV NOTES: ****you need to update FARC.main.odt when updating this data structure****}
      {sub datastructure about orbital period and mean surface temperature, following season}
   type TFCRorbPeriod = record
         {.orbital period type}
      OP_type: TFCEorbPeriodTp;
         {.starting day of the season/orbital period}
      OP_dayStart: integer;
         {.ending day of the season/orbital period}
      OP_dayEnd: integer;
         {.mean surface temperature during this season}
      OP_meanTemp: double;
   end;
   {:DEV NOTES: ****you need to update FARC.main.odt when updating this data structure****}
      {.hydrosphere types}
   type TFCEhydroTp=
      (
            {.no water presence}
         htNone
            {.water presence under vapour}
         ,htVapor
            {.water presence under liquid form}
         ,htLiquid
            {.water presence under ice sheet form}
         ,htIceSheet
            {.water presence under crystal ice form}
         ,htCrystal
            {.water presence in a blend w/ ammonia}
         ,htLiqNH3
            {.water is replaced w/ liquid methane}
         ,htLiqCH4
      );
      {.terrain relief types}
   type TFCEregRelief=
      (
         rr1plain
         ,rr4broken
         ,rr9mountain
      );
      {.soil types}
      {:DEV NOTES: update TFCEdipRegionSoilReq if needed.}
   type TFCEregSoilTp=
      (
         rst01rockDes
         ,rst02sandDes
         ,rst03volcanic
         ,rst04polar
         ,rst05arid
         ,rst06fertile
         ,rst07oceanic
         ,rst08coastRockDes
         ,rst09coastSandDes
         ,rst10coastVolcanic
         ,rst11coastPolar
         ,rst12coastArid
         ,rst13coastFertile
         ,rst14barren
         ,rst15icyBarren
      );
      {.climate types}
   type TFCEregClimate=
      (
         rc00void
         ,rc01vhotHumid
         ,rc02vhotSemiHumid
         ,rc03hotSemiArid
         ,rc04hotArid
         ,rc05modHumid
         ,rc06modDry
         ,rc07coldArid
         ,rc08periarctic
         ,rc09arctic
         ,rc10extreme
      );
   {.region sub data structure}
   {:DEV NOTE: update FCMdF_DBstarSys_Process.}
   type TFCRoobReg = record
      {.type of soil}
      OOR_soilTp: TFCEregSoilTp;
      {.type of relief}
      OOR_relief: TFCEregRelief;
      {.type of climate}
      OOR_climate: TFCEregClimate;
      {.mean temperature at minimum orbital distance in kelvin}
      OOR_meanTdMin: Double;
      {.mean temperature at intermediate orbital distance in kelvin}
      OOR_meanTdInt: Double;
      {.mean temperature at maximum orbital distance in kelvin}
      OOR_meanTdMax: Double;
      {.mean windspeed in m/s}
      OOR_windSpd: Double;
      {.yearly precipitation in mm}
      OOR_precip: Integer;
      {.settlement data}
      OOR_setEnt: integer;
      OOR_setCol: integer;
      OOR_setSet: integer;
      {.environment modifier}
      OOR_emo: double;
      {.resources data}
      OOR_resourceSpot: array of record
         RS_type: TFCEduRsrcSpotType;
         RS_quality: TFCEduRsrcQuality;
         RS_rarity: TFCEduRsrcRarity;
      end;
   end;
   {.satellite data structure, child of TFCRorbObj}
   {:DEV NOTE: don't forget to update farc_data_files / FCMdFiles_DBstarSys_Process.}
   type TFCRorbObjSat = record
         {satellite db token id}
      OOS_token: string[20];
         {NOT LOADED DATA - counter of OOS_inOrbitList}
      OOS_inOrbitCnt: integer;
         {NOT LOADED DATA - list of units in orbit}
      OOS_inOrbitList: array[0..FCDUorbits] of TFCRorbitUnit;
      {.colonies settled on it [faction#]=owned colony id db #, 0= player}
      OOS_colonies: array [0..1] of integer;
         {kind of satellite}
      OOS_type: TFCEduOobjTp;
      {.environment type}
      OOS_envTp: TFCEduEnv;
         {distance from it's central planet in thousands of km}
      OOS_distFrmOOb: double;
         {revolution period, in standard days, around it's planet}
      OOS_revol: integer;
         {starting day for revolution period}
      OOS_revolInit: integer;
         {NOT LOADED DATA - value used for 3d display}
      OOS_angle1stDay: double;
         {diameter in km RTO-1}
      OOS_diam: double;
         {density in kg/m3}
      OOS_dens: double;
         {mass in Earth mass equivalent RTO-6}
      OOS_mass: double;
         {gravity in gees RTO-3}
      OOS_grav: double;
         {gravity sphere of influence radius  in km RTO-1}
      OOS_gravSphRad: double;
         {escape velocity in km/s RTO-2}
      OOS_escVel: double;
         {inclination axis}
      OOS_inclAx: double;
         {magnetic field in gauss}
      OOS_magFld: double;
         {body albedo RTO-2}
      OOS_albedo: double;
         {atmosphere pressure in mbars, 1013 eq 1 atm eq 101.3kpa}
      OOS_atmPress: double;
         {cloud cover in %}
      OOS_cloudsCov: double;
         {atmosphere detailed composition}
      OOS_atmosph: TFCRatmComp;
         {.orbital periods list, 2 intermediate 1 closest (summer) 1 farest (winter)}
      OOS_orbPeriod: array[0..4] of TFCRorbPeriod;
         {.hydrosphere type}
      OOS_hydrotp: TFCEhydroTp;
         {.hydrosphere area}
      OOS_hydroArea: double;
         {.regions}
      OOS_regions: array of TFCRoobReg;
   end;
   {.FUG orbits to generate}
   type TFCRduFUGstarOrb= array[0..3] of integer;
   {.FUG system type}
   type TFCRduFUGsysTp= array[0..3] of integer;
   {.orbital object data structure, child of TFCRstar}
   {:DEV NOTE: don't forget to update farc_data_files / FCMdFiles_DBstarSys_Process.}
   type TFCRduOobj = record
         {db token id}
      OO_token: string[20];
         {NOT LOADED DATA - counter of OO_inOrbitList}
      OO_inOrbitCnt: integer;
         {NOT LOADED DATA - list of units in orbit}
      OO_inOrbitList: array[0..FCDUorbits] of TFCRorbitUnit;
         {NOT LOADED DATA - index of the first satellite object}
      OO_sat1stOb: integer;
      OO_satList: array of TFCRorbObjSat;
      {.colonies settled on it [faction#]=owned colony id db #, 0= player}
      OO_colonies: array [0..1] of integer;
         {kind of orbital object}
      OO_type: TFCEduOobjTp;
      {.environment type}
      OO_envTp: TFCEduEnv;
         {distance from it's star in AU}
      OO_distFrmStar: double;
         {orbit eccentricity in #.### format}
      OO_ecc: double;
         {orbital zone type}
      OO_orbZone: TFCEduHabZone;
         {revolution period, in standard days, around it's star}
      OO_revol: integer;
         {starting day for revolution period}
      OO_revolInit: integer;
         {NOT LOADED DATA - value used for 3d display}
      OO_angle1stDay: double;
         {diameter in km RTO-1}
      OO_diam: double;
         {density in kg/m3}
      OO_dens: double;
         {mass in Earth mass equivalent RTO-6}
      OO_mass: double;
         {gravity in gees RTO-3}
      OO_grav: double;
         {gravity sphere of influence radius  in km RTO-1}
      OO_gravSphRad: double;
         {escape velocity in km/s RTO-2}
      OO_escVel: double;
         {rotation period, around it's own axis, in hours RTO-2}
      OO_rotPer: double;
         {inclination axis}
      OO_inclAx: double;
         {magnetic field in gauss}
      OO_magFld: double;
         {body albedo RTO-2}
      OO_albedo: double;
         {atmosphere pressure in mbars, 1013 eq 1 atm eq 101.3kpa}
      OO_atmPress: double;
         {cloud cover in %}
      OO_cloudsCov: double;
         {atmosphere detailed composition}
      OO_atmosph: TFCRatmComp;
         {.orbital periods list, 2 intermediate 1 closest (summer) 1 farest (winter)}
      OO_orbPeriod: array[0..4] of TFCRorbPeriod;
         {.hydrosphere type}
      OO_hydrotp: TFCEhydroTp;
         {.hydrosphere area}
      OO_hydroArea: double;
         {.regions}
      OO_regions: array of TFCRoobReg;
   end;
   {.star data structure, child of TFCRstarSys}
   type TFCRstar = record
      {db token id}
      SDB_token: string[20];
      {class, like G2, K, PSR...}
      SDB_class: TFCEduStarClass;
      {temperature in degree Kelvin}
      SDB_temp: Integer;
      {mass, relative to Sun}
      SDB_mass: Double;
      {diameter, relative to Sun}
      SDB_diam: Double;
      {luminosity, relative to Sun}
      SDB_lum: Double;
      {orbital object sub-datastructure}
      SDB_obobj: array of TFCRduOobj;
      {.companion star - mean separation}
      SDB_meanSep: double;
      {.companion star - minimal approach distance}
      SDB_minApD: double;
      {.companion star - eccentricity}
      SDB_ecc: double;
      {.companion star 2 - orbit type}
      SDB_comp2Orb: TFCEduCompOrb;
   end;
   {.unified star systems datastructure}
   {:DEV NOTES : update universe.xml + FCMdFiles_DBstarSys_Process.}
   type TFCRstarSys = record
      {.star system db token id}
      SS_token: string[20];
      {.star system location on X axis, the unit is in AU and relative to Sol}
      SS_gLocX: double;
      SS_gLocY: double;                   {star system location on Y axis, the unit is in AU
                                          and relative to Sol}
      SS_gLocZ: double;                   {star system location on Z axis, the unit is in AU
                                          and relative to Sol}
      SS_star: array [0..3] of TFCRstar;  {star's sub datastructure 1= main 2 and 3 =
                                          compagnon ones}
   end;
      {.stellar systems dynamic array}
      TFCDBstarSys = array of TFCRstarSys;
   //=======================================================================================
   {.global variables}
   //=======================================================================================
   var
      FCDBsSys: TFCDBstarSys;
      FUGstarOrb: TFCRduFUGstarOrb;
      FUGsysTp: TFCRduFUGsysTp;

implementation

//=============================================END OF INIT==================================

end.
