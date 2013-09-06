{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: biosphere - sulphur dioxide-based unit

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
unit farc_fug_biospheresulphurdioxide;

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
///   process and test the sulfur dioxide-based level I organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbsD_Level1OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the sulfur dioxide-based level II organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbsD_Level2OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the sulfur dioxide-based level III organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbsD_Level3OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the sulfur dioxide-based micro-organisms evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbsD_MicroOrganismStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process and test the sulfur dioxide-based prebiotics evolution stage
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfbsD_PrebioticsStage_Test(
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
   FCVfbsdHydroType: TFCEduHydrospheres;

   FCVfbsdRootSulphur: integer;

   FCVfbsdStarAge: extended;

   FCVfbsdTectonicActivity: TFCEduTectonicActivity;

   FCVfbsdVigorCalc: integer;

   gasH2S
   ,gasNO2
   ,gasSO2: TFCEduAtmosphericGasStatus;

//==END PRIVATE VAR=========================================================================

const
   FCCfbsdStagePenalty=5;

   FCCfbsdStagePenalty_NoHydro=10;

//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfbsD_Level1OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the sulfur dioxide-based level I organisms evolution stage.
    Additions:
}
   var
      iCalc1: integer;

      StageFailed: boolean;

begin
   StageFailed:=false;

   if FCVfbsdStarAge <= 1
   then StageFailed:=true
   else begin
      {.evolution stage penalty}
      if FCVfbsdHydroType = hWaterLiquid
      then FCVfbsdVigorCalc:=FCVfbsdVigorCalc - FCCfbsdStagePenalty
      else FCVfbsdVigorCalc:=FCVfbsdVigorCalc - FCCfbsdStagePenalty_NoHydro;
      {.star influence}
      iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
      FCVfbsdVigorCalc:=FCVfbsdVigorCalc + ( 40 - iCalc1 );
      if FCVfbsdVigorCalc < 1
      then StageFailed:=true;
   end; //==END== else of: if FCVfbaStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( 40 <= FCVfbsdVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSulphurDioxide_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsdVigorCalc;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2 <= agsTrace
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2:=agsSecondary;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S <= agsTrace
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S:=agsSecondary
         else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S = agsSecondary
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S:=agsPrimary;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2 <= agsTrace
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2:=agsSecondary
         else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2 = agsSecondary
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2:=agsPrimary;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2 <= agsTrace
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2:=agsSecondary
         else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2 = agsSecondary
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2:=agsPrimary;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSulphurDioxide_Level1Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsdVigorCalc;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2 <= agsTrace
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2:=agsSecondary;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S <= agsTrace
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S:=agsSecondary
         else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S = agsSecondary
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S:=agsPrimary;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2 <= agsTrace
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2:=agsSecondary
         else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2 = agsSecondary
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2:=agsPrimary;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2 <= agsTrace
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2:=agsSecondary
         else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2 = agsSecondary
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2:=agsPrimary;
      end;
      FCMfbsD_Level2OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

procedure FCMfbsD_Level2OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the sulfur dioxide-based level II organisms evolution stage.
    Additions:
}
   var
      iCalc1: integer;

      StageFailed: boolean;

begin
   StageFailed:=false;

   if FCVfbsdStarAge <= 2
   then StageFailed:=true
   else begin
      {.evolution stage penalty}
      if FCVfbsdHydroType = hWaterLiquid
      then FCVfbsdVigorCalc:=FCVfbsdVigorCalc - ( FCCfbsdStagePenalty * 2 )
      else FCVfbsdVigorCalc:=FCVfbsdVigorCalc - ( FCCfbsdStagePenalty_NoHydro * 2 );
      {.star influence}
      iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
      FCVfbsdVigorCalc:=FCVfbsdVigorCalc + ( 40 - iCalc1 );
      if FCVfbsdVigorCalc < 1
      then StageFailed:=true;
   end; //==END== else of: if FCVfbaStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( 40 <= FCVfbsdVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSulphurDioxide_Level2Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsdVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSulphurDioxide_Level2Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsdVigorCalc;
      end;
      FCMfbsD_Level3OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

procedure FCMfbsD_Level3OrganismsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the sulfur dioxide-based level III organisms evolution stage.
    Additions:
}
   var
      iCalc1: integer;

      StageFailed: boolean;

begin
   StageFailed:=false;

   if FCVfbsdStarAge <= 5
   then StageFailed:=true
   else begin
      {.evolution stage penalty}
      if FCVfbsdHydroType = hWaterLiquid
      then FCVfbsdVigorCalc:=FCVfbsdVigorCalc - ( FCCfbsdStagePenalty * 3 )
      else FCVfbsdVigorCalc:=FCVfbsdVigorCalc - ( FCCfbsdStagePenalty_NoHydro * 3 );
      {.star influence}
      iCalc1:=FCFfbF_StarModifier_Phase2( FCDduStarSystem[0].SS_stars[Star].S_class );
      FCVfbsdVigorCalc:=FCVfbsdVigorCalc + ( 40 - iCalc1 );
      if FCVfbsdVigorCalc < 1
      then StageFailed:=true;
   end; //==END== else of: if FCVfbaStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( 40 <= FCVfbsdVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSulphurDioxide_Level3Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsdVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSulphurDioxide_Level3Organisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsdVigorCalc;
      end;
   end;
