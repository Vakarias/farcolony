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

uses
   SysUtils;

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
   ,farc_data_infrprod
   ,farc_game_colonyrves
   ,farc_game_core
   ,farc_game_cps
   ,farc_game_csmevents
   ,farc_ui_coredatadisplay
   ,farc_win_debug;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgPS3_ReservesSegment_Process(
   const Entity
         ,Colony: integer
   );
{:Purpose: segment 3 (reserves consumption) processing.
    Additions:
      -2012May20- *add: (COMPLETION) - coding of the segment 3, add water consumption processing.
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
         ceOxygenProductionOverload
         ,Entity
         ,Colony
         );
      PPS:=FCFgCR_OxygenOverload_Calc( Entity, Colony );
      {.process the Oxygen Overload Event}
      if ( ReturnedOverloadEvent=0 )
         and ( PPS>0 )
      then FCMgCSME_Event_Trigger(
         ceOxygenProductionOverload
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
               ,ceColonyEstablished
               ,0
               );
            ReturnedShortageEvent:=FCFgCSME_Search_ByType(
               ceOxygenShortage
               ,Entity
               ,Colony
               );
            if ReturnedShortageEvent>0
            then FCMgCSME_Event_Cancel(
               csmeecRecover
               ,Entity
               ,Colony
               ,ReturnedShortageEvent
               ,ceColonyEstablished
               ,0
               );
            doNotProcessShortageEvent:=true;
         end //==END== if PPS<=0 ==//
         else FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedOverloadEvent ].CCSME_tOPOvPercentPopulationNotSupported:=PPS;
      end; //==END== else if ReturnedOverloadEvent>0 ==//
      {.process the Oxygen Shortage event}
      if not doNotProcessShortageEvent then
      begin
         ReturnedShortageEvent:=FCFgCSME_Search_ByType(
            ceOxygenShortage
            ,Entity
            ,Colony
            );
         if ReturnedShortageEvent=0 then
         begin
            ReturnedShortageEvent:=FCFgCSME_Search_ByType(
               ceOxygenShortage_Recovering
               ,Entity
               ,Colony
               );
            if ReturnedShortageEvent>0 then
            begin
               FCMgCSME_Recovering_Process(
                  Entity
                  ,Colony
                  ,ReturnedShortageEvent
                  );
               if FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedShortageEvent ].CCSME_durationWeeks=-2
               then FCMgCSME_Event_Cancel(
                  csmeecImmediate
                  ,Entity
                  ,Colony
                  ,ReturnedShortageEvent
                  ,ceColonyEstablished
                  ,0
                  );
            end;
         end
         else if ReturnedShortageEvent>0 then
         begin
            {.case when all the population die of asphyxia}
            if FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedShortageEvent ].CCSME_durationWeeks=-3 then
            begin
               if ( Entity=0 )
                  and ( Assigned( FCcps ) )
               then FCMgCore_GameOver_Process( gfrCPSentirePopulationDie )
               else begin
               end;
               {:DEV NOTES: if not trigger a colony unbearable, see the cancellation rule of the Oxygen Shortage event.}
            end
            {.case if there's enough oxygen reserve for at least 1 tick}
            else if FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen>=FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total
            then FCMgCSME_Event_Cancel(
               csmeecRecover
               ,Entity
               ,Colony
               ,ReturnedShortageEvent
               ,ceColonyEstablished
               ,0
               )
            {.in any other case, do the over time process, if it's required}
            else if PPS<>FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedShortageEvent ].CCSME_tOShPercentPopulationNotSupportedAtCalculation
            then FCMgCR_OxygenShortage_Calc(
               Entity
               ,Colony
               ,ReturnedShortageEvent
               ,PPS
               );
         end;
      end; //==END== if not doNotProcessShortageEvent ==//
      {.process the oxygen consumption}
      if FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen<FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total then
      begin
         ReturnedShortageEvent:=FCFgCSME_Search_ByType(
            ceOxygenShortage_Recovering
            ,Entity
            ,Colony
            );
         if ReturnedShortageEvent=0 then
         begin
            ReturnedShortageEvent:=FCFgCSME_Search_ByType(
               ceOxygenShortage
               ,Entity
               ,Colony
               );
            if ReturnedShortageEvent=0
            then FCMgCSME_Event_Trigger(
               ceOxygenShortage
               ,Entity
               ,Colony
               ,0
               ,false
               );
         end
         else if ReturnedShortageEvent>0
         then FCMgCSME_Event_Cancel(
            csmeecOverride
            ,Entity
            ,Colony
            ,ReturnedShortageEvent
            ,ceOxygenShortage
            ,0
            );
         FCMgCR_Reserve_Update(
            Entity
            ,Colony
            ,pfOxygen
            ,-FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen
            ,true
            );
      end
      else if FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen>=FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total
      then FCMgCR_Reserve_Update(
         Entity
         ,Colony
         ,pfOxygen
         ,-FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total
         ,true
         );
   end; //==END== if FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen<>-1 ==//
   {.water consumption}
   doNotProcessShortageEvent:=false;
   ReturnedOverloadEvent:=FCFgCSME_Search_ByType(
      ceWaterProductionOverload
      ,Entity
      ,Colony
      );
   PPS:=FCFgCR_WaterOverload_Calc( Entity, Colony );
   {.process the Water Overload Event}
   if ( ReturnedOverloadEvent=0 )
      and ( PPS>0 )
   then FCMgCSME_Event_Trigger(
      ceWaterProductionOverload
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
            ,ceColonyEstablished
            ,0
            );
         ReturnedShortageEvent:=FCFgCSME_Search_ByType(
            ceWaterShortage
            ,Entity
            ,Colony
            );
         if ReturnedShortageEvent>0
         then FCMgCSME_Event_Cancel(
            csmeecRecover
            ,Entity
            ,Colony
            ,ReturnedShortageEvent
            ,ceColonyEstablished
            ,0
            );
         doNotProcessShortageEvent:=true;
      end //==END== if PPS<=0 ==//
      else FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedOverloadEvent ].CCSME_tWPOvPercentPopulationNotSupported:=PPS;
   end; //==END== else if ReturnedOverloadEvent>0 ==//
   {.process the Water Shortage event}
   if not doNotProcessShortageEvent then
   begin
      ReturnedShortageEvent:=FCFgCSME_Search_ByType(
         ceWaterShortage
         ,Entity
         ,Colony
         );
      if ReturnedShortageEvent=0 then
      begin
         ReturnedShortageEvent:=FCFgCSME_Search_ByType(
            ceWaterShortage_Recovering
            ,Entity
            ,Colony
            );
         if ReturnedShortageEvent>0 then
         begin
            FCMgCSME_Recovering_Process(
               Entity
               ,Colony
               ,ReturnedShortageEvent
               );
            if FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedShortageEvent ].CCSME_durationWeeks=-2
            then FCMgCSME_Event_Cancel(
               csmeecImmediate
               ,Entity
               ,Colony
               ,ReturnedShortageEvent
               ,ceColonyEstablished
               ,0
               );
         end;
      end
      else if ReturnedShortageEvent>0 then
      begin
         {.case when all the population die of dehydratation}
         if FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedShortageEvent ].CCSME_durationWeeks=-3 then
         begin
            if ( Entity=0 )
               and ( Assigned( FCcps ) )
            then FCMgCore_GameOver_Process( gfrCPSentirePopulationDie )
            else begin
            end;
            {:DEV NOTES: if not trigger a colony unbearable, see the cancellation rule of the Water Shortage event.}
         end
         {.case if there's enough water reserve for at least 1 tick}
         else if FCentities[ Entity ].E_col[ Colony ].COL_reserveWater>=FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total
         then FCMgCSME_Event_Cancel(
            csmeecRecover
            ,Entity
            ,Colony
            ,ReturnedShortageEvent
            ,ceColonyEstablished
            ,0
            )
         {.in any other case, do the over time process, if it's required}
         else if PPS<>FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedShortageEvent ].CCSME_tWShPercentPopulationNotSupportedAtCalculation
         then FCMgCR_WaterShortage_Calc(
            Entity
            ,Colony
            ,ReturnedShortageEvent
            ,PPS
            );
      end;
   end; //==END== if not doNotProcessShortageEvent ==//
   {.process the water consumption}
   if FCentities[ Entity ].E_col[ Colony ].COL_reserveWater<FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total then
   begin
      ReturnedShortageEvent:=FCFgCSME_Search_ByType(
         ceWaterShortage_Recovering
         ,Entity
         ,Colony
         );
      if ReturnedShortageEvent=0 then
      begin
         ReturnedShortageEvent:=FCFgCSME_Search_ByType(
            ceWaterShortage
            ,Entity
            ,Colony
            );
         if ReturnedShortageEvent=0
         then FCMgCSME_Event_Trigger(
            ceWaterShortage
            ,Entity
            ,Colony
            ,0
            ,false
            );
      end
      else if ReturnedShortageEvent>0
      then FCMgCSME_Event_Cancel(
         csmeecOverride
         ,Entity
         ,Colony
         ,ReturnedShortageEvent
         ,ceWaterShortage
         ,0
         );
      FCMgCR_Reserve_Update(
         Entity
         ,Colony
         ,pfWater
         ,-FCentities[ Entity ].E_col[ Colony ].COL_reserveWater
         ,true
         );
   end
   else if FCentities[ Entity ].E_col[ Colony ].COL_reserveWater>=FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total
   then FCMgCR_Reserve_Update(
      Entity
      ,Colony
      ,pfWater
      ,-FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total
      ,true
      );
   {.food consumption}
   doNotProcessShortageEvent:=false;
   ReturnedOverloadEvent:=FCFgCSME_Search_ByType(
      ceFoodProductionOverload
      ,Entity
      ,Colony
      );
   PPS:=FCFgCR_FoodOverload_Calc( Entity, Colony );
   {.process the Food Overload Event}
   if ( ReturnedOverloadEvent=0 )
      and ( PPS>0 )
   then FCMgCSME_Event_Trigger(
      ceFoodProductionOverload
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
            ,ceColonyEstablished
            ,0
            );
         ReturnedShortageEvent:=FCFgCSME_Search_ByType(
            ceFoodShortage
            ,Entity
            ,Colony
            );
         if ReturnedShortageEvent>0
         then FCMgCSME_Event_Cancel(
            csmeecRecover
            ,Entity
            ,Colony
            ,ReturnedShortageEvent
            ,ceColonyEstablished
            ,0
            );
         doNotProcessShortageEvent:=true;
      end //==END== if PPS<=0 ==//
      else FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedOverloadEvent ].CCSME_tFPOvPercentPopulationNotSupported:=PPS;
   end; //==END== else if ReturnedOverloadEvent>0 ==//
   {.process the Food Shortage event}
   if not doNotProcessShortageEvent then
   begin
      ReturnedShortageEvent:=FCFgCSME_Search_ByType(
         ceFoodShortage
         ,Entity
         ,Colony
         );
      if ReturnedShortageEvent=0 then
      begin
         ReturnedShortageEvent:=FCFgCSME_Search_ByType(
            ceFoodShortage_Recovering
            ,Entity
            ,Colony
            );
         if ReturnedShortageEvent>0 then
         begin
            FCMgCSME_Recovering_Process(
               Entity
               ,Colony
               ,ReturnedShortageEvent
               );
            if FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedShortageEvent ].CCSME_durationWeeks=-2
            then FCMgCSME_Event_Cancel(
               csmeecImmediate
               ,Entity
               ,Colony
               ,ReturnedShortageEvent
               ,ceColonyEstablished
               ,0
               );
         end;
      end
      else if ReturnedShortageEvent>0 then
      begin
         {.case when all the population die of starvation}
         if FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedShortageEvent ].CCSME_durationWeeks=-3 then
         begin
            if ( Entity=0 )
               and ( Assigned( FCcps ) )
            then FCMgCore_GameOver_Process( gfrCPSentirePopulationDie )
            else begin
            end;
            {:DEV NOTES: if not trigger a colony unbearable, see the cancellation rule of the Food Shortage event.}
         end
         {.case if there's enough food reserve for at least 1 tick}
         else if FCentities[ Entity ].E_col[ Colony ].COL_reserveFood>=FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total
         then FCMgCSME_Event_Cancel(
            csmeecRecover
            ,Entity
            ,Colony
            ,ReturnedShortageEvent
            ,ceColonyEstablished
            ,0
            )
         {.in any other case, do the over time process, if it's required}
         else if PPS<>FCentities[ Entity ].E_col[ Colony ].COL_evList[ ReturnedShortageEvent ].CCSME_tFShPercentPopulationNotSupportedAtCalculation
         then FCMgCR_FoodShortage_Calc(
            Entity
            ,Colony
            ,ReturnedShortageEvent
            ,PPS
            );
      end;
   end; //==END== if not doNotProcessShortageEvent ==//
   {.process the food consumption}
   if FCentities[ Entity ].E_col[ Colony ].COL_reserveFood<FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total then
   begin
      ReturnedShortageEvent:=FCFgCSME_Search_ByType(
         ceFoodShortage_Recovering
         ,Entity
         ,Colony
         );
      if ReturnedShortageEvent=0 then
      begin
         ReturnedShortageEvent:=FCFgCSME_Search_ByType(
            ceFoodShortage
            ,Entity
            ,Colony
            );
         if ReturnedShortageEvent=0
         then FCMgCSME_Event_Trigger(
            ceFoodShortage
            ,Entity
            ,Colony
            ,0
            ,false
            );
      end
      else if ReturnedShortageEvent>0
      then FCMgCSME_Event_Cancel(
         csmeecOverride
         ,Entity
         ,Colony
         ,ReturnedShortageEvent
         ,ceFoodShortage
         ,0
         );
      FCMgCR_Reserve_Update(
         Entity
         ,Colony
         ,pfFood
         ,-FCentities[ Entity ].E_col[ Colony ].COL_reserveFood
         ,true
         );
   end
   else if FCentities[ Entity ].E_col[ Colony ].COL_reserveFood>=FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total
   then FCMgCR_Reserve_Update(
      Entity
      ,Colony
      ,pfFood
      ,-FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total
      ,true
      );
   {.update the interface for CSM events list is required}
   if Entity=0
   then FCMuiCDD_Colony_Update(
      cdlCSMevents
      ,Colony
      ,0
      ,0
      ,true
      ,false
      ,false
      );
end;


end.
