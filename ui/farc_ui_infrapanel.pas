{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructure panel unit.

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
unit farc_ui_infrapanel;

interface

uses
   Classes
   ,SysUtils;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   setup the panel for display the assembling/building configuration interface of the selected available infrastructure
///</summary>
///   <param name="AISinfraToken">database infrastructure token</param>
///   <param name="AISmouseX">mouse position X</param>
///   <param name="AISmouseY">mouse position Y</param>
procedure FCMuiIP_AvailInfra_Setup(
   const AISinfraToken: string;
   const AISmouseX
         ,AISmouseY: integer
   );

///<summary>
///   switch to the correct assembling/building process, regarding the UIIPisAssembling state
///</summary>
procedure FCMuiIP_CABMode_Switch;

///<summary>
///   calculate the duration according to the selected infrastructure kit, and update the interface
///</summary>
procedure FCMuiIP_InfrastructureKit_Select;

///<summary>
///   setup the panel for display the configuration interface of the selected infrastructure
///</summary>
///   <param name="ILSinfraIndex">infrastructure index in the settlement's structure</param>
///   <param name="ILSmouseX">mouse position X</param>
///   <param name="ILSmouseY">mouse position Y</param>
procedure FCMuiIP_InfraList_Setup(
   const ILSinfraIndex
         ,ILSmouseX
         ,ILSmouseY: integer
         );

///<summary>
///   test key routine for the infrastructure panel
///</summary>
///   <param="CNTkeyDump">key number</param>
///   <param="CNTTshftCtrl">shift state</param>
procedure FCMuiIP_PanelKey_Test(
   const PKTkey: integer;
   const PKTshftCtrl: TShiftState
   );

implementation

uses
   farc_data_game
   ,farc_data_html
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_game_colony
   ,farc_game_infra
   ,farc_game_infraconsys
   ,farc_main
   ,farc_ui_coldatapanel
   ,farc_ui_keys;

var
   UIIPcolony
   ,UIIPduration
   ,UIIPinfraKitUsed
   ,UIIPsettlement: integer;

   UIIPiCWP: extended;

   UIIPinfraToken: string;

   UIIPisAssembling: boolean;

   UIIPinfrastructure: TFCRdipInfrastructure;

   UIIPinfraKitList: TFCRgcInfraKit;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiIP_AvailInfra_Setup(
   const AISinfraToken: string;
   const AISmouseX
         ,AISmouseY: integer
   );
{:Purpose: setup the panel for display the assembling/building configuration interface of the selected available infrastructure.
    Additions:
      -2011Jul05- *mod: iCWP are calculated differently for assembling and building processes.
      -2011Jul04- *add: assembling - completion of display of multiple infrastructure kits including the selection.
      -2011Jun29- *add: infrastructure kits display and selection (WIP).
      -2011Jun28- *add: infrastructure kits display and selection (WIP).
      -2011Jun14- *add: put the correct duration calculations concerning the building mode.
      -2011Jun07- *add: text localization.
                  *add: conceal the confirm button in case of error.
                  *mod: colony#, settlement#, calculated iCWP and duration are no two unit's private data.
      -2011Jun06- *add: take in account the case when the iCWP=0.
                  *add: case text for iWCP display between assembling and building + decision to show/hide confirmation button.
                  *add: texts localization.
      -2011Jun05- *mod: refine the panel location.
                  *add: display a custom panel title and message depending it's an assembling or building.
                  *add: display the iCWP that will be assigned to the infrastructure.
      -2011May31- *add: 3 parameters for gather the mouse position for display the panel under the mouse cursor and the infrastructure token.
                  *add: display the infrastructure's name and "details" link.
}
   var
      AISinfraKitCnt
      ,AISinfraKitMax: integer;

      AISicwpResult
      ,AISicwpResultHours
      ,AIStask
      ,AISbreakFormat
      ,AIStitle: string;

      AIScurrLocation: CDPcurrentLocIndexes;
begin
   AIStask:='';
   AIStitle:='';
   UIIPiCWP:=0;
   UIIPcolony:=0;
   UIIPduration:=0;
   UIIPinfraKitUsed:=0;
   UIIPsettlement:=0;
   UIIPinfraToken:=AISinfraToken;
   AIScurrLocation:=FCFuiCDP_DisplayLocation_Retrieve;
   FCWinMain.FCWM_IPinfraKits.Items.Clear;
   FCWinMain.FCWM_IPinfraKits.Hide;
   SetLength(UIIPinfraKitList, 1);
   if (AISinfraToken='')
      and (FCWinMain.FCWM_InfraPanel.Visible)
   then FCWinMain.FCWM_InfraPanel.Hide
   else if AISinfraToken<>''
   then
   begin
      UIIPcolony:=FCFuiCDP_VarCurrentColony_Get;
      UIIPsettlement:=FCFuiCDP_VarCurrentSettlement_Get;
      UIIPinfrastructure:=FCFgI_DataStructure_Get(
         0
         ,UIIPcolony
         ,AISinfraToken
         );
      if UIIPinfrastructure.I_construct=cBuilt
      then
      begin
         UIIPisAssembling:=false;
         AIStitle:=FCCFpanelTitle+FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtitleBuild');
         UIIPiCWP:=FCFgICS_iCWP_Calculation(
            0
            ,UIIPcolony
            ,FCDdgEntities[0].E_colonies[UIIPcolony].C_settlements[UIIPcolony].S_level
            );
         if UIIPiCWP>0
         then
         begin

            if AIScurrLocation.CLI_sat=0
            then UIIPduration:=FCFgICS_BuildingDuration_Calculation(
               UIIPinfrastructure.I_volume[FCDdgEntities[0].E_colonies[UIIPcolony].C_settlements[UIIPsettlement].S_level]
               ,1
               ,UIIPiCWP
               ,FCDduStarSystem[AIScurrLocation.CLI_starsys].SS_stars[AIScurrLocation.CLI_star].S_orbitalObjects[AIScurrLocation.CLI_oobj].OO_regions[ FCDdgEntities[0].E_colonies[UIIPcolony].C_settlements[UIIPcolony].S_locationRegion ].OOR_emo.EMO_cab
               )
            else if AIScurrLocation.CLI_sat<>0
            then UIIPduration:=FCFgICS_BuildingDuration_Calculation(
               UIIPinfrastructure.I_volume[FCDdgEntities[0].E_colonies[UIIPcolony].C_settlements[UIIPsettlement].S_level]
               ,1
               ,UIIPiCWP
               ,FCDduStarSystem[AIScurrLocation.CLI_starsys].SS_stars[AIScurrLocation.CLI_star].S_orbitalObjects[AIScurrLocation.CLI_oobj].OO_satellitesList[AIScurrLocation.CLI_sat].OO_regions[ FCDdgEntities[0].E_colonies[UIIPcolony].C_settlements[UIIPcolony].S_locationRegion ].OOR_emo.EMO_cab
               );
            AIStask:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskBuild');
            AISicwpResult:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskCWPbuild')+' <b>'+FloatToStr(UIIPiCWP)+'</b> ...';
            AISicwpResultHours:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskDuration1')+' <b>'+IntToStr(UIIPduration)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskDuration2');
            FCWinMain.FCWM_IPconfirmButton.Show;
         end
         else
         begin
            AIStask:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskCannotBuild');
            AISicwpResult:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskCannotAssemble2');
            AISicwpResultHours:='';
            FCWinMain.FCWM_IPconfirmButton.Hide;
         end;
      end
      else if UIIPinfrastructure.I_construct=cPrefab
      then
      begin
         UIIPisAssembling:=true;
         AIStitle:=FCCFpanelTitle+FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtitleAssemble');
         UIIPiCWP:=FCFgICS_iCWP_Calculation(
            0
            ,UIIPcolony
            ,1
            );
         if UIIPiCWP>0
         then
         begin
            UIIPinfraKitList:=FCFgC_InfraKitsInStorage_Retrieve(
               0
               ,UIIPcolony
               ,UIIPsettlement
               ,AISinfraToken
               );
            AIStask:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskAssemble');
            AISinfraKitMax:=length(UIIPinfraKitList)-1;
            AISbreakFormat:='';
            if AISinfraKitMax=1
            then
            begin
               FCWinMain.FCWM_IPinfraKits.Hide;
               FCWinMain.FCWM_IPinfraKits.Enabled:=false;
               FCWinMain.FCWM_IPinfraKits.ItemIndex:=-1;
               FCWinMain.FCWM_IPinfraKits.Enabled:=true;
               UIIPduration:=FCFgICS_AssemblingDuration_Calculation(
                  UIIPinfrastructure.I_volume[UIIPinfraKitList[1].IK_infraLevel]
                  ,1
                  ,UIIPiCWP
                  );
               AISicwpResult:=FCCFidxL2+FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskCWPassemble')+' <b>'+FloatToStr(UIIPiCWP)+'</b> ...';
               AISicwpResultHours:=FCCFidxL2+FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskDuration1')+' <b>'+IntToStr(UIIPduration)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskDuration2')+'<br>';
               FCWinMain.FCWM_IPconfirmButton.Enabled:=true;
            end
            else if AISinfraKitMax>1
            then
            begin
               AISbreakFormat:='<br>';
               AISinfraKitCnt:=1;
               while AISinfraKitCnt<=AISinfraKitMax do
               begin
                  FCWinMain.FCWM_IPinfraKits.Items.Add( FCFdTFiles_UIStr_Get(uistrUI, UIIPinfraKitList[AISinfraKitCnt].IK_token) );
                  AISbreakFormat:=AISbreakFormat+'<br>';
                  inc(AISinfraKitCnt);
               end;
               FCWinMain.FCWM_IPinfraKits.Height:=18+(20*AISinfraKitMax);
               FCWinMain.FCWM_IPinfraKits.Show;
               FCWinMain.FCWM_IPinfraKits.ItemIndex:=-1;
               AISicwpResult:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMinfraKit1');
               AISicwpResultHours:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMinfraKit2');
               FCWinMain.FCWM_IPconfirmButton.Enabled:=false;
            end;
            FCWinMain.FCWM_IPconfirmButton.Show;
         end //==END== if UIIPiCWP>0 ==//
         else
         begin
            AIStask:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskCannotAssemble1');
            AISbreakFormat:='';
            AISicwpResult:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskCannotAssemble2');
            AISicwpResultHours:='';
            FCWinMain.FCWM_IPconfirmButton.Hide;
         end;
      end //==END== else if UIIPinfrastructure.I_constr=cPrefab ==//
      else
      begin
         AIStitle:='!ERROR!';
         FCWinMain.FCWM_IPconfirmButton.Hide;
      end;
      FCWinMain.FCWM_InfraPanel.Caption.Text:=AIStitle;
      FCWinMain.FCWM_IPlabel.HTMLText.Clear;
      FCWinMain.FCWM_IPlabel.HTMLText.Add(
         FCCFidxL+'<font size="10"><b>'+FCFdTFiles_UIStr_Get(uistrUI, UIIPinfrastructure.I_token)+'</font></b><ind x="'+inttostr(FCWinMain.FCWM_InfraPanel.Width shr 4 *14)
            +'"><a href="'+UIIPinfrastructure.I_token+'">Details</a><br><br>'
         );
      FCWinMain.FCWM_IPlabel.HTMLText.Add(FCCFidxL2+AIStask+'<br>');
      FCWinMain.FCWM_IPlabel.HTMLText.Add(AISbreakFormat+'<br>');
      FCWinMain.FCWM_IPlabel.HTMLText.Add(FCCFidxL2+AISicwpResult+'<br>');
      FCWinMain.FCWM_IPlabel.HTMLText.Add(FCCFidxL2+AISicwpResultHours+'<br>');
      FCWinMain.FCWM_InfraPanel.Left:=FCWinMain.FCWM_ColDPanel.Left+AISmouseX+FCWinMain.FCWM_InfraPanel.Width+(FCWinMain.FCWM_InfraPanel.Width shr 1);
      FCWinMain.FCWM_InfraPanel.Top:=FCWinMain.FCWM_ColDPanel.Top+AISmouseY+18;
      FCWinMain.FCWM_InfraPanel.Visible:=true;
      FCWinMain.FCWM_InfraPanel.BringToFront;
   end; //==END== else if AISinfraToken<>'' ==//
