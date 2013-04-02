{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: stars data calculations core unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2012, Jean-Francois Baconnet

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
unit farc_fug_stars;

interface

uses
   Math

   ,DecimalRounding_JH1

   ,farc_data_univ;

{:DEV NOTES: move in implementation section.}
type TFCRfsClassDat=record
   private
   FSCD_class: TFCEduStarClasses;
   FSCD_temp: integer;
   FSCD_mass: extended;
   FSCD_diam: extended;
   FSCD_lum: extended;
end;

///<summary>
///   calculate companion star specific data
///</summary>
///   <param name="CSCstIdx">star's index#</param>
procedure FCMfS_CompStar_Calc(const CSCstIdx: integer);

///<summary>
///   load the initial data for the requested star
///</summary>
///   <param name="DLstIdx">star's index#</param>
procedure FCMfS_Data_Load(const DLstIdx: integer);

///<summary>
///   calculate the star's diameter
///</summary>
///   <param name="DCstar">star's index#</param>
///   <param name=""></param>
function FCFfS_Diameter_Calc(const DCstar: integer): extended;

///<summary>
///   calculate the star's luminosity
///</summary>
///   <param name="LCstar">star's index#</param>
function FCFfS_Luminosity_Calc(const LCstar: integer): extended;

///<summary>
///   calculate the star's mass
///</summary>
///   <param name="TMstar">star's index#</param>
function FCFfS_Mass_Calc(const TMstar: integer): extended;

///<summary>
///   calculate the star's temperature
///</summary>
///   <param name="TCstar">star's index#</param>
function FCFfS_Temperature_Calc(const TCstar: integer): integer;

implementation

uses
   farc_common_func;

var
   FSCD: TFCRfsClassDat;

//=======================================END OF INIT========================================

procedure FCMfS_CompEcc_Calc(const CECstIdx: integer);
var
   CECstat
   ,CECmod: integer;

   CECbase
   ,CECbasef
   ,CECcalc
   ,CECecc
   ,CECeccMax
   ,CECend
   ,CECendf: extended;
begin
   if CECstIdx=2 then
   begin
      CECcalc:=(FCDduStarSystem[0].SS_stars[CECstIdx].S_isCompMeanSeparation-0.25)/FCDduStarSystem[0].SS_stars[CECstIdx].S_isCompMeanSeparation;
      CECeccMax:=DecimalRound(CECcalc, 3, 0.0001);
      CECstat:=FCFcF_Random_DoInteger(99)+1;
      CECmod:=FCFcF_Random_DoInteger(9)+1;
      case CECstat of
         1..20:
         begin
            CECend:=CECeccMax*0.2;
            CECendf:=DecimalRound(CECend, 3, 0.0001);
            CECecc:=CECmod*(CECendf*0.1);
         end;
         21..40:
         begin
            CECbase:=CECeccMax*0.1;
            CECbasef:=DecimalRound(CECbase, 3, 0.0001);
            CECend:=CECeccMax*0.2;
            CECendf:=DecimalRound(CECend, 3, 0.0001);
            CECecc:=CECbasef+(CECmod*(CECendf*0.1));
         end;
         41..60:
         begin
            CECbase:=CECeccMax*0.2;
            CECbasef:=DecimalRound(CECbase, 3, 0.0001);
            CECend:=CECeccMax*0.2;
            CECendf:=DecimalRound(CECend, 3, 0.0001);
            CECecc:=CECbasef+(CECmod*(CECendf*0.1));
         end;
         61..80:
         begin
            CECbase:=CECeccMax*0.3;
            CECbasef:=DecimalRound(CECbase, 3, 0.0001);
            CECend:=CECeccMax*0.2;
            CECendf:=DecimalRound(CECend, 3, 0.0001);
            CECecc:=CECbasef+(CECmod*(CECendf*0.1));
         end;
         81..90:
         begin
            CECbase:=CECeccMax*0.4;
            CECbasef:=DecimalRound(CECbase, 3, 0.0001);
            CECend:=CECeccMax*0.2;
            CECendf:=DecimalRound(CECend, 3, 0.0001);
            CECecc:=CECbasef+(CECmod*(CECendf*0.1));
         end;
         91..100:
         begin
            CECbase:=CECeccMax*0.5;
            CECbasef:=DecimalRound(CECbase, 3, 0.0001);
            CECendf:=CECbasef;
            CECecc:=CECbasef+(CECmod*(CECendf*0.1));
         end;
      end; //==END== case CECstat of ==//
   end //==END== if CECstIdx=2 then ==//
   else if CECstIdx=3
   then
   begin
      if (FCDduStarSystem[0].SS_stars[CECstIdx].S_isCompStar2OrbitType=cotAroundMain_Companion1)
         or (FCDduStarSystem[0].SS_stars[CECstIdx].S_isCompStar2OrbitType=cotAroundCompanion1)
      then
      begin
         CECcalc:=(FCDduStarSystem[0].SS_stars[CECstIdx].S_isCompMeanSeparation-0.25)/FCDduStarSystem[0].SS_stars[CECstIdx].S_isCompMeanSeparation;
         CECeccMax:=DecimalRound(CECcalc, 3, 0.0001);
      end
      else if FCDduStarSystem[0].SS_stars[CECstIdx].S_isCompStar2OrbitType=cotAroundMain_Companion1GravityCenter
      then
      begin
         CECcalc:=(
            (FCDduStarSystem[0].SS_stars[CECstIdx].S_isCompMeanSeparation-FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance+0.25)
            -(FCDduStarSystem[0].SS_stars[2].S_isCompMeanSeparation+FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance)
            )
            /(FCDduStarSystem[0].SS_stars[CECstIdx].S_isCompMeanSeparation - FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance+0.25);
         CECeccMax:=DecimalRound(CECcalc, 3, 0.0001);
      end;
      CECmod:=FCFcF_Random_DoInteger(99)+1;
      CECecc:=CECmod*(CECeccMax*0.01);
   end;
   FCDduStarSystem[0].SS_stars[CECstIdx].S_isCompEccentricity:=DecimalRound(CECecc, 3, 0.0001);
end;

procedure FCMfS_CompStar_Calc(const CSCstIdx: integer);
{:Purpose: calculate companion star specific data.
}
var
   CSCmod
   ,CSCstat
   ,CSCstatsub: integer;

   CSCecc
   ,CSCmsep
   ,CSCmad: extended;
begin
   if CSCstIdx=2
   then
   begin
      {mean separation}
      CSCstat:=FCFcF_Random_DoInteger(9)+1;
      CSCmod:=FCFcF_Random_DoInteger(9)+1;
      //            if DBStarSys[1].Sys_StarAge >= 5  then inc(CSstat)
//            else if DBStarSys[1].Sys_StarAge <= 1  then dec(CSstat);
      case CSCstat of
         0..3: CSCmsep:=CSCmod*0.25;
         4..6: CSCmsep:=CSCmod*2.5;
         7..8: CSCmsep:=CSCmod*15;
         9: CSCmsep:=CSCmod*100;
         10:
         begin
            CSCstatsub:=FCFcF_Random_DoInteger(99)+1;
            CSCmsep:=CSCstatsub*200;
         end;
      end;
      FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMeanSeparation:=DecimalRound(CSCmsep, 2, 0.001);
      {.eccentricity}
      FCMfS_CompEcc_Calc(CSCstIdx);
      CSCmad:=FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMeanSeparation*(1-FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompEccentricity);
      FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMinApproachDistance:=DecimalRound(CSCmad, 2, 0.001);
   end //==END== if CSCstIdx=2 ==//
   else if CSCstIdx=3
   then
   begin
      CSCstat:=FCFcF_Random_DoInteger(10);
      case CSCstat of
         0..6:
         begin
            if CSCstat<4
            then FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompStar2OrbitType:=cotAroundMain_Companion1
            else FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompStar2OrbitType:=cotAroundCompanion1;
            CSCmod:=FCFcF_Random_DoInteger(9)+1;
            CSCmsep:=(((FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance*0.5)-(FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance*0.1))*0.1)*CSCmod;
            FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMeanSeparation:=DecimalRound(CSCmsep, 2, 0.001);
            FCMfS_CompEcc_Calc(CSCstIdx);
            CSCmad:=FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMeanSeparation*(1-FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompEccentricity);
            FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMinApproachDistance:=DecimalRound(CSCmad, 2, 0.001);
         end;
         7..10:
         begin
            FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompStar2OrbitType:=cotAroundMain_Companion1GravityCenter;
            CSCmod:=FCFcF_Random_DoInteger(100);
            CSCmad:=(((FCDduStarSystem[0].SS_stars[2].S_isCompMeanSeparation+FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance)*0.5)+0.25)*(1+(CSCmod*0.1));
            FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMinApproachDistance:=DecimalRound(CSCmad, 2, 0.001);
            CSCstat:=FCFcF_Random_DoInteger(9)+1;
            CSCmod:=FCFcF_Random_DoInteger(9)+1;
            case CSCstat of
               0..3: CSCmsep:=FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMinApproachDistance+(CSCmod*0.25);
               4..6: CSCmsep:=FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMinApproachDistance+(CSCmod*2.5);
               7..8: CSCmsep:=FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMinApproachDistance+(CSCmod*15);
               9: CSCmsep:=FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMinApproachDistance+(CSCmod*100);
               10:
               begin
                  CSCmod:=FCFcF_Random_DoInteger(99)+1;
                  CSCmsep:=FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMinApproachDistance+(CSCmod*200);
               end;
            end;
            FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMeanSeparation:=DecimalRound(CSCmsep, 2, 0.001);
            CSCecc:=FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMinApproachDistance/FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompMeanSeparation;
            FCDduStarSystem[0].SS_stars[CSCstIdx].S_isCompEccentricity:=DecimalRound(CSCecc, 3, 0.0001);
         end;
      end; //==END== case CSCstat of ==//
   end;
end;

function FCFfS_Data_WDLum(const DWDLidx: integer): extended;
{:Purpose: calculate the luminosity for White Dwarves
}
var
   DWDLlum: extended;
begin
   Result:=0;
   DWDLlum:=(sqr(FCDduStarSystem[0].SS_stars[DWDLidx].S_diameter*0.5)*power(FCDduStarSystem[0].SS_stars[DWDLidx].S_temperature,4))/power(5800,4);
   Result:=DecimalRound(DWDLlum, 5, 0.000001);
   if Result<=0
   then Result:=0.00001;
end;

procedure FCMfS_Data_Load(const DLstIdx: integer);
{:Purpose: load the initial data for the requested star.
    Additions:
}
var
   DLdiam: extended;
begin
   FSCD.FSCD_class:=FCDduStarSystem[0].SS_stars[DLstIdx].S_class;
   case FSCD.FSCD_class of
      cB5:
      begin
         FSCD.FSCD_temp:=15000;
         FSCD.FSCD_mass:=25;
         FSCD.FSCD_diam:=30;
         FSCD.FSCD_lum:=250000;
      end;
      cB6:
      begin
         FSCD.FSCD_temp:=14320;
         FSCD.FSCD_mass:=23;
         FSCD.FSCD_diam:=32;
         FSCD.FSCD_lum:=200000;
      end;
      cB7:
      begin
         FSCD.FSCD_temp:=13640;
         FSCD.FSCD_mass:=21;
         FSCD.FSCD_diam:=34;
         FSCD.FSCD_lum:=150000;
      end;
      cB8:
      begin
         FSCD.FSCD_temp:=12960;
         FSCD.FSCD_mass:=19;
         FSCD.FSCD_diam:=36;
         FSCD.FSCD_lum:=100000;
      end;
      cB9:
      begin
         FSCD.FSCD_temp:=12280;
         FSCD.FSCD_mass:=17;
         FSCD.FSCD_diam:=38;
         FSCD.FSCD_lum:=50000;
      end;
      cA0:
      begin
         FSCD.FSCD_temp:=12000;
         FSCD.FSCD_mass:=16;
         FSCD.FSCD_diam:=140;
         FSCD.FSCD_lum:=20000;
      end;
      cA1:
      begin
         FSCD.FSCD_temp:=11240;
         FSCD.FSCD_mass:=15;
         FSCD.FSCD_diam:=56;
         FSCD.FSCD_lum:=18770;
      end;
      cA2:
      begin
         FSCD.FSCD_temp:=10480;
         FSCD.FSCD_mass:=14;
         FSCD.FSCD_diam:=73;
         FSCD.FSCD_lum:=17550;
      end;
      cA3:
      begin
         FSCD.FSCD_temp:=9720;
         FSCD.FSCD_mass:=13;
         FSCD.FSCD_diam:=90;
         FSCD.FSCD_lum:=16330;
      end;
      cA4:
      begin
         FSCD.FSCD_temp:=8960;
         FSCD.FSCD_mass:=12;
         FSCD.FSCD_diam:=106;
         FSCD.FSCD_lum:=15110;
      end;
      cA5:
      begin
         FSCD.FSCD_temp:=8200;
         FSCD.FSCD_mass:=11;
         FSCD.FSCD_diam:=123;
         FSCD.FSCD_lum:=13880;
      end;
      cA6:
      begin
         FSCD.FSCD_temp:=7300;
         FSCD.FSCD_mass:=10;
         FSCD.FSCD_diam:=140;
         FSCD.FSCD_lum:=12660;
      end;
      cA7:
      begin
         FSCD.FSCD_temp:=6400;
         FSCD.FSCD_mass:=9;
         FSCD.FSCD_diam:=156;
         FSCD.FSCD_lum:=11440;
      end;
      cA8:
      begin
         FSCD.FSCD_temp:=5500;
         FSCD.FSCD_mass:=8;
         FSCD.FSCD_diam:=173;
         FSCD.FSCD_lum:=10220;
      end;
      cA9:
      begin
         FSCD.FSCD_temp:=4600;
         FSCD.FSCD_mass:=7;
         FSCD.FSCD_diam:=190;
         FSCD.FSCD_lum:=9000;
      end;
      cK0:
      begin
         FSCD.FSCD_temp:=4400;
         FSCD.FSCD_mass:=3;
         FSCD.FSCD_diam:=200;
         FSCD.FSCD_lum:=8000;
      end;
      cK1:
      begin
         FSCD.FSCD_temp:=4280;
         FSCD.FSCD_mass:=2.9;
         FSCD.FSCD_diam:=230;
         FSCD.FSCD_lum:=7550;
      end;
      cK2:
      begin
         FSCD.FSCD_temp:=4160;
         FSCD.FSCD_mass:=2.85;
         FSCD.FSCD_diam:=260;
         FSCD.FSCD_lum:=7510;
      end;
      cK3:
      begin
         FSCD.FSCD_temp:=4040;
         FSCD.FSCD_mass:=2.8;
         FSCD.FSCD_diam:=290;
         FSCD.FSCD_lum:=7260;
      end;
      cK4:
      begin
         FSCD.FSCD_temp:=3920;
         FSCD.FSCD_mass:=2.7;
         FSCD.FSCD_diam:=315;
         FSCD.FSCD_lum:=7020;
      end;
      cK5:
      begin
         FSCD.FSCD_temp:=3810;
         FSCD.FSCD_mass:=2.65;
         FSCD.FSCD_diam:=340;
         FSCD.FSCD_lum:=6770;
      end;
      cK6:
      begin
         FSCD.FSCD_temp:=3690;
         FSCD.FSCD_mass:=2.6;
         FSCD.FSCD_diam:=370;
         FSCD.FSCD_lum:=6530;
      end;
      cK7:
      begin
         FSCD.FSCD_temp:=3570;
         FSCD.FSCD_mass:=2.5;
         FSCD.FSCD_diam:=400;
         FSCD.FSCD_lum:=6290;
      end;
      cK8:
      begin
         FSCD.FSCD_temp:=3450;
         FSCD.FSCD_mass:=2.45;
         FSCD.FSCD_diam:=430;
         FSCD.FSCD_lum:=6040;
      end;
      cK9:
      begin
         FSCD.FSCD_temp:=3340;
         FSCD.FSCD_mass:=2.4;
         FSCD.FSCD_diam:=460;
         FSCD.FSCD_lum:=5800;
      end;
      cM0:
      begin
         FSCD.FSCD_temp:=3300;
         FSCD.FSCD_mass:=16;
         FSCD.FSCD_diam:=500;
         FSCD.FSCD_lum:=30000;
      end;
      cM1:
      begin
         FSCD.FSCD_temp:=3140;
         FSCD.FSCD_mass:=15.4;
         FSCD.FSCD_diam:=600;
         FSCD.FSCD_lum:=27600;
      end;
      cM2:
      begin
         FSCD.FSCD_temp:=2980;
         FSCD.FSCD_mass:=14.9;
         FSCD.FSCD_diam:=700;
         FSCD.FSCD_lum:=25200;
      end;
      cM3:
      begin
         FSCD.FSCD_temp:=2820;
         FSCD.FSCD_mass:=14.3;
         FSCD.FSCD_diam:=800;
         FSCD.FSCD_lum:=22800;
      end;
      cM4:
      begin
         FSCD.FSCD_temp:=2660;
         FSCD.FSCD_mass:=13.8;
         FSCD.FSCD_diam:=900;
         FSCD.FSCD_lum:=20400;
      end;
      cM5:
      begin
         FSCD.FSCD_temp:=2500;
         FSCD.FSCD_mass:=13.3;
         FSCD.FSCD_diam:=1000;
         FSCD.FSCD_lum:=18000 ;
      end;
      gF0:
      begin
         FSCD.FSCD_temp:=6920;
         FSCD.FSCD_mass:=8;
         FSCD.FSCD_diam:=4.7;
         FSCD.FSCD_lum:=53;
      end;
      gF1:
      begin
         FSCD.FSCD_temp:=6770;
         FSCD.FSCD_mass:=7;
         FSCD.FSCD_diam:=4.8;
         FSCD.FSCD_lum:=51;
      end;
      gF2:
      begin
         FSCD.FSCD_temp:=6620;
         FSCD.FSCD_mass:=6;
         FSCD.FSCD_diam:=4.9;
         FSCD.FSCD_lum:=49;
      end;
      gF3:
      begin
         FSCD.FSCD_temp:=6470;
         FSCD.FSCD_mass:=5.2;
         FSCD.FSCD_diam:=5.1;
         FSCD.FSCD_lum:=47;
      end;
      gF4:
      begin
         FSCD.FSCD_temp:=6320;
         FSCD.FSCD_mass:=4.7;
         FSCD.FSCD_diam:=5.2;
         FSCD.FSCD_lum:=46;
      end;
      gF5:
      begin
         FSCD.FSCD_temp:=6170;
         FSCD.FSCD_mass:=4.3;
         FSCD.FSCD_diam:=5.4;
         FSCD.FSCD_lum:=45;
      end;
      gF6:
      begin
         FSCD.FSCD_temp:=6020;
         FSCD.FSCD_mass:=3.9;
         FSCD.FSCD_diam:=5.7;
         FSCD.FSCD_lum:=46;
      end;
      gF7:
      begin
         FSCD.FSCD_temp:=5870;
         FSCD.FSCD_mass:=3.5;
         FSCD.FSCD_diam:=6.1;
         FSCD.FSCD_lum:=47;
      end;
      gF8:
      begin
         FSCD.FSCD_temp:=5720;
         FSCD.FSCD_mass:=3.1;
         FSCD.FSCD_diam:=6.5;
         FSCD.FSCD_lum:=49;
      end;
      gF9:
      begin
         FSCD.FSCD_temp:=5620;
         FSCD.FSCD_mass:=2.8;
         FSCD.FSCD_diam:=6.8;
         FSCD.FSCD_lum:=49;
      end;
      gG0:
      begin
         FSCD.FSCD_temp:=5520;
         FSCD.FSCD_mass:=2.5;
         FSCD.FSCD_diam:=7.1;
         FSCD.FSCD_lum:=50;
      end;
      gG1:
      begin
         FSCD.FSCD_temp:=5420;
         FSCD.FSCD_mass:=2.4;
         FSCD.FSCD_diam:=7.7;
         FSCD.FSCD_lum:=55;
      end;
      gG2:
      begin
         FSCD.FSCD_temp:=5320;
         FSCD.FSCD_mass:=2.5;
         FSCD.FSCD_diam:=8.3;
         FSCD.FSCD_lum:=60;
      end;
      gG3:
      begin
         FSCD.FSCD_temp:=5220;
         FSCD.FSCD_mass:=2.5;
         FSCD.FSCD_diam:=9;
         FSCD.FSCD_lum:=65;
      end;
      gG4:
      begin
         FSCD.FSCD_temp:=5120;
         FSCD.FSCD_mass:=2.6;
         FSCD.FSCD_diam:=9.7;
         FSCD.FSCD_lum:=70;
      end;
      gG5:
      begin
         FSCD.FSCD_temp:=4970;
         FSCD.FSCD_mass:=2.7;
         FSCD.FSCD_diam:=10.7;
         FSCD.FSCD_lum:=77;
      end;
      gG6:
      begin
         FSCD.FSCD_temp:=4820;
         FSCD.FSCD_mass:=2.7;
         FSCD.FSCD_diam:=11.9;
         FSCD.FSCD_lum:=85;
      end;
      gG7:
      begin
         FSCD.FSCD_temp:=4670;
         FSCD.FSCD_mass:=2.8;
         FSCD.FSCD_diam:=13.2;
         FSCD.FSCD_lum:=92;
      end;
      gG8:
      begin
         FSCD.FSCD_temp:=4520;
         FSCD.FSCD_mass:=2.8;
         FSCD.FSCD_diam:=14.7;
         FSCD.FSCD_lum:=101;
      end;
      gG9:
      begin
         FSCD.FSCD_temp:=4370;
         FSCD.FSCD_mass:=2.8;
         FSCD.FSCD_diam:=16.3;
         FSCD.FSCD_lum:=110;
      end;
      gK0:
      begin
         FSCD.FSCD_temp:=4220;
         FSCD.FSCD_mass:=3;
         FSCD.FSCD_diam:=18.2;
         FSCD.FSCD_lum:=120;
      end;
      gK1:
      begin
         FSCD.FSCD_temp:=4120;
         FSCD.FSCD_mass:=3.3;
         FSCD.FSCD_diam:=20.4;
         FSCD.FSCD_lum:=140;
      end;
      gK2:
      begin
         FSCD.FSCD_temp:=4020;
         FSCD.FSCD_mass:=3.6;
         FSCD.FSCD_diam:=22.8;
         FSCD.FSCD_lum:=160;
      end;
      gK3:
      begin
         FSCD.FSCD_temp:=3920;
         FSCD.FSCD_mass:=3.9;
         FSCD.FSCD_diam:=25.6;
         FSCD.FSCD_lum:=180;
      end;
      gK4:
      begin
         FSCD.FSCD_temp:=3820;
         FSCD.FSCD_mass:=4.2;
         FSCD.FSCD_diam:=28.8;
         FSCD.FSCD_lum:=210;
      end;
      gK5:
      begin
         FSCD.FSCD_temp:=3720;
         FSCD.FSCD_mass:=4.5;
         FSCD.FSCD_diam:=32.4;
         FSCD.FSCD_lum:=240;
      end;
      gK6:
      begin
         FSCD.FSCD_temp:=3620;
         FSCD.FSCD_mass:=4.8;
         FSCD.FSCD_diam:=36.5;
         FSCD.FSCD_lum:=270;
      end;
      gK7:
      begin
         FSCD.FSCD_temp:=3520;
         FSCD.FSCD_mass:=5.1;
         FSCD.FSCD_diam:=41.2;
         FSCD.FSCD_lum:=310;
      end;
      gK8:
      begin
         FSCD.FSCD_temp:=3420;
         FSCD.FSCD_mass:=5.4;
         FSCD.FSCD_diam:=46.5;
         FSCD.FSCD_lum:=360;
      end;
      gK9:
      begin
         FSCD.FSCD_temp:=3270;
         FSCD.FSCD_mass:=5.6;
         FSCD.FSCD_diam:=54;
         FSCD.FSCD_lum:=410;
      end;
      gM0:
      begin
         FSCD.FSCD_temp:=3120;
         FSCD.FSCD_mass:=6.2;
         FSCD.FSCD_diam:=63;
         FSCD.FSCD_lum:=470;
      end;
      gM1:
      begin
         FSCD.FSCD_temp:=2920;
         FSCD.FSCD_mass:=6.4;
         FSCD.FSCD_diam:=80;
         FSCD.FSCD_lum:=600;
      end;
      gM2:
      begin
         FSCD.FSCD_temp:=2820;
         FSCD.FSCD_mass:=6.6;
         FSCD.FSCD_diam:=105;
         FSCD.FSCD_lum:=900;
      end;
      gM3:
      begin
         FSCD.FSCD_temp:=2720;
         FSCD.FSCD_mass:=6.8;
         FSCD.FSCD_diam:=135;
         FSCD.FSCD_lum:=1300;
      end;
      gM4:
      begin
         FSCD.FSCD_temp:=2520;
         FSCD.FSCD_mass:=7.2;
         FSCD.FSCD_diam:=180;
         FSCD.FSCD_lum:=1800;
      end;
      gM5:
      begin
         FSCD.FSCD_temp:=2370;
         FSCD.FSCD_mass:=7.4;
         FSCD.FSCD_diam:=230;
         FSCD.FSCD_lum:=2300;
      end;
      O5:
      begin
         FSCD.FSCD_temp:=40000;
         FSCD.FSCD_mass:=60;
         FSCD.FSCD_diam:=15;
         FSCD.FSCD_lum:=14600;
      end;
      O6:
      begin
         FSCD.FSCD_temp:=37250;
         FSCD.FSCD_mass:=37;
         FSCD.FSCD_diam:=12.9;
         FSCD.FSCD_lum:=12000;
      end;
      O7:
      begin
         FSCD.FSCD_temp:=34500;
         FSCD.FSCD_mass:=30;
         FSCD.FSCD_diam:=11.8;
         FSCD.FSCD_lum:=9350;
      end;
      O8:
      begin
         FSCD.FSCD_temp:=31750;
         FSCD.FSCD_mass:=26;
         FSCD.FSCD_diam:=10.8;
         FSCD.FSCD_lum:=6960;
      end;
      O9:
      begin
         FSCD.FSCD_temp:=29000;
         FSCD.FSCD_mass:=23.3;
         FSCD.FSCD_diam:=9.56;
         FSCD.FSCD_lum:=4820;
      end;
      B0:
      begin
         FSCD.FSCD_temp:=27700;
         FSCD.FSCD_mass:=17.5;
         FSCD.FSCD_diam:=8.47;
         FSCD.FSCD_lum:=13000;
      end;
      B1:
      begin
         FSCD.FSCD_temp:=24700;
         FSCD.FSCD_mass:=14.2;
         FSCD.FSCD_diam:=6.56;
         FSCD.FSCD_lum:=7800;
      end;
      B2:
      begin
         FSCD.FSCD_temp:=21700;
         FSCD.FSCD_mass:=10.9;
         FSCD.FSCD_diam:=5.22;
         FSCD.FSCD_lum:=4700;
      end;
      B3:
      begin
         FSCD.FSCD_temp:=18700;
         FSCD.FSCD_mass:=7.6;
         FSCD.FSCD_diam:=4.17;
         FSCD.FSCD_lum:=2800;
      end;
      B4:
      begin
         FSCD.FSCD_temp:=16700;
         FSCD.FSCD_mass:=6.5;
         FSCD.FSCD_diam:=4.11;
         FSCD.FSCD_lum:=1700;
      end;
      B5:
      begin
         FSCD.FSCD_temp:=14700;
         FSCD.FSCD_mass:=5.9;
         FSCD.FSCD_diam:=4.06;
         FSCD.FSCD_lum:=1000;
      end;
      B6:
      begin
         FSCD.FSCD_temp:=13700;
         FSCD.FSCD_mass:=5.2;
         FSCD.FSCD_diam:=3.81;
         FSCD.FSCD_lum:=600;
      end;
      B7:
      begin
         FSCD.FSCD_temp:=12700;
         FSCD.FSCD_mass:=4.5;
         FSCD.FSCD_diam:=3.54;
         FSCD.FSCD_lum:=370;
      end;
      B8:
      begin
         FSCD.FSCD_temp:=11700;
         FSCD.FSCD_mass:=3.8;
         FSCD.FSCD_diam:=3.17;
         FSCD.FSCD_lum:=220;
      end;
      B9:
      begin
         FSCD.FSCD_temp:=10700;
         FSCD.FSCD_mass:=3.35;
         FSCD.FSCD_diam:=2.96;
         FSCD.FSCD_lum:=130;
      end;
      A0:
      begin
         FSCD.FSCD_temp:=9720;
         FSCD.FSCD_mass:=2.9;
         FSCD.FSCD_diam:=2.71;
         FSCD.FSCD_lum:=80;
      end;
      A1:
      begin
         FSCD.FSCD_temp:=9470;
         FSCD.FSCD_mass:=2.72;
         FSCD.FSCD_diam:=2.32;
         FSCD.FSCD_lum:=62;
      end;
      A2:
      begin
         FSCD.FSCD_temp:=9220;
         FSCD.FSCD_mass:=2.54;
         FSCD.FSCD_diam:=2.12;
         FSCD.FSCD_lum:=48;
      end;
      A3:
      begin
         FSCD.FSCD_temp:=8970;
         FSCD.FSCD_mass:=2.36;
         FSCD.FSCD_diam:=2.01;
         FSCD.FSCD_lum:=38;
      end;
      A4:
      begin
         FSCD.FSCD_temp:=8720;
         FSCD.FSCD_mass:=2.2;
         FSCD.FSCD_diam:=1.92;
         FSCD.FSCD_lum:=29;
      end;
      A5:
      begin
         FSCD.FSCD_temp:=8470;
         FSCD.FSCD_mass:=2;
         FSCD.FSCD_diam:=1.86;
         FSCD.FSCD_lum:=23;
      end;
      A6:
      begin
         FSCD.FSCD_temp:=8220;
         FSCD.FSCD_mass:=1.9;
         FSCD.FSCD_diam:=1.81;
         FSCD.FSCD_lum:=18;
      end;
      A7:
      begin
         FSCD.FSCD_temp:=7970;
         FSCD.FSCD_mass:=1.84;
         FSCD.FSCD_diam:=1.76;
         FSCD.FSCD_lum:=14;
      end;
      A8:
      begin
         FSCD.FSCD_temp:=7720;
         FSCD.FSCD_mass:=1.76;
         FSCD.FSCD_diam:=1.71;
         FSCD.FSCD_lum:=11;
      end;
      A9:
      begin
         FSCD.FSCD_temp:=7470;
         FSCD.FSCD_mass:=1.4;
         FSCD.FSCD_diam:=1.6;
         FSCD.FSCD_lum:=8.2;
      end;
      F0:
      begin
         FSCD.FSCD_temp:=7220;
         FSCD.FSCD_mass:=1.6;
         FSCD.FSCD_diam:=1.64;
         FSCD.FSCD_lum:=6.38;
      end;
      F1:
      begin
         FSCD.FSCD_temp:=7070;
         FSCD.FSCD_mass:=1.53;
         FSCD.FSCD_diam:=1.5;
         FSCD.FSCD_lum:=5.5;
      end;
      F2:
      begin
         FSCD.FSCD_temp:=6920;
         FSCD.FSCD_mass:=1.47;
         FSCD.FSCD_diam:=1.46;
         FSCD.FSCD_lum:=4.7;
      end;
      F3:
      begin
         FSCD.FSCD_temp:=6770;
         FSCD.FSCD_mass:=1.42;
         FSCD.FSCD_diam:=1.4;
         FSCD.FSCD_lum:=4;
      end;
      F4:
      begin
         FSCD.FSCD_temp:=6620;
         FSCD.FSCD_mass:=1.36;
         FSCD.FSCD_diam:=1.35;
         FSCD.FSCD_lum:=3.4;
      end;
      F5:
      begin
         FSCD.FSCD_temp:=6470;
         FSCD.FSCD_mass:=1.31;
         FSCD.FSCD_diam:=1.3;
         FSCD.FSCD_lum:=2.9;
      end;
      F6:
      begin
         FSCD.FSCD_temp:=6320;
         FSCD.FSCD_mass:=1.26;
         FSCD.FSCD_diam:=1.28;
         FSCD.FSCD_lum:=2.5;
      end;
      F7:
      begin
         FSCD.FSCD_temp:=6170;
         FSCD.FSCD_mass:=1.21;
         FSCD.FSCD_diam:=1.25;
         FSCD.FSCD_lum:=2.16;
      end;
      F8:
      begin
         FSCD.FSCD_temp:=6020;
         FSCD.FSCD_mass:=1.19;
         FSCD.FSCD_diam:=1.22;
         FSCD.FSCD_lum:=1.85;
      end;
      F9:
      begin
         FSCD.FSCD_temp:=5870;
         FSCD.FSCD_mass:=1.12;
         FSCD.FSCD_diam:=1.1;
         FSCD.FSCD_lum:=1.58;
      end;
      G0:
      begin
         FSCD.FSCD_temp:=5720;
         FSCD.FSCD_mass:=1.08;
         FSCD.FSCD_diam:=1.13;
         FSCD.FSCD_lum:=1.36;
      end;
      G1:
      begin
         FSCD.FSCD_temp:=5620;
         FSCD.FSCD_mass:=1.05;
         FSCD.FSCD_diam:=1.1;
         FSCD.FSCD_lum:=1.21;
      end;
      G2:
      begin
         FSCD.FSCD_temp:=5520;
         FSCD.FSCD_mass:=1.02;
         FSCD.FSCD_diam:=1.07;
         FSCD.FSCD_lum:=1.09;
      end;
      G3:
      begin
         FSCD.FSCD_temp:=5420;
         FSCD.FSCD_mass:=0.99;
         FSCD.FSCD_diam:=1.04;
         FSCD.FSCD_lum:=0.98;
      end;
      G4:
      begin
         FSCD.FSCD_temp:=5320;
         FSCD.FSCD_mass:=0.96;
         FSCD.FSCD_diam:=1.01;
         FSCD.FSCD_lum:=0.88;
      end;
      G5:
      begin
         FSCD.FSCD_temp:=5220;
         FSCD.FSCD_mass:=0.94;
         FSCD.FSCD_diam:=0.99;
         FSCD.FSCD_lum:=0.79;
      end;
      G6:
      begin
         FSCD.FSCD_temp:=5120;
         FSCD.FSCD_mass:=0.92;
         FSCD.FSCD_diam:=0.97;
         FSCD.FSCD_lum:=0.71;
      end;
      G7:
      begin
         FSCD.FSCD_temp:=5020;
         FSCD.FSCD_mass:=0.89;
         FSCD.FSCD_diam:=0.93;
         FSCD.FSCD_lum:=0.64;
      end;
      G8:
      begin
         FSCD.FSCD_temp:=4920;
         FSCD.FSCD_mass:=0.87;
         FSCD.FSCD_diam:=0.875;
         FSCD.FSCD_lum:=0.57;
      end;
      G9:
      begin
         FSCD.FSCD_temp:=4820;
         FSCD.FSCD_mass:=0.85;
         FSCD.FSCD_diam:=0.8;
         FSCD.FSCD_lum:=0.51;
      end;
      K0:
      begin
         FSCD.FSCD_temp:=4700;
         FSCD.FSCD_mass:=0.82;
         FSCD.FSCD_diam:=0.98;
         FSCD.FSCD_lum:=0.46;
      end;
      K1:
      begin
         FSCD.FSCD_temp:=4570;
         FSCD.FSCD_mass:=0.79;
         FSCD.FSCD_diam:=0.95;
         FSCD.FSCD_lum:=0.35;
      end;
      K2:
      begin
         FSCD.FSCD_temp:=4420;
         FSCD.FSCD_mass:=0.75;
         FSCD.FSCD_diam:=0.92;
         FSCD.FSCD_lum:=0.32;
      end;
      K3:
      begin
         FSCD.FSCD_temp:=4270;
         FSCD.FSCD_mass:=0.72;
         FSCD.FSCD_diam:=0.88;
         FSCD.FSCD_lum:=0.27;
      end;
      K4:
      begin
         FSCD.FSCD_temp:=4120;
         FSCD.FSCD_mass:=0.69;
         FSCD.FSCD_diam:=0.87;
         FSCD.FSCD_lum:=0.23;
      end;
      K5:
      begin
         FSCD.FSCD_temp:=3970;
         FSCD.FSCD_mass:=0.66;
         FSCD.FSCD_diam:=0.86;
         FSCD.FSCD_lum:=0.19;
      end;
      K6:
      begin
         FSCD.FSCD_temp:=3820;
         FSCD.FSCD_mass:=0.63;
         FSCD.FSCD_diam:=0.85;
         FSCD.FSCD_lum:=0.16;
      end;
      K7:
      begin
         FSCD.FSCD_temp:=3670;
         FSCD.FSCD_mass:=0.61;
         FSCD.FSCD_diam:=0.84;
         FSCD.FSCD_lum:=0.14;
      end;
      K8:
      begin
         FSCD.FSCD_temp:=3520;
         FSCD.FSCD_mass:=0.56;
         FSCD.FSCD_diam:=0.83;
         FSCD.FSCD_lum:=0.11;
      end;
      K9:
      begin
         FSCD.FSCD_temp:=3370;
         FSCD.FSCD_mass:=0.49;
         FSCD.FSCD_diam:=0.82;
         FSCD.FSCD_lum:=0.1;
      end;
      M0:
      begin
         FSCD.FSCD_temp:=3200;
         FSCD.FSCD_mass:=0.46;
         FSCD.FSCD_diam:=0.8;
         FSCD.FSCD_lum:=0.08;
      end;
      M1:
      begin
         FSCD.FSCD_temp:=3070;
         FSCD.FSCD_mass:=0.38;
         FSCD.FSCD_diam:=0.6;
         FSCD.FSCD_lum:=0.04;
      end;
      M2:
      begin
         FSCD.FSCD_temp:=2920;
         FSCD.FSCD_mass:=0.32;
         FSCD.FSCD_diam:=0.5;
         FSCD.FSCD_lum:=0.02;
      end;
      M3:
      begin
         FSCD.FSCD_temp:=2770;
         FSCD.FSCD_mass:=0.26;
         FSCD.FSCD_diam:=0.4;
         FSCD.FSCD_lum:=0.012;
      end;
      M4:
      begin
         FSCD.FSCD_temp:=2620;
         FSCD.FSCD_mass:=0.21;
         FSCD.FSCD_diam:=0.3;
         FSCD.FSCD_lum:=0.006;
      end;
      M5:
      begin
         FSCD.FSCD_temp:=2470;
         FSCD.FSCD_mass:=0.18;
         FSCD.FSCD_diam:=0.25;
         FSCD.FSCD_lum:=0.003;
      end;
      M6:
      begin
         FSCD.FSCD_temp:=2320;
         FSCD.FSCD_mass:=0.15;
         FSCD.FSCD_diam:=0.2;
         FSCD.FSCD_lum:=0.0017;
      end;
      M7:
      begin
         FSCD.FSCD_temp:=2170;
         FSCD.FSCD_mass:=0.12;
         FSCD.FSCD_diam:=0.17;
         FSCD.FSCD_lum:=0.0009;
      end;
      M8:
      begin
         FSCD.FSCD_temp:=1920;
         FSCD.FSCD_mass:=0.1;
         FSCD.FSCD_diam:=0.14;
         FSCD.FSCD_lum:=0.0005;
      end;
      M9:
      begin
         FSCD.FSCD_temp:=1720;
         FSCD.FSCD_mass:=0.08;
         FSCD.FSCD_diam:=0.11;
         FSCD.FSCD_lum:=0.0002;
      end;
      WD0:
      begin
         FSCD.FSCD_temp:=30000;
         FSCD.FSCD_mass:=1.3;
         FSCD.FSCD_diam:=0.004;
         FSCD.FSCD_lum:=0;
      end;
      WD1:
      begin
         FSCD.FSCD_temp:=25000;
         FSCD.FSCD_mass:=1.21;
         FSCD.FSCD_diam:=0.007;
         FSCD.FSCD_lum:=0;
      end;
      WD2:
      begin
         FSCD.FSCD_temp:=20000;
         FSCD.FSCD_mass:=0.99;
         FSCD.FSCD_diam:=0.009;
         FSCD.FSCD_lum:=0;
      end;
      WD3:
      begin
         FSCD.FSCD_temp:=16000;
         FSCD.FSCD_mass:=0.77;
         FSCD.FSCD_diam:=0.01;
         FSCD.FSCD_lum:=0;
      end;
      WD4:
      begin
         FSCD.FSCD_temp:=14000;
         FSCD.FSCD_mass:=0.66;
         FSCD.FSCD_diam:=0.011;
         FSCD.FSCD_lum:=0;
      end;
      WD5:
      begin
         FSCD.FSCD_temp:=12000;
         FSCD.FSCD_mass:=0.6;
         FSCD.FSCD_diam:=0.012;
         FSCD.FSCD_lum:=0;
      end;
      WD6:
      begin
         FSCD.FSCD_temp:=10000;
         FSCD.FSCD_mass:=0.55;
         FSCD.FSCD_diam:=0.013;
         FSCD.FSCD_lum:=0;
      end;
      WD7:
      begin
         FSCD.FSCD_temp:=8000;
         FSCD.FSCD_mass:=0.49;
         FSCD.FSCD_diam:=0.014;
         FSCD.FSCD_lum:=0;
      end;
      WD8:
      begin
         FSCD.FSCD_temp:=6000;
         FSCD.FSCD_mass:=0.44;
         FSCD.FSCD_diam:=0.015;
         FSCD.FSCD_lum:=0;
      end;
      WD9:
      begin
         FSCD.FSCD_temp:=4000;
         FSCD.FSCD_mass:=0.38;
         FSCD.FSCD_diam:=0.016;
         FSCD.FSCD_lum:=0;
      end;
      PSR:
      begin
         FSCD.FSCD_temp:=1;
         FSCD.FSCD_mass:=1.5;
         FSCD.FSCD_diam:=0.01;
         FSCD.FSCD_lum:=0.0003;
      end;
      BH:
      begin
         FSCD.FSCD_temp:=1;
         FSCD.FSCD_mass:=5+FCFcF_Random_DoInteger(5);
         DLdiam:=((2*6.67e-11*(1.989e30*FCDduStarSystem[0].SS_stars[DLstIdx].S_mass))/299792458)*(2/1390000);
         FSCD.FSCD_diam:=FCFcF_Round( rttCustom2Decimal, DLdiam );
         if DLdiam<=0
         then DLdiam:=0.01;
         FSCD.FSCD_lum:=0.00001;
      end;
   end; //==END== case DLclass of ==//
end;

function FCFfS_Diameter_Calc(const DCstar: integer): extended;
{:Purpose: calculate the star's diameter.
    Additions:
}
var
   DCdiam: extended;
begin
   Result:=0;
   if FCDduStarSystem[0].SS_stars[DCstar].S_class<>FSCD.FSCD_class
   then FCMfS_Data_Load(DCstar);
   if FCDduStarSystem[0].SS_stars[DCstar].S_class<PSR
   then
   begin
      DCdiam:=randg(FSCD.FSCD_diam,0.007);
      Result:=DecimalRound(DCdiam, 2, 0.001);
      if Result<=0
      then Result:=0.01;
   end
   else Result:=FSCD.FSCD_diam;
end;

function FCFfS_Luminosity_Calc(const LCstar: integer): extended;
{:Purpose: calculate the star's luminosity.
    Additions:
}
var
   DClum: extended;
begin
   Result:=0;
   if FCDduStarSystem[0].SS_stars[LCstar].S_class<>FSCD.FSCD_class
   then FCMfS_Data_Load(LCstar);
   if FCDduStarSystem[0].SS_stars[LCstar].S_class<PSR
   then
   begin
      DClum:=randg(FSCD.FSCD_lum,0.007);
      Result:=DecimalRound(DClum, 5, 0.000001);
      if Result<=0
      then Result:=0.00001;
   end
   else if FCDduStarSystem[0].SS_stars[LCstar].S_class in [WD0..WD9]
   then
   begin
      FSCD.FSCD_lum:=FCFfS_Data_WDLum(LCstar);
      Result:=FSCD.FSCD_lum;
   end
   else Result:=FSCD.FSCD_lum;
end;

function FCFfS_Mass_Calc(const TMstar: integer): extended;
{:Purpose: calculate the star's mass.
    Additions:
}
var
   TMmass: extended;
begin
   Result:=0;
   if FCDduStarSystem[0].SS_stars[TMstar].S_class<>FSCD.FSCD_class
   then FCMfS_Data_Load(TMstar);
   TMmass:=randg(FSCD.FSCD_mass,0.007);
   Result:=DecimalRound(TMmass, 2, 0.001);
   if Result<=0
   then Result:=0.01;
end;

function FCFfS_Temperature_Calc(const TCstar: integer): integer;
{:Purpose: calculate the star's temperature.
    Additions:
}
begin
   Result:=0;
   if FCDduStarSystem[0].SS_stars[TCstar].S_class<>FSCD.FSCD_class
   then FCMfS_Data_Load(TCstar);
   if FCDduStarSystem[0].SS_stars[TCstar].S_class<PSR
   then Result:=round(randg(FSCD.FSCD_temp,50))
   else Result:=FSCD.FSCD_temp
end;

end.
