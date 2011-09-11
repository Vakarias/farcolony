{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: production phase - segment 5 CAB/Transition Status and Production Delay

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
unit farc_game_prodSeg5;

interface

uses
   SysUtils;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   segment 5 (CAB + Transition Status) processing
///</summary>
///   <param name="CABTSPent">entity index #</param>
///   <param name="CABTSPcol">colony index #</param>
procedure FCMgPS5_CABTransitionSegment_Process(
   const CABTSPent
         ,CABTSPcol: integer
   );

implementation

uses
   farc_data_game
   ,farc_game_infraconsys
   ,farc_win_debug;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgPS5_CABTransitionSegment_Process(
   const CABTSPent
         ,CABTSPcol: integer
   );
{:Purpose:  segment 5 (CAB + Transition Status) processing.
    Additions:
      -2011Sep10- *fix: correct the max index length reading.
}
   var
      CABTSPcntIdx
      ,CABTSPcntSet
      ,CABTSPinfraIdx
      ,CABTSPmaxIdx
      ,CABTSPmaxSet: integer;
begin
   CABTSPmaxSet:=length( FCentities[CABTSPent].E_col[CABTSPcol].COL_cabQueue )-1;
   if CABTSPmaxSet>0 then
   begin
      CABTSPcntSet:=1;
      while CABTSPcntSet<=CABTSPmaxSet do
      begin
         CABTSPmaxIdx:=length(FCentities[CABTSPent].E_col[CABTSPcol].COL_cabQueue[CABTSPcntSet])-1;
         CABTSPcntIdx:=1;
         while CABTSPcntIdx<=CABTSPmaxIdx do
         begin
            CABTSPinfraIdx:=FCentities[CABTSPent].E_col[CABTSPcol].COL_cabQueue[CABTSPcntSet, CABTSPcntIdx];
            case FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_status of
               istInConversion:
               begin
                  inc(FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_cabWorked);
                  if FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_cabWorked
                     =FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_cabDuration
                  then FCMgICS_Conversion_PostProcess(
                     CABTSPent
                     ,CABTSPcol
                     ,CABTSPcntSet
                     ,CABTSPinfraIdx
                     ,CABTSPcntIdx
                     );
               end;

               istInAssembling:
               begin
                  inc(FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_cabWorked);
                  if FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_cabWorked
                     =FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_cabDuration
                  then FCMgICS_Assembling_PostProcess(
                     CABTSPent
                     ,CABTSPcol
                     ,CABTSPcntSet
                     ,CABTSPinfraIdx
                     );
               end;

               istInBldSite:
               begin
                  inc(FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_cabWorked);
                  if FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_cabWorked
                     =FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_cabDuration
                  then FCMgICS_Building_PostProcess(
                     CABTSPent
                     ,CABTSPcol
                     ,CABTSPcntSet
                     ,CABTSPinfraIdx
                     );
               end;

               istInTransition:
               begin

               end;
            end; //==END== case FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_status of ==//
            inc( CABTSPcntIdx );
         end; //==END== while CABTSPcntIdx<=CABTSPmaxIdx do ==//
         inc(CABTSPcntSet);
      end; //==END== while CABTSPcntSet<=CABTSPmaxSet do ==//
      FCMgICS_CAB_Cleanup( CABTSPent, CABTSPcol );
   end; //== END == if CABTSPmax>0 then ==//
end;

end.