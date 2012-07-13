{=====(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved================

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: colony simulation model (CSM) - core unit

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

unit farc_game_csm;

interface

uses
   SysUtils

   ,DecimalRounding_JH1;

type TFCEgcsmData=(
   dPopulation
   ,dBirthRate
   ,dCohesion
   ,dColonyLvl
   ,dDeathRate
   ,dHealth
   ,dInstruction
   ,dMeanAge
   ,dPCAP
   ,dQOL
   ,dSecurity
   ,dSPL
   ,dTension
   ,dEcoIndusOut
   );

type TFCEgcsmPopTp=(
   gcsmptNone
   ,gcsmptColon
   ,gcsmptASoff
   ,gcsmptASmiSp
   ,gcsmptBSbio
   ,gcsmptBSdoc
   ,gcsmptIStech
   ,gcsmptISeng
   ,gcsmptMSsold
   ,gcsmptMScomm
   ,gcsmptPSphys
   ,gcsmptPSastr
   ,gcsmptESecol
   ,gcsmptESecof
   ,gcsmptAmedian
   ,gcsmptRebels
   );

type TFCEgcsmSPLtp=(
   indexval
   ,QOLmod
   ,indexstr
   );

///<summary>
///   retrieve the age coefficient based on the colony's mean age and on the health index
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <returns>the age coefficient</returns>
function FCFgCSM_AgeCoefficient_Retrieve( const Entity, Colony: integer ): extended;

///<summary>
///   get the cohesion index string
///</summary>
function FCFgCSM_Cohesion_GetIdxStr(const CGISfac, CGIScol: integer): string;

///<summary>
///   get the health index of a colony
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <returns>health index value</returns>
function FCFgCSM_Health_GetIdx( const Entity, Colony: integer ): integer;

///<summary>
///   get the health index string or index level string
///</summary>
function FCFgCSM_Health_GetIdxStr(
   const HGISvalue: boolean;
   const HGISfac
         ,HGIScol: integer
   ): string;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   initialize choosen colony's data
///</summary>
///    <param name="CDIfac">faction index #</param>
///    <param name="CDIcolIdx">colony index #</param>
procedure FCMgCSM_ColonyData_Init(const CDIfac, CDIcolIdx: Integer);

///<summary>
///   update the choosen CSM data and update all the depencies if required
///</summary>
///   <param name="CDUdata">type of data
   ///<summary>
   ///   dPopulation: cduvalue= population xfert, cduvalue1= 0, poptype= never none, fullupd= true=trigger dependencies
      ///<summary>
      ///!!!!!-for population transfer inside the same population use FCMgCSM_Pop_Xfert
      ///</summary>
   ///</summary>
   ///<summary>
   ///   dBirthRate: cduvalue= 0, cduvalue1= 0, poptype= always none, fullupd= always false
   ///</summary>
   ///<summary>
   ///   dCohesion: cduvalue= cohesion modifier, cduvalue1= 0, poptype= always none, fullupd= always false
   ///</summary>
   ///<summary>
   ///   dColonyLvl: cduvalue= 0, cduvalue1= 0, poptype= always none, fullupd= always true
   ///</summary>
   ///<summary>
   ///   dDeathRate: cduvalue= 0, cduvalue1= 0, poptype= always none, fullupd= always false
   ///</summary>
   ///<summary>
   ///   dHealth: cduvalue= HEAL modifier (if fullupd=false), cduvalue1= 0, poptype= always none, fullupd= true=full/false=mod
   ///<summary>
      ///!!!!!-use false ONLY when it's a CSM event which trigger the calculation
      ///</summary>
   ///</summary>
   ///<summary>
   ///   dInstruction: cduvalue= instruction modifier, cduvalue1= 0, poptype= always none, fullupd= always false
   ///</summary>
   ///<summary>
   ///   dMeanAge: cduvalue= population from sender, cduvalue1= sender mean age, poptype= always none, fullupd= always true
   ///</summary>
   ///<summary>
   ///   dPCAP: cduvalue= PCAP modifier (if fullupd=false), cduvalue1= 0, poptype= always none, fullupd= true=full/false=mod
   ///</summary>
   ///<summary>
   ///   dQOL: method setup: cduvalue= 0, cduvalue1= 0, poptype= always none, fullupd= always true
   ///</summary>
   ///<summary>
   ///   dSecurity: method setup: cduvalue= 0, cduvalue1= 0, poptype= always none, fullupd= always true
   ///</summary>
   ///<summary>
   ///   dSPL: method setup: cduvalue= 0, cduvalue1= 0, poptype= always none, fullupd= always true
   ///</summary>
   ///<summary>
   ///   dTension: method setup: cduvalue= tension modifier, cduvalue1= 0, poptype= always none, fullupd= always false
   ///</summary>
   ///<summary>
   ///   dEcoIndusOut: method setup: cduvalue= EIOUT modifier, cduvalue1= 0, poptype= always none, fullupd= always false
   ///</summary>
///</param>
///   <param name="CDUfac">faction index #</param>
///   <param name="CDUcol">colony index #</param>
///   <param name="CDUvalue">[optional] cumulative value to apply in + or -</param>
///   <param name="CDUpopType">required only for population change: gcsmdPopulation, set a none for the rest</param>
///   <param name="CDUfullUpd">true= do not use the cumulative value but recalculate completely the data
///                            [required for gcsmdSec - gcsmdQOL]</param>
procedure FCMgCSM_ColonyData_Upd(
   const CDUdata: TFCEgcsmData;
   const CDUfac
         ,CDUcol: integer;
   const CDUvalue
         ,CDUvalue1: extended;
   const CDUpopType: TFCEgcsmPopTp;
   const CDUfullUpd: boolean
   );

///<summary>
///   update the CSM-Energy data of a colony
///</summary>
///   <param name=Entity">entity index</param>
///   <param name="Colony">colony index</param>
///   <param name="isFullCalculation">true= process full calculation, the next parameters must be at 0</param>
///   <param name="ConsumptionMod">for [CSMEUisFullCalculation=false] update in + or - the energy consumed in the colony</param>
///   <param name="GenerationMod">for [CSMEUisFullCalculation=false] update in + or - the energy generated in the colony</param>
///   <param name="StorageCurrentMod">for [CSMEUisFullCalculation=false] update in + or - the current energy stored in the colony</param>
///   <param name="StorageMaxMod">for [CSMEUisFullCalculation=false] update in + or - the maximum energy that can be stored in the colony</param>
procedure FCMgCSM_Energy_Update(
   const Entity
         ,Colony: integer;
   const isFullCalculation: boolean;
   const ConsumptionMod
         ,GenerationMod
         ,StorageCurrentMod
         ,StorageMaxMod: extended
   );

///<summary>
///   get the education index string
///</summary>
function FCFgCSM_Education_GetIdxStr(const EGISfac, EGIScol: integer): string;

///<summary>
///   CSM phase w/ colony's data tests
///</summary>
///   <param name="PPfacIdx">faction index #</param>
///   <param name="PPcolIdx">colony index #</param>
procedure FCMgCSM_Phase_Proc(
   const PPfac
         ,PPcol: integer
   );

///<summary>
///   update the CSM phase list, and initialize it if needed.
///</summary>
///   <param name="PLUfac">faction index #</param>
///   <param name="PLUcol">colony index #</param>
procedure FCMgCSM_PhaseList_Upd(
   const PLUfac
         ,PLUcol: integer
   );

///<summary>
///   transfert an amount of population of one type to an another category.
///</summary>
///   <param name="PXfac">faction index #</param>
///   <param name="PXcol">colony index #</param>
///   <param name="PXfrom">category of population to take from</param>
///   <param name="PXto">category of population to deposit</param>
///   <param name="PXamount">number of people to transfert</param>
procedure FCMgCSM_Pop_Xfert(
   const PXfac
         ,PXcol: integer;
   const PXfrom,
         PXto: TFCEgcsmPopTp;
   const PXamount: integer
   );

///<summary>
///   get the security index string
///</summary>
///   <param name="SGISfac">faction index #</param>
///   <param name="SGIScol">colony index #</param>
///   <param name="SGISraw">true: return only the level index string</param>
function FCFgCSM_Security_GetIdxStr(
   const SGISfac
         ,SGIScol: integer;
   const SGISraw: boolean
   ): string;

///<summary>
///   get either the spl index value.pb level or the resulting QoL modifier
///</summary>
///   <param name="SPLGIMgetMod">true: get QOL modifier, false: give level.pblevel</param>
///   <param name="SPLGIMfac">faction #</param>
///   <param name="SPLGIMcol">colony index #</param>
function FCFgCSM_SPL_GetIdxMod(
   const SPLGIMgetMod: TFCEgcsmSPLtp;
   const SPLGIMfac
         , SPLGIMcol: integer
   ): string;

///<summary>
///   get the tension index string
///</summary>
function FCFgCSM_Tension_GetIdx(
   const TGISfac
         ,TGIScol: integer;
   const TGISraw: boolean
   ): string;

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_html
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_game_csmevents
   ,farc_game_pgs
   ,farc_game_spmdata
   ,farc_ui_coredatadisplay
   ,farc_univ_func
   ,farc_win_debug;

//===================================================END OF INIT============================

function FCFgCSM_AgeCoefficient_Retrieve( const Entity, Colony: integer ): extended;
{:Purpose: retrieve the age coefficient based on the colony's mean age and on the health index.
    Additions:
}
   var
      HealthIndex
      ,MeanAge: integer;
begin
   Result:=0;
   HealthIndex:=FCFgCSM_Health_GetIdx( Entity, Colony );
   MeanAge:=trunc( FCEntities[ Entity ].E_col[ Colony ].COL_population.POP_meanA );
   case HealthIndex of
      1:
      begin
         case MeanAge of
            0..50: Result:=1.2;

            51..59: Result:=1.3;

            60..84: Result:=1.5;

            85..109: Result:=1.6;

            110..999: Result:=2;
         end;
      end;

      2:
      begin
         case MeanAge of
            0..50: Result:=1.1;

            51..59: Result:=1.2;

            60..84: Result:=1.4;

            85..109: Result:=1.5;

            110..999: Result:=1.9;
         end;
      end;

      3:
      begin
         case MeanAge of
            0..50: Result:=1;

            51..59: Result:=1.2;

            60..84: Result:=1.3;

            85..109: Result:=1.5;

            110..999: Result:=1.8;
         end;
      end;

      4:
      begin
         case MeanAge of
            0..50: Result:=1;

            51..59: Result:=1.1;

            60..84: Result:=1.3;

            85..109: Result:=1.4;

            110..999: Result:=1.8;
         end;
      end;

      5:
      begin
         case MeanAge of
            0..50: Result:=0.9;

            51..59: Result:=1.1;

            60..84: Result:=1.2;

            85..109: Result:=1.4;

            110..999: Result:=1.7;
         end;
      end;

      6:
      begin
         case MeanAge of
            0..50: Result:=0.9;

            51..59: Result:=1;

            60..84: Result:=1.2;

            85..109: Result:=1.3;

            110..999: Result:=1.7;
         end;
      end;

      7:
      begin
         case MeanAge of
            0..50: Result:=0.8;

            51..59: Result:=1;

            60..84: Result:=1.1;

            85..109: Result:=1.3;

            110..999: Result:=1.6;
         end;
      end;
   end; //==END== case HealthIndex of ==//
end;

function FCFgCSM_Cohesion_GetIdxStr(const CGISfac, CGIScol: integer): string;
{:Purpose: get the cohesion index string.
    Additions:
      -2010Sep14- *add: faction # parameter.
                  *add: entities code.
      -2010Jun19- *add: cohesion index color.
}
var
   CGISclr
   ,CGISidx: string;
begin
   if FCentities[CGISfac].E_col[CGIScol].COL_cohes<20
   then
   begin
      CGISidx:='1';
      CGISclr:=FCCFcolRed;
   end
   else if (FCentities[CGISfac].E_col[CGIScol].COL_cohes>=20)
      and (FCentities[CGISfac].E_col[CGIScol].COL_cohes<35)
   then
   begin
      CGISidx:='2';
      CGISclr:=FCCFcolRed;
   end
   else if (FCentities[CGISfac].E_col[CGIScol].COL_cohes>=35)
      and (FCentities[CGISfac].E_col[CGIScol].COL_cohes<50)
   then
   begin
      CGISidx:='3';
      CGISclr:=FCCFcolOrge;
   end
   else if (FCentities[CGISfac].E_col[CGIScol].COL_cohes>=50)
      and (FCentities[CGISfac].E_col[CGIScol].COL_cohes<65)
   then
   begin
      CGISidx:='4';
      CGISclr:=FCCFcolYel;
   end
   else if (FCentities[CGISfac].E_col[CGIScol].COL_cohes>=65)
      and (FCentities[CGISfac].E_col[CGIScol].COL_cohes<80)
   then
   begin
      CGISidx:='5';
      CGISclr:=FCCFcolBlueL;
   end
   else if (FCentities[CGISfac].E_col[CGIScol].COL_cohes>=80)
      and (FCentities[CGISfac].E_col[CGIScol].COL_cohes<95)
   then
   begin
       CGISidx:='6';
       CGISclr:=FCCFcolGreen;
   end
   else if FCentities[CGISfac].E_col[CGIScol].COL_cohes>=95
   then
   begin
      CGISidx:='7';
      CGISclr:=FCCFcolGreen;
   end;
   Result:=CGISclr+FCFdTFiles_UIStr_Get(uistrUI, 'colDcohesI'+CGISidx)+FCCFcolEND;
end;

function FCFgCSM_Health_GetIdx( const Entity, Colony: integer ): integer;
{:Purpose: get the health index of a colony.
    Additions:
}
   var
      HealthIndex: integer;
begin
   Result:=0;
   HealthIndex:=0;
   if FCentities[Entity].E_col[Colony].COL_csmHEheal<=0
   then HealthIndex:=1
   else if (FCentities[Entity].E_col[Colony].COL_csmHEheal>=1)
      and (FCentities[Entity].E_col[Colony].COL_csmHEheal<51)
   then HealthIndex:=2
   else if (FCentities[Entity].E_col[Colony].COL_csmHEheal>=51)
      and (FCentities[Entity].E_col[Colony].COL_csmHEheal<91)
   then HealthIndex:=3
   else if (FCentities[Entity].E_col[Colony].COL_csmHEheal>=91)
      and (FCentities[Entity].E_col[Colony].COL_csmHEheal<111)
   then HealthIndex:=4
   else if (FCentities[Entity].E_col[Colony].COL_csmHEheal>=111)
      and (FCentities[Entity].E_col[Colony].COL_csmHEheal<126)
   then HealthIndex:=5
   else if (FCentities[Entity].E_col[Colony].COL_csmHEheal>=126)
      and (FCentities[Entity].E_col[Colony].COL_csmHEheal<141)
   then HealthIndex:=6
   else if FCentities[Entity].E_col[Colony].COL_csmHEheal>=141
   then HealthIndex:=7;
   Result:=HealthIndex;
end;

function FCFgCSM_Health_GetIdxStr(
   const HGISvalue: boolean;
   const HGISfac
         ,HGIScol: integer
   ): string;
{:Purpose: get the health index string or index value string.
   Additions:
      -2012May13- *code: level determination is tranfered to FCFgCSM_Health_GetIdx.
      -2012May12- *mod: take in account if the COL_csmHEheal<0.
      -2012Apr29- *add/mod: apply the last changes in the doc, by modifying the ranges and add a new level.
      -2010Sep14- *add: a faction parameter.
                  *add: entities code.
}
var
   HealthIndex: integer;

   CGISclr
   ,CGISidx: string;
begin
   Result:='';
   CGISclr:='';
   HealthIndex:=FCFgCSM_Health_GetIdx( HGISfac, HGIScol );
   CGISidx:=IntToStr( HealthIndex );
   if not HGISvalue then
   begin
      case HealthIndex of
         1: CGISclr:=FCCFcolRed;

         2..3: CGISclr:=FCCFcolOrge;

         4: CGISclr:=FCCFcolYel;

         5: CGISclr:=FCCFcolBlueL;

         6..7: CGISclr:=FCCFcolGreen;
      end;
      Result:=CGISclr+FCFdTFiles_UIStr_Get(uistrUI, 'colDhealI'+CGISidx)+FCCFcolEND;
   end
   else Result:=CGISidx;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgCSM_ColonyData_Init(const CDIfac, CDIcolIdx: Integer);
{:Purpose: initialize choosen colony's data.
    Additions:
      -2012Apr15- *add: complete reserve data initialization.
      -2011Jul19- *add: initialize CSM Energy module data.
      -2011Jul07- *add: initialize the production matrix.
      -2011May06- *mod: apply changes for storage data.
      -2011May01- *mod: initialize the storage with the same size than the DBProducts.
      -2011Apr26- *add: assigned population.
                  *add: construction workforce.
      -2011Mar19- *add: CSM Housing - Quality of Life.
                  *add: events list + settlements.
                  *add: CAB queue + storage + reserves.
      -2011Feb01- *add: economic & industrial output initialization.
      -2010Oct24- *add: HQ presence initialization.
      -2010Sep25- *add: SPM modifiers in calculations, where it's needed.
      -2010Sep14- *add: entities code.
      -2010Aug19- *add: rebels + militia population init.
      -2010Aug03- *add: initialize to zero/nil the other data (allow a full cleanup in case of an existing index).
      -2010Aug02- *add: education init.
      -2010May27- *mod: no csm modifier is added to tension since there's no csm event triggered yet.
      -2010May17- *add: cohesion init when the selected faction have more than one colony.
                  *add: default colony level.
                  *add: transfert generated data into choosen colony data structure.
      -2010Mar07- *add: init calculations for tension.
}
var
   CDIcol: TFCRdgColony;
   CDIcolTtl: integer;
begin
   {.retrieve colony data}
   CDIcolTtl:=length(FCentities[CDIfac].E_col)-1;
   CDIcol:=FCentities[CDIfac].E_col[CDIcolIdx];
   {.init cohesion data}
   if CDIcolTtl=1
   then CDIcol.COL_cohes:=85+FCentities[CDIfac].E_spmMcohes
   else if CDIcolTtl>1
   then CDIcol.COL_cohes:=FCFgSPMD_GlobalData_Get(gspmdStability, 0);
   {.init tension data}
   CDIcol.COL_tens:=10+FCentities[CDIfac].E_spmMtens;
   {.init education data}
   if CDIcolTtl=1
   then CDIcol.COL_edu:=80+FCentities[CDIfac].E_spmMedu
   else if CDIcolTtl>1
   then CDIcol.COL_edu:=FCFgSPMD_GlobalData_Get(gspmdInstruction, 0);
   {.init colony level, it's 1 by default, the value is updated when population is added and/or region control has changed}
   CDIcol.COL_level:=cl1Outpost;
   {.transfert colony's data and initialize the non calculated data}
   FCentities[CDIfac].E_col[CDIcolIdx].COL_level:=CDIcol.COL_level;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_hqPres:=dgNoHQ;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_cohes:=CDIcol.COL_cohes;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_secu:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_tens:=CDIcol.COL_tens;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_edu:=CDIcol.COL_edu;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_csmHOpcap:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_csmHOspl:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_csmHOqol:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_csmHEheal:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_csmENcons:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_csmENgen:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_csmENstorCurr:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_csmENstorMax:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_eiOut:=100;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_total:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_meanA:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_dRate:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_dStack:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_bRate:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_bStack:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpColon:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpColonAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpASoff:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpASoffAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpASmiSp:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpASmiSpAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpBSbio:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpBSbioAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpBSdoc:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpBSdocAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpIStech:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpIStechAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpISeng:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpISengAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpMSsold:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpMSsoldAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpMScomm:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpMScommAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpPSphys:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpPSphysAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpPSastr:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpPSastrAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpESecol:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpESecolAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpESecof:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpESecofAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpAmedian:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpAmedianAssigned:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpRebels:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_tpMilitia:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_wcpTotal:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_population.POP_wcpAssignedPeople:=0;
   setlength(FCentities[CDIfac].E_col[CDIcolIdx].COL_evList, 1);
   setlength(FCentities[CDIfac].E_col[CDIcolIdx].COL_settlements, 1);
   setlength(FCentities[CDIfac].E_col[CDIcolIdx].COL_cabQueue, 1);
   setlength(FCentities[CDIfac].E_col[CDIcolIdx].COL_productionMatrix, 1);
   FCentities[CDIfac].E_col[CDIcolIdx].COL_storCapacitySolidCurr:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_storCapacitySolidMax:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_storCapacityLiquidCurr:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_storCapacityLiquidMax:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_storCapacityGasCurr:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_storCapacityGasMax:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_storCapacityBioCurr:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_storCapacityBioMax:=0;
   setlength(FCentities[CDIfac].E_col[CDIcolIdx].COL_storageList, 1);
   FCentities[CDIfac].E_col[CDIcolIdx].COL_reserveOxygen:=0;
   FCentities[CDIfac].E_col[CDIcolIdx].COL_reserveFood:=0;
   SetLength( FCentities[CDIfac].E_col[CDIcolIdx].COL_reserveFoodList, 1 );
   FCentities[CDIfac].E_col[CDIcolIdx].COL_reserveWater:=0;
end;

procedure FCMgCSM_ColonyData_Upd(
   const CDUdata: TFCEgcsmData;
   const CDUfac
         ,CDUcol: integer;
   const CDUvalue
         ,CDUvalue1: extended;
   const CDUpopType: TFCEgcsmPopTp;
   const CDUfullUpd: boolean
   );
{:Purpose: update the choosen CSM data and update all the depencies if required.
    Additions:
      -2012May13- *fix: dHealth - for CDUfullUpd, the wrong data was updated.
      -2012May06- *mod: apply modification according to changes in the CSM event data structure.
      -2012May02- *add: dEcoIndusOut.
      -2011Jul05- *fix: for PCAP and QOL, also include the inConversion infrastructures, since their capabilities are already taken in account.
      -2011Jul04- *fix: prevent a division by zero for the Quality of Life calculations, especially when at the start of a game there's no operational infrastructures.
      -2011Jun26- *add: for PCAP and QOL the calculation include now only the operational infrastructures.
      -2011Mar07- *add: converted housing in the calculations, where it's required.
      -2011Feb12- *add: settlements specific code.
      -2010Sep26- *add: SPM calculations for security + health.
      -2010Sep14- *add: entities code.
      -2010Aug16- *add: a trigger gcsmdPopXfert for population transfer inside a same population.
      -2010Aug10- *fix: trigger birth rate only if total population>0.
      -2010Aug09- *fix: trigger death rate only if total population>0.
      -2010Aug07- *add: birth rate link.
                  *add: update health dependencies.
      -2010Aug05- *add: death rate link.
                  *add: update mean age and health dependencies.
      -2010Aug04- *add: mean age calculation is transfered to the new PGS unit.
      -2010Aug02- *add: health + education calculations.
                  *add: update QoL and tension dependencies.
      -2010Aug01- *add: cohesion and security calculations.
                  *add: security dependency for population calculations.
      -2010Jun20- *add: QOL calculations completion.
                  *add: put QOL dependency update in SPL section.
      -2010Jun02- *add: SPL calculations.
                  *add: update population dependencies.
      -2010Jun01- *add: a second value.
                  *add: update population dependencies.
                  *add: mean age calculations.
      -2010May31- *add: a switch for population change.
                  *add: population change + colony level calculations.
      -2010May27- *add: PCAP basic changes.
                  *add: include full update calculations option.
                  *add: CPAP full calculation.
}
var
   CDUcnt
   ,CDUdatI
   ,CDUdatI1
   ,CDUdatI2
   ,CDUdatI3
   ,CDUsettleCnt
   ,CDUsettleMax
   ,CDUmax
   ,CDUqolMod: integer;

   CDUdatF
   ,CDUdatF1
   ,CDUmeanAge: extended;

   CDUqolModstr: string;
begin
   case CDUdata of
      {.population addition}
      dPopulation:
      begin
         CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total;
         CDUdatI1:=round(CDUvalue);
         FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total:=CDUdatI+CDUdatI1;
         case CDUpopType of
            gcsmptColon:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpColon;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpColon:=CDUdatI+CDUdatI1;
            end;
            gcsmptASoff:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpASoff;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpASoff:=CDUdatI+CDUdatI1;
            end;
            gcsmptASmiSp:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpASmiSp;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpASmiSp:=CDUdatI+CDUdatI1;
            end;
            gcsmptBSbio:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpBSbio;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpBSbio:=CDUdatI+CDUdatI1;
            end;
            gcsmptBSdoc:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpBSdoc;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpBSdoc:=CDUdatI+CDUdatI1;
            end;
            gcsmptIStech:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpIStech;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpIStech:=CDUdatI+CDUdatI1;
            end;
            gcsmptISeng:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpISeng;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpISeng:=CDUdatI+CDUdatI1;
            end;
            gcsmptMSsold:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpMSsold;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpMSsold:=CDUdatI+CDUdatI1;
            end;
            gcsmptMScomm:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpMScomm;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpMScomm:=CDUdatI+CDUdatI1;
            end;
            gcsmptPSphys:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpPSphys;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpPSphys:=CDUdatI+CDUdatI1;
            end;
            gcsmptPSastr:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpPSastr;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpPSastr:=CDUdatI+CDUdatI1;
            end;
            gcsmptESecol:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpESecol;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpESecol:=CDUdatI+CDUdatI1;
            end;
            gcsmptESecof:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpESecof;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpESecof:=CDUdatI+CDUdatI1;
            end;
            gcsmptAmedian:
            begin
               CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpAmedian;
               FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpAmedian:=CDUdatI+CDUdatI1;
            end;
         end; //==END== case CDUpopType of ==//
         {.csm events trigger}
         {.update dependencies}
         if CDUfullUpd
         then
         begin
            FCMgCSM_ColonyData_Upd(
               dColonyLvl
               ,CDUfac
               ,CDUcol
               ,0
               ,0
               ,gcsmptNone
               ,true
               );
            FCMgCSM_ColonyData_Upd(
               dMeanAge
               ,CDUfac
               ,CDUcol
               ,CDUdatI1
               ,CDUvalue1
               ,gcsmptNone
               ,true
               );
            FCMgCSM_ColonyData_Upd(
               dSPL
               ,CDUfac
               ,CDUcol
               ,0
               ,0
               ,gcsmptNone
               ,true
               );
            FCMgCSM_ColonyData_Upd(
               dSecurity
               ,CDUfac
               ,CDUcol
               ,0
               ,0
               ,gcsmptNone
               ,true
               );
         end;
      end; //==END== case: gcsmdPopulation ==//
      dBirthRate:
      begin
         if FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total>0
         then FCMgPGS_BR_Calc(CDUfac, CDUcol);
         {.update dependencies}
      end;
      dCohesion:
      begin
         CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_cohes;
         FCentities[CDUfac].E_col[CDUcol].COL_cohes:=CDUdatI+round(CDUvalue);
         {.update dependencies}
      end;
      dColonyLvl:
      begin
         {:DEV NOTES: don't forget to also put the region control test.}
         if (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total>=1)
            and (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total<11)
         then FCentities[CDUfac].E_col[CDUcol].COL_level:=cl1Outpost
         else if (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total>=11)
            and (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total<101)
         then FCentities[CDUfac].E_col[CDUcol].COL_level:=cl2Base
         else if (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total>=101)
            and (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total<1001)
         then FCentities[CDUfac].E_col[CDUcol].COL_level:=cl3Comm
         else if (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total>=1001)
            and (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total<10001)
         then FCentities[CDUfac].E_col[CDUcol].COL_level:=cl4Settl
         else if (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total>=10001)
            and (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total<100001)
         then FCentities[CDUfac].E_col[CDUcol].COL_level:=cl5MajCol
         else if (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total>=100001)
            and (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total<1000001)
         then FCentities[CDUfac].E_col[CDUcol].COL_level:=cl6LocSt
         else if (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total>=1000001)
         then FCentities[CDUfac].E_col[CDUcol].COL_level:=cl7RegSt;
         {.csm events trigger}
         {.update dependencies}
      end;
      dDeathRate:
      begin
         if FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total>0
         then FCMgPGS_DR_Calc(CDUfac, CDUcol);
         {.update dependencies}
      end;
      dHealth:
      begin
         if not CDUfullUpd
         then
         begin
            CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_csmHEheal;
            FCentities[CDUfac].E_col[CDUcol].COL_csmHEheal:=CDUdatI+round(CDUvalue);
         end
         else if CDUfullUpd
         then
         begin
            CDUdatI:=0;
            CDUdatI1:=0;
            CDUdatI2:=0;
            CDUdatI3:=0;
            {.sum of HEAL CSM events modifiers}
            CDUcnt:=FCFgCSME_Mod_Sum(
               mtHealth
               ,CDUfac
               ,CDUcol
               );
            CDUdatI1:=CDUdatI1+CDUcnt;
            {.tension modifier}
            CDUdatI:=StrToInt(
               FCFgCSM_Tension_GetIdx(
                  CDUfac
                  ,CDUcol
                  ,true
                  )
               );
            case CDUdatI of
               1: CDUdatI2:=20;
               2: CDUdatI2:=5;
               3: CDUdatI2:=-10;
               4: CDUdatI2:=-25;
               5: CDUdatI2:=-40;
            end; //==END== case CDUdatI of ==//
            CDUdatI3:=(FCentities[CDUfac].E_col[CDUcol].COL_csmHOqol*10)+FCentities[CDUfac].E_spmMhealth+CDUdatI2+CDUdatI1;
            FCentities[CDUfac].E_col[CDUcol].COL_csmHEheal:=CDUdatI3;
         end;
         {.update dependencies}
         CDUdatI:=0;
         CDUdatI1:=0;
         CDUdatI2:=0;
         CDUdatI:=FCFgCSME_Search_ByType(
            etHealthEduRel
            ,CDUfac
            ,CDUcol
            );
         if FCentities[CDUfac].E_col[CDUcol].COL_evList[CDUdatI].HER_educationMod>0
         then CDUdatI1:=-FCentities[CDUfac].E_col[CDUcol].COL_evList[CDUdatI].HER_educationMod
         else if FCentities[CDUfac].E_col[CDUcol].COL_evList[CDUdatI].HER_educationMod<0
         then CDUdatI1:=abs(FCentities[CDUfac].E_col[CDUcol].COL_evList[CDUdatI].HER_educationMod);
         FCentities[CDUfac].E_col[CDUcol].COL_evList[CDUdatI].HER_educationMod:=CDUdatI1;
         FCMgCSM_ColonyData_Upd(
            dInstruction
            ,CDUfac
            ,CDUcol
            ,CDUdatI1
            ,0
            ,gcsmptNone
            ,false
            );
         CDUdatI2:=FCFgCSME_HealEdu_GetMod(CDUfac, CDUcol);
         FCentities[CDUfac].E_col[CDUcol].COL_evList[CDUdatI].HER_educationMod:=CDUdatI2;
         FCMgCSM_ColonyData_Upd(
            dInstruction
            ,CDUfac
            ,CDUcol
            ,CDUdatI2
            ,0
            ,gcsmptNone
            ,false
            );
         FCMgCSM_ColonyData_Upd(
            dDeathRate
            ,CDUfac
            ,CDUcol
            ,0
            ,0
            ,gcsmptNone
            ,false
            );
         FCMgCSM_ColonyData_Upd(
            dBirthRate
            ,CDUfac
            ,CDUcol
            ,0
            ,0
            ,gcsmptNone
            ,false
            );
      end;
      dInstruction:
      begin
         CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_edu;
         FCentities[CDUfac].E_col[CDUcol].COL_edu:=CDUdatI+round(CDUvalue);
         {.update dependencies}
      end;
      {.population mean age}
      dMeanAge:
      begin
         FCMgPGS_MeanAge_UpdXfert(
            CDUfac
            ,CDUcol
            ,round(CDUvalue)
            ,round(CDUvalue1)
            );
         {.update dependencies}
         FCMgCSM_ColonyData_Upd(
            dDeathRate
            ,CDUfac
            ,CDUcol
            ,0
            ,0
            ,gcsmptNone
            ,false
            );
      end;
      {.population capacity}
      dPCAP:
      begin
         if not CDUfullUpd
         then
         begin
            CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_csmHOpcap;
            FCentities[CDUfac].E_col[CDUcol].COL_csmHOpcap:=CDUdatI+round(CDUvalue);
         end
         else if CDUfullUpd
         then
         begin
            CDUdatI:=0;
            CDUsettleMax:=length(FCentities[CDUfac].E_col[CDUcol].COL_settlements)-1;
            if CDUsettleMax>0
            then
            begin
               CDUsettleCnt:=1;
               while CDUsettleCnt<=CDUsettleMax do
               begin
                  CDUcnt:=1;
                  CDUmax:=length(FCentities[CDUfac].E_col[CDUcol].COL_settlements[CDUsettleCnt].CS_infra)-1;
                  if CDUmax>0
                  then
                  begin
                     while CDUcnt<=CDUmax do
                     begin
                        if (FCentities[CDUfac].E_col[CDUcol].COL_settlements[CDUsettleCnt].CS_infra[CDUcnt].CI_function=fHousing)
                           and (
                              (FCentities[CDUfac].E_col[CDUcol].COL_settlements[CDUsettleCnt].CS_infra[CDUcnt].CI_status=istInConversion)
                                 or (FCentities[CDUfac].E_col[CDUcol].COL_settlements[CDUsettleCnt].CS_infra[CDUcnt].CI_status=istOperational)
                              )
                        then CDUdatI:=CDUdatI+FCentities[CDUfac].E_col[CDUcol].COL_settlements[CDUsettleCnt].CS_infra[CDUcnt].CI_fhousPCAP;
                        inc(CDUcnt);
                     end;
                  end;
                  inc(CDUsettleCnt);
               end;
            end;
            FCentities[CDUfac].E_col[CDUcol].COL_csmHOpcap:=CDUdatI;
         end; //==END== else if CDUfullUpd ==//
         {.csm events trigger}
         {.update dependencies}
         FCMgCSM_ColonyData_Upd(
            dSPL
            ,CDUfac
            ,CDUcol
            ,0
            ,0
            ,gcsmptNone
            ,true
            );
      end;
      {.quality of life}
      dQOL:
      begin
         CDUdatI:=0;
         CDUdatI1:=0;
         CDUdatF:=0;
         CDUsettleMax:=length(FCentities[CDUfac].E_col[CDUcol].COL_settlements)-1;
         if CDUsettleMax>0
         then
         begin
            CDUsettleCnt:=1;
            while CDUsettleCnt<=CDUsettleMax do
            begin
               CDUcnt:=1;
               CDUmax:=length(FCentities[CDUfac].E_col[CDUcol].COL_settlements[CDUsettleCnt].CS_infra)-1;
               if CDUmax>0
               then
               begin
                  while CDUcnt<=CDUmax do
                  begin
                     if (FCentities[CDUfac].E_col[CDUcol].COL_settlements[CDUsettleCnt].CS_infra[CDUcnt].CI_function=fHousing)
                        and (
                           (FCentities[CDUfac].E_col[CDUcol].COL_settlements[CDUsettleCnt].CS_infra[CDUcnt].CI_status=istInConversion)
                              or (FCentities[CDUfac].E_col[CDUcol].COL_settlements[CDUsettleCnt].CS_infra[CDUcnt].CI_status=istOperational)
                           )
                     then
                     begin
                        CDUdatI:=CDUdatI+FCentities[CDUfac].E_col[CDUcol].COL_settlements[CDUsettleCnt].CS_infra[CDUcnt].CI_fhousQOL;
                        inc(CDUdatI1);
                     end;
                     inc(CDUcnt);
                  end;
               end;
               inc(CDUsettleCnt);
            end;
         end;
         CDUqolModstr:=FCFgCSM_SPL_GetIdxMod(
            QOLmod
            ,CDUfac
            ,CDUcol
            );
         CDUqolMod:=StrToInt(CDUqolModstr);
         if CDUdatI1=0
         then FCentities[CDUfac].E_col[CDUcol].COL_csmHOqol:=CDUqolMod
         else if CDUdatI1>0
         then FCentities[CDUfac].E_col[CDUcol].COL_csmHOqol:=round(CDUdatI/CDUdatI1)+CDUqolMod;
         if FCentities[CDUfac].E_col[CDUcol].COL_csmHOqol<1
         then FCentities[CDUfac].E_col[CDUcol].COL_csmHOqol:=1;
         {.update dependencies}
         FCMgCSM_ColonyData_Upd(
            dHealth
            ,CDUfac
            ,CDUcol
            ,0
            ,0
            ,gcsmptNone
            ,true
            );
      end;
      dSecurity:
      begin
         CDUdatI:=0;
         CDUdatI1:=0;
         CDUdatI2:=0;
         CDUdatF:=0;
         CDUdatF1:=0;
         {.current population number/soldier force}
         if FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpMSsold=0
         then FCentities[CDUfac].E_col[CDUcol].COL_secu:=FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total
         else if FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpMSsold>0
         then
         begin
            CDUdatF:=
               (FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total-FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpMSsold)
               /FCentities[CDUfac].E_col[CDUcol].COL_population.POP_tpMSsold;
            CDUdatI:=round(CDUdatF);
            CDUdatI1:=FCFgCSME_Mod_Sum(
               mtSecurity
               ,CDUfac
               ,CDUcol
               );
            CDUdatI2:=FCentities[CDUfac].E_spmMsec;
            CDUdatF:=1+((CDUdatI1+CDUdatI2)/100);
            if CDUdatF<0
            then CDUdatF:=0;
            CDUdatF1:=CDUdatI*CDUdatF;
            FCentities[CDUfac].E_col[CDUcol].COL_secu:=round(CDUdatF1);
         end;
         {.update dependencies}
      end;
      dSPL:
      begin
         CDUdatF:=FCentities[CDUfac].E_col[CDUcol].COL_csmHOpcap/FCentities[CDUfac].E_col[CDUcol].COL_population.POP_total;
         FCentities[CDUfac].E_col[CDUcol].COL_csmHOspl:=DecimalRound(CDUdatF, 2, 0.001);
         {.csm events trigger}
         {.update dependencies}
         FCMgCSM_ColonyData_Upd(
            dQOL
            ,CDUfac
            ,CDUcol
            ,0
            ,0
            ,gcsmptNone
            ,true
            );
      end;

      {.tension}
      dTension:
      begin
         CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_tens;
         FCentities[CDUfac].E_col[CDUcol].COL_tens:=CDUdatI+round(CDUvalue);
         {.update dependencies}
         FCMgCSM_ColonyData_Upd(
            dHealth
            ,CDUfac
            ,CDUcol
            ,0
            ,0
            ,gcsmptNone
            ,true
            );
      end;

      {.economic - industrial output}
      dEcoIndusOut:
      begin
         CDUdatI:=FCentities[CDUfac].E_col[CDUcol].COL_eiOut;
         FCentities[CDUfac].E_col[CDUcol].COL_eiOut:=CDUdatI+round(CDUvalue);
      end;
   end; //==END== case CDUdata of ==//
end;

procedure FCMgCSM_Energy_Update(
   const Entity
         ,Colony: integer;
   const isFullCalculation: boolean;
   const ConsumptionMod
         ,GenerationMod
         ,StorageCurrentMod
         ,StorageMaxMod: extended
   );
{:Purpose: update the CSM-Energy data of a colony.
    Additions:
      -2012Jan16- *fix: if not isFullCalculation and the mod is<0 it is now also taken in account.
                  *add: cap the energy storage if the current value>max value.
      -2012Jan09- *fix: update the colony data panel ONLY IF Entity=0 and not >0.
      -2012Jan04- *code: the procedure is moved into the game_csm unit.
                  *code audit:
                  (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                  (x)parameters refactoring           (x) ()reformatting         (-)code optimizations
                  (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                  (x)summary completion
                  *add: in case of a complete calculation, limit the COL_csmENstorCurr if it's > newly calculated COL_csmENstorMax.
                  *add: in case of a complete calculation, add the energy generation due to custom effect, if any.
      -2011Jul23- *fix: correction in energy storage/current value calculation.
      -2011Jul19- *add: a new parameter for update the current energy storage.
                  *add: update the Colony Data Panel if this one is opened with the current colony.
      -2011Jul17- *fix: in the case of not CSMEUisFullCalculation, load the correct variable for energy consumption and storage.
}
   var
      InfraCount
      ,InfraMax
      ,SettlementCount
      ,SettlementMax: integer;

begin
   if not isFullCalculation then
   begin
      if ConsumptionMod<>0
      then FCentities[ Entity ].E_col[ Colony ].COL_csmENcons:=FCentities[ Entity ].E_col[ Colony ].COL_csmENcons+ConsumptionMod;
      if GenerationMod<>0
      then FCentities[ Entity ].E_col[ Colony ].COL_csmENgen:=FCentities[ Entity ].E_col[ Colony ].COL_csmENgen+GenerationMod;
      if StorageCurrentMod<>0 then
      begin
         FCentities[ Entity ].E_col[ Colony ].COL_csmENstorCurr:=FCentities[ Entity ].E_col[ Colony ].COL_csmENstorCurr+StorageCurrentMod;
         if FCentities[ Entity ].E_col[ Colony ].COL_csmENstorCurr>FCentities[ Entity ].E_col[ Colony ].COL_csmENstorMax
         then FCentities[ Entity ].E_col[ Colony ].COL_csmENstorCurr:=FCentities[ Entity ].E_col[ Colony ].COL_csmENstorMax;
      end;
      if StorageMaxMod<>0
      then FCentities[ Entity ].E_col[ Colony ].COL_csmENstorMax:=FCentities[ Entity ].E_col[ Colony ].COL_csmENstorMax+StorageMaxMod;
   end
   else if isFullCalculation then
   begin
      FCentities[ Entity ].E_col[ Colony ].COL_csmENcons:=0;
      FCentities[ Entity ].E_col[ Colony ].COL_csmENgen:=0;
      FCentities[ Entity ].E_col[ Colony ].COL_csmENstorMax:=0;
      SettlementMax:=length( FCentities[ Entity ].E_col[ Colony ].COL_settlements )-1;
      SettlementCount:=1;
      while SettlementCount<=SettlementMax do
      begin
         InfraMax:=Length( FCentities[ Entity ].E_col[ Colony ].COL_settlements[ SettlementCount ].CS_infra )-1;
         InfraCount:=1;
         while InfraCount<=InfraMax do
         begin
            if (
               ( FCentities[ Entity ].E_col[ Colony ].COL_settlements[ SettlementCount ].CS_infra[ InfraCount ].CI_status=istInConversion )
               or (
                  ( FCentities[ Entity ].E_col[ Colony ].COL_settlements[ SettlementCount ].CS_infra[ InfraCount ].CI_status>istDisabled )
                     and ( FCentities[ Entity ].E_col[ Colony ].COL_settlements[ SettlementCount ].CS_infra[ InfraCount ].CI_status<istDestroyed )
                  )
               ) then
            begin
               FCentities[ Entity ].E_col[ Colony ].COL_csmENcons
                  :=FCentities[ Entity ].E_col[ Colony ].COL_csmENcons+FCentities[ Entity ].E_col[ Colony ].COL_settlements[ SettlementCount ].CS_infra[ InfraCount ].CI_powerCons;
               if FCentities[ Entity ].E_col[ Colony ].COL_settlements[ SettlementCount ].CS_infra[ InfraCount ].CI_function=fEnergy
               then FCentities[ Entity ].E_col[ Colony ].COL_csmENgen:=
                  FCentities[ Entity ].E_col[ Colony ].COL_csmENgen+FCentities[ Entity ].E_col[ Colony ].COL_settlements[ SettlementCount ].CS_infra[ InfraCount ].CI_fEnergOut
                  +FCentities[ Entity ].E_col[ Colony ].COL_settlements[ SettlementCount ].CS_infra[ InfraCount ].CI_powerGenFromCFx;
               {:DEV NOTES: add custom effect energy storage.}
            end;
            inc( InfraCount );
         end;
         inc( SettlementCount );
      end; //==END== while CSMEUsettleCnt<=CSMEUsettleMax do ==//
      if FCentities[ Entity ].E_col[ Colony ].COL_csmENstorCurr>FCentities[ Entity ].E_col[ Colony ].COL_csmENstorMax
      then FCentities[ Entity ].E_col[ Colony ].COL_csmENstorCurr:=FCentities[ Entity ].E_col[ Colony ].COL_csmENstorMax;
   end; //==END== else if CSMEUisFullCalculation ==//
   if Entity=0
   then FCMuiCDD_Colony_Update(
      cdlDataCSMenergy
      ,Colony
      ,0
      ,0
      ,true
      ,false
      ,false
      );
end;

function FCFgCSM_Education_GetIdxStr(const EGISfac, EGIScol: integer): string;
{:Purpose: get the education index string.
   Additions:
      -2010Sep14- *add: a faction # parameter.
                  *add: entities code.
}
var
   EGISclr
   ,EGISidx: string;
begin
   if (FCentities[EGISfac].E_col[EGIScol].COL_edu>=0)
      and (FCentities[EGISfac].E_col[EGIScol].COL_edu<61)
   then
   begin
      EGISidx:='1';
      EGISclr:=FCCFcolRed;
   end
   else if (FCentities[EGISfac].E_col[EGIScol].COL_edu>=61)
      and (FCentities[EGISfac].E_col[EGIScol].COL_edu<71)
   then
   begin
      EGISidx:='2';
      EGISclr:=FCCFcolOrge;
   end
   else if (FCentities[EGISfac].E_col[EGIScol].COL_edu>=71)
      and (FCentities[EGISfac].E_col[EGIScol].COL_edu<86)
   then
   begin
      EGISidx:='3';
      EGISclr:=FCCFcolYel;
   end
   else if (FCentities[EGISfac].E_col[EGIScol].COL_edu>=86)
      and (FCentities[EGISfac].E_col[EGIScol].COL_edu<116)
   then
   begin
      EGISidx:='4';
      EGISclr:=FCCFcolYel;
   end
   else if (FCentities[EGISfac].E_col[EGIScol].COL_edu>=116)
      and (FCentities[EGISfac].E_col[EGIScol].COL_edu<131)
   then
   begin
      EGISidx:='5';
      EGISclr:=FCCFcolBlueL;
   end
   else if FCentities[EGISfac].E_col[EGIScol].COL_edu>=131
   then
   begin
      EGISidx:='6';
      EGISclr:=FCCFcolGreen;
   end;
   Result:=EGISclr+FCFdTFiles_UIStr_Get(uistrUI, 'colDeduI'+EGISidx)+FCCFcolEND;
end;

procedure FCMgCSM_Phase_Proc(
   const PPfac
         ,PPcol: integer
   );
{:Purpose: CSM phase w/ colony's data tests
   Additions:
      -2010Sep15- *add: entities code.
      -2010Aug01- *mod: readjust cohesion test values.
      -2010Aug30- *fix: cohesion progression calculations.
      -2010Aug23- *add: tension progression.
                  *add: over time processing link.
                  *fix: cohesion progression calculations.
      -2010Aug22- *add: cohesion test - 0-19% cohesion range test.
                  *add: cohesion test - cohesion progression.
      -2010Aug20- *add: cohesion test - CSM event Unrest + Uprising triggers.
      -2010Aug19- *add: Cohesion test - test succeed + 95-100% cohesion range test.
}
var
   PPclvl
   ,PPcohes
   ,PPedu
   ,PPmod
   ,PPrand
   ,PPsec
   ,PPtens
   ,PPtest
   ,PPx: integer;

   PPmodF: extended;

   PPstr: string;

   PPev: TFCEdgEventTypes;
begin
   {.retrieve colony's data}
   PPcohes:=FCentities[PPfac].E_col[PPcol].COL_cohes;
   PPsec:=FCentities[PPfac].E_col[PPcol].COL_secu;
   PPtens:=FCentities[PPfac].E_col[PPcol].COL_tens;
   PPedu:=FCentities[PPfac].E_col[PPcol].COL_edu;
   {.cohesion test}
   case PPcohes of
      0..19:
      begin
         case PPcohes of
            0..4: PPclvl:=1;
            5..9: PPclvl:=2;
            10..14: PPclvl:=3;
            15..19: PPclvl:=4;
         end;
         FCMgCSME_UnSup_FindRepl(
            PPfac
            ,PPcol
            ,etColDissident
            ,PPclvl
            ,csmeecImmediate
            ,true
            );
      end;
      20..94:
      begin
         PPx:=PPcohes-19;
         PPclvl:=round(sqrt(PPx));
         PPrand:=FCFcFunc_Rand_Int(100);
         {.calculate modifiers}
         PPmod:=0;
         PPstr:=FCFgCSM_Tension_GetIdx(
            PPfac
            , PPcol
            ,true
            );
         PPtens:=StrToInt(PPstr);
         case PPtens of
            1: PPmod:=-10;
            3: PPmod:=10;
            4: PPmod:=20;
            5: PPmod:=30;
         end;
         {.apply modifiers}
         PPtest:=PPrand+PPmod;
         case PPclvl of
            1:
            begin
               case PPtest of
                  {.test succeed}
                  0..19: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etColEstab
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  20..25: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  26..51: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etSocdis
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  52..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUprising
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
               end; //==END==  ==//
            end;
            2:
            begin
               case PPtest of
                  {.test succeed}
                  0..35: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etColEstab
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  36..44: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  45..70: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etSocdis
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  71..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUprising
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
               end; //==END==  ==//
            end;
            3:
            begin
               case PPtest of
                  {.test succeed}
                  0..44: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etColEstab
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  45..54: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  55..72: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etSocdis
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  73..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUprising
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
               end; //==END==  ==//
            end;
            4:
            begin
               case PPtest of
                  {.test succeed}
                  0..56: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etColEstab
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  57..67: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  68..85: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etSocdis
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  86..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUprising
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
               end; //==END==  ==//
            end;
            5:
            begin
               case PPtest of
                  {.test succeed}
                  0..66: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etColEstab
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  67..76: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  77..91: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etSocdis
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  92..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUprising
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
               end; //==END==  ==//
            end;
            6:
            begin
               case PPtest of
                  {.test succeed}
                  0..76: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etColEstab
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  77..86: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  87..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etSocdis
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
               end; //==END==  ==//
            end;
            7:
            begin
               case PPtest of
                  {.test succeed}
                  0..82: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etColEstab
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  83..91: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  92..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etSocdis
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
               end; //==END==  ==//
            end;
            8:
            begin
               case PPtest of
                  {.test succeed}
                  0..86: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etColEstab
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  87..94: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  95..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etSocdis
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
               end; //==END==  ==//
            end;
            9:
            begin
               case PPtest of
                  {.test succeed}
                  0..91: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etColEstab
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  92..97: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  98..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,etSocdis
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
               end; //==END==  ==//
            end;
         end; //==END== case PPclvl of ==//
      end; //==END== case: 35..94 ==//
      95..100: FCMgCSME_UnSup_FindRepl(
         PPfac
         ,PPcol
         ,etColEstab
         ,0
         ,csmeecRecover
         ,false
         );
   end; //==END== case PPcohes of ==//
   {.cohesion progression}
   PPev:=FCFgCSME_UnSup_Find(PPfac, PPcol);
   PPtest:=0;
   if PPev<>etColDissident
   then
   begin
      PPrand:=FCFcFunc_Rand_Int(100);
      PPx:=round((PPrand-PPcohes)*0.2);
      PPmodF:=0;
      PPtest:=0;
      if PPrand>PPcohes
      then
      begin
         case PPev of
            etUnrest: PPmodF:=0.75;
            etUnrestRec: PPmodF:=1;
            etSocdis: PPmodF:=0.5;
            etSocdisRec: PPmodF:=0.75;
            etUprising: PPmodF:=0;
            etUprisingRec: PPmodF:=0.5;
            else PPmodF:=1;
         end;
         PPtest:=round(PPcohes+(PPx*PPmodF));
      end
      else if PPrand<=PPcohes
      then
      begin
         case PPev of
            etUnrest: PPmodF:=1;
            etUnrestRec: PPmodF:=0.75;
            etSocdis: PPmodF:=1.25;
            etSocdisRec: PPmodF:=1;
            etUprising: PPmodF:=1.5;
            etUprisingRec: PPmodF:=1.25;
            else PPmodF:=0.75;
         end;
         PPtest:=round(PPcohes-(PPx*PPmodF));
      end;
   end;
   {.update the cohesion data}
   if PPtest<>0
   then
   begin
      if PPfac=0
      then FCentities[PPfac].E_col[PPcol].COL_cohes:=PPtest
      else if PPfac>0
      then
      begin

      end;
   end;
   {.tension progression}
   if (PPTens>0)
      and ((PPev<=etColEstab) or (PPev>etColDissident))
   then FCMgCSM_ColonyData_Upd(
      dTension
      ,PPfac
      ,PPcol
      ,-1
      ,0
      ,gcsmptNone
      ,false
      );
   {.over time processing}
   FCMgCSME_OT_Proc(PPfac, PPcol);
end;

procedure FCMgCSM_PhaseList_Upd(
   const PLUfac
         ,PLUcol: integer
   );
{:Purpose: update the CSM phase list, and initialize it if needed.
    Additions:
      -2010Sep15- *add: entities code.
}
var
   PLUcnt
   ,PLUcntSub
   ,PLUmax
   ,PLUmaxSub
   ,PLUtick: integer;
begin
   PLUtick:=FCentities[PLUfac].E_col[PLUcol].COL_csmTime;
   PLUmax:=length(FCGcsmPhList);
   if PLUmax<2
   then
   begin
      SetLength(FCGcsmPhList, 2);
      SetLength(FCGcsmPhList[1].CSMT_col[PLUfac], 2);
      FCGcsmPhList[1].CSMT_tick:=PLUtick;
      FCGcsmPhList[1].CSMT_col[PLUfac, 1]:=PLUcol;
   end
   else
   begin
      PLUcnt:=1;
      PLUmax:=length(FCGcsmPhList)-1;
      while PLUcnt<=PLUmax do
      begin
         if FCGcsmPhList[PLUcnt].CSMT_tick=PLUtick
         then
         begin
            PLUmaxSub:=length(FCGcsmPhList[PLUcnt].CSMT_col[PLUfac]);
            if PLUmaxSub<2
            then SetLength(FCGcsmPhList[PLUcnt].CSMT_col[PLUfac], 2)
            else SetLength(FCGcsmPhList[PLUcnt].CSMT_col[PLUfac], PLUmaxSub+1);
            PLUcntSub:=Length(FCGcsmPhList[PLUcnt].CSMT_col[PLUfac])-1;
            FCGcsmPhList[PLUcnt].CSMT_col[PLUfac, PLUcntSub]:=PLUcol;
            break;
         end;
         inc(PLUcnt);
      end;
   end;
end;

procedure FCMgCSM_Pop_Xfert(
   const PXfac
         ,PXcol: integer;
   const PXfrom,
         PXto: TFCEgcsmPopTp;
   const PXamount: integer
   );
{:Purpose: transfert an amount of population of one type to an another category.
    Additions:
      -2010Sep15- *add: entities code.
      -2010Aug18- *rem: the rebels are removed because the calculation and management of this data isn't the same as for the others.
}
begin
   case PXfrom of
      gcsmptColon: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpColon:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpColon-PXamount;
      gcsmptASoff: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpASoff:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpASoff-PXamount;
      gcsmptASmiSp: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpASmiSp:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpASmiSp-PXamount;
      gcsmptBSbio: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpBSbio:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpBSbio-PXamount;
      gcsmptBSdoc: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpBSdoc:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpBSdoc-PXamount;
      gcsmptIStech: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpIStech:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpIStech-PXamount;
      gcsmptISeng: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpISeng:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpISeng-PXamount;
      gcsmptMSsold: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpMSsold:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpMSsold-PXamount;
      gcsmptMScomm: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpMScomm:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpMScomm-PXamount;
      gcsmptPSphys: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpPSphys:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpPSphys-PXamount;
      gcsmptPSastr: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpPSastr:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpPSastr-PXamount;
      gcsmptESecol: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpESecol:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpESecol-PXamount;
      gcsmptESecof: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpESecof:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpESecof-PXamount;
      gcsmptAmedian: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpAmedian:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpAmedian-PXamount;
   end;
   case PXto of
      gcsmptColon: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpColon:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpColon+PXamount;
      gcsmptASoff: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpASoff:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpASoff+PXamount;
      gcsmptASmiSp: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpASmiSp:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpASmiSp+PXamount;
      gcsmptBSbio: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpBSbio:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpBSbio+PXamount;
      gcsmptBSdoc: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpBSdoc:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpBSdoc+PXamount;
      gcsmptIStech: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpIStech:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpIStech+PXamount;
      gcsmptISeng: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpISeng:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpISeng+PXamount;
      gcsmptMSsold: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpMSsold:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpMSsold+PXamount;
      gcsmptMScomm: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpMScomm:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpMScomm+PXamount;
      gcsmptPSphys: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpPSphys:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpPSphys+PXamount;
      gcsmptPSastr: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpPSastr:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpPSastr+PXamount;
      gcsmptESecol: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpESecol:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpESecol+PXamount;
      gcsmptESecof: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpESecof:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpESecof+PXamount;
      gcsmptAmedian: FCentities[PXfac].E_col[PXcol].COL_population.POP_tpAmedian:=FCentities[PXfac].E_col[PXcol].COL_population.POP_tpAmedian+PXamount;
   end;
end;

function FCFgCSM_Security_GetIdxStr(
   const SGISfac
         ,SGIScol: integer;
   const SGISraw: boolean
   ): string;
{:Purpose: get the security index string.
   -Additions-
      -2010Sep15- *add: faction # parameter.
                  *add: entities code.
      -2010Aug01- *add: raw switch + raw data return.
}
var
   SGISoobj
   ,SGISsat
   ,SGISssys
   ,SGISstar
   ,SGIStens
   ,SGISd1
   ,SGISd2
   ,SGISd3
   ,SGISd4
   ,SGISd5
   ,SGISd6
   ,SGISd7
   ,SGISd8: integer;

   SGISclr
   ,SGISidx: string;

   SGISenv: TFCEduEnvironmentTypes;
begin
   SGISssys:=FCFuF_StelObj_GetDbIdx(
      ufsoSsys
      ,FCentities[SGISfac].E_col[SGIScol].COL_locSSys
      ,0
      ,0
      ,0
      );
   SGISstar:=FCFuF_StelObj_GetDbIdx(
      ufsoStar
      ,FCentities[SGISfac].E_col[SGIScol].COL_locStar
      ,SGISssys
      ,0
      ,0
      );
   SGISoobj:=FCFuF_StelObj_GetDbIdx(
      ufsoOObj
      ,FCentities[SGISfac].E_col[SGIScol].COL_locOObj
      ,SGISssys
      ,SGISstar
      ,0
      );
   if FCentities[SGISfac].E_col[SGIScol].COL_locSat<>''
   then
   begin
      SGISsat:=FCFuF_StelObj_GetDbIdx(
         ufsoSsys
         ,FCentities[SGISfac].E_col[SGIScol].COL_locSat
         ,SGISssys
         ,SGISstar
         ,SGISoobj
         );
      SGISenv:=FCDduStarSystem[SGISssys].SS_stars[SGISstar].S_orbitalObjects[SGISoobj].OO_satellitesList[SGISsat].OO_environment
   end
   else if FCentities[SGISfac].E_col[SGIScol].COL_locSat=''
   then SGISenv:=FCDduStarSystem[SGISssys].SS_stars[SGISstar].S_orbitalObjects[SGISoobj].OO_environment;
   SGIStens:=StrToInt(
      FCFgCSM_Tension_GetIdx(
         SGISfac
         ,SGIScol
         ,true
         )
      );
   case SGISenv of
      etFreeLiving:
      begin
         case SGIStens of
            1:
            begin
               SGISd1:=451;
               SGISd2:=450;
               SGISd3:=151;
               SGISd4:=150;
               SGISd5:=46;
               SGISd6:=45;
               SGISd7:=16;
               SGISd8:=15;
            end;
            2:
            begin
               SGISd1:=301;
               SGISd2:=300;
               SGISd3:=101;
               SGISd4:=100;
               SGISd5:=31;
               SGISd6:=30;
               SGISd7:=11;
               SGISd8:=10;
            end;
            3:
            begin
               SGISd1:=201;
               SGISd2:=200;
               SGISd3:=68;
               SGISd4:=67;
               SGISd5:=21;
               SGISd6:=20;
               SGISd7:=8;
               SGISd8:=7;
            end;
            4:
            begin
               SGISd1:=151;
               SGISd2:=150;
               SGISd3:=51;
               SGISd4:=50;
               SGISd5:=16;
               SGISd6:=15;
               SGISd7:=6;
               SGISd8:=5;
            end;
            5:
            begin
               SGISd1:=121;
               SGISd2:=120;
               SGISd3:=41;
               SGISd4:=40;
               SGISd5:=13;
               SGISd6:=12;
               SGISd7:=5;
               SGISd8:=4;
            end;
         end; //==END== case SGIStens of ==//
      end; //==END== case: freeLiving ==//
      etRestricted:
      begin
         case SGIStens of
            1:
            begin
               SGISd1:=301;
               SGISd2:=300;
               SGISd3:=101;
               SGISd4:=100;
               SGISd5:=31;
               SGISd6:=30;
               SGISd7:=11;
               SGISd8:=10;
            end;
            2:
            begin
               SGISd1:=201;
               SGISd2:=200;
               SGISd3:=68;
               SGISd4:=67;
               SGISd5:=21;
               SGISd6:=20;
               SGISd7:=8;
               SGISd8:=7;
            end;
            3:
            begin
               SGISd1:=151;
               SGISd2:=150;
               SGISd3:=51;
               SGISd4:=50;
               SGISd5:=16;
               SGISd6:=15;
               SGISd7:=6;
               SGISd8:=5;
            end;
            4:
            begin
               SGISd1:=101;
               SGISd2:=100;
               SGISd3:=34;
               SGISd4:=33;
               SGISd5:=11;
               SGISd6:=10;
               SGISd7:=4;
               SGISd8:=3;
            end;
            5:
            begin
               SGISd1:=87;
               SGISd2:=86;
               SGISd3:=30;
               SGISd4:=29;
               SGISd5:=10;
               SGISd6:=9;
               SGISd7:=4;
               SGISd8:=3;
            end;
         end; //==END== case SGIStens of ==//
      end; //==END== case: restrict ==//
      etSpace:
      begin
         case SGIStens of
            1:
            begin
               SGISd1:=201;
               SGISd2:=200;
               SGISd3:=68;
               SGISd4:=67;
               SGISd5:=21;
               SGISd6:=20;
               SGISd7:=8;
               SGISd8:=7;
            end;
            2:
            begin
               SGISd1:=151;
               SGISd2:=150;
               SGISd3:=51;
               SGISd4:=50;
               SGISd5:=16;
               SGISd6:=15;
               SGISd7:=6;
               SGISd8:=5;
            end;
            3:
            begin
               SGISd1:=101;
               SGISd2:=100;
               SGISd3:=34;
               SGISd4:=33;
               SGISd5:=11;
               SGISd6:=10;
               SGISd7:=4;
               SGISd8:=3;
            end;
            4:
            begin
               SGISd1:=76;
               SGISd2:=75;
               SGISd3:=26;
               SGISd4:=25;
               SGISd5:=9;
               SGISd6:=8;
               SGISd7:=4;
               SGISd8:=3;
            end;
            5:
            begin
               SGISd1:=61;
               SGISd2:=60;
               SGISd3:=21;
               SGISd4:=20;
               SGISd5:=7;
               SGISd6:=6;
               SGISd7:=3;
               SGISd8:=2;
            end;
         end; //==END== case SGIStens of ==//
      end; //==END== case: space ==//
   end; //==END== case SGISenv of ==//
   if FCentities[SGISfac].E_col[SGIScol].COL_secu>=SGISd1
   then
   begin
      SGISidx:='1';
      SGISclr:=FCCFcolRed;
   end
   else if (FCentities[SGISfac].E_col[SGIScol].COL_secu<=SGISd2)
      and (FCentities[SGISfac].E_col[SGIScol].COL_secu>=SGISd3)
   then
   begin
      SGISidx:='2';
      SGISclr:=FCCFcolOrge;
   end
   else if (FCentities[SGISfac].E_col[SGIScol].COL_secu<=SGISd4)
      and (FCentities[SGISfac].E_col[SGIScol].COL_secu>=SGISd5)
   then
   begin
      SGISidx:='3';
      SGISclr:=FCCFcolYel;
   end
   else if (FCentities[SGISfac].E_col[SGIScol].COL_secu<=SGISd6)
      and (FCentities[SGISfac].E_col[SGIScol].COL_secu>=SGISd7)
   then
   begin
      SGISidx:='4';
      SGISclr:=FCCFcolBlueL;
   end
   else if FCentities[SGISfac].E_col[SGIScol].COL_secu<=SGISd8
   then
   begin
      SGISidx:='5';
      SGISclr:=FCCFcolGreen;
   end;
   if SGISraw
   then Result:=SGISidx
   else if not SGISraw
   then Result:=SGISclr+FCFdTFiles_UIStr_Get(uistrUI, 'colDsecI'+SGISidx)+FCCFcolEND;
end;

function FCFgCSM_SPL_GetIdxMod(
   const SPLGIMgetMod: TFCEgcsmSPLtp;
   const SPLGIMfac
         , SPLGIMcol: integer
   ): string;
{:Purpose: get either the spl index value.pb level or the resulting QoL modifier.
    Additions:
      -2010Sep15- *add: entities code.
      -2010Jun24- *mod: add TFCEgcsmSPLtp switch instead of the boolean.
}
var
   SPLGIMoobj
   ,SPLGIMsat
   ,SPLGIMssys
   ,SPLGIMstar: integer;

   SPLGIMclr
   ,SPLGIMres: string;

   SPLGIMenv: TFCEduEnvironmentTypes;
begin
   SPLGIMssys:=FCFuF_StelObj_GetDbIdx(
      ufsoSsys
      ,FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_locSSys
      ,0
      ,0
      ,0
      );
   SPLGIMstar:=FCFuF_StelObj_GetDbIdx(
      ufsoStar
      ,FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_locStar
      ,SPLGIMssys
      ,0
      ,0
      );
   SPLGIMoobj:=FCFuF_StelObj_GetDbIdx(
      ufsoOObj
      ,FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_locOObj
      ,SPLGIMssys
      ,SPLGIMstar
      ,0
      );
   if FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_locSat<>''
   then
   begin
      SPLGIMsat:=FCFuF_StelObj_GetDbIdx(
         ufsoSsys
         ,FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_locSat
         ,SPLGIMssys
         ,SPLGIMstar
         ,SPLGIMoobj
         );
      SPLGIMenv:=FCDduStarSystem[SPLGIMssys].SS_stars[SPLGIMstar].S_orbitalObjects[SPLGIMoobj].OO_satellitesList[SPLGIMsat].OO_environment
   end
   else if FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_locSat=''
   then SPLGIMenv:=FCDduStarSystem[SPLGIMssys].SS_stars[SPLGIMstar].S_orbitalObjects[SPLGIMoobj].OO_environment;
   case SPLGIMenv of
      etFreeLiving:
      begin
         if FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<0.5
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='1.5';
                  SPLGIMclr:=FCCFcolRed;
               end;
               QOLmod: SPLGIMres:='-3';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=0.5)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<0.6)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='2.4';
                  SPLGIMclr:=FCCFcolRed;
               end;
               QOLmod: SPLGIMres:='-2';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=0.6)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<0.8)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='3.3';
                  SPLGIMclr:=FCCFcolOrge;
               end;
               QOLmod: SPLGIMres:='-1';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=0.8)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<0.9)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='4.1';
                  SPLGIMclr:=FCCFcolOrge;
               end;
               QOLmod: SPLGIMres:='0';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=0.9)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.05)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='5';
                  SPLGIMclr:=FCCFcolYel;
               end;
               QOLmod: SPLGIMres:='0';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.05)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.2)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='6';
                  SPLGIMclr:=FCCFcolBlueL;
               end;
               QOLmod: SPLGIMres:='0';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.2)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.45)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='7';
                  SPLGIMclr:=FCCFcolBlueL;
               end;
               QOLmod: SPLGIMres:='1';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.45)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.7)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='8';
                  SPLGIMclr:=FCCFcolGreen;
               end;
               QOLmod: SPLGIMres:='2';
            end;
         end
         else if FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.7
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='9';
                  SPLGIMclr:=FCCFcolGreen;
               end;
               QOLmod: SPLGIMres:='3';
            end;
         end;
      end; //==END== case: freeliving ==//
      etRestricted:
      begin
         if FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<0.65
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='1.6';
                  SPLGIMclr:=FCCFcolRed;
               end;
               QOLmod: SPLGIMres:='-4';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=0.65)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<0.75)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='2.5';
                  SPLGIMclr:=FCCFcolRed;
               end;
               QOLmod: SPLGIMres:='-3';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=0.75)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<0.85)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='3.4';
                  SPLGIMclr:=FCCFcolOrge;
               end;
               QOLmod: SPLGIMres:='-2';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=0.85)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='4.2';
                  SPLGIMclr:=FCCFcolOrge;
               end;
               QOLmod: SPLGIMres:='0';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.15)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='5.1';
                  SPLGIMclr:=FCCFcolYel;
               end;
               QOLmod: SPLGIMres:='0';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.15)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.3)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='6';
                  SPLGIMclr:=FCCFcolBlueL;
               end;
               QOLmod: SPLGIMres:='0';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.3)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.6)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='7';
                  SPLGIMclr:=FCCFcolBlueL;
               end;
               QOLmod: SPLGIMres:='1';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.6)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.9)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='8';
                  SPLGIMclr:=FCCFcolRed;
               end;
               QOLmod: SPLGIMres:='2';
            end;
         end
         else if FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.9
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='9';
                  SPLGIMclr:=FCCFcolRed;
               end;
               QOLmod: SPLGIMres:='3';
            end;
         end;
      end; //==END== case: restrict ==//
      etSpace:
      begin
         if FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<0.75
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='1.6';
                  SPLGIMclr:=FCCFcolRed;
               end;
               QOLmod: SPLGIMres:='-4';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=0.75)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<0.8)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='2.5';
                  SPLGIMclr:=FCCFcolRed;
               end;
               QOLmod: SPLGIMres:='-3';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=0.8)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<0.9)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='3.4';
                  SPLGIMclr:=FCCFcolOrge;
               end;
               QOLmod: SPLGIMres:='-2';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=0.9)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.1)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='4.3';
                  SPLGIMclr:=FCCFcolOrge;
               end;
               QOLmod: SPLGIMres:='-1';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.1)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.25)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='5.2';
                  SPLGIMclr:=FCCFcolYel;
               end;
               QOLmod: SPLGIMres:='0';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.25)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.45)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='6.1';
                  SPLGIMclr:=FCCFcolBlueL;
               end;
               QOLmod: SPLGIMres:='0';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.45)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<1.7)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='7';
                  SPLGIMclr:=FCCFcolBlueL;
               end;
               QOLmod: SPLGIMres:='1';
            end;
         end
         else if (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=1.7)
            and (FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl<2)
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='8';
                  SPLGIMclr:=FCCFcolGreen;
               end;
               QOLmod: SPLGIMres:='2';
            end;
         end
         else if FCentities[SPLGIMfac].E_col[SPLGIMcol].COL_csmHOspl>=2
         then
         begin
            case SPLGIMgetMod of
               indexval, indexstr:
               begin
                  SPLGIMres:='9';
                  SPLGIMclr:=FCCFcolGreen;
               end;
               QOLmod: SPLGIMres:='3';
            end;
         end;
      end; //==END== case: space ==//
   end; //==END== case SPLGIMenv of ==//
   case SPLGIMgetMod of
      indexval, QOLmod: Result:=SPLGIMres;
      indexstr:
      begin
         delete(SPLGIMres,2,2);
         Result:=SPLGIMclr+FCFdTFiles_UIStr_Get(uistrUI, 'colDsplI'+SPLGIMres)+FCCFcolEND;
      end;
   end;
