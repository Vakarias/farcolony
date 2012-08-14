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
   ,farc_game_cpsobjectives
   ,farc_game_gameflow;

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

{:REFERENCES LIST
   - FCFgICS_InfraLevel_Setup
   - FCMdF_Game_Load
   - FCMdF_Game_Save
   - FCMuiWin_UI_Upd w/FCWMS_Grp_MCG_SetType
}
///<summary>
///   settlement types
///</summary>
type TFCEdgSettlements=(
   sSurface
   ,sSpaceSurface
   ,sSubterranean
   ,sSpaceBased
   );

{:REFERENCES LIST
   - factionsdb.xml
   - FCFspuF_AttStatus_Get
   - TFCRfacDotationItem w/ status comment
}
///<summary>
///   space unit attitude status
///</summary>
type TFCEdgSpaceUnitStatus=(
   susInFreeSpace
   ,susInOrbit
   ,susInAtmosphericFlightLandingTakeoff
   ,susLanded
   ,susDocked
   ,susOutOfControl
   ,susDeadWreck
   );

//==END PUBLIC ENUM=========================================================================

{:REFERENCES LIST
   - FCMdFiles_Game_Load
   - FCMdFiles_Game_Save
   - FCMgCSME_Event_Cancel
   - FCMgCSME_Event_Trigger
   - FCFgCSME_Mod_Sum
   - FCMgCSME_OT_Proc
   - FCMgCSME_Recovering_Process
   - FCMuiCDP_Data_Update
   - farc_game_csmevents/TFCEcsmeModTp
   - FCMuiCDP_Data_Update/dtCSMev if any modifier is modified / added
}
///<summary>
///   colony's event
///</summary>
type TFCRdgColonyCSMEvent = record
   ///<summary>
   ///   define if the event is resident or (=false =>) occasional (w/ a duration of 24hrs}
   ///</summary>
   CCSME_isResident: boolean;
   CCSME_durationWeeks: integer;
   CCSME_level: integer;
   case CCSME_type: TFCEdgColonyEvents of
      ceColonyEstablished:(
         CCSME_tCEstTensionMod: integer;
         CCSME_tCEstSecurityMod: integer
         );

      ceUnrest, ceUnrest_Recovering:(
         CCSME_tCUnEconomicIndustrialOutputMod: integer;
         CCSME_tCUnTensionMod: integer
         );

      ceSocialDisorder, ceSocialDisorder_Recovering:(
         CCSME_tSDisEconomicIndustrialOutputMod: integer;
         CCSME_tSDisTensionMod: integer
         );

      {:DEV NOTES: add rebels and fighting results.}
      ceUprising, ceUprising_Recovering:(
         CCSME_tUpEconomicIndustrialOutputMod: integer;
         CCSME_tUpTensionMod: integer
         );

      ceDissidentColony:();

      ceHealthEducationRelation:( CCSME_tHERelEducationMod: integer );

      ceGovernmentDestabilization, ceGovernmentDestabilization_Recovering:( CCSME_tGDestCohesionMod: integer );

      ceOxygenProductionOverload:( CCSME_tOPOvPercentPopulationNotSupported: integer );

      ceOxygenShortage, ceOxygenShortage_Recovering:(
         ///<summary>
         /// percent of population not supported at time of SF calculation
         ///</summary>
         CCSME_tOShPercentPopulationNotSupportedAtCalculation: integer;
         CCSME_tOShEconomicIndustrialOutputMod: integer;
         CCSME_tOShTensionMod: integer;
         CCSME_tOShHealthMod: integer
         );

      ceWaterProductionOverload:( CCSME_tWPOvPercentPopulationNotSupported: integer );

      ceWaterShortage, ceWaterShortage_Recovering:(
         ///<summary>
         /// percent of population not supported at time of SF calculation
         ///</summary>
         CCSME_tWShPercentPopulationNotSupportedAtCalculation: integer;
         CCSME_tWShEconomicIndustrialOutputMod: integer;
         CCSME_tWShTensionMod: integer;
         CCSME_tWShHealthMod: integer
         );

      ceFoodProductionOverload:( CCSME_tFPOvPercentPopulationNotSupported: integer );

      ceFoodShortage, ceFoodShortage_Recovering:(
         ///<summary>
         /// percent of population not supported at time of SF calculation
         ///</summary>
         CCSME_tFShPercentPopulationNotSupportedAtCalculation: integer;
         CCSME_tFShEconomicIndustrialOutputMod: integer;
         CCSME_tFShTensionMod: integer;
         CCSME_tFShHealthMod: integer;
         CCSME_tFShDirectDeathPeriod: integer;
         CCSME_tFShDeathFractionalValue: extended
         );
      //==END== case CSMEV_token: TFCEdgEventTypes of ==//
