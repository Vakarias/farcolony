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
   farc_data_game
   ,farc_data_init
   ,farc_rds_func;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMcC_NonPlayerFaction_Initialize( const Entity: integer );
{:Purpose: initialize the common core for a non-player faction.
    Additions:
}
   var
      Count
      ,Count1
      ,MaxTL: integer;
begin
   Count:=0;
   Count1:=1;
   while Count1 <= FCCdiRDSdomainsMax do
   begin
//      FCDdgEntities[Entity].;
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
      MaxTL:=FCFrdsF_CommonCoreNPFaction_GetRDomTLCap( Count1 );
      inc( Count1 )
   end; //==END== while Count1 <= FCCdiRDSdomainsMax ==//
end;

procedure FCMcC_PlayerFaction_Initialize;
{:Purpose: initialize the common core for the player faction.
    Additions:
}
begin

end;

end.
