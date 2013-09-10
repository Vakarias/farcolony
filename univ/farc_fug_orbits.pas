{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - orbits generation unit

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
unit farc_fug_orbits;

interface

uses
   Math
   ,SysUtils

   ,farc_data_univ;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   calculate the orbital eccentricity
///</summary>
///   <param name="SystemType">TFCRfdSystemType value</param>
///   <param name="ObjectDistance">orbital object's distance from its star</param>
///   <param name="StarLuminosity">luminosity of the central star</param>
///   <returns>orbital eccentricity</returns>
///   <remarks>format [x.xxxx]</remarks>
function FCFfS_OrbitalEccentricity_Calculation(
   const SystemType: integer;
   const ObjectDistance
         ,StarLuminosity: extended
   ): extended;

///<summary>
///   calculate the orbital zone in which the orbit is located
///</summary>
///   <param name="OrbitDistance">distance of the orbit from the central star</param>
///   <param name="StarLuminosity">luminosity of the star</param>
///   <returns>the orbital zone</returns>
///   <remarks>don't apply it if the star is a BH, all orbits are located in the outer zone for this class of star</remarks>
function FCFfS_OrbitalZone_Determining( const OrbitDistance, StarLuminosity: extended ): TFCEduHabitableZones;

///<summary>
///   generate the basic type of orbital object given the star's class, for a Balanced distribution system
///</summary>
///   <param name="StarClass">star class</param>
///   <param name="Zone">orbital zone</param>
///   <return>the default orbital object that must be generated</return>
function FCFfS_OrbitGen_Balanced( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEduOrbitalObjectBasicTypes;

///<summary>
///   generate the basic type of orbital object given the star's class, for a Sol-Like distribution system
///</summary>
///   <param name="StarClass">star class</param>
///   <param name="Zone">orbital zone</param>
///   <return>the default orbital object that must be generated</return>
function FCFfS_OrbitGen_SolLike( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEduOrbitalObjectBasicTypes;

///<summary>
///   generate the basic type of orbital object given the star's class, for a ExtraSol-Like distribution system
///</summary>
///   <param name="StarClass">star class</param>
///   <param name="Zone">orbital zone</param>
///   <return>the default orbital object that must be generated</return>
function FCFfS_OrbitGen_ExtraSolLike( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEduOrbitalObjectBasicTypes;

function FCFfO_Satellites_Distance( const RootRadius: extended ): extended; overload;

///<summary>
///   calculate the satellite's orbit distance from its root planet
///</summary>
///   <param name="RootRadius">radius, in km, of the root object</param>
///   <param name="RootGravSphere">root's gravitational sphere</param>
///   <param name="RootBasicType">root's basic type</param>
///   <param name="SatBasicType">satellite's basic type</param>
///   <return>the distance in thousands of km.</return>
///   <remarks>format [x.xx]</remarks>
function FCFfO_Satellites_Distance(
   const RootRadius
         ,RootGravSphere: extended;
   const RootBasicType
         ,SatBasicType: TFCEduOrbitalObjectBasicTypes
          ): extended; overload;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   core routine for orbits generation
///   <param="FOGstar">star index #</param>
///</summary>
procedure FCMfO_Generate(const CurrentStar: integer);

///<summary>
///   calculate the gravitational sphere radius, the geosynchronous and the low orbits of an orbital object
///</summary>
///   <param name="Star">star's index #</param>
///   <param name="OrbitalObject">orbital object's index #</param>
///   <param name="Asteroid">optional parameter, only for an asteroid in a belt. Satellite must be = 0</param>
///   <param name="Satellite">optional parameter, only for any satellite. Asteroid must be = 0</param>
///   <returns></returns>
///   <remarks>format [x.x]</remarks>
procedure FCMfO_GravSphereOrbits_Calculation(
   const Star
         ,OrbitalObject: integer;
   const Asteroid: integer=0;
   const Satellite: integer=0
   );

implementation

uses
   farc_common_func
   ,farc_data_init
   ,farc_data_3dopengl
   ,farc_fug_atmosphere
   ,farc_fug_data
   ,farc_fug_geophysical
   ,farc_fug_hydrosphere
   ,farc_fug_regions
   ,farc_fug_seasons
   ,farc_fug_stars
   ,farc_win_fug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var

   FOsatDistanceRange: TFCEduSatelliteDistances;

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFfS_OrbitalEccentricity_Calculation(
   const SystemType: integer;
   const ObjectDistance
         ,StarLuminosity: extended
   ): extended;
{:Purpose: calculate the orbital eccentricity.
    Additions:
      -2013Apr26- *mod: end of experimental code tests - adoption of new eccentricity calculations method.
      -2013Apr23- *mod: start of experimental code tests.
}
   var
      Probability: integer;

      Calculations
      ,InnerDistance
      ,OuterDistance: extended;
begin
   Result:=0;
   Probability:=FCFcF_Random_DoInteger( 9 ) + 1;
   Calculations:=0;
   InnerDistance:=FCFfS_ZoneInner_CalcDistance( StarLuminosity );
   OuterDistance:=FCFfS_ZoneOuter_CalcDistance( StarLuminosity );
   case SystemType of
      1:
      begin
         if ( ObjectDistance < ( InnerDistance * 0.5 ) )
            or ( ObjectDistance > ( OuterDistance * 25 ) )
         then Probability:=Probability + 2
         else Probability:=Probability - 1;
      end;

      2:
      begin
         if ObjectDistance < ( InnerDistance / 2.25 )
         then Probability:=Probability + 1
         else Probability:=Probability + 2;
      end;

      3:
      begin
         if ObjectDistance < ( InnerDistance * 0.4 ) // /2.5
         then Probability:=Probability - 1
         else Probability:=Probability + 2;
      end;
   end;
   if Probability<1
   then Probability:=1
   else if Probability>10
   then Probability:=10;
   case Probability of
      1..5: Calculations:=0.0005 * ( FCFcF_Random_DoInteger( 99 ) + 1 );

      6..7: Calculations:=0.05 + ( 0.001 * ( FCFcF_Random_DoInteger( 99 ) + 1 ) );

      8..9: Calculations:=0.15 + ( 0.001 * ( FCFcF_Random_DoInteger( 99 ) + 1 ) );

      10: Calculations:=0.25 + ( 0.004 * ( FCFcF_Random_DoInteger( 99 ) + 1 ) );
   end;
   Result:=FCFcF_Round( rttCustom4Decimal, Calculations );
end;

function FCFfS_OrbitalZone_Determining( const OrbitDistance, StarLuminosity: extended ): TFCEduHabitableZones;
{:Purpose: calculate the orbital zone in which the orbit is located.
    Additions:
}
   var
      InnerDistance
      ,OuterDistance: extended;
begin
   Result:=hzInner;
   InnerDistance:=FCFfS_ZoneInner_CalcDistance( StarLuminosity );
   OuterDistance:=FCFfS_ZoneOuter_CalcDistance( StarLuminosity );
   if OrbitDistance < InnerDistance then Result:=hzInner
   else if OrbitDistance> OuterDistance then Result:=hzOuter
   else Result:=hzIntermediary;
end;

function FCFfS_OrbitGen_Balanced( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEduOrbitalObjectBasicTypes;
{:Purpose: generate the basic type of orbital object given the star's class, for a Balanced distribution system.
}
   var
      MaxAsteroid
      ,MaxAsteroidBelt
      ,MaxGaseousPlanet
      ,MaxTelluricPlanet
      ,MinAsteroid
      ,MinAsteroidBelt
      ,MinGaseousPlanet
      ,MinTelluricPlanet
      ,Test: integer;
begin
   Result:=oobtNone;
   MaxAsteroid:=0;
   MaxAsteroidBelt:=0;
   MaxGaseousPlanet:=0;
   MaxTelluricPlanet:=0;
   MinAsteroid:=0;
   MinAsteroidBelt:=0;
   MinGaseousPlanet:=0;
   MinTelluricPlanet:=0;
   Test:=0;
   case StarClass of
      cB5..A9:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=48;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=72;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=83;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=29;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=57;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=77;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=20;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=50;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=58;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;
         end;//==END== case Zone of ==//
      end;

      F0..M9:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=14;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=33;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=71;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=16;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=30;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=57;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=17;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=30;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=41;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;
         end;//==END== case Zone of ==//
      end;

      WD0..WD9:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=85;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=71;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=3;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=61;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=95;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;
         end;//==END== case Zone of ==//
      end;

      PSR:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=77;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=60;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=5;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=61;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;
         end;//==END== case Zone of ==//
      end;

      BH:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=0;
               MaxAsteroid:=0;
               MinTelluricPlanet:=0;
               MaxTelluricPlanet:=0;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=0;
               MaxAsteroid:=0;
               MinTelluricPlanet:=0;
               MaxTelluricPlanet:=0;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=85;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;
         end;//==END== case Zone of ==//
      end;
   end;//==END== case StarClass of ==//
   Test:=FCFcF_Random_DoInteger(99)+1;
   if ( MinAsteroidBelt>0 )
      and ( ( Test>=MinAsteroidBelt ) and ( Test<=MaxAsteroidBelt ) )
   then Result:=oobtAsteroidBelt
   else if ( MinAsteroid>0 )
      and ( ( Test>=MinAsteroid ) and ( Test<=MaxAsteroid ) )
   then Result:=oobtAsteroid
   else if ( MinTelluricPlanet>0 )
      and ( ( Test>=MinTelluricPlanet ) and ( Test<=MaxTelluricPlanet ) )
   then Result:=oobtTelluricPlanet
   else if ( MinGaseousPlanet>0 )
      and ( ( Test>=MinGaseousPlanet ) and ( Test<=MaxGaseousPlanet ) )
   then Result:=oobtGaseousPlanet;
end;

function FCFfS_OrbitGen_ExtraSolLike( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEduOrbitalObjectBasicTypes;
{:Purpose: generate the basic type of orbital object given the star's class, for a ExtraSol-Like distribution system.
}
   var
      MaxAsteroid
      ,MaxAsteroidBelt
      ,MaxGaseousPlanet
      ,MaxTelluricPlanet
      ,MinAsteroid
      ,MinAsteroidBelt
      ,MinGaseousPlanet
      ,MinTelluricPlanet
      ,Test: integer;
begin
   Result:=oobtNone;
   MaxAsteroid:=0;
   MaxAsteroidBelt:=0;
   MaxGaseousPlanet:=0;
   MaxTelluricPlanet:=0;
   MinAsteroid:=0;
   MinAsteroidBelt:=0;
   MinGaseousPlanet:=0;
   MinTelluricPlanet:=0;
   Test:=0;
   case StarClass of
      cB5..A9:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=40;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=49;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=68;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=25;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=35;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=61;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=17;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=30;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=40;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;
         end;//==END== case Zone of ==//
      end;

      F0..M9:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=8;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=35;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=60;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=12;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=27;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=45;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=17;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=30;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=40;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;
         end;//==END== case Zone of ==//
      end;

      WD0..WD9:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=85;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=71;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=52;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=90;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;
         end;//==END== case Zone of ==//
      end;

      PSR:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=70;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=60;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=10;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=80;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;
         end;//==END== case Zone of ==//
      end;

      BH:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=0;
               MaxAsteroid:=0;
               MinTelluricPlanet:=0;
               MaxTelluricPlanet:=0;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=0;
               MaxAsteroid:=0;
               MinTelluricPlanet:=0;
               MaxTelluricPlanet:=0;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=80;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;
         end;//==END== case Zone of ==//
      end;
   end;//==END== case StarClass of ==//
   Test:=FCFcF_Random_DoInteger(99)+1;
   if ( MinAsteroidBelt>0 )
      and ( ( Test>=MinAsteroidBelt ) and ( Test<=MaxAsteroidBelt ) )
   then Result:=oobtAsteroidBelt
   else if ( MinAsteroid>0 )
      and ( ( Test>=MinAsteroid ) and ( Test<=MaxAsteroid ) )
   then Result:=oobtAsteroid
   else if ( MinTelluricPlanet>0 )
      and ( ( Test>=MinTelluricPlanet ) and ( Test<=MaxTelluricPlanet ) )
   then Result:=oobtTelluricPlanet
   else if ( MinGaseousPlanet>0 )
      and ( ( Test>=MinGaseousPlanet ) and ( Test<=MaxGaseousPlanet ) )
   then Result:=oobtGaseousPlanet;
end;

function FCFfS_OrbitGen_SolLike( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEduOrbitalObjectBasicTypes;
{:Purpose: generate the basic type of orbital object given the star's class, for a Sol-Like distribution system.
}
   var
      MaxAsteroid
      ,MaxAsteroidBelt
      ,MaxGaseousPlanet
      ,MaxTelluricPlanet
      ,MinAsteroid
      ,MinAsteroidBelt
      ,MinGaseousPlanet
      ,MinTelluricPlanet
      ,Test: integer;
begin
   Result:=oobtNone;
   MaxAsteroid:=0;
   MaxAsteroidBelt:=0;
   MaxGaseousPlanet:=0;
   MaxTelluricPlanet:=0;
   MinAsteroid:=0;
   MinAsteroidBelt:=0;
   MinGaseousPlanet:=0;
   MinTelluricPlanet:=0;
   Test:=0;
   case StarClass of
      cB5..A9:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=55;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=94;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=98;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=34;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=80;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=94;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=23;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=71;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=76;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;
         end;//==END== case Zone of ==//
      end;

      F0..M9:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=21;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=32;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=83;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=19;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=32;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=69;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=17;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=31;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=43;
               MinGaseousPlanet:=MaxTelluricPlanet+1;
               MaxGaseousPlanet:=100;
            end;
         end;//==END== case Zone of ==//
      end;

      WD0..WD9:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=0;
               MaxAsteroid:=0;
               MinTelluricPlanet:=0;
               MaxTelluricPlanet:=0;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=0;
               MaxAsteroid:=0;
               MinTelluricPlanet:=0;
               MaxTelluricPlanet:=0;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=1;
               MaxAsteroidBelt:=5;
               MinAsteroid:=MaxAsteroidBelt+1;
               MaxAsteroid:=69;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;
         end;//==END== case Zone of ==//
      end;

      PSR:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=84;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=60;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=42;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;
         end;//==END== case Zone of ==//
      end;

      BH:
      begin
         case Zone of
            hzInner:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=0;
               MaxAsteroid:=0;
               MinTelluricPlanet:=0;
               MaxTelluricPlanet:=0;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzIntermediary:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=0;
               MaxAsteroid:=0;
               MinTelluricPlanet:=0;
               MaxTelluricPlanet:=0;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;

            hzOuter:
            begin
               MinAsteroidBelt:=0;
               MaxAsteroidBelt:=0;
               MinAsteroid:=1;
               MaxAsteroid:=90;
               MinTelluricPlanet:=MaxAsteroid+1;
               MaxTelluricPlanet:=100;
               MinGaseousPlanet:=0;
               MaxGaseousPlanet:=0;
            end;
         end;//==END== case Zone of ==//
      end;
   end;//==END== case StarClass of ==//
   Test:=FCFcF_Random_DoInteger(99)+1;
   if ( MinAsteroidBelt>0 )
      and ( ( Test>=MinAsteroidBelt ) and ( Test<=MaxAsteroidBelt ) )
   then Result:=oobtAsteroidBelt
   else if ( MinAsteroid>0 )
      and ( ( Test>=MinAsteroid ) and ( Test<=MaxAsteroid ) )
   then Result:=oobtAsteroid
   else if ( MinTelluricPlanet>0 )
      and ( ( Test>=MinTelluricPlanet ) and ( Test<=MaxTelluricPlanet ) )
   then Result:=oobtTelluricPlanet
   else if ( MinGaseousPlanet>0 )
      and ( ( Test>=MinGaseousPlanet ) and ( Test<=MaxGaseousPlanet ) )
   then Result:=oobtGaseousPlanet;
end;

function FCFfO_Satellites_Distance( const RootRadius: extended ): extended; overload;
{:Purpose: internal recaller for FCFfO_Satellites_Distance.
   Additions:
      -2013Sep09- *fix: prevent a satellite to be too near its root parent by buffing up the minimum distance.
}
   var
      GeneratedProbability: integer;
begin
   Result:=0;
   case FOsatDistanceRange of
      sdClose, sdAverage: Result:=( 2 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.05 ) ) * RootRadius;

      sdDistant: Result:=( 6 + ( FCFcF_Random_DoInteger( 99 ) + 0.1 ) ) * RootRadius;

      sdVeryDistant: Result:=( 16 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.3 ) ) * RootRadius;

      sdCaptured:
      begin
         GeneratedProbability:=FCFcF_Random_DoInteger( 4 ) + 5;
         case GeneratedProbability of
            5..6: Result:=( 6 + ( FCFcF_Random_DoInteger( 99 ) + 0.1 ) ) * RootRadius;

            7..8: Result:=( 16 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.3 ) ) * RootRadius;

            9: Result:=( 46 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 3 ) ) * RootRadius;
         end;
      end;
   end;
end;

function FCFfO_Satellites_Distance(
   const RootRadius
         ,RootGravSphere: extended;
   const RootBasicType
         ,SatBasicType: TFCEduOrbitalObjectBasicTypes
          ): extended; overload;
{:Purpose: calculate the satellite's orbit distance from its root planet.
   Additions:
      -2013Sep09- *fix: prevent a satellite to be too near its root parent by buffing up the minimum distance.
      -2013May19- *add: exception w/ captured satellites.
}
   var
      GeneratedProbability: integer;

      Calculation: extended;
begin
   Result:=0;
   if ( ( ( RootBasicType=oobtTelluricPlanet ) or ( RootBasicType=oobtIcyPlanet ) ) and ( SatBasicType=oobtAsteroid ) )
      or ( RootBasicType=oobtAsteroid ) then
   begin
      FOsatDistanceRange:=sdCaptured;
      Calculation:=FCFfO_Satellites_Distance( RootRadius );
   end
   else begin
      GeneratedProbability:=FCFcF_Random_DoInteger( 9 ) + 1;
      FOsatDistanceRange:=sdNone;
      case GeneratedProbability of
         1..4:
         begin
            FOsatDistanceRange:=sdClose;
            Calculation:=( 2 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.05 ) ) * RootRadius;
         end;

         5..6:
         begin
            FOsatDistanceRange:=sdAverage;
            Calculation:=( 6 + ( FCFcF_Random_DoInteger( 99 ) + 0.1 ) ) * RootRadius;
         end;

         7..8:
         begin
            FOsatDistanceRange:=sdDistant;
            Calculation:=( 16 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.3 ) ) * RootRadius;
         end;

         9:
         begin
            FOsatDistanceRange:=sdVeryDistant;
            Calculation:=( 46 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 3 ) ) * RootRadius;
         end;

         10:
         begin
            FOsatDistanceRange:=sdCaptured;
            Calculation:=FCFfO_Satellites_Distance( RootRadius );
         end;
      end;
   end;
   if ( Calculation > RootGravSphere )
      and ( FOsatDistanceRange < sdCaptured )
   then Calculation:=FCFfO_Satellites_Distance( RootRadius );
   Result:=FCFcF_Round( rttCustom1Decimal, Calculation * 0.001 );
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMfO_Generate(const CurrentStar: integer);
{:Purpose: core routine for orbits generation.
    Additions:
      -2013Sep08- *add: put minimal distance for an asteroid belt compared to the previous orbital object and by taking into account it's diameter.
      -2013Aug27- *add: set the gaseous environment for the gaseous planets.
      -2013Aug18- *add: link to regions generation, if required.
      -2013Aug03- *add: set the type of planets.
      -2013Jul03- *add: orbital periods.
                  *fix: prevent an error on tectonic activity if it is manually set.
      -2013Jul01- *add: hydrosphere.
                  *add: atmosphere: prevent calculations is a WD, PSR, or BH.
                  *fix: correction, for an asteroid in a belt, is the inclination axis < 0.
                  *fix: prevent generation of satellites if manual number=-1.
      -2013Jun29- *add: atmosphere.
      -2013May28- *mod: base temperature calculation.
      -2013May21- *add: completion of geophysical calculations.
                  *fix: satellite generation for non asteroid belts: forgot to resize the satellite dynamic array after the determination of the number of satellites.
      -2013May20- *add: completion of the satellite phase I since May 14.
      -2013May13- *mod: the last adjustments, for the orbit distances, are applied.
      -2013May08- *add: satellites - manual entry initialization.
      -2013Apr14- *add: take in account the data that are manually set and load them in the data structures.
}
var
   Count
   ,CountSat
   ,NumberOfOrbits
   ,NumberOfSat
   ,GeneratedProbability
   ,OrbitProbabilityMax
   ,OrbitProbabilitMin: integer;

   ABeltMinDist
   ,BaseTemperature
   ,CalcFloat
   ,CalcFloat1
   ,CalcFloat2
   ,CalcFloat3: extended;

   isPassedBinaryTrinaryTest: boolean;

   Token: string;

   procedure _BinaryTrinary_Calculate;
   begin
      if (CalcFloat>=1)
         and (CalcFloat<7)
      then GeneratedProbability:=50
      else if (CalcFloat>=7)
         and (CalcFloat<11)
      then GeneratedProbability:=80
      else if CalcFloat>=11
      then GeneratedProbability:=100;
      case GeneratedProbability of
         0: isPassedBinaryTrinaryTest:=false;
         50,80:
         begin
            Count:=FCFcF_Random_DoInteger(99)+1;
            if Count>GeneratedProbability
            then isPassedBinaryTrinaryTest:=false;
         end;
      end;
   end;

