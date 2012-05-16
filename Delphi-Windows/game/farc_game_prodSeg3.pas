{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: production phase - segment 3 reserves consumption

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
unit farc_game_prodSeg3;

interface

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   segment 3 (reserves consumption) processing
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
procedure FCMgPS3_ReservesSegment_Process(
   const Entity
         ,Colony: integer
   );

implementation

uses
   farc_data_game
   ,farc_game_colonyrves
   ,farc_game_csmevents;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgPS3_ReservesSegment_Process(
   const Entity
         ,Colony: integer
   );
{:Purpose: segment 3 (reserves consumption) processing.
    Additions:
      -2012May14- *add: (WORK IN PROGRESS) - coding of the segment 3, including consumption and CSM events trigger, update and cancel.
}
   var
      PPS
      ,ReturnedOverloadEvent
      ,ReturnedShortageEvent: integer;

      doNotProcessShortageEvent: boolean;
begin
   {.oxygen consumption}
   doNotProcessShortageEvent:=false;
   if FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen<>-1 then
   begin
      ReturnedOverloadEvent:=FCFgCSME_Search_ByType(
         etRveOxygenOverload
         ,Entity
         ,Colony
         );
      PPS:=FCFgCR_OxygenOverload_Calc( Entity, Colony );
      if ( ReturnedOverloadEvent=0 )
         and ( PPS>0 )
      then FCMgCSME_Event_Trigger(
         etRveOxygenOverload
         ,Entity
         ,Colony
         ,PPS
         ,false
         )
      else if ReturnedOverloadEvent>0 then
      begin
         if PPS<=0 then
         begin
            FCMgCSME_Event_Cancel(
               csmeecImmediate
               ,Entity
               ,Colony
               ,ReturnedOverloadEvent
               ,etColEstab
               ,0
               );
            ReturnedShortageEvent:=FCFgCSME_Search_ByType(
               etRveOxygenShortage
               ,Entity
               ,Colony
               );
            if ReturnedShortageEvent>0
            then FCMgCSME_Event_Cancel(
               csmeecRecover
               ,Entity
               ,Colony
               ,ReturnedShortageEvent
               ,etColEstab
               ,0
               );
            doNotProcessShortageEvent:=true;
         end
         else FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedOverloadEvent ].ROO_percPopNotSupported:=PPS;
      end;

      if not doNotProcessShortageEvent then
      begin
         ReturnedShortageEvent:=FCFgCSME_Search_ByType(
            etRveOxygenShortage
            ,Entity
            ,Colony
            );
         if ReturnedShortageEvent=0 then
         begin
            ReturnedShortageEvent:=FCFgCSME_Search_ByType(
               etRveOxygenShortageRec
               ,Entity
               ,Colony
               );

         end
         else if ReturnedShortageEvent>0 then
         begin
         end;
      end;
   end //==END== if FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen<>-1 ==//
   {.water consumption}
   {.food consumption}
end;


end.
