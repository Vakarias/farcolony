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
   ,farc_fug_biosphere
   ,farc_fug_biospherefunctions
   ,farc_fug_data
   ,farc_fug_stars
   ,farc_univ_func;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   FCVfbsdRootSulphur: integer;

   FCVfbsdVigorCalc: integer;

   FCVfbsdStarAge: extended;

//==END PRIVATE VAR=========================================================================

const
   FCCfbmStagePenalty=5;

   FCCfbmStagePenalty_NoHydro=10;

//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

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

      HydroType: TFCEduHydrospheres;

      gasH2S
      ,gasNO2
      ,gasSO2: TFCEduAtmosphericGasStatus;

      TectonicActivity: TFCEduTectonicActivity;

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
         case TectonicActivity of
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

   HydroType:=hNoHydro;

   gasH2S:=agsNotPresent;
   gasNO2:=agsNotPresent;
   gasSO2:=agsNotPresent;

   TectonicActivity:=taNull;

   if Satellite <= 0 then
   begin
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_albedo;
      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
      DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      TectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity;
      GasVol:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_primaryGasVolumePerc shr 1;
      gasH2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S;
      gasNO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2;
      gasSO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2;
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
      GasVol:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_primaryGasVolumePerc shr 1;
      gasH2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S;
      gasNO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2;
      gasSO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2;
   end;
   StageFailed:=false;
   FCVfbsdVigorCalc:=0;
   FCVfbsdRootSulphur:=0;
   FCVfbsdStarAge:=FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
   if HydroType = hNoHydro then
   begin
      {.base modifier}
      FCVfbsdVigorCalc:=FCVfbsdVigorCalc + GasVol;
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
   else if HydroType = hWaterLiquid then
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
   if not StageFailed then
   begin
      TestVal:=FCFcF_Random_DoInteger( 99 ) + 1;
      if TestVal <= FCVfbsdVigorCalc then
      begin
         if Satellite <= 0 then
         begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blSulphurDioxide_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbsdVigorCalc;
         end
         else begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blSulphurDioxide_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbsdVigorCalc;
//            FCMfbA_MicroOrganismStage_Test(
         end;
      end
      else FCMfB_FossilPresence_Test(
         Star
         ,OrbitalObject
         ,FCVfbsdStarAge
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
