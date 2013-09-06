{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: biosphere - ammonia-based unit

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
unit farc_fug_biosphereammonia;

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
///   process and test the ammonia-based level I organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbA_Level1OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the ammonia-based level II organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbA_Level2OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the ammonia-based level III organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbA_Level3OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the ammonia-based micro-organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbA_MicroOrganismStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the ammonia-based prebiotics evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbA_PrebioticsStage_Test(
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
   FCVfbaGravity: extended;

   FCVfbaHydroArea: integer;

   FCVfbaHydroType: TFCEduHydrospheres;

   FCVfbaRootAmmonia: integer;

   FCVfbaStarAge: extended;

   FCVfbaTectonicActivity: TFCEduTectonicActivity;

   FCVfbaVigorCalc: integer;

   gasH2
   ,gasH2O
   ,gasN2
   ,gasNH3: TFCEduAtmosphericGasStatus;

//==END PRIVATE VAR=========================================================================

const
   FCCfbaStagePenalty=20;

   FCCfbaStagePenalty_SubSurface=15;

//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfbA_Level1OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the ammonia-based level I organisms evolution stage.
    Additions:
}
   var
      iCalc1: integer;

      fCalc1: extended;

      StageFailed: boolean;

begin
   iCalc1:=0;

   fCalc1:=0;
   FCVfbaGravity:=0;

   StageFailed:=false;

   if Satellite <= 0 then
   begin
      FCVfbaGravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity;
   end
   else begin
      FCVfbaGravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravity;
   end;

   if FCVfbaStarAge <= 1
   then StageFailed:=true
   else begin
      if FCVfbaHydroType = hWaterAmmoniaLiquid then
      begin
         {.evolution stage penalty}
         FCVfbaVigorCalc:=FCVfbaVigorCalc - FCCfbaStagePenalty;
         {.star influence}
         iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
         FCVfbaVigorCalc:=FCVfbaVigorCalc + ( 40 - iCalc1 );
         {.gravity modifier}
         fCalc1:=( 1 - sqr( FCVfbaGravity ) ) * 5;
         FCVfbaGravity:=fCalc1;
         if FCVfbaVigorCalc < 1
         then StageFailed:=true;
      end //==END== if FCVfbcHydroType = hWaterAmmoniaLiquid ==//
      else if FCVfbaHydroType in [hNitrogenIceSheet..hNitrogenIceCrust] then
      begin
         {.evolution stage penalty}
         FCVfbaVigorCalc:=FCVfbaVigorCalc - FCCfbaStagePenalty_SubSurface;
         if FCVfbaVigorCalc < 1
         then StageFailed:=true
      end;
   end; //==END== else of: if FCVfbaStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( 60 <= FCVfbaVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blAmmonia_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbaVigorCalc;
         if FCVfbaHydroType = hWaterAmmoniaLiquid then
         begin
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2:=agsSecondary
            else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2 = agsSecondary
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2:=agsPrimary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O:=agsSecondary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2:=agsSecondary
            else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2 = agsSecondary
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2:=agsPrimary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3:=agsSecondary;
         end;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blAmmonia_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbaVigorCalc;
         if FCVfbaHydroType = hWaterAmmoniaLiquid then
         begin
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2:=agsSecondary
            else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2 = agsSecondary
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2:=agsPrimary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O:=agsSecondary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2:=agsSecondary
            else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2 = agsSecondary
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2:=agsPrimary;
            if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3 <= agsTrace
            then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3:=agsSecondary;
         end;
      end;
      FCMfbA_Level2OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

procedure FCMfbA_Level2OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the ammonia-based level II organisms evolution stage.
    Additions:
}
   var
      iCalc1: integer;

      StageFailed: boolean;

