{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - hydrosphere unit

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
unit farc_fug_hydrosphere;

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
///   main rule for the process of the hydrosphere
///</summary>
/// <param name="Star">star's index #</param>
/// <param name="OrbitalObject">orbital object's index #</param>
/// <param name="BaseTemperature">base temperature in K</param>
/// <param name="Satellite">optional parameter, only for any satellite</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMfH_Hydrosphere_Processing(
   const Star
         ,OrbitalObject: integer;
   const BaseTemperature: extended;
   const Satellite: integer=0
   );

implementation

uses
   farc_common_func
   ,farc_data_univ
   ,farc_fug_atmosphere;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfH_Hydrosphere_Processing(
   const Star
         ,OrbitalObject: integer;
   const BaseTemperature: extended;
   const Satellite: integer=0
   );
{:Purpose: main rule for the process of the hydrosphere.
   Additions:
      -2013Sep04- *mod: atmospheric conditions for CH4/NH3 ecospheres are modified.
      -2013Sep03- *add: trace atmosphere in the same case as atmosphereless objects.
                  *mod: reduced random complexity when it's not needed.
      -2013Sep01- *add: asteroids.
      -2013Jul07- *mod: boiling/melting point adjustments.
      -2013Jul02- *add: conditions to process the hydrosphere or not.
}
   var
      GeneratedProbability
      ,HydroArea
      ,HydroAreaFactor
      ,NumberOfPrimaryGasses
      ,PrimaryGasVolume: integer;

      isHydrosphereEdited: boolean;

      AtmosphericPressure
      ,BoilingPoint
      ,Distance20
      ,Distance30
      ,DistanceFromStar
      ,DistanceZone
      ,IceCrustThreshold
      ,MeltingPoint
      ,Radius
      ,VaporLimit: extended;

      isTraceAtm: boolean;

      HydrosphereType: TFCEduHydrospheres;

      AmmoniaStatus
      ,HydrogenStatus
      ,MethaneStatus
      ,NitrogenStatus
      ,WaterStatus
      ,NewAmmoniaStatus
      ,NewMetaneStatus
      ,NewWaterStatus: TFCEduAtmosphericGasStatus;

      BasicType: TFCEduOrbitalObjectBasicTypes;
