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
   farc_common_func
   ,farc_data_univ
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
      RC_cTempClosest: extended;
      RC_surfaceTemperatureInterm: extended;
      RC_cTempInterm: extended;
      RC_surfaceTemperatureFarthest: extended;
      RC_cTempFarthest: extended;

      RC_windspeedClosest: integer;
      RC_windspeedInterm: integer;
      RC_windspeedFarthest: integer;

      RC_rainfallClosest: integer;
      RC_rainfallInterm: integer;
      RC_rainfallFarthest: integer;

      RC_saturationVaporClosest: extended;
      RC_saturationVaporInterm: extended;
      RC_saturationVaporFarthest: extended;

      RC_vaporPressureDewClosest: extended;
      RC_vaporPressureDewInterm: extended;
      RC_vaporPressureDewFarthest: extended;

      RC_relativeHumidityClosest: extended;
      RC_relativeHumidityInterm: extended;
      RC_relativeHumidityFarthest: extended;

      RC_regionPressureClosest: extended;
      RC_regionPressureInterm: extended;
      RC_regionPressureFarthest: extended;

      RC_finalClimate: TFCEduRegionClimates;
   end;

   var
      Count
      ,fInt0
      ,fInt1
      ,HydroArea
      ,Max
      ,Row: integer;

      AtmospherePressure
      ,AxialTilt
      ,Diameter
      ,fCalc0
      ,fCalc1
      ,fCalc2
      ,fCalc3
      ,fCalc4
      ,LongX
      ,LongY
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

      function _RainfallCalculation(
         const X
               ,RBF
               ,WindSpeed: integer;
         const ModRH: extended
         ): integer;
      {:Purpose: calculate the rainfall.
          Additions:
      }
         var
            RainBase
            ,RainFinal
            ,WindE: extended;
      begin
         Result:=0;
         RainBase:=0;
         RainFinal:=0;
         WindE:=0;
         RainBase:=ln( power( RBF, modRH ) );
         WindE:=logn( WindSpeed, X );
         RainFinal:=( WindE * RainBase * RBF ) / ( 0.35 + ( RBF * 0.001 ) );
         Result:=round( RainFinal );
      end;


      procedure _Windspeed_Calculation( const CoefRegion: extended );
      {:purpose: calculate the windspeed of the current region.
      }
      {:DEV NOTES:
         fInt0:
         fCalc0: circumference
         fCalc1: omega
         fCalc2: coriolis
         fCalc3: distX
         fCalc4: distY
      }
         var
            AtmPress
            ,SpeedU
            ,SpeedV
            ,Windspeed
            ,X1_X0
            ,Y1_Y0: extended;
      begin
         if RotationPeriod <> 0
         then fCalc2:=( ( 4 * pi * sin( pi / ( 12 / CoefRegion ) ) ) / abs( RotationPeriod ) ) * 1000;
         X1_X0:=fCalc3 * cos( 15 * CoefRegion );
         Y1_Y0:=fCalc4 * sin( 15 * CoefRegion );
         AtmPress:=0;
         SpeedU:=0;
         SpeedV:=0;
         if fCalc1 <> 0 then
         begin
            Windspeed:=0;
            AtmPress:=AtmospherePressure / FCDfrcRegion[Count].RC_regionPressureClosest;
            SpeedU:=abs( ( Y1_Y0 * 287 * FCDfrcRegion[Count].RC_surfaceTemperatureClosest * ln( AtmPress ) ) / ( 2 * fCalc1 * sin( 15 * CoefRegion ) * ( sqr( fCalc4 ) ) ) );
            AtmPress:=FCDfrcRegion[Count].RC_regionPressureClosest / AtmospherePressure;
            SpeedV:=abs( ( X1_X0 * 287 * FCDfrcRegion[Count].RC_surfaceTemperatureClosest * ln( AtmPress ) ) / ( 2 * fCalc1 * sin( 15 * CoefRegion ) * ( sqr( fCalc3 ) ) ) );
            Windspeed:=sqrt( sqr( SpeedU ) + sqr( SpeedV ) );
            FCDfrcRegion[Count].RC_windspeedClosest:=round( randg( ( Windspeed + fCalc2 ) * 0.5 , 2 ) );
            Windspeed:=0;
            AtmPress:=AtmospherePressure / FCDfrcRegion[Count].RC_regionPressureInterm;
            SpeedU:=abs( ( Y1_Y0 * 287 * FCDfrcRegion[Count].RC_surfaceTemperatureInterm * ln( AtmPress ) ) / ( 2 * fCalc1 * sin( 15 * CoefRegion ) * ( sqr( fCalc4 ) ) ) );
            AtmPress:=FCDfrcRegion[Count].RC_regionPressureInterm / AtmospherePressure;
            SpeedV:=abs( ( X1_X0 * 287 * FCDfrcRegion[Count].RC_surfaceTemperatureInterm * ln( AtmPress ) ) / ( 2 * fCalc1 * sin( 15 * CoefRegion ) * ( sqr( fCalc3 ) ) ) );
            Windspeed:=sqrt( sqr( SpeedU ) + sqr( SpeedV ) );
            FCDfrcRegion[Count].RC_windspeedInterm:=round( randg( ( Windspeed + fCalc2 ) * 0.5 , 2 ) );
            Windspeed:=0;
            AtmPress:=AtmospherePressure / FCDfrcRegion[Count].RC_regionPressureFarthest;
            SpeedU:=abs( ( Y1_Y0 * 287 * FCDfrcRegion[Count].RC_surfaceTemperatureFarthest * ln( AtmPress ) ) / ( 2 * fCalc1 * sin( 15 * CoefRegion ) * ( sqr( fCalc4 ) ) ) );
            AtmPress:=FCDfrcRegion[Count].RC_regionPressureFarthest / AtmospherePressure;
            SpeedV:=abs( ( X1_X0 * 287 * FCDfrcRegion[Count].RC_surfaceTemperatureFarthest * ln( AtmPress ) ) / ( 2 * fCalc1 * sin( 15 * CoefRegion ) * ( sqr( fCalc3 ) ) ) );
            Windspeed:=sqrt( sqr( SpeedU ) + sqr( SpeedV ) );
            FCDfrcRegion[Count].RC_windspeedFarthest:=round( randg( ( Windspeed + fCalc2 ) * 0.5 , 2 ) );
         end;
      end;
