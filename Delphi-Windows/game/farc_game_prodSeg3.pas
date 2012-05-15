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
      ReturnedOverloadEvent
      ,ReturnedShortageEvent: integer;
begin
   {.oxygen consumption}
   if FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen<>-1 then
   begin
      ReturnedOverloadEvent:=FCFgCSME_Search_ByType(
         etRveOxygenOverload
         ,Entity
         ,Colony
         );
      if ReturnedOverloadEvent=0 then
      begin
      end
      else if ReturnedOverloadEvent>0 then
      begin
      end;


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


      {:DEV NOTES:       if FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen=0 or not enough, trigger an oxygen reserve shortage  .}

      {:DEV NOTES: test and trigger oxygen production overload, if there's no oxygen production or there is but not enough to sustain all the population.}

//
   end
   {.water consumption}
   {.food consumption}
end;


end.
