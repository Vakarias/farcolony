{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: Biosphere - core unit

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
unit farc_fug_biosphere;

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
///   generate the basic biosphere's data
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfB_BiosphereBase_Generation(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   test any presence of fossiles
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="StarAge">age of the current star</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfB_FossilPresence_Test(
   const Star
         ,OrbitalObject: integer;
   const StarAge: extended;
   const Satellite: integer=0
   );

implementation

uses
   farc_common_func
   ,farc_data_univ
   ,farc_fug_biosphereammonia
   ,farc_fug_biospherecarbon
   ,farc_fug_biospheremethane
   ,farc_fug_biospheresilicon
   ,farc_fug_biospheresulphurdioxide
   ,farc_fug_stars;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfB_BiosphereBase_Generation(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: generate the basic biosphere's data.
    Additions:
}
   var
      AtmospherePressure
      ,StarAge: extended;

      HasExtremeTectonic
      ,HasSubsurfaceOcean: boolean;

      ObjectType: TFCEduOrbitalObjectTypes;

      HydroType: TFCEduHydrospheres;

      gasCH4
      ,gasCO2
      ,gasH2
      ,gasH2O
      ,gasH2S
      ,gasN2
      ,gasNH3
      ,gasNO2
      ,gasO2
      ,gasSO2: TFCEduAtmosphericGasStatus;

   procedure _Biochemistry_Branching;
   begin
      {.methane-based branching}
      if ( ( HydroType = hMethaneLiquid ) and ( ( gasN2 = agsPrimary ) or ( gasCH4 >= agsSecondary ) ) )
         or ( ( HasSubsurfaceOcean ) and ( HydroType in [hMethaneIceSheet..hMethaneIceCrust] ) )
      then FCMfbM_PrebioticsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         )
      {.ammonia-based branching}
      else if ( ( HydroType = hWaterAmmoniaLiquid ) and ( ( gasH2 = agsPrimary ) or ( gasN2 = agsPrimary ) or ( gasNH3 >= agsSecondary ) ) and ( gasO2 <= agsTrace ) )
         or ( ( HasSubsurfaceOcean ) and ( HydroType in [hNitrogenIceSheet..hNitrogenIceCrust] ) )
      then FCMfbA_PrebioticsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         )
      {.silicon-based branching}
      else if ( ( HydroType = hNoHydro ) or ( ( not HasSubsurfaceOcean ) and ( ( HydroType in [hWaterIceSheet..hWaterIceCrust] ) or ( HydroType in [hMethaneIceSheet..hNitrogenIceCrust] ) ) ) )
         and ( ( gasH2 >= agsSecondary ) or ( gasSO2 >= agsSecondary ) )
         and ( gasO2 <= agsTrace )
      then FCMfbS_PrebioticsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         )
      {.sulphur dioxide-based branching}
      else if ( ( HydroType = hNoHydro ) and ( gasH2S >= agsSecondary ) )
         or ( ( HydroType = hWaterLiquid ) and ( ( gasNO2 = agsPrimary ) or ( gasSO2 = agsPrimary ) ) )
      then FCMfbsD_PrebioticsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         )
      {.carbon-based branching}
      else if ( ( HydroType = hWaterLiquid ) and ( ( gasN2 = agsPrimary ) or ( gasCO2 >= agsSecondary ) or ( gasH2O >= agsSecondary ) ) )
         or ( ( HasSubsurfaceOcean ) and ( HydroType in [hWaterIceSheet..hWaterIceCrust] ) )
      then FCMfbC_PrebioticsStage_Test(
         Star
         ,OrbitalObject
         ,Satellite
         );
   end;
begin
   AtmospherePressure:=0;
   StarAge:=0;

   HasExtremeTectonic:=false;
   HasSubsurfaceOcean:=false;

   ObjectType:=ootNone;

   HydroType:=hNoHydro;

   gasCH4:=agsNotPresent;
   gasCO2:=agsNotPresent;
   gasH2:=agsNotPresent;
   gasH2O:=agsNotPresent;
   gasH2S:=agsNotPresent;
   gasN2:=agsNotPresent;
   gasNH3:=agsNotPresent;
   gasNO2:=agsNotPresent;
   gasO2:=agsNotPresent;
   gasSO2:=agsNotPresent;

   if Satellite <= 0 then
   begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blNone;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor:=0;
      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure;
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type;
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      HasSubsurfaceOcean:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_subsurfaceOcean;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity = taExtreme
      then HasExtremeTectonic:=true;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure > 0 then
      begin
         gasCH4:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4;
         gasCO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2;
         gasH2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2;
         gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O;
         gasH2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S;
         gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2;
         gasNH3:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3;
         gasNO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2;
         gasO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceO2;
         gasSO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2;
      end;
   end
   else begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blNone;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor:=0;
      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure;
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_type;
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      HasSubsurfaceOcean:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_subsurfaceOcean;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity = taExtreme
      then HasExtremeTectonic:=true;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure > 0 then
      begin
         gasCH4:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4;
         gasCO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2;
         gasH2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2;
         gasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O;
         gasH2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S;
         gasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2;
         gasNH3:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3;
         gasNO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2;
         gasO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceO2;
         gasSO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2;
      end;
   end;
   StarAge:=FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
   if AtmospherePressure <= 0 then
   begin
      if ( ObjectType = ootPlanet_Telluric )
         or ( ObjectType = ootSatellite_Planet_Telluric )
      then FCMfB_FossilPresence_Test(
         Star
         ,OrbitalObject
         ,Satellite
         )
      else if ( ( ObjectType = ootPlanet_Icy ) or ( ObjectType = ootSatellite_Planet_Icy ) )
         and ( not HasSubsurfaceOcean )
      then FCMfB_FossilPresence_Test(
         Star
         ,OrbitalObject
         ,Satellite
         )
      else if ( ( ObjectType = ootPlanet_Icy ) or ( ObjectType = ootSatellite_Planet_Icy ) )
         and ( HasSubsurfaceOcean )
      then _Biochemistry_Branching;
   end
   else begin
      if StarAge <= 0.1
      then FCMfB_FossilPresence_Test(
         Star
         ,OrbitalObject
         ,Satellite
         )
      else if HasExtremeTectonic
      then FCMfB_FossilPresence_Test(
         Star
         ,OrbitalObject
         ,Satellite
         )
      else _Biochemistry_Branching;
   end;
end;

procedure FCMfB_FossilPresence_Test(
   const Star
         ,OrbitalObject: integer;
   const StarAge: extended;
   const Satellite: integer=0
   );
{:Purpose: test any presence of fossiles.
    Additions:
}
   var
      X
      ,Y: integer;

      ObjectType: TFCEduOrbitalObjectTypes;
begin
   X:=0;
   Y:=0;

   ObjectType:=ootNone;

   if Satellite <= 0
   then ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type
   else ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_type;
   if ( ( ObjectType = ootPlanet_Telluric ) or ( ObjectType = ootSatellite_Planet_Telluric ) )
      and ( StarAge >= 1 ) then
   begin
      if FCDduStarSystem[0].SS_stars[Star].S_class >= WD0
      then X:=50
      else X:=30;
      Y:=FCFcF_Random_DoInteger( 99 ) + 1;
      if Y <= X then
      begin
         if Satellite <= 0
         then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel:=blFossils
         else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel:=blFossils;
      end;
   end;
end;

end.
