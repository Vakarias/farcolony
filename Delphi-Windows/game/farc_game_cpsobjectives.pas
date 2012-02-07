{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: CPS objectives management

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
unit farc_game_cpsobjectives;

interface

//uses

   {.viability objectives types}
   {:DEV NOTE: update factionsdb.xml + FCMdFiles_DBFactions_Read + FCMdFiles_Game_Save/Load}
   {:DEV NOTE: update FCM_ViabObj_Init + FCF_ViabObj_Use + FCM_ViabObj_Calc + FCF_ViabObj_GetIdx.}
   type TFCEcpsoObjectiveTypes=(
      {.energy efficient}
      otEcoEnEff
      {.low credit line use}
      ,otEcoLowCr
      {.sustainable colony}
      ,otEcoSustCol
      {.secure population}
      ,otSocSecPop
      );

   {.faction's viability objectives}
   type TFCRcpsoViabilityObjective = record
      FVO_objTp: TFCEcpsoObjectiveTypes;
   end;

//===========================END FUNCTIONS SECTION==========================================

implementation

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

end.
