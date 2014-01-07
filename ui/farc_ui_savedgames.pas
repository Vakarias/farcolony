{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: saved games window - core unit

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
unit farc_ui_savedgames;

interface

uses
   Classes
   ,ComCtrls
   ,SysUtils
   ,Windows;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   test if the text of a selected item correspond to a file or not
///</summary>
///   <param name="ItemNameToTest">item name to test</param>
///   <returns>true if it's a file</returns>
///   <remarks></remarks>
function FCFuiSG_SelectedItem_IsXMLFile( const ItemNameToTest: string ): boolean;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   key test routine
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMuiSG_Key_Test(
   const KeyPressed: integer;
   const ShiftControl: TShiftState
   );

///<summary>
///   init the elements (size and location) of the panel
///</summary>
procedure FCMuiSG_Panel_InitElements;

///<summary>
///   init the texts of the panel
///</summary>
procedure FCMuiSG_Panel_InitText;

///<summary>
///   item selection by double click
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMuiSG_SavedGameItem_DoubleClicked( const ParentItemString, ItemString: string );

///<summary>
///   item selection
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMuiSG_SavedGameItem_Selected( const ItemString: string );

///<summary>
///   update de saved games list and refresh the tree list
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMuiSG_SavedGamesList_Update;

implementation

uses
   farc_common_func
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_data_html
   ,farc_game_core
   ,farc_main
   ,farc_ui_keys
   ,farc_win_debug
   ,farc_win_savedgames;

//==END PRIVATE ENUM========================================================================


//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//   FCVuiSGfilename: string;

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFuiSG_SelectedItem_IsXMLFile( const ItemNameToTest: string ): boolean;
{:Purpose: test if the text of a selected item correspond to a file or not.
    Additions:
}
   var
      ItemLength: integer;

      EndOfFileStr: string;
begin
   Result:=false;
   ItemLength:=length( ItemNameToTest );
   EndOfFileStr:=ItemNameToTest;
   if ItemLength > 4 then
   begin
      Delete(
         EndOfFileStr
         ,1
         ,ItemLength-3
         );
      if EndOfFileStr='xml'
      then Result:=true;
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiSG_Key_Test(
   const KeyPressed: integer;
   const ShiftControl: TShiftState
   );
{:Purpose: key test routine.
    Additions:
}
begin
   if ssAlt in ShiftControl
   then FCMuiK_WinMain_Test( KeyPressed, ShiftControl );
   if KeyPressed <> 27
   then FCMuiK_WinMain_Test( KeyPressed, ShiftControl );
   {.ESCAPE}
   {.close the mission setup window}
   if KeyPressed = 27
   then FCWinSavedGames.Close;
end;

procedure FCMuiSG_Panel_InitElements;
{:Purpose: init the elements (size and location) of the panel.
    Additions:
}
begin
   FCWinSavedGames.Width:=580;
   FCWinSavedGames.Height:=FCWinMain.Height shr 3*5;
   FCWinSavedGames.Left:=FCWinMain.Left+( FCWinMain.Width shr 1 )-(FCWinSavedGames.Width shr 1);
   FCWinSavedGames.Top:=FCWinMain.Top+( FCWinMain.Height shr 1 )-(FCWinSavedGames.Height shr 1);
   FCWinSavedGames.F_SavedGamesHeader.Height:=FCWinSavedGames.Height shr 3*1;
   FCWinSavedGames.F_SavedGamesList.Height:=FCWinSavedGames.Height shr 3 *7;
end;

procedure FCMuiSG_Panel_InitText;
{:Purpose: init the texts of the panel.
    Additions:
      -2013Mar30- *add: complete the texts localization.
}
//   var
//      TextDump
//      ,TextDump1
//      ,TextLicense: string;
//
//      CreditInfo
//      ,CreditSection
//      ,CreditSubsection: IXMLNode;
//
//      InfoNode
//      ,InfoNode1
//      ,RootNodeCredits
//      ,RootNodeCode
//      ,RootNodeAssets2D
//      ,RootNodeAssets3D
//      ,RootNodeAssetsSound
//      ,RootNodeAssetsMusic
//      ,SubNode: TTreeNode;
begin
   {.main frame}
   FCWinSavedGames.WSG_Frame.Caption:=FCFdTFiles_UIStr_Get( uistrUI, 'MMGame_LoadSaved' );
   FCWinSavedGames.F_SavedGamesHeader.HTMLText.Clear;
   FCWinSavedGames.F_SavedGamesHeader.HTMLText.Add( FCCFdHeadC + FCFdTFiles_UIStr_Get( uistrUI,'savedgamesHeader' ) + FCCFdHeadEnd );
end;

procedure FCMuiSG_SavedGameItem_DoubleClicked( const ParentItemString, ItemString: string );
{:Purpose: item selection by double click.
    Additions:
}
begin
   if FCFuiSG_SelectedItem_IsXMLFile( ItemString ) then
   begin
      FCWinSavedGames.WSG_Frame.Caption:=FCFdTFiles_UIStr_Get( uistrUI, 'MMGame_LoadSaved' ) + ': ' + ItemString;
      FCMgC_LoadANewGame_Process( ParentItemString, ItemString );
   end;
end;

procedure FCMuiSG_SavedGameItem_Selected( const ItemString: string );
{:Purpose: item selection.
    Additions:
}

begin
   if FCFuiSG_SelectedItem_IsXMLFile( ItemString ) then
   begin
      FCWinSavedGames.WSG_Frame.Caption:=FCFdTFiles_UIStr_Get( uistrUI, 'MMGame_LoadSaved' ) + ': ' + ItemString;
//      FCVuiSGfilename:=ItemString;
      FCWinSavedGames.UnlockDoubleClick;
   end
   else FCWinSavedGames.LockDoubleClick;
end;

procedure FCMuiSG_SavedGamesList_Update;
{:Purpose: update de saved games list and refresh the tree list.
    Additions:
}
   var
      CurrentSavedGameFile
      ,CurrentSavedGamesSubDir
      ,SavedGamesDirectory: string;

      CurrentSearchedDir
      ,CurrentSearchedFile: TSearchRec;

      RootNode
      ,RootFileName: ttreeNode;
begin
//   FCVuiSGfilename:='';
   CurrentSavedGameFile:='';
   CurrentSavedGamesSubDir:='';
   SavedGamesDirectory:='';

   FCWinSavedGames.F_SavedGamesList.Items.Clear;
   FCWinSavedGames.F_SavedGamesList.FullExpand;
   SavedGamesDirectory:=FCVdiPathConfigDir+'SavedGames\';
   if SysUtils.FindFirst (SavedGamesDirectory + '*', faDirectory, CurrentSearchedDir) = 0 then
   try
      repeat
         if ( CurrentSearchedDir.Name <> '.' )
            and ( CurrentSearchedDir.Name <> '..' ) then
         begin
            RootNode:=FCWinSavedGames.F_SavedGamesList.Items.Add( nil, CurrentSearchedDir.Name );
            CurrentSavedGamesSubDir:=SavedGamesDirectory+CurrentSearchedDir.Name+'\';
            if SysUtils.FindFirst( CurrentSavedGamesSubDir + '*.xml', faAnyFile, CurrentSearchedFile ) = 0 then
               repeat
                  RootFileName:=FCWinSavedGames.F_SavedGamesList.Items.AddChild( RootNode, CurrentSearchedFile.Name );
               until FindNext( CurrentSearchedFile ) <> 0;
         end;
      until FindNext(CurrentSearchedDir) <> 0;
   finally
      SysUtils.FindClose(CurrentSearchedDir) ;
   end;
   FCWinSavedGames.F_SavedGamesList.Select( RootNode );
   FCWinSavedGames.LockDoubleClick;
end;

end.
