{======(C) Copyright Aug.2009-2014 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: research & development system (RDS) - root subsystem unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2014, Jean-Francois Baconnet

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
unit farc_rds_root;

interface

//uses

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMrdsR_CascadedCollateralEffects_Process(
   const isFromCommonCoreProcess: boolean;
   const Entity
         ,ResearchDomain
         ,TSFRIndex: integer
   ); overload;

///<summary>
///
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMrdsR_CascadedCollateralEffects_Process(
   const isFromCommonCoreProcess: boolean;
   const Entity
         ,ResearchDomain
         ,TSFRIndex
         ,TSResearchField: integer
   ); overload;


implementation

uses
   farc_data_game
   ,farc_data_rds;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMrdsR_CascadedCollateralEffects_Process(
   const isFromCommonCoreProcess: boolean;
   const Entity
         ,ResearchDomain
         ,TSFRIndex: integer
   ); overload;
{:Purpose: process the cascaded collateral effects for a fundamental research.
    Additions:
}
   var
      Count
      ,DiscoveredNotMastereCount
      ,Max
      ,RTSindex
      ,RTSrdomain
      ,RTSrfield: integer;
begin
   DiscoveredNotMastereCount:=0;
   RTSindex:=0;
   RTSrdomain:=0;
   RTSrfield:=0;
   Count:=1;
   Max:=length( FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[TSFRIndex].TS_relatedTechnosciences ) - 1;
   while Count <= Max do
   begin
      RTSindex:=FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[TSFRIndex].TS_relatedTechnosciences[Count].RTS_index;
      RTSrdomain:=FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[TSFRIndex].TS_relatedTechnosciences[Count].RTS_domainIndex;
      RTSrfield:=FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[TSFRIndex].TS_relatedTechnosciences[Count].RTS_fieldIndex;

      if ( RTSrfield = 0 )
         and ( FCDdgEntities[Entity].E_researchDomains[RTSrdomain].RDE_fundamentalResearches[RTSindex].TS_masteringStage = tmsNotDiscovered )
         and ( TFCEdrdsResearchDomains( RTSrdomain - 1 ) = FCDdrdsResearchDatabase[ResearchDomain].RD_type )
         and ( FCDdrdsResearchDatabase[RTSrdomain].RD_fundamentalResearches[RTSindex].TS_techLevel <= FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[TSFRIndex].TS_techLevel ) then
      begin
         FCDdgEntities[Entity].E_researchDomains[RTSrdomain].RDE_fundamentalResearches[RTSindex].TS_collateralMastered:=true;
         FCDdgEntities[Entity].E_researchDomains[RTSrdomain].RDE_fundamentalResearches[RTSindex].TS_cmtCollateralTriggerIndex:=RTSindex;
         FCDdgEntities[Entity].E_researchDomains[RTSrdomain].RDE_fundamentalResearches[RTSindex].TS_cmtIsCollateralTriggerFR:=
         FCDdgEntities[Entity].E_researchDomains[RTSrdomain].RDE_fundamentalResearches[RTSindex].
      end


//      else if ( FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[TSFRIndex].TS_relatedTechnosciences[Count].RTS_field > rfFundamentalResearch )
//         and ( FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[TSFRIndex].TS_masteringStage = tmsNotDiscovered )
//         and ( FCDdrdsResearchDatabase[ResearchDomain].RD_type = FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[TSFRIndex].TS_relatedTechnosciences[Count].RTS_domain ) then
//      begin
//
//      end

      ;

      inc( Count );
   end;

end;

procedure FCMrdsR_CascadedCollateralEffects_Process(
   const isFromCommonCoreProcess: boolean;
   const Entity
         ,ResearchDomain
         ,TSFRIndex
         ,TSResearchField: integer
   ); overload;
{:Purpose: process the cascaded collateral effects for a technoscience.
    Additions:
}
begin

end;

end.
