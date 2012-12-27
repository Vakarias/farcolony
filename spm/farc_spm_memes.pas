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
unit farc_spm_memes;

interface

uses
   farc_data_game;

///<summary>
///   returns the BL modifier regarding the given belief level
///</summary>
///   <param name="BLMGbl">belief level</param>
function FCFgSPMM_BLMod_Get(const BLMGbl: TFCEdgBeliefLevels): extended;

/////<summary>
/////   returns requirements margin modifier value
/////</summary>
//function FCFgSPMM_Margin_Get: integer;

///<summary>
///   test the requirements of a meme, returns false if one of these doesn't pass, true if all the requirements pass
///</summary>
///   <param name="RDTent">entity index #</param>
///   <param name="RDTmeme">meme token</param>
///   <remarks>the margin modifier is stored in the private variable FCVspmmRequirementsMarginMod</remarks>
function FCFgSPMM_Req_DoTest(
   const RDTent: integer;
   const RDTmeme: string
   ): boolean;

///<summary>
///   get max SV values regarding the given belief level
///</summary>
///   <param name="SVRGbl">belief level</param>
function FCFspmM_BeliefLevel_GetMaxSV(const SVRGbl: TFCEdgBeliefLevels): integer;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   process the evolution of a particular meme.
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Meme">SPMi-meme index #</param>
procedure FCMgSPMM_Evolution_Process( const Entity, Meme: integer);

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
   farc_common_func
   ,farc_data_spm
   ,farc_game_colony
   ,farc_game_csm
   ,farc_game_spm
   ,farc_game_spmdata;

var
   FCVspmmRequirementsMarginMod: integer;

//===================================================END OF INIT============================
function FCFgSPMM_BLMod_Get(const BLMGbl: TFCEdgBeliefLevels): extended;
{:Purpose: returns the BL modifier regarding the given belief level.
    Additions:
}
begin
   Result:=0;
   case BLMGbl of
      blFleeting: Result:=0.5;
      blUncommon: Result:=0.7;
      blCommon: Result:=0.9;
      blStrong: Result:=1.1;
      blKnownByAll: Result:=1.3;
   end;
end;

//function FCFgSPMM_Margin_Get: integer;
//{:Purpose: returns requirements margin modifier value
//   Additions:
//}
//begin
//   Result:=FCVspmmRequirementsMarginMod;
//end;

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
   FCVspmmRequirementsMarginMod:=0;
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
                  RDTcolMax:=length(FCDdgEntities[RDTent].E_colonies)-1;
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
                     then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-round( (RDTspmi.SPMI_req[RDTreqCnt].SPMIR_percCol-RDTreqRes)*0.8 );
                  end
                  else if RDTcolMax=0
                  then RDTreqPassed:=false;
               end; //==END== case: dgBuilding ==//
               dgFacData:
               begin
                  case RDTspmi.SPMI_req[RDTreqCnt].SPMIR_datTp of
                     rfdFacLv1:
                     begin
                        if FCDdgEntities[RDTent].E_factionLevel=0
                        then RDTreqPassed:=false;
                     end;
                     rfdFacLv2:
                     begin
                        if FCDdgEntities[RDTent].E_factionLevel<=1
                        then RDTreqPassed:=false;
                     end;
                     rfdFacLv3:
                     begin
                        if FCDdgEntities[RDTent].E_factionLevel<=1
                        then RDTreqPassed:=false
                        else if FCDdgEntities[RDTent].E_factionLevel=2
                        then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-10;
                     end;
                     rfdFacLv4:
                     begin
                        if FCDdgEntities[RDTent].E_factionLevel<=2
                        then RDTreqPassed:=false
                        else if FCDdgEntities[RDTent].E_factionLevel=3
                        then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-10;
                     end;
                     rfdFacLv5:
                     begin
                        if FCDdgEntities[RDTent].E_factionLevel<=3
                        then RDTreqPassed:=false
                        else if FCDdgEntities[RDTent].E_factionLevel=4
                        then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-10;
                     end;
                     rfdFacLv6:
                     begin
                        if FCDdgEntities[RDTent].E_factionLevel<=4
                        then RDTreqPassed:=false
                        else if FCDdgEntities[RDTent].E_factionLevel=5
                        then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-10;
                     end;
                     rfdFacLv7:
                     begin
                        if FCDdgEntities[RDTent].E_factionLevel<=4
                        then RDTreqPassed:=false
                        else if FCDdgEntities[RDTent].E_factionLevel=5
                        then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-20
                        else if FCDdgEntities[RDTent].E_factionLevel=6
                        then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-10;
                     end;
                     rfdFacLv8:
                     begin
                        if FCDdgEntities[RDTent].E_factionLevel<=5
                        then RDTreqPassed:=false
                        else if FCDdgEntities[RDTent].E_factionLevel=6
                        then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-20
                        else if FCDdgEntities[RDTent].E_factionLevel=7
                        then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-10;
                     end;
                     rfdFacLv9:
                     begin
                        if FCDdgEntities[RDTent].E_factionLevel<=6
                        then RDTreqPassed:=false
                        else if FCDdgEntities[RDTent].E_factionLevel=7
                        then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-20
                        else if FCDdgEntities[RDTent].E_factionLevel=8
                        then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-10;
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
                        then FCVspmmRequirementsMarginMod:=FCVspmmRequirementsMarginMod-round( (100- ( ( RDTreqRes*100)/RDTspmi.SPMI_req[RDTreqCnt].SPMIR_datValue ) )*0.8 );
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

