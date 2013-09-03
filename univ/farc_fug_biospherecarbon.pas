{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: Biosphere - carbon-based unit

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
unit farc_fug_biospherecarbon;

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
///   process and test the carbon-based prebiotics evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbC_PrebioticsStage_Test(
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
   FCVfbcRootCarbon: integer;

   FCVfbcVigorCalc: integer;

//==END PRIVATE VAR=========================================================================

const
   FCCfbcStagePenalty=5;

   FCCfbcStagePenalty_SubSurface=10;

//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfbC_PrebioticsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the carbon-based prebiotics evolution stage.
    Additions:
}
   var
      HydroArea
      ,TestVal: integer;

      Albedo
      ,CloudsCover
      ,DistanceFromStar
      ,fCalc1: extended;

      StageFailed: boolean;

      HydroType: TFCEduHydrospheres;

      gasCO2
      ,gasH2O
      ,gasN2: TFCEduAtmosphericGasStatus;

      TectonicActivity: TFCEduTectonicActivity;
begin
   HydroArea:=0;
   TestVal:=0;

   Albedo:=0;
   CloudsCover:=0;
   DistanceFromStar:=0;
   fCalc1:=0;

   HydroType:=hNoHydro;

   gasCO2:=agsNotPresent;
   gasH2O:=agsNotPresent;
   gasN2:=agsNotPresent;

   TectonicActivity:=taNull;

   if Satellite <= 0 then
   begin
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
      DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      TectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity;
      gasCO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2;
      gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2;
   end
   else begin
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover;
      DistanceFromStar:=FCFuF_Satellite_GetDistanceFromStar(
         0
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      TectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity;
      gasCO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2;
      gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2;
   end;
   StageFailed:=false;
   FCVfbcVigorCalc:=0;
   FCVfbcRootCarbon:=0;
   if HydroType = hWaterLiquid then
   begin
      {.surface temperature influence}
      FCVfbcVigorCalc:=FCVfbcVigorCalc + FCFfbF_SurfaceTemperaturesModifier_Calculate(
         373.85
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      {.hydrosphere influence}
      FCVfbcVigorCalc:=FCVfbcVigorCalc + FCFfbF_HydrosphereModifier_Calculate( HydroArea );
      {.atmosphere influences}
      case gasCO2 of
         agsNotPresent: FCVfbcVigorCalc:=FCVfbcVigorCalc - 15;

         agsTrace: FCVfbcVigorCalc:=FCVfbcVigorCalc - 7;

         agsSecondary: FCVfbcVigorCalc:=FCVfbcVigorCalc + 15;

         agsPrimary: FCVfbcVigorCalc:=FCVfbcVigorCalc + 30;
      end;
      case gasH2O of
         agsNotPresent: FCVfbcVigorCalc:=FCVfbcVigorCalc - 20;

         agsSecondary: FCVfbcVigorCalc:=FCVfbcVigorCalc + 20;

         agsPrimary: FCVfbcVigorCalc:=FCVfbcVigorCalc + 40;
      end;
      case gasN2 of
         agsNotPresent: FCVfbcVigorCalc:=FCVfbcVigorCalc - 30;

         agsTrace: FCVfbcVigorCalc:=FCVfbcVigorCalc - 15;

         agsSecondary: FCVfbcVigorCalc:=FCVfbcVigorCalc + 15;

         agsPrimary: FCVfbcVigorCalc:=FCVfbcVigorCalc + 30;
      end;
      {.tectonic activity influence}
      case TectonicActivity of
         taDead: FCVfbcVigorCalc:=FCVfbcVigorCalc -20;

         taHotSpot: FCVfbcVigorCalc:=FCVfbcVigorCalc + 5;

         taPlastic: FCVfbcVigorCalc:=FCVfbcVigorCalc + 10;

         taPlateTectonic: FCVfbcVigorCalc:=FCVfbcVigorCalc + 20;

         taPlateletTectonic: FCVfbcVigorCalc:=FCVfbcVigorCalc + 10;
      end;
      {.star luminosity influence}
      fCalc1:=FCFfbF_StarLuminosityFactor_Calculate(
         DistanceFromStar
         ,FCDduStarSystem[0].SS_stars[Star].S_luminosity
         ,Albedo
         ,CloudsCover
         );
      FCVfbcRootCarbon:=round( power( fCalc1, 0.333) );
      if fCalc1 <= 1912
      then begin
         FCVfbcVigorCalc:=FCVfbcVigorCalc + FCFfbF_StarLuminosityVigorMod_Calculate( fCalc1 );
         if FCVfbcVigorCalc < 1 then
         begin
            StageFailed:=true;
            FCMfB_FossilPresence_Test(
               Star
               ,OrbitalObject
               ,FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity )
               ,Satellite
               );
         end;
      end
      else begin
         StageFailed:=true;
         FCMfB_FossilPresence_Test(
            Star
            ,OrbitalObject
            ,FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity )
            ,Satellite
            );
      end;
   end
   else if HydroType in [hWaterIceSheet..hWaterIceCrust] then
   begin
      {.base modifier}
      FCVfbcVigorCalc:=FCVfbcVigorCalc + 50;
      {.hydrosphere influence}
      if HydroType = hWaterIceSheet
      then FCVfbcVigorCalc:=FCVfbcVigorCalc + FCFfbF_HydrosphereModifier_Calculate( round( HydroArea * 1.33 ) )
      else FCVfbcVigorCalc:=FCVfbcVigorCalc + FCFfbF_HydrosphereModifier_Calculate( HydroArea );
      {.tectonic activity influence}
      case TectonicActivity of
         taDead: FCVfbcVigorCalc:=FCVfbcVigorCalc - 40;

         taHotSpot: FCVfbcVigorCalc:=FCVfbcVigorCalc + 10;

         taPlastic: FCVfbcVigorCalc:=FCVfbcVigorCalc + 20;

         taPlateTectonic: FCVfbcVigorCalc:=FCVfbcVigorCalc + 25;

         taPlateletTectonic: FCVfbcVigorCalc:=FCVfbcVigorCalc + 30;
      end;
      if FCVfbcVigorCalc < 1 then
      begin
         StageFailed:=true;
         FCMfB_FossilPresence_Test(
            Star
            ,OrbitalObject
            ,FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity )
            ,Satellite
            );
      end;
   end;
   {.final test}
   if not StageFailed then
   begin
      TestVal:=FCFcF_Random_DoInteger( 99 ) + 1;
      if TestVal <= FCVfbcVigorCalc then
      begin
         if Satellite <= 0 then
         begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blCarbon_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbcVigorCalc;
         end
         else begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blCarbon_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbcVigorCalc;
//            FCMfbC_MicroOrganismStage_Test(
         end;
      end
      else FCMfB_FossilPresence_Test(
         Star
         ,OrbitalObject
         ,FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity )
         ,Satellite
         );
   end
   else FCMfB_FossilPresence_Test(
      Star
      ,OrbitalObject
      ,FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity )
      ,Satellite
      );
end;

end.
