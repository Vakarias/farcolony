{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: universe related datastructures

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

unit farc_data_univ;

interface

//uses


{:REFERENCES LIST
   - FCMoglVMain_Atmosph_SetCol
   - FCFuiSP_EcoDataAtmosphere_Process    FCMuiSP_SurfaceEcosphere_Set
   - TFCRufAtmosphereGasesPercent.AtmosphereGases_CalculatePercents
}
///<summary>
///   atmospheric gas status
///</summary>
type TFCEduAtmosphericGasStatus=(
   agsNotPresent
   ,agsTrace
   ,agsSecondary
   ,agsMain
   );

{:REFERENCES LIST
   - universe.xml
   - FCMdFiles_DBstarSys_Process
}
///<summary>
///   companion 2 orbit types
///</summary>
type TFCEduCompanion2OrbitTypes=(
   cotAroundMain_Companion1
   ,cotAroundCompanion1
   ,cotAroundMain_Companion1GravityCenter
   );

{:REFERENCES LIST
   - universe.xml
   - FCMdF_DBstarSys_Process
   - FCFuF_Env_GetStr
}
///<summary>
///   environment types
///</summary>
type TFCEduEnvironmentTypes=(
   etAny
   ,etFreeLiving
   ,etRestricted
   ,etSpace
   ,etGaseous
   );

{:REFERENCES LIST
   - universe.xml
   - FCMdFiles_DBstarSys_Process
}
///<summary>
///   habitable zones (in the human sense, not for aliens)
///</summary>
type TFCEduHabitableZones=(
   hzInner
   ,hzIntermediary
   ,hzOuter
   );

{:REFERENCES LIST
   - FCFgC_ColEnv_GetTp
   - FCMoglVMain_MapTex_Assign
   - FCMuiCDP_Data_Update
   - FCMuiSP_SurfaceEcosphere_Set
}
///<summary>
///   types of hydrospheres
///</summary>
type TFCEduHydrospheres=(
   hNoH2O
   ,hVaporH2O
   ,hLiquidH2O
   ,hIceSheet
   ,hCrystalIce
   ,hLiquidH2O_blend_NH3
   ,hLiquidCH4
   );

{:REFERENCES LIST
   - universe.xml
   - FCMdF_DBstarSys_Process
   - FCMoglUI_Main3DViewUI_Update
   - FCFoglVMain_Aster_Set    FCMoglVMain_MapTex_Assign  FCMoglVM_MView_Upd
   - FCMuiSP_SurfaceEcosphere_Set
}
///<summary>
///   orbital object types list. old num take reference of the data format of the previous iterations of FARC
///</summary>
{:DEV NOTES: REMOVE THE OLD REFRENCES WHEN THE FUG WILL BE COMPLETE.}
type TFCEduOrbitalObjectTypes=(
   {.old mum=1}
   ootProtoplanetaryDisk
   {.old num=2}
   ,ootAsteroidsBelt_Metallic
   {.old num=3}
   ,ootAsteroidsBelt_Silicate
   {.old num=4}
   ,ootAsteroidsBelt_Carbonaceous
   {.old num=5}
   ,ootAsteroidsBelt_Icy
   {.old num=6}
   ,ootAsteroid_Metallic
   {.old num=7}
   ,ootAsteroid_Silicate
   {.old num=8}
   ,ootAsteroid_Carbonaceous
   {.old num=9}
   ,ootAsteroid_Icy
   {.old num=11}
   ,ootPlanet_Telluric_EarthH0H1
   {.old num=12}
   ,ootPlanet_Telluric_EarthH2
   {.old num=13}
   ,ootPlanet_Telluric_EarthH3
   {.old num=14}
   ,ootPlanet_Telluric_EarthH4
   {.old num=15}
   ,ootPlanet_Telluric_MarsH0H1
   {.old num=16}
   ,ootPlanet_Telluric_MarsH2
   {.old num=17}
   ,ootPlanet_Telluric_MarsH3
   {.old num=18}
   ,ootPlanet_Telluric_MarsH4
   {.old num=19}
   ,ootPlanet_Telluric_VenusH0H1
   {.old num=20}
   ,ootPlanet_Telluric_VenusH2
   {.old num=21}
   ,ootPlanet_Telluric_VenusH3
   {.old num=22}
   ,ootPlanet_Telluric_VenusH4
   {.old num=23}
   ,ootPlanet_Telluric_MercuryH0
   {.old num=24}
   ,ootPlanet_Telluric_MercuryH3
   {.old num=25}
   ,ootPlanet_Telluric_MercuryH4
   {.old num=28}
   ,ootPlanet_Icy_PlutoH3
   {.old num=29}
   ,ootPlanet_Icy_EuropaH4
   {.old num=30}
   ,ootPlanet_Icy_CallistoH3H4Atm0
   {.old num=31}
   ,ootPlanet_Gaseous_Uranus
   {.old num=32}
   ,ootPlanet_Gaseous_Neptune
   {.old num=33}
   ,ootPlanet_Gaseous_Saturn
   //                    TL_Plan_Gas_Other    //old num=34
   {.old num=35}
   ,ootPlanet_Jovian
   //                    TL_Plan_Jovian_Other //old num=36
   {.old num=37}
   ,ootPlanet_Supergiant
   //                    TL_Plan_Supergiant2  //old num=38
   {.old num=39}
   ,ootSatellite_Asteroid_Metallic
   {.old num=40}
   ,ootSatellite_Asteroid_Silicate
   {.old num=41}
   ,ootSatellite_Asteroid_Carbonaceous
   {.old num=42}
   ,ootSatellite_Asteroid_Icy
   //                    TL_Sat_Tellu_Mercu   //old num=43
   {.old num=44}
   ,ootSatellite_Telluric_Lunar
   {.old num=45}
   ,ootSatellite_Telluric_Io
   {.old num=46}
   ,ootSatellite_Telluric_Titan
   {.old num=47}
   ,ootSatellite_Telluric_Earth
   {.old num=48}
   ,ootSatellite_Icy_Pluto
   {.old num=49}
   ,ootSatellite_Icy_Europa
   {.old num=50}
   ,ootSatellite_Icy_Callisto
   {.old num=100}
   ,ootRing_Metallic
   {.old num=101}
   ,ootRing_Silicate
   {.old num=102}
   ,ootRing_Carbonaceous
   {.old num=103}
   ,ootRing_Icy
   );

{:REFERENCES LIST
   - FCMdF_DBstarSys_Process
   - FCFuF_Ecosph_GetCurSeas
}
///<summary>
///   orbital period types
///</summary>
type TFCEduOrbitalPeriodTypes=(
   optClosest
   ,optIntermediary
   ,optFarest
   );

{:REFERENCES LIST
   - FCMdF_DBstarSys_Process
   - FCFuF_Region_GetClim
}
///<summary>
///   region's climates
///</summary>
type TFCEduRegionClimates=(
   rc00VoidNoUse
   ,rc01VeryHotHumid
   ,rc02VeryHotSemiHumid
   ,rc03HotSemiArid
   ,rc04HotArid
   ,rc05ModerateHumid
   ,rc06ModerateDry
   ,rc07ColdArid
   ,rc08Periarctic
   ,rc09Arctic
   ,rc10Extreme
   );

{:REFERENCES LIST
   - FCMdF_DBstarSys_Process
   - FCMuiSP_RegionDataPicture_Update
}
///<summary>
///   region's reliefs
///</summary>
type TFCEduRegionReliefs=(
   rr1Plain
   ,rr4Broken
   ,rr9Mountain
   );

{:REFERENCES LIST
   - TFCEdipRegionSoilReq
   - FCMdF_DBstarSys_Process
   - FCMuiSP_RegionDataPicture_Update
}
///<summary>
///   -
///</summary>
type TFCEduRegionSoilTypes=(
   rst01RockyDesert
   ,rst02SandyDesert
   ,rst03Volcanic
   ,rst04Polar
   ,rst05Arid
   ,rst06Fertile
   ,rst07Oceanic
   ,rst08CoastalRockyDesert
   ,rst09CoastalSandyDesert
   ,rst10CoastalVolcanic
   ,rst11CoastalPolar
   ,rst12CoastalArid
   ,rst13CoastalFertile
   ,rst14Sterile
   ,rst15icySterile
   );

{:REFERENCES LIST
   - universe.xml
   - FCMdF_DBstarSys_Process
}
///<summary>
///   resource spot quality
///</summary>
type TFCEduResourceSpotQuality=(
   rsqNone
   ,rsqF_Bad
   ,rsqE_Poor
   ,rsqD_FairAverage
   ,rsqC_Good
   ,rsqB_Excellent
   ,rsqA_Perfect
   );

{:REFERENCES LIST
   - universe.xml
   - FCMdF_DBstarSys_Process
}
///<summary>
///   resource spot rarity
///</summary>
type TFCEduResourceSpotRarity=(
   rsrRich
   ,rsrAbundant
   ,rsrCommon
   ,rsrPresent
   ,rsrUncommon
   ,rsrRare
   ,rsrAbsent
   );

{:REFERENCES LIST
   - infrastrucdb.xml
   - universe.xml
   - FCMdF_DBInfra_Read
   - FCMdF_DBstarSys_Process
}
///<summary>
///   types of resource spot
///</summary>
type TFCEduResourceSpotTypes=(
   rstNone
   ,rstGasField
   ,rstHydroWell
   ,rstIcyOreField
   ,rstOreField
   ,rstUnderWater
   );

{:REFERENCES LIST
   - FCMdF_DBstarSys_Process
   - TFCWinFUG.FCWFgenerateClick
}
///<summary>
///   star classes used in FARC
///</summary>
type TFCEduStarClasses=(
   {.super giant blue Ia/Ib}
   cB5, cB6, cB7, cB8, cB9
   {.super giant white}
   ,cA0, cA1, cA2, cA3, cA4, cA5, cA6, cA7, cA8, cA9
   {.super giant orange}
   ,cK0, cK1, cK2, cK3, cK4, cK5, cK6, cK7, cK8, cK9
   {.super giant red}
   ,cM0, cM1, cM2, cM3, cM4, cM5
   {.giant yellow-white III}
   ,gF0, gF1, gF2, gF3, gF4, gF5, gF6, gF7, gF8, gF9
   {.giant yellow}
   ,gG0, gG1, gG2, gG3, gG4, gG5, gG6, gG7, gG8, gG9
   {.giant orange}
   ,gK0, gK1, gK2, gK3, gK4, gK5, gK6, gK7, gK8, gK9
   {.giant red}
   ,gM0, gM1, gM2, gM3, gM4, gM5
   {.main sequence blue dwarf}
   ,O5, O6, O7, O8, O9
   {.main sequence blue-white dwarf}
   ,B0, B1, B2, B3, B4, B5, B6, B7, B8, B9
   {.main sequence white dwarf}
   ,A0, A1, A2, A3, A4, A5, A6, A7, A8, A9
   {.main sequence yellow-white dwarf}
   ,F0, F1, F2, F3, F4, F5, F6, F7, F8, F9
   {.main sequence yellow dwarf}
   ,G0, G1, G2, G3, G4, G5, G6, G7, G8, G9
   {.main sequence orange dwarf}
   ,K0, K1, K2, K3, K4, K5, K6, K7, K8, K9
   {.main sequence red dwarf}
   ,M0, M1, M2, M3, M4, M5, M6, M7, M8, M9
   {.white dwarf}
   ,WD0, WD1, WD2, WD3, WD4, WD5, WD6, WD7, WD8, WD9
   {.pulsar}
   ,PSR
   {.black hole}
   ,BH
   );

//==END PUBLIC ENUM=========================================================================

{:REFERENCES LIST
   - universe.xml
   - FCMdF_DBstarSys_Process
   - FCMoglVMain_Atmosph_SetCol
   - FCFuiSP_EcoDataAtmosphere_Process
   - TFCRufAtmosphereGasesPercent.AtmosphereGases_CalculatePercents
}
///<summary>
///   atmospheric composition
///</summary>
type TFCRduAtmosphericComposition = record
   AC_primaryGasVolumePerc: integer;
   AC_gasPresenceH2: TFCEduAtmosphericGasStatus;
   AC_gasPresenceHe: TFCEduAtmosphericGasStatus;
   AC_gasPresenceCH4: TFCEduAtmosphericGasStatus;
   AC_gasPresenceNH3: TFCEduAtmosphericGasStatus;
   AC_gasPresenceH2O: TFCEduAtmosphericGasStatus;
   AC_gasPresenceNe: TFCEduAtmosphericGasStatus;
   AC_gasPresenceN2: TFCEduAtmosphericGasStatus;
   AC_gasPresenceCO: TFCEduAtmosphericGasStatus;
   AC_gasPresenceNO: TFCEduAtmosphericGasStatus;
   AC_gasPresenceO2: TFCEduAtmosphericGasStatus;
   AC_gasPresenceH2S: TFCEduAtmosphericGasStatus;
   AC_gasPresenceAr: TFCEduAtmosphericGasStatus;
   AC_gasPresenceCO2: TFCEduAtmosphericGasStatus;
   AC_gasPresenceNO2: TFCEduAtmosphericGasStatus;
   AC_gasPresenceO3: TFCEduAtmosphericGasStatus;
   AC_gasPresenceSO2: TFCEduAtmosphericGasStatus;
end;

{:REFERENCES LIST
   -
   -
   -
   -
   -
   -
}
{.region sub data structure}
{:DEV NOTE: update FCMdF_DBstarSys_Process.}
type TFCRduOObRegion = record
   {.type of soil}
   OOR_soilTp: TFCEduRegionSoilTypes;
   {.type of relief}
   OOR_relief: TFCEduRegionReliefs;
   {.type of climate}
   OOR_climate: TFCEduRegionClimates;
   {.mean temperature at minimum orbital distance in kelvin}
   OOR_meanTdMin: extended;
   {.mean temperature at intermediate orbital distance in kelvin}
   OOR_meanTdInt: extended;
   {.mean temperature at maximum orbital distance in kelvin}
   OOR_meanTdMax: extended;
   {.mean windspeed in m/s}
   OOR_windSpd: extended;
   {.yearly precipitation in mm}
   OOR_precip: Integer;
   {.settlement data}
   OOR_setEnt: integer;
   OOR_setCol: integer;
   OOR_setSet: integer;
   {.environment modifier}
   OOR_emo: extended;
   {.resources data}
   OOR_resourceSpot: array of record
      RS_type: TFCEduResourceSpotTypes;
      RS_quality: TFCEduResourceSpotQuality;
      RS_rarity: TFCEduResourceSpotRarity;
   end;
end;

{:REFERENCES LIST
   - FCMdF_DBstarSys_Process
   - FCFuF_Ecosph_GetCurSeas
   -
   -
   -
   -
   -
}
///<summary>
///   season, relative to the orbital period
///</summary>
type TFCRduSeason = record
   S_orbitalPeriodType: TFCEduOrbitalPeriodTypes;
   S_dayStart: integer;
   S_dayEnd: integer;
   S_meanTemperature: extended;
end;

{:REFERENCES LIST
   - FCMspuF_Orbits_Process
   -
   -
   -
   -
   -
}
///<summary>
///   space units in orbit
///</summary>
type TFCRduSpaceUnitInOrbit = record
   SUIO_faction: integer;
   SUIO_ownedSpaceUnitIndex: integer;
end;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

//============================OLD CODE==================================================================================
   const
      FCDUorbits=100;

   //=======================================================================================
   {.stars and orbital objects datastructures}
   //=======================================================================================
   



   








   {:DEV NOTES: try to blend the oobj and sat data structure
      do not update the SVN until it's tested and doable without blow all the structure

      put bool in oobj=>  case isAsat of

      false:
         put # of sat
         put index of sat #1


      true:
         put sat# in the order
         put OOS_distFrmOOb

   }
   {.satellite data structure, child of TFCRorbObj}
   {:DEV NOTE: don't forget to update farc_data_files / FCMdFiles_DBstarSys_Process.}
   type TFCRorbObjSat = record
         {satellite db token id}
      OOS_token: string[20];
         {NOT LOADED DATA - counter of OOS_inOrbitList}
      OOS_inOrbitCnt: integer;
         {NOT LOADED DATA - list of units in orbit}
      OOS_inOrbitList: array[0..FCDUorbits] of TFCRduSpaceUnitInOrbit;
      {.colonies settled on it [faction#]=owned colony id db #, 0= player}
      OOS_colonies: array [0..1] of integer;
         {kind of satellite}
      OOS_type: TFCEduOrbitalObjectTypes;
      {.environment type}
      OOS_envTp: TFCEduEnvironmentTypes;
         {distance from it's central planet in thousands of km}
      OOS_distFrmOOb: extended;
         {revolution period, in standard days, around it's planet}
      OOS_revol: integer;
         {starting day for revolution period}
      OOS_revolInit: integer;
         {NOT LOADED DATA - value used for 3d display}
      OOS_angle1stDay: extended;
         {diameter in km RTO-1}
      OOS_diam: extended;
         {density in kg/m3}
      OOS_dens: extended;
         {mass in Earth mass equivalent RTO-6}
      OOS_mass: extended;
         {gravity in gees RTO-3}
      OOS_grav: extended;
         {gravity sphere of influence radius  in km RTO-1}
      OOS_gravSphRad: extended;
         {escape velocity in km/s RTO-2}
      OOS_escVel: extended;
         {inclination axis}
      OOS_inclAx: extended;
         {magnetic field in gauss}
      OOS_magFld: extended;
         {body albedo RTO-2}
      OOS_albedo: extended;
         {atmosphere pressure in mbars, 1013 eq 1 atm eq 101.3kpa}
      OOS_atmPress: extended;
         {cloud cover in %}
      OOS_cloudsCov: extended;
         {atmosphere detailed composition}
      OOS_atmosph: TFCRduAtmosphericComposition;
         {.orbital periods list, 2 intermediate 1 closest (summer) 1 farest (winter)}
      OOS_orbPeriod: array[0..4] of TFCRduSeason;
         {.hydrosphere type}
      OOS_hydrotp: TFCEduHydrospheres;
         {.hydrosphere area}
      OOS_hydroArea: extended;
         {.regions}
      OOS_regions: array of TFCRduOObRegion;
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
      OO_inOrbitList: array[0..FCDUorbits] of TFCRduSpaceUnitInOrbit;
         {NOT LOADED DATA - index of the first satellite object}
      OO_sat1stOb: integer;
      OO_satList: array of TFCRorbObjSat;
      {.colonies settled on it [faction#]=owned colony id db #, 0= player}
      OO_colonies: array [0..1] of integer;
         {kind of orbital object}
      OO_type: TFCEduOrbitalObjectTypes;
      {.environment type}
      OO_envTp: TFCEduEnvironmentTypes;
         {distance from it's star in AU}
      OO_distFrmStar: extended;
         {orbit eccentricity in #.### format}
      OO_ecc: extended;
         {orbital zone type}
      OO_orbZone: TFCEduHabitableZones;
         {revolution period, in standard days, around it's star}
      OO_revol: integer;
         {starting day for revolution period}
      OO_revolInit: integer;
         {NOT LOADED DATA - value used for 3d display}
      OO_angle1stDay: extended;
         {diameter in km RTO-1}
      OO_diam: extended;
         {density in kg/m3}
      OO_dens: extended;
         {mass in Earth mass equivalent RTO-6}
      OO_mass: extended;
         {gravity in gees RTO-3}
      OO_grav: extended;
         {gravity sphere of influence radius  in km RTO-1}
      OO_gravSphRad: extended;
         {escape velocity in km/s RTO-2}
      OO_escVel: extended;
         {rotation period, around it's own axis, in hours RTO-2}
      OO_rotPer: extended;
         {inclination axis}
      OO_inclAx: extended;
         {magnetic field in gauss}
      OO_magFld: extended;
         {body albedo RTO-2}
      OO_albedo: extended;
         {atmosphere pressure in mbars, 1013 eq 1 atm eq 101.3kpa}
      OO_atmPress: extended;
         {cloud cover in %}
      OO_cloudsCov: extended;
         {atmosphere detailed composition}
      OO_atmosph: TFCRduAtmosphericComposition;
         {.orbital periods list, 2 intermediate 1 closest (summer) 1 farest (winter)}
      OO_orbPeriod: array[0..4] of TFCRduSeason;
         {.hydrosphere type}
      OO_hydrotp: TFCEduHydrospheres;
         {.hydrosphere area}
      OO_hydroArea: extended;
         {.regions}
      OO_regions: array of TFCRduOObRegion;
   end;
   {.star data structure, child of TFCRstarSys}
   type TFCRstar = record
      {db token id}
      SDB_token: string[20];
      {class, like G2, K, PSR...}
      SDB_class: TFCEduStarClasses;
      {temperature in degree Kelvin}
      SDB_temp: Integer;
      {mass, relative to Sun}
      SDB_mass: extended;
      {diameter, relative to Sun}
      SDB_diam: extended;
      {luminosity, relative to Sun}
      SDB_lum: extended;
      {orbital object sub-datastructure}
      SDB_obobj: array of TFCRduOobj;
      {.companion star - mean separation}
      SDB_meanSep: extended;
      {.companion star - minimal approach distance}
      SDB_minApD: extended;
      {.companion star - eccentricity}
      SDB_ecc: extended;
      {.companion star 2 - orbit type}
      SDB_comp2Orb: TFCEduCompanion2OrbitTypes;
   end;
   {.unified star systems datastructure}
   {:DEV NOTES : update universe.xml + FCMdFiles_DBstarSys_Process.}
   type TFCRstarSys = record
      {.star system db token id}
      SS_token: string[20];
      {.star system location on X axis, the unit is in AU and relative to Sol}
      SS_gLocX: extended;
      SS_gLocY: extended;                   {star system location on Y axis, the unit is in AU
                                          and relative to Sol}
      SS_gLocZ: extended;                   {star system location on Z axis, the unit is in AU
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
//
////=============================================END OF OLD CODE==================================

implementation

//uses

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================


end.