end;

procedure FCMfbsD_MicroOrganismStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the sulfur dioxide-based micro-organisms evolution stage.
    Additions:
}
   var
      BsdChain
      ,Bh2s
      ,Bso2
      ,iCalc1
      ,PrimaryGasPart
      ,TestVal: integer;

      fCalc1
      ,fCalc2
      ,fCalc3: extended;

      sdDNA
      ,sdMembranes
      ,sdProteins
      ,isRotationPeriodNull
      ,Stagefailed: boolean;

begin
   BsdChain:=0;
   Bh2s:=0;
   Bso2:=0;
   iCalc1:=0;
   PrimaryGasPart:=0;
   TestVal:=0;

   fCalc1:=0;
   fCalc2:=0;
   fCalc3:=0;

   sdDNA:=false;
   sdMembranes:=false;
   sdProteins:=false;
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

   if FCVfbsdStarAge <= 0.8
   then StageFailed:=true else
   begin
      {.star influence}
      iCalc1:=FCFfbF_StarModifier_Phase1( FCDduStarSystem[0].SS_stars[Star].S_class );
      FCVfbsdVigorCalc:=FCVfbsdVigorCalc + ( 40 - iCalc1 );
      {.rotation period influence}
      if isRotationPeriodNull
      then FCVfbsdVigorCalc:=FCVfbsdVigorCalc - 20;
      if FCVfbsdVigorCalc < 1
      then StageFailed:=true
      else begin
         {.molecular building blocks phase}
         {..by tectonic activity}
         case FCVfbsdTectonicActivity of
            taHotSpot: BsdChain:=3;

            taPlastic: BsdChain:=6;

            taPlateTectonic: BsdChain:=9;

            taPlateletTectonic: BsdChain:=15;
         end;
         {..by gasses}
         iCalc1:=FCFfA_PrimaryGasses_GetTotalNumber(
            Star
            ,OrbitalObject
            ,Satellite
            );
         fCalc2:=power( 100 - PrimaryGasPart, 0.333 );
         fCalc3:=power( PrimaryGasPart / iCalc1, 0.333 );
         if gasH2S = agsSecondary
         then fCalc1:=fCalc2
         else if gasH2S = agsPrimary
         then fCalc1:=fCalc3
         else fCalc1:=0;
         Bh2s:=round( fCalc1 );

         if gasSO2 = agsSecondary
         then fCalc1:=fCalc2
         else if gasSO2 = agsPrimary
         then fCalc1:=fCalc3
         else fCalc1:=0;
         Bso2:=round( fCalc1 );
         {..results}
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bso2 - BsdChain;
         if TestVal <= FCVfbsdVigorCalc
         then sdMembranes:=true;
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bso2 - BsdChain - round( ( Bso2 + Bh2s ) / 1.5 );
         if TestVal <= FCVfbsdVigorCalc
         then sdDNA:=true;
         TestVal:=FCFcF_Random_DoInteger( 99 ) + 1 - Bso2 - Bh2s - BsdChain;
         if TestVal <= FCVfbsdVigorCalc
         then sdProteins:=true;
      end;
   end; //==END== else of: if FCVfbcStarAge <= 0.8 ==//
   {.final test}
   if ( not StageFailed )
      and ( sdMembranes )
      and ( sdDNA )
      and ( sdProteins ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSulphurDioxide_MicroOrganisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsdVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSulphurDioxide_MicroOrganisms;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsdVigorCalc;
      end;
      FCMfbsD_Level1OrganismsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
end;

procedure FCMfbsD_PrebioticsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the sulfur dioxide-based prebiotics evolution stage.
    Additions:
}
   var
      GasVol
      ,HydroArea
      ,TestVal: integer;

      Albedo
      ,CloudsCover
      ,DistanceFromStar
      ,fCalc1: extended;

      StageFailed: boolean;

      procedure _AtmosphereInfluence_Apply;
      begin
         case gasH2S of
            agsSecondary: FCVfbsdVigorCalc:=FCVfbsdVigorCalc + 15;

            agsPrimary: FCVfbsdVigorCalc:=FCVfbsdVigorCalc + 30;
         end;
         case gasNO2 of
            agsNotPresent: FCVfbsdVigorCalc:=FCVfbsdVigorCalc - 30;

            agsTrace: FCVfbsdVigorCalc:=FCVfbsdVigorCalc - 30;

            agsSecondary: FCVfbsdVigorCalc:=FCVfbsdVigorCalc + 20;

            agsPrimary: FCVfbsdVigorCalc:=FCVfbsdVigorCalc + 30;
         end;
         case gasSO2 of
            agsNotPresent: FCVfbsdVigorCalc:=FCVfbsdVigorCalc - 10;

            agsTrace: FCVfbsdVigorCalc:=FCVfbsdVigorCalc - 10;

            agsSecondary: FCVfbsdVigorCalc:=FCVfbsdVigorCalc + 10;

            agsPrimary: FCVfbsdVigorCalc:=FCVfbsdVigorCalc + 20;
         end;
      end;

      procedure _StarLuminosity_Apply;
      begin
         fCalc1:=FCFfbF_StarLuminosityFactor_Calculate(
            DistanceFromStar
            ,FCDduStarSystem[0].SS_stars[Star].S_luminosity
            ,Albedo
            ,CloudsCover
            );
         FCVfbsdRootSulphur:=round( power( fCalc1, 0.333) );
         if fCalc1 <= 1912
         then begin
            FCVfbsdVigorCalc:=FCVfbsdVigorCalc + FCFfbF_StarLuminosityVigorMod_Calculate( fCalc1 );
            if FCVfbsdVigorCalc < 1 then
            begin
               StageFailed:=true;
               FCMfB_FossilPresence_Test(
                  Star
                  ,OrbitalObject
                  ,FCVfbsdStarAge
                  ,Satellite
                  );
            end;
         end
         else begin
            StageFailed:=true;
            FCMfB_FossilPresence_Test(
               Star
               ,OrbitalObject
               ,FCVfbsdStarAge
               ,Satellite
               );
         end;
      end;

      procedure _TectonicInfluence_Apply;
      begin
         case FCVfbsdTectonicActivity of
            taDead: FCVfbsdVigorCalc:=FCVfbsdVigorCalc + -30;

            taHotSpot: FCVfbsdVigorCalc:=FCVfbsdVigorCalc + 10;

            taPlastic: FCVfbsdVigorCalc:=FCVfbsdVigorCalc + 20;

            taPlateTectonic: FCVfbsdVigorCalc:=FCVfbsdVigorCalc + 30;

            taPlateletTectonic: FCVfbsdVigorCalc:=FCVfbsdVigorCalc + 50;
         end;
      end;