begin
   NumberOfOrbits:=0;
   GeneratedProbability:=0;
   OrbitProbabilityMax:=0;
   OrbitProbabilitMin:=0;
   Count:=0;
   CalcFloat:=0;
   CalcFloat1:=0;
   isPassedBinaryTrinaryTest:=true;
   {.in case where the orbits generation is randomized}
   if FCRfdStarOrbits[CurrentStar]=0 then
   begin
      {.binary/trinary orbits probability}
      {.CalcFloat: lowest minimal approach distance}
      if FCDduStarSystem[0].SS_stars[3].S_token<>'' then
      begin
         CalcFloat:=Min( FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance, FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance );
         _BinaryTrinary_Calculate;
      end
      else if FCDduStarSystem[0].SS_stars[2].S_token<>'' then
      begin
         CalcFloat:=FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance;
         _BinaryTrinary_Calculate;
      end;
      {.orbits probability + number generation}
      if isPassedBinaryTrinaryTest then
      begin
         case FCDduStarSystem[0].SS_stars[CurrentStar].S_class of
            cB5..cM5:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=10;
            end;

            gF0..gM5:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=20;
            end;

            O5..B9:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=10;
            end;

            A0..A9:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=50;
            end;

            F0..K9:
            begin
               OrbitProbabilitMin:=25;
               OrbitProbabilityMax:=75;
            end;

            M0..M9:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=50;
            end;

            WD0..WD9:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=10;
            end;

            PSR:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=30;
            end;

            BH:
            begin
               OrbitProbabilitMin:=1;
               OrbitProbabilityMax:=5;
            end;
         end; //==END== case FCDBsSys[0].SS_star[FOGstar].SDB_class of ==//
         Count:=FCFcF_Random_DoInteger(99)+1;
         if (Count>=OrbitProbabilitMin)
            and (Count<=OrbitProbabilityMax) then
         begin
            NumberOfOrbits:=round(0.2*Count);
            if NumberOfOrbits=0
            then NumberOfOrbits:=1;
            SetLength(FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects, NumberOfOrbits+1);
         end;
      end; //==END== if FOGisPassedBiTri ==//
   end //==END== if FUGstarOrb[FOGstar]=0 ==//
   else if FCRfdStarOrbits[CurrentStar]>0 then
   begin
      {.data loading from manual edition}
      NumberOfOrbits:=FCRfdStarOrbits[CurrentStar];
      SetLength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects, NumberOfOrbits+1 );
      Count:=1;
      while Count<=NumberOfOrbits do
      begin
         case CurrentStar of
            1:
            begin
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_dbTokenId:=FCDfdMainStarObjectsList[Count].OO_dbTokenId;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isSatellite:=false;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType:=FCDfdMainStarObjectsList[Count].OO_fug_BasicType;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar:=FCDfdMainStarObjectsList[Count].OO_isNotSat_distanceFromStar;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter:=FCDfdMainStarObjectsList[Count].OO_diameter;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density:=FCDfdMainStarObjectsList[Count].OO_density;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass:=FCDfdMainStarObjectsList[Count].OO_mass;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity:=FCDfdMainStarObjectsList[Count].OO_gravity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity:=FCDfdMainStarObjectsList[Count].OO_escapeVelocity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod:=FCDfdMainStarObjectsList[Count].OO_isNotSat_rotationPeriod;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_axialTilt:=FCDfdMainStarObjectsList[Count].OO_isNotSat_axialTilt;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_magneticField:=FCDfdMainStarObjectsList[Count].OO_magneticField;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_tectonicActivity:=FCDfdMainStarObjectsList[Count].OO_tectonicActivity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_isAtmosphereEdited:=FCDfdMainStarObjectsList[Count].OO_fug_isAtmosphereEdited;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphericPressure:=FCDfdMainStarObjectsList[Count].OO_atmosphericPressure;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_traceAtmosphere:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_traceAtmosphere;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_primaryGasVolumePerc:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_primaryGasVolumePerc;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceH2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceHe:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceHe;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCH4:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceCH4;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNH3:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceNH3;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2O:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceH2O;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNe:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceNe;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceN2:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceN2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCO:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceCO;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNO:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceNO;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceO2:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2S:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceH2S;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceAr:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceAr;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCO2:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceCO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNO2:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceNO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceO3:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceO3;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceSO2:=FCDfdMainStarObjectsList[Count].OO_atmosphere.AC_gasPresenceSO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isHydrosphereEdited:=FCDfdMainStarObjectsList[Count].OO_isHydrosphereEdited;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_hydrosphere:=FCDfdMainStarObjectsList[Count].OO_hydrosphere;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_hydrosphereArea:=FCDfdMainStarObjectsList[Count].OO_hydrosphereArea;
               NumberOfSat:=length( FCDfdMainStarObjectsList[Count].OO_satellitesList ) - 1;
               setlength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList, NumberOfSat + 1 );
               CountSat:=1;
               while CountSat<=NumberOfSat do
               begin
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_dbTokenId;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSatellite:=true;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_fug_BasicType;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_diameter;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_density;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_mass;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_gravity:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_gravity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_escapeVelocity:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_escapeVelocity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_magneticField:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_magneticField;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_tectonicActivity:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_tectonicActivity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_isAtmosphereEdited:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_fug_isAtmosphereEdited;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphericPressure:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphericPressure;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_traceAtmosphere:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_traceAtmosphere;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_primaryGasVolumePerc:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_primaryGasVolumePerc;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceHe:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceHe;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCH4:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCH4;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNH3:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNH3;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2O:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2O;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNe:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNe;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceN2:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceN2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO2:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2S:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2S;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceAr:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceAr;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO2:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO2:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO3:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO3;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceSO2:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceSO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isHydrosphereEdited:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_isHydrosphereEdited;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_hydrosphere:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_hydrosphere;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_hydrosphereArea:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_hydrosphereArea;
                  inc( CountSat );
               end;

