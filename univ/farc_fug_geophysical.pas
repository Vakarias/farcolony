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
/// <returns>the density in kg</returns>   
/// <remarks>format is rounded</remarks>
function FCFfG_Density_Calculation(
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitalZone: TFCEduHabitableZones
   ): integer;

///<summary>
///   calculate the orbital object's diameter
///</summary>
/// <param name="ObjectType">basic type of the object</param>
/// <param name="OrbitalZone">orbital zone in which the object is</param>
/// <returns>the diameter in km</returns>   
/// <remarks>format [x.x]</remarks>
function FCFfG_Diameter_Calculation(
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitalZone: TFCEduHabitableZones
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
///   calculate the orbital object's magnetic field
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
function FCFfG_MagneticField_Calculation: extended;

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

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   calculate the orbital object's rotation period
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <remarks>format [x.xx]</remarks>
procedure FCMfG_RotationPeriod_Calculation( const Star, OrbitalObject: integer );

implementation

uses
   farc_common_func
   ,farc_data_init;
//
//   ,farc_data_init
//   ,farc_data_planetarysurvey
//   ,farc_game_colony
//   ,farc_game_prodrsrcspots
//   ,farc_survey_functions
//   ,farc_ui_coredatadisplay
//   ,farc_univ_func
//   ,farc_win_debug;

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
   const OrbitalZone: TFCEduHabitableZones
   ): integer;
{:Purpose: calculate the orbital object's density.
   Additions:
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
         if OrbitalZone in[hzInner..hzIntermediary]
         then WorkingFloat:=0.3 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.01 )//1.3
         else if OrbitalZone = hzOuter
         then WorkingFloat:=0.1 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.005 );//0.6
         WorkingFloat:=WorkingFloat * FCCdiDensityEqEarth;
      end;

      oobtTelluricPlanet:
      begin
         if OrbitalZone in[hzInner..hzIntermediary]
         then WorkingFloat:=0.54 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.0076 )//1.3
         else if OrbitalZone = hzOuter
         then WorkingFloat:=0.3 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.0035 );
         WorkingFloat:=WorkingFloat * FCCdiDensityEqEarth;
      end;

      oobtGaseousPlanet: WorkingFloat:=FCFcF_Random_DoInteger( 1351 ) + 579;
   end;
   Result:=round( WorkingFloat );
end;

function FCFfG_Diameter_Calculation(
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitalZone: TFCEduHabitableZones
   ): extended;
{:Purpose: calculate the orbital object's diameter.
   Additions:
      -2013Apr20- *mod: adjustments.
}
   var
      WorkingFloat: extended;
begin
   Result:=0;
   WorkingFloat:=0;
   case ObjectType of
      oobtAsteroid: WorkingFloat:=FCFcF_Random_DoInteger( 1987 ) + 12.5;
      
      oobtTelluricPlanet:
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

