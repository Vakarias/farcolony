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
///   process and test the carbon-based micro-organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbC_MicroOrganismStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

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
   ,farc_fug_atmosphere
   ,farc_fug_biosphere
   ,farc_fug_biospherefunctions
   ,farc_fug_data
   ,farc_fug_stars
   ,farc_univ_func;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   FCVfbcHydroArea: integer;

   FCVfbcHydroType: TFCEduHydrospheres;

   FCVfbcRootCarbon: integer;

   FCVfbcStarAge: extended;

   FCVfbcTectonicActivity: TFCEduTectonicActivity;

   FCVfbcVigorCalc: integer;

   gasCO2
   ,gasH2O
   ,gasN2: TFCEduAtmosphericGasStatus;

//==END PRIVATE VAR=========================================================================

const
   FCCfbcStagePenalty=5;

   FCCfbcStagePenalty_SubSurface=10;

//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfbC_MicroOrganismStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the carbon-based micro-organisms evolution stage.
    Additions:
}
   var
      BcarbonChain
      ,Bco2
      ,Bh2o
      ,Bh2s
      ,Bn2
      ,iCalc1
      ,PrimaryGasPart: integer;

      fCalc1
      ,fCalc2
      ,fCalc3: extended;

      CarbonDNA
      ,CarbonMembranes
      ,CarbonProteins
      ,isRotationPeriodNull
      ,StageFailed: boolean;

      gasH2S: TFCEduAtmosphericGasStatus;
begin
   BcarbonChain:=0;
   Bco2:=0;
   Bh2o:=0;
   Bh2s:=0;
   Bn2:=0;
   iCalc1:=0;
   PrimaryGasPart:=0;

   fCalc1:=0;
   fCalc2:=0;
   fCalc3:=0;

   CarbonDNA:=false;
   CarbonMembranes:=false;
   CarbonProteins:=false;
   isRotationPeriodNull:=false;
   StageFailed:=false;

   gasH2S:=agsNotPresent;

   if Satellite <= 0 then
   begin
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod = 0
      then isRotationPeriodNull:=true;
      PrimaryGasPart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_primaryGasVolumePerc;
      gasH2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S;
   end
   else begin
      fCalc1:=FCFuF_Satellite_GetRotationPeriod(
         0
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      if fCalc1 = 0
      then isRotationPeriodNull:=true;
      PrimaryGasPart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_primaryGasVolumePerc;
      gasH2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S;
   end;

   if FCVfbcStarAge <= 0.8
   then StageFailed:=true else
   begin
      if FCVfbcHydroType = hWaterLiquid then
      begin
         {.star influence}
         iCalc1:=FCFfbF_StarModifier_Phase1( FCDduStarSystem[0].SS_stars[Star].S_class );
         FCVfbcVigorCalc:=FCVfbcVigorCalc + ( 40 - iCalc1 );
         {.rotation period influence}
         if isRotationPeriodNull
         then FCVfbcVigorCalc:=FCVfbcVigorCalc - 20;
         {.molecular building blocks phase}
         {..by tectonic activity}
         case FCVfbcTectonicActivity of
            taHotSpot: BcarbonChain:=BcarbonChain + 1;

            taPlastic: BcarbonChain:=BcarbonChain + 2;

            taPlateTectonic: BcarbonChain:=BcarbonChain + 3;

            taPlateletTectonic: BcarbonChain:=BcarbonChain + 5;
         end;
         {..by hydrosphere}
         fCalc1:=power( FCVfbcHydroArea, 0.333);
         Bh2o:=Bh2o + round( fCalc1 );
         {..by gasses}
         iCalc1:=FCFfA_PrimaryGasses_GetTotalNumber(
            Star
            ,OrbitalObject
            ,Satellite
            );
         fCalc2:=power( 100 - PrimaryGasPart, 0.333 );
         fCalc3:=power( PrimaryGasPart / iCalc1, 0.333 );
         if gasCO2 = agsSecondary
         then fCalc1:=fCalc2
         else if gasCO2 = agsPrimary
         then fCalc1:=fCalc3
         else fCalc1:=0;
         Bco2:=Bco2 + round( fCalc1 );

         if gasH2O = agsSecondary
         then fCalc1:=fCalc2
         else if gasH2O = agsPrimary
         then fCalc1:=fCalc3
         else fCalc1:=0;
         Bh2o:=Bh2o + round( fCalc1 );

         if gasH2S = agsSecondary
         then fCalc1:=fCalc2
         else if gasH2S = agsPrimary
         then fCalc1:=fCalc3
         else fCalc1:=0;
         Bh2s:=Bh2s + round( fCalc1 );

         if gasN2 = agsSecondary
         then fCalc1:=fCalc2
         else if gasN2 = agsPrimary
         then fCalc1:=fCalc3
         else fCalc1:=0;
         Bn2:=Bn2 + round( fCalc1 );
      end //==END== if FCVfbcHydroType = hWaterLiquid ==//
      else if FCVfbcHydroType in [hWaterIceSheet..hWaterIceCrust] then
      begin
      end;
   end; //==END== else of: if FCVfbcStarAge <= 0.8 ==//
end;

procedure FCMfbC_PrebioticsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the carbon-based prebiotics evolution stage.
    Additions:
}
   var
      TestVal: integer;

      Albedo
      ,CloudsCover
      ,DistanceFromStar
      ,fCalc1: extended;

      StageFailed: boolean;

