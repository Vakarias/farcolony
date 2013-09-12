{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: Regions - land and resources unit

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
unit farc_fug_landresources;

interface

uses
   Math
   ,SysUtils

   ,farc_data_univ;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   return the rarity index based on its value
///</summary>
///   <param name="Value">rarity value</param>
///   <returns></returns>
///   <remarks></remarks>
function FCFfR__RarityIndex_Set(const Value: extended): TFCEduResourceSpotRarity;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   generate the land type and relief for each region
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfR_LandRelief_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   first phase of the calculations of the resources. Gas field isn't processed in this phase (it needs the biosphere data)
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfR_Resources_Phase1(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   final phase of the calculations of the resources. Gas field is processed in this phase
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfR_Resources_Phase2(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

implementation

uses
   farc_common_func
   ,farc_data_init
   ,farc_fug_data
   ,farc_fug_regionsClimate
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFfR__RarityIndex_Set(const Value: extended): TFCEduResourceSpotRarity;
{:Purpose: return the rarity index based on its value.
    Additions:
}
begin
   Result:=rsrAbsent;
   if ( Value > 0 )
      and ( Value <= 8 )
   then Result:=rsrRare
   else if ( Value > 8 )
      and ( Value <= 17 )
   then Result:=rsrUncommon
   else if ( Value > 17 )
      and ( Value <= 35 )
   then Result:=rsrPresent
   else if ( Value > 35 )
      and ( Value <= 60 )
   then Result:=rsrCommon
   else if ( Value > 60 )
      and ( Value <= 81 )
   then Result:=rsrAbundant
   else if Value > 81
   then Result:=rsrRich;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMfR_LandRelief_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: generate the land type and relief for each region.
   Additions:
      -2013Sep11- *fix: asteroids with a hydrosphere of Water/Methane or Nitrogen Ice Crust have now 100% polar or icy sterile regions, whatever the kind of asteroid.
                  *mod: trace atmosphere objects are now affected by the same subsection than the 0 atmosphere planets.
      -2013Sep09- *mod: orbital objects with a tectonic activity < platelet tectonic have now far lesser chance to generate a volcanic region.
                  *fix: bad data assignation in _TectonicActivityMod_Set.
      -2013Aug29- *mod: adjustments for the relief of Icy Sterile land.
      -2013Aug27- *add: adjustment for the GravModifier.
      -2013Aug22- *add: adjustments for the relief.
                  *fix: mislocated the data loading code.
      -2013Aug18- *add: forgot to add the data loading in the region's data structure of the selected orbital object.
}
var
   GravModifier
   ,HydroArea
   ,Max
   ,Proba
   ,Region
   ,TectonicActivityMod: integer;

   isAtmosphere
   ,isTraceAtm: boolean;

   HydroType: TFCEduHydrospheres;

   ObjectType: TFCEduOrbitalObjectTypes;

   TectonicActivity: TFCEduTectonicActivity;

   function _ReliefRule_Set( const minValue, medValue: integer ): TFCEduRegionReliefs;
      var
         iCalc: integer;
   {:Purpose: set the relief. Put medValue to 0 to prevent moutainous relief.
   }
   begin
      Result:=rr1Plain;
      iCalc:=FCFcF_Random_DoInteger( 99 ) + 1 + GravModifier;
      if iCalc <= minValue
      then Result:=rr1Plain
      else if medValue=0
      then Result:=rr4Broken
      else if ( medValue > 0 )
         and ( iCalc > minValue )
         and ( iCalc <= medValue )
      then Result:=rr4Broken
      else Result:=rr9Mountain;
   end;

   procedure _TectonicActivityMod_Set( const TectonicActivityType: TFCEduTectonicActivity );
   begin
      case TectonicActivityType of
         taHotSpot: TectonicActivityMod:=5;

         taPlastic: TectonicActivityMod:=10;

         taPlateTectonic: TectonicActivityMod:=15;

         taPlateletTectonic: TectonicActivityMod:=45;

         taExtreme: TectonicActivityMod:=90;
      end;
      TectonicActivity:=TectonicActivityType;
   end;

   procedure _VolcanicReliefModification_Apply( const RegionIndex: integer );
      var
         iCalc: integer;
   begin
      iCalc:=FCFcF_Random_DoInteger( 99 ) + 1;
      if iCalc <= FCDfdRegions[Region].RC_tectonicActivityMod then
      begin
         FCDfdRegions[Region].RC_landType:=rst03Volcanic;
         FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 10, 50 );
         if ( FCDfdRegions[Region].RC_reliefType=rr1Plain )
            and ( TectonicActivity < taPlateTectonic )
         then FCDfdRegions[Region].RC_reliefType:=rr4Broken
         else if ( FCDfdRegions[Region].RC_reliefType=rr4Broken )
            and ( TectonicActivity < taPlateTectonic )
         then FCDfdRegions[Region].RC_reliefType:=rr9Mountain;
      end;
   end;
begin
   GravModifier:=0;
   HydroArea:=0;
   Max:=0;
   Proba:=0;
   Region:=0;

   TectonicActivityMod:=0;

   isAtmosphere:=false;
   isTraceAtm:=false;

   HydroType:=hNoHydro;

   ObjectType:=ootNone;

   TectonicActivity:=taNull;
   if Satellite = 0 then
   begin
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity <> 1
      then GravModifier:=round( ln( 1 / FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity ) * 2.5 )
      else GravModifier:=0;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure > 0
      then isAtmosphere:=true;
      isTraceAtm:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_traceAtmosphere;
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions ) - 1;
      _TectonicActivityMod_Set( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity );
   end
   else if Satellite > 0 then
   begin
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_type;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravity <> 1
      then GravModifier:=round( ln( 1 / FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravity ) * 10 ) - 10
      else GravModifier:=0;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure > 0
      then isAtmosphere:=true;
      isTraceAtm:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_traceAtmosphere;
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions ) - 1;
      _TectonicActivityMod_Set( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity );
   end;
   Region:=1;
   while Region <= Max do
   begin
      FCDfdRegions[Region].RC_landType:=rst01RockyDesert;
      FCDfdRegions[Region].RC_reliefType:=rr1Plain;
      if TectonicActivityMod > 0
      then FCDfdRegions[Region].RC_tectonicActivityMod:=round( randg( TectonicActivityMod, 5 ) );
      FCDfdRegions[Region].RC_surfaceTemperatureMean:=( FCDfdRegions[Region].RC_surfaceTemperatureClosest + FCDfdRegions[Region].RC_surfaceTemperatureInterm + FCDfdRegions[Region].RC_surfaceTemperatureFarthest ) / 3;
      if ( ( ObjectType >= ootAsteroid_Metallic ) and ( ObjectType <= ootAsteroid_Icy ) ) or ( ( ObjectType >= ootSatellite_Asteroid_Metallic ) and ( ObjectType <= ootSatellite_Asteroid_Icy ) ) then
      begin
         if ( HydroType = hWaterIceSheet )
            or ( HydroType = hMethaneIceSheet )
            or ( HydroType = hNitrogenIceSheet ) then
         begin
            if FCDfdRegions[Region].RC_surfaceTemperatureMean <= 125 then
            begin
               FCDfdRegions[Region].RC_landType:=rst15icySterile;
               FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 30, 70 );
            end
            else begin
               Proba:=FCFcF_Random_DoInteger( 99 ) + 1;
               if Proba <= HydroArea then
               begin
                  FCDfdRegions[Region].RC_landType:=rst15icySterile;
                  FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 30, 70 );
               end
               else begin
                  FCDfdRegions[Region].RC_landType:=rst14Sterile;
                  FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 20, 60 );
               end;
            end;
         end
         else if ( HydroType<> hWaterIceCrust )
            and ( HydroType<> hMethaneIceCrust )
            and ( HydroType<> hNitrogenIceCrust ) then
         begin
            FCDfdRegions[Region].RC_landType:=rst14Sterile;
            FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 30, 0 );
         end
         else begin
            FCDfdRegions[Region].RC_landType:=rst15icySterile;
            FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 40, 0 );
         end;
      end
      else if ( ( ( ObjectType >= ootPlanet_Telluric ) and ( ObjectType < ootPlanet_Gaseous_Uranus ) ) or ( ObjectType >= ootSatellite_Planet_Telluric ) )
         and ( ( not isAtmosphere ) or ( isTraceAtm ) ) then
      begin
         if HydroType = hNoHydro then
         begin
            FCDfdRegions[Region].RC_landType:=rst14Sterile;
            FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 20, 60 );
            _VolcanicReliefModification_Apply( Region );
         end
         else if ( HydroType = hWaterIceSheet )
            or ( HydroType = hMethaneIceSheet )
            or ( HydroType = hNitrogenIceSheet ) then
         begin
            if FCDfdRegions[Region].RC_surfaceTemperatureMean <= 125 then
            begin
               FCDfdRegions[Region].RC_landType:=rst15icySterile;
               FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 30, 70 );
            end
            else begin
               Proba:=FCFcF_Random_DoInteger( 99 ) + 1;
               if Proba <= HydroArea then
               begin
                  FCDfdRegions[Region].RC_landType:=rst15icySterile;
                  FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 30, 70 );
               end
               else begin
                  FCDfdRegions[Region].RC_landType:=rst14Sterile;
                  FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 20, 60 );
               end;
            end;
            _VolcanicReliefModification_Apply( Region );
         end
         else if ( HydroType = hWaterIceCrust )
            or ( HydroType = hMethaneIceCrust )
            or ( HydroType = hNitrogenIceCrust ) then
         begin
            FCDfdRegions[Region].RC_landType:=rst15icySterile;
            FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 30, 70 );
            _VolcanicReliefModification_Apply( Region );
         end;
      end
      else if ( ( ( ObjectType >= ootPlanet_Telluric ) and ( ObjectType < ootPlanet_Gaseous_Uranus ) ) or ( ObjectType >= ootSatellite_Planet_Telluric ) )
         and ( isAtmosphere )
         and ( not isTraceAtm ) then
      begin
         FCDfdRegions[Region].RC_regionPressureMean:=( FCDfdRegions[Region].RC_regionPressureClosest + FCDfdRegions[Region].RC_regionPressureInterm + FCDfdRegions[Region].RC_regionPressureFarthest ) / 3;
         case FCDfdRegions[Region].RC_finalClimate of
            rc01VeryHotHumid, rc02VeryHotSemiHumid:
            begin
               FCDfdRegions[Region].RC_landType:=rst06Fertile;
               FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 40, 85 );
            end;

            rc03HotSemiArid:
            begin
               if FCDfdRegions[Region].RC_regionPressureMean <= 36 then
               begin
                  FCDfdRegions[Region].RC_landType:=rst05Arid;
                  FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 20, 70 );
               end
               else begin
                  FCDfdRegions[Region].RC_landType:=rst06Fertile;
                  FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 40, 85 );
               end;
            end;

            rc04HotArid:
            begin
               if FCDfdRegions[Region].RC_regionPressureMean < 15 then
               begin
                  FCDfdRegions[Region].RC_landType:=rst02SandyDesert;
                  FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 40, 0 );
               end
               else begin
                  FCDfdRegions[Region].RC_landType:=rst01RockyDesert;
                  FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 50, 85 );
               end;
            end;

            rc05ModerateHumid:
            begin
               FCDfdRegions[Region].RC_landType:=rst06Fertile;
               FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 40, 85 );
            end;

            rc06ModerateDry:
            begin
               if FCDfdRegions[Region].RC_regionPressureMean < 30 then
               begin
                  FCDfdRegions[Region].RC_landType:=rst05Arid;
                  FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 20, 70 );
               end
               else begin
                  FCDfdRegions[Region].RC_landType:=rst06Fertile;
                  FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 40, 85 );
               end;
            end;

            rc07ColdArid:
            begin
               FCDfdRegions[Region].RC_landType:=rst01RockyDesert;
               FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 50, 85 );
            end;

            rc08Periarctic:
            begin
               FCDfdRegions[Region].RC_landType:=rst05Arid;
               FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 20, 70 );
            end;

            rc09Arctic:
            begin
               FCDfdRegions[Region].RC_landType:=rst04Polar;
               FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 30, 80 );
            end;

            rc10Extreme:
            begin
               FCDfdRegions[Region].RC_landType:=rst01RockyDesert;
               FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 50, 85 );
            end;
         end; //==END== case FCDfdRegions[Region].RC_finalClimate of ==//
         _VolcanicReliefModification_Apply( Region );
      end; //==END== else of: ( ( ( ObjectType >= oot_Planet_Telluric ) and ( ObjectType < ootPlanet_Gaseous_Uranus ) ) or ( ObjectType >= ootSatellite_Planet_Telluric ) ) and ( isAtmosphere ) ==//
      if Satellite = 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_landType:=FCDfdRegions[Region].RC_landType;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_relief:=FCDfdRegions[Region].RC_reliefType;
      end
      else if Satellite > 0 then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_landType:=FCDfdRegions[Region].RC_landType;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_relief:=FCDfdRegions[Region].RC_reliefType;
      end;
      inc( Region );
   end; //==END== while Region <= Max ==//
