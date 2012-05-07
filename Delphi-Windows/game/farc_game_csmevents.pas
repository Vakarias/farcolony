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
///    <param name="ECevent">event #</param>
///    <param name="ECnewEvent">[only for override] new event type</param>
///    <param name="ECnewLvl">[only for override] event level if needed</param>
procedure FCMgCSME_Event_Cancel(
   const ECcancelTp: TFCEcsmeEvCan;
   const ECfacIdx
         ,ECcolIdx
         ,ECevent: integer;
   const ECnewEvent: TFCEdgEventTypes;
   const ECnewLvl: integer
   );

///<summary>
///   get the event token string
///</summary>
///    <param name="EGSevent">type of event</param>
function FCFgCSME_Event_GetStr(const EGSevent: TFCEdgEventTypes): string;

///<summary>
///   search if a specified event is present, return the event# (0 if not found)
///</summary>
///    <param name="ETevent">type of event</param>
///    <param name="ETfacIdx">faction index #</param>
///    <param name="ETcolIdx">colony index #</param>
function FCSgCSME_Event_Search(
   const ESevent: TFCEdgEventTypes;
   const ESfacIdx
         ,EScolIdx: integer
   ): integer;

///<summary>
///   trigger a specified event
///</summary>
///    <param name="ETevent">type of event</param>
///    <param name="ETfacIdx">faction index #</param>
///    <param name="ETcolIdx">colony index #</param>
///    <param name="ETlvl">[optional] level</param>
procedure FCMgCSME_Event_Trigger(
   const ETevent: TFCEdgEventTypes;
   const ETfacIdx
         ,ETcolIdx
         ,ETlvl: integer;
   const LoadIndex0: boolean
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
   ): TFCEdgEventTypes;

///<summary>
///   over time processing for events of a colony
///</summary>
///    <param name="OTPfac">faction index #</param>
///    <param name="OTPcol">colony index #</param>
procedure FCMgCSME_OT_Proc(
   const OTPfac
         ,OTPcol: integer
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
   const USFRevent: TFCEdgEventTypes;
   const USFRevLvl: integer;
   const USFRevCancel: TFCEcsmeEvCan;
   const USFRtriggerIfEmpty: boolean
   );

implementation