begin
   HydroArea:=0;
   TestVal:=0;

   Albedo:=0;
   CloudsCover:=0;
   DistanceFromStar:=0;
   fCalc1:=0;
   GasVol:=0;

   FCVfbsdHydroType:=hNoHydro;

   gasH2S:=agsNotPresent;
   gasNO2:=agsNotPresent;
   gasSO2:=agsNotPresent;

   FCVfbsdTectonicActivity:=taNull;

   if Satellite <= 0 then
   begin
      FCVfbsdHydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
      DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      FCVfbsdTectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity;
      GasVol:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_primaryGasVolumePerc shr 1;
      gasH2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S;
      gasNO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2;
      gasSO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2;
   end
   else begin
      FCVfbsdHydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover;
      DistanceFromStar:=FCFuF_Satellite_GetDistanceFromStar(
         0
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      FCVfbsdTectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity;
      GasVol:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_primaryGasVolumePerc shr 1;
      gasH2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S;
      gasNO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2;
      gasSO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2;
   end;
   StageFailed:=false;
   FCVfbsdVigorCalc:=0;
   FCVfbsdRootSulphur:=0;
   FCVfbsdStarAge:=FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
   if FCVfbsdHydroType = hNoHydro then
   begin
      {.base modifier}
      FCVfbsdVigorCalc:=GasVol;
      {.surface temperature influence}
      FCVfbsdVigorCalc:=FCVfbsdVigorCalc + FCFfbF_SurfaceTemperaturesModifier_Calculate(
         473.85
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      {.atmosphere influences}
      _AtmosphereInfluence_Apply;
      {.tectonic activity influence}
      _TectonicInfluence_Apply;
      {.star luminosity influence}
      _StarLuminosity_Apply;
   end
   else if FCVfbsdHydroType = hWaterLiquid then
   begin
      {.surface temperature influence}
      FCVfbsdVigorCalc:=FCVfbsdVigorCalc + FCFfbF_SurfaceTemperaturesModifier_Calculate(
         373.85
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      {.hydrosphere influence}
      FCVfbsdVigorCalc:=FCVfbsdVigorCalc + FCFfbF_HydrosphereModifier_Calculate( HydroArea );
      {.atmosphere influences}
      _AtmosphereInfluence_Apply;
      {.tectonic activity influence}
      _TectonicInfluence_Apply;
      {.star luminosity influence}
      _StarLuminosity_Apply;
   end;
   {.final test}
   if ( not StageFailed )
      and ( 40 <= FCVfbsdVigorCalc ) then
   begin
      if Satellite <= 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSulphurDioxide_Prebiotics;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsdVigorCalc;
      end
      else begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSulphurDioxide_Prebiotics;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsdVigorCalc;
      end;
      FCMfbsD_MicroOrganismStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end
   else FCMfB_FossilPresence_Test(
      Star
      ,OrbitalObject
      ,FCVfbsdStarAge
      ,Satellite
      );
end;

end.
