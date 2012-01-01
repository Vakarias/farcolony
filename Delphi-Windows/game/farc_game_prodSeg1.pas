{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: production phase - segment 1 energy

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
unit farc_game_prodSeg1;

interface

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   energy equilibrium rule
///</summary>
///   <param name="EERPisShortageMode">true= in energy shortage mode, false= in energy excedent mode</param>
///   <param name="EERPent">entity index #</param>
///   <param name="EERPcol">colony index #</param>
procedure FCMgSP1_EnergyEqRule_Process(
   const EERPisShortageMode: boolean;
   const EERPent
         ,EERPcol: integer
   );

///<summary>
///   segment 1 (energy) processing
///</summary>
///   <param name="ESPent">entity index #</param>
///   <param name="ESPcol">colony index #</param>
procedure FCMgPS1_EnergySegment_Process(
   const ESPent
         ,ESPcol: integer
   );

implementation

uses
   farc_data_game
   ,farc_data_infrprod
   ,farc_game_infra
   ,farc_game_infrapower;

   type GPS1infraList=record
      IL_settlement: integer;
      IL_index: integer;
   end;

var
   GPS1infraHindex: integer;
   GPS1infraOindex: integer;
   GPS1infraPindex: integer;

   GPS1infraHousing: array of GPS1infraList;
   GPS1infraOther: array of GPS1infraList;
   GPS1infraProduction: array of GPS1infraList;

//===================================================END OF INIT============================

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgSP1_EnergyEqRule_LoadList(
   const EERLLisShortageMode: boolean;
   const EERLLent
         ,EERLLcol: integer
   );
{:Purpose: load the three infrastructure lists
   -2011Dec12- *fix: correctly initialize the GPS1infraProduction array.
}
   var
      EERLLinfraCnt
      ,EERLLinfraMax
      ,EERLLsetCnt
      ,EERLLsetMax: integer;
begin
   SetLength( GPS1infraHousing, 1 );
   GPS1infraHindex:=0;
   SetLength( GPS1infraOther, 1 );
   GPS1infraOindex:=0;
   SetLength( GPS1infraProduction, 1 );
   GPS1infraPindex:=0;
   EERLLsetMax:=Length( FCentities[EERLLent].E_col[EERLLcol].COL_settlements )-1;
   EERLLsetCnt:=1;
   while EERLLSetCnt<=EERLLSetMax do
   begin
      EERLLinfraMax:=Length( FCentities[EERLLent].E_col[EERLLcol].COL_settlements[EERLLSetCnt].CS_infra )-1;
      EERLLinfraCnt:=1;
      while EERLLinfraCnt<=EERLLinfraMax do
      begin
         if  ( ( EERLLisShortageMode ) and ( FCentities[EERLLent].E_col[EERLLcol].COL_settlements[EERLLSetCnt].CS_infra[EERLLinfraCnt].CI_status=istOperational ) )
            or ( ( not EERLLisShortageMode ) and ( FCentities[EERLLent].E_col[EERLLcol].COL_settlements[EERLLSetCnt].CS_infra[EERLLinfraCnt].CI_status=istDisabledByEE ) ) then
         begin
            if FCentities[EERLLent].E_col[EERLLcol].COL_settlements[EERLLSetCnt].CS_infra[EERLLinfraCnt].CI_function=fProduction
            then
            begin
               inc(GPS1infraPindex);
               SetLength( GPS1infraProduction, GPS1infraPindex+1 );
               GPS1infraProduction[GPS1infraPindex].IL_settlement:=EERLLSetCnt;
               GPS1infraProduction[GPS1infraPindex].IL_index:=EERLLinfraCnt;
            end
            else if FCentities[EERLLent].E_col[EERLLcol].COL_settlements[EERLLSetCnt].CS_infra[EERLLinfraCnt].CI_function=fHousing
            then
            begin
               inc(GPS1infraHindex);
               SetLength( GPS1infraHousing, GPS1infraHindex+1 );
               GPS1infraHousing[GPS1infraHindex].IL_settlement:=EERLLSetCnt;
               GPS1infraHousing[GPS1infraHindex].IL_index:=EERLLinfraCnt;
            end
            else if FCentities[EERLLent].E_col[EERLLcol].COL_settlements[EERLLSetCnt].CS_infra[EERLLinfraCnt].CI_function<>fEnergy
            then
            begin
               inc(GPS1infraOindex);
               SetLength( GPS1infraOther, GPS1infraOindex+1 );
               GPS1infraOther[GPS1infraOindex].IL_settlement:=EERLLSetCnt;
               GPS1infraOther[GPS1infraOindex].IL_index:=EERLLinfraCnt;
            end;
         end;
         inc(EERLLinfraCnt);
      end; //==END== while EERLLinfraCnt<=EERLLinfraMax do ==//
      inc( EERLLSetCnt );
   end; //==END== while EERLLSetCnt<=EERLLSetMax do ==//
end;

procedure FCMgSP1_EnergyEqRule_Process(
   const EERPisShortageMode: boolean;
   const EERPent
         ,EERPcol: integer
   );
{:Purpose: energy equilibrium rule, return any excedent.
    Additions:
      -2011Aug18- *add: surplus of energy - full completion with addition of the enabling/disabling tests.
      -2011Aug17- *add: complete the case: surplus of energy.
      -2011Aug16- *add: complete the case: surplus of energy.
                  *mod: infrastructures list and indexes are moved to unit's private variables declaration.
                  *mod: the lists loading is moved to a private function.
}
   type EERPinfraList=record
      IL_settlement: integer;
      IL_index: integer;
   end;

   var
      EERPinfraCnt
      ,EERPinfraMax: integer;

      EERPdone: boolean;

begin
   SetLength( GPS1infraHousing, 0 );
   GPS1infraHousing:=nil;
   SetLength( GPS1infraOther, 0 );
   GPS1infraHousing:=nil;
   SetLength( GPS1infraProduction, 0 );
   GPS1infraHousing:=nil;
   EERPdone:=false;
   FCMgSP1_EnergyEqRule_LoadList(
      EERPisShortageMode
      ,EERPent
      ,EERPcol
      );
   if not EERPisShortageMode
   then
   begin
      if GPS1infraHindex>0
      then
      begin
         EERPinfraMax:=GPS1infraHindex;
         EERPinfraCnt:=1;
         while  ( not EERPdone )
            and ( EERPinfraCnt<=EERPinfraMax ) do
         begin
             FCMgInf_Enabling_Process(
               EERPent
               ,EERPcol
               ,GPS1infraHousing[EERPinfraCnt].IL_settlement
               ,GPS1infraHousing[EERPinfraCnt].IL_index
               );
            if FCentities[EERPent].E_col[EERPcol].COL_csmENgen-FCentities[EERPent].E_col[EERPcol].COL_csmENcons<0
            then
            begin
               FCMgInf_Disabling_Process(
                  EERPent
                  ,EERPcol
                  ,GPS1infraHousing[EERPinfraCnt].IL_settlement
                  ,GPS1infraHousing[EERPinfraCnt].IL_index
                  ,true
                  );
               EERPdone:=true;
               Break;
            end
            else if FCentities[EERPent].E_col[EERPcol].COL_csmENgen-FCentities[EERPent].E_col[EERPcol].COL_csmENcons=0
            then
            begin
               EERPdone:=true;
               Break;
            end;
            inc(EERPinfraCnt);
         end;
      end;
      if ( not EERPdone )
         and (GPS1infraPindex>0)
      then
      begin
         EERPinfraMax:=GPS1infraPindex;
         EERPinfraCnt:=1;
         while  ( not EERPdone )
            and ( EERPinfraCnt<=EERPinfraMax ) do
         begin
            FCMgInf_Enabling_Process(
               EERPent
               ,EERPcol
               ,GPS1infraProduction[EERPinfraCnt].IL_settlement
               ,GPS1infraProduction[EERPinfraCnt].IL_index
               );
            if FCentities[EERPent].E_col[EERPcol].COL_csmENgen-FCentities[EERPent].E_col[EERPcol].COL_csmENcons<0
            then
            begin
               FCMgInf_Disabling_Process(
                  EERPent
                  ,EERPcol
                  ,GPS1infraProduction[EERPinfraCnt].IL_settlement
                  ,GPS1infraProduction[EERPinfraCnt].IL_index
                  ,true
                  );
               EERPdone:=true;
               Break;
            end
            else if FCentities[EERPent].E_col[EERPcol].COL_csmENgen-FCentities[EERPent].E_col[EERPcol].COL_csmENcons=0
            then
            begin
               EERPdone:=true;
               Break;
            end;
            inc(EERPinfraCnt);
         end;
      end;
      if ( not EERPdone )
         and ( GPS1infraOindex>0 ) then
      begin
         EERPinfraMax:=GPS1infraOindex;
         EERPinfraCnt:=1;
         while  ( not EERPdone )
            and ( EERPinfraCnt<=EERPinfraMax ) do
         begin
            FCMgInf_Enabling_Process(
               EERPent
               ,EERPcol
               ,GPS1infraOther[EERPinfraCnt].IL_settlement
               ,GPS1infraOther[EERPinfraCnt].IL_index
               );
            if FCentities[EERPent].E_col[EERPcol].COL_csmENgen-FCentities[EERPent].E_col[EERPcol].COL_csmENcons<0
            then
            begin
               FCMgInf_Disabling_Process(
                  EERPent
                  ,EERPcol
                  ,GPS1infraOther[EERPinfraCnt].IL_settlement
                  ,GPS1infraOther[EERPinfraCnt].IL_index
                  ,true
                  );
               EERPdone:=true;
               Break;
            end
            else if FCentities[EERPent].E_col[EERPcol].COL_csmENgen-FCentities[EERPent].E_col[EERPcol].COL_csmENcons=0
            then
            begin
               EERPdone:=true;
               Break;
            end;
            inc(EERPinfraCnt);
         end;
      end;
   end //==END== if not EERPisShortageMode ==//
   else
   begin
      if GPS1infraOindex>0 then
      begin
         EERPinfraMax:=GPS1infraOindex;
         EERPinfraCnt:=1;
         while  ( not EERPdone )
            and ( EERPinfraCnt<=EERPinfraMax ) do
         begin
            FCMgInf_Disabling_Process(
               EERPent
               ,EERPcol
               ,GPS1infraOther[EERPinfraCnt].IL_settlement
               ,GPS1infraOther[EERPinfraCnt].IL_index
               ,true
               );
            if FCentities[EERPent].E_col[EERPcol].COL_csmENcons-FCentities[EERPent].E_col[EERPcol].COL_csmENgen<=0
            then
            begin
               EERPdone:=true;
               Break;
            end;
            inc(EERPinfraCnt);
         end;
      end;
      if ( not EERPdone )
         and (GPS1infraPindex>0)
      then
      begin
         EERPinfraMax:=GPS1infraPindex;
         EERPinfraCnt:=1;
         while  ( not EERPdone )
            and ( EERPinfraCnt<=EERPinfraMax ) do
         begin
            FCMgInf_Disabling_Process(
               EERPent
               ,EERPcol
               ,GPS1infraProduction[EERPinfraCnt].IL_settlement
               ,GPS1infraProduction[EERPinfraCnt].IL_index
               ,true
               );
            if FCentities[EERPent].E_col[EERPcol].COL_csmENcons-FCentities[EERPent].E_col[EERPcol].COL_csmENgen<=0
            then
            begin
               EERPdone:=true;
               Break;
            end;
            inc(EERPinfraCnt);
         end;
      end;
      if ( not EERPdone )
         and (GPS1infraHindex>0)
      then
      begin
         EERPinfraMax:=GPS1infraHindex;
         EERPinfraCnt:=1;
         while  ( not EERPdone )
            and ( EERPinfraCnt<=EERPinfraMax ) do
         begin
            FCMgInf_Disabling_Process(
               EERPent
               ,EERPcol
               ,GPS1infraHousing[EERPinfraCnt].IL_settlement
               ,GPS1infraHousing[EERPinfraCnt].IL_index
               ,true
               );
            if FCentities[EERPent].E_col[EERPcol].COL_csmENcons-FCentities[EERPent].E_col[EERPcol].COL_csmENgen<=0
            then
            begin
               EERPdone:=true;
               Break;
            end;
            inc(EERPinfraCnt);
         end;
      end;
   end; //==END== else of if not EERPisShortageMode ==//
end;

procedure FCMgPS1_EnergySegment_Process(
   const ESPent
         ,ESPcol: integer
   );
{:Purpose: segment 1 (energy) processing.
    Additions:
      -2011Aug18- *rem: ESPenergyToEquil is removed since to calculate the value is useless with the last energy equuilibrium rule change.
                  *add: for the second case of shortage, the current energy reserve is now depleted to 0.
                  *add: complete the rest of the energy segment by complete the code in case of energy surplus.
      -2011Jul25- *add: segment WIP.
}
begin
   if FCentities[ESPent].E_col[ESPcol].COL_csmENgen<FCentities[ESPent].E_col[ESPcol].COL_csmENcons
   then
   begin
      if (FCentities[ESPent].E_col[ESPcol].COL_csmENstorCurr>0)
         and (FCentities[ESPent].E_col[ESPcol].COL_csmENgen+FCentities[ESPent].E_col[ESPcol].COL_csmENstorCurr>=FCentities[ESPent].E_col[ESPcol].COL_csmENcons)
      then FCMgIP_CSMEnergy_Update(
         ESPent
         ,ESPcol
         ,false
         ,0
         ,0
         ,-(FCentities[ESPent].E_col[ESPcol].COL_csmENcons-FCentities[ESPent].E_col[ESPcol].COL_csmENgen)
         ,0
         )
      else if (FCentities[ESPent].E_col[ESPcol].COL_csmENstorCurr>0)
         and (FCentities[ESPent].E_col[ESPcol].COL_csmENgen+FCentities[ESPent].E_col[ESPcol].COL_csmENstorCurr<FCentities[ESPent].E_col[ESPcol].COL_csmENcons)
      then
      begin
         FCMgIP_CSMEnergy_Update(
            ESPent
            ,ESPcol
            ,false
            ,0
            ,0
            ,-(FCentities[ESPent].E_col[ESPcol].COL_csmENstorCurr)
            ,0
            );
         FCMgSP1_EnergyEqRule_Process(
            true
            ,ESPent
            ,ESPcol
            );
      end
      else if FCentities[ESPent].E_col[ESPcol].COL_csmENstorCurr=0
      then FCMgSP1_EnergyEqRule_Process(
         true
         ,ESPent
         ,ESPcol
         );
   end //==END== if FCentities[ESPent].E_col[ESPcol].COL_csmENgen<FCentities[ESPent].E_col[ESPcol].COL_csmENcons ==//
//   else if FCentities[ESPent].E_col[ESPcol].COL_csmENgen=FCentities[ESPent].E_col[ESPcol].COL_csmENcons
//   then pass to production segment 2
   else if FCentities[ESPent].E_col[ESPcol].COL_csmENgen>FCentities[ESPent].E_col[ESPcol].COL_csmENcons
   then FCMgSP1_EnergyEqRule_Process(
      false
      ,ESPent
      ,ESPcol
      );
end;

end.
