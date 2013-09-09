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
///   process and test the carbon-based level I organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbC_Level1OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the carbon-based level II organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbC_Level2OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

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
   FCVfbcGravity: extended;

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

procedure FCMfbC_Level1OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the carbon-based level I organisms evolution stage.
    Additions:
}
   var
      iCalc1: integer;

      fCalc1: extended;

      StageFailed: boolean;

begin
   iCalc1:=0;

   fCalc1:=0;
   FCVfbcGravity:=0;

   StageFailed:=false;

   if Satellite <= 0 then
   begin
      FCVfbcGravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity;
   end
   else begin
      FCVfbcGravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravity;
   end;

   if FCVfbcStarAge <= 3
   then StageFailed:=true
   else begin
      if FCVfbcHydroType = hWaterLiquid then
      begin
         {.evolution stage penalty}
         FCVfbcVigorCalc:=FCVfbcVigorCalc - FCCfbcStagePenalty;
         {.star influence}
         iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
         FCVfbcVigorCalc:=FCVfbcVigorCalc + ( 40 - iCalc1 );
         {.gravity modifier}
         fCalc1:=( 1 - sqr( FCVfbcGravity ) ) * 5;
         FCVfbcVigorCalc:=FCVfbcVigorCalc + round( fCalc1 );
         FCVfbcGravity:=fCalc1;
         if FCVfbcVigorCalc < 1
         then StageFailed:=true;
      end //==END== if FCVfbcHydroType = hWaterLiquid ==//
      else if FCVfbcHydroType in [hWaterIceSheet..hWaterIceCrust] then
      begin
         {.evolution stage penalty}
         FCVfbcVigorCalc:=FCVfbcVigorCalc - FCCfbcStagePenalty_SubSurface;
         if FCVfbcVigorCalc < 1
         then StageFailed:=true
      end;
   end; //==END== else of: if FCVfbcStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( 50 <= FCVfbcVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blCarbon_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbcVigorCalc;
         if FCVfbcHydroType = hWaterLiquid then
         begin
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceO2 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceO2:=agsSecondary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2 > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2:=agsTrace;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2 < agsPrimary
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2:=agsPrimary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO:=agsTrace;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceAr > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceAr:=agsTrace;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S:=agsTrace;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2 > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2:=agsTrace;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceO3 > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceO3:=agsTrace;
         end;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blCarbon_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbcVigorCalc;
         if FCVfbcHydroType = hWaterLiquid then
         begin
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceO2 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceO2:=agsSecondary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2 > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2:=agsTrace;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2 < agsPrimary
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2:=agsPrimary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO:=agsTrace;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceAr > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceAr:=agsTrace;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S:=agsTrace;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2 > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2:=agsTrace;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceO3 > agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceO3:=agsTrace;
         end;
      end;
      FCMfbC_Level2OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

procedure FCMfbC_Level2OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the carbon-based level II organisms evolution stage.
    Additions:
}
   var
      iCalc1: integer;

      StageFailed: boolean;

begin
   iCalc1:=0;

   StageFailed:=false;

   if FCVfbcStarAge <= 4
   then StageFailed:=true
   else begin
      if FCVfbcHydroType = hWaterLiquid then
      begin
         {.evolution stage penalty}
         FCVfbcVigorCalc:=FCVfbcVigorCalc - ( FCCfbcStagePenalty * 2 );
         {.star influence}
         iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
         FCVfbcVigorCalc:=FCVfbcVigorCalc + ( 40 - iCalc1 );
         {.gravity modifier}
         FCVfbcVigorCalc:=FCVfbcVigorCalc + round( FCVfbcGravity );
         if FCVfbcVigorCalc < 1
         then StageFailed:=true;
      end //==END== if FCVfbcHydroType = hWaterLiquid ==//
      else if FCVfbcHydroType in [hWaterIceSheet..hWaterIceCrust] then
      begin
         {.evolution stage penalty}
         FCVfbcVigorCalc:=FCVfbcVigorCalc - ( FCCfbcStagePenalty_SubSurface * 2 );
         if FCVfbcVigorCalc < 1
         then StageFailed:=true
      end;
   end; //==END== else of: if FCVfbcStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( 50 <= FCVfbcVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blCarbon_Level2Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbcVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blCarbon_Level2Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbcVigorCalc;
      end;
   end;
end;

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
      ,Bsugar
      ,iCalc1
      ,PrimaryGasPart
      ,TestVal: integer;

      fCalc1
      ,fCalc2
      ,fCalc3: extended;

      CarbonDNA
      ,CarbonMembranes
      ,CarbonProteins
      ,isRotationPeriodNull
      ,Stagefailed: boolean;

      gasH2S: TFCEduAtmosphericGasStatus;
