{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: core data display for all elements of the game

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
unit farc_ui_coredatadisplay;

interface

type TFCEuicddColonyDataList=(
   cdlAll
   ,cdlLevel
   ,cdlDataCohesion
   ,cdlDataSecurity
   ,cdlDataTension
   ,cdlDataEducation
   ,cdlDataHealth
   ,cdlDataCSMenergy
   ,cdlDataPopulation
   ,cdlCSMevents
   ,cdlInfrastructuresAll
   ,cdlInfrastructuresOwned
   ,cdlInfrastructuresAvail
   ,cdlStorageAll
   ,cdlStorageItem
   );

type TFCEuicddProductionList=(
   plInfrastructuresInit
   ,plInfrastructuresCABupdate
   ,plProdMatrixAll
   ,plProdMatrixItem
   );

//===========================END FUNCTIONS SECTION==========================================


///<summary>
///   core data display refresh for colony data. Update the Colony Data Panel and the related UMI tabs if required
///</summary>
///   <param name="DataType">type of data to refresh in the display</param>
///   <param name="Colony">colony index #</param>
///   <param name="Settlement">settlement index #, EXCEPTED FOR cdlStorageItem, it represent the item index #</param>
///   <param name="isMustbeTheSameColony">if true=> the Colony index parameter must be of the same value than the current colony displayed</param>
///   <param name="isMustBeTheSameSettlement">if true=> the Settlement index parameter must be of the same value than the current settlement displayed</param>
///   <param name="isSurfacePanelUpdate">if true=> indicate if the surface panel must be updated too (used in case of language change for ex). Used only w/cdlColonyAll</param>
procedure FCMuiCDD_Colony_Update(
   const DataType: TFCEuicddColonyDataList;
   const Colony
         ,SettlementStorageItemIndex: integer;
   const isMustBeTheSameColony
         ,isMustBeTheSameSettlement
         ,isSurfacePanelUpdate: boolean
   );

///<summary>
///   core data display refresh for production data. Update the Colony Data Panel and the related UMI tabs if required
///</summary>
///   <param name="DataType">type of data to refresh in the display</param>
///   <param name="Colony">colony index #</param>
///   <param name="Settlement">settlement index #, EXCEPTED FOR plProdMatrixItem, it represent the item index #</param>
procedure FCMuiCDD_Production_Update(
   const DataType: TFCEuicddProductionList;
   const Colony
         ,Settlement: integer
   );

implementation

uses
   farc_data_game
   ,farc_data_infrprod
   ,farc_game_prod
   ,farc_main
   ,farc_ui_coldatapanel
   ,farc_ui_surfpanel;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiCDD_Colony_Update(
   const DataType: TFCEuicddColonyDataList;
   const Colony
         ,SettlementStorageItemIndex: integer;
   const isMustBeTheSameColony
         ,isMustBeTheSameSettlement
         ,isSurfacePanelUpdate: boolean
   );
{:Purpose: core data display refresh for colony data. Update the Colony Data Panel and the related UMI tabs if required.
    Additions:
      -2012Jan16- *add: cdlStorageItem - update also the corresponding storage capacity.
      -2012Jan09- *add: storage update.
      -2012Jan08- *add: new parameter to indicate if the surface panel must be updated too (used in case of language change for ex).
      -2012Jan03- *add: routine completion.
}
   var
      ColonyDataPanelColony
      ,ColonyDataPanelSettlement
      ,ReturnInt1
      ,ReturnInt2: integer;

      isColonyDataPanelShown: boolean;
begin
   isColonyDataPanelShown:=false;
   ColonyDataPanelColony:=FCFuiCDP_VarCurrentColony_Get;
   ColonyDataPanelSettlement:=FCFuiCDP_VarCurrentSettlement_Get;
   if ( FCWinMain.FCWM_ColDPanel.Visible )
      and (
         ( not isMustbeTheSameColony )
         or ( ( isMustbeTheSameColony ) and ( Colony=ColonyDataPanelColony ) )
         )
      and (
         ( not isMustBeTheSameSettlement )
         or ( ( isMustBeTheSameSettlement ) and ( SettlementStorageItemIndex=ColonyDataPanelSettlement ) )
         )
   then isColonyDataPanelShown:=true;
   case DataType of
      cdlAll:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtAll
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
         {.update the surface panel if needed}
         if isSurfacePanelUpdate then
         begin
            ReturnInt1:=FCFuiSP_VarCurrentOObj_Get;
            ReturnInt2:=FCFuiSP_VarCurrentSat_Get;
            FCMuiSP_SurfaceEcosphere_Set(
               ReturnInt1
               ,ReturnInt2
               ,false
               );
         end;
         {:DEV NOTES: also update the UMI here (full entry in the colonies list).}
         {:DEV NOTES: update the 3d w/ colony name here, if required.}
      end;

      cdlLevel:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtLvl
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlDataCohesion:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtCohes
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
         {:DEV NOTES: update UMI here w/ colonies' list.}
      end;

      cdlDataSecurity:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtSecu
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlDataTension:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtTens
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlDataEducation:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtEdu
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlDataHealth:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtHeal
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlDataCSMenergy:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtCSMenergy
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlDataPopulation:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPpopul)
         then FCMuiCDP_Data_Update(
            dtPopAll
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlCSMevents:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPcsme)
         then FCMuiCDP_Data_Update(
            dtCSMev
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlInfrastructuresAll:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPinfr)
         then FCMuiCDP_Data_Update(
            dtInfraAll
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlInfrastructuresOwned:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPinfr)
         then FCMuiCDP_Data_Update(
            dtInfraOwned
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlInfrastructuresAvail:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPinfr)
         then FCMuiCDP_Data_Update(
            dtInfraAvail
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlStorageAll:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPstorage)
         then FCMuiCDP_Data_Update(
            dtStorageAll
            ,Colony
            ,SettlementStorageItemIndex
            ,0
            );
      end;

      cdlStorageItem:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPstorage) then
         begin
            FCMuiCDP_Data_Update(
               dtStorageIndex
               ,Colony
               ,0
               ,SettlementStorageItemIndex
               );
            ReturnInt1:=FCFgP_Product_GetIndex( FCEntities[ 0 ].E_col[ Colony ].COL_storageList[ SettlementStorageItemIndex ].CPR_token );
            case FCDBProducts[ ReturnInt1 ].PROD_storage of
               stSolid: FCMuiCDP_Data_Update(
                  dtStorageCapSolid
                  ,Colony
                  ,0
                  ,0
                  );

               stLiquid:FCMuiCDP_Data_Update(
                  dtStorageCapLiquid
                  ,Colony
                  ,0
                  ,0
                  );

               stGas:FCMuiCDP_Data_Update(
                  dtStorageCapGas
                  ,Colony
                  ,0
                  ,0
                  );

               stBiologic:FCMuiCDP_Data_Update(
                  dtStorageCapBio
                  ,Colony
                  ,0
                  ,0
                  );
            end;
         end;
      end;
   end; //==END== case DataType of ==//
