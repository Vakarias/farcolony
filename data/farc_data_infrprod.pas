{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructures and production - data unit

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
unit farc_data_infrprod;

interface

uses
   farc_data_pgs
   ,farc_data_research
   ,farc_data_univ;

const
   ///<summary>
   ///   max number of production modes
   ///</summary>
   FCCdipProductionModesMax=10;

{:REFERENCES LIST
   - infrastrucdb.xml
   - FCMdF_DBInfra_Read
}
///<summary>
///   types of construct
///</summary>
type TFCEdipConstructs=(
   cBuilt
   ,cPrefab
   ,cConverted
   );

{:REFERENCES LIST
   - productsdb.xml
   - FCMdF_DBProducts_Read
}
///<summary>
///   corrosive classes
///</summary>
type TFCEdipCorrosiveClasses=(
   ccD_Poor
   ,ccC_Fair
   ,ccB_Good
   ,ccA_Excellent
   );

{:REFERENCES LIST
   - infrastrucdb.xml
   - FCMdF_DBInfra_Read
   - FCMgICFX_Effects_Application
   - FCMgICFX_Effects_Removing
   - FCMgICS_Conversion_Process
   - TFCRdipInfraCustomFX
}
///<summary>
///   list of custom effects
///</summary>
type TFCEdipCustomEffects=(
   ceEnergyGeneration
   ,ceEnergyStorage
   ,ceHeadQuarterBasic
   ,ceHeadQuarterSecondary
   ,ceHeadQuarterPrimary
   ,ceProductStorage
   );

{:REFERENCES LIST
   - infrastrucdb.xml
   - productsdb.xml
   - FCMdF_DBInfra_Read
   - FCMdF_DBProducts_Read
   - TFCRdipInfrastructure
}
///<summary>
///   energy generation modes
///</summary>
type TFCEdipEnergyGenerationModes=(
   egmNone
   ,egmAntimatter
   ,egmFission
   ,egmFusionDT
   ,egmFusionH2
   ,egmFusionHe3
   ,egmPhoton
   );

{:REFERENCES LIST
   - infrastrucdb.xml
   - FCMdF_DBInfra_Read
   - FCMdFSG_Game_Save/Load
   - FCFgC_ColInfra_DReq
   - FCFgInf_InfFunc_GetStr
   - TFCRdipInfrastructure
}
///<summary>
///   functions list
///</summary>
type TFCEdipFunctions=(
   fEnergy
   ,fHousing
   ,fIntelligence
   ,fMiscellaneous
   ,fProduction
   );

{:REFERENCES LIST
   - infrastrucdb.xml
   - FCMdF_DBInfra_Read
}
///<summary>
///   requirement - hydrosphere types
///</summary>
type TFCEdipHydrosphereRequirements=(
   hrAny
   ,hrLiquid_LiquidNH3
   ,hrNone
   ,hrVapour
   ,hrLiquid
   ,hrIceSheet
   ,hrCrystal
   ,hrLiquidNH3
   ,hrCH4
   ,hrLiquid_Vapour_Ice_Sheet
   );

{:REFERENCES LIST
   - productsdb.xml
   - FCMdF_DBProducts_Read
}
///<summary>
///   classes of product
///</summary>
type TFCEdipProductClasses=(
   pcResource
   ,pcEnergyRelated
   ,pcMaterial
   ,pcBioproduct
   ,pcEquipment
   );

{:REFERENCES LIST
   - productsdb.xml
   - FCMdF_DBProducts_Read
   - TFCRdipProduct cases
   -
   -
   -
}
///<summary>
///   product's functions
///</summary>
type TFCEdipProductFunctions=(
   pfNone
   ,pfBuildingMaterial
   ,pfBuildingSupportEquipment
   ,pfEnergyGeneration
   ,pfFood
   ,pfInfrastructureKit
   ,pfManualConstruction
   ,pfManufacturingMaterial
   ,pfMechanicalConstruction
   ,pfMultipurposeMaterial
   ,pfOxygen
   ,pfSpaceMaterial
   ,pfWater
   );

{:REFERENCES LIST
   - infrastrucdb.xml
   - TFCRdipInfraProdMode
}
///<summary>
///   production modes
///</summary>
type TFCEdipProductionModes=(
   pmNone
//      ,pmCarbonaceousOreRefining
//      ,pmMetallicOreRefining
//      ,pmRadioactiveOreRefining
//      ,pmRareMetalsOreRefining
   ,pmResourceMining
   ,pmWaterRecovery
//      ,pmWaterElectrolysis
   );

{:REFERENCES LIST
   - infrastrucdb.xml
   - FCMdF_DBInfra_Read
}
///<summary>
///   requirement - region soils
///</summary>
type TFCEdipRegionSoilRequirements=(
   rsrAny
   ,rsrAnyNonVolcanic
   ,rsrAnyCoastal
   ,rsrAnyCoastalNonVolcanic
   ,rsrAnySterile
   ,rsrAnyFertile
   ,rsOceanic
   );

{:REFERENCES LIST
   - productsdb.xml
   - FCFgC_Storage_Update
   - FCMdF_DBProducts_Read
}
///<summary>
///   storage types
///</summary>
type TFCEdipStorageTypes=(
   stSolid
   ,stLiquid
   ,stGas
   ,stBiologic
   );

//==END PUBLIC ENUM=========================================================================

{:REFERENCES LIST
   - infrastrucdb.xml for energy function AND energy generation custom effect
   - FCFgEM_OutputFromCustomFx_GetValue
   - FCFgEM_OutputFromFunction_GetValue
   - FCMdF_DBInfrastructures_Load
}
///<summary>
///   energy generation modes
///</summary>
type TFCRdipEnergyGenerationMode= record
   case EGM_modes: TFCEdipEnergyGenerationModes of
      egmAntimatter: ();

      egmFission:(
         ///<summary>
         ///   fixed production value, in kW, for each infrastructure levels
         ///   and also by development level > 1
         ///</summary>
         EGM_mFfixedValues: array [0..7] of record
            FV_baseGeneration: extended;
            FV_generationByDevLevel: extended;
         end;
         );

      egmFusionDT: ();

      egmFusionH2: ();

      egmFusionHe3: ();

      egmPhoton:(
         EGM_mParea: integer;
         EGM_mPefficiency: integer
         );
end;

{:REFERENCES LIST
   - productsdb.xml
   - FCMdF_DBProducts_Read
}
///<summary>
///   product
///</summary>
type TFCRdipProduct= record
   ///<summary>
   ///   db token id
   ///</summary>
   P_token: string[20];
   P_class: TFCEdipProductClasses;
   P_storage: TFCEdipStorageTypes;
   P_tagEnvironmentalHazard: boolean;
   P_tagFireHazard: boolean;
   P_tagRadiationsHazard: boolean;
   P_tagToxicHazard: boolean;
   P_volumeByUnit: extended;
   P_massByUnit: extended;
   case P_function: TFCEdipProductFunctions of
      pfBuildingMaterial:(
         P_fBMtensileStrength: extended;
         P_fBMtensileStrengthByDevLevel: extended;
         P_fBMyoungModulus: extended;
         P_fBMyoungModulusByDevLevel: extended;
         P_fBMthermalProtection: extended;
         P_fBMreflectivity: extended;
         P_fBMcorrosiveClass: TFCEdipCorrosiveClasses;
         );

      pfEnergyGeneration:();

      pfFood:( P_fFpoints: integer );

      pfInfrastructureKit:(
         P_fIKtoken: string[20];
         P_fIKlevel: integer;
         );

      pfManualConstruction:( P_fManCwcpCoef: extended );

      pfManufacturingMaterial:();

      pfMechanicalConstruction:(
         P_fMechCwcpCoef: extended;
         P_fMechCcrew: integer
         );

      pfMultipurposeMaterial:(
         P_fMMtensileStrength: extended;
         P_fMMtensileStrengthByDevLevel: extended;
         P_fMMyoungModulus: extended;
         P_fMMyoungModulusByDevLevel: extended;
         P_fMMthermalProtection: extended;
         P_fMMreflectivity: extended;
         P_fMMcorrosiveClass: TFCEdipCorrosiveClasses
         );

      pfOxygen:( P_fOpoints: integer );

      pfSpaceMaterial:(
         P_fSMtensileStrength: extended;
         P_fSMtensileStrengthByDevLevel: extended;
         P_fSMyoungModulus: extended;
         P_fSMyoungModulusByDevLevel: extended;
         P_fSMthermalProtection: extended;
         P_fSMreflectivity: extended;
         P_fSMcorrosiveClass: TFCEdipCorrosiveClasses
         );

      pfWater:( P_fWpoints: integer );
end;
   ///<summary>
   ///   product dynamic array
   ///</summary>
   type TFCDdipProducts= array of TFCRdipProduct;

{:REFERENCES LIST
   - infrastrucdb.xml
   - FCMdF_DBInfra_Read
   - FCMgICS_Assembling_Process
   - FCMgICS_Building_Process
   - FCMgICS_Conversion_Process
   - for requirements update FCMuiCDP_Data_Update
   - FCMgICFX_Effects_Application
   - FCFgICFX_EffectHQ_Search
   - FCMgPM_ProductionModeDataFromFunction_Generate
}
///<summary>
///   infrastructure
///</summary>
type TFCRdipInfrastructure= record
   I_token: string[20];
   I_environment: TFCEduEnvironmentTypes;
   I_construct: TFCEdipConstructs;
   I_minLevel: integer;
   I_maxLevel: integer;
   I_isSurfaceOnly: boolean;
   ///<summary>
   ///   surface, for each levels in the range
   ///</summary>
   I_surface: array[0..7] of extended;
   ///<summary>
   ///   volume, for each levels in the range
   ///</summary>
   I_volume: array[0..7] of extended;
   ///<summary>
   ///   base power consumption, for each levels in the range
   ///</summary>
   I_basePower: array[0..7] of extended;
   ///<summary>
   ///   material volume, for each levels in the range
   ///</summary>
   I_materialVolume: array[0..7] of extended;
   {.prerequisites}
   I_reqGravityMin: extended;
   I_reqGravityMax: extended;
   I_reqHydrosphere: TFCEdipHydrosphereRequirements;
   I_reqConstructionMaterials: array of record
      ///<summary>
      ///   material's db token id
      ///</summary>
      RCM_token: string[20];
      ///<summary>
      ///   part of material volume, noted in %, used by the material
      ///</summary>
      RCM_partOfMaterialVolume: integer;
   end;
   I_reqRegionSoil: TFCEdipRegionSoilRequirements;
   I_reqResourceSpot: TFCEduResourceSpotTypes;
   I_reqStaff: array of record
      RS_type: TFCEdpgsPopulationTypes;
      RS_requiredByLv: array[0..7] of integer;
   end;
   I_customEffectStructure: array of record
      case ICFX_customEffect: TFCEdipCustomEffects of
         ceEnergyGeneration:( ICFX_ceEGmode: TFCRdipEnergyGenerationMode );

         ceEnergyStorage:( ICFX_ceEScapacitiesByLevel: array [0..7] of extended );

         ceHeadQuarterBasic:();

         ceHeadQuarterSecondary:();

         ceHeadQuarterPrimary:();

         ceProductStorage:(
            ICFX_cePSstorageByLevel: array[0..7] of record
               SBL_solid: extended;
               SBL_liquid: extended;
               SBL_gas: extended;
               SBL_biologic: extended;
            end;
            );
   end;
   case I_function: TFCEdipFunctions of
      fEnergy:( I_fEmode: TFCRdipEnergyGenerationMode );

      fHousing:(
         I_fHpopulationCapacity: array[0..7] of integer;
         I_fHqualityOfLife: integer
         );

      fIntelligence:();

      fMiscellaneous:();

      fProduction:(
         I_fPmodeStructure: array[0..FCCdipProductionModesMax] of record
            ///<summary>
            /// occupancy of the production mode for the infrastructure, if the building has only one production mode, occupancy=100(%)
            ///</summary>
            MS_occupancy: integer;
            case MS_mode: TFCEdipProductionModes of
      //         pmCarbonaceousOreRefining:
      //            ();
      //         pmMetallicOreRefining:
      //            ();
      //         pmRadioactiveOreRefining:
      //            ();
      //         pmRareMetalsOreRefining:
      //            ();

               pmResourceMining:();

               pmWaterRecovery:(
                  MS_mWRroofArea: extended;
                  MS_mWRtrapArea: extended
                  );

      //         pmWaterElectrolysis:
      //            ();
         end;
         );
end;
   ///<summary>
   ///   infrastructure dynamic array
   ///</summary>
   TFCDdipInfrastructures= array of TFCRdipInfrastructure;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
var
   ///<summary>
   ///   infrastructures database
   ///</summary>
   FCDdipInfrastructures: TFCDdipInfrastructures;

   ///<summary>
   ///   products database
   ///</summary>
   FCDdipProducts: TFCDdipProducts;

//==END PUBLIC VAR==========================================================================

const
   ///<summary>
   /// standard transition time (hours)
   ///</summary>
   FCCdipTransitionTime=2;

//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

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

end.