begin
   FCVfbcHydroArea:=0;
   TestVal:=0;

   Albedo:=0;
   CloudsCover:=0;
   DistanceFromStar:=0;
   fCalc1:=0;

   FCVfbcHydroType:=hNoHydro;

   gasCO2:=agsNotPresent;
   gasH2O:=agsNotPresent;
   gasN2:=agsNotPresent;

   FCVfbcTectonicActivity:=taNull;

   if Satellite <= 0 then
   begin
      FCVfbcHydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      FCVfbcHydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
      DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      FCVfbcTectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity;
      gasCO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2;
      gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2;
   end
   else begin
      FCVfbcHydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      FCVfbcHydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover;
      DistanceFromStar:=FCFuF_Satellite_GetDistanceFromStar(
         0
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      FCVfbcTectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity;
      gasCO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2;
      gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2;
   end;
   StageFailed:=false;
   FCVfbcVigorCalc:=0;
   FCVfbcRootCarbon:=0;
   FCVfbcStarAge:=FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
   if FCVfbcHydroType = hWaterLiquid then
   begin
      {.surface temperature influence}
      FCVfbcVigorCalc:=FCVfbcVigorCalc + FCFfbF_SurfaceTemperaturesModifier_Calculate(
         373.85
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      {.hydrosphere influence}
      FCVfbcVigorCalc:=FCVfbcVigorCalc + FCFfbF_HydrosphereModifier_Calculate( FCVfbcHydroArea );
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
      case FCVfbcTectonicActivity of
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
               ,FCVfbcStarAge
               ,Satellite
               );
         end;
      end
      else begin
         StageFailed:=true;
         FCMfB_FossilPresence_Test(
            Star
            ,OrbitalObject
            ,FCVfbcStarAge
            ,Satellite
            );
      end;
   end
   else if FCVfbcHydroType in [hWaterIceSheet..hWaterIceCrust] then
   begin
      {.base modifier}
      FCVfbcVigorCalc:=FCVfbcVigorCalc + 50;
      {.hydrosphere influence}
      if FCVfbcHydroType = hWaterIceSheet
      then FCVfbcVigorCalc:=FCVfbcVigorCalc + FCFfbF_HydrosphereModifier_Calculate( round( FCVfbcHydroArea * 1.33 ) )
      else FCVfbcVigorCalc:=FCVfbcVigorCalc + FCFfbF_HydrosphereModifier_Calculate( FCVfbcHydroArea );
      {.tectonic activity influence}
      case FCVfbcTectonicActivity of
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
            ,FCVfbcStarAge
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
         ,FCVfbcStarAge
         ,Satellite
         );
   end
   else FCMfB_FossilPresence_Test(
      Star
      ,OrbitalObject
      ,FCVfbcStarAge
      ,Satellite
      );
end;

end.
