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
   farc_common_func
   ,farc_data_game
   ,farc_game_colony
   ,farc_game_prodmodes
   ,farc_ui_coredatadisplay;

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
      -2012Jan09- *add: update the colony data panel / storage display if needed.
      -2011Dec19- *add: rule foundation, COMPLETION.
      -2011Dec18- *add: rule foundation, work-in-progress.
}
   type prodMatrixDisabled=record
      matrixItemIndex: integer;
      prodModeIndex: integer;
   end;

   var
      PSPcntPmatrix
      ,PSPcntPMitems
      ,PSPcntPmode
      ,PSPmaxPmatrix
      ,PSPmaxPmode
      ,PSPownedInfra
      ,PSPpmatrixDisIndex
      ,PSPpmatrixIndex
      ,PSPprodModeIndex
      ,PSPsettlement
      ,PSPstorageIndex: integer;

      prodMatrixDisList: array of prodMatrixDisabled;
begin
   prodMatrixDisList:=nil;
   setlength( prodMatrixDisList, 1);
   PSPpmatrixDisIndex:=0;
   PSPmaxPmatrix:=length( FCEntities[PSPent].E_col[PSPcol].COL_productionMatrix )-1;
   if PSPmaxPmatrix>0 then
   begin
      PSPcntPmatrix:=1;
      while PSPcntPmatrix<=PSPmaxPmatrix do
      begin
         PSPstorageIndex:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_storageIndex;
         if FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_globalProdFlow<0 then
         begin
            if FCEntities[PSPent].E_col[PSPcol].COL_storageList[ PSPstorageIndex ].CPR_unit<FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_globalProdFlow then
            begin
               PSPmaxPmode:=length( FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_productionModes )-1;
               PSPcntPmode:=1;
               while PSPcntPmode<=PSPmaxPmode do
               begin
                  if FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_productionModes[ PSPcntPmode ].PF_productionFlow<0 then
                  begin
                     PSPsettlement:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_productionModes[ PSPcntPmode ].PF_locSettlement;
                     PSPownedInfra:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_productionModes[ PSPcntPmode ].PF_locInfra;
                     PSPprodModeIndex:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_productionModes[ PSPcntPmode ].PF_locProdModeIndex;
                     PSPcntPMitems:=1;
                     while PSPcntPMitems<=FCEntities[ PSPent ].E_col[ PSPcol ].COL_settlements[ PSPsettlement ].CS_infra[ PSPownedInfra ].CI_fprodMode[ PSPprodModeIndex ].PM_matrixItemMax do
                     begin
                        PSPpmatrixIndex:=
                           FCEntities[ PSPent ].E_col[ PSPcol ].COL_settlements[ PSPsettlement ].CS_infra[ PSPownedInfra ].CI_fprodMode[ PSPprodModeIndex ].PF_linkedMatrixItemIndexes[ PSPcntPMitems ].LMII_matrixItmIndex;
                        if PSPpmatrixIndex<PSPcntPmatrix then
                        begin
                           if FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_globalProdFlow<0
                           then FCFgC_Storage_Update(
                              true
                              ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_productToken
                              ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_globalProdFlow
                              ,PSPent
                              ,PSPcol
                              )
                           else if FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_globalProdFlow>0
                           then FCFgC_Storage_Update(
                              false
                              ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_productToken
                              ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPpmatrixIndex ].CPMI_globalProdFlow
                              ,PSPent
                              ,PSPcol
                              );
                        end
                        else if PSPpmatrixIndex>=PSPcntPmatrix
                        then break;
                        inc( PSPcntPMitems );
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
                     prodMatrixDisList[ PSPpmatrixDisIndex ].matrixItemIndex:=PSPcntPmatrix;
                     prodMatrixDisList[ PSPpmatrixDisIndex ].prodModeIndex:=PSPcntPmode;
                     if FCEntities[PSPent].E_col[PSPcol].COL_storageList[ PSPstorageIndex ].CPR_unit>=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_globalProdFlow
                     then Break;
                  end;
                  inc( PSPcntPmode );
               end;
            end
            else if FCEntities[PSPent].E_col[PSPcol].COL_storageList[ PSPstorageIndex ].CPR_unit>=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_globalProdFlow
            then FCFgC_Storage_Update(
               false
               ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_productToken
               ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_globalProdFlow
               ,PSPent
               ,PSPcol
               );
         end //==END== if FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_globalProdFlow<0 then ==//
         else if FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_globalProdFlow>0
         then FCFgC_Storage_Update(
            true
            ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_productToken
            ,FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ PSPcntPmatrix ].CPMI_globalProdFlow
            ,PSPent
            ,PSPcol
            );
         inc(PSPcntPmatrix);
      end; //==END== while PSPcntPmatrix<=PSPmaxPmatrix do ==//
      if PSPpmatrixDisIndex>0 then
      begin
         PSPcntPmatrix:=1;
         while PSPcntPmatrix<=PSPpmatrixDisIndex do
         begin
            PSPsettlement:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ prodMatrixDisList[ PSPcntPmatrix ].matrixItemIndex ].CPMI_productionModes[ prodMatrixDisList[ PSPcntPmatrix ].prodModeIndex ].PF_locSettlement;
            PSPownedInfra:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ prodMatrixDisList[ PSPcntPmatrix ].matrixItemIndex ].CPMI_productionModes[ prodMatrixDisList[ PSPcntPmatrix ].prodModeIndex ].PF_locInfra;
            PSPprodModeIndex:=FCEntities[ PSPent ].E_col[ PSPcol ].COL_productionMatrix[ prodMatrixDisList[ PSPcntPmatrix ].matrixItemIndex ].CPMI_productionModes[ prodMatrixDisList[ PSPcntPmatrix ].prodModeIndex ].PF_locProdModeIndex;
            FCMgPM_EnableDisable_Process(
               PSPent
               ,PSPcol
               ,PSPsettlement
               ,PSPownedInfra
               ,PSPprodModeIndex
               ,true
               ,true
               );
            inc( PSPcntPmatrix );
         end;
      end;
      FCMuiCDD_Colony_Update(
         cdlStorage
         ,PSPcol
         ,0
         ,true
         ,false
         ,false
         );
   end; //==END== if PSPmaxPmatrix>0 then ==//
end;

end.
