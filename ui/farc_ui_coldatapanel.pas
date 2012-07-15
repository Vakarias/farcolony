{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: colony data panel unit

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
unit farc_ui_coldatapanel;

interface

uses
   Classes
   ,ComCtrls
   ,SysUtils

   ,farc_data_infrprod;

{:DEV NOTES: update TFCEuicddColonyDataList+FCMuiCDD_Colony_Update.}
type TFCEuicdpDataTypes=(
   dtAll
   ,dtLvl
   ,dtCohes
   ,dtSecu
   ,dtTens
   ,dtEdu
   ,dtHeal
   ,dtCSMenergy
   ,dtPopAll
   ,dtCSMev
   ,dtInfraAll
   ,dtInfraOwned
   ,dtInfraOwnedIndex
   ,dtInfraAvail
   ,dtStorageAll
   ,dtStorageIndex
   ,dtStorageCapSolid
   ,dtStorageCapLiquid
   ,dtStorageCapGas
   ,dtStorageCapBio
   ,dtProdMatrixAll
   ,dtProdMatrixIndex
   ,dtReservesAll
   ,dtReservesOxy
   ,dtReservesFood
   ,dtReservesWater
   );

type CDPcurrentLocIndexes= record
   CLI_starsys: integer;
   CLI_star: integer;
   CLI_oobj: integer;
   CLI_sat: integer;
end;

///<summary>
///   retrieve an database infrastructure index by using HTML tree view selected data
///</summary>
///   <param name=ALIRIcategoryName">infrastructure's category has it appears on the tree list</param>
///   <param name="AIRIcategoryIndex">index of the infrastructure in the designed category</param>
//function FCFuiCDP_AvailInfra_RetrieveIndex( const AIRIcategoryName: string; const AIRIcategoryIndex: integer ): integer;

///<summary>
///   retrieve the display's current location in the universe
///</summary>
function FCFuiCDP_DisplayLocation_Retrieve: CDPcurrentLocIndexes;

///<summary>
///   compare a tree node function text with one specified enumeration
///</summary>
///   <param name="FunctionToCompare">function to compare</param>
///   <param name="FunctionText">tree node function text</param>
///   <returns>true= match function</returns>
function FCFuiCDP_FunctionCateg_Compare( const FunctionToCompare: TFCEdipFunctions; const FunctionText: string ): boolean;

///<summary>
///   retrieve an infrastructure index of the current colony and settlement by using HTML tree view selected data
///</summary>
///   <param name="LIRIcategoryName">infrastructure's category has it appears on the tree list</param>
///   <param name="LIRIcategoryIndex">index of the infrastructure in the designed category</param>
function FCFuiCDP_ListInfra_RetrieveIndex( const LIRIcategoryName: string; const LIRIcategoryIndex: integer ): integer;

///<summary>
///   retrieve the CDPcurrentColony variable value
///</summary>
function FCFuiCDP_VarCurrentColony_Get: integer;

///<summary>
///   retrieve the CDPcurrentSettlement variable value
///</summary>
function FCFuiCDP_VarCurrentSettlement_Get: integer;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   test key routine for colony data panel / population / CWP population assign edit
///</summary>
///   <param="CNTkeyDump">key number</param>
///   <param="CNTTshftCtrl">shift state</param>
procedure FCMuiCDP_CWPAssignKey_Test(
   const CWCPAkey: integer;
   const CWCPAshftCtrl: TShiftState
   );

///<summary>
///   test key routine for colony data panel / population / CWP vehicles assign edit
///</summary>
///   <param="CNTkeyDump">key number</param>
///   <param="CNTTshftCtrl">shift state</param>
procedure FCMuiCDP_CWPAssignVehKey_Test(
   const CWPAVKkey: integer;
   const CWPAVKshftCtrl: TShiftState
   );

///<summary>
///   process the CWP radio click
///</summary>
///    <param name="WCPRCset">= true => initialize the interface</param>
procedure FCMuiCDP_WCPradio_Click(const WCPRCset: boolean);

///<summary>
///   update the colony data display
///</summary>
///    <param name="CPUtp">colony's data to update</param>
///    <param name="CPUcol">colony index</param>
///    <param name="CPUsettlement">[optional] settlement index</param>
///    <param name="DataIndex1">[optional] only for Index type, indicate which index in a list is to update</param>
procedure FCMuiCDP_Data_Update(
   const CPUtp: TFCEuicdpDataTypes;
   const CPUcol
         ,CPUsettlement
         ,DataIndex1: integer
   );

///<summary>
///   display the colony/faction data panel.
///</summary>
procedure FCMuiCDP_Display_Set(
   const CFDssys
         ,CFDstar
         ,CFDoobj
         ,CFDsat: integer
   );

///<summary>
///   set the functions private variables strings
///</summary>
procedure FCMuiCDP_FunctionCateg_Initialize;

///<summary>
///   test key routine for colony panel / available infrastructures list
///</summary>
///   <param="AITkey">key number</param>
///   <param="AITshftCtrl">shift state</param>
procedure FCMuiCDP_KeyAvailInfra_Test(
   const AITkey: integer;
   const AITshftCtrl: TShiftState
   );

///<summary>
///   test key routine for colony panel / CWP Equipment List
///</summary>
///   <param="InputKey">key number</param>
///   <param="ShiftControl">shift state</param>
procedure FCMuiCDP_KeyCWPEquipmentList_Test(
   const InputKey: integer;
   const ShiftControl: TShiftState
   );

///<summary>
///   test key routine for colony panel / infrastructures list.
///</summary>
///   <param="ILKTkey">key number</param>
///   <param="ILKTshftCtrl">shift state</param>
procedure FCMuiCDP_KeyInfraList_Test(
   const ILKTkey: integer;
   const ILKTshftCtrl: TShiftState
   );

///<summary>
///   test key routine for colony panel / production matrix list
///</summary>
///   <param="InputKey">key number</param>
///   <param="ShiftControl">shift state</param>
procedure FCMuiCDP_KeyProductionMatrixList_Test(
   const InputKey: integer;
   const ShiftControl: TShiftState
   );

///<summary>
///   test key routine for colony panel / storage list
///</summary>
///   <param="InputKey">key number</param>
///   <param="ShiftControl">shift state</param>
procedure FCMuiCDP_KeyStorageList_Test(
   const InputKey: integer;
   const ShiftControl: TShiftState
   );

///<summary>
///   load the CDPcurrentColony variable with a new data
///</summary>
///   <param name="VCCLcolony">player's colony index to load</param>
//procedure FCMuiCDP_VarCurrentColony_Load(const VCCLcolony: integer);

implementation

uses
   farc_common_func
   ,farc_data_textfiles
   ,farc_data_game
   ,farc_data_html
   ,farc_data_init
   ,farc_data_univ
   ,farc_game_colony
   ,farc_game_csm
   ,farc_game_csmevents
   ,farc_game_infra
   ,farc_game_prod
   ,farc_game_prodrsrcspots
   ,farc_main
   ,farc_ui_coredatadisplay
   ,farc_ui_html
   ,farc_ui_keys
   ,farc_ui_surfpanel
   ,farc_ui_win
   ,farc_win_debug;

var
  CDPcurrentColony,
  CDPcurrentSettlement: integer;

  CDPfunctionEN
  ,CDPfunctionHO
  ,CDPfunctionIN
  ,CDPfunctionMISC
  ,CDPfunctionPR: string;

  CDPdisplayLocation: CDPcurrentLocIndexes;

  CDPconstNode: TTreeNode;

  CDPmanEquipDB: array of integer;
  CDPmanEquipStor: array of integer;

//===================================================END OF INIT============================

//function FCFuiCDP_AvailInfra_RetrieveIndex( const AIRIcategoryName: string; const AIRIcategoryIndex: integer ): integer;
//{:Purpose: retrieve an database infrastructure index by using HTML tree view selected data.
//    Additions:
//}
//var
//   AIRIcount
//   ,AIRIcurrentCategoryIndex
//   ,AIRImax: integer;
//
//   LIRIfunctionToSearch: TFCEdipFunction;
//begin
//   Result:=0;
//   AIRImax:=0;
//   if AIRIcategoryName=CDPfunctionEN
//   then LIRIfunctionToSearch:=fEnergy
//   else if AIRIcategoryName=CDPfunctionHO
//   then LIRIfunctionToSearch:=fHousing
//   else if AIRIcategoryName=CDPfunctionIN
//   then LIRIfunctionToSearch:=fIntelligence
//   else if AIRIcategoryName=CDPfunctionMISC
//   then LIRIfunctionToSearch:=fMiscellaneous
//   else if AIRIcategoryName=CDPfunctionPR
//   then LIRIfunctionToSearch:=fProduction
//   else AIRImax:=-1;
//   if AIRImax>-1
//   then
//   begin
//      AIRImax:=length(FCDBinfra)-1;
//      AIRIcount:=1;
//      AIRIcurrentCategoryIndex:=0;
//      while AIRIcount<=AIRImax do
//      begin
//         if FCDBinfra[AIRIcount].I_function=LIRIfunctionToSearch
//         then
//         begin
//            inc(AIRIcurrentCategoryIndex);
//            if AIRIcurrentCategoryIndex=AIRIcategoryIndex
//            then
//            begin
//               Result:=AIRIcount;
//               break;
//            end;
//         end;
//         inc(AIRIcount);
//      end;
//   end;
//end;

function FCFuiCDP_DisplayLocation_Retrieve: CDPcurrentLocIndexes;
{:Purpose: retrieve the display's current location in the universe.
    Additions:
}
begin
   Result:=CDPdisplayLocation;
end;

function FCFuiCDP_FunctionCateg_Compare( const FunctionToCompare: TFCEdipFunctions; const FunctionText: string ): boolean;
{:Purpose: compare a tree node function text with one specified enumeration.
    Additions:
}
begin
   Result:=false;
   case FunctionToCompare of
      fEnergy: if FunctionText=CDPfunctionEN then Result:=true;

      fHousing: if FunctionText=CDPfunctionHO then Result:=true;

      fIntelligence: if FunctionText=CDPfunctionIN then Result:=true;

      fMiscellaneous: if FunctionText=CDPfunctionMISC then Result:=true;

      fProduction: if FunctionText=CDPfunctionPR then Result:=true;
   end;
end;

function FCFuiCDP_ListInfra_RetrieveIndex( const LIRIcategoryName: string; const LIRIcategoryIndex: integer ): integer;
{:Purpose: retrieve an infrastructure index of the current colony and settlement by using HTML tree view selected data.
    Additions:
}
var
   LIRIcount
   ,LIRIcurrentCategoryIndex
   ,LIRImax: integer;

   LIRIfunctionToSearch: TFCEdipFunctions;
begin
   Result:=0;
   LIRImax:=0;
   if LIRIcategoryName=CDPfunctionEN
   then LIRIfunctionToSearch:=fEnergy
   else if LIRIcategoryName=CDPfunctionHO
   then LIRIfunctionToSearch:=fHousing
   else if LIRIcategoryName=CDPfunctionIN
   then LIRIfunctionToSearch:=fIntelligence
   else if LIRIcategoryName=CDPfunctionMISC
   then LIRIfunctionToSearch:=fMiscellaneous
   else if LIRIcategoryName=CDPfunctionPR
   then LIRIfunctionToSearch:=fProduction
   else LIRImax:=-1;
   if LIRImax>-1
   then
   begin
      LIRImax:=length(FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra)-1;
      LIRIcount:=1;
      LIRIcurrentCategoryIndex:=0;
      while LIRIcount<=LIRImax do
      begin
         if FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[LIRIcount].CI_function=LIRIfunctionToSearch
         then
         begin
            inc(LIRIcurrentCategoryIndex);
            if LIRIcurrentCategoryIndex=LIRIcategoryIndex
            then
            begin
               Result:=LIRIcount;
               break;
            end;
         end;
         inc(LIRIcount);
      end;
   end;
end;

function FCFuiCDP_VarCurrentColony_Get: integer;
{:Purpose: retrieve the CDPcurrentColony variable value.
    Additions:
}
begin
   Result:=CDPcurrentColony;
end;

function FCFuiCDP_VarCurrentSettlement_Get: integer;
{:Purpose: retrieve the CDPcurrentSettlement variable value.
    Additions:
}
begin
   Result:=CDPcurrentSettlement;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiCDP_CWPAssignKey_Test(
   const CWCPAkey: integer;
   const CWCPAshftCtrl: TShiftState
   );
{:Purpose: test key routine for colony data panel / population / WCP population assign edit.
    Additions:
      -2011Jan09- *fix: take in account when there's no more available colonists.
      -2011Dec22- *mod: update the interface refresh by using the link to the new routine.
      -2011Jul04- *fix: correctly call the colony's storage update to avoid a double update on the storage values + change location of CWP calculations.
      -2011May24- *mod: use a private variable instead of a tag for the colony index.
      -2011May09- *add: update the colony's storage when tools are taken.
                  *add: if there's no enough tools, the number of colonist is reduced to the maximum number of allowable tools.
}
var
   CWPAKTcol
   ,CWPAKTequipIndex
   ,ColonistLeft: integer;

   CWPAKTvalue: integer;

   CWPAKTcwp: extended;
begin
   if (ssAlt in CWCPAshftCtrl)
   then FCMuiK_WinMain_Test(CWCPAkey, CWCPAshftCtrl)
   else if (CWCPAkey<>13)
      and ( (CWCPAkey<48) or (CWCPAkey>57) )
      and ( (CWCPAkey<96) or (CWCPAkey>105) )
   then FCMuiK_WinMain_Test(CWCPAkey, CWCPAshftCtrl);
   {.ENTER}
   {.assign the colonists}
   if CWCPAkey=13
   then
   begin
      CWPAKTcwp:=0;
      CWPAKTcol:=FCFuiCDP_VarCurrentColony_Get;
      ColonistLeft:=FCEntities[0].E_col[CWPAKTcol].COL_population.POP_tpColon-FCEntities[0].E_col[CWPAKTcol].COL_population.POP_tpColonAssigned;
      if ColonistLeft>0 then
      begin
         CWPAKTvalue:=StrToInt64(FCWinMain.FCWM_CDPwcpAssign.Text);
         CWPAKTequipIndex:=FCWinMain.FCWM_CDPwcpEquip.ItemIndex;
         if CWPAKTvalue>ColonistLeft
         then CWPAKTvalue:=ColonistLeft;
         if CWPAKTequipIndex=0
         then CWPAKTcwp:=FCFcFunc_Rnd( cfrttpSizem, CWPAKTvalue*0.5 )
         else if CWPAKTequipIndex>0
         then
         begin
            if FCEntities[0].E_col[CWPAKTcol].COL_storageList[ CDPmanEquipStor[CWPAKTequipIndex] ].CPR_unit<CWPAKTvalue
            then CWPAKTvalue:=round(FCEntities[0].E_col[CWPAKTcol].COL_storageList[ CDPmanEquipStor[CWPAKTequipIndex] ].CPR_unit);
            FCFgC_Storage_Update(
               FCEntities[0].E_col[CWPAKTcol].COL_storageList[ CDPmanEquipStor[CWPAKTequipIndex] ].CPR_token
               ,-CWPAKTvalue
               ,0
               ,CWPAKTcol
               ,false
               );
            CWPAKTcwp:=FCFcFunc_Rnd( cfrttpSizem, CWPAKTvalue*FCDBproducts[ CDPmanEquipDB[CWPAKTequipIndex] ].PROD_fManConstWCPcoef );
         end;
         FCEntities[0].E_col[CWPAKTcol].COL_population.POP_tpColonAssigned:=FCEntities[0].E_col[CWPAKTcol].COL_population.POP_tpColonAssigned+CWPAKTvalue;
         FCEntities[0].E_col[CWPAKTcol].COL_population.POP_wcpAssignedPeople:=FCEntities[0].E_col[CWPAKTcol].COL_population.POP_wcpAssignedPeople+CWPAKTvalue;
         FCEntities[0].E_col[CWPAKTcol].COL_population.POP_wcpTotal:=FCEntities[0].E_col[CWPAKTcol].COL_population.POP_wcpTotal+CWPAKTcwp;
         FCMuiCDD_Colony_Update(
            cdlDataPopulation
            ,0
            ,0
            ,0
            ,false
            ,false
            ,false
            );
      end;
      FCWinMain.FCWM_CDPwcpAssign.Text:='';
   end;
end;

procedure FCMuiCDP_CWPAssignVehKey_Test(
   const CWPAVKkey: integer;
   const CWPAVKshftCtrl: TShiftState
   );
{:Purpose: test key routine for colony data panel / population / WCP vehicles assign edit.
    Additions:
      -2011Jan09- *fix: take in account when there's no more available colonists.
      -2011Jan05- *mod: adjust the index due to the removal of the "No Equipment" item in the list.
      -2011Jul04- *fix: correctly call the colony's storage update to avoid a double update on the storage values.
}
var
   CWPAVKTcol
   ,CWPAVKTcrew
   ,CWPAVKTequipIndex
   ,CWPAVKTvalue
   ,ColonistLeft: integer;

   CWPAVKTcwp: extended;
begin
   if (ssAlt in CWPAVKshftCtrl)
   then FCMuiK_WinMain_Test(CWPAVKkey, CWPAVKshftCtrl)
   else if (CWPAVKkey<>13)
      and ( (CWPAVKkey<48) or (CWPAVKkey>57) )
      and ( (CWPAVKkey<96) or (CWPAVKkey>105) )
   then FCMuiK_WinMain_Test(CWPAVKkey, CWPAVKshftCtrl);
   {.ENTER}
   {.assign the vehicles}
   if CWPAVKkey=13
   then
   begin
      CWPAVKTcwp:=0;
      CWPAVKTequipIndex:=FCWinMain.FCWM_CDPwcpEquip.ItemIndex+1;
      CWPAVKTcol:=FCFuiCDP_VarCurrentColony_Get;
      ColonistLeft:=FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_tpColon-FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_tpColonAssigned;
      if (ColonistLeft>0)
         and (CWPAVKTequipIndex>0)
      then
      begin
         CWPAVKTvalue:=StrToInt64(FCWinMain.FCWM_CDPcwpAssignVeh.Text);
         if CWPAVKTvalue>FCEntities[0].E_col[CWPAVKTcol].COL_storageList[ CDPmanEquipStor[CWPAVKTequipIndex] ].CPR_unit
         then CWPAVKTvalue:=round(FCEntities[0].E_col[CWPAVKTcol].COL_storageList[ CDPmanEquipStor[CWPAVKTequipIndex] ].CPR_unit);
         CWPAVKTcrew:=CWPAVKTvalue*FCDBproducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].PROD_fMechConstCrew;
         if CWPAVKTcrew>(ColonistLeft)
         then
         begin
            CWPAVKTvalue:=trunc( ColonistLeft / FCDBproducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].PROD_fMechConstCrew );
            CWPAVKTcrew:=CWPAVKTvalue*FCDBproducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].PROD_fMechConstCrew;
         end;
         FCFgC_Storage_Update(
            FCEntities[0].E_col[CWPAVKTcol].COL_storageList[ CDPmanEquipStor[CWPAVKTequipIndex] ].CPR_token
            ,-CWPAVKTvalue
            ,0
            ,CWPAVKTcol
            ,false
            );
         FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_tpColonAssigned:=FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_tpColonAssigned+CWPAVKTcrew;
         FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_wcpAssignedPeople:=FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_wcpAssignedPeople+CWPAVKTcrew;
         CWPAVKTcwp:=FCFcFunc_Rnd( cfrttpSizem, CWPAVKTvalue*FCDBproducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].PROD_fManConstWCPcoef );
         FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_wcpTotal:=FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_wcpTotal+CWPAVKTcwp;
         FCMuiCDD_Colony_Update(
            cdlDataPopulation
            ,0
            ,0
            ,0
            ,false
            ,false
            ,false
            );
      end;
      FCWinMain.FCWM_CDPcwpAssignVeh.Text:='';
   end;
