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
///   process and test the silicon-based level I organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbS_Level1OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the silicon-based level II organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbS_Level2OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the silicon-based level III organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbS_Level3OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the silicon-based micro-organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbS_MicroOrganismStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

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
   FCVfbsObjectType: TFCEduOrbitalObjectTypes;

   FCVfbsRootSilicon: integer;

   FCVfbsStarAge: extended;

   FCVfbsTectonicActivity: TFCEduTectonicActivity;

   FCVfbsVigorCalc: integer;

   gasH2
   ,gasN2
   ,gasNe
   ,gasSO2: TFCEduAtmosphericGasStatus;

//==END PRIVATE VAR=========================================================================

const
   FCCfbsStagePenalty=10;

//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfbS_Level1OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the silicon-based level I organisms evolution stage.
    Additions:
}
   var
      iCalc1
      ,TestVal: integer;

      StageFailed: boolean;

begin
   iCalc1:=0;

   StageFailed:=false;

   if FCVfbsStarAge <= 1
   then StageFailed:=true
   else begin
      {.evolution stage penalty}
      FCVfbsVigorCalc:=FCVfbsVigorCalc - FCCfbsStagePenalty;
      {.star influence}
      iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
      FCVfbsVigorCalc:=FCVfbsVigorCalc + ( 40 - iCalc1 );
      if FCVfbsVigorCalc < 1
      then StageFailed:=true;
   end; //==END== else of: if FCVfbcStarAge <= 0.8 ==//
   {.final test}
   if ( FCVfbsObjectType = ootPlanet_Icy )
      or ( FCVfbsObjectType = ootSatellite_Planet_Icy )
   then TestVal:=70
   else TestVal:=40;
   if ( not StageFailed )
      and ( TestVal <= FCVfbsVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSilicon_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSilicon_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsVigorCalc;
      end;
      FCMfbS_Level2OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

procedure FCMfbS_Level2OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the silicon-based level II organisms evolution stage.
    Additions:
}
   var
      iCalc1
      ,TestVal: integer;

      StageFailed: boolean;

begin
   iCalc1:=0;

   StageFailed:=false;

   if FCVfbsStarAge <= 2
   then StageFailed:=true
   else begin
      {.evolution stage penalty}
      FCVfbsVigorCalc:=FCVfbsVigorCalc - ( FCCfbsStagePenalty * 2 );
      {.star influence}
      iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
      FCVfbsVigorCalc:=FCVfbsVigorCalc + ( 40 - iCalc1 );
      if FCVfbsVigorCalc < 1
      then StageFailed:=true;
   end; //==END== else of: if FCVfbcStarAge <= 0.8 ==//
   {.final test}
   if ( FCVfbsObjectType = ootPlanet_Icy )
      or ( FCVfbsObjectType = ootSatellite_Planet_Icy )
   then TestVal:=70
   else TestVal:=40;
   if ( not StageFailed )
      and ( TestVal <= FCVfbsVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSilicon_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSilicon_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsVigorCalc;
      end;
      FCMfbS_Level3OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

procedure FCMfbS_Level3OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the silicon-based level III organisms evolution stage.
    Additions:
}
   var
      iCalc1
      ,TestVal: integer;

      StageFailed: boolean;

begin
   iCalc1:=0;

   StageFailed:=false;

   if FCVfbsStarAge <= 2
   then StageFailed:=true
   else begin
      {.evolution stage penalty}
      FCVfbsVigorCalc:=FCVfbsVigorCalc - ( FCCfbsStagePenalty * 3 );
      {.star influence}
      iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
      FCVfbsVigorCalc:=FCVfbsVigorCalc + ( 40 - iCalc1 );
      if FCVfbsVigorCalc < 1
      then StageFailed:=true;
   end; //==END== else of: if FCVfbcStarAge <= 0.8 ==//
   {.final test}
   if ( FCVfbsObjectType = ootPlanet_Icy )
      or ( FCVfbsObjectType = ootSatellite_Planet_Icy )
   then TestVal:=70
   else TestVal:=40;
   if ( not StageFailed )
      and ( TestVal <= FCVfbsVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSilicon_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSilicon_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsVigorCalc;
      end;
   end;
end;

procedure FCMfbS_MicroOrganismStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the silicon-based micro-organisms evolution stage.
    Additions:
}
   var
      Bh2
      ,Bn2
      ,Bne
      ,Bso2
      ,Bsilicones
      ,iCalc1
      ,PrimaryGasPart
      ,TestVal: integer;

      fCalc1
      ,fCalc2
      ,fCalc3: extended;

      SiliconDNA
      ,SiliconMembranes
      ,SiliconProteins
      ,isRotationPeriodNull
      ,Stagefailed: boolean;
