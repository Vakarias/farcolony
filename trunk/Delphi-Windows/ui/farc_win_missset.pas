{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: mission setup window

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

unit farc_win_missset;

interface

uses
   Classes,
   Controls,
   Dialogs,
   Forms,
   Graphics,
   Messages,
   SysUtils,
   Variants,
   Windows, StdCtrls, AdvGroupBox, HTMLabel, AdvTrackBar, AdvGlowButton, ExtCtrls, AdvCombo;

type
  TFCWinMissSet = class(TForm)
    FCWMS_Grp: TAdvGroupBox;
    FCWMS_Grp_MSDG: TAdvGroupBox;
    FCWMS_Grp_MCG: TAdvGroupBox;
    FCWMS_Grp_MSDG_Disp: THTMLabel;
    FCWMS_Grp_MCG_DatDisp: THTMLabel;
    FCWMS_Grp_MCG_RMassTrack: TAdvTrackBar;
    FCWMS_Grp_MCG_MissCfgData: THTMLabel;
    FCWMS_ButCancel: TAdvGlowButton;
    FCWMS_ButProceed: TAdvGlowButton;
    FCWMS_Grp_MCGColName: TLabeledEdit;
    FCWMS_Grp_MCG_SetName: TLabeledEdit;
    FCWMS_Grp_MCG_SetType: TAdvComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWMS_Grp_MCG_RMassTrackChange(Sender: TObject);
    procedure FCWMS_ButProceedClick(Sender: TObject);
    procedure FCWMS_ButCancelClick(Sender: TObject);
    procedure FCWMS_Grp_MCG_RMassTrackKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FCWMS_ButProceedKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWMS_ButCancelKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWMS_Grp_MCGColNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FCWMS_Grp_MCGColNameKeyPress(Sender: TObject; var Key: Char);
    procedure FCWMS_Grp_MCG_SetNameKeyPress(Sender: TObject; var Key: Char);
    procedure FCWMS_Grp_MCG_SetNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FCWinMissSet: TFCWinMissSet;

implementation

uses
   farc_data_game
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_game_missioncore
   ,farc_main
   ,farc_ui_keys
   ,farc_ui_win;

{$R *.dfm}

//===================================END OF INIT============================================

procedure TFCWinMissSet.FCWMS_ButCancelClick(Sender: TObject);
begin
   FCWinMissSet.Close;
   FCGtimeFlow.Enabled:=true;
end;

procedure TFCWinMissSet.FCWMS_ButCancelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_WinMissSet_Test(Key, Shift);
end;

procedure TFCWinMissSet.FCWMS_ButProceedClick(Sender: TObject);
begin
   FCMgMCore_Mission_Commit;
end;

procedure TFCWinMissSet.FCWMS_ButProceedKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_WinMissSet_Test(Key, Shift);
end;

procedure TFCWinMissSet.FCWMS_Grp_MCGColNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_MissionColonyName_Test(Key, Shift);
end;

procedure TFCWinMissSet.FCWMS_Grp_MCGColNameKeyPress(Sender: TObject; var Key: Char);
begin
   If sender is TLabeledEdit then
   begin
      if Key in [#8, #13, #32, #39, 'a'..'z', 'A'..'Z', '0'..'9']
      then exit
      else Key:=#0;
   end;
end;

procedure TFCWinMissSet.FCWMS_Grp_MCG_RMassTrackChange(Sender: TObject);
var
   RMTCmiss: string;
begin
   if (FCWinMissSet.Visible)
      and (FCWMS_Grp_MCG_RMassTrack.Tag=0)
   then
   begin
      RMTCmiss:=FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet');
      if FCWinMissSet.FCWMS_Grp.Caption=RMTCmiss+FCFdTFiles_UIStr_Get(uistrUI,'Mission.itransit')
      then FCMgMCore_Mission_TrackUpd(tatpMissItransit)
      else if FCWinMissSet.FCWMS_Grp.Caption=RMTCmiss+FCFdTFiles_UIStr_Get(uistrUI,'Mission.coloniz')
      then FCMgMCore_Mission_TrackUpd(tatpMissColonize);
   end
   else if (FCWinMissSet.Visible)
      and (FCWMS_Grp_MCG_RMassTrack.Tag=1)
   then FCWMS_Grp_MCG_RMassTrack.Tag:=0;
end;

procedure TFCWinMissSet.FCWMS_Grp_MCG_RMassTrackKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_WinMissSet_Test(Key, Shift);
end;

procedure TFCWinMissSet.FCWMS_Grp_MCG_SetNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_MissionSettleName_Test(Key, Shift);
end;

procedure TFCWinMissSet.FCWMS_Grp_MCG_SetNameKeyPress(Sender: TObject; var Key: Char);
begin
   If sender is TLabeledEdit then
   begin
      if Key in [#8, #13, #32, #39, 'a'..'z', 'A'..'Z', '0'..'9']
      then exit
      else Key:=#0;
   end;
end;

procedure TFCWinMissSet.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FCWinMissSet.Hide;
   FCWinMissSet.Enabled:=False;
   if FCWinMain.FCWM_SurfPanel.Visible
   then
   begin
      FCWinMain.FCWM_SurfPanel.Hide;
      fcwinmain.FCWM_SP_Surface.Enabled:=false;
   end;
end;

procedure TFCWinMissSet.FormCreate(Sender: TObject);
begin
   FCVallowUpMSWin:=true;
   FCMuiWin_UI_Upd(mwupSecwinMissSetup);
   FCMuiWin_UI_Upd(mwupFontWinMS);
   FCMuiWin_UI_Upd(mwupTextWinMS);
end;

procedure TFCWinMissSet.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   FCMuiK_WinMissSet_Test(Key, Shift);
end;

end.