end;

procedure FCMuiCDP_WCPradio_Click(const WCPRCset: boolean);
{:Purpose: process the WCP radio click.
    Additions:
      -2012Feb02- *add: display also the number of available units for each listed equipment.
                  *add: display each equipment only if their unit in the storage list >0.
                  *add: for mechanized workforce option, if there's no available equipment, the player cannot set anything for the CWP.
      -2012Jan05- *mod: display the "No Equipment" item only in the case of an "Add Colonists".
      -2011May09- *add: set the display of the vehicles assignation ui element.
      -2011May06- *add: populate the dropdown interface element w/ equipments, if there's one available.
}
var
   WCPRCstorCnt
   ,WCPRCcol
   ,WCPRCdbCnt
   ,WCPRCindex
   ,WCPRCmax: integer;

   WCPRCcheck: boolean;
begin
   FCWinMain.FCWM_CDPpopList.GetRadioButton(CDPconstNode[2], WCPRCcheck);
   setlength(CDPmanEquipDB, 1);
   setlength(CDPmanEquipStor, 1);
   WCPRCindex:=0;
   FCWinMain.FCWM_CDPwcpAssign.Text:='';
   FCWinMain.FCWM_CDPcwpAssignVeh.Text:='';
   FCWinMain.FCWM_CDPwcpEquip.Items.Clear;
   WCPRCcol:=FCFuiCDP_VarCurrentColony_Get;
   FCWinMain.FCWM_CDPwcpEquip.Enabled:=true;
   if (WCPRCset)
      or (WCPRCcheck)
   then
   begin
      FCWinMain.FCWM_CDPwcpEquip.Items.Add(FCFdTFiles_UIStr_Get(uistrUI, 'cwpEquipNone'));
      FCWinMain.FCWM_CDPcwpAssignVeh.Visible:=false;
      FCWinMain.FCWM_CDPwcpAssign.Visible:=true;
      WCPRCmax:=Length(FCentities[0].E_col[WCPRCcol].COL_storageList)-1;
      if WCPRCmax>1
      then
      begin
         WCPRCstorCnt:=1;
         while WCPRCstorCnt<=WCPRCmax do
         begin
            WCPRCdbCnt:=FCFgP_Product_GetIndex(FCentities[0].E_col[WCPRCcol].COL_storageList[WCPRCstorCnt].CPR_token);
            if ( FCDBProducts[WCPRCdbCnt].PROD_function=prfuManConstruction )
               and ( FCentities[0].E_col[WCPRCcol].COL_storageList[WCPRCstorCnt].CPR_unit>0 )
            then
            begin
               inc(WCPRCindex);
               setlength(CDPmanEquipDB, WCPRCindex+1);
               setlength(CDPmanEquipStor, WCPRCindex+1);
               CDPmanEquipDB[WCPRCindex]:=WCPRCdbCnt;
               CDPmanEquipStor[WCPRCindex]:=WCPRCstorCnt;
               FCWinMain.FCWM_CDPwcpEquip.Items.Add( FCFdTFiles_UIStr_Get( uistrUI, FCDBProducts[WCPRCdbCnt].PROD_token )+' (x '+floattostr( FCentities[0].E_col[WCPRCcol].COL_storageList[WCPRCstorCnt].CPR_unit )+')' );
            end;
            inc(WCPRCstorCnt);
         end;
      end;
      FCWinMain.FCWM_CDPwcpEquip.ItemIndex:=0;
   end
   else
   begin
      FCWinMain.FCWM_CDPcwpAssignVeh.Visible:=true;
      FCWinMain.FCWM_CDPcwpAssignVeh.Enabled:=true;
      FCWinMain.FCWM_CDPwcpAssign.Visible:=false;
      WCPRCmax:=Length(FCentities[0].E_col[WCPRCcol].COL_storageList)-1;
      if WCPRCmax>1
      then
      begin
         WCPRCstorCnt:=1;
         while WCPRCstorCnt<=WCPRCmax do
         begin
            WCPRCdbCnt:=FCFgP_Product_GetIndex(FCentities[0].E_col[WCPRCcol].COL_storageList[WCPRCstorCnt].CPR_token);
            if ( FCDBProducts[WCPRCdbCnt].PROD_function=prfuMechConstruction )
               and ( FCentities[0].E_col[WCPRCcol].COL_storageList[WCPRCstorCnt].CPR_unit>0 )
            then
            begin
               inc(WCPRCindex);
               setlength(CDPmanEquipDB, WCPRCindex+1);
               setlength(CDPmanEquipStor, WCPRCindex+1);
               CDPmanEquipDB[WCPRCindex]:=WCPRCdbCnt;
               CDPmanEquipStor[WCPRCindex]:=WCPRCstorCnt;
               FCWinMain.FCWM_CDPwcpEquip.Items.Add(FCFdTFiles_UIStr_Get(uistrUI, FCDBProducts[WCPRCdbCnt].PROD_token)+' (x '+floattostr( FCentities[0].E_col[WCPRCcol].COL_storageList[WCPRCstorCnt].CPR_unit )+')' );
            end;
            inc(WCPRCstorCnt);
         end;
      end;
      if FCWinMain.FCWM_CDPwcpEquip.Items.Count=0 then
      begin
         FCWinMain.FCWM_CDPwcpEquip.Items.Add(FCFdTFiles_UIStr_Get(uistrUI, 'cwpEquipNone'));
         FCWinMain.FCWM_CDPwcpEquip.Enabled:=false;
         FCWinMain.FCWM_CDPcwpAssignVeh.Text:='N/A';
         FCWinMain.FCWM_CDPcwpAssignVeh.Enabled:=false;
      end
      else FCWinMain.FCWM_CDPwcpEquip.ItemIndex:=0;
   end;
