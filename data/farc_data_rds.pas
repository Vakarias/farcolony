{======(C) Copyright Aug.2009-2014 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: research & development system (RDS) - data unit

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
unit farc_data_rds;

interface

uses
   farc_data_init;

{:REFERENCES LIST
   - TFCRdrdsTechnoscience
}
type TFCEdrdsARITypes=(
   aritEventUndiscArea
   ,aritPolicy
   ,aritMeme
   );

{:REFERENCES LIST
   - TFCRdrdsTechnoscience
}
///<summary>
///
///</summary>
type TFCEdrdsInfluenceProjectionTypes=(
   iptProduct
   ,iptInfrastructure
   ,iptSpaceUnitArchitecture
   ,iptEquipmentModule
   ,iptSPMItem
   ,iptOwnRDOM
   ,iptExternalResearchField
   );

{:REFERENCES LIST
   - FCFrdsF_Domain_GetNumberOfResearchFields
   - TFCRdipProduct
}
///<summary>
///
///</summary>
type TFCEdrdsResearchDomains=(
   rdAerospaceengineering
   ,rdAstroEngineering
   ,rdBiosciences
   ,rdCulture
   ,rdEcosciences
   ,rdIndustrialTechnologies
   ,rdNanotechnology
   ,rdPhysics
   );

{:REFERENCES LIST
   - FCFrdsF_Domain_GetNumberOfResearchFields
   - TFCRdipProduct
}
type TFCEdrdsResearchFields=(
   rfFundamentalResearch
   ,rf1AerospaceTechnics
   ,rf1SpaceArchitecture
   ,rf1SpaceDrives
   ,rf2Astrophysics
   ,rf2SpaceEngineering
   ,rf3Biotechnologies
   ,rf3Medicine
   ,rf3Neuroscience
   ,rf4Communication
   ,rf4Entertainment
   ,rf4MemeticEngineering
   ,rf4Organization
   ,rf5Ecology
   ,rf5Planetology
   ,rf6Automation
   ,rf6Computing
   ,rf6IndustrialTechnics
   ,rf6Materials
   ,rf7MechanicalNanotechnology
   ,rf7MolecularNanotechnology
   ,rf7Nanomaterials
   ,rf8Energy
   ,rf8NuclearPhysics
   ,rf8ParticlesPhysics
   );

{:REFERENCES LIST
   -
}
///<summary>
///
///</summary>
type TFCEdrdsTechnologyLevels=(
   tl01IndustrialAge
   ,tl02RoboticAge
   ,tl03InformationAge
   ,tl04CyberAge
   ,tl05InterplanetaryAge
   ,tl06TranshumanismAge
   ,tl07NanoAge
   ,tl08SingularityAge
   ,tl09InterstellarAge
   ,tl10UnificationAge
   ,tl11EnlightementAge
   ,tl12TranscendenceAge
   ,tl13KardashevAge
   ,tl14GalacticAge
   ,tl15AIgodsAge
   ,tl16DimensionalAge
   ,tl17InfinityAge
   );

//==END PUBLIC ENUM=========================================================================

type TFCRdrdsAdditionalRelatedItem= record
   ARI_token: string[20];
   ARI_type: TFCEdrdsARITypes;
end;

type TFCRdrdsInfluenceProjection= record
   IP_token: string[20];
   IP_type: TFCEdrdsInfluenceProjectionTypes;
end;

{:REFERENCES LIST
   - FCMdF_DBResearchDevelopmentSystem_Load
}
type TFCRdrdsRelatedTechnoscience=  record
   RTS_token: string[20];
   RTS_domain: TFCEdrdsResearchDomains;
   RTS_field: TFCEdrdsResearchFields;
   RTS_isKeyTech: boolean;
   RTS_rawInfluence: integer;
end;

{:REFERENCES LIST
   - FCMdF_DBResearchDevelopmentSystem_Load
}
///<summary>
///
///</summary>
type TFCRdrdsTechnoscience = record
   TS_token: string[20];
   TS_techLevel: TFCEdrdsTechnologyLevels;
   TS_difficulty: integer;
   TS_discoveryThreshold: integer;
   TS_maxRIPpoints: integer;
   TS_relatedTechnosciences: array of TFCRdrdsRelatedTechnoscience;
   TS_additionalRelatedItems: array of TFCRdrdsAdditionalRelatedItem;
   TS_influenceProjections: array of TFCRdrdsInfluenceProjection;
end;

{:REFERENCES LIST
   - FCMdF_DBResearchDevelopmentSystem_Load
}
///<summary>
///
///</summary>
type TFCRdrdsResearchDomain = record
   RD_type: TFCEdrdsResearchDomains;
   RD_fundamentalResearches: array of TFCRdrdsTechnoscience;
   RD_researchFields: array of record
      RF_type: TFCEdrdsResearchFields;
      RF_technosciences: array of TFCRdrdsTechnoscience;
   end;
end;

   TFCDdrdsResearchDatabase = array[0..FCCdiRDSdomainsMax] of TFCRdrdsResearchDomain;

//==END PUBLIC RECORDS======================================================================


var
   //==========databases and other data structures pre-init=================================
   FCDdrdsResearchDatabase: TFCDdrdsResearchDatabase;


//==END PUBLIC VAR==========================================================================

//const
  // FCCdgWeekInTicks=1008;

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
