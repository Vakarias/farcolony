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

unit farc_win_savedgames;

interface

uses
   Classes
   ,Controls
   ,Forms
   ,ShellApi
   ,StdCtrls
   ,Windows

   ,AdvGroupBox
   ,HTMLCredit
   ,HTMLabel, ComCtrls, htmltv;

type
  TFCWinSavedGames = class(TForm)
    WSG_Frame: TAdvGroupBox;
    F_SavedGamesHeader: THTMLabel;
    F_SavedGamesList: THTMLTreeview;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWA_ButUpKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FCWA_ButDownKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure F_SavedGamesListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure F_SavedGamesListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure F_SavedGamesListDblClick(Sender: TObject);
    procedure LockDoubleClick;
    procedure UnlockDoubleClick;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FCWinSavedGames: TFCWinSavedGames;

implementation

uses
   farc_data_init
   ,farc_ui_savedgames
   ,farc_ui_win
   ,farc_win_debug;

var
   FCwsgUnlockDoubleClick: boolean;

{$R *.dfm}

//===================================END OF INIT============================================

procedure TFCWinSavedGames.FCWA_ButDownKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FCMuiSG_Key_Test(Key, Shift);
end;

procedure TFCWinSavedGames.FCWA_ButUpKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   FCMuiSG_Key_Test(Key, Shift);
end;

procedure TFCWinSavedGames.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FCMuiW_WinSavedGames_Close;
end;

procedure TFCWinSavedGames.FormCreate(Sender: TObject);
begin
   FCVdiWinSavedGamesAllowUpdate:=true;
end;

procedure TFCWinSavedGames.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   FCMuiSG_Key_Test(Key, Shift);
end;

procedure TFCWinSavedGames.F_SavedGamesListDblClick(Sender: TObject);
   var
      CurrentNode: TTreenode;
      ParentNode: TTreenode;
begin
   if FCwsgUnlockDoubleClick then
   begin
      CurrentNode:=THTMLTreeview( Sender ).Selected;
      if CurrentNode.Parent<>nil
      then ParentNode:=CurrentNode.Parent;
      FCMuiSG_SavedGameItem_DoubleClicked( ParentNode.Text, CurrentNode.Text );
   end;
end;

procedure TFCWinSavedGames.F_SavedGamesListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   FCMuiSG_Key_Test(Key, Shift);
end;

procedure TFCWinSavedGames.F_SavedGamesListMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
   var
      CurrentNode: TTreenode;
begin
   CurrentNode:=THTMLTreeview( Sender ).Selected;
   FCMuiSG_SavedGameItem_Selected( CurrentNode.Text );
end;

procedure TFCWinSavedGames.LockDoubleClick;
begin
   FCwsgUnlockDoubleClick:=false;
end;

procedure TFCWinSavedGames.UnlockDoubleClick;
begin
   FCwsgUnlockDoubleClick:=true;
end;

end.