end;

procedure FCMuiCDP_Data_Update(
   const CPUtp: TFCEuicdpDataTypes;
   const CPUcol
         ,CPUsettlement
         ,DataIndex1: integer
   );
{:Purpose: update the colony data display
   -2012May21- *add: CSM events: etRveOxygenShortage, etRveOxygenShortageRec, etRveWaterOverload, etRveWaterShortage, etRveWaterShortageRec, etRveFoodOverload, etRveFoodShortage and, etRveFoodShortageRec.
   -2012May06- *add: CSM events: etRveOxygenOverload.
   -2012apr29- *mod: CSM event modifiers and data are displayed according to the new changes in the data structure.
   -2012Apr18- *add: encyclopaedia links reformat for owned infrastructures list.
   -2012Apr16- *add: encyclopedia link are displayed with [?] (COMPLETION).
               *add: reserves (COMPLETION)
   -2012Apr15- *add: reserves.
               *mod: colony level is now regrouped with the basic data.
               *add: [experiment-WIP] encyclopedia link are displayed with [?].
   -2012Mar13- *fix: correctly update the status icons for dtInfraOwnedIndex.
   -2012Feb23- *add: complete dtInfraOwnedIndex.
   -2012Feb23- *add: new category dtInfraOwnedIndex, for update only one owned infrastructure instead to refresh the whole list.
   -2012Feb05- *fix: do not display an infrastructure kit, in the available infrastructures list, if there's no more kits.
               *add: in the owned infrastructures list, when an infrastructure is in Transition phase, the transition duration is correctly displayed now.
   -2012Feb05- *add: complete the production matrix list.
   -2012Jan29- *mod: relocate the CSM Energy data for taking in account the spanish language + put the format infos in a constant.
               *mod: CSM Events list no use the specific function to display the modifiers (remove useless code).
   -2012Jan25- *mod: some code cleanup + root in tree isn't selected by default.
               *add: localize storage and production matrix display.
               *add: forgot to localize the production matrix header.
   -2012Jan16- *add: dtStorageCapSolid + dtStorageCapLiquid + dtStorageCapGas + dtStorageCapBio (update display for each kind of storage).
               *add: dtProdMatrixAll (display of the production matrix).
               *add: dtAll - update also the production matrix now.
   -2012Jan15- *add: dtStorageAll - display the storage capacities.
   -2012Jan10- *mod: Population - display the population in the form assigned/total.
               *add: new parameter to indicate the index to update, when it's required.
               *mod: dtStorage => dtStorageAll.
               *add: dtStorageIndex, to update only one product in the list.
   -2012Jan09- *add: Storage List.
   -2012Jan05- *add: Population / CWP - set correctly the first option, "Add Colonists", by default.
   -2011Dec22- *add: 2 possible display for infrastructures: owned only, available only.
   -2011Dec21- *add: if the CPUcol is at 0, private data is used and not updated. CPUsettlement can't be at 0, if it's the case, the index 1 is selected (there's no colony w/o at least one settlement anyway).
               *mod: CPUsettlement is back in a constant.
               *fix: display correctly the ETA for converting/assembling/building.
   -2011Nov21- *add: available infrastructures list - take in account the resource spot requirement.
   -2011Oct26- *add: available infrastructures list - take in account the ANY environment + fix gravity requirements.
   -2011Oct23- *add: available infrastructures list - take in account the gravity requirement + add missing requirements test for infrastructure kits.
   -2011Jul24- *add: complete and cleaner rewrite of the procedure.
   -2011Jul20- *add: dtCSMenergy data type completion.
   -2011Jul19- *add: dtCSMenergy data type.
               *add: can now update colony data (only) section by section too.
               *mod: complete and cleaner rewrite of the procedure (WIP).
   -2011Jul18- *add: start of the implementation of CSM Energy module data.
   -2011Jul05- *mod: all sections, in infrastructures list, are displayed, like for the available infrastructures list.
   -2011Jul02- *add: available infrastructures/infrastructure kits - change the level case by using the product infralevel data instead of the infrastructure level range.
               *add: available infrastructures/infrastructure kits - if there more than one infrastructure kit linked to the same infrastructure, only one iteration is displayed.
   -2011Jun06- *add: available infrastructures - add a requirement to display each infrastructure: the level range compared to the settlement's level.
   -2011Jun05- *add: available infrastructures - for assembled infrastructures, the nummber of infrastructure kits is displayed.
   -2011May24- *mod: use a private variable instead of a tag for the colony index.
               *add: put the current settlement in a private variable.
   -2011May08- *add: population - construction workforce subsection WIP - CWP texts localization.
   -2011May06- *add: available infrastructures - display the infrastructure kits to assemble, if the displayed colony has at least one of them in it's storage.
               *add: available infrastructures - complete and localize correctly the list.
               *code: some optimizations by reducing the number of local variables.
               *add: population - construction workforce subsection WIP.
   -2011Apr28- *code: moved into it's proper unit.
               *add: population - construction workforce subsection WIP.
   -2011Apr18- *mod: small change in the data display.
               *mod: changes in the display of population main data.
   -2011Apr17- *add: settlement's infrastructures - available list generation.
   -2011Apr13- *add: settlement's infrastructures - display a status line under the infrastructure's name if it's required.
   -2011Apr11- *add: settlement's infrastructures - add a parameter for displaying a particular settlement.
               *add: settlement's infrastructures - add the real settlement name + sort the infrastructures in each functions.
               *fix: settlement's infrastructures - correction of the tree's behavior.
   -2011Apr10- *add: settlement's infrastructures - status icons are now displayed beside infrastructure's name.
   -2011Mar21- *mod: display the settlement's infrastructures in a tree list (WIP).
   -2011Jan20- *add: update the population in 2 lists.
   -2010Sep19- *add: entities code.
   -2010Aug19- *add: trigger for updating only the CSM events list and an other one for the infrastructures list.
   -2010Aug09- *add: CSM event duration.
   -2010Aug02- *add: CSM event health modifier.
   -2010Jul27- *add: update CSM event data display w/ economic & industrial output modifier.
               *add: complete the multiple csm events display.
   -2010Jun29- *add: CSM event descriptions are now links to the help panel / topic-definitions.
   -2010Jun28- *add: infrastructures list.
   -2010Jun27- *add: csm events display.
               *add: new format for population data display (in subnodes).
               *mod: many display changes for population list.
   -2010Jun25- *add: display space level for population.
   -2010Jun24- *add: population tree list completion and localization.
   -2010Jun22- *add: health data + population tree list.
   -2010Jun21- *add: security + education data.
   -2010Jun19- *add; cohesion index color.
               *add: tension, security data.
   -2010Jun16- *add: informations: foundation date, location, environment (only header for now) and colony level.
               *add: cohesion data.
}
   const
      IndX='<ind x="82">';
var
   CPUcnt
   ,CPUintDump
   ,CPUmax
   ,CPUradioIdx, CPUrspotIndex: integer;

   CPUcolLv
   ,CPUdataIndex
   ,CPUevN
   ,CPUfnd
   ,CPUinfDisplay
   ,CPUinfKitroot
   ,CPUinfStatus
   ,CPUpopMaxOrAssigned
   ,CPUstrDump1: string;

   isSearchDone: boolean;

   CPUnode
   ,CPUnodeTp
   ,CPUrootnode
   ,CPUrootnodeInfra
   ,CPUrootnodeInfraEN
   ,CPUrootnodeInfraHO
   ,CPUrootnodeInfraIN
   ,CPUrootnodeInfraMI
   ,CPUrootnodeInfraPR
   ,CPUrootnodeTp
   ,CPUsubnode
   ,CPUsubnodeTp: TTreeNode;

   CPUenvironment: TFCRgcEnvironment;

   CPUinfra: TFCRdipInfrastructure;
begin
   if CPUcol>0
   then CDPcurrentColony:=CPUcol;
   if CPUsettlement>0
   then CDPcurrentSettlement:=CPUsettlement
   else if CDPcurrentSettlement=0
   then CDPcurrentSettlement:=1;
   case CPUtp of
      dtAll:
      begin
         FCWinMain.FCWM_CDPinfoText.HTMLText.Clear;
         if FCentities[0].E_col[CDPcurrentColony].COL_name=''
         then FCWinMain.FCWM_CDPcolName.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcolNameNo')
         else FCWinMain.FCWM_CDPcolName.Text:=FCentities[0].E_col[CDPcurrentColony].COL_name;
         {.idx=0}
         CPUfnd:=FCFcF_Time_GetDate(
            FCentities[0].E_col[CDPcurrentColony].COL_fndDy
            ,FCentities[0].E_col[CDPcurrentColony].COL_fndMth
            ,FCentities[0].E_col[CDPcurrentColony].COL_fndYr
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'colFndD' )+FCCFdHeadEnd+CPUfnd+'<br>'
            +FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'colLoc' )+FCCFdHeadEnd
            +FCFdTFiles_UIStr_Get( dtfscPrprName, FCentities[0].E_col[CDPcurrentColony].COL_locOObj )+'<br>'
            );
         {.idx=1}
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'colDat' )+FCCFdHeadEnd) ;
         {.idx=2}
         CPUcolLv:=inttostr( FCFgC_ColLvl_GetIdx( 0, CDPcurrentColony ) );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colLvl' )+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+CPUcolLv+'</b> (<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'colLvl'+CPUcolLv)+'</b>)<br>'
            );
         {.idx=3}
         CPUdataIndex:=FCFgCSM_Cohesion_GetIdxStr( 0, CDPcurrentColony );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDcohes' )+FCCFcolEND+UIHTMLencyBEGIN+'csmDataCohesion'+UIHTMLencyEND
               +IndX+'<b>'+inttostr( FCentities[0].E_col[CDPcurrentColony].COL_cohes )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         {.idx=4}
         CPUdataIndex:=FCFgCSM_Security_GetIdxStr(
            0
            ,CDPcurrentColony
            ,false
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDsec' )+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+CPUdataIndex+'</b><br>'
            );
         {.idx=5}
         CPUdataIndex:=FCFgCSM_Tension_GetIdx(
            0
            ,CDPcurrentColony
            ,false
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDtens' )+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+inttostr( FCentities[0].E_col[CDPcurrentColony].COL_tens )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         {.idx=6}
         CPUdataIndex:=FCFgCSM_Education_GetIdxStr(0, CDPcurrentColony);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDedu' )+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+inttostr( FCentities[0].E_col[CDPcurrentColony].COL_edu )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         {.idx=7}
         CPUdataIndex:=FCFgCSM_Health_GetIdxStr(
            false
            ,0
            ,CDPcurrentColony
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+inttostr(FCentities[0].E_col[CDPcurrentColony].COL_csmHEheal)+'</b> % (<b>'+CPUdataIndex+'<b>)</p>'
            );
         {.idx=8 to 10}
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'colDCSMEnergTitle' )+FCCFdHeadEnd
            );
         CPUintDump:=round( FCentities[0].E_col[CDPcurrentColony].COL_csmENcons*100/FCentities[0].E_col[CDPcurrentColony].COL_csmENgen );
         if (CPUintDump=0)
            and (FCentities[0].E_col[CDPcurrentColony].COL_csmENcons>0)
         then CPUintDump:=1;
         CPUdataIndex:=FCMuiW_PercentColorGoodBad_Generate( CPUintDump );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergUsed')+FCCFcolEND+IndX+'<b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_csmENgen, ',')+'</b> kW <br>'
            );
         CPUintDump:=round( FCentities[0].E_col[CDPcurrentColony].COL_csmENstorCurr*100/FCentities[0].E_col[CDPcurrentColony].COL_csmENstorMax );
         if (CPUintDump=0)
            and (FCentities[0].E_col[CDPcurrentColony].COL_csmENstorCurr>0)
         then CPUintDump:=1;
         CPUdataIndex:=IntToStr(CPUintDump);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergStocked')+FCCFcolEND+IndX+'<b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_csmENstorMax, ',')+'</b> kW </p>'
            );
         {.END of colony's data}
         FCMuiCDP_Data_Update( dtReservesAll, 0, CDPcurrentSettlement, 0 );
         FCMuiCDP_Data_Update(dtPopAll, 0, CDPcurrentSettlement, 0);
         FCMuiCDP_Data_Update(dtCSMev, 0, CDPcurrentSettlement, 0);
         FCMuiCDP_Data_Update(dtInfraAll, 0, CDPcurrentSettlement, 0);
         FCMuiCDP_Data_Update(dtStorageAll, 0, CDPcurrentSettlement, 0);
         FCMuiCDP_Data_Update(dtProdMatrixAll, 0, CDPcurrentSettlement, 0);
      end; //==END== case of: dtAll ==//

      dtLvl:
      begin
         CPUcolLv:=IntToStr( FCFgC_ColLvl_GetIdx( 0, CDPcurrentColony ) );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            2
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colLvl' )+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+CPUcolLv+'</b> (<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'colLvl'+CPUcolLv)+'</b>)<br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 3 );
      end;

      dtCohes:
      begin
         CPUdataIndex:=FCFgCSM_Cohesion_GetIdxStr( 0, CDPcurrentColony );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            3
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDcohes' )+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+inttostr( FCentities[0].E_col[CDPcurrentColony].COL_cohes )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 4 );
      end;

      dtSecu:
      begin
         CPUdataIndex:=FCFgCSM_Security_GetIdxStr(
            0
            ,CDPcurrentColony
            ,false
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            4
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDsec' )+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+CPUdataIndex+'</b><br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 5 );
      end;

      dtTens:
      begin
         CPUdataIndex:=FCFgCSM_Tension_GetIdx(
            0
            ,CDPcurrentColony
            ,false
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            5
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDtens' )+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+inttostr( FCentities[0].E_col[CDPcurrentColony].COL_tens )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 6 );
      end;

      dtEdu:
      begin
         CPUdataIndex:=FCFgCSM_Education_GetIdxStr(0, CDPcurrentColony);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            6
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDedu' )+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+inttostr( FCentities[0].E_col[CDPcurrentColony].COL_edu )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 7 );
      end;

      dtHeal:
      begin
         CPUdataIndex:=FCFgCSM_Health_GetIdxStr(
            false
            ,0
            ,CDPcurrentColony
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            7
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+inttostr(FCentities[0].E_col[CDPcurrentColony].COL_csmHEheal)+'</b> % (<b>'+CPUdataIndex+'<b>)</p>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 8 );
      end;

      dtCSMenergy:
      begin
         CPUintDump:=round( FCentities[0].E_col[CDPcurrentColony].COL_csmENcons*100/FCentities[0].E_col[CDPcurrentColony].COL_csmENgen );
         if (CPUintDump=0)
            and (FCentities[0].E_col[CDPcurrentColony].COL_csmENcons>0)
         then CPUintDump:=1;
         CPUdataIndex:=FCMuiW_PercentColorGoodBad_Generate( CPUintDump );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            9
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergUsed')+FCCFcolEND+IndX+'<b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_csmENgen, ',')+'</b> kW <br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 10 );
         CPUintDump:=round( FCentities[0].E_col[CDPcurrentColony].COL_csmENstorCurr*100/FCentities[0].E_col[CDPcurrentColony].COL_csmENstorMax );
         if (CPUintDump=0)
            and (FCentities[0].E_col[CDPcurrentColony].COL_csmENstorCurr>0)
         then CPUintDump:=1;
         CPUdataIndex:=IntToStr(CPUintDump);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            10
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergStocked')+FCCFcolEND+IndX+'<b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_csmENstorMax, ',')+'</b> kW </p>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 11 );
      end;

      dtPopAll:
      begin
         {population display}
         FCWinMain.FCWM_CDPpopList.Items.Clear;
         FCWinMain.FCWM_CDPpopType.Items.Clear;
         CPUstrDump1:=FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_total,',');
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_csmHOpcap,',');
         CPUdataIndex:=FCFgCSM_SPL_GetIdxMod(
            indexstr
            ,0
            ,CDPcurrentColony
            );
         CPUrootnode:=FCWinMain.FCWM_CDPpopList.Items.Add( nil, 'Population Details');
         FCWinMain.FCWM_CDPpopList.Items.AddChild( CPUrootnode, '<b>'+CPUstrDump1+' / '+CPUpopMaxOrAssigned+'</b> max');
         CPUsubnode:=FCWinMain.FCWM_CDPpopList.Items.AddChild( CPUrootnode, FCFdTFiles_UIStr_Get(uistrUI, 'colPopSPL')+' [ <b>'+CPUdataIndex+'</b> ]');
         FCWinMain.FCWM_CDPpopList.Items.AddChild(
            CPUrootnode
            ,FCFdTFiles_UIStr_Get(uistrUI, 'colPopMAge')+' [ <b>'+floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_meanA)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFstdY')+' ]'
            );
         FCWinMain.FCWM_CDPpopList.Items.AddChild(
            CPUrootnode
            ,FCFdTFiles_UIStr_Get(uistrUI, 'colDdrate')+' [ <b>'+floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_dRate)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI, 'colPopBDR')
               +'/'+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFstdY')+']'
            );
         FCWinMain.FCWM_CDPpopList.Items.AddChild(
            CPUrootnode
            ,FCFdTFiles_UIStr_Get(uistrUI, 'colDbrate')+' [ <b>'+floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_bRate)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI, 'colPopBDR')
               +'/'+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFstdY')+']'
            );
         CDPconstNode:=FCWinMain.FCWM_CDPpopList.Items.AddChild(nil, FCFdTFiles_UIStr_Get(uistrUI, 'cwpTitle'));
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, FCFdTFiles_UIStr_Get(
            uistrUI, 'cwpAssigned')+' [ <b>'+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_wcpAssignedPeople)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, 'Total <a href="cwpRoot">CWP</a> [ <b>'+FloatToStr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_wcpTotal)+'</b> ]');
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, FCFdTFiles_UIStr_Get(uistrUI, 'cwpColonAdd'));
         FCWinMain.FCWM_CDPpopList.SetRadioButton(CDPconstNode[2], CPUradioIdx=1);
         FCWinMain.FCWM_CDPpopList.SetRadioButton(CDPconstNode[2], true);
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, FCFdTFiles_UIStr_Get(uistrUI, 'cwpMechAdd'));
         FCWinMain.FCWM_CDPpopList.SetRadioButton(CDPconstNode[3], CPUradioIdx=2);
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, FCFdTFiles_UIStr_Get(uistrUI, 'cwpAssignConfirm'));
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, FCFdTFiles_UIStr_Get(uistrUI, 'cwpAvailEquip'));
         FCMuiCDP_WCPradio_Click(true);
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpColon, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpColonAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.Add(
            nil
            ,FCFdTFiles_UIStr_Get(uistrUI, 'colPTcol')+' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUnodeTp:=FCWinMain.FCWM_CDPpopType.Items.Add(nil, FCFdTFiles_UIStr_Get(uistrUI, 'colPTspe'));
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpASoff, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpASoffAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTaero')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPToff')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpASmiSp, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpASmiSpAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTaero')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTmisss')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpBSbio, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpBSbioAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTbio')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTbios')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpBSdoc, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpBSdocAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTbio')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTdoc')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpIStech, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpIStechAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTindus')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTtech')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpISeng, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpISengAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTindus')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTeng')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpMSsold, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpMSsoldAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTarmy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTsold')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpMScomm, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpMScommAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTarmy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTcom')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpPSphys, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpPSphysAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTphy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTphys')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpPSastr, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpPSastrAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTphy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTastrop')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpESecol, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpESecolAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTeco')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTecol')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpESecof, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpESecofAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTeco')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTecof')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpAmedian, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpAmedianAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTadmin')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTmedian')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopList.FullExpand;
         FCWinMain.FCWM_CDPpopList.Select(CPUrootnode);
         FCWinMain.FCWM_CDPpopType.FullExpand;
         FCWinMain.FCWM_CDPpopType.Select(CPUnodeTp);
      end; //==END== case: dtPopAll ==//

      dtCSMev:
      begin
         {.csm events display}
         FCWinMain.FCWM_CDPcsmeList.Items.Clear;
         CPUmax:=length(FCentities[0].E_col[CDPcurrentColony].COL_evList)-1;
         CPUcnt:=1;
         while CPUcnt<=CPUmax do
         begin
            CPUevN:=FCFgCSME_Event_GetStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_token);
            CPUdataIndex:='';
            CPUrootnode:=FCWinMain.FCWM_CDPcsmeList.Items.Add(nil, FCFdTFiles_UIStr_Get(uistrUI, CPUevN)+UIHTMLencyBEGIN+CPUevN+UIHTMLencyEND );
            if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_duration>0
            then FCWinMain.FCWM_CDPpopList.Items.AddChild( CPUrootnode, FCFdTFiles_UIStr_Get(uistrUI, 'csmdur')+': <b>'+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_duration)
                  +' </b>'+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFwks') );
            {.order to display modifiers is: cohesion, tension, security, education, economic and industrial output, health}
            {.the special data are always displayed after the modifiers}
            case FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_token of
               etColEstab:
               begin
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CE_tensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CE_tensionMod, true )+'</b>  ';
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CE_securityMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDsec')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CE_securityMod, true )+'</b>  ';
               end;

               etUnrest, etUnrestRec:
               begin
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].UN_ecoindMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].UN_ecoindMod, true )+'</b>  ';
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].UN_tensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].UN_tensionMod, true )+'</b>  ';
               end;

               etSocdis, etSocdisRec:
               begin
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].SD_ecoindMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].SD_ecoindMod, true )+'</b>  ';
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].SD_tensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].SD_tensionMod, true )+'</b>  ';
               end;

               etUprising, etUprisingRec:
               begin
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].UP_ecoindMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].UP_ecoindMod, true )+'</b>  ';
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].UP_tensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].UP_tensionMod, true )+'</b>  ';
               end;

               etHealthEduRel:
               begin
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].HER_educationMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDedu')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].HER_educationMod, true )+'</b>  ';
               end;

               etGovDestab, etGovDestabRec:
               begin
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].GD_cohesionMod<>0
                  then CPUdataIndex:=FCFdTFiles_UIStr_Get(uistrUI, 'colDcohes')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].GD_cohesionMod, true )+'</b>  ';
               end;

               etRveOxygenOverload: CPUdataIndex:=FCFdTFiles_UIStr_Get(uistrUI, 'csmPercPopNotSupported')+'<b>'+IntToStr( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].ROO_percPopNotSupported )+'</b>  ';

               etRveOxygenShortage, etRveOxygenShortageRec:
               begin
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].ROS_ecoindMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].ROS_ecoindMod, true )+'</b>  ';
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].ROS_tensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].ROS_tensionMod, true )+'</b>  ';
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].ROS_healthMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].ROS_healthMod, true )+'</b>  ';
               end;

               etRveWaterOverload: CPUdataIndex:=FCFdTFiles_UIStr_Get(uistrUI, 'csmPercPopNotSupported')+'<b>'+IntToStr( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RWO_percPopNotSupported )+'</b>  ';

               etRveWaterShortage, etRveWaterShortageRec:
               begin
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RWS_ecoindMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RWS_ecoindMod, true )+'</b>  ';
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RWS_tensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RWS_tensionMod, true )+'</b>  ';
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RWS_healthMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RWS_healthMod, true )+'</b>  ';
               end;

               etRveFoodOverload: CPUdataIndex:=FCFdTFiles_UIStr_Get(uistrUI, 'csmPercPopNotSupported')+'<b>'+IntToStr( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RFO_percPopNotSupported )+'</b>  ';

               etRveFoodShortage, etRveFoodShortageRec:
               begin
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RFS_ecoindMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RFS_ecoindMod, true )+'</b>  ';
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RFS_tensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RFS_tensionMod, true )+'</b>  ';
                  if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RFS_healthMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].RFS_healthMod, true )+'</b>  ';
               end;
            end; //==END== case FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_token of ==//
            FCWinMain.FCWM_CDPpopList.Items.AddChild(
               CPUrootnode
               ,CPUdataIndex
               );
            inc(CPUcnt);
         end; //==END== while CPUcnt<=CPUmax do ==//
         FCWinMain.FCWM_CDPcsmeList.Select(CPUrootnode);
      end; //==END== case: dtCSMev ==//

      dtInfraAll:
      begin
         FCMuiCDP_Data_Update(dtInfraOwned, 0, 0, 0);
         FCMuiCDP_Data_Update(dtInfraAvail, 0, 0, 0);
      end; //==END== case: dtInfra ==//

      dtInfraOwned:
      begin
         {.infrastructures list}
         FCWinMain.FCWM_CDPinfrList.Items.Clear;
         CPUrootnodeInfra:=FCWinMain.FCWM_CDPinfrList.Items.Add(nil, FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_name);
         CPUrootnodeInfraEN:=FCWinMain.FCWM_CDPinfrList.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Energy')+']' );
         CPUrootnodeInfraHO:=FCWinMain.FCWM_CDPinfrList.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Housing')+']' );
         CPUrootnodeInfraIN:=FCWinMain.FCWM_CDPinfrList.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Intel')+']' );
         CPUrootnodeInfraMI:=FCWinMain.FCWM_CDPinfrList.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Misc')+']' );
         CPUrootnodeInfraPR:=FCWinMain.FCWM_CDPinfrList.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Prod')+']' );
         CPUmax:=length(FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra)-1;
         CPUcnt:=1;
         while CPUcnt<=CPUmax do
         begin
            CPUinfStatus:=FCFgInf_Status_GetToken(FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_status);
            CPUinfDisplay:='<img src="file://'+FCVdiPathResourceDir+'pics-ui-colony\'+CPUinfStatus+'16.jpg" align="middle"> - '
               +FCFdTFiles_UIStr_Get(uistrUI, FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_dbToken)
               +' '+UIHTMLencyBEGIN+FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_dbToken+UIHTMLencyEND;
            case FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_function of
               fEnergy: CPUsubnode:=FCWinMain.FCWM_CDPinfrList.Items.AddChild(CPUrootnodeInfraEN, CPUinfDisplay);
               fHousing: CPUsubnode:=FCWinMain.FCWM_CDPinfrList.Items.AddChild(CPUrootnodeInfraHO, CPUinfDisplay);
               fIntelligence: CPUsubnode:=FCWinMain.FCWM_CDPinfrList.Items.AddChild(CPUrootnodeInfraIN, CPUinfDisplay);
               fMiscellaneous: CPUsubnode:=FCWinMain.FCWM_CDPinfrList.Items.AddChild(CPUrootnodeInfraMI, CPUinfDisplay);
               fProduction: CPUsubnode:=FCWinMain.FCWM_CDPinfrList.Items.AddChild(CPUrootnodeInfraPR, CPUinfDisplay);
            end; //==END== case FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].IO_func of ==//
            case FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_status of
               istInConversion, istInAssembling, istInBldSite: FCWinMain.FCWM_CDPinfrList.Items.AddChild(
                  CPUsubnode
                  ,FCFdTFiles_UIStr_Get(uistrUI, CPUinfStatus)+': '+IntToStr(
                     FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_cabDuration
                     -FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_cabWorked
                     )+' hr(s)'
                  );

               istInTransition: FCWinMain.FCWM_CDPinfrList.Items.AddChild(
                  CPUsubnode
                  ,FCFdTFiles_UIStr_Get(uistrUI, CPUinfStatus)+': '+IntToStr( FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_cabDuration )+' hr(s)'
                  );
            end;
            inc(CPUcnt);
         end; //==END== while CPUcnt<=CPUmax do ==//
         FCWinMain.FCWM_CDPinfrList.FullExpand;
      end;

      dtInfraOwnedIndex:
      begin
         CPUinfStatus:=FCFgInf_Status_GetToken(FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[DataIndex1].CI_status);
         CPUrootnode:=FCWinMain.FCWM_CDPinfrList.Items.GetFirstNode;
         CPUmax:=FCFgI_IndexInFunction_Retrieve(
            0
            ,CPUcol
            ,CPUsettlement
            ,DataIndex1
            )-1;
         isSearchDone:=false;
         CPUnode:=CPUrootnode.getFirstChild;
         while ( CPUnode<>nil )
            and (not isSearchDone) do
         begin
            if FCFuiCDP_FunctionCateg_Compare( FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_settlements[ CDPcurrentSettlement ].CS_infra[ DataIndex1 ].CI_function, CPUnode.Text ) then
            begin
               CPUsubnode:=CPUnode.getFirstChild;
               CPUcnt:=0;
               while CPUcnt<=CPUmax do
               begin
                  if CPUcnt>0
                  then CPUsubnode:=CPUsubnode.getNextSibling;
                  inc( CPUcnt );
               end;
               CPUsubnodeTp:=CPUsubnode.getFirstChild;
               case FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[DataIndex1].CI_status of
                  istInConversion, istInAssembling, istInBldSite: CPUsubnodetp.Text:=
                     FCFdTFiles_UIStr_Get(uistrUI, CPUinfStatus)+': '+IntToStr(
                        FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[DataIndex1].CI_cabDuration
                        -FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[DataIndex1].CI_cabWorked
                        )+' hr(s)';

                  istInTransition:
                  begin
                     if FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[DataIndex1].CI_cabDuration=FCCtransitionTime
                     then CPUsubnode.Text:='<img src="file://'+FCVdiPathResourceDir+'pics-ui-colony\'+CPUinfStatus+'16.jpg" align="middle"> - '
                        +FCFdTFiles_UIStr_Get(uistrUI, FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[DataIndex1].CI_dbToken)
                        +' '+UIHTMLencyBEGIN+FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[DataIndex1].CI_dbToken+UIHTMLencyEND;
                     CPUsubnodetp.Text:=
                        FCFdTFiles_UIStr_Get(uistrUI, CPUinfStatus)+': '+IntToStr( FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[DataIndex1].CI_cabDuration )+' hr(s)'
                        ;
                  end;

                  istOperational:
                  begin
                     CPUsubnode.Text:='<img src="file://'+FCVdiPathResourceDir+'pics-ui-colony\'+CPUinfStatus+'16.jpg" align="middle"> - '
                        +FCFdTFiles_UIStr_Get(uistrUI, FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[DataIndex1].CI_dbToken)
                        +' '+UIHTMLencyBEGIN+FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[DataIndex1].CI_dbToken+UIHTMLencyEND;
                     CPUsubnodeTp.Delete;
                  end;
               end;
               isSearchDone:=true;
            end;
            CPUnode:=CPUnode.getNextSibling;
         end;
      end;

      dtInfraAvail:
      begin
         {.available infrastructure list}
         FCWinMain.FCWM_CDPinfrAvail.Items.Clear;
         CPUrootnodeInfra:=FCWinMain.FCWM_CDPinfrAvail.Items.Add(nil, FCFdTFiles_UIStr_Get(uistrUI, 'infraUIavailTitle'));
         CPUrootnodeInfraEN:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Energy')+']' );
         CPUrootnodeInfraHO:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Housing')+']' );
         CPUrootnodeInfraIN:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Intel')+']' );
         CPUrootnodeInfraMI:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Misc')+']' );
         CPUrootnodeInfraPR:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Prod')+']' );
         {:DEV NOTES: req to implement technosciences database + research status array for entities before to put the code for technoscience requirement.}
         CPUmax:=length(FCDBinfra)-1;
         CPUcnt:=1;
         CPUenvironment:=FCFgC_ColEnv_GetTp(0, CDPcurrentColony);
         CPUrspotIndex:=FCFgPRS_PresenceBySettlement_Check(
            0
            ,CDPcurrentColony
            ,CDPcurrentSettlement
            ,0
            ,rstOreField
            ,true
            );
         while CPUcnt<=CPUmax do
         begin
            CPUrspotIndex:=FCFgPRS_PresenceBySettlement_Check(
               0
               ,CDPcurrentColony
               ,CDPcurrentSettlement
               ,0
               ,FCDBinfra[CPUcnt].I_reqRsrcSpot
               ,false
               );
            if (FCDBinfra[CPUcnt].I_constr=cBuilt)
               and (
                  (FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_level>=FCDBinfra[CPUcnt].I_minLevel)
                     and (FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_level<=FCDBinfra[CPUcnt].I_maxLevel)
                  )
               and ( (FCDBinfra[CPUcnt].I_environment=etAny) or (FCDBinfra[CPUcnt].I_environment=CPUenvironment.ENV_envType) )
               and (
                  ( FCDBinfra[CPUcnt].I_reqGravMin<=CPUenvironment.ENV_gravity )
                     and ( ( FCDBinfra[CPUcnt].I_reqGravMax=-1) or ( FCDBinfra[CPUcnt].I_reqGravMax>=CPUenvironment.ENV_gravity ) )
                  )
               and ((FCDBinfra[CPUcnt].I_reqHydro=hrAny)
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrLiquid_LiquidNH3) and ( (CPUenvironment.ENV_hydroTp=hLiquidH2O) or (CPUenvironment.ENV_hydroTp=hLiquidH2O_blend_NH3) ))
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrNone) and (CPUenvironment.ENV_hydroTp=hNoH2O) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrVapour) and (CPUenvironment.ENV_hydroTp=hVaporH2O) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrLiquid) and (CPUenvironment.ENV_hydroTp=hLiquidH2O) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrIceSheet) and (CPUenvironment.ENV_hydroTp=hIceSheet) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrCrystal) and (CPUenvironment.ENV_hydroTp=hCrystalIce) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrLiquidNH3) and (CPUenvironment.ENV_hydroTp=hLiquidH2O_blend_NH3) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrCH4) and (CPUenvironment.ENV_hydroTp=hLiquidCH4) )
                  )
               and ( (FCDBinfra[CPUcnt].I_reqRsrcSpot=rstNone) or ( CPUrspotIndex>0 ) ) then
            begin
               CPUinfDisplay:='<a href="'+FCDBInfra[CPUcnt].I_token+'">'
                  +FCFdTFiles_UIStr_Get(uistrUI, FCDBInfra[CPUcnt].I_token)
                  +'</a>';
               case FCDBinfra[CPUcnt].I_function of
                  fEnergy: CPUsubnode:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild(CPUrootnodeInfraEN, CPUinfDisplay);
                  fHousing: CPUsubnode:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild(CPUrootnodeInfraHO, CPUinfDisplay);
                  fIntelligence: CPUsubnode:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild(CPUrootnodeInfraIN, CPUinfDisplay);
                  fMiscellaneous: CPUsubnode:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild(CPUrootnodeInfraMI, CPUinfDisplay);
                  fProduction: CPUsubnode:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild(CPUrootnodeInfraPR, CPUinfDisplay);
               end; //==END== case FCDBinfra[CPUcnt].I_function of ==//
            end; //==END== if (FCDBinfra[CPUcnt].I_environment=CPUenvironment) and (FCDBinfra[CPUcnt].I_constr=cBuilt) ==//
            inc(CPUcnt);
         end; //==END== while CPUcnt<=CPUmax do ==//
         {.include the infrastructure kits, if there's any}
         CPUmax:=length(FCentities[0].E_col[CDPcurrentColony].COL_storageList)-1;
         if CPUmax>0 then
         begin
            CPUcnt:=1;
            while CPUcnt<=CPUmax do
            begin
               CPUintDump:=FCFgP_Product_GetIndex(FCentities[0].E_col[CDPcurrentColony].COL_storageList[CPUcnt].CPR_token);
               if (FCDBProducts[CPUintDump].PROD_function=prfuInfraKit)
                  and ( FCentities[0].E_col[CDPcurrentColony].COL_storageList[CPUcnt].CPR_unit>0 )
                  and ( (CPUinfKitroot='') or (FCDBProducts[CPUintDump].PROD_fInfKitToken<>CPUinfKitroot) ) then
               begin
                  CPUinfKitroot:=FCDBProducts[CPUintDump].PROD_fInfKitToken;
                  CPUinfra:=FCFgI_DataStructure_Get(
                     0
                     ,CDPcurrentColony
                     ,FCDBProducts[CPUintDump].PROD_fInfKitToken
                     );
                  if CPUinfra.I_token<>'ERROR'
                  then CPUrspotIndex:=FCFgPRS_PresenceBySettlement_Check(
                     0
                     ,CDPcurrentColony
                     ,CDPcurrentSettlement
                     ,0
                     ,CPUinfra.I_reqRsrcSpot
                     ,false
                     )
                  else raise Exception.Create( 'bad infratoken for infra available list/infrastructure kits: Col= '+intTostr(CDPcurrentColony)+'  product token= '+FCDBProducts[CPUintDump].PROD_fInfKitToken );
                  if (FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_level>=FCDBProducts[CPUintDump].PROD_fInfKitLevel)
                     and ( (CPUinfra.I_environment=etAny) or (CPUinfra.I_environment=CPUenvironment.ENV_envType) )
                     and (
                        ( CPUinfra.I_reqGravMin<=CPUenvironment.ENV_gravity )
                           and ( ( CPUinfra.I_reqGravMax=-1 ) or ( CPUinfra.I_reqGravMax>=CPUenvironment.ENV_gravity ) )
                        )
                     and ( (CPUinfra.I_reqHydro=hrAny)
                        or ( (CPUinfra.I_reqHydro=hrLiquid_LiquidNH3) and ( (CPUenvironment.ENV_hydroTp=hLiquidH2O) or (CPUenvironment.ENV_hydroTp=hLiquidH2O_blend_NH3) ))
                        or ( (CPUinfra.I_reqHydro=hrNone) and (CPUenvironment.ENV_hydroTp=hNoH2O) )
                        or ( (CPUinfra.I_reqHydro=hrVapour) and (CPUenvironment.ENV_hydroTp=hVaporH2O) )
                        or ( (CPUinfra.I_reqHydro=hrLiquid) and (CPUenvironment.ENV_hydroTp=hLiquidH2O) )
                        or ( (CPUinfra.I_reqHydro=hrIceSheet) and (CPUenvironment.ENV_hydroTp=hIceSheet) )
                        or ( (CPUinfra.I_reqHydro=hrCrystal) and (CPUenvironment.ENV_hydroTp=hCrystalIce) )
                        or ( (CPUinfra.I_reqHydro=hrLiquidNH3) and (CPUenvironment.ENV_hydroTp=hLiquidH2O_blend_NH3) )
                        or ( (CPUinfra.I_reqHydro=hrCH4) and (CPUenvironment.ENV_hydroTp=hLiquidCH4) )
                        )
                     and ( (CPUinfra.I_reqRsrcSpot=rstNone) or ( CPUrspotIndex>0 ) ) then
                  begin
                     CPUinfDisplay:='<a href="'+CPUinfra.I_token+'">'+FCFdTFiles_UIStr_Get(uistrUI, CPUinfra.I_token)+'</a> x '+FloatToStr(FCentities[0].E_col[CDPcurrentColony].COL_storageList[CPUcnt].CPR_unit);
                     case CPUinfra.I_function of
                        fEnergy: CPUsubnode:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild(CPUrootnodeInfraEN, CPUinfDisplay);
                        fHousing: CPUsubnode:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild(CPUrootnodeInfraHO, CPUinfDisplay);
                        fIntelligence: CPUsubnode:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild(CPUrootnodeInfraIN, CPUinfDisplay);
                        fMiscellaneous: CPUsubnode:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild(CPUrootnodeInfraMI, CPUinfDisplay);
                        fProduction: CPUsubnode:=FCWinMain.FCWM_CDPinfrAvail.Items.AddChild(CPUrootnodeInfraPR, CPUinfDisplay);
                     end;
                  end; //==END== if CPUinfra.I_token<>'ERROR' ==//
               end; //==END== if FCDBProducts[CPUdump].PROD_function=prfuInfraKit ==//
               inc(CPUcnt);
            end; //==END== while CPUcnt<=CPUmax do ==//
         end; //==END== if CPUmax>0 ==//
         FCWinMain.FCWM_CDPinfrAvail.FullExpand;
      end;

      dtStorageAll:
      begin
         FCWinMain.CDPstorageList.Items.Clear;
         CPUintDump:=length( FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_storageList );
         CPUmax:=CPUintDump-1;
         CPUcnt:=1;
         CPUrootnode:=FCWinMain.CDPstorageList.Items.Add( nil, FCFdTFiles_UIStr_Get(uistrUI, 'colStorage'));
         while CPUcnt<=CPUmax do
         begin
            CPUnode:= FCWinMain.CDPstorageList.Items.AddChild(
               CPUrootnode,
               FCFgP_StringFromUnit_Get(
                  FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_storageList[ CPUcnt ].CPR_token
                  ,FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_storageList[ CPUcnt ].CPR_unit
                  ,FCFdTFiles_UIStr_Get( uistrUI, FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_storageList[ CPUcnt ].CPR_token )
                  ,true
                  ,false
                  )
               );
            inc( CPUcnt );
         end;
         FCWinMain.CDPstorageList.FullExpand;
//         FCWinDebug.AdvMemo1.Lines.Add('1st item:='+FCWinMain.CDPstorageList.Items[1].Text);
//         FCWinDebug.AdvMemo1.Lines.Add('2nd item:='+FCWinMain.CDPstorageList.Items[2].Text);
         FCWinMain.CDPstorageCapacity.HTMLText.Clear;
         {.idx=0}
         FCWinMain.CDPstorageCapacity.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'colStorageCapHead')+FCCFdHeadEnd+'<br>' );
         {.idx=1}
         FCWinMain.CDPstorageCapacity.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'colStorageCapSolid')+' (curr./max)'+FCCFdHeadEnd );
         {.idx=2}
         FCWinMain.CDPstorageCapacity.HTMLText.Add(
            FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacitySolidCurr, ',' )+' m3<br>/<br>'
            +FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacitySolidMax, ',' )+' m3<br>'
            );
         {.idx=3}
         FCWinMain.CDPstorageCapacity.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'colStorageCapLiquid')+' (curr./max)'+FCCFdHeadEnd );
         {.idx=4}
         FCWinMain.CDPstorageCapacity.HTMLText.Add(
            FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityLiquidCurr, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityLiquidMax, ',' )+' m3<br>'
            );
         {.idx=5}
         FCWinMain.CDPstorageCapacity.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'colStorageCapGas')+' (curr./max)'+FCCFdHeadEnd );
         {.idx=6}
         FCWinMain.CDPstorageCapacity.HTMLText.Add(
            FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityGasCurr, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityGasMax, ',' )+' m3<br>'
            );
         {.idx=7}
         FCWinMain.CDPstorageCapacity.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'colStorageCapBio')+' (curr./max)'+FCCFdHeadEnd );
         {.idx=8}
         FCWinMain.CDPstorageCapacity.HTMLText.Add(
            FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityBioCurr, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityBioMax, ',' )+' m3'
            );
      end;

      dtStorageIndex:
      begin
         if DataIndex1+1>FCWinMain.CDPstorageList.Items.Count
         then FCMuiCDP_Data_Update(dtStorageAll, 0, CDPcurrentSettlement, 0)
         else begin
            FCWinMain.CDPstorageList.Items[ DataIndex1 ].Text:=FCFgP_StringFromUnit_Get(
               FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_storageList[ DataIndex1 ].CPR_token
               ,FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_storageList[ DataIndex1 ].CPR_unit
               ,FCFdTFiles_UIStr_Get( uistrUI, FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_storageList[ DataIndex1 ].CPR_token )
               ,true
               ,false
               );
         end;
      end;

      dtStorageCapSolid:
      begin
         FCWinMain.CDPstorageCapacity.HTMLText.Insert(
            2
            ,FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacitySolidCurr, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacitySolidMax, ',' )+' m3<br>'
            );
         FCWinMain.CDPstorageCapacity.HTMLText.Delete( 3 );
      end;

      dtStorageCapLiquid:
      begin
         FCWinMain.CDPstorageCapacity.HTMLText.Insert(
            4
            ,FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityLiquidCurr, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityLiquidMax, ',' )+' m3<br>'
            );
         FCWinMain.CDPstorageCapacity.HTMLText.Delete( 5 );
      end;

      dtStorageCapGas:
      begin
         FCWinMain.CDPstorageCapacity.HTMLText.Insert(
            6
            ,FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityGasCurr, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityGasMax, ',' )+' m3<br>'
            );
         FCWinMain.CDPstorageCapacity.HTMLText.Delete( 7 );
      end;

      dtStorageCapBio:
      begin
         FCWinMain.CDPstorageCapacity.HTMLText.Insert(
            8
            ,FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityBioCurr, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCentities[ 0 ].E_col[ CDPcurrentColony ].COL_storCapacityBioMax, ',' )+' m3'
            );
         FCWinMain.CDPstorageCapacity.HTMLText.Delete( 9 );
      end;

      dtProdMatrixAll:
      begin
         FCWinMain.CDPproductionMatrixList.Items.Clear;
         CPUintDump:=length( FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_productionMatrix );
         CPUmax:=CPUintDump-1;
         CPUcnt:=1;
         CPUrootnode:=FCWinMain.CDPproductionMatrixList.Items.Add( nil, FCFdTFiles_UIStr_Get(uistrUI, 'colProdMatrix') );
         while CPUcnt<=CPUmax do
         begin
            CPUnode:=FCWinMain.CDPproductionMatrixList.Items.AddChild(
               CPUrootnode,
               FCFgP_StringFromUnit_Get(
                  FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_productionMatrix[ CPUcnt ].CPMI_productToken
                  ,FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_productionMatrix[ CPUcnt ].CPMI_globalProdFlow
                  ,FCFdTFiles_UIStr_Get( uistrUI, FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_productionMatrix[ CPUcnt ].CPMI_productToken )
                  ,true
                  ,true
                  )+' /hr'
               );
            inc( CPUcnt );
         end;
         FCWinMain.CDPproductionMatrixList.FullExpand;
      end;

      dtProdMatrixIndex:
      begin
         if DataIndex1+1>FCWinMain.CDPproductionMatrixList.Items.Count
         then FCMuiCDP_Data_Update(dtProdMatrixAll, 0, CDPcurrentSettlement, 0)
         else begin
            FCWinMain.CDPproductionMatrixList.Items[ DataIndex1 ].Text:=FCFgP_StringFromUnit_Get(
               FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_productionMatrix[ DataIndex1 ].CPMI_productToken
               ,FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_productionMatrix[ DataIndex1 ].CPMI_globalProdFlow
               ,FCFdTFiles_UIStr_Get( uistrUI, FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_productionMatrix[ DataIndex1 ].CPMI_productToken )
               ,true
               ,true
               )+' /hr';
         end;
      end;

      dtReservesAll:
      begin
         {.idx=11}
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'colReserves' )+FCCFdHeadEnd) ;
         {.idx=12}
         if FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_reserveOxygen=-1
         then CPUstrDump1:='N/A'
         else CPUstrDump1:=FCFcFunc_ThSep( FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_reserveOxygen );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colReserveOxygen' )+FCCFcolEND+' '+UIHTMLencyBEGIN+''+UIHTMLencyEND+IndX+'<b>'+CPUstrDump1+'</b><br>'
            );
         {.idx=13}
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colReserveFood' )+FCCFcolEND+' '+UIHTMLencyBEGIN+''+UIHTMLencyEND+IndX+'<b>'
               +FCFcFunc_ThSep( FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_reserveFood )+'</b><br>'
            );
         {.idx=14}
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colReserveWater' )+FCCFcolEND+' '+UIHTMLencyBEGIN+''+UIHTMLencyEND+IndX+'<b>'
               +FCFcFunc_ThSep( FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_reserveWater )+'</b><br>'
            );
      end;

      dtReservesOxy:
      begin
         if FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_reserveOxygen=-1
         then CPUstrDump1:='N/A'
         else CPUstrDump1:=FCFcFunc_ThSep( FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_reserveOxygen );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            12
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colReserveOxygen' )+FCCFcolEND+' '+UIHTMLencyBEGIN+''+UIHTMLencyEND+IndX+'<b>'+CPUstrDump1+'</b><br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 13 );
      end;

      dtReservesFood:
      begin
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            13
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colReserveFood' )+FCCFcolEND+' '+UIHTMLencyBEGIN+''+UIHTMLencyEND+IndX+'<b>'
               +FCFcFunc_ThSep( FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_reserveFood )+'</b><br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 14 );
      end;

      dtReservesWater:
      begin
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            14
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colReserveWater' )+FCCFcolEND+' '+UIHTMLencyBEGIN+''+UIHTMLencyEND+IndX+'<b>'
               +FCFcFunc_ThSep( FCEntities[ 0 ].E_col[ CDPcurrentColony ].COL_reserveWater )+'</b><br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 15 );
      end;
   end; //==END== case CPUtp of ==//
