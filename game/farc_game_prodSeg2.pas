{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: production phase - segment 2 products/items production

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
unit farc_game_prodSeg2;

interface

///<summary>
///   search a specified product in a specified colony's production matrix
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="ProductToFind">product's token</param>
///   <returns>0 if not found, >0 => production matrix's index # if found</returns>
function FCFgPS2_ProductionMatrixItem_Search(
   const Entity
         ,Colony: integer;
   const ProductToFind: string
   ): integer;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   add a production item in a colony's production matrix
///</summary>
///   <param name="PIAent">entity index #</param>
///   <param name="PIAcol">colony index #</param>
///   <param name="PIAsettlement">settlement index #</param>
///   <param name="PIAownedInfra">owned infrastructure index #</param>
///   <param name="PIAprodModeIndex">owned infrastructure's production mode index #</param>
///   <param name="PIAproduct">product's token</param>
///   <param name="PIAproductionFlow">production flow in product's unit/hr (override number)</param>
procedure FCMgPS2_ProductionMatrixItem_Add(
   const PIAent
         ,PIAcol
         ,PIAsettlement
         ,PIAownedInfra
         ,PIAprodModeIndex: integer;
   const PIAproduct: string;
   const PIAproductionFlow: extended
   );

///<summary>
///   segment 2 (items production) processing
///</summary>
///   <param name="PSPent">entity index #</param>
///   <param name="PSPcol">colony index #</param>
procedure FCMgPS2_ProductionSegment_Process(
   const PSPent
         ,PSPcol: integer
   );

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_infrprod
   ,farc_game_colony
   ,farc_game_prod
   ,farc_game_prodmodes
   ,farc_ui_coredatadisplay
   ,farc_win_debug;

//===================================================END OF INIT============================

function FCFgPS2_ProductionMatrixItem_Search(
   const Entity
         ,Colony: integer;
   const ProductToFind: string
   ): integer;
{:Purpose: search a specified product in a specified colony's production matrix.
    Additions:
}
   var
      Count
      ,Max: integer;
begin
   Result:=0;
   Max:=Length( FCentities[ Entity ].E_col[ Colony ].COL_productionMatrix )-1;
   Count:=1;
   while Count<=Max do
   begin
      if FCentities[ Entity ].E_col[ Colony ].COL_productionMatrix[ Count ].CPMI_productToken=ProductToFind then
      begin
         Result:=Count;
         break;
      end
      else inc( Count );
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgPS2_ProductionMatrixItem_Add(
   const PIAent
         ,PIAcol
         ,PIAsettlement
         ,PIAownedInfra
         ,PIAprodModeIndex: integer;
   const PIAproduct: string;
   const PIAproductionFlow: extended
   );
{:Purpose: add a production item in a colony's production matrix.
    Additions:
      -2012Jan18- *add: if a production matrix item need to be created, the colony data panel is updated if required.
      -2012Jan11- *add: load the CPMI_storageType.
      -2011Dec12- *fix: update the global production flow only if the production mode is enabled.
      -2011Dec11- *mod: the production matrix' global production flow value isn't updated when the production mode is created and set as disabled.
      -2011Dec08- *mod: if the production mode, inside the production matrix, is created, it is disabled by default. The reason is that a production mode is created only in case of a new infrastructure.
      -2011Dec06- *add: completion of procedure basics.
      -2011Dec05- *add: Work In Progress of the procedure basics.
}
   var
      PIApmCount
      ,PIApmMax
      ,PIApmodeCount
      ,PIApmodeMax
      ,PIAprodMatrixFound
      ,PIAstorageIndex
      ,ProductIndex: integer;

      PIAisPModeCreated: boolean;
begin
   PIAprodMatrixFound:=0;
   PIAstorageIndex:=0;
   ProductIndex:=0;
   PIAisPModeCreated:=false;
   PIApmCount:=1;
   {.first, the production matrix item is tested if it already created}
   PIApmMax:=Length( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix )-1;
   while PIApmCount<=PIApmMax do
   begin
      if FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIApmCount ].CPMI_productToken=PIAproduct then
      begin
         PIAprodMatrixFound:=PIApmCount;
         PIApmodeMax:=Length( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIApmCount ].CPMI_productionModes )-1;
         PIApmodeCount:=1;
         while PIApmodeCount<=PIApmodeMax do
         begin
            if ( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIApmCount ].CPMI_productionModes[ PIApmodeCount ].PF_locSettlement=PIAsettlement )
               and ( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIApmCount ].CPMI_productionModes[ PIApmodeCount ].PF_locInfra=PIAownedInfra )
               and ( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIApmCount ].CPMI_productionModes[ PIApmodeCount ].PF_locProdModeIndex=PIAprodModeIndex ) then
            begin
               FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIApmCount ].CPMI_productionModes[ PIApmodeCount ].PF_productionFlow:=PIAproductionFlow;
               if not FCentities[ PIAent ].E_col[ PIAcol ].COL_settlements[ PIAsettlement ].CS_infra[ PIAownedInfra ].CI_fprodMode[ PIAprodModeIndex ].PM_isDisabled
               then FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIApmCount ].CPMI_globalProdFlow:=
                  FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIApmCount ].CPMI_globalProdFlow
                  +FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIApmCount ].CPMI_productionModes[ PIApmodeCount ].PF_productionFlow
                  ;
               PIAisPModeCreated:=true;
               Break;
            end;
            inc( PIApmodeCount );
         end;
      end;
      if PIAisPModeCreated
      then Break
      else inc( PIApmCount );
   end;
   {.if not created, a new production matrix item is created and initialized}
   if not PIAisPModeCreated then
   begin

      if PIAprodMatrixFound=0 then
      begin
         if PIApmMax<=0
         then PIApmMax:=1
         else inc( PIApmMax );
         SetLength( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix, PIApmMax+1 );
         PIAprodMatrixFound:=PIApmMax;
         FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_productToken:=PIAproduct;
         PIAstorageIndex:=FCFgC_Storage_RetrieveIndex(
            PIAproduct
            ,PIAent
            ,PIAcol
            ,true
            );
         FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_storageIndex:=PIAstorageIndex;
         ProductIndex:=FCFgP_Product_GetIndex( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_productToken );
         FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_storageType:=FCDdipProducts[ ProductIndex ].P_storage;
         SetLength( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_productionModes, 1 );
         if PIAent=0
         then FCMuiCDD_Production_Update(
            plProdMatrixAll
            ,PIAcol
            ,PIAsettlement
            ,0
            );
      end;
      PIApmodeCount:=Length( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_productionModes );
      SetLength( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_productionModes, PIApmodeCount+1 );
      FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_productionModes[ PIApmodeCount ].PF_locSettlement:=PIAsettlement;
      FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_productionModes[ PIApmodeCount ].PF_locInfra:=PIAownedInfra;
      FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_productionModes[ PIApmodeCount ].PF_locProdModeIndex:=PIAprodModeIndex;
      FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_productionModes[ PIApmodeCount ].PF_isDisabledByProdSegment:=false;
      FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_productionModes[ PIApmodeCount ].PF_productionFlow:=PIAproductionFlow;
      inc( FCentities[ PIAent ].E_col[ PIAcol ].COL_settlements[ PIAsettlement ].CS_infra[ PIAownedInfra ].CI_fprodMode[ PIAprodModeIndex ].PM_matrixItemMax );
      PIApmCount:=FCentities[ PIAent ].E_col[ PIAcol ].COL_settlements[ PIAsettlement ].CS_infra[ PIAownedInfra ].CI_fprodMode[ PIAprodModeIndex ].PM_matrixItemMax;
      FCentities[ PIAent ].E_col[ PIAcol ].COL_settlements[ PIAsettlement ].CS_infra[ PIAownedInfra ].CI_fprodMode[ PIAprodModeIndex ].PM_isDisabled:=true;
      FCentities[ PIAent ].E_col[ PIAcol ].COL_settlements[ PIAsettlement ].CS_infra[ PIAownedInfra ].CI_fprodMode[ PIAprodModeIndex ].PF_linkedMatrixItemIndexes[ PIApmCount ].LMII_matrixItmIndex:=PIAprodMatrixFound;
      FCentities[ PIAent ].E_col[ PIAcol ].COL_settlements[ PIAsettlement ].CS_infra[ PIAownedInfra ].CI_fprodMode[ PIAprodModeIndex ].PF_linkedMatrixItemIndexes[ PIApmCount ].LMII_matrixProdModeIndex:=PIApmodeCount;

   end;
