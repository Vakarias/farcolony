{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - atmosphere unit

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
unit farc_fug_atmosphere;

interface

//uses

type TFCEfaGases=(
   gNone
   ,gH2
   ,gHe
   ,gCH4
   ,gNH3
   ,gH2O
   ,gNe
   ,gN2
   ,gCO
   ,gNO
   ,gO2
   ,gH2S
   ,gAr
   ,gCO2
   ,gNO2
   ,gO3
   ,gSO2
   );

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   return the number of primary gasses an orbital object has
///</summary>
/// <param name="Star">star's index #</param>
/// <param name="OrbitalObject">orbital object's index #</param>
/// <param name="Satellite">optional parameter, only for any satellite</param>
/// <returns>then # of primary gasses</returns>
/// <remarks></remarks>
function FCFfA_PrimaryGasses_GetTotalNumber(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   ): integer;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   main rule for the process of the atmosphere
///</summary>
/// <param name="Star">star's index #</param>
/// <param name="OrbitalObject">orbital object's index #</param>
/// <param name="Satellite">optional parameter, only for any satellite</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfA_Atmosphere_Processing(
   const Star
         ,OrbitalObject: integer;
   const BaseTemperature: extended;
   const Satellite: integer=0
   );

implementation

uses
   farc_common_func
   ,farc_data_univ
   ,farc_fug_stars;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

const
   FAmolecularMassCoef=1.66e-27;

   FAmolWeightH2=2;
   FAmolWeightHe=4;
   FAmolWeightCH4=16;
   FAmolWeightNH3=17;
   FAmolWeightH2O=18;
   FAmolWeightNe=20.2;
   FAmolWeightN2=28;
   FAmolWeightCO=28;
   FAmolWeightNO=30;
   FAmolWeightO2=32;
   FAmolWeightH2S=34.1;
   FAmolWeightAr=39.9;
   FAmolWeightCO2=44;
   FAmolWeightNO2=46;
   FAmolWeightO3=48;
   FAmolWeightSO2=64.1;

//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFfA_GasVelocity_Calculation(
   const BaseTemperature: extended;
   const Gas: TFCEfaGases
   ): extended;
{:Purpose: calculate the velocity of a specified gas.
   Additions:
}
   var
      Calculation
      ,MolecularWeight: extended;
begin
   case Gas of
      gH2: MolecularWeight:=2;

      gHe: MolecularWeight:=4;

      gCH4: MolecularWeight:=16;

      gNH3: MolecularWeight:=17;

      gH2O: MolecularWeight:=18;

      gNe: MolecularWeight:=20.2;

      gN2: MolecularWeight:=28;

      gCO: MolecularWeight:=28;

      gNO: MolecularWeight:=30;

      gO2: MolecularWeight:=32;

      gH2S: MolecularWeight:=34.1;

      gAr: MolecularWeight:=39.9;

      gCO2: MolecularWeight:=44;

      gNO2: MolecularWeight:=46;

      gO3: MolecularWeight:=48;

      gSO2: MolecularWeight:=64.1;
   end;
   Calculation:=BaseTemperature / MolecularWeight;
   Result:=145.559 * sqrt( Calculation )
end;

