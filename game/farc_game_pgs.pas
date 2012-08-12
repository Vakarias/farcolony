{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: population growth system (PGS) - core unit

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

unit farc_game_pgs;

interface

uses
   SysUtils

   ,DecimalRounding_JH1;

///<summary>
///   calculate the birth rate of a choosed colony
///</summary>
///   <param name="BRCfac">faction index number</param>
///   <param name="BRCcol">colony index number</param>
procedure FCMgPGS_BR_Calc(
   const BRCfac
         ,BRCcol: integer
   );

///<summary>
///   calculate the death rate of a choosed colony
///</summary>
///   <param name="DRCfac">faction index number</param>
///   <param name="DRCcol">colony index number</param>
procedure FCMgPGS_DR_Calc(
   const DRCfac
         ,DRCcol: integer
   );

///<summary>
///   update the mean age of the population of a colony after a population transfert
///</summary>
///   <param name="MAUXfac">faction index number</param>
///   <param name="MAUXcol">colony index number</param>
///   <param name="MAUXsendPop">population sent from sender</param>
///   <param name="MAUXsendMA">sender's mean age</param>
procedure FCMgPGS_MeanAge_UpdXfert(
   const MAUXfac
         ,MAUXcol
         ,MAUXsendPop
         ,MAUXsendMA: integer
   );

implementation

uses
   farc_data_game
   ,farc_game_csm
   ,farc_win_debug;

//===================================================END OF INIT============================

procedure FCMgPGS_BR_Calc(
   const BRCfac
         ,BRCcol: integer
   );
{:Purpose: calculate the birth rate of a choosed colony.
    Additions:
      -2010Sep25- *add: SPM modifiers in calculations, where it's needed.
      -2010Sep11- *add: entities code.
      -2010Aug10- *mod/add: final complete rewrite of the birth rate calculations and fertility tables.
}
var
   BRChealth
   ,BRCpop
   ,BRCqol
   ,BRCspmNat
   ,BRCtension: integer;

   BRCbrCateg
   ,BRCfertAdS
   ,BRCfertAS
   ,BRCfertBS
   ,BRCfertCol
   ,BRCfertES
   ,BRCfertIS
   ,BRCfertMS
   ,BRCfertPS
   ,BRCfinal
   ,BRCpopAmedian
   ,BRCpopAmedianFert
   ,BRCpopASmiSp
   ,BRCpopASmiSpFert
   ,BRCpopASoff
   ,BRCpopASoffFert
   ,BRCpopBSbio
   ,BRCpopBSbioFert
   ,BRCpopBSdoc
   ,BRCpopBSdocFert
   ,BRCpopCol
   ,BRCpopColFert
   ,BRCpopESecof
   ,BRCpopESecofFert
   ,BRCpopESecol
   ,BRCpopESecolFert
   ,BRCpopISeng
   ,BRCpopISengFert
   ,BRCpopIStech
   ,BRCpopIStechFert
   ,BRCpopMScomm
   ,BRCpopMScommFert
   ,BRCpopMSsold
   ,BRCpopMSsoldFert
   ,BRCpopPSastr
   ,BRCpopPSastrFert
   ,BRCpopPSphys
   ,BRCpopPSphysFert
   ,BRCspm: extended;
begin
   BRCpopAmedianFert:=0;
   BRCpopASmiSpFert:=0;
   BRCpopASoffFert:=0;
   BRCpopBSbioFert:=0;
   BRCpopBSdocFert:=0;
   BRCpopColFert:=0;
   BRCpopESecofFert:=0;
   BRCpopESecolFert:=0;
   BRCpopISengFert:=0;
   BRCpopIStechFert:=0;
   BRCpopMScommFert:=0;
   BRCpopMSsoldFert:=0;
   BRCpopPSastrFert:=0;
   BRCpopPSphysFert:=0;
   BRCbrCateg:=0;
   BRCfertAdS:=0;
   BRCfertAS:=0;
   BRCfertBS:=0;
   BRCfertCol:=0;
   BRCfertES:=0;
   BRCfertIS:=0;
   BRCfertMS:=0;
   BRCfertPS:=0;
   BRCfinal:=0;
   BRCpop:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_total;
   BRChealth:=FCFgCSM_Health_GetIdx( BRCfac, BRCcol );
   BRCqol:=FCentities[BRCfac].E_col[BRCcol].COL_csmHOqol;
   BRCtension:=StrToInt(
      FCFgCSM_Tension_GetIdx(
         BRCfac
         ,BRCcol
         ,true
         )
      );
   BRCpopAmedian:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classAdmMedian;
   BRCpopASmiSp:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classAerMissionSpecialist;
   BRCpopASoff:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classAerOfficer;
   BRCpopBSbio:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classBioBiologist;
   BRCpopBSdoc:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classBioDoctor;
   BRCpopCol:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classColonist;
   BRCpopESecof:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classEcoEcoformer;
   BRCpopESecol:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classEcoEcologist;
   BRCpopISeng:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classIndEngineer;
   BRCpopIStech:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classIndTechnician;
   BRCpopMScomm:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classMilCommando;
   BRCpopMSsold:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classMilSoldier;
   BRCpopPSastr:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classPhyAstrophysicist;
   BRCpopPSphys:=FCentities[BRCfac].E_col[BRCcol].COL_population.CP_classPhyPhysicist;
   case BRCtension of
      1:
      begin
         case BRChealth of
            1:
            begin
               BRCfertCol:=1.49;
               BRCfertAS:=0.13;
               BRCfertBS:=1.06;
               BRCfertIS:=0.85;
               BRCfertMS:=0.43;
               BRCfertPS:=0.64;
               BRCfertES:=1.28;
               BRCfertAdS:=1.7;
            end;
            2:
            begin
               BRCfertCol:=1.65;
               BRCfertAS:=0.14;
               BRCfertBS:=1.18;
               BRCfertIS:=0.94;
               BRCfertMS:=0.47;
               BRCfertPS:=0.71;
               BRCfertES:=1.41;
               BRCfertAdS:=1.88;
            end;
            3:
            begin
               BRCfertCol:=1.75;
               BRCfertAS:=0.15;
               BRCfertBS:=1.25;
               BRCfertIS:=1;
               BRCfertMS:=0.5;
               BRCfertPS:=0.75;
               BRCfertES:=1.5;
               BRCfertAdS:=2;
            end;
            4:
            begin
               BRCfertCol:=2.8;
               BRCfertAS:=0.24;
               BRCfertBS:=2;
               BRCfertIS:=1.6;
               BRCfertMS:=0.8;
               BRCfertPS:=1.2;
               BRCfertES:=2.4;
               BRCfertAdS:=3.2;
            end;
            5:
            begin
               BRCfertCol:=3.43;
               BRCfertAS:=0.29;
               BRCfertBS:=2.45;
               BRCfertIS:=1.96;
               BRCfertMS:=0.98;
               BRCfertPS:=1.47;
               BRCfertES:=2.94;
               BRCfertAdS:=3.92;
            end;
            6:
            begin
               BRCfertCol:=4.06;
               BRCfertAS:=0.35;
               BRCfertBS:=2.9;
               BRCfertIS:=2.32;
               BRCfertMS:=1.16;
               BRCfertPS:=1.74;
               BRCfertES:=3.48;
               BRCfertAdS:=4.64;
            end;
         end;//==END== case BRChealth of ==//
      end; //==END== case BRCtension: 1 ==//
      2:
      begin
         case BRChealth of
            1:
            begin
               BRCfertCol:=1.39;
               BRCfertAS:=0.2;
               BRCfertBS:=1;
               BRCfertIS:=0.8;
               BRCfertMS:=0.4;
               BRCfertPS:=0.6;
               BRCfertES:=1.2;
               BRCfertAdS:=1.6;
            end;
            2:
            begin
               BRCfertCol:=1.49;
               BRCfertAS:=0.22;
               BRCfertBS:=1.07;
               BRCfertIS:=0.86;
               BRCfertMS:=0.43;
               BRCfertPS:=0.64;
               BRCfertES:=1.29;
               BRCfertAdS:=1.71;
            end;
            3:
            begin
               BRCfertCol:=1.66;
               BRCfertAS:=0.24;
               BRCfertBS:=1.19;
               BRCfertIS:=0.95;
               BRCfertMS:=0.48;
               BRCfertPS:=0.71;
               BRCfertES:=1.43;
               BRCfertAdS:=1.9;
            end;
            4:
            begin
               BRCfertCol:=2.46;
               BRCfertAS:=0.36;
               BRCfertBS:=1.76;
               BRCfertIS:=1.41;
               BRCfertMS:=0.71;
               BRCfertPS:=1.05;
               BRCfertES:=2.12;
               BRCfertAdS:=2.81;
            end;
            5:
            begin
               BRCfertCol:=3.05;
               BRCfertAS:=0.44;
               BRCfertBS:=2.19;
               BRCfertIS:=1.75;
               BRCfertMS:=0.88;
               BRCfertPS:=1.31;
               BRCfertES:=2.63;
               BRCfertAdS:=3.5;
            end;
            6:
            begin
               BRCfertCol:=3.45;
               BRCfertAS:=0.5;
               BRCfertBS:=2.48;
               BRCfertIS:=1.98;
               BRCfertMS:=1;
               BRCfertPS:=1.48;
               BRCfertES:=2.97;
               BRCfertAdS:=3.95;
            end;
         end;//==END== case BRChealth of ==//
      end; //==END== case BRCtension: 2 ==//
      3:
      begin
         case BRChealth of
            1:
            begin
               BRCfertCol:=1.19;
               BRCfertAS:=0.17;
               BRCfertBS:=0.85;
               BRCfertIS:=0.68;
               BRCfertMS:=0.34;
               BRCfertPS:=0.51;
               BRCfertES:=1.02;
               BRCfertAdS:=1.36;
            end;
            2:
            begin
               BRCfertCol:=1.27;
               BRCfertAS:=0.18;
               BRCfertBS:=0.9;
               BRCfertIS:=0.72;
               BRCfertMS:=0.37;
               BRCfertPS:=0.54;
               BRCfertES:=1.09;
               BRCfertAdS:=1.45;
            end;
            3:
            begin
               BRCfertCol:=1.49;
               BRCfertAS:=0.21;
               BRCfertBS:=1.06;
               BRCfertIS:=0.85;
               BRCfertMS:=0.43;
               BRCfertPS:=0.64;
               BRCfertES:=1.28;
               BRCfertAdS:=1.7;
            end;
            4:
            begin
               BRCfertCol:=1.94;
               BRCfertAS:=0.27;
               BRCfertBS:=1.38;
               BRCfertIS:=1.11;
               BRCfertMS:=0.56;
               BRCfertPS:=0.83;
               BRCfertES:=1.66;
               BRCfertAdS:=2.21;
            end;
            5:
            begin
               BRCfertCol:=2.24;
               BRCfertAS:=0.32;
               BRCfertBS:=1.59;
               BRCfertIS:=1.28;
               BRCfertMS:=0.65;
               BRCfertPS:=0.96;
               BRCfertES:=1.92;
               BRCfertAdS:=2.55;
            end;
            6:
            begin
               BRCfertCol:=2.53;
               BRCfertAS:=0.36;
               BRCfertBS:=1.8;
               BRCfertIS:=1.45;
               BRCfertMS:=0.73;
               BRCfertPS:=1.09;
               BRCfertES:=2.18;
               BRCfertAdS:=2.89;
            end;
         end;//==END== case BRChealth of ==//
      end; //==END== case BRCtension: 3 ==//
      4:
      begin
         case BRChealth of
            1:
            begin
               BRCfertCol:=0.96;
               BRCfertAS:=0.14;
               BRCfertBS:=0.69;
               BRCfertIS:=0.55;
               BRCfertMS:=0.28;
               BRCfertPS:=0.41;
               BRCfertES:=0.82;
               BRCfertAdS:=1.1;
            end;
            2:
            begin
               BRCfertCol:=1.03;
               BRCfertAS:=0.15;
               BRCfertBS:=0.74;
               BRCfertIS:=0.59;
               BRCfertMS:=0.3;
               BRCfertPS:=0.44;
               BRCfertES:=0.89;
               BRCfertAdS:=1.19;
            end;
            3:
            begin
               BRCfertCol:=1.31;
               BRCfertAS:=0.19;
               BRCfertBS:=0.94;
               BRCfertIS:=0.75;
               BRCfertMS:=0.38;
               BRCfertPS:=0.56;
               BRCfertES:=1.13;
               BRCfertAdS:=1.5;
            end;
            4:
            begin
               BRCfertCol:=1.47;
               BRCfertAS:=0.21;
               BRCfertBS:=1.05;
               BRCfertIS:=0.84;
               BRCfertMS:=0.43;
               BRCfertPS:=0.63;
               BRCfertES:=1.27;
               BRCfertAdS:=1.68;
            end;
            5:
            begin
               BRCfertCol:=1.62;
               BRCfertAS:=0.24;
               BRCfertBS:=1.17;
               BRCfertIS:=0.93;
               BRCfertMS:=0.47;
               BRCfertPS:=0.69;
               BRCfertES:=1.4;
               BRCfertAdS:=1.86;
            end;
            6:
            begin
               BRCfertCol:=1.7;
               BRCfertAS:=0.25;
               BRCfertBS:=1.22;
               BRCfertIS:=0.98;
               BRCfertMS:=0.49;
               BRCfertPS:=0.73;
               BRCfertES:=1.47;
               BRCfertAdS:=1.95;
            end;
         end;//==END== case BRChealth of ==//
      end; //==END== case BRCtension: 4 ==//
      5:
      begin
         case BRChealth of
            1:
            begin
               BRCfertCol:=0.71;
               BRCfertAS:=0.1;
               BRCfertBS:=0.5;
               BRCfertIS:=0.4;
               BRCfertMS:=0.2;
               BRCfertPS:=0.3;
               BRCfertES:=0.61;
               BRCfertAdS:=0.81;
            end;
            2:
            begin
               BRCfertCol:=0.82;
               BRCfertAS:=0.12;
               BRCfertBS:=0.58;
               BRCfertIS:=0.47;
               BRCfertMS:=0.24;
               BRCfertPS:=0.35;
               BRCfertES:=0.71;
               BRCfertAdS:=0.94;
            end;
            3:
            begin
               BRCfertCol:=1.14;
               BRCfertAS:=0.16;
               BRCfertBS:=0.81;
               BRCfertIS:=0.65;
               BRCfertMS:=0.33;
               BRCfertPS:=0.49;
               BRCfertES:=0.98;
               BRCfertAdS:=1.3;
            end;
            4:
            begin
               BRCfertCol:=1.22;
               BRCfertAS:=0.17;
               BRCfertBS:=0.87;
               BRCfertIS:=0.7;
               BRCfertMS:=0.35;
               BRCfertPS:=0.52;
               BRCfertES:=1.05;
               BRCfertAdS:=1.39;
            end;
            5:
            begin
               BRCfertCol:=1.3;
               BRCfertAS:=0.18;
               BRCfertBS:=0.92;
               BRCfertIS:=0.74;
               BRCfertMS:=0.38;
               BRCfertPS:=0.56;
               BRCfertES:=1.12;
               BRCfertAdS:=1.48;
            end;
            6:
            begin
               BRCfertCol:=1.38;
               BRCfertAS:=0.19;
               BRCfertBS:=0.98;
               BRCfertIS:=0.79;
               BRCfertMS:=0.4;
               BRCfertPS:=0.59;
               BRCfertES:=1.19;
               BRCfertAdS:=1.57;
            end;
         end;//==END== case BRChealth of ==//
      end; //==END== case BRCtension: 5 ==//
   end; //==END== case BRCtension of ==//
   if BRCpopAmedian>0
   then BRCpopAmedianFert:=(BRCpopAmedian/BRCpop)*BRCfertAdS;
   if BRCpopASmiSp>0
   then BRCpopASmiSpFert:=(BRCpopASmiSp/BRCpop)*BRCfertAS;
   if BRCpopASoff>0
   then BRCpopASoffFert:=(BRCpopASoff/BRCpop)*BRCfertAS;
   if BRCpopBSbio>0
   then BRCpopBSbioFert:=(BRCpopBSbio/BRCpop)*BRCfertBS;
   if BRCpopBSdoc>0
   then BRCpopBSdocFert:=(BRCpopBSdoc/BRCpop)*BRCfertBS;
   if BRCpopCol>0
   then BRCpopColFert:=(BRCpopCol/BRCpop)*BRCfertCol;
   if BRCpopESecof>0
   then BRCpopESecofFert:=(BRCpopESecof/BRCpop)*BRCfertES;
   if BRCpopESecol>0
   then BRCpopESecolFert:=(BRCpopESecol/BRCpop)*BRCfertES;
   if BRCpopISeng>0
   then BRCpopISengFert:=(BRCpopISeng/BRCpop)*BRCfertIS;
   if BRCpopIStech>0
   then BRCpopIStechFert:=(BRCpopIStech/BRCpop)*BRCfertIS;
   if BRCpopMScomm>0
   then BRCpopMScommFert:=(BRCpopMScomm/BRCpop)*BRCfertMS;
   if BRCpopMSsold>0
   then BRCpopMSsoldFert:=(BRCpopMSsold/BRCpop)*BRCfertMS;
   if BRCpopPSastr>0
   then BRCpopPSastrFert:=(BRCpopPSastr/BRCpop)*BRCfertPS;
   if BRCpopPSphys>0
   then BRCpopPSphysFert:=(BRCpopPSphys/BRCpop)*BRCfertPS;
   BRCbrCateg:=(BRCpopAmedianFert+BRCpopASmiSpFert+BRCpopASoffFert+BRCpopBSbioFert+BRCpopBSdocFert+BRCpopColFert+BRCpopESecofFert
      +BRCpopESecolFert+BRCpopISengFert+BRCpopIStechFert+BRCpopMScommFert+BRCpopMSsoldFert+BRCpopPSastrFert+BRCpopPSphysFert);
   BRCspmNat:=FCentities[BRCfac].E_spmMnat;
   if BRCspmNat<-100
   then BRCspmNat:=-100;
   BRCspm:=BRCbrCateg*((100+BRCspmNat)*0.01);
   BRCfinal:=(BRCspm*(BRCpop*0.5))/(75-((BRCspm*1.664)+0.68));
   FCentities[BRCfac].E_col[BRCcol].COL_population.CP_birthRate:=DecimalRound(BRCfinal, 4, 0.00001);
end;


procedure FCMgPGS_DR_Calc(
   const DRCfac
         ,DRCcol: integer
   );
{:Purpose: calculate the death rate of a choosed colony.
    Additions:
      -2010Sep14- *add: entities code.
      -2010Aug10- *fix: loading population types correctly.
                  *mod: death rate calculations completion.
}
var
   DRChealth
  ,DRCpop
   ,DRCpopAmedian
   ,DRCpopAmedianRsk
   ,DRCpopASmiSp
   ,DRCpopASmiSpRsk
   ,DRCpopASoff
   ,DRCpopASoffRsk
   ,DRCpopBSbio
   ,DRCpopBSbioRsk
   ,DRCpopBSdoc
   ,DRCpopBSdocRsk
   ,DRCpopCol
   ,DRCpopColRsk
   ,DRCpopESecof
   ,DRCpopESecofRsk
   ,DRCpopESecol
   ,DRCpopESecolRsk
   ,DRCpopISeng
   ,DRCpopISengRsk
   ,DRCpopIStech
   ,DRCpopIStechRsk
   ,DRCpopMScomm
   ,DRCpopMScommRsk
   ,DRCpopMSsold
   ,DRCpopMSsoldRsk
   ,DRCpopPSastr
   ,DRCpopPSastrRsk
   ,DRCpopPSphys
   ,DRCpopPSphysRsk
   ,DRCrf1
   ,DRCrf2
   ,DRCrf3
   ,DRCrf4
   ,DRCrf5
   ,DRCtRiskF: integer;

   DRCbasicDR
   ,DRCmA
   ,DRCfinalDR
   ,DRCmodDR: extended;
begin
   DRChealth:=0;
   DRCpop:=0;
   DRCpopAmedian:=0;
   DRCpopAmedianRsk:=0;
   DRCpopASmiSp:=0;
   DRCpopASmiSpRsk:=0;
   DRCpopASoff:=0;
   DRCpopASoffRsk:=0;
   DRCpopBSbio:=0;
   DRCpopBSbioRsk:=0;
   DRCpopBSdoc:=0;
   DRCpopBSdocRsk:=0;
   DRCpopCol:=0;
   DRCpopColRsk:=0;
   DRCpopESecof:=0;
   DRCpopESecofRsk:=0;
   DRCpopESecol:=0;
   DRCpopESecolRsk:=0;
   DRCpopISeng:=0;
   DRCpopISengRsk:=0;
   DRCpopIStech:=0;
   DRCpopIStechRsk:=0;
   DRCpopMScomm:=0;
   DRCpopMScommRsk:=0;
   DRCpopMSsold:=0;
   DRCpopMSsoldRsk:=0;
   DRCpopPSastr:=0;
   DRCpopPSastrRsk:=0;
   DRCpopPSphys:=0;
   DRCpopPSphysRsk:=0;
   DRCrf1:=0;
   DRCrf2:=0;
   DRCrf3:=0;
   DRCrf4:=0;
   DRCrf5:=0;
   DRCtRiskF:=0;
   DRCbasicDR:=0;
   DRCmA:=0;
   DRCfinalDR:=0;
   DRCmodDR:=0;
   DRChealth:=FCFgCSM_Health_GetIdx( DRCfac, DRCcol );
   DRCpop:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_total;
   DRCmA:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_meanAge;
   DRCpopAmedian:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classAdmMedian;
   DRCpopASmiSp:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classAerMissionSpecialist;
   DRCpopASoff:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classAerOfficer;
   DRCpopBSbio:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classBioBiologist;
   DRCpopBSdoc:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classBioDoctor;
   DRCpopCol:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classColonist;
   DRCpopESecof:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classEcoEcoformer;
   DRCpopESecol:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classEcoEcologist;
   DRCpopISeng:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classIndEngineer;
   DRCpopIStech:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classIndTechnician;
   DRCpopMScomm:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classMilCommando;
   DRCpopMSsold:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classMilSoldier;
   DRCpopPSastr:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classPhyAstrophysicist;
   DRCpopPSphys:=FCentities[DRCfac].E_col[DRCcol].COL_population.CP_classPhyPhysicist;
   DRCbasicDR:=(DRCmA*0.07)/25.3;
   case DRChealth of
      1:
      begin
         DRCrf1:=98;
         DRCrf2:=130;
         DRCrf3:=156;
         DRCrf4:=195;
         DRCrf5:=260;
      end;
      2:
      begin
         DRCrf1:=90;
         DRCrf2:=120;
         DRCrf3:=144;
         DRCrf4:=180;
         DRCrf5:=240;
      end;
      3:
      begin
         DRCrf1:=83;
         DRCrf2:=110;
         DRCrf3:=132;
         DRCrf4:=165;
         DRCrf5:=220;
      end;
      4:
      begin
         DRCrf1:=75;
         DRCrf2:=100;
         DRCrf3:=120;
         DRCrf4:=150;
         DRCrf5:=200;
      end;
      5:
      begin
         DRCrf1:=70;
         DRCrf2:=93;
         DRCrf3:=112;
         DRCrf4:=140;
         DRCrf5:=186;
      end;
      6:
      begin
         DRCrf1:=64;
         DRCrf2:=85;
         DRCrf3:=102;
         DRCrf4:=128;
         DRCrf5:=170;
      end;
   end; //==END== case DRChealth of ==//
   if DRCpopAmedian>0
   then DRCpopAmedianRsk:=(DRCpopAmedian div DRCpop)*DRCrf1;
   if DRCpopASmiSp>0
   then DRCpopASmiSpRsk:=(DRCpopASmiSp div DRCpop)*DRCrf4;
   if DRCpopASoff>0
   then DRCpopASoffRsk:=(DRCpopASoff div DRCpop)*DRCrf4;
   if DRCpopBSbio>0
   then DRCpopBSbioRsk:=(DRCpopBSbio div DRCpop)*DRCrf2;
   if DRCpopBSdoc>0
   then DRCpopBSdocRsk:=(DRCpopBSdoc div DRCpop)*DRCrf2;
   if DRCpopCol>0
   then DRCpopColRsk:=(DRCpopCol div DRCpop)*DRCrf2;
   if DRCpopESecof>0
   then DRCpopESecofRsk:=(DRCpopESecof div DRCpop)*DRCrf1;
   if DRCpopESecol>0
   then DRCpopESecolrsk:=(DRCpopESecol div DRCpop)*DRCrf1;
   if DRCpopISeng>0
   then DRCpopISengRsk:=(DRCpopISeng div DRCpop)*DRCrf3;
   if DRCpopIStech>0
   then DRCpopIStechRsk:=(DRCpopIStech div DRCpop)*DRCrf3;
   if DRCpopMScomm>0
   then DRCpopMScommRsk:=(DRCpopMScomm div DRCpop)*DRCrf5;
   if DRCpopMSsold>0
   then DRCpopMSsoldRsk:=(DRCpopMSsold div DRCpop)*DRCrf5;
   if DRCpopPSastr>0
   then DRCpopPSastrRsk:=(DRCpopPSastr div DRCpop)*DRCrf2;
   if DRCpopPSphys>0
   then DRCpopPSphysRsk:=(DRCpopPSphys div DRCpop)*DRCrf2;
   DRCtRiskF:=DRCpopAmedianRsk+DRCpopASmiSpRsk+DRCpopASoffRsk+DRCpopBSbioRsk+DRCpopBSdocRsk+DRCpopColRsk+DRCpopESecofRsk
      +DRCpopESecolrsk+DRCpopISengRsk+DRCpopIStechRsk+DRCpopMScommRsk+DRCpopMSsoldRsk+DRCpopPSastrRsk+DRCpopPSphysRsk;
   DRCmodDR:=DRCbasicDR*(DRCtRiskF*0.01);
   DRCfinalDR:=DRCmodDR*(DRCpop*0.1);
   FCentities[DRCfac].E_col[DRCcol].COL_population.CP_deathRate:=DecimalRound(DRCfinalDR, 4, 0.00001);
end;

procedure FCMgPGS_MeanAge_UpdXfert(
   const MAUXfac
         ,MAUXcol
         ,MAUXsendPop
         ,MAUXsendMA: integer
   );
{:Purpose: update the mean age of the population of a colony after a population transfert.
    Additions:
      -2010Sep14- *add: entities code.
}
var
   MAUXmeanA: extended;
begin
   MAUXmeanA
      :=FCentities[MAUXfac].E_col[MAUXcol].COL_population.CP_meanAge
         -(
            (FCentities[MAUXfac].E_col[MAUXcol].COL_population.CP_meanAge-MAUXsendMA)
            *(MAUXsendPop/FCentities[MAUXfac].E_col[MAUXcol].COL_population.CP_total)
            );
   FCentities[MAUXfac].E_col[MAUXcol].COL_population.CP_meanAge:=DecimalRound(MAUXmeanA, 1, 0.01);
end;

end.