end;

procedure FCMfR_Resources_Phase1(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: first phase of the calculations of the resources. Gas field isn't processed in this phase (it needs the biosphere data).
    Additions:
      -2013Sep04- *fix: corrections with the use of the minimal value of TectonicActivyIndex.
}
   var
      Count
      ,HydroArea
      ,Max
      ,Region
      ,Spot
      ,TectonicActivityIndex: integer;

      DensityCoef
      ,DiamRed
      ,fCalc1
      ,RandgStdev
      ,RarityValue
      ,RsrcPotential: extended;

      hasaSubsurfaceOcean
      ,isAtmosphere
      ,istraceAtm: boolean;

      ObjectType: TFCEduOrbitalObjectTypes;

      HydroType: TFCEduHydrospheres;

      NatureCoef: array [1..4] of extended;

      procedure _OreNatureCoefficients_Set( const ObjectType: TFCEduOrbitalObjectTypes );
      begin
         if ( ObjectType = ootAsteroid_Metallic )
            or ( ObjectType = ootSatellite_Asteroid_Metallic ) then
         begin
            NatureCoef[1]:=-10;
            NatureCoef[2]:=25;
            NatureCoef[3]:=-27.5;
            NatureCoef[4]:=-5;
         end
         else if ( ObjectType = ootAsteroid_Silicate )
            or ( ObjectType = ootSatellite_Asteroid_Silicate ) then
         begin
            NatureCoef[1]:=7.5;
            NatureCoef[2]:=17.5;
            NatureCoef[3]:=-10;
            NatureCoef[4]:=-7.5;
         end
         else if ( ObjectType = ootAsteroid_Carbonaceous )
            or ( ObjectType = ootSatellite_Asteroid_Carbonaceous ) then
         begin
            NatureCoef[1]:=25;
            NatureCoef[2]:=10;
            NatureCoef[3]:=-20;
            NatureCoef[4]:=-10;
         end
         else if ( ObjectType = ootAsteroid_Icy )
            or ( ObjectType = ootSatellite_Asteroid_Icy )
            or ( ObjectType = ootPlanet_Icy )
            or ( ObjectType = ootSatellite_Planet_Icy ) then
         begin
            NatureCoef[1]:=10;
            NatureCoef[2]:=-5;
            NatureCoef[3]:=-25;
            NatureCoef[4]:=-20;
         end
         else if ( ObjectType = ootPlanet_Telluric )
            or ( ObjectType = ootSatellite_Planet_Telluric ) then
         begin
            NatureCoef[1]:=7.5;
            NatureCoef[2]:=17.5;
            NatureCoef[3]:=-19.1;
            NatureCoef[4]:=-7.5;
         end;
      end;

