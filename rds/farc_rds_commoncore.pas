{======(C) Copyright Aug.2009-2014 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: research & development system (RDS) - common core unit

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
unit farc_rds_commoncore;

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
///   initialize the common core for a non-player faction
///</summary>
///   <param name="Entity">entity index # to initialize</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMcC_NonPlayerFaction_Initialize( const Entity: integer );

///<summary>
///   initialize the common core for the player faction
///</summary>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMcC_PlayerFaction_Initialize;

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_init
   ,farc_data_rds
   ,farc_rds_func;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   FCVrdsccDesignModifier: integer;

   FCVrdsccHighestTLbyDesign: TFCEdrdsTechnologyLevels;

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FMcC_DevelopmentLevel_Generate( const RDomOrientation: integer ): TFCEdgTechnoscienceMasteringStages;
{:Purpose: generate a development level accordingly to the research domain's orientation.
    Additions:
}
   var
      GeneratedProbability: integer;
begin
   Result:=tmsNotDiscovered;
   GeneratedProbability:=0;
   GeneratedProbability:=FCFcF_Random_DoInteger( 5 ) + 1 + RDomOrientation;
   if GeneratedProbability < 0
   then GeneratedProbability:=0
   else if GeneratedProbability > 10
   then GeneratedProbability:=10;
   {.+2 because the enum contain also the other mastering stage below the development levels}
   Result:=TFCEdgTechnoscienceMasteringStages( GeneratedProbability + 2 );
end;

function FCFrdsF_NonPlayerFaction_GetRDomTLCap( const RDOMOrientation: integer ): TFCEdrdsTechnologyLevels;
{:Purpose: gives the tech level cap of a research domain according to its orientation, for a non-player faction.
    Additions:
      -2014Aug27- *add: rule concerning the tech level of technosciences/fundamental researches added by design.
                  *add: design modifier calculations.
      -2014Aug25- *code: moved from farc_rds_func => farc_rds_commoncore. Include refactoring.
}
begin
   Result:=tl04CyberAge;
   case RDOMOrientation of
      -3: Result:=tl04CyberAge;

      -2..-1: Result:=tl05InterplanetaryAge;

      0: Result:=tl06TranshumanismAge;

      1..2: Result:=tl07NanoAge;

      3: Result:=tl08SingularityAge;
   end;
   if FCVrdsccHighestTLbyDesign > Result then
   begin
      Result:=FCVrdsccHighestTLbyDesign;
      FCVrdsccDesignModifier:=round( ( Integer( FCVrdsccHighestTLbyDesign ) + 1 ) / 3 ) + 1;
   end;

end;

//===========================END FUNCTIONS SECTION==========================================

procedure FMcC_Core_Initialize(
   const Entity
         ,ResearchDomain
         ,RDomOrientation: integer
   );
{:Purpose: initialize the rds data structure and master the tech level 1 technosciences and fundamental researches.
    Additions:
      -2014Aug27- *add: initialize FCVrdsccHighestTLbyDesign and set it if there are any technosciences and fundamental researches by design.
                  *add: initialize the FCVrdsccDesignModifier.
      -2014Aug25- *add: common core of technosciences and fundamental researches by design.
}
   var
      Count1
      ,Count2
      ,Count3
      ,Max1
      ,Max2
      ,Max3: integer;

   function _CompareWithFactionCoreSetup( const TSFRtokenToCompare: string ): boolean;
   begin
      Result:=false;
      Max3:=length( FCDdgFactions[Entity].F_comCoreSetup ) - 1;
      Count3:=1;
      while Count3 <= Max3 do
      begin
         if FCDdgFactions[Entity].F_comCoreSetup[Count3].CCS_techToken = TSFRtokenToCompare then
         begin
            Result:=true;
            break;
         end;
         inc( Count3 );
      end;
   end;

begin
   Count1:=0;
   Count2:=0;
   Max1:=0;
   Max2:=0;
   FCVrdsccHighestTLbyDesign:=tl01IndustrialAge;
   FCVrdsccDesignModifier:=0;
   FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_type:=FCDdrdsResearchDatabase[ResearchDomain].RD_type;
   FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_knowledgeCurrent:=0;
   {.fundamental researches}
   Count1:=1;
   Max1:=length( FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches ) - 1;
   setlength( FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_fundamentalResearches, Max1 + 1 );
   while Count1 <= Max1 do
   begin
      FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_fundamentalResearches[Count1].TS_token:=FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[Count1].TS_token;
      FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_fundamentalResearches[Count1].TS_collateralMastered:=false;
      if FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[Count1].TS_techLevel = tl01IndustrialAge
      then FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_fundamentalResearches[Count1].TS_masteringStage:=FMcC_DevelopmentLevel_Generate( RDomOrientation )
      else if (Entity > 0 )
         and ( _CompareWithFactionCoreSetup( FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_fundamentalResearches[Count1].TS_token ) ) then
      begin
         FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_fundamentalResearches[Count1].TS_masteringStage:=FMcC_DevelopmentLevel_Generate( RDomOrientation );
         if FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[Count1].TS_techLevel > FCVrdsccHighestTLbyDesign
         then FCVrdsccHighestTLbyDesign:=FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[Count1].TS_techLevel;
      end
      else FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_fundamentalResearches[Count1].TS_masteringStage:=tmsNotDiscovered;
      FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_fundamentalResearches[Count1].TS_ripCurrent:=0;
      FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_fundamentalResearches[Count1].TS_ripMax:=FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[Count1].TS_maxRIPpoints;
      inc( Count1 );
   end;
   {.research fields/technosciences}
   Count1:=1;
   Max1:=length( FCDdrdsResearchDatabase[ResearchDomain].RD_researchFields ) - 1;
   setlength( FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields, Max1 + 1 );
   while Count1 <= Max1 do
   begin
      FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_type:=FCDdrdsResearchDatabase[ResearchDomain].RD_researchFields[Count1].RF_type;
      FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_knowledgeCurrent:=0;
      FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_knowledgeGenerationTotal:=0;
      Count2:=1;
      Max2:=length( FCDdrdsResearchDatabase[ResearchDomain].RD_researchFields[Count1].RF_technosciences ) - 1;
      setlength( FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_technosciences, Max2 + 1 );
      while Count2 <= Max2 do
      begin
         FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_technosciences[Count2].TS_token:=FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[Count1].TS_token;
         FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_technosciences[Count2].TS_collateralMastered:=false;
         if FCDdrdsResearchDatabase[ResearchDomain].RD_researchFields[Count1].RF_technosciences[Count2].TS_techLevel = tl01IndustrialAge
         then FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_technosciences[Count2].TS_masteringStage:=FMcC_DevelopmentLevel_Generate( RDomOrientation )
         else if ( Entity > 0 )
            and ( _CompareWithFactionCoreSetup( FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_technosciences[Count2].TS_token ) ) then
         begin
            FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_technosciences[Count2].TS_masteringStage:=FMcC_DevelopmentLevel_Generate( RDomOrientation );
            if FCDdrdsResearchDatabase[ResearchDomain].RD_researchFields[Count1].RF_technosciences[Count2].TS_techLevel > FCVrdsccHighestTLbyDesign
            then FCVrdsccHighestTLbyDesign:=FCDdrdsResearchDatabase[ResearchDomain].RD_researchFields[Count1].RF_technosciences[Count2].TS_techLevel;
         end
         else FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_technosciences[Count2].TS_masteringStage:=tmsNotDiscovered;
         FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_technosciences[Count2].TS_ripCurrent:=0;
         FCDdgEntities[Entity].E_researchDomains[ResearchDomain].RDE_researchFields[Count1].RF_technosciences[Count2].TS_ripMax:=FCDdrdsResearchDatabase[ResearchDomain].RD_fundamentalResearches[Count1].TS_maxRIPpoints;
         inc( Count2 );
      end;
      inc( Count1 );
   end;
end;

procedure FCMcC_NonPlayerFaction_Initialize( const Entity: integer );
{:Purpose: initialize the common core for a non-player faction.
    Additions:
}
   var
      Count
      ,Count1
      ,Count2
      ,Count3
      ,Count4
      ,CurrentTLindex
      ,DesignModifier
      ,GeneratedProbability
      ,Max2
      ,Max4
      ,MaxTLindex: integer;

      MaxTL: TFCEdrdsTechnologyLevels;

      ///<summary>
      /// available technosciences/fundamental researches list [x,y] = record
         ///<summary>
         /// x= tech level index from 2 to TL cap
         ///</summary>
         ///<summary>
         /// y= non db index of available technosciences/fundamental research
         ///</summary>
      ///</summary>
      TSFRlist: array of array of record
         TSFRL_indexInDB: integer;
         case TSFRL_isFundamentalResearch: boolean of
            False:( TSFRL_fResearchFieldIdx: integer );

            True:( );
      end;
begin
   Count:=0;
   Count1:=1;
   Count2:=0;
   Count3:=0;
   Count4:=0;
   CurrentTLindex:=0;
   DesignModifier:=0;
   GeneratedProbability:=0;
   Max2:=0;
   Max4:=0;
   MaxTLindex:=0;
   MaxTL:=tl01IndustrialAge;
   SetLength( TSFRlist, 1 );
   while Count1 <= FCCdiRDSdomainsMax do
   begin
      SetLength( TSFRlist, 1 );
      {.
         Count: common core orientation of the current research domain
      }
      case Count1 of
         1: Count:=FCDdgFactions[Entity].F_comCoreOrient_aerospaceEng;

         2: Count:=FCDdgFactions[Entity].F_comCoreOrient_astroEng;

         3: Count:=FCDdgFactions[Entity].F_comCoreOrient_biosciences;

         4: Count:=FCDdgFactions[Entity].F_comCoreOrient_culture;

         5: Count:=FCDdgFactions[Entity].F_comCoreOrient_ecosciences;

         6: Count:=FCDdgFactions[Entity].F_comCoreOrient_indusTech;

         7: Count:=FCDdgFactions[Entity].F_comCoreOrient_nanotech;

         8: Count:=FCDdgFactions[Entity].F_comCoreOrient_physics;
      end;
      FMcC_Core_Initialize(
         Entity
         ,Count1
         ,Count
         );
      MaxTL:=FCFrdsF_NonPlayerFaction_GetRDomTLCap( Count );
      MaxTLindex:=Integer( MaxTL ) + 1;
      if FCVrdsccDesignModifier = 0
      then GeneratedProbability:=FCFcF_Random_DoInteger( 2 ) + Count
      else if FCVrdsccDesignModifier > 0
      then GeneratedProbability:=FCVrdsccDesignModifier + Count;
      if ( ( GeneratedProbability <= 0 ) and ( FCVrdsccDesignModifier > 0 ) )
         or ( GeneratedProbability > 0 ) then
      begin
         {:DEV NOTES: PUT LIST CREATION INTO FMcC_Core_Initialize, WARNING TO USE ENTITY>1 WITH IT.}
         {.creation of a list of available technosciences/fundamental researches}
         SetLength( TSFRlist, MaxTLindex + 1 );
         {..fundamental researches first}
         Max2:=length( FCDdgEntities[Entity].E_researchDomains[Count1].RDE_fundamentalResearches ) - 1;
         Count2:=1;
         Count3:=0;
         while Count2 <= Max2 do
         begin
            if FCDdgEntities[Entity].E_researchDomains[Count1].RDE_fundamentalResearches[Count2].TS_masteringStage = tmsNotDiscovered then
            begin
               CurrentTLindex:=Integer( FCDdrdsResearchDatabase[Count1].RD_fundamentalResearches[Count2].TS_techLevel ) + 1;
               Count3:=length( TSFRlist[CurrentTLindex] ) - 1;
               inc( Count3 );
               SetLength( TSFRlist[CurrentTLindex], Count3 + 1 );
               TSFRlist[CurrentTLindex, Count3].TSFRL_indexInDB:=Count2;
               TSFRlist[CurrentTLindex, Count3].TSFRL_isFundamentalResearch:=true;
            end;
            inc( Count2 );
         end;
         {..technosciences in second}
         Max2:=length( FCDdgEntities[Entity].E_researchDomains[Count1].RDE_researchFields ) - 1;
         Count2:=1;
         while Count2 <= Max2 do
         begin
            Max4:=length( FCDdgEntities[Entity].E_researchDomains[Count1].RDE_researchFields[Count2].RF_technosciences ) - 1;
            Count4:=1;
            while Count4 <= Max4 do
            begin
               if FCDdgEntities[Entity].E_researchDomains[Count1].RDE_researchFields[Count2].RF_technosciences[Count4].TS_masteringStage = tmsNotDiscovered then
               begin
                  CurrentTLindex:=Integer( FCDdrdsResearchDatabase[Count1].RD_researchFields[Count2].RF_technosciences[Count4].TS_techLevel ) + 1;
                  Count3:=length( TSFRlist[CurrentTLindex] ) - 1;
                  inc( Count3 );
                  SetLength( TSFRlist[CurrentTLindex], Count3 + 1 );
                  TSFRlist[CurrentTLindex, Count3].TSFRL_indexInDB:=Count4;
                  TSFRlist[CurrentTLindex, Count3].TSFRL_isFundamentalResearch:=false;
                  TSFRlist[CurrentTLindex, Count3].TSFRL_fResearchFieldIdx:=Count2;
               end;
               inc( Count4);
            end;
            inc( Count2 );
         end;
         {.generation subprocess}
         Count2:=MaxTLindex;
         while Count2 > 0 do
         begin
            Count3:=FCFcF_Random_DoInteger( MaxTLindex - 1 ) + 1;
            if Count3 < 2
            then Count3:=2;
            Max4:=length( TSFRlist[Count3] ) - 1;
            if Max4 > 0 then
            begin
               Count4:=FCFcF_Random_DoInteger( Max4 - 1 ) + 1;
               if ( TSFRlist[Count3, Count4].TSFRL_isFundamentalResearch )
                  and ( FCDdgEntities[Entity].E_researchDomains[Count1].RDE_fundamentalResearches[TSFRlist[Count3, Count4].TSFRL_indexInDB].TS_masteringStage = tmsNotDiscovered
            end;
            dec( Count2 );
         end;



      end; //==END== if ( ( GeneratedProbability <= 0 ) and ( FCVrdsccDesignModifier > 0 ) ) or ( GeneratedProbability > 0 ) ==//



      inc( Count1 );
   end; //==END== while Count1 <= FCCdiRDSdomainsMax ==//
end;

procedure FCMcC_PlayerFaction_Initialize;
{:Purpose: initialize the common core for the player faction.
    Additions:
}
begin

end;

end.
