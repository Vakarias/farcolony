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
   ,farc_fug_geophysical;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfS_OrbitalPeriods_Generate(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: generate the orbital periods and their base effects
   Additions:
}
   var
      Count
      ,GeneratedProbability
      ,RevolutionPeriodPart: integer;

      Albedo
      ,AtmospherePressure
      ,CalcFloat
      ,CloudsCover
      ,ConvectionFactor
      ,DistanceFromStar
      ,DistMax
      ,DistMin
      ,Eccentricity
      ,HydrosphereArea: extended;

      OrbitalPeriodsWork: array[0..4] of TFCRduOObSeason;

      BasicType: TFCEduOrbitalObjectBasicTypes;

      FinalType: TFCEduOrbitalObjectTypes;

      Hydrosphere: TFCEduHydrospheres;
begin
   Count:=0;
   GeneratedProbability:=0;
   RevolutionPeriodPart:=0;
   Albedo:=0;
   AtmospherePressure:=0;
   CalcFloat:=0;
   CloudsCover:=0;
   ConvectionFactor:=0;
   DistanceFromStar:=0;
   DistMax:=0;
   DistMin:=0;
   HydrosphereArea:=0;
   OrbitalPeriodsWork[1]:=OrbitalPeriodsWork[0];
   OrbitalPeriodsWork[2]:=OrbitalPeriodsWork[0];
   OrbitalPeriodsWork[3]:=OrbitalPeriodsWork[0];
   OrbitalPeriodsWork[4]:=OrbitalPeriodsWork[0];
   BasicType:=oobtNone;
   Hydrosphere:=hNoHydro;
   Eccentricity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity;
   if Satellite=0 then
   begin
      RevolutionPeriodPart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod div 4;
      DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_basicType;
      FinalType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type;
      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure;
   end
   else begin
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type=ootAsteroidsBelt then
      begin
         RevolutionPeriodPart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_revolutionPeriod div 4;
         DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_isSat_distanceFromPlanet;
      end
      else begin
         RevolutionPeriodPart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod div 4;
         DistanceFromStar:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      end;
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_basicType;
      FinalType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_type;
      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure;
   end;
   {.init part}
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
         OrbitalPeriodsWork[3].OOS_orbitalPeriodType:=optFarest;
      end;

      2:
      begin
         OrbitalPeriodsWork[2].OOS_orbitalPeriodType:=optClosest;
         OrbitalPeriodsWork[4].OOS_orbitalPeriodType:=optFarest;
      end;

      3:
      begin
         OrbitalPeriodsWork[3].OOS_orbitalPeriodType:=optClosest;
         OrbitalPeriodsWork[1].OOS_orbitalPeriodType:=optFarest;
      end;

      4:
      begin
         OrbitalPeriodsWork[4].OOS_orbitalPeriodType:=optClosest;
         OrbitalPeriodsWork[2].OOS_orbitalPeriodType:=optFarest;
      end;
   end;
   DistMin:=( 1 - Eccentricity ) * DistanceFromStar;
   DistMax:=( 1 + Eccentricity ) * DistanceFromStar;
   {.main loop}
   Count:=1;
   while Count <= 4 do
   begin
      case OrbitalPeriodsWork[Count].OOS_orbitalPeriodType of
         optIntermediary: OrbitalPeriodsWork[Count].OOS_baseTemperature:=FCFfG_BaseTemperature_Calc( DistanceFromStar, FCDduStarSystem[0].SS_stars[Star].S_luminosity );

         optClosest: OrbitalPeriodsWork[Count].OOS_baseTemperature:=FCFfG_BaseTemperature_Calc( DistMin, FCDduStarSystem[0].SS_stars[Star].S_luminosity );

         optFarest: OrbitalPeriodsWork[Count].OOS_baseTemperature:=FCFfG_BaseTemperature_Calc( DistMax, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
      end;
      case BasicType of
         oobtAsteroidBelt:
         begin
            OrbitalPeriodsWork[Count].OOS_surfaceTemperature:=0;
            Albedo:=0;
            CloudsCover:=0;
            Hydrosphere:=hNoHydro;
            HydrosphereArea:=0;
         end;

         oobtAsteroid:
         begin
            Hydrosphere:=hNoHydro;
            HydrosphereArea:=0;
            ConvectionFactor:=0;
            case FinalType of
               ootAsteroid_Metallic..ootAsteroid_Silicate, ootSatellite_Asteroid_Metallic..ootSatellite_Asteroid_Silicate: ConvectionFactor:=0.15 * ( 0.9 + ( FCFcF_Random_DoFloat * 0.2 ) );

               ootAsteroid_Carbonaceous, ootSatellite_Asteroid_Carbonaceous: ConvectionFactor:=0.07 * ( 0.9 + ( FCFcF_Random_DoFloat * 0.2 ) );

               ootAsteroid_Icy, ootSatellite_Asteroid_Icy: ConvectionFactor:=0.5 * ( 0.9 + ( FCFcF_Random_DoFloat * 0.2 ) );
            end;
            Albedo:=FCFcF_Round( rttCustom2Decimal, ConvectionFactor );
            if Albedo >= 1
            then Albedo:=0.99;
            CalcFloat:=OrbitalPeriodsWork[Count].OOS_baseTemperature * power(  ( ( 1 - Albedo) / 0.7 ), 0.25  );
            OrbitalPeriodsWork[Count].OOS_surfaceTemperature:=FCFcF_Round( rttCustom2Decimal, CalcFloat );
            CloudsCover:=0;
         end;

         oobtTelluricPlanet, oobtIcyPlanet:
         begin
            if AtmospherePressure = 0 then
            begin
               CalcFloat:=OrbitalPeriodsWork[Count].OOS_baseTemperature * power(  ( ( 1 - Albedo) / 0.7 ), 0.25  );
               OrbitalPeriodsWork[Count].OOS_surfaceTemperature:=FCFcF_Round( rttCustom2Decimal, CalcFloat );

            end
            else begin
            end;
         end; //==END== case of: oobtTelluricPlanet, oobtIcyPlanet ==//

         oobtGaseousPlanet:;
      end; //==END== case BasicType ==//
      inc( Count );
   end;
   {.data loading orb periods + albedo + clouds cover + hydrosphere}
   if Satellite=0 then
   begin
//      if not FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isHydrosphereEdited then
//      begin
//      end;
   end
   else begin
   end;
end;

end.