begin
   Count:=0;
   HydroArea:=0;
   Max:=0;
   TectonicActivityIndex:=0;

   DensityCoef:=0;
   DiamRed:=0;

   hasaSubsurfaceOcean:=false;
   isAtmosphere:=false;
   istraceAtm:=false;

   ObjectType:=ootNone;

   HydroType:=hNoHydro;

   NatureCoef[1]:=0;
   NatureCoef[2]:=0;
   NatureCoef[3]:=0;
   NatureCoef[4]:=0;

   if Satellite = 0 then
   begin
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type;
      if ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure > 0 )
         and ( not FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_traceAtmosphere )
      then isAtmosphere:=true;
      istraceAtm:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_traceAtmosphere;
      DensityCoef:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_density / 551.5;
      DiamRed:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_diameter * 0.002;
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      TectonicActivityIndex:=integer( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity );
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions ) - 1;
   end
   else if Satellite > 0 then
   begin
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_type;
      if ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure > 0 )
         and ( not FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_traceAtmosphere )
      then isAtmosphere:=true;
      istraceAtm:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_traceAtmosphere;
      DensityCoef:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_density / 551.5;
      DiamRed:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_diameter * 0.002;
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      TectonicActivityIndex:=integer( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity );
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions ) - 1;
   end;
   _OreNatureCoefficients_Set( ObjectType );
   Spot:=0;
   Region:=1;
   while Region <= Max do
   begin
      Spot:=0;
      setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
      {.hydrosphere locations}
      {:DEV NOTES:
         fCalc1: land/relief coefficient
      .}
      if ( HydroType = hWaterLiquid )
         or ( HydroType = hWaterAmmoniaLiquid )
         or ( HydroType = hMethaneLiquid ) then
      begin
         inc( Spot );
         setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         fCalc1:=1;
         RsrcPotential:=0;
         RarityValue:=0;
         if ( FCDfdRegions[Region].RC_landType = rst01RockyDesert )
            or ( FCDfdRegions[Region].RC_landType = rst08CoastalRockyDesert ) then
         begin
            case FCDfdRegions[Region].RC_reliefType of
               rr1Plain: fCalc1:= 0.5;

               rr4Broken: fCalc1:= 0.35;

               rr9Mountain: fCalc1:= 0.2;
            end;
         end
         else if ( FCDfdRegions[Region].RC_landType = rst02SandyDesert )
            or ( FCDfdRegions[Region].RC_landType = rst09CoastalSandyDesert ) then
         begin
            case FCDfdRegions[Region].RC_reliefType of
               rr1Plain: fCalc1:= 0.25;

               rr4Broken: fCalc1:= 0.175;

               rr9Mountain: fCalc1:= 0.1;
            end;
         end
         else if ( FCDfdRegions[Region].RC_landType = rst03Volcanic )
            or ( FCDfdRegions[Region].RC_landType = rst10CoastalVolcanic ) then
         begin
            case FCDfdRegions[Region].RC_reliefType of
               rr1Plain: fCalc1:= 0.1;

               rr4Broken: fCalc1:= 0.07;

               rr9Mountain: fCalc1:= 0.04;
            end;
         end
         else if ( FCDfdRegions[Region].RC_landType = rst04Polar )
            or ( FCDfdRegions[Region].RC_landType = rst11CoastalPolar ) then
         begin
            case FCDfdRegions[Region].RC_reliefType of
               rr1Plain: fCalc1:= 1;

               rr4Broken: fCalc1:= 0.7;

               rr9Mountain: fCalc1:= 0.4;
            end;
         end
         else if ( FCDfdRegions[Region].RC_landType = rst05Arid )
            or ( FCDfdRegions[Region].RC_landType = rst12CoastalArid ) then
         begin
            case FCDfdRegions[Region].RC_reliefType of
               rr1Plain: fCalc1:= 0.5;

               rr4Broken: fCalc1:= 0.35;

               rr9Mountain: fCalc1:= 0.2;
            end;
         end
         else if ( FCDfdRegions[Region].RC_landType = rst06Fertile )
            or ( FCDfdRegions[Region].RC_landType = rst13CoastalFertile ) then
         begin
            case FCDfdRegions[Region].RC_reliefType of
               rr1Plain: fCalc1:= 1.5;

               rr4Broken: fCalc1:= 1.05;

               rr9Mountain: fCalc1:= 0.6;
            end;
         end
         else fCalc1:=0;
         RsrcPotential:=HydroArea * fCalc1;
         if RsrcPotential <= 0 then
         begin
            dec( Spot );
            setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         end
         else begin
            RandgStdev:=FCFcF_Round( rttCustom1Decimal, RsrcPotential * 0.1 ) * 2;
            RarityValue:=randg( RsrcPotential, RandgStdev );
            if RarityValue <= 0 then
            begin
               dec( Spot );
               setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
            end
            else begin
               if RarityValue > 100
               then RarityValue:=100;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstHydroWell;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=FCFfR__RarityIndex_Set( RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality:=rsqNone;
            end;
         end;
      end;

      {.icy ore field}
      if ( HydroType in [hWaterIceSheet..hWaterIceCrust] )
         or ( HydroType >= hMethaneIceSheet ) then
      begin
         inc( Spot );
         setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         RsrcPotential:=0;
         RarityValue:=0;
         RsrcPotential:=HydroArea;
         if RsrcPotential <= 0 then
         begin
            dec( Spot );
            setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         end
         else begin
            RandgStdev:=FCFcF_Round( rttCustom1Decimal, RsrcPotential * 0.1 ) * 2;
            RarityValue:=randg( RsrcPotential, RandgStdev );
            if RarityValue <= 0 then
            begin
               dec( Spot );
               setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
            end
            else begin
               if RarityValue > 100
               then RarityValue:=100;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstIcyOreField;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=FCFfR__RarityIndex_Set( RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality:=rsqNone;
            end;
         end;
      end;

      {.carbonaceous ore field}
      inc( Spot );
      setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
      RsrcPotential:=0;
      RarityValue:=0;
      RsrcPotential:=DiamRed + DensityCoef - NatureCoef[1] + sqr( TectonicActivityIndex - 1 );
      if RsrcPotential <= 0 then
      begin
         dec( Spot );
         setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
      end
      else begin
         RandgStdev:=FCFcF_Round( rttCustom1Decimal, RsrcPotential * 0.1 ) * 2;
         case FCDfdRegions[Region].RC_landType of
            rst01RockyDesert: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst02SandyDesert: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst03Volcanic: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst04Polar: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

            rst05Arid..rst10CoastalVolcanic: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst11CoastalPolar: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

            rst12CoastalArid..rst14Sterile: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst15icySterile: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );
         end;
         if RarityValue <= 0 then
         begin
            dec( Spot );
            setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         end
         else begin
            if RarityValue > 100
            then RarityValue:=100;
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstOreFieldCarbo;
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=FCFfR__RarityIndex_Set( RarityValue );
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality:=rsqNone;
         end;
      end;

      {.metallic ore field}
      inc( Spot );
      setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
      RsrcPotential:=0;
      RarityValue:=0;
      RsrcPotential:=DiamRed + DensityCoef + NatureCoef[2] + sqr( TectonicActivityIndex - 1 );
      if RsrcPotential <= 0 then
      begin
         dec( Spot );
         setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
      end
      else begin
         RandgStdev:=FCFcF_Round( rttCustom1Decimal, RsrcPotential * 0.1 ) * 2;
         case FCDfdRegions[Region].RC_landType of
            rst01RockyDesert: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst02SandyDesert: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

            rst03Volcanic: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst04Polar: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

            rst05Arid: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst06Fertile: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

            rst07Oceanic: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst08CoastalRockyDesert..rst13CoastalFertile: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst14Sterile: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst15icySterile: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );
         end;
         if RarityValue <= 0 then
         begin
            dec( Spot );
            setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         end
         else begin
            if RarityValue > 100
            then RarityValue:=100;
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstOreFieldMetal;
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=FCFfR__RarityIndex_Set( RarityValue );
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality:=rsqNone;
         end;
      end;

      {.rare metals ore field}
      inc( Spot );
      setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
      RsrcPotential:=0;
      RarityValue:=0;
      RsrcPotential:=DiamRed + DensityCoef - NatureCoef[3] + sqr( TectonicActivityIndex - 1 );
      if RsrcPotential <= 0 then
      begin
         dec( Spot );
         setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
      end
      else begin
         RandgStdev:=FCFcF_Round( rttCustom1Decimal, RsrcPotential * 0.1 ) * 2;
         case FCDfdRegions[Region].RC_landType of
            rst01RockyDesert..rst02SandyDesert: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst03Volcanic: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst04Polar: RarityValue:=0;

            rst05Arid: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst06Fertile: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst07Oceanic..rst09CoastalSandyDesert: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

            rst10CoastalVolcanic: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst11CoastalPolar: RarityValue:=0;

            rst12CoastalArid: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

            rst13CoastalFertile: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst14Sterile..rst15icySterile: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );
         end;
         if RarityValue <= 0 then
         begin
            dec( Spot );
            setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         end
         else begin
            if RarityValue > 100
            then RarityValue:=100;
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstOreFieldRareMetal;
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=FCFfR__RarityIndex_Set( RarityValue );
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality:=rsqNone;
         end;
      end;

      {.uranium ore field}
      inc( Spot );
      setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
      RsrcPotential:=0;
      RarityValue:=0;
      RsrcPotential:=DiamRed + DensityCoef - NatureCoef[4] + sqr( TectonicActivityIndex - 1 );
      if FCDduStarSystem[0].SS_stars[Star].S_class >= PSR
      then RsrcPotential:=RsrcPotential * ( 1 +( FCFcF_Random_DoFloat * 0.5 ) );
      if RsrcPotential <= 0 then
      begin
         dec( Spot );
         setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
      end
      else begin
         RandgStdev:=FCFcF_Round( rttCustom1Decimal, RsrcPotential * 0.1 ) * 2;
         case FCDfdRegions[Region].RC_landType of
            rst01RockyDesert: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst02SandyDesert: RarityValue:=0;

            rst03Volcanic: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst04Polar: RarityValue:=0;

            rst05Arid: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst06Fertile..rst08CoastalRockyDesert: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst09CoastalSandyDesert..rst11CoastalPolar: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

            rst12CoastalArid..rst13CoastalFertile: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst14Sterile:
            begin
               if FCDduStarSystem[0].SS_stars[Star].S_class >= PSR
               then RarityValue:=randg( RsrcPotential * 1.25, RandgStdev )
               else RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );
            end;

            rst15icySterile:
            begin
               if FCDduStarSystem[0].SS_stars[Star].S_class >= PSR
               then RarityValue:=randg( RsrcPotential, RandgStdev )
               else RarityValue:=randg( RsrcPotential * 0.5, RandgStdev );
            end;
         end;
         if RarityValue <= 0 then
         begin
            dec( Spot );
            setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         end
         else begin
            if RarityValue > 100
            then RarityValue:=100;
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstOreFieldUran;
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=FCFfR__RarityIndex_Set( RarityValue );
            FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality:=rsqNone;
         end;
      end;

      {.underground water}
      {:DEV NOTES:
         fCalc1: mean relative humidity
      .}
      if ( HydroType = hWaterLiquid )
         or ( HydroType = hWaterAmmoniaLiquid )
         or ( HydroType = hMethaneLiquid ) then
      begin
         inc( Spot );
         setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         fCalc1:=0;
         RsrcPotential:=0;
         RarityValue:=0;
         fCalc1:=( FCDfdRegions[Region].RC_relativeHumidityClosest + FCDfdRegions[Region].RC_relativeHumidityInterm + FCDfdRegions[Region].RC_relativeHumidityFarthest ) / 300;
         RsrcPotential:=HydroArea * 0.01 * fCalc1;
         if RsrcPotential <= 0 then
         begin
            dec( Spot );
            setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         end
         else begin
            RandgStdev:=FCFcF_Round( rttCustom1Decimal, RsrcPotential * 0.1 ) * 2;
            case FCDfdRegions[Region].RC_landType of
               rst01RockyDesert..rst02SandyDesert: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

               rst03Volcanic: RarityValue:=0;

               rst04Polar: RarityValue:=randg( RsrcPotential, RandgStdev );

               rst05Arid: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

               rst06Fertile: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

               rst07Oceanic: RarityValue:=0;

               rst08CoastalRockyDesert..rst09CoastalSandyDesert: RarityValue:=randg( RsrcPotential, RandgStdev );

               rst10CoastalVolcanic: RarityValue:=0;

               rst11CoastalPolar: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

               rst12CoastalArid: RarityValue:=randg( RsrcPotential, RandgStdev );

               rst13CoastalFertile: RarityValue:=randg( RsrcPotential * 1.5, RandgStdev );

               rst14Sterile..rst15icySterile: RarityValue:=0;
            end;
            if RarityValue <= 0 then
            begin
               dec( Spot );
               setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
            end
            else begin
               if RarityValue > 100
               then RarityValue:=100;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstUnderWater;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=FCFfR__RarityIndex_Set( RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality:=rsqNone;
            end;
         end;
      end
      else if ( HydroType = hWaterIceSheet )
         or ( HydroType = hWaterIceCrust )
         or ( HydroType = hMethaneIceSheet )
         or ( HydroType = hMethaneIceCrust )
         or ( HydroType = hNitrogenIceSheet )
         or ( HydroType = hNitrogenIceCrust ) then
      begin
         inc( Spot );
         setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         fCalc1:=0;
         RsrcPotential:=0;
         RarityValue:=0;
         if ( ( not isAtmosphere ) or ( istraceAtm ) )
            and ( TectonicActivityIndex > 1 )
            and ( TectonicActivityIndex < 6 ) then
         begin
            fCalc1:=( TectonicActivityIndex - 1 ) * 10;
         end
         else if isAtmosphere then
         begin
            fCalc1:=( FCDfdRegions[Region].RC_relativeHumidityClosest + FCDfdRegions[Region].RC_relativeHumidityInterm + FCDfdRegions[Region].RC_relativeHumidityFarthest ) / 300;
         end;
         {.special case for subsurface ocean}
         if ( ( ObjectType = ootPlanet_Icy ) or ( ObjectType = ootSatellite_Planet_Icy ) )
            and ( TectonicActivityIndex > 1 )
            and ( TectonicActivityIndex < 6 ) then
         begin
            hasaSubsurfaceOcean:=true;
            fCalc1:=( TectonicActivityIndex - 1 ) * 25;
         end;
         if fCalc1 <= 0 then
         begin
            dec( Spot );
            setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         end
         else begin
            RsrcPotential:=HydroArea * 0.01 * fCalc1;
            RandgStdev:=FCFcF_Round( rttCustom1Decimal, RsrcPotential * 0.1 ) * 2;
            case FCDfdRegions[Region].RC_landType of
               rst01RockyDesert..rst02SandyDesert: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

               rst03Volcanic:
               begin
                  if not hasaSubsurfaceOcean
                  then RarityValue:=0
                  else RarityValue:=randg( RsrcPotential, RandgStdev );
               end;

               rst04Polar: RarityValue:=randg( RsrcPotential, RandgStdev );

               rst05Arid: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

               rst06Fertile: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

               rst14Sterile:
               begin
                  if not hasaSubsurfaceOcean
                  then RarityValue:=randg( RsrcPotential * 0.25, RandgStdev )
                  else RarityValue:=randg( RsrcPotential * 0.5, RandgStdev );
               end;

               rst15icySterile:
               begin
                  if not hasaSubsurfaceOcean
                  then RarityValue:=randg( RsrcPotential * 0.5, RandgStdev )
                  else RarityValue:=randg( RsrcPotential, RandgStdev );
               end;
            end;
            if RarityValue <= 0 then
            begin
               dec( Spot );
               setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
            end
            else begin
               if RarityValue > 100
               then RarityValue:=100;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstUnderWater;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=FCFfR__RarityIndex_Set( RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality:=rsqNone;
            end;
         end;
      end;
      {.resource spots data loading}
      Count:=1;
      if Satellite = 0 then
      begin
         SetLength( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_resourceSpot, Spot + 1 );
         while Count <= Spot do
         begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_resourceSpot[Count].RRS_type:=FCDfdRegions[Region].RC_rsrcSpots[Count].RRS_type;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_resourceSpot[Count].RRS_rarityVal:=FCDfdRegions[Region].RC_rsrcSpots[Count].RRS_rarityVal;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_resourceSpot[Count].RRS_rarity:=FCDfdRegions[Region].RC_rsrcSpots[Count].RRS_rarity;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_resourceSpot[Count].RRS_quality:=FCDfdRegions[Region].RC_rsrcSpots[Count].RRS_quality;
            inc( Count );
         end;
      end
      else if Satellite > 0 then
      begin
         SetLength( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_resourceSpot, Spot + 1 );
         while Count <= Spot do
         begin
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_resourceSpot[Count].RRS_type:=FCDfdRegions[Region].RC_rsrcSpots[Count].RRS_type;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_resourceSpot[Count].RRS_rarityVal:=FCDfdRegions[Region].RC_rsrcSpots[Count].RRS_rarityVal;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_resourceSpot[Count].RRS_rarity:=FCDfdRegions[Region].RC_rsrcSpots[Count].RRS_rarity;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_resourceSpot[Count].RRS_quality:=FCDfdRegions[Region].RC_rsrcSpots[Count].RRS_quality;
            inc( Count );
         end;
      end;
      inc( Region );
   end; //==END== while Region <= Max ==//
   {.data load for subsurface ocean}
   if Satellite = 0
   then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_subsurfaceOcean:=hasaSubsurfaceOcean
   else if Satellite > 0
   then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_subsurfaceOcean:=hasaSubsurfaceOcean;
end;

procedure FCMfR_Resources_Phase2(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose:  final phase of the calculations of the resources. Gas field is processed in this phase.
    Additions:
}
   var
      BioVigor
      ,Max
      ,Region
      ,Spot: integer;

      fCalc1
      ,fCalc2
      ,RandgStdev
      ,RarityValue
      ,RsrcPotential: extended;

      BioLevel: TFCEduBiosphereLevels;

      TectonicActivity: TFCEduTectonicActivity;

      procedure _ResourceData_Loading;
      begin
         if Satellite = 0 then
         begin
            setlength( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_resourceSpot, Spot + 1 );
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_resourceSpot[Spot].RRS_type:=FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_resourceSpot[Spot].RRS_rarityVal:=FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_resourceSpot[Spot].RRS_rarity:=FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_resourceSpot[Spot].RRS_quality:=FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality;
         end
         else if Satellite > 0 then
         begin
            setlength( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_resourceSpot, Spot + 1 );
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_resourceSpot[Spot].RRS_type:=FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_resourceSpot[Spot].RRS_rarityVal:=FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_resourceSpot[Spot].RRS_rarity:=FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity;
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_resourceSpot[Spot].RRS_quality:=FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality;
         end;
      end;

      procedure _LandModifier_Process;
      begin
         case FCDfdRegions[Region].RC_landType of
            rst01RockyDesert: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst02SandyDesert: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst03Volcanic: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst04Polar: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst05Arid: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

            rst06Fertile..rst08CoastalRockyDesert: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst09CoastalSandyDesert: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst10CoastalVolcanic: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst11CoastalPolar..rst12CoastalArid: RarityValue:=randg( RsrcPotential, RandgStdev );

            rst13CoastalFertile: RarityValue:=randg( RsrcPotential * 1.25, RandgStdev );

            rst14Sterile: RarityValue:=randg( RsrcPotential * 0.75, RandgStdev );

            rst15icySterile: RarityValue:=randg( RsrcPotential, RandgStdev );
         end;
      end;

begin
   BioVigor:=0;
   Max:=0;
   Region:=0;
   Spot:=0;

   fCalc1:=0;
   fCalc2:=0;
   RandgStdev:=0;

   BioLevel:=blNone;

   TectonicActivity:=taNull;

   if Satellite = 0 then
   begin
      TectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity;
      BioLevel:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereLevel;
      BioVigor:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_biosphereVigor;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions ) - 1;
   end
   else if Satellite > 0 then
   begin
      TectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity;
      BioLevel:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereLevel;
      BioVigor:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_biosphereVigor;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions ) - 1;
   end;
   fCalc1:=sqr( Integer( TectonicActivity ) - 1 );
   if BioVigor > 0
   then fCalc2:=sqrt( BioVigor );
   Region:=1;
   while Region <= Max do
   begin
      Spot:=length( FCDfdRegions[Region].RC_rsrcSpots ) - 1;
      if ( BioLevel < blCarbon_Prebiotics )
         and ( TectonicActivity > taDead ) then
      begin
         inc( Spot );
         setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         RsrcPotential:=0;
         RarityValue:=0;
         if BioLevel=blNone
         then RsrcPotential:=fCalc1 * 2
         else RsrcPotential:=fCalc1 * ( 2 + FCFcF_Random_DoFloat );
         if RsrcPotential <= 0 then
         begin
            dec( Spot );
            setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         end
         else begin
            RandgStdev:=FCFcF_Round( rttCustom1Decimal, RsrcPotential * 0.1 ) * 2;
            _LandModifier_Process;
            if RarityValue <= 0 then
            begin
               dec( Spot );
               setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
            end
            else begin
               if RarityValue > 100
               then RarityValue:=100;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstGasField;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=FCFfR__RarityIndex_Set( RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality:=rsqNone;
               _ResourceData_Loading;
            end;
         end;
      end
      else begin
         inc( Spot );
         setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         RsrcPotential:=0;
         RarityValue:=0;
         if ( BioLevel = blCarbon_Prebiotics )
            or ( BioLevel = blAmmonia_Prebiotics )
         then RsrcPotential:=fCalc1 + fCalc2
         else if ( BioLevel = blCarbon_MicroOrganisms )
            or ( BioLevel = blAmmonia_MicroOrganisms )
            or ( BioLevel = blSilicon_Prebiotics )
            or ( BioLevel = blMethane_Prebiotics )
            or ( BioLevel = blSulphurDioxide_Prebiotics )
         then RsrcPotential:=fCalc1 + ( fCalc2 * 2 )
         else if ( BioLevel = blCarbon_Level1Organisms )
            or ( BioLevel = blAmmonia_Level1Organisms )
            or ( BioLevel = blSilicon_MicroOrganisms )
            or ( BioLevel = blMethane_MicroOrganisms )
            or ( BioLevel = blSulphurDioxide_MicroOrganisms )
         then RsrcPotential:=fCalc1 + ( fCalc2 * 4 )
         else if ( BioLevel = blCarbon_Level2Organisms )
            or ( BioLevel = blAmmonia_Level2Organisms )
            or ( BioLevel = blSilicon_Level1Organisms )
            or ( BioLevel = blMethane_Level1Organisms )
            or ( BioLevel = blSulphurDioxide_Level1Organisms )
         then RsrcPotential:=fCalc1 + ( fCalc2 * 6 )
         else if ( BioLevel = blAmmonia_Level3Organisms )
            or ( BioLevel = blSilicon_Level2Organisms )
            or ( BioLevel = blMethane_Level2Organisms )
            or ( BioLevel = blSulphurDioxide_Level2Organisms )
         then RsrcPotential:=fCalc1 + ( fCalc2 * 8 )
         else if ( BioLevel = blSilicon_Level3Organisms )
            or ( BioLevel = blMethane_Level3Organisms )
            or ( BioLevel = blSulphurDioxide_Level3Organisms )
         then RsrcPotential:=fCalc1 + ( fCalc2 * 10 );
         if RsrcPotential <= 0 then
         begin
            dec( Spot );
            setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         end
         else begin
            RandgStdev:=FCFcF_Round( rttCustom1Decimal, RsrcPotential * 0.1 ) * 2;
            _LandModifier_Process;
            if RarityValue <= 0 then
            begin
               dec( Spot );
               setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
            end
            else begin
               if RarityValue > 100
               then RarityValue:=100;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstGasField;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=FCFfR__RarityIndex_Set( RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality:=rsqNone;
               _ResourceData_Loading;
            end;
         end;
      end;
      inc( Region );
   end;
end;

end.

