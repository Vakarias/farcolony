{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructure's power/energy management

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
unit farc_game_infrapower;

interface

   uses
      SysUtils;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   update the CSM-Energy data of a colony
///</summary>
///   <param name=CSMEUent">entity index</param>
///   <param name="CSMEUcol">colony index</param>
///   <param name="CSMEUisFullCalculation">true= process full calculation, the next parameters must be at 0</param>
///   <param name="CSMEUcons">for [CSMEUisFullCalculation=false] update in + or - the energy consumed in the colony</param>
///   <param name="CSMEUgen">for [CSMEUisFullCalculation=false] update in + or - the energy generated in the colony</param>
///   <param name="CSMEUstorCurr">for [CSMEUisFullCalculation=false] update in + or - the current energy stored in the colony</param>
///   <param name="CSMEUstorMax">for [CSMEUisFullCalculation=false] update in + or - the maximum energy that can be stored in the colony</param>
procedure FCMgIP_CSMEnergy_Update(
   const CSMEUent
         ,CSMEUcol: integer;
   const CSMEUisFullCalculation: boolean;
   const CSMEUcons
         ,CSMEUgen
         ,CSMEUstorCurr
         ,CSMEUstorMax: double
   );

implementation

uses
   farc_data_game
   ,farc_data_infrprod
   ,farc_ui_coldatapanel
   ,farc_win_debug;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgIP_CSMEnergy_Update(
   const CSMEUent
         ,CSMEUcol: integer;
   const CSMEUisFullCalculation: boolean;
   const CSMEUcons
         ,CSMEUgen
         ,CSMEUstorCurr
         ,CSMEUstorMax: double
   );
{:Purpose: update the CSM-Energy data of a colony.
    Additions:
      -2011Jul23- *fix: correction in energy storage/current value calculation.
      -2011Jul19- *add: a new parameter for update the current energy storage.
                  *add: update the Colony Data Panel if this one is opened with the current colony.
      -2011Jul17- *fix: in the case of not CSMEUisFullCalculation, load the correct variable for energy consumption and storage.
}
   var
      CSMEUinfraCnt
      ,CSMEUinfraMax
      ,CSMEUsettleCnt
      ,CSMEUsettleMax: integer;

      CSMEUisShown: boolean;
begin
if not CSMEUisFullCalculation
   then
   begin
      if CSMEUcons>0
      then FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENcons:=FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENcons+CSMEUcons;
      if CSMEUgen>0
      then FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENgen:=FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENgen+CSMEUgen;
      if CSMEUstorCurr>0
      then FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENstorCurr:=FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENstorCurr+CSMEUstorCurr;
      if CSMEUstorMax>0
      then FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENstorMax:=FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENstorMax+CSMEUstorMax;
   end
   else if CSMEUisFullCalculation
   then
   begin
      FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENcons:=0;
      FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENgen:=0;
      FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENstorMax:=0;
      CSMEUsettleMax:=length(FCentities[CSMEUent].E_col[CSMEUcol].COL_settlements)-1;
      CSMEUsettleCnt:=1;
      while CSMEUsettleCnt<=CSMEUsettleMax do
      begin
         CSMEUinfraMax:=Length(FCentities[CSMEUent].E_col[CSMEUcol].COL_settlements[CSMEUsettleCnt].CS_infra)-1;
         CSMEUinfraCnt:=1;
         while CSMEUinfraCnt<=CSMEUinfraMax do
         begin
            if (
               (FCentities[CSMEUent].E_col[CSMEUcol].COL_settlements[CSMEUsettleCnt].CS_infra[CSMEUinfraCnt].CI_status=istInConversion)
                  or (
                     (FCentities[CSMEUent].E_col[CSMEUcol].COL_settlements[CSMEUsettleCnt].CS_infra[CSMEUinfraCnt].CI_status>istDisabled)
                     and (FCentities[CSMEUent].E_col[CSMEUcol].COL_settlements[CSMEUsettleCnt].CS_infra[CSMEUinfraCnt].CI_status<istDestroyed)
                     )
               )
            then
            begin
               FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENcons
                  :=FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENcons+FCentities[CSMEUent].E_col[CSMEUcol].COL_settlements[CSMEUsettleCnt].CS_infra[CSMEUinfraCnt].CI_powerCons;
               if FCentities[CSMEUent].E_col[CSMEUcol].COL_settlements[CSMEUsettleCnt].CS_infra[CSMEUinfraCnt].CI_function=fEnergy
               then FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENgen
                  :=FCentities[CSMEUent].E_col[CSMEUcol].COL_csmENgen+FCentities[CSMEUent].E_col[CSMEUcol].COL_settlements[CSMEUsettleCnt].CS_infra[CSMEUinfraCnt].CI_fEnergOut;
               {:DEV NOTES: add custom effect energy generation.}
               {:DEV NOTES: add custom effect energy storage.}
            end;
            inc(CSMEUinfraCnt);
         end;
         inc(CSMEUsettleCnt);
      end; //==END== while CSMEUsettleCnt<=CSMEUsettleMax do ==//
   end; //==END== else if CSMEUisFullCalculation ==//
   CSMEUisShown:=FCFuiCDP_isPanel_Shown(CSMEUcol);
   if CSMEUisShown
   then FCMuiCDP_Data_Update(
      dtCSMenergy
      ,CSMEUcol
      ,0
      );
end;

end.
