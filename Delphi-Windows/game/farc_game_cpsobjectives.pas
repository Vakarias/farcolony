{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: CPS objectives management

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
unit farc_game_cpsobjectives;

interface

uses
   Math;

   {.viability objectives types}
   {:DEV NOTES: update TFCRcpsoViabilityObjective + TFCRcpsObj + FCFuiCPS_Objective_GetFormat.}
   {:DEV NOTE: update factionsdb.xml + FCMdF_DBFactions_Read + FCMdFiles_Game_Save/Load}
   {:DEV NOTE: update FCM_ViabObj_Init + FCM_ViabObj_Load + FCF_ViabObj_Use + FCMgCPSO_Score_Update.}
   {:DEV NOTES: update TFCcps.FCM_EndPhase_Proc.}
   type TFCEcpsoObjectiveTypes=(
      {.for internal use only, do not include it in the XML and savegame file}
      otAll
      {.energy efficient}
      ,otEcoEnEff
      {.industrial force}
      ,otEcoIndustrialForce
      {.low credit line use}
      ,otEcoLowCr
      {.sustainable colony}
      ,otEcoSustCol
      {.secure population}
//      ,otSocSecPop
      );

   {.faction's viability objectives}
   type TFCRcpsoViabilityObjective = record
      case FVO_objTp: TFCEcpsoObjectiveTypes of
         otEcoEnEff: ();

         otEcoIndustrialForce: (
            FVO_ifProduct: string[20];
            FVO_ifThreshold: extended;
            );

         otEcoLowCr: ();

         otEcoSustCol: ();

//         otSocSecPop: ();
   end;

///<summary>
///   caculate the final outcome of a CPS status category based on the given mean score
///</summary>
///   <param name="ViabilityThreshold">viability threshold in the category</param>
///   <param name="MeanScore">calculated mean score in %</param>
///   <returns>the final outcome level</returns>
function FCMgCPSO_Outcome_Process( const ViabilityThreshold, MeanScore: integer ): integer;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   update the score of a specified objective
///</summary>
///   <param name="ObjectiveToUpdateIndex">index of the CPS objective to update</param>
///   <param name="isCVStoCalculate">[=true] update the CVS</param>
procedure FCMgCPSO_Score_Update(
   const ObjectiveToUpdateIndex: integer;
   const isCVStoCalculate: boolean
   );
{:DEV NOTES: put objectives score calculations in THIS procedure.}
{:DEV NOTES: move the code from game_cps.}
{:DEV NOTES: look to include it in the coredata display ! and put some link, as at the end of the prod/spm phase for each colony (and ONLY if entity=0 + colony=1 indeed).}

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_game_cps
   ,farc_game_prodSeg2;

//===================================================END OF INIT============================

function FCMgCPSO_Outcome_Process( const ViabilityThreshold, MeanScore: integer ): integer;
{:Purpose: caculate the final outcome of a CPS status category based on the given mean score.
    Additions:
}
begin
   Result:=0;
   case ViabilityThreshold of
      70:
      begin
         case MeanScore of
            0..19: Result:=0;

            20..54: Result:=1;

            55..69: Result:=2;

            70..999: Result:=3;
         end;
      end;

      85:
      begin
         case MeanScore of
            0..34: Result:=0;

            35..69: Result:=1;

            70..84: Result:=2;

            85..999: Result:=3;
         end;
      end;

      100:
      begin
         case MeanScore of
            0..49: Result:=0;

            50..84: Result:=1;

            85..99: Result:=2;

            100..999: Result:=3;
         end;
      end;

      110:
      begin
         case MeanScore of
            0..59: Result:=0;

            60..94: Result:=1;

            95..109: Result:=2;

            110..999: Result:=3;
         end;
      end;

      120:
      begin
         case MeanScore of
            0..69: Result:=0;

            70..104: Result:=1;

            105..119: Result:=2;

            120..999: Result:=3;
         end;
      end;

      130:
      begin
         case MeanScore of
            0..79: Result:=0;

            80..114: Result:=1;

            115..129: Result:=2;

            130..999: Result:=3;
         end;
      end;
   end; //==END== case ViabilityThreshold of ==//
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgCPSO_Score_Update(
   const ObjectiveToUpdateIndex: integer;
   const isCVStoCalculate: boolean
   );
{:Purpose: update the score of a specified objective.
    Additions:
      -2012May22- *mod: remove the cap of 100% on the scores.
      -2012Mar11- *add: otEcoIndustrialForce.
      -2012Mar07- *fix: otEcoEnEff - apply correction in calculation order to be in accordance to the results in the game design documents.
                  *fix: otEcoEnEff - take in account if the reserves=0, remove a calculation error with the ln().
                  *fix: otEcoLowCr - protect ln() in the calculations.
      -2012Feb15- *add: otEcoEnEff - add also the reserves in the calculations of the score.
}
   var
      CVStempo
      ,ObjectiveCount
      ,ObjectiveMax: integer;

      CreditLineInterest
      ,CreditLineMax
      ,CreditLineUsed: extended;

      SocreList: array of double;
begin
   CVStempo:=0;
   ObjectiveCount:=0;
   ObjectiveMax:=0;
   CreditLineInterest:=0;
   CreditLineMax:=0;
   CreditLineUsed:=0;
   case FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_type of
      otEcoEnEff:
      begin
         if FCentities[ 0 ].E_col[ 1 ].COL_csmENcons=0
         then FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score:=100
         else FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score:=round(
            power(
               FCFcF_Ln_Protected( FCentities[ 0 ].E_col[ 1 ].COL_csmENgen ) + FCFcF_Ln_Protected( FCentities[ 0 ].E_col[ 1 ].COL_csmENstorCurr ) - FCFcF_Ln_Protected( FCentities[ 0 ].E_col[ 1 ].COL_csmENcons )
               ,0.333
               )*60
            );
      end;

      otEcoIndustrialForce:
      begin
         CVStempo:=FCFgPS2_ProductionMatrixItem_Search(
            0
            ,1
            ,FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_ifProduct
            );
         if (CVStempo=0)
            or ( FCentities[ 0 ].E_col[ 1 ].COL_productionMatrix[ CVStempo ].CPMI_globalProdFlow<=0 )
         then FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score:=0
         else FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score:=round(
            ( FCentities[ 0 ].E_col[ 1 ].COL_productionMatrix[ CVStempo ].CPMI_globalProdFlow / FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_ifThreshold )*100
            );
      end;

      otEcoLowCr:
      begin
         CreditLineInterest:=FCcps.FCF_CredLineInterest_Get;
         CreditLineMax:=FCcps.FCF_CredLine_Get( false );
         CreditLineUsed:=FCcps.FCF_CredLine_Get( true );
         if CreditLineUsed=0
         then FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score:=100
         else FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score:=round(
            ( power( FCFcF_Ln_Protected( CreditLineMax ) - FCFcF_Ln_Protected( CreditLineUsed ), 0.333 ) *50 ) + ( ln( 5 ) - power( FCFcF_Ln_Protected( CreditLineInterest ), 2.5 ) )
            );
      end;

      otEcoSustCol:
      begin
      end;

//      otSocSecPop:
//      begin
//      end;
   end;
   if FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score<0
   then FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score:=0;
   {.update the CVS score is asked to do it}
   if isCVStoCalculate then
   begin
      CVStempo:=0;
      ObjectiveMax:=length( FCcps.CPSviabObj )-1;
      setlength( SocreList, ObjectiveMax );
      ObjectiveCount:=1;
      while ObjectiveCount<=ObjectiveMax-1 do
      begin
         SocreList[ ObjectiveCount-1 ]:=FCcps.CPSviabObj[ ObjectiveCount ].CPSO_score;
         inc( ObjectiveCount );
      end;
      CVStempo:=round( mean( SocreList ) );
      FCcps.FCM_CVS_update( CVStempo );
   end;
end;

end.
