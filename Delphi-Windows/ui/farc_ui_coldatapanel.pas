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
   ,SysUtils;

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
   ,dtInfraAvail
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
function FCFuiCDP_AvailInfra_RetrieveIndex( const AIRIcategoryName: string; const AIRIcategoryIndex: integer ): integer;

///<summary>
///   retrieve the display's current location in the universe
///</summary>
function FCFuiCDP_DisplayLocation_Retrieve: CDPcurrentLocIndexes;

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
///   test key routine for colony panel / available infrastructures list
///</summary>
///   <param="AITkey">key number</param>
///   <param="AITshftCtrl">shift state</param>
procedure FCMuiCDP_AvailInfra_Test(
   const AITkey: integer;
   const AITshftCtrl: TShiftState
   );

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
///    <param name="TFCEuiwColData">colony's data to update</param>
///    <param name="CPUcol">colony index</param>
///    <param name="CPUsettlement">[optional] settlement index</param>
procedure FCMuiCDP_Data_Update(
   const CPUtp: TFCEuicdpDataTypes;
   const CPUcol
         ,CPUsettlement: integer
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
///   test key routine for colony panel / infrastructures list.
///</summary>
///   <param="ILKTkey">key number</param>
///   <param="ILKTshftCtrl">shift state</param>
procedure FCMuiCDP_InfraListKey_Test(
   const ILKTkey: integer;
   const ILKTshftCtrl: TShiftState
   );

///<summary>
///   relocate the surface panel behind the colony panel
///</summary>
procedure FCMuiCDP_Surface_Relocate;

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
   ,farc_data_infrprod
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

function FCFuiCDP_AvailInfra_RetrieveIndex( const AIRIcategoryName: string; const AIRIcategoryIndex: integer ): integer;
{:Purpose: retrieve an database infrastructure index by using HTML tree view selected data.
    Additions:
}
var
   AIRIcount
   ,AIRIcurrentCategoryIndex
   ,AIRImax: integer;

   LIRIfunctionToSearch: TFCEdipFunction;
begin
   Result:=0;
   AIRImax:=0;
   if AIRIcategoryName=CDPfunctionEN
   then LIRIfunctionToSearch:=fEnergy
   else if AIRIcategoryName=CDPfunctionHO
   then LIRIfunctionToSearch:=fHousing
   else if AIRIcategoryName=CDPfunctionIN
   then LIRIfunctionToSearch:=fIntelligence
   else if AIRIcategoryName=CDPfunctionMISC
   then LIRIfunctionToSearch:=fMiscellaneous
   else if AIRIcategoryName=CDPfunctionPR
   then LIRIfunctionToSearch:=fProduction
   else AIRImax:=-1;
   if AIRImax>-1
   then
   begin
      AIRImax:=length(FCDBinfra)-1;
      AIRIcount:=1;
      AIRIcurrentCategoryIndex:=0;
      while AIRIcount<=AIRImax do
      begin
         if FCDBinfra[AIRIcount].I_function=LIRIfunctionToSearch
         then
         begin
            inc(AIRIcurrentCategoryIndex);
            if AIRIcurrentCategoryIndex=AIRIcategoryIndex
            then
            begin
               Result:=AIRIcount;
               break;
            end;
         end;
         inc(AIRIcount);
      end;
   end;
end;

function FCFuiCDP_DisplayLocation_Retrieve: CDPcurrentLocIndexes;
{:Purpose: retrieve the display's current location in the universe.
    Additions:
}
begin
   Result:=CDPdisplayLocation;
end;

function FCFuiCDP_ListInfra_RetrieveIndex( const LIRIcategoryName: string; const LIRIcategoryIndex: integer ): integer;
{:Purpose: retrieve an infrastructure index of the current colony and settlement by using HTML tree view selected data.
    Additions:
}
var
   LIRIcount
   ,LIRIcurrentCategoryIndex
   ,LIRImax: integer;

   LIRIfunctionToSearch: TFCEdipFunction;
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

procedure FCMuiCDP_AvailInfra_Test(
   const AITkey: integer;
   const AITshftCtrl: TShiftState
   );
{:Purpose: test key routine for colony panel / available infrastructures list.
    Additions:
}
begin
   if (ssAlt in AITshftCtrl)
   then FCMuiK_WinMain_Test(AITkey, AITshftCtrl);
//   if ((ILTkey<>13) and (FCWinMain.Tag<>1))
//      and (ILTkey<>38)
//      and (ILTkey<>40)
//   then FCMuiK_WinMain_Test(ILTkey, ILTshftCtrl);
//   {.ENTER}
//   {.infrastructure selection}
//   {:DEV NOTE: will be used for details display.}
//   if ILTkey=13
//   then
//   begin
//
//   end;
end;

procedure FCMuiCDP_CWPAssignKey_Test(
   const CWCPAkey: integer;
   const CWCPAshftCtrl: TShiftState
   );
{:Purpose: test key routine for colony data panel / population / WCP population assign edit.
    Additions:
      -2011Dec22- *mod: update the interface refresh by using the link to the new routine.
      -2011Jul04- *fix: correctly call the colony's storage update to avoid a double update on the storage values + change location of CWP calculations.
      -2011May24- *mod: use a private variable instead of a tag for the colony index.
      -2011May09- *add: update the colony's storage when tools are taken.
                  *add: if there's no enough tools, the number of colonist is reduced to the maximum number of allowable tools.
}
var
   CWPAKTcol
   ,CWPAKTequipIndex: integer;

   CWPAKTvalue: integer;

   CWPAKTcwp: double;
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
      CWPAKTvalue:=StrToInt64(FCWinMain.FCWM_CDPwcpAssign.Text);
      CWPAKTcol:=FCFuiCDP_VarCurrentColony_Get;
      CWPAKTequipIndex:=FCWinMain.FCWM_CDPwcpEquip.ItemIndex;
      if CWPAKTvalue>(FCEntities[0].E_col[CWPAKTcol].COL_population.POP_tpColon-FCEntities[0].E_col[CWPAKTcol].COL_population.POP_tpColonAssigned)
      then CWPAKTvalue:=FCEntities[0].E_col[CWPAKTcol].COL_population.POP_tpColon-FCEntities[0].E_col[CWPAKTcol].COL_population.POP_tpColonAssigned;
      if CWPAKTequipIndex=0
      then CWPAKTcwp:=FCFcFunc_Rnd( cfrttpSizem, CWPAKTvalue*0.5 )
      else if CWPAKTequipIndex>0
      then
      begin
         if FCEntities[0].E_col[CWPAKTcol].COL_storageList[ CDPmanEquipStor[CWPAKTequipIndex] ].CPR_unit<CWPAKTvalue
         then CWPAKTvalue:=round(FCEntities[0].E_col[CWPAKTcol].COL_storageList[ CDPmanEquipStor[CWPAKTequipIndex] ].CPR_unit);
         FCFgC_Storage_Update(
            false
            ,FCEntities[0].E_col[CWPAKTcol].COL_storageList[ CDPmanEquipStor[CWPAKTequipIndex] ].CPR_token
            ,CWPAKTvalue
            ,0
            ,CWPAKTcol
            );
         CWPAKTcwp:=FCFcFunc_Rnd( cfrttpSizem, CWPAKTvalue*FCDBproducts[ CDPmanEquipDB[CWPAKTequipIndex] ].PROD_fManConstWCPcoef );
      end;
      FCEntities[0].E_col[CWPAKTcol].COL_population.POP_tpColonAssigned:=FCEntities[0].E_col[CWPAKTcol].COL_population.POP_tpColonAssigned+CWPAKTvalue;
      FCEntities[0].E_col[CWPAKTcol].COL_population.POP_wcpAssignedPeople:=FCEntities[0].E_col[CWPAKTcol].COL_population.POP_wcpAssignedPeople+CWPAKTvalue;
      FCEntities[0].E_col[CWPAKTcol].COL_population.POP_wcpTotal:=FCEntities[0].E_col[CWPAKTcol].COL_population.POP_wcpTotal+CWPAKTcwp;
      FCMuiCDD_Colony_Update(
         cdlColonyDataPopulation
         ,0
         ,0
         ,false
         ,false
         ,false
         );
      FCWinMain.FCWM_CDPwcpAssign.Text:='';
   end;
end;

procedure FCMuiCDP_CWPAssignVehKey_Test(
   const CWPAVKkey: integer;
   const CWPAVKshftCtrl: TShiftState
   );
{:Purpose: test key routine for colony data panel / population / WCP vehicles assign edit.
    Additions:
      -2011Jan05- *mod: adjust the index due to the removal of the "No Equipment" item in the list.
      -2011Jul04- *fix: correctly call the colony's storage update to avoid a double update on the storage values.
}
var
   CWPAVKTcol
   ,CWPAVKTcrew
   ,CWPAVKTequipIndex
   ,CWPAVKTvalue: integer;

   CWPAVKTcwp: double;
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
      if CWPAVKTequipIndex>0
      then
      begin
         CWPAVKTvalue:=StrToInt64(FCWinMain.FCWM_CDPcwpAssignVeh.Text);
         CWPAVKTcol:=FCFuiCDP_VarCurrentColony_Get;
         if CWPAVKTvalue>FCEntities[0].E_col[CWPAVKTcol].COL_storageList[ CDPmanEquipStor[CWPAVKTequipIndex] ].CPR_unit
         then CWPAVKTvalue:=round(FCEntities[0].E_col[CWPAVKTcol].COL_storageList[ CDPmanEquipStor[CWPAVKTequipIndex] ].CPR_unit);
         CWPAVKTcrew:=CWPAVKTvalue*FCDBproducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].PROD_fMechConstCrew;
         if CWPAVKTcrew>(FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_tpColon-FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_tpColonAssigned)
         then
         begin
            CWPAVKTvalue:=trunc( (FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_tpColon-FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_tpColonAssigned)
               / FCDBproducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].PROD_fMechConstCrew );
            CWPAVKTcrew:=CWPAVKTvalue*FCDBproducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].PROD_fMechConstCrew;
         end;
         FCFgC_Storage_Update(
            false
            ,FCEntities[0].E_col[CWPAVKTcol].COL_storageList[ CDPmanEquipStor[CWPAVKTequipIndex] ].CPR_token
            ,CWPAVKTvalue
            ,0
            ,CWPAVKTcol
            );
         FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_tpColonAssigned:=FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_tpColonAssigned+CWPAVKTcrew;
         FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_wcpAssignedPeople:=FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_wcpAssignedPeople+CWPAVKTcrew;
         CWPAVKTcwp:=FCFcFunc_Rnd( cfrttpSizem, CWPAVKTvalue*FCDBproducts[ CDPmanEquipDB[CWPAVKTequipIndex] ].PROD_fManConstWCPcoef );
         FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_wcpTotal:=FCEntities[0].E_col[CWPAVKTcol].COL_population.POP_wcpTotal+CWPAVKTcwp;
         FCMuiCDD_Colony_Update(
            cdlColonyDataPopulation
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
            if FCDBProducts[WCPRCdbCnt].PROD_function=prfuManConstruction
            then
            begin
               inc(WCPRCindex);
               setlength(CDPmanEquipDB, WCPRCindex+1);
               setlength(CDPmanEquipStor, WCPRCindex+1);
               CDPmanEquipDB[WCPRCindex]:=WCPRCdbCnt;
               CDPmanEquipStor[WCPRCindex]:=WCPRCstorCnt;
               FCWinMain.FCWM_CDPwcpEquip.Items.Add(FCFdTFiles_UIStr_Get(uistrUI, FCDBProducts[WCPRCdbCnt].PROD_token));
            end;
            inc(WCPRCstorCnt);
         end;
      end;
      FCWinMain.FCWM_CDPwcpEquip.ItemIndex:=0;
   end
   else
   begin
      FCWinMain.FCWM_CDPcwpAssignVeh.Visible:=true;
      FCWinMain.FCWM_CDPwcpAssign.Visible:=false;
      WCPRCmax:=Length(FCentities[0].E_col[WCPRCcol].COL_storageList)-1;
      if WCPRCmax>1
      then
      begin
         WCPRCstorCnt:=1;
         while WCPRCstorCnt<=WCPRCmax do
         begin
            WCPRCdbCnt:=FCFgP_Product_GetIndex(FCentities[0].E_col[WCPRCcol].COL_storageList[WCPRCstorCnt].CPR_token);
            if FCDBProducts[WCPRCdbCnt].PROD_function=prfuMechConstruction
            then
            begin
               inc(WCPRCindex);
               setlength(CDPmanEquipDB, WCPRCindex+1);
               setlength(CDPmanEquipStor, WCPRCindex+1);
               CDPmanEquipDB[WCPRCindex]:=WCPRCdbCnt;
               CDPmanEquipStor[WCPRCindex]:=WCPRCstorCnt;
               FCWinMain.FCWM_CDPwcpEquip.Items.Add(FCFdTFiles_UIStr_Get(uistrUI, FCDBProducts[WCPRCdbCnt].PROD_token));
            end;
            inc(WCPRCstorCnt);
         end;
      end;
      FCWinMain.FCWM_CDPwcpEquip.ItemIndex:=0;
   end;
end;

procedure FCMuiCDP_Data_Update(
   const CPUtp: TFCEuicdpDataTypes;
   const CPUcol
         ,CPUsettlement: integer
   );
{:Purpose: update the colony data display
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
   ,CPUpopTtl: string;

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
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'colLvl')+FCCFdHeadEnd);
         {.idx=2}
         CPUcolLv:=inttostr( FCFgC_ColLvl_GetIdx( 0, CDPcurrentColony ) );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add( '['+CPUcolLv+'] '+FCFdTFiles_UIStr_Get(uistrUI, 'colLvl'+CPUcolLv)+'<br>' );
         {.idx=3}
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'colDat' )+FCCFdHeadEnd) ;
         {.idx=4}
         CPUdataIndex:=FCFgCSM_Cohesion_GetIdxStr( 0, CDPcurrentColony );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDcohes' )+FCCFcolEND+'<ind x="79"><b>'
            +inttostr( FCentities[0].E_col[CDPcurrentColony].COL_cohes )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         {.idx=5}
         CPUdataIndex:=FCFgCSM_Security_GetIdxStr(
            0
            ,CDPcurrentColony
            ,false
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add( '<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDsec' )+FCCFcolEND+'<ind x="79"><b>'+CPUdataIndex+'</b><br>' );
         {.idx=6}
         CPUdataIndex:=FCFgCSM_Tension_GetIdx(
            0
            ,CDPcurrentColony
            ,false
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDtens' )+FCCFcolEND+'<ind x="79"><b>'
            +inttostr( FCentities[0].E_col[CDPcurrentColony].COL_tens )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         {.idx=7}
         CPUdataIndex:=FCFgCSM_Education_GetIdxStr(0, CDPcurrentColony);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDedu' )+FCCFcolEND+'<ind x="79"><b>'
            +inttostr( FCentities[0].E_col[CDPcurrentColony].COL_edu )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         {.idx=8}
         CPUdataIndex:=FCFgCSM_Health_GetIdxStr(
            false
            ,0
            ,CDPcurrentColony
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+FCCFcolEND+'<ind x="79"><b>'
            +inttostr(FCentities[0].E_col[CDPcurrentColony].COL_csmHEheal)+'</b> % (<b>'+CPUdataIndex+'<b>)</p>'
            );
         {.idx=9 to 11}
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI, 'colDCSMEnergTitle' )+FCCFdHeadEnd
            );
         CPUintDump:=round( FCentities[0].E_col[CDPcurrentColony].COL_csmENcons*100/FCentities[0].E_col[CDPcurrentColony].COL_csmENgen );
         if (CPUintDump=0)
            and (FCentities[0].E_col[CDPcurrentColony].COL_csmENcons>0)
         then CPUintDump:=1;
         CPUdataIndex:=FCMuiW_PercentColorGBad_Generate( CPUintDump );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergUsed')+FCCFcolEND+'<ind x="58"><b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_csmENgen, ',')+'</b> kW <br>'
            );
         CPUintDump:=round( FCentities[0].E_col[CDPcurrentColony].COL_csmENstorCurr*100/FCentities[0].E_col[CDPcurrentColony].COL_csmENstorMax );
         if (CPUintDump=0)
            and (FCentities[0].E_col[CDPcurrentColony].COL_csmENstorCurr>0)
         then CPUintDump:=1;
         CPUdataIndex:=IntToStr(CPUintDump);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Add(
            '<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergStocked')+FCCFcolEND+'<ind x="58"><b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_csmENstorMax, ',')+'</b> kW </p>'
            );
         FCMuiCDP_Data_Update(dtPopAll, 0, CDPcurrentSettlement);
         FCMuiCDP_Data_Update(dtCSMev, 0, CDPcurrentSettlement);
         FCMuiCDP_Data_Update(dtInfraAll, 0, CDPcurrentSettlement);
      end; //==END== case of: dtAll ==//

      dtLvl:
      begin
         CPUcolLv:=IntToStr( FCFgC_ColLvl_GetIdx( 0, CDPcurrentColony ) );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert( 2, '['+CPUcolLv+'] '+FCFdTFiles_UIStr_Get( uistrUI, 'colLvl'+CPUcolLv )+'<br>' );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 3 );
      end;

      dtCohes:
      begin
         CPUdataIndex:=FCFgCSM_Cohesion_GetIdxStr( 0, CDPcurrentColony );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            4
            ,'<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDcohes' )+FCCFcolEND+'<ind x="79"><b>'
            +inttostr( FCentities[0].E_col[CDPcurrentColony].COL_cohes )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 5 );
      end;

      dtSecu:
      begin
         CPUdataIndex:=FCFgCSM_Security_GetIdxStr(
            0
            ,CDPcurrentColony
            ,false
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            5
            ,'<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDsec' )+FCCFcolEND+'<ind x="79"><b>'+CPUdataIndex+'</b><br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 6 );
      end;

      dtTens:
      begin
         CPUdataIndex:=FCFgCSM_Tension_GetIdx(
            0
            ,CDPcurrentColony
            ,false
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            6
            ,'<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDtens' )+FCCFcolEND+'<ind x="79"><b>'
            +inttostr( FCentities[0].E_col[CDPcurrentColony].COL_tens )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 7 );
      end;

      dtEdu:
      begin
         CPUdataIndex:=FCFgCSM_Education_GetIdxStr(0, CDPcurrentColony);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            7
            ,'<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'colDedu' )+FCCFcolEND+'<ind x="79"><b>'
            +inttostr( FCentities[0].E_col[CDPcurrentColony].COL_edu )+'</b> % (<b>'+CPUdataIndex+'</b>)<br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 8 );
      end;

      dtHeal:
      begin
         CPUdataIndex:=FCFgCSM_Health_GetIdxStr(
            false
            ,0
            ,CDPcurrentColony
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            8
            ,'<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+FCCFcolEND+'<ind x="79"><b>'
            +inttostr(FCentities[0].E_col[CDPcurrentColony].COL_csmHEheal)+'</b> % (<b>'+CPUdataIndex+'<b>)</p>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 9 );
      end;

      dtCSMenergy:
      begin
         CPUintDump:=round( FCentities[0].E_col[CDPcurrentColony].COL_csmENcons*100/FCentities[0].E_col[CDPcurrentColony].COL_csmENgen );
         if (CPUintDump=0)
            and (FCentities[0].E_col[CDPcurrentColony].COL_csmENcons>0)
         then CPUintDump:=1;
         CPUdataIndex:=FCMuiW_PercentColorGBad_Generate( CPUintDump );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            10
            ,'<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergUsed')+FCCFcolEND+'<ind x="58"><b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_csmENgen, ',')+'</b> kW <br>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 11 );
         CPUintDump:=round( FCentities[0].E_col[CDPcurrentColony].COL_csmENstorCurr*100/FCentities[0].E_col[CDPcurrentColony].COL_csmENstorMax );
         if (CPUintDump=0)
            and (FCentities[0].E_col[CDPcurrentColony].COL_csmENstorCurr>0)
         then CPUintDump:=1;
         CPUdataIndex:=IntToStr(CPUintDump);
         FCWinMain.FCWM_CDPinfoText.HTMLText.Insert(
            11
            ,'<p align="left">'+FCCFidxL+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'colDCSMEnergStocked')+FCCFcolEND+'<ind x="58"><b>'+CPUdataIndex+' % of '
            +FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_csmENstorMax, ',')+'</b> kW </p>'
            );
         FCWinMain.FCWM_CDPinfoText.HTMLText.Delete( 12 );
      end;

      dtPopAll:
      begin
         {population display}
         FCWinMain.FCWM_CDPpopList.Items.Clear;
         FCWinMain.FCWM_CDPpopType.Items.Clear;
         CPUpopTtl:=FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_total,',');
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep(FCentities[0].E_col[CDPcurrentColony].COL_csmHOpcap,',');
         CPUdataIndex:=FCFgCSM_SPL_GetIdxMod(
            indexstr
            ,0
            ,CDPcurrentColony
            );
         CPUrootnode:=FCWinMain.FCWM_CDPpopList.Items.Add( nil, 'Population Details');
         FCWinMain.FCWM_CDPpopList.Items.AddChild( CPUrootnode, '<b>'+CPUpopTtl+' / '+CPUpopMaxOrAssigned+'</b> max');
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
         CPUpopTtl:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpColon, ',' );
         CPUpopMaxOrAssigned:=FCFcFunc_ThSep( FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpColonAssigned, ',' );
         FCWinMain.FCWM_CDPpopType.Items.Add(
            nil
            ,FCFdTFiles_UIStr_Get(uistrUI, 'colPTcol')+' [ <b>'+CPUpopMaxOrAssigned+' / '+CPUpopTtl+'</b> ]'
            );
         CPUnodeTp:=FCWinMain.FCWM_CDPpopType.Items.Add(nil, FCFdTFiles_UIStr_Get(uistrUI, 'colPTspe'));
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTaero')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPToff')
               +' [ <b>'+floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpASoff)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTaero')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTmisss')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpASmiSp)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTbio')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTbios')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpBSbio)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTbio')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTdoc')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpBSdoc)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTindus')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTtech')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpIStech)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTindus')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTeng')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpISeng)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTarmy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTsold')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpMSsold)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTarmy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTcom')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpMScomm)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTphy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTphys')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpPSphys)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTphy')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTastrop')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpPSastr)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTeco')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTecol')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpESecol)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTeco')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTecof')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpESecof)+'</b> ]'
            );
         FCWinMain.FCWM_CDPpopType.Items.AddChild(
            CPUnodeTp
            ,'<u>'+FCFdTFiles_UIStr_Get(uistrUI, 'colPTadmin')+'</u>  '+FCFdTFiles_UIStr_Get(uistrUI, 'colPTmedian')+' [ <b>'
               +floattostr(FCentities[0].E_col[CDPcurrentColony].COL_population.POP_tpAmedian)+'</b> ]'
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
            if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_duration=-1
            then CPUrootnode:=FCWinMain.FCWM_CDPcsmeList.Items.Add(nil, FCFdTFiles_UIStr_Get(uistrUI, CPUevN))
            else if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_duration>0
            then CPUrootnode:=FCWinMain.FCWM_CDPcsmeList.Items.Add(
               nil
               ,FCFdTFiles_UIStr_Get(uistrUI, CPUevN)+' ('+FCFdTFiles_UIStr_Get(uistrUI, 'csmdur')+': <b>'+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_duration)
                  +' </b>'+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFwks')+' )'
               );
            FCWinMain.FCWM_CDPpopList.Items.AddChild( CPUrootnode , '<a href="'+CPUevN+'">'+FCFdTFiles_UIStr_Get(uistrUI, 'csmdesc')+'</a>' );
            {.cohesion mod}
            if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_cohMod>0
            then CPUdataIndex:=FCFdTFiles_UIStr_Get(uistrUI, 'colDcohes')+' <b>+'
               +FCCFcolGreen+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_cohMod)+FCCFcolEND+'</b>  '
            else if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_cohMod<0
            then CPUdataIndex:=FCFdTFiles_UIStr_Get(uistrUI, 'colDcohes')+' <b>'
               +FCCFcolRed+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_cohMod)+FCCFcolEND+'</b>  ';
            {.tension mod}
            if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_tensMod>0
            then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>+'
               +FCCFcolGreen+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_tensMod)+FCCFcolEND+'</b>  '
            else if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_tensMod<0
            then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDtens')+' <b>'
               +FCCFcolRed+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_tensMod)+FCCFcolEND+'</b>  ';
            {.security mod}
            if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_secMod>0
            then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDsec')+' <b>+'
               +FCCFcolGreen+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_secMod)+FCCFcolEND+'</b>  '
            else if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_secMod<0
            then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDsec')+' <b>'
               +FCCFcolRed+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_secMod)+FCCFcolEND+'</b>  ';
            {.education mod}
            if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_eduMod>0
            then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDedu')+' <b>+'
               +FCCFcolGreen+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_eduMod)+FCCFcolEND+'</b>  '
            else if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_eduMod<0
            then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDedu')+' <b>'
               +FCCFcolRed+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_eduMod)+FCCFcolEND+'</b>  ';
            {.economic and industrial ouput mod}
            if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_iecoMod<0
            then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'csmieco')+' <b>'+FCCFcolRed+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_iecoMod)+FCCFcolEND
               +'</b>  ';
            {.health mod}
            if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_healMod>0
            then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+' <b>+'+FCCFcolGreen+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_healMod)+FCCFcolEND
               +'</b>  '
            else if FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_healMod<0
            then CPUdataIndex:=CPUdataIndex+FCFdTFiles_UIStr_Get(uistrUI, 'colDheal')+' <b>'
               +FCCFcolRed+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_evList[CPUcnt].CSMEV_healMod)+FCCFcolEND+'</b>  ';
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
         FCMuiCDP_Data_Update(dtInfraOwned, 0, 0);
         FCMuiCDP_Data_Update(dtInfraAvail, 0, 0);
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
            CPUinfDisplay:='<img src="file://'+FCVpathRsrc+'pics-ui-colony\'+CPUinfStatus+'16.jpg" align="middle"> - '
               +'<a href="'+FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_dbToken+'">'
               +FCFdTFiles_UIStr_Get(uistrUI, FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_dbToken)
               +'</a>';
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
                  ,FCFdTFiles_UIStr_Get(uistrUI, CPUinfStatus)+': '+IntToStr(FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_cabDuration-FCentities[0].E_col[CDPcurrentColony].COL_settlements[CDPcurrentSettlement].CS_infra[CPUcnt].CI_cabWorked)+' hr(s)' );
               {:DEV NOTES: for transition, duration calculation must be inmplemented first.}
               {:DEV NOTES: TO IMPLEMENT, transition rule is already DONE.}
               istInTransition: FCWinMain.FCWM_CDPinfrList.Items.AddChild(CPUsubnode, '<i>Not Implemented yet');
            end;
            inc(CPUcnt);
         end; //==END== while CPUcnt<=CPUmax do ==//
         FCWinMain.FCWM_CDPinfrList.FullExpand;
         FCWinMain.FCWM_CDPinfrList.Select(CPUrootnodeInfra);
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
               and ( (FCDBinfra[CPUcnt].I_environment=envAny) or (FCDBinfra[CPUcnt].I_environment=CPUenvironment.ENV_envType) )
               and (
                  ( FCDBinfra[CPUcnt].I_reqGravMin<=CPUenvironment.ENV_gravity )
                     and ( ( FCDBinfra[CPUcnt].I_reqGravMax=-1) or ( FCDBinfra[CPUcnt].I_reqGravMax>=CPUenvironment.ENV_gravity ) )
                  )
               and ((FCDBinfra[CPUcnt].I_reqHydro=hrAny)
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrLiquid_LiquidNH3) and ( (CPUenvironment.ENV_hydroTp=htLiquid) or (CPUenvironment.ENV_hydroTp=htLiqNH3) ))
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrNone) and (CPUenvironment.ENV_hydroTp=htNone) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrVapour) and (CPUenvironment.ENV_hydroTp=htVapor) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrLiquid) and (CPUenvironment.ENV_hydroTp=htLiquid) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrIceSheet) and (CPUenvironment.ENV_hydroTp=htIceSheet) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrCrystal) and (CPUenvironment.ENV_hydroTp=htCrystal) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrLiquidNH3) and (CPUenvironment.ENV_hydroTp=htLiqNH3) )
                  or ((FCDBinfra[CPUcnt].I_reqHydro=hrCH4) and (CPUenvironment.ENV_hydroTp=htLiqCH4) )
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
                     and ( (CPUinfra.I_environment=envAny) or (CPUinfra.I_environment=CPUenvironment.ENV_envType) )
                     and (
                        ( CPUinfra.I_reqGravMin<=CPUenvironment.ENV_gravity )
                           and ( ( CPUinfra.I_reqGravMax=-1 ) or ( CPUinfra.I_reqGravMax>=CPUenvironment.ENV_gravity ) )
                        )
                     and ( (CPUinfra.I_reqHydro=hrAny)
                        or ( (CPUinfra.I_reqHydro=hrLiquid_LiquidNH3) and ( (CPUenvironment.ENV_hydroTp=htLiquid) or (CPUenvironment.ENV_hydroTp=htLiqNH3) ))
                        or ( (CPUinfra.I_reqHydro=hrNone) and (CPUenvironment.ENV_hydroTp=htNone) )
                        or ( (CPUinfra.I_reqHydro=hrVapour) and (CPUenvironment.ENV_hydroTp=htVapor) )
                        or ( (CPUinfra.I_reqHydro=hrLiquid) and (CPUenvironment.ENV_hydroTp=htLiquid) )
                        or ( (CPUinfra.I_reqHydro=hrIceSheet) and (CPUenvironment.ENV_hydroTp=htIceSheet) )
                        or ( (CPUinfra.I_reqHydro=hrCrystal) and (CPUenvironment.ENV_hydroTp=htCrystal) )
                        or ( (CPUinfra.I_reqHydro=hrLiquidNH3) and (CPUenvironment.ENV_hydroTp=htLiqNH3) )
                        or ( (CPUinfra.I_reqHydro=hrCH4) and (CPUenvironment.ENV_hydroTp=htLiqCH4) )
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
         FCWinMain.FCWM_CDPinfrAvail.Select(CPUrootnodeInfra);
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
         FCWinMain.FCWM_SP_Surface.Tag:=0;
         FCWinMain.FCWM_SP_SurfSel.Width:=0;
         FCWinMain.FCWM_SP_SurfSel.Height:=0;
         FCWinMain.FCWM_SP_SurfSel.Left:=0;
         FCWinMain.FCWM_SP_SurfSel.Top:=0;
      end;
      CFDcol:=FCDBSsys[CFDssys].SS_star[CFDstar].SDB_obobj[CFDoobj].OO_colonies[0];
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
         FCWinMain.FCWM_SP_Surface.Tag:=0;
         FCWinMain.FCWM_SP_SurfSel.Width:=0;
         FCWinMain.FCWM_SP_SurfSel.Height:=0;
         FCWinMain.FCWM_SP_SurfSel.Left:=0;
         FCWinMain.FCWM_SP_SurfSel.Top:=0;
      end;
      CFDcol:=FCDBSsys[CFDssys].SS_star[CFDstar].SDB_obobj[CFDoobj].OO_satList[CFDsat].OOS_colonies[0];
   end;
   if FCWinMain.FCWM_SP_AutoUp.Checked
   then FCWinMain.FCWM_SP_AutoUp.Checked:=false;
   FCMuiCDP_Surface_Relocate;
   FCWinMain.FCWM_ColDPanel.Visible:=true;
   FCMuiCDD_Colony_Update(
      cdlColonyAll
      ,CFDcol
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

procedure FCMuiCDP_InfraListKey_Test(
   const ILKTkey: integer;
   const ILKTshftCtrl: TShiftState
   );
{:Purpose: test key routine for colony panel / infrastructures list.
    Additions:
}
begin
   if (ssAlt in ILKTshftCtrl)
   then FCMuiK_WinMain_Test(ILKTkey, ILKTshftCtrl);
   if ((ILKTkey<>13) and (FCWinMain.Tag<>1))
      and (ILKTkey<>38)
      and (ILKTkey<>40)
   then FCMuiK_WinMain_Test(ILKTkey, ILKTshftCtrl);
   {.ENTER}
   {.infrastructure selection}
   {:DEV NOTE: will be used for details display.}
   if ILKTkey=13
   then
   begin

   end;
end;

procedure FCMuiCDP_Surface_Relocate;
{:Purpose: relocate the surface panel behind the colony panel.
    Additions:
}
begin
   if FCWinMain.FCWM_SurfPanel.Collaps
   then FCWinMain.FCWM_SurfPanel.Collaps:=false;
   FCWinMain.FCWM_SurfPanel.Left:=FCWinMain.FCWM_ColDPanel.Left;
   FCWinMain.FCWM_SurfPanel.Top:=FCWinMain.FCWM_ColDPanel.Top+330;
end;

end.
