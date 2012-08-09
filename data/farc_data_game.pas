{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: misc game systems - data unit

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
unit farc_data_game;

interface

uses
   farc_data_infrprod
   ,farc_data_init
   ,farc_data_spm
   ,farc_data_univ
   ,farc_game_cpsobjectives;

{:REFERENCES LIST
   - factionsdb.xml
   - FCMdF_DBFactions_Read
   - FCFgSPM_Meme_GetSVRange
}
///<summary>
///   meme's belief levels
///</summary>
type TFCEdgBeliefLevels=(
   blUnknown
   ,blFleeting
   ,blUncommon
   ,blCommon
   ,blStrong
   ,blKnownByAll
   );

///<summary>
///   colony levels
///</summary>
type TFCEdgColonyLevels=(
   cl1Outpost
   ,cl2Base
   ,cl3Community
   ,cl4Settlement
   ,cl5MajorColony
   ,cl6LocalState
   ,cl7RegionalState
   ,cl8FederatedStates
   ,cl9ContinentalState
   ,cl10UnifiedWorld
   );

///<summary>
///   credit and interest range
///</summary>
type TFCEdgCreditInterestRanges=(
   cirPoor_Insignificant
   ,cirUnderfunded_Low
   ,cirBelowAverage_Moderate
   ,cirAverage
   ,cirAboveAverage
   ,cirRich_High
   ,cirOverFunded_Usurious
   ,cirUnlimited_Insane
   );

{:REFERENCES LIST
   - FCFgCSME_Event_GetStr
}
///<summary>
///   colony events
///</summary>
type TFCEdgColonyEvents=(
   ceColonyEstablished
   ,ceUnrest
   ,ceUnrest_Recovering
   ,ceSocialDisorder
   ,ceSocialDisorder_Recovering
   ,ceUprising
   ,ceUprising_Recovering
   ,ceDissidentColony
   ,ceHealthEducationRelation
   ,ceGovernmentDestabilization
   ,ceGovernmentDestabilization_Recovering
   ,ceOxygenProductionOverload
   ,ceOxygenShortage
   ,ceOxygenShortage_Recovering
   ,ceWaterProductionOverload
   ,ceWaterShortage
   ,ceWaterShortage_Recovering
   ,ceFoodProductionOverload
   ,ceFoodShortage
   ,ceFoodShortage_Recovering
   );

{:REFERENCES LIST
   - factionsdb.xml
   - FCMdF_DBFactions_Read
   - FCMgNG_Core_Proceed
}
///<summary>
///   list of faction's equipment item types
///</summary>
type TFCEdgFactionEquipItemTypes=(
   feitProduct
   ,feitSpaceUnit
   );

{:REFERENCES LIST
   - FCFgC_HQ_GetStr
}
///<summary>
///   HQ status list
///</summary>
type TFCEdgHeadQuarterStatus=(
   hqsNoHQPresent
   ,hqsBasicHQ
   ,hqsSecondaryHQ
   ,hqsPrimaryUniqueHQ
   );

{:REFERENCES LIST
   - FCFgInf_Status_GetToken
   - FCMdF_Game_Load
   - FCMdF_Game_Save
   - FCMuiCDP_Data_Update / dtInfra
}
///<summary>
///   owned infrastructure status list
///</summary>
type TFCEdgInfrastructureStatus=(
   isInKit
   ,isInConversion
   ,isInAssembling
   ,isInBluidingSite
   ,isDisabled
   ,isDisabledByEnergyEquilibrium
   ,isInTransition
   ,isOperational
   );

{:REFERENCES LIST
   - FCFgSPMD_Level_GetToken
}
///<summary>
///   player's faction status
///</summary>
type TFCEdgPlayerFactionStatus=(
   pfs0_NotViable
   ,pfs1_FullyDependent
   ,pfs2_SemiDependent
   ,pfs3_Independent
   );




//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================









   {.settlement types}
   {:DEV NOTES: update FCMdF_Game_Save/FCMdF_Game_Load + FCMuiWin_UI_Upd w/FCWMS_Grp_MCG_SetType + FCFgICS_InfraLevel_Setup.}
   type TFCEdgSettleType=(
      stSurface
      ,stSpaceSurf
      ,stSubterranean
      ,stSpaceBased
      );
   
  


   
   {.space unit attitude status}
   {:DEV NOTES: update factionsdb.xml}
   {:DEV NOTES: update TFCRfacDotationItem w/ status comment.}
   {:DEV NOTES: update spu_functions / FCFspuF_AttStatus_Get.}
   type TFCEspUnStatus=(
      {in free space w/ a transit or not}
      susInFreeSpace
      {in orbit of an orbital object}
      ,susInOrbit
      {in an atmospheric flight, landing or taking off}
      ,susInAtmosph
      {landed on an orbital object}
      ,susLanded
      {docked on/in an another space unit}
      ,susDocked
      {is out of control ie there's no more maneuver and main propulsion and naturally considered in free space}
      ,susOutOfCtl
      {is a dead wreck}
      ,susDeadWreck
//    scstatInLagrange    look to add this more later in development
      );
   {task action type list}
   {:DEV NOTES: update: FCMgMCore_Mission_Setup + FCMgMCore_Mission_Commit + FCMgMCore_Mission_TrackUpd + FCMspuF_SpUnit_Remove.}
   {:DEV NOTES: update: FCFspuF_Mission_GetMissName.}
   type TFCEtaskActionTp=(
      {space unit - mission - colonization}
      tatpMissColonize
      {space unit - mission - interplanetary transit}
      ,tatpMissItransit
      ,tatpDummy
      );
   {.task phases}
   {:DEV NOTES: update: FCFspuF_Mission_GetPhaseName.}
   type TFCEtaskPhase=(
      tpAccel
      ,tpCruise
      ,tpDecel
      ,tpAtmEnt
      ,tpDone
      ,tpTerminated
      );
   {task target type list}
   type TFCEtaskTargetTp=(
      {infrastructure}
      tttInfrast
      {space unit}
      ,tttSpaceUnit
      {orbital object}
      ,tttOrbObj
      ,tttSat
      ,tttSpace
      );
   {time phases}
   type TFCEtimePhases=(
      {.null data}
      tphNull
      {.reset the time flow}
//      ,tphRESET
      {tactical, 1secRT eq 10minGT}
      ,tphTac
      {management, time accelerated by 2}
      ,tphMan
      {strategical/historical, time accelerated by 10}
      ,tphSTH
      {game paused}
      ,tphPAUSE
      {.game paused w/o interface}
      ,tphPAUSEwo
      );
   //==END ENUM=============================================================================
   {.colony event data structure}
   {:DEV NOTES: UPDATE FCMdFiles_Game_Load + FCMdFiles_Game_Save + FCMuiCDP_Data_Update}
   {:DEV NOTES: UPDATE FCMgCSME_Event_Trigger + FCMgCSME_Event_Cancel + FCMgCSME_OT_Proc.}
   {:DEV NOTES: update farc_game_csmevents/TFCEcsmeModTp + FCFgCSME_Mod_Sum + FCMuiCDP_Data_Update/dtCSMev if any modifier is modified / added.}
   {:DEV NOTES: update FCMgCSME_Recovering_Process.}
   type TFCRdgColonCSMev = record
      {.define if the event is resident or (=false =>) occasional (w/ a duration of 24hrs}
      CSMEV_isRes: boolean;
      {.duration in # of full weeks (or # of CSM phases)}
      CSMEV_duration: integer;
      {.optional level data - this data is never displayed to the player}
      CSMEV_lvl: integer;
      {.event types with linked data}
      case CSMEV_token: TFCEdgColonyEvents of
         ceColonyEstablished:(
            CE_tensionMod: integer;
            CE_securityMod: integer
            );

         ceUnrest, ceUnrest_Recovering:(
            UN_ecoindMod: integer;
            UN_tensionMod: integer
            );

         ceSocialDisorder, ceSocialDisorder_Recovering:(
            SD_ecoindMod: integer;
            SD_tensionMod: integer
            );

         {:DEV NOTES: add rebels and fighting results.}
         ceUprising, ceUprising_Recovering:(
            UP_ecoindMod: integer;
            UP_tensionMod: integer
            );

         ceDissidentColony:();

         ceHealthEducationRelation:( HER_educationMod: integer );

         ceGovernmentDestabilization, ceGovernmentDestabilization_Recovering:( GD_cohesionMod: integer );

         ceOxygenProductionOverload:( ROO_percPopNotSupported: integer );

         ceOxygenShortage, ceOxygenShortage_Recovering:(
            ///<summary>
            /// percent of population not supported at time of SF calculation
            ///</summary>
            ROS_percPopNotSupAtCalc: integer;
            ROS_ecoindMod: integer;
            ROS_tensionMod: integer;
            ROS_healthMod: integer
            );

         ceWaterProductionOverload:( RWO_percPopNotSupported: integer );

         ceWaterShortage, ceWaterShortage_Recovering:(
            ///<summary>
            /// percent of population not supported at time of SF calculation
            ///</summary>
            RWS_percPopNotSupAtCalc: integer;
            RWS_ecoindMod: integer;
            RWS_tensionMod: integer;
            RWS_healthMod: integer
            );

         ceFoodProductionOverload:( RFO_percPopNotSupported: integer );

         ceFoodShortage, ceFoodShortage_Recovering:(
            ///<summary>
            /// percent of population not supported at time of SF calculation
            ///</summary>
            RFS_percPopNotSupAtCalc: integer;
            RFS_ecoindMod: integer;
            RFS_tensionMod: integer;
            RFS_healthMod: integer;
            RFS_directDeathPeriod: integer;
            RFS_deathFracValue: extended
            );
         //==END== case CSMEV_token: TFCEdgEventTypes of ==//
   end;
   {.owned infrastructure data structure}
   {:DEV NOTES: update FCMdFiles_Game_Save/Load + FCMgICS_Conversion_Process + FCMgICS_Assembling_Process + FCMgICS_Building_Process + FCMuiCDP_Data_Update/dtInfra.}
   {:DEV NOTES: for functions: update FCMgIF_Functions_Initialize + FCMgIF_Functions_ApplicationRemove.}
   type TFCRdgColonInfra= record
      {.dbinfra token id}
      CI_dbToken: string[20];
      {.current level}
      CI_level: integer;
      {.current status}
      CI_status: TFCEdgInfrastructureStatus;
      {.CAB duration and worked}
      CI_cabDuration: integer;
      CI_cabWorked: integer;
      {.consumed power = infrastructure's base power + enabled production modes}
      CI_powerCons: extended;
      ///<summary>
      /// power generated by the custom effect Power Generation, if the infrastructure have any and is enabled
      ///</summary>
      CI_powerGenFromCFx: extended;
      {.function and dependent data}
      case CI_function: TFCEdipFunctions of
         fEnergy:
            {.energy output by hour in kW}
            (CI_fEnergOut: extended);
            {:DEV NOTES: add energy fuel current status.}

         fHousing:
            {.population capacity}
            (CI_fhousPCAP: integer;
            {.quality of life}
            CI_fhousQOL: integer;
            {.calculated volume}
            CI_fhousVol: integer;
            {.calculated surface}
            CI_fhousSurf: integer
            );

         fProduction:
            (
            ///<summary>
            /// linked surveyed spot index, if needed
            ///</summary>
            CI_fprodSurveyedSpot: integer;
            ///<summary>
            /// linked surveyed region index, if needed
            ///</summary>
            CI_fprodSurveyedRegion: integer;
            ///<summary>
            /// linked surveyed resource spot index, in the surveyed region, if needed
            ///</summary>
            CI_fprodResourceSpot: integer;
            CI_fprodMode: array [0..FCCdipProductionModesMax] of record
               PM_type: TFCEdipProductionModes;
               ///<summary>
               /// switch when the related production mode is disabled or not by the game or the player
               ///</summary>
               PM_isDisabled: boolean;
               PM_energyCons: extended;
               PM_matrixItemMax: integer;
               ///<summary>
               /// linked matrix items indexes
               ///</summary>
               PF_linkedMatrixItemIndexes: array [0..FCCdiMatrixItemsMax] of record
                  LMII_matrixItmIndex: integer;
                  LMII_matrixProdModeIndex: integer;
               end;
            end;
      );
   end;
   {.production matrix item}
   {:DEV NOTES: update FCMdFiles_Game_Load + FCMdFiles_Game_Save + FCMgCSM_ColonyData_Init + FCMgPS2_ProductionMatrixItem_Add.}
   type TFCRdgColonProdMatrixItm= record
      CPMI_productToken: string[20];
      ///<summary>
      /// index # in the colony's storage which correspond to the product
      ///</summary>
      CPMI_storageIndex: integer;
      ///<summary>
      /// indicate the storage type used by the product
      ///</summary>
      CPMI_storageType: TFCEdipStorageTypes;
      ///<summary>
      /// global production flow
      ///</summary>
      CPMI_globalProdFlow: extended;
      CPMI_productionModes: array of record
         PF_locSettlement: integer;
         PF_locInfra: integer;
         ///<summary>
         /// owned infrastructure's production mode index
         ///</summary>
         PF_locProdModeIndex: integer;
         ///<summary>
         /// switch used by the production phase to manage the production matrix
         ///</summary>
         PF_isDisabledByProdSegment: boolean;
         ///<summary>
         /// production flow in + or - and in unit/hr. if -: used as source
         ///</summary>
         PF_productionFlow: extended;
      end;
   end;

   {.settlements data structure}
   {:DEV NOTES: update .}
   type TFCRdgColonSettlements= record
      {.personalized name}
      CS_name: string[20];
      {.settlement type}
      CS_type: TFCEdgSettleType;
      {.settlement current level}
      CS_level: integer;
      {.location w/ region #}
      CS_region: integer;
      {.infrastructures}
      CS_infra: array of TFCRdgColonInfra;
   end;
   {.colony population data structure}
   {:DEV NOTES: UPDATE FCMdFiles_Game_Load / Save + FCMgCSM_ColonyData_Init + FCMgCSM_ColonyData_Upd + FCMgCSM_Pop_Xfert.}
   {:DEV NOTES: for population type, update TFCEgcsmPopTp + FCMgPGS_DR_Calc + FCMgPGS_BR_Calc, excepted for Rebels and Militia + FCFgIS_RequiredStaff_Test.}
   {:DEV NOTES: for population type, also update TFCEdiPopType.}
   type TFCRdgColonPopulation= record
      POP_total: int64;
      {.mean age}
      POP_meanA: extended;
      {.death rate}
      POP_dRate: extended;
      {.death stack}
      POP_dStack: extended;
      {.birth rate}
      POP_bRate: extended;
      {.birth stack}
      POP_bStack: extended;
      {.colonists}
      POP_tpColon: int64;
      POP_tpColonAssigned: int64;
      {.aerospace specialist - officer}
      POP_tpASoff: integer;
      POP_tpASoffAssigned: integer;
      {.aerospace specialist - mission specialist}
      POP_tpASmiSp: integer;
      POP_tpASmiSpAssigned: integer;
      {.biology specialist - biologist}
      POP_tpBSbio: integer;
      POP_tpBSbioAssigned: integer;
      {.biology specialist - doctor}
      POP_tpBSdoc: integer;
      POP_tpBSdocAssigned: integer;
      {.industrial specialist - technician}
      POP_tpIStech: integer;
      POP_tpIStechAssigned: integer;
      {.industrial specialist - engineer}
      POP_tpISeng: integer;
      POP_tpISengAssigned: integer;
      {.military specialist - soldier}
      POP_tpMSsold: integer;
      POP_tpMSsoldAssigned: integer;
      {.military specialist - commando}
      POP_tpMScomm: integer;
      POP_tpMScommAssigned: integer;
      {.physics specialits - physicist}
      POP_tpPSphys: integer;
      POP_tpPSphysAssigned: integer;
      {.physics specialits - astrophysicist}
      POP_tpPSastr: integer;
      POP_tpPSastrAssigned: integer;
      {.ecology specialist - ecologist}
      POP_tpESecol: integer;
      POP_tpESecolAssigned: integer;
      {.ecology specialist - ecoformer}
      POP_tpESecof: integer;
      POP_tpESecofAssigned: integer;
      {.administrative specialist - median}
      POP_tpAmedian: integer;
      POP_tpAmedianAssigned: integer;
      {.rebels}
      POP_tpRebels: integer;
      {.militia}
      POP_tpMilitia: integer;
      {.construction workforce}
      POP_wcpTotal: extended;
      POP_wcpAssignedPeople: integer;
   end;
   {.colony's product item}
   type TFCRdgColonProduct=record
      CPR_token: string[20];
      CPR_unit: extended;
   end;
   {.colony data structure}
   {DEV NOTE: update FCMdFiles_Game_Load + FCMdFiles_Game_Save + FCMgCSM_ColonyData_Init + FCMgCSM_ColonyData_Upd}
   {:DEV NOTES: for sub data structure dependencies, update FCFgC_Colony_Core and eventually related methods/functions.}
   {:DEV NOTES: for colony data + csm data, upd TFCEuiwColData + FCMgCSM_ColonyData_Init. fro CSM Energy module: FCMgIP_CSMEnergy_Update}
   type TFCRdgColony = record
      {.personalized name, not required so can be ''}
      COL_name: string[20];
      {.foundation date - year}
      COL_fndYr: integer;
      {.foundation date - month}
      COL_fndMth: integer;
      {.foundation date - day}
      COL_fndDy: integer;
      {.time tick for the next CSM test session}
      COL_csmTime: integer;
      {.location - star system}
      COL_locSSys: string[20];
      {.location - star}
      COL_locStar: string[20];
      {.location - orbital object}
      COL_locOObj: string[20];
      {.location - satellite}
      COL_locSat: string[20];
      {.colony level}
      COL_level: TFCEdgColonyLevels;
      {.HQ presence}
      COL_hqPres: TFCEdgHeadQuarterStatus;
      {.cohesion}
      COL_cohes: integer;
      {.security}
      COL_secu: integer;
      {.tension}
      COL_tens: integer;
      {.education}
      COL_edu: integer;
      {.csm housing - pcap}
      COL_csmHOpcap: int64;
      {.csm housing - pcap}
      COL_csmHOspl: extended;
      {.csm housing - qol}
      COL_csmHOqol: integer;
      {.csm health - heal}
      COL_csmHEheal: integer;
      {.csm energy - consumption}
      COL_csmENcons: extended;
      {.csm energy - generation}
      COL_csmENgen: extended;
      {.csm energy - storage}
      COL_csmENstorCurr: extended;
      COL_csmENstorMax: extended;
      {.economic & industrial output}
      COL_eiOut: integer;
      {.population}
      COL_population: TFCRdgColonPopulation;
      {.events list}
      COL_evList: array of TFCRdgColonCSMev;
      {.colony's settlements}
      COL_settlements: array of TFCRdgColonSettlements;
      ///<summary>
      /// CAB queue [x,y] = infrastructure index in settlement
         ///<summary>
         /// x= settlements index
         ///</summary>
         ///<summary>
         /// y= CAB index in settlement
         ///</summary>
      ///</summary>
      COL_cabQueue: array of array of integer;
      {.production matrix}
      COL_productionMatrix: array of TFCRdgColonProdMatrixItm;
      {.storage capacities}
      COL_storCapacitySolidCurr: extended;
      COL_storCapacitySolidMax: extended;
      COL_storCapacityLiquidCurr: extended;
      COL_storCapacityLiquidMax: extended;
      COL_storCapacityGasCurr: extended;
      COL_storCapacityGasMax: extended;
      COL_storCapacityBioCurr: extended;
      COL_storCapacityBioMax: extended;
      {.storage list, in units}
		COL_storageList: array of TFCRdgColonProduct;
		{.reserves}
      COL_reserveOxygen: integer;
		COL_reserveFood: integer;
      ///<summary>
      /// store the storage indexes for each food product
      ///</summary>
      COL_reserveFoodList: array of integer;
		COL_reserveWater: integer;
   end;
   {.CSM test list}
   {:DEV NOTES: update FCMdFiles_Game_Load/Save + FCMgTFlow_CSMphase_Proc.}
   type TFCRdgCSMtest= record
      CSMT_tick: integer;
      ///<summary>
      /// colonies to test [x,y] = colony index #
         ///<summary>
         /// x= faction index #
         ///</summary>
         ///<summary>
         /// y= test list index # (<>colony index #)
         ///</summary>
      ///</summary>
      CSMT_col: array[0..FCCdiFactionsMax] of array of integer;
   end;
   TFCcsmPhaseL = array of TFCRdgCSMtest;

   {equipment list item datastructure}
   {:DEV NOTE: update FCMdFiles_DBFactions_Read + FCMgNG_ColMode_Upd.}
   type TFCRdgFactCMEquipItm = record
      {type of dotation item}
      case FCMEI_itemType: TFCEdgFactionEquipItemTypes of
         feitProduct:
            (
               {.product token related to the item}
               FCMEI_prodToken: string[20];
               {.units of this product}
               FCMEI_prodUnit: integer;
               {.indicate which space unit carries this product, use the owned index #, since the unique id tokens are generated during game setup}
               FCMEI_prodCarriedBy: integer;
               );
         feitSpaceUnit:
            (
               {.space unit proper name token}
               FCMEI_spuProperNameToken: string[20];
               {.design token}
               FCMEI_spuDesignToken: string[20];
               {.current status}
               FCMEI_spuStatus: TFCEspUnStatus;
               {.dock info -1: not docked/mother vessel, 1: mother vessel (all subsequent w/ 0 are docked to this one), 0: docked vessel}
               FCMEI_spuDockInfo: integer;
               {.current available energy/reaction mass volume}
               FCMEI_spuAvailEnRM: extended
               );
   end;
   {.colonization mode data structure}
   {:DEV NOTE: update FCMdFiles_DBFactions_Read + FCMgNG_ColMode_Upd + FCMgNG_Core_Proceed.}
   type TFCRdgFactColMode = record
      {.token}
      FCM_token: string[20];
      ///<summary>
      /// CPS - economic viability threshold
      ///</summary>
      FCM_cpsVthEconomic: integer;
      ///<summary>
      /// CPS - social viability threshold
      ///</summary>
      FCM_cpsVthSocial: integer;
      ///<summary>
      /// CPS - space & military viability threshold
      ///</summary>
      FCM_cpsVthSpaceMilitary: integer;
      {.CPS data - credit range}
      FCM_cpsCrRg: TFCEdgCreditInterestRanges;
      {.CPS data - interest range}
      FCM_cpsIntRg: TFCEdgCreditInterestRanges;
      {.CPS data - viability objectives}
      FCM_cpsViabObj: array of TFCRcpsoViabilityObjective;
      {.dotation list sub datastructure}
      FCM_dotList: array of TFCRdgFactCMEquipItm;
   end;
   {.SPM settings for entities}
   {:DEV NOTES: update FCMdF_Game_Load / FCMdF_Game_Save + FCMdF_DBFactions_Read + FCMgNG_Core_Proceed.}
   {:DEV NOTES: put custom effects current set values.}
   type TFCRdgFactSPMset= record
      SPMS_token: string[20];
      SPMS_duration: integer;
      {.cost storage}
      SPMS_ucCost: integer;
      case SPMS_isPolicy: boolean of
         true:
            (SPMS_isSet: boolean;
            {.acceptance value}
            SPMS_aprob: integer);
         false:
            (SPMS_bLvl: TFCEdgBeliefLevels;
            SPMS_sprdVal: integer);
   end;
   {starting location item}
   type TFCRdgFactStartLoc = record
      {star system location}
      FSL_locSSys: string[20];
      {local star location}
      FSL_locStar: string[20];
      {orbital object location}
      FSL_locObObj: string[20];
   end;
   {faction's data structure}
   {:DEV NOTE: don't forget to update FCMdFiles_DBFactions_Read.}
   type TFCRdgFaction = record
      {.db token id}
      F_token: string[20];
      {.type}
      {:DEV NOTES: remove it and replace by faction level (FL).}
      F_lvl: integer;
      {.colonization modes}
      F_facCmode: array of TFCRdgFactColMode;
      {.starting locations list}
      F_facStartLocList: array of TFCRdgFactStartLoc;
      {.SPM setting}
      F_spm: array of TFCRdgFactSPMset;
   end;
      {.factions dynamic array}
      {:DEV NOTES: also update the array of colonies for TFCRorbObj + TFCRorbObjSat + TFCRcsmTest.}
      TFCDBfactions = array [0..FCCdiFactionsMax] of TFCRdgFaction;
   {.player's data structure}
   {DEV NOTE: UPDATE NEW GAME SETUP + FCMdFSG_Game_Save + FCMdFSG_Game_Load}
   type TFCRdgPlayer = record
      {.game name, used for save game name}
      P_gameName: string;
      {.token id of faction the player belongs to, if fullInd then = 'null'}
      P_facAlleg: string[20];
      {.economic status}
      P_ecoStat: TFCEdgPlayerFactionStatus;
      P_viabThrEco: integer;
      {.social status}
      P_socStat: TFCEdgPlayerFactionStatus;
      P_viabThrSoc: integer;
      {.military status}
      P_milStat: TFCEdgPlayerFactionStatus;
      P_viabThrSpMil: integer;
      {.3d view focus location - star system token id}
      P_starSysLoc: string[20];
      {.3d view focus location - star token id}
      P_starLoc: string[20];
      {.3d view focus location - orbital object token id}
      P_oObjLoc: string[20];
      {.3d view focus location - satellite token id}
      P_satLoc: string[20];
      {.timer tick, 1 = 1sec RT}
      P_timeTick: integer;
      {.current game time - minutes}
      P_timeMin: integer;
      {.current game time - hour}
      P_timeHr: integer;
      {.current game time - day}
      P_timeday: integer;
      {.current game time - month}
      P_timeMth: integer;
      {.current game time - year}
      P_timeYr: integer;
      {.time phases}
      P_timePhse: TFCEtimePhases;
      {surveyed resources}
      P_surveyedSpots: array of record
         SS_oobjToken: string[20];
         SS_ssysIndex: integer;
         SS_starIndex: integer;
         SS_oobjIndex: integer;
         SS_satIndex: integer;
         SS_surveyedRegions: array of record
            SR_ResourceSpot: array of record
               RS_MQC: extended;
               RS_SpotSizeCur: integer;
               RS_SpotSizeMax: integer;
               case RS_type: TFCEduResourceSpotTypes of
                  rstIcyOreField: ();

                  rstOreField: (
                     RS_oreCarbonaceous: integer;
                     RS_oreMetallic: integer;
                     RS_oreRare: integer;
                     RS_oreUranium: integer;
                     );
            end;
         end;
      end;
   end;
   
   type TFCRdgSPUdocked = record
      {.unique token id of the docked space unit}
      SUD_dckdToken: string[20];
   end;
   {.owned space units (space unit and infrastructures) for factions and player}
   {:DEV NOTES: UPDATE DBFACTION DOTATION LIST LOAD AND/OR NEW GAME SETUP.}
   {:DEV NOTES: UPDATE FCMdFiles_Game_Load + FCMdFiles_Game_Save}
   type TFCRdgSPUowned = record
      {space unit unique db token id}
      SUO_spUnToken: string[20];
      {space unit proper name, only have display purposes}
      SUO_nameToken: string[20];
      {linked design db token id}
      SUO_designId: string[20];
      {unit location - star system token id}
      SUO_starSysLoc: string[20];
      {unit location - star token id}
      SUO_starLoc: string[20];
      {unit location - orbital object}
      SUO_oobjLoc: string[20];
      {unit location - satellite}
      SUO_satLoc: string[20];
      {linked 3d object index}
      SUO_3dObjIdx: integer;
      {unit location in local star view - x axis}
      SUO_locStarX: extended;
      {unit location in local star view - z axis}
      SUO_locStarZ: extended;
      {assigned task index, 0= none}
      SUO_taskIdx: integer;
      {space unit attitude status}
      SUO_status: TFCEspUnStatus;
      {.docked space units}
      SUO_dockedSU: array of TFCRdgSPUdocked;
      {current velocity (deltaV) in km/s}
      SUO_deltaV: extended;
      {current velocity (deltaV) in km/s}
      SUO_3dmove: extended;
      {available volume of reaction mass}
      SUO_availRMass: extended;
   end;
   {.faction's entity data structure}
   {:DEV NOTES: entity [0] is always the player's faction entity.}
   {:DEV NOTES: update FCMdG_Entities_Clear / FCMdF_Game_Load / FCMdF_Game_Save / FCMgNG_Core_Proceed.}
   {:DEV NOTES: if centralized SPMi mod ad/rem/update and/or bureaucracy/corruption: update FCMgSPM_SPMI_Set.}
   type TFCRdgEntity= record
      {.corresponding faction's token}
      E_token: string[20];
      {.faction level}
      E_facLvl: integer;
      E_bureau: integer;
      E_corrupt: integer;
      {.higher hq level present in the faction}
      E_hqHigherLvl: TFCEdgHeadQuarterStatus;
      E_uc: extended;
      {.owned space units sub data structure}
      E_spU: array of TFCRdgSPUowned;
      {.owned colonies}
      E_col: array of TFCRdgColony;
      {.SPM settings}
      E_spm: array of TFCRdgFactSPMset;
      {.centralized modifiers of all SPMi currently set}
      E_spmMcohes: integer;
      E_spmMtens: integer;
      E_spmMsec: integer;
      E_spmMedu: integer;
      E_spmMnat: integer;
      E_spmMhealth: integer;
      E_spmMBur: integer;
      E_spmMCorr: integer;
   end;
      TFCentities= array [0..FCCdiFactionsMax] of TFCRdgEntity;
   {.task item data structure}
   {DEV NOTE: for TFCGtasklistToProc don't forget to update farc_game_missioncore /FCMgMCore_Mission_Commit.}
   {DEV NOTE: for TFCGtasklistInProc don't forget to update farc_game_gameflow /FCMgTFlow_GameTimer_Process + FCMgGFlow_Tasks_Process.}
   {DEV NOTE: don't forget to update farc_data_files / FCMdFiles_Game_Save/Load.}
   type TFCRdgTask = record
      {indicate that the task is in processing }
      {:DEV NOTES: TO DEL.}
      TITP_enabled: boolean;
      {type of action}
      TITP_actionTp: TFCEtaskActionTp;
      {current phase}
      TITP_phaseTp: TFCEtaskPhase;
      {controlled target type}
      TITP_ctldType: TFCEtaskTargetTp;
      {controlled target's faction number, 0=player}
      TITP_ctldFac: integer;
      {controlled target's index in subdata structure}
      TITP_ctldIdx: integer;
      {.timer tick at start of the mission}
      {:DEV NOTES: taskinprocONLY.}
      TITP_timeOrg: integer;
      {task duration in ticks, 0= infinite}
      TITP_duration: integer;
      {interval, in clock tick, between 2 running processes in same thread}
      TITP_interval: integer;
      {kind of origin}
      TITP_orgType: TFCEtaskTargetTp;
      {origin index (OBJECT)}
      TITP_orgIdx: integer;
      {kind of destination}
      TITP_destType: TFCEtaskTargetTp;
      {destination index (OBJECT)}
      TITP_destIdx: integer;
      {.targeted region #}
      TITP_regIdx: integer;
      {cruise velocity to reach , if 0 then =current deltav}
      TITP_velCruise: extended;
      {acceleration time in ticks}
      TITP_timeToCruise: integer;
      {.time in tick for deceleration}
      {:DEV NOTES: taskinprocONLY.}
      TITP_timeDecel: integer;
      {.time to transfert}
      {:DEV NOTES: taskinprocONLY.}
      TITP_time2xfert: integer;
      {.time to transfert to decel}
      {:DEV NOTES: taskinprocONLY.}
      TITP_time2xfert2decel: integer;
      {final velocity, if 0 then = cruise vel}
      TITP_velFinal: extended;
      {deceleration time in ticks}
      TITP_timeToFinal: integer;
      {.acceleration by tick for the current mission}
      {:DEV NOTES: taskinprocONLY.}
      TITP_accelbyTick: extended;
      {used reaction mass volume for the complete task}
      TITP_usedRMassV: extended;
      {.data string 1 for needed data transferts}
      TITP_str1: string;
      {.data string 2 for needed data transferts}
      TITP_str2: string;
      {.data integer 1 for needed data transferts}
      TITP_int1: integer;
   end; //==END== type TFCRtaskItem = record ==//
      {.tasklist to process dynamic array}
      TFCGtasklistToProc = array of TFCRdgTask;
      {.current tasklit dynamic array}
      TFCGtasklistInProc = array of TFCRdgTask;
   {.owned space unit docked unit}
   ///<summary>
   ///   clear the entities data
   ///</summary>
   procedure FCMdG_Entities_Clear;
   //=======================================================================================
   {.global variables}
   //=======================================================================================
   var
      FCDBfactions: TFCDBfactions;
      FCDBdgSPMi: TFCDBdgSPMi;
      FCentities: TFCentities;
      {.CSM test list}
      FCGcsmPhList: TFCcsmPhaseL;
      {.game timer phase dump}
      FCGtimePhase: TFCEtimePhases =tphNull;
      {.tasklist in process}
      FCGtskListInProc: TFCGtasklistInProc;
      {.tasklist to process}
      FCGtskLstToProc: TFCGtaskListToProc;
      FCRplayer: TFCRdgPlayer;
   //=======================================================================================
   {.constants}
   //=======================================================================================
   const
      FCCwkTick=1008;



implementation

//uses

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMdG_Entities_Clear;
{:Purpose: clear the entities data.
    Additions:
      -2010Nov08- *add: forgot to add bureaucracy, corruption and the SPM modifiers.
                  *add: UC.
      -2010Sep20- *add: SPM settings.
}
var
   ECcnt: integer;
begin
   ECcnt:=0;
   while ECcnt<=FCCdiFactionsMax do
   begin
      FCentities[ECcnt].E_token:='';
      FCentities[ECcnt].E_facLvl:=0;
      FCentities[ECcnt].E_bureau:=0;
      FCentities[ECcnt].E_corrupt:=0;
      FCentities[ECcnt].E_hqHigherLvl:=hqsNoHQPresent;
      FCentities[ECcnt].E_uc:=0;
      SetLength(FCentities[ECcnt].E_spU, 0);
      SetLength(FCentities[ECcnt].E_col, 0);
      SetLength(FCentities[ECcnt].E_spm, 0);
      FCentities[ECcnt].E_spmMcohes:=0;
      FCentities[ECcnt].E_spmMtens:=0;
      FCentities[ECcnt].E_spmMsec:=0;
      FCentities[ECcnt].E_spmMedu:=0;
      FCentities[ECcnt].E_spmMnat:=0;
      FCentities[ECcnt].E_spmMhealth:=0;
      FCentities[ECcnt].E_spmMBur:=0;
      FCentities[ECcnt].E_spmMCorr:=0;
      inc(ECcnt);
   end;
end;

end.
