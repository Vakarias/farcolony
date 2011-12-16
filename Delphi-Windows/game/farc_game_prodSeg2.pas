{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: production phase - segment 2 products/items production

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
unit farc_game_prodSeg2;

interface

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
   const PIAproductionFlow: double
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
   farc_data_game
   ,farc_game_colony;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgPS2_ProductionMatrixItem_Add(
   const PIAent
         ,PIAcol
         ,PIAsettlement
         ,PIAownedInfra
         ,PIAprodModeIndex: integer;
   const PIAproduct: string;
   const PIAproductionFlow: double
   );
{:Purpose: add a production item in a colony's production matrix.
    Additions:
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
      ,PIAstorageIndex: integer;

      PIAisPModeCreated: boolean;
begin
   PIAprodMatrixFound:=0;
   PIAstorageIndex:=0;
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
         SetLength( FCentities[ PIAent ].E_col[ PIAcol ].COL_productionMatrix[ PIAprodMatrixFound ].CPMI_productionModes, 1 );
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

procedure FCMgPS2_ProductionSegment_Process(
   const PSPent
         ,PSPcol: integer
   );
{:Purpose:  segment 2 (items production) processing.
    Additions:
}
   var
      PSPcnt
      ,PSPmax
      ,PSPstorCnt
      ,PSPstorIndex
      ,PSPstorMax: integer;

      PSPstorageRoot: array of TFCRdgColonProduct;
begin
   SetLength( PSPstorageRoot, 1 );
   PSPstorageRoot:=nil;
   PSPstorMax:=length( FCEntities[PSPent].E_col[PSPcol].COL_storageList )-1;
   SetLength( PSPstorageRoot, PSPstorMax+1 );
   PSPstorCnt:=1;
   while PSPstorCnt<=PSPstorMax do
   begin
      PSPstorageRoot[ PSPstorCnt ].CPR_token:=FCEntities[PSPent].E_col[PSPcol].COL_storageList[ PSPstorCnt ].CPR_token;
      PSPstorageRoot[ PSPstorCnt ].CPR_unit:=FCEntities[PSPent].E_col[PSPcol].COL_storageList[ PSPstorCnt ].CPR_unit;
      inc( PSPstorCnt );
   end;
   PSPmax:=length( FCEntities[PSPent].E_col[PSPcol].COL_productionMatrix )-1;
   if PSPmax>0 then
   begin
      PSPcnt:=1;
      while PSPcnt<=PSPmax do
      begin
         PSPstorIndex:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcnt ].CPMI_storageIndex;
         if FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcnt ].CPMI_globalProdFlow<0 then
         begin
            if FCEntities[PSPent].E_col[PSPcol].COL_storageList[ PSPstorIndex ].CPR_unit>=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcnt ].CPMI_globalProdFlow
            then FCFgC_Storage_Update( {:DEV NOTES: put var to store the result, if not all is xfer.}
               false
               ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcnt ].CPMI_productToken
               ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcnt ].CPMI_globalProdFlow
               ,PSPent
               ,PSPcol
               );
         end;
         inc(PSPcnt);
      end;
   end;
end;

end.
