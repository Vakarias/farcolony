{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: colony data panel unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2013, Jean-Francois Baconnet

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
      LIRImax:=length(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures)-1;
      LIRIcount:=1;
      LIRIcurrentCategoryIndex:=0;
      while LIRIcount<=LIRImax do
      begin
         if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[LIRIcount].I_function=LIRIfunctionToSearch
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
      ColonistLeft:=FCDdgEntities[0].E_colonies[CWPAKTcol].C_population.CP_classColonist-FCDdgEntities[0].E_colonies[CWPAKTcol].C_population.CP_classColonistAssigned;
      if ColonistLeft>0 then
      begin
         CWPAKTvalue:=StrToInt64(FCWinMain.FCWM_CDPwcpAssign.Text);
         CWPAKTequipIndex:=FCWinMain.FCWM_CDPwcpEquip.ItemIndex;
         if CWPAKTvalue>ColonistLeft
         then CWPAKTvalue:=ColonistLeft;
         if CWPAKTequipIndex=0
         then CWPAKTcwp:=FCFcF_Round( rttSizeInMeters, CWPAKTvalue*0.5 )
         else if CWPAKTequipIndex>0
         then
         begin
            if FCDdgEntities[0].E_colonies[CWPAKTcol].C_storedProducts[ CDPmanEquipStor[CWPAKTequipIndex] ].SP_unit<CWPAKTvalue
            then CWPAKTvalue:=round(FCDdgEntities[0].E_colonies[CWPAKTcol].C_storedProducts[ CDPmanEquipStor[CWPAKTequipIndex] ].SP_unit);
            FCFgC_Storage_Update(
               FCDdgEntities[0].E_colonies[CWPAKTcol].C_storedProducts[ CDPmanEquipStor[CWPAKTequipIndex] ].SP_token
               ,-CWPAKTvalue
               ,0
               ,CWPAKTcol
               ,false
               );
            CWPAKTcwp:=FCFcF_Round( rttSizeInMeters, CWPAKTvalue*FCDdipProducts[ CDPmanEquipDB[CWPAKTequipIndex] ].P_fManCwcpCoef );
         end;
         FCDdgEntities[0].E_colonies[CWPAKTcol].C_population.CP_classColonistAssigned:=FCDdgEntities[0].E_colonies[CWPAKTcol].C_population.CP_classColonistAssigned+CWPAKTvalue;
         FCDdgEntities[0].E_colonies[CWPAKTcol].C_population.CP_CWPassignedPeople:=FCDdgEntities[0].E_colonies[CWPAKTcol].C_population.CP_CWPassignedPeople+CWPAKTvalue;
         FCDdgEntities[0].E_colonies[CWPAKTcol].C_population.CP_CWPtotal:=FCDdgEntities[0].E_colonies[CWPAKTcol].C_population.CP_CWPtotal+CWPAKTcwp;
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
      ColonistLeft:=FCDdgEntities[0].E_colonies[CWPAVKTcol].C_population.CP_classColonist-FCDdgEntities[0].E_colonies[CWPAVKTcol].C_population.CP_classColonistAssigned;
      if (ColonistLeft>0)
         and (CWPAVKTequipIndex>0)
      then
      begin
         CWPAVKTvalue:=StrToInt64(FCWinMain.FCWM_CDPcwpAssignVeh.Text);
         if CWPAVKTvalue>FCDdgEntities[0].E_colonies[CWPAVKTcol].C_storedProducts[ CDPmanEquipStor[CWPAVKTequipIndex] ].SP_unit
         then CWPAVKTvalue:=round(FCDdgEntities[0].E_colonies[CWPAVKTcol].C_storedProducts[ CDPmanEquipStor[CWPAVKTequipIndex] ].SP_unit);
         CWPAVKTcrew:=CWPAVKTvalue*FCDdipProducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].P_fMechCcrew;
         if CWPAVKTcrew>(ColonistLeft)
         then
         begin
            CWPAVKTvalue:=trunc( ColonistLeft / FCDdipProducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].P_fMechCcrew );
            CWPAVKTcrew:=CWPAVKTvalue*FCDdipProducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].P_fMechCcrew;
         end;
         FCFgC_Storage_Update(
            FCDdgEntities[0].E_colonies[CWPAVKTcol].C_storedProducts[ CDPmanEquipStor[CWPAVKTequipIndex] ].SP_token
            ,-CWPAVKTvalue
            ,0
            ,CWPAVKTcol
            ,false
            );
         FCDdgEntities[0].E_colonies[CWPAVKTcol].C_population.CP_classColonistAssigned:=FCDdgEntities[0].E_colonies[CWPAVKTcol].C_population.CP_classColonistAssigned+CWPAVKTcrew;
         FCDdgEntities[0].E_colonies[CWPAVKTcol].C_population.CP_CWPassignedPeople:=FCDdgEntities[0].E_colonies[CWPAVKTcol].C_population.CP_CWPassignedPeople+CWPAVKTcrew;
         CWPAVKTcwp:=FCFcF_Round( rttSizeInMeters, CWPAVKTvalue*FCDdipProducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].P_fManCwcpCoef );
         FCDdgEntities[0].E_colonies[CWPAVKTcol].C_population.CP_CWPtotal:=FCDdgEntities[0].E_colonies[CWPAVKTcol].C_population.CP_CWPtotal+CWPAVKTcwp;
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
      WCPRCmax:=Length(FCDdgEntities[0].E_colonies[WCPRCcol].C_storedProducts)-1;
      if WCPRCmax>1
      then
      begin
         WCPRCstorCnt:=1;
         while WCPRCstorCnt<=WCPRCmax do
         begin
            WCPRCdbCnt:=FCFgP_Product_GetIndex(FCDdgEntities[0].E_colonies[WCPRCcol].C_storedProducts[WCPRCstorCnt].SP_token);
            if ( FCDdipProducts[WCPRCdbCnt].P_function=pfManpowerConstruction )
               and ( FCDdgEntities[0].E_colonies[WCPRCcol].C_storedProducts[WCPRCstorCnt].SP_unit>0 )
            then
            begin
               inc(WCPRCindex);
               setlength(CDPmanEquipDB, WCPRCindex+1);
               setlength(CDPmanEquipStor, WCPRCindex+1);
               CDPmanEquipDB[WCPRCindex]:=WCPRCdbCnt;
               CDPmanEquipStor[WCPRCindex]:=WCPRCstorCnt;
               FCWinMain.FCWM_CDPwcpEquip.Items.Add( FCFdTFiles_UIStr_Get( uistrUI, FCDdipProducts[WCPRCdbCnt].P_token )+' (x '+floattostr( FCDdgEntities[0].E_colonies[WCPRCcol].C_storedProducts[WCPRCstorCnt].SP_unit )+')' );
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
      WCPRCmax:=Length(FCDdgEntities[0].E_colonies[WCPRCcol].C_storedProducts)-1;
      if WCPRCmax>1
      then
      begin
         WCPRCstorCnt:=1;
         while WCPRCstorCnt<=WCPRCmax do
         begin
            WCPRCdbCnt:=FCFgP_Product_GetIndex(FCDdgEntities[0].E_colonies[WCPRCcol].C_storedProducts[WCPRCstorCnt].SP_token);
            if ( FCDdipProducts[WCPRCdbCnt].P_function=pfMechanizedConstruction )
               and ( FCDdgEntities[0].E_colonies[WCPRCcol].C_storedProducts[WCPRCstorCnt].SP_unit>0 )
            then
            begin
               inc(WCPRCindex);
               setlength(CDPmanEquipDB, WCPRCindex+1);
               setlength(CDPmanEquipStor, WCPRCindex+1);
               CDPmanEquipDB[WCPRCindex]:=WCPRCdbCnt;
               CDPmanEquipStor[WCPRCindex]:=WCPRCstorCnt;
               FCWinMain.FCWM_CDPwcpEquip.Items.Add(FCFdTFiles_UIStr_Get(uistrUI, FCDdipProducts[WCPRCdbCnt].P_token)+' (x '+floattostr( FCDdgEntities[0].E_colonies[WCPRCcol].C_storedProducts[WCPRCstorCnt].SP_unit )+')' );
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
   -2013Sep29- *mod/add: completion of text localization for dtStorageAll.
   -2013Jan06- *fix: CAB duration display is corrected.
               *fix: for owned infrastructures - transition phase, if the infrastructure is in transition because of a lack of staff, it's now displayed.
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
         if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_name=''
         then FCWinMain.FCWM_CDPcolName.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_CDPcolNameNo')
         else FCWinMain.FCWM_CDPcolName.Text:=FCDdgEntities[0].E_colonies[CDPcurrentColony].C_name;
         {.idx=0}
         CPUfnd:=FCFcF_Time_GetDate(
            FCDdgEntities[0].E_colonies[CDPcurrentColony].C_foundationDateDay
            ,FCDdgEntities[0].E_colonies[CDPcurrentColony].C_foundationDateMonth
            ,FCDdgEntities[0].E_colonies[CDPcurrentColony].C_foundationDateYear
            );
         {:DEV NOTES: add also for satellite...}
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'colFndD' )+FCCFdHeadEnd+CPUfnd+'<br>'
            +FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'colLoc' )+FCCFdHeadEnd
            +FCFdTFiles_UIStr_Get( dtfscPrprName, FCDdgEntities[0].E_colonies[CDPcurrentColony].C_locationOrbitalObject )+'<br>'  //here...
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
               +IndX+'<b>'+inttostr( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_cohesion )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
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
               +IndX+'<b>'+inttostr( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_tension )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         {.idx=6}
         CPUdataIndex:=FCFgCSM_Education_GetIdxStr(0, CDPcurrentColony);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDedu' )+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+inttostr( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_instruction )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         {.idx=7}
         CPUdataIndex:=FCFgCSM_Health_GetIdxStr(
            false
            ,0
            ,CDPcurrentColony
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+inttostr(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmHealth_HealthLevel)+'</b> % (<b>'+CPUdataIndex+'<b>)</p>'
            );
         {.idx=8 to 10}
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'colDCSMEnergTitle' )+FCCFdHeadEnd
            );
         CPUintDump:=round( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_Consumption*100/FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_Generation );
         if (CPUintDump=0)
            and (FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_Consumption>0)
         then CPUintDump:=1;
         CPUdataIndex:=FCMuiW_PercentColorGoodBad_Generate( CPUintDump );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergUsed')+FCCFcolEND+IndX+'<b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_Generation, ',')+'</b> kW <br>'
            );
         CPUintDump:=round( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_StorageCurrent*100/FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_StorageMax );
         if (CPUintDump=0)
            and (FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_StorageCurrent>0)
         then CPUintDump:=1;
         CPUdataIndex:=IntToStr(CPUintDump);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergStocked')+FCCFcolEND+IndX+'<b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_StorageMax, ',')+'</b> kW </p>'
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
               +IndX+'<b>'+inttostr( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_cohesion )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
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
               +IndX+'<b>'+inttostr( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_tension )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 6 );
      end;

      dtEdu:
      begin
         CPUdataIndex:=FCFgCSM_Education_GetIdxStr(0, CDPcurrentColony);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            6
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDedu' )+FCCFcolEND+UIHTMLencyBEGIN+''+UIHTMLencyEND
               +IndX+'<b>'+inttostr( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_instruction )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
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
               +IndX+'<b>'+inttostr(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmHealth_HealthLevel)+'</b> % (<b>'+CPUdataIndex+'<b>)</p>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 8 );
      end;

      dtCSMenergy:
      begin
         CPUintDump:=round( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_Consumption*100/FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_Generation );
         if (CPUintDump=0)
            and (FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_Consumption>0)
         then CPUintDump:=1;
         CPUdataIndex:=FCMuiW_PercentColorGoodBad_Generate( CPUintDump );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            9
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergUsed')+FCCFcolEND+IndX+'<b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_Generation, ',')+'</b> kW <br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 10 );
         CPUintDump:=round( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_StorageCurrent*100/FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_StorageMax );
         if (CPUintDump=0)
            and (FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_StorageCurrent>0)
         then CPUintDump:=1;
         CPUdataIndex:=IntToStr(CPUintDump);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            10
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergStocked')+FCCFcolEND+IndX+'<b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmEnergy_StorageMax, ',')+'</b> kW </p>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 11 );
      end;

      dtPopAll:
      begin
         {population display}
         FCWinMain.FCWM_CDPpopList.Items.Clear;
         FCWinMain.FCWM_CDPpopType.Items.Clear;
         CPUstrDump1:=FCFcFunc_ThSep(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_total,',');
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_csmHousing_PopulationCapacity,',');
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
            ,FCFdTFiles_UIStr_Get(uistrUI, 'colPopMAge')+' [ <b>'+floattostr(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_meanAge)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFstdY')+' ]'
            );
         FCWinMain.FCWM_CDPpopList.Items.AddChild(
            CPUrootnode
            ,FCFdTFiles_UIStr_Get(uistrUI, 'colDdrate')+' [ <b>'+floattostr(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_deathRate)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI, 'colPopBDR')
               +'/'+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFstdY')+']'
            );
         FCWinMain.FCWM_CDPpopList.Items.AddChild(
            CPUrootnode
            ,FCFdTFiles_UIStr_Get(uistrUI, 'colDbrate')+' [ <b>'+floattostr(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_birthRate)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI, 'colPopBDR')
               +'/'+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFstdY')+']'
            );
         CDPconstNode:=FCWinMain.FCWM_CDPpopList.Items.AddChild(nil, FCFdTFiles_UIStr_Get(uistrUI, 'cwpTitle'));
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, FCFdTFiles_UIStr_Get(
            uistrUI, 'cwpAssigned')+' [ <b>'+IntToStr(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_CWPassignedPeople)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, 'Total <a href="cwpRoot">CWP</a> [ <b>'+FloatToStr(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_CWPtotal)+'</b> ]');
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, FCFdTFiles_UIStr_Get(uistrUI, 'cwpColonAdd'));
         FCWinMain.FCWM_CDPpopList.SetRadioButton(CDPconstNode[2], CPUradioIdx=1);
         FCWinMain.FCWM_CDPpopList.SetRadioButton(CDPconstNode[2], true);
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, FCFdTFiles_UIStr_Get(uistrUI, 'cwpMechAdd'));
         FCWinMain.FCWM_CDPpopList.SetRadioButton(CDPconstNode[3], CPUradioIdx=2);
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, FCFdTFiles_UIStr_Get(uistrUI, 'cwpAssignConfirm'));
         FCWinMain.FCWM_CDPpopList.Items.AddChild(CDPconstNode, FCFdTFiles_UIStr_Get(uistrUI, 'cwpAvailEquip'));
         FCMuiCDP_WCPradio_Click(true);
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classColonist, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classColonistAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.Add(
            nil
            ,FCFdTFiles_UIStr_Get(uistrUI, 'colPTcol')+' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUnodeTp:=FCWinMain.FCWM_CDPpopType.Items.Add(nil, FCFdTFiles_UIStr_Get(uistrUI, 'colPTspe'));
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classAerOfficer, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classAerOfficerAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTaero')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPToff')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classAerMissionSpecialist, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classAerMissionSpecialistAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTaero')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTmisss')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classBioBiologist, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classBioBiologistAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTbio')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTbios')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classBioDoctor, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classBioDoctorAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTbio')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTdoc')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classIndTechnician, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classIndTechnicianAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTindus')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTtech')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classIndEngineer, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classIndEngineerAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTindus')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTeng')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classMilSoldier, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classMilSoldierAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTarmy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTsold')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classMilCommando, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classMilCommandoAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTarmy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTcom')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classPhyPhysicist, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classPhyPhysicistAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTphy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTphys')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classPhyAstrophysicist, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classPhyAstrophysicistAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTphy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTastrop')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classEcoEcologist, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classEcoEcologistAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTeco')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTecol')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classEcoEcoformer, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classEcoEcoformerAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTeco')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTecof')
               +' [ <b>'+CPUpopMaxOrAssigned+'</b> / <b>'+CPUstrDump1+'</b> ]'
            );
         CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classAdmMedian, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_population.CP_classAdmMedianAssigned, ',' );
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
         CPUmax:=length(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events)-1;
         CPUcnt:=1;
         while CPUcnt<=CPUmax do
         begin
            CPUevN:=FCFgCSME_Event_GetStr(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_type);
            CPUdataIndex:='';
            CPUrootnode:=FCWinMain.FCWM_CDPcsmeList.Items.Add(nil, FCFdTFiles_UIStr_Get(uistrUI, CPUevN)+UIHTMLencyBEGIN+CPUevN+UIHTMLencyEND );
            if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_durationWeeks>0
            then FCWinMain.FCWM_CDPpopList.Items.AddChild( CPUrootnode, FCFdTFiles_UIStr_Get(uistrUI, 'csmdur')+': <b>'+IntToStr(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_durationWeeks)
                  +' </b>'+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFwks') );
            {.order to display modifiers is: cohesion, tension, security, education, economic and industrial output, health}
            {.the special data are always displayed after the modifiers}
            case FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_type of
               ceColonyEstablished:
               begin
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tCEstTensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tCEstTensionMod, true )+'</b>  ';
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tCEstSecurityMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDsec')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tCEstSecurityMod, true )+'</b>  ';
               end;

               ceUnrest, ceUnrest_Recovering:
               begin
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tCUnEconomicIndustrialOutputMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tCUnEconomicIndustrialOutputMod, true )+'</b>  ';
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tCUnTensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tCUnTensionMod, true )+'</b>  ';
               end;

               ceSocialDisorder, ceSocialDisorder_Recovering:
               begin
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tSDisEconomicIndustrialOutputMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tSDisEconomicIndustrialOutputMod, true )+'</b>  ';
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tSDisTensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tSDisTensionMod, true )+'</b>  ';
               end;

               ceUprising, ceUprising_Recovering:
               begin
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tUpEconomicIndustrialOutputMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tUpEconomicIndustrialOutputMod, true )+'</b>  ';
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tUpTensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tUpTensionMod, true )+'</b>  ';
               end;

               ceHealthEducationRelation:
               begin
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tHERelEducationMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDedu')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tHERelEducationMod, true )+'</b>  ';
               end;

               ceGovernmentDestabilization, ceGovernmentDestabilization_Recovering:
               begin
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tGDestCohesionMod<>0
                  then CPUdataIndex:=FCFdTFiles_UIStr_Get(uistrUI, 'colDcohes')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tGDestCohesionMod, true )+'</b>  ';
               end;

               ceOxygenProductionOverload: CPUdataIndex:=FCFdTFiles_UIStr_Get(uistrUI, 'csmPercPopNotSupported')+'<b>'+IntToStr( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tOPOvPercentPopulationNotSupported )+'</b>  ';

               ceOxygenShortage, ceOxygenShortage_Recovering:
               begin
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tOShEconomicIndustrialOutputMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tOShEconomicIndustrialOutputMod, true )+'</b>  ';
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tOShTensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tOShTensionMod, true )+'</b>  ';
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tOShHealthMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tOShHealthMod, true )+'</b>  ';
               end;

               ceWaterProductionOverload: CPUdataIndex:=FCFdTFiles_UIStr_Get(uistrUI, 'csmPercPopNotSupported')+'<b>'+IntToStr( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tWPOvPercentPopulationNotSupported )+'</b>  ';

               ceWaterShortage, ceWaterShortage_Recovering:
               begin
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tWShEconomicIndustrialOutputMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tWShEconomicIndustrialOutputMod, true )+'</b>  ';
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tWShTensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tWShTensionMod, true )+'</b>  ';
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tWShHealthMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tWShHealthMod, true )+'</b>  ';
               end;

               ceFoodProductionOverload: CPUdataIndex:=FCFdTFiles_UIStr_Get(uistrUI, 'csmPercPopNotSupported')+'<b>'+IntToStr( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tFPOvPercentPopulationNotSupported )+'</b>  ';

               ceFoodShortage, ceFoodShortage_Recovering:
               begin
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tFShEconomicIndustrialOutputMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tFShEconomicIndustrialOutputMod, true )+'</b>  ';
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tFShTensionMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tFShTensionMod, true )+'</b>  ';
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tFShHealthMod<>0
                  then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+' <b>'+FCFuiHTML_Modifier_GetFormat( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_events[CPUcnt].CCSME_tFShHealthMod, true )+'</b>  ';
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
         CPUrootnodeInfra:=FCWinMain.FCWM_CDPinfrList.Items.Add(nil, FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_name);
         CPUrootnodeInfraEN:=FCWinMain.FCWM_CDPinfrList.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Energy')+']' );
         CPUrootnodeInfraHO:=FCWinMain.FCWM_CDPinfrList.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Housing')+']' );
         CPUrootnodeInfraIN:=FCWinMain.FCWM_CDPinfrList.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Intel')+']' );
         CPUrootnodeInfraMI:=FCWinMain.FCWM_CDPinfrList.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Misc')+']' );
         CPUrootnodeInfraPR:=FCWinMain.FCWM_CDPinfrList.Items.AddChild( CPUrootnodeInfra, '['+FCFdTFiles_UIStr_Get(uistrUI, 'infrafunc_Prod')+']' );
         CPUmax:=length(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures)-1;
         CPUcnt:=1;
         while CPUcnt<=CPUmax do
         begin
            CPUinfStatus:=FCFgInf_Status_GetToken(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[CPUcnt].I_status);
            CPUinfDisplay:='<img src="file://'+FCVdiPathResourceDir+'pics-ui-colony\'+CPUinfStatus+'16.jpg" align="middle"> - '
               +FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[CPUcnt].I_token)
               +' '+UIHTMLencyBEGIN+FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[CPUcnt].I_token+UIHTMLencyEND;
            case FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[CPUcnt].I_function of
               fEnergy: CPUsubnode:=FCWinMain.FCWM_CDPinfrList.Items.AddChild(CPUrootnodeInfraEN, CPUinfDisplay);
               fHousing: CPUsubnode:=FCWinMain.FCWM_CDPinfrList.Items.AddChild(CPUrootnodeInfraHO, CPUinfDisplay);
               fIntelligence: CPUsubnode:=FCWinMain.FCWM_CDPinfrList.Items.AddChild(CPUrootnodeInfraIN, CPUinfDisplay);
               fMiscellaneous: CPUsubnode:=FCWinMain.FCWM_CDPinfrList.Items.AddChild(CPUrootnodeInfraMI, CPUinfDisplay);
               fProduction: CPUsubnode:=FCWinMain.FCWM_CDPinfrList.Items.AddChild(CPUrootnodeInfraPR, CPUinfDisplay);
            end; //==END== case FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].IO_func of ==//
            case FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[CPUcnt].I_status of
               isInConversion, isInAssembling, isInBluidingSite:
               begin
                  if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[CPUcnt].I_cabWorked=-1
                  then FCWinMain.FCWM_CDPinfrList.Items.AddChild(
                     CPUsubnode
                     ,FCFdTFiles_UIStr_Get(uistrUI, CPUinfStatus)+': '+IntToStr(
                        FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[CPUcnt].I_cabDuration
                        )+' hr(s)'
                     )
                  else FCWinMain.FCWM_CDPinfrList.Items.AddChild(
                     CPUsubnode
                     ,FCFdTFiles_UIStr_Get(uistrUI, CPUinfStatus)+': '+IntToStr(
                        FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[CPUcnt].I_cabDuration
                        -FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[CPUcnt].I_cabWorked
                        )+' hr(s)'
                     );
               end;

               isInTransition:
               begin
                     if  FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[CPUcnt].I_cabDuration=-1
                     then FCWinMain.FCWM_CDPinfrList.Items.AddChild(
                     CPUsubnode, FCFdTFiles_UIStr_Get( uistrUI, 'infralackofstaff' ) )
                     else FCWinMain.FCWM_CDPinfrList.Items.AddChild(
                  CPUsubnode, FCFdTFiles_UIStr_Get(uistrUI, CPUinfStatus)+': '+IntToStr( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[CPUcnt].I_cabDuration )+' hr(s)');
               end;
            end;
            inc(CPUcnt);
         end; //==END== while CPUcnt<=CPUmax do ==//
         FCWinMain.FCWM_CDPinfrList.FullExpand;
      end;

      dtInfraOwnedIndex:
      begin
         CPUinfStatus:=FCFgInf_Status_GetToken(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_status);
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
            if FCFuiCDP_FunctionCateg_Compare( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_settlements[ CDPcurrentSettlement ].S_infrastructures[ DataIndex1 ].I_function, CPUnode.Text ) then
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
               case FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_status of
                  isInConversion, isInAssembling, isInBluidingSite:
                  begin
                     if FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_cabWorked=-1
                     then CPUsubnodetp.Text:=
                        FCFdTFiles_UIStr_Get(uistrUI, CPUinfStatus)+': '+IntToStr(
                           FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_cabDuration
                           )+' hr(s)'
                     else CPUsubnodetp.Text:=
                        FCFdTFiles_UIStr_Get(uistrUI, CPUinfStatus)+': '+IntToStr(
                           FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_cabDuration
                           -FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_cabWorked
                           )+' hr(s)';
                  end;

                  isInTransition:
                  begin
                     if ( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_cabDuration=-1 )
                        or ( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_cabDuration=FCCdipTransitionTime )
                     then CPUsubnode.Text:='<img src="file://'+FCVdiPathResourceDir+'pics-ui-colony\'+CPUinfStatus+'16.jpg" align="middle"> - '
                        +FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_token)
                        +' '+UIHTMLencyBEGIN+FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_token+UIHTMLencyEND;
                     if  FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_cabDuration=-1
                     then CPUsubnodetp.Text:=FCFdTFiles_UIStr_Get( uistrUI, 'infralackofstaff' )
                     else CPUsubnodetp.Text:=FCFdTFiles_UIStr_Get(uistrUI, CPUinfStatus)+': '+IntToStr( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_cabDuration )+' hr(s)';
                  end;

                  isOperational:
                  begin
                     CPUsubnode.Text:='<img src="file://'+FCVdiPathResourceDir+'pics-ui-colony\'+CPUinfStatus+'16.jpg" align="middle"> - '
                        +FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_token)
                        +' '+UIHTMLencyBEGIN+FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_infrastructures[DataIndex1].I_token+UIHTMLencyEND;
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
         CPUmax:=length(FCDdipInfrastructures)-1;
         CPUcnt:=1;
         CPUenvironment:=FCFgC_ColEnv_GetTp(0, CDPcurrentColony);
         CPUrspotIndex:=FCFgPRS_PresenceBySettlement_Check(
            0
            ,CDPcurrentColony
            ,CDPcurrentSettlement
            ,0
            ,rstOreFields
            ,true
            );
         while CPUcnt<=CPUmax do
         begin
            CPUrspotIndex:=FCFgPRS_PresenceBySettlement_Check(
               0
               ,CDPcurrentColony
               ,CDPcurrentSettlement
               ,0
               ,FCDdipInfrastructures[CPUcnt].I_reqResourceSpot
               ,false
               );
            if (FCDdipInfrastructures[CPUcnt].I_construct=cBuilt)
               and (
                  (FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_level>=FCDdipInfrastructures[CPUcnt].I_minLevel)
                     and (FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_level<=FCDdipInfrastructures[CPUcnt].I_maxLevel)
                  )
               and ( (FCDdipInfrastructures[CPUcnt].I_environment=etAny) or (FCDdipInfrastructures[CPUcnt].I_environment=CPUenvironment.ENV_envType) )
               and (
                  ( FCDdipInfrastructures[CPUcnt].I_reqGravityMin<=CPUenvironment.ENV_gravity )
                     and ( ( FCDdipInfrastructures[CPUcnt].I_reqGravityMax=-1) or ( FCDdipInfrastructures[CPUcnt].I_reqGravityMax>=CPUenvironment.ENV_gravity ) )
                  )
               and ((FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrAny)
                  or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrWaterLiquid ) and ( CPUenvironment.ENV_hydroTp = hWaterLiquid ) )
                  or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrWaterIceSheet ) and ( CPUenvironment.ENV_hydroTp=hWaterIceSheet ) )
                  or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrWaterIceCrust ) and ( CPUenvironment.ENV_hydroTp=hWaterIceCrust ) )
                  or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrWaterLiquid_IceSheet ) and ( ( CPUenvironment.ENV_hydroTp=hWaterLiquid ) or ( CPUenvironment.ENV_hydroTp=hWaterIceSheet ) ) )
                  or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrWaterAmmoniaLiquid ) and ( CPUenvironment.ENV_hydroTp=hWaterAmmoniaLiquid ) )
                  or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrMethaneLiquid ) and ( CPUenvironment.ENV_hydroTp=hMethaneLiquid ) )
                  )
               and ( (FCDdipInfrastructures[CPUcnt].I_reqResourceSpot=rstNone) or ( CPUrspotIndex>0 ) ) then
            begin
               CPUinfDisplay:='<a href="'+FCDdipInfrastructures[CPUcnt].I_token+'">'
                  +FCFdTFiles_UIStr_Get(uistrUI, FCDdipInfrastructures[CPUcnt].I_token)
                  +'</a>';
               case FCDdipInfrastructures[CPUcnt].I_function of
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
         CPUmax:=length(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_storedProducts)-1;
         if CPUmax>0 then
         begin
            CPUcnt:=1;
            while CPUcnt<=CPUmax do
            begin
               CPUintDump:=FCFgP_Product_GetIndex(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_storedProducts[CPUcnt].SP_token);
               if (FCDdipProducts[CPUintDump].P_function=pfInfrastructureKit)
                  and ( FCDdgEntities[0].E_colonies[CDPcurrentColony].C_storedProducts[CPUcnt].SP_unit>0 )
                  and ( (CPUinfKitroot='') or (FCDdipProducts[CPUintDump].P_fIKtoken<>CPUinfKitroot) ) then
               begin
                  CPUinfKitroot:=FCDdipProducts[CPUintDump].P_fIKtoken;
                  CPUinfra:=FCFgI_DataStructure_Get(
                     0
                     ,CDPcurrentColony
                     ,FCDdipProducts[CPUintDump].P_fIKtoken
                     );
                  if CPUinfra.I_token<>'ERROR'
                  then CPUrspotIndex:=FCFgPRS_PresenceBySettlement_Check(
                     0
                     ,CDPcurrentColony
                     ,CDPcurrentSettlement
                     ,0
                     ,CPUinfra.I_reqResourceSpot
                     ,false
                     )
                  else raise Exception.Create( 'bad infratoken for infra available list/infrastructure kits: Col= '+intTostr(CDPcurrentColony)+'  product token= '+FCDdipProducts[CPUintDump].P_fIKtoken );
                  if (FCDdgEntities[0].E_colonies[CDPcurrentColony].C_settlements[CDPcurrentSettlement].S_level>=FCDdipProducts[CPUintDump].P_fIKlevel)
                     and ( (CPUinfra.I_environment=etAny) or (CPUinfra.I_environment=CPUenvironment.ENV_envType) )
                     and ( ( CPUinfra.I_reqGravityMin<=CPUenvironment.ENV_gravity ) and ( ( CPUinfra.I_reqGravityMax=-1 ) or ( CPUinfra.I_reqGravityMax>=CPUenvironment.ENV_gravity ) ) )
                     and ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere = hrAny )
                        or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrWaterLiquid ) and ( CPUenvironment.ENV_hydroTp = hWaterLiquid ) )
                        or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrWaterIceSheet ) and ( CPUenvironment.ENV_hydroTp=hWaterIceSheet ) )
                        or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrWaterIceCrust ) and ( CPUenvironment.ENV_hydroTp=hWaterIceCrust ) )
                        or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrWaterLiquid_IceSheet ) and ( ( CPUenvironment.ENV_hydroTp=hWaterLiquid ) or ( CPUenvironment.ENV_hydroTp=hWaterIceSheet ) ) )
                        or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrWaterAmmoniaLiquid ) and ( CPUenvironment.ENV_hydroTp=hWaterAmmoniaLiquid ) )
                        or ( ( FCDdipInfrastructures[CPUcnt].I_reqHydrosphere=hrMethaneLiquid ) and ( CPUenvironment.ENV_hydroTp=hMethaneLiquid ) )
                        )
                     and ( (CPUinfra.I_reqResourceSpot=rstNone) or ( CPUrspotIndex>0 ) ) then
                  begin
                     CPUinfDisplay:='<a href="'+CPUinfra.I_token+'">'+FCFdTFiles_UIStr_Get(uistrUI, CPUinfra.I_token)+'</a> x '+FloatToStr(FCDdgEntities[0].E_colonies[CDPcurrentColony].C_storedProducts[CPUcnt].SP_unit);
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
         CPUintDump:=length( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storedProducts );
         CPUmax:=CPUintDump-1;
         CPUcnt:=1;
         CPUrootnode:=FCWinMain.CDPstorageList.Items.Add( nil, FCFdTFiles_UIStr_Get(uistrUI, 'colStorage'));
         while CPUcnt<=CPUmax do
         begin
            CPUnode:= FCWinMain.CDPstorageList.Items.AddChild(
               CPUrootnode,
               FCFgP_StringFromUnit_Get(
                  FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storedProducts[ CPUcnt ].SP_token
                  ,FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storedProducts[ CPUcnt ].SP_unit
                  ,FCFdTFiles_UIStr_Get( uistrUI, FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storedProducts[ CPUcnt ].SP_token )
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
         FCWinMain.CDPstorageCapacity.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'colStorageCapSolid')+' ('+FCFdTFiles_UIStr_Get( uistrUI, 'capacityCurr' )+'/'+FCFdTFiles_UIStr_Get( uistrUI, 'capacityMax' )+')'+FCCFdHeadEnd );
         {.idx=2}
         FCWinMain.CDPstorageCapacity.HTMLText.Add(
            FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacitySolidCurrent, ',' )+' m3<br>/<br>'
            +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacitySolidMax, ',' )+' m3<br>'
            );
         {.idx=3}
         FCWinMain.CDPstorageCapacity.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'colStorageCapLiquid')+' ('+FCFdTFiles_UIStr_Get( uistrUI, 'capacityCurr' )+'/'+FCFdTFiles_UIStr_Get( uistrUI, 'capacityMax' )+')'+FCCFdHeadEnd );
         {.idx=4}
         FCWinMain.CDPstorageCapacity.HTMLText.Add(
            FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityLiquidCurrent, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityLiquidMax, ',' )+' m3<br>'
            );
         {.idx=5}
         FCWinMain.CDPstorageCapacity.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'colStorageCapGas')+' ('+FCFdTFiles_UIStr_Get( uistrUI, 'capacityCurr' )+'/'+FCFdTFiles_UIStr_Get( uistrUI, 'capacityMax' )+')'+FCCFdHeadEnd );
         {.idx=6}
         FCWinMain.CDPstorageCapacity.HTMLText.Add(
            FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityGasCurrent, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityGasMax, ',' )+' m3<br>'
            );
         {.idx=7}
         FCWinMain.CDPstorageCapacity.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'colStorageCapBio')+' ('+FCFdTFiles_UIStr_Get( uistrUI, 'capacityCurr' )+'/'+FCFdTFiles_UIStr_Get( uistrUI, 'capacityMax' )+')'+FCCFdHeadEnd );
         {.idx=8}
         FCWinMain.CDPstorageCapacity.HTMLText.Add(
            FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityBioCurrent, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityBioMax, ',' )+' m3'
            );
      end;

      dtStorageIndex:
      begin
         if DataIndex1+1>FCWinMain.CDPstorageList.Items.Count
         then FCMuiCDP_Data_Update(dtStorageAll, 0, CDPcurrentSettlement, 0)
         else begin
            FCWinMain.CDPstorageList.Items[ DataIndex1 ].Text:=FCFgP_StringFromUnit_Get(
               FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storedProducts[ DataIndex1 ].SP_token
               ,FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storedProducts[ DataIndex1 ].SP_unit
               ,FCFdTFiles_UIStr_Get( uistrUI, FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storedProducts[ DataIndex1 ].SP_token )
               ,true
               ,false
               );
         end;
      end;

      dtStorageCapSolid:
      begin
         FCWinMain.CDPstorageCapacity.HTMLText.Insert(
            2
            ,FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacitySolidCurrent, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacitySolidMax, ',' )+' m3<br>'
            );
         FCWinMain.CDPstorageCapacity.HTMLText.Delete( 3 );
      end;

      dtStorageCapLiquid:
      begin
         FCWinMain.CDPstorageCapacity.HTMLText.Insert(
            4
            ,FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityLiquidCurrent, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityLiquidMax, ',' )+' m3<br>'
            );
         FCWinMain.CDPstorageCapacity.HTMLText.Delete( 5 );
      end;

      dtStorageCapGas:
      begin
         FCWinMain.CDPstorageCapacity.HTMLText.Insert(
            6
            ,FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityGasCurrent, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityGasMax, ',' )+' m3<br>'
            );
         FCWinMain.CDPstorageCapacity.HTMLText.Delete( 7 );
      end;

      dtStorageCapBio:
      begin
         FCWinMain.CDPstorageCapacity.HTMLText.Insert(
            8
            ,FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityBioCurrent, ',' )+' m3<br>/<br>'
               +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_storageCapacityBioMax, ',' )+' m3'
            );
         FCWinMain.CDPstorageCapacity.HTMLText.Delete( 9 );
      end;

      dtProdMatrixAll:
      begin
         FCWinMain.CDPproductionMatrixList.Items.Clear;
         CPUintDump:=length( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_productionMatrix );
         CPUmax:=CPUintDump-1;
         CPUcnt:=1;
         CPUrootnode:=FCWinMain.CDPproductionMatrixList.Items.Add( nil, FCFdTFiles_UIStr_Get(uistrUI, 'colProdMatrix') );
         while CPUcnt<=CPUmax do
         begin
            CPUnode:=FCWinMain.CDPproductionMatrixList.Items.AddChild(
               CPUrootnode,
               FCFgP_StringFromUnit_Get(
                  FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_productionMatrix[ CPUcnt ].PM_productToken
                  ,FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_productionMatrix[ CPUcnt ].PM_globalProductionFlow
                  ,FCFdTFiles_UIStr_Get( uistrUI, FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_productionMatrix[ CPUcnt ].PM_productToken )
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
               FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_productionMatrix[ DataIndex1 ].PM_productToken
               ,FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_productionMatrix[ DataIndex1 ].PM_globalProductionFlow
               ,FCFdTFiles_UIStr_Get( uistrUI, FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_productionMatrix[ DataIndex1 ].PM_productToken )
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
         if FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_reserveOxygen=-1
         then CPUstrDump1:='N/A'
         else CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_reserveOxygen );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colReserveOxygen' )+FCCFcolEND+' '+UIHTMLencyBEGIN+''+UIHTMLencyEND+IndX+'<b>'+CPUstrDump1+'</b><br>'
            );
         {.idx=13}
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colReserveFood' )+FCCFcolEND+' '+UIHTMLencyBEGIN+''+UIHTMLencyEND+IndX+'<b>'
               +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_reserveFood )+'</b><br>'
            );
         {.idx=14}
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colReserveWater' )+FCCFcolEND+' '+UIHTMLencyBEGIN+''+UIHTMLencyEND+IndX+'<b>'
               +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_reserveWater )+'</b><br>'
            );
      end;

      dtReservesOxy:
      begin
         if FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_reserveOxygen=-1
         then CPUstrDump1:='N/A'
         else CPUstrDump1:=FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_reserveOxygen );
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
               +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_reserveFood )+'</b><br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 14 );
      end;

      dtReservesWater:
      begin
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            14
            ,'<p align="left">'+FCCFidxL6+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colReserveWater' )+FCCFcolEND+' '+UIHTMLencyBEGIN+''+UIHTMLencyEND+IndX+'<b>'
               +FCFcFunc_ThSep( FCDdgEntities[ 0 ].E_colonies[ CDPcurrentColony ].C_reserveWater )+'</b><br>'
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
         CFDssys
         ,CFDstar
         ,CFDoobj
         ,0
         ,false
         )
      else
      begin
         FCWinMain.MVG_SurfacePanel.Visible:=true;
         FCWinMain.SP_SurfaceDisplay.Enabled:=true;
         FCMuiSP_VarRegionHoveredSelected_Reset;
         FCWinMain.SP_SD_SurfaceSelector.Width:=0;
         FCWinMain.SP_SD_SurfaceSelector.Height:=0;
         FCWinMain.SP_SD_SurfaceSelector.Left:=0;
         FCWinMain.SP_SD_SurfaceSelector.Top:=0;
      end;
      CFDcol:=FCDduStarSystem[CFDssys].SS_stars[CFDstar].S_orbitalObjects[CFDoobj].OO_colonies[0];
   end
   else if CFDsat>0
   then
   begin
      surfaceSat:=FCFuiSP_VarCurrentSat_Get;
      if surfaceSat<>CFDsat
      then FCMuiSP_SurfaceEcosphere_Set(
         CFDssys
         ,CFDstar
         ,CFDoobj
         ,CFDsat
         ,false
         )
      else
      begin
         FCWinMain.MVG_SurfacePanel.Visible:=true;
         FCWinMain.SP_SurfaceDisplay.Enabled:=true;
         FCMuiSP_VarRegionHoveredSelected_Reset;
         FCWinMain.SP_SD_SurfaceSelector.Width:=0;
         FCWinMain.SP_SD_SurfaceSelector.Height:=0;
         FCWinMain.SP_SD_SurfaceSelector.Left:=0;
         FCWinMain.SP_SD_SurfaceSelector.Top:=0;
      end;
      CFDcol:=FCDduStarSystem[CFDssys].SS_stars[CFDstar].S_orbitalObjects[CFDoobj].OO_satellitesList[CFDsat].OO_colonies[0];
   end;
   if FCWinMain.SP_AutoUpdateCheck.Checked
   then FCWinMain.SP_AutoUpdateCheck.Checked:=false;
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
   FCWinMain.MVG_SurfacePanel.Visible:=true;
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