begin
   Bh2:=0;
   Bn2:=0;
   Bne:=0;
   Bso2:=0;
   Bsilicones:=0;
   iCalc1:=0;
   PrimaryGasPart:=0;
   TestVal:=0;

   fCalc1:=0;
   fCalc2:=0;
   fCalc3:=0;

   SiliconDNA:=false;
   SiliconMembranes:=false;
   SiliconProteins:=false;
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

   if FCVfbsStarAge > 0.8
   then StageFailed:=true else
   begin
      {.star influence}
      iCalc1:=FCFfbF_StarModifier_Phase1( FCDduStarSystem[0].SS_stars[Star].S_class );
      FCVfbsVigorCalc:=FCVfbsVigorCalc + ( 40 - iCalc1 );
      {.rotation period influence}
      if isRotationPeriodNull
      then FCVfbsVigorCalc:=FCVfbsVigorCalc - 20;
      if FCVfbsVigorCalc < 1
      then StageFailed:=true
      else begin
         {.molecular building blocks phase}
         {..by tectonic activity}
         case FCVfbsTectonicActivity of
            taHotSpot: Bsilicones:=3;

            taPlastic: Bsilicones:=5;

            taPlateTectonic: Bsilicones:=8;

            taPlateletTectonic: Bsilicones:=13;
         end;
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

         if gasN2 = agsSecondary
         then fCalc1:=fCalc2
         else if gasN2 = agsPrimary
         then fCalc1:=fCalc3
         else fCalc1:=0;
         Bn2:=round( fCalc1 );

         if gasNe = agsSecondary
         then fCalc1:=fCalc2
         else if gasNe = agsPrimary
         then fCalc1:=fCalc3
         else fCalc1:=0;
         Bne:=round( fCalc1 );

         if gasSO2 = agsSecondary
         then fCalc1:=fCalc2
         else if gasSO2 = agsPrimary
         then fCalc1:=fCalc3
         else fCalc1:=0;
         Bso2:=round( fCalc1 );
         {..results}
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bn2 - Bsilicones;
         if TestVal <= FCVfbsVigorCalc
         then SiliconMembranes:=true;
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bn2 - Bsilicones - round( ( Bne + Bso2 ) / 1.5 );
         if TestVal <= FCVfbsVigorCalc
         then SiliconDNA:=true;
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bn2 - Bh2 - Bsilicones;
         if TestVal <= FCVfbsVigorCalc
         then SiliconProteins:=true;
      end;
   end; //==END== else of: if FCVfbcStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( SiliconMembranes )
      and ( SiliconDNA )
      and ( SiliconProteins ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSilicon_MicroOrganisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSilicon_MicroOrganisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsVigorCalc;
      end;
      FCMfbS_Level1OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

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
      FCVfbsObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type;
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
      FCVfbsObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_type;
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
   if ( FCVfbsObjectType = ootPlanet_Icy )
      or ( FCVfbsObjectType = ootSatellite_Planet_Icy )
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
   if ( FCVfbsObjectType = ootPlanet_Icy )
      or ( FCVfbsObjectType = ootSatellite_Planet_Icy )
   then TestVal:=70
   else TestVal:=40;
   if ( not StageFailed )
      and ( TestVal <= FCVfbsVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSilicon_Prebiotics;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSilicon_Prebiotics;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsVigorCalc;
      end;
      FCMfbS_MicroOrganismStage_Test(
         Star
         ,OrbitalObject
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