uses
   farc_common_func
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
         ,ECevent: integer;
   const ECnewEvent: TFCEdgEventTypes;
   const ECnewLvl: integer
   );
{:Purpose: cancel a specified event.
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
   //   ,ECheal
   //   ,EChealMean
      ,ModEcoIndOut
      ,ModInstruction
      ,MeanEcoIndOut
      ,Max
      ,FinalCSMvalue
      ,ModSecurity
      ,MeanSecurity
      ,ModTension
      ,MeanTension: integer;

      ECeventLst: array of TFCRdgColonCSMev;
begin
   ModCohesion:=0;
   ModEcoIndOut:=0;
   ModInstruction:=0;
   ModSecurity:=0;
   ModTension:=0;
   {.retrieve the modifiers}
   case FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].CSMEV_token of
      etColEstab:
      begin
         ModTension:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].CE_tensionMod;
         ModSecurity:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].CE_securityMod;
      end;

      etUnrest, etUnrestRec:
      begin
         ModEcoIndOut:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].UN_ecoindMod;
         ModTension:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].UN_tensionMod;
      end;

      etSocdis, etSocdisRec:
      begin
         ModEcoIndOut:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].SD_ecoindMod;
         ModTension:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].SD_tensionMod;
      end;

      etUprising, etUprisingRec:
      begin
         ModEcoIndOut:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].UP_ecoindMod;
         ModTension:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].UP_tensionMod;
      end;

      etHealthEduRel: ModInstruction:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].HER_educationMod;

      etGovDestab, etGovDestabRec: ModCohesion:=FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].GD_cohesionMod;
   end;
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
            case FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].CSMEV_token of
               etColEstab: FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].CE_securityMod:=FinalCSMvalue;
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
//         if ECheal<0
//         then FinalCSMvalue:=abs(ECheal)
//         else if ECheal>0
//         then FinalCSMvalue:=-ECheal;
//         FCMgCSM_ColonyData_Upd(
//            dHealth
//            ,ECfacIdx
//            ,ECcolIdx
//            ,FinalCSMvalue
//            ,0
//            ,gcsmptNone
//            ,false
//            );
         {.indicate that the event must be cleared}
         FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].CSMEV_duration:=-255;
         if ECcancelTp=csmeecImmediate
         then
         begin
            SetLength(ECeventLst, 0);
            Max:=length(FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList)-1;
            Count:=1;
            CountClone:=0;
            if Max>1
            then
            begin
               SetLength(ECeventLst, Max);
               while Count<=Max do
               begin
                  if FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[Count].CSMEV_duration<>-255
                  then
                  begin
                     inc(CountClone);
                     ECeventLst[CountClone]:=FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[Count];
                  end;
                  inc(Count);
               end;
               SetLength(FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList, 0);
               SetLength(FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList, CountClone+1);
               Count:=1;
               while Count<=CountClone do
               begin
                  FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[Count]:=ECeventLst[Count];
                  inc(Count);
               end;
            end
            else if Max=1
            then setlength(FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList, 1);
         end;
      end; //==END== case of: csmeecImmediate, csmeecImmediateDelay ==//

      csmeecRecover:
      begin
         case FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].CSMEV_token of
            etUnrest: FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].CSMEV_token:=etUnrestRec;
            etSocdis: FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].CSMEV_token:=etSocdisRec;
            etUprising: FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].CSMEV_token:=etUprisingRec;
            etGovDestab:
            begin
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].CSMEV_token:=etGovDestabRec;
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].CSMEV_duration:=-1;
            end;
         end;
      end;

      csmeecOverride:
      begin
         FCMgCSME_Event_Trigger(
            ECnewEvent
            ,ECfacIdx
            ,ECcolIdx
            ,ECnewLvl
            ,true
            );
         FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].CSMEV_token:=ECnewEvent;
         FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].CSMEV_lvl:=ECnewLvl;
         case FCentities[ ECfacIdx ].E_col[ ECcolIdx].COL_evList[ ECevent ].CSMEV_token of
            etColEstab:
            begin
               MeanTension:=round( ( ModTension+FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[0].CE_tensionMod )*0.5 );
               MeanSecurity:=round( ( ModSecurity+FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[0].CE_securityMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].CE_tensionMod:=MeanTension;
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].CE_securityMod:=MeanSecurity;
            end;

            etUnrest, etUnrestRec:
            begin
               MeanEcoIndOut:=round( ( ModEcoIndOut+FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[0].UN_ecoindMod )*0.5 );
               MeanTension:=round( ( ModTension+FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[0].UN_tensionMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].UN_ecoindMod:=MeanEcoIndOut;
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].UN_tensionMod:=MeanTension;
            end;

            etSocdis, etSocdisRec:
            begin
               MeanEcoIndOut:=round( ( ModEcoIndOut+FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[0].SD_ecoindMod )*0.5 );
               MeanTension:=round( ( ModTension+FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[0].SD_tensionMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].SD_ecoindMod:=MeanEcoIndOut;
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].SD_tensionMod:=MeanTension;
            end;

            etUprising, etUprisingRec:
            begin
               MeanEcoIndOut:=round( ( ModEcoIndOut+FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[0].UP_ecoindMod )*0.5 );
               MeanTension:=round( ( ModTension+FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[0].UP_tensionMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].UP_ecoindMod:=MeanEcoIndOut;
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].UP_tensionMod:=MeanTension;
            end;

            etHealthEduRel:
            begin
               MeanInstruction:=round( ( ModInstruction+FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[0].HER_educationMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].HER_educationMod:=MeanInstruction;
            end;

            etGovDestab, etGovDestabRec:
            begin
               MeanCohesion:=round( ( ModCohesion+FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[0].GD_cohesionMod )*0.5 );
               FCentities[ECfacIdx].E_col[ECcolIdx].COL_evList[ECevent].GD_cohesionMod:=MeanCohesion;
            end;
         end;
      end; //==END== case: csmeecOverride ==//
   end; //==END== case ECcancelTp of ==//
end;

function FCFgCSME_Event_GetStr(const EGSevent: TFCEdgEventTypes): string;
{:Purpose: get the event token string.
   Additions:
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
      etColEstab: result:='csmevColEst';
      etUnrest: result:='csmevUnrest';
      etUnrestRec: result:='csmevUnrestRec';
      etSocdis: result:='csmevSocDis';
      etSocdisRec: result:='csmevSocDisRec';
      etUprising: result:='csmevUprising';
      etUprisingRec: result:='csmevUprisingRec';
      etColDissident: result:='csmevColDissident';
      etHealthEduRel: result:='csmevHealthEduRel';
      etGovDestab: result:='csmevGovDestab';
      etGovDestabRec: result:= 'csmevGovDestabRec';
   end;
end;

function FCSgCSME_Event_Search(
   const ESevent: TFCEdgEventTypes;
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
   ESmax:=length(FCentities[ESfacIdx].E_col[EScolIdx].COL_evList)-1;
   while EScnt<=ESmax do
   begin
      if FCentities[ESfacIdx].E_col[EScolIdx].COL_evList[EScnt].CSMEV_token=ESevent
      then
      begin
         result:=EScnt;
         break;
      end;
      inc(EScnt);
   end;
end;

procedure FCMgCSME_Event_Trigger(
   const ETevent: TFCEdgEventTypes;
   const ETfacIdx
         ,ETcolIdx
         ,ETlvl: integer;
   const LoadIndex0: boolean
   );
{:Purpose: trigger a specified event.
    Additions:
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
   ETevIdx
   ,ETevMod
   ,ETintEv
   ,ETloyal
   ,ETloyalCalc
   ,ETrnd
   ,ETuprRebAmnt
   ,ETuprRebels: integer;

   ETdur
   ,ETuprDurCoef: extended;

   ETenv: TFCRgcEnvironment;
begin
   if LoadIndex0
   then
   begin
      if length(FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList)=0
      then setlength(FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList, 1);
      ETevIdx:=0;
      FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[0].CSMEV_isRes:=false;
      FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[0].CSMEV_duration:=0;
      FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[0].CSMEV_lvl:=0;
      FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[0].CSMEV_token:=etColEstab;
      FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[0].CE_tensionMod:=0;
      FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[0].CE_securityMod:=0;
   end
   else if not LoadIndex0
   then
   begin
      ETuprRebAmnt:=0;
      setlength(FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList, length(FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList)+1);
      ETevIdx:=length(FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList)-1;
   end;
   case ETevent of
      etColEstab:
      begin
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_token:=etColEstab;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_isRes:=true;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=5;
         ETenv:=FCFgC_ColEnv_GetTp(ETfacIdx, ETcolIdx);
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_lvl:=-1;
         case ETenv.ENV_envType of
            envfreeLiving:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_lvl:=0;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CE_tensionMod:=10;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CE_securityMod:=-15;
            end;

            restrict:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_lvl:=1;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CE_tensionMod:=15;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CE_securityMod:=-20;
            end;

            space:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_lvl:=2;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CE_tensionMod:=25;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CE_securityMod:=-20;
            end;
         end;
         if not LoadIndex0
         then
         begin
            FCMgCSM_ColonyData_Upd(
               dTension
               ,ETfacIdx
               ,ETcolIdx
               ,FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CE_tensionMod
               ,0
               ,gcsmptNone
               ,false
               );
            FCMgCSM_ColonyData_Upd(
               dSecurity
               ,ETfacIdx
               ,ETcolIdx
               ,0
               ,0
               ,gcsmptNone
               ,true
               );
         end;
      end; //==END== case: csmeeColEstablished ==//

      etUnrest:
      begin
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_token:=etUnrest;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_isRes:=true;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=-1;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_lvl:=ETlvl;
         case ETlvl of
            1:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_ecoindMod:=-15;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_tensionMod:=15;
            end;

            2:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_ecoindMod:=-13;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_tensionMod:=11;
            end;

            3:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_ecoindMod:=-13;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_tensionMod:=9;
            end;

            4:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_ecoindMod:=-10;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_tensionMod:=7;
            end;

            5:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_ecoindMod:=-8;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_tensionMod:=5;
            end;

            6:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_ecoindMod:=-5;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_tensionMod:=4;
            end;

            7:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_ecoindMod:=-5;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_tensionMod:=3;
            end;

            8..9:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_ecoindMod:=-3;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_tensionMod:=3;
            end;
         end; //==END== case ETlvl of ==//
         if not LoadIndex0
         then
         begin
            FCMgCSM_ColonyData_Upd(
               dTension
               ,ETfacIdx
               ,ETcolIdx
               ,FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UN_tensionMod
               ,0
               ,gcsmptNone
               ,false
               );
         end;
      end; //==END== case: etUnrest ==//

      etSocdis:
      begin
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_token:=etSocdis;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_isRes:=true;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=-1;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_lvl:=ETlvl;
         case ETlvl of
            1:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_ecoindMod:=-32;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_tensionMod:=22;
            end;

            2:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_ecoindMod:=-29;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_tensionMod:=17;
            end;

            3:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_ecoindMod:=-25;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_tensionMod:=17;
            end;

            4:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_ecoindMod:=-20;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_tensionMod:=13;
            end;

            5:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_ecoindMod:=-19;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_tensionMod:=13;
            end;

            6:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_ecoindMod:=-13;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_tensionMod:=10;
            end;

            7:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_ecoindMod:=-10;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_tensionMod:=9;
            end;

            8..9:
            begin
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_ecoindMod:=-8;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_tensionMod:=8;
            end;
         end; //==END== case ETlvl of ==//
         if not LoadIndex0
         then
         begin
            FCMgCSM_ColonyData_Upd(
               dTension
               ,ETfacIdx
               ,ETcolIdx
               ,FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].SD_tensionMod
               ,0
               ,gcsmptNone
               ,false
               );
         end;
      end; //==END== case: etSocdis ==//

      etUprising:
      begin
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_token:=etUprising;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_isRes:=true;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=0;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_lvl:=ETlvl;
         case ETlvl of
            1:
            begin
               ETuprRebAmnt:=80;
               if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold>0
               then FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=-1
               else if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold=0
               then ETuprDurCoef:=5;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UP_ecoindMod:=-65;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UP_tensionMod:=43;
            end;

            2:
            begin
               ETuprRebAmnt:=50;
               if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold>0
               then FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=-1
               else if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold=0
               then ETuprDurCoef:=4;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UP_ecoindMod:=-52;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UP_tensionMod:=34;
            end;

            3:
            begin
               ETuprRebAmnt:=30;
               if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold>0
               then FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=-1
               else if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold=0
               then ETuprDurCoef:=2;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UP_ecoindMod:=-39;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UP_tensionMod:=26;
            end;

            4:
            begin
               ETuprRebAmnt:=20;
               if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold>0
               then FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=-1
               else if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold=0
               then ETuprDurCoef:=1.5;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UP_ecoindMod:=-23;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UP_tensionMod:=19;
            end;

            5:
            begin
               ETuprRebAmnt:=10;
               if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold>0
               then FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=-1
               else if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold=0
               then ETuprDurCoef:=1;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UP_ecoindMod:=-15;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UP_tensionMod:=15;
            end;
         end; //==END== case ETlvl of ==//
         if FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration=-1
         then ETuprRebels:=round(
            ( FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_total-FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold )*( 1+( ETuprRebAmnt/100 ) )
            )
         else if FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration=0
         then
         begin
            ETuprRebels:=round(FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_total*(1+(ETuprRebAmnt/100)));
            ETdur:=sqrt(ETuprRebels)*ETuprDurCoef;
            FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=round(ETdur);
         end;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpRebels:=ETuprRebels;
         if not LoadIndex0
         then
         begin
            FCMgCSM_ColonyData_Upd(
               dTension
               ,ETfacIdx
               ,ETcolIdx
               ,FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].UP_tensionMod
               ,0
               ,gcsmptNone
               ,false
               );
         end;
      end; //==END== case: etUprising ==//

      etColDissident:
      begin
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_token:=etColDissident;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_isRes:=true;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_lvl:=ETlvl;
         ETrnd:=FCFcFunc_Rand_Int(100);
         ETintEv:=0;
         ETuprRebAmnt:=0;
         ETloyal:=0;
         ETloyalCalc:=0;
         case ETlvl of
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
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_lvl:=ETintEv;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=-1;
         case ETintEv of
            {.no resistance}
            0:
            begin
               if Assigned(FCcps)
               then FCMgCore_EndofGame_Fail
               else if not Assigned(FCcps)
               then
               begin
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
               if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold=0
               then
               begin
                  ETuprRebels:=round(FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_total*(1+(ETuprRebAmnt/100)));
                  ETloyalCalc:=round((FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_total-ETuprRebels)*(1+(ETloyal/100)));
               end
               else if FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold>0
               then
               begin
                  ETuprRebels:=round(
                     (FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_total-FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMSsold)
                     *(1+(ETuprRebAmnt/100))
                     );
                  ETloyalCalc:=0;
               end;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpRebels:=ETuprRebels;
               FCentities[ETfacIdx].E_col[ETcolIdx].COL_population.POP_tpMilitia:=ETloyalCalc;
            end;
         end; //==END== case ETintEv of ==//
      end; //==END== case: etColDissident ==//

      etHealthEduRel:
      begin
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_token:=etHealthEduRel;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_isRes:=true;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=-1;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_lvl:=0;
         ETevMod:=FCFgCSME_HealEdu_GetMod(ETfacIdx, ETcolIdx);
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].HER_educationMod:=ETevMod;
         FCMgCSM_ColonyData_Upd(
            dInstruction
            ,ETfacIdx
            ,ETcolIdx
            ,ETevMod
            ,0
            ,gcsmptNone
            ,false
            );
      end;

      etGovDestab:
      begin
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_token:=etGovDestab;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_isRes:=true;
         FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].CSMEV_duration:=-1;
         case ETlvl of
            1..3: FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].GD_cohesionMod:=-8;
            4..6: FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].GD_cohesionMod:=-13;
            7..9: FCentities[ETfacIdx].E_col[ETcolIdx].COL_evList[ETevIdx].GD_cohesionMod:=-20;
         end;
      end;
   end; //==END== case ETevent of ==//
   if ETfacIdx=0
   then FCMuiCDD_Colony_Update(
      cdlCSMevents
      ,ETcolIdx
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
   HEGMhealLvl:=StrToInt(
      FCFgCSM_Health_GetIdxStr(
         true
         ,HEGMfacIdx
         ,HEGMcolIdx
         )
      );
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
   MSmax:=length(FCentities[MSfac].E_col[MScolIDx].COL_evList)-1;
   if MSmax>0
   then
   begin
      MScnt:=1;
      while MScnt<=MSmax do
      begin
         case MStype of
            mtCohesion:
            begin
               case FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].CSMEV_token of
                  etGovDestab, etGovDestabRec: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].GD_cohesionMod;
               end;
            end;

            mtTension:
            begin
               case FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].CSMEV_token of
                  etColEstab: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].CE_tensionMod;

                  etUnrest, etUnrestRec: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].UN_tensionMod;

                  etSocdis, etSocdisRec: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].SD_tensionMod;

                  etUprising, etUprisingRec: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].UP_tensionMod;
               end;
            end;

            mtSecurity:
            begin
               case FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].CSMEV_token of
                  etColEstab: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].CE_securityMod;
               end;
            end;

            mtInstruction:
            begin
               case FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].CSMEV_token of
                  etHealthEduRel: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].HER_educationMod;
               end;
            end;

            mtEcoIndOutput:
            begin
               case FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].CSMEV_token of
                  etUnrest, etUnrestRec: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].UN_ecoindMod;

                  etSocdis, etSocdisRec: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].SD_ecoindMod;

                  etUprising, etUprisingRec: MSdmp:=MSdmp+FCentities[MSfac].E_col[MScolIDx].COL_evList[MScnt].UP_ecoindMod;
               end;
            end;

