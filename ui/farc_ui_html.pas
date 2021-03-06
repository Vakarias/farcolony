{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: HTML / link processing unit

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
unit farc_ui_html;

interface

uses
   SysUtils;


///<summary>
///   extract the a href value in a string that must begin with <a href=". Return the value in a string
///</summary>
///   <param name="AIAEhref">string containing the a href</param>
///   <returns>the href token</returns>
function FCFuiHTML_AnchorInAhref_Extract(const AIAEhref: string): string;

///<summary>
///   extract the a href value in a item which contain a question mark which is an encyclopaedia link
///</summary>
///   <param name="ListItemValue">string containing the a href</param>
///   <returns>the href token</returns>
function FCFuiHTML_AnchorInAhrefFromQuestionMarkItem_Extract( const ListItemValue: string ): string;

///<summary>
///   format a modifier value (+/- integer or extended) to a formatted HTML text with green (positive), red (negative) or default color (=0) colors, including the sign +/-
///</summary>
///   <param name="ModifierValue">the value to format</param>
///   <param name="isPutValInBold">[true]= put the value in bold</param>
///   <returns>the formatted HTML modifier</returns>
function FCFuiHTML_Modifier_GetFormat(
   const ModifierValue: extended;
   const isPutValInBold: boolean
   ): string;

//===========================END FUNCTIONS SECTION==========================================

{:DEV NOTES: put those in farc_data_html.}
const
   UIHTMLencyBEGIN=' <font size="7"><b><a href="';
   UIHTMLencyEND='">?</a></b></font> ';

implementation

uses
   farc_data_init
   ,farc_data_html;

type
   UIHTMLcharset = set of char;

const
   UIHTMLcharEndHref: UIHTMLcharset=['"'];

//===================================================END OF INIT============================

function FCFuiHTML_AnchorInAhref_Extract(const AIAEhref: string): string;
{:Purpose: extract the a href value in a string that must begin with <a href=". Return the value in a string.
    Additions:
}
var
   AIAEcount: integer;

   AIAEworkString: string;
begin
   Result:='';
   AIAEworkString:=AIAEhref;
   delete(AIAEworkString, 1, 9);
   AIAEcount:=1;
   While (AIAEcount<=length(AIAEworkString)) and not (AIAEworkString[AIAEcount] in UIHTMLcharEndHref) do inc(AIAEcount);
   delete(AIAEworkString, AIAEcount, length(AIAEworkString));
   Result:=AIAEworkString;
end;

function FCFuiHTML_AnchorInAhrefFromQuestionMarkItem_Extract( const ListItemValue: string ): string;
{:Purpose: extract the a href value in a item which contain a question mark which is an encyclopaedia link.
    Additions:
}
   var
      ItemPosition: integer;

      WorkingString: string;
begin
//   APLGSTlen:= Length(APLGSTres);
   WorkingString:=ListItemValue;
   ItemPosition:=pos('b', WorkingString)+1;
      Delete(WorkingString, 1, ItemPosition);
//   Delete(APLGSTres, 1, 1);
//   APLGSTpos:=pos('"', APLGSTres);
//   Delete(APLGSTres, APLGSTpos, APLGSTlen);
   Result:=FCFuiHTML_AnchorInAhref_Extract( WorkingString);
end;

function FCFuiHTML_Modifier_GetFormat(
   const ModifierValue: extended;
   const isPutValInBold: boolean
   ): string;
{:Purpose: format a modifier value (+/- integer or extended) to a formatted HTML text with green (positive), red (negative) or default color (=0) colors, including the sign +/-.
    Additions:
}
   var
      BoldEndText
      ,BoldText
      ,ValText: string;
begin
   Result:='';
   BoldEndText:='';
   BoldText:='';
   ValText:='';
   if isPutValInBold then
   begin
      BoldEndText:='</b>';
      BoldText:='<b>';
   end;
   if ModifierValue<0
   then Result:=FCCFcolRed+BoldText+FloatToStr( ModifierValue )+BoldEndText+FCCFcolEND
   else if ModifierValue>0
   then Result:=FCCFcolGreen+BoldText+'+'+FloatToStr( ModifierValue )+BoldEndText+FCCFcolEND
   else Result:=BoldText+FloatToStr( ModifierValue )+BoldEndText;
end;

//===========================END FUNCTIONS SECTION==========================================

end.