//               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_albedo:=FCDfdMainStarObjectsList[Count].OO_albedo;
            end;

            2:
            begin
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_dbTokenId:=FCDfdComp1StarObjectsList[Count].OO_dbTokenId;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isSatellite:=false;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType:=FCDfdComp1StarObjectsList[Count].OO_fug_BasicType;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar:=FCDfdComp1StarObjectsList[Count].OO_isNotSat_distanceFromStar;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter:=FCDfdComp1StarObjectsList[Count].OO_diameter;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density:=FCDfdComp1StarObjectsList[Count].OO_density;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass:=FCDfdComp1StarObjectsList[Count].OO_mass;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity:=FCDfdComp1StarObjectsList[Count].OO_gravity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity:=FCDfdComp1StarObjectsList[Count].OO_escapeVelocity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod:=FCDfdComp1StarObjectsList[Count].OO_isNotSat_rotationPeriod;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_axialTilt:=FCDfdComp1StarObjectsList[Count].OO_isNotSat_axialTilt;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_magneticField:=FCDfdComp1StarObjectsList[Count].OO_magneticField;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_tectonicActivity:=FCDfdComp1StarObjectsList[Count].OO_tectonicActivity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_isAtmosphereEdited:=FCDfdComp1StarObjectsList[Count].OO_fug_isAtmosphereEdited;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphericPressure:=FCDfdComp1StarObjectsList[Count].OO_atmosphericPressure;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_traceAtmosphere:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_traceAtmosphere;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_primaryGasVolumePerc:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_primaryGasVolumePerc;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceH2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceHe:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceHe;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCH4:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceCH4;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNH3:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceNH3;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2O:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceH2O;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNe:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceNe;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceN2:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceN2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCO:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceCO;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNO:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceNO;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceO2:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2S:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceH2S;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceAr:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceAr;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCO2:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceCO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNO2:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceNO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceO3:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceO3;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceSO2:=FCDfdComp1StarObjectsList[Count].OO_atmosphere.AC_gasPresenceSO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isHydrosphereEdited:=FCDfdComp1StarObjectsList[Count].OO_isHydrosphereEdited;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_hydrosphere:=FCDfdComp1StarObjectsList[Count].OO_hydrosphere;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_hydrosphereArea:=FCDfdComp1StarObjectsList[Count].OO_hydrosphereArea;
               NumberOfSat:=length( FCDfdComp1StarObjectsList[Count].OO_satellitesList ) - 1;
               setlength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList, NumberOfSat + 1 );
               CountSat:=1;
               while CountSat<=NumberOfSat do
               begin
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_dbTokenId;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSatellite:=true;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_fug_BasicType;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_diameter;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_density;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_mass;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_gravity:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_gravity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_escapeVelocity:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_escapeVelocity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_magneticField:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_magneticField;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_tectonicActivity:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_tectonicActivity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_isAtmosphereEdited:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_fug_isAtmosphereEdited;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphericPressure:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphericPressure;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_traceAtmosphere:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_traceAtmosphere;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_primaryGasVolumePerc:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_primaryGasVolumePerc;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceHe:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceHe;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCH4:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCH4;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNH3:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNH3;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2O:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2O;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNe:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNe;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceN2:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceN2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO2:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2S:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2S;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceAr:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceAr;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO2:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO2:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO3:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO3;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceSO2:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceSO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isHydrosphereEdited:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_isHydrosphereEdited;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_hydrosphere:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_hydrosphere;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_hydrosphereArea:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_hydrosphereArea;
                  inc( CountSat );
               end;

