{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - geophysical unit

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
unit farc_fug_geophysical;

interface

uses
   Math

   ,farc_data_univ;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   calculate the asteroids belt's diameter
///</summary>
/// <param name="Distance">distance of the belt from its star</param>
/// <returns>the diameter in AU</returns>   
/// <remarks>format [x.xx]</remarks>
function FCFfG_AsteroidsBelt_CalculateDiameter( const Distance: extended ): extended;

///<summary>
///   calculate the orbital object's density
///</summary>
/// <param name="ObjectType">basic type of the object</param>
/// <param name="OrbitalZone">orbital zone in which the object is</param>
/// <param name="isSatCaptured">optional parameter, false by default. Apply only in case of a satellite must be processed and indicate if it is captured or not</param>
/// <returns>the density in kg</returns>
/// <remarks>format is rounded</remarks>
function FCFfG_Density_Calculation(
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitalZone: TFCEduHabitableZones;
   const isSatCaptured: boolean=false
   ): integer;

///<summary>
///   density precalculations for satellites
///</summary>
///   <param name="Star">star's index #</param>
///   <param name="Root">root planet/asteroid's index #</param>
///   <param name="Satellite">satellite's index #</param>
///   <param name="SatCaptured">indicate if the satellite is captured or not, so either sdCaptured or sdNone</param>
/// <returns>the density in kg</returns>
/// <remarks>format is rounded</remarks>
function FCFfG_DensitySat_Calculation(
   const Star
         ,Root
         ,Satellite: integer;
   const SatCaptured: TFCEduSatelliteDistances
   ): integer;

///<summary>
///   calculate the orbital object's diameter
///</summary>
/// <param name="ObjectType">basic type of the object</param>
/// <param name="OrbitalZone">orbital zone in which the object is. Doesn't apply if the object is a gaseous planet or an asteroid</param>
/// <returns>the diameter in km</returns>   
/// <remarks>format [x.x]</remarks>
function FCFfG_Diameter_Calculation(
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitalZone: TFCEduHabitableZones
   ): extended;

///<summary>
///   calculate the satellite's diameter
///</summary>
/// <param name="ObjectType">basic type of the satellite</param>
/// <param name="OrbitDistance">range of orbit distance</param>
/// <returns>the diameter in km</returns>
/// <remarks>format [x.x]</remarks>
function FCFfG_Diameter_SatCalculation(
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitDistance: TFCEduSatelliteDistances
   ): extended;

///<summary>
///   calculate the orbital object's escape velocity
///</summary>
/// <param name="Diameter">orbital object's diameter</param>
/// <param name="Mass">orbital object's mass</param>
/// <returns>the escape velocity in km/sec</returns>
/// <remarks>format [x.xx]</remarks>
function FCFfG_EscapeVelocity_Calculation(
   const Diameter
         ,Mass: extended
   ): extended;

///<summary>
///   calculate the orbital object's gravity
///</summary>
/// <param name="Diameter">orbital object's diameter</param>
/// <param name="Mass">orbital object's mass</param>
/// <returns>the gravity in gees</returns>
/// <remarks>format [x.xxx]</remarks>
function FCFfG_Gravity_Calculation(
   const Diameter
         ,Mass: extended
   ): extended;

///<summary>
///   calculate the orbital object's inclination axis
///</summary>
///   <returns>inclination axis in degrees</returns>
///   <remarks>format [x.x], return in negative value is the rotation period is retrograde. must load the function's result with abs() and set the negative rotation period</remarks>
function FCFfG_InclinationAxis_Calculation: extended;

///<summary>
///   calculate the orbital object's mass equivalent
///</summary>
/// <param name="Diameter">orbital object's diameter</param>
/// <param name="Density">orbital object's density</param>
/// <param name="isAsteroid">[=true]: specificity for asteroids</param>
/// <returns>the mass in Earth mass equivalent</returns>
/// <remarks>format [x.xxxx] for planets and [x.xxxxxxxxxx] for asteroids</remarks>
function FCFfG_Mass_Calculation(
   const Diameter
         , Density: extended;
   const isAsteroid: boolean
   ): extended;

///<summary>
///   retrieve the final type of asteroid based on the density
///</summary>
///   <param name="Density">asteroid's density</param>
///   <param name="isSatellite">optional parameter, false by default, [=true] process for satellites</param>
///   <returns>the orbital object type</returns>
///   <remarks></remarks>
function FCFfG_Refinement_Asteroid( const Density: integer; const isSatellite: boolean=false ): TFCEduOrbitalObjectTypes;

///<summary>
///   retrieve the final type of gaseous planet based on the mass
///</summary>
///   <param name="Mass">planet's mass</param>
///   <returns>the orbital object type</returns>
///   <remarks></remarks>
function FCFfG_Refinement_GaseousPlanet( const Mass: extended): TFCEduOrbitalObjectTypes;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   calculate the orbital object's magnetic field
///</summary>
///   <param name="Star">star index #</param>
///   <param name="OrbitalObject">orbital object index #</param>
///   <param name="Satellite">OPTIONAL: satellite index #</param>
///   <remarks>format [x.xxx]</remarks>
procedure FCMfG_MagneticField_Calculation(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   calculate the orbital object's rotation period
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Asteroid">optional parameter, only for an asteroid in a belt</param>
/// <remarks>format [x.xx]</remarks>
procedure FCMfG_RotationPeriod_Calculation(
   const Star
         ,OrbitalObject
         ,Asteroid: integer
   );

///<summary>
///   calculate the orbital object's tectonic activity
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <remarks></remarks>
procedure FCMfG_TectonicActivity_Calculation( const Star, OrbitalObject: integer );

implementation

uses
   farc_common_func
   ,farc_data_init
   ,farc_fug_stars;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFfG_AsteroidsBelt_CalculateDiameter( const Distance: extended ): extended;
{:Purpose: calculate the asteroids belt's diameter.
}
   var
      WorkingFloat: extended;
begin
   Result:=0;
   WorkingFloat:=0;
   if Distance < 1.5
   then WorkingFloat:=FCFcF_Random_DoFloat + 0.5
   else if ( Distance >= 1.5 )
      and ( Distance < 20 )
   then WorkingFloat:=FCFcF_Random_DoInteger( 5 ) + 1
   else if Distance >= 20
   then WorkingFloat:=FCFcF_Random_DoInteger( 10 ) + 1;
   Result:=FCFcF_Round( rttCustom2Decimal, WorkingFloat );
end;

function FCFfG_Density_Calculation(
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitalZone: TFCEduHabitableZones;
   const isSatCaptured: boolean=false
   ): integer;
{:Purpose: calculate the orbital object's density.
   Additions:
      -2013May19- *add: satellites calculations.
      -2013Apr29- *mod: put specific calculation for icy planets.
      -2013Apr28- *add: icy planet basic type.
      -2013Apr20- *mod: adjustments.
}
   var
      WorkingFloat: extended;
begin
   Result:=0;
   WorkingFloat:=0;
   case ObjectType of
      oobtAsteroid:
      begin
         if isSatCaptured
         then WorkingFloat:=0.1 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.012 )
         else begin
            if OrbitalZone in[hzInner..hzIntermediary]
            then WorkingFloat:=0.3 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.01 )//1.3
            else if OrbitalZone = hzOuter
            then WorkingFloat:=0.1 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.005 );//0.6
         end;
         WorkingFloat:=WorkingFloat * FCCdiDensityEqEarth;
      end;

      oobtTelluricPlanet:
      begin
         if isSatCaptured
         then WorkingFloat:=0.3 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.01 )
         else begin
            if OrbitalZone in[hzInner..hzIntermediary]
            then WorkingFloat:=0.54 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.0076 )//1.3
            else if OrbitalZone = hzOuter
            then WorkingFloat:=0.3 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.0035 );
         end;
         WorkingFloat:=WorkingFloat * FCCdiDensityEqEarth;
      end;

      oobtGaseousPlanet: WorkingFloat:=FCFcF_Random_DoInteger( 1351 ) + 579;

      oobtIcyPlanet:
      begin
         WorkingFloat:=0.15 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.0045 );//0.1545 - 0.60;
         WorkingFloat:=WorkingFloat * FCCdiDensityEqEarth;
      end;
   end;
   Result:=round( WorkingFloat );
