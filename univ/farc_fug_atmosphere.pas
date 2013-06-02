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
      Count
      ,PrimaryGasCount
      ,Stat: integer;

      CalculatedPressure
      ,EscapeVelocity
      ,GasVelocity
      ,PartOfVel: extended;

      isVeryDense
      ,TestBool: boolean;

      BasicType: TFCEduOrbitalObjectBasicTypes;

      GasSettingNull: TFCRduAtmosphericComposition;
      GasSettings: TFCRduAtmosphericComposition;

      function _SecondaryGas_test: boolean;
      begin
         Result:=false;
         PartOfVel:=1 - ( GasVelocity / EscapeVelocity );
         if ( ( PartOfVel < 0.45 ) and ( isVeryDense ) )
            or ( PartOfVel > 0.45 )
         then Result:=true;
      end;

      procedure _SpecialAtmosphere_Process;
      begin
         Stat:=FCFcF_Random_DoInteger( 9 ) + 1;
         case Stat of
            1..3:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceCO:=agsMain;
               PrimaryGasCount:=2;
            end;

            4..6:
            begin
               GasSettings.AC_gasPresenceCO:=agsMain;
               PrimaryGasCount:=1;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceCO:=agsMain;
               isVeryDense:=true;
               PrimaryGasCount:=2;
            end;

            9..10:
            begin
               GasSettings.AC_gasPresenceCO:=agsMain;
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
   PartOfVel:=0;
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
            1..4:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               PrimaryGasCount:=1;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceHe:=agsMain;
               PrimaryGasCount:=1;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceHe:=agsMain;
               PrimaryGasCount:=2;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceNe:=agsMain;
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
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCH4:=agsMain;
               PrimaryGasCount:=2;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceHe:=agsMain;
               GasSettings.AC_gasPresenceN2:=agsMain;
               PrimaryGasCount:=3;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCO:=agsMain;
               PrimaryGasCount:=2;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceHe:=agsMain;
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
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCO2:=agsMain;
               PrimaryGasCount:=2;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceCO2:=agsMain;
               PrimaryGasCount:=1;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCH4:=agsMain;
               PrimaryGasCount:=2;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceH2:=agsMain;
               GasSettings.AC_gasPresenceHe:=agsMain;
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
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCO2:=agsMain;
               PrimaryGasCount:=2;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceCO2:=agsMain;
               PrimaryGasCount:=1;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCH4:=agsMain;
               PrimaryGasCount:=2;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceCO2:=agsMain;
               GasSettings.AC_gasPresenceCH4:=agsMain;
               GasSettings.AC_gasPresenceNH3:=agsMain;
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
               GasSettings.AC_gasPresenceN2:=agsMain;
               GasSettings.AC_gasPresenceCO2:=agsMain;
               PrimaryGasCount:=2;
            end;

            5..6:
            begin
               GasSettings.AC_gasPresenceCO2:=agsMain;
               PrimaryGasCount:=1;
            end;

            7..8:
            begin
               GasSettings.AC_gasPresenceNO2:=agsMain;
               GasSettings.AC_gasPresenceSO2:=agsMain;
               PrimaryGasCount:=2;
            end;

            9:
            begin
               GasSettings.AC_gasPresenceSO2:=agsMain;
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
         GasSettings.AC_gasPresenceCH4:=agsMain;
         GasSettings.AC_gasPresenceNH3:=agsMain;
         PrimaryGasCount:=PrimaryGasCount + 2;
      end
      else if ( BaseTemperature > 50 )
         and ( BaseTemperature <= 150 ) then
      begin
         GasSettings.AC_gasPresenceH2:=agsMain;
         GasSettings.AC_gasPresenceHe:=agsMain;
         GasSettings.AC_gasPresenceCH4:=agsMain;
         PrimaryGasCount:=PrimaryGasCount + 3;
      end
      else if ( BaseTemperature > 150 )
         and ( BaseTemperature <= 400 ) then
      begin
         GasSettings.AC_gasPresenceH2:=agsMain;
         GasSettings.AC_gasPresenceHe:=agsMain;
         PrimaryGasCount:=PrimaryGasCount + 2;
      end
      else if BaseTemperature > 400 then
      begin
         GasSettings.AC_gasPresenceCO2:=agsMain;
         PrimaryGasCount:=PrimaryGasCount + 1;
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
                  if GasSettings.AC_gasPresenceH2=agsMain then
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
                  if GasSettings.AC_gasPresenceH2=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceHe=agsMain then
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
                  if GasSettings.AC_gasPresenceHe=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceCH4=agsMain then
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
                  if GasSettings.AC_gasPresenceCH4=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceNH3=agsMain then
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
                  if GasSettings.AC_gasPresenceNH3=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceH2O=agsMain then
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
                  if GasSettings.AC_gasPresenceH2O=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceNe=agsMain then
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
                  if GasSettings.AC_gasPresenceNe=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceN2=agsMain then
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
                  if GasSettings.AC_gasPresenceN2=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceCO=agsMain then
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
                  if GasSettings.AC_gasPresenceCO=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceNO=agsMain then
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
                  if GasSettings.AC_gasPresenceNO=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceO2=agsMain then
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
                  if GasSettings.AC_gasPresenceO2=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceH2S=agsMain then
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
                  if GasSettings.AC_gasPresenceH2S=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceAr=agsMain then
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
                  if GasSettings.AC_gasPresenceAr=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceCO2=agsMain then
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
                  if GasSettings.AC_gasPresenceCO2=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceNO2=agsMain then
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
                  if GasSettings.AC_gasPresenceNO2=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceO3=agsMain then
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
                  if GasSettings.AC_gasPresenceO3=agsMain then
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
               else begin
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
                  if GasSettings.AC_gasPresenceSO2=agsMain then
                  begin
                     dec( PrimaryGasCount );
                     if PrimaryGasCount <= 0
                     then GasSettings.AC_traceAtmosphere:=true;
                  end;
                  GasSettings.AC_gasPresenceSO2:=agsNotPresent;
               end
               else if ( GasVelocity > EscapeVelocity )
                  and ( isVeryDense ) then
               begin
                  if GasSettings.AC_gasPresenceSO2=agsMain then
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
               else begin
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
