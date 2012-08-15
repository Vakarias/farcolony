{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: production phase - segment 5 CAB/Transition Status and Production Delay

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
   ,farc_ui_coredatadisplay
   ,farc_win_debug;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgPS5_CABTransitionSegment_Process(
   const CABTSPent
         ,CABTSPcol: integer
   );
{:Purpose:  segment 5 (CAB + Transition Status) processing.
    Additions:
      -2012Feb26- *mod: the owned list now refresh only updated items, and only of course if the CAB queue isn't empty.
      -2011Dec21- *add: update the interface if needed.
      -2011Sep21- *add: complete the inTransition case.
      -2011Sep10- *fix: correct the max index length reading.
}
   var
      CABTSPcntIdx
      ,CABTSPcntSet
      ,CABTSPinfraIdx
      ,CABTSPmaxIdx
      ,CABTSPmaxSet: integer;
      
      CABTSPpopResult: TFCRdgColonyPopulation;
begin
   CABTSPmaxSet:=length( FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_cabQueue )-1;
   if CABTSPmaxSet>0 then
   begin
      CABTSPcntSet:=1;
      while CABTSPcntSet<=CABTSPmaxSet do
      begin
         CABTSPmaxIdx:=length(FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_cabQueue[CABTSPcntSet])-1;
         CABTSPcntIdx:=1;
         while CABTSPcntIdx<=CABTSPmaxIdx do
         begin
            CABTSPinfraIdx:=FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_cabQueue[CABTSPcntSet, CABTSPcntIdx];
            case FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_status of
               isInConversion:
               begin
                  inc(FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabWorked);
                  if FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabWorked
                     =FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabDuration
                  then FCMgICS_Conversion_PostProcess(
                     CABTSPent
                     ,CABTSPcol
                     ,CABTSPcntSet
                     ,CABTSPinfraIdx
                     ,CABTSPcntIdx
                     );
               end;

               isInAssembling:
               begin
                  inc(FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabWorked);
                  if FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabWorked
                     =FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabDuration
                  then FCMgICS_TransitionRule_Process(
                     CABTSPent
                     ,CABTSPcol
                     ,CABTSPcntSet
                     ,CABTSPinfraIdx
                     ,CABTSPcntIdx
                     ,true
                     );
               end;

               isInBluidingSite:
               begin
                  inc(FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabWorked);
                  if FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabWorked
                     =FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabDuration
                  then FCMgICS_TransitionRule_Process(
                     CABTSPent
                     ,CABTSPcol
                     ,CABTSPcntSet
                     ,CABTSPinfraIdx
                     ,CABTSPcntIdx
                     ,true
                     );
               end;

               isInTransition:
               begin
                  if FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabDuration=-1
                  then FCMgICS_TransitionRule_Process(
                     CABTSPent
                     ,CABTSPcol
                     ,CABTSPcntSet
                     ,CABTSPinfraIdx
                     ,CABTSPcntIdx
                     ,true
                     )
                  else if FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabDuration>0 then
                  begin
                     dec( FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabDuration );
                     if FCDdgEntities[CABTSPent].E_colonies[CABTSPcol].C_settlements[CABTSPcntSet].S_infrastructures[CABTSPinfraIdx].I_cabDuration=0
                     then FCMgICS_TransitionRule_Process(
                        CABTSPent
                        ,CABTSPcol
                        ,CABTSPcntSet
                        ,CABTSPinfraIdx
                        ,CABTSPcntIdx
                        ,false
                        );
                  end;
               end;
            end; //==END== case FCentities[CABTSPent].E_col[CABTSPcol].COL_settlements[CABTSPcntSet].CS_infra[CABTSPinfraIdx].CI_status of ==//
            if CABTSPent=0
            then FCMuiCDD_Production_Update(
               plInfrastructuresCABupdate
               ,CABTSPcol
               ,CABTSPcntSet
               ,CABTSPinfraIdx
               );
            inc( CABTSPcntIdx );
         end; //==END== while CABTSPcntIdx<=CABTSPmaxIdx do ==//
         inc(CABTSPcntSet);
      end; //==END== while CABTSPcntSet<=CABTSPmaxSet do ==//
      FCMgICS_CAB_Cleanup( CABTSPent, CABTSPcol );
   end; //== END == if CABTSPmax>0 then ==//
end;

end.