end;

function FCFfG_DensitySat_Calculation(
   const Star
         ,Root
         ,Satellite: integer;
   const SatCaptured: TFCEduSatelliteDistances
   ): integer;
{:Purpose: density precalculations for satellites.
}
   var
      MaxDensity: integer;

      CoefDensity
      ,DistanceRadii
      ,PlanetaryRadii
      ,WorkingFloat: extended;
begin
   Result:=0;
   MaxDensity:=0;
   CoefDensity:=1;
   if SatCaptured=sdNone then
   begin
      MaxDensity:=round( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[Root].OO_density * ( 1 - ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.001 ) ) );
      if ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[Root].OO_basicType=oobtGaseousPlanet )
         and ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[Root].OO_isNotSat_orbitalZone=hzOuter )
         and ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[Root].OO_mass >= 200 ) then
      begin
         DistanceRadii:=( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[Root].OO_satellitesList[Satellite].OO_isSat_distanceFromPlanet * 1000 / ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[Root].OO_diameter * 0.5 ) );
         PlanetaryRadii:=7 + ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[Root].OO_mass / 300 );
         if DistanceRadii <= PlanetaryRadii
         then CoefDensity:=2
         else if DistanceRadii <= ( PlanetaryRadii * 1.5 )
         then CoefDensity:=1.5;
      end;
      WorkingFloat:=FCFfG_Density_Calculation(
         FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[Root].OO_satellitesList[Satellite].OO_basicType
         ,FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[Root].OO_isNotSat_orbitalZone
         );
   end
   else if SatCaptured=sdCaptured
   then WorkingFloat:=FCFfG_Density_Calculation(
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[Root].OO_satellitesList[Satellite].OO_basicType
      ,FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[Root].OO_isNotSat_orbitalZone
      ,true
      );
   if ( MaxDensity > 0 )
      and ( WorkingFloat > MaxDensity )
   then WorkingFloat:=MaxDensity;
   Result:=round( WorkingFloat );
