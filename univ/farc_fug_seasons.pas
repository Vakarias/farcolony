{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - orbital periods/seasonal effects unit

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
unit farc_fug_seasons;

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
///   generate the orbital periods and their base effects
///</summary>
/// <param name="Star">star's index #</param>
/// <param name="OrbitalObject">orbital object's index #</param>
/// <param name="Satellite">optional parameter, only for any satellite</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfS_OrbitalPeriods_Generate(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

implementation

uses
   farc_common_func
   ,farc_data_univ
   ,farc_fug_geophysical
   ,farc_fug_hydrosphere;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFfS_HydroCoef_Get( const Hydrosphere: TFCEduHydrospheres ): extended;
{:Purpose: return the hydrosphere coefficient.
    Additions:
}
begin
   Result:=0;
   if ( Hydrosphere > hNoHydro )
      and ( Hydrosphere < hWaterAmmoniaLiquid )
   then Result:=288.15
   else if Hydrosphere = hWaterAmmoniaLiquid
   then Result:=210
   else if ( Hydrosphere > hWaterAmmoniaLiquid )
      and ( Hydrosphere < hNitrogenIceSheet )
   then Result:=105.7
   else if Hydrosphere > hMethaneIceCrust
   then Result:=78;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMfS_OrbitalPeriods_Generate(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: generate the orbital periods and their base effects
   Additions:
      -2013Sep01- *add: allow asteroids to have atmosphereless hydrosphere.
      -2013Aug25- *add: calculate the greenhouse to be stored for Fractal Terrains use.
      -2013Aug03- *fix: mis-assignment for intermediary orbital periods.
      -2013Jul07- *fix: addition of special conditions for asteroid belts.
                  *mod: greenhouse calculations adjustments.
                  *fix: prevent calculated clouds cover > 100.
}
   var
      Components
      ,Count
      ,Count1
      ,GeneratedProbability
      ,HydrosphereArea
      ,PrimaryGasVolume
      ,RevolutionPeriodPart
      ,TectonicActivityIndex: integer;

      Albedo
      ,AtmospherePressure
      ,CalcFloat
      ,CloudAdjustment
      ,CloudContribution
      ,CloudFraction
      ,CloudsCover
      ,ConvectionFactor
      ,DistanceFromStar
      ,DistMax
      ,DistMin
      ,Eccentricity
      ,GreenHouse
      ,GreenCH4
      ,GreenCO2
      ,GreenH2O
      ,GreenSO2
      ,GreenTotal
      ,GreenRise
      ,HydroAreaFrac
      ,HydroCoef
      ,OpticalDepth
      ,RockContribution
      ,RockFraction
      ,TemperatureMean
      ,WorkHydro: extended;

      isHydroEdited
      ,isLoadHydrosphere
      ,isSatToLoadFromRoot: boolean;

      OrbitalPeriodsWork: array[0..4] of TFCRduOObSeason;

      BasicType: TFCEduOrbitalObjectBasicTypes;

      FinalType: TFCEduOrbitalObjectTypes;

      Hydrosphere: TFCEduHydrospheres;

      GasCH4
      ,GasCO2
      ,GasH2O
      ,GasN2
      ,GasSO2: TFCEduAtmosphericGasStatus;
begin
   Components:=0;
   Count:=0;
   Count1:=0;
   GeneratedProbability:=0;
   HydrosphereArea:=0;
   PrimaryGasVolume:=0;
   RevolutionPeriodPart:=0;
   TectonicActivityIndex:=0;

   Albedo:=0;
   AtmospherePressure:=0;
   CalcFloat:=0;
   CloudAdjustment:=0;
   CloudContribution:=0;
   CloudFraction:=0;
   CloudsCover:=0;
   ConvectionFactor:=0;
   DistanceFromStar:=0;
   DistMax:=0;
   DistMin:=0;
   GreenHouse:=0;
   GreenCH4:=0;
   GreenCO2:=0;
   GreenH2O:=0;
   GreenSO2:=0;
   GreenTotal:=0;
   GreenRise:=0;
   HydroAreaFrac:=0;
   HydroCoef:=0;
   OpticalDepth:=0;
   RockContribution:=0;
   RockFraction:=0;
   TemperatureMean:=0;
   WorkHydro:=0;

   isHydroEdited:=false;
   isLoadHydrosphere:=false;
   isSatToLoadFromRoot:=false;

   OrbitalPeriodsWork[1]:=OrbitalPeriodsWork[0];
   OrbitalPeriodsWork[2]:=OrbitalPeriodsWork[0];
   OrbitalPeriodsWork[3]:=OrbitalPeriodsWork[0];
   OrbitalPeriodsWork[4]:=OrbitalPeriodsWork[0];

   BasicType:=oobtNone;

   FinalType:=ootNone;

   Hydrosphere:=hNoHydro;

   GasCH4:=agsNotPresent;
   GasCO2:=agsNotPresent;
   GasH2O:=agsNotPresent;
   GasSO2:=agsNotPresent;
   Eccentricity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity;
   if Satellite=0 then
   begin
      RevolutionPeriodPart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod div 4;
      DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_fug_BasicType;
      FinalType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type;
      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure;
      PrimaryGasVolume:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_primaryGasVolumePerc;
      GasCH4:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4;
      GasCO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2;
      GasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O;
      GasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2;
      GasSO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2;
      TectonicActivityIndex:=Integer( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity );
      isHydroEdited:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isHydrosphereEdited;
   end
   else begin
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type=ootAsteroidsBelt then
      begin
         RevolutionPeriodPart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_revolutionPeriod div 4;
         DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar;
      end
      else begin
         isSatToLoadFromRoot:=true;
         RevolutionPeriodPart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod div 4;
         DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
         Count:=1;
         while Count <= 4 do
         begin
            OrbitalPeriodsWork[Count].OOS_orbitalPeriodType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_orbitalPeriodType;
            OrbitalPeriodsWork[Count].OOS_dayStart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_dayStart;
            OrbitalPeriodsWork[Count].OOS_dayEnd:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_dayEnd;
            OrbitalPeriodsWork[Count].OOS_baseTemperature:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_baseTemperature;
            inc( Count );
         end;
      end;
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_fug_BasicType;
      FinalType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_type;
      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure;
      PrimaryGasVolume:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_primaryGasVolumePerc;
      GasCH4:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4;
      GasCO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2;
      GasH2O:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O;
      GasN2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2;
      GasSO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2;
      TectonicActivityIndex:=Integer( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity );
      isHydroEdited:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_isHydrosphereEdited;
   end;
   {.init part}
   if BasicType=oobtAsteroidBelt then
   begin
      OrbitalPeriodsWork[1].OOS_orbitalPeriodType:=optIntermediary;
      OrbitalPeriodsWork[1].OOS_dayStart:=0;
      OrbitalPeriodsWork[1].OOS_dayEnd:=0;
      OrbitalPeriodsWork[2].OOS_orbitalPeriodType:=optIntermediary;
      OrbitalPeriodsWork[2].OOS_dayStart:=0;
      OrbitalPeriodsWork[2].OOS_dayEnd:=0;
      OrbitalPeriodsWork[3].OOS_orbitalPeriodType:=optIntermediary;
      OrbitalPeriodsWork[3].OOS_dayStart:=0;
      OrbitalPeriodsWork[3].OOS_dayEnd:=0;
      OrbitalPeriodsWork[4].OOS_orbitalPeriodType:=optIntermediary;
      OrbitalPeriodsWork[4].OOS_dayStart:=0;
      OrbitalPeriodsWork[4].OOS_dayEnd:=0;
   end
   else if not isSatToLoadFromRoot then
   begin
      OrbitalPeriodsWork[1].OOS_dayStart:=1;
      OrbitalPeriodsWork[1].OOS_dayEnd:=RevolutionPeriodPart;
      OrbitalPeriodsWork[2].OOS_dayStart:=OrbitalPeriodsWork[1].OOS_dayEnd + 1;
      OrbitalPeriodsWork[2].OOS_dayEnd:=OrbitalPeriodsWork[2].OOS_dayStart + RevolutionPeriodPart - 1;
      OrbitalPeriodsWork[3].OOS_dayStart:=OrbitalPeriodsWork[2].OOS_dayEnd + 1;
      OrbitalPeriodsWork[3].OOS_dayEnd:=OrbitalPeriodsWork[3].OOS_dayStart + RevolutionPeriodPart - 1;
      OrbitalPeriodsWork[4].OOS_dayStart:=OrbitalPeriodsWork[3].OOS_dayEnd + 1;
      OrbitalPeriodsWork[4].OOS_dayEnd:=OrbitalPeriodsWork[4].OOS_dayStart + RevolutionPeriodPart - 1;
      GeneratedProbability:=FCFcF_Random_DoInteger( 3 ) + 1;
      case GeneratedProbability of
         1:
         begin
            OrbitalPeriodsWork[1].OOS_orbitalPeriodType:=optClosest;
            OrbitalPeriodsWork[2].OOS_orbitalPeriodType:=optIntermediary;
            OrbitalPeriodsWork[3].OOS_orbitalPeriodType:=optFarthest;
            OrbitalPeriodsWork[4].OOS_orbitalPeriodType:=optIntermediary;
         end;

         2:
         begin
            OrbitalPeriodsWork[1].OOS_orbitalPeriodType:=optIntermediary;
            OrbitalPeriodsWork[2].OOS_orbitalPeriodType:=optClosest;
            OrbitalPeriodsWork[3].OOS_orbitalPeriodType:=optIntermediary;
            OrbitalPeriodsWork[4].OOS_orbitalPeriodType:=optFarthest;
         end;

         3:
         begin
            OrbitalPeriodsWork[1].OOS_orbitalPeriodType:=optFarthest;
            OrbitalPeriodsWork[2].OOS_orbitalPeriodType:=optIntermediary;
            OrbitalPeriodsWork[3].OOS_orbitalPeriodType:=optClosest;
            OrbitalPeriodsWork[4].OOS_orbitalPeriodType:=optIntermediary;
         end;

         4:
         begin
            OrbitalPeriodsWork[1].OOS_orbitalPeriodType:=optIntermediary;
            OrbitalPeriodsWork[2].OOS_orbitalPeriodType:=optFarthest;
            OrbitalPeriodsWork[3].OOS_orbitalPeriodType:=optIntermediary;
            OrbitalPeriodsWork[4].OOS_orbitalPeriodType:=optClosest;
         end;
      end;
      DistMin:=( 1 - Eccentricity ) * DistanceFromStar;
      DistMax:=( 1 + Eccentricity ) * DistanceFromStar;
   end;
   {.main loop}
   Count:=1;
   TemperatureMean:=0;
   while Count <= 4 do
   begin
      if BasicType=oobtAsteroidBelt
      then OrbitalPeriodsWork[Count].OOS_baseTemperature:=0
      else if not isSatToLoadFromRoot then
      begin
         case OrbitalPeriodsWork[Count].OOS_orbitalPeriodType of
            optIntermediary: OrbitalPeriodsWork[Count].OOS_baseTemperature:=FCFfG_BaseTemperature_Calc( DistanceFromStar, FCDduStarSystem[0].SS_stars[Star].S_luminosity );

            optClosest: OrbitalPeriodsWork[Count].OOS_baseTemperature:=FCFfG_BaseTemperature_Calc( DistMin, FCDduStarSystem[0].SS_stars[Star].S_luminosity );

            optFarthest: OrbitalPeriodsWork[Count].OOS_baseTemperature:=FCFfG_BaseTemperature_Calc( DistMax, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
         end;
      end;
      case BasicType of
         oobtAsteroidBelt:
         begin
            OrbitalPeriodsWork[Count].OOS_surfaceTemperature:=0;
            if Count=4 then
            begin
               Albedo:=0;
               CloudsCover:=0;
               if not isHydroEdited then
               begin
                  Hydrosphere:=hNoHydro;
                  HydrosphereArea:=0;
                  isLoadHydrosphere:=true;
               end;
            end;
         end;

         oobtAsteroid:
         begin
            TemperatureMean:=TemperatureMean + OrbitalPeriodsWork[Count].OOS_baseTemperature;
            if Count=1 then
            begin
               ConvectionFactor:=0;
               case FinalType of
                  ootAsteroid_Metallic..ootAsteroid_Silicate, ootSatellite_Asteroid_Metallic..ootSatellite_Asteroid_Silicate: ConvectionFactor:=0.15 * ( 0.9 + ( FCFcF_Random_DoFloat * 0.2 ) );

                  ootAsteroid_Carbonaceous, ootSatellite_Asteroid_Carbonaceous: ConvectionFactor:=0.07 * ( 0.9 + ( FCFcF_Random_DoFloat * 0.2 ) );

                  ootAsteroid_Icy, ootSatellite_Asteroid_Icy: ConvectionFactor:=0.5 * ( 0.9 + ( FCFcF_Random_DoFloat * 0.2 ) );
               end;
               Albedo:=FCFcF_Round( rttCustom2Decimal, ConvectionFactor );
               if Albedo >= 1
               then Albedo:=0.99;
               CloudsCover:=0;
               if not isHydroEdited then
               begin
                  Hydrosphere:=hNoHydro;
                  HydrosphereArea:=0;
                  isLoadHydrosphere:=true;
               end;
            end
            else if Count=4 then
            begin
               TemperatureMean:=TemperatureMean / 4;
               if not isHydroEdited
               then FCMfH_Hydrosphere_Processing(
                  Star
                  ,OrbitalObject
                  ,TemperatureMean
                  ,Satellite
                  );
               if Satellite=0 then
               begin
                  Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
                  HydrosphereArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
               end
               else begin
                  Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
                  HydrosphereArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
               end;
            end;
            CalcFloat:=OrbitalPeriodsWork[Count].OOS_baseTemperature * power(  ( ( 1 - Albedo) / 0.7 ), 0.25  );
            OrbitalPeriodsWork[Count].OOS_surfaceTemperature:=FCFcF_Round( rttCustom2Decimal, CalcFloat );
         end;

         oobtTelluricPlanet, oobtIcyPlanet:
         begin
            if AtmospherePressure = 0 then
            begin
               TemperatureMean:=TemperatureMean + OrbitalPeriodsWork[Count].OOS_baseTemperature;
               if Count=4 then
               begin
                  TemperatureMean:=TemperatureMean / 4;
                  if not isHydroEdited
                  then FCMfH_Hydrosphere_Processing(
                     Star
                     ,OrbitalObject
                     ,TemperatureMean
                     ,Satellite
                     );
                  if Satellite=0 then
                  begin
                     Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
                     HydrosphereArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
                  end
                  else begin
                     Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
                     HydrosphereArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
                  end;
                  HydroAreaFrac:=HydrosphereArea * 0.01;
                  ConvectionFactor:=0;
                  if ( Hydrosphere=hWaterIceSheet )
                     or ( Hydrosphere=hMethaneIceSheet )
                     or ( Hydrosphere=hNitrogenIceSheet )
                  then ConvectionFactor:=0.5 * ( 0.9 + ( HydroAreaFrac * 0.2 ) )
                  else if ( Hydrosphere=hWaterIceCrust )
                     or ( Hydrosphere=hMethaneIceCrust )
                     or ( Hydrosphere=hNitrogenIceCrust )
                  then ConvectionFactor:=0.5 * ( 0.9 + ( FCFcF_Random_DoFloat * 0.2 ) )
                  else ConvectionFactor:=0.07 * ( 0.9 + ( FCFcF_Random_DoFloat * 0.2 ) );
                  Albedo:=FCFcF_Round( rttCustom2Decimal, ConvectionFactor );
                  if Albedo >= 1
                  then Albedo:=0.99;
                  Count1:=1;
                  while Count1 <= 4 do
                  begin
                     CalcFloat:=OrbitalPeriodsWork[Count1].OOS_baseTemperature * power(  ( ( 1 - Albedo) / 0.7 ), 0.25  );
                     OrbitalPeriodsWork[Count1].OOS_surfaceTemperature:=FCFcF_Round( rttCustom2Decimal, CalcFloat );
                     inc( Count1 );
                  end;
                  CloudsCover:=0;
               end;
            end
            else begin
               if Count=1 then
               begin
                  OpticalDepth:=0;
                  case PrimaryGasVolume of
                     0..9: OpticalDepth:=3;

                     10..19: OpticalDepth:=2.34;

                     20..29: OpticalDepth:=1;

                     30..44: OpticalDepth:=0.15;

                     45..99: OpticalDepth:=0.05;

                     100: OpticalDepth:=0;
                  end;
                  if ( AtmospherePressure >= 5065 )
                     and ( AtmospherePressure < 10130 )
                  then OpticalDepth:=OpticalDepth * 1.5
                  else if ( AtmospherePressure >= 10130 )
                     and ( AtmospherePressure < 30390 )
                  then OpticalDepth:=OpticalDepth * 2
                  else if ( AtmospherePressure >= 30390 )
                     and ( AtmospherePressure < 50650 )
                  then OpticalDepth:=OpticalDepth * 3.333
                  else if ( AtmospherePressure >= 50650 )
                     and ( AtmospherePressure < 70910 )
                  then OpticalDepth:=OpticalDepth * 6.666
                  else if AtmospherePressure >= 70910
                  then OpticalDepth:=OpticalDepth * 8.333;
                  ConvectionFactor:=0.43 * power( ( AtmospherePressure / 1000 ) ,0.25 );
                  GreenCO2:=0;
                  if GasCO2=agsTrace
                  then GeneratedProbability:=FCFcF_Random_DoInteger( 50 )
                  else if GasCO2 > agsTrace
                  then GeneratedProbability:=FCFcF_Random_DoInteger( 100 )
                  else GeneratedProbability:=0;
                  GreenCO2:=( sqrt( AtmospherePressure ) * 0.01 * GeneratedProbability ) / sqrt( AtmospherePressure );
                  GreenCH4:=0;
                  if GasCH4=agsTrace
                  then GeneratedProbability:=FCFcF_Random_DoInteger( 50 )
                  else if GasCH4 > agsTrace
                  then GeneratedProbability:=FCFcF_Random_DoInteger( 100 )
                  else GeneratedProbability:=0;
                  GreenCH4:=( sqrt( AtmospherePressure ) * 0.01 * GeneratedProbability ) / sqrt( AtmospherePressure );
                  GreenH2O:=0;
                  if GasH2O = agsMain
                  then GeneratedProbability:=FCFcF_Random_DoInteger( 100 )
                  else GeneratedProbability:=0;
                  GreenH2O:=( sqrt( AtmospherePressure ) * 0.01 * GeneratedProbability ) / sqrt( AtmospherePressure );
                  GreenSO2:=0;
                  if GasSO2=agsTrace
                  then GeneratedProbability:=TectonicActivityIndex
                  else if GasSO2 > agsTrace
                  then GeneratedProbability:=round( ( TectonicActivityIndex + 1 ) * 14.28571428 )
                  else GeneratedProbability:=0;
                  GreenSO2:=( sqrt( AtmospherePressure ) * 0.01 * GeneratedProbability ) / sqrt( AtmospherePressure );
                  GreenTotal:=0.5 + ( ( GreenCO2 + GreenCH4 + GreenH2O + GreenSO2 ) / 10.6666666666664 );
               end;
               {.surface temperature}
               GreenRise:=( ( ( ( power( ( 1 + ( 0.75 * OpticalDepth ) ), 0.25 ) - 1 ) * ConvectionFactor ) + GreenTotal ) * OrbitalPeriodsWork[Count].OOS_baseTemperature ) / 4.98;
               GreenHouse:=GreenHouse + ( GreenRise / OrbitalPeriodsWork[Count].OOS_baseTemperature );
               CalcFloat:=OrbitalPeriodsWork[Count].OOS_baseTemperature + GreenRise;
               OrbitalPeriodsWork[Count].OOS_surfaceTemperature:=FCFcF_Round( rttCustom2Decimal, CalcFloat );
               TemperatureMean:=TemperatureMean + OrbitalPeriodsWork[Count].OOS_surfaceTemperature;
               {.hydrosphere, clouds cover and albedo}
               if Count=4 then
               begin
                  GreenHouse:=FCFcF_Round( rttCustom2Decimal, GreenHouse / 4 );
                  TemperatureMean:=TemperatureMean / 4;
                  if not isHydroEdited
                  then FCMfH_Hydrosphere_Processing(
                     Star
                     ,OrbitalObject
                     ,TemperatureMean
                     ,Satellite
                     );
                  if Satellite=0 then
                  begin
                     Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
                     HydrosphereArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
                  end
                  else begin
                     Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
                     HydrosphereArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
                  end;
                  HydroAreaFrac:=HydrosphereArea * 0.01;
                  CloudFraction:=0;
                  if ( Hydrosphere=hWaterLiquid )
                     or ( Hydrosphere=hWaterAmmoniaLiquid )
                     or ( Hydrosphere=hMethaneLiquid ) then
                  begin
                     HydroCoef:=FCFfS_HydroCoef_Get( Hydrosphere );
                     CloudFraction:=HydroAreaFrac * ( 1 + ( ( TemperatureMean - HydroCoef ) * 0.00767 ) );
                     if CloudFraction < 0
                     then CloudFraction:=0
                     else if CloudFraction > 1
                     then CloudFraction:=1;
                  end
                  else if ( Hydrosphere=hWaterIceSheet )
                     or ( Hydrosphere=hMethaneIceSheet )
                     or ( Hydrosphere=hNitrogenIceSheet ) then
                  begin
                     HydroCoef:=FCFfS_HydroCoef_Get( Hydrosphere );
                     CloudFraction:=( 1 - HydroAreaFrac ) * ( 1 + ( ( TemperatureMean ) * 0.00767 ) );
                  end
                  else if Hydrosphere=hWaterIceCrust then
                  begin
                     HydroCoef:=FCFfS_HydroCoef_Get( Hydrosphere );
                     if GasH2O = agsSecondary
                     then CloudFraction:=( 1 - ( PrimaryGasVolume * 0.01 ) ) * ( 1 + ( ( TemperatureMean ) * 0.00767 ) )
                     else if GasH2O = agsMain
                     then CloudFraction:=( PrimaryGasVolume * 0.01 ) * ( 1 + ( ( TemperatureMean - HydroCoef ) * 0.00767 ) );
                  end
                  else if Hydrosphere=hMethaneIceCrust then
                  begin
                     HydroCoef:=FCFfS_HydroCoef_Get( Hydrosphere );
                     if GasCH4 = agsSecondary
                     then CloudFraction:=( 1 - ( PrimaryGasVolume * 0.01 ) ) * ( 1 + ( ( TemperatureMean ) * 0.00767 ) )
                     else if GasCH4 = agsMain
                     then CloudFraction:=( PrimaryGasVolume * 0.01 ) * ( 1 + ( ( TemperatureMean - HydroCoef ) * 0.00767 ) );
                  end
                  else if Hydrosphere=hNitrogenIceCrust then
                  begin
                     HydroCoef:=FCFfS_HydroCoef_Get( Hydrosphere );
                     if GasN2 = agsSecondary
                     then CloudFraction:=( 1 - ( PrimaryGasVolume * 0.01 ) ) * ( 1 + ( ( TemperatureMean ) * 0.00767 ) )
                     else if GasN2 = agsMain
                     then CloudFraction:=( PrimaryGasVolume * 0.01 ) * ( 1 + ( ( TemperatureMean - HydroCoef ) * 0.00767 ) );
                  end;
                  CloudsCover:=FCFcF_Round( rttCustom1Decimal, CloudFraction * 100 );
                  if CloudsCover > 100
                  then CloudsCover:=100;
                  {.albedo}
                  RockFraction:=1 - HydroAreaFrac;
                  Components:=0;
                  CloudAdjustment:=0;
                  if Hydrosphere > hNoHydro
                  then Components:=2;
                  if RockFraction > 0
                  then inc( Components );
                  if Components > 0
                  then CloudAdjustment:=CloudFraction / Components;
                  if RockFraction > CloudAdjustment
                  then RockFraction:=RockFraction - CloudAdjustment
                  else RockFraction:=0;
                  WorkHydro:=0;
                  if HydroAreaFrac > CloudAdjustment
                  then WorkHydro:=HydroAreaFrac - CloudAdjustment;
                  CloudContribution:=CloudFraction * ( 0.52 * ( FCFcF_Random_DoFloat * 0.4 ) );
                  RockContribution:=RockFraction * ( 0.15 * ( FCFcF_Random_DoFloat * 0.2 ) );
                  if Hydrosphere = hWaterLiquid
                  then WorkHydro:=WorkHydro * ( 0.01 * ( FCFcF_Random_DoFloat * 0.4 ) )
                  else if Hydrosphere = hWaterAmmoniaLiquid
                  then WorkHydro:=WorkHydro * ( 0.35 * ( FCFcF_Random_DoFloat * 0.3 ) )
                  else if Hydrosphere = hMethaneLiquid
                  then WorkHydro:=WorkHydro * ( 0.01 * ( FCFcF_Random_DoFloat * 0.2 ) )
                  else if Hydrosphere > hNoHydro
                  then WorkHydro:=WorkHydro * ( 0.7 * ( FCFcF_Random_DoFloat * 0.2 ) );
                  CalcFloat:=( CloudContribution + RockContribution + ( WorkHydro * 0.5 ) ) * 2.5;
                  Albedo:=FCFcF_Round( rttCustom2Decimal, CalcFloat );
                  if Albedo >= 1
                  then Albedo:=0.99;
               end; //==END== if Count=4 ==//
            end; //==END== else of if AtmospherePressure = 0 ( > 0 ) ==//
            isLoadHydrosphere:=false;
         end; //==END== case of: oobtTelluricPlanet, oobtIcyPlanet ==//

         oobtGaseousPlanet:
         begin
            if Count=1 then
            begin
               ConvectionFactor:=0.5 * ( 0.9 + ( FCFcF_Random_DoFloat * 0.2 ) );
               Albedo:=FCFcF_Round( rttCustom2Decimal, ConvectionFactor );
               if Albedo >= 1
               then Albedo:=0.99;
               CloudsCover:=0;
               if not isHydroEdited then
               begin
                  Hydrosphere:=hNoHydro;
                  HydrosphereArea:=0;
                  isLoadHydrosphere:=true;
               end;
            end;
            CalcFloat:=OrbitalPeriodsWork[Count].OOS_baseTemperature * power( ( ( 1 - Albedo) / 0.7 ), 0.25 );
            OrbitalPeriodsWork[Count].OOS_surfaceTemperature:=FCFcF_Round( rttCustom2Decimal, CalcFloat );
         end;
      end; //==END== case BasicType ==//
      inc( Count );
   end;
   {.data loading}
   if Satellite=0 then
   begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_fug_Greenhouse:=GreenHouse;
      Count:=1;
      while Count <= 4 do
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_orbitalPeriodType:=OrbitalPeriodsWork[Count].OOS_orbitalPeriodType;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_dayStart:=OrbitalPeriodsWork[Count].OOS_dayStart;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_dayEnd:=OrbitalPeriodsWork[Count].OOS_dayEnd;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_baseTemperature:=OrbitalPeriodsWork[Count].OOS_baseTemperature;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[Count].OOS_surfaceTemperature:=OrbitalPeriodsWork[Count].OOS_surfaceTemperature;
         inc( Count );
      end;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_albedo:=Albedo;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover:=CloudsCover;
      if ( not isHydroEdited )
         and ( not FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isHydrosphereEdited )
         and ( isLoadHydrosphere ) then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere:=Hydrosphere;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea:=HydrosphereArea;
      end;
   end
   else begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_fug_Greenhouse:=GreenHouse;
      Count:=1;
      while Count <= 4 do
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_orbitalPeriodType:=OrbitalPeriodsWork[Count].OOS_orbitalPeriodType;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_dayStart:=OrbitalPeriodsWork[Count].OOS_dayStart;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_dayEnd:=OrbitalPeriodsWork[Count].OOS_dayEnd;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_baseTemperature:=OrbitalPeriodsWork[Count].OOS_baseTemperature;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[Count].OOS_surfaceTemperature:=OrbitalPeriodsWork[Count].OOS_surfaceTemperature;
         inc( Count );
      end;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_albedo:=Albedo;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover:=CloudsCover;
      if ( not isHydroEdited )
         and ( not FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_isHydrosphereEdited )
         and ( isLoadHydrosphere ) then
      begin
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere:=Hydrosphere;
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea:=HydrosphereArea;
      end;
   end;
end;

end.