end;

function FCFgCSM_Tension_GetIdx(
   const TGISfac
         ,TGIScol: integer;
   const TGISraw: boolean
   ): string;
{:Purpose: get the tension index string.
    Additions:
      -2010Sep15- *add: a parameter for faction #.
                  *add: entities code.
      -2010xxxxx- *add: a parameter for either have the index string or index value string.
}
var
   CGISclr
   ,CGISidx: string;
begin
   if FCentities[TGISfac].E_col[TGIScol].COL_tens<16
   then
   begin
      CGISidx:='1';
      if not TGISraw
      then CGISclr:=FCCFcolGreen;
   end
   else if (FCentities[TGISfac].E_col[TGIScol].COL_tens>=16)
      and (FCentities[TGISfac].E_col[TGIScol].COL_tens<41)
   then
   begin
      CGISidx:='2';
      if not TGISraw
      then CGISclr:=FCCFcolBlueL;
   end
   else if (FCentities[TGISfac].E_col[TGIScol].COL_tens>=41)
      and (FCentities[TGISfac].E_col[TGIScol].COL_tens<66)
   then
   begin
      CGISidx:='3';
      if not TGISraw
      then CGISclr:=FCCFcolYel;
   end
   else if (FCentities[TGISfac].E_col[TGIScol].COL_tens>=66)
      and (FCentities[TGISfac].E_col[TGIScol].COL_tens<86)
   then
   begin
      CGISidx:='4';
      if not TGISraw
      then CGISclr:=FCCFcolOrge;
   end
   else if FCentities[TGISfac].E_col[TGIScol].COL_tens>=86
   then
   begin
      CGISidx:='5';
      if not TGISraw
      then CGISclr:=FCCFcolRed;
   end;
   if not TGISraw
   then Result:=CGISclr+FCFdTFiles_UIStr_Get(uistrUI, 'colDtensI'+CGISidx)+FCCFcolEND
   else if TGISraw
   then Result:=CGISidx;
end;

end.