end;

{:REFERENCES LIST
   - FCMdFiles_Game_Load
   - FCMdFiles_Game_Save
   - FCMgCSM_ColonyData_Init
   - FCMgCSM_ColonyData_Upd
   - FCMgCSM_Pop_Xfert
   - TFCEdiPopType
   - TFCEgcsmPopTp
   - FCFgIS_RequiredStaff_Test
   - FCMgPGS_BR_Calc, excepted for Rebels and Militia
   - FCMgPGS_DR_Calc
}
///<summary>
///   colony's population
///</summary>
type TFCRdgColonyPopulation= record
   CP_total: int64;
   CP_meanAge: extended;
   CP_deathRate: extended;
   CP_deathStack: extended;
   CP_birthRate: extended;
   CP_birthStack: extended;
   CP_classColonist: int64;
   CP_classColonistAssigned: int64;
   CP_classAerOfficer: integer;
   CP_classAerOfficerAssigned: integer;
   CP_classAerMissionSpecialist: integer;
   CP_classAerMissionSpecialistAssigned: integer;
   CP_classBioBiologist: integer;
   CP_classBioBiologistAssigned: integer;
   CP_classBioDoctor: integer;
   CP_classBioDoctorAssigned: integer;
   CP_classIndTechnician: integer;
   CP_classIndTechnicianAssigned: integer;
   CP_classIndEngineer: integer;
   CP_classIndEngineerAssigned: integer;
   CP_classMilSoldier: integer;
   CP_classMilSoldierAssigned: integer;
   CP_classMilCommando: integer;
   CP_classMilCommandoAssigned: integer;
   CP_classPhyPhysicist: integer;
   CP_classPhyPhysicistAssigned: integer;
   CP_classPhyAstrophysicist: integer;
   CP_classPhyAstrophysicistAssigned: integer;
   CP_classEcoEcologist: integer;
   CP_classEcoEcologistAssigned: integer;
   CP_classEcoEcoformer: integer;
   CP_classEcoEcoformerAssigned: integer;
   CP_classAdmMedian: integer;
   CP_classAdmMedianAssigned: integer;
   CP_classRebels: integer;
   CP_classMilitia: integer;
   CP_CWPtotal: extended;
   CP_CWPassignedPeople: integer;
end;

