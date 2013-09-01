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
///   process the environment for the selected orbital object
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfE_Environment_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

///<summary>
///   process the environmental modifiers for each region
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfE_EnvironmentalModifiers_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

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

procedure FCMfE_Environment_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process the environment for the selected orbital object.
    Additions:
}
   var
      isO2AtLeastSecondary: boolean;

      IndexRadiations
      ,IndexAtmosphere
      ,IndexAtmPressure: TFCEduHabitabilityIndex;

      Environment: TFCEduEnvironmentTypes;
begin
   isO2AtLeastSecondary:=false;

   IndexRadiations:=higNone;
   IndexAtmosphere:=higNone;
   IndexAtmPressure:=higNone;

   Environment:=etAny;

   if Satellite <= 0 then
   begin
      IndexRadiations:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_habitabilityRadiations;
      IndexAtmosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_habitabilityAtmosphere;
      IndexAtmPressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_habitabilityAtmPressure;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceO2 > agsTrace
      then isO2AtLeastSecondary:=true;
   end
   else begin
      IndexRadiations:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_habitabilityRadiations;
      IndexAtmosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_habitabilityAtmosphere;
      IndexAtmPressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_habitabilityAtmPressure;
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceO2 > agsTrace
      then isO2AtLeastSecondary:=true;
   end;
   if ( ( IndexRadiations=higAcceptable ) or ( IndexRadiations=higIdeal ) )
      and ( isO2AtLeastSecondary )
      and ( ( IndexAtmosphere = higAcceptable ) or ( IndexAtmosphere = higIdeal ) )
      and ( ( IndexAtmPressure = higAcceptable_n ) or ( IndexAtmPressure = higIdeal ) or ( IndexAtmPressure = higAcceptable_p ) )
   then Environment:=etFreeLiving
   else if IndexAtmosphere = higNone
   then Environment:=etSpace
   else Environment:=etRestricted;
   if Satellite <= 0
   then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_environment:=Environment
   else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_environment:=Environment;
end;

procedure FCMfE_EnvironmentalModifiers_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process the environmental modifiers for each region.
    Additions:
      -2013Sep01- *mod: atmosphereless object put air survey modifier into 0.
}
   var
      Max
      ,Modifiers
      ,NO2SO2mod
      ,Region
      ,WindSpeed: integer;

      AtmospherePress
      ,EMO
      ,fCalc1: extended;

      IndexGravity
      ,IndexRadiations
      ,IndexAtmosphere
      ,IndexAtmPressure: TFCEduHabitabilityIndex;

      Climate: TFCEduRegionClimates;

      Land: TFCEduRegionSoilTypes;

      Relief: TFCEduRegionReliefs;

      function _WindMod( const Coef: extended ): integer;
         var
            fCalc
            ,fCalc1: extended;
      begin
         Result:=0;
         fCalc:=0;
         fCalc1:=0;
         if WindSpeed > 0 then
         begin
            fCalc:=sqrt( WindSpeed );
            fCalc1:=( round( fCalc ) * 5 ) * Coef;
            Result:=round( fCalc );
         end;
      end;
