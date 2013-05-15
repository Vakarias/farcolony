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
///   <returns></returns>
///   <remarks>format [x.x]</remarks>
procedure FCMfO_GravSphereOrbits_Calculation( const Star, OrbitalObject: integer );

implementation

uses
   farc_common_func
   ,farc_data_init
   ,farc_data_3dopengl
   ,farc_fug_data
   ,farc_fug_geophysical
   ,farc_fug_stars
   ,farc_win_fug;

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

//===========================END FUNCTIONS SECTION==========================================

procedure FCMfO_Generate(const CurrentStar: integer);
{:Purpose: core routine for orbits generation.
    Additions:
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

   BaseTemperature
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
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType:=FCDfdMainStarObjectsList[Count].OO_basicType;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar:=FCDfdMainStarObjectsList[Count].OO_isNotSat_distanceFromStar;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter:=FCDfdMainStarObjectsList[Count].OO_diameter;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density:=FCDfdMainStarObjectsList[Count].OO_density;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass:=FCDfdMainStarObjectsList[Count].OO_mass;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity:=FCDfdMainStarObjectsList[Count].OO_gravity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity:=FCDfdMainStarObjectsList[Count].OO_escapeVelocity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod:=FCDfdMainStarObjectsList[Count].OO_isNotSat_rotationPeriod;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_inclinationAxis:=FCDfdMainStarObjectsList[Count].OO_isNotSat_inclinationAxis;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_magneticField:=FCDfdMainStarObjectsList[Count].OO_magneticField;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_tectonicActivity:=FCDfdMainStarObjectsList[Count].OO_tectonicActivity;
               NumberOfSat:=length( FCDfdMainStarObjectsList[Count].OO_satellitesList ) - 1;
               if NumberOfSat>0
               then setlength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList, NumberOfSat + 1 );
               CountSat:=1;
               while CountSat<=NumberOfSat do
               begin
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_dbTokenId;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSatellite:=true;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_basicType:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_basicType;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanet:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanet;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_diameter;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_density;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_mass;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_gravity:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_gravity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_escapeVelocity:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_escapeVelocity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_magneticField:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_magneticField;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_tectonicActivity:=FCDfdMainStarObjectsList[Count].OO_satellitesList[CountSat].OO_tectonicActivity;
                  inc( CountSat );
               end;

//               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_albedo:=FCDfdMainStarObjectsList[Count].OO_albedo;
            end;

            2:
            begin
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_dbTokenId:=FCDfdComp1StarObjectsList[Count].OO_dbTokenId;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isSatellite:=false;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType:=FCDfdComp1StarObjectsList[Count].OO_basicType;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar:=FCDfdComp1StarObjectsList[Count].OO_isNotSat_distanceFromStar;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter:=FCDfdComp1StarObjectsList[Count].OO_diameter;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density:=FCDfdComp1StarObjectsList[Count].OO_density;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass:=FCDfdComp1StarObjectsList[Count].OO_mass;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity:=FCDfdComp1StarObjectsList[Count].OO_gravity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity:=FCDfdComp1StarObjectsList[Count].OO_escapeVelocity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod:=FCDfdComp1StarObjectsList[Count].OO_isNotSat_rotationPeriod;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_inclinationAxis:=FCDfdComp1StarObjectsList[Count].OO_isNotSat_inclinationAxis;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_magneticField:=FCDfdComp1StarObjectsList[Count].OO_magneticField;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_tectonicActivity:=FCDfdComp1StarObjectsList[Count].OO_tectonicActivity;
               NumberOfSat:=length( FCDfdComp1StarObjectsList[Count].OO_satellitesList ) - 1;
               if NumberOfSat>0
               then setlength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList, NumberOfSat + 1 );
               CountSat:=1;
               while CountSat<=NumberOfSat do
               begin
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_dbTokenId;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSatellite:=true;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_basicType:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_basicType;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanet:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanet;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_diameter;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_density;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_mass;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_gravity:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_gravity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_escapeVelocity:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_escapeVelocity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_magneticField:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_magneticField;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_tectonicActivity:=FCDfdComp1StarObjectsList[Count].OO_satellitesList[CountSat].OO_tectonicActivity;
                  inc( CountSat );
               end;