end;

procedure FCMuiCDP_Display_Set(
   const CFDssys
         ,CFDstar
         ,CFDoobj
         ,CFDsat: integer
   );
{:Purpose: set the display of the colony data panel
   Additions:
      -2011Jun14- *add: save the current location indexes in a unit's record.
      -2011May25- *add: check if the infrastructure function private data are well initialized, if it's not the case, they're initialized.
      -2011Apr29- *add: set the tag of the WCP assignation edit component with the current colony index.
      -2011Apr28- *code: moved into it's proper unit.
      -2011Jan25- *fix: restore the collapsed data panel if it's needed.
      -2010Jun17- *add: gather colony index and update the data.
      -2010Jun16- *add: relocate surface panel + display the two panels.
}
var
   CFDcol
   ,surfaceOObj
   ,surfaceSat: integer;
begin
   CDPdisplayLocation.CLI_starsys:=CFDssys;
   CDPdisplayLocation.CLI_star:=CFDstar;
   CDPdisplayLocation.CLI_oobj:=CFDoobj;
   CDPdisplayLocation.CLI_sat:=CFDsat;
   if CDPfunctionEN=''
   then FCMuiCDP_FunctionCateg_Initialize;
   if CFDsat=0
   then
   begin
      surfaceOObj:=FCFuiSP_VarCurrentOObj_Get;
      if surfaceOObj<>CFDoobj
      then FCMuiSP_SurfaceEcosphere_Set(
         CFDoobj
         ,0
         ,false
         )
      else
      begin
         FCWinMain.FCWM_SurfPanel.Visible:=true;
         FCWinMain.FCWM_SP_Surface.Enabled:=true;
         FCMuiSP_VarRegionSelected_Reset;
         FCWinMain.FCWM_SP_SurfSel.Width:=0;
         FCWinMain.FCWM_SP_SurfSel.Height:=0;
         FCWinMain.FCWM_SP_SurfSel.Left:=0;
         FCWinMain.FCWM_SP_SurfSel.Top:=0;
      end;
      CFDcol:=FCDduStarSystem[CFDssys].SS_stars[CFDstar].S_orbitalObjects[CFDoobj].OO_colonies[0];
   end
   else if CFDsat>0
   then
   begin
      surfaceSat:=FCFuiSP_VarCurrentSat_Get;
      if surfaceSat<>CFDsat
      then FCMuiSP_SurfaceEcosphere_Set(
         CFDoobj
         ,CFDsat
         ,false
         )
      else
      begin
         FCWinMain.FCWM_SurfPanel.Visible:=true;
         FCWinMain.FCWM_SP_Surface.Enabled:=true;
         FCMuiSP_VarRegionSelected_Reset;
         FCWinMain.FCWM_SP_SurfSel.Width:=0;
         FCWinMain.FCWM_SP_SurfSel.Height:=0;
         FCWinMain.FCWM_SP_SurfSel.Left:=0;
         FCWinMain.FCWM_SP_SurfSel.Top:=0;
      end;
      CFDcol:=FCDduStarSystem[CFDssys].SS_stars[CFDstar].S_orbitalObjects[CFDoobj].OO_satellitesList[CFDsat].OO_colonies[0];
   end;
   if FCWinMain.FCWM_SP_AutoUp.Checked
   then FCWinMain.FCWM_SP_AutoUp.Checked:=false;
   FCMuiSP_Panel_Relocate( false );
   FCWinMain.FCWM_ColDPanel.Visible:=true;
   FCMuiCDD_Colony_Update(
      cdlAll
      ,CFDcol
      ,0
      ,0
      ,false
      ,false
      ,false
      );
   if FCWinMain.FCWM_ColDPanel.Collaps
   then FCWinMain.FCWM_ColDPanel.Collaps:=false;
   FCWinMain.FCWM_ColDPanel.BringToFront;
   FCWinMain.FCWM_SurfPanel.Visible:=true;