function FCFfG_MagneticField_Calculation: extended;
{:Purpose: calculate the orbital object's magnetic field.
    Additions:
}
begin
   Result:=0;
   {.magnetic field
        if TabOrbit[OrbDBCounter].TypeAstre<10 then TabOrbit[OrbDBCounter].MagField:=0
        else if TabOrbit[OrbDBCounter].TypeAstre in [10..30] then begin
            if (abs(TabOrbit[OrbDBCounter].PerRot)=0)
                or (abs(TabOrbit[OrbDBCounter].PerRot)>(TabOrbit[OrbDBCounter].Revol*24))
                then rotation_period:=TabOrbit[OrbDBCounter].Revol*24
            else if abs(TabOrbit[OrbDBCounter].PerRot)>0 then rotation_period:=abs(TabOrbit[OrbDBCounter].PerRot);
            if TabOrbit[OrbDBCounter].TypeAstre>=27 then mag_factor:=(10*(1/(sqrt(rotation_period/24)
                *sqr(TabOrbit[OrbDBCounter].DensEq)*sqrt(TabOrbit[OrbDBCounter].Mass)))/StarClone_Age)*0.5
            else if TabOrbit[OrbDBCounter].TypeAstre<27 then mag_factor:=10*(1/(sqrt(rotation_period/24)
                *sqr(TabOrbit[OrbDBCounter].DensEq)*sqrt(TabOrbit[OrbDBCounter].Mass)))/StarClone_Age;
            OCCA_Proba:=random(9)+1;
            if mag_factor<0.05 then TabOrbit[OrbDBCounter].MagField:=0
            else if (mag_factor>=0.05)
                and (mag_factor<0.5) then begin

                case OCCA_Proba of
                    1..4: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.001)*0.3076;
                    5..8: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.002)*0.3076;
                    9..10: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.01)*0.3076;
                end;
            end
            else if (mag_factor>=0.5)
                and (mag_factor<1) then begin

                case OCCA_Proba of
                    1..3: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.001)*0.3076;
                    4..6: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.002)*0.3076;
                    7..9: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.01)*0.3076;
                    10: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.05)*0.3076;
                end;
            end
            else if (mag_factor>=1)
                and (mag_factor<2) then begin

                case OCCA_Proba of
                    1..3: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.001)*0.3076;
                    4..5: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.002)*0.3076;
                    6..7: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.01)*0.3076;
                    8..9: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.05)*0.3076;
                    10: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.1)*0.3076;
                end;
            end
            else if (mag_factor>=2)
                and (mag_factor<4) then begin

                case OCCA_Proba of
                    1..3: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.05)*0.3076;
                    4..5: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.1)*0.3076;
                    6..7: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.2)*0.3076;
                    8..9: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.3)*0.3076;
                    10: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.5)*0.3076;
                end;
            end
            else if mag_factor>=4 then begin
                case OCCA_Proba of
                    1..3: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.1)*0.3076;
                    4..5: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.2)*0.3076;
                    6..7: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.3)*0.3076;
                    8..9: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.5)*0.3076;
                    10: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*1.0)*0.3076;
                end;
            end;
        end{else if TabOrbit[OrbDBCounter].TypeAstre in [10..30]
        else if TabOrbit[OrbDBCounter].TypeAstre in [31..32] then begin
            OCCA_Proba:=random(9)+1;
            case OCCA_Proba of
                1: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.1)*0.3076;
                2..4: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.25)*0.3076;
                5..7: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.5)*0.3076;
                8..9: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.75)*0.3076;
                10: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*1)*0.3076;
            end;
        end
        else if TabOrbit[OrbDBCounter].TypeAstre in [33..34] then begin
            OCCA_Proba:=random(9)+1;
            case OCCA_Proba of
                1: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.25)*0.3076;
                2..4: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.5)*0.3076;
                5..7: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.75)*0.3076;
                8..9: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*1)*0.3076;
                10: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*1.5)*0.3076;
            end;
        end
        else if TabOrbit[OrbDBCounter].TypeAstre in [35..36] then begin
            OCCA_Proba:=random(9)+1;
            case OCCA_Proba of
                1: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*0.5)*0.3076;
                2..4: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*1)*0.3076;
                5..7: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*1.5)*0.3076;
                8..9: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*2)*0.3076;
                10: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*3)*0.3076;
            end;
        end
        else if TabOrbit[OrbDBCounter].TypeAstre in [37..38] then begin
            OCCA_Proba:=random(9)+1;
            case OCCA_Proba of
                1: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*1.5)*0.3076;
                2..4: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*2.5)*0.3076;
                5..7: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*5)*0.3076;
                8..9: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*10)*0.3076;
                10: TabOrbit[OrbDBCounter].MagField:=((random(9)+1)*25)*0.3076;
            end;
        end;
        TabOrbit[OrbDBCounter].MagField:=roundto(TabOrbit[OrbDBCounter].MagField,-3);}
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

//===========================END FUNCTIONS SECTION==========================================

procedure FCMfG_RotationPeriod_Calculation( const Star, OrbitalObject: integer );
{:Purpose: calculate the orbital object's rotation period.
   Additions:
}
   var
      Probability: integer;

      CalculatedRotationPeriod
      ,CoefPeriod
      ,KStar
      ,MassInG
      ,RadiusInCm
      ,ShortestPeriod
      ,StarAge
      ,TidalFinal
      ,TidalForce
      ,VelFinal
      ,Velocity: extended;
begin
   ShortestPeriod:=sqrt( ( 2 * Pi ) / ( 0.19 * FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity * 9.807 ) );
   TidalForce:=( FCDduStarSystem[0].SS_stars[Star].S_mass * 26640000 ) /   power( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar * 400, 3 );
   StarAge:=( ( 10.1 * FCDduStarSystem[0].SS_stars[Star].S_mass ) / FCDduStarSystem[0].SS_stars[Star].S_luminosity ) / 2.244;
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
      RadiusInCm:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_diameter * 100000;
      MassInG:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_mass * FCCdiMassEqEarth * 1000;
      KStar:=( ( 0.19 * FCDduStarSystem[0].SS_stars[Star].S_mass ) / FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar ) * FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity;
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
   FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_rotationPeriod:=FCFcF_Round( rttCustom2Decimal, CalculatedRotationPeriod );
end;

end.
