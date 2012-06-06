{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: HTML / link processing - data unit

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
unit farc_data_html;

interface

//uses

//==END PUBLIC ENUM=========================================================================

{:REFERENCES LIST
   - FCMdF_HelpTDef_Load
   - FCMuiW_HelpTDef_Link
   - FCMuiW_UI_Initialize
}
type TFCRtopdef= record
      TD_link: string[20];
      TD_str: string;
   end;
      TFCDBtdef= array of TFCRtopdef;


//==END PUBLIC RECORDS======================================================================

var
   //==========databases and other data structures pre-init=================================
      FCDBhelpTdef: TFCDBtdef;
//==END PUBLIC VAR==========================================================================

const

 {.miniHTML standard formating}
      {:DEV NOTES: put them in ui_html.}
      FCCFdHead='<p align="left" bgcolor="#374A4A00" bgcolorto="#25252500"><b>';
      FCCFdHeadC='<p align="center" bgcolor="#374A4A00" bgcolorto="#25252500"><b>';
      FCCFdHeadEnd='</b></p>';
      FCCFcolBlue='<font color="#3e3eff00">';
      FCCFcolBlueL='<font color="#409FFF00">';
      FCCFcolEND='</font>';
      FCCFcolGreen='<font color="cllime">';
      FCCFcolOrge='<font color="#FF641a00">';
      FCCFcolRed='<font color="#EA000000">';
      FCCFcolWhBL='<font color="#DCEAFA00">';
      FCCFcolYel='<font color="#FFFFCA00">';
      FCCFidxL6='<ind x="6">';
      FCCFidxL='<ind x="14">';
      FCCFidxL2='<ind x="20">';
      FCCFidxR='<ind x="120">';
      FCCFidxRi='<ind x="140">';
      FCCFidxRR='<ind x="180">';
      FCCFidxRRR='<ind x="240">';
      FCCFidxRRRR='<ind x="340">';    {:DEV NOTES: rename them including the spaceX.}
      FCCFpanelTitle=FCCFidxL2+'<b>';

//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

implementation

//uses

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

end.
