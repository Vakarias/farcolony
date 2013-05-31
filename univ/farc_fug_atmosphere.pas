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

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//function FCFfA_GasVelocity_Calculation(
//   const BaseTemperature: extended;
//   const

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
   ,farc_data_univ;

type TFCEfaGases=(
   gH2
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

//===========================END FUNCTIONS SECTION==========================================

procedure FCMfA_Atmosphere_Processing(
   const Star
         ,OrbitalObject: integer;
   const BaseTemperature: extended;
   const Satellite: integer=0
   );
{:Purpose: main rule for the process of the atmosphere.
   Additions:
}
   var
      Stat: integer;

      CalculatedPressure
      ,EscapeVelocity
      ,GasVelocity: extended;

      isVeryDense: boolean;

      BasicType: TFCEduOrbitalObjectBasicTypes;

      GasSettingNull: TFCRduAtmosphericComposition;
      GasSettings: TFCRduAtmosphericComposition;

      procedure _SpecialAtmosphere_Process;
      begin
         Stat:=FCFcF_Random_DoInteger( 9 ) + 1;
         case Stat of
            1..3:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceCO:=agsMain;
            end;

            4..6: GasSettings.AC_gasPresenceCO:=agsMain;

            7..8:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceCO:=agsMain;
               isVeryDense:=true;
            end;

            9..10:
            begin
               GasSettings.AC_gasPresenceCO:=agsMain;
               isVeryDense:=true;
            end;
         end;
      end;
begin
   CalculatedPressure:=0;
   EscapeVelocity:=0;
   GasVelocity:=0;
   isVeryDense:=false;
   GasSettings:=GasSettingNull;
   if Satellite=0 then
   begin
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_basicType;
      EscapeVelocity:=( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_escapeVelocity * 1000 ) / 6;
   end
   else begin
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_basicType;
      EscapeVelocity:=( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_escapeVelocity * 1000 ) / 6;
   end;
   {.step 1: primary composition}
   if ( BasicType=oobtTelluricPlanet )
      or ( BasicType=oobtIcyPlanet ) then
   begin
      Stat:=FCFcF_Random_DoInteger( 9 ) + 1;
      if BaseTemperature <= 50 then
      begin
         case Stat of
            1..4: GasSettings.AC_gasPresenceH2:=agsMain;

            5..6: GasSettings.AC_gasPresenceHe:=agsMain;

            7..8:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceHe:=agsMain;
            end;

            9: GasSettings.AC_gasPresenceNe:=agsMain;

            10: _SpecialAtmosphere_Process;
         end;
      end
      else if ( BaseTemperature > 50 )
         and ( BaseTemperature <= 150 ) then
      begin
         case Stat of
            1..4:
            begin
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCH4:=agsMain;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceHe:=agsMain;
               GasSettings.AC_gasPresenceN2:=agsMain;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCO:=agsMain;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceHe:=agsMain;
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
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCO2:=agsMain;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceCO2:=agsMain;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCH4:=agsMain;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceHe:=agsMain;
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
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCO2:=agsMain;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceCO2:=agsMain;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCH4:=agsMain;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceCO2:=agsMain;
               GasSettings.AC_gasPresenceCH4:=agsMain;
               GasSettings.AC_gasPresenceNH3:=agsMain;
            end;

            10: _SpecialAtmosphere_Process;
         end;
      end
      else if BaseTemperature > 400 then
      begin
         case Stat of
            1..4:
            begin
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCO2:=agsMain;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceCO2:=agsMain;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceNO2:=agsMain;
               GasSettings.AC_gasPresenceSO2:=agsMain;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceSO2:=agsMain;
            end;

            10: _SpecialAtmosphere_Process;
         end;
      end;
   end //==END== if ( BasicType=oobtTelluricPlanet ) or ( BasicType=oobtIcyPlanet ) ==//
   else if BasicType=oobtGaseousPlanet then
   begin
      if BaseTemperature <= 50 then
      begin
         GasSettings.AC_gasPresenceCH4:=agsMain;
         GasSettings.AC_gasPresenceNH3:=agsMain;
      end
      else if ( BaseTemperature > 50 )
         and ( BaseTemperature <= 150 ) then
      begin
         GasSettings.AC_gasPresenceH2:=agsMain;
         GasSettings.AC_gasPresenceHe:=agsMain;
         GasSettings.AC_gasPresenceCH4:=agsMain;
      end
      else if ( BaseTemperature > 150 )
         and ( BaseTemperature <= 400 ) then
      begin
         GasSettings.AC_gasPresenceH2:=agsMain;
         GasSettings.AC_gasPresenceHe:=agsMain;
      end
      else if BaseTemperature > 400
      then GasSettings.AC_gasPresenceCO2:=agsMain;
   end; //==END== if BasicType=oobtGaseousPlanet ==//
   {.step 2: trace atmosphere}
   GasVelocity:=FCFfA_GasVelocity_Calculation( BaseTemperature, gSO2 );
   if ( not isVeryDense )
      and ( GasVelocity > EscapeVelocity ) then
   begin
      CalculatedPressure:=0;
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

   end; //==END== else begin of: if ( not/is isVeryDense ) and ( GasVelocity > EscapeVelocity ) ==//
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
