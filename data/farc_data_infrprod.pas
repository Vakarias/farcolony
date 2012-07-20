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

{.energy generation modes}
{:DEV NOTES: update infrastrucdb.xml for energy function AND energy generation custom effect + FCMdF_DBInfra_Read.}
{:DEV NOTES: update FCFgEM_OutputFromFunction_GetValue + FCFgEM_OutputFromCustomFx_GetValue.}
type TFCRdipEnergyGenerationMode= record
   case FEPM_productionModes: TFCEdipEnergyGenerationModes of
      egmAntimatter: ();

      egmFission:
         {.fixed production value, in kW, for each infrastructure levels}
         (FEPM_fissionFPlvl: array [0..7] of extended;
            FEPM_fissionFPlvlByDL: array [0..7] of extended
            );

      egmFusionDT: ();

      egmFusionH2: ();

      egmFusionHe3: ();

      egmPhoton:
         (FEPM_photonArea: integer;
            FEPM_photonEfficiency: integer
            );
end;

   type TFCRdipInfraProdStorage= record
   	IPS_solid: extended;
      IPS_liquid: extended;
      IPS_gas: extended;
      IPS_biologic: extended;
   end;
   {.product data structure}
   {:DEV NOTES: update productsdb.xml + FCMdF_DBProducts_Read.}
   type TFCRdipProduct= record
      PROD_token: string[20];
      PROD_class: TFCEdipProductClasses;
      PROD_storage: TFCEdipStorageTypes;
      PROD_tsSector: TFCEdrResearchSectors;
      PROD_tsToken: string[20];
		PROD_tagHazEnv: boolean;
		PROD_tagHazFire: boolean;
		PROD_tagHazRad: boolean;
		PROD_tagHazToxic: boolean;
      PROD_volByUnit: extended;
      PROD_massByUnit: extended;
      case PROD_function: TFCEdipProductFunctions of
			pfBuildingMaterial:
				(
					PROD_fBmatTensileStr: extended;
					PROD_fBmatTSbyLevel: extended;
					PROD_fBmatYoungModulus: extended;
					PROD_fBmatYMbyLevel: extended;
					PROD_fBmatThermalProt: extended;
					PROD_fBmatReflectivity: extended;
					PROD_fBmatCorrosiveClass: TFCEdipCorrosiveClasses;
					);

         pfEnergyGeneration: ();

			pfFood:
				(PROD_fFoodPoint: integer);
         pfInfrastructureKit:
            (PROD_fInfKitToken: string[20];
             	PROD_fInfKitLevel: integer;
            	);
			pfManualConstruction:
				(PROD_fManConstWCPcoef: extended);
			pfManufacturingMaterial:
				();
			pfMechanicalConstruction:
				(
					PROD_fMechConstWCP: extended;
					PROD_fMechConstCrew: integer
					);
			pfMultipurposeMaterial:
				(
					PROD_fMmatTensileStr: extended;
					PROD_fMmatTSbyLevel: extended;
					PROD_fMmatYoungModulus: extended;
					PROD_fMmatYMbyLevel: extended;
					PROD_fMmatThermalProt: extended;
					PROD_fMmatReflectivity: extended;
					PROD_fMmatCorrosiveClass: TFCEdipCorrosiveClasses
					);
			pfOxygen:
            (PROD_fOxyPoint: integer);
			pfSpaceMaterial:
				(
					PROD_fSmatTensileStr: extended;
					PROD_fSmatTSbyLevel: extended;
					PROD_fSmatYoungModulus: extended;
					PROD_fSmatYMbyLevel: extended;
					PROD_fSmatThermalProt: extended;
					PROD_fSmatReflectivity: extended;
					PROD_fSmatCorrosiveClass: TFCEdipCorrosiveClasses
					);
			pfWater:
				(PROD_fWaterPoint: integer);
	end;
		type TFCDBProducts= array of TFCRdipProduct;
	{.custom effects}
	{:DEV NOTES: update infrastrucdb.xml + FCMdF_DBInfra_Read + FCMgICFX_Effects_Application + FCFgICFX_EffectHQ_Search.}
	type TFCRdipInfraCustomFX= record
      case ICFX_customEffect: TFCEdipCustomEffects of
         ceEnergyGeneration: (ICFX_enGenMode: TFCRdipEnergyGenerationMode);
         ceEnergyStorage: (ICFX_enStorLvl: array [0..7] of extended);
         ceHeadQuarterBasic: ();
         ceHeadQuarterSecondary: ();
         ceHeadQuarterPrimary: ();
         ceProductStorage: (ICFX_prodStorageLvl: array[0..7] of TFCRdipInfraProdStorage);
	end;
   {.production modes}
   {:DEV NOTES: update infrastrucdb.xml + FCMdF_DBInfra_Read + FCMgPM_ProductionModeDataFromFunction_Generate.}
   type TFCRdipInfraProdMode= record
      ///<summary>
      /// occupancy of the production mode for the infrastructure, if the building has only one production mode, occupancy=100(%)
      ///</summary>
      IPM_occupancy: integer;
      case IPM_productionModes: TFCEdipProductionModes of