end;

procedure FCMuiIP_CABMode_Switch;
{:Purpose: switch to the correct assembling/building process, regarding the UIIPisAssembling state.
    Additions:
      -2011Jul05- *add: hide the infrastructure panel.
      -2011Jul04- *add: transfer the infrastructure kit storage index # to the assembling process method.
      -2011Jun12- *add: the building case.
}
{:DEV NOTES: update the assembling method w/ the index number of the chosen infrastructure kit (and of course add the parameter).}
begin
   FCWinMain.FCWM_InfraPanel.Hide;
   if not UIIPisAssembling
   then FCMgICS_Building_Process(
      0
      ,UIIPcolony
      ,UIIPsettlement
      ,UIIPduration
      ,UIIPinfraToken
      )
   else if UIIPisAssembling
   then
   begin
      if FCWinMain.FCWM_IPinfraKits.ItemIndex=-1
      then FCMgICS_Assembling_Process(
         0
         ,UIIPcolony
         ,UIIPsettlement
         ,UIIPduration
         ,UIIPinfraToken
         ,UIIPinfraKitList[1].IK_index
         )
      else if FCWinMain.FCWM_IPinfraKits.ItemIndex>-1
      then FCMgICS_Assembling_Process(
         0
         ,UIIPcolony
         ,UIIPsettlement
         ,UIIPduration
         ,UIIPinfraToken
         ,UIIPinfraKitList[FCWinMain.FCWM_IPinfraKits.ItemIndex+1].IK_index
         );
   end;