end;

function FCFfG_Diameter_Calculation(
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitalZone: TFCEduHabitableZones
   ): extended;
{:Purpose: calculate the orbital object's diameter.
   Additions:
      -2013Apr28- *add: icy planet basic type.
      -2013Apr20- *mod: adjustments.
}
   var
      WorkingFloat: extended;
begin
   Result:=0;
   WorkingFloat:=0;
   case ObjectType of
      oobtAsteroid: WorkingFloat:=FCFcF_Random_DoInteger( 1987 ) + 12.5;
      
      oobtTelluricPlanet, oobtIcyPlanet:
      begin
         case OrbitalZone of
            hzInner: WorkingFloat:=FCFcF_Random_DoInteger( 18409 ) + 2000;
            
            hzIntermediary: WorkingFloat:=FCFcF_Random_DoInteger( 29676 ) + 2324;
            
            hzOuter: WorkingFloat:=FCFcF_Random_DoInteger( 8520 ) + 2000;
         end;
      end;
      
      oobtGaseousPlanet: WorkingFloat:=FCFcF_Random_DoInteger( 130000 ) + 30000;
   end;
   Result:=FCFcF_Round( rttCustom1Decimal, WorkingFloat );
end;

function FCFfG_Diameter_SatCalculation(
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitDistance: TFCEduSatelliteDistances
   ): extended;
{:Purpose: calculate the satellite's diameter.
    Additions:
}
   var
      GeneratedProbability: integer;

      Calculation: extended;
