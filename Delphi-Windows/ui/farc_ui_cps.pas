{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: CPS interface core

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
unit farc_ui_cps;

interface

uses
   SysUtils

   ,farc_game_cpsobjectives;

///<summary>
///   format a string which contain the specified CPS objectives, its score, and additional data if needed
///</summary>
///   <param name="TFCEcpsoObjectiveTypes">objective type</param>
///   <param name="ObjectiveScore">current objective' score</param>
///   <returns>the formatted objective w/ score and data</returns>
function FCFuiCPS_Objective_GetFormat( const ObjectiveType: TFCEcpsoObjectiveTypes; const ObjectiveScore: integer ): string;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_data_init
   ,farc_data_textfiles
   ,farc_game_cps;

//===================================================END OF INIT============================

function FCFuiCPS_Objective_GetFormat( const ObjectiveType: TFCEcpsoObjectiveTypes; const ObjectiveScore: integer ): string;
{:Purpose: format a string which contain the specified CPS objectives, its score, and additional data if needed.
    Additions:
}
   var
      ResultStr: string;
begin
   Result:='';
   ResultStr:='';
   case ObjectiveType of
      otEcoEnEff: ResultStr:=FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI, 'cpsVOotEcoEnEff');

      otEcoIndustrialForce: ResultStr:=FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI, 'cpsVOotEcoIndustrialForce');
      {:DEV NOTES: take in plyrs allegiance faction the secondary data and create a line with a br.}

      otEcoLowCr: ResultStr:=FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI, 'cpsVOotEcoLowCr');

      otEcoSustCol:;

      otSocSecPop:;
   end;
   Result:=ResultStr+'<ind x="250"> ['+inttostr(ObjectiveScore)+'%]'+'<br>Product = "carbonaceous ore" threshold="2.0"'+FCCFdHeadEnd;
end;

//===========================END FUNCTIONS SECTION==========================================

end.