{:REFERENCES LIST
   - FCFgC_Colony_Core
   - FCMdFiles_Game_Load
   - FCMdFiles_Game_Save
   - FCMgCSM_ColonyData_Init
   - FCMgCSM_ColonyData_Upd
   - FCMgICS_Assembling_Process
   - FCMgICS_Building_Process
   - FCMgICS_Conversion_Process
   - FCMgIF_Functions_ApplicationRemove
   - FCMgIF_Functions_Initialize
   - FCMgIP_CSMEnergy_Update
   - FCMgPS2_ProductionMatrixItem_Add
   - FCMuiCDP_Data_Update/dtInfra
   - for colony data + csm data, upd TFCEuiwColData
}
///<summary>
///   colony
///</summary>
type TFCRdgColony = record
   C_name: string[20];
   C_foundationDateYear: integer;
   C_foundationDateMonth: integer;
   C_foundationDateDay: integer;
   C_nextCSMsessionInTick: integer;
   C_locationStarSystem: string[20];
   C_locationStar: string[20];
   C_locationOrbitalObject: string[20];
   C_locationSatellite: string[20];
   C_level: TFCEdgColonyLevels;
   C_hqPresence: TFCEdgHeadQuarterStatus;
   C_cohesion: integer;
   C_security: integer;
   C_tension: integer;
   C_instruction: integer;
   C_csmHousing_PopulationCapacity: int64;
   C_csmHousing_SpaceLevel: extended;
   C_csmHousing_QualityOfLife: integer;
   C_csmHealth_healthLevel: integer;
   C_csmEnergy_consumption: extended;
   C_csmEnergy_generation: extended;
   C_csmEnergy_StorageCurrent: extended;
   C_csmEnergy_StorageMax: extended;
   C_economicIndustrialOutput: integer;
   C_population: TFCRdgColonyPopulation;
   C_events: array of TFCRdgColonyCSMEvent;
   C_settlements: array of record
      S_name: string[20];
      S_settlement: TFCEdgSettlements;
      S_level: integer;
      S_locationRegion: integer;
      S_infrastructures: array of record
         I_token: string[20];
         I_level: integer;
         I_status: TFCEdgInfrastructureStatus;
         I_cabDuration: integer;
         I_cabWorked: integer;
         I_powerConsumption: extended;
         ///<summary>
         /// power generated by the custom effect Power Generation, if the infrastructure have any and is enabled
         ///</summary>
         I_powerGeneratedFromCustomEffect: extended;
         case I_function: TFCEdipFunctions of
            fEnergy:( I_fEnOutput: extended );
               {:DEV NOTES: add energy fuel current status.}

            fHousing:(
               I_fHousPopulationCapacity: integer;
               I_fHousQualityOfLife: integer;
               I_fHousCalculatedVolume: integer;
               I_fHousCalculatedSurface: integer
               );

            fProduction:(
               ///<summary>
               /// linked surveyed spot index, if needed
               ///</summary>
               I_fProdSurveyedSpot: integer;
               ///<summary>
               /// linked surveyed region index, if needed
               ///</summary>
               I_fProdSurveyedRegion: integer;
               ///<summary>
               /// linked surveyed resource spot index, in the surveyed region, if needed
               ///</summary>
               I_fProdResourceSpot: integer;
               I_fProdProductionMode: array [0..FCCdipProductionModesMax] of record
                  PM_type: TFCEdipProductionModes;
                  ///<summary>
                  /// switch when the related production mode is disabled or not by the game or the player
                  ///</summary>
                  PM_isDisabled: boolean;
                  PM_energyConsumption: extended;
                  PM_matrixItemMax: integer;
                  ///<summary>
                  /// linked matrix items indexes
                  ///</summary>
                  PM_linkedColonyMatrixItems: array [0..FCCdiMatrixItemsMax] of record
                     LMII_matrixItemIndex: integer;
                     LMII_matrixItem_ProductionModeIndex: integer;
                  end; //==END== record: PF_linkedMatrixItemIndexes ==//
               end; //==END== record: I_fProdProductionMode ==//
         );
      end; //==END== record: S_infrastructures ==//
   end; //==END== record: C_settlements ==//
   ///<summary>
   /// CAB queue [x,y] = infrastructure index in settlement
      ///<summary>
      /// x= settlements index
      ///</summary>
      ///<summary>
      /// y= CAB index in settlement
      ///</summary>
   ///</summary>
   C_cabQueue: array of array of integer;
   C_productionMatrix: array of record
      PM_productToken: string[20];
      ///<summary>
      /// index # in the colony's storage which correspond to the product
      ///</summary>
      PM_storageIndex: integer;
      ///<summary>
      /// indicate the storage type used by the product
      ///</summary>
      PM_storage: TFCEdipStorageTypes;
      ///<summary>
      /// global production flow
      ///</summary>
      PM_globalProductionFlow: extended;
      PM_productionModes: array of record
         PM_locationSettlement: integer;
         PM_locationInfrastructure: integer;
         ///<summary>
         /// owned infrastructure's production mode index
         ///</summary>
         PM_locationProductionModeIndex: integer;
         ///<summary>
         /// switch used by the production phase to manage the production matrix
         ///</summary>
         PM_isDisabledByProductionSegment: boolean;
         ///<summary>
         /// production flow in + or - and in unit/hr. if -: used as source
         ///</summary>
         PM_productionFlow: extended;
      end; //==END== record: PM_productionModes ==//
   end; //==END== record: C_productionMatrix ==//
   C_storageCapacitySolidCurrent: extended;
   C_storageCapacitySolidMax: extended;
   C_storageCapacityLiquidCurrent: extended;
   C_storageCapacityLiquidMax: extended;
   C_storageCapacityGasCurrent: extended;
   C_storageCapacityGasMax: extended;
   C_storageCapacityBioCurrent: extended;
   C_storageCapacityBioMax: extended;
   C_storedProducts: array of record
      SP_token: string[20];
      SP_unit: extended;
   end;
   C_reserveOxygen: integer;
   C_reserveFood: integer;
   ///<summary>
   /// store the storage indexes for each food product
   ///</summary>
   C_reserveFoodProductsIndex: array of integer;
   C_reserveWater: integer;