begin
   Result:=0;
   GeneratedProbability:=FCFcF_Random_DoInteger( 9 ) + 1;
   if ObjectType=oobtAsteroid then
   begin
      case OrbitDistance of
         sdClose: GeneratedProbability:=GeneratedProbability - 1;

         sdDistant: GeneratedProbability:=GeneratedProbability + 1;

         sdVeryDistant: GeneratedProbability:=GeneratedProbability + 2;

         sdCaptured: GeneratedProbability:=GeneratedProbability - 1;
      end;
      case GeneratedProbability of
         0..7: Calculation:=FCFcF_Random_DoInteger( 99 ) + 1;

         8..9: Calculation:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 10;

         10..12: Calculation:=1000 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 10 );
      end;
   end
   else if ( ObjectType=oobtTelluricPlanet )
      or ( ObjectType=oobtIcyPlanet ) then
   begin
      case OrbitDistance of
         sdClose: GeneratedProbability:=GeneratedProbability - 1;

         sdDistant: GeneratedProbability:=GeneratedProbability + 1;

         sdVeryDistant: GeneratedProbability:=GeneratedProbability + 2;

         sdCaptured: GeneratedProbability:=GeneratedProbability - 2;
      end;
      case GeneratedProbability of
         -1..8: Calculation:=2000 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 20 );

         9..12: Calculation:=4000 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 40 );
      end;
   end;
   Result:=FCFcF_Round( rttCustom1Decimal, Calculation );
end;


function FCFfG_EscapeVelocity_Calculation(
   const Diameter
         ,Mass: extended
   ): extended;
{:Purpose: calculate the orbital object's escape velocity.
}
   var
      CalculatedEscapeVelocity
      ,MassInKg
      ,RadiusInMeters: extended;
begin
   Result:=0;
   MassInKg:=Mass * FCCdiMassEqEarth;
   RadiusInMeters:=Diameter * 500;
   CalculatedEscapeVelocity:=sqrt( 2 * FCCdiGravitationalConst * MassInKg / sqr( RadiusInMeters ) ) / FCCdiMetersBySec_In_1G;
   Result:=FCFcF_Round( rttCustom2Decimal, CalculatedEscapeVelocity );
end;

function FCFfG_Gravity_Calculation(
   const Diameter
         ,Mass: extended
   ): extended;
{:Purpose: calculate the orbital object's gravity.
    Additions:
}
   var
      CalculatedGravity
      ,MassInKg
      ,RadiusInMeters: extended;
begin
   Result:=0;
   MassInKg:=Mass * FCCdiMassEqEarth;
   RadiusInMeters:=Diameter * 500;
   CalculatedGravity:=( FCCdiGravitationalConst * MassInKg / sqr( RadiusInMeters ) ) / FCCdiMetersBySec_In_1G;
   Result:=FCFcF_Round( rttCustom3Decimal, CalculatedGravity );
end;

function FCFfG_InclinationAxis_Calculation: extended;
{:Purpose: calculate the orbital object's inclination axis.
   Additions:
}
   var
      Probability: integer;

      Calculations: extended;
begin
   Probability:=FCFcF_Random_DoInteger( 9 ) + 1;
   Calculations:=0;
   case Probability of
      1..2: Calculations:=FCFcF_Random_DoInteger( 100 ) * 0.1;

      3..4: Calculations:=10 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.1 );

      5..6: Calculations:=20 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.35 );

      7..8: Calculations:=30 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.7 );

      9..10: Calculations:=40 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 1.4 );
   end;
   if Calculations > 90
   then Calculations:=- ( Calculations );
   Result:=FCFcF_Round( rttCustom1Decimal, Calculations );
end;

function FCFfG_Mass_Calculation(
   const Diameter
         , Density: extended;
   const isAsteroid: boolean
   ): extended;
{:Purpose: calculate the orbital object's mass equivalent.
    Additions:
      -2013Apr23- *fix: forgot to put the density in the calculations...
}
   var
      CalculatedMass
      ,RadiusInMeters: extended;
begin
   Result:=0;
   RadiusInMeters:=Diameter * 500;
   CalculatedMass:=( ( 4 / 3 * Pi * power( RadiusInMeters, 3 ) ) * Density ) / FCCdiMassEqEarth;
   if not isAsteroid
   then Result:=FCFcF_Round( rttCustom4Decimal, CalculatedMass )
   else Result:=FCFcF_Round( rttMassAsteroid, CalculatedMass );
end;