//            mtHealth: ;
         end;
         inc(MScnt);
      end;
   end;
   Result:=MSdmp;
end;

function FCFgCSME_UnSup_Find(
   const USFfac
         ,USFcol: integer
   ): TFCEdgEventTypes;
{:Purpose: find if any Unrest, Social Disorder, Uprising or Dissident Colony event is set, and return the type.
    Additions:
      -2010Sep14- *add: entities code.
}
var
   USFcnt
   ,USFmax: integer;
begin
   Result:=etColEstab;
   USFmax:=length(FCentities[USFfac].E_col[USFcol].COL_evList)-1;
   if USFmax>1
   then
   begin
      USFcnt:=2;
      while USFcnt<=USFmax do
      begin
         if (
               (FCentities[USFfac].E_col[USFcol].COL_evList[USFcnt].CSMEV_token=etUnrest)
                  or (FCentities[USFfac].E_col[USFcol].COL_evList[USFcnt].CSMEV_token=etUnrestRec)
                  or (FCentities[USFfac].E_col[USFcol].COL_evList[USFcnt].CSMEV_token=etSocdis)
                  or (FCentities[USFfac].E_col[USFcol].COL_evList[USFcnt].CSMEV_token=etSocdisRec)
                  or (FCentities[USFfac].E_col[USFcol].COL_evList[USFcnt].CSMEV_token=etUprising)
                  or (FCentities[USFfac].E_col[USFcol].COL_evList[USFcnt].CSMEV_token=etUprisingRec)
                  or (FCentities[USFfac].E_col[USFcol].COL_evList[USFcnt].CSMEV_token=etColDissident)
                  )
         then
         begin
            Result:=FCentities[USFfac].E_col[USFcol].COL_evList[USFcnt].CSMEV_token;
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
}
   var
      AbsoluteCoefficient
      ,ModCohesion
      ,ModEcoIndOutput
      ,ModTension
      ,NewCohesion
      ,NewEcoIndOutput
      ,NewTension: integer;
