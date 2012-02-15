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
   ,farc_data_univ
   ,farc_game_colony
   ,farc_game_csm
   ,farc_game_infrastaff
   ,farc_game_prodSeg2
   ,farc_ui_coredatadisplay
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
      -2012Feb14- *mod: pmResourceMining - new calculation of the energy consumption.
      -2011Dec04- *add: Resource Mining (COMPLETION).
      -2011Dec04- *add: Resource Mining (WIP).
      -2011Nov14- *add: code framewrok inclusion + Resource Mining (WIP).
}
   var
      PMDFFGcnt
      ,PMDFFGresourceSpot
      ,PMDFFGstaffColonIndex
      ,PMDFFGstaffTechIndex
      ,PMDFFGsurveyedRegion
      ,PMDFFGsurveyedSpot: integer;

      PMDFFGresCarbonace
      ,PMDFFGresMetallic
      ,PMDFFGresRareMetal
      ,PMDFFGresUranium
      ,PMDFFGrmp: extended;

      PMDFFGenv: TFCRgcEnvironment;
begin
   PMDFFGcnt:=1;
   while PMDFFGcnt<=FCCpModeMax do
   begin
      if PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_occupancy>0 then
      begin
         case PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_productionModes of
            pmNone: break;

            pmResourceMining:
            begin
               FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodMode[PMDFFGcnt].PM_type:=PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_productionModes;
               PMDFFGsurveyedSpot:=FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodSurveyedSpot;
               PMDFFGsurveyedRegion:=FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodSurveyedRegion;
               PMDFFGresourceSpot:=FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodResourceSpot;
               PMDFFGrmp:=( ( power( PMDFFGinfraData.I_surface[PMDFFGinfraLevel], 0.333 ) + power( PMDFFGinfraData.I_volume[PMDFFGinfraLevel], 0.111 ) )*0.5 )
                  * FCRplayer.P_surveyedSpots[PMDFFGsurveyedSpot].SS_surveyedRegions[PMDFFGsurveyedRegion].SR_ResourceSpot[PMDFFGresourceSpot].RS_MQC
                  * (PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_occupancy*0.01);
               if PMDFFGinfraData.I_reqRsrcSpot=rstIcyOreField then
               begin
                  PMDFFGrmp:=FCFcFunc_Rnd( cfrttpVolm3, PMDFFGrmp );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,PMDFFGcnt
                     ,'resIcyOre'
                     ,PMDFFGrmp
                     );
               end
               else begin
                  PMDFFGresCarbonace:=PMDFFGrmp*( FCRplayer.P_surveyedSpots[PMDFFGsurveyedSpot].SS_surveyedRegions[PMDFFGsurveyedRegion].SR_ResourceSpot[PMDFFGresourceSpot].RS_oreCarbonaceous*0.01 );
                  PMDFFGresCarbonace:=FCFcFunc_Rnd( cfrttpVolm3, PMDFFGresCarbonace );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,PMDFFGcnt
                     ,'resCarbOre'
                     ,PMDFFGresCarbonace
                     );
                  PMDFFGresMetallic:=PMDFFGrmp*( FCRplayer.P_surveyedSpots[PMDFFGsurveyedSpot].SS_surveyedRegions[PMDFFGsurveyedRegion].SR_ResourceSpot[PMDFFGresourceSpot].RS_oreMetallic*0.01 );
                  PMDFFGresMetallic:=FCFcFunc_Rnd( cfrttpVolm3, PMDFFGresMetallic );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,PMDFFGcnt
                     ,'resMetalOre'
                     ,PMDFFGresMetallic
                     );
                  PMDFFGresRareMetal:=PMDFFGrmp*( FCRplayer.P_surveyedSpots[PMDFFGsurveyedSpot].SS_surveyedRegions[PMDFFGsurveyedRegion].SR_ResourceSpot[PMDFFGresourceSpot].RS_oreRare*0.01 );
                  PMDFFGresRareMetal:=FCFcFunc_Rnd( cfrttpVolm3, PMDFFGresRareMetal );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,PMDFFGcnt
                     ,'resRareMetOre'
                     ,PMDFFGresRareMetal
                     );
                  PMDFFGresUranium:=PMDFFGrmp*( FCRplayer.P_surveyedSpots[PMDFFGsurveyedSpot].SS_surveyedRegions[PMDFFGsurveyedRegion].SR_ResourceSpot[PMDFFGresourceSpot].RS_oreUranium*0.01 );
                  PMDFFGresUranium:=FCFcFunc_Rnd( cfrttpVolm3, PMDFFGresUranium );
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,PMDFFGcnt
                     ,'resUrOre'
                     ,PMDFFGresUranium
                     );
               end;
               PMDFFGstaffColonIndex:=FCFgIS_IndexByData_Retrieve( ptColonist, PMDFFGinfraData );
               PMDFFGstaffTechIndex:=FCFgIS_IndexByData_Retrieve( ptTechnic, PMDFFGinfraData );
               PMDFFGenv:=FCFgC_ColEnv_GetTp( PMDFFGent, PMDFFGcol );
               PMDFFGrmp:=(
                  ( sqrt( PMDFFGinfraData.I_reqStaff[PMDFFGstaffColonIndex].RS_requiredByLv[ PMDFFGinfraLevel ] )*0.5 )
                  +( int( PMDFFGinfraData.I_reqStaff[PMDFFGstaffTechIndex].RS_requiredByLv[ PMDFFGinfraLevel ] /3 )*354 )
                  )
                  *( 1-( 1-PMDFFGenv.ENV_gravity ) );
               FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodMode[PMDFFGcnt].PM_energyCons:=FCFcFunc_Rnd( rttPowerKw, PMDFFGrmp );
            end;
         end; //==END== case PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_productionModes of ==//
      end //==END== if PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_occupancy>0 then ==//
      else Break;
      inc(PMDFFGcnt);
   end; //==END== while PMDFFGcnt<=FCCpModeMax do ==//
end;

end.
