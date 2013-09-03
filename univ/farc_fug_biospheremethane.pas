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

//uses

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

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
   farc_data_univ
   ,farc_fug_biospherefunctions;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   FCVfbmRootMethane: integer;

   FCVfbmVigorCalc: integer;

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfbM_PrebioticsStage_Test(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process and test the methane-based prebiotics evolution stage.
    Additions:
}
   var
      //HydroArea
      //,TestVal: integer;
//
//      Albedo
//      ,CloudsCover
//      ,DistanceFromStar
//      ,fCalc1: extended;
//
      StageFailed: boolean;

//      HydroType: TFCEduHydrospheres;

      ,gasN2
      ,gasCH4: TFCEduAtmosphericGasStatus;

//      TectonicActivity: TFCEduTectonicActivity;

begin
   //HydroArea:=0;
   //TestVal:=0;
   //
   //Albedo:=0;
   //CloudsCover:=0;
   //DistanceFromStar:=0;
   //fCalc1:=0;
   //
   //HydroType:=hNoHydro;

//   gasH2:=agsNotPresent;
//   gasH2O:=agsNotPresent;
   gasN2:=agsNotPresent;
   gasCH4:=agsNotPresent;

//   TectonicActivity:=taNull;

   if Satellite <= 0 then
   begin
//      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
//      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
//      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_albedo;
//      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
//      DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
//      TectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity;
//      gasH2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2;
//      gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2;
      gasCH4:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4;
   end
   else begin
//      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
//      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
//      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_albedo;
//      CloudsCover:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover;
//      DistanceFromStar:=FCFuF_Satellite_GetDistanceFromStar(
//         0
//         ,Star
//         ,OrbitalObject
//         ,Satellite
//         );
//      TectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity;
//      gasH2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2;
//      gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2;
      gasCH4:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4;
   end;
   StageFailed:=false;
   FCVfbmVigorCalc:=0;
   FCVfbmRootMethane:=0;
//   if HydroType = hWaterAmmoniaLiquid then
//   begin
//      {.surface temperature influence}
//      FCVfbmVigorCalc:=FCVfbmVigorCalc + FCFfbF_SurfaceTemperaturesModifier_Calculate(
//         300
//         ,Star
//         ,OrbitalObject
//         ,Satellite
//         );
//      {.hydrosphere influence}
//      FCVfbmVigorCalc:=FCVfbmVigorCalc + FCFfbF_HydrosphereModifier_Calculate( HydroArea );
//      {.atmosphere influences}
//      case gasH2 of
//         agsNotPresent: FCVfbmVigorCalc:=FCVfbmVigorCalc - 15;
//
//         agsTrace: FCVfbmVigorCalc:=FCVfbmVigorCalc - 15;
//
//         agsSecondary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 20;
//
//         agsPrimary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 40;
//      end;
//      case gasH2O of
//         agsNotPresent: FCVfbmVigorCalc:=FCVfbmVigorCalc - 20;
//
//         agsSecondary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 20;
//
//         agsPrimary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 40;
//      end;
//      case gasN2 of
//         agsNotPresent: FCVfbmVigorCalc:=FCVfbmVigorCalc - 20;
//
//         agsTrace: FCVfbmVigorCalc:=FCVfbmVigorCalc - 20;
//
//         agsSecondary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 10;
//
//         agsPrimary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 20;
//      end;
//      case gasNH3 of
//         agsNotPresent: FCVfbmVigorCalc:=FCVfbmVigorCalc - 5;
//
//         agsTrace: FCVfbmVigorCalc:=FCVfbmVigorCalc - 5;
//
//         agsSecondary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 10;
//
//         agsPrimary: FCVfbmVigorCalc:=FCVfbmVigorCalc + 30;
//      end;
//      {.tectonic activity influence}
//      case TectonicActivity of
//         taDead: FCVfbmVigorCalc:=FCVfbmVigorCalc -20;
//
//         taHotSpot: FCVfbmVigorCalc:=FCVfbmVigorCalc + 5;
//
//         taPlastic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 10;
//
//         taPlateTectonic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 20;
//
//         taPlateletTectonic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 10;
//      end;
//      {.star luminosity influence}
//      fCalc1:=FCFfbF_StarLuminosityFactor_Calculate(
//         DistanceFromStar
//         ,FCDduStarSystem[0].SS_stars[Star].S_luminosity
//         ,Albedo
//         ,CloudsCover
//         );
//      FCVfbmRootMethane:=round( power( fCalc1, 0.333) );
//      if fCalc1 <= 1912
//      then begin
//         FCVfbmVigorCalc:=FCVfbmVigorCalc + FCFfbF_StarLuminosityVigorMod_Calculate( fCalc1 );
//         if FCVfbmVigorCalc < 1 then
//         begin
//            StageFailed:=true;
//            FCMfB_FossilPresence_Test(
//               Star
//               ,OrbitalObject
//               ,FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
//               ,Satellite
//               );
//         end;
//      end
//      else begin
//         StageFailed:=true;
//         FCMfB_FossilPresence_Test(
//            Star
//            ,OrbitalObject
//            ,FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
//            ,Satellite
//            );
//      end;
//   end
//   else if HydroType in [hNitrogenIceSheet..hNitrogenIceCrust] then
//   begin
//      {.base modifier}
//      FCVfbmVigorCalc:=FCVfbmVigorCalc + 40;
//      {.hydrosphere influence}
//      if HydroType = hNitrogenIceSheet
//      then FCVfbmVigorCalc:=FCVfbmVigorCalc + FCFfbF_HydrosphereModifier_Calculate( round( HydroArea * 1.33 ) )
//      else FCVfbmVigorCalc:=FCVfbmVigorCalc + FCFfbF_HydrosphereModifier_Calculate( HydroArea );
//      {.tectonic activity influence}
//      case TectonicActivity of
//         taHotSpot: FCVfbmVigorCalc:=FCVfbmVigorCalc + 5;
//
//         taPlastic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 10;
//
//         taPlateTectonic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 15;
//
//         taPlateletTectonic: FCVfbmVigorCalc:=FCVfbmVigorCalc + 20;
//      end;
//      if FCVfbmVigorCalc < 1 then
//      begin
//         StageFailed:=true;
//         FCMfB_FossilPresence_Test(
//            Star
//            ,OrbitalObject
//            ,FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
//            ,Satellite
//            );
//      end;
//   end;
   {.final test}
   if not StageFailed then
   begin
      TestVal:=FCFcF_Random_DoInteger( 99 ) + 1;
      if TestVal <= FCVfbmVigorCalc then
      begin
         if Satellite <= 0 then
         begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blMethane_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=FCVfbmVigorCalc;
         end
         else begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blMethane_Prebiotics;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=FCVfbmVigorCalc;
            FCMfbA_MicroOrganismStage_Test(
         end;
      end
      else FCMfM_FossilPresence_Test(
         Star
         ,OrbitalObject
         ,FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
         ,Satellite
         );
   end
   else FCMfB_FossilPresence_Test(
      Star
      ,OrbitalObject
      ,FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
      ,Satellite
      );
end;

end.