begin
   AbsoluteCoefficient:=0;
   ModCohesion:=0;
   ModEcoIndOutput:=0;
   ModTension:=0;
   NewCohesion:=0;
   NewEcoIndOutput:=0;
   NewTension:=0;
   {.we retrieve the specific data}
   case FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].CSMEV_token of
      etUnrestRec:
      begin
         ModEcoIndOutput:=FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].UN_ecoindMod;
         ModTension:=FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].UN_tensionMod;
      end;

      etSocdisRec:
      begin
         ModEcoIndOutput:=FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].SD_ecoindMod;
         ModTension:=FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].SD_tensionMod;
      end;

      etUprisingRec:
      begin
         ModEcoIndOutput:=FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].UP_ecoindMod;
         ModTension:=FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].UP_tensionMod;
      end;

      etGovDestabRec: ModCohesion:=FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].GD_cohesionMod;
   end;
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
   {.determine if the recovering is finished + whatever the case, update the CSM}
   case FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].CSMEV_token of
      etUnrestRec:
      begin
         if ( NewEcoIndOutput=0 )
            and ( NewTension=0 )
         then FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].CSMEV_duration:=-2;
         FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].UN_ecoindMod:=NewEcoIndOutput;
         FCMgCSM_ColonyData_Upd(
            dEcoIndusOut
            ,Entity
            ,Colony
            ,NewEcoIndOutput
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].UN_tensionMod:=NewTension;
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

      etSocdisRec:
      begin
         if ( NewEcoIndOutput=0 )
            and ( NewTension=0 )
         then FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].CSMEV_duration:=-2;
         FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].SD_ecoindMod:=NewEcoIndOutput;
         FCMgCSM_ColonyData_Upd(
            dEcoIndusOut
            ,Entity
            ,Colony
            ,NewEcoIndOutput
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].SD_tensionMod:=NewTension;
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

      etUprisingRec:
      begin
         if ( NewEcoIndOutput=0 )
            and ( NewTension=0 )
         then FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].CSMEV_duration:=-2;
         FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].UP_ecoindMod:=NewEcoIndOutput;
         FCMgCSM_ColonyData_Upd(
            dEcoIndusOut
            ,Entity
            ,Colony
            ,NewEcoIndOutput
            ,0
            ,gcsmptNone
            ,false
            );
         FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].UP_tensionMod:=NewTension;
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

      etGovDestabRec:
      begin
         if NewCohesion=0
         then FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].CSMEV_duration:=-2;
         FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].GD_cohesionMod:=NewCohesion;
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
   end; //==END== case FCentities[ Entity ].E_col[ Colony ].COL_evList[ Event ].CSMEV_token of ==//