begin
   BcarbonChain:=0;
   Bco2:=0;
   Bh2o:=0;
   Bh2s:=0;
   Bn2:=0;
   Bsugar:=0;
   iCalc1:=0;
   PrimaryGasPart:=0;
   TestVal:=0;

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
         if FCVfbcVigorCalc < 1
         then StageFailed:=true
         else begin
            {.molecular building blocks phase}
            {..by tectonic activity}
            case FCVfbcTectonicActivity of
               taHotSpot: BcarbonChain:=1;

               taPlastic: BcarbonChain:=2;

               taPlateTectonic: BcarbonChain:=3;

               taPlateletTectonic: BcarbonChain:=5;
            end;
            {..by hydrosphere}
            fCalc1:=power( FCVfbcHydroArea, 0.333);
            Bh2o:=round( fCalc1 );
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
            Bco2:=round( fCalc1 );

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
            Bh2s:=round( fCalc1 );

            if gasN2 = agsSecondary
            then fCalc1:=fCalc2
            else if gasN2 = agsPrimary
            then fCalc1:=fCalc3
            else fCalc1:=0;
            Bn2:=round( fCalc1 );
            {..by associations}
            fCalc2:=6 * Bco2;
            fCalc3:=12 * Bh2s;
            fCalc1:=( fCalc2 + fCalc3 + FCVfbcRootCarbon ) / 7;
            BcarbonChain:=BcarbonChain + round( fCalc1 );
            fCalc1:=( fCalc2 + fCalc3 + FCVfbcRootCarbon ) / 13;
            Bh2o:=Bh2o + round( fCalc1 );
            fCalc1:=( fCalc2 + fCalc3 + FCVfbcRootCarbon ) / 18;
            Bsugar:=round( fCalc1 );
            fCalc1:=( fCalc2 + ( 6 * Bh2o ) + FCVfbcRootCarbon ) / 12;
            Bsugar:=Bsugar + round( fCalc1 );
            fCalc1:=( Bsugar + ( 6 * Bh2o ) + ( 4 * Bn2 ) ) / 8;
            Bco2:=Bco2 + round( fCalc1 );
            {..results}
            TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bco2 - BcarbonChain;
            if TestVal <= FCVfbcVigorCalc
            then CarbonMembranes:=true;
            TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bco2 - BcarbonChain - Bsugar;
            if TestVal <= FCVfbcVigorCalc
            then CarbonDNA:=true;
            TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bco2 - Bh2s - BcarbonChain;
            if TestVal <= FCVfbcVigorCalc
            then CarbonProteins:=true;
         end;
      end //==END== if FCVfbcHydroType = hWaterLiquid ==//
      else if FCVfbcHydroType in [hWaterIceSheet..hWaterIceCrust] then
      begin
         {.molecular building blocks phase}
         {..by tectonic activity}
         case FCVfbcTectonicActivity of
            taDead:
            begin
               BcarbonChain:=0;
               Bh2o:=2;
               Bh2s:=0;
            end;

            taHotSpot:
            begin
               BcarbonChain:=1;
               Bh2o:=3;
               Bh2s:=1;
            end;

            taPlastic:
            begin
               BcarbonChain:=2;
               Bh2o:=5;
               Bh2s:=2;
            end;

            taPlateTectonic:
            begin
               BcarbonChain:=3;
               Bh2o:=8;
               Bh2s:=4;
            end;

            taPlateletTectonic:
            begin
               BcarbonChain:=5;
               Bh2o:=13;
               Bh2s:=7;
            end;
         end;
         {..results}
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - BcarbonChain;
         if TestVal <= FCVfbcVigorCalc
         then CarbonMembranes:=true;
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bh2o - BcarbonChain;
         if TestVal <= FCVfbcVigorCalc
         then CarbonDNA:=true;
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bh2s - BcarbonChain;
         if TestVal <= FCVfbcVigorCalc
         then CarbonProteins:=true;
      end;
   end; //==END== else of: if FCVfbcStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( CarbonMembranes )
      and ( CarbonDNA )
      and ( CarbonProteins ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blCarbon_MicroOrganisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbcVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blCarbon_MicroOrganisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbcVigorCalc;
      end;
      FCMfbC_Level1OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
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
      FCVfbcVigorCalc:=FCFfbF_SurfaceTemperaturesModifier_Calculate(
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
      FCVfbcVigorCalc:=50;
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
   if ( not StageFailed )
      and ( 50 <= FCVfbcVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blCarbon_Prebiotics;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbcVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blCarbon_Prebiotics;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbcVigorCalc;
      end;
      FCMfbC_MicroOrganismStage_Test(
         Star
         ,OrbitalObject
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
