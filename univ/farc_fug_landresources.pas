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
   ,Max
   ,Region
   ,TectonicActivityMod: integer;

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
   Max:=0;
   Region:=0;

   TectonicActivityMod:=0;

   ObjectType:=ootNone;

   TectonicActivity:=taNull;
   if Satellite = 0 then
   begin
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type;
      GravModifier:=round( ( 1 / FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity ) * 10 ) - 10;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions ) - 1;
      _TectonicActivityMod_Set( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity );
   end
   else if Satellite > 0 then
   begin
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_type;
      GravModifier:=round( ( 1 / FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravity ) * 10 ) - 10;
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
      end;

      {:DEV: add region data loading here for land type and relief!}
      inc( Region );
   end;
end;




{   var


      Diameter: extended;
begin
   Max:=0;

   Diameter:=0;
   if Satellite = 0 then
   begin
      Diameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_Diameter;
      { RotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod;
      AxialTilt:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_axialTilt;

      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure;
      {.the clouds cover loaded into fCalc0 is only used for the surface temperatures subsection. It can be used afterward}
      { fCalc0:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
      Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      ObjectSurfaceTempClosest:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optClosest
      ,0
      ,Star
      ,OrbitalObject
      );
      ObjectSurfaceTempInterm:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optIntermediary
      ,0
      ,Star
      ,OrbitalObject
      );
      ObjectSurfaceTempFarthest:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optFarthest
      ,0
      ,Star
      ,OrbitalObject
      );
       }
  {  end
   else if Satellite > 0 then
   begin
      Diameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_Diameter;
       }
      { RotationPeriod:=FCFuF_Satellite_GetRotationPeriod(
      0
      ,Star
      ,OrbitalObject
      ,Satellite
      );
      AxialTilt:=FCFuF_Satellite_GetAxialTilt(
      0
      ,Star
      ,OrbitalObject
      ,Satellite
      );

      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure;
      {.the clouds cover loaded into fCalc0 is only used for the surface temperatures subsection. It can be used afterward}
      { fCalc0:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover;
      Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      HydroArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      ObjectSurfaceTempClosest:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optClosest
      ,0
      ,Star
      ,OrbitalObject
      ,Satellite
      );
      ObjectSurfaceTempInterm:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optIntermediary
      ,0
      ,Star
      ,OrbitalObject
      ,Satellite
      );
      ObjectSurfaceTempFarthest:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optFarthest
      ,0
      ,Star
      ,OrbitalObject
      ,Satellite
      );
       }
   { end; }
   {.generate the total number of region an orbital object has}
  {  if Satellite = 0
   then setlength( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions, Max + 1 )
   else if Satellite > 0
   then setlength( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions, Max + 1 );
   end; }
  {  {.generate the climate of each region}
  {  FCMfRC_Climate_Generate(
      Star
      ,OrbitalObject
      ,Satellite
      );
end; }

end.

