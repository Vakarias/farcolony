{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: biosphere - methane-based unit

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
unit farc_fug_biospheremethane;

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
///   process and test the methane-based level I organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbM_Level1OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the methane-based level II organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbM_Level2OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the methane-based level III organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbM_Level3OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the methane-based micro-organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbM_MicroOrganismStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the methane-based prebiotics evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbM_PrebioticsStage_Test(
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
   FCVfbmHydroArea: integer;

   FCVfbmHydroType: TFCEduHydrospheres;

   FCVfbmRootMethane: integer;

   FCVfbmStarAge: extended;

   FCVfbmTectonicActivity: TFCEduTectonicActivity;

   FCVfbmVigorCalc: integer;

   gasCH4
   ,gasN2: TFCEduAtmosphericGasStatus;

//==END PRIVATE VAR=========================================================================

const
   FCCfbmStagePenalty=30;

   FCCfbmStagePenalty_SubSurface=20;

//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfbM_Level1OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the methane-based level I organisms evolution stage.
    Additions:
}
   var
      iCalc1: integer;

      StageFailed: boolean;

begin
   StageFailed:=false;

   if FCVfbmStarAge <= 1
   then StageFailed:=true
   else begin
      if FCVfbmHydroType = hMethaneLiquid then
      begin
         {.evolution stage penalty}
         FCVfbmVigorCalc:=FCVfbmVigorCalc - FCCfbmStagePenalty;
         {.star influence}
         iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
         FCVfbmVigorCalc:=FCVfbmVigorCalc + ( 40 - iCalc1 );
         if FCVfbmVigorCalc < 1
         then StageFailed:=true;
      end //==END== if FCVfbcHydroType = hWaterAmmoniaLiquid ==//
      else if FCVfbmHydroType in [hMethaneIceSheet..hMethaneIceCrust] then
      begin
         {.evolution stage penalty}
         FCVfbmVigorCalc:=FCVfbmVigorCalc - FCCfbmStagePenalty_SubSurface;
         if FCVfbmVigorCalc < 1
         then StageFailed:=true
      end;
   end; //==END== else of: if FCVfbaStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( 70 <= FCVfbmVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blMethane_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbmVigorCalc;
         if FCVfbmHydroType = hMethaneLiquid then
         begin
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2:=agsSecondary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4:=agsSecondary
            else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4 = agsSecondary
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4:=agsPrimary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2:=agsSecondary
            else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2 = agsSecondary
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2:=agsPrimary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3:=agsSecondary;
            FCMfbM_Level2OrganismsStage_Test(
               Star
               ,OrbitalObject
               ,Satellite
               );
         end;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blMethane_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbmVigorCalc;
         if FCVfbmHydroType = hWaterAmmoniaLiquid then
         begin
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2:=agsSecondary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4:=agsSecondary
            else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4 = agsSecondary
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4:=agsPrimary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2:=agsSecondary
            else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2 = agsSecondary
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2:=agsPrimary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3:=agsSecondary;
            FCMfbM_Level2OrganismsStage_Test(
               Star
               ,OrbitalObject
               ,Satellite
               );
         end;
      end;
   end;
end;

procedure FCMfbM_Level2OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the methane-based level II organisms evolution stage.
    Additions:
}
   var
      iCalc1: integer;

      StageFailed: boolean;

begin
   iCalc1:=0;

   StageFailed:=false;

   if FCVfbmStarAge <= 2
   then StageFailed:=true
   else begin
      {.evolution stage penalty}
      FCVfbmVigorCalc:=FCVfbmVigorCalc - ( FCCfbmStagePenalty * 2 );
      {.star influence}
      iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
      FCVfbmVigorCalc:=FCVfbmVigorCalc + ( 40 - iCalc1 );
      if FCVfbmVigorCalc < 1
      then StageFailed:=true;
   end; //==END== else of: if FCVfbaStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( 70 <= FCVfbmVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blMethane_Level2Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbmVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blMethane_Level2Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbmVigorCalc;
      end;
      FCMfbM_Level3OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

procedure FCMfbM_Level3OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the methane-based level III organisms evolution stage.
    Additions:
}
   var
      iCalc1: integer;

      StageFailed: boolean;

