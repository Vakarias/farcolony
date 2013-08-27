{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - environment unit

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
unit farc_fug_environments;

interface

//uses

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   process the habitability indexes of a given orbital object
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfE_HabitabilityIndexes_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

implementation

uses
   farc_data_univ;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfE_HabitabilityIndexes_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process the habitability indexes of a given orbital object.
   Additions:
}
   var
      AtmPress
      ,Gravity: extended;

      IndexGravity
      ,IndexRadiations
      ,IndexAtmosphere
      ,IndexAtmPressure: TFCEduHabitabilityIndex;
begin
   AtmPress:=0;
   Gravity:=0;

   IndexGravity:=higNone;
   IndexRadiations:=higNone;
   IndexAtmosphere:=higNone;
   IndexAtmPressure:=higNone;

   if Satellite <= 0 then
   begin
      AtmPress:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure;
      Gravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_Gravity;
   end
   else begin
      AtmPress:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure;
      Gravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_Gravity;
   end;
   {.gravity index}
   if Gravity = 0
   then IndexGravity:=higHostile_n
   else if ( Gravity > 0 )
      and ( Gravity < 0.2 )
   then IndexGravity:=higBad_n
   else if ( Gravity >= 0.2 )
      and ( Gravity < 0.5 )
   then IndexGravity:=higMediocre_n
   else if ( Gravity >= 0.5 )
      and ( Gravity < 0.8 )
   then IndexGravity:=higAcceptable
   else if ( Gravity >= 0.8 )
      and ( Gravity < 1.1 )
   then IndexGravity:=higIdeal
   else if ( Gravity >= 1.1 )
      and ( Gravity < 1.3 )
   then IndexGravity:=higMediocre_p
   else if ( Gravity >= 1.3 )
      and ( Gravity < 1.5 )
   then IndexGravity:=higBad_p
   else if Gravity >= 1.5
   then IndexGravity:=higHostile_p;
   {.radiations level index}
   if ( FCDduStarSystem[0].SS_stars[Star].S_class in[cB5..cB9] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[B0..B9] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[WD0..WD9] ) then
   begin

   end
   else if ( FCDduStarSystem[0].SS_stars[Star].S_class in[cA0..cA9] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[A0..A9] ) then
   begin

   end
   else if ( FCDduStarSystem[0].SS_stars[Star].S_class in[cK0..cK9] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[gK0..gK9] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[K0..K9] ) then
   begin

   end
   else if ( FCDduStarSystem[0].SS_stars[Star].S_class in[cM0..cM5] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[gM0..gM5] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[M0..M9] ) then
   begin

   end
   else if ( FCDduStarSystem[0].SS_stars[Star].S_class in[gF0..gF9] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[F0..F9] ) then
   begin

   end
   else if FCDduStarSystem[0].SS_stars[Star].S_class in[gG0..gG9] then
   begin

   end
   else if FCDduStarSystem[0].SS_stars[Star].S_class in[O5..O9] then
   begin

   end
   else if FCDduStarSystem[0].SS_stars[Star].S_class in[G0..G9] then
   begin

   end
   else if FCDduStarSystem[0].SS_stars[Star].S_class in[PSR..BH] then
   begin

   end;
end;

end.