function FCFfG_Refinement_Asteroid( const Density: integer; const isSatellite: boolean=false ): TFCEduOrbitalObjectTypes;
{:Purpose: retrieve the final type of asteroid based on the density.
    Additions:
      -2013May17- *add: isSatellite parameter.
}
begin
   Result:=ootNone;
   case Density of
      0..2481:
      begin
         if not isSatellite
         then Result:=ootAsteroid_Icy
         else Result:=ootSatellite_Asteroid_Icy;
      end;

      2482..3639:
      begin
         if not isSatellite
         then Result:=ootAsteroid_Carbonaceous
         else Result:=ootSatellite_Asteroid_Carbonaceous;
      end;

      3640..4963:
      begin
         if not isSatellite
         then Result:=ootAsteroid_Silicate
         else Result:=ootSatellite_Asteroid_Silicate;
      end;

      4964..8273:
      begin
         if not isSatellite
         then Result:=ootAsteroid_Metallic
         else Result:=ootSatellite_Asteroid_Metallic;
      end;
   end;
end;

function FCFfG_Refinement_GaseousPlanet( const Mass: extended): TFCEduOrbitalObjectTypes;
{:Purpose: retrieve the final type of gaseous planet based on the mass.
    Additions:
}
   var
      Probability: integer;
begin
   Result:=ootNone;
   if Mass < 40 then
   begin
      Probability:=FCFcF_Random_DoInteger( 1 );
      if Probability=0
      then Result:=ootPlanet_Gaseous_Uranus
      else if Probability=1
      then Result:=ootPlanet_Gaseous_Neptune;
   end
   else if ( Mass >= 40 )
      and ( Mass < 180 )
   then Result:=ootPlanet_Gaseous_Saturn
   else if ( Mass >= 180 )
      and ( Mass < 350 )
   then Result:=ootPlanet_Jovian
   else if Mass >= 350
   then Result:=ootPlanet_Supergiant;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMfG_MagneticField_Calculation(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: calculate the orbital object's magnetic field.
    Additions:
      -2013May20- *add: satellites process.
                  *mod: adjustments for the final step of magfield calculation.
}
   var
      Probability: integer;

      DensityEq
      ,MagFactor
      ,MagField
      ,RevolutionPeriodHrs
      ,RotationPeriod
      ,StarAge: extended;

      BasicType: TFCEduOrbitalObjectBasicTypes;