begin
   Max:=0;
   Modifiers:=0;
   NO2SO2mod:=0;
   Region:=0;

   AtmospherePress:=0;
   EMO:=0;
   fCalc1:=0;

   IndexGravity:=higNone;
   IndexRadiations:=higNone;
   IndexAtmosphere:=higNone;
   IndexAtmPressure:=higNone;

   if Satellite <= 0 then
   begin
      IndexGravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_habitabilityGravity;
      IndexRadiations:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_habitabilityRadiations;
      IndexAtmosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_habitabilityAtmosphere;
      IndexAtmPressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_habitabilityAtmPressure;
      AtmospherePress:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure;
      if AtmospherePress = 0
      then NO2SO2mod:=0
      else begin
         case FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2 of
            agsTrace: NO2SO2mod:=10;

            agsSecondary: NO2SO2mod:=30;

            agsMain: NO2SO2mod:=60
         end;
         case FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2 of
            agsTrace: NO2SO2mod:=NO2SO2mod + 10;

            agsSecondary: NO2SO2mod:=NO2SO2mod + 30;

            agsMain: NO2SO2mod:=NO2SO2mod + 60
         end;
      end;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions ) - 1;
   end
   else begin
      IndexGravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_habitabilityGravity;
      IndexRadiations:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_habitabilityRadiations;
      IndexAtmosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_habitabilityAtmosphere;
      IndexAtmPressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_habitabilityAtmPressure;
      AtmospherePress:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure;
      if AtmospherePress = 0
      then NO2SO2mod:=0
      else begin
         case FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2 of
            agsTrace: NO2SO2mod:=10;

            agsSecondary: NO2SO2mod:=30;

            agsMain: NO2SO2mod:=60
         end;
         case FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2 of
            agsTrace: NO2SO2mod:=NO2SO2mod + 10;

            agsSecondary: NO2SO2mod:=NO2SO2mod + 30;

            agsMain: NO2SO2mod:=NO2SO2mod + 60
         end;
      end;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions ) - 1;
   end;
   NO2SO2mod:=NO2SO2mod shr 1;
   Region:=1;
   while Region <= Max do
   begin
      Climate:=rc00VoidNoUse;
      Land:=rst01RockyDesert;
      Relief:=rr1Plain;
      WindSpeed:=0;
      if Satellite <= 0 then
      begin
         Climate:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_climate;
         Land:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_landType;
         Relief:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_relief;
         WindSpeed:=(
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_seasonClosest.OP_windspeed
               +FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_seasonIntermediate.OP_windspeed
               +FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_seasonFarthest.OP_windspeed
            ) div 3;
      end
      else begin
         Climate:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_climate;
         Land:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_landType;
         Relief:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_relief;
         WindSpeed:=(
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_seasonClosest.OP_windspeed
               +FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_seasonIntermediate.OP_windspeed
               +FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_seasonFarthest.OP_windspeed
            ) div 3;
      end;
      {.for the planetary survey - ground}
      EMO:=0;
      fCalc1:=0;
      case IndexAtmPressure of
         higHostile_n: EMO:=20;

         higHostile_p: EMO:=100;

         higBad_n: EMO:=10;

         higBad_p: EMO:=50;

         higMediocre_n: EMO:=5;

         higMediocre_p: EMO:=25;

         higAcceptable_n: EMO:=5;

         higAcceptable_p: EMO:=15;
      end;
      case IndexGravity of
         higHostile_n: EMO:=EMO + 20;

         higHostile_p: EMO:=EMO + 60;

         higBad_n: EMO:=EMO + 15;

         higBad_p: EMO:=EMO + 40;

         higMediocre_n: EMO:=EMO + 10;

         higMediocre_p: EMO:=EMO + 20;

         higAcceptable_n: EMO:=EMO + 5;

         higAcceptable_p: EMO:=EMO + 10;
      end;
      case IndexRadiations of
         higHostile: EMO:=EMO + 60;

         higBad: EMO:=EMO + 30;

         higMediocre: EMO:=EMO + 15;

         higAcceptable: EMO:=EMO + 10;
      end;
      case Relief of
         rr4Broken: EMO:=EMO + 20;

         rr9Mountain: EMO:=EMO + 40;
      end;
      case Land of
         rst01RockyDesert: EMO:=EMO + 10;

         rst02SandyDesert: EMO:=EMO + 30;

         rst03Volcanic: EMO:=EMO + 60;

         rst04Polar: EMO:=EMO + 40;

         rst05Arid: EMO:=EMO + 10;

         rst08CoastalRockyDesert: EMO:=EMO + 10;

         rst09CoastalSandyDesert: EMO:=EMO + 30;

         rst10CoastalVolcanic: EMO:=EMO + 60;

         rst11CoastalPolar: EMO:=EMO + 40;

         rst12CoastalArid: EMO:=EMO + 10;

         rst14Sterile: EMO:=EMO + 40;

         rst15icySterile: EMO:=EMO + 60;
      end;
      EMO:=EMO + _WindMod( 2 );
      fCalc1:=( EMO + 100 ) * 0.01;
      if Satellite <= 0
      then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_emo.EMO_planetarySurveyGround:=FCFcF_Round( rttCustom3Decimal, fCalc1 )
      else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_emo.EMO_planetarySurveyGround:=FCFcF_Round( rttCustom3Decimal, fCalc1 );
      {.for the planetary survey - air}
      EMO:=0;
      fCalc1:=0;
      if AtmospherePress = 0
      then EMO:=-100
      else begin
         case IndexAtmPressure of
            higHostile_n: EMO:=120;

            higHostile_p: EMO:=-100;

            higBad_n: EMO:=60;

            higBad_p: EMO:=-50;

            higMediocre_n: EMO:=30;

            higMediocre_p: EMO:=-25;

            higAcceptable_n: EMO:=10;

            higAcceptable_p: EMO:=-15;
         end;
         case IndexGravity of
            higHostile_n: EMO:=EMO + 5;

            higHostile_p: EMO:=EMO + 15;

            higBad_n: EMO:=EMO + 5;

            higBad_p: EMO:=EMO + 10;

            higMediocre_n: EMO:=EMO + 5;

            higMediocre_p: EMO:=EMO + 5;

            higAcceptable_n: EMO:=EMO + 5;

            higAcceptable_p: EMO:=EMO + 5;
         end;
         case IndexRadiations of
            higHostile: EMO:=EMO + 80;

            higBad: EMO:=EMO + 40;

            higMediocre: EMO:=EMO + 20;

            higAcceptable: EMO:=EMO + 10;
         end;
         if Relief = rr9Mountain
         then EMO:=EMO + 10;
         EMO:=EMO + _WindMod( 1 );
      end;
      fCalc1:=( EMO + 100 ) * 0.01;
      if Satellite <= 0
      then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_emo.EMO_planetarySurveyAir:=FCFcF_Round( rttCustom3Decimal, fCalc1 )
      else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_emo.EMO_planetarySurveyAir:=FCFcF_Round( rttCustom3Decimal, fCalc1 );
      {.for the planetary survey - antigrav}
      EMO:=0;
      fCalc1:=0;
      case IndexAtmPressure of
         higHostile_n: EMO:=20;

         higHostile_p: EMO:=-20;

         higBad_n: EMO:=15;

         higBad_p: EMO:=-10;

         higMediocre_n: EMO:=10;

         higMediocre_p: EMO:=-5;

         higAcceptable_n: EMO:=5;

         higAcceptable_p: EMO:=-5;
      end;
      case IndexRadiations of
         higHostile: EMO:=EMO + 60;

         higBad: EMO:=EMO + 30;

         higMediocre: EMO:=EMO + 15;

         higAcceptable: EMO:=EMO + 10;
      end;
      EMO:=EMO + _WindMod( 0.5 );
      fCalc1:=( EMO + 100 ) * 0.01;
      if Satellite <= 0
      then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_emo.EMO_planetarySurveyAntigrav:=FCFcF_Round( rttCustom3Decimal, fCalc1 )
      else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_emo.EMO_planetarySurveyAntigrav:=FCFcF_Round( rttCustom3Decimal, fCalc1 );
      {.for the planetary survey - swarm antigrav}
      if Satellite <= 0
      then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_emo.EMO_planetarySurveySwarmAntigrav:=1
      else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_emo.EMO_planetarySurveySwarmAntigrav:=1;
      {.for the CAB}
      EMO:=0;
      fCalc1:=0;
      case IndexAtmPressure of
         higHostile_n: EMO:=40;

         higHostile_p: EMO:=120;

         higBad_n: EMO:=30;

         higBad_p: EMO:=60;

         higMediocre_n: EMO:=20;

         higMediocre_p: EMO:=30;

         higAcceptable_n: EMO:=10;

         higAcceptable_p: EMO:=15;
      end;
      case Climate of
         rc01VeryHotHumid, rc02VeryHotSemiHumid: EMO:=EMO + 40;

         rc04HotArid: EMO:=EMO + 30;

         rc07ColdArid, rc08Periarctic: EMO:=EMO + 15;

         rc09Arctic: EMO:=EMO + 30;

         rc10Extreme: EMO:=EMO + 80;
      end;
      if ( ( ( Land <= rst02SandyDesert ) or ( Land = rst08CoastalRockyDesert ) or ( Land = rst09CoastalSandyDesert ) ) and ( ( Climate = rc04HotArid ) or ( Climate = rc07ColdArid ) ) )
         or ( ( Land = rst14Sterile ) and ( ( IndexGravity = higHostile_n ) or ( IndexGravity = higBad_n ) ) )
      then EMO:=EMO + 10;
      case IndexGravity of
         higHostile_n: EMO:=EMO + 25;

         higHostile_p: EMO:=EMO + 75;

         higBad_n: EMO:=EMO + 15;

         higBad_p: EMO:=EMO + 50;

         higMediocre_n: EMO:=EMO + 10;

         higMediocre_p: EMO:=EMO + 30;

         higAcceptable_n: EMO:=EMO + 5;

         higAcceptable_p: EMO:=EMO + 15;
      end;
      case IndexRadiations of
         higHostile: EMO:=EMO + 80;

         higBad: EMO:=EMO + 40;

         higMediocre: EMO:=EMO + 20;

         higAcceptable: EMO:=EMO + 10;
      end;
      case Relief of
         rr4Broken: EMO:=EMO + 10;

         rr9Mountain: EMO:=EMO + 40;
      end;
      case Land of
         rst01RockyDesert: EMO:=EMO + 30;

         rst02SandyDesert: EMO:=EMO + 50;

         rst03Volcanic: EMO:=EMO + 80;

         rst04Polar: EMO:=EMO + 60;

         rst05Arid: EMO:=EMO + 30;

         rst08CoastalRockyDesert: EMO:=EMO + 30;

         rst09CoastalSandyDesert: EMO:=EMO + 50;

         rst10CoastalVolcanic: EMO:=EMO + 80;

         rst11CoastalPolar: EMO:=EMO + 60;

         rst12CoastalArid: EMO:=EMO + 30;

         rst14Sterile: EMO:=EMO + 60;

         rst15icySterile: EMO:=EMO + 80;
      end;
      EMO:=EMO + _WindMod( 1.5 );
      fCalc1:=( EMO + 100 ) * 0.01;
      if Satellite <= 0
      then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_emo.EMO_cab:=FCFcF_Round( rttCustom3Decimal, fCalc1 )
      else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_emo.EMO_cab:=FCFcF_Round( rttCustom3Decimal, fCalc1 );
      {.infrastructure wearing coefficient}
      EMO:=0;
      fCalc1:=0;
      EMO:=NO2SO2mod;
      case IndexAtmPressure of
         higHostile_p: EMO:=EMO + 200;

         higBad_p: EMO:=EMO + 120;

         higMediocre_p: EMO:=EMO + 60;

         higAcceptable_p: EMO:=EMO + 20;
      end;
      case Climate of
         rc01VeryHotHumid, rc02VeryHotSemiHumid: EMO:=EMO + 50;

         rc04HotArid: EMO:=EMO + 20;

         rc07ColdArid, rc08Periarctic: EMO:=EMO + 10;

         rc09Arctic: EMO:=EMO + 30;

         rc10Extreme: EMO:=EMO + 100;
      end;
      if ( ( ( Land <= rst02SandyDesert ) or ( Land = rst08CoastalRockyDesert ) or ( Land = rst09CoastalSandyDesert ) ) and ( ( Climate = rc04HotArid ) or ( Climate = rc07ColdArid ) ) )
         or ( ( Land = rst14Sterile ) and ( ( IndexGravity = higHostile_n ) or ( IndexGravity = higBad_n ) ) )
      then EMO:=EMO + 60;
      case IndexGravity of
         higHostile_p: EMO:=EMO + 200;

         higBad_p: EMO:=EMO + 120;

         higMediocre_p: EMO:=EMO + 60;

         higAcceptable_p: EMO:=EMO + 30;
      end;
      case IndexRadiations of
         higHostile: EMO:=EMO + 60;

         higBad: EMO:=EMO + 30;

         higMediocre: EMO:=EMO + 15;

         higAcceptable: EMO:=EMO + 10;
      end;
      EMO:=EMO + _WindMod( 1 );
      fCalc1:=( EMO + 100 ) * 0.01;
      if Satellite <= 0
      then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_emo.EMO_iwc:=FCFcF_Round( rttCustom3Decimal, fCalc1 )
      else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_emo.EMO_iwc:=FCFcF_Round( rttCustom3Decimal, fCalc1 );
      {.ground combat}
      EMO:=0;
      fCalc1:=0;
      case IndexAtmPressure of
         higHostile_n: EMO:=65;

         higHostile_p: EMO:=200;

         higBad_n: EMO:=40;

         higBad_p: EMO:=120;

         higMediocre_n: EMO:=20;

         higMediocre_p: EMO:=60;

         higAcceptable_n: EMO:=5;

         higAcceptable_p: EMO:=10;
      end;
      case Climate of
         rc01VeryHotHumid, rc02VeryHotSemiHumid: EMO:=EMO + 50;

         rc04HotArid: EMO:=EMO + 40;

         rc07ColdArid, rc08Periarctic: EMO:=EMO + 20;

         rc09Arctic: EMO:=EMO + 40;

         rc10Extreme: EMO:=EMO + 120;
      end;
      if ( ( ( Land <= rst02SandyDesert ) or ( Land = rst08CoastalRockyDesert ) or ( Land = rst09CoastalSandyDesert ) ) and ( ( Climate = rc04HotArid ) or ( Climate = rc07ColdArid ) ) )
         or ( ( Land = rst14Sterile ) and ( ( IndexGravity = higHostile_n ) or ( IndexGravity = higBad_n ) ) )
      then EMO:=EMO + 20;
      case IndexGravity of
         higHostile_n: EMO:=EMO + 50;

         higHostile_p: EMO:=EMO + 150;

         higBad_n: EMO:=EMO + 35;

         higBad_p: EMO:=EMO + 100;

         higMediocre_n: EMO:=EMO + 20;

         higMediocre_p: EMO:=EMO + 60;

         higAcceptable_n: EMO:=EMO + 10;

         higAcceptable_p: EMO:=EMO + 30;
      end;
      case IndexRadiations of
         higHostile: EMO:=EMO + 100;

         higBad: EMO:=EMO + 50;

         higMediocre: EMO:=EMO + 25;

         higAcceptable: EMO:=EMO + 10;
      end;
      case Relief of
         rr4Broken: EMO:=EMO + 20;

         rr9Mountain: EMO:=EMO + 60;
      end;
      case Land of
         rst01RockyDesert: EMO:=EMO + 50;

         rst02SandyDesert: EMO:=EMO + 70;

         rst03Volcanic: EMO:=EMO + 100;

         rst04Polar: EMO:=EMO + 80;

         rst05Arid: EMO:=EMO + 50;

         rst08CoastalRockyDesert: EMO:=EMO + 50;

         rst09CoastalSandyDesert: EMO:=EMO + 70;

         rst10CoastalVolcanic: EMO:=EMO + 100;

         rst11CoastalPolar: EMO:=EMO + 80;

         rst12CoastalArid: EMO:=EMO + 50;

         rst14Sterile: EMO:=EMO + 80;

         rst15icySterile: EMO:=EMO + 100;
      end;
      EMO:=EMO + _WindMod( 1.5 );
      fCalc1:=( EMO + 100 ) * 0.01;
      if Satellite <= 0
      then FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions[Region].OOR_emo.EMO_groundCombat:=FCFcF_Round( rttCustom3Decimal, fCalc1 )
      else FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions[Region].OOR_emo.EMO_groundCombat:=FCFcF_Round( rttCustom3Decimal, fCalc1 );
      inc( Region );
   end; //==END== while Region <= Max ==//
