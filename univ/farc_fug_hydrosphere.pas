{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - hydrosphere unit

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
unit farc_fug_hydrosphere;

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

implementation

uses
   farc_common_func
   ,farc_data_univ;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfH_Hydrosphere_Processing(
   const Star
         ,OrbitalObject: integer;
   const BaseTemperature: extended;
   const Satellite: integer=0
   );
{:Purpose: main rule for the process of the hydrosphere.
   Additions:
}
   var
      GeneratedProbability: integer;

      AtmosphericPressure
      ,Distance20
      ,Distance30
      ,DistanceZone: extended;

      HydrosphereType: TFCEduHydrospheres;
begin
   AtmosphericPressure:=0;
   Distance20:=0;
   Distance30:=0;
   DistanceZone:=0;
   HydrosphereType:=hNoH2O;
   if Satellite=0 then
   begin
      AtmosphericPressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure;
   end
   else begin
      AtmosphericPressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure;
   end;
   {.hydrosphere for atmosphereless planets}
   if AtmosphericPressure=0 then
   begin
      DistanceZone:=sqrt( FCDduStarSystem[0].SS_stars[Star].S_luminosity / 0.53 );
      Distance20:=DistanceZone * 20;
      Distance30:=DistanceZone * 30;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar <= Distance20 then
      begin
//         if BaseTemperature <= 110
//         then HydrosphereType:=water ice crust
//         else if ( BaseTemperature > 110 )
//            and ( BaseTemperature <= 245)
//         then HydrosphereType:=water ice sheet
//         else Hydrosphere:=none;
         {.WARNING: UPDATE HYDRO TYPES! + NONE AS FIRST!}
      end
      else if ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar > Distance20 )
         and ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar <= Distance30 ) then
      begin
         GeneratedProbability:=FCFcF_Random_DoInteger( 99 ) + 1;
      end
   end
   {.hydrosphere for planets with atmosphere}
   else begin
   end;
end;

end.