function FCFspmM_BeliefLevel_GetMaxSV(const SVRGbl: TFCEdgBeliefLevels): integer;
{:Purpose: get max SV values regarding the given belief level.
    Additions:
}
begin
   Result:=0;
   case SVRGbl of
      blFleeting: Result:=20;

      blUncommon: Result:=40;

      blCommon: Result:=60;

      blStrong: Result:=80;

      blKnownByAll: Result:=100;
   end;
end;
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgSPMM_Evolution_Process( const Entity, Meme: integer);
{:Purpose: process the evolution of a particular meme.
    Additions:
      -2012Dec26- *fix: small bug fix with the SV value.
                  *mod: some adjustments.
      -2012dec18- *add: end of complete rewriting of the code, based on the part taken in the SPM core unit.
                  *fix: kill of the show stopper bug.
      -2012dec18- *add: start of complete rewriting of the code, based on the part taken in the SPM core unit.
}
   var
      FinalBLProgression
      ,MaxSV
      ,Modifier
      ,Modifier1
      ,NewSpreadValue
      ,TotalInfluence
      ,TotalOfColonies: integer;

      BLmod
      ,Calculation: extended;

      isBeliefLevelDecreased
      ,isRequirementsPassed: boolean;

      MemeData: TFCRdgSPMi;

   const
      BaseBLModifier=50;
