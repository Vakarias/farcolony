{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: CPS objectives management

============================================================================================
********************************************************************************************
Copyright (c) 2009-2011, Jean-Francois Baconnet

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
   {:DEV NOTES: update TFCRcpsObj.}
   {:DEV NOTE: update factionsdb.xml + FCMdFiles_DBFactions_Read + FCMdFiles_Game_Save/Load}
   {:DEV NOTE: update FCM_ViabObj_Init + FCF_ViabObj_Use + FCF_ViabObj_GetIdx + FCMgCPSO_Score_Update.}
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
      ,otSocSecPop
      );

   {.faction's viability objectives}
   type TFCRcpsoViabilityObjective = record
      FVO_objTp: TFCEcpsoObjectiveTypes;
   end;

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
   ,farc_game_cps;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgCPSO_Score_Update(
   const ObjectiveToUpdateIndex: integer;
   const isCVStoCalculate: boolean
   );
{:Purpose: update the score of a specified objective.
    Additions:
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
            power( FCFcF_Ln_Protected( FCentities[ 0 ].E_col[ 1 ].COL_csmENgen ) + FCFcF_Ln_Protected( FCentities[ 0 ].E_col[ 1 ].COL_csmENstorCurr ) - FCFcF_Ln_Protected( FCentities[ 0 ].E_col[ 1 ].COL_csmENcons ), 0.333 )*60
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

      otSocSecPop:
      begin
      end;
   end;
   if FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score<0
   then FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score:=0
   else if FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score>100
   then FCcps.CPSviabObj[ ObjectiveToUpdateIndex ].CPSO_score:=100;
   {.update the CVS score is asked to do it}
   if isCVStoCalculate then
   begin
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
