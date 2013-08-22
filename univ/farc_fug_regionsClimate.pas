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
   Math
   ,SysUtils;

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
/// <param name="ShortestTravelDistance">region shortest travel distance</param>
/// <param name="FarthestTravelDistance">region farthest travel distance</param>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfRC_Climate_Generate(
   const ShortestTravelDistance
         ,FarthestTravelDistance: extended;
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

implementation

uses
   farc_common_func
   ,farc_data_init
   ,farc_data_univ
   ,farc_fug_data
   ,farc_univ_func
   ,farc_win_debug;

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
   const ShortestTravelDistance
         ,FarthestTravelDistance: extended;
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: generate climate, and each of its related data, for all the regions of a given orbital object.
   Addition:
      -2013Aug22- *add/mod: end of the overhaul. Code cleanup.
      -2013Aug21- *add/mod: begin overhaul of the subroutine that affect windspeed calculations.
      -2013Aug20- *fix: corrections to avoid multiple division by zero.
                  *fix: region's pressure is correctly adjusted.
      -2013Aug19- *fix: a range check occured with sqrt( rotation period ), if the value was negative (inverse rotation period).
}
   var
      Count
      ,fInt0
      ,fInt1
      ,HydroArea
      ,Max
      ,RegionRefIndex
      ,Row: integer;

      AtmospherePressure
      ,AxialTilt
      ,Diameter
      ,DryAir
      ,fCalc0
      ,fCalc1
      ,fCalc2
      ,MeanTravelDistance
      ,ObjectSurfaceTempClosest
      ,ObjectSurfaceTempInterm
      ,ObjectSurfaceTempFarthest
      ,Omega
      ,RegionMod1
      ,RegionMod2
      ,RegionMod3
      ,RegionMod4
      ,RegionMod5
      ,RegionMod6
      ,RotationPeriod: extended;

      isPrimaryCH4
      ,isPrimaryCO
      ,isPrimaryCO2
      ,isPrimaryH2
      ,isPrimaryH2S
      ,isPrimaryHe
      ,isPrimaryN2
      ,isPrimaryNH3
      ,isPrimaryNO2
      ,isPrimarySO2: boolean;

      Hydrosphere: TFCEduHydrospheres;

      OrbObjLoc: TFCRufStelObj;

      RegionRefLoc: TFCRufRegionLoc;

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

      procedure _Windspeed_Calculation( const RefRegion: integer );
      {:purpose: calculate the windspeed of the current region.
      }
         var
            RefLat: integer;

            DistanceRegRegRef
            ,Tavg
            ,P0_P1
            ,P1_P0
            ,U
            ,V
            ,Windspeed
            ,X1_X0
            ,Y1_Y0: extended;

            RegionLoc: TFCRufRegionLoc;
      begin
         RefLat:=0;
         RegionLoc:=FCFuF_RegionLoc_ExtractNum( OrbObjLoc, Count );
         X1_X0:=( abs( RegionLoc.RL_X - RegionRefLoc.RL_X ) * FarthestTravelDistance ) * 1000;
         Y1_Y0:=( abs( RegionLoc.RL_Y - RegionRefLoc.RL_Y ) * ShortestTravelDistance ) * 1000;
         DistanceRegRegRef:=sqrt( power( RegionLoc.RL_X - RegionRefLoc.RL_X, 2 ) + power( RegionLoc.RL_Y - RegionRefLoc.RL_Y, 2 ) ) * MeanTravelDistance * 1000;
         case Max of
            4:
            begin
               if ( Count = 1 )
                  or ( Count = 4 )
               then RefLat:=68
               else RefLat:=0;
            end;

            6:
            begin
               if ( Count = 1 )
                  or ( Count = 6 )
               then RefLat:=68
               else RefLat:=22;
            end;

            8:
            begin
               if ( Count = 1 )
                  or ( Count = 8 )
               then RefLat:=68
               else RefLat:=22;
            end;

            10:
            begin
               if ( Count = 1 )
                  or ( Count = 10 )
               then RefLat:=68
               else RefLat:=22;
            end;

            14:
            begin
               if ( Count = 1 )
                  or ( Count = 14 )
               then RefLat:=75
               else if ( ( Count >= 2 ) and ( Count <= 5 ) )
                  or ( ( Count >= 10 ) and ( Count <= 13 ) )
               then RefLat:=45
               else RefLat:=0;
            end;

            18:
            begin
               if ( Count = 1 )
                  or ( Count = 18 )
               then RefLat:=75
               else if ( ( Count >= 2 ) and ( Count <= 5 ) )
                  or ( ( Count >= 14 ) and ( Count <= 17 ) )
               then RefLat:=45
               else RefLat:=15;
            end;

            22:
            begin
               if ( Count = 1 )
                  or ( Count = 22 )
               then RefLat:=75
               else if ( ( Count >= 2 ) and ( Count <= 6 ) )
                  or ( ( Count >= 17 ) and ( Count <= 21 ) )
               then RefLat:=45
               else RefLat:=15;
            end;

            26:
            begin
               if ( Count = 1 )
                  or ( Count = 26 )
               then RefLat:=75
               else if ( ( Count >= 2 ) and ( Count <= 7 ) )
                  or ( ( Count >= 20 ) and ( Count <= 25 ) )
               then RefLat:=45
               else RefLat:=15;
            end;

            30:
            begin
               if ( Count = 1 )
                  or ( Count = 30 )
               then RefLat:=75
               else if ( ( Count >= 2 ) and ( Count <= 8 ) )
                  or ( ( Count >= 23 ) and ( Count <= 29 ) )
               then RefLat:=45
               else RefLat:=15;
            end;
         end; //==END== case Max of ==//
         {.windspeed for closest distance}
         Tavg:=( FCDfdRegion[Count].RC_surfaceTemperatureClosest + FCDfdRegion[RefRegion].RC_surfaceTemperatureClosest ) * 0.5;
         P0_P1:=FCDfdRegion[Count].RC_regionPressureClosest / FCDfdRegion[RefRegion].RC_regionPressureClosest;
         P1_P0:=FCDfdRegion[RefRegion].RC_regionPressureClosest / FCDfdRegion[Count].RC_regionPressureClosest;
         U:=( Y1_Y0 * DryAir * Tavg * ln( P0_P1 ) ) / ( 2 * Omega * sin( RefLat ) * power(  DistanceRegRegRef, 2 ) );
         V:=( X1_X0 * DryAir * Tavg * ln( P1_P0 ) ) / ( 2 * Omega * sin( RefLat ) * power(  DistanceRegRegRef, 2 ) );
         Windspeed:=sqrt( power( U, 2 ) + power( V, 2 ) );
         FCDfdRegion[Count].RC_windspeedClosest:=round( Windspeed );
         {.windspeed for intermediate distance}
         Tavg:=( FCDfdRegion[Count].RC_surfaceTemperatureInterm + FCDfdRegion[RefRegion].RC_surfaceTemperatureInterm ) * 0.5;
         P0_P1:=FCDfdRegion[Count].RC_regionPressureInterm / FCDfdRegion[RefRegion].RC_regionPressureInterm;
         P1_P0:=FCDfdRegion[RefRegion].RC_regionPressureInterm / FCDfdRegion[Count].RC_regionPressureInterm;
         U:=( Y1_Y0 * DryAir * Tavg * ln( P0_P1 ) ) / ( 2 * Omega * sin( RefLat ) * power(  DistanceRegRegRef, 2 ) );
         V:=( X1_X0 * DryAir * Tavg * ln( P1_P0 ) ) / ( 2 * Omega * sin( RefLat ) * power(  DistanceRegRegRef, 2 ) );
         Windspeed:=sqrt( power( U, 2 ) + power( V, 2 ) );
         FCDfdRegion[Count].RC_windspeedInterm:=round( Windspeed );
         {.windspeed for farthest distance}
         Tavg:=( FCDfdRegion[Count].RC_surfaceTemperatureFarthest + FCDfdRegion[RefRegion].RC_surfaceTemperatureFarthest ) * 0.5;
         P0_P1:=FCDfdRegion[Count].RC_regionPressureFarthest / FCDfdRegion[RefRegion].RC_regionPressureFarthest;
         P1_P0:=FCDfdRegion[RefRegion].RC_regionPressureFarthest / FCDfdRegion[Count].RC_regionPressureFarthest;
         U:=( Y1_Y0 * DryAir * Tavg * ln( P0_P1 ) ) / ( 2 * Omega * sin( RefLat ) * power(  DistanceRegRegRef, 2 ) );
         V:=( X1_X0 * DryAir * Tavg * ln( P1_P0 ) ) / ( 2 * Omega * sin( RefLat ) * power(  DistanceRegRegRef, 2 ) );
         Windspeed:=sqrt( power( U, 2 ) + power( V, 2 ) );
         FCDfdRegion[Count].RC_windspeedFarthest:=round( Windspeed );
      end;