end;

{:DEV NOTES: add private FCMgPS2_ProductionReverse_Process and xfer RevertProduction.}

procedure FCMgPS2_ProductionSegment_Process(
   const PSPent
         ,PSPcol: integer
   );
   {:DEV NOTES: there's an error in case an infrastructure have on prodmode including multiples matrix items BUT WITH <> .}
{:Purpose:  segment 2 (items production) processing.
    Additions:
      -2012Mar20- *fix: correction in the tests with negative production flow.
      -2012Jan16- *add: in case of a positive production flow that overload a storage, the corresponding 'Full' boolean is updated.
                  *fix: correction of some logical errors.
      -2012Jan12- *add: in case of a storage reached its max capacity, and in case of a positive production flow, revert and disable the production of a product (COMPLETION).
      -2012Jan11- *add: in case of a storage reached its max capacity, and in case of a positive production flow, revert and disable the production of a product (Work In Progress).
      -2012Jan09- *add: update the colony data panel / storage display if needed.
      -2011Dec19- *add: rule foundation, COMPLETION.
      -2011Dec18- *add: rule foundation, work-in-progress.
}
   type prodMatrixDisabled=record
      matrixItemIndex: integer;
      prodModeIndex: integer;
   end;

   var
      ColonyProdMatrixIdx
      ,InfraPModeLinkedMatrixItmIdx
      ,ColonyPMatrixPModeIdx
      ,InfraToColonyLinkedMatrixIdx
      ,ColonyPMatrixPModesListMax
      ,PSPownedInfra
      ,PSPpmatrixDisIndex
      ,PSPpmatrixIndex
      ,PSPprodModeIndex
      ,PSPsettlement
      ,PSPstorageIndex: integer;
      ReturnPRod: extended;

      isMaxStorageSolidFull
      ,isMaxStorageLiquidFull
      ,isMaxStorageGasFull
      ,isMaxStorageBioFull: boolean;

      prodMatrixDisList: array of prodMatrixDisabled;

      procedure RevertProduction( isGlobalNegative: boolean);
      begin
         ColonyPMatrixPModesListMax:=length( FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_productionModes )-1;
         ColonyPMatrixPModeIdx:=1;
         while ColonyPMatrixPModeIdx<=ColonyPMatrixPModesListMax do
         begin
            if ( (isGlobalNegative) and ( FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_productionModes[ ColonyPMatrixPModeIdx ].PF_productionFlow<0 ) )
               or ( (not isGlobalNegative) and ( FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_productionModes[ ColonyPMatrixPModeIdx ].PF_productionFlow>0 ) ) then
            begin
               PSPsettlement:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_productionModes[ ColonyPMatrixPModeIdx ].PF_locSettlement;
               PSPownedInfra:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_productionModes[ ColonyPMatrixPModeIdx ].PF_locInfra;
               PSPprodModeIndex:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_productionModes[ ColonyPMatrixPModeIdx ].PF_locProdModeIndex;
               InfraPModeLinkedMatrixItmIdx:=1;
               while InfraPModeLinkedMatrixItmIdx<=FCEntities[ PSPent ].E_col[ PSPcol ].COL_settlements[ PSPsettlement ].CS_infra[ PSPownedInfra ].CI_fprodMode[ PSPprodModeIndex ].PM_matrixItemMax do
               begin
                  PSPpmatrixIndex:=
         FCEntities[ PSPent ].E_col[ PSPcol ].COL_settlements[ PSPsettlement ].CS_infra[ PSPownedInfra ].CI_fprodMode[ PSPprodModeIndex ].PF_linkedMatrixItemIndexes[ InfraPModeLinkedMatrixItmIdx ].LMII_matrixItmIndex;
                  if PSPpmatrixIndex<ColonyProdMatrixIdx then
                  begin
                     if FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_globalProdFlow<0
                     then FCFgC_Storage_Update(
                        FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_productToken
                        ,abs( FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_globalProdFlow )
                        ,PSPent
                        ,PSPcol
                        ,true
                        )
                     else if FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_globalProdFlow>0
                     then FCFgC_Storage_Update(
                        FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_productToken
                        ,-FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_globalProdFlow
                        ,PSPent
                        ,PSPcol
                        ,true
                        );
                  end
                  else if PSPpmatrixIndex>=ColonyProdMatrixIdx
                  then break;
                  inc( InfraPModeLinkedMatrixItmIdx );
               end;
               FCMgPM_EnableDisable_Process(
                  PSPent
                  ,PSPcol
                  ,PSPsettlement
                  ,PSPownedInfra
                  ,PSPprodModeIndex
                  ,false
                  ,true
                  );
               inc( PSPpmatrixDisIndex );
               setlength( prodMatrixDisList, PSPpmatrixDisIndex+1 );
               prodMatrixDisList[ PSPpmatrixDisIndex ].matrixItemIndex:=ColonyProdMatrixIdx;
               prodMatrixDisList[ PSPpmatrixDisIndex ].prodModeIndex:=ColonyPMatrixPModeIdx;
               if ( isGlobalNegative )
                  and ( FCEntities[PSPent].E_col[PSPcol].COL_storageList[ PSPstorageIndex ].CPR_unit>=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_globalProdFlow )
               then Break;
            end;
            inc( ColonyPMatrixPModeIdx );
         end;
      end;
begin
   if FCEntities[ PSPent ].E_col[ PSPcol ].COL_storCapacitySolidCurr<FCEntities[ PSPent ].E_col[ PSPcol ].COL_storCapacitySolidMax
   then isMaxStorageSolidFull:=false;
   if FCEntities[ PSPent ].E_col[ PSPcol ].COL_storCapacityLiquidCurr<FCEntities[ PSPent ].E_col[ PSPcol ].COL_storCapacityLiquidMax
   then isMaxStorageLiquidFull:=false;
   if FCEntities[ PSPent ].E_col[ PSPcol ].COL_storCapacityGasCurr<FCEntities[ PSPent ].E_col[ PSPcol ].COL_storCapacityGasMax
   then isMaxStorageGasFull:=false;
   if FCEntities[ PSPent ].E_col[ PSPcol ].COL_storCapacityBioCurr<FCEntities[ PSPent ].E_col[ PSPcol ].COL_storCapacityBioMax
   then isMaxStorageBioFull:=false;
   prodMatrixDisList:=nil;
   setlength( prodMatrixDisList, 1);
   PSPpmatrixDisIndex:=0;
   InfraToColonyLinkedMatrixIdx:=length( FCEntities[PSPent].E_col[PSPcol].COL_productionMatrix )-1;
   ColonyProdMatrixIdx:=1;
   while ColonyProdMatrixIdx<=InfraToColonyLinkedMatrixIdx do
   begin
      PSPstorageIndex:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_storageIndex;
      if FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_globalProdFlow<0 then
      begin
         if FCEntities[PSPent].E_col[PSPcol].COL_storageList[ PSPstorageIndex ].CPR_unit < abs( FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_globalProdFlow )
         then RevertProduction(true)
         else if FCEntities[PSPent].E_col[PSPcol].COL_storageList[ PSPstorageIndex ].CPR_unit>=abs( FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_globalProdFlow )
         then FCFgC_Storage_Update(
            FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_productToken
            ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_globalProdFlow
            ,PSPent
            ,PSPcol
            ,true
            );
      end //==END== if FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_globalProdFlow<0 then ==//
      else if (FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_globalProdFlow>0)
         and (
            ( ( FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_storageType=stSolid ) and ( not isMaxStorageSolidFull) )
            or ( ( FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_storageType=stLiquid ) and ( not isMaxStorageLiquidFull) )
            or ( ( FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_storageType=stGas ) and ( not isMaxStorageGasFull) )
            or ( ( FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_storageType=stBiologic ) and ( not isMaxStorageBioFull) )
            )
      then
      begin
         ReturnPRod:=FCFgC_Storage_Update(
            FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_productToken
            ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_globalProdFlow
            ,PSPent
            ,PSPcol
            ,true
            );
         if ReturnPRod<>0 then begin
            case FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ ColonyProdMatrixIdx ].CPMI_storageType of
               stSolid: isMaxStorageSolidFull:=true;
               stLiquid: isMaxStorageLiquidFull:=true;
               stGas: isMaxStorageGasFull:=true;
               stBiologic: isMaxStorageBioFull:=true;
            end;
            RevertProduction(false);
         end;
      end;
      inc(ColonyProdMatrixIdx);
   end; //==END== while PSPcntPmatrix<=PSPmaxPmatrix do ==//
   if PSPpmatrixDisIndex>0 then
   begin
      ColonyProdMatrixIdx:=1;
      while ColonyProdMatrixIdx<=PSPpmatrixDisIndex do
      begin
         PSPsettlement:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ prodMatrixDisList[ ColonyProdMatrixIdx ].matrixItemIndex ].CPMI_productionModes[ prodMatrixDisList[ ColonyProdMatrixIdx ].prodModeIndex ].PF_locSettlement;
         PSPownedInfra:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ prodMatrixDisList[ ColonyProdMatrixIdx ].matrixItemIndex ].CPMI_productionModes[ prodMatrixDisList[ ColonyProdMatrixIdx ].prodModeIndex ].PF_locInfra;
         PSPprodModeIndex:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ prodMatrixDisList[ ColonyProdMatrixIdx ].matrixItemIndex ].CPMI_productionModes[ prodMatrixDisList[ ColonyProdMatrixIdx ].prodModeIndex ].PF_locProdModeIndex;
         FCMgPM_EnableDisable_Process(
            PSPent
            ,PSPcol
            ,PSPsettlement
            ,PSPownedInfra
            ,PSPprodModeIndex
            ,true
            ,true
            );
         inc( ColonyProdMatrixIdx );
      end;
   end;
end;

end.