end;

procedure FCMgCSME_OT_Proc(
   const OTPfac
         ,OTPcol: integer
   );
{:Purpose: over time processing for events of a colony.
   Additions:
      -2012May06- *mod: apply modification according to changes in the CSM event data structure.
                  *mod: cleanup data assignation by using FCMgCSM_ColonyData_Upd.
                  *add: complete the recovering part for the concerned events.
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

   OTPevArr: array of TFCRdgColonCSMev;
begin
   OTPmax:=length(FCentities[OTPfac].E_col[OTPcol].COL_evList)-1;
   if OTPmax>1
   then
   begin
      OTPcnt:=1;
      while OTPcnt<=OTPmax do
      begin
         case FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_token of
            etColEstab:
            begin
               OTPmodTens:=FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CE_tensionMod;
               OTPmodSec:=FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CE_securityMod;
               case FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_lvl of
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
               FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CE_tensionMod:=OTPmodTens+OTPmod1;
               FCMgCSM_ColonyData_Upd(
                  dTension
                  ,OTPfac
                  ,OTPcol
                  ,OTPmod1
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CE_securityMod:=OTPmodSec+OTPmod2;
               FCMgCSM_ColonyData_Upd(
                  dSecurity
                  ,OTPfac
                  ,OTPcol
                  ,0
                  ,0
                  ,gcsmptNone
                  ,true
                  );
               dec(FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration);
               if FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration=0
               then FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration:=-2;
            end; //==END== case: etColEstab ==//

            etUnrest:
            begin
               OTPmodEiO:=FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].UN_ecoindMod;
               OTPmodTens:=FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].UN_tensionMod;
               case FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_lvl of
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
               FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].UN_ecoindMod:=OTPmodEiO+OTPmod1;
               FCMgCSM_ColonyData_Upd(
                  dEcoIndusOut
                  ,OTPfac
                  ,OTPcol
                  ,OTPmod1
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].UN_tensionMod:=OTPmodTens+OTPmod2;
               FCMgCSM_ColonyData_Upd(
                  dTension
                  ,OTPfac
                  ,OTPcol
                  ,OTPmod2
                  ,0
                  ,gcsmptNone
                  ,false
                  );


            end; //==END== case: etUnrest ==//

            etUnrestRec: FCMgCSME_Recovering_Process(
               OTPfac
               ,OTPcol
               ,OTPcnt
               );

            etSocdis:
            begin
               OTPmodEiO:=FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].SD_ecoindMod;
               OTPmodTens:=FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].SD_tensionMod;
               case FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_lvl of
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
               FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].SD_ecoindMod:=OTPmodEiO+OTPmod1;
               FCMgCSM_ColonyData_Upd(
                  dEcoIndusOut
                  ,OTPfac
                  ,OTPcol
                  ,OTPmod1
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].SD_tensionMod:=OTPmodTens+OTPmod2;
               FCMgCSM_ColonyData_Upd(
                  dTension
                  ,OTPfac
                  ,OTPcol
                  ,OTPmod2
                  ,0
                  ,gcsmptNone
                  ,false
                  );
            end; //==END== case: etSocdis ==//

            etSocdisRec: FCMgCSME_Recovering_Process(
               OTPfac
               ,OTPcol
               ,OTPcnt
               );

            etUprising:
            begin
               OTPmodEiO:=FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].UP_ecoindMod;
               OTPmodTens:=FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].UP_tensionMod;
               case FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_lvl of
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
               FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].UP_ecoindMod:=OTPmodEiO+OTPmod1;
               FCMgCSM_ColonyData_Upd(
                  dEcoIndusOut
                  ,OTPfac
                  ,OTPcol
                  ,OTPmod1
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].UP_tensionMod:=OTPmodTens+OTPmod2;
               FCMgCSM_ColonyData_Upd(
                  dTension
                  ,OTPfac
                  ,OTPcol
                  ,OTPmod2
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               {.fighting system}
               OTPsold:=FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMSsold;
               OTPreb:=FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpRebels;
               if OTPsold>0
               then
               begin
                  {.in case of soldiers were been added after that the uprising event was set}
                  if FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration<>-1
                  then FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration:=-1;
                  OTPsec:=StrToInt(
                     FCFgCSM_Security_GetIdxStr(
                        OTPfac
                        ,OTPcol
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
                  OTPpopTtl:=FCentities[OTPfac].E_col[OTPcol].COL_population.POP_total-OTPsold;
                  OTPpCnt:=1;
                  while OTPcurr>0 do
                  begin
                     case OTPpcnt of
                        {.colonists}
                        1:
                        begin
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpColon>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpColon*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpASoff>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpASoff*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpASmiSp>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpASmiSp*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpBSbio>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpBSbio*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpBSdoc>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpBSdoc*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpIStech>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpIStech*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpISeng>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpISeng*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMScomm>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMScomm*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpPSphys>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpPSphys*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpPSastr>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpPSastr*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpESecol>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpESecol*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpESecof>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpESecof*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpAmedian>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpAmedian*OTPcasPop/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                  FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpRebels:=OTPreb-OTPcasPop;
                  FCMgCSM_ColonyData_Upd(
                     dPopulation
                     ,OTPfac
                     ,OTPcol
                     ,-OTPcasSold
                     ,0
                     ,gcsmptMSsold
                     ,true
                     );
                  FCMgCSM_ColonyData_Upd(
                     dCohesion
                     ,OTPfac
                     ,OTPcol
                     ,-1
                     ,0
                     ,gcsmptNone
                     ,false
                     );
                  {.event resolving rules}
                  if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpRebels=0
                  then FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration:=-3
                  else if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMSsold=0
                  then FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration:=-4;
               end //==END== if OTPsold>0 ==//
               else if (OTPsold=0)
                  and (FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration<>-1)
               then
               begin
                  dec(FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration);
                  {.event resolving rules}
                  if FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration=0
                  then FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration:=-2
               end;
            end; //==END== case: etUprising ==//

            etUprisingRec: FCMgCSME_Recovering_Process(
               OTPfac
               ,OTPcol
               ,OTPcnt
               );

            etColDissident:
            begin
               case FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_lvl of
                  {.unrest}
                  1: OTPrebEqup:=1;
                  {.social disorder}
                  2: OTPrebEqup:=2;
                  {.uprising}
                  3: OTPrebEqup:=3;
               end;
               {.fighting system}
               OTPsold:=FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMSsold;
               OTPreb:=FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpRebels;
               OTPmili:=FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMilitia;
               if (OTPsold>0)
                  or (OTPmili>0)
               then
               begin
                  OTPsec:=StrToInt(
                     FCFgCSM_Security_GetIdxStr(
                        OTPfac
                        ,OTPcol
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
                  OTPpopTtl:=FCentities[OTPfac].E_col[OTPcol].COL_population.POP_total-OTPsold;
                  OTPpCnt:=1;
                  while OTPcurr>0 do
                  begin
                     case OTPpcnt of
                        {.colonists}
                        1:
                        begin
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpColon>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpColon*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpASoff>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpASoff*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpASmiSp>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpASmiSp*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpBSbio>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpBSbio*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpBSdoc>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpBSdoc*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpIStech>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpIStech*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpISeng>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpISeng*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMScomm>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMScomm*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpPSphys>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpPSphys*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpPSastr>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpPSastr*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpESecol>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpESecol*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpESecof>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpESecof*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                           if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpAmedian>0
                           then
                           begin
                              OTPrem:=round(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpAmedian*OTPcivil/OTPpopTtl);
                              if OTPrem>=OTPcurr
                              then
                              begin
                                 FCMgCSM_ColonyData_Upd(
                                    dPopulation
                                    ,OTPfac
                                    ,OTPcol
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
                                    ,OTPfac
                                    ,OTPcol
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
                  FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpRebels:=OTPreb-OTPcasPop;
                  if OTPmili>0
                  then FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMilitia:=OTPmili-OTPcasSold
                  else if OTPsold>0
                  then FCMgCSM_ColonyData_Upd(
                     dPopulation
                     ,OTPfac
                     ,OTPcol
                     ,-OTPcasSold
                     ,0
                     ,gcsmptMSsold
                     ,true
                     );
                  FCMgCSM_ColonyData_Upd(
                     dCohesion
                     ,OTPfac
                     ,OTPcol
                     ,-1
                     ,0
                     ,gcsmptNone
                     ,false
                     );
                  {.event resolving rules}
                  if FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpRebels=0
                  then FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration:=-3
                  else if (FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMSsold=0)
                     and (FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMilitia=0)
                  then FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration:=-4;
               end //==END== if OTPsold>0 or OTPmili>0 ==//
               else if (OTPsold=0)
                  and (OTPmili=0)
               then FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration:=-2;
            end; //==END== case: etColDissident: ==//

            etGovDestab:
            begin
               OTPmodCoh:=FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].GD_cohesionMod;
               OTPmod1:=0;
               case FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_lvl of
                  2..3: OTPmod1:=-2;
                  5..6: OTPmod1:=-3;
                  8..9: OTPmod1:=-5;
               end;
               FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].GD_cohesionMod:=OTPmodCoh+OTPmod1;
               FCMgCSM_ColonyData_Upd(
                  dCohesion
                  ,OTPfac
                  ,OTPcol
                  ,OTPmod1
                  ,0
                  ,gcsmptNone
                  ,false
                  );
               if FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration>0
               then
               begin
                  dec(FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration);
                  if FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration=0
                  then FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration:=-2;
                                    {:DEV NOTES: enable the new HQ, if duration or reorganization time is equal to 0, and put the event in recovery.}
//                  if FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration=0
//                  then HQ get + HQ enable + Rec;
//                  if FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration=0
//                  then
               end;
            end;

            etGovDestabRec: FCMgCSME_Recovering_Process(
               OTPfac
               ,OTPcol
               ,OTPcnt
               );
         end; //==END== case FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_token of ==//
         inc(OTPcnt);
      end; //==END== while OTPcnt<=OTPmax do ==//
      {.post-process sub-routine for event resolving}
      setlength(OTPevArr, length(FCentities[OTPfac].E_col[OTPcol].COL_evList));
      {.load the event list data structure in a temp data structure. It's required to have this extra loop because in the next one the origin event list
         will be altered. Mainly by event cancellations call}
      OTPcnt:=1;
      while OTPcnt<=OTPmax do
      begin
         OTPevArr[OTPcnt]:=FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt];
         inc(OTPcnt);
      end;
      OTPcnt:=1;
      while OTPcnt<=OTPmax do
      begin
         if OTPevArr[OTPcnt].CSMEV_duration<=-2 then
         begin
            case OTPevArr[OTPcnt].CSMEV_token of
               etColEstab, etUnrestRec, etSocdisRec:
               begin
                  if OTPcnt=OTPmax
                  then FCMgCSME_Event_Cancel(
                     csmeecImmediate
                     ,OTPfac
                     ,OTPcol
                     ,OTPcnt
                     ,etColEstab
                     ,0
                     )
                  else FCMgCSME_Event_Cancel(
                     csmeecImmediateDelay
                     ,OTPfac
                     ,OTPcol
                     ,OTPcnt
                     ,etColEstab
                     ,0
                     );
               end;
               etUprising:
               begin
                  if (OTPevArr[OTPcnt].CSMEV_duration=-2)
                     or (OTPevArr[OTPcnt].CSMEV_duration=-3)
                  then
                  begin
                     FCMgCSME_Event_Cancel(
                        csmeecOverride
                        ,OTPfac
                        ,OTPcol
                        ,OTPcnt
                        ,etSocdis
                        ,OTPevArr[OTPcnt].CSMEV_lvl
                        );
                     FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpRebels:=0;
                  end
                  else if OTPevArr[OTPcnt].CSMEV_duration=-4
                  then FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_duration:=round(sqrt(FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpRebels));
               end;
               etUprisingRec:
               begin
                  if OTPcnt=OTPmax
                  then FCMgCSME_Event_Cancel(
                     csmeecImmediate
                     ,OTPfac
                     ,OTPcol
                     ,OTPcnt
                     ,etColEstab
                     ,0
                     )
                  else FCMgCSME_Event_Cancel(
                     csmeecImmediateDelay
                     ,OTPfac
                     ,OTPcol
                     ,OTPcnt
                     ,etColEstab
                     ,0
                     );
               end;
               etColDissident:
               begin
                  if OTPevArr[OTPcnt].CSMEV_duration=-2
                  then
                  begin
                     if OTPcnt=OTPmax
                     then FCMgCSME_Event_Cancel(
                        csmeecImmediate
                        ,OTPfac
                        ,OTPcol
                        ,OTPcnt
                        ,etColEstab
                        ,0
                        )
                     else FCMgCSME_Event_Cancel(
                        csmeecImmediateDelay
                        ,OTPfac
                        ,OTPcol
                        ,OTPcnt
                        ,etColEstab
                        ,0
                        );
                  end
                  else if OTPevArr[OTPcnt].CSMEV_duration=-3
                  then
                  begin
                     if Assigned(FCcps)
                     then FCMgCore_EndofGame_Fail
                     else if not Assigned(FCcps)
                     then
                     begin
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
                  else if OTPevArr[OTPcnt].CSMEV_duration=-4
                  then
                  begin
                     OTPmod1:=0;
                     case FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_lvl of
                        1: OTPmod1:=1;
                        2: OTPmod1:=5;
                        3: OTPmod1:=10;
                        4: OTPmod1:=15;
                     end;
                     FCMgCSME_Event_Cancel(
                        csmeecOverride
                        ,OTPfac
                        ,OTPcol
                        ,OTPcnt
                        ,etUprising
                        ,FCentities[OTPfac].E_col[OTPcol].COL_evList[OTPcnt].CSMEV_lvl*2
                        );
                     FCMgCSM_ColonyData_Upd(
                        dCohesion
                        ,OTPfac
                        ,OTPcol
                        ,OTPmod1
                        ,0
                        ,gcsmptNone
                        ,false
                        );
                     FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpRebels:=0;
                     FCentities[OTPfac].E_col[OTPcol].COL_population.POP_tpMilitia:=0;
                  end;
               end; //==END== case: etColDissident ==//
               etGovDestab:
               begin
                  FCMgCSME_Event_Cancel(
                     csmeecRecover
                     ,OTPfac
                     ,OTPcol
                     ,OTPcnt
                     ,etColEstab
                     ,0
                     );
               end;
               etGovDestabRec:
               begin
                  if OTPcnt=OTPmax
                  then FCMgCSME_Event_Cancel(
                     csmeecImmediate
                     ,OTPfac
                     ,OTPcol
                     ,OTPcnt
                     ,etColEstab
                     ,0
                     )
                  else FCMgCSME_Event_Cancel(
                     csmeecImmediateDelay
                     ,OTPfac
                     ,OTPcol
                     ,OTPcnt
                     ,etColEstab
                     ,0
                     );
               end;
            end; //==END== case OTPevArr[OTPcnt].CSMEV_token of ==//
         end; //==END== if OTPevArr[OTPcnt].CSMEV_duration<=-2 ==//
         inc(OTPcnt);
      end; //==END== while OTPcnt<=OTPmax do ==//
      if OTPfac=0
      then FCMuiCDD_Colony_Update(
         cdlCSMevents
         ,OTPcol
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
   const USFRevent: TFCEdgEventTypes;
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
   USFRmax:=length(FCentities[USFRfac].E_col[USFRcol].COL_evList)-1;
   if USFRmax>1
   then
   begin
      USFRcnt:=2;
      while USFRcnt<=USFRmax do
      begin
         if (
               (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etUnrest)
                  or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etUnrestRec)
                  or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etSocdis)
                  or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etSocdisRec)
                  or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etUprising)
                  or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etUprisingRec)
                  )
            and (USFRevent<>FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token)
         then
         begin
            if (USFRevCancel=csmeecRecover)
               and ((FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etUnrestRec)
                  or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etSocdisRec)
                  or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etUprisingRec)
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
            (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etUnrest)
               or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etUnrestRec)
               or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etSocdis)
               or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etSocdisRec)
               or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etUprising)
               or (FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token=etUprisingRec)
               )
            and (USFRevent=FCentities[USFRfac].E_col[USFRcol].COL_evList[USFRcnt].CSMEV_token)
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
                  ,etColEstab
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
               ,etColEstab
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
         and (USFRevent<>etColEstab)
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
