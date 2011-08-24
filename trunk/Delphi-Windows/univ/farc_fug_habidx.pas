{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - habitability indexes calculations

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
unit farc_fug_habidx;

interface

//===========================END FUNCTIONS SECTION==========================================

implementation

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

//procedure Habitability(HDBOrb, HDBSys: integer);
//{:Purpose: refresh the habitability indices.
//    Additions:
//        -112904-*indice level name integration.
//}
//var
//    H_AtmCnter, H_RadCnter: integer;
//    H_1stGaz: boolean;
//begin
//    with FCScr do begin
//        {.reset the user interface}
//        H_AtmCnter:=0;
//        H_RadCnter:=0;
//        H_1stGaz:=false;
//        {.gravity}
//        try
//            if DBOrbits[HDBOrb].Grav<0.2 then HabGau_Grav.Position:=round((DBOrbits[HDBOrb].Grav+0.1)*100)// 29
//            else if (DBOrbits[HDBOrb].Grav>=0.2)
//                and (DBOrbits[HDBOrb].Grav<0.5) then HabGau_Grav.Position:=round((DBOrbits[HDBOrb].Grav+0.1)*100)// 59
//            else if (DBOrbits[HDBOrb].Grav>=0.5)
//                and (DBOrbits[HDBOrb].Grav<0.8) then HabGau_Grav.Position:=round((DBOrbits[HDBOrb].Grav+0.1)*100)// 89
//            else if (DBOrbits[HDBOrb].Grav>=0.8)
//                and (DBOrbits[HDBOrb].Grav<1.1) then HabGau_Grav.Position:=100-round(((1-DBOrbits[HDBOrb].Grav)*50))//99
//            else if (DBOrbits[HDBOrb].Grav>=1.1)
//                and (DBOrbits[HDBOrb].Grav<1.3) then HabGau_Grav.Position:=69-round((DBOrbits[HDBOrb].Grav-0.95)*100)//59
//            else if (DBOrbits[HDBOrb].Grav>=1.3)
//                and (DBOrbits[HDBOrb].Grav<1.5) then HabGau_Grav.Position:=round(((1/DBOrbits[HDBOrb].Grav)-0.66)*260)//29
//            else if DBOrbits[HDBOrb].Grav>=1.5 then HabGau_Grav.Position:=0;
//        finally
//            HabGauBox_Grav.Caption:=DM_GetStr(SC_UI,'GRAVITY');
//            if HabGau_Grav.Position=0 then HabGauBox_Grav.Caption:=HabGauBox_Grav.Caption+DM_GetStr(SC_UI,'HAB_HOSTILE')
//            else if HabGau_Grav.Position in[1..29] then HabGauBox_Grav.Caption:=HabGauBox_Grav.Caption
//                +DM_GetStr(SC_UI,'HAB_BAD')
//            else if HabGau_Grav.Position in[30..59] then HabGauBox_Grav.Caption:=HabGauBox_Grav.Caption
//                +DM_GetStr(SC_UI,'HAB_MEDIOCRE')
//            else if HabGau_Grav.Position in[60..89] then HabGauBox_Grav.Caption:=HabGauBox_Grav.Caption
//                +DM_GetStr(SC_UI,'HAB_AVG')
//            else if HabGau_Grav.Position>=90 then HabGauBox_Grav.Caption:=HabGauBox_Grav.Caption
//                +DM_GetStr(SC_UI,'HAB_IDEAL');
//        end;
//        {.radiations}
//        try
//            with DBOrbits[HDBOrb] do begin
//              if (DBSystems[HDBSys].Star_Class='PSR')
//                  or (DBSystems[HDBSys].Star_Class='BH') then H_RadCnter:=14
//              else if DBSystems[HDBSys].Star_Class='O' then begin
//                  if AtmPress<1 then H_RadCnter:=13
//                  else if (AtmPress>=1)
//                      and (AtmPress<5) then H_RadCnter:=12
//                  else if (AtmPress>=5)
//                      and (AtmPress<25) then H_RadCnter:=11
//                  else if (AtmPress>=25)
//                      and (AtmPress<125) then H_RadCnter:=10
//                  else if (AtmPress>=125)
//                      and (AtmPress<625) then H_RadCnter:=9
//                  else if (AtmPress>=625)
//                      and (AtmPress<1250) then H_RadCnter:=8
//                  else if (AtmPress>=1250)
//                      and (AtmPress<2500) then H_RadCnter:=7
//                  else if (AtmPress>=2500)
//                      and (AtmPress<5000) then H_RadCnter:=6
//                  else if AtmPress>=5000 then H_RadCnter:=5;
//              end
//              else if (DBSystems[HDBSys].Star_Class='B')
//                  or (DBSystems[HDBSys].Star_Class='cB')
//                  or (DBSystems[HDBSys].Star_Class='WD') then begin
//
//                  if AtmPress<1 then H_RadCnter:=12
//                  else if (AtmPress>=1)
//                      and (AtmPress<5) then H_RadCnter:=11
//                  else if (AtmPress>=5)
//                      and (AtmPress<25) then H_RadCnter:=10
//                  else if (AtmPress>=25)
//                      and (AtmPress<125) then H_RadCnter:=9
//                  else if (AtmPress>=125)
//                      and (AtmPress<625) then H_RadCnter:=8
//                  else if (AtmPress>=625)
//                      and (AtmPress<1250) then H_RadCnter:=7
//                  else if (AtmPress>=1250)
//                      and (AtmPress<2500) then H_RadCnter:=6
//                  else if (AtmPress>=2500)
//                      and (AtmPress<5000) then H_RadCnter:=5
//                  else if AtmPress>=5000 then H_RadCnter:=4;
//              end
//              else if (DBSystems[HDBSys].Star_Class='A')
//                  or (DBSystems[HDBSys].Star_Class='cA') then begin
//
//                  if AtmPress<1 then H_RadCnter:=11
//                  else if (AtmPress>=1)
//                      and (AtmPress<5) then H_RadCnter:=10
//                  else if (AtmPress>=5)
//                      and (AtmPress<25) then H_RadCnter:=9
//                  else if (AtmPress>=25)
//                      and (AtmPress<125) then H_RadCnter:=8
//                  else if (AtmPress>=125)
//                      and (AtmPress<625) then H_RadCnter:=7
//                  else if (AtmPress>=625)
//                      and (AtmPress<1250) then H_RadCnter:=6
//                  else if (AtmPress>=1250)
//                      and (AtmPress<2500) then H_RadCnter:=5
//                  else if (AtmPress>=2500)
//                      and (AtmPress<5000) then H_RadCnter:=4
//                  else if AtmPress>=5000 then H_RadCnter:=3;
//              end
//              else if (DBSystems[HDBSys].Star_Class='F')
//                  or (DBSystems[HDBSys].Star_Class='gF') then begin
//
//                  if AtmPress<1 then H_RadCnter:=10
//                  else if (AtmPress>=1)
//                      and (AtmPress<5) then H_RadCnter:=9
//                  else if (AtmPress>=5)
//                      and (AtmPress<25) then H_RadCnter:=8
//                  else if (AtmPress>=25)
//                      and (AtmPress<125) then H_RadCnter:=7
//                  else if (AtmPress>=125)
//                      and (AtmPress<625) then H_RadCnter:=6
//                  else if (AtmPress>=625)
//                      and (AtmPress<1250) then H_RadCnter:=5
//                  else if (AtmPress>=1250)
//                      and (AtmPress<2500) then H_RadCnter:=4
//                  else if (AtmPress>=2500)
//                      and (AtmPress<5000) then H_RadCnter:=3
//                  else if AtmPress>=5000 then H_RadCnter:=2;
//              end
//              else if DBSystems[HDBSys].Star_Class='G' then begin
//                  if AtmPress<1 then H_RadCnter:=9
//                  else if (AtmPress>=1)
//                      and (AtmPress<5) then H_RadCnter:=8
//                  else if (AtmPress>=5)
//                      and (AtmPress<25) then H_RadCnter:=7
//                  else if (AtmPress>=25)
//                      and (AtmPress<125) then H_RadCnter:=6
//                  else if (AtmPress>=125)
//                      and (AtmPress<625) then H_RadCnter:=5
//                  else if (AtmPress>=625)
//                      and (AtmPress<1250) then H_RadCnter:=4
//                  else if (AtmPress>=1250)
//                      and (AtmPress<2500) then H_RadCnter:=3
//                  else if (AtmPress>=2500)
//                      and (AtmPress<5000) then H_RadCnter:=2
//                  else if AtmPress>=5000 then H_RadCnter:=1;
//              end
//              else if DBSystems[HDBSys].Star_Class='gG' then begin
//                  if AtmPress<1 then H_RadCnter:=8
//                  else if (AtmPress>=1)
//                      and (AtmPress<5) then H_RadCnter:=7
//                  else if (AtmPress>=5)
//                      and (AtmPress<25) then H_RadCnter:=6
//                  else if (AtmPress>=25)
//                      and (AtmPress<125) then H_RadCnter:=5
//                  else if (AtmPress>=125)
//                      and (AtmPress<625) then H_RadCnter:=4
//                  else if (AtmPress>=625)
//                      and (AtmPress<1250) then H_RadCnter:=3
//                  else if (AtmPress>=1250)
//                      and (AtmPress<2500) then H_RadCnter:=2
//                  else if (AtmPress>=2500)
//                      and (AtmPress<5000) then H_RadCnter:=1
//                  else if AtmPress>=5000 then H_RadCnter:=0;
//              end
//              else if (DBSystems[HDBSys].Star_Class='K')
//                  or (DBSystems[HDBSys].Star_Class='cK')
//                  or (DBSystems[HDBSys].Star_Class='gK') then begin
//
//                  if AtmPress<1 then H_RadCnter:=7
//                  else if (AtmPress>=1)
//                      and (AtmPress<5) then H_RadCnter:=6
//                  else if (AtmPress>=5)
//                      and (AtmPress<25) then H_RadCnter:=5
//                  else if (AtmPress>=25)
//                      and (AtmPress<125) then H_RadCnter:=4
//                  else if (AtmPress>=125)
//                      and (AtmPress<625) then H_RadCnter:=3
//                  else if (AtmPress>=625)
//                      and (AtmPress<1250) then H_RadCnter:=2
//                  else if (AtmPress>=1250)
//                      and (AtmPress<2500) then H_RadCnter:=1
//                  else if (AtmPress>=2500)
//                      and (AtmPress<5000) then H_RadCnter:=0
//                  else if DBOrbits[HDBOrb].AtmPress>=5000 then H_RadCnter:=-1;
//              end
//              else if (DBSystems[HDBSys].Star_Class='M')
//                  or (DBSystems[HDBSys].Star_Class='cM')
//                  or (DBSystems[HDBSys].Star_Class='gM') then begin
//
//                  if AtmPress<1 then H_RadCnter:=6
//                  else if (AtmPress>=1)
//                      and (AtmPress<5) then H_RadCnter:=5
//                  else if (AtmPress>=5)
//                      and (AtmPress<25) then H_RadCnter:=4
//                  else if (AtmPress>=25)
//                      and (AtmPress<125) then H_RadCnter:=3
//                  else if (AtmPress>=125)
//                      and (AtmPress<625) then H_RadCnter:=2
//                  else if (AtmPress>=625)
//                      and (AtmPress<1250) then H_RadCnter:=1
//                  else if (AtmPress>=1250)
//                      and (AtmPress<2500) then H_RadCnter:=0
//                  else if (AtmPress>=2500)
//                      and (AtmPress<5000) then H_RadCnter:=-1
//                  else if AtmPress>=5000 then H_RadCnter:=-2;
//              end;
//          end;{with DBOrbits[HDBOrb]}
//          H_RadCnter:=H_RadCnter-(round(DBOrbits[HDBOrb].MagField*10));
//          if H_RadCnter<=1 then HabGau_Rad.Position:=94-round(H_RadCnter*1.5)
//          else if H_RadCnter=2 then HabGau_Rad.Position:=88
//          else if H_RadCnter=3 then HabGau_Rad.Position:=74
//          else if H_RadCnter=4 then HabGau_Rad.Position:=58
//          else if H_RadCnter=5 then HabGau_Rad.Position:=44
//          else if H_RadCnter=6 then HabGau_Rad.Position:=29
//          else if H_RadCnter=7 then HabGau_Rad.Position:=15
//          else if H_RadCnter>=8 then HabGau_Rad.Position:=0;
//        finally
//            HabGauBox_Rad.Caption:=DM_GetStr(SC_UI,'RADIATIONS');
//            if HabGau_Rad.Position=0 then HabGauBox_Rad.Caption:=HabGauBox_Rad.Caption+DM_GetStr(SC_UI,'HAB_HOSTILE')
//            else if HabGau_Rad.Position in[1..29] then HabGauBox_Rad.Caption:=HabGauBox_Rad.Caption
//                +DM_GetStr(SC_UI,'HAB_BAD')
//            else if HabGau_Rad.Position in[30..59] then HabGauBox_Rad.Caption:=HabGauBox_Rad.Caption
//                +DM_GetStr(SC_UI,'HAB_MEDIOCRE')
//            else if HabGau_Rad.Position in[60..89] then HabGauBox_Rad.Caption:=HabGauBox_Rad.Caption
//                +DM_GetStr(SC_UI,'HAB_AVG')
//            else if HabGau_Rad.Position>=90 then HabGauBox_Rad.Caption:=HabGauBox_Rad.Caption
//                +DM_GetStr(SC_UI,'HAB_IDEAL');
//        end;
//        {.atmosphere type}
//        try
//          with DBOrbits[HDBOrb] do begin
//            if AtmPress>0 then begin
//                if Gaz_CH4=1 then H_AtmCnter:=H_AtmCnter-1
//                else if Gaz_CH4=100 then H_AtmCnter:=H_AtmCnter-2;
//                if Gaz_NH3=1 then H_AtmCnter:=H_AtmCnter-2
//                else if Gaz_NH3=100 then H_AtmCnter:=H_AtmCnter-4;
//                if Gaz_Ne=1 then H_AtmCnter:=H_AtmCnter-2
//                else if Gaz_Ne=100 then H_AtmCnter:=H_AtmCnter-4;
//                if Gaz_N2=1 then H_AtmCnter:=H_AtmCnter+0
//                else if Gaz_N2=100 then H_AtmCnter:=H_AtmCnter+1;
//                if Gaz_CO=1 then H_AtmCnter:=H_AtmCnter-1
//                else if Gaz_CO=100 then H_AtmCnter:=H_AtmCnter-3;
//                if Gaz_NO=1 then H_AtmCnter:=H_AtmCnter-2
//                else if Gaz_NO=100 then H_AtmCnter:=H_AtmCnter-4;
//                if Gaz_O2=1 then H_AtmCnter:=H_AtmCnter+1
//                else if Gaz_O2=100 then H_AtmCnter:=H_AtmCnter+3;
//                if Gaz_H2S=1 then H_AtmCnter:=H_AtmCnter-1
//                else if Gaz_H2S=100 then H_AtmCnter:=H_AtmCnter-3;
//                if Gaz_CO2=1 then H_AtmCnter:=H_AtmCnter-1
//                else if Gaz_CO2=100 then H_AtmCnter:=H_AtmCnter-2;
//                if Gaz_NO2=1 then H_AtmCnter:=H_AtmCnter-2
//                else if Gaz_NO2=100 then H_AtmCnter:=H_AtmCnter-4;
//                if Gaz_SO2=1 then H_AtmCnter:=H_AtmCnter-1
//                else if Gaz_SO2=100 then H_AtmCnter:=H_AtmCnter-3;
//                H_1stGaz:=true;
//            end;
//          end;
//          if not H_1stGaz then H_AtmCnter:=-90;
//          if H_AtmCnter>=3 then HabGau_Atm.Position:=60+(H_AtmCnter*10)
//          else if H_AtmCnter=2 then HabGau_Atm.Position:=88
//          else if H_AtmCnter=1 then HabGau_Atm.Position:=74
//          else if H_AtmCnter=0 then HabGau_Atm.Position:=58
//          else if H_AtmCnter=-1 then HabGau_Atm.Position:=44
//          else if H_AtmCnter=-2 then HabGau_Atm.Position:=29
//          else if H_AtmCnter=-3 then HabGau_Atm.Position:=15
//          else if H_AtmCnter<=-4 then HabGau_Atm.Position:=0;
//        finally
//            HabGauBox_Atm.Caption:=DM_GetStr(SC_UI,'ATMOSPH');
//            if HabGau_Atm.Position=0 then HabGauBox_Atm.Caption:=HabGauBox_Atm.Caption+DM_GetStr(SC_UI,'HAB_HOSTILE')
//            else if HabGau_Atm.Position in[1..29] then HabGauBox_Atm.Caption:=HabGauBox_Atm.Caption
//                +DM_GetStr(SC_UI,'HAB_BAD')
//            else if HabGau_Atm.Position in[30..59] then HabGauBox_Atm.Caption:=HabGauBox_Atm.Caption
//                +DM_GetStr(SC_UI,'HAB_MEDIOCRE')
//            else if HabGau_Atm.Position in[60..89] then HabGauBox_Atm.Caption:=HabGauBox_Atm.Caption
//                +DM_GetStr(SC_UI,'HAB_AVG')
//            else if HabGau_Atm.Position>=90 then HabGauBox_Atm.Caption:=HabGauBox_Atm.Caption
//                +DM_GetStr(SC_UI,'HAB_IDEAL');
//        end;
//        {.atmosphere pressure}
//        try
//          {..combi required}
//          if (DBOrbits[HDBOrb].AtmPress<1.013)
//              or (DBOrbits[HDBOrb].AtmPress>=8104) then HabGau_AtmP.Position:=0
//          {..light combi}
//          else if (DBOrbits[HDBOrb].AtmPress>=1.013)
//              and (DBOrbits[HDBOrb].AtmPress<96.235) then HabGau_AtmP.Position:=round(DBOrbits[HDBOrb].AtmPress/3.31)
//          {..respirateur}
//          else if (DBOrbits[HDBOrb].AtmPress>=96.235)
//              and (DBOrbits[HDBOrb].AtmPress<506.5)
//              then HabGau_AtmP.Position:=round((DBOrbits[HDBOrb].AtmPress-96.235)*(29/410.165))+30
//          else if (DBOrbits[HDBOrb].AtmPress>=506.5)
//              and (DBOrbits[HDBOrb].AtmPress<709.1)
//              then HabGau_AtmP.Position:=round((DBOrbits[HDBOrb].AtmPress-506.5)*(29/202.6))+60
//          else if (DBOrbits[HDBOrb].AtmPress>=709.1)
//              and (DBOrbits[HDBOrb].AtmPress<1316.9)
//              then HabGau_AtmP.Position:=round((DBOrbits[HDBOrb].AtmPress-709.1)*(10/607.8))+90
//          else if (DBOrbits[HDBOrb].AtmPress>=1316.9)
//              and (DBOrbits[HDBOrb].AtmPress<1620.8)
//              then HabGau_AtmP.Position:=89-round((DBOrbits[HDBOrb].AtmPress-1316.9)*(29/303.9))
//          {..respirateur}
//          else if (DBOrbits[HDBOrb].AtmPress>=1620.8)
//              and (DBOrbits[HDBOrb].AtmPress<2026)
//              then HabGau_AtmP.Position:=59-round((DBOrbits[HDBOrb].AtmPress-1620.8)*(29/405.2))
//          else if (DBOrbits[HDBOrb].AtmPress>=2026)
//              and (DBOrbits[HDBOrb].AtmPress<8104)
//              then HabGau_AtmP.Position:=29-round((DBOrbits[HDBOrb].AtmPress-2026)*(29/6078))
//          else if DBOrbits[HDBOrb].AtmPress>=8104 then HabGau_AtmP.Position:=0;
//        finally
//            HabGauBox_AtmP.Caption:=DM_GetStr(SC_UI,'ATMOSPH_PRESS');
//            if HabGau_AtmP.Position=0 then HabGauBox_AtmP.Caption:=HabGauBox_AtmP.Caption+DM_GetStr(SC_UI,'HAB_HOSTILE')
//            else if HabGau_AtmP.Position in[1..29] then HabGauBox_AtmP.Caption:=HabGauBox_AtmP.Caption
//                +DM_GetStr(SC_UI,'HAB_BAD')
//            else if HabGau_AtmP.Position in[30..59] then HabGauBox_AtmP.Caption:=HabGauBox_AtmP.Caption
//                +DM_GetStr(SC_UI,'HAB_MEDIOCRE')
//            else if HabGau_AtmP.Position in[60..89] then HabGauBox_AtmP.Caption:=HabGauBox_AtmP.Caption
//                +DM_GetStr(SC_UI,'HAB_AVG')
//            else if HabGau_AtmP.Position>=90 then HabGauBox_AtmP.Caption:=HabGauBox_AtmP.Caption
//                +DM_GetStr(SC_UI,'HAB_IDEAL');
//        end;
//    end;{with FCScr}
//end;

end.
