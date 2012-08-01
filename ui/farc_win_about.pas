{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: about window

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

unit farc_win_about;

interface

uses
   Classes
   ,Controls
   ,Forms
   ,StdCtrls

   ,AdvGroupBox
   ,HTMLCredit
   ,HTMLabel;

type
  TFCWinAbout = class(TForm)
    FCWA_Frame: TAdvGroupBox;
    FCWA_Frm_Header: THTMLabel;
    FCWA_Frm_Creds: THTMLCredit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FCWA_ButDownClick(Sender: TObject);
    procedure FCWA_ButUpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWA_ButUpKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWA_ButDownKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWA_Frm_CredsMouseEnter(Sender: TObject);
    procedure FCWA_Frm_CredsMouseLeave(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FCWinAbout: TFCWinAbout;

implementation

uses
   farc_data_init,
   farc_ui_keys,
   farc_ui_win;

{$R *.dfm}

//===================================END OF INIT============================================

procedure TFCWinAbout.FCWA_ButDownClick(Sender: TObject);
var
   i,
   oldpos: integer;
begin
   FCWA_Frm_Creds.ScrollPosition:=FCWA_Frm_Creds.ScrollPosition-30;
end;

procedure TFCWinAbout.FCWA_ButDownKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiK_AboutWin_Test(Key, Shift);
end;

procedure TFCWinAbout.FCWA_ButUpClick(Sender: TObject);
begin
   FCWA_Frm_Creds.ScrollPosition:=FCWA_Frm_Creds.ScrollPosition+30;
end;

procedure TFCWinAbout.FCWA_ButUpKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   FCMuiK_AboutWin_Test(Key, Shift);
end;

procedure TFCWinAbout.FCWA_Frm_CredsMouseEnter(Sender: TObject);
begin
   FCWA_Frm_Creds.AutoScroll:=false;
end;

procedure TFCWinAbout.FCWA_Frm_CredsMouseLeave(Sender: TObject);
begin
   FCWA_Frm_Creds.AutoScroll:=true;
end;

procedure TFCWinAbout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FCMuiW_About_Close;
//   FCWA_Frm_Creds.AutoScroll:=false;
end;

procedure TFCWinAbout.FormCreate(Sender: TObject);
begin
   FCVdiWinAboutAllowUpdate:=true;
end;

procedure TFCWinAbout.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   FCMuiK_AboutWin_Test(Key, Shift);
end;

procedure TFCWinAbout.FormShow(Sender: TObject);
begin
   FCWA_Frm_Creds.AutoScroll:=true;
end;

end.
