{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: production phase - segment 2 products/items production

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
unit farc_game_prodSeg2;

interface

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   add a production item in a colony's production matrix
///</summary>
///   <param name="PIAent">entity index #</param>
///   <param name="PIAcol">colony index #</param>
///   <param name="PIAsettlement">settlement index #</param>
///   <param name="PIAownedInfra">owned infrastructure index #</param>
///   <param name="PIAprodModeIndex">owned infrastructure's production mode index #</param>
///   <param name="PIAproduct">product's token</param>
///   <param name="PIAproductionFlow">production flow in product's unit/hr (override number)</param>
procedure FCMgPS2_ProductionMatrixItem_Add(
   const PIAent
         ,PIAcol
         ,PIAsettlement
         ,PIAownedInfra
         ,PIAprodModeIndex: integer;
   const PIAproduct: string;
   const PIAproductionFlow: double
   );

///<summary>
///   segment 2 (items production) processing
///</summary>
///   <param name="PSPent">entity index #</param>
///   <param name="PSPcol">colony index #</param>
procedure FCMgPS2_ProductionSegment_Process(
   const PSPent
         ,PSPcol: integer
   );

implementation

uses
   farc_data_game;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgPS2_ProductionMatrixItem_Add(
   const PIAent
         ,PIAcol
         ,PIAsettlement
         ,PIAownedInfra
         ,PIAprodModeIndex: integer;
   const PIAproduct: string;
   const PIAproductionFlow: double
   );
{:Purpose: add a production item in a colony's production matrix.
    Additions:
}
   var
      PIApmCount
      ,PIApmMax
      ,PIApmodeCount
      ,PIApmodeMax: integer;

      PIAisCreated: boolean;
begin
   PIAisCreated:=false;
   PIApmCount:=1;
   PIApmMax:=Length( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix )-1;
   if PIApmMax<1 then
   begin
      SetLength( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix, 2 );
      PIApmMax:=1;
      {:DEV NOTES: load the production matrix item here.}
      PIAisCreated:=true;
   end
   else begin
      while PIApmCount<=PIApmMax do
      begin
         if FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIApmCount ].CPMI_productToken=PIAproduct then
         begin
            PIApmodeMax:=Length( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIApmCount ].CPMI_productionModes )-1;
            PIApmodeCount:=1;
            while PIApmodeCount<=PIApmodeMax do
            begin
               inc( PIApmodeCount );
            end;
         end;
         inc( PIApmCount );
      end;
   end;
//   if not PIAisCreated
//   then
end;

procedure FCMgPS2_ProductionSegment_Process(
   const PSPent
         ,PSPcol: integer
   );
{:Purpose:  segment 2 (items production) processing.
    Additions:
}
   var
      PSPprodMatrixCnt
      ,PSPprodMatrixMax: integer;
begin
   PSPprodMatrixMax:=length(FCEntities[PSPent].E_col[PSPcol].COL_productionMatrix)-1;
   if PSPprodMatrixMax>0 then
   begin
      PSPprodMatrixCnt:=1;
      while PSPprodMatrixCnt<=PSPprodMatrixMax do
      begin

         inc(PSPprodMatrixCnt);
      end;
   end;
end;

end.