end;

{:REFERENCES LIST
   - FCMdFiles_Game_Load
   - FCMdFiles_Game_Save
   - FCMgTFlow_CSMphase_Proc
}
///<summary>
///   CSM phase schedule
///</summary>
type TFCRdgCSMPhaseSchedule= record
   CSMPS_ProcessAtTick: integer;
   ///<summary>
   /// colonies to test [x,y] = colony index #
      ///<summary>
      /// x= faction index #
      ///</summary>
      ///<summary>
      /// y= test list index # (<>colony index #)
      ///</summary>
   ///</summary>
   CSMPS_colonies: array[0..FCCdiFactionsMax] of array of integer;
end;
   ///<summary>
   ///   CSM phase schedule dynamic array
   ///</summary>
   TFCDdgCSMPhaseSchedule = array of TFCRdgCSMPhaseSchedule;

{:REFERENCES LIST
   - FCMdF_DBFactions_Read
   - FCMdF_Game_Load
   - FCMdF_Game_Save
   - FCMgNG_Core_Proceed
}
///<summary>
///   SPM settings for factions and entities
///</summary>
{:DEV NOTES: put custom effects current set values.}
type TFCRdgSPMSettings= record
   SPMS_token: string[20];
   SPMS_duration: integer;
   SPMS_ucCost: integer;
   case SPMS_isPolicy: boolean of
      true:(
         SPMS_iPtIsSet: boolean;
         SPMS_iPtAcceptanceProbability: integer
         );
      false:(
         SPMS_iPtBeliefLevel: TFCEdgBeliefLevels;
         SPMS_iPtSpreadValue: integer
         );
end;