begin
   iCalc1:=0;

   StageFailed:=false;

   if FCVfbmStarAge <= 5
   then StageFailed:=true
   else begin
      {.evolution stage penalty}
      FCVfbmVigorCalc:=FCVfbmVigorCalc - ( FCCfbmStagePenalty * 3 );
      {.star influence}
      iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
      FCVfbmVigorCalc:=FCVfbmVigorCalc + ( 40 - iCalc1 );
      if FCVfbmVigorCalc < 1
      then StageFailed:=true;
   end; //==END== else of: if FCVfbaStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( 70 <= FCVfbmVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blMethane_Level3Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbmVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blMethane_Level3Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbmVigorCalc;
      end;
   end;
end;

procedure FCMfbM_MicroOrganismStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the methane-based micro-organisms evolution stage.
    Additions:
}
   var
      BmethChain
      ,Bch4
      ,Bh2
      ,Bh2s
      ,Bn2
      ,Bnh3
      ,Bsugar

      ,iCalc1
      ,PrimaryGasPart
      ,TestVal: integer;

      fCalc1
      ,fCalc2
      ,fCalc3: extended;

      MethDNA
      ,MethMembranes
      ,MethProteins
      ,isRotationPeriodNull
      ,Stagefailed: boolean;

      gasH2
      ,gasH2S
      ,gasNH3: TFCEduAtmosphericGasStatus;

