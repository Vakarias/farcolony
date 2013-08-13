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
procedure FCMfR_LandReliefFractalTerrains_Process(
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

procedure FCMfR_LandReliefFractalTerrains_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: generate the land type and relief for each region.
   Additions:
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
      if iCalc <= FCDfdRegion[Region].RC_tectonicActivityMod then
      begin
         FCDfdRegion[Region].RC_landType:=rst03Volcanic;
         FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 10, 50 );
         if ( FCDfdRegion[Region].RC_reliefType=rr1Plain )
            and ( TectonicActivity < taPlateTectonic )
         then FCDfdRegion[Region].RC_reliefType:=rr4Broken
         else if ( FCDfdRegion[Region].RC_reliefType=rr4Broken )
            and ( TectonicActivity < taPlateTectonic )
         then FCDfdRegion[Region].RC_reliefType:=rr9Mountain;
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
      GravModifier:=round( ( 1 / FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity ) * 10 ) - 10;
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
      GravModifier:=round( ( 1 / FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravity ) * 10 ) - 10;
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
      FCDfdRegion[Region].RC_tectonicActivityMod:=round( randg( TectonicActivityMod, 3 ) );
      FCDfdRegion[Region].RC_surfaceTemperatureMean:=( FCDfdRegion[Region].RC_surfaceTemperatureClosest + FCDfdRegion[Region].RC_surfaceTemperatureInterm + FCDfdRegion[Region].RC_surfaceTemperatureFarthest ) / 3;
      if ( ( ObjectType > ootAsteroidsBelt ) and ( ObjectType < ootAsteroid_Icy ) )
         or ( ( ObjectType > ootPlanet_Supergiant ) and ( ObjectType < ootSatellite_Asteroid_Icy ) ) then
      begin
         FCDfdRegion[Region].RC_landType:=rst14Sterile;
         FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 30, 0 );
      end
      else if ( ObjectType = ootAsteroid_Icy )
         or ( ObjectType = ootSatellite_Asteroid_Icy ) then
      begin
         FCDfdRegion[Region].RC_landType:=rst15icySterile;
         FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 40, 0 );
      end
      else if ( ( ( ObjectType >= oot_Planet_Telluric ) and ( ObjectType < ootPlanet_Gaseous_Uranus ) ) or ( ObjectType >= ootSatellite_Planet_Telluric ) )
         and ( not isAtmosphere ) then
      begin
         if HydroType = hNoHydro then
         begin
            FCDfdRegion[Region].RC_landType:=rst14Sterile;
            FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 20, 60 );
            _VolcanicReliefModification_Apply( Region );
         end
         else if ( HydroType = hWaterIceSheet )
            or ( HydroType = hMethaneIceSheet )
            or ( HydroType = hNitrogenIceSheet ) then
         begin
            if FCDfdRegion[Region].RC_surfaceTemperatureMean <= 125 then
            begin
               FCDfdRegion[Region].RC_landType:=rst15icySterile;
               FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 30, 80 );
            end
            else begin
               Proba:=FCFcF_Random_DoInteger( 99 ) + 1;
               if Proba <= HydroArea then
               begin
                  FCDfdRegion[Region].RC_landType:=rst15icySterile;
                  FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 30, 80 );
               end
               else begin
                  FCDfdRegion[Region].RC_landType:=rst14Sterile;
                  FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 30, 70 );
               end;
            end;
            _VolcanicReliefModification_Apply( Region );
         end
         else if ( HydroType = hWaterIceCrust )
            or ( HydroType = hMethaneIceCrust )
            or ( HydroType = hNitrogenIceCrust ) then
         begin
            FCDfdRegion[Region].RC_landType:=rst15icySterile;
            FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 30, 80 );
            _VolcanicReliefModification_Apply( Region );
         end;
      end
      else if ( ( ( ObjectType >= oot_Planet_Telluric ) and ( ObjectType < ootPlanet_Gaseous_Uranus ) ) or ( ObjectType >= ootSatellite_Planet_Telluric ) )
         and ( isAtmosphere ) then
      begin
         FCDfdRegion[Region].RC_regionPressureMean:=( FCDfdRegion[Region].RC_regionPressureClosest + FCDfdRegion[Region].RC_regionPressureInterm + FCDfdRegion[Region].RC_regionPressureFarthest ) / 3;
         case FCDfdRegion[Region].RC_finalClimate of
            rc01VeryHotHumid, rc02VeryHotSemiHumid:
            begin
               FCDfdRegion[Region].RC_landType:=rst06Fertile;
               FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 40, 85 );
            end;

            rc03HotSemiArid:
            begin
               if FCDfdRegion[Region].RC_regionPressureMean <= 36 then
               begin
                  FCDfdRegion[Region].RC_landType:=rst05Arid;
                  FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 20, 70 );
               end
               else begin
                  FCDfdRegion[Region].RC_landType:=rst06Fertile;
                  FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 40, 85 );
               end;
            end;

            rc04HotArid:
            begin
               if FCDfdRegion[Region].RC_regionPressureMean < 15 then
               begin
                  FCDfdRegion[Region].RC_landType:=rst02SandyDesert;
                  FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 40, 0 );
               end
               else begin
                  FCDfdRegion[Region].RC_landType:=rst01RockyDesert;
                  FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 50, 85 );
               end;
            end;

            rc05ModerateHumid:
            begin
               FCDfdRegion[Region].RC_landType:=rst06Fertile;
               FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 40, 85 );
            end;

            rc06ModerateDry:
            begin
               if FCDfdRegion[Region].RC_regionPressureMean < 30 then
               begin
                  FCDfdRegion[Region].RC_landType:=rst05Arid;
                  FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 20, 70 );
               end
               else begin
                  FCDfdRegion[Region].RC_landType:=rst06Fertile;
                  FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 40, 85 );
               end;
            end;

            rc07ColdArid:
            begin
               FCDfdRegion[Region].RC_landType:=rst01RockyDesert;
               FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 50, 85 );
            end;

            rc08Periarctic:
            begin
               FCDfdRegion[Region].RC_landType:=rst05Arid;
               FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 20, 70 );
            end;

            rc09Arctic:
            begin
               FCDfdRegion[Region].RC_landType:=rst04Polar;
               FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 30, 80 );
            end;

            rc10Extreme:
            begin
               FCDfdRegion[Region].RC_landType:=rst01RockyDesert;
               FCDfdRegion[Region].RC_reliefType:=_ReliefRule_Set( 50, 85 );
            end;
         end; //==END== case FCDfdRegion[Region].RC_finalClimate of ==//
         _VolcanicReliefModification_Apply( Region );
      end; //==END== else of: ( ( ( ObjectType >= oot_Planet_Telluric ) and ( ObjectType < ootPlanet_Gaseous_Uranus ) ) or ( ObjectType >= ootSatellite_Planet_Telluric ) ) and ( isAtmosphere ) ==//
      inc( Region );
   end; //==END== while Region <= Max ==//
end;

end.

