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
