{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: general game system related datastructures

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

unit farc_data_game;

interface

   uses
      farc_data_infrprod
      ,farc_data_univ;

   const
      {:DEV NOTES: update FCMuiWin_MsgeBox_AddMsg/ FCMuiWin_MsgeBox_AddMsg.}
      FCCfacMax=1;
      FCCmatrixItems=20;

   //=======================================================================================
   {.game system datastructures}
   //=======================================================================================

   {.meme belief levels}
   {:DEV NOTES: update factionsdb.xml + FCMdF_DBFactions_Read + FCFgSPM_Meme_GetSVRange.}
   type TFCEdgBelLvl=(
      dgUnknown
      ,dgFleeting
      ,dgUncommon
      ,dgCommon
      ,dgStrong
      ,dgKbyAll
      );

   {.colony levels}
   type TFCEcolLvl=(
      cl1Outpost
      ,cl2Base
      {.community}
      ,cl3Comm
      ,cl4Settl
      ,cl5MajCol
      {.local state}
      ,cl6LocSt
      {.regional state}
      ,cl7RegSt
      {.federated states}
      ,cl8FedSt
      {.continental state}
      ,cl9ContSt
      ,cl10UniWrld
      );
   {.viability objectives types}
   {:DEV NOTE: update factionsdb.xml + FCMdFiles_DBFactions_Read + FCMdFiles_Game_Save/Load}
   {:DEV NOTE: update FCM_ViabObj_Init + FCF_ViabObj_Use + FCM_ViabObj_Calc + FCF_ViabObj_GetIdx.}
   type TFCEcpsObjTp=(
      {.energy efficient}
      cpsotEcoEnEff
      {.low credit line use}
      ,cpsotEcoLowCr
      {.sustainable colony}
      ,cpsotEcoSustCol
      {.secure population}
      ,cpsotSocSecPop
      );
   {.credit and interest range}
   type TFCEcrIntRg=(
      crirPoor_Insign
      ,crirUndFun_Low
      ,crirBelAvg_Mod
      ,crirAverage
      ,crirAbAvg_Maj
      ,crirRch_High
      ,crirOvrFun_Usu
      ,crirUnl_Ins
      );
   {.SPMi custom effects}
   {:DEV: update TFCRdgCustomEffect}
   type TFCEdgCustomFX=(
      cfxEIOUT
      ,cfxREVTX
      );
   {.colony event type list}
   {:DEV NOTES: update FCFgCSME_Event_GetStr. WARNING: deprecate any previous save game files if an event is INSERTED}
   {:DEV NOTES: update also FCMgCSME_Event_Cancel if a recovering status is added and for the override mode.}
   {:DEV NOTES: update also FCMgCSME_OT_Proc for over time processing + FCMgCSME_Event_Trigger.}
   type TFCEevTp=(
      {.colony established}
      etColEstab
      {.unrest}
      ,etUnrest
      {.unrest - recovering}
      ,etUnrestRec
      {.social disorder}
      ,etSocdis
      {.social disorder - recovering}
      ,etSocdisRec
      {.uprising}
      ,etUprising
      {.uprising - recovering}
      ,etUprisingRec
      {.dissident colony}
      ,etColDissident
      {.health-education relation}
      ,etHealthEduRel
      {.government destabilization}
      ,etGovDestab
      {.government destabilization - recovering}
      ,etGovDestabRec
      );
   {.list of faction equipment item types}
   {:DEV NOTES: update factionsdbxml + FCMdF_DBFactions_Read + FCMgNG_Core_Proceed}
   type TFCEdgFactionEquipItemType=(
      {.product equipment item}
      feitProduct
      {.spacecraft equipment item}
      ,feitSpaceUnit
      );
   {.player's faction status}
   {:DEV NOTES: update FCFgSPMD_Level_GetToken.}
   type TFCEfacStat=(
      fs0NViable
      ,fs1StabFDep
      ,fs2DepVar
      ,fs3Indep
      );
   {.hq status list}
   {:DEV NOTES: update ui.xml + game_colony/FCFgC_HQ_GetStr.}
   type TFCEdgHQstatus=(
      {.no HQ present}
      dgNoHQ
      {.basic HQ, as for Colonization Shelter, present}
      ,dgBasicHQ
      {.secondary HQ present}
      ,dgSecHQ
      {.primary/unique HQ present}
      ,dgPriUnHQ
      );
   {.owned infrastructure status list}
   {:DEV NOTES: update FCMdF_Game_Save/FCMdF_Game_Load + FCFgInf_Status_GetToken + FCMuiCDP_Data_Update / dtInfra.}
   type TFCEdgInfStatTp=(
      {.in kit}
      istInKit
      {.in conversion, for LV space unit}
      ,istInConversion
      {.assembling, for construction kits infra}
      ,istInAssembling
      {.in building site, for standard infra}
      ,istInBldSite
      {.disabled, the infrastructure is ok but disabled by the player or events}
      ,istDisabled
      {.disabled by the energy equilibrium rule}
      ,istDisabledByEE
      {.in transition to operational state}
      ,istInTransition
      ,istOperational
      ,istDestroyed
      );
   {.settlement types}
   {:DEV NOTES: update FCMdF_Game_Save/FCMdF_Game_Load + FCMuiWin_UI_Upd w/FCWMS_Grp_MCG_SetType + FCFgICS_InfraLevel_Setup.}
   type TFCEdgSettleType=(
      stSurface
      ,stSpaceSurf
      ,stSubterranean
      ,stSpaceBased
      );
   {.SPM areas list}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCEdgSPMarea=(
      {.Administration (or ADMIN)}
      dgADMIN
      {.Economy (ECON)}
      ,dgECON
      {.Medical Care (MEDCA)}
      ,dgMEDCA
      {.Society (SOC)}
      ,dgSOC
      {.Space Politics (SPOL)}
      ,dgSPOL
      {.Spirituality (SPI)}
      ,dgSPI
      );
   {.SPM HQ structures}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCEdgSPMhqStr=(
      {.centralized}
      dgCentral
      {.clustered}
      ,dgClust
      {.corporative}
      ,dgCorpo
      {.federative}
      ,dgFed
      );
   {.SPMi requirements}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCEdgSPMiReq=(
      dgBuilding
      ,dgFacData
      ,dgTechSci
      ,dgUC
      );
   {.SPMi requirement types for faction data requirement}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCEdgSPMiReqFDat=(
      rfdFacLv1
      ,rfdFacLv2
      ,rfdFacLv3
      ,rfdFacLv4
      ,rfdFacLv5
      ,rfdFacLv6
      ,rfdFacLv7
      ,rfdFacLv8
      ,rfdFacLv9
      ,rfdFacStab
      ,rfdInstrLv
      ,rfdLifeQ
      ,rfdEquil
      );
   {.SPMi requirement types for UC requirement}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCEdgSPMiReqUC=(
      {.fixed value}
      dgFixed
      ,dgFixed_yr
      {.calculation - population}
      ,dgCalcPop
      ,dgCalcPop_yr
      {.calculation - colonies}
      ,dgCalcCol
      ,dgCalcCol_yr
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
   {:DEV NOTE: DON'T FORGET TO UPDATE FCMdFiles_Game_Load + FCMdFiles_Game_Save + FCMuiW_ColPan_Upd}
   {:DEV NOTES: UPDATE FCMgCSME_Event_Trigger + FCMgCSME_Event_Cancel + FCFgCSME_Mod_Sum + TFCEcsmeModTp.}
   type TFCRdgColonCSMev = record
      CSMEV_token: TFCEevTp;
      {.define if the event is resident or (=false =>) occasional (w/ a duration of 24hrs}
      CSMEV_isRes: boolean;
      {.duration in # of full weeks (or # of CSM phases)}
      CSMEV_duration: integer;
      {.optional level data - this data is never displayed to the player}
      CSMEV_lvl: integer;
      {.modifiers list}
      {:DEV NOTES: update TFCEcsmeModTp.}
      CSMEV_cohMod: integer;
      CSMEV_tensMod: integer;
      CSMEV_secMod: integer;
      CSMEV_eduMod: integer;
      CSMEV_iecoMod: integer;
      CSMEV_healMod: integer;
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
      CI_status: TFCEdgInfStatTp;
      {.CAB duration and worked}
      CI_cabDuration: integer;
      CI_cabWorked: integer;
      {.consumed power = infrastructure's base power + enabled production modes}
      CI_powerCons: double;
      {.function and dependent data}
      case CI_function: TFCEdipFunction of
         fEnergy:
            {.energy output by hour in kW}
            (CI_fEnergOut: double);

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
            /// linked resource spot indexes, if needed
            ///</summary>
            CI_fprodSurveyedSpot: integer;
            CI_fprodSurveyedRegion: integer;
            CI_fprodResourceSpot: integer;
            CI_fprodMode: array [0..FCCpModeMax] of record
               PM_type: TFCEdipProductionModes;
               PM_energyCons: double;
               ///<summary>
               /// linked matrix items indexes
               ///</summary>
               PF_linkedMatrixItemIndexes: array [0..FCCmatrixItems] of record
                  LMII_matrixItmIndex: integer;
                  LMII_matrixProdModeIndex: integer;
               end;
            end;
            );
   end;
   {.production matrix item}
   {:DEV NOTES: update FCMdFiles_Game_Load + FCMdFiles_Game_Save + FCMgCSM_ColonyData_Init.}
   type TFCRdgColonProdMatrixItm= record
      CPMI_productToken: string[20];
      CPMI_storageIndex: integer;
      CPMI_globalProdFlow: double;
      CPMI_productionModes: array of record
         PF_locSettlement: integer;
         PF_locInfra: integer;
         PF_locProdModeIndex: integer;
         PF_isDisabledManually: boolean;
         PF_isDisabledByProdSegment: boolean;
         ///<summary>
         /// production flow in + or - and in unit/hr. if -: used as source
         ///</summary>
         PF_productionFlow: double;
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
      POP_meanA: double;
      {.death rate}
      POP_dRate: double;
      {.death stack}
      POP_dStack: double;
      {.birth rate}
      POP_bRate: double;
      {.birth stack}
      POP_bStack: double;
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
      POP_wcpTotal: double;
      POP_wcpAssignedPeople: integer;
   end;
   {.colony's product item}
   type TFCRdgColonProduct=record
      CPR_token: string[20];
      CPR_unit: double;
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
      COL_level: TFCEcolLvl;
      {.HQ presence}
      COL_hqPres: TFCEdgHQstatus;
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
      COL_csmHOspl: double;
      {.csm housing - qol}
      COL_csmHOqol: integer;
      {.csm health - heal}
      COL_csmHEheal: integer;
      {.csm energy - consumption}
      COL_csmENcons: double;
      {.csm energy - generation}
      COL_csmENgen: double;
      {.csm energy - storage}
      COL_csmENstorCurr: double;
      COL_csmENstorMax: double;
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
      COL_storCapacitySolidCurr: double;
      COL_storCapacitySolidMax: double;
      COL_storCapacityLiquidCurr: double;
      COL_storCapacityLiquidMax: double;
      COL_storCapacityGasCurr: double;
      COL_storCapacityGasMax: double;
      COL_storCapacityBioCurr: double;
      COL_storCapacityBioMax: double;
      {.storage list, in units}
		COL_storageList: array of TFCRdgColonProduct;
		{.reserves}
		COL_reserveFoodCur: integer;
		COL_reserveFoodMax: integer;
		COL_reserveOxygenCur: integer;
		COL_reserveOxygenMax: integer;
		COL_reserveWaterCur: integer;
		COL_reserveWaterMax: integer;
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
      CSMT_col: array[0..FCCfacMax] of array of integer;
   end;
   TFCcsmPhaseL = array of TFCRdgCSMtest;
   {.SPMi influences sub-data structure}
   type TFCRdgSPMiInfl= record
      {.token of the SPMi}
      SPMII_token: string[20];
      {.influence factor}
      SPMII_influence: integer;
   end;
   {equipment list item datastructure}
   {:DEV NOTE: update FCMdFiles_DBFactions_Read + FCMgNG_ColMode_Upd.}
   type TFCRdgFactCMEquipItm = record
      {type of dotation item}
      case FCMEI_itemType: TFCEdgFactionEquipItemType of
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
               FCMEI_spuStatus: string[20];
               {.dock info -1: not docked/mother vessel, 1: mother vessel (all subsequent w/ 0 are docked to this one), 0: docked vessel}
               FCMEI_spuDockInfo: integer;
               {.current available energy/reaction mass volume}
               FCMEI_spuAvailEnRM: double
               );
   end;
   {.faction's viability objectives}
   type TFCRdgFactCMViabObj = record
      FVO_objTp: TFCEcpsObjTp;
   end;
   {.colonization mode data structure}
   {:DEV NOTE: update FCMdFiles_DBFactions_Read.}
   type TFCRdgFactColMode = record
      {.token}
      FCM_token: string[20];
      {.CPS data - starting econ status}
      FCM_cpsEconS: TFCEfacStat;
      {.CPS data - starting soc status}
      FCM_cpsSocS: TFCEfacStat;
      {.CPS data - starting mil status}
      FCM_cpsMilS: TFCEfacStat;
      {.CPS data - max econ status}
      FCM_cpsEconM: TFCEfacStat;
      {.CPS data - max soc status}
      FCM_cpsSocM: TFCEfacStat;
      {.CPS data - max mil status}
      FCM_cpsMilM: TFCEfacStat;
      {.CPS data - credit range}
      FCM_cpsCrRg: TFCEcrIntRg;
      {.CPS data - interest range}
      FCM_cpsIntRg: TFCEcrIntRg;
      {.CPS data - viability objectives}
      FCM_cpsViabObj: array of TFCRdgFactCMViabObj;
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
            (SPMS_bLvl: TFCEdgBelLvl;
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
      TFCDBfactions = array [0..FCCfacMax] of TFCRdgFaction;
   {.player's data structure}
   {DEV NOTE: UPDATE NEW GAME SETUP + FCMdFSG_Game_Save + FCMdFSG_Game_Load}
   type TFCRdgPlayer = record
      {.game name, used for save game name}
      P_gameName: string;
      {.token id of faction the player belongs to, if fullInd then = 'null'}
      P_facAlleg: string[20];
      {.economic status}
      P_ecoStat: TFCEfacStat;
      {.social status}
      P_socStat: TFCEfacStat;
      {.military status}
      P_milStat: TFCEfacStat;
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
               RS_MQC: double;
               RS_SpotSizeCur: integer;
               RS_SpotSizeMax: integer;
               case RS_type: TFCEduRsrcSpotType of
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
   {.SPMi requirements sub-data structure}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCRdgSPMiReq= record
      case SPMIR_type: TFCEdgSPMiReq of
         {.building requirement}
         dgBuilding:
            {.infrastructure token}
            (SPMIR_infToken: string[20];
            {.percent of colonies which have one}
            SPMIR_percCol: integer);
         {.faction data requirement}
         dgFacData:
            (SPMIR_datTp: TFCEdgSPMiReqFDat;
            SPMIR_datValue: integer);
         {.technoscience requirement}
         dgTechSci:
            {.technoscience token}
            (SPMIR_tsToken: string[20];
            {.mastered level}
            SPMIR_masterLvl: integer);
         {.UC requirement}
         dgUC:
            {.technoscience token}
            (SPMIR_ucMethod: TFCEdgSPMiReqUC;
            {.mastered level}
            SPMIR_ucVal: double);
   end;
   {.SPMi custom effects data structure}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read + FCMgSPMCFX_Core_Setup and related subroutines}
   type TFCRdgCustomEffect= record
      case CFX_code: TFCEdgCustomFX of
         cfxEIOUT: (
            CFX_eioutMod: integer;
            CFX_eioutIsBurMod: boolean
            );
         cfxREVTX: (CFX_revtxCoef: double);
   end;
   {.SPM items}
   {:DEV NOTES: update FCMdF_DBSPMi_Read.}
   type TFCRdgSPMi= record
      {.unique token}
      SPMI_token: string[20];
      {.area in which the item is linked to}
      SPMI_area: TFCEdgSPMarea;
      {.true= unique: only one of this kind can be set in the area}
      SPMI_isUnique2set: boolean;
      {.requirements}
      SPMI_req: array of TFCRdgSPMiReq;
      {.influences}
      SPMI_infl: array of TFCRdgSPMiInfl;
      {.mod-cohesion}
      SPMI_modCohes: integer;
      {.mod-tension}
      SPMI_modTens: integer;
      {.mod-security}
      SPMI_modSec: integer;
      {.mod-education}
      SPMI_modEdu: integer;
      {.mod-natality}
      SPMI_modNat: integer;
      {.mod-health}
      SPMI_modHeal: integer;
      {.mod-bureaucracy}
      SPMI_modBur: integer;
      {.mod-corruption}
      SPMI_modCorr: integer;
      {.custom effects}
      SPMI_customFxList: array of TFCRdgCustomEffect;
      {.policy sub datastructure}
      case SPMI_isPolicy: boolean of
         true:
            {.HQ structure}
            (SPMI_hqStruc: TFCEdgSPMhqStr;
            SPMI_hqRTM: integer);
   end;
      {.SPMi dynamic array}
      TFCDBdgSPMi = array of TFCRdgSPMi;
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
      SUO_locStarX: double;
      {unit location in local star view - z axis}
      SUO_locStarZ: double;
      {assigned task index, 0= none}
      SUO_taskIdx: integer;
      {space unit attitude status}
      SUO_status: TFCEspUnStatus;
      {.docked space units}
      SUO_dockedSU: array of TFCRdgSPUdocked;
      {current velocity (deltaV) in km/s}
      SUO_deltaV: double;
      {current velocity (deltaV) in km/s}
      SUO_3dmove: double;
      {available volume of reaction mass}
      SUO_availRMass: double;
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
      E_hqHigherLvl: TFCEdgHQstatus;
      E_uc: double;
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
      TFCentities= array [0..FCCfacMax] of TFCRdgEntity;
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
      TITP_velCruise: double;
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
      TITP_velFinal: double;
      {deceleration time in ticks}
      TITP_timeToFinal: integer;
      {.acceleration by tick for the current mission}
      {:DEV NOTES: taskinprocONLY.}
      TITP_accelbyTick: double;
      {used reaction mass volume for the complete task}
      TITP_usedRMassV: double;
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

//=============================================END OF INIT==================================

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
   while ECcnt<=FCCfacMax do
   begin
      FCentities[ECcnt].E_token:='';
      FCentities[ECcnt].E_facLvl:=0;
      FCentities[ECcnt].E_bureau:=0;
      FCentities[ECcnt].E_corrupt:=0;
      FCentities[ECcnt].E_hqHigherLvl:=dgNoHQ;
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
