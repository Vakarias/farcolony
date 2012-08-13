{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: csm/colony events

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

unit farc_game_csmevents;

interface

uses
   SysUtils

   ,farc_data_game;

type TFCEcsmeEvCan=(
   csmeecImmediate
   ,csmeecImmediateDelay
   ,csmeecRecover
   ,csmeecOverride
   );

{:DEV NOTES: update FCFgCSME_Mod_Sum.}
type TFCEcsmeModTp=(
   mtCohesion
   ,mtTension
   ,mtSecurity
   ,mtInstruction
   ,mtEcoIndOutput
   ,mtHealth
   );

///<summary>
///   cancel a specified event
///</summary>
///    <param name="ECcancelTp">cancellation type</param>
///    <param name="ECfacIdx">faction index #</param>
///    <param name="ECcolIdx">colony index #</param>
///    <param name="EventIndex">event index #</param>
///    <param name="NewEventType">[only for override] new event type</param>
///    <param name="ECnewLvl">[only for override] event level if needed</param>
procedure FCMgCSME_Event_Cancel(
   const ECcancelTp: TFCEcsmeEvCan;
   const ECfacIdx
         ,ECcolIdx
         ,EventIndex: integer;
   const NewEventType: TFCEdgColonyEvents;
   const ECnewLvl: integer
   );

///<summary>
///   get the event token string
///</summary>
///    <param name="EGSevent">type of event</param>
function FCFgCSME_Event_GetStr(const EGSevent: TFCEdgColonyEvents): string;

///<summary>
///   apply one time the recover rule on a specified event
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="Event">recovering event index #</param>
procedure FCMgCSME_Recovering_Process(
   const Entity
         ,Colony
         ,Event: integer
   );

///<summary>
///   search if a specified event is present, return the event# (0 if not found)
///</summary>
///    <param name="ETevent">type of event</param>
///    <param name="ETfacIdx">faction index #</param>
///    <param name="ETcolIdx">colony index #</param>
function FCFgCSME_Search_ByType(
   const ESevent: TFCEdgColonyEvents;
   const ESfacIdx
         ,EScolIdx: integer
   ): integer;

///<summary>
///   trigger a specified event
///</summary>
///    <param name="ETevent">type of event</param>
///    <param name="ETfacIdx">faction index #</param>
///    <param name="ETcolIdx">colony index #</param>
///    <param name="ETlvl">[optional] level. For etRveOxygenOverload, etRveWaterOverload and etRveFoodOverload it's the PPS which is loaded in this parameter</param>
procedure FCMgCSME_Event_Trigger(
   const ETevent: TFCEdgColonyEvents;
   const Entity
         ,Colony
         ,EventLevel: integer;
   const LoadToIndex0: boolean
   );

///<summary>
///   get the health-education event modifier value
///</summary>
///    <param name="HEGMfacIdx">faction index #</param>
///    <param name="HEGMcolIdx">colony index #</param>
function FCFgCSME_HealEdu_GetMod(
   const HEGMfacIdx
         ,HEGMcolIdx: integer
   ): integer;

///<summary>
///   make the sum of one type of data modifiers in one colony events list.
///</summary>
///    <param name=""></param>
///    <param name=""></param>
function FCFgCSME_Mod_Sum(
   const MStype: TFCEcsmeModTp;
   const MSfac
         ,MScolIDx: integer
   ): integer;

///<summary>
///   find if any Unrest, Social Disorder, Uprising or Dissident Colony event is set, and return the type
///</summary>
///    <param name="USFfac">faction index #</param>
///    <param name="USFcol">colony index #</param>
function FCFgCSME_UnSup_Find(
   const USFfac
         ,USFcol: integer
   ): TFCEdgColonyEvents;

///<summary>
///   over time processing for events of a colony
///</summary>
///    <param name="OTPfac">faction index #</param>
///    <param name="OTPcol">colony index #</param>
procedure FCMgCSME_OT_Proc(
   const Entity
         ,Colony: integer
   );

///<summary>
///   find if any Unrest, Social Disorder, Uprising event is set, and replace it by a chosen event w/ a specified method
///</summary>
///    <param name="USFRfac">faction index #</param>
///    <param name="USFRcol">colony index #</param>
///    <param name="USFRevent">new event</param>
///    <param name="USFRevLvl">new event level</param>
///    <param name="USFRevCancel">cancellation method</param>
procedure FCMgCSME_UnSup_FindRepl(
   const USFRfac
         ,USFRcol: integer;
   const USFRevent: TFCEdgColonyEvents;
   const USFRevLvl: integer;
   const USFRevCancel: TFCEcsmeEvCan;
   const USFRtriggerIfEmpty: boolean
   );

implementation

uses
   farc_game_colonyrves
   ,farc_common_func
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_game_colony
   ,farc_game_core
   ,farc_game_cps
   ,farc_game_csm
   ,farc_main
   ,farc_ui_coldatapanel
   ,farc_ui_coredatadisplay
   ,farc_ui_win
   ,farc_win_debug;

//===================================================END OF INIT============================

procedure FCMgCSME_Event_Cancel(
   const ECcancelTp: TFCEcsmeEvCan;
   const ECfacIdx
         ,ECcolIdx
         ,EventIndex: integer;
   const NewEventType: TFCEdgColonyEvents;
   const ECnewLvl: integer
   );
{:Purpose: cancel a specified event.
   -2012May17- *add: csmeecOverride - reset also the durations.
   -2012May16- *add: etRveFoodShortage, etRveFoodShortageRec - reset of RFS_directDeathPeriod and RFS_deathFracValue.
               *add: etRveFoodShortage, etRveFoodShortageRec - re-initialize RFS_directDeathPeriod in case of an override.
   -2012May15- *add: etRveWaterOverload, etRveFoodOverload.
               *add: etRveOxygenShortage, etRveWaterShortage, etRveFoodShortage.
               *mod: re-enable health data update for cancellation.
               mod: csmeecOverride - only events that can be overriden stay in the list, the rest is removed.
   -2012May06- *add: etRveOxygenOverload.
   -2012May03- *add: COMPLETION - rewriting of the code due to  new changes in the data structure.
   -2012Apr30- *mod: rewriting of the code due to  new changes in the data structure.
   -2011Jan19- *add: recovery mode for Governmental Destabilization.
   -2010Aug29- *add: csmeecImmediate: add the case if there was only 1 record left.
               *add: csmeecImmediateDelay, delay the data structure cleanup.
   -2010Aug09- *add: override cancellation type.
               *add: immediate cancellation: delete the selected event and update the event list.
   -2010Aug08- *add: immediate cancellation: education + economic and industrial output + health.
               *add: recovering cancellation.
   -2010Aug02- *add: immediate cancellation: security.
               *add: health modifier.
   -2010Aug01- *add: immediate cancellation: cohesion, tension.
}
   var
      Count
      ,CountClone
      ,ModCohesion
      ,MeanCohesion

      ,MeanInstruction
      ,ModHealth
      ,MeanHealth
      ,ModEcoIndOut
      ,ModInstruction
      ,MeanEcoIndOut
      ,Max
      ,FinalCSMvalue
      ,ModSecurity
      ,MeanSecurity
      ,ModTension
      ,MeanTension: integer;

      ECeventLst: array of TFCRdgColonyCSMEvent;
begin
   ModCohesion:=0;
   ModEcoIndOut:=0;
   ModInstruction:=0;
   ModSecurity:=0;
   ModTension:=0;
   ModHealth:=0;
   {.retrieve the CSM modifiers, if the event have any, or apply special rule to non modifier data}
   case FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_type of
      ceColonyEstablished:
      begin
         ModTension:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tCEstTensionMod;
         ModSecurity:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tCEstSecurityMod;
      end;

      ceUnrest, ceUnrest_Recovering:
      begin
         ModEcoIndOut:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tCUnEconomicIndustrialOutputMod;
         ModTension:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tCUnTensionMod;
      end;

      ceSocialDisorder, ceSocialDisorder_Recovering:
      begin
         ModEcoIndOut:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tSDisEconomicIndustrialOutputMod;
         ModTension:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tSDisTensionMod;
      end;

      ceUprising, ceUprising_Recovering:
      begin
         ModEcoIndOut:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tUpEconomicIndustrialOutputMod;
         ModTension:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tUpTensionMod;
      end;

      ceHealthEducationRelation: ModInstruction:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tHERelEducationMod;

      ceGovernmentDestabilization, ceGovernmentDestabilization_Recovering: ModCohesion:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tGDestCohesionMod;

      ceOxygenProductionOverload: FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tOPOvPercentPopulationNotSupported:=0;

      ceOxygenShortage, ceOxygenShortage_Recovering:
      begin
         FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tOShPercentPopulationNotSupportedAtCalculation:=0;
         ModEcoIndOut:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tOShEconomicIndustrialOutputMod;
         ModTension:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tOShTensionMod;
         ModHealth:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tOShHealthMod;
      end;

      ceWaterProductionOverload: FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tWPOvPercentPopulationNotSupported:=0;

      ceWaterShortage, ceWaterShortage_Recovering:
      begin
         FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tWShPercentPopulationNotSupportedAtCalculation:=0;
         ModEcoIndOut:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tWShEconomicIndustrialOutputMod;
         ModTension:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tWShTensionMod;
         ModHealth:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tWShHealthMod;
      end;

      ceFoodProductionOverload: FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tFPOvPercentPopulationNotSupported:=0;

      ceFoodShortage, ceFoodShortage_Recovering:
      begin
         FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tFShPercentPopulationNotSupportedAtCalculation:=0;
         ModEcoIndOut:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tFShEconomicIndustrialOutputMod;
         ModTension:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tFShTensionMod;
         ModHealth:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tFShHealthMod;
         FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tFShDirectDeathPeriod:=0;
         FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tFShDeathFractionalValue:=0;
      end;
   end; //==END== case FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].CSMEV_token of ==//
   {.apply the correct cancellation method}
   case ECcancelTp of
      csmeecImmediate, csmeecImmediateDelay:
      begin
         {.reverse the modifiers effects}
         if ModCohesion<>0 then
         begin
            if ModCohesion<0
            then FinalCSMvalue:=abs(ModCohesion)
            else if ModCohesion>0
            then FinalCSMvalue:=-ModCohesion;
            FCMgCSM_ColonyData_Upd(
               dCohesion
               ,ECfacIdx
               ,ECcolIdx
               ,FinalCSMvalue
               ,0
               ,gcsmptNone
               ,false
               );
         end;
         if ModTension<>0 then
         begin
            if ModTension<0
            then FinalCSMvalue:=abs(ModTension)
            else if ModTension>0
            then FinalCSMvalue:=-ModTension;
            FCMgCSM_ColonyData_Upd(
               dTension
               ,ECfacIdx
               ,ECcolIdx
               ,FinalCSMvalue
               ,0
               ,gcsmptNone
               ,false
               );
         end;
         if ModSecurity<>0 then
         begin
            if ModSecurity<0
            then FinalCSMvalue:=abs(ModSecurity)
            else if ModSecurity>0
            then FinalCSMvalue:=-ModSecurity;
            case FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_type of
               ceColonyEstablished: FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_tCEstSecurityMod:=FinalCSMvalue;
            end;
            FCMgCSM_ColonyData_Upd(
               dSecurity
               ,ECfacIdx
               ,ECcolIdx
               ,0
               ,0
               ,gcsmptNone
               ,true
               );
         end;
         if ModInstruction<>0 then
         begin
            if ModInstruction<0
            then FinalCSMvalue:=abs(ModInstruction)
            else if ModInstruction>0
            then FinalCSMvalue:=-ModInstruction;
            FCMgCSM_ColonyData_Upd(
               dInstruction
               ,ECfacIdx
               ,ECcolIdx
               ,FinalCSMvalue
               ,0
               ,gcsmptNone
               ,false
               );
         end;
         if ModEcoIndOut<>0 then
         begin
            if ModEcoIndOut<0
            then FinalCSMvalue:=abs(ModEcoIndOut)
            else if ModEcoIndOut>0
            then FinalCSMvalue:=-ModEcoIndOut;
            FCMgCSM_ColonyData_Upd(
               dEcoIndusOut
               ,ECfacIdx
               ,ECcolIdx
               ,FinalCSMvalue
               ,0
               ,gcsmptNone
               ,false
               );
         end;
         {.health}
         if ModHealth<0
         then FinalCSMvalue:=abs(ModHealth)
         else if ModHealth>0
         then FinalCSMvalue:=-ModHealth;
         FCMgCSM_ColonyData_Upd(
            dHealth
            ,ECfacIdx
            ,ECcolIdx
            ,FinalCSMvalue
            ,0
            ,gcsmptNone
            ,false
            );
         {.indicate that the event must be cleared}
         FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_durationWeeks:=-255;
         if ECcancelTp=csmeecImmediate
         then
         begin
            SetLength(ECeventLst, 0);
            Max:=length(FCentities[ECfacIdx].E_col[ECcolIdx].C_events)-1;
            Count:=1;
            CountClone:=0;
            if Max>1
            then
            begin
               SetLength(ECeventLst, Max);
               while Count<=Max do
               begin
                  if FCentities[ECfacIdx].E_col[ECcolIdx].C_events[Count].CCSME_durationWeeks<>-255
                  then
                  begin
                     inc(CountClone);
                     ECeventLst[CountClone]:=FCentities[ECfacIdx].E_col[ECcolIdx].C_events[Count];
                  end;
                  inc(Count);
               end;
               SetLength(FCentities[ECfacIdx].E_col[ECcolIdx].C_events, 0);
               SetLength(FCentities[ECfacIdx].E_col[ECcolIdx].C_events, CountClone+1);
               Count:=1;
               while Count<=CountClone do
               begin
                  FCentities[ECfacIdx].E_col[ECcolIdx].C_events[Count]:=ECeventLst[Count];
                  inc(Count);
               end;
            end
            else if Max=1
            then setlength(FCentities[ECfacIdx].E_col[ECcolIdx].C_events, 1);
         end;
      end; //==END== case of: csmeecImmediate, csmeecImmediateDelay ==//

      csmeecRecover:
      begin
         case FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_type of
            ceUnrest: FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_type:=ceUnrest_Recovering;

            ceSocialDisorder: FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_type:=ceSocialDisorder_Recovering;

            ceUprising: FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_type:=ceUprising_Recovering;

            ceGovernmentDestabilization:
            begin
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_type:=ceGovernmentDestabilization_Recovering;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_durationWeeks:=-1;
            end;

            ceOxygenShortage: FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_type:=ceOxygenShortage_Recovering;

            ceWaterShortage: FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_type:=ceWaterShortage_Recovering;

            ceFoodShortage: FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_type:=ceFoodShortage_Recovering;
         end;
      end;

      csmeecOverride:
      begin
         FCMgCSME_Event_Trigger(
            NewEventType
            ,ECfacIdx
            ,ECcolIdx
            ,ECnewLvl
            ,true
            );
         FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_type:=NewEventType;
         FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_durationWeeks:=FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_durationWeeks;
         case FCentities[ ECfacIdx ].E_col[ ECcolIdx].C_events[ EventIndex ].CCSME_type of
            ceUnrest:
            begin
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_level:=ECnewLvl;
               MeanEcoIndOut:=round( ( ModEcoIndOut+FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tCUnEconomicIndustrialOutputMod )*0.5 );
               MeanTension:=round( ( ModTension+FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tCUnTensionMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tCUnEconomicIndustrialOutputMod:=MeanEcoIndOut;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tCUnTensionMod:=MeanTension;
            end;

            ceSocialDisorder:
            begin
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_level:=ECnewLvl;
               MeanEcoIndOut:=round( ( ModEcoIndOut+FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tSDisEconomicIndustrialOutputMod )*0.5 );
               MeanTension:=round( ( ModTension+FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tSDisTensionMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tSDisEconomicIndustrialOutputMod:=MeanEcoIndOut;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tSDisTensionMod:=MeanTension;
            end;

            ceUprising:
            begin
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_level:=ECnewLvl;
               MeanEcoIndOut:=round( ( ModEcoIndOut+FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tUpEconomicIndustrialOutputMod )*0.5 );
               MeanTension:=round( ( ModTension+FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tUpTensionMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tUpEconomicIndustrialOutputMod:=MeanEcoIndOut;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tUpTensionMod:=MeanTension;
            end;

            ceGovernmentDestabilization:
            begin
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_level:=ECnewLvl;
               MeanCohesion:=round( ( ModCohesion+FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tGDestCohesionMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tGDestCohesionMod:=MeanCohesion;
            end;

            ceOxygenShortage:
            begin
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tOShPercentPopulationNotSupportedAtCalculation:=FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tOShPercentPopulationNotSupportedAtCalculation;
               MeanEcoIndOut:=round( ( ModEcoIndOut + FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tOShEconomicIndustrialOutputMod )*0.5 );
               MeanTension:=round( ( ModTension + FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tOShTensionMod )*0.5 );
               MeanHealth:=round( ( ModHealth + FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tOShHealthMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tOShEconomicIndustrialOutputMod:=MeanEcoIndOut;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tOShTensionMod:=MeanTension;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tOShHealthMod:=MeanHealth;
            end;

            ceWaterShortage:
            begin
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tWShPercentPopulationNotSupportedAtCalculation:=FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tWShPercentPopulationNotSupportedAtCalculation;
               MeanEcoIndOut:=round( ( ModEcoIndOut + FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tWShEconomicIndustrialOutputMod )*0.5 );
               MeanTension:=round( ( ModTension + FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tWShTensionMod )*0.5 );
               MeanHealth:=round( ( ModHealth + FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tWShHealthMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tWShEconomicIndustrialOutputMod:=MeanEcoIndOut;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tWShTensionMod:=MeanTension;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tWShHealthMod:=MeanHealth;
            end;

            ceFoodShortage:
            begin
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tFShPercentPopulationNotSupportedAtCalculation:=FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tFShPercentPopulationNotSupportedAtCalculation;
               MeanEcoIndOut:=round( ( ModEcoIndOut + FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tFShEconomicIndustrialOutputMod )*0.5 );
               MeanTension:=round( ( ModTension + FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tFShTensionMod )*0.5 );
               MeanHealth:=round( ( ModHealth + FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tFShHealthMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tFShEconomicIndustrialOutputMod:=MeanEcoIndOut;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tFShTensionMod:=MeanTension;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tFShHealthMod:=MeanHealth;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tFShDirectDeathPeriod:=FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tFShDirectDeathPeriod;
               FCentities[ECfacIdx].E_col[ECcolIdx].C_events[EventIndex].CCSME_tFShDeathFractionalValue:=FCentities[ECfacIdx].E_col[ECcolIdx].C_events[0].CCSME_tFShDeathFractionalValue;
            end;
         end; //==END== case FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].CSMEV_token of ==//

      end; //==END== case: csmeecOverride ==//
   end; //==END== case ECcancelTp of ==//
end;

function FCFgCSME_Event_GetStr(const EGSevent: TFCEdgColonyEvents): string;
{:Purpose: get the event token string.
   Additions:
      -2012May12- *add: etRveOxygenShortage, etRveWaterShortageRec, etRveWaterOverload, etRveWaterShortage, etRveFoodOverload and etRveFoodShortage.
      -2012May06- *add: etRveOxygenOverload.
      -2012Apr29- *add: forgot to add: etGovDestabRec.
      -2011Jan18- *add: etGovDestab.
      -2010Aug12- *rem: etColRogue.
      -2010Aug02- *add: etHealthEduRel.
      -2010Jul29- *add: etUprisingRec, etSocdisRec.
      -2010Jul28- *add: etUnrestRec.
      -2010Jul23- *add: etUnrest, etSocdis, etUprising, etColRogue, etColDissident
}
begin
   case EGSevent of
      ceColonyEstablished: result:='csmevColEst';

      ceUnrest: result:='csmevUnrest';

      ceUnrest_Recovering: result:='csmevUnrestRec';

      ceSocialDisorder: result:='csmevSocDis';

      ceSocialDisorder_Recovering: result:='csmevSocDisRec';

      ceUprising: result:='csmevUprising';

      ceUprising_Recovering: result:='csmevUprisingRec';

      ceDissidentColony: result:='csmevColDissident';

      ceHealthEducationRelation: result:='csmevHealthEduRel';

      ceGovernmentDestabilization: result:='csmevGovDestab';

      ceGovernmentDestabilization_Recovering: result:= 'csmevGovDestabRec';

      ceOxygenProductionOverload: result:='csmevRveOxygenOverload';

      ceOxygenShortage: result:='csmevRveOxygenShortage';

      ceOxygenShortage_Recovering: result:='csmevRveOxygenShortageRec';

      ceWaterProductionOverload: result:='csmevRveWaterOverload';

      ceWaterShortage: result:='csmevRveWaterShortage';

      ceWaterShortage_Recovering: result:='csmevRveWaterShortageRec';

      ceFoodProductionOverload: result:='csmevRveFoodOverload';

      ceFoodShortage: result:='csmevRveFoodShortage';

      ceFoodShortage_Recovering: result:='csmevRveFoodShortageRec';
   end;
end;

function FCFgCSME_Search_ByType(
   const ESevent: TFCEdgColonyEvents;
   const ESfacIdx
         ,EScolIdx: integer
   ): integer;
{:Purpose: search if a specified event is present, return the event# (0 if not found).
   Additions:
      -2010Sep14- *add: entities code.
}
var
   EScnt
   ,ESmax: integer;
begin
   EScnt:=1;
   Result:=0;
   ESmax:=length(FCentities[ESfacIdx].E_col[EScolIdx].C_events)-1;
   while EScnt<=ESmax do
   begin
      if FCentities[ESfacIdx].E_col[EScolIdx].C_events[EScnt].CCSME_type=ESevent
      then
      begin
         result:=EScnt;
         break;
      end;
      inc(EScnt);
   end;
end;

procedure FCMgCSME_Event_Trigger(
   const ETevent: TFCEdgColonyEvents;
   const Entity
         ,Colony
         ,EventLevel: integer;
   const LoadToIndex0: boolean
   );
   {:DEV NOTES: A LOT OF UPDATE TO PUT, FOLLOW THE DOC !! + COMPLETE CSM DATA UPDATE (like for ecoIndOutput !!!!.}
   {:DEV NOTES: test if a same event already exist in recovering mode, if it's the case => override, if not => do nothing.}
{:Purpose: trigger a specified event.
    Additions:
      -2012May19- *rem: etRveWaterShortage calculation is moved into its proper method.
      -2012May17- *rem: etRveOxygenShortage calculation is moved into its proper method.
      -2012May15- *mod: etRveOxygenOverload - since the PPS is already calculated in the segment 3, it's loaded in the EventLevel parameter (so need to recalculate the PPS in this method).
      -2012May14- *add: etRveFoodShortage.
      -2012May13- *add: etRveOxygenShortage, etRveWaterOverload, etRveWaterShortage and etRveFoodOverload events.
                  *fix: forgot to update the CSM data Economic & Industrial Output for some events.
                  *fix: etGovDestab - forgot to update the CSM data related to this event.
      -2012May05- *add: etRveOxygenOverload event.
                  *code: refactoring of all procedure's parameters.
      -2012May03- *mod: apply modification according to changes in the CSM event data structure.
      -2012Apr30- *add: update the colony panel if needed.
      -2011Jan19- *add: governmental destabilization.
      -2010Sep14- *add: entities code.
      -2010Aug29- *mod: Dissident Colony: there's no duration, it's the fight itself which decide of the duration.
      -2010Aug24- *mod: Uprising: there's no duration in case of a fight (it's the fight itself which decide of the duration), if there's
                  no soldiers: an uprising duration is calculated.
      -2010Aug23- *add: include level 9 for Unrest and Social Disorder.
      -2010Aug19- *add: Dissident colony calculations completion.
      -2010Aug18- *fix: Uprising rebels and duration calculations are corrected.
      -2010Aug17- *add: Uprising completion.
                  *add: Dissident colony calculations.
      -2010Aug16- *mod: due to a balancing work Unrest, Social Disorders and Uprising modifiers are readjusted again.
                  *add: rebels calculations for Uprising event.
      -2010Aug12- *rem: etColRogue.
      -2010Aug10- *add: duration init for etHealthEduRel.
                  *add: update Colony Established event w/environments.
                  *add: Uprising calculations.
      -2010Aug09- *add: ETretr switch for basic modifier retrieving.
                  *add: duration.
      -2010Aug02- *add: load CSM event health modifier.
                  *add: CSM event Health-Education Relation.
      -2010Jul28- *add: Social Disorder Calculations.
      -2010Jul27- *add: load CSM event level and economic & industrial ouput modifier.
                  *add: Unrest calculations.
      -2010Jul26- *add: an optional level data.
      -2010Jul23- *add: switchs.
}
var
   CurrentEventIndex
   ,ETevMod
   ,ETintEv
   ,ETloyal
   ,ETloyalCalc
   ,ETrnd
   ,ETuprRebAmnt
   ,ETuprRebels
   ,EventDataI1
   ,EventDataI2
   ,EventDataI3: integer;

   ETdur
   ,ETuprDurCoef
   ,EventDataF1
   ,EventDataF2
   ,EventDataF3
   ,EventDataF4: extended;

   ColonyEnvironment: TFCRgcEnvironment;
begin
   if LoadToIndex0
   then
   begin
      if length(FCentities[Entity].E_col[Colony].C_events)=0
      then setlength(FCentities[Entity].E_col[Colony].C_events, 1);
      CurrentEventIndex:=0;
      FCentities[Entity].E_col[Colony].C_events[0].CCSME_isResident:=false;
      FCentities[Entity].E_col[Colony].C_events[0].CCSME_durationWeeks:=0;
      FCentities[Entity].E_col[Colony].C_events[0].CCSME_level:=0;
      FCentities[Entity].E_col[Colony].C_events[0].CCSME_type:=ceColonyEstablished;
      FCentities[Entity].E_col[Colony].C_events[0].CCSME_tCEstTensionMod:=0;
      FCentities[Entity].E_col[Colony].C_events[0].CCSME_tCEstSecurityMod:=0;
   end
   else if not LoadToIndex0
   then
   begin
      ETuprRebAmnt:=0;
      setlength(FCentities[Entity].E_col[Colony].C_events, length(FCentities[Entity].E_col[Colony].C_events)+1);
      CurrentEventIndex:=length(FCentities[Entity].E_col[Colony].C_events)-1;
   end;
   case ETevent of
      ceColonyEstablished:
      begin
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceColonyEstablished;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=5;
         ColonyEnvironment:=FCFgC_ColEnv_GetTp(Entity, Colony);
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=-1;
         case ColonyEnvironment.ENV_envType of
            etFreeLiving:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=0;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCEstTensionMod:=10;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCEstSecurityMod:=-15;
            end;

            etRestricted:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=1;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCEstTensionMod:=15;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCEstSecurityMod:=-20;
            end;

            etSpace:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=2;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCEstTensionMod:=25;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCEstSecurityMod:=-20;
            end;
         end;
         if not LoadToIndex0 then
         begin
            FCMgCSM_ColonyData_Upd(
               dTension
               ,Entity
               ,Colony
               ,FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCEstTensionMod
               ,0
               ,gcsmptNone
               ,false
               );
            FCMgCSM_ColonyData_Upd(
               dSecurity
               ,Entity
               ,Colony
               ,0
               ,0
               ,gcsmptNone
               ,true
               );
         end;
      end; //==END== case: csmeeColEstablished ==//

      ceUnrest:
      begin
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceUnrest;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=EventLevel;
         case EventLevel of
            1:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnEconomicIndustrialOutputMod:=-15;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnTensionMod:=15;
            end;

            2:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnEconomicIndustrialOutputMod:=-13;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnTensionMod:=11;
            end;

            3:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnEconomicIndustrialOutputMod:=-13;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnTensionMod:=9;
            end;

            4:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnEconomicIndustrialOutputMod:=-10;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnTensionMod:=7;
            end;

            5:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnEconomicIndustrialOutputMod:=-8;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnTensionMod:=5;
            end;

            6:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnEconomicIndustrialOutputMod:=-5;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnTensionMod:=4;
            end;

            7:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnEconomicIndustrialOutputMod:=-5;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnTensionMod:=3;
            end;

            8..9:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnEconomicIndustrialOutputMod:=-3;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnTensionMod:=3;
            end;
         end; //==END== case ETlvl of ==//
         if not LoadToIndex0 then
         begin
            FCMgCSM_ColonyData_Upd(
               dEcoIndusOut
               ,Entity
               ,Colony
               ,FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnEconomicIndustrialOutputMod
               ,0
               ,gcsmptNone
               ,false
               );
            FCMgCSM_ColonyData_Upd(
               dTension
               ,Entity
               ,Colony
               ,FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tCUnTensionMod
               ,0
               ,gcsmptNone
               ,false
               );
         end;
      end; //==END== case: etUnrest ==//

      ceSocialDisorder:
      begin
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceSocialDisorder;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=EventLevel;
         case EventLevel of
            1:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisEconomicIndustrialOutputMod:=-32;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisTensionMod:=22;
            end;

            2:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisEconomicIndustrialOutputMod:=-29;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisTensionMod:=17;
            end;

            3:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisEconomicIndustrialOutputMod:=-25;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisTensionMod:=17;
            end;

            4:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisEconomicIndustrialOutputMod:=-20;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisTensionMod:=13;
            end;

            5:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisEconomicIndustrialOutputMod:=-19;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisTensionMod:=13;
            end;

            6:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisEconomicIndustrialOutputMod:=-13;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisTensionMod:=10;
            end;

            7:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisEconomicIndustrialOutputMod:=-10;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisTensionMod:=9;
            end;

            8..9:
            begin
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisEconomicIndustrialOutputMod:=-8;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisTensionMod:=8;
            end;
         end; //==END== case ETlvl of ==//
         if not LoadToIndex0 then
         begin
            FCMgCSM_ColonyData_Upd(
               dEcoIndusOut
               ,Entity
               ,Colony
               ,FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisEconomicIndustrialOutputMod
               ,0
               ,gcsmptNone
               ,false
               );
            FCMgCSM_ColonyData_Upd(
               dTension
               ,Entity
               ,Colony
               ,FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tSDisTensionMod
               ,0
               ,gcsmptNone
               ,false
               );
         end;
      end; //==END== case: etSocdis ==//

      ceUprising:
      begin
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceUprising;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=EventLevel;
         case EventLevel of
            1:
            begin
               ETuprRebAmnt:=80;
               if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier>0
               then FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1
               else if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier=0
               then ETuprDurCoef:=5;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpEconomicIndustrialOutputMod:=-65;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpTensionMod:=43;
            end;

            2:
            begin
               ETuprRebAmnt:=50;
               if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier>0
               then FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1
               else if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier=0
               then ETuprDurCoef:=4;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpEconomicIndustrialOutputMod:=-52;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpTensionMod:=34;
            end;

            3:
            begin
               ETuprRebAmnt:=30;
               if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier>0
               then FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1
               else if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier=0
               then ETuprDurCoef:=2;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpEconomicIndustrialOutputMod:=-39;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpTensionMod:=26;
            end;

            4:
            begin
               ETuprRebAmnt:=20;
               if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier>0
               then FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1
               else if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier=0
               then ETuprDurCoef:=1.5;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpEconomicIndustrialOutputMod:=-23;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpTensionMod:=19;
            end;

            5:
            begin
               ETuprRebAmnt:=10;
               if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier>0
               then FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1
               else if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier=0
               then ETuprDurCoef:=1;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpEconomicIndustrialOutputMod:=-15;
               FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpTensionMod:=15;
            end;
         end; //==END== case ETlvl of ==//
         if FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks=-1
         then ETuprRebels:=round(
            ( FCentities[Entity].E_col[Colony].C_population.CP_total-FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier )*( 1+( ETuprRebAmnt/100 ) )
            )
         else if FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks=0
         then
         begin
            ETuprRebels:=round(FCentities[Entity].E_col[Colony].C_population.CP_total*(1+(ETuprRebAmnt/100)));
            ETdur:=sqrt(ETuprRebels)*ETuprDurCoef;
            FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=round(ETdur);
         end;
         FCentities[Entity].E_col[Colony].C_population.CP_classRebels:=ETuprRebels;
         if not LoadToIndex0 then
         begin
            FCMgCSM_ColonyData_Upd(
               dEcoIndusOut
               ,Entity
               ,Colony
               ,FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpEconomicIndustrialOutputMod
               ,0
               ,gcsmptNone
               ,false
               );
            FCMgCSM_ColonyData_Upd(
               dTension
               ,Entity
               ,Colony
               ,FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tUpTensionMod
               ,0
               ,gcsmptNone
               ,false
               );
         end;
      end; //==END== case: etUprising ==//

      ceDissidentColony:
      begin
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceDissidentColony;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=EventLevel;
         ETrnd:=FCFcFunc_Rand_Int(100);
         ETintEv:=0;
         ETuprRebAmnt:=0;
         ETloyal:=0;
         ETloyalCalc:=0;
         case EventLevel of
            1:
            begin
               ETuprRebAmnt:=1;
               if ETrnd in [0..5]
               then ETintEv:=3;
               ETloyal:=35;
            end;
            2:
            begin
               ETuprRebAmnt:=5;
               case ETrnd of
                  0..10: ETintEv:=3;
                  11..20: ETintEv:=2;
                  21..30: ETintEv:=1;
               end;
               ETloyal:=25;
            end;
            3:
            begin
               ETuprRebAmnt:=10;
               case ETrnd of
                  0..15: ETintEv:=3;
                  16..35: ETintEv:=2;
                  36..60: ETintEv:=1;
               end;
               ETloyal:=15;
            end;
            4:
            begin
               ETuprRebAmnt:=15;
               case ETrnd of
                  0..20: ETintEv:=3;
                  21..50: ETintEv:=2;
                  51..90: ETintEv:=1;
               end;
               ETloyal:=5;
            end;
         end; //==END== case ETlvl of ==//
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=ETintEv;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1;
         case ETintEv of
            {.no resistance}
            0:
            begin
               if ( Entity=0)
                  and ( Assigned(FCcps) )
               then FCMgCore_GameOver_Process( gfrCPScolonyBecameDissident )
               else begin
                  {:DEV NOTES: WARNING, DUPLICATE CODE W/ OT - FIX THAT !.}
                  {:DEV NOTES: colony is lost.
                  the procedure to implement when AI will be done:
                     1/create a faction for the dissident colony and transfert the colony's data to the new faction's sub-datastructure
                     2/cleanup the player's or AI faction w/ the lost colony
                     2/initialize an entity and assign the new colony's faction on it
                     3/raise the new independent colony's cohesion w/: new Cohesion= (CurrentCohesion + 20%)*2.
                     4/process landed space units if there's any
                  }
               end;
            end;
            1..3:
            begin
               if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier=0
               then
               begin
                  ETuprRebels:=round(FCentities[Entity].E_col[Colony].C_population.CP_total*(1+(ETuprRebAmnt/100)));
                  ETloyalCalc:=round((FCentities[Entity].E_col[Colony].C_population.CP_total-ETuprRebels)*(1+(ETloyal/100)));
               end
               else if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier>0
               then
               begin
                  ETuprRebels:=round(
                     (FCentities[Entity].E_col[Colony].C_population.CP_total-FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier)
                     *(1+(ETuprRebAmnt/100))
                     );
                  ETloyalCalc:=0;
               end;
               FCentities[Entity].E_col[Colony].C_population.CP_classRebels:=ETuprRebels;
               FCentities[Entity].E_col[Colony].C_population.CP_classMilitia:=ETloyalCalc;
            end;
         end; //==END== case ETintEv of ==//
      end; //==END== case: etColDissident ==//

      ceHealthEducationRelation:
      begin
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceHealthEducationRelation;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=0;
         ETevMod:=FCFgCSME_HealEdu_GetMod(Entity, Colony);
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tHERelEducationMod:=ETevMod;
         if not LoadToIndex0
         then FCMgCSM_ColonyData_Upd(
            dInstruction
            ,Entity
            ,Colony
            ,ETevMod
            ,0
            ,gcsmptNone
            ,false
            );
      end; //==END== case: etHealthEduRel ==//

      ceGovernmentDestabilization:
      begin
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceGovernmentDestabilization;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=EventLevel;
         case EventLevel of
            1..3: FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tGDestCohesionMod:=-8;
            4..6: FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tGDestCohesionMod:=-13;
            7..9: FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tGDestCohesionMod:=-20;
         end;
         if not LoadToIndex0
         then FCMgCSM_ColonyData_Upd(
            dCohesion
            ,Entity
            ,Colony
            ,FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tGDestCohesionMod
            ,0
            ,gcsmptNone
            ,false
            );
      end; //==END== case: etGovDestab ==//

      ceOxygenProductionOverload:
      begin
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceOxygenProductionOverload;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tOPOvPercentPopulationNotSupported:=FCFgCR_OxygenOverload_Calc( Entity, Colony );;
      end; //==END== case: etRveOxygenOverload ==//

      ceOxygenShortage:
      begin
         {.EventDataI1 = index # for Oxygen Production Overload event}
         EventDataI1:=FCFgCSME_Search_ByType(
            ceOxygenProductionOverload
            ,Entity
            ,Colony
            );
         if EventDataI1=0
         then raise Exception.Create('there is no Oxygen Production Overload event created, prior to Oxygen Shortage, check the reserves consumption rule.');
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceOxygenShortage;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tOShEconomicIndustrialOutputMod:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tOShTensionMod:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tOShHealthMod:=0;
         FCMgCR_OxygenShortage_Calc(
            Entity
            ,Colony
            ,CurrentEventIndex
            ,FCentities[ Entity ].E_col[ Colony ].C_events[ EventDataI1 ].CCSME_tOPOvPercentPopulationNotSupported
            );
      end; //==END== case: etRveOxygenShortage ==//

      ceWaterProductionOverload:
      begin
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceWaterProductionOverload;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tWPOvPercentPopulationNotSupported:=FCFgCR_WaterOverload_Calc( Entity, Colony );
      end;

      ceWaterShortage:
      begin
         {.EventDataI1 = index # for Water Production Overload event}
         EventDataI1:=FCFgCSME_Search_ByType(
            ceWaterProductionOverload
            ,Entity
            ,Colony
            );
         if EventDataI1=0
         then raise Exception.Create('there is no Water Production Overload event created, prior to Water Shortage, check the reserves consumption rule.');
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceWaterShortage;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tWShEconomicIndustrialOutputMod:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tWShTensionMod:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tWShHealthMod:=0;
         FCMgCR_WaterShortage_Calc(
            Entity
            ,Colony
            ,CurrentEventIndex
            ,FCentities[ Entity ].E_col[ Colony ].C_events[ EventDataI1 ].CCSME_tWPOvPercentPopulationNotSupported
            );
      end; //==END== case: etRveWaterShortage ==//

      ceFoodProductionOverload:
      begin
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceFoodProductionOverload;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tFPOvPercentPopulationNotSupported:=FCFgCR_FoodOverload_Calc( Entity, Colony );
      end;

      ceFoodShortage:
      begin
         {.EventDataI1 = index # for Food Production Overload event}
         EventDataI1:=FCFgCSME_Search_ByType(
            ceFoodProductionOverload
            ,Entity
            ,Colony
            );
         if EventDataI1=0
         then raise Exception.Create('there is no Food Production Overload event created, prior to Food Shortage, check the reserves consumption rule.');
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_type:=ceFoodShortage;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_isResident:=true;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_durationWeeks:=-1;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_level:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tFShEconomicIndustrialOutputMod:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tFShTensionMod:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tFShHealthMod:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tFShDirectDeathPeriod:=0;
         FCentities[Entity].E_col[Colony].C_events[CurrentEventIndex].CCSME_tFShDeathFractionalValue:=0;
         FCMgCR_FoodShortage_Calc(
            Entity
            ,Colony
            ,CurrentEventIndex
            ,FCentities[ Entity ].E_col[ Colony ].C_events[ EventDataI1 ].CCSME_tFPOvPercentPopulationNotSupported
            );
      end; //==END== case: etRveFoodShortage ==//
   end; //==END== case ETevent of ==//
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

function FCFgCSME_HealEdu_GetMod(
   const HEGMfacIdx
         ,HEGMcolIdx: integer
   ): integer;
{:Purpose: get the health-education event modifier value.
    Additions:
      -2012Apr29- *mod: refinement of the modifiers.
                  *add: apply the changes in the health levels according to the update in the document.
}
var
   HEGMhealLvl
   ,HEGMmod: integer;
begin
   Result:=0;
   HEGMmod:=0;
   HEGMhealLvl:=FCFgCSM_Health_GetIdx( HEGMfacIdx, HEGMcolIdx );
   case HEGMhealLvl of
      1: HEGMmod:=-20;
      2: HEGMmod:=-10;
      3: HEGMmod:=-5;
      4: HEGMmod:=0;
      5: HEGMmod:=5;
      6: HEGMmod:=10;
      7: HEGMmod:=20;
   end;
   Result:=HEGMmod;
end;

function FCFgCSME_Mod_Sum(
   const MStype: TFCEcsmeModTp;
   const MSfac
         ,MScolIDx: integer
   ): integer;
{:Purpose: make the sum of one type of data modifiers in one colony events list.
    Additions:
      -2012May13- *add: mtHealth section w/ all related events currently implemented.
                  *add: etRveOxygenShortage, etRveOxygenShortageRec, etRveWaterShortage, etRveWaterShortageRec, etRveFoodShortage and etRveFoodShortageRec.
      -2012May03- *mod: apply modification according to changes in the CSM event data structure.
      -2010Sep14- *add: entities faction.
      -2010Aug02- *add: health modifier.
      -2010Aug01- *add/fix: missed the result load.
      -2010Jul28- *add: economic & industrial output modifier.
}
var
   MScnt
   ,MSmax
   ,MSdmp: integer;
begin
   MSdmp:=0;
   Result:=0;
   MSmax:=length(FCentities[MSfac].E_col[MScolIDx].C_events)-1;
//   if MSmax>0
//   then
//   begin
      MScnt:=1;
      while MScnt<=MSmax do
      begin
         case MStype of
            mtCohesion:
            begin
               case FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_type of
                  ceGovernmentDestabilization, ceGovernmentDestabilization_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tGDestCohesionMod;
               end;
            end;

            mtTension:
            begin
               case FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_type of
                  ceColonyEstablished: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tCEstTensionMod;

                  ceUnrest, ceUnrest_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tCUnTensionMod;

                  ceSocialDisorder, ceSocialDisorder_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tSDisTensionMod;

                  ceUprising, ceUprising_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tUpTensionMod;

                  ceOxygenShortage, ceOxygenShortage_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tOShTensionMod;

                  ceWaterShortage, ceWaterShortage_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tWShTensionMod;

                  ceFoodShortage, ceFoodShortage_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tFShTensionMod;
               end;
            end;

            mtSecurity:
            begin
               case FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_type of
                  ceColonyEstablished: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tCEstSecurityMod;
               end;
            end;

            mtInstruction:
            begin
               case FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_type of
                  ceHealthEducationRelation: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tHERelEducationMod;
               end;
            end;

            mtEcoIndOutput:
            begin
               case FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_type of
                  ceUnrest, ceUnrest_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tCUnEconomicIndustrialOutputMod;

                  ceSocialDisorder, ceSocialDisorder_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tSDisEconomicIndustrialOutputMod;

                  ceUprising, ceUprising_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tUpEconomicIndustrialOutputMod;

                  ceOxygenShortage, ceOxygenShortage_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tOShEconomicIndustrialOutputMod;

                  ceWaterShortage, ceWaterShortage_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tWShEconomicIndustrialOutputMod;

                  ceFoodShortage, ceFoodShortage_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tFShEconomicIndustrialOutputMod;
               end;
            end;

            mtHealth:
            begin
               case FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_type of
                  ceOxygenShortage, ceOxygenShortage_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tOShHealthMod;

                  ceWaterShortage, ceWaterShortage_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tWShHealthMod;

                  ceFoodShortage, ceFoodShortage_Recovering: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].C_events[MScnt].CCSME_tFShHealthMod;
               end;
            end;
         end; //==END== case MStype of ==//
         inc(MScnt);
      end; //==END== while MScnt<=MSmax do ==//
//   end;
   Result:=MSdmp;
end;

function FCFgCSME_UnSup_Find(
   const USFfac
         ,USFcol: integer
   ): TFCEdgColonyEvents;
{:Purpose: find if any Unrest, Social Disorder, Uprising or Dissident Colony event is set, and return the type.
    Additions:
      -2010Sep14- *add: entities code.
}
var
   USFcnt
   ,USFmax: integer;
begin
   Result:=ceColonyEstablished;
   USFmax:=length(FCentities[USFfac].E_col[USFcol].C_events)-1;
   if USFmax>1
   then
   begin
      USFcnt:=2;
      while USFcnt<=USFmax do
      begin
         if (
               (FCentities[USFfac].E_col[USFcol].C_events[USFcnt].CCSME_type=ceUnrest)
                  or (FCentities[USFfac].E_col[USFcol].C_events[USFcnt].CCSME_type=ceUnrest_Recovering)
                  or (FCentities[USFfac].E_col[USFcol].C_events[USFcnt].CCSME_type=ceSocialDisorder)
                  or (FCentities[USFfac].E_col[USFcol].C_events[USFcnt].CCSME_type=ceSocialDisorder_Recovering)
                  or (FCentities[USFfac].E_col[USFcol].C_events[USFcnt].CCSME_type=ceUprising)
                  or (FCentities[USFfac].E_col[USFcol].C_events[USFcnt].CCSME_type=ceUprising_Recovering)
                  or (FCentities[USFfac].E_col[USFcol].C_events[USFcnt].CCSME_type=ceDissidentColony)
                  )
         then
         begin
            Result:=FCentities[USFfac].E_col[USFcol].C_events[USFcnt].CCSME_type;
            break;
         end
         else inc(USFcnt);
      end;
   end;
end;

procedure FCMgCSME_Recovering_Process(
   const Entity
         ,Colony
         ,Event: integer
   );
{:Purpose: apply one time the recover rule on a specified event.
    Additions:
      -2012May16- *add: etRveOxygenShortageRec, etRveWaterShortageRec and etRveFoodShortageRec.
                  *add: rule process for the health modifier.
                  *code: put the method in public.
}
   var
      AbsoluteCoefficient
      ,ModCohesion
      ,ModEcoIndOutput
      ,ModTension
      ,ModHealth
      ,NewCohesion
      ,NewEcoIndOutput
      ,NewTension
      ,NewHealth: integer;
begin
   AbsoluteCoefficient:=0;
   ModCohesion:=0;
   ModEcoIndOutput:=0;
   ModTension:=0;
   ModHealth:=0;
   NewCohesion:=0;
   NewEcoIndOutput:=0;
   NewTension:=0;
   NewHealth:=0;
   {.we retrieve the specific data}
   case FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_type of
      ceUnrest_Recovering:
      begin
         ModEcoIndOutput:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tCUnEconomicIndustrialOutputMod;
         ModTension:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tCUnTensionMod;
      end;

      ceSocialDisorder_Recovering:
      begin
         ModEcoIndOutput:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tSDisEconomicIndustrialOutputMod;
         ModTension:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tSDisTensionMod;
      end;

      ceUprising_Recovering:
      begin
         ModEcoIndOutput:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tUpEconomicIndustrialOutputMod;
         ModTension:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tUpTensionMod;
      end;

      ceGovernmentDestabilization_Recovering: ModCohesion:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tGDestCohesionMod;

      ceOxygenShortage_Recovering:
      begin
         ModEcoIndOutput:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tOShEconomicIndustrialOutputMod;
         ModTension:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tOShTensionMod;
         ModHealth:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tOShHealthMod;
      end;

      ceWaterShortage_Recovering:
      begin
         ModEcoIndOutput:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tWShEconomicIndustrialOutputMod;
         ModTension:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tWShTensionMod;
         ModHealth:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tWShHealthMod;
      end;

      ceFoodShortage_Recovering:
      begin
         ModEcoIndOutput:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tFShEconomicIndustrialOutputMod;
         ModTension:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tFShTensionMod;
         ModHealth:=FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tFShHealthMod;
      end;
   end; //==END== case FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].CSMEV_token of ==//
   {.rule process for each modifier}
   if ModCohesion<0 then
   begin
      AbsoluteCoefficient:=abs( round( ModCohesion * 0.1 ) );
      if AbsoluteCoefficient=0
      then AbsoluteCoefficient:=1;
   end
   else if ModCohesion>0 then
   begin
      AbsoluteCoefficient:=-round( ModCohesion * 0.1 );
      if AbsoluteCoefficient=0
      then AbsoluteCoefficient:=-1;
   end
   else AbsoluteCoefficient:=0;
   NewCohesion:=ModCohesion+AbsoluteCoefficient;
   if ModEcoIndOutput<0 then
   begin
      AbsoluteCoefficient:=abs( round( ModEcoIndOutput * 0.1 ) );
      if AbsoluteCoefficient=0
      then AbsoluteCoefficient:=1;
   end
   else if ModEcoIndOutput>0 then
   begin
      AbsoluteCoefficient:=-round( ModEcoIndOutput * 0.1 );
      if AbsoluteCoefficient=0
      then AbsoluteCoefficient:=-1;
   end
   else AbsoluteCoefficient:=0;
   NewEcoIndOutput:=ModEcoIndOutput+AbsoluteCoefficient;
   if ModTension<0 then
   begin
      AbsoluteCoefficient:=abs( round( ModTension * 0.1 ) );
      if AbsoluteCoefficient=0
      then AbsoluteCoefficient:=1;
   end
   else if ModTension>0 then
   begin
      AbsoluteCoefficient:=-round( ModTension * 0.1 );
      if AbsoluteCoefficient=0
      then AbsoluteCoefficient:=-1;
   end
   else AbsoluteCoefficient:=0;
   NewTension:=ModTension+AbsoluteCoefficient;
   if ModHealth<0 then
   begin
      AbsoluteCoefficient:=abs( round( ModHealth * 0.1 ) );
      if AbsoluteCoefficient=0
      then AbsoluteCoefficient:=1;
   end
   else if ModHealth>0 then
   begin
      AbsoluteCoefficient:=-round( ModHealth * 0.1 );
      if AbsoluteCoefficient=0
      then AbsoluteCoefficient:=-1;
   end
   else AbsoluteCoefficient:=0;
   NewHealth:=ModHealth+AbsoluteCoefficient;
   {.determine if the recovering is finished + whatever the case, update the CSM}
   case FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_type of
      ceUnrest_Recovering:
      begin
         if ( NewEcoIndOutput=0 )
            and ( NewTension=0 )
         then FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_durationWeeks:=-2;
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tCUnEconomicIndustrialOutputMod:=NewEcoIndOutput;
         FCMgCSM_ColonyData_Upd(
            dEcoIndusOut
            ,Entity
            ,Colony
            ,NewEcoIndOutput
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tCUnTensionMod:=NewTension;
         FCMgCSM_ColonyData_Upd(
            dTension
            ,Entity
            ,Colony
            ,NewTension
            ,0
            ,gcsmptNone
            ,false
            );
      end; //==END== case: etUnrestRec ==//

      ceSocialDisorder_Recovering:
      begin
         if ( NewEcoIndOutput=0 )
            and ( NewTension=0 )
         then FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_durationWeeks:=-2;
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tSDisEconomicIndustrialOutputMod:=NewEcoIndOutput;
         FCMgCSM_ColonyData_Upd(
            dEcoIndusOut
            ,Entity
            ,Colony
            ,NewEcoIndOutput
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tSDisTensionMod:=NewTension;
         FCMgCSM_ColonyData_Upd(
            dTension
            ,Entity
            ,Colony
            ,NewTension
            ,0
            ,gcsmptNone
            ,false
            );
      end; //==END== case: etSocdisRec ==//

      ceUprising_Recovering:
      begin
         if ( NewEcoIndOutput=0 )
            and ( NewTension=0 )
         then FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_durationWeeks:=-2;
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tUpEconomicIndustrialOutputMod:=NewEcoIndOutput;
         FCMgCSM_ColonyData_Upd(
            dEcoIndusOut
            ,Entity
            ,Colony
            ,NewEcoIndOutput
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tUpTensionMod:=NewTension;
         FCMgCSM_ColonyData_Upd(
            dTension
            ,Entity
            ,Colony
            ,NewTension
            ,0
            ,gcsmptNone
            ,false
            );
      end; //==END== case: etUprisingRec ==//

      ceGovernmentDestabilization_Recovering:
      begin
         if NewCohesion=0
         then FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_durationWeeks:=-2;
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tGDestCohesionMod:=NewCohesion;
         FCMgCSM_ColonyData_Upd(
            dCohesion
            ,Entity
            ,Colony
            ,NewCohesion
            ,0
            ,gcsmptNone
            ,false
            );
      end; //==END== case: etGovDestabRec ==//

      ceOxygenShortage_Recovering:
      begin
         if ( NewEcoIndOutput=0 )
            and ( NewTension=0 )
            and ( NewHealth=0 )
         then FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_durationWeeks:=-2;
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tOShEconomicIndustrialOutputMod:=NewEcoIndOutput;
         FCMgCSM_ColonyData_Upd(
            dEcoIndusOut
            ,Entity
            ,Colony
            ,NewEcoIndOutput
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tOShTensionMod:=NewTension;
         FCMgCSM_ColonyData_Upd(
            dTension
            ,Entity
            ,Colony
            ,NewTension
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tOShHealthMod:=NewHealth;
         FCMgCSM_ColonyData_Upd(
            dHealth
            ,Entity
            ,Colony
            ,NewHealth
            ,0
            ,gcsmptNone
            ,false
            );
      end; //==END== case: etRveOxygenShortageRec ==//

      ceWaterShortage_Recovering:
      begin
         if ( NewEcoIndOutput=0 )
            and ( NewTension=0 )
            and ( NewHealth=0 )
         then FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_durationWeeks:=-2;
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tWShEconomicIndustrialOutputMod:=NewEcoIndOutput;
         FCMgCSM_ColonyData_Upd(
            dEcoIndusOut
            ,Entity
            ,Colony
            ,NewEcoIndOutput
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tWShTensionMod:=NewTension;
         FCMgCSM_ColonyData_Upd(
            dTension
            ,Entity
            ,Colony
            ,NewTension
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tWShHealthMod:=NewHealth;
         FCMgCSM_ColonyData_Upd(
            dHealth
            ,Entity
            ,Colony
            ,NewHealth
            ,0
            ,gcsmptNone
            ,false
            );
      end; //==END== case: etRveWaterShortageRec ==//

      ceFoodShortage_Recovering:
      begin
         if ( NewEcoIndOutput=0 )
            and ( NewTension=0 )
            and ( NewHealth=0 )
         then FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_durationWeeks:=-2;
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tFShEconomicIndustrialOutputMod:=NewEcoIndOutput;
         FCMgCSM_ColonyData_Upd(
            dEcoIndusOut
            ,Entity
            ,Colony
            ,NewEcoIndOutput
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tFShTensionMod:=NewTension;
         FCMgCSM_ColonyData_Upd(
            dTension
            ,Entity
            ,Colony
            ,NewTension
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].C_events[ Event ].CCSME_tFShHealthMod:=NewHealth;
         FCMgCSM_ColonyData_Upd(
            dHealth
            ,Entity
            ,Colony
            ,NewHealth
            ,0
            ,gcsmptNone
            ,false
            );
      end; //==END== case: etRveFoodShortageRec ==//
   end; //==END== case FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].CSMEV_token of ==//
end;

procedure FCMgCSME_OT_Proc(
   const Entity
         ,Colony: integer
   );
{:Purpose: over time processing for events of a colony.
   Additions:
      -2012May21- *add: etRveFoodShortage for the direct death process.
      -2012May16- *fix: for CPS test, do it ONLY if it'S NOT the player's faction.
      -2012May15- *rem: etRveOxygenOverload is removed, there's no process in CSM phase of this event, it's processed in the segment 3 of the production phase.
      -2012May06- *mod: apply modification according to changes in the CSM event data structure.
                  *mod: cleanup data assignation by using FCMgCSM_ColonyData_Upd.
                  *add: complete the recovering part for the concerned events.
                  *add: etRveOxygenOverload event.
      -2012Apr30- *add: update the colony panel if needed.
      -2011Jan20- *add: government destabilization - recovery calculations.
      -2011Jan19- *add: government destabilization.
      -2010Sep14- *add: entities code.
      -2010Sep05- *mod: correctly transfer the event list to the temp one, for post process.
      -2010Aug29- *add: Uprising - event resolve rules.
                  *add: finalize the recovery events.
                  *add: Dissident Colony.
                  *add: post process sub-routine for event resolving.
      -2010Aug26- *add: Uprising - population losses are calculated proportionally on each population classes.
                                 - -1 cohesion is directly applied after the end of each fighting round.
                                 - add the case where the Uprising event has been triggered w/o soldiers available (w/ a duration).
      -2010Aug25- *add: Uprising - rebels equipment + security modifiers + fighting calculations (including losses).
      -2010Aug24- *add: Social Disorder + Social Disorder(recovering).
                  *add: Uprising.
                  *add: Uprising fighting system (WIP).
}
var
   OTPcivil: integer;
   OTPamnt
   ,OTPcasPop
   ,OTPcasSold
   ,OTPcnt
   ,OTPcurr
   ,OTPmax
   ,OTPmili
   ,OTPmod1
   ,OTPmod2
   ,OTPmod3
   ,OTPmodCoh
   ,OTPmodEiO
   ,OTPmodSec
   ,OTPmodTens
   ,OTPpCnt
   ,OTPpopTtl
   ,OTPreb
   ,OTPrem
   ,OTPsec
   ,OTPsold: integer;

   OTPratio
   ,OTPratioPop
   ,OTPratioSold
   ,OTPrebEqup: extended;

   OTPevArr: array of TFCRdgColonyCSMEvent;
begin
   OTPmax:=length(FCentities[Entity].E_col[Colony].C_events)-1;
   if OTPmax>1
   then
   begin
      OTPcnt:=1;
      while OTPcnt<=OTPmax do
      begin
         case FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_type of
            ceColonyEstablished:
            begin
               OTPmodTens:=FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tCEstTensionMod;
               OTPmodSec:=FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tCEstSecurityMod;
               case FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_level of
                  0:
                  begin
                     OTPmod1:=-5;
                     OTPmod2:=4;
                  end;
                  1:
                  begin
                     OTPmod1:=-3;
                     OTPmod2:=4;
                  end;
                  2:
                  begin
                     OTPmod1:=-2;
                     OTPmod2:=3;
                  end;
               end;
               FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tCEstTensionMod:=OTPmodTens+OTPmod1;
               FCMgCSM_ColonyData_Upd(
                  dTension
                  ,Entity
                  ,Colony
                  ,OTPmod1
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tCEstSecurityMod:=OTPmodSec+OTPmod2;
               FCMgCSM_ColonyData_Upd(
                  dSecurity
                  ,Entity
                  ,Colony
                  ,0
                  ,0
                  ,gcsmptNone
                  ,true
                  );
               dec(FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks);
               if FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks=0
               then FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks:=-2;
            end; //==END== case: etColEstab ==//

            ceUnrest:
            begin
               OTPmodEiO:=FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tCUnEconomicIndustrialOutputMod;
               OTPmodTens:=FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tCUnTensionMod;
               case FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_level of
                  1:
                  begin
                     OTPmod1:=-3;
                     OTPmod2:=5;
                  end;
                  2:
                  begin
                     OTPmod1:=-3;
                     OTPmod2:=5;
                  end;
                  3:
                  begin
                     OTPmod1:=-3;
                     OTPmod2:=4;
                  end;
                  4:
                  begin
                     OTPmod1:=-2;
                     OTPmod2:=4;
                  end;
                  5:
                  begin
                     OTPmod1:=-2;
                     OTPmod2:=3;
                  end;
                  6:
                  begin
                     OTPmod1:=-1;
                     OTPmod2:=2;
                  end;
                  7:
                  begin
                     OTPmod1:=-1;
                     OTPmod2:=1;
                  end;
                  8..9:
                  begin
                     OTPmod1:=-1;
                     OTPmod2:=1;
                  end;
               end;
               FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tCUnEconomicIndustrialOutputMod:=OTPmodEiO+OTPmod1;
               FCMgCSM_ColonyData_Upd(
                  dEcoIndusOut
                  ,Entity
                  ,Colony
                  ,OTPmod1
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tCUnTensionMod:=OTPmodTens+OTPmod2;
               FCMgCSM_ColonyData_Upd(
                  dTension
                  ,Entity
                  ,Colony
                  ,OTPmod2
                  ,0
                  ,gcsmptNone
                  ,false
                  );


            end; //==END== case: etUnrest ==//

            ceUnrest_Recovering: FCMgCSME_Recovering_Process(
               Entity
               ,Colony
               ,OTPcnt
               );

            ceSocialDisorder:
            begin
               OTPmodEiO:=FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tSDisEconomicIndustrialOutputMod;
               OTPmodTens:=FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tSDisTensionMod;
               case FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_level of
                  1:
                  begin
                     OTPmod1:=-5;
                     OTPmod2:=8;
                  end;
                  2:
                  begin
                     OTPmod1:=-5;
                     OTPmod2:=8;
                  end;
                  3:
                  begin
                     OTPmod1:=-4;
                     OTPmod2:=5;
                  end;
                  4:
                  begin
                     OTPmod1:=-3;
                     OTPmod2:=5;
                  end;
                  5:
                  begin
                     OTPmod1:=-2;
                     OTPmod2:=3;
                  end;
                  6:
                  begin
                     OTPmod1:=-1;
                     OTPmod2:=2;
                  end;
                  7:
                  begin
                     OTPmod1:=-1;
                     OTPmod2:=1;
                  end;
                  8..9:
                  begin
                     OTPmod1:=-1;
                     OTPmod2:=1;
                  end;
               end;
               FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tSDisEconomicIndustrialOutputMod:=OTPmodEiO+OTPmod1;
               FCMgCSM_ColonyData_Upd(
                  dEcoIndusOut
                  ,Entity
                  ,Colony
                  ,OTPmod1
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tSDisTensionMod:=OTPmodTens+OTPmod2;
               FCMgCSM_ColonyData_Upd(
                  dTension
                  ,Entity
                  ,Colony
                  ,OTPmod2
                  ,0
                  ,gcsmptNone
                  ,false
                  );
            end; //==END== case: etSocdis ==//

            ceSocialDisorder_Recovering: FCMgCSME_Recovering_Process(
               Entity
               ,Colony
               ,OTPcnt
               );

            ceUprising:
            begin
               OTPmodEiO:=FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tUpEconomicIndustrialOutputMod;
               OTPmodTens:=FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tUpTensionMod;
               case FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_level of
                  1:
                  begin
                     OTPmod1:=-8;
                     OTPmod2:=13;
                     OTPrebEqup:=3;
                  end;
                  2:
                  begin
                     OTPmod1:=-7;
                     OTPmod2:=10;
                     OTPrebEqup:=2;
                  end;
                  3:
                  begin
                     OTPmod1:=-4;
                     OTPmod2:=6;
                     OTPrebEqup:=2;
                  end;
                  4:
                  begin
                     OTPmod1:=-2;
                     OTPmod2:=3;
                     OTPrebEqup:=1;
                  end;
                  5:
                  begin
                     OTPmod1:=-2;
                     OTPmod2:=2;
                     OTPrebEqup:=0.5;
                  end;
               end;
               FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tUpEconomicIndustrialOutputMod:=OTPmodEiO+OTPmod1;
               FCMgCSM_ColonyData_Upd(
                  dEcoIndusOut
                  ,Entity
                  ,Colony
                  ,OTPmod1
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tUpTensionMod:=OTPmodTens+OTPmod2;
               FCMgCSM_ColonyData_Upd(
                  dTension
                  ,Entity
                  ,Colony
                  ,OTPmod2
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               {.fighting system}
               OTPsold:=FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier;
               OTPreb:=FCentities[Entity].E_col[Colony].C_population.CP_classRebels;
               if OTPsold>0
               then
               begin
                  {.in case of soldiers were been added after that the uprising event was set}
                  if FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks<>-1
                  then FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks:=-1;
                  OTPsec:=StrToInt(
                     FCFgCSM_Security_GetIdxStr(
                        Entity
                        ,Colony
                        ,true
                        )
                     );
                  case OTPsec of
                     1: OTPmod3:=-40;
                     2: OTPmod3:=-15;
                     3: OTPmod3:=0;
                     4: OTPmod3:=10;
                     5: OTPmod3:=25;
                  end;
                  OTPratioPop:=(OTPreb/5)*OTPrebEqup;
                  {.Ratiosold= sold*equip + secu modifier,  equip is hardcoded for now, until equipment for soldiers is integrated}
                  OTPratioSold:=(OTPsold*2)*(1+(OTPmod3*0.01));
                  OTPratio:=(OTPratioPop/OTPratioSold)+0.444;
                  OTPcasPop:=round(sqrt(OTPreb)/OTPratio);
                  if OTPcasPop>OTPreb
                  then OTPcasPop:=OTPreb;
                  OTPcasSold:=round(sqrt(OTPsold)*OTPratio);
                  if OTPcasSold>OTPsold
                  then OTPcasSold:=OTPsold;
                  {.population losses are calculated proportionally on each population classes}
                  OTPcurr:=OTPcasPop;
                  OTPpopTtl:=FCentities[Entity].E_col[Colony].C_population.CP_total-OTPsold;
                  OTPpCnt:=1;
                  while OTPcurr>0 do
                  begin
                     case OTPpcnt of
                        {.colonists}
                        1:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classColonist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classColonist*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptColon
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptColon
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: colonists ==//
                        {.aerospace officers}
                        2:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classAerOfficer>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classAerOfficer*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptASoff
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptASoff
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: aerospace officers ==//
                        {.mission specialists}
                        3:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classAerMissionSpecialist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classAerMissionSpecialist*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptASmiSp
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptASmiSp
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: mission specialists ==//
                        {.biologists}
                        4:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classBioBiologist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classBioBiologist*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptBSbio
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptBSbio
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: biologists ==//
                        {.doctors}
                        5:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classBioDoctor>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classBioDoctor*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptBSdoc
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptBSdoc
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: doctors ==//
                        {.technicians}
                        6:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classIndTechnician>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classIndTechnician*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptIStech
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptIStech
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: technicians ==//
                        {.engineers}
                        7:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classIndEngineer>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classIndEngineer*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptISeng
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptISeng
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: engineers ==//
                        {.commandos}
                        8:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classMilCommando>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classMilCommando*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptMScomm
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptMScomm
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: commandos ==//
                        {.physicists}
                        9:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classPhyPhysicist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classPhyPhysicist*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptPSphys
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptPSphys
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: physicists ==//
                        {.astrophysicists}
                        10:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classPhyAstrophysicist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classPhyAstrophysicist*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptPSastr
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptPSastr
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: astrophysicists ==//
                        {.ecologists}
                        11:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classEcoEcologist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classEcoEcologist*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptESecol
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptESecol
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: ecologists ==//
                        {.ecoformers}
                        12:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classEcoEcoformer>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classEcoEcoformer*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptESecof
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptESecof
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: ecoformers ==//
                        {.medians}
                        13:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classAdmMedian>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classAdmMedian*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptAmedian
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptAmedian
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: medians ==//
                     end; //==END== case OTPpcnt of ==//
                     inc(OTPpCnt);
                     if OTPcnt>13
                     then break;
                  end; //==END== while OTPcurr>0 do ==//
                  {.final data changes}
                  FCentities[Entity].E_col[Colony].C_population.CP_classRebels:=OTPreb-OTPcasPop;
                  FCMgCSM_ColonyData_Upd(
                     dPopulation
                     ,Entity
                     ,Colony
                     ,-OTPcasSold
                     ,0
                     ,gcsmptMSsold
                     ,true
                     );
                  FCMgCSM_ColonyData_Upd(
                     dCohesion
                     ,Entity
                     ,Colony
                     ,-1
                     ,0
                     ,gcsmptNone
                     ,false
                     );
                  {.event resolving rules}
                  if FCentities[Entity].E_col[Colony].C_population.CP_classRebels=0
                  then FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks:=-3
                  else if FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier=0
                  then FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks:=-4;
               end //==END== if OTPsold>0 ==//
               else if (OTPsold=0)
                  and (FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks<>-1)
               then
               begin
                  dec(FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks);
                  {.event resolving rules}
                  if FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks=0
                  then FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks:=-2
               end;
            end; //==END== case: etUprising ==//

            ceUprising_Recovering: FCMgCSME_Recovering_Process(
               Entity
               ,Colony
               ,OTPcnt
               );

            ceDissidentColony:
            begin
               case FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_level of
                  {.unrest}
                  1: OTPrebEqup:=1;
                  {.social disorder}
                  2: OTPrebEqup:=2;
                  {.uprising}
                  3: OTPrebEqup:=3;
               end;
               {.fighting system}
               OTPsold:=FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier;
               OTPreb:=FCentities[Entity].E_col[Colony].C_population.CP_classRebels;
               OTPmili:=FCentities[Entity].E_col[Colony].C_population.CP_classMilitia;
               if (OTPsold>0)
                  or (OTPmili>0)
               then
               begin
                  OTPsec:=StrToInt(
                     FCFgCSM_Security_GetIdxStr(
                        Entity
                        ,Colony
                        ,true
                        )
                     );
                  case OTPsec of
                     1: OTPmod3:=-40;
                     2: OTPmod3:=-15;
                     3: OTPmod3:=0;
                     4: OTPmod3:=10;
                     5: OTPmod3:=25;
                  end;
                  OTPratioPop:=(OTPreb*0.2)*OTPrebEqup;
                  {.Ratiosold= sold*equip + secu modifier,  equip is hardcoded for now, until equipment for soldiers is integrated}
                  if OTPsold>0
                  then OTPratioSold:=(OTPsold*2)*(1+(OTPmod3*0.01))
                  else if OTPmili>0
                  then OTPratioSold:=OTPmili*0.2*2;
                  OTPratio:=(OTPratioPop/OTPratioSold)+0.444;
                  OTPcasPop:=round(sqrt(OTPreb)/OTPratio);
                  if OTPcasPop>OTPreb
                  then OTPcasPop:=OTPreb;
                  OTPcasSold:=round(sqrt(OTPsold+OTPmili)*OTPratio);
                  if OTPcasSold>(OTPsold+OTPmili)
                  then OTPcasSold:=(OTPsold+OTPmili);
                  {.population losses are calculated proportionally on each population classes, if there's militia casualties, it's also counted in it}
                  if OTPmili>0
                  then OTPcurr:=OTPcasPop+OTPcasSold
                  else if OTPmili=0
                  then OTPcurr:=OTPcasPop;
                  OTPcivil:=OTPcurr;
                  OTPpopTtl:=FCentities[Entity].E_col[Colony].C_population.CP_total-OTPsold;
                  OTPpCnt:=1;
                  while OTPcurr>0 do
                  begin
                     case OTPpcnt of
                        {.colonists}
                        1:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classColonist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classColonist*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptColon
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptColon
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: colonists ==//
                        {.aerospace officers}
                        2:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classAerOfficer>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classAerOfficer*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptASoff
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptASoff
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: aerospace officers ==//
                        {.mission specialists}
                        3:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classAerMissionSpecialist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classAerMissionSpecialist*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptASmiSp
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptASmiSp
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: mission specialists ==//
                        {.biologists}
                        4:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classBioBiologist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classBioBiologist*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptBSbio
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptBSbio
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: biologists ==//
                        {.doctors}
                        5:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classBioDoctor>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classBioDoctor*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptBSdoc
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptBSdoc
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: doctors ==//
                        {.technicians}
                        6:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classIndTechnician>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classIndTechnician*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptIStech
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptIStech
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: technicians ==//
                        {.engineers}
                        7:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classIndEngineer>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classIndEngineer*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptISeng
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptISeng
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: engineers ==//
                        {.commandos}
                        8:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classMilCommando>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classMilCommando*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptMScomm
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptMScomm
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: commandos ==//
                        {.physicists}
                        9:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classPhyPhysicist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classPhyPhysicist*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptPSphys
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptPSphys
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: physicists ==//
                        {.astrophysicists}
                        10:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classPhyAstrophysicist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classPhyAstrophysicist*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptPSastr
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptPSastr
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: astrophysicists ==//
                        {.ecologists}
                        11:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classEcoEcologist>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classEcoEcologist*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptESecol
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptESecol
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: ecologists ==//
                        {.ecoformers}
                        12:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classEcoEcoformer>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classEcoEcoformer*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptESecof
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptESecof
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: ecoformers ==//
                        {.medians}
                        13:
                        begin
                           if FCentities[Entity].E_col[Colony].C_population.CP_classAdmMedian>0
                           then
                           begin
                              OTPrem:=round(FCentities[Entity].E_col[Colony].C_population.CP_classAdmMedian*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPcurr
                                    ,0
                                    ,gcsmptAmedian
                                    ,false
                                    );
                                 OTPcurr:=0;
                              end
                              else if OTPrem<OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,Entity
                                    ,Colony
                                    ,-OTPrem
                                    ,0
                                    ,gcsmptAmedian
                                    ,false
                                    );
                                 OTPcurr:=OTPcurr-OTPrem;
                              end;
                           end;
                        end; //==END== case: medians ==//
                     end; //==END== case OTPpcnt of ==//
                     inc(OTPpCnt);
                     if OTPcnt>13
                     then break;
                  end; //==END== while OTPcurr>0 do ==//
                  {.final data changes}
                  FCentities[Entity].E_col[Colony].C_population.CP_classRebels:=OTPreb-OTPcasPop;
                  if OTPmili>0
                  then FCentities[Entity].E_col[Colony].C_population.CP_classMilitia:=OTPmili-OTPcasSold
                  else if OTPsold>0
                  then FCMgCSM_ColonyData_Upd(
                     dPopulation
                     ,Entity
                     ,Colony
                     ,-OTPcasSold
                     ,0
                     ,gcsmptMSsold
                     ,true
                     );
                  FCMgCSM_ColonyData_Upd(
                     dCohesion
                     ,Entity
                     ,Colony
                     ,-1
                     ,0
                     ,gcsmptNone
                     ,false
                     );
                  {.event resolving rules}
                  if FCentities[Entity].E_col[Colony].C_population.CP_classRebels=0
                  then FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks:=-3
                  else if (FCentities[Entity].E_col[Colony].C_population.CP_classMilSoldier=0)
                     and (FCentities[Entity].E_col[Colony].C_population.CP_classMilitia=0)
                  then FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks:=-4;
               end //==END== if OTPsold>0 or OTPmili>0 ==//
               else if (OTPsold=0)
                  and (OTPmili=0)
               then FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks:=-2;
            end; //==END== case: etColDissident: ==//

            ceGovernmentDestabilization:
            begin
               OTPmodCoh:=FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tGDestCohesionMod;
               OTPmod1:=0;
               case FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_level of
                  2..3: OTPmod1:=-2;
                  5..6: OTPmod1:=-3;
                  8..9: OTPmod1:=-5;
               end;
               FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tGDestCohesionMod:=OTPmodCoh+OTPmod1;
               FCMgCSM_ColonyData_Upd(
                  dCohesion
                  ,Entity
                  ,Colony
                  ,OTPmod1
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               if FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks>0
               then
               begin
                  dec(FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks);
                  if FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks=0
                  then FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks:=-2;
                                    {:DEV NOTES: enable the new HQ, if duration or reorganization time is equal to 0, and put the event in recovery.}
//                  if FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration=0
//                  then HQ get + HQ enable + Rec;
//                  if FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration=0
//                  then
               end;
            end;

            ceGovernmentDestabilization_Recovering: FCMgCSME_Recovering_Process(
               Entity
               ,Colony
               ,OTPcnt
               );

            ceFoodShortage:
            begin
               dec( FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tFShDirectDeathPeriod);
               if FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tFShDirectDeathPeriod=0 then
               begin
                  if FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tFShPercentPopulationNotSupportedAtCalculation>10
                  then FCMgCR_FoodShortage_DirectDeath(
                     Entity
                     ,Colony
                     ,OTPcnt
                     ,0
                     );
                  FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_tFShDirectDeathPeriod:=4;
               end;
            end;
         end; //==END== case FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_token of ==//
         inc(OTPcnt);
      end; //==END== while OTPcnt<=OTPmax do ==//
      {.post-process sub-routine for event resolving}
      setlength(OTPevArr, length(FCentities[Entity].E_col[Colony].C_events));
      {.load the event list data structure in a temp data structure. It's required to have this extra loop because in the next one the origin event list
         will be altered. Mainly by event cancellations call}
      OTPcnt:=1;
      while OTPcnt<=OTPmax do
      begin
         OTPevArr[OTPcnt]:=FCentities[Entity].E_col[Colony].C_events[OTPcnt];
         inc(OTPcnt);
      end;
      OTPcnt:=1;
      while OTPcnt<=OTPmax do
      begin
         if OTPevArr[OTPcnt].CCSME_durationWeeks<=-2 then
         begin
            case OTPevArr[OTPcnt].CCSME_type of
               ceColonyEstablished, ceUnrest_Recovering, ceSocialDisorder_Recovering:
               begin
                  if OTPcnt=OTPmax
                  then FCMgCSME_Event_Cancel(
                     csmeecImmediate
                     ,Entity
                     ,Colony
                     ,OTPcnt
                     ,ceColonyEstablished
                     ,0
                     )
                  else FCMgCSME_Event_Cancel(
                     csmeecImmediateDelay
                     ,Entity
                     ,Colony
                     ,OTPcnt
                     ,ceColonyEstablished
                     ,0
                     );
               end;

               ceUprising:
               begin
                  if (OTPevArr[OTPcnt].CCSME_durationWeeks=-2)
                     or (OTPevArr[OTPcnt].CCSME_durationWeeks=-3)
                  then
                  begin
                     FCMgCSME_Event_Cancel(
                        csmeecOverride
                        ,Entity
                        ,Colony
                        ,OTPcnt
                        ,ceSocialDisorder
                        ,OTPevArr[OTPcnt].CCSME_level
                        );
                     FCentities[Entity].E_col[Colony].C_population.CP_classRebels:=0;
                  end
                  else if OTPevArr[OTPcnt].CCSME_durationWeeks=-4
                  then FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_durationWeeks:=round(sqrt(FCentities[Entity].E_col[Colony].C_population.CP_classRebels));
               end;

               ceUprising_Recovering:
               begin
                  if OTPcnt=OTPmax
                  then FCMgCSME_Event_Cancel(
                     csmeecImmediate
                     ,Entity
                     ,Colony
                     ,OTPcnt
                     ,ceColonyEstablished
                     ,0
                     )
                  else FCMgCSME_Event_Cancel(
                     csmeecImmediateDelay
                     ,Entity
                     ,Colony
                     ,OTPcnt
                     ,ceColonyEstablished
                     ,0
                     );
               end;

               ceDissidentColony:
               begin
                  if OTPevArr[OTPcnt].CCSME_durationWeeks=-2
                  then
                  begin
                     if OTPcnt=OTPmax
                     then FCMgCSME_Event_Cancel(
                        csmeecImmediate
                        ,Entity
                        ,Colony
                        ,OTPcnt
                        ,ceColonyEstablished
                        ,0
                        )
                     else FCMgCSME_Event_Cancel(
                        csmeecImmediateDelay
                        ,Entity
                        ,Colony
                        ,OTPcnt
                        ,ceColonyEstablished
                        ,0
                        );
                  end
                  else if OTPevArr[OTPcnt].CCSME_durationWeeks=-3
                  then
                  begin
                     if ( Entity=0)
                        and ( Assigned(FCcps) )
                     then FCMgCore_GameOver_Process( gfrCPScolonyBecameDissident )
                     else begin
                        {:DEV NOTES: colony is lost.
                        the procedure to implement when AI will be done:
                           1/create a faction for the dissident colony and transfert the colony's data to the new faction's sub-datastructure
                           2/cleanup the player's or AI faction w/ the lost colony
                           2/initialize an entity and assign the new colony's faction on it
                           3/raise the new independent colony's cohesion w/: new Cohesion= (CurrentCohesion + 20%)*2.
                           4/process landed space units if there's any
                        }
                     end;
                  end
                  else if OTPevArr[OTPcnt].CCSME_durationWeeks=-4
                  then
                  begin
                     OTPmod1:=0;
                     case FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_level of
                        1: OTPmod1:=1;
                        2: OTPmod1:=5;
                        3: OTPmod1:=10;
                        4: OTPmod1:=15;
                     end;
                     FCMgCSME_Event_Cancel(
                        csmeecOverride
                        ,Entity
                        ,Colony
                        ,OTPcnt
                        ,ceUprising
                        ,FCentities[Entity].E_col[Colony].C_events[OTPcnt].CCSME_level*2
                        );
                     FCMgCSM_ColonyData_Upd(
                        dCohesion
                        ,Entity
                        ,Colony
                        ,OTPmod1
                        ,0
                        ,gcsmptNone
                        ,false
                        );
                     FCentities[Entity].E_col[Colony].C_population.CP_classRebels:=0;
                     FCentities[Entity].E_col[Colony].C_population.CP_classMilitia:=0;
                  end;
               end; //==END== case: etColDissident ==//

               ceGovernmentDestabilization:
               begin
                  FCMgCSME_Event_Cancel(
                     csmeecRecover
                     ,Entity
                     ,Colony
                     ,OTPcnt
                     ,ceColonyEstablished
                     ,0
                     );
               end;

               ceGovernmentDestabilization_Recovering:
               begin
                  if OTPcnt=OTPmax
                  then FCMgCSME_Event_Cancel(
                     csmeecImmediate
                     ,Entity
                     ,Colony
                     ,OTPcnt
                     ,ceColonyEstablished
                     ,0
                     )
                  else FCMgCSME_Event_Cancel(
                     csmeecImmediateDelay
                     ,Entity
                     ,Colony
                     ,OTPcnt
                     ,ceColonyEstablished
                     ,0
                     );
               end;
            end; //==END== case OTPevArr[OTPcnt].CSMEV_token of ==//
         end; //==END== if OTPevArr[OTPcnt].CSMEV_duration<=-2 ==//
         inc(OTPcnt);
      end; //==END== while OTPcnt<=OTPmax do ==//
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
   end; //==END== if OTPmax>1 ==//
end;

procedure FCMgCSME_UnSup_FindRepl(
   const USFRfac
         ,USFRcol: integer;
   const USFRevent: TFCEdgColonyEvents;
   const USFRevLvl: integer;
   const USFRevCancel: TFCEcsmeEvCan;
   const USFRtriggerIfEmpty: boolean
   );
{:Purpose: find if any Unrest, Social Disorder, Uprising event is set, and replace it by a chosen event w/ a specified method.
   Additions:
      -2012Apr30- *add: update the colony panel if needed.
      -2011May24- *mod: use a private variable instead of a tag for the colony index.
      -2010Sep14- *add: entities code.
      -2010Aug30- *fix: prevent a recover/etColEstab to trigger again etColEstab. etColEstab is used as default value for unrest/social disorder/uprising events.
      -2010Aug22- *add: complete routine behavior by including USFRtriggerIfEmpty case.
      -2010Aug20- *add: case of the new event to trigger is the same than the already set event.
                  *add: case of a recovering event is set w/ USFRevent<>CSMEV_token and a recovering event is already set.
      -2010Aug19- *add: cancellation by recover.
                  *add: a trigger for replace by a or not in the case of no Unrest/Social Disorder/Uprising is set.
                  *add: update the colony data display if this one is opened w/ the same colony.
}
var
   USFRcnt
   ,USFRdisplayedColony
   ,USFRmax: integer;

   USFRchge
   ,USFRsameEv: boolean;
begin
   USFRchge:=false;
   USFRsameEv:=false;
   USFRdisplayedColony:=FCFuiCDP_VarCurrentColony_Get;
   USFRmax:=length(FCentities[USFRfac].E_col[USFRcol].C_events)-1;
   if USFRmax>1
   then
   begin
      USFRcnt:=2;
      while USFRcnt<=USFRmax do
      begin
         if (
               (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceUnrest)
                  or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceUnrest_Recovering)
                  or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceSocialDisorder)
                  or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceSocialDisorder_Recovering)
                  or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceUprising)
                  or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceUprising_Recovering)
                  )
            and (USFRevent<>FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type)
         then
         begin
            if (USFRevCancel=csmeecRecover)
               and ((FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceUnrest_Recovering)
                  or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceSocialDisorder_Recovering)
                  or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceUprising_Recovering)
                  )
            then
            begin
               USFRchge:=false;
               USFRsameEv:=true;
               break;
            end
            else
            begin
               USFRchge:=true;
               break;
            end;
         end
         else if (
            (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceUnrest)
               or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceUnrest_Recovering)
               or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceSocialDisorder)
               or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceSocialDisorder_Recovering)
               or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceUprising)
               or (FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type=ceUprising_Recovering)
               )
            and (USFRevent=FCentities[USFRfac].E_col[USFRcol].C_events[USFRcnt].CCSME_type)
         then
         begin
            USFRsameEv:=true;
            break;
         end
         else inc(USFRcnt);
      end; //==END== while USFRcnt<=USFRmax ==//
      if USFRchge
      then
      begin
         case USFRevCancel of
            csmeecImmediate:
            begin
               FCMgCSME_Event_Cancel(
                  USFRevCancel
                  ,USFRfac
                  ,USFRcol
                  ,USFRcnt
                  ,ceColonyEstablished
                  ,0
                  );
               FCMgCSME_Event_Trigger(
                  USFRevent
                  ,USFRfac
                  ,USFRcol
                  ,USFRevLvl
                  ,false
                  );
            end;
            csmeecRecover: FCMgCSME_Event_Cancel(
               USFRevCancel
               ,USFRfac
               ,USFRcol
               ,USFRcnt
               ,ceColonyEstablished
               ,0
               );
            csmeecOverride:
            begin
               FCMgCSME_Event_Cancel(
                  USFRevCancel
                  ,USFRfac
                  ,USFRcol
                  ,USFRcnt
                  ,USFRevent
                  ,USFRevLvl
                  );
            end;
         end;
      end //==END== if USFRchge ==//
      else if (not USFRchge)
         and (not USFRsameEv)
         and (USFRevent<>ceColonyEstablished)
      then FCMgCSME_Event_Trigger(
         USFRevent
         ,USFRfac
         ,USFRcol
         ,USFRevLvl
         ,false
         );
      if USFRfac=0
      then FCMuiCDD_Colony_Update(
         cdlCSMevents
         ,USFRcol
         ,0
         ,0
         ,true
         ,false
         ,false
         );
   end //==END== if USFRmax>1 ==//
   else if (USFRmax<=1)
      and (USFRtriggerIfEmpty)
   then
   begin
      FCMgCSME_Event_Trigger(
         USFRevent
         ,USFRfac
         ,USFRcol
         ,USFRevLvl
         ,false
         );
      if USFRfac=0
      then FCMuiCDD_Colony_Update(
         cdlCSMevents
         ,USFRcol
         ,0
         ,0
         ,true
         ,false
         ,false
         );
   end;
   if USFRfac=0
   then FCMuiCDD_Colony_Update(
      cdlCSMevents
      ,USFRcol
      ,0
      ,0
      ,true
      ,false
      ,false
      );
end;

end.
