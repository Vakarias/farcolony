{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: Regions - core unit

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
unit farc_fug_regions;

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
///   generate the regions of an orbital object. It is the first phase (pre-generation of the surface maps)
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfR_GenerationPhase1_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   generate the regions of an orbital object. It is the second and final phase (post manual edition + resources)
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfR_GenerationPhase2_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

implementation

uses
   farc_common_func
   ,farc_data_univ
   ,farc_fug_fractalterrains
   ,farc_fug_landresources
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

procedure FCMfR_GenerationPhase1_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: generate the regions of an orbital object. It is the first phase (pre-generation of the surface maps).
   Additions:
      -2013Aug20- *add: short/long/mean travel distances calculation.
}
   var
      Max
      ,RegionSurf: integer;

      Diameter
      ,DistanceFarthest
      ,DistanceMean
      ,DistanceShortest
      ,SurfaceByRegion: extended;
begin
   Max:=0;
   RegionSurf:=0;

   Diameter:=0;
   DistanceFarthest:=0;
   DistanceMean:=0;
   DistanceShortest:=0;
   SurfaceByRegion:=0;
   if Satellite = 0
   then Diameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_Diameter
   else if Satellite > 0
   then Diameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_Diameter;
   {.generate the total number of region an orbital object has}
   if Diameter < 30 then
   begin
      Max:=4;
      RegionSurf:=6;
   end
   else if ( Diameter >= 30 )
      and ( Diameter < 75 ) then
   begin
      Max:=6;
      RegionSurf:=8;
   end
   else if ( Diameter >= 75 )
      and ( Diameter < 187 ) then
   begin
      Max:=8;
      RegionSurf:=12;
   end
   else if ( Diameter >= 187 )
      and ( Diameter < 468 ) then
   begin
      Max:=10;
      RegionSurf:=16;
   end
   else if ( Diameter >= 468 )
      and ( Diameter < 1171 ) then
   begin
      Max:=14;
      RegionSurf:=20;
   end
   else if ( Diameter >= 1171 )
      and ( Diameter < 2929 ) then
   begin
      Max:=18;
      RegionSurf:=24;
   end
   else if ( Diameter >= 2929 )
      and ( Diameter < 7324 ) then
   begin
      Max:=22;
      RegionSurf:=30;
   end
   else if ( Diameter >= 7324 )
      and ( Diameter < 18310 ) then
   begin
      Max:=26;
      RegionSurf:=36;
   end
   else if Diameter >= 18310 then
   begin
      Max:=30;
      RegionSurf:=42;
   end;
   SurfaceByRegion:=4 * Pi * power( Diameter * 0.5, 2 ) /  RegionSurf;
   DistanceFarthest:=sqrt( SurfaceByRegion * 2 );
   DistanceShortest:=sqrt( SurfaceByRegion ) / 1.45;
   DistanceMean:=( DistanceFarthest + DistanceShortest ) * 0.5;
   if Satellite = 0 then
   begin
      setlength( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions, Max + 1 );
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regionSurface:=FCFcF_Round( rttCustom1Decimal, SurfaceByRegion );
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_meanTravelDistance:=round( DistanceMean );
   end
   else if Satellite > 0 then
   begin
      setlength( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions, Max + 1 );
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regionSurface:=FCFcF_Round( rttCustom1Decimal, SurfaceByRegion );
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_meanTravelDistance:=round( DistanceMean );
   end;
   {.generate the climate of each region}
   FCMfRC_Climate_Generate(
      DistanceShortest
      ,DistanceFarthest
      ,Star
      ,OrbitalObject
      ,Satellite
      );
   {.generate the land types and relief}
   FCMfR_LandRelief_Process(
      Star
      ,OrbitalObject
      ,Satellite
      );
   {.initialize Fractal Terrains Data and initialize the interface}
   FCMfT_DataLinking_Process(
      Star
      ,OrbitalObject
      ,Satellite
      );
end;

procedure FCMfR_GenerationPhase2_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: generate the regions of an orbital object. It is the second and final phase (post manual edition + resources).
    Additions:
}
begin

end;

end.