//         pmCarbonaceousOreRefining:
//            ();
//         pmMetallicOreRefining:
//            ();
//         pmRadioactiveOreRefining:
//            ();
//         pmRareMetalsOreRefining:
//            ();

         pmResourceMining: ();

         pmWaterRecovery:(
            WR_roofarea: extended;
            WR_traparea: extended
            );

//         pmWaterElectrolysis:
//            ();
   end;
   {.infrastructure}
   {:DEV NOTES: update infrastrucdb.xml + FCMdF_DBInfra_Read + FCMgICS_Conversion_Process + FCMgICS_Assembling_Process + FCMgICS_Building_Process.}
   {:DEV NOTES: for requirements update FCMuiCDP_Data_Update.}
   type TFCRdipInfrastructure= record
      I_token: string[20];
      I_environment: TFCEduEnvironmentTypes;
      {.construct type}
      I_constr: TFCEdipConstructs;
      {.level range}
      I_minLevel: integer;
      I_maxLevel: integer;
      {.is surface only}
      I_isSurfOnly: boolean;
      {.surface, for each levels in the range}
      I_surface: array[0..7] of extended;
      {.volume, for each levels in the range}
      I_volume: array[0..7] of extended;
      {.base power consumption, for each levels in the range}
      I_basePwr: array[0..7] of extended;
      {.material volume, for each levels in the range}
      I_matVolume: array[0..7] of extended;
      {.prerequisites}
      I_reqGravMin: extended;
      I_reqGravMax: extended;
      I_reqHydro: TFCEdipHydrosphereRequirements;
      I_reqConstrMat: array of record
         RCM_token: string[20];
         RCM_percent: integer;
      end;
      I_reqRegionSoil: TFCEdipRegionSoilRequirements;
      I_reqRsrcSpot: TFCEduResourceSpotTypes;
      I_reqTechSci: record
         RTS_sector: TFCEdrResearchSectors;
         RTS_token: string[20];
      end;
      {.custom effects}
      I_customFx: array of TFCRdipInfraCustomFX;
      {.required staff}
      I_reqStaff: array of record
         RS_type: TFCEdpgsPopulationTypes;
         RS_requiredByLv: array[0..7] of integer;
      end;
      {.function}
      case I_function: TFCEdipFunctions of
         fEnergy: (I_fEnergyPmode: TFCRdipEnergyGenerationMode);

         fHousing: (
            I_fHousPopulationCap: array[0..7] of integer;
            I_fHousQualityOfLife: integer
            );

         fIntelligence: ();

         fMiscellaneous: ();

         fProduction: (I_fProductionMode: array[0..FCCdipProductionModesMax] of TFCRdipInfraProdMode);
   end;
      {.infrastructures dynamic array}
      TFCDBinfra= array of TFCRdipInfrastructure;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
var
   FCDBinfra: TFCDBinfra;
   FCDBProducts: TFCDBProducts;

//==END PUBLIC VAR==========================================================================

const


   ///<summary>
   /// standard transition time (hours)
   ///</summary>
   FCCtransitionTime=2;
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
