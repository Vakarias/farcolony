{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: production system & products - core unit

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
unit farc_game_prod;

interface

///<summary>
///   return the index #, in the database, of a given product
///</summary>
///   <param name="PGIproduct">product token</param>
function FCFgP_Product_GetIndex(const PGIproduct: string): integer;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   production phase, core routine
///</summary>
procedure FCMgP_PhaseCore_Process;

implementation

uses
   farc_data_game
   ,farc_data_infrprod
   ,farc_game_prodSeg1
   ,farc_game_prodSeg2
   ,farc_game_prodSeg5;

var
   GPmaxProducts: integer;

//===================================================END OF INIT============================

function FCFgP_Product_GetIndex(const PGIproduct: string): integer;
{:Purpose: return the index #, in the database, of a given product.
    Additions:
}
var
   PGIcnt: integer;
begin
   Result:=-1;
   if GPmaxProducts=0
   then GPmaxProducts:=length(FCDBProducts)-1;
   PGIcnt:=1;
   while PGIcnt<=GPmaxProducts do
   begin
      if FCDBProducts[PGIcnt].PROD_token=PGIproduct
      then
      begin
         Result:=PGIcnt;
         break;
      end;
      inc(PGIcnt);
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgP_PhaseCore_Process;
{:Purpose: production phase, core routine.
    Additions:
      -2011Sep06- *add: CAB/Transition segment link.
      -2011Jul25- *add: production segment 2 link.
      -2011Jul14- *fix: apply correction in the second while loop by increasing the correct data.
}
   var
      PCPfacCount
      ,PCPcolCount
      ,PCPcolMax: integer;
begin
   PCPfacCount:=0;
   while PCPfacCount<=FCCfacMax do
   begin
      PCPcolMax:=length(FCentities[PCPfacCount].E_col)-1;
      if PCPcolMax>0
      then
      begin
         PCPcolCount:=1;
         while PCPcolCount<=PCPcolMax do
         begin
            {:DEV NOTES: 1st segment: energy.}
            FCMgPS1_EnergySegment_Process(PCPfacCount, PCPcolCount);
            {:DEV NOTES: 2nd segment, items production, test the production matrix here.}
            FCMgPS2_ProductionSegment_Process(PCPfacCount, PCPcolCount);
            {:DEV NOTES: 3rd segment, reserves testing each 24hours.}
            {:DEV NOTES: post 1st alpha: 4th segment, space unit manufacturing.}
            {:DEV NOTES: 5th segment, CAB queue processing.}
            FCMgPS5_CABTransitionSegment_Process(PCPfacCount, PCPcolCount);
            inc(PCPcolCount);
         end;
      end;
      inc(PCPfacCount);
   end;
end;

end.