begin
   GeneratedProbability:=0;
   HydroArea:=0;
   NumberOfPrimaryGasses:=0;
   PrimaryGasVolume:=0;
   isHydrosphereEdited:=false;
   AtmosphericPressure:=0;
   BoilingPoint:=0;
   Distance20:=0;
   Distance30:=0;
   DistanceFromStar:=0;
   DistanceZone:=0;
   IceCrustThreshold:=0;
   MeltingPoint:=0;
   Radius:=0;
   VaporLimit:=0;

   isTraceAtm:=false;

   HydrosphereType:=hNoHydro;

   AmmoniaStatus:=agsNotPresent;
   HydrogenStatus:=agsNotPresent;
   MethaneStatus:=agsNotPresent;
   NitrogenStatus:=agsNotPresent;
   WaterStatus:=agsNotPresent;
   NewAmmoniaStatus:=agsNotPresent;
   NewMetaneStatus:=agsNotPresent;
   NewWaterStatus:=agsNotPresent;
   BasicType:=oobtNone;
   if Satellite=0 then
   begin
      DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      AtmosphericPressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure / 1000;
      isTraceAtm:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_traceAtmosphere;
      AmmoniaStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3;
      HydrogenStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2;
      MethaneStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4;
      NitrogenStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2;
      WaterStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O;
      PrimaryGasVolume:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_primaryGasVolumePerc;
      Radius:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_diameter * 0.5;
      isHydrosphereEdited:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isHydrosphereEdited;
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_fug_BasicType;
   end
   else begin
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_fug_BasicType = oobtAsteroidBelt
      then DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar
      else DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      AtmosphericPressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure / 1000;
      isTraceAtm:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_traceAtmosphere;
      AmmoniaStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3;
      HydrogenStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2;
      MethaneStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4;
      NitrogenStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2;
      WaterStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O;
      PrimaryGasVolume:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_primaryGasVolumePerc;
      Radius:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_diameter * 0.5;
      isHydrosphereEdited:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_isHydrosphereEdited;
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_fug_BasicType;
   end;
   NewAmmoniaStatus:=AmmoniaStatus;
   NewMetaneStatus:=MethaneStatus;
   NewWaterStatus:=WaterStatus;
   if ( FCDduStarSystem[0].SS_stars[Star].S_class < WD0 )
      and ( not isHydrosphereEdited )
      and ( ( BasicType = oobtTelluricPlanet ) or ( BasicType = oobtIcyPlanet ) or ( BasicType = oobtAsteroid ) ) then
   begin
      {.hydrosphere for atmosphereless/trace atmosphere planets}
      if ( AtmosphericPressure=0 )
         or ( isTraceAtm )
         then
      begin
         DistanceZone:=sqrt( FCDduStarSystem[0].SS_stars[Star].S_luminosity / 0.53 );
         Distance20:=DistanceZone * 20;
         Distance30:=DistanceZone * 30;
         if DistanceFromStar <= Distance20 then
         begin
            if BaseTemperature <= 110
            then HydrosphereType:=hWaterIceCrust
            else if ( BaseTemperature > 110 )
               and ( BaseTemperature <= 245)
            then HydrosphereType:=hWaterIceSheet
            else HydrosphereType:=hNoHydro;
         end
         else if ( DistanceFromStar > Distance20 )
            and ( DistanceFromStar <= Distance30 ) then
         begin
            if BaseTemperature <= 110 then
            begin
               GeneratedProbability:=FCFcF_Random_DoInteger( 9 ) + 1;
               if GeneratedProbability<=7
               then HydrosphereType:=hWaterIceCrust
               else begin
                  if BaseTemperature <= 63
                  then HydrosphereType:=hNitrogenIceCrust
                  else HydrosphereType:=hWaterIceCrust;
               end;
            end
            else if ( BaseTemperature > 110 )
               and ( BaseTemperature <= 245)
            then HydrosphereType:=hWaterIceSheet
            else HydrosphereType:=hNoHydro;
         end
         else begin
            if BaseTemperature <= 110 then
            begin
               GeneratedProbability:=FCFcF_Random_DoInteger( 9 ) + 1;
               case GeneratedProbability of
                  1..2: HydrosphereType:=hWaterIceCrust;

                  3..6:
                  begin
                     if BaseTemperature <= 63
                     then HydrosphereType:=hNitrogenIceCrust
                     else HydrosphereType:=hWaterIceCrust;
                  end;

                  7..10:
                  begin
                     if BaseTemperature <= 90
                     then HydrosphereType:=hMethaneIceCrust
                     else HydrosphereType:=hWaterIceCrust;
                  end;
               end;

            end
            else if ( BaseTemperature > 110 )
               and ( BaseTemperature <= 245)
            then HydrosphereType:=hWaterIceSheet
            else HydrosphereType:=hNoHydro;
         end;
      end
      {.hydrosphere for planets with (no trace) atmosphere}
      else begin
         NumberOfPrimaryGasses:=FCFfA_PrimaryGasses_GetTotalNumber(
            Star
            ,OrbitalObject
            ,Satellite
            );
         {.methane hydrosphere}
         if ( ( MethaneStatus >= agsSecondary ) or ( NitrogenStatus = agsPrimary ) )
            and ( BaseTemperature < 146 ) then
         begin
            BoilingPoint:=1 / ( ( ln( sqrt( AtmosphericPressure ) ) / -2392.5 ) + ( 1 / 109 ) );
            MeltingPoint:=1 / ( ( ln( sqrt( AtmosphericPressure ) ) / -2392.5 ) + ( 1 / 90.7 ) );
            IceCrustThreshold:=MeltingPoint * 193 / 273.15;
            VaporLimit:=BoilingPoint * 500 / 373.15;
            if BaseTemperature <= IceCrustThreshold
            then HydrosphereType:=hMethaneIceCrust
            else if ( BaseTemperature > IceCrustThreshold )
               and ( BaseTemperature < MeltingPoint )
            then HydrosphereType:=hMethaneIceSheet
            else if ( BaseTemperature >= MeltingPoint )
               and ( BaseTemperature < BoilingPoint ) then
            begin
               HydrosphereType:=hMethaneLiquid;
               if MethaneStatus < agsSecondary
               then NewMetaneStatus:=agsSecondary
               else if MethaneStatus = agsSecondary
               then NewMetaneStatus:=agsPrimary;
            end
            else if ( BaseTemperature >= BoilingPoint )
               and ( BaseTemperature <= VaporLimit )
            then HydrosphereType:=hNoHydro
            else if BaseTemperature > VaporLimit then
            begin
               HydrosphereType:=hNoHydro;
               if ( ( MethaneStatus = agsPrimary ) and ( NumberOfPrimaryGasses > 1 ) )
                  or ( MethaneStatus = agsSecondary )
               then NewMetaneStatus:=agsTrace;
            end;
         end
         {.water-ammonia hydrosphere}
         else if ( ( AmmoniaStatus >= agsSecondary ) or ( HydrogenStatus = agsPrimary ) )
            and ( BaseTemperature < 321 ) then
         begin
            BoilingPoint:=1 / ( ( ln( sqrt( AtmosphericPressure ) ) / -2392.5 ) + ( 1 / 240 ) );
            MeltingPoint:=1 / ( ( ln( sqrt( AtmosphericPressure ) ) / -2392.5 ) + ( 1 / 195 ) );
            IceCrustThreshold:=MeltingPoint * 193 / 273.15;
            VaporLimit:=BoilingPoint * 500 / 373.15;
            if BaseTemperature <= IceCrustThreshold
            then HydrosphereType:=hWaterIceCrust
            else if ( BaseTemperature > IceCrustThreshold )
               and ( BaseTemperature < MeltingPoint )
            then HydrosphereType:=hWaterIceSheet
            else if ( BaseTemperature >= MeltingPoint )
               and ( BaseTemperature < BoilingPoint ) then
            begin
               HydrosphereType:=hWaterAmmoniaLiquid;
               if WaterStatus=agsNotPresent
               then NewWaterStatus:=agsTrace;
               if AmmoniaStatus < agsSecondary
               then NewAmmoniaStatus:=agsSecondary
               else if AmmoniaStatus = agsSecondary
               then NewAmmoniaStatus:=agsPrimary;
            end
            else if ( BaseTemperature >= BoilingPoint )
               and ( BaseTemperature <= VaporLimit ) then
            begin
               HydrosphereType:=hNoHydro;
               if WaterStatus=agsNotPresent
               then NewWaterStatus:=agsTrace
               else if WaterStatus=agsTrace
               then NewWaterStatus:=agsSecondary;
            end
            else if BaseTemperature > VaporLimit then
            begin
               HydrosphereType:=hNoHydro;
               if ( ( AmmoniaStatus = agsPrimary ) and ( NumberOfPrimaryGasses > 1 ) )
                  or ( AmmoniaStatus = agsSecondary )
               then NewAmmoniaStatus:=agsTrace;
               if ( ( WaterStatus = agsPrimary ) and ( NumberOfPrimaryGasses > 1 ) )
                  or ( WaterStatus = agsSecondary )
               then NewWaterStatus:=agsTrace;
            end;
         end
         {.water hydrosphere}
         else begin
            BoilingPoint:=1 / ( ( ln( sqrt( AtmosphericPressure ) ) / -2392.5 ) + ( 1 / 373.15 ) );
            MeltingPoint:=1 / ( ( ln( sqrt( AtmosphericPressure ) ) / -2392.5 ) + ( 1 / 273.15 ) );
            IceCrustThreshold:=MeltingPoint * 193 / 273.15;
            VaporLimit:=BoilingPoint * 500 / 373.15;
            if BaseTemperature <= IceCrustThreshold
            then HydrosphereType:=hWaterIceCrust
            else if ( BaseTemperature > IceCrustThreshold )
               and ( BaseTemperature < MeltingPoint )
            then HydrosphereType:=hWaterIceSheet
            else if ( BaseTemperature >= MeltingPoint )
               and ( BaseTemperature < BoilingPoint ) then
            begin
               HydrosphereType:=hWaterLiquid;
               if WaterStatus=agsNotPresent
               then NewWaterStatus:=agsTrace;
            end
            else if ( BaseTemperature >= BoilingPoint )
               and ( BaseTemperature <= VaporLimit ) then
            begin
               HydrosphereType:=hNoHydro;
               if WaterStatus=agsNotPresent
               then NewWaterStatus:=agsTrace
               else if WaterStatus=agsTrace
               then NewWaterStatus:=agsSecondary;
            end
            else if BaseTemperature > VaporLimit then
            begin
               HydrosphereType:=hNoHydro;
               if ( ( WaterStatus = agsPrimary ) and ( NumberOfPrimaryGasses > 1 ) )
                  or ( WaterStatus = agsSecondary )
               then NewWaterStatus:=agsTrace;
            end;
         end;
      end; //==END== else of: if AtmosphericPressure=0 ==//
      {.hydrosphere area}
      if ( ( HydrosphereType > hNoHydro ) and ( HydrosphereType < hWaterIceCrust ) )
         or ( ( HydrosphereType > hWaterIceCrust ) and ( HydrosphereType < hMethaneIceCrust ) )
         or ( HydrosphereType = hNitrogenIceSheet ) then
      begin
         HydroAreaFactor:=round( power( BaseTemperature, 0.333 ) ) - 2;
         GeneratedProbability:=FCFcF_Random_DoInteger( 9 ) + HydroAreaFactor;
         if GeneratedProbability > 10
         then GeneratedProbability:=10;
         if Radius < 2000 then
         begin
            case GeneratedProbability of
               1..5: HydroArea:=FCFcF_Random_DoInteger( 4 ) + 1;

               6..7: HydroArea:=FCFcF_Random_DoInteger( 9 ) + 1;

               8: HydroArea:=10 + FCFcF_Random_DoInteger( 10 );

               9: HydroArea:=FCFcF_Random_DoInteger( 45 ) + 5;

               10: HydroArea:=20 + FCFcF_Random_DoInteger( 90 );
            end;
         end
         else if ( Radius >= 2000 )
            and ( Radius < 4000 ) then
         begin
            case GeneratedProbability of
               1..2: HydroArea:=FCFcF_Random_DoInteger( 4 ) + 1;

               3..4: HydroArea:=FCFcF_Random_DoInteger( 9 ) + 1;

               5: HydroArea:=10 + FCFcF_Random_DoInteger( 10 );

               6: HydroArea:=20 + FCFcF_Random_DoInteger( 10 );

               7: HydroArea:=30 + FCFcF_Random_DoInteger( 10 );

               8: HydroArea:=40 + FCFcF_Random_DoInteger( 10 );

               9: HydroArea:=50 + FCFcF_Random_DoInteger( 10 );

               10: HydroArea:=20 + FCFcF_Random_DoInteger( 90 );
            end;
         end
         else if ( Radius >= 4000 )
            and ( Radius < 7000 ) then
         begin
            case GeneratedProbability of
               1: HydroArea:=FCFcF_Random_DoInteger( 5 );

               2: HydroArea:=FCFcF_Random_DoInteger( 18 ) + 2;

               3: HydroArea:=20 + FCFcF_Random_DoInteger( 10 );

               4: HydroArea:=30 + FCFcF_Random_DoInteger( 10 );

               5: HydroArea:=40 + FCFcF_Random_DoInteger( 10 );

               6: HydroArea:=50 + FCFcF_Random_DoInteger( 10 );

               7: HydroArea:=60 + FCFcF_Random_DoInteger( 10 );

               8: HydroArea:=70 + FCFcF_Random_DoInteger( 10 );

               9: HydroArea:=82 + FCFcF_Random_DoInteger( 18 );

               10: HydroArea:=100;
            end;
         end
         else if Radius >= 7000 then
         begin
            case GeneratedProbability of
               1: HydroArea:=FCFcF_Random_DoInteger( 5 );

               2: HydroArea:=FCFcF_Random_DoInteger( 18 ) + 2;

               3: HydroArea:=20 + FCFcF_Random_DoInteger( 18 ) + 2;

               4: HydroArea:=40 + FCFcF_Random_DoInteger( 18 ) + 2;

               5: HydroArea:=60 + FCFcF_Random_DoInteger( 9 ) + 1;

               6: HydroArea:=70 + FCFcF_Random_DoInteger( 9 ) + 1;

               7: HydroArea:=80 + FCFcF_Random_DoInteger( 9 ) + 1;

               8: HydroArea:=90 + FCFcF_Random_DoInteger( 9 ) + 1;

               9..10: HydroArea:=100;
            end;
         end;
      end  //==END== if ( ( HydrosphereType > hNoHydro ) and ( HydrosphereType < hWaterIceCrust ) ) or ( ( HydrosphereType > hWaterIceCrust ) and ( HydrosphereType < hMethaneIceCrust ) ) or ( HydrosphereType = hNitrogenIceSheet ) ==//
      else if ( HydrosphereType > hNoHydro )
      then HydroArea:=100
      else HydroArea:=0;
   end
   else if FCDduStarSystem[0].SS_stars[Star].S_class >= WD0 then
   begin
      isHydrosphereEdited:=false;
      HydrosphereType:=hNoHydro;
      HydroArea:=0;
   end;
   {.data loading}
   if Satellite=0 then
   begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isHydrosphereEdited:=isHydrosphereEdited;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere:=HydrosphereType;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea:=HydroArea;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4:=NewMetaneStatus;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3:=NewAmmoniaStatus;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O:=NewWaterStatus;
   end
   else begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_isHydrosphereEdited:=isHydrosphereEdited;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere:=HydrosphereType;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea:=HydroArea;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4:=NewMetaneStatus;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3:=NewAmmoniaStatus;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O:=NewWaterStatus;
   end;
end;

end.