//               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_albedo:=FCDfdComp1StarObjectsList[Count].OO_albedo;
            end;

            3:
            begin
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_dbTokenId:=FCDfdComp2StarObjectsList[Count].OO_dbTokenId;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isSatellite:=false;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType:=FCDfdComp2StarObjectsList[Count].OO_basicType;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar:=FCDfdComp2StarObjectsList[Count].OO_isNotSat_distanceFromStar;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter:=FCDfdComp2StarObjectsList[Count].OO_diameter;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density:=FCDfdComp2StarObjectsList[Count].OO_density;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass:=FCDfdComp2StarObjectsList[Count].OO_mass;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity:=FCDfdComp2StarObjectsList[Count].OO_gravity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity:=FCDfdComp2StarObjectsList[Count].OO_escapeVelocity;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod:=FCDfdComp2StarObjectsList[Count].OO_isNotSat_rotationPeriod;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_inclinationAxis:=FCDfdComp2StarObjectsList[Count].OO_isNotSat_inclinationAxis;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_magneticField:=FCDfdComp2StarObjectsList[Count].OO_magneticField;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_tectonicActivity:=FCDfdComp2StarObjectsList[Count].OO_tectonicActivity;
               NumberOfSat:=length( FCDfdComp2StarObjectsList[Count].OO_satellitesList ) - 1;
               if NumberOfSat>0
               then setlength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList, NumberOfSat + 1 );
               CountSat:=1;
               while CountSat<=NumberOfSat do
               begin
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_dbTokenId;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSatellite:=true;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_basicType:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_basicType;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanet:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_isSat_distanceFromPlanet;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_diameter:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_diameter;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_density:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_density;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_mass:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_mass;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_gravity:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_gravity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_escapeVelocity:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_escapeVelocity;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_magneticField:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_magneticField;
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_tectonicActivity:=FCDfdComp2StarObjectsList[Count].OO_satellitesList[CountSat].OO_tectonicActivity;
                  inc( CountSat );
               end;

