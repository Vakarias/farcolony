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
///   get the security index
///</summary>
///   <param name="SGISfac">faction index #</param>
///   <param name="SGIScol">colony index #</param>
function FCFgCSM_Security_GetIndex(
   const SGISfac
         ,SGIScol: integer
   ): integer;

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
   MeanAge:=trunc( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_population.CP_meanAge );
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
   if FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion<20
   then
   begin
      CGISidx:='1';
      CGISclr:=FCCFcolRed;
   end
   else if (FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion>=20)
      and (FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion<35)
   then
   begin
      CGISidx:='2';
      CGISclr:=FCCFcolRed;
   end
   else if (FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion>=35)
      and (FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion<50)
   then
   begin
      CGISidx:='3';
      CGISclr:=FCCFcolOrge;
   end
   else if (FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion>=50)
      and (FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion<65)
   then
   begin
      CGISidx:='4';
      CGISclr:=FCCFcolYel;
   end
   else if (FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion>=65)
      and (FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion<80)
   then
   begin
      CGISidx:='5';
      CGISclr:=FCCFcolBlueL;
   end
   else if (FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion>=80)
      and (FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion<95)
   then
   begin
       CGISidx:='6';
       CGISclr:=FCCFcolGreen;
   end
   else if FCDdgEntities[CGISfac].E_colonies[CGIScol].C_cohesion>=95
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
   if FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel<=0
   then HealthIndex:=1
   else if (FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel>=1)
      and (FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel<51)
   then HealthIndex:=2
   else if (FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel>=51)
      and (FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel<91)
   then HealthIndex:=3
   else if (FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel>=91)
      and (FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel<111)
   then HealthIndex:=4
   else if (FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel>=111)
      and (FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel<126)
   then HealthIndex:=5
   else if (FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel>=126)
      and (FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel<141)
   then HealthIndex:=6
   else if FCDdgEntities[Entity].E_colonies[Colony].C_csmHealth_HealthLevel>=141
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
   CDIcolTtl:=length(FCDdgEntities[CDIfac].E_colonies)-1;
   CDIcol:=FCDdgEntities[CDIfac].E_colonies[CDIcolIdx];
   {.init cohesion data}
   if CDIcolTtl=1
   then CDIcol.C_cohesion:=85+FCDdgEntities[CDIfac].E_spmMod_Cohesion
   else if CDIcolTtl>1
   then CDIcol.C_cohesion:=FCFgSPMD_GlobalData_Get(gspmdStability, 0);
   {.init tension data}
   CDIcol.C_tension:=10+FCDdgEntities[CDIfac].E_spmMod_Tension;
   {.init education data}
   if CDIcolTtl=1
   then CDIcol.C_instruction:=80+FCDdgEntities[CDIfac].E_spmMod_Education
   else if CDIcolTtl>1
   then CDIcol.C_instruction:=FCFgSPMD_GlobalData_Get(gspmdInstruction, 0);
   {.init colony level, it's 1 by default, the value is updated when population is added and/or region control has changed}
   CDIcol.C_level:=cl1Outpost;
   {.transfert colony's data and initialize the non calculated data}
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_level:=CDIcol.C_level;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_hqPresence:=hqsNoHQPresent;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_cohesion:=CDIcol.C_cohesion;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_security:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_tension:=CDIcol.C_tension;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_instruction:=CDIcol.C_instruction;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_csmHousing_PopulationCapacity:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_csmHousing_SpaceLevel:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_csmHousing_QualityOfLife:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_csmHealth_HealthLevel:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_csmEnergy_Consumption:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_csmEnergy_Generation:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_csmEnergy_StorageCurrent:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_csmEnergy_StorageMax:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_economicIndustrialOutput:=100;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_total:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_meanAge:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_deathRate:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_deathStack:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_birthRate:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_birthStack:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classColonist:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classColonistAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classAerOfficer:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classAerOfficerAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classAerMissionSpecialist:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classAerMissionSpecialistAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classBioBiologist:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classBioBiologistAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classBioDoctor:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classBioDoctorAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classIndTechnician:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classIndTechnicianAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classIndEngineer:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classIndEngineerAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classMilSoldier:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classMilSoldierAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classMilCommando:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classMilCommandoAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classPhyPhysicist:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classPhyPhysicistAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classPhyAstrophysicist:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classPhyAstrophysicistAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classEcoEcologist:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classEcoEcologistAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classEcoEcoformer:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classEcoEcoformerAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classAdmMedian:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classAdmMedianAssigned:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classRebels:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_classMilitia:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_CWPtotal:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_population.CP_CWPassignedPeople:=0;
   setlength(FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_events, 1);
   setlength(FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_settlements, 1);
   setlength(FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_cabQueue, 1);
   setlength(FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_productionMatrix, 1);
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_storageCapacitySolidCurrent:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_storageCapacitySolidMax:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_storageCapacityLiquidCurrent:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_storageCapacityLiquidMax:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_storageCapacityGasCurrent:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_storageCapacityGasMax:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_storageCapacityBioCurrent:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_storageCapacityBioMax:=0;
   setlength(FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_storedProducts, 1);
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_reserveOxygen:=0;
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_reserveFood:=0;
   SetLength( FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_reserveFoodProductsIndex, 1 );
   FCDdgEntities[CDIfac].E_colonies[CDIcolIdx].C_reserveWater:=0;
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
         CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total;
         CDUdatI1:=round(CDUvalue);
         FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total:=CDUdatI+CDUdatI1;
         case CDUpopType of
            gcsmptColon:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classColonist;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classColonist:=CDUdatI+CDUdatI1;
            end;
            gcsmptASoff:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classAerOfficer;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classAerOfficer:=CDUdatI+CDUdatI1;
            end;
            gcsmptASmiSp:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classAerMissionSpecialist;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classAerMissionSpecialist:=CDUdatI+CDUdatI1;
            end;
            gcsmptBSbio:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classBioBiologist;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classBioBiologist:=CDUdatI+CDUdatI1;
            end;
            gcsmptBSdoc:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classBioDoctor;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classBioDoctor:=CDUdatI+CDUdatI1;
            end;
            gcsmptIStech:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classIndTechnician;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classIndTechnician:=CDUdatI+CDUdatI1;
            end;
            gcsmptISeng:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classIndEngineer;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classIndEngineer:=CDUdatI+CDUdatI1;
            end;
            gcsmptMSsold:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classMilSoldier;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classMilSoldier:=CDUdatI+CDUdatI1;
            end;
            gcsmptMScomm:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classMilCommando;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classMilCommando:=CDUdatI+CDUdatI1;
            end;
            gcsmptPSphys:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classPhyPhysicist;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classPhyPhysicist:=CDUdatI+CDUdatI1;
            end;
            gcsmptPSastr:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classPhyAstrophysicist;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classPhyAstrophysicist:=CDUdatI+CDUdatI1;
            end;
            gcsmptESecol:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classEcoEcologist;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classEcoEcologist:=CDUdatI+CDUdatI1;
            end;
            gcsmptESecof:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classEcoEcoformer;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classEcoEcoformer:=CDUdatI+CDUdatI1;
            end;
            gcsmptAmedian:
            begin
               CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classAdmMedian;
               FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classAdmMedian:=CDUdatI+CDUdatI1;
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
         if FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total>0
         then FCMgPGS_BR_Calc(CDUfac, CDUcol);
         {.update dependencies}
      end;
      dCohesion:
      begin
         CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_cohesion;
         FCDdgEntities[CDUfac].E_colonies[CDUcol].C_cohesion:=CDUdatI+round(CDUvalue);
         {.update dependencies}
      end;
      dColonyLvl:
      begin
         {:DEV NOTES: don't forget to also put the region control test.}
         if (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total>=1)
            and (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total<11)
         then FCDdgEntities[CDUfac].E_colonies[CDUcol].C_level:=cl1Outpost
         else if (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total>=11)
            and (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total<101)
         then FCDdgEntities[CDUfac].E_colonies[CDUcol].C_level:=cl2Base
         else if (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total>=101)
            and (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total<1001)
         then FCDdgEntities[CDUfac].E_colonies[CDUcol].C_level:=cl3Community
         else if (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total>=1001)
            and (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total<10001)
         then FCDdgEntities[CDUfac].E_colonies[CDUcol].C_level:=cl4Settlement
         else if (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total>=10001)
            and (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total<100001)
         then FCDdgEntities[CDUfac].E_colonies[CDUcol].C_level:=cl5MajorColony
         else if (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total>=100001)
            and (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total<1000001)
         then FCDdgEntities[CDUfac].E_colonies[CDUcol].C_level:=cl6LocalState
         else if (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total>=1000001)
         then FCDdgEntities[CDUfac].E_colonies[CDUcol].C_level:=cl7RegionalState;
         {.csm events trigger}
         {.update dependencies}
      end;
      dDeathRate:
      begin
         if FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total>0
         then FCMgPGS_DR_Calc(CDUfac, CDUcol);
         {.update dependencies}
      end;
      dHealth:
      begin
         if not CDUfullUpd
         then
         begin
            CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHealth_HealthLevel;
            FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHealth_HealthLevel:=CDUdatI+round(CDUvalue);
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
            CDUdatI3:=(FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHousing_QualityOfLife*10)+FCDdgEntities[CDUfac].E_spmMod_Health+CDUdatI2+CDUdatI1;
            FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHealth_HealthLevel:=CDUdatI3;
         end;
         {.update dependencies}
         CDUdatI:=0;
         CDUdatI1:=0;
         CDUdatI2:=0;
         CDUdatI:=FCFgCSME_Search_ByType(
            ceHealthEducationRelation
            ,CDUfac
            ,CDUcol
            );
         if FCDdgEntities[CDUfac].E_colonies[CDUcol].C_events[CDUdatI].CCSME_tHERelEducationMod>0
         then CDUdatI1:=-FCDdgEntities[CDUfac].E_colonies[CDUcol].C_events[CDUdatI].CCSME_tHERelEducationMod
         else if FCDdgEntities[CDUfac].E_colonies[CDUcol].C_events[CDUdatI].CCSME_tHERelEducationMod<0
         then CDUdatI1:=abs(FCDdgEntities[CDUfac].E_colonies[CDUcol].C_events[CDUdatI].CCSME_tHERelEducationMod);
         FCDdgEntities[CDUfac].E_colonies[CDUcol].C_events[CDUdatI].CCSME_tHERelEducationMod:=CDUdatI1;
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
         FCDdgEntities[CDUfac].E_colonies[CDUcol].C_events[CDUdatI].CCSME_tHERelEducationMod:=CDUdatI2;
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
         CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_instruction;
         FCDdgEntities[CDUfac].E_colonies[CDUcol].C_instruction:=CDUdatI+round(CDUvalue);
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
            CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHousing_PopulationCapacity;
            FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHousing_PopulationCapacity:=CDUdatI+round(CDUvalue);
         end
         else if CDUfullUpd
         then
         begin
            CDUdatI:=0;
            CDUsettleMax:=length(FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements)-1;
            if CDUsettleMax>0
            then
            begin
               CDUsettleCnt:=1;
               while CDUsettleCnt<=CDUsettleMax do
               begin
                  CDUcnt:=1;
                  CDUmax:=length(FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements[CDUsettleCnt].S_infrastructures)-1;
                  if CDUmax>0
                  then
                  begin
                     while CDUcnt<=CDUmax do
                     begin
                        if (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements[CDUsettleCnt].S_infrastructures[CDUcnt].I_function=fHousing)
                           and (
                              (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements[CDUsettleCnt].S_infrastructures[CDUcnt].I_status=isInConversion)
                                 or (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements[CDUsettleCnt].S_infrastructures[CDUcnt].I_status=isOperational)
                              )
                        then CDUdatI:=CDUdatI+FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements[CDUsettleCnt].S_infrastructures[CDUcnt].I_fHousPopulationCapacity;
                        inc(CDUcnt);
                     end;
                  end;
                  inc(CDUsettleCnt);
               end;
            end;
            FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHousing_PopulationCapacity:=CDUdatI;
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
         CDUsettleMax:=length(FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements)-1;
         if CDUsettleMax>0
         then
         begin
            CDUsettleCnt:=1;
            while CDUsettleCnt<=CDUsettleMax do
            begin
               CDUcnt:=1;
               CDUmax:=length(FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements[CDUsettleCnt].S_infrastructures)-1;
               if CDUmax>0
               then
               begin
                  while CDUcnt<=CDUmax do
                  begin
                     if (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements[CDUsettleCnt].S_infrastructures[CDUcnt].I_function=fHousing)
                        and (
                           (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements[CDUsettleCnt].S_infrastructures[CDUcnt].I_status=isInConversion)
                              or (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements[CDUsettleCnt].S_infrastructures[CDUcnt].I_status=isOperational)
                           )
                     then
                     begin
                        CDUdatI:=CDUdatI+FCDdgEntities[CDUfac].E_colonies[CDUcol].C_settlements[CDUsettleCnt].S_infrastructures[CDUcnt].I_fHousQualityOfLife;
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
         then FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHousing_QualityOfLife:=CDUqolMod
         else if CDUdatI1>0
         then FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHousing_QualityOfLife:=round(CDUdatI/CDUdatI1)+CDUqolMod;
         if FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHousing_QualityOfLife<1
         then FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHousing_QualityOfLife:=1;
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
         if FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classMilSoldier=0
         then FCDdgEntities[CDUfac].E_colonies[CDUcol].C_security:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total
         else if FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classMilSoldier>0
         then
         begin
            CDUdatF:=
               (FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total-FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classMilSoldier)
               /FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_classMilSoldier;
            CDUdatI:=round(CDUdatF);
            CDUdatI1:=FCFgCSME_Mod_Sum(
               mtSecurity
               ,CDUfac
               ,CDUcol
               );
            CDUdatI2:=FCDdgEntities[CDUfac].E_spmMod_Security;
            CDUdatF:=1+((CDUdatI1+CDUdatI2)/100);
            if CDUdatF<0
            then CDUdatF:=0;
            CDUdatF1:=CDUdatI*CDUdatF;
            FCDdgEntities[CDUfac].E_colonies[CDUcol].C_security:=round(CDUdatF1);
         end;
         {.update dependencies}
      end;
      dSPL:
      begin
         CDUdatF:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHousing_PopulationCapacity/FCDdgEntities[CDUfac].E_colonies[CDUcol].C_population.CP_total;
         FCDdgEntities[CDUfac].E_colonies[CDUcol].C_csmHousing_SpaceLevel:=DecimalRound(CDUdatF, 2, 0.001);
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
         CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_tension;
         FCDdgEntities[CDUfac].E_colonies[CDUcol].C_tension:=CDUdatI+round(CDUvalue);
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
         CDUdatI:=FCDdgEntities[CDUfac].E_colonies[CDUcol].C_economicIndustrialOutput;
         FCDdgEntities[CDUfac].E_colonies[CDUcol].C_economicIndustrialOutput:=CDUdatI+round(CDUvalue);
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
      then FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_Consumption:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_Consumption+ConsumptionMod;
      if GenerationMod<>0
      then FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_Generation:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_Generation+GenerationMod;
      if StorageCurrentMod<>0 then
      begin
         FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageCurrent:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageCurrent+StorageCurrentMod;
         if FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageCurrent>FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageMax
         then FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageCurrent:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageMax;
      end;
      if StorageMaxMod<>0
      then FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageMax:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageMax+StorageMaxMod;
   end
   else if isFullCalculation then
   begin
      FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_Consumption:=0;
      FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_Generation:=0;
      FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageMax:=0;
      SettlementMax:=length( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_settlements )-1;
      SettlementCount:=1;
      while SettlementCount<=SettlementMax do
      begin
         InfraMax:=Length( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_settlements[ SettlementCount ].S_infrastructures )-1;
         InfraCount:=1;
         while InfraCount<=InfraMax do
         begin
            if (
               ( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_settlements[ SettlementCount ].S_infrastructures[ InfraCount ].I_status=isInConversion )
               or ( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_settlements[ SettlementCount ].S_infrastructures[ InfraCount ].I_status=isOperational)

               ) then
            begin
               FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_Consumption
                  :=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_Consumption+FCDdgEntities[ Entity ].E_colonies[ Colony ].C_settlements[ SettlementCount ].S_infrastructures[ InfraCount ].I_powerConsumption;
               if FCDdgEntities[ Entity ].E_colonies[ Colony ].C_settlements[ SettlementCount ].S_infrastructures[ InfraCount ].I_function=fEnergy
               then FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_Generation:=
                  FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_Generation+FCDdgEntities[ Entity ].E_colonies[ Colony ].C_settlements[ SettlementCount ].S_infrastructures[ InfraCount ].I_fEnOutput
                  +FCDdgEntities[ Entity ].E_colonies[ Colony ].C_settlements[ SettlementCount ].S_infrastructures[ InfraCount ].I_powerGeneratedFromCustomEffect;
               {:DEV NOTES: add custom effect energy storage.}
            end;
            inc( InfraCount );
         end;
         inc( SettlementCount );
      end; //==END== while CSMEUsettleCnt<=CSMEUsettleMax do ==//
      if FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageCurrent>FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageMax
      then FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageCurrent:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_csmEnergy_StorageMax;
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
   if (FCDdgEntities[EGISfac].E_colonies[EGIScol].C_instruction>=0)
      and (FCDdgEntities[EGISfac].E_colonies[EGIScol].C_instruction<61)
   then
   begin
      EGISidx:='1';
      EGISclr:=FCCFcolRed;
   end
   else if (FCDdgEntities[EGISfac].E_colonies[EGIScol].C_instruction>=61)
      and (FCDdgEntities[EGISfac].E_colonies[EGIScol].C_instruction<71)
   then
   begin
      EGISidx:='2';
      EGISclr:=FCCFcolOrge;
   end
   else if (FCDdgEntities[EGISfac].E_colonies[EGIScol].C_instruction>=71)
      and (FCDdgEntities[EGISfac].E_colonies[EGIScol].C_instruction<86)
   then
   begin
      EGISidx:='3';
      EGISclr:=FCCFcolYel;
   end
   else if (FCDdgEntities[EGISfac].E_colonies[EGIScol].C_instruction>=86)
      and (FCDdgEntities[EGISfac].E_colonies[EGIScol].C_instruction<116)
   then
   begin
      EGISidx:='4';
      EGISclr:=FCCFcolYel;
   end
   else if (FCDdgEntities[EGISfac].E_colonies[EGIScol].C_instruction>=116)
      and (FCDdgEntities[EGISfac].E_colonies[EGIScol].C_instruction<131)
   then
   begin
      EGISidx:='5';
      EGISclr:=FCCFcolBlueL;
   end
   else if FCDdgEntities[EGISfac].E_colonies[EGIScol].C_instruction>=131
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

   PPev: TFCEdgColonyEvents;
begin
   {.retrieve colony's data}
   PPcohes:=FCDdgEntities[PPfac].E_colonies[PPcol].C_cohesion;
   PPsec:=FCDdgEntities[PPfac].E_colonies[PPcol].C_security;
   PPtens:=FCDdgEntities[PPfac].E_colonies[PPcol].C_tension;
   PPedu:=FCDdgEntities[PPfac].E_colonies[PPcol].C_instruction;
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
            ,ceDissidentColony
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
                     ,ceColonyEstablished
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  20..25: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  26..51: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceSocialDisorder
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  52..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUprising
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
                     ,ceColonyEstablished
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  36..44: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  45..70: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceSocialDisorder
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  71..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUprising
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
                     ,ceColonyEstablished
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  45..54: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  55..72: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceSocialDisorder
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  73..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUprising
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
                     ,ceColonyEstablished
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  57..67: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  68..85: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceSocialDisorder
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  86..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUprising
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
                     ,ceColonyEstablished
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  67..76: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  77..91: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceSocialDisorder
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  92..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUprising
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
                     ,ceColonyEstablished
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  77..86: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  87..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceSocialDisorder
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
                     ,ceColonyEstablished
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  83..91: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  92..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceSocialDisorder
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
                     ,ceColonyEstablished
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  87..94: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  95..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceSocialDisorder
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
                     ,ceColonyEstablished
                     ,0
                     ,csmeecRecover
                     ,false
                     );
                  92..97: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceUnrest
                     ,PPclvl
                     ,csmeecOverride
                     ,true
                     );
                  98..100: FCMgCSME_UnSup_FindRepl(
                     PPfac
                     ,PPcol
                     ,ceSocialDisorder
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
         ,ceColonyEstablished
         ,0
         ,csmeecRecover
         ,false
         );
   end; //==END== case PPcohes of ==//
   {.cohesion progression}
   PPev:=FCFgCSME_UnSup_Find(PPfac, PPcol);
   PPtest:=0;
   if PPev<>ceDissidentColony
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
            ceUnrest: PPmodF:=0.75;
            ceUnrest_Recovering: PPmodF:=1;
            ceSocialDisorder: PPmodF:=0.5;
            ceSocialDisorder_Recovering: PPmodF:=0.75;
            ceUprising: PPmodF:=0;
            ceUprising_Recovering: PPmodF:=0.5;
            else PPmodF:=1;
         end;
         PPtest:=round(PPcohes+(PPx*PPmodF));
      end
      else if PPrand<=PPcohes
      then
      begin
         case PPev of
            ceUnrest: PPmodF:=1;
            ceUnrest_Recovering: PPmodF:=0.75;
            ceSocialDisorder: PPmodF:=1.25;
            ceSocialDisorder_Recovering: PPmodF:=1;
            ceUprising: PPmodF:=1.5;
            ceUprising_Recovering: PPmodF:=1.25;
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
      then FCDdgEntities[PPfac].E_colonies[PPcol].C_cohesion:=PPtest
      else if PPfac>0
      then
      begin

      end;
   end;
   {.tension progression}
   if (PPTens>0)
      and ((PPev<=ceColonyEstablished) or (PPev>ceDissidentColony))
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
   PLUtick:=FCDdgEntities[PLUfac].E_colonies[PLUcol].C_nextCSMsessionInTick;
   PLUmax:=length(FCDdgCSMPhaseSchedule);
   if PLUmax<2
   then
   begin
      SetLength(FCDdgCSMPhaseSchedule, 2);
      SetLength(FCDdgCSMPhaseSchedule[1].CSMPS_colonies[PLUfac], 2);
      FCDdgCSMPhaseSchedule[1].CSMPS_ProcessAtTick:=PLUtick;
      FCDdgCSMPhaseSchedule[1].CSMPS_colonies[PLUfac, 1]:=PLUcol;
   end
   else
   begin
      PLUcnt:=1;
      PLUmax:=length(FCDdgCSMPhaseSchedule)-1;
      while PLUcnt<=PLUmax do
      begin
         if FCDdgCSMPhaseSchedule[PLUcnt].CSMPS_ProcessAtTick=PLUtick
         then
         begin
            PLUmaxSub:=length(FCDdgCSMPhaseSchedule[PLUcnt].CSMPS_colonies[PLUfac]);
            if PLUmaxSub<2
            then SetLength(FCDdgCSMPhaseSchedule[PLUcnt].CSMPS_colonies[PLUfac], 2)
            else SetLength(FCDdgCSMPhaseSchedule[PLUcnt].CSMPS_colonies[PLUfac], PLUmaxSub+1);
            PLUcntSub:=Length(FCDdgCSMPhaseSchedule[PLUcnt].CSMPS_colonies[PLUfac])-1;
            FCDdgCSMPhaseSchedule[PLUcnt].CSMPS_colonies[PLUfac, PLUcntSub]:=PLUcol;
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
      gcsmptColon: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classColonist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classColonist-PXamount;
      gcsmptASoff: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAerOfficer:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAerOfficer-PXamount;
      gcsmptASmiSp: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAerMissionSpecialist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAerMissionSpecialist-PXamount;
      gcsmptBSbio: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classBioBiologist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classBioBiologist-PXamount;
      gcsmptBSdoc: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classBioDoctor:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classBioDoctor-PXamount;
      gcsmptIStech: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classIndTechnician:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classIndTechnician-PXamount;
      gcsmptISeng: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classIndEngineer:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classIndEngineer-PXamount;
      gcsmptMSsold: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classMilSoldier:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classMilSoldier-PXamount;
      gcsmptMScomm: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classMilCommando:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classMilCommando-PXamount;
      gcsmptPSphys: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classPhyPhysicist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classPhyPhysicist-PXamount;
      gcsmptPSastr: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classPhyAstrophysicist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classPhyAstrophysicist-PXamount;
      gcsmptESecol: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classEcoEcologist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classEcoEcologist-PXamount;
      gcsmptESecof: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classEcoEcoformer:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classEcoEcoformer-PXamount;
      gcsmptAmedian: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAdmMedian:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAdmMedian-PXamount;
   end;
   case PXto of
      gcsmptColon: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classColonist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classColonist+PXamount;
      gcsmptASoff: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAerOfficer:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAerOfficer+PXamount;
      gcsmptASmiSp: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAerMissionSpecialist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAerMissionSpecialist+PXamount;
      gcsmptBSbio: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classBioBiologist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classBioBiologist+PXamount;
      gcsmptBSdoc: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classBioDoctor:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classBioDoctor+PXamount;
      gcsmptIStech: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classIndTechnician:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classIndTechnician+PXamount;
      gcsmptISeng: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classIndEngineer:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classIndEngineer+PXamount;
      gcsmptMSsold: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classMilSoldier:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classMilSoldier+PXamount;
      gcsmptMScomm: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classMilCommando:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classMilCommando+PXamount;
      gcsmptPSphys: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classPhyPhysicist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classPhyPhysicist+PXamount;
      gcsmptPSastr: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classPhyAstrophysicist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classPhyAstrophysicist+PXamount;
      gcsmptESecol: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classEcoEcologist:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classEcoEcologist+PXamount;
      gcsmptESecof: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classEcoEcoformer:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classEcoEcoformer+PXamount;
      gcsmptAmedian: FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAdmMedian:=FCDdgEntities[PXfac].E_colonies[PXcol].C_population.CP_classAdmMedian+PXamount;
   end;
end;

function FCFgCSM_Security_GetIndex(
   const SGISfac
         ,SGIScol: integer
   ): integer;
{:Purpose: get the security index.
    Additions:
}
   var
      ResultString: string;
begin
   Result:=0;
   ResultString:='';
   ResultString:=FCFgCSM_Security_GetIdxStr(
      SGISfac
      ,SGIScol
      ,true
      );
   Result:=StrToInt( ResultString );
end;

function FCFgCSM_Security_GetIdxStr(
   const SGISfac
         ,SGIScol: integer;
   const SGISraw: boolean
   ): string;
{:Purpose: get the security index string.
   -Additions-
      -2012Nov25- *mod: update of the three security range tables after refinement.
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
      ,FCDdgEntities[SGISfac].E_colonies[SGIScol].C_locationStarSystem
      ,0
      ,0
      ,0
      );
   SGISstar:=FCFuF_StelObj_GetDbIdx(
      ufsoStar
      ,FCDdgEntities[SGISfac].E_colonies[SGIScol].C_locationStar
      ,SGISssys
      ,0
      ,0
      );
   SGISoobj:=FCFuF_StelObj_GetDbIdx(
      ufsoOObj
      ,FCDdgEntities[SGISfac].E_colonies[SGIScol].C_locationOrbitalObject
      ,SGISssys
      ,SGISstar
      ,0
      );
   if FCDdgEntities[SGISfac].E_colonies[SGIScol].C_locationSatellite<>''
   then
   begin
      SGISsat:=FCFuF_StelObj_GetDbIdx(
         ufsoSsys
         ,FCDdgEntities[SGISfac].E_colonies[SGIScol].C_locationSatellite
         ,SGISssys
         ,SGISstar
         ,SGISoobj
         );
      SGISenv:=FCDduStarSystem[SGISssys].SS_stars[SGISstar].S_orbitalObjects[SGISoobj].OO_satellitesList[SGISsat].OO_environment
   end
   else if FCDdgEntities[SGISfac].E_colonies[SGIScol].C_locationSatellite=''
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
               SGISd1:=1001;
               SGISd2:=1000;
               SGISd3:=251;
               SGISd4:=250;
               SGISd5:=76;
               SGISd6:=75;
               SGISd7:=51;
               SGISd8:=50;
            end;
            2:
            begin
               SGISd1:=668;
               SGISd2:=667;
               SGISd3:=168;
               SGISd4:=167;
               SGISd5:=51;
               SGISd6:=50;
               SGISd7:=34;
               SGISd8:=33;
            end;
            3:
            begin
               SGISd1:=446;
               SGISd2:=445;
               SGISd3:=112;
               SGISd4:=111;
               SGISd5:=34;
               SGISd6:=33;
               SGISd7:=24;
               SGISd8:=23;
            end;
            4:
            begin
               SGISd1:=335;
               SGISd2:=334;
               SGISd3:=84;
               SGISd4:=83;
               SGISd5:=26;
               SGISd6:=25;
               SGISd7:=17;
               SGISd8:=16;
            end;
            5:
            begin
               SGISd1:=268;
               SGISd2:=267;
               SGISd3:=67;
               SGISd4:=66;
               SGISd5:=21;
               SGISd6:=20;
               SGISd7:=14;
               SGISd8:=13;
            end;
         end; //==END== case SGIStens of ==//
      end; //==END== case: freeLiving ==//
      etRestricted:
      begin
         case SGIStens of
            1:
            begin
               SGISd1:=667;
               SGISd2:=666;
               SGISd3:=167;
               SGISd4:=166;
               SGISd5:=51;
               SGISd6:=50;
               SGISd7:=34;
               SGISd8:=33;
            end;
            2:
            begin
               SGISd1:=446;
               SGISd2:=445;
               SGISd3:=112;
               SGISd4:=111;
               SGISd5:=34;
               SGISd6:=33;
               SGISd7:=23;
               SGISd8:=22;
            end;
            3:
            begin
               SGISd1:=335;
               SGISd2:=334;
               SGISd3:=84;
               SGISd4:=83;
               SGISd5:=26;
               SGISd6:=25;
               SGISd7:=17;
               SGISd8:=16;
            end;
            4:
            begin
               SGISd1:=224;
               SGISd2:=223;
               SGISd3:=56;
               SGISd4:=55;
               SGISd5:=18;
               SGISd6:=17;
               SGISd7:=11;
               SGISd8:=10;
            end;
            5:
            begin
               SGISd1:=192;
               SGISd2:=191;
               SGISd3:=49;
               SGISd4:=48;
               SGISd5:=16;
               SGISd6:=15;
               SGISd7:=9;
               SGISd8:=8;
            end;
         end; //==END== case SGIStens of ==//
      end; //==END== case: restrict ==//
      etSpace:
      begin
         case SGIStens of
            1:
            begin
               SGISd1:=445;
               SGISd2:=444;
               SGISd3:=113;
               SGISd4:=112;
               SGISd5:=34;
               SGISd6:=33;
               SGISd7:=24;
               SGISd8:=23;
            end;
            2:
            begin
               SGISd1:=335;
               SGISd2:=334;
               SGISd3:=85;
               SGISd4:=84;
               SGISd5:=26;
               SGISd6:=25;
               SGISd7:=18;
               SGISd8:=17;
            end;
            3:
            begin
               SGISd1:=224;
               SGISd2:=223;
               SGISd3:=56;
               SGISd4:=55;
               SGISd5:=18;
               SGISd6:=17;
               SGISd7:=11;
               SGISd8:=10;
            end;
            4:
            begin
               SGISd1:=168;
               SGISd2:=167;
               SGISd3:=43;
               SGISd4:=42;
               SGISd5:=14;
               SGISd6:=13;
               SGISd7:=11;
               SGISd8:=10;
            end;
            5:
            begin
               SGISd1:=135;
               SGISd2:=134;
               SGISd3:=34;
               SGISd4:=33;
               SGISd5:=11;
               SGISd6:=10;
               SGISd7:=8;
               SGISd8:=7;
            end;
         end; //==END== case SGIStens of ==//
      end; //==END== case: space ==//
   end; //==END== case SGISenv of ==//
   if FCDdgEntities[SGISfac].E_colonies[SGIScol].C_security>=SGISd1
   then
   begin
      SGISidx:='1';
      SGISclr:=FCCFcolRed;
   end
   else if (FCDdgEntities[SGISfac].E_colonies[SGIScol].C_security<=SGISd2)
      and (FCDdgEntities[SGISfac].E_colonies[SGIScol].C_security>=SGISd3)
   then
   begin
      SGISidx:='2';
      SGISclr:=FCCFcolOrge;
   end
   else if (FCDdgEntities[SGISfac].E_colonies[SGIScol].C_security<=SGISd4)
      and (FCDdgEntities[SGISfac].E_colonies[SGIScol].C_security>=SGISd5)
   then
   begin
      SGISidx:='3';
      SGISclr:=FCCFcolYel;
   end
   else if (FCDdgEntities[SGISfac].E_colonies[SGIScol].C_security<=SGISd6)
      and (FCDdgEntities[SGISfac].E_colonies[SGIScol].C_security>=SGISd7)
   then
   begin
      SGISidx:='4';
      SGISclr:=FCCFcolBlueL;
   end
   else if FCDdgEntities[SGISfac].E_colonies[SGIScol].C_security<=SGISd8
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
      ,FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_locationStarSystem
      ,0
      ,0
      ,0
      );
   SPLGIMstar:=FCFuF_StelObj_GetDbIdx(
      ufsoStar
      ,FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_locationStar
      ,SPLGIMssys
      ,0
      ,0
      );
   SPLGIMoobj:=FCFuF_StelObj_GetDbIdx(
      ufsoOObj
      ,FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_locationOrbitalObject
      ,SPLGIMssys
      ,SPLGIMstar
      ,0
      );
   if FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_locationSatellite<>''
   then
   begin
      SPLGIMsat:=FCFuF_StelObj_GetDbIdx(
         ufsoSsys
         ,FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_locationSatellite
         ,SPLGIMssys
         ,SPLGIMstar
         ,SPLGIMoobj
         );
      SPLGIMenv:=FCDduStarSystem[SPLGIMssys].SS_stars[SPLGIMstar].S_orbitalObjects[SPLGIMoobj].OO_satellitesList[SPLGIMsat].OO_environment
   end
   else if FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_locationSatellite=''
   then SPLGIMenv:=FCDduStarSystem[SPLGIMssys].SS_stars[SPLGIMstar].S_orbitalObjects[SPLGIMoobj].OO_environment;
   case SPLGIMenv of
      etFreeLiving:
      begin
         if FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<0.5
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=0.5)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<0.6)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=0.6)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<0.8)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=0.8)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<0.9)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=0.9)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.05)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.05)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.2)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.2)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.45)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.45)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.7)
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
         else if FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.7
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
         if FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<0.65
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=0.65)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<0.75)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=0.75)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<0.85)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=0.85)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.15)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.15)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.3)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.3)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.6)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.6)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.9)
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
         else if FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.9
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
         if FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<0.75
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=0.75)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<0.8)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=0.8)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<0.9)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=0.9)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.1)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.1)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.25)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.25)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.45)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.45)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<1.7)
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
         else if (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=1.7)
            and (FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel<2)
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
         else if FCDdgEntities[SPLGIMfac].E_colonies[SPLGIMcol].C_csmHousing_SpaceLevel>=2
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
   if FCDdgEntities[TGISfac].E_colonies[TGIScol].C_tension<16
   then
   begin
      CGISidx:='1';
      if not TGISraw
      then CGISclr:=FCCFcolGreen;
   end
   else if (FCDdgEntities[TGISfac].E_colonies[TGIScol].C_tension>=16)
      and (FCDdgEntities[TGISfac].E_colonies[TGIScol].C_tension<41)
   then
   begin
      CGISidx:='2';
      if not TGISraw
      then CGISclr:=FCCFcolBlueL;
   end
   else if (FCDdgEntities[TGISfac].E_colonies[TGIScol].C_tension>=41)
      and (FCDdgEntities[TGISfac].E_colonies[TGIScol].C_tension<66)
   then
   begin
      CGISidx:='3';
      if not TGISraw
      then CGISclr:=FCCFcolYel;
   end
   else if (FCDdgEntities[TGISfac].E_colonies[TGIScol].C_tension>=66)
      and (FCDdgEntities[TGISfac].E_colonies[TGIScol].C_tension<86)
   then
   begin
      CGISidx:='4';
      if not TGISraw
      then CGISclr:=FCCFcolOrge;
   end
   else if FCDdgEntities[TGISfac].E_colonies[TGIScol].C_tension>=86
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
