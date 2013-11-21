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
   ,farc_main
   ,farc_ui_keys
   ,farc_win_savedgames;

//==END PRIVATE ENUM========================================================================


//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
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
   FCWinSavedGames.WSG_Frame.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'MMGame_LoadSaved');
   FCWinSavedGames.F_SavedGamesHeader.HTMLText.Clear;
   FCWinSavedGames.F_SavedGamesHeader.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI,'savedgamesHeader' )+FCCFdHeadEnd );
//   RootNodeCredits:=FCWinAbout.F_Credits.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutCredits' )+'</b>' );
//   RootNodeCode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCredits, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutCodeDesign' )+'</b>' );
//   RootNodeAssets2D:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCredits, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssets2D' )+'</b>' );
//   RootNodeAssets3D:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCredits, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssets3D' )+'</b>' );
//   RootNodeAssetsSound:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCredits, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetsSound' )+'</b>' );
//   RootNodeAssetsMusic:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCredits, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetsMusic' )+'</b>' );
//   FCWinMain.FCXMLtxtCredits.FileName:=FCVdiPathXML+'\text\credits.xml';
//   FCWinMain.FCXMLtxtCredits.Active:=true;
//   {.code and design section}
//   CreditSection:=FCWinMain.FCXMLtxtCredits.DocumentElement.ChildNodes.FindNode('code_design');
//   if CreditSection<>nil then
//   begin
//      CreditSubsection:=CreditSection.ChildNodes.First;
//      while creditSubsection<>nil do
//      begin
//         TextDump:='';
//         SubNode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCode, CreditSubsection.attributes['name']+' (contact: <a href="'+CreditSubsection.attributes['contact']+'">'+CreditSubsection.attributes['contact']+'</a>)' );
//         CreditInfo:=CreditSubsection.ChildNodes.FindNode( FCVdiLanguage );
//         if CreditInfo<>nil
//         then TextDump:=CreditInfo.Text;
//         InfoNode:=FCWinAbout.F_Credits.Items.AddChild( SubNode, TextDump );
//         SubNode.Expanded:=true;
//         InfoNode.Expanded:=true;
//         CreditSubsection:=CreditSubsection.NextSibling;
//      end;
//   end;
//   {.2d assets section}
//   CreditSection:=FCWinMain.FCXMLtxtCredits.DocumentElement.ChildNodes.FindNode('assets2D');
//   if CreditSection<>nil then
//   begin
//      CreditSubsection:=CreditSection.ChildNodes.First;
//      while CreditSubsection<>nil do
//      begin
//         TextDump:='';
//         TextDump1:='';
//         SubNode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeAssets2D, CreditSubsection.attributes['author']+' (contact: <a href="'+CreditSubsection.attributes['contact']+'">'+CreditSubsection.attributes['contact']+'</a>)' );
//         CreditInfo:=CreditSubsection.ChildNodes.First;
//         while CreditInfo<>nil do
//         begin
//            TextLicense:=CreditInfo.attributes['license'];
//            if TextLicense='' then
//            begin
//               CreditInfo:=CreditInfo.NextSibling;
//               if CreditInfo<>nil then
//               begin
//                  TextLicense:=CreditInfo.attributes['license'];
//                  InfoNode:=FCWinAbout.F_Credits.Items.AddChild( SubNode, '( '+FCFdTFiles_UIStr_Get( uistrUI, TextLicense )+')' );
//                  InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
//               end;
//            end
//            else InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
//            CreditInfo:=CreditInfo.NextSibling;
//         end;
//         SubNode.Expanded:=false;
//         InfoNode.Expanded:=false;
//         InfoNode1.Expanded:=false;
//         CreditSubsection:=CreditSubsection.NextSibling;
//      end;
//   end;
//   {.3d assets section}
//   CreditSection:=FCWinMain.FCXMLtxtCredits.DocumentElement.ChildNodes.FindNode('assets3D');
//   if CreditSection<>nil then
//   begin
//      CreditSubsection:=CreditSection.ChildNodes.First;
//      while CreditSubsection<>nil do
//      begin
//         TextDump:='';
//         TextDump1:='';
//         SubNode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeAssets3D, CreditSubsection.attributes['author']+' (contact: <a href="'+CreditSubsection.attributes['contact']+'">'+CreditSubsection.attributes['contact']+'</a>)' );
//         CreditInfo:=CreditSubsection.ChildNodes.First;
//         while CreditInfo<>nil do
//         begin
//            TextLicense:=CreditInfo.attributes['license'];
//            if TextLicense='' then
//            begin
//               CreditInfo:=CreditInfo.NextSibling;
//               if CreditInfo<>nil then
//               begin
//                  TextLicense:=CreditInfo.attributes['license'];
//                  InfoNode:=FCWinAbout.F_Credits.Items.AddChild( SubNode, '( '+FCFdTFiles_UIStr_Get( uistrUI, TextLicense )+')' );
//                  InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
//               end;
//            end
//            else InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
//            CreditInfo:=CreditInfo.NextSibling;
//         end;
//         SubNode.Expanded:=false;
//         InfoNode.Expanded:=false;
//         InfoNode1.Expanded:=false;
//         CreditSubsection:=CreditSubsection.NextSibling;
//      end;
//   end;
//   {.sound assets section}
//   CreditSection:=FCWinMain.FCXMLtxtCredits.DocumentElement.ChildNodes.FindNode('assetsSound');
//   if CreditSection<>nil then
//   begin
//      CreditSubsection:=CreditSection.ChildNodes.First;
//      while CreditSubsection<>nil do
//      begin
//         TextDump:='';
//         TextDump1:='';
//         SubNode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeAssetsSound, CreditSubsection.attributes['author']+' (contact: <a href="'+CreditSubsection.attributes['contact']+'">'+CreditSubsection.attributes['contact']+'</a>)' );
//         CreditInfo:=CreditSubsection.ChildNodes.First;
//         while CreditInfo<>nil do
//         begin
//            TextLicense:=CreditInfo.attributes['license'];
//            if TextLicense='' then
//            begin
//               CreditInfo:=CreditInfo.NextSibling;
//               if CreditInfo<>nil then
//               begin
//                  TextLicense:=CreditInfo.attributes['license'];
//                  InfoNode:=FCWinAbout.F_Credits.Items.AddChild( SubNode, '( '+FCFdTFiles_UIStr_Get( uistrUI, TextLicense )+')' );
//                  InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
//               end;
//            end
//            else InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
//            CreditInfo:=CreditInfo.NextSibling;
//         end;
//         SubNode.Expanded:=false;
//         InfoNode.Expanded:=false;
//         InfoNode1.Expanded:=false;
//         CreditSubsection:=CreditSubsection.NextSibling;
//      end;
//   end;
//   {.music assets section}
//   CreditSection:=FCWinMain.FCXMLtxtCredits.DocumentElement.ChildNodes.FindNode('assetsMusic');
//   if CreditSection<>nil then
//   begin
//      CreditSubsection:=CreditSection.ChildNodes.First;
//      while CreditSubsection<>nil do
//      begin
//         TextDump:='';
//         TextDump1:='';
//         SubNode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeAssetsMusic, CreditSubsection.attributes['author']+' (contact: <a href="'+CreditSubsection.attributes['contact']+'">'+CreditSubsection.attributes['contact']+'</a>)' );
//         CreditInfo:=CreditSubsection.ChildNodes.First;
//         while CreditInfo<>nil do
//         begin
//            TextLicense:=CreditInfo.attributes['license'];
//            if TextLicense='' then
//            begin
//               CreditInfo:=CreditInfo.NextSibling;
//               if CreditInfo<>nil then
//               begin
//                  TextLicense:=CreditInfo.attributes['license'];
//                  InfoNode:=FCWinAbout.F_Credits.Items.AddChild( SubNode, '( '+FCFdTFiles_UIStr_Get( uistrUI, TextLicense )+')' );
//                  InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
//               end;
//            end
//            else InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
//            CreditInfo:=CreditInfo.NextSibling;
//         end;
//         SubNode.Expanded:=false;
//         InfoNode.Expanded:=false;
//         InfoNode1.Expanded:=false;
//         CreditSubsection:=CreditSubsection.NextSibling;
//      end;
//   end;
//   FCWinMain.FCXMLtxtCredits.Active:=false;
//   RootNodeCredits.Expanded:=true;
//   RootNodeCode.Expanded:=true;
//   RootNodeAssets2D.Expanded:=true;
//   RootNodeAssets3D.Expanded:=true;
//   RootNodeAssetsSound.Expanded:=true;
//   RootNodeAssetsMusic.Expanded:=true;
//   FCWinAbout.F_Credits.Select(RootNodeCode);
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
            RootNode:=FCWinSavedGames.F_SavedGamesList.Items.Add( nil, '<b>'+CurrentSearchedDir.Name+'</b>' );
            CurrentSavedGamesSubDir:=SavedGamesDirectory+CurrentSearchedDir.Name+'\';
            if SysUtils.FindFirst( CurrentSavedGamesSubDir + '*.xml', faAnyFile, CurrentSearchedFile ) = 0 then
               repeat
                  RootFileName:=FCWinSavedGames.F_SavedGamesList.Items.AddChild( RootNode, '<b>'+CurrentSearchedFile.Name+'</b>' );
               until FindNext( CurrentSearchedFile ) <> 0;
         end;
      until FindNext(CurrentSearchedDir) <> 0;
   finally
      SysUtils.FindClose(CurrentSearchedDir) ;
   end;
end;

end.
