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
   ,farc_data_univ
   ,farc_fug_atmosphere;

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
      GeneratedProbability
      ,NumberOfPrimaryGasses
      ,PrimaryGasVolume: integer;

      AtmosphericPressure
      ,BoilingPoint
      ,Distance20
      ,Distance30
      ,DistanceZone
      ,IceCrustThreshold
      ,MeltingPoint
      ,VaporLimit: extended;

      HydrosphereType: TFCEduHydrospheres;

      AmmoniaStatus
      ,MethaneStatus
      ,NewMetaneStatus: TFCEduAtmosphericGasStatus;
begin
   AtmosphericPressure:=0;
   Distance20:=0;
   Distance30:=0;
   DistanceZone:=0;
   HydrosphereType:=hNoHydro;
   if Satellite=0 then
   begin
      AtmosphericPressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure / 1000;
      AmmoniaStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3;
      MethaneStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4;
      PrimaryGasVolume:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_primaryGasVolumePerc;
   end
   else begin
      AtmosphericPressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure / 1000;
      AmmoniaStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3;
      MethaneStatus:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4;
      PrimaryGasVolume:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_primaryGasVolumePerc;
   end;
   NewMetaneStatus:=MethaneStatus;
   {.hydrosphere for atmosphereless planets}
   if AtmosphericPressure=0 then
   begin
      DistanceZone:=sqrt( FCDduStarSystem[0].SS_stars[Star].S_luminosity / 0.53 );
      Distance20:=DistanceZone * 20;
      Distance30:=DistanceZone * 30;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar <= Distance20 then
      begin
         if BaseTemperature <= 110
         then HydrosphereType:=hWaterIceCrust
         else if ( BaseTemperature > 110 )
            and ( BaseTemperature <= 245)
         then HydrosphereType:=hWaterIceSheet
         else HydrosphereType:=hNoHydro;
      end
      else if ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar > Distance20 )
         and ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_distanceFromStar <= Distance30 ) then
      begin
         if BaseTemperature <= 110 then
         begin
            GeneratedProbability:=FCFcF_Random_DoInteger( 99 ) + 1;
            if GeneratedProbability<=70
            then HydrosphereType:=hWaterIceCrust
            else begin
               if BaseTemperature <= 63
               then HydrosphereType:=hNitrogenIceCrust
               else HydrosphereType:=hWaterIceCrust;
            end;
         end
         else if ( BaseTemperature > 110 )
            and ( BaseTemperature <= 245)
         then HydrosphereType:=hWaterIceSheet
         else HydrosphereType:=hNoHydro;
      end
      else begin
         if BaseTemperature <= 110 then
         begin
            GeneratedProbability:=FCFcF_Random_DoInteger( 99 ) + 1;
            case GeneratedProbability of
               1..20: HydrosphereType:=hWaterIceCrust;

               21..60:
               begin
                  if BaseTemperature <= 63
                  then HydrosphereType:=hNitrogenIceCrust
                  else HydrosphereType:=hWaterIceCrust;
               end;

               61..100:
               begin
                  if BaseTemperature <= 90
                  then HydrosphereType:=hMethaneIceCrust
                  else HydrosphereType:=hWaterIceCrust;
               end;
            end;

         end
         else if ( BaseTemperature > 110 )
            and ( BaseTemperature <= 245)
         then HydrosphereType:=hWaterIceSheet
         else HydrosphereType:=hNoHydro;
      end;
   end
   {.hydrosphere for planets with atmosphere}
   else begin
      NumberOfPrimaryGasses:=FCFfA_PrimaryGasses_GetTotalNumber(
         Star
         ,OrbitalObject
         ,Satellite
         );
      {.methane hydrosphere}
      if ( ( MethaneStatus = agsMain ) or ( ( MethaneStatus = agsSecondary ) and ( PrimaryGasVolume <= 85 ) ) )
         and ( BaseTemperature < 191 )
         and ( AtmosphericPressure < 46.598 ) then
      begin
         BoilingPoint:=1 / ( ( ln( sqrt( AtmosphericPressure ) ) / -592.5 ) + ( 1 / 109 ) );
         MeltingPoint:=1 / ( ( ln( sqrt( AtmosphericPressure ) ) / -592.5 ) + ( 1 / 90.7 ) );
         IceCrustThreshold:=MeltingPoint * 193 / 273.15;
         VaporLimit:=BoilingPoint * 500 / 373.15;
         if BaseTemperature <= IceCrustThreshold
         then HydrosphereType:=hMethaneIceCrust
         else if ( BaseTemperature > IceCrustThreshold )
            and ( BaseTemperature < MeltingPoint )
         then HydrosphereType:=hMethaneIceSheet
         else if ( BaseTemperature >= MeltingPoint )
            and ( BaseTemperature < BoilingPoint )
         then HydrosphereType:=hMethaneLiquid
         else if ( BaseTemperature >= BoilingPoint )
            and ( BaseTemperature <= VaporLimit )
         then HydrosphereType:=hNoHydro
         else if BaseTemperature > VaporLimit then
         begin
            HydrosphereType:=hNoHydro;
//            if ( ( MethaneStatus = agsMain ) and ( NumberOfPrimaryGasses > 1 ) )
//               or ( MethaneStatus = agsSecondary )
//            then NewMetaneStatus = agsTrace;
         end;
      end;
   end;
   if Satellite=0 then
   begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere:=HydrosphereType;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4:=NewMetaneStatus;
   end
   else begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere:=HydrosphereType;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4:=NewMetaneStatus;
   end;
end;

end.
