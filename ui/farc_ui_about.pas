{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: about window - core unit

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
unit farc_ui_about;

interface

uses
   ComCtrls
   ,MSXMLDOM
   ,XMLIntf
	,XMLDoc;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   init the elements (size and location) of the panel
///</summary>
procedure FCMuiA_Panel_InitElements;

///<summary>
///   init the fonts of the panel
///</summary>
procedure FCMuiA_Panel_InitFonts;

///<summary>
///   init the texts of the panel
///</summary>
procedure FCMuiA_Panel_InitText;

implementation

uses
   farc_common_func
   ,farc_data_html
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_main
   ,farc_win_about;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiA_Panel_InitElements;
{:Purpose: init the elements (size and location) of the panel.
    Additions:            
}
begin
   FCWinAbout.Width:=580;
   FCWinAbout.Height:=FCWinMain.Height shr 3*5;
   FCWinAbout.Left:=FCWinMain.Left+( FCWinMain.Width shr 1 )-(FCWinAbout.Width shr 1);
   FCWinAbout.Top:=FCWinMain.Top+( FCWinMain.Height shr 1 )-(FCWinAbout.Height shr 1);
   FCWinAbout.F_Header.Height:=FCWinAbout.Height shr 3*1;
   FCWinAbout.F_Credits.Height:=FCWinAbout.Height shr 3 *7;
end;

procedure FCMuiA_Panel_InitFonts;
{:Purpose: init the fonts of the panel.
    Additions:
}
begin

end;

procedure FCMuiA_Panel_InitText;
{:Purpose: init the texts of the panel.
    Additions:
      -2013Mar30- *add: complete the texts localization.
}
   var
      TextDump
      ,TextDump1
      ,TextLicense: string;

      CreditInfo
      ,CreditSection
      ,CreditSubsection: IXMLNode;

      InfoNode
      ,InfoNode1
      ,RootNodeCredits
      ,RootNodeCode
      ,RootNodeAssets2D
      ,RootNodeAssets3D
      ,RootNodeAssetsSound
      ,RootNodeAssetsMusic
      ,SubNode: TTreeNode;
begin
   {.main frame}
   FCWinAbout.WA_Frame.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_MMenu_H_About')+' FAR Colony '+FCFcF_FARCVersion_Get;
   FCWinAbout.F_Header.HTMLText.Clear;
   FCWinAbout.F_Header.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI,'aboutheader1' )+FCCFdHeadEnd );
   FCWinAbout.F_Header.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI,'aboutheader2' )+'</b></font><a href="http://farcolony.blogspot.com/">http://farcolony.blogspot.com/</a>'+FCCFdHeadEnd );
   FCWinAbout.F_Header.HTMLText.Add( FCCFdHeadC+FCFdTFiles_UIStr_Get( uistrUI,'aboutheader3' )+'</b></font><a href="http://code.google.com/p/farcolony/">http://code.google.com/p/farcolony/</a>'+FCCFdHeadEnd );
   FCWinAbout.F_Credits.Items.Clear;
   FCWinAbout.F_Credits.FullExpand;
   RootNodeCredits:=FCWinAbout.F_Credits.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutCredits' )+'</b>' );
   RootNodeCode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCredits, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutCodeDesign' )+'</b>' );
   RootNodeAssets2D:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCredits, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssets2D' )+'</b>' );
   RootNodeAssets3D:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCredits, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssets3D' )+'</b>' );
   RootNodeAssetsSound:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCredits, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetsSound' )+'</b>' );
   RootNodeAssetsMusic:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCredits, '<b>'+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetsMusic' )+'</b>' );
   FCWinMain.FCXMLtxtCredits.FileName:=FCVdiPathXML+'\text\credits.xml';
   FCWinMain.FCXMLtxtCredits.Active:=true;
   {.code and design section}
   CreditSection:=FCWinMain.FCXMLtxtCredits.DocumentElement.ChildNodes.FindNode('code_design');
   if CreditSection<>nil then
   begin
      CreditSubsection:=CreditSection.ChildNodes.First;
      while creditSubsection<>nil do
      begin
         TextDump:='';
         SubNode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeCode, CreditSubsection.attributes['name']+' (contact: <a href="'+CreditSubsection.attributes['contact']+'">'+CreditSubsection.attributes['contact']+'</a>)' );
         CreditInfo:=CreditSubsection.ChildNodes.FindNode( FCVdiLanguage );
         if CreditInfo<>nil
         then TextDump:=CreditInfo.Text;
         InfoNode:=FCWinAbout.F_Credits.Items.AddChild( SubNode, TextDump );
         SubNode.Expanded:=true;
         InfoNode.Expanded:=true;
         CreditSubsection:=CreditSubsection.NextSibling;
      end;
   end;
   {.2d assets section}
   CreditSection:=FCWinMain.FCXMLtxtCredits.DocumentElement.ChildNodes.FindNode('assets2D');
   if CreditSection<>nil then
   begin
      CreditSubsection:=CreditSection.ChildNodes.First;
      while CreditSubsection<>nil do
      begin
         TextDump:='';
         TextDump1:='';
         SubNode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeAssets2D, CreditSubsection.attributes['author']+' (contact: <a href="'+CreditSubsection.attributes['contact']+'">'+CreditSubsection.attributes['contact']+'</a>)' );
         CreditInfo:=CreditSubsection.ChildNodes.First;
         while CreditInfo<>nil do
         begin
            TextLicense:=CreditInfo.attributes['license'];
            if TextLicense='' then
            begin
               CreditInfo:=CreditInfo.NextSibling;
               if CreditInfo<>nil then
               begin
                  TextLicense:=CreditInfo.attributes['license'];
                  InfoNode:=FCWinAbout.F_Credits.Items.AddChild( SubNode, '( '+FCFdTFiles_UIStr_Get( uistrUI, TextLicense )+')' );
                  InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
               end;
            end
            else InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
            CreditInfo:=CreditInfo.NextSibling;
         end;
         SubNode.Expanded:=false;
         InfoNode.Expanded:=false;
         InfoNode1.Expanded:=false;
         CreditSubsection:=CreditSubsection.NextSibling;
      end;
   end;
   {.3d assets section}
   CreditSection:=FCWinMain.FCXMLtxtCredits.DocumentElement.ChildNodes.FindNode('assets3D');
   if CreditSection<>nil then
   begin
      CreditSubsection:=CreditSection.ChildNodes.First;
      while CreditSubsection<>nil do
      begin
         TextDump:='';
         TextDump1:='';
         SubNode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeAssets3D, CreditSubsection.attributes['author']+' (contact: <a href="'+CreditSubsection.attributes['contact']+'">'+CreditSubsection.attributes['contact']+'</a>)' );
         CreditInfo:=CreditSubsection.ChildNodes.First;
         while CreditInfo<>nil do
         begin
            TextLicense:=CreditInfo.attributes['license'];
            if TextLicense='' then
            begin
               CreditInfo:=CreditInfo.NextSibling;
               if CreditInfo<>nil then
               begin
                  TextLicense:=CreditInfo.attributes['license'];
                  InfoNode:=FCWinAbout.F_Credits.Items.AddChild( SubNode, '( '+FCFdTFiles_UIStr_Get( uistrUI, TextLicense )+')' );
                  InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
               end;
            end
            else InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
            CreditInfo:=CreditInfo.NextSibling;
         end;
         SubNode.Expanded:=false;
         InfoNode.Expanded:=false;
         InfoNode1.Expanded:=false;
         CreditSubsection:=CreditSubsection.NextSibling;
      end;
   end;
   {.sound assets section}
   CreditSection:=FCWinMain.FCXMLtxtCredits.DocumentElement.ChildNodes.FindNode('assetsSound');
   if CreditSection<>nil then
   begin
      CreditSubsection:=CreditSection.ChildNodes.First;
      while CreditSubsection<>nil do
      begin
         TextDump:='';
         TextDump1:='';
         SubNode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeAssetsSound, CreditSubsection.attributes['author']+' (contact: <a href="'+CreditSubsection.attributes['contact']+'">'+CreditSubsection.attributes['contact']+'</a>)' );
         CreditInfo:=CreditSubsection.ChildNodes.First;
         while CreditInfo<>nil do
         begin
            TextLicense:=CreditInfo.attributes['license'];
            if TextLicense='' then
            begin
               CreditInfo:=CreditInfo.NextSibling;
               if CreditInfo<>nil then
               begin
                  TextLicense:=CreditInfo.attributes['license'];
                  InfoNode:=FCWinAbout.F_Credits.Items.AddChild( SubNode, '( '+FCFdTFiles_UIStr_Get( uistrUI, TextLicense )+')' );
                  InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
               end;
            end
            else InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
            CreditInfo:=CreditInfo.NextSibling;
         end;
         SubNode.Expanded:=false;
         InfoNode.Expanded:=false;
         InfoNode1.Expanded:=false;
         CreditSubsection:=CreditSubsection.NextSibling;
      end;
   end;
   {.music assets section}
   CreditSection:=FCWinMain.FCXMLtxtCredits.DocumentElement.ChildNodes.FindNode('assetsMusic');
   if CreditSection<>nil then
   begin
      CreditSubsection:=CreditSection.ChildNodes.First;
      while CreditSubsection<>nil do
      begin
         TextDump:='';
         TextDump1:='';
         SubNode:=FCWinAbout.F_Credits.Items.AddChild( RootNodeAssetsMusic, CreditSubsection.attributes['author']+' (contact: <a href="'+CreditSubsection.attributes['contact']+'">'+CreditSubsection.attributes['contact']+'</a>)' );
         CreditInfo:=CreditSubsection.ChildNodes.First;
         while CreditInfo<>nil do
         begin
            TextLicense:=CreditInfo.attributes['license'];
            if TextLicense='' then
            begin
               CreditInfo:=CreditInfo.NextSibling;
               if CreditInfo<>nil then
               begin
                  TextLicense:=CreditInfo.attributes['license'];
                  InfoNode:=FCWinAbout.F_Credits.Items.AddChild( SubNode, '( '+FCFdTFiles_UIStr_Get( uistrUI, TextLicense )+')' );
                  InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
               end;
            end
            else InfoNode1:=FCWinAbout.F_Credits.Items.AddChild( InfoNode, FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetCurrent' )+FCCFcolEND+' <b>'+CreditInfo.attributes['current']+'</b> - '+FCCFcolWhBL+FCFdTFiles_UIStr_Get( uistrUI, 'aboutAssetOriginal' )+FCCFcolEND+' <b>'+CreditInfo.attributes['original']+'</b>' );
            CreditInfo:=CreditInfo.NextSibling;
         end;
         SubNode.Expanded:=false;
         InfoNode.Expanded:=false;
         InfoNode1.Expanded:=false;
         CreditSubsection:=CreditSubsection.NextSibling;
      end;
   end;
   FCWinMain.FCXMLtxtCredits.Active:=false;
   RootNodeCredits.Expanded:=true;
   RootNodeCode.Expanded:=true;
   RootNodeAssets2D.Expanded:=true;
   RootNodeAssets3D.Expanded:=true;
   RootNodeAssetsSound.Expanded:=true;
   RootNodeAssetsMusic.Expanded:=true;
   FCWinAbout.F_Credits.Select(RootNodeCode);
end;

end.