end;

procedure FCMfE_HabitabilityIndexes_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: process the habitability indexes of a given orbital object.
   Additions:
}
   var
      Magfield
      ,iCalc1
      ,iCalc2: integer;

      AtmPress
      ,Gravity: extended;

      IndexGravity
      ,IndexRadiations
      ,IndexAtmosphere
      ,IndexAtmPressure: TFCEduHabitabilityIndex;

      CH4
      ,NH3
      ,Ne
      ,N2
      ,CO
      ,NO
      ,O2
      ,H2S
      ,CO2
      ,NO2
      ,SO2: TFCEduAtmosphericGasStatus;

begin
   iCalc1:=0;
   iCalc2:=0;

   AtmPress:=0;
   Gravity:=0;

   IndexGravity:=higNone;
   IndexRadiations:=higNone;
   IndexAtmosphere:=higNone;
   IndexAtmPressure:=higNone;

   CH4:=agsNotPresent;
   NH3:=agsNotPresent;
   Ne:=agsNotPresent;
   N2:=agsNotPresent;
   CO:=agsNotPresent;
   NO:=agsNotPresent;
   O2:=agsNotPresent;
   H2S:=agsNotPresent;
   CO2:=agsNotPresent;
   NO2:=agsNotPresent;
   SO2:=agsNotPresent;

   if Satellite <= 0 then
   begin
      AtmPress:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure;
      Gravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_Gravity;
      Magfield:=round( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_magneticField * 10 );
      CH4:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4;
      NH3:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3;
      Ne:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNe;
      N2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2;
      CO:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO;
      NO:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO;
      O2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceO2;
      H2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S;
      CO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2;
      NO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2;
      SO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2;
   end
   else begin
      AtmPress:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure;
      Gravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_Gravity;
      Magfield:=round( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_magneticField * 10 );
      CH4:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4;
      NH3:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3;
      Ne:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNe;
      N2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2;
      CO:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO;
      NO:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO;
      O2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceO2;
      H2S:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S;
      CO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2;
      NO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2;
      SO2:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2;
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
      if AtmPress = 0
      then iCalc1:=12
      else if ( AtmPress > 0 )
         and ( AtmPress < 5 )
      then iCalc1:=11
      else if ( AtmPress >= 5 )
         and ( AtmPress < 25 )
      then iCalc1:=10
      else if ( AtmPress >= 25 )
         and ( AtmPress < 125 )
      then iCalc1:=9
      else if ( AtmPress >= 125 )
         and ( AtmPress < 625 )
      then iCalc1:=8
      else if ( AtmPress >=625  )
         and ( AtmPress < 1250 )
      then iCalc1:=7
      else if ( AtmPress >= 1250 )
         and ( AtmPress < 2500 )
      then iCalc1:=6
      else if ( AtmPress >= 2500 )
         and ( AtmPress < 5000 )
      then iCalc1:=5
      else if AtmPress >= 5000
      then iCalc1:=4;
   end
   else if ( FCDduStarSystem[0].SS_stars[Star].S_class in[cA0..cA9] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[A0..A9] ) then
   begin
      if AtmPress = 0
      then iCalc1:=11
      else if ( AtmPress > 0 )
         and ( AtmPress < 5 )
      then iCalc1:=10
      else if ( AtmPress >= 5 )
         and ( AtmPress < 25 )
      then iCalc1:=9
      else if ( AtmPress >= 25 )
         and ( AtmPress < 125 )
      then iCalc1:=8
      else if ( AtmPress >= 125 )
         and ( AtmPress < 625 )
      then iCalc1:=7
      else if ( AtmPress >=625  )
         and ( AtmPress < 1250 )
      then iCalc1:=6
      else if ( AtmPress >= 1250 )
         and ( AtmPress < 2500 )
      then iCalc1:=5
      else if ( AtmPress >= 2500 )
         and ( AtmPress < 5000 )
      then iCalc1:=4
      else if AtmPress >= 5000
      then iCalc1:=3;
   end
   else if ( FCDduStarSystem[0].SS_stars[Star].S_class in[cK0..cK9] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[gK0..gK9] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[K0..K9] ) then
   begin
      if AtmPress = 0
      then iCalc1:=7
      else if ( AtmPress > 0 )
         and ( AtmPress < 5 )
      then iCalc1:=6
      else if ( AtmPress >= 5 )
         and ( AtmPress < 25 )
      then iCalc1:=4
      else if ( AtmPress >= 25 )
         and ( AtmPress < 125 )
      then iCalc1:=3
      else if ( AtmPress >= 125 )
         and ( AtmPress < 625 )
      then iCalc1:=2
      else if ( AtmPress >=625  )
         and ( AtmPress < 1250 )
      then iCalc1:=0
      else if ( AtmPress >= 1250 )
         and ( AtmPress < 2500 )
      then iCalc1:=0
      else if ( AtmPress >= 2500 )
         and ( AtmPress < 5000 )
      then iCalc1:=0
      else if AtmPress >= 5000
      then iCalc1:=-1;
   end
   else if ( FCDduStarSystem[0].SS_stars[Star].S_class in[cM0..cM5] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[gM0..gM5] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[M0..M9] ) then
   begin
      if AtmPress = 0
      then iCalc1:=5
      else if ( AtmPress > 0 )
         and ( AtmPress < 5 )
      then iCalc1:=3
      else if ( AtmPress >= 5 )
         and ( AtmPress < 25 )
      then iCalc1:=2
      else if ( AtmPress >= 25 )
         and ( AtmPress < 125 )
      then iCalc1:=1
      else if ( AtmPress >= 125 )
         and ( AtmPress < 625 )
      then iCalc1:=0
      else if ( AtmPress >=625  )
         and ( AtmPress < 1250 )
      then iCalc1:=0
      else if ( AtmPress >= 1250 )
         and ( AtmPress < 2500 )
      then iCalc1:=-1
      else if ( AtmPress >= 2500 )
         and ( AtmPress < 5000 )
      then iCalc1:=-1
      else if AtmPress >= 5000
      then iCalc1:=-2;
   end
   else if ( FCDduStarSystem[0].SS_stars[Star].S_class in[gF0..gF9] )
      or ( FCDduStarSystem[0].SS_stars[Star].S_class in[F0..F9] ) then
   begin
      if AtmPress = 0
      then iCalc1:=10
      else if ( AtmPress > 0 )
         and ( AtmPress < 5 )
      then iCalc1:=9
      else if ( AtmPress >= 5 )
         and ( AtmPress < 25 )
      then iCalc1:=8
      else if ( AtmPress >= 25 )
         and ( AtmPress < 125 )
      then iCalc1:=7
      else if ( AtmPress >= 125 )
         and ( AtmPress < 625 )
      then iCalc1:=6
      else if ( AtmPress >=625  )
         and ( AtmPress < 1250 )
      then iCalc1:=5
      else if ( AtmPress >= 1250 )
         and ( AtmPress < 2500 )
      then iCalc1:=4
      else if ( AtmPress >= 2500 )
         and ( AtmPress < 5000 )
      then iCalc1:=3
      else if AtmPress >= 5000
      then iCalc1:=2;
   end
   else if FCDduStarSystem[0].SS_stars[Star].S_class in[gG0..gG9] then
   begin
      if AtmPress = 0
      then iCalc1:=8
      else if ( AtmPress > 0 )
         and ( AtmPress < 5 )
      then iCalc1:=7
      else if ( AtmPress >= 5 )
         and ( AtmPress < 25 )
      then iCalc1:=6
      else if ( AtmPress >= 25 )
         and ( AtmPress < 125 )
      then iCalc1:=4
      else if ( AtmPress >= 125 )
         and ( AtmPress < 625 )
      then iCalc1:=3
      else if ( AtmPress >=625  )
         and ( AtmPress < 1250 )
      then iCalc1:=2
      else if ( AtmPress >= 1250 )
         and ( AtmPress < 2500 )
      then iCalc1:=1
      else if ( AtmPress >= 2500 )
         and ( AtmPress < 5000 )
      then iCalc1:=1
      else if AtmPress >= 5000
      then iCalc1:=0;
   end
   else if FCDduStarSystem[0].SS_stars[Star].S_class in[O5..O9] then
   begin
      if AtmPress = 0
      then iCalc1:=13
      else if ( AtmPress > 0 )
         and ( AtmPress < 5 )
      then iCalc1:=12
      else if ( AtmPress >= 5 )
         and ( AtmPress < 25 )
      then iCalc1:=11
      else if ( AtmPress >= 25 )
         and ( AtmPress < 125 )
      then iCalc1:=10
      else if ( AtmPress >= 125 )
         and ( AtmPress < 625 )
      then iCalc1:=9
      else if ( AtmPress >=625  )
         and ( AtmPress < 1250 )
      then iCalc1:=8
      else if ( AtmPress >= 1250 )
         and ( AtmPress < 2500 )
      then iCalc1:=7
      else if ( AtmPress >= 2500 )
         and ( AtmPress < 5000 )
      then iCalc1:=6
      else if AtmPress >= 5000
      then iCalc1:=5;
   end
   else if FCDduStarSystem[0].SS_stars[Star].S_class in[G0..G9] then
   begin
      if AtmPress = 0
      then iCalc1:=9
      else if ( AtmPress > 0 )
         and ( AtmPress < 5 )
      then iCalc1:=8
      else if ( AtmPress >= 5 )
         and ( AtmPress < 25 )
      then iCalc1:=7
      else if ( AtmPress >= 25 )
         and ( AtmPress < 125 )
      then iCalc1:=6
      else if ( AtmPress >= 125 )
         and ( AtmPress < 625 )
      then iCalc1:=4
      else if ( AtmPress >=625  )
         and ( AtmPress < 1250 )
      then iCalc1:=3
      else if ( AtmPress >= 1250 )
         and ( AtmPress < 2500 )
      then iCalc1:=3
      else if ( AtmPress >= 2500 )
         and ( AtmPress < 5000 )
      then iCalc1:=1
      else if AtmPress >= 5000
      then iCalc1:=1;
   end
   else if FCDduStarSystem[0].SS_stars[Star].S_class in[PSR..BH]
   then iCalc1:=14;
   iCalc2:=iCalc1 - Magfield;
   if iCalc2 <= 1
   then IndexRadiations:=higIdeal
   else if ( iCalc2 > 1 )
      and ( iCalc2 < 4 )
   then IndexRadiations:=higAcceptable
   else if ( iCalc2 >= 4 )
      and ( iCalc2 < 6 )
   then IndexRadiations:=higMediocre
   else if ( iCalc2 >= 6 )
      and ( iCalc2 < 8 )
   then IndexRadiations:=higBad
   else if iCalc2 >= 8
   then IndexRadiations:=higHostile;
   if AtmPress <= 0 then
   begin
      IndexAtmosphere:=higNone;
      IndexAtmPressure:=higHostile_n;
   end
   else begin
      {.atmosphere composition index}
      iCalc1:=0;
      if CH4 = agsSecondary
      then iCalc1:=-1
      else if CH4 = agsMain
      then iCalc1:=-2;
      if NH3 = agsSecondary
      then iCalc1:=iCalc1 - 2
      else if NH3 = agsMain
      then iCalc1:=iCalc1 - 4;
      if Ne = agsSecondary
      then iCalc1:=iCalc1 - 2
      else if Ne = agsMain
      then iCalc1:=iCalc1 - 4;
      if N2 = agsMain
      then iCalc1:=iCalc1 + 1;
      if CO = agsSecondary
      then iCalc1:=iCalc1 - 1
      else if CO = agsMain
      then iCalc1:=iCalc1 - 3;
      if NO = agsSecondary
      then iCalc1:=iCalc1 - 2
      else if NO = agsMain
      then iCalc1:=iCalc1 - 4;
      if O2 = agsSecondary
      then iCalc1:=iCalc1 + 2
      else if O2 = agsMain
      then iCalc1:=iCalc1 + 3;
      if H2S = agsSecondary
      then iCalc1:=iCalc1 - 1
      else if H2S = agsMain
      then iCalc1:=iCalc1 - 3;
      if CO2 = agsSecondary
      then iCalc1:=iCalc1 - 1
      else if CO2 = agsMain
      then iCalc1:=iCalc1 - 2;
      if NO2 = agsSecondary
      then iCalc1:=iCalc1 - 2
      else if NO2 = agsMain
      then iCalc1:=iCalc1 - 4;
      if SO2 = agsSecondary
      then iCalc1:=iCalc1 - 1
      else if SO2 = agsMain
      then iCalc1:=iCalc1 - 3;
      if iCalc1 = 0
      then iCalc1:=-4;
      if iCalc1 <= -4
      then IndexAtmosphere:=higHostile
      else if ( iCalc1 > -4 )
         and ( iCalc1 <= -2 )
      then IndexAtmosphere:=higBad
      else if ( iCalc1 > -2 )
         and ( iCalc1 <= 0 )
      then IndexAtmosphere:=higMediocre
      else if ( iCalc1 > 0 )
         and ( iCalc1 <= 2 )
      then IndexAtmosphere:=higAcceptable
      else if iCalc1 > 2
      then IndexAtmosphere:=higIdeal;
      {.atmosphere pressure index}
      if AtmPress < 1.013
      then IndexAtmPressure:=higHostile_n
      else if ( AtmPress >= 1.013 )
         and ( AtmPress < 96.235 )
      then IndexAtmPressure:=higBad_n
      else if ( AtmPress >= 96.235 )
         and ( AtmPress < 506.5 )
      then IndexAtmPressure:=higMediocre_n
      else if ( AtmPress >= 506.5 )
         and ( AtmPress < 709.1 )
      then IndexAtmPressure:=higAcceptable_n
      else if ( AtmPress >= 709.1 )
         and ( AtmPress < 1316.9 )
      then IndexAtmPressure:=higIdeal
      else if ( AtmPress >= 1316.9 )
         and ( AtmPress < 1620.8 )
      then IndexAtmPressure:=higAcceptable_p
      else if ( AtmPress >= 1620.8 )
         and ( AtmPress < 2026 )
      then IndexAtmPressure:=higMediocre_p
      else if ( AtmPress >= 2026 )
         and ( AtmPress < 8104 )
      then IndexAtmPressure:=higBad_p
      else if AtmPress >= 8104
      then IndexAtmPressure:=higHostile_p;
   end; //==END== else of if AtmPress <= 0 ==//
   {.data loading}
   if Satellite <= 0 then
   begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_habitabilityGravity:=IndexGravity;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_habitabilityRadiations:=IndexRadiations;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_habitabilityAtmosphere:=IndexAtmosphere;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_habitabilityAtmPressure:=IndexAtmPressure;
   end
   else begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_habitabilityGravity:=IndexGravity;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_habitabilityRadiations:=IndexRadiations;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_habitabilityAtmosphere:=IndexAtmosphere;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_habitabilityAtmPressure:=IndexAtmPressure;
   end;
end;

end.
