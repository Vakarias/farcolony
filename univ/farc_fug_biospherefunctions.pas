{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: biosphere - common functions/ unit

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
unit farc_fug_biospherefunctions;

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
///   calculate the hydrosphere modifier
///</summary>
///    <param name="HydroArea">hydrosphere area</param>
///   <returns>hydrosphere modifier</returns>
///   <remarks></remarks>
function FCFfbF_HydrosphereModifier_Calculate( const HydroArea: integer ): integer;

///<summary>
///   calculate the star luminosity factor
///</summary>
///   <param name="DistanceFromStar">distance from the central star in AU</param>
///   <param name="StarLuminosity">star's luminosity</param>
///   <param name="Albedo">albedo</param>
///   <param name="CloudsCover">clouds cover</param>
///   <returns>star luminosity factor</returns>
///   <remarks>value not formatted</remarks>
function FCFfbF_StarLuminosityFactor_Calculate(
   const DistanceFromStar
         ,StarLuminosity
         ,Albedo
         ,CloudsCover: extended
   ): extended;

///<summary>
///   calculate the star luminosity vigor modifier
///</summary>
///   <param name="StarLuminosityFactor">star luminosity factor</param>
///   <returns>luminosity vigor modifier</returns>
///   <remarks></remarks>
function FCFfbF_StarLuminosityVigorMod_Calculate( const StarLuminosityFactor: extended ): integer;

///<summary>
///   provide the star modifier in it's phase 1
///</summary>
///   <param name="StarType">type of star</param>
///   <returns>vigor modifier</returns>
///   <remarks></remarks>
function FCFfbF_StarModifier_Phase1( const StarType: TFCEduStarClasses ): integer;

///<summary>
///   provide the star modifier in it's phase 2
///</summary>
///   <param name="StarType">type of star</param>
///   <returns>vigor modifier</returns>
///   <remarks></remarks>
function FCFfbF_StarModifier_Phase2( const StarType: TFCEduStarClasses ): integer;

///<summary>
///   calculate the surface temperatures modifier
///</summary>
///    <param name="TemperatureFactor">temperature factor</param>
///    <param name="Star">star index #</param>
///    <param name="OrbitalObject">orbital object index #</param>
///    <param name="Satellite">[optional] satellite index</param>
///   <returns>surface temperatures modifier</returns>
///   <remarks></remarks>
function FCFfbF_SurfaceTemperaturesModifier_Calculate(
   const TemperatureFactor: extended;
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   ): integer;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_univ_func;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFfbF_HydrosphereModifier_Calculate( const HydroArea: integer ): integer;
{:Purpose: calculate the hydrosphere modifier.
    Additions:
}
   var
      Calc1
      ,Calc2: extended;
begin
   Result:=0;
   Calc1:=logn( HydroArea * 0.1, 10 );
   Calc2:=power( Calc1, 2 ) * 30;
   Result:=round( Calc2 );
end;

function FCFfbF_StarLuminosityFactor_Calculate(
   const DistanceFromStar
         ,StarLuminosity
         ,Albedo
         ,CloudsCover: extended
   ): extended;
{:Purpose: calculate the star luminosity factor.
    Additions:
}
   var
      Calculations
      ,DistMod
      ,LumMod
      ,CloudsMod: extended;
begin
   Result:=0;
   DistMod:=1 / sqr( DistanceFromStar );
   LumMod:=StarLuminosity * 1353;
   CloudsMod:=CloudsCover * 0.005;
   Calculations:=DistMod * ( LumMod / ( 1 + Albedo + CloudsMod ) );
   Result:=Calculations;
end;

function FCFfbF_StarLuminosityVigorMod_Calculate( const StarLuminosityFactor: extended ): integer;
{:Purpose: calculate the star luminosity vigor modifier.
    Additions:
}
   var
      fCalc1
      ,fCalc2
      ,Modifier: extended;
begin
   Result:=0;
   fCalc1:=logn( StarLuminosityFactor, 956 );
   fCalc2:=power( fCalc1, 5 );
   Modifier:=( fCalc2 - ( 1 / fCalc2 ) ) * 20;
   Result:=round( Modifier );
end;

function FCFfbF_StarModifier_Phase1( const StarType: TFCEduStarClasses ): integer;
{:Purpose: provide the star modifier in it's phase 1.
    Additions:
}
begin
   Result:=0;
   case StarType of
      cB5..cB9: Result:=83;

      cA0..cA9: Result:=73;

      cK0..cK9: Result:=60;

      cM0..cM5: Result:=48;

      gF0..gF9: Result:=43;

      gG0..gG9: Result:=35;

      gK0..gK9: Result:=30;

      gM0..gM5: Result:=23;

      O5..O9: Result:=25;

      B0..B9: Result:=23;

      A0..A9: Result:=18;

      F0..F9: Result:=15;

      G0..G9: Result:=10;

      K0..K9: Result:=8;

      M0..M9: Result:=5;

      WD0..BH: Result:=100;
   end;
end;

function FCFfbF_StarModifier_Phase2( const StarType: TFCEduStarClasses ): integer;
{:Purpose: provide the star modifier in it's phase 2.
    Additions:
}
begin
   Result:=0;
   case StarType of
      cB5..cB9: Result:=105;

      cA0..cA9: Result:=85;

      cK0..cK9: Result:=65;

      cM0..cM5: Result:=45;

      gF0..gF9: Result:=45;

      gG0..gG9: Result:=35;

      gK0..gK9: Result:=25;

      gM0..gM5: Result:=15;

      O5..O9: Result:=30;

      B0..B9: Result:=25;

      A0..A9: Result:=20;

      F0..F9: Result:=15;

      G0..G9: Result:=10;

      K0..K9: Result:=5;

      M0..M9: Result:=5;

      WD0..BH: Result:=130;
   end;
end;

function FCFfbF_SurfaceTemperaturesModifier_Calculate(
   const TemperatureFactor: extended;
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   ): integer;
{:Purpose: calculate the surface temperatures modifier.
    Additions:
}
   var
      Calc1
      ,Calc2
      ,Calc3
      ,MeanSurfaceTemperature: extended;
begin
   Result:=0;
   MeanSurfaceTemperature:=FCFuF_OrbitalPeriods_GetMeanSurfaceTemperature(
      0
      ,Star
      ,OrbitalObject
      ,Satellite
      );
   Calc1:=logn( MeanSurfaceTemperature, TemperatureFactor );
   Calc2:=power( Calc1, 5 );
   Calc3:=Calc2 * ( Calc2 * 50 );
   Result:=round( Calc3 );
end;

//===========================END FUNCTIONS SECTION==========================================

end.