begin
   BmethChain:=0;
   Bch4:=0;
   Bh2:=0;
   Bh2s:=0;
   Bn2:=0;
   Bnh3:=0;
   Bsugar:=0;
   iCalc1:=0;
   PrimaryGasPart:=0;
   TestVal:=0;

   fCalc1:=0;
   fCalc2:=0;
   fCalc3:=0;

   MethDNA:=false;
   MethMembranes:=false;
   MethProteins:=false;
   isRotationPeriodNull:=false;
   StageFailed:=false;

   gasH2:=agsNotPresent;
   gasH2S:=agsNotPresent;
   gasNH3:=agsNotPresent;

   if Satellite <= 0 then
   begin
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod = 0
      then isRotationPeriodNull:=true;
      PrimaryGasPart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_primaryGasVolumePerc;
      gasH2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2;
      gasH2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S;
      gasNH3:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3;
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
      gasH2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2;
      gasH2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S;
      gasNH3:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3;
   end;

   if FCVfbmStarAge <= 0.8
   then StageFailed:=true else
   begin
      if FCVfbmHydroType = hMethaneLiquid then
      begin
         {.star influence}
         iCalc1:=FCFfbF_StarModifier_Phase1( FCDduStarSystem[0].SS_stars[Star].S_class );
         FCVfbmVigorCalc:=FCVfbmVigorCalc + ( 40 - iCalc1 );
         {.rotation period influence}
         if isRotationPeriodNull
         then FCVfbmVigorCalc:=FCVfbmVigorCalc - 20;
         if FCVfbmVigorCalc < 1
         then StageFailed:=true
         else begin
            {.molecular building blocks phase}
            {..by tectonic activity}
            case FCVfbmTectonicActivity of
               taHotSpot: BmethChain:=2;

               taPlastic: BmethChain:=3;

               taPlateTectonic: BmethChain:=5;

               taPlateletTectonic: BmethChain:=6;
            end;
            {..by hydrosphere}
            fCalc1:=power( FCVfbmHydroArea, 0.333);
            Bch4:=round( fCalc1 );
            {..by gasses}
            iCalc1:=FCFfA_PrimaryGasses_GetTotalNumber(
               Star
               ,OrbitalObject
               ,Satellite
               );
            fCalc2:=power( 100 - PrimaryGasPart, 0.333 );
            fCalc3:=power( PrimaryGasPart / iCalc1, 0.333 );
            if gasCH4 = agsSecondary
            then fCalc1:=fCalc2
            else if gasCH4 = agsPrimary
            then fCalc1:=fCalc3
            else fCalc1:=0;
            Bch4:=Bch4 + round( fCalc1 );

            if gasH2 = agsSecondary
            then fCalc1:=fCalc2
            else if gasH2 = agsPrimary
            then fCalc1:=fCalc3
            else fCalc1:=0;
            Bh2:=round( fCalc1 );

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

            if gasNH3 = agsSecondary
            then fCalc1:=fCalc2
            else if gasNH3 = agsPrimary
            then fCalc1:=fCalc3
            else fCalc1:=0;
            Bnh3:=round( fCalc1 );
            {..by associations}
            fCalc2:=6 * Bch4;
            fCalc3:=6 * Bh2;
            fCalc1:=( fCalc2 + ( 12 * Bh2s ) + FCVfbmRootMethane ) / 7;
            BmethChain:=BmethChain + round( fCalc1 );
            fCalc1:=( fCalc2 + ( 12 * Bh2s ) + FCVfbmRootMethane ) / 18;
            Bsugar:=round( fCalc1 );
            fCalc1:=( fCalc2 + ( 12 * Bh2s ) + FCVfbmRootMethane ) / 13;
            Bh2:=Bh2 + round( fCalc1 );
            fCalc1:=( fCalc2 + fCalc3 + FCVfbmRootMethane ) / 6;
            Bsugar:=Bsugar + round( fCalc1 );
            fCalc1:=( fCalc2 + fCalc3 + FCVfbmRootMethane );
            Bn2:=Bn2 + round( fCalc1 );
            fCalc1:=( Bsugar + fCalc3 + ( 4 * Bn2 ) ) / 8;
            Bch4:=Bch4 + round( fCalc1 );
            fCalc1:=( Bsugar + fCalc3 + ( 4 * Bn2 ) ) / 6;
            Bnh3:=Bnh3 + round( fCalc1 );
            {..results}
            TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bch4 - BmethChain;
            if TestVal <= FCVfbmVigorCalc
            then MethMembranes:=true;
            TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bch4 - BmethChain - Bsugar;
            if TestVal <= FCVfbmVigorCalc
            then MethDNA:=true;
            TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bch4 - Bn2 - BmethChain;
            if TestVal <= FCVfbmVigorCalc
            then MethProteins:=true;
         end;
      end //==END== if FCVfbcHydroType = hWaterLiquid ==//
      else if FCVfbmHydroType in [hMethaneIceSheet..hMethaneIceCrust] then
      begin
         {.molecular building blocks phase}
         {..by tectonic activity}
         case FCVfbmTectonicActivity of
            taDead:
            begin
               BmethChain:=0;
               Bch4:=2;
               Bh2s:=0;
            end;

            taHotSpot:
            begin
               BmethChain:=2;
               Bch4:=3;
               Bh2s:=1;
            end;

            taPlastic:
            begin
               BmethChain:=3;
               Bch4:=5;
               Bh2s:=2;
            end;

            taPlateTectonic:
            begin
               BmethChain:=5;
               Bch4:=8;
               Bh2s:=4;
            end;

            taPlateletTectonic:
            begin
               BmethChain:=6;
               Bch4:=13;
               Bh2s:=7;
            end;
         end;
         {..results}
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - BmethChain;
         if TestVal <= FCVfbmVigorCalc
         then MethMembranes:=true;
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bch4 - BmethChain;
         if TestVal <= FCVfbmVigorCalc
         then MethDNA:=true;
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bh2s - BmethChain;
         if TestVal <= FCVfbmVigorCalc
         then MethProteins:=true;
      end;
   end; //==END== else of: if FCVfbcStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( MethMembranes )
      and ( MethDNA )
      and ( MethProteins ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blMethane_MicroOrganisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbmVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blMethane_MicroOrganisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbmVigorCalc;
      end;
      FCMfbM_Level1OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

procedure FCMfbM_PrebioticsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the methane-based prebiotics evolution stage.
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
   FCVfbmHydroArea:=0;
   TestVal:=0;

   Albedo:=0;
   CloudsCover:=0;
   DistanceFromStar:=0;
   fCalc1:=0;

   FCVfbmHydroType:=hNoHydro;

   gasCH4:=agsNotPresent;
   gasN2:=agsNotPresent;

   FCVfbmTectonicActivity:=taNull;

   if Satellite <= 0 then
   begin
      FCVfbmHydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      FCVfbmHydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
      DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      FCVfbmTectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity;
      gasCH4:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2;
   end
   else begin
      FCVfbmHydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      FCVfbmHydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover;
      DistanceFromStar:=FCFuF_Satellite_GetDistanceFromStar(
         0
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      FCVfbmTectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity;
      gasCH4:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2;
   end;
   StageFailed:=false;
   FCVfbmVigorCalc:=0;
   FCVfbmRootMethane:=0;
   FCVfbmStarAge:=FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
   if FCVfbmHydroType = hMethaneLiquid then
   begin
      {.surface temperature influence}
      FCVfbmVigorCalc:=FCVfbmVigorCalc + FCFfbF_SurfaceTemperaturesModifier_Calculate(
         143.075
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      {.hydrosphere influence}
      FCVfbmVigorCalc:=FCVfbmVigorCalc + FCFfbF_HydrosphereModifier_Calculate( FCVfbmHydroArea );
      {.atmosphere influences}
      case gasCH4 of
         agsNotPresent: FCVfbmVigorCalc:=FCVfbmVigorCalc + 5;

         agsTrace: FCVfbmVigorCalc:=FCVfbmVigorCalc + 5;

         agsSecondary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 10;

         agsPrimary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 15;
      end;
      case gasN2 of
         agsNotPresent: FCVfbmVigorCalc:=FCVfbmVigorCalc - 30;

         agsTrace: FCVfbmVigorCalc:=FCVfbmVigorCalc - 15;

         agsSecondary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 15;

         agsPrimary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 30;
      end;
      {.tectonic activity influence}
      case FCVfbmTectonicActivity of
         taDead: FCVfbmVigorCalc:=FCVfbmVigorCalc -20;

         taHotSpot: FCVfbmVigorCalc:=FCVfbmVigorCalc + 5;

         taPlastic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 10;

         taPlateTectonic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 20;

         taPlateletTectonic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 10;
      end;
      {.star luminosity influence}
      fCalc1:=FCFfbF_StarLuminosityFactor_Calculate(
         DistanceFromStar
         ,FCDduStarSystem[0].SS_stars[Star].S_luminosity
         ,Albedo
         ,CloudsCover
         );
      FCVfbmRootMethane:=round( power( fCalc1, 0.333) );
      if fCalc1 <= 1912
      then begin
         FCVfbmVigorCalc:=FCVfbmVigorCalc + FCFfbF_StarLuminosityVigorMod_Calculate( fCalc1 );
         if FCVfbmVigorCalc < 1 then
         begin
            StageFailed:=true;
            FCMfB_FossilPresence_Test(
               Star
               ,OrbitalObject
               ,FCVfbmStarAge
               ,Satellite
               );
         end;
      end
      else begin
         StageFailed:=true;
         FCMfB_FossilPresence_Test(
            Star
            ,OrbitalObject
            ,FCVfbmStarAge
            ,Satellite
            );
      end;
   end
   else if FCVfbmHydroType in [hMethaneIceSheet..hMethaneIceCrust] then
   begin
      {.base modifier}
      FCVfbmVigorCalc:=FCVfbmVigorCalc + 30;
      {.hydrosphere influence}
      if FCVfbmHydroType = hMethaneIceSheet
      then FCVfbmVigorCalc:=FCVfbmVigorCalc + FCFfbF_HydrosphereModifier_Calculate( round( FCVfbmHydroArea * 1.33 ) )
      else FCVfbmVigorCalc:=FCVfbmVigorCalc + FCFfbF_HydrosphereModifier_Calculate( FCVfbmHydroArea );
      {.tectonic activity influence}
      case FCVfbmTectonicActivity of
         taDead: FCVfbmVigorCalc:=FCVfbmVigorCalc + -40;

         taHotSpot: FCVfbmVigorCalc:=FCVfbmVigorCalc + 10;

         taPlastic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 20;

         taPlateTectonic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 25;

         taPlateletTectonic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 30;
      end;
      if FCVfbmVigorCalc < 1 then
      begin
         StageFailed:=true;
         FCMfB_FossilPresence_Test(
            Star
            ,OrbitalObject
            ,FCVfbmStarAge
            ,Satellite
            );
      end;
   end;
   {.final test}
   if ( not StageFailed )
      and ( 70 <= FCVfbmVigorCalc ) then
      begin
         if Satellite <= 0 then
         begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blMethane_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbmVigorCalc;
         end
         else begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blMethane_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbmVigorCalc;
         end;
         FCMfbM_MicroOrganismStage_Test(
            Star
            ,OrbitalObject
            ,Satellite
            );
      end
      else FCMfB_FossilPresence_Test(
         Star
         ,OrbitalObject
         ,FCVfbmStarAge
         ,Satellite
         );
end;

end.