end;

procedure FCMuiCDP_FunctionCateg_Initialize;
{:Purpose: set the functions private variables strings.
    Additions:
}
begin
   CDPfunctionEN:='['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Energy')+']';
   CDPfunctionHO:='['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Housing')+']';
   CDPfunctionIN:='['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Intel')+']';
   CDPfunctionMISC:='['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Misc')+']';
   CDPfunctionPR:='['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Prod')+']';
end;

procedure FCMuiCDP_KeyAvailInfra_Test(
   const AITkey: integer;
   const AITshftCtrl: TShiftState
   );
{:Purpose: test key routine for colony panel / available infrastructures list.
    Additions:
      -2012Jan25- *add: complete the routine
}
begin
   if (ssAlt in AITshftCtrl)
   then FCMuiK_WinMain_Test(AITkey, AITshftCtrl);
   {.keep up/down keys for the list}
   if ( (AITkey<>38) and (AITkey<>40) )
   then FCMuiK_WinMain_Test(AITkey, AITshftCtrl);
end;

procedure FCMuiCDP_KeyCWPEquipmentList_Test(
   const InputKey: integer;
   const ShiftControl: TShiftState
   );
{:Purpose: test key routine for colony panel / CWP Equipment List.
    Additions:
}
begin
   if (ssAlt in ShiftControl)
   then FCMuiK_WinMain_Test(InputKey, ShiftControl);
   {.keep up/down keys for the list}
   if ( (InputKey<>38) and (InputKey<>40) )
   then FCMuiK_WinMain_Test(InputKey, ShiftControl);