end;

procedure FCMuiCDD_Production_Update(
   const DataType: TFCEuicddProductionList;
   const Colony
         ,Settlement: integer
   );
{:Purpose: core data display refresh for production data. Update the Colony Data Panel and the related UMI tabs if required.
    Additions:
      -2012Jan25- *fix: support of the case when Colony=0. Allow a rare case like tab selection to be enabled.
      -2012Jan18- *add: plProdMatrixAll + plProdMatrixItem.
}
   var
      ColonyDataPanelColony: integer;

      isColonyDataPanelShown: boolean;
begin
   isColonyDataPanelShown:=false;
   ColonyDataPanelColony:=FCFuiCDP_VarCurrentColony_Get;
   if ( FCWinMain.FCWM_ColDPanel.Visible )
      and ( ( Colony=0 ) or ( ( Colony>0 ) and ( Colony=ColonyDataPanelColony ) ) )
   then isColonyDataPanelShown:=true;
   case DataType of
      plInfrastructuresInit:
      begin
         FCMuiCDD_Colony_Update(
            cdlInfrastructuresAll
            ,Colony
            ,Settlement
            ,true
            ,true
            ,false
            );
         {:DEV NOTES: UMI here.}
      end;

      plInfrastructuresCABupdate:
      begin
         FCMuiCDD_Colony_Update(
            cdlInfrastructuresOwned
            ,Colony
            ,Settlement
            ,true
            ,true
            ,false
            );
         {:DEV NOTES: UMI here.}
      end;

      plProdMatrixAll:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPstorage)
         then FCMuiCDP_Data_Update(
            dtProdMatrixAll
            ,Colony
            ,0
            ,0
            );
      end;

      plProdMatrixItem:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPstorage)
         then FCMuiCDP_Data_Update(
            dtProdMatrixIndex
            ,Colony
            ,0
            ,Settlement
            );
      end;
   end;
end;

end.
