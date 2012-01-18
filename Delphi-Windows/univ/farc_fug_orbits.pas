{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: orbits generation unit

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
   ,farc_data_univ;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================
procedure FCMfO_Generate(const FOGstar: integer);
{:Purpose: core routine for orbits generation.
    Additions:
}
var
   FOGnbOrb
   ,FOGorbitProbaGenOrb
   ,OrbitProbaRngMax
   ,OrbitProbaRngMin
   ,OrbitProbaTest: integer;

   FOGdapmMin: extended;

   FOGisPassedBiTri: boolean;

   FOGdapmSC: array[1..2] of double;
begin
   FOGnbOrb:=0;
   FOGorbitProbaGenOrb:=0;
   OrbitProbaRngMax:=0;
   OrbitProbaRngMin:=0;
   OrbitProbaTest:=0;
   FOGdapmMin:=0;
   FOGdapmSC[1]:=100000;
   FOGdapmSC[2]:=100000;
   FOGisPassedBiTri:=true;
   if FUGstarOrb[FOGstar]=0
   then
   begin
      {.binary/trinary orbits probability}
      if FCDBsSys[0].SS_star[3].SDB_token<>''
      then FOGdapmSC[2]:=FCDBsSys[0].SS_star[3].SDB_minApD;
      if FCDBsSys[0].SS_star[2].SDB_token<>''
      then
      begin
         FOGdapmSC[1]:=FCDBsSys[0].SS_star[2].SDB_minApD;
         FOGdapmMin:=MinValue(FOGdapmSC);
         if (FOGdapmMin>=1)
            and (FOGdapmMin<7)
         then FOGorbitProbaGenOrb:=50
         else if (FOGdapmMin>=7)
            and (FOGdapmMin<11)
         then FOGorbitProbaGenOrb:=80
         else if FOGdapmMin>=11
         then FOGorbitProbaGenOrb:=100;
         case FOGorbitProbaGenOrb of
            0: FOGisPassedBiTri:=false;
            50,80:
            begin
               OrbitProbaTest:=FCFcFunc_Rand_Int(99)+1;
               if OrbitProbaTest>FOGorbitProbaGenOrb
               then FOGisPassedBiTri:=false;
            end;
         end;
      end;
      if FOGisPassedBiTri
      then
      begin
         {.orbits probability + number generation}
         case FCDBsSys[0].SS_star[FOGstar].SDB_class of
            cB5..cM5:
            begin
               OrbitProbaRngMin:=5;
               OrbitProbaRngMax:=10;
            end;
            gF0..gM5:
            begin
               OrbitProbaRngMin:=5;
               OrbitProbaRngMax:=20;
            end;
            O5..B9:
            begin
               OrbitProbaRngMin:=5;
               OrbitProbaRngMax:=10;
            end;
            A0..A9:
            begin
               OrbitProbaRngMin:=5;
               OrbitProbaRngMax:=50;
            end;
            F0..K9:
            begin
               OrbitProbaRngMin:=25;
               OrbitProbaRngMax:=75;
            end;
            M0..M9:
            begin
               OrbitProbaRngMin:=5;
               OrbitProbaRngMax:=50;
            end;
            WD0..WD9:
            begin
               OrbitProbaRngMin:=5;
               OrbitProbaRngMax:=10;
            end;
            PSR:
            begin
               OrbitProbaRngMin:=5;
               OrbitProbaRngMax:=30;
            end;
            BH:
            begin
               OrbitProbaRngMin:=1;
               OrbitProbaRngMax:=5;
            end;
         end; //==END== case FCDBsSys[0].SS_star[FOGstar].SDB_class of ==//
         OrbitProbaTest:=FCFcFunc_Rand_Int(99)+1;
         if (OrbitProbaTest>=OrbitProbaRngMin)
            and (OrbitProbaTest<=OrbitProbaRngMax)
         then
         begin
            FOGnbOrb:=round(0.2*OrbitProbaTest);
            SetLength(FCDBsSys[0].SS_star[FOGstar].SDB_obobj, FOGnbOrb+1);
         end;
      end; //==END== if FOGisPassedBiTri ==//
   end //==END== if FUGstarOrb[FOGstar]=0 ==//
   else if FUGstarOrb[FOGstar]>0
   then
   begin
      FOGnbOrb:=FUGstarOrb[FOGstar];
      SetLength(FCDBsSys[0].SS_star[FOGstar].SDB_obobj, FOGnbOrb+1);
   end;
   {.orbit generation}
   if FOGnbOrb>0
   then
   begin

   end; //==END== if FOGnbOrb>0 ==//
end;

end.