//               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_albedo:=FCDfdComp2StarObjectsList[Count].OO_albedo;
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
               GeneratedProbability:=FCFcF_Random_DoInteger( 9 ) + 1;
               CalcFloat1:=( CalcFloat1 * ( 1.1 + ( GeneratedProbability * 0.1 ) ) ) + 0.1;
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
            BaseTemperature:=255 / sqrt( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar / sqrt( FCDduStarSystem[0].SS_stars[CurrentStar].S_luminosity ) );
            BaseTemperature:=FCFcF_Round( rttCustom2Decimal, BaseTemperature );
            if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType=oobtNone then
            begin
               case FCRfdSystemType[CurrentStar] of
                  1: FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType:=FCFfS_OrbitGen_SolLike( FCDduStarSystem[0].SS_stars[CurrentStar].S_class, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone );

                  2: FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType:=FCFfS_OrbitGen_Balanced( FCDduStarSystem[0].SS_stars[CurrentStar].S_class, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone );

                  3: FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType:=FCFfS_OrbitGen_ExtraSolLike( FCDduStarSystem[0].SS_stars[CurrentStar].S_class, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone );
               end;
            end;
            if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType=oobtTelluricPlanet )
               and ( BaseTemperature < 140 )
            then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType:=oobtIcyPlanet;
            {..for asteroids belt}
            if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType=oobtAsteroidBelt then
            begin
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_type:=ootAsteroidsBelt;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter:=FCFfG_AsteroidsBelt_CalculateDiameter( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar );
               CalcFloat1:=CalcFloat1 + ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter * 0.5 );
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar:=FCFcF_Round( rttCustom2Decimal, CalcFloat1 );
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravitationalSphereRadius:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_geosynchOrbit:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_lowOrbit:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_inclinationAxis:=0;
               FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_magneticField:=0;
               {...satellites phase I - basics + orbital + geophysical data}
               NumberOfSat:=length( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList ) - 1;
               if NumberOfSat<=0 then
               begin
                  CalcFloat2:=FCFcF_Scale_Conversion( cAU_to3dViewUnits, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar );
                  CalcFloat3:=sqrt( 2 * FCCdiPiDouble * CalcFloat2 ) / ( 4.52 * FC3doglCoefViewReduction );
                  NumberOfSat:=round( CalcFloat3 );
                  setlength( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList, NumberOfSat + 1 );
                  CountSat:=1;
                  while CountSat <= NumberOfSat do
                  begin
                     if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId='' )
                        or ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId='sat' ) then
                     begin
                        Token:=FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_dbTokenId;
                        delete( Token, 1, 6 );
                        FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_dbTokenId:='sat' + Token + inttostr( Count );
                        CalcFloat2:=FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar - ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter * 0.5 );
                     end;
                     FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_satellitesList[CountSat].OO_isSatellite:=true;
                     inc( CountSat );
                  end;
               end;
            end //==END== if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType=oobtAsteroidBelt then ==//
            {..for the rest of the basic types}
            else begin
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter=0
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter:=FCFfG_Diameter_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density=0
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density:=FCFfG_Density_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType=oobtAsteroid
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_type:=FCFfG_Refinement_Asteroid( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_density );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass=0 then
               begin
                  if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType=oobtAsteroid
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
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType=oobtGaseousPlanet
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_type:=FCFfG_Refinement_GaseousPlanet( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity=0
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_gravity:=FCFfG_Gravity_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity=0
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_escapeVelocity:=FCFfG_EscapeVelocity_Calculation( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_diameter, FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_mass );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod=0
               then FCMfG_RotationPeriod_Calculation( CurrentStar, Count );
               FCMfO_GravSphereOrbits_Calculation( CurrentStar , Count );
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_inclinationAxis=0
               then FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_inclinationAxis:=FCFfG_InclinationAxis_Calculation;
               if FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_inclinationAxis<0 then
               begin
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_inclinationAxis:=abs( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_inclinationAxis );
                  FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod:=-( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_rotationPeriod );
               end;
               if ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_magneticField=0 )
                  and ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_basicType > oobtAsteroid )
               then FCMfG_MagneticField_Calculation( CurrentStar, Count );
               {...satellites phase I - basics + orbital + geophysical data}
            end;

            {:DEV NOTES: geophysical data here.
                 //


                TectonicActivityDetermination

               .}



            {:DEV NOTES: ecosphere here


               AtmosphericDetermination;
                OrbitsCreation_Hydrosphere(TabOrbit[OrbDBCounter].BaseTemp);
                OrbitsCreation_Weather;
                                       .}

            {:DEV NOTES: orbital periods / seasons here.}



             {:DEV NOTES: look if tectonic needed below, if it is the case: generate sat (w/o surf generation and after geophysical, apply FCMfG_TectonicActivityDifferential_Calculation.}

            {:DEV NOTES: surface generation + regions here incl resources.}

            {:DEV NOTES: biosphere here + resources 2.}

            {:DEV NOTES: OOrb Obj type refinment here for telluric


                try
            if TabOrbit[OrbDBCounter].TypeAstre=10 then begin
                if TabOrbit[OrbDBCounter].AtmPress=0 then begin
                    if TabOrbit[OrbDBCounter].HydroType=0 then TabOrbit[OrbDBCounter].TypeAstre:=23
                    else if TabOrbit[OrbDBCounter].HydroType=3 then TabOrbit[OrbDBCounter].TypeAstre:=24
                    else if TabOrbit[OrbDBCounter].HydroType=4 then TabOrbit[OrbDBCounter].TypeAstre:=25;
                end
                else if (TabOrbit[OrbDBCounter].AtmPress>0) and (TabOrbit[OrbDBCounter].AtmPress<400) then begin
                    if TabOrbit[OrbDBCounter].HydroType in [0..1] then TabOrbit[OrbDBCounter].TypeAstre:=15
                    else if TabOrbit[OrbDBCounter].HydroType=2 then TabOrbit[OrbDBCounter].TypeAstre:=16
                    else if TabOrbit[OrbDBCounter].HydroType=3 then TabOrbit[OrbDBCounter].TypeAstre:=17
                    else if TabOrbit[OrbDBCounter].HydroType=4 then TabOrbit[OrbDBCounter].TypeAstre:=18
                    else if TabOrbit[OrbDBCounter].HydroType in [5..6] then TabOrbit[OrbDBCounter].TypeAstre:=17;
                end
                else if (TabOrbit[OrbDBCounter].AtmPress>=400) and (TabOrbit[OrbDBCounter].AtmPress<=3100) then begin
                    if TabOrbit[OrbDBCounter].HydroType in [0..1] then TabOrbit[OrbDBCounter].TypeAstre:=11
                    else if TabOrbit[OrbDBCounter].HydroType=2 then TabOrbit[OrbDBCounter].TypeAstre:=12
                    else if TabOrbit[OrbDBCounter].HydroType=3 then TabOrbit[OrbDBCounter].TypeAstre:=13
                    else if TabOrbit[OrbDBCounter].HydroType=4 then TabOrbit[OrbDBCounter].TypeAstre:=14
                    else if TabOrbit[OrbDBCounter].HydroType in [5..6] then TabOrbit[OrbDBCounter].TypeAstre:=12;
                end
                else if TabOrbit[OrbDBCounter].AtmPress>3100 then begin
                    if TabOrbit[OrbDBCounter].HydroType in [0..1] then TabOrbit[OrbDBCounter].TypeAstre:=19
                    else if TabOrbit[OrbDBCounter].HydroType=2 then TabOrbit[OrbDBCounter].TypeAstre:=20
                    else if TabOrbit[OrbDBCounter].HydroType=3 then TabOrbit[OrbDBCounter].TypeAstre:=21
                    else if TabOrbit[OrbDBCounter].HydroType=4 then TabOrbit[OrbDBCounter].TypeAstre:=22
                    else if TabOrbit[OrbDBCounter].HydroType in [5..6] then TabOrbit[OrbDBCounter].TypeAstre:=21;
                end;
            end
            else if TabOrbit[OrbDBCounter].TypeAstre=27 then begin
                if TabOrbit[OrbDBCounter].AtmPress=0 then TabOrbit[OrbDBCounter].TypeAstre:=30
                else if TabOrbit[OrbDBCounter].AtmPress>0 then begin
                    if TabOrbit[OrbDBCounter].HydroType=3 then TabOrbit[OrbDBCounter].TypeAstre:=28
                    else if TabOrbit[OrbDBCounter].HydroType=4 then TabOrbit[OrbDBCounter].TypeAstre:=29;
                end;
            end;

            .}

            {:DEV NOTES: satellites.}

            //FCMfG_TectonicActivityDifferential_Calculation: do that maybe before regions!

         end; //==END== else: if ( CalcFloat>0 ) and ( FCDduStarSystem[0].SS_stars[CurrentStar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar > CalcFloat ) ==//
         inc( Count);
      end; //==END== while Count<=NumberOfOrbits ==//
   end; //==END== else of if CalcFloat=0 ==//
end;

procedure FCMfO_GravSphereOrbits_Calculation( const Star, OrbitalObject: integer );
{:Purpose: calculate the gravitational sphere radius, the geosynchronous and the low orbits of an orbital object.
    Additions:
      -2013May05- *mod: function = > procedure.
                  *add: geosynchronous and low orbit calculations.
}
   var
      Calculation
      ,DistanceKm
      ,GravSphereCoef
      ,ObjectMassKg
      ,StarMassKg: extended;
begin
   ObjectMassKg:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_mass * FCCdiMassEqEarth;
   StarMassKg:=FCDduStarSystem[0].SS_stars[Star].S_mass * FCCdiMassEqSun;
   DistanceKm:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar * FCCdiKm_In_1AU;
   {.gravitational sphere radius}
   Calculation:=DistanceKm * power( ( ObjectMassKg /  StarMassKg ), 2 / 5 );
   FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravitationalSphereRadius:=FCFcF_Round( rttCustom1Decimal, Calculation );
   {.geosynchronous orbit}
   Calculation:=( power( ( FCCdiGravitationalConst * ObjectMassKg * power(  FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod * 3600, 2 ) ) / ( 4 * power( Pi, 2 ) ) ,0.333 ) ) / 1000;
   FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_geosynchOrbit:=FCFcF_Round( rttCustom1Decimal, Calculation );
   {.low orbit}
   GravSphereCoef:=10 - ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravitationalSphereRadius / 100000 );
   if GravSphereCoef < 1
   then GravSphereCoef:=1;
   Calculation:=( ( power(  FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_geosynchOrbit  , 0.333  ) * 14.5 ) + ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_diameter * 0.5 ) ) * GravSphereCoef;
   FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_lowOrbit:=FCFcF_Round( rttCustom1Decimal, Calculation );
end;

end.
