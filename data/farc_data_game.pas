{======(C) Copyright Aug.2009-2014 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: misc game systems - data unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2014, Jean-Francois Baconnet

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
   ,farc_data_rds
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

///<summary>
///   types of planetary surveys
///</summary>
type TFCEdgPlanetarySurveys=(
   psResources
   ,psBiosphere
   ,psFeaturesArtifacts
   );

///<summary>
///   types of extension for a planetary survey expedition
///</summary>
type TFCEdgPlanetarySurveyExtensions=(
   pseSelectedRegionOnly
   ,pseAllAdjacentRegions
   ,pseAllControlledNeutralRegions
   );

{:REFERENCES LIST
   - FCFsF_SurveyVehicles_GetPhase
   - FCFsF_SurveyVehicles_GetPhaseDuration
   - FCMsC_ResourceSurvey_Core
   -
   -
   -
   -
}
///<summary>
///   planetary survey phases
///</summary>
type TFCEdgPlanetarySurveyPhases=(
   pspInTransitToSite
   ,pspResourcesSurveying
   ,pspBiosphereSurveying
   ,pspFeaturesArtifactsSurveying
   ,pspBackToBase
   ,pspReplenishment
   ,pspBackToBaseFINAL
   ,pspMissionCompletion
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

{:REFERENCES LIST
   -
   -
   -
   -
   -
   -
}
///<summary>
///
///</summary>
type TFCEdgTechnoscienceMasteringStages=(
   tmsNotDiscovered
   ,tmsNotMastered
   ,tmsMasteredAtLevel00
   ,tmsMasteredAtLevel01
   ,tmsMasteredAtLevel02
   ,tmsMasteredAtLevel03
   ,tmsMasteredAtLevel04
   ,tmsMasteredAtLevel05
   ,tmsMasteredAtLevel06
   ,tmsMasteredAtLevel07
   ,tmsMasteredAtLevel08
   ,tmsMasteredAtLevel09
   ,tmsMasteredAtLevel10
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
   - FCMdFSG_Game_Load
   - FCMdFSG_Game_Save
}
///<summary>
///
///</summary>
type TFCRdgTechnoscience = record
   TS_token: string[20];
   TS_masteringStage: TFCEdgTechnoscienceMasteringStages;
   TS_ripCurrent: integer;
   TS_ripMax: integer;
   case TS_collateralMastered: boolean of
      False: ();

      True: (
         TS_cmtCollateralTriggerIndex: integer;
         TS_cmtCollateralTriggerRDomain: integer;
         ///<summary>
         ///   =0 if the collateral trigger is a fundamental research
         ///</summary>
         TS_cmtCollateralTriggerRFI: integer
      );
end;

{:REFERENCES LIST
   - FCMdG_RDScolonyDomains_Reset
   - FCMdFSG_Game_Load
   - FCMdFSG_Game_Save
}
///<summary>
///
///</summary>
type TFCRdgResearchDomainColony = record
   RDC_type: TFCEdrdsResearchDomains;
   RDC_researchFields: array of record
      RF_type: TFCEdrdsResearchFields;
      ///<summary>
      ///   rto-5
      ///</summary>
      RF_knowledgeGeneration: extended;
      ///<summary>
      /// intelligence infrastructures [x,y] = infrastructure index in settlement
      ///<summary>
      /// x= settlements index
      ///</summary>
      ///<summary>
      /// y= index of intelligenceInfrastructures
      ///</summary>
      ///</summary>
      RF_intelligenceInfrastructures: array of array of integer;
   end;
end;

{:REFERENCES LIST
   - FCMdFSG_Game_Load
   - FCMdFSG_Game_Save
}
///<summary>
///
///</summary>
type TFCRdgResearchDomainEntity = record
   RDE_type: TFCEdrdsResearchDomains;
   RDE_knowledgeCurrent: integer;
   RDE_fundamentalResearches: array of TFCRdgTechnoscience;
   RDE_researchFields: array of record
      RF_type: TFCEdrdsResearchFields;
      RF_knowledgeCurrent: extended;
      RF_knowledgeGenerationTotal: extended;
      RF_technosciences: array of TFCRdgTechnoscience;
   end;
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
   C_csmHealth_HealthLevel: integer;
   C_csmEnergy_Consumption: extended;
   C_csmEnergy_Generation: extended;
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
      ///<summary>
      ///   sum of units of all DL
      ///</summary>
      SP_unit: extended;
      ///<summary>
      ///   array of the product by DL
      ///</summary>
      SP_listByDLinUnits: array [0..10] of extended;
   end;
   C_reserveOxygen: integer;
   C_reserveFood: integer;
   ///<summary>
   /// store the storage indexes for each food product
   ///</summary>
   C_reserveFoodProductsIndex: array of integer;
   C_reserveWater: integer;
   C_researchDomains: array[0..FCCdiRDSdomainsMax] of TFCRdgResearchDomainColony;
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
         SPMS_iPfBeliefLevel: TFCEdgBeliefLevels;
         SPMS_iPfSpreadValue: integer
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
            {:DEV NOTES: add population.}
      end; //==END== record: CM_equipmentList ==//
   end; //==END== record: F_colonizationModes ==//
   F_startingLocations: array of record
      SL_stellarSystem: string[20];
      SL_star: string[20];
      SL_orbitalObject: string[20];
   end; //==END== record: F_startingLocations ==//
   F_spm: array of TFCRdgSPMSettings;
   F_comCoreOrient_aerospaceEng: integer;
   F_comCoreOrient_astroEng: integer;
   F_comCoreOrient_biosciences: integer;
   F_comCoreOrient_culture: integer;
   F_comCoreOrient_ecosciences: integer;
   F_comCoreOrient_indusTech: integer;
   F_comCoreOrient_nanotech: integer;
   F_comCoreOrient_physics: integer;
   F_comCoreSetup: array of record
      CCS_techToken: string[20];
      CCS_techLevel: TFCEdrdsTechnologyLevels;
      CCS_resDomain: TFCEdrdsResearchDomains;
      CCS_resField: TFCEdrdsResearchFields;
   end;
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
   P_isTurnBased: boolean;
   P_currentRealTimeAcceleration: TFCEggfRealTimeAccelerations;
   P_currentTypeOfTurn: TFCEggfTurnTypes;
end;

///<summary>
///   list of docked space units
///</summary>
type TFCRdgSpaceUnitDockList = record
   SUDL_index: integer;
end;

{:REFERENCES LIST
   - FCMdF_DBFactions_Load
   - FCMdFiles_Game_Load
   - FCMdFiles_Game_Save
   - FCMgNG_ColMode_Upd
   - FCMgNG_Core_Proceed
   - FCMgNG_FactionList_Multipurpose
}
///<summary>
///   owned space units
///</summary>
type TFCRdgSpaceUnit = record
   SU_token: string[20];
   SU_name: string[20];
   SU_designToken: string[20];
   SU_locationStarSystem: string[20];
   SU_locationStar: string[20];
   SU_locationOrbitalObject: string[20];
   SU_locationSatellite: string[20];
   SU_locationDockingMotherCraft: integer;
   SU_linked3dObject: integer;
   SU_locationViewX: extended;
   SU_locationViewZ: extended;
   SU_assignedTask: integer;
   SU_status: TFCEdgSpaceUnitStatus;
   SU_dockedSpaceUnits: array of TFCRdgSpaceUnitDockList;
   SU_deltaV: extended;
   SU_3dVelocity: extended;
   SU_reactionMass: extended;
end;

type TFCRdgPlanetarySurvey = record
   PS_type: TFCEdgPlanetarySurveys;
   PS_locationSSys: string[20];
   PS_locationStar: string[20];
   PS_locationOobj: string[20];
   PS_locationSat: string[20];
   ///<summary>
   ///   targeted region for the survey. If the mission is complete but not all vehicles are back to base, region=0. If the mission is entirely complete, region=-1
   ///</summary>
   PS_targetRegion: integer;
   PS_meanEMO: extended;
   PS_linkedColony: integer;
   PS_linkedSurveyedResource: integer;
   PS_missionExtension: TFCEdgPlanetarySurveyExtensions;
   ///<summary>
   ///   current percent of surface surveyed by day
   ///</summary>
   PS_pss: extended;
   PS_completionPercent: extended;
   PS_vehiclesGroups: array of record
      VG_linkedStorage: integer;
      VG_numberOfUnits: integer;
      VG_numberOfVehicles: integer;
      VG_vehiclesFunction: TFCEdipProductFunctions;
      VG_speed: integer;
      VG_totalMissionTime: integer;
      VG_usedCapability: integer;
      VG_crew: integer;
      VG_regionEMO: extended;
      VG_timeOfOneWayTravel: integer;
      ///<summary>
      ///   DMS = days of mission (note for design doc)
      ///</summary>
      VG_timeOfMission: integer;
      VG_timeOfReplenishment: integer;
      VG_distanceOfSurvey: extended;
      VG_currentPhase: TFCEdgPlanetarySurveyPhases;
      VG_currentPhaseElapsedTime: integer;
   end; //==END== record: PS_vehiclesGroups ==//
end;

{:REFERENCES LIST
   - FCMdF_Game_Load
   - FCMdF_Game_Save
   - FCMdG_Entities_Clear
   - FCMgNG_Core_Proceed
   - if centralized SPMi mod ad/rem/update and/or bureaucracy/corruption: FCMgSPM_SPMI_Set
   - for any array, init it in FCMgNG_Core_Proceed.
   - for resources spots: FCFgPRS_SurveyedResourceSpots_Add + FCFgPRS_ResourceSpots_Add
   - for E_surveyedResourceSpots / TFCEduResourceSpotTypes: init special data in FCFgPRS_ResourceSpots_Add
}
///<summary>
///   entities
///</summary>
type TFCRdgEntity= record
   E_token: string[20];
   E_factionLevel: integer;
   E_bureaucracy: integer;
   E_corruption: integer;
   E_hqHigherLevel: TFCEdgHeadQuarterStatus;
   E_ucInAccount: extended;
   E_spaceUnits: array of TFCRdgSpaceUnit;
   E_colonies: array of TFCRdgColony;
   E_spmSettings: array of TFCRdgSPMSettings;
   E_spmMod_Cohesion: integer;
   E_spmMod_Tension: integer;
   E_spmMod_Security: integer;
   E_spmMod_Education: integer;
   E_spmMod_Natality: integer;
   E_spmMod_Health: integer;
   E_spmMod_Bureaucracy: integer;
   E_spmMod_Corruption: integer;
   ///<summary>
   ///   switch to indicate if the planetary survey array must be cleaned up
   ///</summary>
   E_cleanupSurveys: boolean;
   E_planetarySurveys: array of TFCRdgPlanetarySurvey;
   E_surveyedResourceSpots: array of record
      SRS_orbitalObject_SatelliteToken: string[20];
      SRS_starSystem: integer;
      SRS_star: integer;
      SRS_orbitalObject: integer;
      SRS_satellite: integer;
      SRS_surveyedRegions: array of record
         ///<summary>
         ///   store the planetary survey index that currently process the survey of the region. If it's equal to 0, the survey is completed.
         ///</summary>
         SRS_currentPlanetarySurvey: integer;
         SR_ResourceSpots: array of record
            RS_type: TFCEduResourceSpotTypes;
            RS_meanQualityCoefficient: extended;
            RS_spotSizeCurrent: integer;
            RS_spotSizeMax: integer;
         end; //==END== record: SR_ResourceSpots ==//
      end; //==END== record: SRS_surveyedRegions ==//
   end; //==END== record: P_surveyedResourceSpots ==//
   E_researchDomains: array[0..FCCdiRDSdomainsMax] of TFCRdgResearchDomainEntity;
end;
   TFCDdgEntities= array [0..FCCdiFactionsMax] of TFCRdgEntity;

//==END PUBLIC RECORDS======================================================================


var
   //==========databases and other data structures pre-init=================================
   FCDdgCSMPhaseSchedule: TFCDdgCSMPhaseSchedule;

   FCDdgEntities: TFCDdgEntities;

   FCDdgFactions: TFCDdgFactions;

   FCDdgSPMi: TFCDdgSPMi;

   //==========core game data===============================================================
   FCVdgPlayer: TFCRdgPlayer;

//   FCVdgTimePhase: TFCEggfRealTimeAccelerations =rtaX1;

//==END PUBLIC VAR==========================================================================

const
   FCCdgWeekInTicks=1008;

//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   clear the entities' data
///</summary>
procedure FCMdG_Entities_Clear;

///<summary>
///   reset the research domains' data of a particular colony from a particular faction
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMdG_RDScolonyDomains_Reset( const Entity, Colony: integer );

implementation

uses
   farc_rds_func;

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
{:Purpose: clear the entities' data.
    Additions:
      -2014Aug20- *add: E_researchDomains.
      -2013Mar30- *add: E_cleanupSurveys.
      -2013Mar12- *add: E_surveyedResourceSpots.
      -2013Jan31- *add: E_planetarySurveys.
      -2012Aug14- *code audit:
                     (x)var formatting + refactoring     (_)if..then reformatting   (_)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (_)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)use of enumindex                 (_)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
      -2010Nov08- *add: forgot to add bureaucracy, corruption and the SPM modifiers.
                  *add: UC.
      -2010Sep20- *add: SPM settings.
}
   var
      Count
      ,Count1: integer;
begin
   Count:=0;
   Count1:=0;
   while Count<=FCCdiFactionsMax do
   begin
      FCDdgEntities[Count].E_token:='';
      FCDdgEntities[Count].E_factionLevel:=0;
      FCDdgEntities[Count].E_bureaucracy:=0;
      FCDdgEntities[Count].E_corruption:=0;
      FCDdgEntities[Count].E_hqHigherLevel:=hqsNoHQPresent;
      FCDdgEntities[Count].E_ucInAccount:=0;
      SetLength( FCDdgEntities[Count].E_spaceUnits, 0 );
      SetLength( FCDdgEntities[Count].E_colonies, 0 );
      SetLength( FCDdgEntities[Count].E_spmSettings, 0 );
      FCDdgEntities[Count].E_spmMod_Cohesion:=0;
      FCDdgEntities[Count].E_spmMod_Tension:=0;
      FCDdgEntities[Count].E_spmMod_Security:=0;
      FCDdgEntities[Count].E_spmMod_Education:=0;
      FCDdgEntities[Count].E_spmMod_Natality:=0;
      FCDdgEntities[Count].E_spmMod_Health:=0;
      FCDdgEntities[Count].E_spmMod_Bureaucracy:=0;
      FCDdgEntities[Count].E_spmMod_Corruption:=0;
      FCDdgEntities[Count].E_cleanupSurveys:=false;
      SetLength( FCDdgEntities[Count].E_planetarySurveys, 1 );
      SetLength( FCDdgEntities[Count].E_surveyedResourceSpots, 1 );
      Count1:=1;
      while Count1 <= FCCdiRDSdomainsMax do
      begin
         FCDdgEntities[Count].E_researchDomains[Count1].RDE_type:=TFCEdrdsResearchDomains( Count1 - 1 );
         FCDdgEntities[Count].E_researchDomains[Count1].RDE_knowledgeCurrent:=0;
         SetLength( FCDdgEntities[Count].E_researchDomains[Count1].RDE_researchFields, 1 );
         inc( Count1 );
      end;
      inc(Count);
   end;
end;

procedure FCMdG_RDScolonyDomains_Reset( const Entity, Colony: integer );
{:Purpose: reset the domains' data of a particular colony from a particular faction.
    Additions:
      -2014Aug17- *rem: technosciences and theories aren't at the colony level.
                  *add: initialize intelligence infrastructures multi-array.
                  *code: method refactoring to indicate that is concern the colonies.
                  *add: RF_knowledgeGeneration is initialized.
}
   var
      Count
      ,Count1
      ,Count2
      ,Max: integer;
begin
   Count:=1;
   Count1:=0;
   Count2:=0;
   Max:=0;
   while Count <= FCCdiRDSdomainsMax do
   begin
      FCDdrdsResearchDatabase[Count].RD_type:=TFCEdrdsResearchDomains( Count - 1 );
      Max:=FCFrdsF_Domain_GetNumberOfResearchFields( FCDdrdsResearchDatabase[Count].RD_type );
      setlength( FCDdrdsResearchDatabase[Count].RD_researchFields, Max + 1 );
      Count1:=1;
      while Count1 <= Max do
      begin
         FCDdgEntities[Entity].E_colonies[Colony].C_researchDomains[Count].RDC_researchFields[Count1].RF_type:=TFCEdrdsResearchFields( Count1 + Count2 );
         FCDdgEntities[Entity].E_colonies[Colony].C_researchDomains[Count].RDC_researchFields[Count1].RF_knowledgeGeneration:=0;
//         setlength( FCDdgEntities[Entity].E_colonies[Colony].C_researchDomains[Count].RDC_researchFields[Count1].RF_technosciences, 1 );
//         setlength( FCDdgEntities[Entity].E_colonies[Colony].C_researchDomains[Count].RDC_researchFields[Count1].RF_theories, 1 );
         setlength( FCDdgEntities[Entity].E_colonies[Colony].C_researchDomains[Count].RDC_researchFields[Count1].RF_intelligenceInfrastructures, 1 );
         inc( Count1 );
      end;
      Count2:=Count2 + Max;
      inc( Count );
   end;
end;

end.