begin
   iCalc1:=0;

   StageFailed:=false;

   if FCVfbaStarAge <= 2
   then StageFailed:=true
   else begin
      if FCVfbaHydroType = hWaterAmmoniaLiquid then
      begin
         {.evolution stage penalty}
         FCVfbaVigorCalc:=FCVfbaVigorCalc - ( FCCfbaStagePenalty * 2 );
         {.star influence}
         iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
         FCVfbaVigorCalc:=FCVfbaVigorCalc + ( 40 - iCalc1 );
         if FCVfbaVigorCalc < 1
         then StageFailed:=true;
      end //==END== if FCVfbcHydroType = hWaterAmmoniaLiquid ==//
      else if FCVfbaHydroType in [hNitrogenIceSheet..hNitrogenIceCrust] then
      begin
         {.evolution stage penalty}
         FCVfbaVigorCalc:=FCVfbaVigorCalc - ( FCCfbaStagePenalty_SubSurface * 2 );
         if FCVfbaVigorCalc < 1
         then StageFailed:=true
      end;
   end; //==END== else of: if FCVfbaStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( 60 <= FCVfbaVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blAmmonia_Level2Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbaVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blAmmonia_Level2Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbaVigorCalc;
      end;
      if FCVfbaHydroType = hWaterAmmoniaLiquid
      then FCMfbA_Level3OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

procedure FCMfbA_Level3OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the ammonia-based level III organisms evolution stage.
    Additions:
}
   var
      iCalc1: integer;

      StageFailed: boolean;

begin
   iCalc1:=0;

   StageFailed:=false;

   if FCVfbaStarAge <= 2
   then StageFailed:=true
   else begin
      if FCVfbaHydroType = hWaterAmmoniaLiquid then
      begin
         {.evolution stage penalty}
         FCVfbaVigorCalc:=FCVfbaVigorCalc - ( FCCfbaStagePenalty * 3 );
         {.star influence}
         iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
         FCVfbaVigorCalc:=FCVfbaVigorCalc + ( 40 - iCalc1 );
         {.gravity modifier}
         FCVfbaVigorCalc:=FCVfbaVigorCalc + round( FCVfbaGravity );
         if FCVfbaVigorCalc < 1
         then StageFailed:=true;
      end //==END== if FCVfbcHydroType = hWaterAmmoniaLiquid ==//
      else if FCVfbaHydroType in [hNitrogenIceSheet..hNitrogenIceCrust] then
      begin
         {.evolution stage penalty}
         FCVfbaVigorCalc:=FCVfbaVigorCalc - ( FCCfbaStagePenalty_SubSurface * 3 );
         if FCVfbaVigorCalc < 1
         then StageFailed:=true
      end;
   end; //==END== else of: if FCVfbaStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( 60 <= FCVfbaVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blAmmonia_Level3Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbaVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blAmmonia_Level3Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbaVigorCalc;
      end;
   end;
end;

procedure FCMfbA_MicroOrganismStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the ammonia-based micro-organisms evolution stage.
    Additions:
}
   var
      BnhPolymers
      ,Bh2
      ,Bh2o
      ,Bn2
      ,Bnh3
      ,Bsugar

      ,iCalc1
      ,PrimaryGasPart
      ,TestVal: integer;

      fCalc1
      ,fCalc2
      ,fCalc3: extended;

      AmmoDNA
      ,AmmoMembranes
      ,AmmoProteins
      ,isRotationPeriodNull
      ,Stagefailed: boolean;

