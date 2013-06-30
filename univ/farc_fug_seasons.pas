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
///   generate the seasons and their base effects
///</summary>
/// <param name="Star">star's index #</param>
/// <param name="OrbitalObject">orbital object's index #</param>
/// <param name="Satellite">optional parameter, only for any satellite</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfS_Seasons_Generate(
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

procedure FCMfS_Seasons_Generate(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: generate the seasons and their base effects
   Additions:
}
   var
      RevolutionPeriodPart: integer;

      OrbitalPeriodsWork: array[0..4] of TFCRduOObSeason;
begin
   OrbitalPeriodsWork[1]:=OrbitalPeriodsWork[0];
   OrbitalPeriodsWork[2]:=OrbitalPeriodsWork[0];
   OrbitalPeriodsWork[3]:=OrbitalPeriodsWork[0];
   OrbitalPeriodsWork[4]:=OrbitalPeriodsWork[0];
   {.in the case of a satellite, revolution period is taken from its central orbital object}
   RevolutionPeriodPart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_revolutionPeriod div 4;
   if Satellite=0 then
   begin

   end
   else begin
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type=ootAsteroidsBelt then
      begin
//         OrbitalPeriodsWork[1].OOS_orbitalPeriodType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[1].OOS_orbitalPeriodType;
//         OrbitalPeriodsWork[1].OOS_dayStart:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[1].OOS_dayStart;
//         OrbitalPeriodsWork[1].OOS_dayEnd:=;
//
//         OrbitalPeriodsWork[2].OOS_orbitalPeriodType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[2].OOS_orbitalPeriodType;
//         OrbitalPeriodsWork[2].OOS_dayStart:=;
//         OrbitalPeriodsWork[2].OOS_dayEnd:=;
//
//         OrbitalPeriodsWork[3].OOS_orbitalPeriodType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[3].OOS_orbitalPeriodType;
//         OrbitalPeriodsWork[3].OOS_dayStart:=;
//         OrbitalPeriodsWork[3].OOS_dayEnd:=;
//
//         OrbitalPeriodsWork[4].OOS_orbitalPeriodType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[4].OOS_orbitalPeriodType;
//         OrbitalPeriodsWork[4].OOS_dayStart:=;
//         OrbitalPeriodsWork[4].OOS_dayEnd:=
      end;
   end;
   OrbitalPeriodsWork[1].OOS_dayStart:=1;
   OrbitalPeriodsWork[1].OOS_dayEnd:=RevolutionPeriodPart;
   OrbitalPeriodsWork[2].OOS_dayStart:=OrbitalPeriodsWork[1].OOS_dayEnd + 1;
   OrbitalPeriodsWork[2].OOS_dayEnd:=OrbitalPeriodsWork[2].OOS_dayStart + RevolutionPeriodPart - 1;
   OrbitalPeriodsWork[3].OOS_dayStart:=OrbitalPeriodsWork[2].OOS_dayEnd + 1;
   OrbitalPeriodsWork[3].OOS_dayEnd:=OrbitalPeriodsWork[3].OOS_dayStart + RevolutionPeriodPart - 1;
   OrbitalPeriodsWork[4].OOS_dayStart:=OrbitalPeriodsWork[3].OOS_dayEnd + 1;
   OrbitalPeriodsWork[4].OOS_dayEnd:=OrbitalPeriodsWork[4].OOS_dayStart + RevolutionPeriodPart - 1;
end;

end.
