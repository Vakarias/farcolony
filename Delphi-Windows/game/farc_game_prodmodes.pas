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
      then FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PM_isDisabled:=false;
      FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_powerCons:=
         FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_powerCons
         +FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PM_energyCons
         ;
      FCMgCSM_Energy_Update(
         EDPentity
         ,EDPcolony
         ,false
         ,FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PM_energyCons
         ,0
         ,0
         ,0
         );
      EDPpmiCount:=1;
      while EDPpmiCount<=FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PM_matrixItemMax do
      begin
         EDPprodMatrixIndex:=
            FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PF_linkedMatrixItemIndexes[ EDPpmiCount ].LMII_matrixItmIndex;
         EDPprodModeIndex:=
            FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PF_linkedMatrixItemIndexes[ EDPpmiCount ].LMII_matrixProdModeIndex;
         FCentities[ EDPentity ].E_col[ EDPcolony ].COL_productionMatrix[ EDPprodMatrixIndex ].CPMI_globalProdFlow:=
            FCentities[ EDPentity ].E_col[ EDPcolony ].COL_productionMatrix[ EDPprodMatrixIndex ].CPMI_globalProdFlow
            +FCentities[ EDPentity ].E_col[ EDPcolony ].COL_productionMatrix[ EDPprodMatrixIndex ].CPMI_productionModes[ EDPprodModeIndex ].PF_productionFlow
            ;
         if EDPifFromProd
         then FCEntities[ EDPentity ].E_col[ EDPcolony ].COL_productionMatrix[ EDPprodMatrixIndex ].CPMI_productionModes[ EDPprodModeIndex ].PF_isDisabledByProdSegment:=false;
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
      then FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PM_isDisabled:=true;
      FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_powerCons:=
         FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_powerCons
         -FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PM_energyCons
         ;
      FCMgCSM_Energy_Update(
         EDPentity
         ,EDPcolony
         ,false
         ,-FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PM_energyCons
         ,0
         ,0
         ,0
         );
      EDPpmiCount:=1;
      while EDPpmiCount<=FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PM_matrixItemMax do
      begin
         EDPprodMatrixIndex:=
            FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PF_linkedMatrixItemIndexes[ EDPpmiCount ].LMII_matrixItmIndex;
         EDPprodModeIndex:=
            FCentities[ EDPentity ].E_col[ EDPcolony ].COL_settlements[ EDPsettlement ].CS_infra[ EDPownedInfra ].CI_fprodMode[ EDPproductionMode ].PF_linkedMatrixItemIndexes[ EDPpmiCount ].LMII_matrixProdModeIndex;
         FCentities[ EDPentity ].E_col[ EDPcolony ].COL_productionMatrix[ EDPprodMatrixIndex ].CPMI_globalProdFlow:=
            FCentities[ EDPentity ].E_col[ EDPcolony ].COL_productionMatrix[ EDPprodMatrixIndex ].CPMI_globalProdFlow
            -FCentities[ EDPentity ].E_col[ EDPcolony ].COL_productionMatrix[ EDPprodMatrixIndex ].CPMI_productionModes[ EDPprodModeIndex ].PF_productionFlow
            ;
         if EDPifFromProd
         then FCEntities[ EDPentity ].E_col[ EDPcolony ].COL_productionMatrix[ EDPprodMatrixIndex ].CPMI_productionModes[ EDPprodModeIndex ].PF_isDisabledByProdSegment:=true;
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
   while EDAPpmodeCount<=FCCpModeMax do
   begin
      if FCentities[ EDAPentity ].E_col[ EDAPcolony ].COL_settlements[ EDAPsettlement ].CS_infra[ EDAPownedInfra ].CI_fprodMode[ EDAPpmodeCount ].PM_type>pmNone
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

      AtmosphereGases: TFCRufAtmosphereGasesPercent;

      OrbObjRow: TFCRufStelObj;