end;

procedure FCMuiIP_InfrastructureKit_Select;
{:Purpose: calculate the duration according to the selected infrastructure kit, and update the interface.
    Additions:
      -2011Jul05- *add: calculation of iCWP since it's bound to the infrastructure kit level, so for each kit there's a different assembling duration.
}
begin
   if FCWinMain.FCWM_IPinfraKits.ItemIndex=-1
   then FCWinMain.FCWM_IPconfirmButton.Enabled:=false
   else if FCWinMain.FCWM_IPinfraKits.ItemIndex>-1
   then
   begin
      UIIPiCWP:=FCFgICS_iCWP_Calculation(
         0
         ,UIIPcolony
         ,UIIPinfraKitList[FCWinMain.FCWM_IPinfraKits.ItemIndex+1].IK_infraLevel
         );
      UIIPduration:=FCFgICS_AssemblingDuration_Calculation(
         UIIPinfrastructure.I_volume[UIIPinfraKitList[FCWinMain.FCWM_IPinfraKits.ItemIndex+1].IK_infraLevel]
         ,1
         ,UIIPiCWP
         );
      FCWinMain.FCWM_IPlabel.HTMLText.Insert(3, FCCFidxL2+FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskCWPassemble')+' <b>'+FloatToStr(UIIPiCWP)+'</b> ...<br>');
      FCWinMain.FCWM_IPlabel.HTMLText.Delete(4);
      FCWinMain.FCWM_IPlabel.HTMLText.Insert(4, FCCFidxL2+FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskDuration1')+' <b>'+IntToStr(UIIPduration)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI, 'FCWMtaskDuration2')+'<br>');
      FCWinMain.FCWM_IPlabel.HTMLText.Delete(5);
      FCWinMain.FCWM_IPconfirmButton.Enabled:=true;
   end;
end;

procedure FCMuiIP_InfraList_Setup(
   const ILSinfraIndex
         ,ILSmouseX
         ,ILSmouseY: integer
         );
{:Purpose: setup the panel for display the configuration interface of the selected infrastructure.
    Additions:
      -2013Jan09- *add: hide useless interface elements.
      -2011Jun06- *add: display the real infrastructure name.
      -2011May30- *add: 2 parameters for gather the mouse position for display the panel under the mouse cursor.
      -2011May26- *add: infrastructure name and details hotlink display.
      -2011May25- *add: ILSinfraIndex to specify which infrastructure is concerned, in the current settlement.
}
var
   ILScolony
   ,ILSsettlement: integer;
begin
   if (ILSinfraIndex=0)
      and (FCWinMain.FCWM_InfraPanel.Visible)
   then FCWinMain.FCWM_InfraPanel.Hide
   else if ILSinfraIndex>0
   then
   begin
      FCWinMain.FCWM_InfraPanel.Caption.Text:=FCCFpanelTitle+'Infrastructure Configuration';
      FCWinMain.FCWM_IPlabel.HTMLText.Clear;
      ILScolony:=FCFuiCDP_VarCurrentColony_Get;
      ILSsettlement:=FCFuiCDP_VarCurrentSettlement_Get;
      FCWinMain.FCWM_IPlabel.HTMLText.Add(
         FCCFidxL+'<font size="10"><b>'+FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_colonies[ILScolony].C_settlements[ILSsettlement].S_infrastructures[ILSinfraIndex].I_token)
            +'</b></font><ind x="'+inttostr(FCWinMain.FCWM_InfraPanel.Width shr 4 *14)
            +'"><a href="'+FCDdgEntities[0].E_colonies[ILScolony].C_settlements[ILSsettlement].S_infrastructures[ILSinfraIndex].I_token+'">Details</a>'
         );
      FCWinMain.FCWM_InfraPanel.Left:=FCWinMain.FCWM_ColDPanel.Left+ILSmouseX+(FCWinMain.FCWM_InfraPanel.Width shr 1);
      FCWinMain.FCWM_InfraPanel.Top:=FCWinMain.FCWM_ColDPanel.Top+ILSmouseY+18;
      FCWinMain.FCWM_IPconfirmButton.Hide;
      FCWinMain.FCWM_InfraPanel.Visible:=true;
      FCWinMain.FCWM_InfraPanel.BringToFront;
   end; //==END== else if ILSinfraIndex>0 ==//
end;

procedure FCMuiIP_PanelKey_Test(
   const PKTkey: integer;
   const PKTshftCtrl: TShiftState
   );
{:Purpose: test key routine for the infrastructure panel.
    Additions:
}
begin
   if (ssAlt in PKTshftCtrl)
   then FCMuiK_WinMain_Test(PKTkey, PKTshftCtrl)
   else if PKTkey<>27
   then FCMuiK_WinMain_Test(PKTkey, PKTshftCtrl);
   {.ESCAPE}
   {.close the panel}
   if PKTkey=27
   then FCWinMain.FCWM_InfraPanel.Hide;
end;

end.
