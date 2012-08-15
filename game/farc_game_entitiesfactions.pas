{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: factions and entities core unit

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
unit farc_game_entitiesfactions;

interface

///<summary>
///   retrieve the faction DB index # of the given token
///</summary>
///   <param name="FactionToken">faction's token to retrieve</param>
///   <returns>faction DB index #</returns>
function FCFgEF_FactionToken_GetIndex( const FactionToken: string): integer;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_data_game;

//===================================================END OF INIT============================

function FCFgEF_FactionToken_GetIndex( const FactionToken: string): integer;
{:Purpose: retrieve the faction DB index # of the given token.
    Additions:
}
   var
      Count
      ,Max: integer;
begin
   Result:=0;
   Count:=1;
   Max:=length( FCDdgFactions )-1;
   while Count<=Max do
   begin
      if FCDdgFactions[ Count ].F_token=FactionToken then
      begin
         Result:=Count;
         Break;
      end;
      inc( Count );
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

end.
