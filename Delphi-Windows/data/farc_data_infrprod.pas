{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructures and production related data structures

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
   farc_data_init
   ,farc_data_research
   ,farc_data_univ;

const
   ///<summary>
   /// max number of production modes
   ///</summary>
   FCCpModeMax=10;

   ///<summary>
   /// standard transition time (hours)
   ///</summary>
   FCCtransitionTime=2;

   //=======================================================================================
   {.infrastructures data}
   //=======================================================================================
   {.types of construct}
   {:DEV NOTES: update infrastrucdb.xml.}
   type TFCEdipConstruct=(
      cBuilt
      ,cPrefab
      ,cConv
      );
   {.custom effects}
   {:DEV NOTES: update TFCRdipInfraCustomFX + infrastrucdb.xml.}
   type TFCEdipCustomFX=(
      cfxEnergyGen
      ,cfxEnergyStor
      ,cfxHQbasic
      ,cfxHQSecondary
      ,cfxHQPrimary
      ,cfxProductStorage
      );
   {.energy generation modes}
   {:DEV NOTES: update infrastrucdb.xml + productsdb.xml + TFCRdipInfrastructure + FCMdF_DBInfra_Read + FCMdF_DBProducts_Read.}
   type TFCEdipEnergyGenModes=(
      egmNone
		,egmAntimatter
      ,egmFission
      ,egmFusionDT
		,egmFusionH2
		,egmFusionHe3
      ,egmPhoton
      );
   {.infrastructure functions}
   {:DEV NOTES: update infrastrucdb.xml + FCMdF_DBInfra_Read + FCFgInf_InfFunc_GetStr + FCFgC_ColInfra_DReq.}
   {:DEV NOTES: update TFCRdipInfrastructure.}
   type TFCEdipFunction=(
      fEnergy
      ,fHousing
      ,fIntelligence
      ,fMiscellaneous
      ,fProduction
      );
   {.requirement - hydrosphere types}
   {:DEV NOTES: update infrastrucdb + FCMdF_DBInfra_Read.}
   type TFCEdipHydrosphereReq=(
      hrAny
      ,hrLiquid_LiquidNH3
      ,hrNone
      ,hrVapour
      ,hrLiquid
      ,hrIceSheet
      ,hrCrystal
      ,hrLiquidNH3
      ,hrCH4
      );
   {.product cargos}
//   type TFCEdipProductCargos=(
//
//      );
   {.product classes}
   {:DEV NOTES: update productsdb.xml + FCMdF_DBProducts_Read.}
   type TFCEdipProductClasses=(
      prclResource
      ,prcEnergyRelItem
      ,prcMaterial
      ,prcBioproduct
      ,prcEquipment
      );
   {.product corrosive classes}
	{:DEV NOTES: update productsdb.xml + FCMdF_DBProducts_Read}
	type TFCEdipProductCorrosiveClasses=(
		prciDpoor
		,prciCfair
		,prciBgood
		,prciAexcellent
		);
   {.product functions}
   {:DEV NOTES: update productsdb.xml + FCMdF_DBProducts_Read + TFCRdipProduct cases.}
   type TFCEdipProductFunctions=(
      prfuNone
      ,prfuBuildingMat
      ,prfuBuildingSupportEquip
      ,prfuEnergyGeneration
      ,prfuFood
      ,prfuInfraKit
      ,prfuManConstruction
      ,prfuManufacturingMat
      ,prfuMechConstruction
      ,prfuMultipurposeMat
      ,prfuOxygen
      ,prfuSpaceMat
      ,prfuWater
      );
   {.production modes}
   {:DEV NOTES: update infrastrucdb + TFCRdipInfraProdMode + FCMdFSG_Game_Save/Load + FCMgPM_ProductionModeDataFromFunction_Generate.}
   type TFCEdipProductionModes=(
      pmNone
//      ,pmCarbonaceousOreRefining
//      ,pmHumidityGathering
//      ,pmMetallicOreRefining
//      ,pmRadioactiveOreRefining
//      ,pmRareMetalsOreRefining
      ,pmResourceMining
//      ,pmWaterElectrolysis
      );
   {.requirement - region soil}
   {:DEV NOTES: update infrastrucdb + FCMdF_DBInfra_Read.}
   type TFCEdipRegionSoilReq=(
      rsrAny
      ,rsrAnyNonVolcanic
      ,rsrAnyCoastal
      ,rsrAnyCoastalNonVolcanic
      ,rsrAnySterile
      ,rsrAnyFertile
      ,rsOceanic
      );
   {.storage type}
   {:DEV NOTES: update productsdb.xml + FCMdF_DBProducts_Read + FCFgC_Storage_Update.}
   type TFCEdipStorageType=(
      stSolid
      ,stLiquid
      ,stGas
      ,stBiologic
      );
   //==END ENUM=============================================================================
   {.energy generation modes}
   {:DEV NOTES: update infrastrucdb.xml for energy function AND energy generation custom effect + FCMdF_DBInfra_Read.}
   {:DEV NOTES: update FCFgEM_OutputFromFunction_GetValue + FCFgEM_OutputFromCustomFx_GetValue.}
   type TFCRdipEnergyGenerationMode= record
		case FEPM_productionModes: TFCEdipEnergyGenModes of
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
      PROD_storage: TFCEdipStorageType;
      PROD_tsSector: TFCEdresResearchSectors;
      PROD_tsToken: string[20];
		PROD_tagHazEnv: boolean;
		PROD_tagHazFire: boolean;
		PROD_tagHazRad: boolean;
		PROD_tagHazToxic: boolean;
      PROD_volByUnit: extended;
      PROD_massByUnit: extended;
      case PROD_function: TFCEdipProductFunctions of
			prfuBuildingMat:
				(
					PROD_fBmatTensileStr: extended;
					PROD_fBmatTSbyLevel: extended;
					PROD_fBmatYoungModulus: extended;
					PROD_fBmatYMbyLevel: extended;
					PROD_fBmatThermalProt: extended;
					PROD_fBmatReflectivity: extended;
					PROD_fBmatCorrosiveClass: TFCEdipProductCorrosiveClasses;
					);

         prfuEnergyGeneration: ();

			prfuFood:
				(PROD_fFoodPoint: integer);
         prfuInfraKit:
            (PROD_fInfKitToken: string[20];
             	PROD_fInfKitLevel: integer;
            	);
			prfuManConstruction:
				(PROD_fManConstWCPcoef: extended);
			prfuManufacturingMat:
				();
			prfuMechConstruction:
				(
					PROD_fMechConstWCP: extended;
					PROD_fMechConstCrew: integer
					);
			prfuMultipurposeMat:
				(
					PROD_fMmatTensileStr: extended;
					PROD_fMmatTSbyLevel: extended;
					PROD_fMmatYoungModulus: extended;
					PROD_fMmatYMbyLevel: extended;
					PROD_fMmatThermalProt: extended;
					PROD_fMmatReflectivity: extended;
					PROD_fMmatCorrosiveClass: TFCEdipProductCorrosiveClasses
					);
			prfuOxygen:
            (PROD_fOxyPoint: integer);
			prfuSpaceMat:
				(
					PROD_fSmatTensileStr: extended;
					PROD_fSmatTSbyLevel: extended;
					PROD_fSmatYoungModulus: extended;
					PROD_fSmatYMbyLevel: extended;
					PROD_fSmatThermalProt: extended;
					PROD_fSmatReflectivity: extended;
					PROD_fSmatCorrosiveClass: TFCEdipProductCorrosiveClasses
					);
			prfuWater:
				(PROD_fWaterPoint: integer);
	end;
		type TFCDBProducts= array of TFCRdipProduct;
	{.custom effects}
	{:DEV NOTES: update infrastrucdb.xml + FCMdF_DBInfra_Read + FCMgICFX_Effects_Application + FCFgICFX_EffectHQ_Search.}
	type TFCRdipInfraCustomFX= record
      case ICFX_customEffect: TFCEdipCustomFX of
         cfxEnergyGen: (ICFX_enGenMode: TFCRdipEnergyGenerationMode);
         cfxEnergyStor: (ICFX_enStorLvl: array [0..7] of extended);
         cfxHQbasic: ();
         cfxHQSecondary: ();
         cfxHQPrimary: ();
         cfxProductStorage: (ICFX_prodStorageLvl: array[0..7] of TFCRdipInfraProdStorage);
	end;
   {.production modes}
   {:DEV NOTES: update infrastrucdb.xml + FCMdF_DBInfra_Read.}
   {:DEV NOTES: update data_game/TFCRdgColonInfra + FCMgPM_ProductionModeDataFromFunction_Generate.}
   type TFCRdipInfraProdMode= record
      ///<summary>
      /// occupancy of the production mode for the infrastructure, if the building has only one production mode, occupancy=100(%)
      ///</summary>
      IPM_occupancy: integer;
      case IPM_productionModes: TFCEdipProductionModes of
//         pmCarbonaceousOreRefining:
//            ();
//         pmHumidityGathering:
//            (IPM_roofArea: integer;
//            IPM_trapArea: integer);
//         pmMetallicOreRefining:
//            ();
//         pmRadioactiveOreRefining:
//            ();
//         pmRareMetalsOreRefining:
//            ();

         pmResourceMining: ();

//         pmWaterElectrolysis:
//            ();
   end;
   {.infrastructure}
   {:DEV NOTES: update infrastrucdb.xml + FCMdF_DBInfra_Read + FCMgICS_Conversion_Process + FCMgICS_Assembling_Process + FCMgICS_Building_Process.}
   {:DEV NOTES: for requirements update FCMuiCDP_Data_Update.}
   type TFCRdipInfrastructure= record
      I_token: string[20];
      I_environment: TFCEduEnv;
      {.construct type}
      I_constr: TFCEdipConstruct;
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
      I_reqHydro: TFCEdipHydrosphereReq;
      I_reqConstrMat: array of record
         RCM_token: string[20];
         RCM_percent: integer;
      end;
      I_reqRegionSoil: TFCEdipRegionSoilReq;
      I_reqRsrcSpot: TFCEduRsrcSpotType;
      I_reqTechSci: record
         RTS_sector: TFCEdresResearchSectors;
         RTS_token: string[20];
      end;
      {.custom effects}
      I_customFx: array of TFCRdipInfraCustomFX;
      {.required staff}
      I_reqStaff: array of record
         RS_type: TFCEdiPopType;
         RS_requiredByLv: array[0..7] of integer;
      end;
      {.function}
      case I_function: TFCEdipFunction of
         fEnergy: (I_fEnergyPmode: TFCRdipEnergyGenerationMode);

         fHousing: (
            I_fHousPopulationCap: array[0..7] of integer;
            I_fHousQualityOfLife: integer
            );

         fIntelligence: ();

         fMiscellaneous: ();

         fProduction: (I_fProductionMode: array[0..FCCpModeMax] of TFCRdipInfraProdMode);
   end;
      {.infrastructures dynamic array}
      TFCDBinfra= array of TFCRdipInfrastructure;
   //=======================================================================================
   {.global variables}
   //=======================================================================================
   var
      FCDBinfra: TFCDBinfra;
      FCDBProducts: TFCDBProducts;

implementation

//=============================================END OF INIT==================================

end.