begin
   BnhPolymers:=0;
   Bh2:=0;
   Bh2o:=0;
   Bn2:=0;
   Bnh3:=0;
   Bsugar:=0;
   iCalc1:=0;
   PrimaryGasPart:=0;
   TestVal:=0;

   fCalc1:=0;
   fCalc2:=0;
   fCalc3:=0;

   AmmoDNA:=false;
   AmmoMembranes:=false;
   AmmoProteins:=false;
   isRotationPeriodNull:=false;
   StageFailed:=false;

   if Satellite <= 0 then
   begin
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod = 0
      then isRotationPeriodNull:=true;
      PrimaryGasPart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_primaryGasVolumePerc;
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
   end;

   if FCVfbaStarAge <= 0.8
   then StageFailed:=true else
   begin
      if FCVfbaHydroType = hWaterAmmoniaLiquid then
      begin
         {.star influence}
         iCalc1:=FCFfbF_StarModifier_Phase1( FCDduStarSystem[0].SS_stars[Star].S_class );
         FCVfbaVigorCalc:=FCVfbaVigorCalc + ( 40 - iCalc1 );
         {.rotation period influence}
         if isRotationPeriodNull
         then FCVfbaVigorCalc:=FCVfbaVigorCalc - 20;
         if FCVfbaVigorCalc < 1
         then StageFailed:=true
         else begin
            {.molecular building blocks phase}
            {..by tectonic activity}
            case FCVfbaTectonicActivity of
               taHotSpot: BnhPolymers:=1;

               taPlastic: BnhPolymers:=2;

               taPlateTectonic: BnhPolymers:=3;

               taPlateletTectonic: BnhPolymers:=5;
            end;
            {..by hydrosphere}
            fCalc1:=power( FCVfbaHydroArea, 0.333);
            Bnh3:=round( fCalc1 );
            Bh2o:=Bnh3;
            {..by gasses}
            iCalc1:=FCFfA_PrimaryGasses_GetTotalNumber(
               Star
               ,OrbitalObject
               ,Satellite
               );
            fCalc2:=power( 100 - PrimaryGasPart, 0.333 );
            fCalc3:=power( PrimaryGasPart / iCalc1, 0.333 );
            if gasH2 = agsSecondary
            then fCalc1:=fCalc2
            else if gasH2 = agsPrimary
            then fCalc1:=fCalc3
            else fCalc1:=0;
            Bh2:=round( fCalc1 );

            if gasH2O = agsSecondary
            then fCalc1:=fCalc2
            else if gasH2O = agsPrimary
            then fCalc1:=fCalc3
            else fCalc1:=0;
            Bh2o:=Bh2o + round( fCalc1 );

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
            Bnh3:=Bnh3 + round( fCalc1 );
            {..by associations}
            fCalc2:=6 * Bnh3;
            fCalc3:=6 * Bh2o;
            fCalc1:=( fCalc2 + ( 12 * Bh2 ) + FCVfbaRootAmmonia ) / 18;
            Bsugar:=round( fCalc1 );
            fCalc1:=( fCalc2 + ( 12 * Bh2 ) + FCVfbaRootAmmonia ) / 7;
            BnhPolymers:=BnhPolymers + round( fCalc1 );
            fCalc1:=( fCalc2 + ( 12 * Bh2 ) + FCVfbaRootAmmonia ) / 13;
            Bh2:=Bh2 + round( fCalc1 );
            fCalc1:=( fCalc2 + fCalc3 + FCVfbaRootAmmonia ) / 6;
            Bsugar:=Bsugar + round( fCalc1 );
            fCalc1:=( fCalc2 + fCalc3 + FCVfbaRootAmmonia );
            Bn2:=Bn2 + round( fCalc1 );
            fCalc1:=( Bsugar + fCalc3 + ( 4 * Bn2 ) ) / 8;
            Bh2:=Bh2 + round( fCalc1 );
            fCalc1:=( Bsugar + fCalc3 + ( 4 * Bn2 ) ) / 6;
            Bnh3:=Bnh3 + round( fCalc1 );
            {..results}
            TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bnh3 - BnhPolymers;
            if TestVal <= FCVfbaVigorCalc
            then AmmoMembranes:=true;
            TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bnh3 - BnhPolymers - Bsugar;
            if TestVal <= FCVfbaVigorCalc
            then AmmoDNA:=true;
            TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bnh3 - Bh2 - BnhPolymers;
            if TestVal <= FCVfbaVigorCalc
            then AmmoProteins:=true;
         end;
      end //==END== if FCVfbcHydroType = hWaterLiquid ==//
      else if FCVfbaHydroType in [hNitrogenIceSheet..hNitrogenIceCrust] then
      begin
         {.molecular building blocks phase}
         {..by tectonic activity}
         case FCVfbaTectonicActivity of
            taDead:
            begin
               BnhPolymers:=1;
               Bnh3:=12;
               Bh2o:=2;
            end;

            taHotSpot:
            begin
               BnhPolymers:=2;
               Bnh3:=10;
               Bh2o:=3;
            end;

            taPlastic:
            begin
               BnhPolymers:=3;
               Bnh3:=7;
               Bh2o:=5;
            end;

            taPlateTectonic:
            begin
               BnhPolymers:=5;
               Bnh3:=5;
               Bh2o:=8;
            end;

            taPlateletTectonic:
            begin
               BnhPolymers:=8;
               Bnh3:=2;
               Bh2o:=13;
            end;
         end;
         {..results}
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bnh3 - BnhPolymers;
         if TestVal <= FCVfbaVigorCalc
            then AmmoMembranes:=true;
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bnh3 - BnhPolymers - Integer( FCVfbaTectonicActivity ) - 1;
         if TestVal <= FCVfbaVigorCalc
            then AmmoDNA:=true;
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bnh3 - Bh2o - BnhPolymers;
         if TestVal <= FCVfbaVigorCalc
            then AmmoProteins:=true;
      end;
   end; //==END== else of: if FCVfbcStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( AmmoMembranes )
      and ( AmmoDNA )
      and ( AmmoProteins ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blAmmonia_MicroOrganisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbaVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blAmmonia_MicroOrganisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbaVigorCalc;
      end;
      FCMfbA_Level1OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

procedure FCMfbA_PrebioticsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the ammonia-based prebiotics evolution stage.
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
   FCVfbaHydroArea:=0;
   TestVal:=0;

   Albedo:=0;
   CloudsCover:=0;
   DistanceFromStar:=0;
   fCalc1:=0;

   FCVfbaHydroType:=hNoHydro;

   gasH2:=agsNotPresent;
   gasH2O:=agsNotPresent;
   gasN2:=agsNotPresent;
   gasNH3:=agsNotPresent;

   FCVfbaTectonicActivity:=taNull;

   if Satellite <= 0 then
   begin
      FCVfbaHydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      FCVfbaHydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
      DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      FCVfbaTectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity;
      gasH2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2;
      gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2;
      gasNH3:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3;
   end
   else begin
      FCVfbaHydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      FCVfbaHydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover;
      DistanceFromStar:=FCFuF_Satellite_GetDistanceFromStar(
         0
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      FCVfbaTectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity;
      gasH2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2;
      gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2;
      gasNH3:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3;
   end;
   StageFailed:=false;
   FCVfbaVigorCalc:=0;
   FCVfbaRootAmmonia:=0;
   FCVfbaStarAge:=FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
   if FCVfbaHydroType = hWaterAmmoniaLiquid then
   begin
      {.surface temperature influence}
      FCVfbaVigorCalc:=FCVfbaVigorCalc + FCFfbF_SurfaceTemperaturesModifier_Calculate(
         300
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      {.hydrosphere influence}
      FCVfbaVigorCalc:=FCVfbaVigorCalc + FCFfbF_HydrosphereModifier_Calculate( FCVfbaHydroArea );
      {.atmosphere influences}
      case gasH2 of
         agsNotPresent: FCVfbaVigorCalc:=FCVfbaVigorCalc - 15;

         agsTrace: FCVfbaVigorCalc:=FCVfbaVigorCalc - 15;

         agsSecondary: FCVfbaVigorCalc:=FCVfbaVigorCalc + 20;

         agsPrimary: FCVfbaVigorCalc:=FCVfbaVigorCalc + 40;
      end;
      case gasH2O of
         agsNotPresent: FCVfbaVigorCalc:=FCVfbaVigorCalc - 20;

         agsSecondary: FCVfbaVigorCalc:=FCVfbaVigorCalc + 20;

         agsPrimary: FCVfbaVigorCalc:=FCVfbaVigorCalc + 40;
      end;
      case gasN2 of
         agsNotPresent: FCVfbaVigorCalc:=FCVfbaVigorCalc - 20;

         agsTrace: FCVfbaVigorCalc:=FCVfbaVigorCalc - 20;

         agsSecondary: FCVfbaVigorCalc:=FCVfbaVigorCalc + 10;

         agsPrimary: FCVfbaVigorCalc:=FCVfbaVigorCalc + 20;
      end;
      case gasNH3 of
         agsNotPresent: FCVfbaVigorCalc:=FCVfbaVigorCalc - 5;

         agsTrace: FCVfbaVigorCalc:=FCVfbaVigorCalc - 5;

         agsSecondary: FCVfbaVigorCalc:=FCVfbaVigorCalc + 10;

         agsPrimary: FCVfbaVigorCalc:=FCVfbaVigorCalc + 30;
      end;
      {.tectonic activity influence}
      case FCVfbaTectonicActivity of
         taDead: FCVfbaVigorCalc:=FCVfbaVigorCalc -20;

         taHotSpot: FCVfbaVigorCalc:=FCVfbaVigorCalc + 5;

         taPlastic: FCVfbaVigorCalc:=FCVfbaVigorCalc + 10;

         taPlateTectonic: FCVfbaVigorCalc:=FCVfbaVigorCalc + 20;

         taPlateletTectonic: FCVfbaVigorCalc:=FCVfbaVigorCalc + 10;
      end;
      {.star luminosity influence}
      fCalc1:=FCFfbF_StarLuminosityFactor_Calculate(
         DistanceFromStar
         ,FCDduStarSystem[0].SS_stars[Star].S_luminosity
         ,Albedo
         ,CloudsCover
         );
      FCVfbaRootAmmonia:=round( power( fCalc1, 0.333) );
      if fCalc1 <= 1912
      then begin
         FCVfbaVigorCalc:=FCVfbaVigorCalc + FCFfbF_StarLuminosityVigorMod_Calculate( fCalc1 );
         if FCVfbaVigorCalc < 1 then
         begin
            StageFailed:=true;
            FCMfB_FossilPresence_Test(
               Star
               ,OrbitalObject
               ,FCVfbaStarAge
               ,Satellite
               );
         end;
      end
      else begin
         StageFailed:=true;
         FCMfB_FossilPresence_Test(
            Star
            ,OrbitalObject
            ,FCVfbaStarAge
            ,Satellite
            );
      end;
   end
   else if FCVfbaHydroType in [hNitrogenIceSheet..hNitrogenIceCrust] then
   begin
      {.base modifier}
      FCVfbaVigorCalc:=FCVfbaVigorCalc + 40;
      {.hydrosphere influence}
      if FCVfbaHydroType = hNitrogenIceSheet
      then FCVfbaVigorCalc:=FCVfbaVigorCalc + FCFfbF_HydrosphereModifier_Calculate( round( FCVfbaHydroArea * 1.33 ) )
      else FCVfbaVigorCalc:=FCVfbaVigorCalc + FCFfbF_HydrosphereModifier_Calculate( FCVfbaHydroArea );
      {.tectonic activity influence}
      case FCVfbaTectonicActivity of
         taHotSpot: FCVfbaVigorCalc:=FCVfbaVigorCalc + 5;

         taPlastic: FCVfbaVigorCalc:=FCVfbaVigorCalc + 10;

         taPlateTectonic: FCVfbaVigorCalc:=FCVfbaVigorCalc + 15;

         taPlateletTectonic: FCVfbaVigorCalc:=FCVfbaVigorCalc + 20;
      end;
      if FCVfbaVigorCalc < 1 then
      begin
         StageFailed:=true;
         FCMfB_FossilPresence_Test(
            Star
            ,OrbitalObject
            ,FCVfbaStarAge
            ,Satellite
            );
      end;
   end;
   {.final test}
   if ( not StageFailed )
      and ( 60 <= FCVfbaVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blAmmonia_Prebiotics;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbaVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blAmmonia_Prebiotics;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbaVigorCalc;
      end;
      FCMfbA_MicroOrganismStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end
   else FCMfB_FossilPresence_Test(
      Star
      ,OrbitalObject
      ,FCVfbaStarAge
      ,Satellite
      );

end;

end.
