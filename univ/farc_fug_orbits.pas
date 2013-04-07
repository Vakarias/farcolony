{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - orbits generation unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2012, Jean-Francois Baconnet

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

   ,farc_data_univ
   ,farc_fug_data;

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
function FCFfS_OrbitGen_Balanced( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEfdOrbitalObjectBasicTypes;

///<summary>
///   generate the basic type of orbital object given the star's class, for a Sol-Like distribution system
///</summary>
///   <param name="StarClass">star class</param>
///   <param name="Zone">orbital zone</param>
///   <return>the default orbital object that must be generated</return>
function FCFfS_OrbitGen_SolLike( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEfdOrbitalObjectBasicTypes;

///<summary>
///   generate the basic type of orbital object given the star's class, for a ExtraSol-Like distribution system
///</summary>
///   <param name="StarClass">star class</param>
///   <param name="Zone">orbital zone</param>
///   <return>the default orbital object that must be generated</return>
function FCFfS_OrbitGen_ExtraSolLike( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEfdOrbitalObjectBasicTypes;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   core routine for orbits generation
///   <param="FOGstar">star index #</param>
///</summary>
procedure FCMfO_Generate(const FOGstar: integer);

implementation

uses
   farc_common_func;

//===================================================END OF INIT============================

function FCFfS_OrbitalZone_Determining( const OrbitDistance, StarLuminosity: extended ): TFCEduHabitableZones;
{:Purpose: calculate the orbital zone in which the orbit is located.
    Additions:
}
begin
   Result:=hzInner;
   if OrbitDistance < sqrt( StarLuminosity / 1.1 ) then Result:=hzInner
   else if OrbitDistance>sqrt( StarLuminosity / 0.53 ) then Result:=hzOuter
   else Result:=hzIntermediary;
end;

function FCFfS_OrbitGen_Balanced( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEfdOrbitalObjectBasicTypes;
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

function FCFfS_OrbitGen_ExtraSolLike( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEfdOrbitalObjectBasicTypes;
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

function FCFfS_OrbitGen_SolLike( const StarClass: TFCEduStarClasses; const Zone: TFCEduHabitableZones ): TFCEfdOrbitalObjectBasicTypes;
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

procedure FCMfO_Generate(const FOGstar: integer);
{:Purpose: core routine for orbits generation.
    Additions:
}
var
   Count
   ,NumberOfOrbits
   ,GeneratedProbability
   ,OrbitProbabilityMax
   ,OrbitProbabilitMin: integer;

   CalcFloat
   ,CalcFloat1: extended;

   isPassedBinaryTrinaryTest: boolean;

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
   if FCRfdStarOrbits[FOGstar]=0 then
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
         case FCDduStarSystem[0].SS_stars[FOGstar].S_class of
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
            SetLength(FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects, NumberOfOrbits+1);
         end;
      end; //==END== if FOGisPassedBiTri ==//
   end //==END== if FUGstarOrb[FOGstar]=0 ==//
   else if FCRfdStarOrbits[FOGstar]>0 then
   begin
      NumberOfOrbits:=FCRfdStarOrbits[FOGstar];
      SetLength(FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects, NumberOfOrbits+1);
   end;
   {.orbit distances}
   {.CalcFloat=maximum allowed orbit distance (MAOD)}
   CalcFloat:=0;
   {.for a single star}
   if ( FOGstar=1 )
      and ( FCDduStarSystem[0].SS_stars[2].S_token='' )
   then CalcFloat:=400 * FCDduStarSystem[0].SS_stars[FOGstar].S_mass
   {.for a binary system}
   else if ( ( FOGstar=1 ) and ( FCDduStarSystem[0].SS_stars[2].S_token<>'' ) and ( FCDduStarSystem[0].SS_stars[3].S_token='' ) )
      or ( ( FOGstar=2 ) and ( FCDduStarSystem[0].SS_stars[3].S_token='' ) )
   then CalcFloat:=FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance * 0.5
   {.for a trinary system - main star}
   else if FOGstar=1 then
   begin
      case FCDduStarSystem[0].SS_stars[3].S_isCompStar2OrbitType of
         cotAroundMain_Companion1: CalcFloat:=FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance * 0.5;

         cotAroundCompanion1: CalcFloat:=min( FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance, FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance ) * 0.5;

         cotAroundMain_Companion1GravityCenter: CalcFloat:=( FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance - FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance ) * 0.5;
      end;
   end
   else if FOGstar=2 then
   begin
      case FCDduStarSystem[0].SS_stars[3].S_isCompStar2OrbitType of
         cotAroundMain_Companion1: CalcFloat:=( FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance - FCDduStarSystem[0].SS_stars[3].S_isCompMeanSeparation ) * 0.5;

         cotAroundCompanion1: CalcFloat:=( FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance - FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance ) * 0.5;

         cotAroundMain_Companion1GravityCenter: CalcFloat:=( FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance - FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance ) * 0.5;
      end;
   end
   else if FOGstar=3 then
   begin
      case FCDduStarSystem[0].SS_stars[3].S_isCompStar2OrbitType of
         cotAroundMain_Companion1, cotAroundCompanion1: CalcFloat:=FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance * 0.5;

         cotAroundMain_Companion1GravityCenter: CalcFloat:=( FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance - FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance ) * 0.5;
      end;
   end;
   CalcFloat:=FCFcF_Round( rttCustom2Decimal, CalcFloat );
   if CalcFloat<=0
   then SetLength( FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects, 1 )
   {.orbit generation}
   else begin
      {.CalcFloat=maximum allowed orbit distance (MAOD)}
      {.CalcFloat1: current orbit's distance}
      Count:=1;
      while Count<=NumberOfOrbits do
      begin
         FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects[Count].OO_isSatellite:=false;
         if Count=1 then
         begin
            CalcFloat1:=( FCDduStarSystem[0].SS_stars[FOGstar].S_diameter * 0.5 ) * 0.004645787 * SQRT( FCDduStarSystem[0].SS_stars[FOGstar].S_temperature ) * ( 1 + ( FCFcF_Random_DoInteger( 10 ) * 0.02 ) );
         end
         else begin
            GeneratedProbability:=FCFcF_Random_DoInteger( 8 ) + 1;
            CalcFloat1:=CalcFloat1 * ( 1.2 + ( GeneratedProbability * 0.1 ) );
         end;
         FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar:=FCFcF_Round( rttCustom2Decimal, CalcFloat1 );
         if FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar > CalcFloat then
         begin
            SetLength( FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects, Count );
            break;
         end
         {.continue the orbit generation}
         else begin
            {:DEV NOTES: ecc + zones + end of build.}
            if FCDduStarSystem[0].SS_stars[FOGstar].S_class=BH
            then FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone:=hzOuter
            else FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects[Count].OO_isNotSat_orbitalZone:=FCFfS_OrbitalZone_Determining( FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects[Count].OO_isNotSat_distanceFromStar, FCDduStarSystem[0].SS_stars[FOGstar].S_luminosity );
            {:DEV NOTES: generate orb obj type.}
            
         end;
         inc( Count);
      end;
   end;
end;

end.