begin
   {.data initialization}
   Count:=1;
   fInt0:=0;
   fInt1:=0;
   HydroArea:=0;
   Max:=0;
   Row:=0;

   AtmospherePressure:=0;
   AxialTilt:=0;
   Diameter:=0;
   fCalc0:=0;
   fCalc1:=0;
   fCalc2:=0;
   fCalc3:=0;
   fCalc4:=0;
   LongX:=0;
   LongY:=0;
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
      Diameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_Diameter;
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
      Diameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_Diameter;
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
               FCDfrcRegion[1].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;

               FCDfrcRegion[3].RC_surfaceTemperatureClosest:=FCDfrcRegion[2].RC_surfaceTemperatureClosest;
               FCDfrcRegion[3].RC_surfaceTemperatureFarthest:=FCDfrcRegion[2].RC_surfaceTemperatureFarthest;
               FCDfrcRegion[3].RC_surfaceTemperatureInterm:=FCDfrcRegion[2].RC_surfaceTemperatureInterm;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
               FCDfrcRegion[4].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
               FCDfrcRegion[4].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod3 ) * 0.5 );
               FCDfrcRegion[4].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
            end
            else begin
               fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
               FCDfrcRegion[1].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
               FCDfrcRegion[1].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod3 ) * 0.5 );
               FCDfrcRegion[1].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * RegionMod1;
               FCDfrcRegion[2].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;

               FCDfrcRegion[3].RC_surfaceTemperatureClosest:=FCDfrcRegion[2].RC_surfaceTemperatureClosest;
               FCDfrcRegion[3].RC_surfaceTemperatureFarthest:=FCDfrcRegion[2].RC_surfaceTemperatureFarthest;
               FCDfrcRegion[3].RC_surfaceTemperatureInterm:=FCDfrcRegion[2].RC_surfaceTemperatureInterm;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
               FCDfrcRegion[4].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
               FCDfrcRegion[4].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod3 ) * 0.5 );
               FCDfrcRegion[4].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
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
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < Row + 2 ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > Row + 1 ) and ( Count < Max - 1 ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
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
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < Row + 2 ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > Row + 1 ) and ( Count < Max - 1 ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end;
                  inc( Count );
               end; //==END== while Count <= Max ==//
            end; //==END== else of: if AxialTilt <= 105 ==//
         end; //==END== case Max: 6,8,10 ==//

         14:
         begin
            Row:=4;
            if ( AxialTilt <= 10 )
               or ( AxialTilt > 170 ) then
            begin
               RegionMod1:=1.15;
               RegionMod2:=0.978;
               RegionMod3:=0.65;
               RegionMod4:=0.978;
               RegionMod5:=0.65;
            end
            else if ( ( AxialTilt > 10 ) and ( AxialTilt <= 20 ) )
               or ( ( AxialTilt > 160 ) and ( AxialTilt <= 170 ) ) then
            begin
               RegionMod1:=1.058;
               RegionMod2:=0.99;
               RegionMod3:=0.74;
               RegionMod4:=0.876;
               RegionMod5:=0.58;
            end
            else if ( ( AxialTilt > 20 ) and ( AxialTilt <= 30 ) )
               or ( ( AxialTilt > 150 ) and ( AxialTilt <= 160 ) ) then
            begin
               RegionMod1:=1;
               RegionMod2:=0.996;
               RegionMod3:=0.823;
               RegionMod4:=0.812;
               RegionMod5:=0.54;
            end
            else if ( ( AxialTilt > 30 ) and ( AxialTilt <= 45 ) )
               or ( ( AxialTilt > 135 ) and ( AxialTilt <= 150 ) ) then
            begin
               RegionMod1:=0.946;
               RegionMod2:=0.938;
               RegionMod3:=0.88;
               RegionMod4:=0.774;
               RegionMod5:=0.513;
            end
            else if ( ( AxialTilt > 45 ) and ( AxialTilt <= 60 ) )
               or ( ( AxialTilt > 120 ) and ( AxialTilt <= 135 ) ) then
            begin
               RegionMod1:=0.82;
               RegionMod2:=0.928;
               RegionMod3:=0.986;
               RegionMod4:=0.652;
               RegionMod5:=0.433;
            end
            else if ( ( AxialTilt > 60 ) and ( AxialTilt <= 75 ) )
               or ( ( AxialTilt > 105 ) and ( AxialTilt <= 120 ) ) then
            begin
               RegionMod1:=0.718;
               RegionMod2:=0.928;
               RegionMod3:=1.093;
               RegionMod4:=0.544;
               RegionMod5:=0.366;
            end
            else if ( AxialTilt > 75 )
               and ( AxialTilt <= 105 ) then
            begin
               RegionMod1:=0.613;
               RegionMod2:=0.938;
               RegionMod3:=1.226;
               RegionMod4:=0.45;
               RegionMod5:=0.296;
            end;
            Count:=1;
            if AxialTilt <= 105 then
            begin
               while Count <= Max do
               begin
                  if Count=1 then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod5;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod5 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < ( Row + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( Row + 1 ) ) and ( Count < ( ( Row * 2 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 2 ) + 1 ) ) and ( Count < ( Max - 1 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod5;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod5 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end;
                  inc( Count );
               end; //==END== while Count <= Max ==//
            end
            else begin
               while Count <= Max do
               begin
                  if Count=1 then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod5;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod5 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < ( Row + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( Row + 1 ) ) and ( Count < ( ( Row * 2 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 2 ) + 1 ) ) and ( Count < ( Max - 1 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod5;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod5 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end;
                  inc( Count );
               end; //==END== while Count <= Max ==//
            end; //==END== else of: if AxialTilt <= 105 ==//
         end; //==END== case Max: 14 ==//

         18,22,26,30:
         begin
            case Max of
               18: Row:=4;

               22: Row:=5;

               26: Row:=6;

               30: Row:=7;
            end;
            if ( AxialTilt <= 10 )
               or ( AxialTilt > 170 ) then
            begin
               RegionMod1:=1.127;
               RegionMod2:=0.877;
               RegionMod3:=0.65;
               RegionMod4:=1.127;
               RegionMod5:=0.877;
               RegionMod6:=0.65;
            end
            else if ( ( AxialTilt > 10 ) and ( AxialTilt <= 20 ) )
               or ( ( AxialTilt > 160 ) and ( AxialTilt <= 170 ) ) then
            begin
               RegionMod1:=1.07;
               RegionMod2:=0.93;
               RegionMod3:=0.74;
               RegionMod4:=1.012;
               RegionMod5:=0.785;
               RegionMod6:=0.58;
            end
            else if ( ( AxialTilt > 20 ) and ( AxialTilt <= 30 ) )
               or ( ( AxialTilt > 150 ) and ( AxialTilt <= 160 ) ) then
            begin
               RegionMod1:=1.035;
               RegionMod2:=0.957;
               RegionMod3:=0.823;
               RegionMod4:=0.94;
               RegionMod5:=0.727;
               RegionMod6:=0.54;
            end
            else if ( ( AxialTilt > 30 ) and ( AxialTilt <= 45 ) )
               or ( ( AxialTilt > 135 ) and ( AxialTilt <= 150 ) ) then
            begin
               RegionMod1:=0.975;
               RegionMod2:=0.92;
               RegionMod3:=0.88;
               RegionMod4:=0.892;
               RegionMod5:=0.695;
               RegionMod6:=0.513;
            end
            else if ( ( AxialTilt > 45 ) and ( AxialTilt <= 60 ) )
               or ( ( AxialTilt > 120 ) and ( AxialTilt <= 135 ) ) then
            begin
               RegionMod1:=0.882;
               RegionMod2:=0.952;
               RegionMod3:=0.986;
               RegionMod4:=0.755;
               RegionMod5:=0.582;
               RegionMod6:=0.433;
            end
            else if ( ( AxialTilt > 60 ) and ( AxialTilt <= 75 ) )
               or ( ( AxialTilt > 105 ) and ( AxialTilt <= 120 ) ) then
            begin
               RegionMod1:=0.815;
               RegionMod2:=0.992;
               RegionMod3:=1.093;
               RegionMod4:=0.632;
               RegionMod5:=0.492;
               RegionMod6:=0.366;
            end
            else if ( AxialTilt > 75 )
               and ( AxialTilt <= 105 ) then
            begin
               RegionMod1:=0.747;
               RegionMod2:=1.047;
               RegionMod3:=1.226;
               RegionMod4:=0.522;
               RegionMod5:=0.462;
               RegionMod6:=0.296;
            end;
            Count:=1;
            if AxialTilt <= 105 then
            begin
               while Count <= Max do
               begin
                  if Count=1 then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod6;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod6 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < ( Row + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod5;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod5 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( Row + 1 ) ) and ( Count < ( ( Row * 2 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 2 ) + 1 ) ) and ( Count < ( ( Row * 3 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 3 ) + 1 ) ) and ( Count < ( Max - 1 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod5;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod5 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod6;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod6 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end;
                  inc( Count );
               end; //==END== while Count <= Max ==//
            end
            else begin
               while Count <= Max do
               begin
                  if Count=1 then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod6;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod6 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < ( Row + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod5;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod5 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( Row + 1 ) ) and ( Count < ( ( Row * 2 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 2 ) + 1 ) ) and ( Count < ( ( Row * 3 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod4 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 3 ) + 1 ) ) and ( Count < ( Max - 1 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod5;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod5 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod6;
                     FCDfrcRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfrcRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod6 ) * 0.5 );
                     FCDfrcRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end;
                  inc( Count );
               end; //==END== while Count <= Max ==//
            end; //==END== else of: if AxialTilt <= 105 ==//
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
   {:DEV NOTES:
      fInt0:
      fCalc0: circumference
      fCalc1: omega
      fCalc2: coriolis
      fCalc3: distX
      fCalc4: distY
   }
   fCalc0:=0;
   fCalc1:=0;
   fCalc2:=0;
   if AtmospherePressure > 0 then
   begin
      {.global precalculations}
      fCalc0:=( 2 * Pi * ( Diameter * 0.5 ) ) * 1000;
      if RotationPeriod <> 0
      then fCalc1:=( 2 * Pi ) / ( abs( RotationPeriod * 3600 ) );
      case Max of
         4:
         begin
            LongX:=fCalc0 * 0.5;
            LongY:=fCalc0 / 3;
         end;

         6:
         begin
            LongX:=fCalc0 * 0.5;
            LongY:=fCalc0 * 0.25;
         end;

         8:
         begin
            LongX:=fCalc0 / 3;
            LongY:=fCalc0 * 0.25;
         end;

         10:
         begin
            LongX:=fCalc0 * 0.25;
            LongY:=fCalc0 * 0.25;
         end;

         14:
         begin
            LongX:=fCalc0 * 0.25;
            LongY:=fCalc0 * 0.2;
         end;

         18:
         begin
            LongX:=fCalc0 * 0.25;
            LongY:=fCalc0 / 6;
         end;

         22:
         begin
            LongX:=fCalc0 * 0.2;
            LongY:=fCalc0 / 6;
         end;

         26:
         begin
            LongX:=fCalc0 / 6;
            LongY:=fCalc0 / 6;
         end;

         30:
         begin
            LongX:=fCalc0 / 7;
            LongY:=fCalc0 / 6;
         end;
      end; //==END== case Max of ==//
      Count:=1;
      while Count <= Max do
      begin
         {.region precalculations}
         FCDfrcRegion[Count].RC_cTempClosest:=FCDfrcRegion[Count].RC_surfaceTemperatureClosest - 273.15;
         FCDfrcRegion[Count].RC_cTempInterm:=FCDfrcRegion[Count].RC_surfaceTemperatureInterm - 273.15;
         FCDfrcRegion[Count].RC_cTempFarthest:=FCDfrcRegion[Count].RC_surfaceTemperatureFarthest - 273.15;
         FCDfrcRegion[Count].RC_saturationVaporClosest:=6.11 * power( 10, ( 7.5 * FCDfrcRegion[Count].RC_cTempClosest / ( 237.7 + FCDfrcRegion[Count].RC_cTempClosest ) ) );
         FCDfrcRegion[Count].RC_saturationVaporInterm:=6.11 * power( 10, ( 7.5 * FCDfrcRegion[Count].RC_cTempInterm / ( 237.7 + FCDfrcRegion[Count].RC_cTempInterm ) ) );
         FCDfrcRegion[Count].RC_saturationVaporFarthest:=6.11 * power( 10, ( 7.5 * FCDfrcRegion[Count].RC_cTempFarthest / ( 237.7 + FCDfrcRegion[Count].RC_cTempFarthest ) ) );
         case Hydrosphere of
            hWaterLiquid:
            begin
               FCDfrcRegion[Count].RC_vaporPressureDewClosest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureClosest - 228 ) * 0.00767 ) );
               FCDfrcRegion[Count].RC_vaporPressureDewInterm:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureInterm - 228 ) * 0.00767 ) );
               FCDfrcRegion[Count].RC_vaporPressureDewFarthest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureFarthest - 228 ) * 0.00767 ) );
            end;

            hWaterIceSheet, hWaterIceCrust:
            begin
               FCDfrcRegion[Count].RC_vaporPressureDewClosest:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureClosest - 228 ) * 0.00767 ) );
               FCDfrcRegion[Count].RC_vaporPressureDewInterm:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureInterm - 228 ) * 0.00767 ) );
               FCDfrcRegion[Count].RC_vaporPressureDewFarthest:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureFarthest - 228 ) * 0.00767 ) );
            end;

            hWaterAmmoniaLiquid:
            begin
               FCDfrcRegion[Count].RC_vaporPressureDewClosest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureClosest - 146 ) * 0.00767 ) );
               FCDfrcRegion[Count].RC_vaporPressureDewInterm:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureInterm - 146 ) * 0.00767 ) );
               FCDfrcRegion[Count].RC_vaporPressureDewFarthest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureFarthest - 146 ) * 0.00767 ) );
            end;

            hMethaneLiquid:
            begin
               FCDfrcRegion[Count].RC_vaporPressureDewClosest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureClosest - 66 ) * 0.00767 ) );
               FCDfrcRegion[Count].RC_vaporPressureDewInterm:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureInterm - 66 ) * 0.00767 ) );
               FCDfrcRegion[Count].RC_vaporPressureDewFarthest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureFarthest - 66 ) * 0.00767 ) );
            end;

            hMethaneIceSheet, hMethaneIceCrust:
            begin
               FCDfrcRegion[Count].RC_vaporPressureDewClosest:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureClosest - 66 ) * 0.00767 ) );
               FCDfrcRegion[Count].RC_vaporPressureDewInterm:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureInterm - 66 ) * 0.00767 ) );
               FCDfrcRegion[Count].RC_vaporPressureDewFarthest:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfrcRegion[Count].RC_surfaceTemperatureFarthest - 66 ) * 0.00767 ) );
            end;
         end; //==END== case Hydrosphere of ==//
         FCDfrcRegion[Count].RC_relativeHumidityClosest:=( FCDfrcRegion[Count].RC_vaporPressureDewClosest * 100 ) /  FCDfrcRegion[Count].RC_saturationVaporClosest;
         if ( FCDfrcRegion[Count].RC_relativeHumidityClosest < 0 )
            or ( FCDfrcRegion[Count].RC_relativeHumidityClosest > 100 )
         then FCDfrcRegion[Count].RC_relativeHumidityClosest:=0;
         FCDfrcRegion[Count].RC_relativeHumidityInterm:=( FCDfrcRegion[Count].RC_vaporPressureDewInterm * 100 ) /  FCDfrcRegion[Count].RC_saturationVaporInterm;
         if ( FCDfrcRegion[Count].RC_relativeHumidityInterm < 0 )
            or ( FCDfrcRegion[Count].RC_relativeHumidityInterm > 100 )
         then FCDfrcRegion[Count].RC_relativeHumidityInterm:=0;
         FCDfrcRegion[Count].RC_relativeHumidityFarthest:=( FCDfrcRegion[Count].RC_vaporPressureDewFarthest * 100 ) /  FCDfrcRegion[Count].RC_saturationVaporFarthest;
         if ( FCDfrcRegion[Count].RC_relativeHumidityFarthest < 0 )
            or ( FCDfrcRegion[Count].RC_relativeHumidityFarthest > 100 )
         then FCDfrcRegion[Count].RC_relativeHumidityFarthest:=0;
         if FCDfrcRegion[Count].RC_vaporPressureDewClosest >= AtmospherePressure
         then FCDfrcRegion[Count].RC_regionPressureClosest:=AtmospherePressure
         else FCDfrcRegion[Count].RC_regionPressureClosest:=FCDfrcRegion[Count].RC_vaporPressureDewClosest;
         if FCDfrcRegion[Count].RC_vaporPressureDewInterm >= AtmospherePressure
         then FCDfrcRegion[Count].RC_regionPressureInterm:=AtmospherePressure
         else FCDfrcRegion[Count].RC_regionPressureInterm:=FCDfrcRegion[Count].RC_vaporPressureDewInterm;
         if FCDfrcRegion[Count].RC_vaporPressureDewFarthest >= AtmospherePressure
         then FCDfrcRegion[Count].RC_regionPressureFarthest:=AtmospherePressure
         else FCDfrcRegion[Count].RC_regionPressureFarthest:=FCDfrcRegion[Count].RC_vaporPressureDewFarthest;
         {.windspeed calculations}
         fCalc2:=0;
         case Max of
            4:
            begin
               if ( Count = 1 )
                  or ( Count = Max) then
               begin
                  fCalc3:=fCalc0;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 1 );
               end
               else begin
                  fCalc3:=LongX;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 2 );
               end;
            end;

            6, 8, 10:
            begin
               if ( Count = 1 )
                  or ( Count = Max) then
               begin
                  fCalc3:=fCalc0;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 1 );
               end
               else begin
                  fCalc3:=LongX;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 4 );
               end;
            end;

            14:
            begin
               if ( Count = 1 )
                  or ( Count = Max) then
               begin
                  fCalc3:=fCalc0;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 0.86667623 );
               end
               else if ( Count in [2..5] )
                  or ( Count in [10..13] ) then
               begin
                  fCalc3:=LongX;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 3.13397754 );
               end
               else begin
                  fCalc3:=LongX;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 5.26777875 );
               end;
            end;

            18, 22, 26:
            begin
               if ( Count = 1 )
                  or ( Count = Max) then
               begin
                  fCalc3:=fCalc0;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 0.66666667 );
               end
               else if ( ( Max = 18 ) and ( ( Count in [2..5] ) or ( Count in [14..17] ) ) )
                  or ( ( Max = 22 ) and ( ( Count in [2..6] ) or ( Count in [17..21] ) ) )
                  or ( ( Max = 26 ) and ( ( Count in [2..7] ) or ( Count in [20..25] ) ) ) then
               begin
                  fCalc3:=LongX;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 2.53378378 );
               end
               else begin
                  fCalc3:=LongX;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 4.86815416 );
               end;
            end;

            30:
            begin
               if ( Count = 1 )
                  or ( Count = Max) then
               begin
                  fCalc3:=fCalc0;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 0.53333333 );
               end
               else if ( Count in [2..8] )
                  or ( Count in [23..29] ) then
               begin
                  fCalc3:=LongX;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 2 );
               end
               else begin
                  fCalc3:=LongX;
                  fCalc4:=LongY;
                  _Windspeed_Calculation( 4.53343408 );
               end;
            end;
         end; //==END== case Max of ==//
         {.region's climate calculations}
         {:DEV NOTES:
            fInt0: h
            fCalc0: meanRH
            fCalc1: meanST
            fCalc2:
            fCalc3:
            fCalc4:
         }
         FCDfrcRegion[Count].RC_finalClimate:=rc00VoidNoUse;
         fCalc0:=( FCDfrcRegion[Count].RC_relativeHumidityClosest + FCDfrcRegion[Count].RC_relativeHumidityInterm + FCDfrcRegion[Count].RC_relativeHumidityFarthest ) / 3;
         fCalc1:=( FCDfrcRegion[Count].RC_surfaceTemperatureClosest + FCDfrcRegion[Count].RC_surfaceTemperatureInterm + FCDfrcRegion[Count].RC_surfaceTemperatureFarthest ) / 3;
         if ( fCalc1 >= 500 )
            and ( fCalc0 = 0 )
         then FCDfrcRegion[Count].RC_finalClimate:=rc10Extreme
         else if ( fCalc1 < 293 )
            and ( fCalc0 < 6 )
         then FCDfrcRegion[Count].RC_finalClimate:=rc07ColdArid
         else if fCalc1 < 273 then
         begin
            fInt0:=0;
            if FCDfrcRegion[Count].RC_surfaceTemperatureClosest >= 273
            then inc( fInt0 );
            if FCDfrcRegion[Count].RC_surfaceTemperatureInterm >= 273
            then inc( fInt0 );
            if FCDfrcRegion[Count].RC_surfaceTemperatureFarthest >= 273
            then inc( fInt0 );
            if fInt0 = 0
            then FCDfrcRegion[Count].RC_finalClimate:=rc09Arctic
            else FCDfrcRegion[Count].RC_finalClimate:=rc07ColdArid;
         end
         else if ( fCalc1 >= 273 )
            and ( fCalc1 < 293 ) then
         begin
            if ( fCalc0 >= 6 )
               and ( fCalc0 < 15 )
            then FCDfrcRegion[Count].RC_finalClimate:=rc08Periarctic
            else if ( fCalc0 >= 15 )
               and ( fCalc0 < 30 )
            then FCDfrcRegion[Count].RC_finalClimate:=rc06ModerateDry
            else if fCalc0 >= 30
            then FCDfrcRegion[Count].RC_finalClimate:=rc05ModerateHumid;
         end
         else if fCalc1 >= 293 then
         begin
            if fCalc0 < 15
            then FCDfrcRegion[Count].RC_finalClimate:=rc04HotArid
            else if ( fCalc0 >= 15 )
               and ( fCalc0 <= 36 )
            then FCDfrcRegion[Count].RC_finalClimate:=rc03HotSemiArid
            else if ( fCalc0 > 36 )
               and ( fCalc0 <= 90 )
            then FCDfrcRegion[Count].RC_finalClimate:=rc02VeryHotSemiHumid
            else if fCalc0 > 90
            then FCDfrcRegion[Count].RC_finalClimate:=rc01VeryHotHumid;
         end;
         {.region's rainfall calculations}
         {:DEV NOTES:
            fInt0: x
            fInt1: RBF
            fCalc0: modRH
            fCalc1:
            fCalc2:
            fCalc3:
            fCalc4:
         }
         fInt0:=0;
         fInt1:=0;
         case FCDfrcRegion[Count].RC_finalClimate of
            rc01VeryHotHumid:
            begin
               fInt0:=12;
               fInt1:=1500;
            end;

            rc02VeryHotSemiHumid:
            begin
               fInt0:=9;
               fInt1:=1050;
            end;

            rc03HotSemiArid:
            begin
               fInt0:=5;
               fInt1:=425;
            end;

            rc04HotArid:
            begin
               fInt0:=3;
               fInt1:=125;
            end;

            rc05ModerateHumid:
            begin
               fInt0:=6;
               fInt1:=500;
            end;

            rc06ModerateDry:
            begin
               fInt0:=5;
               fInt1:=375;
            end;

            rc07ColdArid:
            begin
               fInt0:=3;
               fInt1:=50;
            end;

            rc08Periarctic:
            begin
               fInt0:=3;
               fInt1:=175;
            end;

            rc09Arctic:
            begin
               fInt0:=3;
               fInt1:=5;
            end;
         end; //==END== case FCDfrcRegion[Count].RC_finalClimate of ==//
         fCalc0:=FCDfrcRegion[Count].RC_relativeHumidityClosest * 0.01;
         if ( fInt0 > 0 )
            and ( FCDfrcRegion[Count].RC_windspeedClosest > 0 )
            and ( fCalc0 > 0 )
         then FCDfrcRegion[Count].RC_rainfallClosest:=_RainfallCalculation(
            fInt0
            ,fInt1
            ,FCDfrcRegion[Count].RC_windspeedClosest
            ,fCalc0
            );
         fCalc0:=FCDfrcRegion[Count].RC_relativeHumidityInterm * 0.01;
         if ( fInt0 > 0 )
            and ( FCDfrcRegion[Count].RC_windspeedInterm > 0 )
            and ( fCalc0 > 0 )
         then FCDfrcRegion[Count].RC_rainfallInterm:=_RainfallCalculation(
            fInt0
            ,fInt1
            ,FCDfrcRegion[Count].RC_windspeedInterm
            ,fCalc0
            );
         fCalc0:=FCDfrcRegion[Count].RC_relativeHumidityFarthest * 0.01;
         if ( fInt0 > 0 )
            and ( FCDfrcRegion[Count].RC_windspeedFarthest > 0 )
            and ( fCalc0 > 0 )
         then FCDfrcRegion[Count].RC_rainfallFarthest:=_RainfallCalculation(
            fInt0
            ,fInt1
            ,FCDfrcRegion[Count].RC_windspeedFarthest
            ,fCalc0
            );
         inc( Count );
      end; //==END== while Count <= Max ==//
   end; //==END== if Atmosphere > 0 ==//
   {.final data transfert}
   if Satellite = 0 then
   begin
      Count:=1;
      while Count <= Max do
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_climate:=FCDfrcRegion[Count].RC_finalClimate;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonClosest.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfrcRegion[Count].RC_surfaceTemperatureClosest );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonClosest.OP_windspeed:=FCDfrcRegion[Count].RC_windspeedClosest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonClosest.OP_rainfall:=FCDfrcRegion[Count].RC_rainfallClosest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonIntermediate.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfrcRegion[Count].RC_surfaceTemperatureInterm );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonIntermediate.OP_windspeed:=FCDfrcRegion[Count].RC_windspeedInterm;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonIntermediate.OP_rainfall:=FCDfrcRegion[Count].RC_rainfallInterm;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonFarthest.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfrcRegion[Count].RC_surfaceTemperatureFarthest );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonFarthest.OP_windspeed:=FCDfrcRegion[Count].RC_windspeedFarthest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonFarthest.OP_rainfall:=FCDfrcRegion[Count].RC_rainfallFarthest;
         inc( Count );
      end; //==END== while Count <= Max ==//
   end
   else if Satellite > 0 then
   begin
      Count:=1;
      while Count <= Max do
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_climate:=FCDfrcRegion[Count].RC_finalClimate;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonClosest.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfrcRegion[Count].RC_surfaceTemperatureClosest );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonClosest.OP_windspeed:=FCDfrcRegion[Count].RC_windspeedClosest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonClosest.OP_rainfall:=FCDfrcRegion[Count].RC_rainfallClosest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonIntermediate.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfrcRegion[Count].RC_surfaceTemperatureInterm );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonIntermediate.OP_windspeed:=FCDfrcRegion[Count].RC_windspeedInterm;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonIntermediate.OP_rainfall:=FCDfrcRegion[Count].RC_rainfallInterm;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonFarthest.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfrcRegion[Count].RC_surfaceTemperatureFarthest );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonFarthest.OP_windspeed:=FCDfrcRegion[Count].RC_windspeedFarthest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonFarthest.OP_rainfall:=FCDfrcRegion[Count].RC_rainfallFarthest;
         inc( Count );
      end; //==END== while Count <= Max ==//
   end;
end;

end.