end;

procedure FCMuiCDP_KeyInfraList_Test(
   const ILKTkey: integer;
   const ILKTshftCtrl: TShiftState
   );
{:Purpose: test key routine for colony panel / infrastructures list.
    Additions:
      -2012Jan25- *mod: routine optimization.
}
begin
   if (ssAlt in ILKTshftCtrl)
   then FCMuiK_WinMain_Test(ILKTkey, ILKTshftCtrl);
   {.ENTER}
   {.infrastructure selection}
   {:DEV NOTE: will be used for details display.}
   if ILKTkey=13
   then
   begin

   end
   {.keep up/down keys for the list}
   else if ( (ILKTkey<>38) and (ILKTkey<>40) )
   then FCMuiK_WinMain_Test(ILKTkey, ILKTshftCtrl);
end;

procedure FCMuiCDP_KeyProductionMatrixList_Test(
   const InputKey: integer;
   const ShiftControl: TShiftState
   );
{:Purpose: test key routine for colony panel / production matrix list.
    Additions:
}
begin
   if (ssAlt in ShiftControl)
   then FCMuiK_WinMain_Test(InputKey, ShiftControl);
   {.keep up/down keys for the list}
   if ( (InputKey<>38) and (InputKey<>40) )
   then FCMuiK_WinMain_Test(InputKey, ShiftControl);
end;

procedure FCMuiCDP_KeyStorageList_Test(
   const InputKey: integer;
   const ShiftControl: TShiftState
   );
{:Purpose: test key routine for colony panel / storage list.
    Additions:
}
begin
   if (ssAlt in ShiftControl)
   then FCMuiK_WinMain_Test(InputKey, ShiftControl);
   {.keep up/down keys for the list}
   if ( (InputKey<>38) and (InputKey<>40) )
   then FCMuiK_WinMain_Test(InputKey, ShiftControl);
end;

end.
