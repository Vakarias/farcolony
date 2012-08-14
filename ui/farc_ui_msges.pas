{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: message box related routines

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
unit farc_ui_msges;

interface

uses
   SysUtils;

{:DEV NOTES: put that in data_messages.}
type TFCEuimMsgeTp=(
   mtColonize
   ,mtColonizeWset
   ,mtInterplanTransit
   ,mtSPMrequirements
//   ,uiwmtViabObj
   ,mtWelcome
   );

//===========================END FUNCTIONS SECTION==========================================
///<summary>
///   add a game message in the message box
///</summary>
///    <param name="MBAMmsgeTp">message type, w/uiwmt </param>
///   <param name="MBAMfacIdx">faction index</param>
///   <param name="MBAMitm0Idx">uiwmtCol, uiwmtMissIT: owned space unit / uiwmtWelcome: colonization mode #</param>
///   <param name="MBAMitm1Idx">uiwmtCol, uiwmtMissIT: destination orbital object</param>
///   <param name="MBAMitm2Idx">uiwmtCol, uiwmtMissIT: destination satellite [optional]</param>
///   <param name="MBAMitm3Idx">uiwmtCol: destination region</param>
procedure FCMuiM_Message_Add(
   const MBAMmsgeTp: TFCEuimMsgeTp;
   const MBAMfac
         ,MBAMitm0Idx
         ,MBAMitm1Idx
         ,MBAMitm2Idx
         ,MBAMitm3Idx: integer
   );

///<summary>
///   expand the message box
///</summary>
procedure FCFuiM_MessageBox_Expand;

///<summary>
///   reset the messagebox state
///</summary>
procedure FCMuiM_MessageBox_ResetState(const MBRScollaps: Boolean);

///<summary>
///   update message box description text of current selection
///</summary>
procedure FCMuiM_MessageDesc_Upd;

///<summary>
///   reset the messagebox messages
///</summary>
procedure FCMuiM_Messages_Reset;


implementation

uses
   farc_data_game
   ,farc_data_init
   ,farc_data_messages
   ,farc_data_univ
   ,farc_game_gameflow
   ,farc_main
   ,farc_data_textfiles
   ,farc_univ_func;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================
procedure FCMuiM_Message_Add(
   const MBAMmsgeTp: TFCEuimMsgeTp;
   const MBAMfac
         ,MBAMitm0Idx
         ,MBAMitm1Idx
         ,MBAMitm2Idx
         ,MBAMitm3Idx: integer
   );
{:Purpose: add a game message in the message box.
    Additions:
      -2011Jan02- *add: SPM requirement not met during SPM phase.
      -2010Sep19- *add: entities code.
                  *fix: MBAMssys and MBAMstar arte calculated only when needed, not each time (fix a crash).
      -2010Jul07- *add: colonization mission end message: add colony name.
      -2010Jun16- *mod: display header's date month in plain letter.
      -2010Jun15- *add: use local variable for stellar/star location.
      -2010Jun06- *rem: remove the viability objectives message (transfered in cps panel).
      -2010Jun02- *add: colonization: switch message if the colony is founded or not.
      -2010May13- *add: interplanetary mission message is completed.
      -2010May12- *add: colonization message.
                  *mod: change the message type selection switch method.
                  *add: 2 new parameters: MBAMitm1Idx, MBAMitm2Idx and MBAMitm3Idx.
      -2010Mar14- *add: cps viability objectives status.
                  *rem: deletion of useless code (the test message).
      -2010Mar13- *mod: update the welcome message including colonization mode option.
      -2009Oct29- *add 2 parameters: MBAMfacIdx and MBAMitm0Idx.
                  *add arrival in orbit message w/ uiwmtMissITinOrb.
                  *focus the newer message.
      -2009Oct04- *modify first header initialization subroutine location and set item index
                  *add the welcome message.
      -2009Sep30- *completion list display w/ test message.
}
var
   MBAMcnt
   ,MBAMmax
   ,MBAMssys
   ,MBAMstar: integer;

   MBAMcmode
   ,MBAMcolName
   ,MBAMdestName
   ,MBAMdmpHeader
   ,MBAMdmpSpUnName
   ,MBAMregLoc
   ,MBAMstatus
   ,MBAMvoN: string;

   procedure MA_Loc_Calc;
   begin
      MBAMssys:=FCFuF_StelObj_GetDbIdx(
      ufsoSsys
      ,FCentities[MBAMfac].E_spU[MBAMitm0Idx].SU_locationStarSystem
      ,0
      ,0
      ,0
      );
   MBAMstar:=FCFuF_StelObj_GetDbIdx(
      ufsoStar
      ,FCentities[MBAMfac].E_spU[MBAMitm0Idx].SUO_starLoc
      ,MBAMssys
      ,0
      ,0
      );
   end;
begin
   {.update string arrays and initialize data}
   inc(FCVmsgCount);
   SetLength(FCVmsgStoTtl,FCVmsgCount+1);
   SetLength(FCVmsgStoMsg,FCVmsgCount+1);
   MBAMdmpHeader:='('+inttostr(FCRplayer.P_currentTimeDay)+'/'+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFM'+inttostr(FCRplayer.P_currentTimeMonth))+'/'+inttostr(FCRplayer.P_currentTimeYear)+'): ';
   case MBAMmsgeTp of
      {.mission - colonization
      MBAMitm0Idx= owned space unit MBAMitm1Idx= destination orbital object MBAMitm2Idx= destination satellite MBAMitm3Idx= destination region}
      mtColonize, mtColonizeWset:
      begin
         MA_Loc_Calc;
         {.header}
         FCVmsgStoTtl[FCVmsgCount]:=MBAMdmpHeader+FCFdTFiles_UIStr_Get(uistrUI, 'MSG_MissColHead');
         {.message}
         if MBAMitm2Idx=0
         then
         begin
            MBAMdestName:=FCFdTFiles_UIStr_Get(
               dtfscPrprName
               ,FCDduStarSystem[MBAMssys].SS_stars[MBAMstar].S_orbitalObjects[MBAMitm1Idx].OO_dbTokenId
               );
            MBAMcolName:=FCentities[MBAMfac].E_col[FCDduStarSystem[MBAMssys].SS_stars[MBAMstar].S_orbitalObjects[MBAMitm1Idx].OO_colonies[0]].C_name;
         end
         else if MBAMitm2Idx>0
         then
         begin
            MBAMdestName:=FCFdTFiles_UIStr_Get(
               dtfscPrprName
               ,FCDduStarSystem[MBAMssys].SS_stars[MBAMstar].S_orbitalObjects[MBAMitm1Idx].OO_satellitesList[MBAMitm2Idx].OO_dbTokenId
               );
            MBAMcolName
               :=FCentities[MBAMfac].E_col[FCDduStarSystem[MBAMssys].SS_stars[MBAMstar].S_orbitalObjects[MBAMitm1Idx].OO_satellitesList[MBAMitm2Idx].OO_colonies[0]].C_name;
         end;
         MBAMregLoc:=FCFuF_RegionLoc_Extract(
            MBAMssys
            ,MBAMstar
            ,MBAMitm1Idx
            ,MBAMitm2Idx
            ,MBAMitm3Idx
            );
         if MBAMmsgeTp=mtColonize
         then FCVmsgStoMsg[FCVmsgCount]
            :=FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissCol0')
               +FCFdTFiles_UIStr_Get(dtfscPrprName, FCentities[MBAMfac].E_spU[MBAMitm0Idx].SU_name)
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissCol1')
               +MBAMdestName
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissCol2')
               +MBAMregLoc
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissCol5')
               +MBAMcolName
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissCol6')
         else if MBAMmsgeTp=mtColonizeWset
         then FCVmsgStoMsg[FCVmsgCount]
            :=FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissCol0')
               +FCFdTFiles_UIStr_Get(dtfscPrprName, FCentities[MBAMfac].E_spU[MBAMitm0Idx].SU_name)
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissCol1')
               +MBAMdestName
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissCol2')
               +MBAMregLoc
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissCol3')
               +MBAMcolName
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissCol4');
      end;
      {.mission - interplanetary transit
      MBAMitm0Idx= owned space unit MBAMitm1Idx= destination orbital object MBAMitm2Idx= destination satellite}
      mtInterplanTransit:
      begin
         MA_Loc_Calc;
         {.header}
         FCVmsgStoTtl[FCVmsgCount]:=MBAMdmpHeader+FCFdTFiles_UIStr_Get(uistrUI, 'MSG_MissITHead');
         {.message}
         if MBAMitm2Idx=0
         then MBAMdestName:=FCFdTFiles_UIStr_Get(
            dtfscPrprName
            ,FCDduStarSystem[MBAMssys].SS_stars[MBAMstar].S_orbitalObjects[MBAMitm1Idx].OO_dbTokenId
            )
         else if MBAMitm2Idx>0
         then MBAMdestName:=FCFdTFiles_UIStr_Get(
            dtfscPrprName
            ,FCDduStarSystem[MBAMssys].SS_stars[MBAMstar].S_orbitalObjects[MBAMitm1Idx].OO_satellitesList[MBAMitm2Idx].OO_dbTokenId
            );
         FCVmsgStoMsg[FCVmsgCount]:=FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissIT0')
            +FCFdTFiles_UIStr_Get(dtfscPrprName, FCentities[MBAMfac].E_spU[MBAMitm0Idx].SU_name)
            +FCFdTFiles_UIStr_Get(uistrUI,'MSG_MissIT1')
            +MBAMdestName+'</b>.';
      end;
      {.SPM item requirement not met during SPM phase
      MBAMitm0Idx= SPMi index
      MBAMitm1Idx= 0 if meme/1 if policy
      MBAMitm2Idx=
      MBAMitm3Idx= }
      mtSPMrequirements:
      begin
         {.header}
         FCVmsgStoTtl[FCVmsgCount]:=MBAMdmpHeader+FCFdTFiles_UIStr_Get(uistrUI, 'MSG_SPMreqHead');
         {.message}
         FCVmsgStoMsg[FCVmsgCount]:=FCFdTFiles_UIStr_Get( uistrUI, 'MSG_SPMreq'+IntToStr(MBAMitm1Idx) )
            +'<b>'+FCFdTFiles_UIStr_Get(uistrUI, FCentities[MBAMfac].E_spm[MBAMitm0Idx].SPMS_token)+'</b> '
            +FCFdTFiles_UIStr_Get(uistrUI, 'MSG_SPMreq2');
      end;
      {.welcome message
      MBAMfacIdx= allegiance faction id, MBAMitm0Idx= colonization mode #}
      mtWelcome:
      begin
         {.header}
         FCVmsgStoTtl[FCVmsgCount]:=MBAMdmpHeader+FCFdTFiles_UIStr_Get(uistrUI,'MSG_IntroHead');
         {.message}
   //      case MBAMfacIdx of
         if MBAMfac=1
         then MBAMcmode:=FCFdTFiles_UIStr_Get(uistrUI, 'MSG_IntroCMmun');
   //      end;
         FCVmsgStoMsg[FCVmsgCount]
            :=FCFdTFiles_UIStr_Get(uistrUI,'MSG_Intro1')
               +FCFdTFiles_UIStr_Get(uistrUI,FCRplayer.P_allegianceFaction+'Wart')
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_Intro2')
               +FCFdTFiles_UIStr_Get(dtfscPrprName,FCRplayer.P_viewOrbitalObject)
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_Intro3')
               +FCFdTFiles_UIStr_Get(dtfscPrprName,FCRplayer.P_viewStar)
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_Intro4')
               +FCFdTFiles_UIStr_Get(dtfscPrprName,FCRplayer.P_viewStarSystem)
               +FCFdTFiles_UIStr_Get(uistrUI,'MSG_Intro5')
               +'<br>'
               +MBAMcmode
               +'<br>'+FCFdTFiles_UIStr_Get(uistrUI, 'MSG_IntroCMend');
      end;
   end; //==END== case MBAMmsgeTp of ==//
   {.update message headers list}
   FCWinMain.FCWM_MsgeBox_List.Items.Add('<b>'+IntToStr(FCVmsgCount)+'</b> - '+FCVmsgStoTtl[FCVmsgCount]);
   {.in case of the first header}
   if FCVmsgCount=1
   then
   begin
      FCWinMain.FCWM_MsgeBox.Collaps:=true;
      FCWinMain.FCWM_MsgeBox.Top:=FCWinMain.Height-(FCWinMain.Height div 22)-(((1024-FCWinMain.Height)*10 shr 8)+22);
      FCWinMain.FCWM_MsgeBox.Show;
   end;
   FCWinMain.FCWM_MsgeBox_List.ItemIndex:=FCWinMain.FCWM_MsgeBox_List.Items.Count-1;
   FCMgTFlow_FlowState_Set(tphTac);
   {.update description}
   FCMuiM_MessageDesc_Upd;
end;

procedure FCFuiM_MessageBox_Expand;
{:Purpose: expand the message box.
    Additions:
}
begin
   FCWinMain.FCWM_MsgeBox.Top:=FCWinMain.FCWM_MsgeBox.Top-(FCWinMain.FCWM_MsgeBox.Height shl 2);
   FCWinMain.FCWM_MsgeBox.Height:=FCWinMain.FCWM_MsgeBox.Height shl 3 div 3;
   FCWinMain.FCWM_MsgeBox_Desc.Height:=FCWinMain.FCWM_MsgeBox.Height-(FCWinMain.FCWM_MsgeBox_List.Height+22);
   FCWinMain.FCWM_MsgeBox_Desc.Visible:=True;
   FCWinMain.FCWM_MsgeBox.Tag:=1;
   FCMuiM_MessageDesc_Upd;
end;

procedure FCMuiM_MessageBox_ResetState(const MBRScollaps: Boolean);
{:Purpose: reset the messagebox state.
    Additions:
      -2009Nov28- *add a switch for not change or change the FCWM_MsgeBox.Collaps.
}
begin
   FCWinMain.FCWM_MsgeBox_Desc.Visible:=False;
   if MBRScollaps
   then FCWinMain.FCWM_MsgeBox.Collaps:=true;
   FCWinMain.FCWM_MsgeBox.Top:=FCWinMain.FCWM_3dMainGrp.Height-22;
   FCWinMain.FCWM_MsgeBox.Tag:=0;
end;

procedure FCMuiM_MessageDesc_Upd;
{:Purpose: update message box description text of current selection.
    Additions:
      -2009Nov26- *bugfix: release gameflow, which is freezed when a message is added.
      -2009Oct01- *add tag condition.
}
begin
   FCWinMain.FCWM_MsgeBox.Caption.Text
      :='Message '
         +IntToStr(FCWinMain.FCWM_MsgeBox_List.ItemIndex+1)
         +'/'+IntToStr(FCVmsgCount)+' - '
         +FCVmsgStoTtl[FCWinMain.FCWM_MsgeBox_List.ItemIndex+1];
   if FCWinMain.FCWM_MsgeBox.Tag=1 then
   begin
      FCWinMain.FCWM_MsgeBox_Desc.HTMLText.Clear;
      FCWinMain.FCWM_MsgeBox_Desc.HTMLText.Add
         (
            '<b><u>'+FCVmsgStoTtl[FCWinMain.FCWM_MsgeBox_List.ItemIndex+1]+'</u></b><br>'
         );
      FCWinMain.FCWM_MsgeBox_Desc.HTMLText.Add(FCVmsgStoMsg[FCWinMain.FCWM_MsgeBox_List.ItemIndex+1]);
   end;
end;

procedure FCMuiM_Messages_Reset;
{:Purpose: reset the messages.
    Additions:
}
begin
   FCVmsgCount:=0;
   SetLength(FCVmsgStoTtl,1);
   SetLength(FCVmsgStoMsg,1);
   FCWinMain.FCWM_MsgeBox_List.ItemIndex:=-1;
   FCWinMain.FCWM_MsgeBox_List.Items.Clear;
   FCWinMain.FCWM_MsgeBox_Desc.HTMLText.Clear;
   FCWinMain.FCWM_MsgeBox.Hide;
end;

end.