begin
   {.data initialization}
   Count:=1;
   fInt0:=0;
   fInt1:=0;
   HydroArea:=0;
   Max:=0;
   RegionRefIndex:=0;
   Row:=0;

   AtmospherePressure:=0;
   AxialTilt:=0;
   Diameter:=0;
   DryAir:=0;
   fCalc0:=0;
   fCalc1:=0;
   fCalc2:=0;
   MeanTravelDistance:=0;
   ObjectSurfaceTempClosest:=0;
   ObjectSurfaceTempInterm:=0;
   ObjectSurfaceTempFarthest:=0;
   Omega:=0;
   RegionMod1:=0;
   RegionMod2:=0;
   RegionMod3:=0;
   RegionMod4:=0;
   RegionMod5:=0;
   RegionMod6:=0;
   RotationPeriod:=0;
   
   isPrimaryCH4:=false;
   isPrimaryCO:=false;
   isPrimaryCO2:=false;
   isPrimaryH2:=false;
   isPrimaryH2S:=false;
   isPrimaryHe:=false;
   isPrimaryN2:=false;
   isPrimaryNH3:=false;
   isPrimaryNO2:=false;
   isPrimarySO2:=false;

   Hydrosphere:=hNoHydro;

   OrbObjLoc[1]:=0;
   OrbObjLoc[2]:=Star;
   OrbObjLoc[3]:=OrbitalObject;
   OrbObjLoc[4]:=Satellite;

   if Satellite = 0 then
   begin
      RotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod;
      AxialTilt:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_axialTilt;
      Diameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_Diameter;
      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure;
      if AtmospherePressure > 0 then
      begin
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4=agsMain
         then isPrimaryCH4:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO=agsMain
         then isPrimaryCO:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2=agsMain
         then isPrimaryCO2:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2=agsMain
         then isPrimaryH2:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S=agsMain
         then isPrimaryH2S:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceHe=agsMain
         then isPrimaryHe:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2=agsMain
         then isPrimaryN2:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3=agsMain
         then isPrimaryNH3:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2=agsMain
         then isPrimaryNO2:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2=agsMain
         then isPrimarySO2:=true;
      end;
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
      MeanTravelDistance:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_meanTravelDistance;
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
      if AtmospherePressure > 0 then
      begin
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4=agsMain
         then isPrimaryCH4:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO=agsMain
         then isPrimaryCO:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2=agsMain
         then isPrimaryCO2:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2=agsMain
         then isPrimaryH2:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S=agsMain
         then isPrimaryH2S:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceHe=agsMain
         then isPrimaryHe:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2=agsMain
         then isPrimaryN2:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3=agsMain
         then isPrimaryNH3:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2=agsMain
         then isPrimaryNO2:=true;
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2=agsMain
         then isPrimarySO2:=true;
      end;
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
      MeanTravelDistance:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_meanTravelDistance;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions ) - 1;
   end;

   while Count <= Max do
   begin
      FCDfdRegion[Count]:=FCDfdRegion[0];
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
   fInt0:=fInt0 + round( sqrt( abs( RotationPeriod ) ) );
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
               FCDfdRegion[1].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
               FCDfdRegion[1].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod3 ) * 0.5 );
               FCDfdRegion[1].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
               FCDfdRegion[2].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
               FCDfdRegion[2].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * RegionMod1;
               FCDfdRegion[2].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;

               FCDfdRegion[3].RC_surfaceTemperatureClosest:=FCDfdRegion[2].RC_surfaceTemperatureClosest;
               FCDfdRegion[3].RC_surfaceTemperatureFarthest:=FCDfdRegion[2].RC_surfaceTemperatureFarthest;
               FCDfdRegion[3].RC_surfaceTemperatureInterm:=FCDfdRegion[2].RC_surfaceTemperatureInterm;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
               FCDfdRegion[4].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
               FCDfdRegion[4].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod3 ) * 0.5 );
               FCDfdRegion[4].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
            end
            else begin
               fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
               FCDfdRegion[1].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
               FCDfdRegion[1].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod3 ) * 0.5 );
               FCDfdRegion[1].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
               FCDfdRegion[2].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
               FCDfdRegion[2].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * RegionMod1;
               FCDfdRegion[2].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;

               FCDfdRegion[3].RC_surfaceTemperatureClosest:=FCDfdRegion[2].RC_surfaceTemperatureClosest;
               FCDfdRegion[3].RC_surfaceTemperatureFarthest:=FCDfdRegion[2].RC_surfaceTemperatureFarthest;
               FCDfdRegion[3].RC_surfaceTemperatureInterm:=FCDfdRegion[2].RC_surfaceTemperatureInterm;

               fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
               FCDfdRegion[4].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
               FCDfdRegion[4].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
               fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod3 ) * 0.5 );
               FCDfdRegion[4].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
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
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < ( Row + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( Row + 1 ) ) and ( Count <= ( Max - 1 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
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
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < ( Row + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( Row + 1 ) ) and ( Count <= ( Max - 1 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod3 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
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
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod5 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < ( Row + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( Row + 1 ) ) and ( Count < ( ( Row * 2 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 2 ) + 1 ) ) and ( Count <= ( Max - 1 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod5;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod5 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
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
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod5;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod5 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < ( Row + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( Row + 1 ) ) and ( Count < ( ( Row * 2 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 2 ) + 1 ) ) and ( Count <= ( Max - 1 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod5;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod5 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
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
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod6 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < ( Row + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod5;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod5 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( Row + 1 ) ) and ( Count < ( ( Row * 2 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 2 ) + 1 ) ) and ( Count < ( ( Row * 3 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 3 ) + 1 ) ) and ( Count <= ( Max - 1 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod5;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod5 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod3;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod6;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod6 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
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
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod6;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod6 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > 1 ) and ( Count < ( Row + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod2;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod5;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod5 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( Row + 1 ) ) and ( Count < ( ( Row * 2 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod4;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 2 ) + 1 ) ) and ( Count < ( ( Row * 3 ) + 2 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod4;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod1;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod1 + RegionMod4 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if ( Count > ( ( Row * 3 ) + 1 ) ) and ( Count <= ( Max - 1 ) ) then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod5;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod2;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod2 + RegionMod5 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
                  end
                  else if Count = Max then
                  begin
                     fCalc2:=ObjectSurfaceTempClosest * RegionMod6;
                     FCDfdRegion[Count].RC_surfaceTemperatureClosest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempFarthest * RegionMod3;
                     FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=randg( fCalc2, 5 ) * fCalc1;
                     fCalc2:=ObjectSurfaceTempInterm * ( ( RegionMod3 + RegionMod6 ) * 0.5 );
                     FCDfdRegion[Count].RC_surfaceTemperatureInterm:=randg( fCalc2, 5 ) * fCalc1;
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
         FCDfdRegion[Count].RC_surfaceTemperatureClosest:=ObjectSurfaceTempClosest;
         FCDfdRegion[Count].RC_surfaceTemperatureInterm:=ObjectSurfaceTempInterm;
         FCDfdRegion[Count].RC_surfaceTemperatureFarthest:=ObjectSurfaceTempFarthest;
         inc( count );
      end; //==END== while Count <= Max ==//
   end; //==END== else of: if fCalc0 <= 90 ==//
   {.climate and its related data}
   if AtmospherePressure > 0 then
   begin
      {.global precalculations}
      Omega:=( 2 * Pi ) / abs( RotationPeriod * 3600 );
      if isPrimarySO2
      then DryAir:=130
      else if isPrimaryNO2
      then DryAir:=180
      else if isPrimaryCO2
      then DryAir:=188.92
      else if isPrimaryH2S
      then DryAir:=190
      else if isPrimaryCO
      then DryAir:=297
      else if isPrimaryN2
      then DryAir:=287.058
      else if isPrimaryNH3
      then DryAir:=488
      else if isPrimaryCH4
      then DryAir:=518.3
      else if isPrimaryHe
      then DryAir:=2077
      else if isPrimaryH2
      then DryAir:=4124;
      case Max of
         4, 6, 8: RegionRefIndex:=3;

         10: RegionRefIndex:=4;

         14, 18: RegionRefIndex:=8;

         22: RegionRefIndex:=9;

         26: RegionRefIndex:=11;

         30: RegionRefIndex:=12;
      end; //==END== case Max of ==//
      RegionRefLoc:=FCFuF_RegionLoc_ExtractNum( OrbObjLoc, RegionRefIndex );
      Count:=1;
      while Count <= Max do
      begin
         {.region precalculations}
         FCDfdRegion[Count].RC_cTempClosest:=FCDfdRegion[Count].RC_surfaceTemperatureClosest - 273.15;
         FCDfdRegion[Count].RC_cTempInterm:=FCDfdRegion[Count].RC_surfaceTemperatureInterm - 273.15;
         FCDfdRegion[Count].RC_cTempFarthest:=FCDfdRegion[Count].RC_surfaceTemperatureFarthest - 273.15;
         FCDfdRegion[Count].RC_saturationVaporClosest:=6.11 * power( 10, ( 7.5 * FCDfdRegion[Count].RC_cTempClosest / ( 237.7 + FCDfdRegion[Count].RC_cTempClosest ) ) );
         FCDfdRegion[Count].RC_saturationVaporInterm:=6.11 * power( 10, ( 7.5 * FCDfdRegion[Count].RC_cTempInterm / ( 237.7 + FCDfdRegion[Count].RC_cTempInterm ) ) );
         FCDfdRegion[Count].RC_saturationVaporFarthest:=6.11 * power( 10, ( 7.5 * FCDfdRegion[Count].RC_cTempFarthest / ( 237.7 + FCDfdRegion[Count].RC_cTempFarthest ) ) );
         case Hydrosphere of
            hWaterLiquid:
            begin
               FCDfdRegion[Count].RC_vaporPressureDewClosest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureClosest - 228 ) * 0.00767 ) );
               FCDfdRegion[Count].RC_vaporPressureDewInterm:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureInterm - 228 ) * 0.00767 ) );
               FCDfdRegion[Count].RC_vaporPressureDewFarthest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureFarthest - 228 ) * 0.00767 ) );
            end;

            hWaterIceSheet, hWaterIceCrust:
            begin
               FCDfdRegion[Count].RC_vaporPressureDewClosest:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureClosest - 228 ) * 0.00767 ) );
               FCDfdRegion[Count].RC_vaporPressureDewInterm:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureInterm - 228 ) * 0.00767 ) );
               FCDfdRegion[Count].RC_vaporPressureDewFarthest:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureFarthest - 228 ) * 0.00767 ) );
            end;

            hWaterAmmoniaLiquid:
            begin
               FCDfdRegion[Count].RC_vaporPressureDewClosest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureClosest - 146 ) * 0.00767 ) );
               FCDfdRegion[Count].RC_vaporPressureDewInterm:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureInterm - 146 ) * 0.00767 ) );
               FCDfdRegion[Count].RC_vaporPressureDewFarthest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureFarthest - 146 ) * 0.00767 ) );
            end;

            hMethaneLiquid:
            begin
               FCDfdRegion[Count].RC_vaporPressureDewClosest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureClosest - 66 ) * 0.00767 ) );
               FCDfdRegion[Count].RC_vaporPressureDewInterm:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureInterm - 66 ) * 0.00767 ) );
               FCDfdRegion[Count].RC_vaporPressureDewFarthest:=( HydroArea * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureFarthest - 66 ) * 0.00767 ) );
            end;

            hMethaneIceSheet, hMethaneIceCrust:
            begin
               FCDfdRegion[Count].RC_vaporPressureDewClosest:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureClosest - 66 ) * 0.00767 ) );
               FCDfdRegion[Count].RC_vaporPressureDewInterm:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureInterm - 66 ) * 0.00767 ) );
               FCDfdRegion[Count].RC_vaporPressureDewFarthest:=( ( 100 - HydroArea ) * 0.1 ) * ( 1 - ( ( FCDfdRegion[Count].RC_surfaceTemperatureFarthest - 66 ) * 0.00767 ) );
            end;
         end; //==END== case Hydrosphere of ==//
         {.fix: prevent low temperatures to generate incoherent vapor dew and so relative humidity }
         if FCDfdRegion[Count].RC_vaporPressureDewClosest=0
         then FCDfdRegion[Count].RC_vaporPressureDewClosest:=FCDfdRegion[Count].RC_saturationVaporClosest * 0.01
         else if FCDfdRegion[Count].RC_vaporPressureDewClosest > FCDfdRegion[Count].RC_saturationVaporClosest
         then FCDfdRegion[Count].RC_vaporPressureDewClosest:=FCDfdRegion[Count].RC_saturationVaporClosest / FCDfdRegion[Count].RC_vaporPressureDewClosest;
         if FCDfdRegion[Count].RC_vaporPressureDewInterm=0
         then FCDfdRegion[Count].RC_vaporPressureDewInterm:=FCDfdRegion[Count].RC_saturationVaporInterm * 0.01
         else if FCDfdRegion[Count].RC_vaporPressureDewInterm > FCDfdRegion[Count].RC_saturationVaporInterm
         then FCDfdRegion[Count].RC_vaporPressureDewInterm:=FCDfdRegion[Count].RC_saturationVaporInterm / FCDfdRegion[Count].RC_vaporPressureDewInterm;
         if FCDfdRegion[Count].RC_vaporPressureDewFarthest=0
         then FCDfdRegion[Count].RC_vaporPressureDewFarthest:=FCDfdRegion[Count].RC_saturationVaporFarthest * 0.01
         else if FCDfdRegion[Count].RC_vaporPressureDewFarthest > FCDfdRegion[Count].RC_saturationVaporFarthest
         then FCDfdRegion[Count].RC_vaporPressureDewFarthest:=FCDfdRegion[Count].RC_saturationVaporFarthest / FCDfdRegion[Count].RC_vaporPressureDewFarthest;
         {.end of fix}
         FCDfdRegion[Count].RC_relativeHumidityClosest:=( FCDfdRegion[Count].RC_vaporPressureDewClosest * 100 ) /  FCDfdRegion[Count].RC_saturationVaporClosest;
         if FCDfdRegion[Count].RC_relativeHumidityClosest < 0
         then FCDfdRegion[Count].RC_relativeHumidityClosest:=0
         else if FCDfdRegion[Count].RC_relativeHumidityClosest > 100
         then FCDfdRegion[Count].RC_relativeHumidityClosest:=100;
         FCDfdRegion[Count].RC_relativeHumidityInterm:=( FCDfdRegion[Count].RC_vaporPressureDewInterm * 100 ) /  FCDfdRegion[Count].RC_saturationVaporInterm;
         if FCDfdRegion[Count].RC_relativeHumidityInterm < 0
         then FCDfdRegion[Count].RC_relativeHumidityInterm:=0
         else if FCDfdRegion[Count].RC_relativeHumidityInterm > 100
         then FCDfdRegion[Count].RC_relativeHumidityInterm:=100;
         FCDfdRegion[Count].RC_relativeHumidityFarthest:=( FCDfdRegion[Count].RC_vaporPressureDewFarthest * 100 ) /  FCDfdRegion[Count].RC_saturationVaporFarthest;
         if FCDfdRegion[Count].RC_relativeHumidityFarthest < 0
         then FCDfdRegion[Count].RC_relativeHumidityFarthest:=0
         else if FCDfdRegion[Count].RC_relativeHumidityFarthest > 100
         then FCDfdRegion[Count].RC_relativeHumidityFarthest:=100;
         if FCDfdRegion[Count].RC_vaporPressureDewClosest >= AtmospherePressure
         then FCDfdRegion[Count].RC_regionPressureClosest:=AtmospherePressure
         else FCDfdRegion[Count].RC_regionPressureClosest:=FCDfdRegion[Count].RC_vaporPressureDewClosest;
         if FCDfdRegion[Count].RC_vaporPressureDewInterm >= AtmospherePressure
         then FCDfdRegion[Count].RC_regionPressureInterm:=AtmospherePressure
         else FCDfdRegion[Count].RC_regionPressureInterm:=FCDfdRegion[Count].RC_vaporPressureDewInterm;
         if FCDfdRegion[Count].RC_vaporPressureDewFarthest >= AtmospherePressure
         then FCDfdRegion[Count].RC_regionPressureFarthest:=AtmospherePressure
         else FCDfdRegion[Count].RC_regionPressureFarthest:=FCDfdRegion[Count].RC_vaporPressureDewFarthest;
         {.windspeed calculations}
         _Windspeed_Calculation( RegionRefIndex );
         {.region's climate calculations}
         {:DEV NOTES:
            fInt0: h
            fCalc0: meanRH
            fCalc1: meanST
         }
         FCDfdRegion[Count].RC_finalClimate:=rc00VoidNoUse;
         fCalc0:=( FCDfdRegion[Count].RC_relativeHumidityClosest + FCDfdRegion[Count].RC_relativeHumidityInterm + FCDfdRegion[Count].RC_relativeHumidityFarthest ) / 3;
         fCalc1:=( FCDfdRegion[Count].RC_surfaceTemperatureClosest + FCDfdRegion[Count].RC_surfaceTemperatureInterm + FCDfdRegion[Count].RC_surfaceTemperatureFarthest ) / 3;
         if ( fCalc1 >= 500 )
            and ( fCalc0 = 0 )
         then FCDfdRegion[Count].RC_finalClimate:=rc10Extreme
         else if ( fCalc1 < 293 )
            and ( fCalc0 < 6 )
         then FCDfdRegion[Count].RC_finalClimate:=rc07ColdArid
         else if fCalc1 < 273 then
         begin
            fInt0:=0;
            if FCDfdRegion[Count].RC_surfaceTemperatureClosest >= 273
            then inc( fInt0 );
            if FCDfdRegion[Count].RC_surfaceTemperatureInterm >= 273
            then inc( fInt0 );
            if FCDfdRegion[Count].RC_surfaceTemperatureFarthest >= 273
            then inc( fInt0 );
            if fInt0 = 0
            then FCDfdRegion[Count].RC_finalClimate:=rc09Arctic
            else FCDfdRegion[Count].RC_finalClimate:=rc07ColdArid;
         end
         else if ( fCalc1 >= 273 )
            and ( fCalc1 < 293 ) then
         begin
            if ( fCalc0 >= 6 )
               and ( fCalc0 < 15 )
            then FCDfdRegion[Count].RC_finalClimate:=rc08Periarctic
            else if ( fCalc0 >= 15 )
               and ( fCalc0 < 30 )
            then FCDfdRegion[Count].RC_finalClimate:=rc06ModerateDry
            else if fCalc0 >= 30
            then FCDfdRegion[Count].RC_finalClimate:=rc05ModerateHumid;
         end
         else if fCalc1 >= 293 then
         begin
            if fCalc0 < 15
            then FCDfdRegion[Count].RC_finalClimate:=rc04HotArid
            else if ( fCalc0 >= 15 )
               and ( fCalc0 <= 36 )
            then FCDfdRegion[Count].RC_finalClimate:=rc03HotSemiArid
            else if ( fCalc0 > 36 )
               and ( fCalc0 <= 90 )
            then FCDfdRegion[Count].RC_finalClimate:=rc02VeryHotSemiHumid
            else if fCalc0 > 90
            then FCDfdRegion[Count].RC_finalClimate:=rc01VeryHotHumid;
         end;
         {.region's rainfall calculations}
         {:DEV NOTES:
            fInt0: x
            fInt1: RBF
            fCalc0: modRH
         }
         fInt0:=0;
         fInt1:=0;
         case FCDfdRegion[Count].RC_finalClimate of
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
         end; //==END== case FCDfdRegion[Count].RC_finalClimate of ==//
         fCalc0:=FCDfdRegion[Count].RC_relativeHumidityClosest * 0.01;
         if ( fInt0 > 0 )
            and ( FCDfdRegion[Count].RC_windspeedClosest > 0 )
            and ( fCalc0 > 0 )
         then FCDfdRegion[Count].RC_rainfallClosest:=_RainfallCalculation(
            fInt0
            ,fInt1
            ,FCDfdRegion[Count].RC_windspeedClosest
            ,fCalc0
            );
         fCalc0:=FCDfdRegion[Count].RC_relativeHumidityInterm * 0.01;
         if ( fInt0 > 0 )
            and ( FCDfdRegion[Count].RC_windspeedInterm > 0 )
            and ( fCalc0 > 0 )
         then FCDfdRegion[Count].RC_rainfallInterm:=_RainfallCalculation(
            fInt0
            ,fInt1
            ,FCDfdRegion[Count].RC_windspeedInterm
            ,fCalc0
            );
         fCalc0:=FCDfdRegion[Count].RC_relativeHumidityFarthest * 0.01;
         if ( fInt0 > 0 )
            and ( FCDfdRegion[Count].RC_windspeedFarthest > 0 )
            and ( fCalc0 > 0 )
         then FCDfdRegion[Count].RC_rainfallFarthest:=_RainfallCalculation(
            fInt0
            ,fInt1
            ,FCDfdRegion[Count].RC_windspeedFarthest
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
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_climate:=FCDfdRegion[Count].RC_finalClimate;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonClosest.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfdRegion[Count].RC_surfaceTemperatureClosest );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonClosest.OP_windspeed:=FCDfdRegion[Count].RC_windspeedClosest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonClosest.OP_rainfall:=FCDfdRegion[Count].RC_rainfallClosest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonIntermediate.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfdRegion[Count].RC_surfaceTemperatureInterm );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonIntermediate.OP_windspeed:=FCDfdRegion[Count].RC_windspeedInterm;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonIntermediate.OP_rainfall:=FCDfdRegion[Count].RC_rainfallInterm;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonFarthest.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfdRegion[Count].RC_surfaceTemperatureFarthest );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonFarthest.OP_windspeed:=FCDfdRegion[Count].RC_windspeedFarthest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Count].OOR_seasonFarthest.OP_rainfall:=FCDfdRegion[Count].RC_rainfallFarthest;
         inc( Count );
      end; //==END== while Count <= Max ==//
   end
   else if Satellite > 0 then
   begin
      Count:=1;
      while Count <= Max do
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_climate:=FCDfdRegion[Count].RC_finalClimate;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonClosest.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfdRegion[Count].RC_surfaceTemperatureClosest );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonClosest.OP_windspeed:=FCDfdRegion[Count].RC_windspeedClosest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonClosest.OP_rainfall:=FCDfdRegion[Count].RC_rainfallClosest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonIntermediate.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfdRegion[Count].RC_surfaceTemperatureInterm );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonIntermediate.OP_windspeed:=FCDfdRegion[Count].RC_windspeedInterm;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonIntermediate.OP_rainfall:=FCDfdRegion[Count].RC_rainfallInterm;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonFarthest.OP_meanTemperature:=FCFcF_Round( rttCustom2Decimal, FCDfdRegion[Count].RC_surfaceTemperatureFarthest );
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonFarthest.OP_windspeed:=FCDfdRegion[Count].RC_windspeedFarthest;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Count].OOR_seasonFarthest.OP_rainfall:=FCDfdRegion[Count].RC_rainfallFarthest;
         inc( Count );
      end; //==END== while Count <= Max ==//
   end;
end;

end.

