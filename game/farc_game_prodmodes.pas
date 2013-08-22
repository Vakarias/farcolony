{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: production modes management

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
unit farc_game_prodmodes;

interface

uses
   math
   ,sysutils

   ,farc_data_infrprod;


//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   enable or disable a specified production mode by applying its data into colony's global data
///</summary>
///   <param name="EDPentity">entity index #</param>
///   <param name="EDPcolony">colony index #</param>
///   <param name="EDPsettlement">settlement index #</param>
///   <param name="EDPownedInfra">owned infrastructure index #</param>
///   <param name="EDPproductionMode">production mode index #</param>
///   <param name="EDPisToEnable">if true=> enable the production mode</param>
///   <param name="EDPifFromProd">if true=> enable/disable comes from the production phase</param>
procedure FCMgPM_EnableDisable_Process(
   const EDPentity
         ,EDPcolony
         ,EDPsettlement
         ,EDPownedInfra
         ,EDPproductionMode: integer;
   const EDPisToEnable
         ,EDPifFromProd: boolean
         );

///<summary>
///   enable or disable all production modes of a specified infrastructure
///</summary>
///   <param name="EDPentity">entity index #</param>
///   <param name="EDPcolony">colony index #</param>
///   <param name="EDPsettlement">settlement index #</param>
///   <param name="EDPownedInfra">owned infrastructure index #</param>
///   <param name="EDPisToEnable">if true=> enable the production mode</param>
procedure FCMgPM_EnableDisableAll_Process(
   const EDAPentity
         ,EDAPcolony
         ,EDAPsettlement
         ,EDAPownedInfra: integer;
   const EDAPisToEnable: boolean
         );

///<summary>
///   generate the production modes' data from the infrastructure's function
///</summary>
///   <param name="PMDFFGent">entity index #</param>
///   <param name="PMDFFGcol">colony index #</param>
///   <param name="PMDFFGsett">settlement index #</param>
///   <param name="PMDFFGinfra">owned infrastructure index #</param>
///   <param name="PMDFFGinfraLevel">owned infrastructure level</param>
///   <param name="PMDFFGinfraData">infrastructure data</param>
procedure FCMgPM_ProductionModeDataFromFunction_Generate(
   const PMDFFGent
         ,PMDFFGcol
         ,PMDFFGsett
         ,PMDFFGinfra
         ,PMDFFGinfraLevel: integer;
   const PMDFFGinfraData: TFCRdipInfrastructure
   );

implementation

uses
   farc_common_func
   ,farc_data_init
   ,farc_data_game
   ,farc_data_pgs
   ,farc_data_univ
   ,farc_game_colony
   ,farc_game_csm
   ,farc_game_infracustomfx
   ,farc_game_infrastaff
   ,farc_game_prodSeg2
   ,farc_ui_coredatadisplay
   ,farc_univ_func
   ,farc_win_debug;

//===================================================END OF INIT============================


//===========================END FUNCTIONS SECTION==========================================

procedure FCMgPM_EnableDisable_Process(
   const EDPentity
         ,EDPcolony
         ,EDPsettlement
         ,EDPownedInfra
         ,EDPproductionMode: integer;
   const EDPisToEnable
         ,EDPifFromProd: boolean
         );
{:Purpose: enable or disable a specified production mode by applying its data into colony's global data.
    Additions:
      -2011Jan18- *add: update the data display if required.
      -2011Dec19- *add: new parameter for indicate if a disabling/enabling comes from the production phase or not.
      -2011Dec12- *fix: power consumption calculations are put outside the matrix item processing loops, prevent to update the CSM energy <matrix items number> time.
}
   var
      EDPpmiCount
      ,EDPprodMatrixIndex
      ,EDPprodModeIndex: integer;
begin
   if EDPisToEnable then
   begin
      if not EDPifFromProd
      then FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_isDisabled:=false;
      FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_powerConsumption:=
         FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_powerConsumption
         +FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_energyConsumption
         ;
      FCMgCSM_Energy_Update(
         EDPentity
         ,EDPcolony
         ,false
         ,FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_energyConsumption
         ,0
         ,0
         ,0
         );
      EDPpmiCount:=1;
      while EDPpmiCount<=FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_matrixItemMax do
      begin
         EDPprodMatrixIndex:=
            FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_linkedColonyMatrixItems[ EDPpmiCount ].LMII_matrixItemIndex;
         EDPprodModeIndex:=
            FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_linkedColonyMatrixItems[ EDPpmiCount ].LMII_matrixItem_ProductionModeIndex;
         FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_productionMatrix[ EDPprodMatrixIndex ].PM_globalProductionFlow:=
            FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_productionMatrix[ EDPprodMatrixIndex ].PM_globalProductionFlow
            +FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_productionMatrix[ EDPprodMatrixIndex ].PM_productionModes[ EDPprodModeIndex ].PM_productionFlow
            ;
         if EDPifFromProd
         then FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_productionMatrix[ EDPprodMatrixIndex ].PM_productionModes[ EDPprodModeIndex ].PM_isDisabledByProductionSegment:=false;
         if EDPentity=0
         then FCMuiCDD_Production_Update(
            plProdMatrixItem
            ,EDPcolony
            ,EDPprodMatrixIndex
            ,0
            );
         inc( EDPpmiCount );
      end;
   end
   else begin
      if not EDPifFromProd
      then FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_isDisabled:=true;
      FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_powerConsumption:=
         FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_powerConsumption
         -FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_energyConsumption
         ;
      FCMgCSM_Energy_Update(
         EDPentity
         ,EDPcolony
         ,false
         ,-FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_energyConsumption
         ,0
         ,0
         ,0
         );
      EDPpmiCount:=1;
      while EDPpmiCount<=FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_matrixItemMax do
      begin
         EDPprodMatrixIndex:=
            FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_linkedColonyMatrixItems[ EDPpmiCount ].LMII_matrixItemIndex;
         EDPprodModeIndex:=
            FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_settlements[ EDPsettlement ].S_infrastructures[ EDPownedInfra ].I_fProdProductionMode[ EDPproductionMode ].PM_linkedColonyMatrixItems[ EDPpmiCount ].LMII_matrixItem_ProductionModeIndex;
         FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_productionMatrix[ EDPprodMatrixIndex ].PM_globalProductionFlow:=
            FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_productionMatrix[ EDPprodMatrixIndex ].PM_globalProductionFlow
            -FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_productionMatrix[ EDPprodMatrixIndex ].PM_productionModes[ EDPprodModeIndex ].PM_productionFlow
            ;
         if EDPifFromProd
         then FCDdgEntities[ EDPentity ].E_colonies[ EDPcolony ].C_productionMatrix[ EDPprodMatrixIndex ].PM_productionModes[ EDPprodModeIndex ].PM_isDisabledByProductionSegment:=true;
         if EDPentity=0
         then FCMuiCDD_Production_Update(
            plProdMatrixItem
            ,EDPcolony
            ,EDPprodMatrixIndex
            ,0
            );
         inc( EDPpmiCount );
      end;
   end;
end;

procedure FCMgPM_EnableDisableAll_Process(
   const EDAPentity
         ,EDAPcolony
         ,EDAPsettlement
         ,EDAPownedInfra: integer;
   const EDAPisToEnable: boolean
         );
{:Purpose: enable or disable all production modes of a specified infrastructure.
    Additions:
}
   var
      EDAPpmodeCount: integer;
begin
   EDAPpmodeCount:=1;
   while EDAPpmodeCount<=FCCdipProductionModesMax do
   begin
      if FCDdgEntities[ EDAPentity ].E_colonies[ EDAPcolony ].C_settlements[ EDAPsettlement ].S_infrastructures[ EDAPownedInfra ].I_fProdProductionMode[ EDAPpmodeCount ].PM_type>pmNone
      then FCMgPM_EnableDisable_Process(
         EDAPentity
         ,EDAPcolony
         ,EDAPsettlement
         ,EDAPownedInfra
         ,EDAPpmodeCount
         ,EDAPisToEnable
         ,false
         )
      else Break;
      inc( EDAPpmodeCount );
   end;
end;

procedure FCMgPM_ProductionModeDataFromFunction_Generate(
   const PMDFFGent
         ,PMDFFGcol
         ,PMDFFGsett
         ,PMDFFGinfra
         ,PMDFFGinfraLevel: integer;
   const PMDFFGinfraData: TFCRdipInfrastructure
   );
{:Purpose: generate the production modes' data from the infrastructure's function.
    Additions:
      -2012Jun03- *add: complete pmWaterRecovery by adding calculation for the atmosphere humidity part and the energy consumption.
      -2012May30- *add: pmWaterRecovery.
      -2012Feb14- *mod: pmResourceMining - new calculation of the energy consumption.
      -2011Dec04- *add: Resource Mining (COMPLETION).
      -2011Dec04- *add: Resource Mining (WIP).
      -2011Nov14- *add: code framewrok inclusion + Resource Mining (WIP).
}
   var
      InfraProdModeCount
      ,ProdModeDataI1
      ,PMDFFGstaffTechIndex
      ,ProdModeDataI2
      ,ProdModeDataI3
      ,PMDFFGsurveyedSpot: integer;

      ProdModeDataF1
      ,ProdModeDataF2
      ,ProdModeDataF3
      ,ProdModeDataF4
      ,ProdModeDataF5
      ,ProdModeDataF6: extended;

      ColonyEnvironment: TFCRgcEnvironment;

      AtmosphereGases: TFCRufAtmosphereGases;

      OrbObjRow: TFCRufStelObj;
begin
   InfraProdModeCount:=1;
   while InfraProdModeCount<=FCCdipProductionModesMax do
   begin
      if PMDFFGinfraData.I_fPmodeStructure[InfraProdModeCount].MS_occupancy>0 then
      begin
         case PMDFFGinfraData.I_fPmodeStructure[InfraProdModeCount].MS_mode of
            pmNone: break;

            pmResourceMining:
            begin
               {.resource mining production / production mode's energy consumption}
               ProdModeDataF1:=0;
               {.RMP for carbonaceous ore}
               ProdModeDataF2:=0;
               {.RMP for metallic ore}
               ProdModeDataF3:=0;
               {.RMP for rare metal}
               ProdModeDataF4:=0;
               {.RMP for uranium}
               ProdModeDataF5:=0;
               {.resource spot index}
               ProdModeDataI1:=0;
               {.surveyed region index}
               ProdModeDataI2:=0;
               {.staff colonists index}
               ProdModeDataI3:=0;
               {.calculations}
               FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_settlements[PMDFFGsett].S_infrastructures[PMDFFGinfra].I_fProdProductionMode[InfraProdModeCount].PM_type:=PMDFFGinfraData.I_fPmodeStructure[InfraProdModeCount].MS_mode;
               PMDFFGsurveyedSpot:=FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_settlements[PMDFFGsett].S_infrastructures[PMDFFGinfra].I_fProdSurveyedSpot;
               {.surveyed region index}
               ProdModeDataI2:=FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_settlements[PMDFFGsett].S_infrastructures[PMDFFGinfra].I_fProdSurveyedRegion;
               {.resource spot index}
               ProdModeDataI1:=FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_settlements[PMDFFGsett].S_infrastructures[PMDFFGinfra].I_fProdResourceSpot;
               {.resource mining production calculation}
               ProdModeDataF1:=( ( power( PMDFFGinfraData.I_surface[PMDFFGinfraLevel], 0.333 ) + power( PMDFFGinfraData.I_volume[PMDFFGinfraLevel], 0.111 ) )*0.5 )
                  * FCDdgEntities[PMDFFGent].E_surveyedResourceSpots[PMDFFGsurveyedSpot].SRS_surveyedRegions[ProdModeDataI2].SR_ResourceSpots[ProdModeDataI1].RS_meanQualityCoefficient
                  * (PMDFFGinfraData.I_fPmodeStructure[InfraProdModeCount].MS_occupancy*0.01);
               if PMDFFGinfraData.I_reqResourceSpot=rstIcyOreField then
               begin
                  ProdModeDataF1:=FCFcF_Round( rttVolume, ProdModeDataF1 );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,InfraProdModeCount
                     ,'resIcyOre'
                     ,ProdModeDataF1
                     );
               end
               else begin
                  ProdModeDataF2:=ProdModeDataF1*( FCDdgEntities[PMDFFGent].E_surveyedResourceSpots[PMDFFGsurveyedSpot].SRS_surveyedRegions[ProdModeDataI2].SR_ResourceSpots[ProdModeDataI1].RS_tOFiCarbonaceous*0.01 );
                  ProdModeDataF2:=FCFcF_Round( rttVolume, ProdModeDataF2 );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,InfraProdModeCount
                     ,'resCarbOre'
                     ,ProdModeDataF2
                     );
                  ProdModeDataF3:=ProdModeDataF1*( FCDdgEntities[PMDFFGent].E_surveyedResourceSpots[PMDFFGsurveyedSpot].SRS_surveyedRegions[ProdModeDataI2].SR_ResourceSpots[ProdModeDataI1].RS_tOFiMetallic*0.01 );
                  ProdModeDataF3:=FCFcF_Round( rttVolume, ProdModeDataF3 );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,InfraProdModeCount
                     ,'resMetalOre'
                     ,ProdModeDataF3
                     );
                  ProdModeDataF4:=ProdModeDataF1*( FCDdgEntities[PMDFFGent].E_surveyedResourceSpots[PMDFFGsurveyedSpot].SRS_surveyedRegions[ProdModeDataI2].SR_ResourceSpots[ProdModeDataI1].RS_tOFiRare*0.01 );
                  ProdModeDataF4:=FCFcF_Round( rttVolume, ProdModeDataF4 );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,InfraProdModeCount
                     ,'resRareMetOre'
                     ,ProdModeDataF4
                     );
                  ProdModeDataF5:=ProdModeDataF1*( FCDdgEntities[PMDFFGent].E_surveyedResourceSpots[PMDFFGsurveyedSpot].SRS_surveyedRegions[ProdModeDataI2].SR_ResourceSpots[ProdModeDataI1].RS_tOFiUranium*0.01 );
                  ProdModeDataF5:=FCFcF_Round( rttVolume, ProdModeDataF5 );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,InfraProdModeCount
                     ,'resUrOre'
                     ,ProdModeDataF5
                     );
               end;
               {.staff colonists index}
               ProdModeDataI3:=FCFgIS_IndexByData_Retrieve( ptColonist, PMDFFGinfraData );
               PMDFFGstaffTechIndex:=FCFgIS_IndexByData_Retrieve( ptTechnician, PMDFFGinfraData );
               ColonyEnvironment:=FCFgC_ColEnv_GetTp( PMDFFGent, PMDFFGcol );
               {.energy consumption calculation}
               ProdModeDataF1:=(
                  ( PMDFFGinfraData.I_reqStaff[ProdModeDataI3].RS_requiredByLv[ PMDFFGinfraLevel ]*2 )
                  +( int( PMDFFGinfraData.I_reqStaff[PMDFFGstaffTechIndex].RS_requiredByLv[ PMDFFGinfraLevel ] /3 )*354 )
                  )
                  *( 1-( 1-ColonyEnvironment.ENV_gravity ) );
               FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_settlements[PMDFFGsett].S_infrastructures[PMDFFGinfra].I_fProdProductionMode[InfraProdModeCount].PM_energyConsumption:=FCFcF_Round( rttPowerKw, ProdModeDataF1 );
            end; //==END== case of: pmResourceMining ==//

            pmWaterRecovery:
            begin
               {.cmyr / production mode's energy consumption}
               ProdModeDataF1:=0;
               {.l/m2 for 1cm rainfall}
               ProdModeDataF2:=9.94507683310307;
               {.universal process efficiency}
               ProdModeDataF3:=0.95;
               {.precipitations calculations}
               ProdModeDataF4:=0;
               {.region's windspeed}
               ProdModeDataF5:=0;
               {.atmospheric humidity calculations}
               ProdModeDataF6:=0;
               {.settlement's region number}
               ProdModeDataI1:=FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_settlements[PMDFFGsett].S_locationRegion;
               {.region's precipitations}
               ProdModeDataI2:=0;
               {.H2O gas status}
               ProdModeDataI3:=0;
               {.we retrieve the colony's orbital object indexes}
               OrbObjRow:=FCFuF_StelObj_GetFullRow(
                  FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_locationStarSystem
                  ,FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_locationStar
                  ,FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_locationOrbitalObject
                  ,FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_locationSatellite
                  );
               {.calculations}
               FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_settlements[PMDFFGsett].S_infrastructures[PMDFFGinfra].I_fProdProductionMode[InfraProdModeCount].PM_type:=PMDFFGinfraData.I_fPmodeStructure[InfraProdModeCount].MS_mode;
               if OrbObjRow[ 4 ]=0 then
               begin
                  {.region's rainfall}
                  ProdModeDataI2:=FCDduStarSystem[ OrbObjRow[ 1 ] ].SS_stars[ OrbObjRow[ 2 ] ].S_orbitalObjects[ OrbObjRow[ 3 ] ].OO_regions[ ProdModeDataI1 ].OOR_currentRainfall;
                  {.region's windspeed}
                  ProdModeDataF5:=FCDduStarSystem[ OrbObjRow[ 1 ] ].SS_stars[ OrbObjRow[ 2 ] ].S_orbitalObjects[ OrbObjRow[ 3 ] ].OO_regions[ ProdModeDataI1 ].OOR_currentWindspeed;
                  {.H2O gas status}
                  ProdModeDataI3:=Integer(FCDduStarSystem[ OrbObjRow[ 1 ] ].SS_stars[ OrbObjRow[ 2 ] ].S_orbitalObjects[ OrbObjRow[ 3 ] ].OO_atmosphere.AC_gasPresenceH2O);
                  if FCVdiDebugMode
                  then FCWinDebug.AdvMemo1.Lines.Add('H2O gas status='+inttostr(ProdModeDataI3));
               end
               else if OrbObjRow[ 4 ]>0 then
               begin
                  {.region's precipitations}
                  ProdModeDataI2:=FCDduStarSystem[ OrbObjRow[ 1 ] ].SS_stars[ OrbObjRow[ 2 ] ].S_orbitalObjects[ OrbObjRow[ 3 ] ].OO_satellitesList[ OrbObjRow[ 4 ] ].OO_regions[ ProdModeDataI1 ].OOR_currentRainfall;
                  {.region's windspeed}
                  ProdModeDataF5:=FCDduStarSystem[ OrbObjRow[ 1 ] ].SS_stars[ OrbObjRow[ 2 ] ].S_orbitalObjects[ OrbObjRow[ 3 ] ].OO_satellitesList[ OrbObjRow[ 4 ] ].OO_regions[ ProdModeDataI1 ].OOR_currentWindspeed;
                  {.H2O gas status}
                  ProdModeDataI3:=Integer(FCDduStarSystem[ OrbObjRow[ 1 ] ].SS_stars[ OrbObjRow[ 2 ] ].S_orbitalObjects[ OrbObjRow[ 3 ] ].OO_satellitesList[ OrbObjRow[ 4 ] ].OO_atmosphere.AC_gasPresenceH2O);
               end;
               {.cmyr}
               ProdModeDataF1:=( ProdModeDataI2 / sqrt( ProdModeDataF5 ) )*0.1;
               {.precipitations calculations}
               ProdModeDataF4:=( ProdModeDataF1 * PMDFFGinfraData.I_fPmodeStructure[InfraProdModeCount].MS_mWRroofArea * ProdModeDataF2 * ProdModeDataF3 * 0.001 ) / 8760;
               {.format and update the production matrix}
               ProdModeDataF4:=FCFcF_Round( rttVolume, ProdModeDataF4 );
               FCMgPS2_ProductionMatrixItem_Add(
                  PMDFFGent
                  ,PMDFFGcol
                  ,PMDFFGsett
                  ,PMDFFGinfra
                  ,InfraProdModeCount
                  ,'resWater'
                  ,ProdModeDataF4
                  );
               {.atmosphere humidity calculations}
               AtmosphereGases.AGP_primaryGasPercent:=0;
               AtmosphereGases.AGP_secondaryGasPercent:=0;
               AtmosphereGases.AGP_traceGasPercent:=0;
               AtmosphereGases.CalculatePercents(
                  OrbObjRow[ 1 ]
                  ,OrbObjRow[ 2 ]
                  ,OrbObjRow[ 3 ]
                  ,OrbObjRow[ 4 ]
                  );
               {.atmospheric humidity calculations}
               if ProdModeDataI3=1
               then ProdModeDataF6:=AtmosphereGases.AGP_traceGasPercent * 0.01
               else if ProdModeDataI3=2
               then ProdModeDataF6:=AtmosphereGases.AGP_secondaryGasPercent * 0.01
               else if ProdModeDataI3=3
               then ProdModeDataF6:=AtmosphereGases.AGP_primaryGasPercent * 0.01;
               ProdModeDataF6:=ProdModeDataF6 * ( AtmosphereGases.AGP_atmosphericPressure * 0.001 ) * PMDFFGinfraData.I_fPmodeStructure[InfraProdModeCount].MS_mWRtrapArea;
               {.energy consumption calculations}
               ProdModeDataF1:=FCFgICFX_EffectStorageLiquid_Search( PMDFFGinfraData, PMDFFGinfraLevel );
               ProdModeDataF1:=ProdModeDataF1 / 4.5 * 1.1;
               FCDdgEntities[PMDFFGent].E_colonies[PMDFFGcol].C_settlements[PMDFFGsett].S_infrastructures[PMDFFGinfra].I_fProdProductionMode[InfraProdModeCount].PM_energyConsumption:=FCFcF_Round( rttPowerKw, ProdModeDataF1 );
            end; //==END== case of: pmWaterRecovery ==//
         end; //==END== case PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_productionModes of ==//
      end //==END== if PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_occupancy>0 then ==//
      else Break;
      inc(InfraProdModeCount);
   end; //==END== while PMDFFGcnt<=FCCpModeMax do ==//
end;

end.
