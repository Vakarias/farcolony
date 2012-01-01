{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: SPM memes related functions and procedures

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
unit farc_game_spmmemes;

interface

uses
   farc_data_game;

type
   GSPMMret= array[0..2] of integer;

///<summary>
///   returns the BL modifier regarding the given belief level
///</summary>
///   <param name="BLMGbl">belief level</param>
function FCFgSPMM_BLMod_Get(const BLMGbl: TFCEdgBelLvl): double;

///<summary>
///   returns requirements margin modifier value
///</summary>
function FCFgSPMM_Margin_Get: integer;

///<summary>
///   test the requirements of a meme, returns false if one of these doesn't pass, true if all the requirements pass
///</summary>
///   <param name="RDTent">entity index #</param>
///   <param name="RDTmeme">meme token</param>
function FCFgSPMM_Req_DoTest(
   const RDTent: integer;
   const RDTmeme: string
   ): boolean;

///<summary>
///   returns min and max SV values regarding the given belief level
///</summary>
///   <param name="SVRGbl">belief level</param>
function FCFgSPMM_SVRange_Get(const SVRGbl: TFCEdgBelLvl): GSPMMret;

//===========================END FUNCTIONS SECTION==========================================
///<summary>
///   update the meme modifiers and custom effects with the updated BL and new SV value
///</summary>
///   <param name="MCFUent">entity index #</param>
///   <param name="MCFUmeme">meme index #</param>
///   <param name="MCFUnewSV">new SV value to apply</param>
procedure FCMgSPMM_ModifCustFx_Upd(
   const MCFUent
         ,MCFUmeme
         ,MCFUnewSV: integer
   );

implementation

uses
   farc_game_colony
   ,farc_game_csm
   ,farc_game_spm
   ,farc_game_spmdata;

var
   GSPMMmarginMod: integer;

//===================================================END OF INIT============================
function FCFgSPMM_BLMod_Get(const BLMGbl: TFCEdgBelLvl): double;
{:Purpose: returns the BL modifier regarding the given belief level.
    Additions:
}
begin
   Result:=0;
   case BLMGbl of
      dgFleeting: Result:=0.5;
      dgUncommon: Result:=0.7;
      dgCommon: Result:=0.9;
      dgStrong: Result:=1.1;
      dgKbyAll: Result:=1.3;
   end;
end;

function FCFgSPMM_Margin_Get: integer;
{:Purpose: returns requirements margin modifier value
   Additions:
}
begin
   Result:=GSPMMmarginMod;
end;

function FCFgSPMM_Req_DoTest(
   const RDTent: integer;
   const RDTmeme: string
   ): boolean;
{:Purpose: test the requirements of a meme, returns false if one of these doesn't pass, true if all the requirements pass.
    Additions:
      -2010Jan06- *fix: load the result w/ calculated boolean.
}
var
   RDTcolStack
   ,RDTcolCnt
   ,RDTcolMax
   ,RDTinfra
   ,RDTmarginMin
   ,RDTreqCnt
   ,RDTreqMax
   ,RDTreqRes: integer;

   RDTreqPassed: boolean;

   RDTspmi: TFCRdgSPMi;
begin
   {.data initialization}
   GSPMMmarginMod:=0;
   RDTreqCnt:=0;
   RDTreqMax:=0;
   RDTreqPassed:=true;
   RDTspmi:=FCFgSPM_SPMIData_Get(RDTmeme);
   RDTreqMax:=length(RDTspmi.SPMI_req)-1;
   if RDTreqMax>0
   then
   begin
      RDTreqCnt:=1;
      while RDTreqCnt<=RDTreqMax do
      begin
         if RDTreqPassed
         then
         begin
            case RDTspmi.SPMI_req[RDTreqCnt].SPMIR_type of
               dgBuilding:
               begin
                  RDTcolStack:=0;
                  RDTinfra:=0;
                  RDTmarginMin:=0;
                  RDTreqRes:=0;
                  RDTcolCnt:=0;
                  RDTcolMax:=0;
                  RDTcolMax:=length(FCentities[RDTent].E_col)-1;
                  if RDTcolMax>0
                  then
                  begin
                     RDTmarginMin:=round(RDTspmi.SPMI_req[RDTreqCnt].SPMIR_percCol*0.75);
                     RDTcolCnt:=1;
                     while RDTcolCnt<=RDTcolMax do
                     begin
                        RDTinfra:=FCFgC_ColInfra_DReq(
                           gcSpecToken
                           ,RDTent
                           ,RDTcolCnt
                           ,RDTspmi.SPMI_req[RDTreqCnt].SPMIR_infToken
                           );
                        if RDTinfra>0
                        then inc(RDTcolStack);
                        inc(RDTcolCnt);
                     end;
                     RDTreqRes:=round((RDTcolStack*100)/RDTcolMax);
                     if RDTreqRes<RDTmarginMin
                     then RDTreqPassed:=false
                     else if (RDTreqRes>=RDTmarginMin)
                        and (RDTreqRes<RDTspmi.SPMI_req[RDTreqCnt].SPMIR_percCol)
                     then GSPMMmarginMod:=GSPMMmarginMod-round( (RDTspmi.SPMI_req[RDTreqCnt].SPMIR_percCol-RDTreqRes)*0.8 );
                  end
                  else if RDTcolMax=0
                  then RDTreqPassed:=false;
               end; //==END== case: dgBuilding ==//
               dgFacData:
               begin
                  case RDTspmi.SPMI_req[RDTreqCnt].SPMIR_datTp of
                     rfdFacLv1:
                     begin
                        if FCentities[RDTent].E_facLvl=0
                        then RDTreqPassed:=false;
                     end;
                     rfdFacLv2:
                     begin
                        if FCentities[RDTent].E_facLvl<=1
                        then RDTreqPassed:=false;
                     end;
                     rfdFacLv3:
                     begin
                        if FCentities[RDTent].E_facLvl<=1
                        then RDTreqPassed:=false
                        else if FCentities[RDTent].E_facLvl=2
                        then GSPMMmarginMod:=GSPMMmarginMod-10;
                     end;
                     rfdFacLv4:
                     begin
                        if FCentities[RDTent].E_facLvl<=2
                        then RDTreqPassed:=false
                        else if FCentities[RDTent].E_facLvl=3
                        then GSPMMmarginMod:=GSPMMmarginMod-10;
                     end;
                     rfdFacLv5:
                     begin
                        if FCentities[RDTent].E_facLvl<=3
                        then RDTreqPassed:=false
                        else if FCentities[RDTent].E_facLvl=4
                        then GSPMMmarginMod:=GSPMMmarginMod-10;
                     end;
                     rfdFacLv6:
                     begin
                        if FCentities[RDTent].E_facLvl<=4
                        then RDTreqPassed:=false
                        else if FCentities[RDTent].E_facLvl=5
                        then GSPMMmarginMod:=GSPMMmarginMod-10;
                     end;
                     rfdFacLv7:
                     begin
                        if FCentities[RDTent].E_facLvl<=4
                        then RDTreqPassed:=false
                        else if FCentities[RDTent].E_facLvl=5
                        then GSPMMmarginMod:=GSPMMmarginMod-20
                        else if FCentities[RDTent].E_facLvl=6
                        then GSPMMmarginMod:=GSPMMmarginMod-10;
                     end;
                     rfdFacLv8:
                     begin
                        if FCentities[RDTent].E_facLvl<=5
                        then RDTreqPassed:=false
                        else if FCentities[RDTent].E_facLvl=6
                        then GSPMMmarginMod:=GSPMMmarginMod-20
                        else if FCentities[RDTent].E_facLvl=7
                        then GSPMMmarginMod:=GSPMMmarginMod-10;
                     end;
                     rfdFacLv9:
                     begin
                        if FCentities[RDTent].E_facLvl<=6
                        then RDTreqPassed:=false
                        else if FCentities[RDTent].E_facLvl=7
                        then GSPMMmarginMod:=GSPMMmarginMod-20
                        else if FCentities[RDTent].E_facLvl=8
                        then GSPMMmarginMod:=GSPMMmarginMod-10;
                     end;
                     rfdFacStab..rfdEquil:
                     begin
                        case RDTspmi.SPMI_req[RDTreqCnt].SPMIR_datTp of
                           rfdFacStab: RDTreqRes:=FCFgSPMD_GlobalData_Get(gspmdStability, RDTent);
                           rfdInstrLv: RDTreqRes:=FCFgSPMD_GlobalData_Get(gspmdInstruction, RDTent);
                           rfdLifeQ: RDTreqRes:=FCFgSPMD_GlobalData_Get(gspmdLifeQual, RDTent);
                           rfdEquil: RDTreqRes:=FCFgSPMD_GlobalData_Get(gspmdEquilibrium, RDTent);
                        end;
                        RDTmarginMin:=round(RDTspmi.SPMI_req[RDTreqCnt].SPMIR_datValue*0.75);
                        if RDTreqRes<RDTmarginMin
                        then RDTreqPassed:=false
                        else if (RDTreqRes>=RDTmarginMin)
                           and (RDTreqRes<RDTspmi.SPMI_req[RDTreqCnt].SPMIR_datValue)
                        then GSPMMmarginMod:=GSPMMmarginMod-round( (100- ( ( RDTreqRes*100)/RDTspmi.SPMI_req[RDTreqCnt].SPMIR_datValue ) )*0.8 );
                     end;
                  end; //==END== case RDTspmi.SPMI_req[RDTreqCnt].SPMIR_datTp of ==//
               end; //==END== case: dgFacData ==//
               dgTechSci:
               begin
                  {:DEV NOTES: req to implement technosciences database + research status array for entities before to put the code for this case.}
               end;
            end; //==END== case RDTspmi.SPMI_req[RDTreqCnt].SPMIR_type of ==//
         end //==END== if RDTreqPassed ==//
         else if not RDTreqPassed
         then break;
         inc(RDTreqCnt);
      end; //==END== while RDTreqCnt<=RDTreqMax do ==//
   end; //==END== if RDTreqMax>0 ==//
   Result:=RDTreqPassed;
end;

function FCFgSPMM_SVRange_Get(const SVRGbl: TFCEdgBelLvl): GSPMMret;
{:Purpose: returns min and max SV values regarding the given belief level.
    Additions:
}
begin
   Result[1]:=Result[0];
   Result[2]:=Result[0];
   case SVRGbl of
      dgFleeting:
      begin
         Result[1]:=1;
         Result[2]:=20;
      end;
      dgUncommon:
      begin
         Result[1]:=21;
         Result[2]:=40;
      end;
      dgCommon:
      begin
         Result[1]:=41;
         Result[2]:=60;
      end;
      dgStrong:
      begin
         Result[1]:=61;
         Result[2]:=80;
      end;
      dgKbyAll:
      begin
         Result[1]:=81;
         Result[2]:=100;
      end;
   end;
end;
//===========================END FUNCTIONS SECTION==========================================
procedure FCMgSPMM_ModifCustFx_Upd(
   const MCFUent
         ,MCFUmeme
         ,MCFUnewSV: integer
   );
{:Purpose: update the meme modifiers and custom effects with the updated BL and new SV value.
}
var
   MCFUcnt
   ,MCFUfinalBur
   ,MCFUfinalCoh
   ,MCFUfinalCorr
   ,MCFUfinalEdu
   ,MCFUfinalHealth
   ,MCFUfinalNat
   ,MCFUfinalSec
   ,MCFUfinalTens
   ,MCFUmax
   ,MCFUnewBur
   ,MCFUnewCoh
   ,MCFUnewCorr
   ,MCFUnewEdu
   ,MCFUnewHealth
   ,MCFUnewNat
   ,MCFUnewSec
   ,MCFUnewTens
   ,MCFUoldBur
   ,MCFUoldCoh
   ,MCFUoldCorr
   ,MCFUoldEdu
   ,MCFUoldHealth
   ,MCFUoldNat
   ,MCFUoldSec
   ,MCFUoldSV
   ,MCFUoldTens: integer;

   MCFUnewSVmod
   ,MCFUoldSVmod: double;

   MCFUspmi: TFCRdgSPMi;

begin
   MCFUoldSV:=FCentities[MCFUent].E_spm[MCFUmeme].SPMS_sprdVal;
   MCFUspmi:=FCFgSPM_SPMIData_Get(FCentities[MCFUent].E_spm[MCFUmeme].SPMS_token);
   if MCFUoldSV=0
   then
   begin
      MCFUoldSVmod:=0;
      MCFUoldBur:=0;
      MCFUoldCoh:=0;
      MCFUoldCorr:=0;
      MCFUoldEdu:=0;
      MCFUoldHealth:=0;
      MCFUoldNat:=0;
      MCFUoldSec:=0;
      MCFUoldTens:=0;
   end
   else if MCFUoldSV>0
   then
   begin
      MCFUoldSVmod:=MCFUoldSV*0.01;
      MCFUoldBur:=round(MCFUspmi.SPMI_modbur*MCFUoldSVmod);
      MCFUoldCoh:=round(MCFUspmi.SPMI_modCohes*MCFUoldSVmod);
      MCFUoldCorr:=round(MCFUspmi.SPMI_modCorr*MCFUoldSVmod);
      MCFUoldEdu:=round(MCFUspmi.SPMI_modEdu*MCFUoldSVmod);
      MCFUoldHealth:=round(MCFUspmi.SPMI_modHeal*MCFUoldSVmod);
      MCFUoldNat:=round(MCFUspmi.SPMI_modNat*MCFUoldSVmod);
      MCFUoldSec:=round(MCFUspmi.SPMI_modSec*MCFUoldSVmod);
      MCFUoldTens:=round(MCFUspmi.SPMI_modTens*MCFUoldSVmod);
      FCentities[MCFUent].E_spmMcohes:=FCentities[MCFUent].E_spmMcohes-MCFUoldCoh;
      FCentities[MCFUent].E_spmMtens:=FCentities[MCFUent].E_spmMtens-MCFUoldTens;
      FCentities[MCFUent].E_spmMsec:=FCentities[MCFUent].E_spmMsec-MCFUoldSec;
      FCentities[MCFUent].E_spmMedu:=FCentities[MCFUent].E_spmMedu-MCFUoldEdu;
      FCentities[MCFUent].E_spmMnat:=FCentities[MCFUent].E_spmMnat-MCFUoldNat;
      FCentities[MCFUent].E_spmMhealth:=FCentities[MCFUent].E_spmMhealth-MCFUoldHealth;
      FCentities[MCFUent].E_spmMbur:=FCentities[MCFUent].E_spmMbur-MCFUoldBur;
      FCentities[MCFUent].E_bureau:=FCentities[MCFUent].E_bureau-MCFUoldBur;
      FCentities[MCFUent].E_spmMcorr:=FCentities[MCFUent].E_spmMcorr-MCFUoldCorr;
      FCentities[MCFUent].E_corrupt:=FCentities[MCFUent].E_corrupt-MCFUoldCorr;
   end;
   if MCFUnewSV=0
   then
   begin
      MCFUnewSVmod:=0;
      MCFUnewBur:=0;
      MCFUnewCoh:=0;
      MCFUnewCorr:=0;
      MCFUnewEdu:=0;
      MCFUnewHealth:=0;
      MCFUnewNat:=0;
      MCFUnewSec:=0;
      MCFUnewTens:=0;
   end
   else if MCFUnewSV>0
   then
   begin
      MCFUnewSVmod:=MCFUnewSV*0.01;
      MCFUnewBur:=round(MCFUspmi.SPMI_modbur*MCFUnewSVmod);
      MCFUnewCoh:=round(MCFUspmi.SPMI_modCohes*MCFUnewSVmod);
      MCFUnewCorr:=round(MCFUspmi.SPMI_modCorr*MCFUnewSVmod);
      MCFUnewEdu:=round(MCFUspmi.SPMI_modEdu*MCFUnewSVmod);
      MCFUnewHealth:=round(MCFUspmi.SPMI_modHeal*MCFUnewSVmod);
      MCFUnewNat:=round(MCFUspmi.SPMI_modNat*MCFUnewSVmod);
      MCFUnewSec:=round(MCFUspmi.SPMI_modSec*MCFUnewSVmod);
      MCFUnewTens:=round(MCFUspmi.SPMI_modTens*MCFUnewSVmod);
      FCentities[MCFUent].E_spmMcohes:=FCentities[MCFUent].E_spmMcohes+MCFUnewCoh;
      FCentities[MCFUent].E_spmMtens:=FCentities[MCFUent].E_spmMtens+MCFUnewTens;
      FCentities[MCFUent].E_spmMsec:=FCentities[MCFUent].E_spmMsec+MCFUnewSec;
      FCentities[MCFUent].E_spmMedu:=FCentities[MCFUent].E_spmMedu+MCFUnewEdu;
      FCentities[MCFUent].E_spmMnat:=FCentities[MCFUent].E_spmMnat+MCFUnewNat;
      FCentities[MCFUent].E_spmMhealth:=FCentities[MCFUent].E_spmMhealth+MCFUnewHealth;
      FCentities[MCFUent].E_spmMbur:=FCentities[MCFUent].E_spmMbur+MCFUnewBur;
      FCentities[MCFUent].E_bureau:=FCentities[MCFUent].E_bureau+MCFUnewBur;
      FCentities[MCFUent].E_spmMcorr:=FCentities[MCFUent].E_spmMcorr+MCFUnewCorr;
      FCentities[MCFUent].E_corrupt:=FCentities[MCFUent].E_corrupt+MCFUnewCorr;
   end;
   MCFUfinalBur:=MCFUnewBur-MCFUoldBur;
   MCFUfinalCoh:=MCFUnewCoh-MCFUoldCoh;
   MCFUfinalCorr:=MCFUnewCorr-MCFUoldCorr;
   MCFUfinalEdu:=MCFUnewEdu-MCFUoldEdu;
   MCFUfinalHealth:=MCFUnewHealth-MCFUoldHealth;
   MCFUfinalNat:=MCFUnewNat-MCFUoldNat;
   MCFUfinalSec:=MCFUnewSec-MCFUoldSec;
   MCFUfinalTens:=MCFUnewTens-MCFUoldTens;
   {.update colonies' data with updated meme modifiers}
   MCFUmax:=length(FCentities[MCFUent].E_col)-1;
   if MCFUmax>0
   then
   begin
      MCFUcnt:=1;
      while MCFUcnt<=MCFUmax do
      begin
         if MCFUfinalCoh<>0
         then FCMgCSM_ColonyData_Upd(
            gcsmdCohes
            ,0
            ,MCFUcnt
            ,MCFUfinalCoh
            ,0
            ,gcsmptNone
            ,false
            );
         if MCFUfinalTens<>0
         then FCMgCSM_ColonyData_Upd(
            gcsmdTens
            ,0
            ,MCFUcnt
            ,MCFUfinalTens
            ,0
            ,gcsmptNone
            ,false
            );
         if MCFUfinalSec<>0
         then FCMgCSM_ColonyData_Upd(
            gcsmdSec
            ,0
            ,MCFUcnt
            ,0
            ,0
            ,gcsmptNone
            ,true
            );
         if MCFUfinalEdu<>0
         then FCMgCSM_ColonyData_Upd(
            gcsmdEdu
            ,0
            ,MCFUcnt
            ,MCFUfinalEdu
            ,0
            ,gcsmptNone
            ,false
            );
         if (MCFUfinalNat<>0)
            and (MCFUfinalTens=0)
         then FCMgCSM_ColonyData_Upd(
            gcsmdBirthR
            ,0
            ,MCFUcnt
            ,0
            ,0
            ,gcsmptNone
            ,false
            );
         if (MCFUfinalHealth<>0)
            and (MCFUfinalTens=0)
         then FCMgCSM_ColonyData_Upd(
            gcsmdHEAL
            ,0
            ,MCFUcnt
            ,MCFUfinalHealth
            ,0
            ,gcsmptNone
            ,false
            );
         inc(MCFUcnt);
      end; //==END== while MCFUcnt<=PECmax do ==//
   end; //==END== if MCFUmax>0 ==// }
   {.custom effects adjustements}
   {:extreme END}
   FCentities[MCFUent].E_spm[MCFUmeme].SPMS_sprdVal:=MCFUnewSV;
end;

end.