{:REFERENCES LIST
   - FCMdFiles_DBFactions_Read
   - FCMgNG_ColMode_Upd
   - FCMgNG_Core_Proceed
}
type TFCRdgFaction = record
   F_token: string[20];
   F_level: integer;
   F_colonizationModes: array of record
      CM_token: string[20];
      CM_cpsViabilityThreshold_Economic: integer;
      CM_cpsViabilityThreshold_Social: integer;
      CM_cpsViabilityThreshold_SpaceMilitary: integer;
      CM_cpsCreditRange: TFCEdgCreditInterestRanges;
      CM_cpsInterestRange: TFCEdgCreditInterestRanges;
      CM_cpsViabilityObjectives: array of TFCRcpsoViabilityObjective;
      CM_equipmentList: array of record
         case EL_equipmentItem: TFCEdgFactionEquipItemTypes of
            feitProduct:(
               EL_eiProdToken: string[20];
               EL_eiProdUnit: integer;
               EL_eiProdCarriedBy: integer;
               );

            feitSpaceUnit:(
               EL_eiSUnNameToken: string[20];
               EL_eiSUnDesignToken: string[20];
               EL_eiSUnStatus: TFCEdgSpaceUnitStatus;
               EL_eiSUnDockStatus: ( diNotDocked, diMotherVessel, diDockedVessel );
               EL_eiSUnReactionMass: extended
               );
      end; //==END== record: CM_equipmentList ==//
   end; //==END== record: F_colonizationModes ==//
   F_startingLocations: array of record
      SL_stellarSystem: string[20];
      SL_star: string[20];
      SL_orbitalObject: string[20];
   end; //==END== record: F_startingLocations ==//
   F_spm: array of TFCRdgSPMSettings;
end;
   ///<summary>
   ///   factions dynamic array
   ///</summary>
   TFCDdgFactions = array [0..FCCdiFactionsMax] of TFCRdgFaction;

{:REFERENCES LIST
   - FCMdFSG_Game_Load
   - FCMdFSG_Game_Save
   - FCMgNG_Core_Proceed
   - FCMgNG_Core_Setup
}
///<summary>
///   player's own data
///</summary>
type TFCRdgPlayer = record
   P_gameName: string;
   P_allegianceFaction: string[20];
   P_economicStatus: TFCEdgPlayerFactionStatus;
   P_economicViabilityThreshold: integer;
   P_socialStatus: TFCEdgPlayerFactionStatus;
   P_socialViabilityThreshold: integer;
   P_militaryStatus: TFCEdgPlayerFactionStatus;
   P_militaryViabilityThreshold: integer;
   P_viewStarSystem: string[20];
   P_viewStar: string[20];
   P_viewOrbitalObject: string[20];
   P_viewSatellite: string[20];
   P_currentTimeTick: integer;
   P_currentTimeMinut: integer;
   P_currentTimeHour: integer;
   P_currentTimeDay: integer;
   P_currentTimeMonth: integer;
   P_currentTimeYear: integer;
   P_currentTimePhase: TFCEtimePhases;
   P_surveyedResourceSpots: array of record
      SRS_orbitalObject_SatelliteToken: string[20];
      SRS_starSystem: integer;
      SRS_star: integer;
      SRS_orbitalObject: integer;
      SRS_satellite: integer;
      SRS_surveyedRegions: array of record
         SR_ResourceSpots: array of record
            RS_meanQualityCoefficient: extended;
            RS_spotSizeCurrent: integer;
            RS_spotSizeMax: integer;
            case RS_type: TFCEduResourceSpotTypes of
               rstIcyOreField:();

               rstOreField:(
                  RS_tOFiCarbonaceous: integer;
                  RS_tOFiMetallic: integer;
                  RS_tOFiRare: integer;
                  RS_tOFiUranium: integer;
                  );
         end; //==END== record: SR_ResourceSpots ==//
      end; //==END== record: SRS_surveyedRegions ==//
   end; //==END== record: P_surveyedResourceSpots ==//
end;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================





   







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
      SUO_status: TFCEdgSpaceUnitStatus;
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
      E_spm: array of TFCRdgSPMSettings;
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
   ///<summary>
   ///   clear the entities data
   ///</summary>
   procedure FCMdG_Entities_Clear;
   //=======================================================================================
   {.global variables}
   //=======================================================================================
   var
      FCDBfactions: TFCDdgFactions;
      FCDBdgSPMi: TFCDBdgSPMi;
      FCentities: TFCentities;
      {.CSM test list}
      FCGcsmPhList: TFCDdgCSMPhaseSchedule;
      {.game timer phase dump}
      FCGtimePhase: TFCEtimePhases =tphNull;

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
