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
   Math;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

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

//===========================END FUNCTIONS SECTION==========================================

implementation

//uses

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

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

//===========================END FUNCTIONS SECTION==========================================

end.