function FCFfA_PrimaryGasses_GetTotalNumber(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   ): integer;
{:Purpose: return the number of primary gasses an orbital object has.
    Additions:
}
begin
   Result:=0;
   if ( Satellite = 0 )
      and ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure > 0 ) then
   begin
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceHe=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNe=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceO2=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceAr=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceO3=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2=agsPrimary
      then inc( Result);
   end
   else if ( Satellite > 0 )
      and ( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure > 0 ) then
   begin
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceHe=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNe=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceO2=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceAr=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceO3=agsPrimary
      then inc( Result);
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2=agsPrimary
      then inc( Result);
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMfA_Atmosphere_Processing(
   const Star
         ,OrbitalObject: integer;
   const BaseTemperature: extended;
   const Satellite: integer=0
   );
{:Purpose: main rule for the process of the atmosphere.
   Additions:
      -2013Sep04- *add: set the trace atmosphere flag when the pressure is < 7mb.
                  *mod: stellar implications - CH4/NH3 doesn't become trace but secondary gases.
      -2013Jul07- *add: adjust the calculated pressure is the atmosphere is tagged as very dense.
      -2013Jun30- *fix: correction in logic that switched all primary gasses as secondary, if not trace.
                  *fix: force to set the traceatmosphere=false when no gas is present.
                  *fix: set correctly the trace atmosphere, when it is required, in the gasses interactions.
                  *add: the gasses interactions is expanded.
      -2013Jun29- *fix: fixed a strange crash due to the gas settings initialization.
                  *fix: the conditions for the PrimaryGasVolume and CalculatedPressure calculations are reorganized in a better way.
                  *fix: correction in the retained gasses rule for the SO2.
                  *fix: correction in one part of test of _SecondaryGas_test.
}
   var
      Count
      ,PrimaryGasCount
      ,Stat: integer;

      CalculatedPressure
      ,EscapeVelocity
      ,GasVelocity
      ,CalculationMisc
      ,Gravity
      ,Mass
      ,Pressure
      ,PressureMax
      ,Radius
      ,VolInventory
      ,VolInventoryMax: extended;

      isVeryDense
      ,TestBool: boolean;

      BasicType: TFCEduOrbitalObjectBasicTypes;

      TectonicActivity: TFCEduTectonicActivity;

      GasSettings: TFCRduAtmosphericComposition;

      function _NextSecondary_SetAsPrimary: boolean;
      begin
         Result:=true;
         inc( PrimaryGasCount );
         if GasSettings.AC_gasPresenceH2O=agsSecondary
         then GasSettings.AC_gasPresenceH2O:=agsPrimary
         else if GasSettings.AC_gasPresenceNe=agsSecondary
         then GasSettings.AC_gasPresenceNe:=agsPrimary
         else if GasSettings.AC_gasPresenceN2=agsSecondary
         then GasSettings.AC_gasPresenceN2:=agsPrimary
         else if GasSettings.AC_gasPresenceCO=agsSecondary
         then GasSettings.AC_gasPresenceCO:=agsPrimary
         else if GasSettings.AC_gasPresenceNO=agsSecondary
         then GasSettings.AC_gasPresenceNO:=agsPrimary
         else if GasSettings.AC_gasPresenceO2=agsSecondary
         then GasSettings.AC_gasPresenceO2:=agsPrimary
         else if GasSettings.AC_gasPresenceH2S=agsSecondary
         then GasSettings.AC_gasPresenceH2S:=agsPrimary
         else if GasSettings.AC_gasPresenceAr=agsSecondary
         then GasSettings.AC_gasPresenceAr:=agsPrimary
         else if GasSettings.AC_gasPresenceCO2=agsSecondary
         then GasSettings.AC_gasPresenceCO2:=agsPrimary
         else if GasSettings.AC_gasPresenceNO2=agsSecondary
         then GasSettings.AC_gasPresenceNO2:=agsPrimary
         else if GasSettings.AC_gasPresenceO3=agsSecondary
         then GasSettings.AC_gasPresenceO3:=agsPrimary
         else if GasSettings.AC_gasPresenceSO2=agsSecondary
         then GasSettings.AC_gasPresenceSO2:=agsPrimary
         else begin
            Result:=false;
            dec( PrimaryGasCount );
         end;
      end;

      function _SecondaryGas_test: boolean;
      begin
         Result:=false;
         CalculationMisc:=1 - ( GasVelocity / EscapeVelocity );
         if ( ( CalculationMisc < 0.45 ) and ( isVeryDense ) )
            or ( CalculationMisc >= 0.45 )
         then Result:=true;
      end;

      procedure _SpecialAtmosphere_Process;
      begin
         Stat:=FCFcF_Random_DoInteger( 9 ) + 1;
         case Stat of
            1..3:
            begin
               GasSettings.AC_gasPresenceH2:=agsPrimary;
               GasSettings.AC_gasPresenceCO:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            4..6:
            begin
               GasSettings.AC_gasPresenceCO:=agsPrimary;
               PrimaryGasCount:=1;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceH2:=agsPrimary;
               GasSettings.AC_gasPresenceCO:=agsPrimary;
               isVeryDense:=true;
               PrimaryGasCount:=2;
            end;

            9..10:
            begin
               GasSettings.AC_gasPresenceCO:=agsPrimary;
               isVeryDense:=true;
               PrimaryGasCount:=1;
            end;
         end;
      end;