//               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_albedo:=FCDfdComp1StarObjectsList[Count].OO_albedo;
            end;

            3:
            begin
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_dbTokenId:=FCDfdComp2StarObjectsList[Count].OO_dbTokenId;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isSatellite:=false;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType:=FCDfdComp2StarObjectsList[Count].OO_fug_BasicType;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar:=FCDfdComp2StarObjectsList[Count].OO_isNotSat_distanceFromStar;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter:=FCDfdComp2StarObjectsList[Count].OO_diameter;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density:=FCDfdComp2StarObjectsList[Count].OO_density;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass:=FCDfdComp2StarObjectsList[Count].OO_mass;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity:=FCDfdComp2StarObjectsList[Count].OO_gravity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity:=FCDfdComp2StarObjectsList[Count].OO_escapeVelocity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod:=FCDfdComp2StarObjectsList[Count].OO_isNotSat_rotationPeriod;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_axialTilt:=FCDfdComp2StarObjectsList[Count].OO_isNotSat_axialTilt;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_magneticField:=FCDfdComp2StarObjectsList[Count].OO_magneticField;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_tectonicActivity:=FCDfdComp2StarObjectsList[Count].OO_tectonicActivity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_isAtmosphereEdited:=FCDfdComp2StarObjectsList[Count].OO_fug_isAtmosphereEdited;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphericPressure:=FCDfdComp2StarObjectsList[Count].OO_atmosphericPressure;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_traceAtmosphere:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_traceAtmosphere;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_primaryGasVolumePerc:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_primaryGasVolumePerc;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceH2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceHe:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceHe;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCH4:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceCH4;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNH3:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceNH3;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2O:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceH2O;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNe:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceNe;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceN2:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceN2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCO:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceCO;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNO:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceNO;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceO2:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2S:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceH2S;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceAr:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceAr;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCO2:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceCO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNO2:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceNO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceO3:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceO3;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceSO2:=FCDfdComp2StarObjectsList[Count].OO_atmosphere.AC_gasPresenceSO2;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isHydrosphereEdited:=FCDfdComp2StarObjectsList[Count].OO_isHydrosphereEdited;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_hydrosphere:=FCDfdComp2StarObjectsList[Count].OO_hydrosphere;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_hydrosphereArea:=FCDfdComp2StarObjectsList[Count].OO_hydrosphereArea;
               NumberOfSat:=length( FCDfdComp2StarObjectsList[Count].OO_satellitesList ) - 1;
               setlength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList, NumberOfSat + 1 );
               CountSat:=1;
               while CountSat<=NumberOfSat do
               begin
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_dbTokenId;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSatellite:=true;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_fug_BasicType;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_diameter;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_density;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_mass;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_gravity:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_gravity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_escapeVelocity:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_escapeVelocity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_magneticField:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_magneticField;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_tectonicActivity:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_tectonicActivity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_isAtmosphereEdited:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_fug_isAtmosphereEdited;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphericPressure:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphericPressure;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_traceAtmosphere:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_traceAtmosphere;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_primaryGasVolumePerc:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_primaryGasVolumePerc;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceHe:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceHe;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCH4:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCH4;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNH3:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNH3;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2O:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2O;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNe:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNe;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceN2:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceN2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO2:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2S:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2S;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceAr:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceAr;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO2:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO2:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO3:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO3;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceSO2:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceSO2;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isHydrosphereEdited:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_isHydrosphereEdited;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_hydrosphere:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_hydrosphere;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_hydrosphereArea:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_hydrosphereArea;
                  inc( CountSat );
               end;
            end;
         end; //==END== case CurrentStar of ==//
         inc( Count );
      end; //==END== while Count<=NumberOfOrbits ==//
   end; //==END== else if FCRfdStarOrbits[CurrentStar]>0 ==//
   {.orbit distances}
   {.CalcFloat=maximum allowed orbit distance (MAOD)}
   if FCRfdStarOrbits[CurrentStar]>0
   then CalcFloat:=-1
   else begin
      CalcFloat:=0;
      {.for a single star}
      if ( CurrentStar=1 )
         and ( not FCWinFUG.TC1S_EnableGroupCompanion1.Checked )
      then CalcFloat:=FCDduStarSystem[0].SS_stars[CurrentStar].S_mass * ( ( 75 + FCFcF_Random_DoInteger( 15 ) ) / 1.5 )//400*
      {.for a binary system}
      else if ( ( CurrentStar=1 ) and ( FCWinFUG.TC1S_EnableGroupCompanion1.Checked ) and ( not FCWinFUG.TC2S_EnableGroupCompanion2.Checked ) )
         or ( ( CurrentStar=2 ) and ( not FCWinFUG.TC2S_EnableGroupCompanion2.Checked ) )
      then CalcFloat:=FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance * 0.5
      {.for a trinary system - main star}
      else if CurrentStar=1 then
      begin
         case FCDduStarSystem[0].SS_stars[3].S_isCompStar2OrbitType of
            cotAroundMain_Companion1: CalcFloat:=FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance * 0.5;

            cotAroundCompanion1: CalcFloat:=min( FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance, FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance ) * 0.5;

            cotAroundMain_Companion1GravityCenter: CalcFloat:=( FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance - FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance ) * 0.5;
         end;
      end
      else if CurrentStar=2 then
      begin
         case FCDduStarSystem[0].SS_stars[3].S_isCompStar2OrbitType of
            cotAroundMain_Companion1: CalcFloat:=( FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance - FCDduStarSystem[0].SS_stars[3].S_isCompMeanSeparation ) * 0.5;

            cotAroundCompanion1: CalcFloat:=( FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance - FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance ) * 0.5;

            cotAroundMain_Companion1GravityCenter: CalcFloat:=( FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance - FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance ) * 0.5;
         end;
      end
      else if CurrentStar=3 then
      begin
         case FCDduStarSystem[0].SS_stars[3].S_isCompStar2OrbitType of
            cotAroundMain_Companion1, cotAroundCompanion1: CalcFloat:=FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance * 0.5;

            cotAroundMain_Companion1GravityCenter: CalcFloat:=( FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance - FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance ) * 0.5;
         end;
      end;
      CalcFloat:=FCFcF_Round( rttCustom2Decimal, CalcFloat );
      if CalcFloat<0
      then CalcFloat:=0;
   end;
   if CalcFloat=0
   then SetLength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects, 1 )
   {.orbit generation}
   else begin
      {.CalcFloat=maximum allowed orbit distance (MAOD). =-1 if fixed orbits}
      {.CalcFloat1: current orbit's distance}
      Count:=1;
      while Count<=NumberOfOrbits do
      begin
         ABeltMinDist:=0;
         if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_dbTokenId='' )
            or ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_dbTokenId='orbobj' ) then
         begin
            Token:=FCDduStarSystem[0].SS_stars[CurrentStar].S_token;
            delete( Token, 1, 4 );
            FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_dbTokenId:='orbobj' + Token + inttostr( Count );
         end;
         FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isSatellite:=false;

         if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar=0 then
         begin
            if Count=1 then
            begin
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_class in [WD0..WD9] then
               begin
                  GeneratedProbability:=FCFcF_Random_DoInteger( 9 ) + 1;
                  if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_mass >= 0.6 )
                     and ( FCDduStarSystem[0].SS_stars[CurrentStar].S_mass < 0.9 )
                  then GeneratedProbability:=GeneratedProbability + 2
                  else if FCDduStarSystem[0].SS_stars[CurrentStar].S_mass > 0.9
                  then GeneratedProbability:=GeneratedProbability + 4;
                  case GeneratedProbability of
                     1..4: CalcFloat1:=( FCFcF_Random_DoInteger( 100 ) * 0.01 ) + 1;

                     5..8: CalcFloat1:=( FCFcF_Random_DoInteger( 100 ) * 0.02 ) + 2;

                     9..11: CalcFloat1:=( FCFcF_Random_DoInteger( 100 ) * 0.02 ) + 4;

                     12..14: CalcFloat1:=( FCFcF_Random_DoInteger( 100 ) * 0.04 ) + 6;
                  end;
               end
               else if FCDduStarSystem[0].SS_stars[CurrentStar].S_class=PSR then
               begin
                  GeneratedProbability:=FCFcF_Random_DoInteger( 9 ) + 1;
                  case GeneratedProbability of
                     1..3: CalcFloat1:=( FCFcF_Random_DoInteger( 100 ) * 0.001 ) + 0.1;

                     4..7: CalcFloat1:=( FCFcF_Random_DoInteger( 100 ) * 0.01 ) + 1;

                     8..9: CalcFloat1:=( FCFcF_Random_DoInteger( 100 ) * 0.1 ) + 10;

                     10: CalcFloat1:=( FCFcF_Random_DoInteger( 10 ) * 1 ) + 15;
                  end;
               end
               else if FCDduStarSystem[0].SS_stars[CurrentStar].S_class=BH then
               begin
                  CalcFloat2:=( ( 2 * FCCdiGravitationalConst * ( FCCdiMassEqSun * FCDduStarSystem[0].SS_stars[CurrentStar].S_mass ) ) / sqr( FCCdiMetersBySec_In_1c ) ) / 1000;
                  CalcFloat1:=( CalcFloat2 / FCCdiKm_In_1AU ) * ( 1.5 + ( FCFcF_Random_DoInteger( 100 ) * 0.01 ) );
               end
               else CalcFloat1:=( FCDduStarSystem[0].SS_stars[CurrentStar].S_diameter * 0.5 ) * 0.004645787 * sqrt( FCDduStarSystem[0].SS_stars[CurrentStar].S_temperature ) * ( 1 + ( FCFcF_Random_DoInteger( 10 ) * 0.02 ) );
            end
            else begin
               GeneratedProbability:=FCFcF_Random_DoInteger( 99 ) + 1;
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count-1].OO_fug_BasicType = oobtAsteroidBelt
               then CalcFloat1:=( ( CalcFloat1 + ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count-1].OO_diameter * 0.5 ) ) * ( 1.1 + ( GeneratedProbability * 0.01 ) ) ) + 0.1
               else CalcFloat1:=( CalcFloat1 * ( 1 + ( GeneratedProbability * 0.01 ) ) ) + 0.02;
            end;
            FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar:=FCFcF_Round( rttCustom2Decimal, CalcFloat1 );
         end
         else CalcFloat1:=FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar;
         if ( CalcFloat>0 )
            and ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar > CalcFloat ) then
         begin
            SetLength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects, Count );
            break;
         end
         {.continue the orbit generation}
         else begin
            {.orbital data}
            if FCDduStarSystem[0].SS_stars[CurrentStar].S_class=BH
            then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone:=hzOuter
            else FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone:=FCFfS_OrbitalZone_Determining( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar, FCDduStarSystem[0].SS_stars[CurrentStar].S_luminosity );
            FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_eccentricity:=FCFfS_OrbitalEccentricity_Calculation(
               FCRfdSystemType[CurrentStar]
               ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar
               ,FCDduStarSystem[0].SS_stars[CurrentStar].S_luminosity
               );
            CalcFloat2:=SQRT( ( power( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar, 3 ) / FCDduStarSystem[0].SS_stars[CurrentStar].S_mass ) ) * 365.2422;
            FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_revolutionPeriod:=round( CalcFloat2 );
            if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_revolutionPeriod<1
            then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_revolutionPeriod:=1;
            CalcFloat2:=( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_revolutionPeriod / 100 ) * ( FCFcF_Random_DoInteger( 99 ) + 1 );
            FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_revolutionPeriodInit:=round( CalcFloat2 );
            if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_revolutionPeriodInit<1
            then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_revolutionPeriodInit:=1;
            {.geophysical data}
            BaseTemperature:=FCFfG_BaseTemperature_Calc( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar, FCDduStarSystem[0].SS_stars[CurrentStar].S_luminosity );
            if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType=oobtNone then
            begin
               case FCRfdSystemType[CurrentStar] of
                  1: FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType:=FCFfS_OrbitGen_SolLike( FCDduStarSystem[0].SS_stars[CurrentStar].S_class, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone );

                  2: FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType:=FCFfS_OrbitGen_Balanced( FCDduStarSystem[0].SS_stars[CurrentStar].S_class, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone );

                  3: FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType:=FCFfS_OrbitGen_ExtraSolLike( FCDduStarSystem[0].SS_stars[CurrentStar].S_class, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone );
               end;
            end;
            if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType=oobtTelluricPlanet )
               and ( BaseTemperature < 140 ) then
            begin
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType:=oobtIcyPlanet;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_type:=ootPlanet_Icy;
            end
            else FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_type:=ootPlanet_Telluric;
            {..for asteroids belt}
            if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType=oobtAsteroidBelt then
            begin
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_type:=ootAsteroidsBelt;

               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter = 0
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter:=FCFfG_AsteroidsBelt_CalculateDiameter( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar );

               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar = 0 then
               begin
                  if Count = 1
                  then CalcFloat1:=CalcFloat1 + ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter * 0.5 )
                  else begin
                     if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count-1].OO_fug_BasicType <> oobtAsteroidBelt then
                     begin
                        ABeltMinDist:=FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count-1].OO_isNotSat_distanceFromStar
                           + ( ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count-1].OO_gravitationalSphereRadius / FCCdiKm_In_1AU ) * 2 );
                     end
                     else begin
                        ABeltMinDist:=FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count-1].OO_isNotSat_distanceFromStar
                           + ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count-1].OO_diameter * 0.75 );
                     end;
                     if CalcFloat1 < ABeltMinDist
                     then CalcFloat1:=ABeltMinDist + ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter * 0.5 )
                     else CalcFloat1:=CalcFloat1 + ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter * 0.5 )
                  end;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar:=FCFcF_Round( rttCustom2Decimal, CalcFloat1 );
               end;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_revolutionPeriod:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_revolutionPeriodInit:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravitationalSphereRadius:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_geosynchOrbit:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_lowOrbit:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_axialTilt:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_magneticField:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_tectonicActivity:=taDead;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_isAtmosphereEdited:=false;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphericPressure:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_traceAtmosphere:=false;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_primaryGasVolumePerc:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceHe:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCH4:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNH3:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2O:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNe:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceN2:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCO:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNO:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceO2:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2S:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceAr:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCO2:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNO2:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceO3:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceSO2:=agsNotPresent;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isHydrosphereEdited:=false;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_hydrosphere:=hNoHydro;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_hydrosphereArea:=0;
               FCMfS_OrbitalPeriods_Generate( CurrentStar, Count );
               SetLength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_regions, 0 );
               {...asteroids phase I - basics + orbital + geophysical data}
               NumberOfSat:=length( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList ) - 1;
               if NumberOfSat=-1 then
               begin
                  CalcFloat2:=FCFcF_Scale_Conversion( cAU_to3dViewUnits, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar );
                  CalcFloat3:=sqrt( 2 * FCCdiPiDouble * CalcFloat2 ) / ( 4.52 * FC3doglCoefViewReduction );
                  NumberOfSat:=round( CalcFloat3 );
                  setlength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList, NumberOfSat + 1 );
               end; //==END== if NumberOfSat<=0 ==//
               CountSat:=1;
               while CountSat <= NumberOfSat do
               begin
                  if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId='' )
                     or ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId='abelt' ) then
                  begin
                     Token:=FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_dbTokenId;
                     delete( Token, 1, 6 );
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId:='abelt' + Token + '-' + inttostr( CountSat );
                  end;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSatellite:=true;
                  CalcFloat2:=FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar - ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter * 0.5 );
                  CalcFloat3:=CalcFloat2 + ( FCFcF_Random_DoFloat * FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter );
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar:=FCFcF_Round( rttCustom2Decimal, CalcFloat3 );
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType:=oobtAsteroid;
                  if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriod=0 then
                  begin
                     CalcFloat2:=SQRT( ( power( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar, 3 ) / FCDduStarSystem[0].SS_stars[CurrentStar].S_mass ) ) * 365.2422;
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriod:=round( CalcFloat2 );
                     if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriod<1
                     then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriod:=1;
                     CalcFloat2:=( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriod / 100 ) * ( FCFcF_Random_DoInteger( 99 ) + 1 );
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriodInit:=round( CalcFloat2 );
                     if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriodInit<1
                     then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriodInit:=1;
                  end;
                  if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter=0
                  then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter:=FCFfG_Diameter_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType, hzInner );
                  if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density=0
                  then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density:=FCFfG_Density_Calculation(
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType
                     ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone
                     ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar
                     ,FCDduStarSystem[0].SS_stars[CurrentStar].S_luminosity
                     );
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_type:=FCFfG_Refinement_Asteroid(
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density
                     ,BaseTemperature
                     ,false
                     );
                  if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass=0
                  then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass:=FCFfG_Mass_Calculation(
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter
                     ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density
                     ,true
                     );
                  if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_gravity=0
                  then  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_gravity:=FCFfG_Gravity_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass );
                  if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_escapeVelocity=0
                  then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_escapeVelocity:=FCFfG_EscapeVelocity_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass );
                  if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isAsterBelt_rotationPeriod=0
                  then FCMfG_RotationPeriod_Calculation(
                     CurrentStar
                     ,Count
                     ,CountSat
                     );
                  FCMfO_GravSphereOrbits_Calculation(
                     CurrentStar
                     ,Count
                     ,CountSat
                     );
                  if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isAsterBelt_axialTilt=0
                  then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isAsterBelt_axialTilt:=FCFfG_InclinationAxis_Calculation;
                  if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isAsterBelt_axialTilt<0 then
                  begin
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isAsterBelt_axialTilt:=abs( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isAsterBelt_axialTilt );
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isAsterBelt_rotationPeriod:=-( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isAsterBelt_rotationPeriod );
                  end;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_magneticField:=0;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_tectonicActivity:=taDead;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_isAtmosphereEdited:=false;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphericPressure:=0;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_traceAtmosphere:=false;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_primaryGasVolumePerc:=0;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceHe:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCH4:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNH3:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2O:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNe:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceN2:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO2:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2S:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceAr:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO2:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO2:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO3:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceSO2:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isHydrosphereEdited:=false;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_hydrosphere:=hNoHydro;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_hydrosphereArea:=0;
                  FCMfS_OrbitalPeriods_Generate(
                     CurrentStar
                     ,Count
                     ,CountSat
                     );
                  FCMfR_GenerationPhase_Process(
                     CurrentStar
                     ,Count
                     ,CountSat
                     );
                  inc( CountSat );
               end; //==END== while CountSat <= NumberOfSat ==//
            end //==END== if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType=oobtAsteroidBelt then ==//
            {..for the rest of the basic types}
            else begin
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter=0
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter:=FCFfG_Diameter_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density=0

               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density:=FCFfG_Density_Calculation(
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType
                  ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone
                  ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar
                  ,FCDduStarSystem[0].SS_stars[CurrentStar].S_luminosity
                  );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType=oobtAsteroid
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_type:=FCFfG_Refinement_Asteroid(
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density
                  ,BaseTemperature
                  ,false
                  );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass=0 then
               begin
                  if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType=oobtAsteroid
                  then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass:=FCFfG_Mass_Calculation(
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter
                     ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density
                     ,true
                     )
                  else FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass:=FCFfG_Mass_Calculation(
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter
                     ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density
                     ,false
                     );
               end;
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType=oobtGaseousPlanet
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_type:=FCFfG_Refinement_GaseousPlanet( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity=0
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity:=FCFfG_Gravity_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity=0
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity:=FCFfG_EscapeVelocity_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod=0
               then FCMfG_RotationPeriod_Calculation(
                  CurrentStar
                  ,Count
                  ,0
                  );
               FCMfO_GravSphereOrbits_Calculation( CurrentStar, Count );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_axialTilt=0
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_axialTilt:=FCFfG_InclinationAxis_Calculation;
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_axialTilt<0 then
               begin
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_axialTilt:=abs( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_axialTilt );
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod:=-( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod );
               end;
               if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_magneticField=0 )
                  and ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType > oobtAsteroid )
               then FCMfG_MagneticField_Calculation( CurrentStar, Count );
               if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_tectonicActivity=taNull )
                  and ( ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType= oobtTelluricPlanet ) or ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType= oobtIcyPlanet ) )
               then FCMfG_TectonicActivity_Calculation( CurrentStar, Count );
