{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: Regions - climate unit

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
unit farc_fug_regionsClimate;

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
///   generate climate, and each of its related data, for all the regions of a given orbital object
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfRC_Climate_Generate(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

implementation

uses
   farc_data_univ
   ,farc_univ_func;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfRC_Climate_Generate(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: generate climate, and each of its related data, for all the regions of a given orbital object.
   Addition:
}
   type TFCRfrcRegionCalc = record
      RC_surfaceTemperatureClosest: extended;
      RC_surfaceTemperatureInterm: extended;
      RC_surfaceTemperatureFarthest: extended;
   end;

   var
      Count
      ,fInt0
      ,HydroArea
      ,Max
      ,Row: integer;

      AtmospherePressure
      ,AxialTilt
      ,fCalc0
      ,fCalc1
      ,fCalc2
      ,ObjectSurfaceTempClosest
      ,ObjectSurfaceTempInterm
      ,ObjectSurfaceTempFarthest
      ,RegionMod1
      ,RegionMod2
      ,RegionMod3
      ,RegionMod4
      ,RegionMod5
      ,RegionMod6
      ,RotationPeriod: extended;

      Hydrosphere: TFCEduHydrospheres;

      FCDfrcRegion: array [0..30] of TFCRfrcRegionCalc;
begin
   {.data initialization}
   Count:=1;
   fInt0:=0;
   HydroArea:=0;
   Max:=0;
   Row:=0;

   AtmospherePressure:=0;
   AxialTilt:=0;
   fCalc0:=0;
   fCalc1:=0;
   fCalc2:=0;
   ObjectSurfaceTempClosest:=0;
   ObjectSurfaceTempInterm:=0;
   ObjectSurfaceTempFarthest:=0;
   RegionMod1:=0;
   RegionMod2:=0;
   RegionMod3:=0;
   RegionMod4:=0;
   RegionMod5:=0;
   RegionMod6:=0;
   RotationPeriod:=0;

   if Satellite = 0 then
   begin
      RotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod;
      AxialTilt:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_axialTilt;
      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure;
      {.the clouds cover loaded into fCalc0 is only used for the surface temperatures subsection. It can be used afterward}
      fCalc0:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
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
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions ) - 1;
   end
   else if Satellite > 0 then
   begin
      RotationPeriod:=FCFuF_Satellite_GetRotationPeriod(
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
      fCalc0:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover;
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
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions ) - 1;
   end;
   while Count <= Max do
   begin
      FCDfrcRegion[Count]:=FCDfrcRegion[0];
      inc( count );
   end; //==END== while Count <= Max ==//
   {.surface temperatures}
   {:DEV NOTES:
      fInt0: average (sum of modifiers)
      fCalc0: clouds cover
      fCalc1: moderation modifier
      fCalc2: surface temperature w/ RegionMods
   }
   if ( Hydrosphere = hWaterLiquid )
      or ( Hydrosphere = hWaterAmmoniaLiquid )
      or ( Hydrosphere = hMethaneLiquid )
   then fInt0:=round( HydroArea * 0.1 );
   fInt0:=fInt0 + round( sqrt( RotationPeriod ) );
   fInt0:=fInt0 + round( sqrt( AxialTilt ) );
   fInt0:=fInt0 + round( sqrt( AtmospherePressure * 0.001 ) );
   if fInt0 <= 3
   then fCalc1:=1
   else if ( fInt0 > 3 )
      and ( fInt0 <= 6 )
   then fCalc1:=0.954
   else if fInt0 >= 7
   then fCalc1:=0.927;
   if fCalc0 <= 90 then
   begin
      case Max of
         4:
         begin
            if ( AxialTilt <= 10 )
               or ( AxialTilt > 170 ) then
            begin
               RegionMod1:=1.09;
               RegionMod2:=0.702;
               RegionMod3:=0.702;
            end
            else if ( ( AxialTilt > 10 ) and ( AxialTilt <= 20 ) )
               or ( ( AxialTilt > 160 ) and ( AxialTilt <= 170 ) ) then
            begin
               RegionMod1:=0.975;
               RegionMod2:=0.785;
               RegionMod3:=0.627;
            end
            else if ( ( AxialTilt > 20 ) and ( AxialTilt <= 30 ) )
               or ( ( AxialTilt > 150 ) and ( AxialTilt <= 160 ) ) then
            begin
               RegionMod1:=0.935;
               RegionMod2:=0.855;
               RegionMod3:=0.582;
            end
            else if ( ( AxialTilt > 30 ) and ( AxialTilt <= 45 ) )
               or ( ( AxialTilt > 135 ) and ( AxialTilt <= 150 ) ) then
            begin
               RegionMod1:=0.887;
               RegionMod2:=0.887;
               RegionMod3:=0.555;
            end
            else if ( ( AxialTilt > 45 ) and ( AxialTilt <= 60 ) )
               or ( ( AxialTilt > 120 ) and ( AxialTilt <= 135 ) ) then
            begin
               RegionMod1:=0.8;
               RegionMod2:=0.98;
               RegionMod3:=0.467;
            end
            else if ( ( AxialTilt > 60 ) and ( AxialTilt <= 75 ) )
               or ( ( AxialTilt > 105 ) and ( AxialTilt <= 120 ) ) then
            begin
               RegionMod1:=0.73;
               RegionMod2:=1.072;
               RegionMod3:=0.395;
            end
            else if ( AxialTilt > 75 )
               and ( AxialTilt <= 105 ) then
            begin
               RegionMod1:=0.669;
               RegionMod2:=1.192;
               RegionMod3:=0.322;
            end;
            if AxialTilt <= 105 then
            begin
               fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
               FCDfrcRegion[1].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
               FCDfrcRegion[1].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod3 ) * 0.5 );
               FCDfrcRegion[1].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;

               FCDfrcRegion[3].RC_surfaceTemperatureClosest:=FCDfrcRegion[2].RC_surfaceTemperatureClosest;
               FCDfrcRegion[3].RC_surfaceTemperatureFarthest:=FCDfrcRegion[2].RC_surfaceTemperatureFarthest;
               FCDfrcRegion[3].RC_surfaceTemperatureFarthest:=FCDfrcRegion[2].RC_surfaceTemperatureFarthest;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
               FCDfrcRegion[4].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
               FCDfrcRegion[4].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod3 ) * 0.5 );
               FCDfrcRegion[4].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
            end
            else begin
               fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
               FCDfrcRegion[1].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
               FCDfrcRegion[1].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod3 ) * 0.5 );
               FCDfrcRegion[1].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;

               FCDfrcRegion[3].RC_surfaceTemperatureClosest:=FCDfrcRegion[2].RC_surfaceTemperatureClosest;
               FCDfrcRegion[3].RC_surfaceTemperatureFarthest:=FCDfrcRegion[2].RC_surfaceTemperatureFarthest;
               FCDfrcRegion[3].RC_surfaceTemperatureFarthest:=FCDfrcRegion[2].RC_surfaceTemperatureFarthest;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
               FCDfrcRegion[4].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
               FCDfrcRegion[4].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod3 ) * 0.5 );
               FCDfrcRegion[4].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
            end; //==END== else of: if AxialTilt <= 105 ==//
         end; //==END== case Max: 4 ==//

         6,8,10:
         begin
            case Max of
               6: Row:=2;

               8: Row:=3;

               10: Row:=4;
            end;
            if ( AxialTilt <= 10 )
               or ( AxialTilt > 170 ) then
            begin
               RegionMod1:=1.035;
               RegionMod2:=0.702;
               RegionMod3:=1.035;
               RegionMod4:=0.702;
            end
            else if ( ( AxialTilt > 10 ) and ( AxialTilt <= 20 ) )
               or ( ( AxialTilt > 160 ) and ( AxialTilt <= 170 ) ) then
            begin
               RegionMod1:=1.021;
               RegionMod2:=0.785;
               RegionMod3:=0.928;
               RegionMod4:=0.627;
            end
            else if ( ( AxialTilt > 20 ) and ( AxialTilt <= 30 ) )
               or ( ( AxialTilt > 150 ) and ( AxialTilt <= 160 ) ) then
            begin
               RegionMod1:=1.01;
               RegionMod2:=0.855;
               RegionMod3:=0.861;
               RegionMod4:=0.582;
            end
            else if ( ( AxialTilt > 30 ) and ( AxialTilt <= 45 ) )
               or ( ( AxialTilt > 135 ) and ( AxialTilt <= 150 ) ) then
            begin
               RegionMod1:=0.954;
               RegionMod2:=0.887;
               RegionMod3:=0.82;
               RegionMod4:=0.555;
            end
            else if ( ( AxialTilt > 45 ) and ( AxialTilt <= 60 ) )
               or ( ( AxialTilt > 120 ) and ( AxialTilt <= 135 ) ) then
            begin
               RegionMod1:=0.91;
               RegionMod2:=0.98;
               RegionMod3:=0.691;
               RegionMod4:=0.467;
            end
            else if ( ( AxialTilt > 60 ) and ( AxialTilt <= 75 ) )
               or ( ( AxialTilt > 105 ) and ( AxialTilt <= 120 ) ) then
            begin
               RegionMod1:=0.882;
               RegionMod2:=1.072;
               RegionMod3:=0.578;
               RegionMod4:=0.395;
            end
            else if ( AxialTilt > 75 )
               and ( AxialTilt <= 105 ) then
            begin
               RegionMod1:=0.86;
               RegionMod2:=1.192;
               RegionMod3:=0.478;
               RegionMod4:=0.322;
            end;
            Count:=1;
            if AxialTilt <= 105 then
            begin
               while Count <= Max do
               begin
                  if Count=1 then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < Row + 2 ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > Row + 1 ) and ( Count < Max - 1 ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                  end;
                  inc( Count );
               end; //==END== while Count <= Max ==//
            end
            else begin
               while Count <= Max do
               begin
                  if Count=1 then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < Row + 2 ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > Row + 1 ) and ( Count < Max - 1 ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                  end;
                  inc( Count );
               end; //==END== while Count <= Max ==//
            end; //==END== else of: if AxialTilt <= 105 ==//
         end; //==END== case Max: 6,8,10 ==//

         14:
         begin
            Row:=4;
            Count:=1;
         end; //==END== case Max: 14 ==//

         18,22,26,30:
         begin
            Row:=4;
            Count:=1;
         end; //==END== case Max: 18,22,26,30 ==//
      end; //==END== case Max of ==//
   end //==END== if fCalc0 <= 90 ==//
   else begin
      Count:=1;
      while Count <= Max do
      begin
         FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=ObjectSurfaceTempClosest;
         FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=ObjectSurfaceTempInterm;
         FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=ObjectSurfaceTempFarthest;
         inc( count );
      end; //==END== while Count <= Max ==//
   end; //==END== else of: if fCalc0 <= 90 ==//
   {.climate and its related data}
   if AtmospherePressure > 0 then
   begin

   end; //==END== if Atmosphere > 0 ==//
   {:DEV NOTES: data load w/ the correct rtos }
end;

end.