begin
   Count:=0;
   PrimaryGasCount:=0;
   CalculatedPressure:=0;
   EscapeVelocity:=0;
   GasVelocity:=0;
   CalculationMisc:=0;
   isVeryDense:=false;
   GasSettings.AC_traceAtmosphere:=false;
   GasSettings.AC_primaryGasVolumePerc:=0;
   GasSettings.AC_gasPresenceH2:=agsNotPresent;
   GasSettings.AC_gasPresenceHe:=agsNotPresent;
   GasSettings.AC_gasPresenceCH4:=agsNotPresent;
   GasSettings.AC_gasPresenceNH3:=agsNotPresent;
   GasSettings.AC_gasPresenceH2O:=agsNotPresent;
   GasSettings.AC_gasPresenceNe:=agsNotPresent;
   GasSettings.AC_gasPresenceN2:=agsNotPresent;
   GasSettings.AC_gasPresenceCO:=agsNotPresent;
   GasSettings.AC_gasPresenceNO:=agsNotPresent;
   GasSettings.AC_gasPresenceO2:=agsNotPresent;
   GasSettings.AC_gasPresenceH2S:=agsNotPresent;
   GasSettings.AC_gasPresenceAr:=agsNotPresent;
   GasSettings.AC_gasPresenceCO2:=agsNotPresent;
   GasSettings.AC_gasPresenceNO2:=agsNotPresent;
   GasSettings.AC_gasPresenceO3:=agsNotPresent;
   GasSettings.AC_gasPresenceSO2:=agsNotPresent;
   if Satellite=0 then
   begin
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_fug_BasicType;
      EscapeVelocity:=( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_escapeVelocity * 1000 ) / 6;
      TectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_tectonicActivity;
      Mass:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_mass;
      Gravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity;
      Radius:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_diameter * 0.5;
   end
   else begin
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_fug_BasicType;
      EscapeVelocity:=( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_escapeVelocity * 1000 ) / 6;
      TectonicActivity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_tectonicActivity;
      Mass:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_mass;
      Gravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravity;
      Radius:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_diameter * 0.5;
   end;
   {.step 1: primary composition}
   if ( BasicType=oobtTelluricPlanet )
      or ( BasicType=oobtIcyPlanet ) then
   begin
      Stat:=FCFcF_Random_DoInteger( 9 ) + 1;
      if BaseTemperature <= 50 then
      begin
         case Stat of
            1..4:
            begin
               GasSettings.AC_gasPresenceH2:=agsPrimary;
               PrimaryGasCount:=1;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceHe:=agsPrimary;
               PrimaryGasCount:=1;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceH2:=agsPrimary;
               GasSettings.AC_gasPresenceHe:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceNe:=agsPrimary;
               PrimaryGasCount:=1;
            end;

            10: _SpecialAtmosphere_Process;
         end;
      end
      else if ( BaseTemperature > 50 )
         and ( BaseTemperature <= 150 ) then
      begin
         case Stat of
            1..4:
            begin
               GasSettings.AC_gasPresenceN2:=agsPrimary;
               GasSettings.AC_gasPresenceCH4:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceH2:=agsPrimary;
               GasSettings.AC_gasPresenceHe:=agsPrimary;
               GasSettings.AC_gasPresenceN2:=agsPrimary;
               PrimaryGasCount:=3;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceN2:=agsPrimary;
               GasSettings.AC_gasPresenceCO:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceH2:=agsPrimary;
               GasSettings.AC_gasPresenceHe:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            10: _SpecialAtmosphere_Process;
         end;
      end
      else if ( BaseTemperature > 150 )
         and ( BaseTemperature <= 240 ) then
      begin
         case Stat of
            1..4:
            begin
               GasSettings.AC_gasPresenceN2:=agsPrimary;
               GasSettings.AC_gasPresenceCO2:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceCO2:=agsPrimary;
               PrimaryGasCount:=1;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceN2:=agsPrimary;
               GasSettings.AC_gasPresenceCH4:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceH2:=agsPrimary;
               GasSettings.AC_gasPresenceHe:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            10: _SpecialAtmosphere_Process;
         end;
      end
      else if ( BaseTemperature > 240 )
         and ( BaseTemperature <= 400 ) then
      begin
         case Stat of
            1..4:
            begin
               GasSettings.AC_gasPresenceN2:=agsPrimary;
               GasSettings.AC_gasPresenceCO2:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceCO2:=agsPrimary;
               PrimaryGasCount:=1;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceN2:=agsPrimary;
               GasSettings.AC_gasPresenceCH4:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceCO2:=agsPrimary;
               GasSettings.AC_gasPresenceCH4:=agsPrimary;
               GasSettings.AC_gasPresenceNH3:=agsPrimary;
               PrimaryGasCount:=3;
            end;

            10: _SpecialAtmosphere_Process;
         end;
      end
      else if BaseTemperature > 400 then
      begin
         case Stat of
            1..4:
            begin
               GasSettings.AC_gasPresenceN2:=agsPrimary;
               GasSettings.AC_gasPresenceCO2:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceCO2:=agsPrimary;
               PrimaryGasCount:=1;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceNO2:=agsPrimary;
               GasSettings.AC_gasPresenceSO2:=agsPrimary;
               PrimaryGasCount:=2;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceSO2:=agsPrimary;
               PrimaryGasCount:=1;
            end;

            10: _SpecialAtmosphere_Process;
         end;
      end;
   end //==END== if ( BasicType=oobtTelluricPlanet ) or ( BasicType=oobtIcyPlanet ) ==//
   else if BasicType=oobtGaseousPlanet then
   begin
      if BaseTemperature <= 50 then
      begin
         GasSettings.AC_gasPresenceCH4:=agsPrimary;
         GasSettings.AC_gasPresenceNH3:=agsPrimary;
         PrimaryGasCount:=2;
      end
      else if ( BaseTemperature > 50 )
         and ( BaseTemperature <= 150 ) then
      begin
         GasSettings.AC_gasPresenceH2:=agsPrimary;
         GasSettings.AC_gasPresenceHe:=agsPrimary;
         GasSettings.AC_gasPresenceCH4:=agsPrimary;
         PrimaryGasCount:=3;
      end
      else if ( BaseTemperature > 150 )
         and ( BaseTemperature <= 400 ) then
      begin
         GasSettings.AC_gasPresenceH2:=agsPrimary;
         GasSettings.AC_gasPresenceHe:=agsPrimary;
         PrimaryGasCount:=2;
      end
      else if BaseTemperature > 400 then
      begin
         GasSettings.AC_gasPresenceCO2:=agsPrimary;
         PrimaryGasCount:=1;
      end;
   end; //==END== if BasicType=oobtGaseousPlanet ==//
   {.step 2: trace atmosphere}
   GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gSO2 );
   if ( not isVeryDense )
      and ( GasVelocity > EscapeVelocity ) then
   begin
      CalculatedPressure:=0;
      PrimaryGasCount:=0;
      GasSettings.AC_traceAtmosphere:=false;
      GasSettings.AC_primaryGasVolumePerc:=0;
      GasSettings.AC_gasPresenceH2:=agsNotPresent;
      GasSettings.AC_gasPresenceHe:=agsNotPresent;
      GasSettings.AC_gasPresenceCH4:=agsNotPresent;
      GasSettings.AC_gasPresenceNH3:=agsNotPresent;
      GasSettings.AC_gasPresenceH2O:=agsNotPresent;
      GasSettings.AC_gasPresenceNe:=agsNotPresent;
      GasSettings.AC_gasPresenceN2:=agsNotPresent;
      GasSettings.AC_gasPresenceCO:=agsNotPresent;
      GasSettings.AC_gasPresenceNO:=agsNotPresent;
      GasSettings.AC_gasPresenceO2:=agsNotPresent;
      GasSettings.AC_gasPresenceH2S:=agsNotPresent;
      GasSettings.AC_gasPresenceAr:=agsNotPresent;
      GasSettings.AC_gasPresenceCO2:=agsNotPresent;
      GasSettings.AC_gasPresenceNO2:=agsNotPresent;
      GasSettings.AC_gasPresenceO3:=agsNotPresent;
      GasSettings.AC_gasPresenceSO2:=agsNotPresent;
   end
   else if ( isVeryDense )
      and ( GasVelocity > EscapeVelocity ) then
   begin
      CalculatedPressure:=0;
      PrimaryGasCount:=0;
      GasSettings.AC_traceAtmosphere:=true;
      GasSettings.AC_primaryGasVolumePerc:=0;
      GasSettings.AC_gasPresenceH2:=agsTrace;
      GasSettings.AC_gasPresenceHe:=agsTrace;
      GasSettings.AC_gasPresenceCH4:=agsTrace;
      GasSettings.AC_gasPresenceNH3:=agsTrace;
      GasSettings.AC_gasPresenceH2O:=agsTrace;
      GasSettings.AC_gasPresenceNe:=agsTrace;
      GasSettings.AC_gasPresenceN2:=agsTrace;
      GasSettings.AC_gasPresenceCO:=agsTrace;
      GasSettings.AC_gasPresenceNO:=agsTrace;
      GasSettings.AC_gasPresenceO2:=agsTrace;
      GasSettings.AC_gasPresenceH2S:=agsTrace;
      GasSettings.AC_gasPresenceAr:=agsTrace;
      GasSettings.AC_gasPresenceCO2:=agsTrace;
      GasSettings.AC_gasPresenceNO2:=agsTrace;
      GasSettings.AC_gasPresenceO3:=agsTrace;
      GasSettings.AC_gasPresenceSO2:=agsTrace;
   end
   else begin
      {.step 3: retained gases}
      Count:=1;
      while Count <= 16 do
      begin
         case Count of
            1:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gH2 );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceH2=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceH2:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceH2=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceH2:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceH2:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceH2:=agsTrace
               else if GasSettings.AC_gasPresenceH2 < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceH2:=agsTrace
                  else GasSettings.AC_gasPresenceH2:=agsSecondary;
               end;
            end; //==END== case Count(gas): 1 ==//

            2:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gHe );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceHe=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceHe:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceHe=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceHe:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceHe:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceHe:=agsTrace
               else if GasSettings.AC_gasPresenceHe < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceHe:=agsTrace
                  else GasSettings.AC_gasPresenceHe:=agsSecondary;
               end;
            end;

            3:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gCH4 );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceCH4=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceCH4:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceCH4=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceCH4:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceCH4:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceCH4:=agsTrace
               else if GasSettings.AC_gasPresenceCH4 < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceCH4:=agsTrace
                  else GasSettings.AC_gasPresenceCH4:=agsSecondary;
               end;
            end;

            4:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gNH3 );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceNH3=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceNH3:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceNH3=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceNH3:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceNH3:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceNH3:=agsTrace
               else if GasSettings.AC_gasPresenceNH3 < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceNH3:=agsTrace
                  else GasSettings.AC_gasPresenceNH3:=agsSecondary;
               end;
            end;

            5:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gH2O );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceH2O=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceH2O:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceH2O=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceH2O:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceH2O:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceH2O:=agsTrace
               else if GasSettings.AC_gasPresenceH2O < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceH2O:=agsTrace
                  else GasSettings.AC_gasPresenceH2O:=agsSecondary;
               end;
            end;

            6:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gNe );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceNe=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceNe:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceNe=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceNe:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceNe:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceNe:=agsTrace
               else if GasSettings.AC_gasPresenceNe < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceNe:=agsTrace
                  else GasSettings.AC_gasPresenceNe:=agsSecondary;
               end;
            end;

            7:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gN2 );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceN2=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceN2:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceN2=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceN2:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceN2:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceN2:=agsTrace
               else if GasSettings.AC_gasPresenceN2 < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceN2:=agsTrace
                  else GasSettings.AC_gasPresenceN2:=agsSecondary;
               end;
            end;

            8:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gCO );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceCO=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceCO:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceCO=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceCO:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceCO:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceCO:=agsTrace
               else if GasSettings.AC_gasPresenceCO < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceCO:=agsTrace
                  else GasSettings.AC_gasPresenceCO:=agsSecondary;
               end;
            end;

            9:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gNO );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceNO=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceNO:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceNO=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceNO:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceNO:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceNO:=agsTrace
               else if GasSettings.AC_gasPresenceNO < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceNO:=agsTrace
                  else GasSettings.AC_gasPresenceNO:=agsSecondary;
               end;
            end;

            10:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gO2 );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceO2=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceO2:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceO2=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceO2:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceO2:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceO2:=agsTrace
               else if GasSettings.AC_gasPresenceO2 < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceO2:=agsTrace
                  else GasSettings.AC_gasPresenceO2:=agsSecondary;
               end;
            end;

            11:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gH2S );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceH2S=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceH2S:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceH2S=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceH2S:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceH2S:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceH2S:=agsTrace
               else if GasSettings.AC_gasPresenceH2S < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceH2S:=agsTrace
                  else GasSettings.AC_gasPresenceH2S:=agsSecondary;
               end;
            end;

            12:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gAr );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceAr=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceAr:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceAr=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceAr:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceAr:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceAr:=agsTrace
               else if GasSettings.AC_gasPresenceAr < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceAr:=agsTrace
                  else GasSettings.AC_gasPresenceAr:=agsSecondary;
               end;
            end;

            13:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gCO2 );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceCO2=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceCO2:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceCO2=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceCO2:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceCO2:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceCO2:=agsTrace
               else if GasSettings.AC_gasPresenceCO2 < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceCO2:=agsTrace
                  else GasSettings.AC_gasPresenceCO2:=agsSecondary;
               end;
            end;

            14:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gNO2 );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceNO2=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceNO2:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceNO2=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceNO2:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceNO2:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceNO2:=agsTrace
               else if GasSettings.AC_gasPresenceNO2 < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceNO2:=agsTrace
                  else GasSettings.AC_gasPresenceNO2:=agsSecondary;
               end;
            end;

            15:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gO3 );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceO3=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceO3:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceO3=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceO3:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceO3:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceO3:=agsTrace
               else if GasSettings.AC_gasPresenceO3 < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceO3:=agsTrace
                  else GasSettings.AC_gasPresenceO3:=agsSecondary;
               end;
            end;

            16:
            begin
               GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gSO2 );
               if ( GasVelocity > EscapeVelocity )
                  and ( not isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceSO2=agsPrimary then
                  begin
                     dec( PrimaryGasCount );
//                     if PrimaryGasCount <= 0
//                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceSO2:=agsNotPresent;
                  GasSettings.AC_traceAtmosphere:=false;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceSO2=agsPrimary then
                  begin
                     if PrimaryGasCount-1 > 0 then
                     begin
                        GasSettings.AC_gasPresenceSO2:=agsTrace;
                        dec( PrimaryGasCount );
                     end;
                  end
                  else GasSettings.AC_gasPresenceSO2:=agsTrace;
               end
               else if ( GasVelocity <= EscapeVelocity )
                  and ( GasSettings.AC_traceAtmosphere )
               then GasSettings.AC_gasPresenceSO2:=agsTrace
               else if GasSettings.AC_gasPresenceSO2 < agsPrimary then
               begin
                  TestBool:=_SecondaryGas_test;
                  if not TestBool
                  then GasSettings.AC_gasPresenceSO2:=agsTrace
                  else GasSettings.AC_gasPresenceSO2:=agsSecondary;
               end;
            end;
         end; //==END== case Count of ==//
         inc( Count );
      end; //==END== while Count <= 16 ==//
   end; //==END== else begin of: if ( not/is isVeryDense ) and ( GasVelocity > EscapeVelocity ) ==//
   {.step 4: stellar implications}
   CalculationMisc:=FCFfS_Age_Calc( FCDduStarSystem[0].SS_stars[Star].S_mass, FCDduStarSystem[0].SS_stars[Star].S_luminosity );
   if CalculationMisc > 0.5 then
   begin
      if ( ( BaseTemperature > 150 ) and ( ( FCDduStarSystem[0].SS_stars[Star].S_class < cK0 ) or ( ( FCDduStarSystem[0].SS_stars[Star].S_class >= B0 ) and ( FCDduStarSystem[0].SS_stars[Star].S_class < F0 ) ) ) )
         or ( ( BaseTemperature > 180 ) and ( ( ( FCDduStarSystem[0].SS_stars[Star].S_class >= gF0 ) and ( FCDduStarSystem[0].SS_stars[Star].S_class < gG0 ) ) or ( ( FCDduStarSystem[0].SS_stars[Star].S_class >= F0 ) and ( FCDduStarSystem[0].SS_stars[Star].S_class < G0 ) ) ) )
         or ( ( BaseTemperature > 200 ) and ( ( ( FCDduStarSystem[0].SS_stars[Star].S_class >= gG0 ) and ( FCDduStarSystem[0].SS_stars[Star].S_class < gK0 ) ) or ( ( FCDduStarSystem[0].SS_stars[Star].S_class >= G0 ) and ( FCDduStarSystem[0].SS_stars[Star].S_class < K0 ) ) ) )
         or ( ( BaseTemperature > 230 ) and ( ( ( FCDduStarSystem[0].SS_stars[Star].S_class >= cK0 ) and ( FCDduStarSystem[0].SS_stars[Star].S_class < cM0 ) ) or ( ( FCDduStarSystem[0].SS_stars[Star].S_class >= gK0 ) and ( FCDduStarSystem[0].SS_stars[Star].S_class < gM0 ) ) or ( ( FCDduStarSystem[0].SS_stars[Star].S_class >= K0 ) and ( FCDduStarSystem[0].SS_stars[Star].S_class < M0 ) ) ) )
         or ( ( BaseTemperature > 260 ) and ( ( ( FCDduStarSystem[0].SS_stars[Star].S_class >= cM0 ) and ( FCDduStarSystem[0].SS_stars[Star].S_class < gF0 ) ) or ( ( FCDduStarSystem[0].SS_stars[Star].S_class >= gM0 ) and ( FCDduStarSystem[0].SS_stars[Star].S_class < O5 ) ) or ( ( FCDduStarSystem[0].SS_stars[Star].S_class >= M0 ) and ( FCDduStarSystem[0].SS_stars[Star].S_class < WD0 ) ) ) )
      then
      begin
         if GasSettings.AC_gasPresenceNH3=agsPrimary then
         begin
            dec( PrimaryGasCount );
            GasSettings.AC_gasPresenceNH3:=agsSecondary;
            if PrimaryGasCount=0
            then TestBool:=_NextSecondary_SetAsPrimary;
            if not TestBool
            then GasSettings.AC_traceAtmosphere:=true;
         end;
         if GasSettings.AC_gasPresenceCH4=agsPrimary then
         begin
            dec( PrimaryGasCount );
            GasSettings.AC_gasPresenceCH4:=agsSecondary;
            if PrimaryGasCount=0
            then TestBool:=_NextSecondary_SetAsPrimary;
            if not TestBool
            then GasSettings.AC_traceAtmosphere:=true;
         end;
      end;
   end;
   {.step 5: tectonic activity}
   if ( ( BasicType=oobtTelluricPlanet ) or ( BasicType=oobtIcyPlanet ) )
      and ( not GasSettings.AC_traceAtmosphere ) then
   begin
      if TectonicActivity = taDead then
      begin
         if ( ( GasSettings.AC_gasPresenceH2S = agsTrace ) or ( GasSettings.AC_gasPresenceH2S = agsSecondary ) )
            and ( not isVeryDense )
         then GasSettings.AC_gasPresenceH2S:=agsNotPresent
         else if ( GasSettings.AC_gasPresenceH2S = agsPrimary )
            and ( not isVeryDense ) then
         begin
            GasSettings.AC_gasPresenceH2S:=agsTrace;
            dec( PrimaryGasCount );
         end
         else if ( GasSettings.AC_gasPresenceH2S = agsPrimary )
            and ( isVeryDense ) then
         begin
            GasSettings.AC_gasPresenceH2S:=agsSecondary;
            dec( PrimaryGasCount );
         end;
         if ( ( GasSettings.AC_gasPresenceSO2 = agsTrace ) or ( GasSettings.AC_gasPresenceSO2 = agsSecondary ) )
            and ( not isVeryDense )
         then GasSettings.AC_gasPresenceSO2:=agsNotPresent
         else if ( GasSettings.AC_gasPresenceSO2 = agsPrimary )
            and ( not isVeryDense ) then
         begin
            GasSettings.AC_gasPresenceSO2:=agsTrace;
            dec( PrimaryGasCount );
         end
         else if ( GasSettings.AC_gasPresenceSO2 = agsPrimary )
            and ( isVeryDense ) then
         begin
            GasSettings.AC_gasPresenceSO2:=agsSecondary;
            dec( PrimaryGasCount );
         end;
         if PrimaryGasCount=0
         then GasSettings.AC_traceAtmosphere:=true;
      end
      else if TectonicActivity > taPlateTectonic then
      begin
         if GasSettings.AC_gasPresenceH2S <= agsTrace
         then GasSettings.AC_gasPresenceH2S:=agsSecondary
         else if GasSettings.AC_gasPresenceH2S = agsSecondary then
         begin
            GasSettings.AC_gasPresenceH2S:=agsPrimary;
            inc( PrimaryGasCount );
         end;
         if GasSettings.AC_gasPresenceSO2 <= agsTrace
         then GasSettings.AC_gasPresenceSO2:=agsSecondary
         else if GasSettings.AC_gasPresenceSO2 = agsSecondary then
         begin
            GasSettings.AC_gasPresenceSO2:=agsPrimary;
            inc( PrimaryGasCount );
         end;
         if ( PrimaryGasCount > 0 )
            and ( GasSettings.AC_traceAtmosphere )
         then GasSettings.AC_traceAtmosphere:=false;
      end;
   end;
   {.step 6: gasses interactions}
   if GasSettings.AC_gasPresenceCO2 = agsPrimary then
   begin
      if GasSettings.AC_gasPresenceNH3 = agsPrimary then
      begin
         GasSettings.AC_gasPresenceNH3:=agsSecondary;
         dec( PrimaryGasCount );
         if PrimaryGasCount<=0
         then GasSettings.AC_traceAtmosphere:=true;
      end
      else if GasSettings.AC_gasPresenceNH3 = agsSecondary
      then GasSettings.AC_gasPresenceNH3:=agsTrace
      else if GasSettings.AC_gasPresenceNH3 = agsTrace
      then GasSettings.AC_gasPresenceNH3:=agsNotPresent;
      if GasSettings.AC_gasPresenceH2 = agsNotPresent
      then GasSettings.AC_gasPresenceH2:=agsTrace;
   end;
   if ( GasSettings.AC_gasPresenceH2 = agsPrimary )
      and ( GasSettings.AC_gasPresenceCO = agsPrimary ) then
   begin
      if GasSettings.AC_gasPresenceO2 = agsPrimary then
      begin
         dec( PrimaryGasCount );
         if PrimaryGasCount<=0
         then GasSettings.AC_traceAtmosphere:=true;
      end;
      GasSettings.AC_gasPresenceO2:=agsNotPresent;
   end;
   if GasSettings.AC_gasPresenceNH3 = agsSecondary then
   begin
      if GasSettings.AC_gasPresenceO2 = agsTrace
      then GasSettings.AC_gasPresenceO2:=agsNotPresent
      else if GasSettings.AC_gasPresenceO2 > agsTrace
      then GasSettings.AC_gasPresenceNH3:=agsTrace;
   end
   else if GasSettings.AC_gasPresenceNH3 = agsPrimary then
   begin
      if GasSettings.AC_gasPresenceO2 = agsTrace
      then GasSettings.AC_gasPresenceO2:=agsNotPresent
      else if GasSettings.AC_gasPresenceO2 > agsTrace then
      begin
         if GasSettings.AC_gasPresenceO2=agsPrimary then
         begin
            dec( PrimaryGasCount );
            if PrimaryGasCount<=0
            then GasSettings.AC_traceAtmosphere:=true;
         end;
         GasSettings.AC_gasPresenceO2:=agsTrace;
      end;
      if GasSettings.AC_gasPresenceCO2 = agsTrace
      then GasSettings.AC_gasPresenceCO2:=agsNotPresent
      else if GasSettings.AC_gasPresenceCO2 > agsTrace then
      begin
         if GasSettings.AC_gasPresenceCO2=agsPrimary then
         begin
            dec( PrimaryGasCount );
            if PrimaryGasCount<=0
            then GasSettings.AC_traceAtmosphere:=true;
         end;
         GasSettings.AC_gasPresenceCO2:=agsTrace;
      end;
   end;
   if GasSettings.AC_gasPresenceCO = agsSecondary then
   begin
      if GasSettings.AC_gasPresenceO2 = agsTrace
      then GasSettings.AC_gasPresenceO2:=agsNotPresent
      else if GasSettings.AC_gasPresenceO2 > agsTrace
      then GasSettings.AC_gasPresenceCO:=agsTrace;
   end
   else if ( GasSettings.AC_gasPresenceCO = agsPrimary )
      and ( GasSettings.AC_gasPresenceH2 < agsPrimary ) then
   begin
      if GasSettings.AC_gasPresenceO2 = agsTrace
      then GasSettings.AC_gasPresenceO2:=agsNotPresent
      else if GasSettings.AC_gasPresenceO2 > agsTrace then
      begin
         if GasSettings.AC_gasPresenceO2=agsPrimary then
         begin
            dec( PrimaryGasCount );
            if PrimaryGasCount<=0
            then GasSettings.AC_traceAtmosphere:=true;
         end;
         GasSettings.AC_gasPresenceO2:=agsTrace;
      end;
   end;
   if GasSettings.AC_gasPresenceCH4 = agsSecondary then
   begin
      if GasSettings.AC_gasPresenceO2 = agsTrace
      then GasSettings.AC_gasPresenceO2:=agsNotPresent
      else if GasSettings.AC_gasPresenceO2 > agsTrace
      then GasSettings.AC_gasPresenceCH4:=agsTrace;
   end
   else if GasSettings.AC_gasPresenceCH4 = agsPrimary then
   begin
      if GasSettings.AC_gasPresenceO2 = agsTrace
      then GasSettings.AC_gasPresenceO2:=agsNotPresent
      else if GasSettings.AC_gasPresenceO2 > agsTrace then
      begin
         if GasSettings.AC_gasPresenceO2=agsPrimary then
         begin
            dec( PrimaryGasCount );
            if PrimaryGasCount<=0
            then GasSettings.AC_traceAtmosphere:=true;
         end;
         GasSettings.AC_gasPresenceO2:=agsTrace;
      end;
   end;
   if ( GasSettings.AC_gasPresenceNO < agsSecondary )
      or ( GasSettings.AC_gasPresenceO2 < agsSecondary )
   then GasSettings.AC_gasPresenceNO2:=agsTrace;
   if BaseTemperature >= 44.4
   then GasSettings.AC_gasPresenceNe:=agsTrace;
   {.step 7: primary gas volume}
   TestBool:=false;
   if ( GasSettings.AC_gasPresenceH2=agsNotPresent )
      and ( GasSettings.AC_gasPresenceHe=agsNotPresent )
      and ( GasSettings.AC_gasPresenceCH4=agsNotPresent )
      and ( GasSettings.AC_gasPresenceNH3=agsNotPresent )
      and ( GasSettings.AC_gasPresenceH2O=agsNotPresent )
      and ( GasSettings.AC_gasPresenceNe=agsNotPresent )
      and ( GasSettings.AC_gasPresenceN2=agsNotPresent )
      and ( GasSettings.AC_gasPresenceCO=agsNotPresent )
      and ( GasSettings.AC_gasPresenceNO=agsNotPresent )
      and ( GasSettings.AC_gasPresenceO2=agsNotPresent )
      and ( GasSettings.AC_gasPresenceH2S=agsNotPresent )
      and ( GasSettings.AC_gasPresenceAr=agsNotPresent )
      and ( GasSettings.AC_gasPresenceCO2=agsNotPresent )
      and ( GasSettings.AC_gasPresenceNO2=agsNotPresent )
      and ( GasSettings.AC_gasPresenceO3=agsNotPresent )
      and ( GasSettings.AC_gasPresenceSO2=agsNotPresent ) then
   begin
      TestBool:=true;
      GasSettings.AC_traceAtmosphere:=false;
   end;
   if not TestBool then
   begin
      if not GasSettings.AC_traceAtmosphere then
      begin
         Stat:=FCFcF_Random_DoInteger( 9 ) + 1;
         case Stat of
            1..5: GasSettings.AC_primaryGasVolumePerc:=54 + FCFcF_Random_DoInteger( 36 );

            6..8: GasSettings.AC_primaryGasVolumePerc:=77 + FCFcF_Random_DoInteger( 19 );

            9..10: GasSettings.AC_primaryGasVolumePerc:=96 + ( FCFcF_Random_DoInteger( 3 ) + 1 )
         end;
      end
      else GasSettings.AC_primaryGasVolumePerc:=0;
      {.step 8: pressure}
      if FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_orbitalZone=hzInner
      then VolInventory:=( ( 100000 * Mass ) / FCDduStarSystem[0].SS_stars[Star].S_mass ) * 0.01
      else VolInventory:=( ( 75000 * Mass ) / FCDduStarSystem[0].SS_stars[Star].S_mass ) * 0.01;
      VolInventoryMax:=VolInventory + ( VolInventory * 0.6 );
      Pressure:=VolInventory * Gravity / sqr( 6378 / Radius );
      PressureMax:=VolInventoryMax * Gravity / sqr( 6378 / Radius );
      CalculatedPressure:=Pressure + ( ( PressureMax - Pressure ) / 1.71 );
      if isVeryDense
      then CalculatedPressure:=CalculatedPressure * ( 1.5 + ( FCFcF_Random_DoInteger( 49 ) + 1 ) );
      if CalculatedPressure < 7
      then GasSettings.AC_traceAtmosphere:=true;
   end
   else begin
      GasSettings.AC_primaryGasVolumePerc:=0;
      CalculatedPressure:=0;
   end;
   {.last step: data loading}
   if Satellite=0 then
   begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure:=FCFcF_Round( rttCustom3Decimal, CalculatedPressure );
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_traceAtmosphere:=GasSettings.AC_traceAtmosphere;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_primaryGasVolumePerc:=GasSettings.AC_primaryGasVolumePerc;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2:=GasSettings.AC_gasPresenceH2;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceHe:=GasSettings.AC_gasPresenceHe;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCH4:=GasSettings.AC_gasPresenceCH4;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNH3:=GasSettings.AC_gasPresenceNH3;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2O:=GasSettings.AC_gasPresenceH2O;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNe:=GasSettings.AC_gasPresenceNe;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceN2:=GasSettings.AC_gasPresenceN2;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO:=GasSettings.AC_gasPresenceCO;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO:=GasSettings.AC_gasPresenceNO;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceO2:=GasSettings.AC_gasPresenceO2;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceH2S:=GasSettings.AC_gasPresenceH2S;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceAr:=GasSettings.AC_gasPresenceAr;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceCO2:=GasSettings.AC_gasPresenceCO2;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceNO2:=GasSettings.AC_gasPresenceNO2;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceO3:=GasSettings.AC_gasPresenceO3;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphere.AC_gasPresenceSO2:=GasSettings.AC_gasPresenceSO2;
   end
   else begin
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure:=FCFcF_Round( rttCustom3Decimal, CalculatedPressure );
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_traceAtmosphere:=GasSettings.AC_traceAtmosphere;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_primaryGasVolumePerc:=GasSettings.AC_primaryGasVolumePerc;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2:=GasSettings.AC_gasPresenceH2;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceHe:=GasSettings.AC_gasPresenceHe;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCH4:=GasSettings.AC_gasPresenceCH4;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNH3:=GasSettings.AC_gasPresenceNH3;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2O:=GasSettings.AC_gasPresenceH2O;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNe:=GasSettings.AC_gasPresenceNe;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceN2:=GasSettings.AC_gasPresenceN2;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO:=GasSettings.AC_gasPresenceCO;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO:=GasSettings.AC_gasPresenceNO;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceO2:=GasSettings.AC_gasPresenceO2;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceH2S:=GasSettings.AC_gasPresenceH2S;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceAr:=GasSettings.AC_gasPresenceAr;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceCO2:=GasSettings.AC_gasPresenceCO2;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceNO2:=GasSettings.AC_gasPresenceNO2;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceO3:=GasSettings.AC_gasPresenceO3;
      FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphere.AC_gasPresenceSO2:=GasSettings.AC_gasPresenceSO2;
   end;
end;

end.
