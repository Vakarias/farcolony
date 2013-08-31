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
///   first phase of the calculations of the resources. Gas field isn't processed in this phase (it needs the biosphere data).
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

implementation

uses
   farc_common_func
   ,farc_data_univ
   ,farc_fug_data
   ,farc_fug_regionsClimate;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfR_LandRelief_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: generate the land type and relief for each region.
   Additions:
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

   isAtmosphere: boolean;

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
         taHotSpot: TectonicActivityMod:=10;

         taPlastic: TectonicActivityMod:=20;

         taPlateTectonic: TectonicActivityMod:=30;

         taPlateletTectonic: TectonicActivityMod:=50;

         taExtreme: TectonicActivityMod:=80;
      end;
      TectonicActivity:=TectonicActivity;
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
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions ) - 1;
      _TectonicActivityMod_Set( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity );
   end;
   Region:=1;
   while Region <= Max do
   begin
      FCDfdRegions[Region].RC_tectonicActivityMod:=round( randg( TectonicActivityMod, 3 ) );
      FCDfdRegions[Region].RC_surfaceTemperatureMean:=( FCDfdRegions[Region].RC_surfaceTemperatureClosest + FCDfdRegions[Region].RC_surfaceTemperatureInterm + FCDfdRegions[Region].RC_surfaceTemperatureFarthest ) / 3;
      if ( ( ObjectType > ootAsteroidsBelt ) and ( ObjectType < ootAsteroid_Icy ) )
         or ( ( ObjectType > ootPlanet_Supergiant ) and ( ObjectType < ootSatellite_Asteroid_Icy ) ) then
      begin
         FCDfdRegions[Region].RC_landType:=rst14Sterile;
         FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 30, 0 );
      end
      else if ( ObjectType = ootAsteroid_Icy )
         or ( ObjectType = ootSatellite_Asteroid_Icy ) then
      begin
         FCDfdRegions[Region].RC_landType:=rst15icySterile;
         FCDfdRegions[Region].RC_reliefType:=_ReliefRule_Set( 40, 0 );
      end
      else if ( ( ( ObjectType >= oot_Planet_Telluric ) and ( ObjectType < ootPlanet_Gaseous_Uranus ) ) or ( ObjectType >= ootSatellite_Planet_Telluric ) )
         and ( not isAtmosphere ) then
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
      else if ( ( ( ObjectType >= oot_Planet_Telluric ) and ( ObjectType < ootPlanet_Gaseous_Uranus ) ) or ( ObjectType >= ootSatellite_Planet_Telluric ) )
         and ( isAtmosphere ) then
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
}
   var
      HydroArea
      ,Max
      ,Region
      ,Spot: integer;

      DensityCoef
      ,DiamRed
      ,fCalc1
      ,RandgStdev
      ,RarityValue
      ,RsrcPotential: extended;

      hasaSubsurfaceOcean: boolean;

      HydroType: TFCEduHydrospheres;

      function _RarityIndex_Set: TFCEduResourceSpotRarity;
      begin
         Result:=rsrAbsent;
         if ( RarityValue > 0 )
            and ( RarityValue <= 8 )
         then Result:=rsrRare
         else if ( RarityValue > 8 )
            and ( RarityValue <= 17 )
         then Result:=rsrUncommon
         else if ( RarityValue > 17 )
            and ( RarityValue <= 35 )
         then Result:=rsrPresent
         else if ( RarityValue > 35 )
            and ( RarityValue <= 60 )
         then Result:=rsrCommon
         else if ( RarityValue > 60 )
            and ( RarityValue <= 81 )
         then Result:=rsrAbundant
         else if RarityValue > 81
         then Result:=rsrRich;
      end;

begin
   HydroArea:=0;
   Max:=0;

   DensityCoef:=0;
   DiamRed:=0;

   hasaSubsurfaceOcean:=false;

   HydroType:=hNoHydro;

   if Satellite = 0 then
   begin
//      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type;
//      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity <> 1
//      then GravModifier:=round( ln( 1 / FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity ) * 2.5 )
//      else GravModifier:=0;
//      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure > 0
//      then isAtmosphere:=true;
      DensityCoef:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_density / 551.5;
      DiamRed:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_diameter * 0.002;
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions ) - 1;
//      _TectonicActivityMod_Set( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity );
   end
   else if Satellite > 0 then
   begin
//      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_type;
//      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravity <> 1
//      then GravModifier:=round( ln( 1 / FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravity ) * 10 ) - 10
//      else GravModifier:=0;
//      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure > 0
//      then isAtmosphere:=true;
      DensityCoef:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_density / 551.5;
      DiamRed:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_diameter * 0.002;
      HydroType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions ) - 1;
//      _TectonicActivityMod_Set( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity );
   end;
   Spot:=0;
   Region:=1;
   while Region <= Max do
   begin
      setlength( FCDfdRegions[Region].RC_rsrcSpots, 1 );
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
            if RarityValue < 0 then
            begin
               dec( Spot );
               setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
            end
            else begin
               if RarityValue > 100
               then RarityValue:=100;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstHydroWell;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=_RarityIndex_Set;
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
         RsrcPotential:=HydroArea;
         if RsrcPotential <= 0 then
         begin
            dec( Spot );
            setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
         end
         else begin
            RandgStdev:=FCFcF_Round( rttCustom1Decimal, RsrcPotential * 0.1 ) * 2;
            RarityValue:=randg( RsrcPotential, RandgStdev );
            if RarityValue < 0 then
            begin
               dec( Spot );
               setlength( FCDfdRegions[Region].RC_rsrcSpots, Spot + 1 );
            end
            else begin
               if RarityValue > 100
               then RarityValue:=100;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_type:=rstIcyOreField;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarityVal:=FCFcF_Round( rttCustom1Decimal, RarityValue );
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_rarity:=_RarityIndex_Set;
               FCDfdRegions[Region].RC_rsrcSpots[Spot].RRS_quality:=rsqNone;
            end;
         end;
      end;

      {.carbonaceous ore field}

      {.metallic ore field}

      {.rare metals ore field}

      {.uranium ore field}

      {.underground water}


      {:DEV NOTES: data loading
      with a while max rsrcspots
      .}
      inc( Region );
   end; //==END== while Region <= Max ==//
   {:DEV NOTES: data load for subsurface ocean.}
end;

end.

