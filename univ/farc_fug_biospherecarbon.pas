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
   farc_data_univ
   ,farc_fug_biospherefunctions
   ,farc_fug_data;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
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
      HydroArea: integer;

      StageFailed: boolean;

      HydroType: TFCEduHydrospheres;

      gasCO2
      ,gasH2O
      ,gasN2: TFCEduAtmosphericGasStatus;
begin
   HydroArea:=0;

   HydroType:=hNoHydro;

   gasCO2:=agsNotPresent;
   gasH2O:=agsNotPresent;
   gasN2:=agsNotPresent;

   if Satellite <= 0 then
   begin
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      gasCO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2;
      gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2;
   end
   else begin
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      gasCO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2;
      gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O;
      gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2;
   end;
   StageFailed:=false;
   FCVfbcVigorCalc:=0;
   if HydroType = hWaterLiquid then
   begin
      FCVfbcVigorCalc:=FCVfbcVigorCalc + FCFfbF_SurfaceTemperaturesModifier_Calculate(
         373.85
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      FCVfbcVigorCalc:=FCVfbcVigorCalc + FCFfbF_HydrosphereModifier_Calculate( HydroArea );
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
   end
   else if HydroType in [hWaterIceSheet..hWaterIceCrust] then
   begin
   end;
end;

end.