//               else FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_tectonicActivity:=taDead;
               if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_class < WD0 )
                  and ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType > oobtAsteroid )
                  and ( not FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_isAtmosphereEdited )
               then FCMfA_Atmosphere_Processing(
                  CurrentStar
                  ,Count
                  ,BaseTemperature
                  )
               else if FCDduStarSystem[0].SS_stars[CurrentStar].S_class >= WD0 then
               begin
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_isAtmosphereEdited:=false;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphericPressure:=0;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_traceAtmosphere:=false;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_primaryGasVolumePerc:=0;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceHe:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCH4:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNH3:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2O:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNe:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceN2:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCO:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNO:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceO2:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceH2S:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceAr:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceCO2:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceNO2:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceO3:=agsNotPresent;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_atmosphere.AC_gasPresenceSO2:=agsNotPresent;
               end;
               FCMfS_OrbitalPeriods_Generate( CurrentStar, Count );
               if ( ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType > oobtAsteroidBelt ) and ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType < oobtGaseousPlanet ) )
                  or ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType = oobtIcyPlanet )
               then FCMfR_GenerationPhase_Process( CurrentStar, Count )
               else setlength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_regions, 0 );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType = oobtGaseousPlanet
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_environment:=etGaseous;
               {...satellites phase I - basics + orbital + geophysical data}
               NumberOfSat:=length( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList ) - 1;
               if (FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod <> 0 )
                  and ( NumberOfSat=-1 ) then
               begin
                  GeneratedProbability:=FCFcF_Random_DoInteger( 9 ) + 1;
                  case FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone of
                     hzInner: GeneratedProbability:=GeneratedProbability - 5;

                     hzIntermediary: GeneratedProbability:=GeneratedProbability + 2;

                     hzOuter: GeneratedProbability:=GeneratedProbability + 5;
                  end;
                  case GeneratedProbability of
                     -4..5:
                     begin
                        if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType=oobtGaseousPlanet
                        then NumberOfSat:=FCFcF_Random_DoInteger( 4 ) + 1;
                     end;

                     6..7:
                     begin
                        case FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType of
                           oobtTelluricPlanet: NumberOfSat:=1;

                           oobtGaseousPlanet: NumberOfSat:=FCFcF_Random_DoInteger( 9 ) + 1;

                           oobtIcyPlanet: NumberOfSat:=1;
                        end;
                     end;

                     8..9:
                     begin
                        case FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType of
                           oobtTelluricPlanet: NumberOfSat:=FCFcF_Random_DoInteger( 1 ) + 1;

                           oobtGaseousPlanet: NumberOfSat:=FCFcF_Random_DoInteger( 9 ) + 2;

                           oobtIcyPlanet: NumberOfSat:=FCFcF_Random_DoInteger( 1 ) + 1;
                        end;
                     end;

                     10..13:
                     begin
                        case FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType of
                           oobtAsteroid: NumberOfSat:=1;

                           oobtTelluricPlanet: NumberOfSat:=FCFcF_Random_DoInteger( 2 ) + 1;

                           oobtGaseousPlanet: NumberOfSat:=FCFcF_Random_DoInteger( 9 ) + 3;

                           oobtIcyPlanet: NumberOfSat:=FCFcF_Random_DoInteger( 2 ) + 1;
                        end;
                     end;

                     14..15:
                     begin
                        case FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType of
                           oobtAsteroid: NumberOfSat:=1;

                           oobtTelluricPlanet: NumberOfSat:=FCFcF_Random_DoInteger( 3 ) + 1;

                           oobtGaseousPlanet: NumberOfSat:=FCFcF_Random_DoInteger( 9 ) + 6;

                           oobtIcyPlanet: NumberOfSat:=FCFcF_Random_DoInteger( 3 ) + 1;
                        end;
                     end;
                  end; //==END== case GeneratedProbability ==//
                  setlength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList, NumberOfSat + 1 );
               end; //==END== if (FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod <> 0 ) and ( NumberOfSat=0 ) ==//
               if (FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod <> 0 )
                  and ( NumberOfSat > 0 ) then
               begin
                  CountSat:=1;
                  while CountSat <= NumberOfSat do
                  begin
                     if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId='' )
                        or ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId='sat' ) then
                     begin
                        Token:=FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_dbTokenId;
                        delete( Token, 1, 6 );
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId:='sat' + Token + '-' + inttostr( CountSat );
                     end;
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSatellite:=true;
                     {....orbit distance from the root object}
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar:=FCFfO_Satellites_Distance(
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter * 0.5
                        ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravitationalSphereRadius
                        ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_fug_BasicType
                        ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType
                        );
                     {....basic type}
                     GeneratedProbability:=FCFcF_Random_DoInteger( 9 ) + 1;
                     case FOsatDistanceRange of
                        sdClose: GeneratedProbability:=GeneratedProbability - 1;

                        sdDistant: GeneratedProbability:=GeneratedProbability + 1;

                        sdVeryDistant: GeneratedProbability:=GeneratedProbability + 2;
                     end;
                     if GeneratedProbability < 7
                     then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType:=oobtAsteroid
                     else if BaseTemperature < 140 then
                     begin
                        if FOsatDistanceRange=sdCaptured then
                        begin
                           GeneratedProbability:=FCFcF_Random_DoInteger( 99 ) + 1;
                           case FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone of
                              hzInner: GeneratedProbability:=GeneratedProbability - 90;

                              hzIntermediary: GeneratedProbability:=GeneratedProbability - 70;

                              hzOuter: GeneratedProbability:=GeneratedProbability - 40;
                           end;
                           if GeneratedProbability <= 0 then
                           begin
                              FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType:=oobtTelluricPlanet;
                              FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_type:=ootSatellite_Planet_Telluric;
                           end
                           else begin
                              FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType:=oobtIcyPlanet;
                              FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_type:=ootSatellite_Planet_Icy;
                           end;
                        end
                        else begin
                           FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType:=oobtIcyPlanet;
                           FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_type:=ootSatellite_Planet_Icy;
                        end;
                     end
                     else begin
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType:=oobtTelluricPlanet;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_type:=ootSatellite_Planet_Telluric;
                     end;
                     {....revolution period w/ CalcFloat2: Distance Coef}
                     CalcFloat2:=FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar / 384399;
                     CalcFloat3:=sqrt( power( CalcFloat2, 3 ) * ( 746.468843 / FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass ) );
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriod:=round( CalcFloat3 );
                     if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriod < 1
                     then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriod:=1;
                     CalcFloat3:=FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriod / 100 * ( FCFcF_Random_DoInteger( 99 ) + 1 );
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriodInit:=round( CalcFloat3 );
                     if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriodInit < 1
                     then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_revolutionPeriodInit:=1;
                     {....geophysical data: diameter and density}
                     if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter=0
                     then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter:=FCFfG_Diameter_SatCalculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType, FOsatDistanceRange );
                     if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density=0
                     then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density:=FCFfG_DensitySat_Calculation(
                        CurrentStar
                        ,Count
                        ,CountSat
                        ,FOsatDistanceRange
                        );
                     {....orbit distance adjustment w/ CalcFloat3: root radius and CalcFloat3: Roche limit}
                     CalcFloat2:=FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter * 0.5;
                     CalcFloat3:=2.456 * power( ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density / FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density ), 0.333 ) * CalcFloat2;
                     if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar * 1000 ) < CalcFloat3 then
                     begin
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar:=CalcFloat3 + ( ( FCFcF_Random_DoInteger( 31 ) + 1 ) * ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter * 0.5 ) );
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar:=FCFcF_Round( rttCustom1Decimal, ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar * 0.001 ) );
                     end;
                     {....geophysical data: mass, gravity and escape velocity}
                     if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass=0 then
                     begin
                        if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType=oobtAsteroid
                        then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass:=FCFfG_Mass_Calculation(
                           FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter
                           ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density
                           ,true
                           )
                        else FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass:=FCFfG_Mass_Calculation(
                           FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter
                           ,FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density
                           ,false
                           );
                     end;
                     if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_gravity=0
                     then  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_gravity:=FCFfG_Gravity_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass );
                     if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_escapeVelocity=0
                     then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_escapeVelocity:=FCFfG_EscapeVelocity_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass );
                     {....asteroids refinement}
                     if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType=oobtAsteroid
                     then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_type:=FCFfG_Refinement_Asteroid(
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density
                        ,BaseTemperature
                        ,true
                        );
                     {....geophysical data: gravitational sphere, magnetic field}
                     FCMfO_GravSphereOrbits_Calculation(
                        CurrentStar
                        ,Count
                        ,0
                        ,CountSat
                        );
                     if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_magneticField=0 )
                        and ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType > oobtAsteroid )
                     then FCMfG_MagneticField_Calculation(
                        CurrentStar
                        ,Count
                        ,CountSat
                        );
                     if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_tectonicActivity=taNull )
                        and ( ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType= oobtTelluricPlanet ) or ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType= oobtIcyPlanet ) )
                     then FCMfG_TectonicActivity_Calculation( CurrentStar, Count, CountSat )
                     else FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_tectonicActivity:=taDead;
                     if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_class < WD0 )
                        and ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_BasicType > oobtAsteroid )
                        and ( not FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_isAtmosphereEdited )
                     then FCMfA_Atmosphere_Processing(
                        CurrentStar
                        ,Count
                        ,BaseTemperature
                        ,CountSat
                        )
                     else if FCDduStarSystem[0].SS_stars[CurrentStar].S_class >= WD0 then
                     begin
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_fug_isAtmosphereEdited:=false;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphericPressure:=0;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_traceAtmosphere:=false;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_primaryGasVolumePerc:=0;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceHe:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCH4:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNH3:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2O:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNe:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceN2:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO2:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceH2S:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceAr:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceCO2:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceNO2:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceO3:=agsNotPresent;
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_atmosphere.AC_gasPresenceSO2:=agsNotPresent;
                     end;
                     FCMfS_OrbitalPeriods_Generate(
                        CurrentStar
                        ,Count
                        ,CountSat
                        );
                     FCMfR_GenerationPhase_Process(
                        CurrentStar
                        ,Count
                        ,CountSat
                        );
                     inc( CountSat );
                  end; //==END== while CountSat <= NumberOfSat ==//
               end //==END== if (FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod <> 0 ) and ( NumberOfSat > 0 ) ==//
               else setlength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList, 0 );
            end; //==END== else of: if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType=oobtAsteroidBelt ==//
         end; //==END== else: if ( CalcFloat>0 ) and ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar > CalcFloat ) ==//
         inc( Count);
      end; //==END== while Count<=NumberOfOrbits ==//
   end; //==END== else of if CalcFloat=0 ==//