begin
   if Satellite=0 then
   begin
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_basicType;
      RevolutionPeriodHrs:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod * 24;
      DensityEq:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_density / FCCdiDensityEqEarth;
   end
   else begin
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_basicType;
      RevolutionPeriodHrs:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_revolutionPeriod * 24;
      DensityEq:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_density / FCCdiDensityEqEarth;
   end;
   if ( BasicType=oobtTelluricPlanet )
      or ( BasicType=oobtIcyPlanet ) then
   begin
      if Satellite=0 then
      begin
         if ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod=0 )
            or ( abs( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod ) > RevolutionPeriodHrs )
         then RotationPeriod:=RevolutionPeriodHrs
         else RotationPeriod:=abs( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod );
      end
      else RotationPeriod:=RevolutionPeriodHrs;
      StarAge:=FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
      MagFactor:=( 10 * ( 1 / sqrt( RotationPeriod / 24 ) ) * sqr( DensityEq ) * SQRT( FCDduStarSystem[0].SS_stars[Star].S_mass ) ) / StarAge;
      if ( BasicType=oobtIcyPlanet )
         and ( DensityEq <= 0.45 )
      then MagFactor:=MagFactor * 0.5;
      Probability:=FCFcF_Random_DoInteger( 9 ) + 1;
      if MagFactor < 0.05
      then MagField:=0
      else if ( Magfactor >= 0.05 )
         and ( Magfactor < 0.5 ) then
      begin
         case Probability of
            1..4: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.00003076;

            5..8: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.00006152;

            9..10: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.0003076;
         end;
      end
      else if ( Magfactor >= 0.5 )
         and ( Magfactor < 1 ) then
      begin
         case Probability of
            1..3: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.00003076;

            4..6: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.00006152;

            7..9: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.0003076;

            10: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.001538;
         end;
      end
      else if ( Magfactor >= 1 )
         and ( Magfactor < 2 ) then
      begin
         case Probability of
            1..3: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.00003076;

            4..5: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.00006152;

            6..7: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.0003076;

            8..9: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.001538;

            10: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.003076;
         end;
      end
      else if ( Magfactor >= 2 )
         and ( Magfactor < 4 ) then
      begin
         case Probability of
            1..3: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.001538;

            4..5: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.003076;

            6..7: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.006152;

            8..9: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.009228;

            10: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.01538;
         end;
      end
      else if Magfactor >= 4 then
      begin
         case Probability of
            1..3: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.003076;

            4..5: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.006152;

            6..7: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.009228;

            8..9: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.01538;

            10: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.03076;
         end;
      end;
   end
   else if ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type=ootPlanet_Gaseous_Uranus )
      or ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type=ootPlanet_Gaseous_Neptune ) then
   begin
      Probability:=FCFcF_Random_DoInteger( 9 ) + 1;
      case Probability of
         1: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.003076;

         2..4: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.00769;

         5..7: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.01538;

         8..9: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.02307;

         10: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.03076;
      end;
   end
   else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type=ootPlanet_Gaseous_Saturn then
   begin
      Probability:=FCFcF_Random_DoInteger( 9 ) + 1;
      case Probability of
         1: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.00769;

         2..4: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.01538;

         5..7: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.02307;

         8..9: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.03076;

         10: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.04614;
      end;
   end
   else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type=ootPlanet_Jovian then
   begin
      Probability:=FCFcF_Random_DoInteger( 9 ) + 1;
      case Probability of
         1: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.01538;

         2..4: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.03076;

         5..7: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.04614;

         8..9: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.06152;

         10: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.09228;
      end;
   end
   else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type=ootPlanet_Supergiant then
   begin
      Probability:=FCFcF_Random_DoInteger( 9 ) + 1;
      case Probability of
         1: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.04614;

         2..4: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.0769;

         5..7: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.1538;

         8..9: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.3076;

         10: MagField:=( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.769;
      end;
   end;
   if Satellite=0
   then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_magneticField:=FCFcF_Round( rttCustom3Decimal, MagField )
   else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_magneticField:=FCFcF_Round( rttCustom3Decimal, MagField );
end;

procedure FCMfG_RotationPeriod_Calculation(
   const Star
         ,OrbitalObject
         ,Asteroid: integer
   );
{:Purpose: calculate the orbital object's rotation period.
   Additions:
      -2013May15- *add: Asteroid parameter, for asteroids in a belt.
}
   var
      Probability: integer;

      CalculatedRotationPeriod
      ,CoefPeriod
      ,KStar
      ,MassInG
      ,ObjectDiameter
      ,ObjectDistance
      ,ObjectGravity
      ,ObjectMass
      ,RadiusInCm
      ,ShortestPeriod
      ,StarAge
      ,TidalFinal
      ,TidalForce
      ,VelFinal
      ,Velocity: extended;
begin
   if Asteroid=0 then
   begin
      ObjectDiameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_diameter;
      ObjectDistance:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar;
      ObjectGravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity;
      ObjectMass:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_mass;
   end
   else begin
      ObjectDiameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_diameter;
      ObjectDistance:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_isSat_distanceFromPlanet;
      ObjectGravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_gravity;
      ObjectMass:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_mass;
   end;
   ShortestPeriod:=sqrt( ( 2 * Pi ) / ( 0.19 * ObjectGravity * 9.807 ) );
   TidalForce:=( FCDduStarSystem[0].SS_stars[Star].S_mass * 26640000 ) /   power( ObjectDistance * 400, 3 );
   StarAge:=FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
   Probability:=FCFcF_Random_DoInteger( 9 ) + 1;
   TidalFinal:=( ( 0.83 + ( Probability * 0.03 ) ) * TidalForce * StarAge ) /  6.6;
   {.case if tidally locked}
   if TidalFinal > 1 then
   begin
      if TidalForce>=1 then
      begin
         if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity < 0.21
         then CalculatedRotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod * 24
         else if ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity >= 0.21 )
            and ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity < 0.39 )
         then CalculatedRotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod * 16 //( revol * 2 / 3 ) * 24
         else if ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity >= 0.39 )
            and ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity < 0.57 )
         then CalculatedRotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod * 12 //( revol * 0.5 ) * 24
         else if ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity >= 0.57 )
            and ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity < 0.72 )
         then CalculatedRotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod * 9.6 //( revol * 0.4 ) * 24
         else if ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity >= 0.72 )
            and ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity < 0.87 )
         then CalculatedRotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod * 8 //( revol * 1 / 3 ) * 24
         else if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_eccentricity >= 0.87
         then CalculatedRotationPeriod:=( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod * 2 / 7 ) * 24; //no simplification for this one
         if CalculatedRotationPeriod < ShortestPeriod
         then CalculatedRotationPeriod:=ShortestPeriod * ( 1 + ( 4 * FCFcF_Random_DoInteger( 10 ) ) );
      end
      else CalculatedRotationPeriod:=0;
   end
   else begin
      RadiusInCm:=ObjectDiameter * 100000;
      MassInG:=ObjectMass * FCCdiMassEqEarth * 1000;
      KStar:=( ( 0.19 * FCDduStarSystem[0].SS_stars[Star].S_mass ) / ObjectDistance ) * ObjectGravity;
      Velocity:=sqrt( ( 2 * 1.46e-19 * MassInG ) / ( KStar * sqr( RadiusInCm ) ) );
      VelFinal:=1 / ( ( Velocity / ( 2 * Pi ) ) * 3600 );
      Probability:=FCFcF_Random_DoInteger( 99 ) + 1;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_basicType<oobtGaseousPlanet then
      begin
         case Probability of
            1..35: CoefPeriod:=1;

            36..55: CoefPeriod:=1 + ( FCFcF_Random_DoInteger( 3 ) / 10 );

            56..85: CoefPeriod:=30 + FCFcF_Random_DoInteger( 10 );

            86..100: CoefPeriod:=110 + FCFcF_Random_DoInteger( 110 );
         end;
      end
      else begin
         case Probability of
            1..40: CoefPeriod:=1;

            41..60: CoefPeriod:=1 + ( FCFcF_Random_DoInteger( 6 ) / 10 );

            61..100: CoefPeriod:=3 + ( FCFcF_Random_DoInteger( 10 ) / 10 );
         end;
      end;
      CalculatedRotationPeriod:=VelFinal * CoefPeriod;
      if CalculatedRotationPeriod < ShortestPeriod
      then CalculatedRotationPeriod:=ShortestPeriod * ( 1 + ( 4 * FCFcF_Random_DoInteger( 10 ) ) );
   end; //==END== else of: if TidalFinal > 1 ==//
   if Asteroid=0
   then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod:=FCFcF_Round( rttCustom2Decimal, CalculatedRotationPeriod )
   else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_isAsterBelt_rotationPeriod:=FCFcF_Round( rttCustom2Decimal, CalculatedRotationPeriod );
