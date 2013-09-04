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
   ,farc_fug_biosphere
   ,farc_fug_biospherefunctions
   ,farc_fug_data
   ,farc_fug_stars
   ,farc_univ_func;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   FCVfbaHydroType: TFCEduHydrospheres;

   FCVfbaRootAmmonia: integer;

   FCVfbaStarAge: extended;

   FCVfbaTectonicActivity: TFCEduTectonicActivity;

   FCVfbaVigorCalc: integer;

//==END PRIVATE VAR=========================================================================

const
   FCCfbaStagePenalty=20;

   FCCfbaStagePenalty_SubSurface=15;

//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfbA_PrebioticsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the ammonia-based prebiotics evolution stage.
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

      gasH2
      ,gasH2O
      ,gasN2
      ,gasNH3: TFCEduAtmosphericGasStatus;

begin
   HydroArea:=0;
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
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
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
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
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
      FCVfbaVigorCalc:=FCVfbaVigorCalc + FCFfbF_HydrosphereModifier_Calculate( HydroArea );
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
      then FCVfbaVigorCalc:=FCVfbaVigorCalc + FCFfbF_HydrosphereModifier_Calculate( round( HydroArea * 1.33 ) )
      else FCVfbaVigorCalc:=FCVfbaVigorCalc + FCFfbF_HydrosphereModifier_Calculate( HydroArea );
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
   if not StageFailed then
   begin
      TestVal:=FCFcF_Random_DoInteger( 99 ) + 1;
      if TestVal <= FCVfbaVigorCalc then
      begin
         if Satellite <= 0 then
         begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blAmmonia_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbaVigorCalc;
         end
         else begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blAmmonia_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbaVigorCalc;
//            FCMfbA_MicroOrganismStage_Test(
         end;
      end
      else FCMfB_FossilPresence_Test(
         Star
         ,OrbitalObject
         ,FCVfbaStarAge
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