begin
   FinalBLProgression:=0;
   MaxSV:=0;
   Modifier:=0;
   Modifier1:=0;
   NewSpreadValue:=0;
   TotalInfluence:=0;
   TotalOfColonies:=0;
   BLmod:=0;
   Calculation:=0;
   isBeliefLevelDecreased:=false;
   isRequirementsPassed:=false;
   {.meme requirements}
   isRequirementsPassed:=FCFgSPMM_Req_DoTest( Entity, FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_token );
   if ( not isRequirementsPassed )
      and ( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel>blUnknown ) then
   begin
      dec( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel );
      isBeliefLevelDecreased:=true;
   end
   else if isRequirementsPassed then
   begin
      {.BL progression}
      MemeData:=FCFgSPM_SPMIData_Get( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_token );
      TotalInfluence:=FCFgSPM_SPMiInfluence_Get( MemeData, Entity );
      Modifier:=round( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue*0.2 );
      FinalBLProgression:=BaseBLModifier +FCVspmmRequirementsMarginMod +TotalInfluence+Modifier;
      Modifier1:=FCFcF_Random_DoInteger(99)+1;
      if ( Modifier1<FinalBLProgression*0.8 )
         and ( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel<blKnownByAll )then
      begin
         inc( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel );
         if FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel=blFleeting
         then NewSpreadValue:=1;
      end
      else if ( Modifier1>FinalBLProgression*1.2 )
         and ( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel>blUnknown )
      then
      begin
         dec(FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel);
         isBeliefLevelDecreased:=true;
      end;
   end;
   if not isBeliefLevelDecreased then
   begin
      {.spread value evolution}
      if ( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel=blUnknown )
         and ( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue>0 )
      then NewSpreadValue:=0
      else if FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel>blUnknown then
      begin
         MaxSV:=FCFspmM_BeliefLevel_GetMaxSV( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel );
         if FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue<MaxSV then
         begin
            TotalOfColonies:=length( FCDdgEntities[Entity].E_colonies )-1;
            BLmod:=FCFgSPMM_BLMod_Get( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel );
            Calculation:=( ( ( MaxSV-FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue )-sqrt( TotalOfColonies ) )*BLmod )*0.1;
            if Calculation<=0
            then NewSpreadValue:=FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue
            else if Calculation>0
            then
            begin
               Modifier:=FCFcF_Random_DoInteger(9)+1;
               NewSpreadValue:=FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue+round( Calculation*( Modifier*0.1 ) );
               if NewSpreadValue=0
               then NewSpreadValue:=1;
            end;
            if NewSpreadValue>MaxSV
            then NewSpreadValue:=MaxSV;
         end
         else if FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue>MaxSV
         then NewSpreadValue:=FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue-round( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue*0.25 )
         else NewSpreadValue:=MaxSV;
         if NewSpreadValue<=0
         then NewSpreadValue:=1;
      end;
   end
   else begin
      if FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel=blUnknown
      then NewSpreadValue:=0
      else begin
         MaxSV:=FCFspmM_BeliefLevel_GetMaxSV( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfBeliefLevel );
         if FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue>MaxSV then
         begin
            NewSpreadValue:=FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue-round( FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue*0.25 );
            if NewSpreadValue<=0
            then NewSpreadValue:=1;
         end
         else NewSpreadValue:=FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue;
      end;
   end;
   {.readjust custom effects modifiers and meme's modifiers}
   FCMgSPMM_ModifCustFx_Upd(Entity, Meme, NewSpreadValue);
   FCDdgEntities[Entity].E_spmSettings[Meme].SPMS_iPfSpreadValue:=NewSpreadValue;
end;

procedure FCMgSPMM_ModifCustFx_Upd(
   const MCFUent
         ,MCFUmeme
         ,MCFUnewSV: integer
   );
{:Purpose: update the meme modifiers and custom effects with the updated BL and new SV value.
   Additions:
      -2012Dec26- *rem: removing of useless code.
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
   ,MCFUoldSVmod: extended;

   MCFUspmi: TFCRdgSPMi;

begin
   MCFUoldSV:=FCDdgEntities[MCFUent].E_spmSettings[MCFUmeme].SPMS_iPfSpreadValue;
   MCFUspmi:=FCFgSPM_SPMIData_Get(FCDdgEntities[MCFUent].E_spmSettings[MCFUmeme].SPMS_token);
   {.the old modifiers are reverted}
   MCFUoldSVmod:=MCFUoldSV*0.01;
   MCFUoldBur:=round(MCFUspmi.SPMI_modbur*MCFUoldSVmod);
   MCFUoldCoh:=round(MCFUspmi.SPMI_modCohes*MCFUoldSVmod);
   MCFUoldCorr:=round(MCFUspmi.SPMI_modCorr*MCFUoldSVmod);
   MCFUoldEdu:=round(MCFUspmi.SPMI_modEdu*MCFUoldSVmod);
   MCFUoldHealth:=round(MCFUspmi.SPMI_modHeal*MCFUoldSVmod);
   MCFUoldNat:=round(MCFUspmi.SPMI_modNat*MCFUoldSVmod);
   MCFUoldSec:=round(MCFUspmi.SPMI_modSec*MCFUoldSVmod);
   MCFUoldTens:=round(MCFUspmi.SPMI_modTens*MCFUoldSVmod);
   FCDdgEntities[MCFUent].E_spmMod_Cohesion:=FCDdgEntities[MCFUent].E_spmMod_Cohesion-MCFUoldCoh;
   FCDdgEntities[MCFUent].E_spmMod_Tension:=FCDdgEntities[MCFUent].E_spmMod_Tension-MCFUoldTens;
   FCDdgEntities[MCFUent].E_spmMod_Security:=FCDdgEntities[MCFUent].E_spmMod_Security-MCFUoldSec;
   FCDdgEntities[MCFUent].E_spmMod_Education:=FCDdgEntities[MCFUent].E_spmMod_Education-MCFUoldEdu;
   FCDdgEntities[MCFUent].E_spmMod_Natality:=FCDdgEntities[MCFUent].E_spmMod_Natality-MCFUoldNat;
   FCDdgEntities[MCFUent].E_spmMod_Health:=FCDdgEntities[MCFUent].E_spmMod_Health-MCFUoldHealth;
   FCDdgEntities[MCFUent].E_spmMod_Bureaucracy:=FCDdgEntities[MCFUent].E_spmMod_Bureaucracy-MCFUoldBur;
   FCDdgEntities[MCFUent].E_bureaucracy:=FCDdgEntities[MCFUent].E_bureaucracy-MCFUoldBur;
   FCDdgEntities[MCFUent].E_spmMod_Corruption:=FCDdgEntities[MCFUent].E_spmMod_Corruption-MCFUoldCorr;
   FCDdgEntities[MCFUent].E_corruption:=FCDdgEntities[MCFUent].E_corruption-MCFUoldCorr;
   {.the new modifiers are applied}
   MCFUnewSVmod:=MCFUnewSV*0.01;
   MCFUnewBur:=round(MCFUspmi.SPMI_modbur*MCFUnewSVmod);
   MCFUnewCoh:=round(MCFUspmi.SPMI_modCohes*MCFUnewSVmod);
   MCFUnewCorr:=round(MCFUspmi.SPMI_modCorr*MCFUnewSVmod);
   MCFUnewEdu:=round(MCFUspmi.SPMI_modEdu*MCFUnewSVmod);
   MCFUnewHealth:=round(MCFUspmi.SPMI_modHeal*MCFUnewSVmod);
   MCFUnewNat:=round(MCFUspmi.SPMI_modNat*MCFUnewSVmod);
   MCFUnewSec:=round(MCFUspmi.SPMI_modSec*MCFUnewSVmod);
   MCFUnewTens:=round(MCFUspmi.SPMI_modTens*MCFUnewSVmod);
   FCDdgEntities[MCFUent].E_spmMod_Cohesion:=FCDdgEntities[MCFUent].E_spmMod_Cohesion+MCFUnewCoh;
   FCDdgEntities[MCFUent].E_spmMod_Tension:=FCDdgEntities[MCFUent].E_spmMod_Tension+MCFUnewTens;
   FCDdgEntities[MCFUent].E_spmMod_Security:=FCDdgEntities[MCFUent].E_spmMod_Security+MCFUnewSec;
   FCDdgEntities[MCFUent].E_spmMod_Education:=FCDdgEntities[MCFUent].E_spmMod_Education+MCFUnewEdu;
   FCDdgEntities[MCFUent].E_spmMod_Natality:=FCDdgEntities[MCFUent].E_spmMod_Natality+MCFUnewNat;
   FCDdgEntities[MCFUent].E_spmMod_Health:=FCDdgEntities[MCFUent].E_spmMod_Health+MCFUnewHealth;
   FCDdgEntities[MCFUent].E_spmMod_Bureaucracy:=FCDdgEntities[MCFUent].E_spmMod_Bureaucracy+MCFUnewBur;
   FCDdgEntities[MCFUent].E_bureaucracy:=FCDdgEntities[MCFUent].E_bureaucracy+MCFUnewBur;
   FCDdgEntities[MCFUent].E_spmMod_Corruption:=FCDdgEntities[MCFUent].E_spmMod_Corruption+MCFUnewCorr;
   FCDdgEntities[MCFUent].E_corruption:=FCDdgEntities[MCFUent].E_corruption+MCFUnewCorr;
   MCFUfinalBur:=MCFUnewBur-MCFUoldBur;
   MCFUfinalCoh:=MCFUnewCoh-MCFUoldCoh;
   MCFUfinalCorr:=MCFUnewCorr-MCFUoldCorr;
   MCFUfinalEdu:=MCFUnewEdu-MCFUoldEdu;
   MCFUfinalHealth:=MCFUnewHealth-MCFUoldHealth;
   MCFUfinalNat:=MCFUnewNat-MCFUoldNat;
   MCFUfinalSec:=MCFUnewSec-MCFUoldSec;
   MCFUfinalTens:=MCFUnewTens-MCFUoldTens;
   {.update colonies' data with updated meme modifiers}
   MCFUmax:=length(FCDdgEntities[MCFUent].E_colonies)-1;
   if MCFUmax>0
   then
   begin
      MCFUcnt:=1;
      while MCFUcnt<=MCFUmax do
      begin
         if MCFUfinalCoh<>0
         then FCMgCSM_ColonyData_Upd(
            dCohesion
            ,0
            ,MCFUcnt
            ,MCFUfinalCoh
            ,0
            ,gcsmptNone
            ,false
            );
         if MCFUfinalTens<>0
         then FCMgCSM_ColonyData_Upd(
            dTension
            ,0
            ,MCFUcnt
            ,MCFUfinalTens
            ,0
            ,gcsmptNone
            ,false
            );
         if MCFUfinalSec<>0
         then FCMgCSM_ColonyData_Upd(
            dSecurity
            ,0
            ,MCFUcnt
            ,0
            ,0
            ,gcsmptNone
            ,true
            );
         if MCFUfinalEdu<>0
         then FCMgCSM_ColonyData_Upd(
            dInstruction
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
            dBirthRate
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
            dHealth
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
end;

end.
