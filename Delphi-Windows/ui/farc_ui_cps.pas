{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: CPS interface core

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
unit farc_ui_cps;

interface

uses
   SysUtils

   ,farc_game_cpsobjectives;

///<summary>
///   format a string which contain the specified CPS objectives, its score, and additional data if needed
///</summary>
///   <param name="ObjectiveIndex">objective index #</param>
///   <returns>the formatted objective w/ score and data</returns>
function FCFuiCPS_Objective_GetFormat( const ObjectiveIndex: integer ): string;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_data_game
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_game_cps
   ,farc_game_entitiesfactions
   ,farc_game_prod;

//===================================================END OF INIT============================

function FCFuiCPS_Objective_GetFormat( const ObjectiveIndex: integer ): string;
{:Purpose: format a string which contain the specified CPS objectives, its score, and additional data if needed.
    Additions:
      -2012Mar25- *add: otEcoEnEff + otEcoIndustrialForce + otEcoLowCr completion.
}
   var
      ResultStr1
      ,ResultStr2: string;
begin
   Result:='';
   ResultStr1:='';
   ResultStr2:='';
   case FCcps.CPSviabObj[ ObjectiveIndex ].CPSO_type of
      otEcoEnEff:
      begin
         ResultStr1:=FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI, 'cpsVOotEcoEnEff');
         ResultStr2:=' <br>';
         FCcpsObjectivesLines:=FCcpsObjectivesLines+1;
      end;

      otEcoIndustrialForce:
      begin
         ResultStr1:=FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI, 'cpsVOotEcoIndustrialForce');
         ResultStr2:='Product to Produce: '+FCFdTFiles_UIStr_Get( uistrUI, FCcps.CPSviabObj[ ObjectiveIndex ].CPSO_ifProduct )+'<br>'
            +'Threshold to Reach: '+FCFgP_StringFromUnit_Get(
               FCcps.CPSviabObj[ ObjectiveIndex ].CPSO_ifProduct
               ,FCcps.CPSviabObj[ ObjectiveIndex ].CPSO_ifThreshold
               ,''
               ,false
               ,false
               )+' /hr <br><br> ';
         FCcpsObjectivesLines:=FCcpsObjectivesLines+3;
      end;

      otEcoLowCr:
      begin
         ResultStr1:=FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI, 'cpsVOotEcoLowCr');
         ResultStr2:=' <br>';
         FCcpsObjectivesLines:=FCcpsObjectivesLines+1;
      end;

      otEcoSustCol:;

      otSocSecPop:;
   end;
   Result:=ResultStr1+'<ind x="250"> ['+inttostr(FCcps.CPSviabObj[ ObjectiveIndex ].CPSO_score)+'%]'+FCCFdHeadEnd+ResultStr2;

end;

//===========================END FUNCTIONS SECTION==========================================

end.