end;

procedure FCMfO_GravSphereOrbits_Calculation(
   const Star
         ,OrbitalObject: integer;
   const Asteroid: integer=0;
   const Satellite: integer=0
   );
{:Purpose: calculate the gravitational sphere radius, the geosynchronous and the low orbits of an orbital object.
    Additions:
      -2013May20- *fix: for asteroids in a belt: select the correct distance to use for the calculation.
                  *add: satellites.
      -2013May16- *add: Asteroid parameter, for asteroids in a belt.
      -2013May05- *mod: function = > procedure.
                  *add: geosynchronous and low orbit calculations.
}
   var
      Calculation
      ,GravSphereCoef
      ,ObjectDiameter
      ,ObjectDistanceKm
      ,ObjectGravSphere
      ,ObjectMassKg
      ,ObjectRotationPeriod
      ,ObjectSynchOrbit
      ,StarMassKg: extended;
begin
   if ( Asteroid=0 )
      and ( Satellite=0 ) then
   begin
      ObjectDistanceKm:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar * FCCdiKm_In_1AU;
      ObjectMassKg:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_mass * FCCdiMassEqEarth;
      ObjectRotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod;
      ObjectDiameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_diameter;
      StarMassKg:=FCDduStarSystem[0].SS_stars[Star].S_mass * FCCdiMassEqSun;
   end
   else if ( Asteroid=0 )
      and ( Satellite>0 ) then
   begin
      ObjectDistanceKm:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar * 1000;
      ObjectMassKg:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_mass * FCCdiMassEqEarth;
      ObjectRotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_revolutionPeriod * 24;
      ObjectDiameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_diameter;
      StarMassKg:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_mass * FCCdiMassEqEarth;
   end
   {.for asteroids in a belt}
   else begin
      ObjectDistanceKm:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar * FCCdiKm_In_1AU;
      ObjectMassKg:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_mass * FCCdiMassEqEarth;
      ObjectRotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_isAsterBelt_rotationPeriod;
      ObjectDiameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_diameter;
      StarMassKg:=FCDduStarSystem[0].SS_stars[Star].S_mass * FCCdiMassEqSun;
   end;
   {.gravitational sphere radius}
   Calculation:=ObjectDistanceKm * power( ( ObjectMassKg /  StarMassKg ), 2 / 5 );
   if ( Asteroid=0 )
      and ( Satellite=0 ) then
   begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravitationalSphereRadius:=FCFcF_Round( rttCustom1Decimal, Calculation );
      ObjectGravSphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravitationalSphereRadius;
   end
   else if ( Asteroid=0 )
      and ( Satellite>0 ) then
   begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravitationalSphereRadius:=FCFcF_Round( rttCustom1Decimal, Calculation );
      ObjectGravSphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravitationalSphereRadius;
   end
   {..for asteroids in a belt}
   else begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_gravitationalSphereRadius:=FCFcF_Round( rttCustom1Decimal, Calculation );
      ObjectGravSphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_gravitationalSphereRadius;
   end;
   {.geosynchronous orbit}
   Calculation:=( power( ( FCCdiGravitationalConst * ObjectMassKg * power(  ObjectRotationPeriod * 3600, 2 ) ) / ( 4 * power( Pi, 2 ) ) ,0.333 ) ) / 1000;
   if ( Asteroid=0 )
      and ( Satellite=0 ) then
   begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_geosynchOrbit:=FCFcF_Round( rttCustom1Decimal, Calculation );
      ObjectSynchOrbit:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_geosynchOrbit;
   end
   else if ( Asteroid=0 )
      and ( Satellite>0 ) then
   begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_geosynchOrbit:=FCFcF_Round( rttCustom1Decimal, Calculation );
      ObjectSynchOrbit:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_geosynchOrbit;
   end
   {..for asteroids in a belt}
   else begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_geosynchOrbit:=FCFcF_Round( rttCustom1Decimal, Calculation );
      ObjectSynchOrbit:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_geosynchOrbit;
   end;
   {.low orbit}
   GravSphereCoef:=10 - ( ObjectGravSphere / 100000 );
   if GravSphereCoef < 1
   then GravSphereCoef:=1;
   Calculation:=( ( power(  ObjectSynchOrbit  , 0.333  ) * 14.5 ) + ( ObjectDiameter * 0.5 ) ) * GravSphereCoef;
   if ( Asteroid=0 )
      and ( Satellite=0 )
   then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_lowOrbit:=FCFcF_Round( rttCustom1Decimal, Calculation )
   else if ( Asteroid=0 )
      and ( Satellite>0 )
   then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_lowOrbit:=FCFcF_Round( rttCustom1Decimal, Calculation )
   else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Asteroid].OO_lowOrbit:=FCFcF_Round( rttCustom1Decimal, Calculation );
end;

end.
