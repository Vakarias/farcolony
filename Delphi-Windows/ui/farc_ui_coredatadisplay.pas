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
   cdlColonyAll
   ,cdlColonyLevel
   ,cdlColonyDataCohesion
   ,cdlColonyDataSecurity
   ,cdlColonyDataTension
   ,cdlColonyDataEducation
   ,cdlColonyDataHealth
   ,cdlColonyDataCSMenergy
   ,cdlColonyDataPopulation
   ,cdlColonyDataCSMevents
   ,cdlColonyDataInfrastructuresAll
   ,cdlColonyDataInfrastructuresOwned
   ,cdlColonyDataInfrastructuresAvail
   );

type TFCEuicddProductionList=(
   plInfrastructuresInit
   ,plInfrastructuresCABupdate
   ,plProducts
   ,plSpaceUnits
   );

//===========================END FUNCTIONS SECTION==========================================


///<summary>
///   core data display refresh for colony data. Update the Colony Data Panel and the related UMI tabs if required
///</summary>
///   <param name="DataType">type of data to refresh in the display</param>
///   <param name="Colony">colony index #</param>
///   <param name="Settlement">settlement index #</param>
///   <param name="isMustbeTheSameColony">if true=> the Colony index parameter must be of the same value than the current colony displayed</param>
///   <param name="isMustBeTheSameSettlement">if true=> the Settlement index parameter must be of the same value than the current settlement displayed</param>
procedure FCMuiCDD_Colony_Update(
   const DataType: TFCEuicddColonyDataList;
   const Colony
         ,Settlement: integer;
   const isMustBeTheSameColony
         ,isMustBeTheSameSettlement: boolean
   );

///<summary>
///   core data display refresh for production data. Update the Colony Data Panel and the related UMI tabs if required
///</summary>
///   <param name="DataType">type of data to refresh in the display</param>
///   <param name="Colony">colony index #</param>
///   <param name="Settlement">settlement index #</param>
procedure FCMuiCDD_Production_Update(
   const DataType: TFCEuicddProductionList;
   const Colony
         ,Settlement: integer
   );

implementation

uses
   farc_main
   ,farc_ui_coldatapanel;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiCDD_Colony_Update(
   const DataType: TFCEuicddColonyDataList;
   const Colony
         ,Settlement: integer;
   const isMustBeTheSameColony
         ,isMustBeTheSameSettlement: boolean
   );
{:Purpose: core data display refresh for colony data. Update the Colony Data Panel and the related UMI tabs if required.
    Additions:
      -2012Jan03- *add: routine completion.
}
   var
      ColonyDataPanelColony
      ,ColonyDataPanelSettlement: integer;

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
         or ( ( isMustBeTheSameSettlement ) and ( Settlement=ColonyDataPanelSettlement ) )
         )
   then isColonyDataPanelShown:=true;
   case DataType of
      cdlColonyAll:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtAll
            ,Colony
            ,Settlement
            );
         {:DEV NOTES: also update the UMI here (full entry in the colonies list).}
         {:DEV NOTES: update the 3d w/ colony name here, if required.}
      end;

      cdlColonyLevel:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtLvl
            ,Colony
            ,Settlement
            );
      end;

      cdlColonyDataCohesion:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtCohes
            ,Colony
            ,Settlement
            );
         {:DEV NOTES: update UMI here w/ colonies' list.}
      end;

      cdlColonyDataSecurity:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtSecu
            ,Colony
            ,Settlement
            );
      end;

      cdlColonyDataTension:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtTens
            ,Colony
            ,Settlement
            );
      end;

      cdlColonyDataEducation:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtEdu
            ,Colony
            ,Settlement
            );
      end;

      cdlColonyDataHealth:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtHeal
            ,Colony
            ,Settlement
            );
      end;

      cdlColonyDataCSMenergy:
      begin
         if isColonyDataPanelShown
         then FCMuiCDP_Data_Update(
            dtCSMenergy
            ,Colony
            ,Settlement
            );
      end;

      cdlColonyDataPopulation:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPpopul)
         then FCMuiCDP_Data_Update(
            dtPopAll
            ,Colony
            ,Settlement
            );
      end;

      cdlColonyDataCSMevents:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPcsme)
         then FCMuiCDP_Data_Update(
            dtCSMev
            ,Colony
            ,Settlement
            );
      end;

      cdlColonyDataInfrastructuresAll:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPinfr)
         then FCMuiCDP_Data_Update(
            dtInfraAll
            ,Colony
            ,Settlement
            );
      end;

      cdlColonyDataInfrastructuresOwned:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPinfr)
         then FCMuiCDP_Data_Update(
            dtInfraOwned
            ,Colony
            ,Settlement
            );
      end;

      cdlColonyDataInfrastructuresAvail:
      begin
         if ( isColonyDataPanelShown )
            and (FCWinMain.FCWM_CDPepi.ActivePage=FCWinMain.FCWM_CDPinfr)
         then FCMuiCDP_Data_Update(
            dtInfraAvail
            ,Colony
            ,Settlement
            );
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
}
begin
   case DataType of
      plInfrastructuresInit:
      begin
         FCMuiCDD_Colony_Update(
            cdlColonyDataInfrastructuresAll
            ,Colony
            ,Settlement
            ,true
            ,true
            );
         {:DEV NOTES: UMI here.}
      end;

      plInfrastructuresCABupdate:
      begin
         FCMuiCDD_Colony_Update(
            cdlColonyDataInfrastructuresOwned
            ,Colony
            ,Settlement
            ,true
            ,true
            );
         {:DEV NOTES: UMI here.}
      end;

      plProducts:
      begin
//         FCMuiCDD_Colony_Update(
//            cdlColonyDataInfrastructuresOwned
//            ,Colony
//            ,Settlement
//            ,true
//            ,true
//            );
      end;

      plSpaceUnits:
      begin
      end;
   end;
end;

end.
