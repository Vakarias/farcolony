{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: biosphere - silicon-based unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2013, Jean-Francois Baconnet

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
unit farc_fug_biospheresilicon;

interface

uses
   Math;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   process and test the silicon-based prebiotics evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbS_PrebioticsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

implementation

uses
   farc_common_func
   ,farc_data_univ
   ,farc_fug_biosphere
   ,farc_fug_biospherefunctions
   ,farc_fug_data
   ,farc_fug_stars
   ,farc_univ_func;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   FCVfbsRootSilicon: integer;

   FCVfbsVigorCalc: integer;

   FCVfbsStarAge: extended;

   FCVfbsTectonicActivity: TFCEduTectonicActivity;

//==END PRIVATE VAR=========================================================================

const
   FCCfbsStagePenalty=10;

//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfbS_PrebioticsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the silicon-based prebiotics evolution stage.
    Additions:
}
   var
      TestVal: integer;

      Albedo
      ,CloudsCover
      ,DistanceFromStar
      ,fCalc1: extended;

      StageFailed: boolean;

      gasH2
      ,gasN2
      ,gasNe
      ,gasSO2: TFCEduAtmosphericGasStatus;

      ObjectType: TFCEduOrbitalObjectTypes;
begin
   Albedo:=0;
   CloudsCover:=0;
   DistanceFromStar:=0;
   fCalc1:=0;

   gasH2:=agsNotPresent;
   gasN2:=agsNotPresent;
   gasNe:=agsNotPresent;
   gasSO2:=agsNotPresent;

   FCVfbsTectonicActivity:=taNull;

   if Satellite <= 0 then
   begin
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
      DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      FCVfbsTectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity;
      gasH2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2;
      gasNe:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNe;
      gasSO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2;
   end
   else begin
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_type;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover;
      DistanceFromStar:=FCFuF_Satellite_GetDistanceFromStar(
         0
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      FCVfbsTectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity;
      gasH2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2;
      gasNe:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNe;
      gasSO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2;
   end;
   StageFailed:=false;
   FCVfbsVigorCalc:=0;
   FCVfbsRootSilicon:=0;
   FCVfbsStarAge:=FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
   {.base modifier}
   {.icy planet influence}
   if ( ObjectType = ootPlanet_Icy )
      or ( ObjectType = ootSatellite_Planet_Icy )
   then FCVfbsVigorCalc:=30
   else FCVfbsVigorCalc:=60;
   {.atmosphere influences}
   case gasH2 of
      agsNotPresent: FCVfbsVigorCalc:=FCVfbsVigorCalc - 5;

      agsTrace: FCVfbsVigorCalc:=FCVfbsVigorCalc - 5;

      agsSecondary: FCVfbsVigorCalc:=FCVfbsVigorCalc + 10;

      agsPrimary: FCVfbsVigorCalc:=FCVfbsVigorCalc + 30;
   end;
   case gasN2 of
      agsNotPresent: FCVfbsVigorCalc:=FCVfbsVigorCalc - 5;

      agsTrace: FCVfbsVigorCalc:=FCVfbsVigorCalc - 5;

      agsSecondary: FCVfbsVigorCalc:=FCVfbsVigorCalc + 5;

      agsPrimary: FCVfbsVigorCalc:=FCVfbsVigorCalc + 12;
   end;
   case gasNe of
      agsSecondary: FCVfbsVigorCalc:=FCVfbsVigorCalc + 5;

      agsPrimary: FCVfbsVigorCalc:=FCVfbsVigorCalc + 15;
   end;
   case gasSO2 of
      agsNotPresent: FCVfbsVigorCalc:=FCVfbsVigorCalc - 15;

      agsTrace: FCVfbsVigorCalc:=FCVfbsVigorCalc - 15;

      agsSecondary: FCVfbsVigorCalc:=FCVfbsVigorCalc + 15;

      agsPrimary: FCVfbsVigorCalc:=FCVfbsVigorCalc + 40;
   end;
   {.tectonic activity influence}
   case FCVfbsTectonicActivity of
      taDead: FCVfbsVigorCalc:=FCVfbsVigorCalc -20;

      taHotSpot: FCVfbsVigorCalc:=FCVfbsVigorCalc + 10;

      taPlastic: FCVfbsVigorCalc:=FCVfbsVigorCalc + 20;

      taPlateTectonic: FCVfbsVigorCalc:=FCVfbsVigorCalc + 30;

      taPlateletTectonic: FCVfbsVigorCalc:=FCVfbsVigorCalc + 40;
   end;
   {.star luminosity influence}
   fCalc1:=FCFfbF_StarLuminosityFactor_Calculate(
      DistanceFromStar
      ,FCDduStarSystem[0].SS_stars[Star].S_luminosity
      ,Albedo
      ,CloudsCover
      );
   FCVfbsRootSilicon:=round( power( fCalc1, 0.333) );
   if fCalc1 <= 1912
   then begin
      FCVfbsVigorCalc:=FCVfbsVigorCalc + FCFfbF_StarLuminosityVigorMod_Calculate( fCalc1 );
      if FCVfbsVigorCalc < 1 then
      begin
         StageFailed:=true;
         FCMfB_FossilPresence_Test(
            Star
            ,OrbitalObject
            ,FCVfbsStarAge
            ,Satellite
            );
      end;
   end
   else begin
      StageFailed:=true;
      FCMfB_FossilPresence_Test(
         Star
         ,OrbitalObject
         ,FCVfbsStarAge
         ,Satellite
         );
   end;
   {.final test}
   if not StageFailed then
   begin
      TestVal:=FCFcF_Random_DoInteger( 99 ) + 1;
      if TestVal <= FCVfbsVigorCalc then
      begin
         if Satellite <= 0 then
         begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSilicon_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsVigorCalc;
         end
         else begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSilicon_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsVigorCalc;
//            FCMfbS_MicroOrganismStage_Test(
         end;
      end
      else FCMfB_FossilPresence_Test(
         Star
         ,OrbitalObject
         ,FCVfbsStarAge
         ,Satellite
         );
   end
   else FCMfB_FossilPresence_Test(
      Star
      ,OrbitalObject
      ,FCVfbsStarAge
      ,Satellite
      );
end;

end.