begin
   InfraProdModeCount:=1;
   while InfraProdModeCount<=FCCpModeMax do
   begin
      if PMDFFGinfraData.I_fProductionMode[InfraProdModeCount].IPM_occupancy>0 then
      begin
         case PMDFFGinfraData.I_fProductionMode[InfraProdModeCount].IPM_productionModes of
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
               FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodMode[InfraProdModeCount].PM_type:=PMDFFGinfraData.I_fProductionMode[InfraProdModeCount].IPM_productionModes;
               PMDFFGsurveyedSpot:=FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodSurveyedSpot;
               {.surveyed region index}
               ProdModeDataI2:=FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodSurveyedRegion;
               {.resource spot index}
               ProdModeDataI1:=FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodResourceSpot;
               {.resource mining production calculation}
               ProdModeDataF1:=( ( power( PMDFFGinfraData.I_surface[PMDFFGinfraLevel], 0.333 ) + power( PMDFFGinfraData.I_volume[PMDFFGinfraLevel], 0.111 ) )*0.5 )
                  * FCRplayer.P_surveyedSpots[PMDFFGsurveyedSpot].SS_surveyedRegions[ProdModeDataI2].SR_ResourceSpot[ProdModeDataI1].RS_MQC
                  * (PMDFFGinfraData.I_fProductionMode[InfraProdModeCount].IPM_occupancy*0.01);
               if PMDFFGinfraData.I_reqRsrcSpot=rstIcyOreField then
               begin
                  ProdModeDataF1:=FCFcFunc_Rnd( cfrttpVolm3, ProdModeDataF1 );
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
                  ProdModeDataF2:=ProdModeDataF1*( FCRplayer.P_surveyedSpots[PMDFFGsurveyedSpot].SS_surveyedRegions[ProdModeDataI2].SR_ResourceSpot[ProdModeDataI1].RS_oreCarbonaceous*0.01 );
                  ProdModeDataF2:=FCFcFunc_Rnd( cfrttpVolm3, ProdModeDataF2 );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,InfraProdModeCount
                     ,'resCarbOre'
                     ,ProdModeDataF2
                     );
                  ProdModeDataF3:=ProdModeDataF1*( FCRplayer.P_surveyedSpots[PMDFFGsurveyedSpot].SS_surveyedRegions[ProdModeDataI2].SR_ResourceSpot[ProdModeDataI1].RS_oreMetallic*0.01 );
                  ProdModeDataF3:=FCFcFunc_Rnd( cfrttpVolm3, ProdModeDataF3 );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,InfraProdModeCount
                     ,'resMetalOre'
                     ,ProdModeDataF3
                     );
                  ProdModeDataF4:=ProdModeDataF1*( FCRplayer.P_surveyedSpots[PMDFFGsurveyedSpot].SS_surveyedRegions[ProdModeDataI2].SR_ResourceSpot[ProdModeDataI1].RS_oreRare*0.01 );
                  ProdModeDataF4:=FCFcFunc_Rnd( cfrttpVolm3, ProdModeDataF4 );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,InfraProdModeCount
                     ,'resRareMetOre'
                     ,ProdModeDataF4
                     );
                  ProdModeDataF5:=ProdModeDataF1*( FCRplayer.P_surveyedSpots[PMDFFGsurveyedSpot].SS_surveyedRegions[ProdModeDataI2].SR_ResourceSpot[ProdModeDataI1].RS_oreUranium*0.01 );
                  ProdModeDataF5:=FCFcFunc_Rnd( cfrttpVolm3, ProdModeDataF5 );
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
               FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodMode[InfraProdModeCount].PM_energyCons:=FCFcFunc_Rnd( rttPowerKw, ProdModeDataF1 );
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
               ProdModeDataI1:=FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_region;
               {.region's precipitations}
               ProdModeDataI2:=0;
               {.H2O gas status}
               ProdModeDataI3:=0;
               {.we retrieve the colony's orbital object indexes}
               OrbObjRow:=FCFuF_StelObj_GetFullRow(
                  FCentities[PMDFFGent].E_col[PMDFFGcol].COL_locSSys
                  ,FCentities[PMDFFGent].E_col[PMDFFGcol].COL_locStar
                  ,FCentities[PMDFFGent].E_col[PMDFFGcol].COL_locOObj
                  ,FCentities[PMDFFGent].E_col[PMDFFGcol].COL_locSat
                  );
               {.calculations}
               FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodMode[InfraProdModeCount].PM_type:=PMDFFGinfraData.I_fProductionMode[InfraProdModeCount].IPM_productionModes;
               if OrbObjRow[ 4 ]=0 then
               begin
                  {.region's precipitations}
                  ProdModeDataI2:=FCDBSSys[ OrbObjRow[ 1 ] ].SS_star[ OrbObjRow[ 2 ] ].SDB_obobj[ OrbObjRow[ 3 ] ].OO_regions[ ProdModeDataI1 ].OOR_precip;
                  {.region's windspeed}
                  ProdModeDataF5:=FCDBSSys[ OrbObjRow[ 1 ] ].SS_star[ OrbObjRow[ 2 ] ].SDB_obobj[ OrbObjRow[ 3 ] ].OO_regions[ ProdModeDataI1 ].OOR_windSpd;
                  {.H2O gas status}
                  ProdModeDataI3:=Integer(FCDBSSys[ OrbObjRow[ 1 ] ].SS_star[ OrbObjRow[ 2 ] ].SDB_obobj[ OrbObjRow[ 3 ] ].OO_atmosph.agasH2O);
                  if FCVdiDebugMode
                  then FCWinDebug.AdvMemo1.Lines.Add('H2O gas status='+inttostr(ProdModeDataI3));
               end
               else if OrbObjRow[ 4 ]>0 then
               begin
                  {.region's precipitations}
                  ProdModeDataI2:=FCDBSSys[ OrbObjRow[ 1 ] ].SS_star[ OrbObjRow[ 2 ] ].SDB_obobj[ OrbObjRow[ 3 ] ].OO_satList[ OrbObjRow[ 4 ] ].OOS_regions[ ProdModeDataI1 ].OOR_precip;
                  {.region's windspeed}
                  ProdModeDataF5:=FCDBSSys[ OrbObjRow[ 1 ] ].SS_star[ OrbObjRow[ 2 ] ].SDB_obobj[ OrbObjRow[ 3 ] ].OO_satList[ OrbObjRow[ 4 ] ].OOS_regions[ ProdModeDataI1 ].OOR_windSpd;
                  {.H2O gas status}
                  ProdModeDataI3:=Integer(FCDBSSys[ OrbObjRow[ 1 ] ].SS_star[ OrbObjRow[ 2 ] ].SDB_obobj[ OrbObjRow[ 3 ] ].OO_satList[ OrbObjRow[ 4 ] ].OOS_atmosph.agasH2O);
               end;
               {.cmyr}
               ProdModeDataF1:=( ProdModeDataI2 / sqrt( ProdModeDataF5 ) )*0.1;
               {.precipitations calculations}
               ProdModeDataF4:=( ProdModeDataF1 * PMDFFGinfraData.I_fProductionMode[InfraProdModeCount].WR_roofarea * ProdModeDataF2 * ProdModeDataF3 * 0.001 ) / 8760;
               {.format and update the production matrix}
               ProdModeDataF4:=FCFcFunc_Rnd( cfrttpVolm3, ProdModeDataF4 );
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
               AtmosphereGases.AtmosphereGases_CalculatePercents(
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
               ProdModeDataF6:=ProdModeDataF6 * ( AtmosphereGases.AGP_atmosphericPressure * 0.001 ) * PMDFFGinfraData.I_fProductionMode[InfraProdModeCount].WR_traparea;
               {.energy consumption calculations}
               ProdModeDataF1:=FCFgICFX_EffectStorageLiquid_Search( PMDFFGinfraData, PMDFFGinfraLevel );
               ProdModeDataF1:=ProdModeDataF1 / 4.5 * 1.1;
               FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodMode[InfraProdModeCount].PM_energyCons:=FCFcFunc_Rnd( rttPowerKw, ProdModeDataF1 );
            end; //==END== case of: pmWaterRecovery ==//
         end; //==END== case PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_productionModes of ==//
      end //==END== if PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_occupancy>0 then ==//
      else Break;
      inc(InfraProdModeCount);
   end; //==END== while PMDFFGcnt<=FCCpModeMax do ==//
end;

end.
