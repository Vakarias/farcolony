{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: region's resource spots (including surveys)

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
unit farc_game_prodrsrcspots;

interface

   uses
      farc_data_univ;

       {:DEV NOTES: upd SurveyedRsrcSpot.}

///<summary>
///   check if a given resource spot type is present (surveyed) by giving entity/colony and settlement #
///</summary>
///   <param name="IPIRCentity">entity index #</param>
///   <param name="IPIRCcolony">colony index#</param>
///   <param name="IPIRCsettlement">settlement index #</param>
///   <param name="IPIRCrsrcSpot">resource spot type</param>
///   <param name="IPIRCcalculateLocation">true= calculate the colony's location (retrieve the indexes)</param>
///   <returns>the resource spot index #, 0 if not found, more than 0 if found</returns>
function FCFgPRS_PresenceBySettlement_Check(
   const IPIRCentity
         ,IPIRCcolony
         ,IPIRCsettlement: integer;
   const IPIRCrsrcSpot: TFCEduRsrcSpotType;
   const IPIRCcalculateLocation: boolean
   ): integer;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_data_game
   ,farc_univ_func;

var
   GPRSloc: TFCRufStelObj;

//===================================================END OF INIT============================

function FCFgPRS_PresenceBySettlement_Check(
   const IPIRCentity
         ,IPIRCcolony
         ,IPIRCsettlement: integer;
   const IPIRCrsrcSpot: TFCEduRsrcSpotType;
   const IPIRCcalculateLocation: boolean
   ): integer;
{:Purpose: check if a given resource spot type is present (surveyed) by giving entity/colony and settlement #.
    Additions:
}
   var
      IPIRCregion
      ,IPIRCspotCount
      ,IPIRCspotMax
      ,IPIRCspotSubCount
      ,IPIRCspotSubMax: integer;

      IPIRCtargetOobj: string[20];
begin
   Result:=0;
   if ( IPIRCcalculateLocation )
      or ( GPRSloc[1]=0 ) then
   begin
      GPRSloc:=FCFuF_StelObj_GetFullRow(
         FCentities[IPIRCentity].E_col[IPIRCcolony].COL_locSSys
         ,FCentities[IPIRCentity].E_col[IPIRCcolony].COL_locStar
         ,FCentities[IPIRCentity].E_col[IPIRCcolony].COL_locOObj
         ,FCentities[IPIRCentity].E_col[IPIRCcolony].COL_locSat
         );
   end;
   if GPRSloc[4]=0
   then IPIRCtargetOobj:=FCDBSSys[ GPRSloc[1] ].SS_star[ GPRSloc[2] ].SDB_obobj[ GPRSloc[3] ].OO_token
   else if GPRSloc[4]>0
   then IPIRCtargetOobj:=FCDBSSys[ GPRSloc[1] ].SS_star[ GPRSloc[2] ].SDB_obobj[ GPRSloc[3] ].OO_satList[ GPRSloc[4] ].OOS_token;
   IPIRCregion:=FCentities[IPIRCentity].E_col[IPIRCcolony].COL_settlements[IPIRCsettlement].CS_region;
   IPIRCspotMax:=length(FCRplayer.P_SurveyedResourceSpots)-1;
   if IPIRCspotMax>0 then
   begin
      IPIRCspotCount:=1;
      while IPIRCspotCount<=IPIRCspotMax do
      begin
         if FCRplayer.P_SurveyedResourceSpots[IPIRCspotCount].SS_oobjToken=IPIRCtargetOobj then
         begin
            IPIRCspotSubMax:=length( FCRplayer.P_SurveyedResourceSpots[IPIRCspotCount].SS_surveyedRegions[IPIRCregion].SR_ResourceSpot )-1;
            IPIRCspotSubCount:=1;
            while IPIRCspotSubCount<=IPIRCspotSubMax do
            begin
               if FCRplayer.P_SurveyedResourceSpots[IPIRCspotCount].SS_surveyedRegions[IPIRCregion].SR_ResourceSpot[IPIRCspotSubCount].RS_type=IPIRCrsrcSpot
               then Result:=IPIRCspotCount;
               inc( IPIRCspotSubCount );
            end;
         end;
         inc(IPIRCspotCount);
      end;
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

end.
