{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: new game setup window

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

unit farc_win_newgset;

interface

uses
   Classes,


   Forms,
   Graphics,
   Messages,
   SysUtils,
   Variants,
   Windows, StdCtrls, ExtCtrls, AdvGroupBox, GR32_Image, HTMListB, AdvPageControl, ComCtrls,
  HTMLabel, AdvGlowButton, AdvEdit, htmltv, htmlbtns, Controls;

type
  TFCWinNewGSetup = class(TForm)
    FCWNGS_Frm_FactionFlag: TImage32;
    FCWNGS_Frame: TAdvGroupBox;
    FCWNGS_Frm_GNameEdit: TLabeledEdit;
    FCWNGS_Frm_FactionList: THTMListBox;
    FCWNGS_Frm_DataPad: TAdvPageControl;
    FCWNGS_Frm_DPad_SheetHisto: TAdvTabSheet;
    FCWNGS_Frm_DPad_SheetSPM: TAdvTabSheet;
    FCWNGS_Frm_DPad_SheetCol: TAdvTabSheet;
    FCWNGS_Frm_DPad_SHisto_Text: THTMLabel;
    FCWNGS_Frm_DPad_SCol_Text: THTMLabel;
    FCWNGS_Frm_ButtProceed: TAdvGlowButton;
    FCWNGS_Frm_DPad_SheetDotList: TAdvTabSheet;
    FCWNGS_Frm_DPad_SDL_DotList: THTMLTreeview;
    FCWNGS_Frm_ButtCancel: TAdvGlowButton;
    FCWNGS_Frm_ColMode: THTMLRadioGroup;
    FCWNGS_FDPad_ShSPM_SPMList: THTMLTreeview;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FCWNGS_Frm_GNameEditChange(Sender: TObject);
    procedure FCWNGS_Frm_ButtProceedClick(Sender: TObject);
    procedure FCWNGS_Frm_GNameEditKeyPress(Sender: TObject; var Key: Char);
    procedure FCWNGS_Frm_ButtCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWNGS_Frm_ButtCancelKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWNGS_Frm_ButtProceedKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWNGS_Frm_FactionListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWNGS_Frm_GNameEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWNGS_Frm_ColModeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FCWinNewGSetup: TFCWinNewGSetup;

implementation

uses
   farc_data_init,
   farc_game_newg,
   farc_main,
   farc_ui_keys,
   farc_ui_win;
//===================================END OF INIT============================================
{$R *.dfm}

procedure TFCWinNewGSetup.FCWNGS_Frm_ButtCancelClick(Sender: TObject);
begin
   FCWinNewGSetup.Close;
end;

procedure TFCWinNewGSetup.FCWNGS_Frm_ButtCancelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_NewGSet_Test(Key, Shift);
end;

procedure TFCWinNewGSetup.FCWNGS_Frm_ButtProceedClick(Sender: TObject);
begin
   FCMgNG_Core_Proceed;
end;

procedure TFCWinNewGSetup.FCWNGS_Frm_ButtProceedKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_NewGSet_Test(Key, Shift);
end;

procedure TFCWinNewGSetup.FCWNGS_Frm_ColModeClick(Sender: TObject);
begin
   FCMgNG_ColMode_Upd;
end;

procedure TFCWinNewGSetup.FCWNGS_Frm_FactionListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_NewGSet_Test(Key, Shift);
end;

procedure TFCWinNewGSetup.FCWNGS_Frm_GNameEditChange(Sender: TObject);
var
   FGNECdmpTxt: string;
begin
   FGNECdmpTxt:= FCWNGS_Frm_GNameEdit.Text;
   if Length(FGNECdmpTxt)>=5 then
   begin
      if FCWNGS_Frm_GNameEdit.EditLabel.Font.Color= clRed
      then FCWNGS_Frm_GNameEdit.EditLabel.Font.Color:= clWhite;
      if not FCWNGS_Frm_ButtProceed.Enabled
      then FCWNGS_Frm_ButtProceed.Enabled:= true;
   end
   else
   begin
      if FCWNGS_Frm_GNameEdit.EditLabel.Font.Color= clWhite
      then FCWNGS_Frm_GNameEdit.EditLabel.Font.Color:= clRed;
      if FCWNGS_Frm_ButtProceed.Enabled
      then FCWNGS_Frm_ButtProceed.Enabled:= false;
   end;
end;

procedure TFCWinNewGSetup.FCWNGS_Frm_GNameEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_NewGSet_Test(Key, Shift);
end;

procedure TFCWinNewGSetup.FCWNGS_Frm_GNameEditKeyPress(Sender: TObject; var Key: Char);
begin
   If sender is TLabeledEdit then
   begin
      if Key in [#8, #13, 'a'..'z', 'A'..'Z', '0'..'9']
      then exit
      else Key:=#0;
   end;
end;

procedure TFCWinNewGSetup.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FCWinMain.Enabled:= true;
   FreeAndNil(FCWinNewGSetup);
//   FCWinNewGSetup.Enabled:= false;

end;

procedure TFCWinNewGSetup.FormCreate(Sender: TObject);
begin
   FCVdiWinNewGameAllowUpdate:=true;
end;

procedure TFCWinNewGSetup.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   FCMuiK_NewGSet_Test(Key, Shift);
end;

end.
