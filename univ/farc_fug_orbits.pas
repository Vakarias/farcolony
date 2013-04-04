{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - orbits generation unit

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
unit farc_fug_orbits;

interface

uses
   Math;

///<summary>
///   core routine for orbits generation
///   <param="FOGstar">star index #</param>
///</summary>
procedure FCMfO_Generate(const FOGstar: integer);

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_common_func
   ,farc_data_univ
   ,farc_fug_data;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================
procedure FCMfO_Generate(const FOGstar: integer);
{:Purpose: core routine for orbits generation.
    Additions:
}
var
   NumberOfOrbits
   ,FOGorbitProbaGenOrb
   ,OrbitProbabilityMax
   ,OrbitProbabilitMin
   ,OrbitProbaTest: integer;

   LowestMADCompanion: extended;

   isPassedBinaryTrinaryTest: boolean;

   MinimalApproachDistanceCompanion: array[1..2] of double;
begin
   NumberOfOrbits:=0;
   FOGorbitProbaGenOrb:=0;
   OrbitProbabilityMax:=0;
   OrbitProbabilitMin:=0;
   OrbitProbaTest:=0;
   LowestMADCompanion:=0;
   MinimalApproachDistanceCompanion[1]:=100000;
   MinimalApproachDistanceCompanion[2]:=100000;
   isPassedBinaryTrinaryTest:=true;
   {.in case where the orbits generation is randomized}
   if FCRfdStarOrbits[FOGstar]=0
   then
   begin
      {.binary/trinary orbits probability}
      if FCDduStarSystem[0].SS_stars[3].S_token<>''
      then MinimalApproachDistanceCompanion[2]:=FCDduStarSystem[0].SS_stars[3].S_isCompMinApproachDistance;
      if FCDduStarSystem[0].SS_stars[2].S_token<>''
      then
      begin
         MinimalApproachDistanceCompanion[1]:=FCDduStarSystem[0].SS_stars[2].S_isCompMinApproachDistance;
         LowestMADCompanion:=MinValue(MinimalApproachDistanceCompanion);
         if (LowestMADCompanion>=1)
            and (LowestMADCompanion<7)
         then FOGorbitProbaGenOrb:=50
         else if (LowestMADCompanion>=7)
            and (LowestMADCompanion<11)
         then FOGorbitProbaGenOrb:=80
         else if LowestMADCompanion>=11
         then FOGorbitProbaGenOrb:=100;
         case FOGorbitProbaGenOrb of
            0: isPassedBinaryTrinaryTest:=false;
            50,80:
            begin
               OrbitProbaTest:=FCFcF_Random_DoInteger(99)+1;
               if OrbitProbaTest>FOGorbitProbaGenOrb
               then isPassedBinaryTrinaryTest:=false;
            end;
         end;
      end;
      if isPassedBinaryTrinaryTest
      then
      begin
         {.orbits probability + number generation}
         case FCDduStarSystem[0].SS_stars[FOGstar].S_class of
            cB5..cM5:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=10;
            end;
            gF0..gM5:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=20;
            end;
            O5..B9:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=10;
            end;
            A0..A9:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=50;
            end;
            F0..K9:
            begin
               OrbitProbabilitMin:=25;
               OrbitProbabilityMax:=75;
            end;
            M0..M9:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=50;
            end;
            WD0..WD9:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=10;
            end;
            PSR:
            begin
               OrbitProbabilitMin:=5;
               OrbitProbabilityMax:=30;
            end;
            BH:
            begin
               OrbitProbabilitMin:=1;
               OrbitProbabilityMax:=5;
            end;
         end; //==END== case FCDBsSys[0].SS_star[FOGstar].SDB_class of ==//
         OrbitProbaTest:=FCFcF_Random_DoInteger(99)+1;
         if (OrbitProbaTest>=OrbitProbabilitMin)
            and (OrbitProbaTest<=OrbitProbabilityMax)
         then
         begin
            NumberOfOrbits:=round(0.2*OrbitProbaTest);
            SetLength(FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects, NumberOfOrbits+1);
         end;
      end; //==END== if FOGisPassedBiTri ==//
   end //==END== if FUGstarOrb[FOGstar]=0 ==//
   else if FCRfdStarOrbits[FOGstar]>0
   then
   begin
      NumberOfOrbits:=FCRfdStarOrbits[FOGstar];
      SetLength(FCDduStarSystem[0].SS_stars[FOGstar].S_orbitalObjects, NumberOfOrbits+1);
   end;
   {.orbit generation}
   if NumberOfOrbits>0
   then
   begin

   end; //==END== if FOGnbOrb>0 ==//
end;

end.