end;

procedure FCMfG_TectonicActivity_Calculation( const Star, OrbitalObject: integer );
{:Purpose: calculate the orbital object's tectonic activity.
    Additions:
}
begin
   {
   else if (TabOrbit[OrbDBCounter].TypeAstre in [10..30])
            or (TabOrbit[OrbDBCounter].TypeAstre in [43..99]) then begin

       Proba:=random(3);
       TabOrbit[OrbDBCounter].TFactor:=((15)*sqrt(TabOrbit[OrbDBCounter].Mass))/StarClone_Age;
       if (TabOrbit[OrbDBCounter].TypeAstre>26) and (TabOrbit[OrbDBCounter].TypeAstre<31) then TabOrbit[OrbDBCounter].TFactor:=TabOrbit[OrbDBCounter].TFactor*TabOrbit[OrbDBCounter].DensEq;
       if (TabOrbit[OrbDBCounter].TypeAstre>47) and (TabOrbit[OrbDBCounter].TypeAstre<=50) then TabOrbit[OrbDBCounter].TFactor:=TabOrbit[OrbDBCounter].TFactor*TabOrbit[OrbDBCounter].DensEq;
       if (TabOrbit[OrbDBCounter].PerRot<18) and (TabOrbit[OrbDBCounter].PerRot>0) then TabOrbit[OrbDBCounter].TFactor:=TabOrbit[OrbDBCounter].TFactor*1.25;
       if (TabOrbit[OrbDBCounter].PerRot>100) and (TabOrbit[OrbDBCounter].PerRot<=8760) then TabOrbit[OrbDBCounter].TFactor:=TabOrbit[OrbDBCounter].TFactor*0.75;
       if (TabOrbit[OrbDBCounter].PerRot=0) or (TabOrbit[OrbDBCounter].PerRot>8760) then TabOrbit[OrbDBCounter].TFactor:=TabOrbit[OrbDBCounter].TFactor*0.5;
       Proba:=random(9)+1;
       if TabOrbit[OrbDBCounter].TFactor<0.5 then TabOrbit[OrbDBCounter].AcTec:=0
       else if (TabOrbit[OrbDBCounter].TFactor>=0.5) and (TabOrbit[OrbDBCounter].TFactor<1) then begin
               case Proba of
                       1..7: TabOrbit[OrbDBCounter].AcTec:=0;
                       8..9: TabOrbit[OrbDBCounter].AcTec:=1;
                       10: TabOrbit[OrbDBCounter].AcTec:=2;
               end;
       end
       else if (TabOrbit[OrbDBCounter].TFactor>=1) and (TabOrbit[OrbDBCounter].TFactor<2) then begin
               case Proba of
                       1: TabOrbit[OrbDBCounter].AcTec:=0;
                       2..5: TabOrbit[OrbDBCounter].AcTec:=1;
                       6..9: TabOrbit[OrbDBCounter].AcTec:=2;
                       10: TabOrbit[OrbDBCounter].AcTec:=3;
               end;
       end
       else if (TabOrbit[OrbDBCounter].TFactor>=2) and (TabOrbit[OrbDBCounter].TFactor<3) then begin
               case Proba of
                       1..2: TabOrbit[OrbDBCounter].AcTec:=1;
                       3..6: TabOrbit[OrbDBCounter].AcTec:=2;
                       7..10: TabOrbit[OrbDBCounter].AcTec:=3;
               end;
       end
       else if (TabOrbit[OrbDBCounter].TFactor>=3) and (TabOrbit[OrbDBCounter].TFactor<5) then begin
               case Proba of
                       1: TabOrbit[OrbDBCounter].AcTec:=1;
                       2..3: TabOrbit[OrbDBCounter].AcTec:=2;
                       4..8: TabOrbit[OrbDBCounter].AcTec:=3;
                       9..10: TabOrbit[OrbDBCounter].AcTec:=4;
               end;
       end
       else if TabOrbit[OrbDBCounter].TFactor>=5 then begin
               case Proba of
                       1: TabOrbit[OrbDBCounter].AcTec:=2;
                       2: TabOrbit[OrbDBCounter].AcTec:=3;
                       3..7: TabOrbit[OrbDBCounter].AcTec:=4;
                       8..10: TabOrbit[OrbDBCounter].AcTec:=5;
               end;
       end;
        end;
   }
end;

procedure FCMfG_TectonicActivityDifferential_Calculation( const Star, OrbitalObject: integer );
{:Purpose: calculate the differential for each planet vs its satellites, if it has any, and the reverse.
    Additions:
}
begin
   {:DEV NOTES:
      calc tidal force planet vs EACH sat (do a loop) and do a mean of these values

      calc differential tidal stress= 1 + ( 0.25 * ( ( moon mass kg * 26.64 ) / power( moon distance km (thkm*1000) * 324  ,3 ) ) )

      new tectonic activity factor= taf * dts

      formula present in FARC.calculations

   .}

end;

end.
