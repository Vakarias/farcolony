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

//Set Trace Atmosphere (VDswitch

//Unset Trace Atmosphere

implementation

uses
   farc_common_func
   ,farc_data_univ;

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
   isVeryDense:=false;
   GasSettings:=GasSettingNull;
   if Satellite=0 then
   begin
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_basicType;
   end
   else begin
      BasicType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_basicType;
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
   end; //==END== if BasicType=oobtGaseousPlanet ==//
end;

end.
