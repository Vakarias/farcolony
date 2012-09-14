{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: SocioPolitical Matrix (SPM) - core unit

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
unit farc_game_spm;

interface

uses
   SysUtils

   ,farc_data_spm;

type TFCEgspmData=(
   gspmAccProbability
   ,gspmInfl
   ,gspmMargMod
   );

type TFCEgspmPolRslt=(
   gspmResMassRjct
   ,gspmResReject
   ,gspmResFifFifty
   ,gspmResAccept
   );

///<summary>
///   return the token of a given SPM area
///</summary>
function FCFgSPM_Area_GetString(const SPMarea: TFCEdgSPMarea): string;

///<summary>
///   return the private calculated enforcement data
///</summary>
///   <param name="CDGdata">type of data to retrieve</param>
function FCFgSPM_EnforcData_Get(const CDGdata: TFCEgspmData): integer;

///<summary>
///   return the state of the unique data of the current policy to enforce
///</summary>
function FCFgSPM_EnforcPol_GetUnique: boolean;

///<summary>
///   return the SPM area of the current policy to enforce
///</summary>
function FCFgSPM_EnforcPol_GetArea: TFCEdgSPMarea;

///<summary>
///   get the system token according to the gvt/economic/medical care/spiritual system chosen
///</summary>
///   <param name="GEMSSGTent">entity #</param>
///   <param name="GEMSSGTarea">area amongs: ADMIN, ECON, MEDCA and SPI</param>
function FCFgSPM_GvtEconMedcaSpiSystems_GetToken(
   const GEMSSGTent: integer;
   const GEMSSGTarea: TFCEdgSPMarea
   ): string;

///<summary>
///   get the system index # according to the gvt/economic/medical care/spiritual system chosen
///</summary>
///   <param name="GEMSSGIent">entity #</param>
///   <param name="GEMSSGIarea">area amongs: ADMIN, ECON, MEDCA and SPI</param>
function FCFgSPM_GvtEconMedcaSpiSystems_GetIdx(
   const GEMSSGIent: integer;
   const GEMSSGIarea: TFCEdgSPMarea
   ): integer;

///<summary>
///   retrieve the <token> SPMi data
///</summary>
///   <param name="SPMIGtoken">SPMi token</param>
///   <param name="SPMIGloadIndex">load the index in GSPMitmIdx</param>
function FCFgSPM_SPMIData_Get(
   const SPMIDGtoken: string;
   const SPMIDGloadIndex: boolean=false
   ): TFCRdgSPMi;

///<summary>
///   calculate the influence factor for a policy to set or a meme evolution regarding how is set the SPM of a given entity
///</summary>
///   <param name="SPMIIGspmi">policy/meme to set/evolve</param>
///   <param name="SPMIIGent">entity index #</param>
function FCFgSPM_SPMiInfluence_Get(
   const SPMIIGspmi: TFCRdgSPMi;
   const SPMIIGent: integer
   ): integer;

///<summary>
///   retrieve the FS modifier, regarding the entity, for policy processing and return the modifier
///</summary>
///   <param name="PGFSMent">entity #</param>
function FCFgSPM_Policy_GetFSMod(const PGFSMent: integer): integer;

///<summary>
///   preprocess a policy setup, return false if the faction doesn't meet the policy's requirements
///</summary>
///   <param name="PPent">entity index #</param>
///   <param name="PPpolicy">policy token string</param>
function FCFgSPM_PolicyEnf_Preproc(
   const PPent: integer;
   const PPpolicy: string
   ): boolean;

///<summary>
///   preprocess a policy setup, return false if the faction doesn't meet the policy's requirements.
///   doesn't update the UI and don't update the private SPM variables, it's only for requirement purposes
///</summary>
///   <param name="PPent">entity index #</param>
///   <param name="PPpolicy">policy token string</param>
function FCFgSPM_PolicyEnf_PreprocNoUI(
   const PPent: integer;
   const PPpolicy: string
   ): boolean;

///<summary>
///   process the policy enforcement test and retrieve the result.
///</summary>
///   <param name="PPDTsimulVal">[optional] if >0 : launch a test simulation w/ the PPDTsimulVal</param>
function FCFgSPM_PolicyProc_DoTest(PPDTsimulVal: integer): TFCEgspmPolRslt;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   SPM phase processing
///</summary>
procedure FCMgSPM_Phase_Proc;

///<summary>
///   end enforcement process: confirm policy
///</summary>
procedure FCMgSPM_PolicyEnf_Confirm;

///<summary>
///   process the enforcement of a policy
///</summary>
///   <param name="PEPent">entity index #</param>
procedure FCMgSPM_PolicyEnf_Process(const PEPent: integer);

///<summary>
///   end enforcement process: retire policy
///</summary>
procedure FCMgSPM_PolicyEnf_Retire;

///<summary>
///   retire a chosen SPMi, and update the centralized modifiers and/or entity's data
///</summary>
///   <param name="SPMIRent">entity #</param>
///   <param name="SPMIRspmi">SPMi #</param>
procedure FCMgSPM_SPMI_Retire(
   const SPMIRent
         ,SPMIRidx: integer
   );

///<summary>
///   set a chosen SPMi, and update the centralized modifiers and/or entity's data
///</summary>
///   <param name="SPMISent">entity #</param>
///   <param name="SPMISspmi">SPMi #</param>
///   <param name="SPMIScsmUpd">true= update dependent CSM data too</param>
procedure FCMgSPM_SPMI_Set(
   const SPMISent
         , SPMISspmi: integer;
   const SPMIScsmUpd: boolean
   );

implementation

uses
   farc_common_func
   ,farc_data_html
   ,farc_data_init
   ,farc_data_infrprod
   ,farc_data_game
   ,farc_data_textfiles
   ,farc_game_colony
   ,farc_game_csm
   ,farc_game_csmevents
   ,farc_game_spmdata
   ,farc_game_spmmemes
   ,farc_main
   ,farc_ui_msges
   ,farc_ui_umi
   ,farc_win_debug;

var
   {.calculated acceptance probability}
   GSPMap
   ,GSPMcohPen
   ,GSPMcohPenRej
   ,GSPMduration
   ,GSPMfap_x
   ,GSPMfsMod
   ,GSPMinfluence
   ,GSPMitmIdx
   ,GSPMmarginMod
   ,GSPMmodMax: integer;

   GSPMspmi: TFCRdgSPMi;

   GSPMrslt: TFCEgspmPolRslt;

//===================================================END OF INIT============================

function FCFgSPM_Area_GetString(const SPMarea: TFCEdgSPMarea): string;
{:Purpose: return the token of a given SPM area.
}
begin
   result:='';
   case SPMarea of
      dgADMIN: result:='SPMiAreaADMIN';
      dgECON: result:='SPMiAreaECON';
      dgMEDCA: result:='SPMiAreaMEDCA';
      dgSOC: result:='SPMiAreaSOC';
      dgSPOL: result:='SPMiAreaSPOL';
      dgSPI: result:='SPMiAreaSPI';
   end;
end;

function FCFgSPM_EnforcData_Get(const CDGdata: TFCEgspmData): integer;
{:Purpose: return the private calculated enforcement data.
    Additions:
      -2012Sep13- *mod: change the result format to integer.
      -2010Dec07- *add: influence.
}
begin
   Result:=0;
   case CDGdata of
      gspmAccProbability: Result:=GSPMap;
      gspmInfl: Result:=GSPMinfluence;
      gspmMargMod: Result:=GSPMmarginMod;
   end;
end;

function FCFgSPM_EnforcPol_GetUnique: boolean;
{:Purpose: return the state of the unique data of the current policy to enforce.
    Additions:
}
begin
   Result:=GSPMspmi.SPMI_isUnique2set;
end;

function FCFgSPM_EnforcPol_GetArea: TFCEdgSPMarea; overload;
{:Purpose: return the SPM area of the current policy to enforce.
    Additions:
}
begin
   Result:=GSPMspmi.SPMI_area;
end;

function FCFgSPM_GvtEconMedcaSpiSystems_GetToken(
   const GEMSSGTent: integer;
   const GEMSSGTarea: TFCEdgSPMarea
   ): string;
{:Purpose: get the system token according to the gvt/economic/medical care/spiritual system chosen.
    Additions:
      -2012Sep09- *fix: any SPM item > dgADMIN couldn't be retrieved, due to a logical error.
      -2011Sep10- *add: test if the SPMi duration = 0, because if set and duration>0 indicate that the SPMi is a reject/cancellation.
                  *code audit:
                  (+)var formatting + refactoring     (+)if..then reformatting   (+)function/procedure refactoring   
                  (+)parameters refactoring           (+) ()reformatting         (N)code optimizations
                  (N)float local variables=> extended (N)case..of reformatting   (N)local methods
      -2010Dec21- *mod/add: refactoring + parameter is now one of the four SPM area.
                  *add: ECON/MEDCA/SPI area.
}
   var
      GEMSSGTspmiCnt
      ,GEMSSGTspmiMax: integer;

      isAreaFound: boolean;

      GEMSSGTspmi: TFCRdgSPMi;
begin
   Result:='';
   isAreaFound:=false;
   GEMSSGTspmiMax:=length( FCDdgEntities[GEMSSGTent].E_spmSettings )-1;
   if GEMSSGTspmiMax>0 then
   begin
      GEMSSGTspmiCnt:=1;
      while GEMSSGTspmiCnt<=GEMSSGTspmiMax do
      begin
         GEMSSGTspmi:=FCFgSPM_SPMIData_Get( FCDdgEntities[GEMSSGTent].E_spmSettings[GEMSSGTspmiCnt].SPMS_token );
         if ( GEMSSGTspmi.SPMI_area=GEMSSGTarea )
            and ( GEMSSGTspmi.SPMI_isUnique2set )
            and ( FCDdgEntities[GEMSSGTent].E_spmSettings[GEMSSGTspmiCnt].SPMS_iPtIsSet )
            and ( FCDdgEntities[GEMSSGTent].E_spmSettings[GEMSSGTspmiCnt].SPMS_duration=0 ) then
         begin
            if not isAreaFound
            then isAreaFound:=true;
            Result:=FCDdgEntities[GEMSSGTent].E_spmSettings[GEMSSGTspmiCnt].SPMS_token;
            break;
         end
         else if ( isAreaFound )
         and ( GEMSSGTspmi.SPMI_area<>GEMSSGTarea )
         then break;
         inc( GEMSSGTspmiCnt );
      end;
   end;
end;

function FCFgSPM_GvtEconMedcaSpiSystems_GetIdx(
   const GEMSSGIent: integer;
   const GEMSSGIarea: TFCEdgSPMarea
   ): integer;
{:Purpose: get the system index # according to the gvt/economic/medical care/spiritual system chosen.
    Additions:
      -2011Sep10- *add: test if the SPMi duration = 0, because if set and duration>0 indicate that the SPMi is a reject/cancellation.
                  *code audit:
                  (+)var formatting + refactoring     (+)if..then reformatting   (+)function/procedure refactoring   
                  (+)parameters refactoring           (+) ()reformatting         (N)code optimizations
                  (N)float local variables=> extended (N)case..of reformatting   (N)local methods
}
   var
      GEMSSGIspmiCnt
      ,GEMSSGIspmiMax: integer;

      GEMSSGIspmi: TFCRdgSPMi;
begin
   Result:=0;
   GEMSSGIspmiMax:=length( FCDdgEntities[GEMSSGIent].E_spmSettings )-1;
   if GEMSSGIspmiMax>0 then
   begin
      GEMSSGIspmiCnt:=1;
      while GEMSSGIspmiCnt<=GEMSSGIspmiMax do
      begin
         GEMSSGIspmi:=FCFgSPM_SPMIData_Get( FCDdgEntities[GEMSSGIent].E_spmSettings[GEMSSGIspmiCnt].SPMS_token );
         if ( GEMSSGIspmi.SPMI_area=GEMSSGIarea )
            and ( GEMSSGIspmi.SPMI_isUnique2set )
            and ( FCDdgEntities[GEMSSGIent].E_spmSettings[GEMSSGIspmiCnt].SPMS_iPtIsSet )
            and ( FCDdgEntities[GEMSSGIent].E_spmSettings[GEMSSGIspmiCnt].SPMS_duration=0 ) then
         begin
            Result:=GEMSSGIspmiCnt;
            break;
         end
         else if GEMSSGIspmi.SPMI_area>GEMSSGIarea
         then break;
         inc( GEMSSGIspmiCnt );
      end;
   end;
end;

function FCFgSPM_SPMIData_Get(
   const SPMIDGtoken: string;
   const SPMIDGloadIndex: boolean=false
   ): TFCRdgSPMi;
{:Purpose: retrieve the <token> SPMi data.
    Additions:
      -2011Sep10- *code audit:
                  (x)var formatting + refactoring     (+)if..then reformatting   (x)function/procedure refactoring
                  (x)parameters refactoring           (+) ()reformatting         (N)code optimizations
                  (N)float local variables=> extended (N)case..of reformatting   (N)local methods
}
   var
      SPMIDGcnt
      ,SPMIDGmax: integer;
begin
   Result:=FCDdgSPMi[0];
   SPMIDGmax:=length( FCDdgSPMi )-1;
   SPMIDGcnt:=1;
   while SPMIDGcnt<=SPMIDGmax do
   begin
      if FCDdgSPMi[SPMIDGcnt].SPMI_token=SPMIDGtoken then
      begin
         Result:=FCDdgSPMi[SPMIDGcnt];
         break;
      end;
      inc( SPMIDGcnt );
   end;
   if SPMIDGloadIndex
   then GSPMitmIdx:=SPMIDGcnt;
end;

function FCFgSPM_SPMiInfluence_Get(
   const SPMIIGspmi: TFCRdgSPMi;
   const SPMIIGent: integer
   ): integer;
{:Purpose: calculate the influence factor for a policy to set or a meme evolution regarding how is set the SPM of a given entity.
    Additions:
      -2011Sep10- *add: test if the SPMi duration = 0, because if set and duration>0 indicate that the SPMi is a reject/cancellation.
                  *code audit:
                  (x)var formatting + refactoring     (x)if..then reformatting   (N)function/procedure refactoring
                  (N)parameters refactoring           (x) ()reformatting         (N)code optimizations
                  (N)float local variables=> extended (N)case..of reformatting   (N)local methods
      -2010Dec05- *add: memes progressive influence.
}
   var
      SPMIIGcnt
      ,SPMIIGmax
      ,SPMIIGres: integer;

      SPMIIGsv: GSPMMret;
begin
   SPMIIGcnt:=1;
   SPMIIGmax:=length( FCDdgEntities[SPMIIGent].E_spmSettings )-1;
   SPMIIGres:=0;
   SPMIIGsv[1]:=SPMIIGsv[0];
   SPMIIGsv[2]:=SPMIIGsv[0];
   Result:=0;
   while SPMIIGcnt<=SPMIIGmax do
   begin
      if ( FCDdgEntities[SPMIIGent].E_spmSettings[SPMIIGcnt].SPMS_isPolicy )
         and ( FCDdgEntities[SPMIIGent].E_spmSettings[SPMIIGcnt].SPMS_iPtIsSet )
         and ( FCDdgEntities[SPMIIGent].E_spmSettings[SPMIIGcnt].SPMS_duration=0 )
      then SPMIIGres:=SPMIIGres+SPMIIGspmi.SPMI_infl[SPMIIGcnt].SPMII_influence
      else if ( not FCDdgEntities[SPMIIGent].E_spmSettings[SPMIIGcnt].SPMS_isPolicy )
         and ( FCDdgEntities[SPMIIGent].E_spmSettings[SPMIIGcnt].SPMS_iPtBeliefLevel>blUnknown ) then
      begin
         SPMIIGsv:=FCFgSPMM_SVRange_Get( FCDdgEntities[SPMIIGent].E_spmSettings[SPMIIGcnt].SPMS_iPtBeliefLevel );
         SPMIIGres:=SPMIIGres+round( SPMIIGspmi.SPMI_infl[SPMIIGcnt].SPMII_influence* ( SPMIIGsv[2]*0.01 ) );
      end;
      inc( SPMIIGcnt );
   end;
   Result:=SPMIIGres;
end;

function FCFgSPM_Policy_GetFSMod(const PGFSMent: integer): integer;
{:Purpose: retrieve the FS modifier, regarding the entity, for policy processing and return the modifier.
    Additions:
      -2012Apr25- *fix: take into account when cohesion>100.
}
var
   PGFSMfs: integer;
begin
   Result:=-100;
   PGFSMfs:=FCFgSPMD_GlobalData_Get(gspmdStability, PGFSMent);
   case PGFSMfs of
      0..19: Result:=15;
      20..34: Result:=11;
      35..49: Result:=7;
      50..64: Result:=0;
      65..79: Result:=-7;
      80..94: Result:=-11;
      95..1000: Result:=-13;
   end;
end;

function FCFgSPM_PolicyEnf_Preproc(
   const PPent: integer;
   const PPpolicy: string
   ): boolean;
{:Purpose: preprocess a policy setup, return false if the faction doesn't meet the policy's requirements.
    Additions:
      -2012Jan31- *fix: for UC requirement, display the right requirement value.
      -2010Dec29- *add: UC cost in case of UC requirement.
      -2010Dec13- *add: store SPMi data in a private variable.
      -2010Dec09- *add: infrastructure requirement results display, complete the requirements display.
      -2010Dec08- *add: faction's data requirement results display.
      -2010Dec07- *fix: UC margin calculation correction for compute the right penalty.
                  *mod: implementation of a new and final AP calculation method (verified by simulation).
                  *add: UC requirement results display (COMPLETE).
      -2010Dec05- *mod: AP calculation (w/ base AP).
                  *add: UC requirement results display (WIP).
      -2010Nov15- *add: AP calculations completion.
      -2010Nov14- *add: AP calculations - sum of requirement margins modifiers and sum of influence factors.
      -2010Nov10- *fix: correction of margin calculations.
                  *add: acceptance probability calculation (WIP).
      -2010Nov09- *add: UC requirement calculations - population, population_yr, colonies, colonies_yr.
      -2010Nov08- *add: UC requirement calculations - fixed and fixed_yr.
      -2010Nov07- *add: faction data requirement calculations completion.
      -2010Nov05- *add: faction data requirement calculations - faction stability completion.
      -2010Nov04- *add: building requirement calculations completion.
                  *add: faction data requirement calculations - faction level completion.
      -2010Nov03- *add: requirements calculations, begin WIP.
}
{:DEV NOTES: WARNING: all updates in this procedure must be applied in FCFgSPM_PolicyEnf_PreprocNoUI.}
var
   PPbAP
   ,PPbcMod
   ,PPbREQ
   ,PPcol
   ,PPeSUM
   ,PPfAP
   ,PPinfra
   ,PPmarginMin
   ,PPreqCnt
   ,PPreqMax
   ,PPreqResult
   ,PPreqSubVal
   ,PPsubCnt
   ,PPsubMax: integer;

   PPcurOutput
   ,PPreqOutput: string;

   PPisReqPassed: boolean;

begin
   {.initialize the data}
   GSPMfsMod:=0;
   GSPMap:=0;
   GSPMmarginMod:=0;
   GSPMduration:=0;
   GSPMcohPen:=0;
   GSPMcohPenRej:=0;
   GSPMfap_x:=0;
   GSPMitmIdx:=0;
   PPreqCnt:=0;
   PPreqMax:=0;
   PPeSUM:=0;
   PPisReqPassed:=true;
   GSPMspmi:=FCFgSPM_SPMIData_Get(PPpolicy, true);
   {.initialize the interface}
   FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Clear;
   {.requirements calculations}
   PPreqMax:=length(GSPMspmi.SPMI_req)-1;
   if PPreqMax>0
   then
   begin
      FCDdgEntities[PPent].E_spmSettings[GSPMitmIdx].SPMS_ucCost:=0;
      PPreqCnt:=1;
      while PPreqCnt<=PPreqMax do
      begin
         if PPisReqPassed
         then
         begin
            case GSPMspmi.SPMI_req[PPreqCnt].SPMIR_type of
               dgBuilding:
               begin
                  PPcol:=0;
                  PPinfra:=0;
                  PPmarginMin:=0;
                  PPreqResult:=0;
                  PPsubCnt:=0;
                  PPsubMax:=0;
                  PPreqOutput:='';
                  FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Add( '<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'Infrastructure') +'...' );
                  {.PPsubMax and PPsubCnt below related to colonies}
                  PPsubMax:=length(FCDdgEntities[PPent].E_colonies)-1;
                  if PPsubMax>0
                  then
                  begin
                     PPmarginMin:=round(GSPMspmi.SPMI_req[PPreqCnt].SPMIR_percCol*0.75);
                     PPsubCnt:=1;
                     while PPsubCnt<=PPsubMax do
                     begin
                        PPinfra:=FCFgC_ColInfra_DReq(gcSpecToken, PPent, PPsubCnt, GSPMspmi.SPMI_req[PPreqCnt].SPMIR_infToken);
                        if PPinfra>0
                        then inc(PPcol);
                        inc(PPsubCnt);
                     end;
                     PPreqResult:=round((PPcol*100)/PPsubMax);
                     if PPreqResult<PPmarginMin
                     then PPisReqPassed:=false
                     else if (PPreqResult>=PPmarginMin)
                        and (PPreqResult<GSPMspmi.SPMI_req[PPreqCnt].SPMIR_percCol)
                     then GSPMmarginMod:=GSPMmarginMod-round( (GSPMspmi.SPMI_req[PPreqCnt].SPMIR_percCol-PPreqResult)*0.8 );
                  end
                  else if PPsubMax=0
                  then PPisReqPassed:=false;
                  {.requirement text}
                  PPreqOutput:='<br>'
                     +FCCFidxL+'<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReq')+' '+FCFdTFiles_UIStr_Get(uistrUI, GSPMspmi.SPMI_req[PPreqCnt].SPMIR_infToken)+'</b><br>'
                     +FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqInf1')+' <b>'+IntToStr(GSPMspmi.SPMI_req[PPreqCnt].SPMIR_percCol)+'</b> % '
                     +FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqInf2')
                     +'<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqCurr')+' <b>'+IntToStr(PPreqResult)+'</b> %<br>--------';
               end; //==END== case: dgBuilding ==//
               dgFacData:
               begin
                     PPreqOutput:='<br>'+FCCFidxL+'<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReq')+' ';
                     PPcurOutput:='<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'faclvl'+IntToStr(FCDdgEntities[0].E_factionLevel))+'</b>';
                     FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Add( '<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'faclvl') +'...' );
                  case GSPMspmi.SPMI_req[PPreqCnt].SPMIR_datTp of
                     rfdFacLv1:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel=0
                        then PPisReqPassed:=false;
                        PPreqOutput:=PPreqOutput+' (1)-'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl1')+' +</b>';
                     end;
                     rfdFacLv2:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=1
                        then PPisReqPassed:=false;
                        PPreqOutput:=PPreqOutput+' (2)-'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl2')+' +</b>';
                     end;
                     rfdFacLv3:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=1
                        then PPisReqPassed:=false
                        else if FCDdgEntities[PPent].E_factionLevel=2
                        then GSPMmarginMod:=GSPMmarginMod-10;
                        PPreqOutput:=PPreqOutput+' (3)-'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl3')+' +</b>';
                     end;
                     rfdFacLv4:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=2
                        then PPisReqPassed:=false
                        else if FCDdgEntities[PPent].E_factionLevel=3
                        then GSPMmarginMod:=GSPMmarginMod-10;
                        PPreqOutput:=PPreqOutput+' (4)-'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl4')+' +</b>';
                     end;
                     rfdFacLv5:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=3
                        then PPisReqPassed:=false
                        else if FCDdgEntities[PPent].E_factionLevel=4
                        then GSPMmarginMod:=GSPMmarginMod-10;
                        PPreqOutput:=PPreqOutput+' (5)-'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl5')+' +</b>';
                     end;
                     rfdFacLv6:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=4
                        then PPisReqPassed:=false
                        else if FCDdgEntities[PPent].E_factionLevel=5
                        then GSPMmarginMod:=GSPMmarginMod-10;
                        PPreqOutput:=PPreqOutput+' (6)-'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl6')+' +</b>';
                     end;
                     rfdFacLv7:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=4
                        then PPisReqPassed:=false
                        else if FCDdgEntities[PPent].E_factionLevel=5
                        then GSPMmarginMod:=GSPMmarginMod-20
                        else if FCDdgEntities[PPent].E_factionLevel=6
                        then GSPMmarginMod:=GSPMmarginMod-10;
                        PPreqOutput:=PPreqOutput+' (7)-'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl7')+' +</b>';
                     end;
                     rfdFacLv8:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=5
                        then PPisReqPassed:=false
                        else if FCDdgEntities[PPent].E_factionLevel=6
                        then GSPMmarginMod:=GSPMmarginMod-20
                        else if FCDdgEntities[PPent].E_factionLevel=7
                        then GSPMmarginMod:=GSPMmarginMod-10;
                        PPreqOutput:=PPreqOutput+' (8)-'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl8')+' +</b>';
                     end;
                     rfdFacLv9:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=6
                        then PPisReqPassed:=false
                        else if FCDdgEntities[PPent].E_factionLevel=7
                        then GSPMmarginMod:=GSPMmarginMod-20
                        else if FCDdgEntities[PPent].E_factionLevel=8
                        then GSPMmarginMod:=GSPMmarginMod-10;
                        PPreqOutput:=PPreqOutput+' (9)-'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl9')+' +</b>';
                     end;
                     rfdFacStab..rfdEquil:
                     begin
                        case GSPMspmi.SPMI_req[PPreqCnt].SPMIR_datTp of
                           rfdFacStab:
                           begin
                              FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Insert(
                                 FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Count-1
                                 , '<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatEquil') +'...'
                                 );
                              PPreqResult:=FCFgSPMD_GlobalData_Get(gspmdStability, PPent);
                              PPcurOutput:='<b>'+IntToStr(PPreqResult)+'</b> %';
                           end;
                           rfdInstrLv:
                           begin
                              FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Insert(
                                 FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Count-1
                                 , '<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatInstLvl') +'...'
                                 );
                              PPreqResult:=FCFgSPMD_GlobalData_Get(gspmdInstruction, PPent);
                              PPcurOutput:='<b>'+IntToStr(PPreqResult)+'</b> %';
                           end;
                           rfdLifeQ:
                           begin
                              FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Insert(
                                 FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Count-1
                                 , '<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatLifeQ') +'...'
                                 );
                              PPreqResult:=FCFgSPMD_GlobalData_Get(gspmdLifeQual, PPent);
                              PPcurOutput:='<b>'+IntToStr(PPreqResult)+'</b>';
                           end;
                           rfdEquil:
                           begin
                              FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Insert(
                                 FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Count-1
                                 , '<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatEquil') +'...'
                                 );
                              PPreqResult:=FCFgSPMD_GlobalData_Get(gspmdEquilibrium, PPent);
                              PPcurOutput:='<b>'+IntToStr(PPreqResult)+'</b>';
                           end;
                        end;
                        FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Delete(FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Count-1);
                        PPmarginMin:=round(GSPMspmi.SPMI_req[PPreqCnt].SPMIR_datValue*0.75);
                        if PPreqResult<PPmarginMin
                        then PPisReqPassed:=false
                        else if (PPreqResult>=PPmarginMin)
                           and (PPreqResult<GSPMspmi.SPMI_req[PPreqCnt].SPMIR_datValue)
                        then GSPMmarginMod:=GSPMmarginMod-round( (100- ( ( PPreqResult*100)/GSPMspmi.SPMI_req[PPreqCnt].SPMIR_datValue ) )*0.8 );
                        PPreqOutput:=PPreqOutput+' '+IntToStr(GSPMspmi.SPMI_req[PPreqCnt].SPMIR_datValue)+'</b>';
                     end; //==END== case: rfdFacStab..rfdEquil ==//
                  end; //==END== case GSPMspmi.SPMI_req[PPreqCnt].SPMIR_datTp of ==//
                  {.requirement text}
                  PPreqOutput:=PPreqOutput
                     +'<br>'
                     +FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqCurr')
                     +' '+PPcurOutput+'<br>--------';
               end;
               dgTechSci:
               begin
                  {:DEV NOTES: req to implement technosciences database + research status array for entities before to put the code for this case.}
                  {.update the requirements list}
               end;
               dgUC:
               begin
                  {:DEV NOTES: PPreqSubVal= margin max.}
                  PPreqOutput:='';
                  FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Add( '<br>'+FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'acronUCwDes') +'...' );
                  PPreqResult:=trunc(FCDdgEntities[PPent].E_ucInAccount);
                  if PPreqResult>0
                  then
                  begin
                     case GSPMspmi.SPMI_req[PPreqCnt].SPMIR_ucMethod of
                        dgFixed, dgFixed_yr:
                        begin
                           if GSPMspmi.SPMI_req[PPreqCnt].SPMIR_ucMethod=dgFixed_yr
                           then PPsubCnt:=12
                           else PPsubCnt:=1;
                           PPreqSubVal:=round( GSPMspmi.SPMI_req[PPreqCnt].SPMIR_ucVal*PPsubCnt );
                        end;
                        dgCalcPop, dgCalcPop_yr:
                        begin
                           if GSPMspmi.SPMI_req[PPreqCnt].SPMIR_ucMethod=dgCalcPop_yr
                           then PPsubCnt:=12
                           else PPsubCnt:=1;
                           PPreqSubVal:=round( GSPMspmi.SPMI_req[PPreqCnt].SPMIR_ucVal*FCFgSPMD_GlobalData_Get(gmspmdPopulation, PPent)*PPsubCnt );
                        end;
                        dgCalcCol, dgCalcCol_yr:
                        begin
                           if GSPMspmi.SPMI_req[PPreqCnt].SPMIR_ucMethod=dgCalcCol_yr
                           then PPsubCnt:=12
                           else PPsubCnt:=1;
                           PPreqSubVal:=round( GSPMspmi.SPMI_req[PPreqCnt].SPMIR_ucVal*( length(FCDdgEntities[PPent].E_colonies)-1 )*PPsubCnt );
                        end;
                     end; //==END== case GSPMspmi.SPMI_req[PPreqCnt].SPMIR_ucMethod of ==//
                     FCDdgEntities[PPent].E_spmSettings[GSPMitmIdx].SPMS_ucCost:=PPreqSubVal;
                     PPmarginMin:=round(PPreqSubVal*0.75);
                     if PPreqResult<PPmarginMin
                     then PPisReqPassed:=false
                     else if (PPreqResult>=PPmarginMin)
                        and (PPreqResult<PPreqSubVal)
                     then GSPMmarginMod:=GSPMmarginMod-round( ( 100- ( (PPreqResult*100)/PPreqSubVal ) )*0.8 );
                  end
                  else if PPreqResult=0
                  then PPisReqPassed:=false;
                  {.requirement text}
                  PPreqOutput:='<br>'
                     +FCCFidxL+'<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReq')+' '
                     +IntToStr(PPreqSubVal)+'</b>'
                     +' '+FCFdTFiles_UIStr_Get(uistrUI, 'acronUC')
                     +' '+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqUC1')
                     +' '+IntToStr(PPreqSubVal)
                     +' '+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqUC2')
                     +'<br>'
                     +FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqCurr')
                     +' <b>'+IntToStr(PPreqResult)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI, 'acronUC')+'<br>--------';
               end; //==END== case: dgUC ==//
            end; //==END== case GSPMspmi.SPMI_req[PPreqCnt].SPMIR_type of ==//
            if PPisReqPassed
            then FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Add( FCCFcolGreen+'<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqPass')+'</b>'+FCCFcolEND )
            else if not PPisReqPassed
            then FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Add( FCCFcolRed+'<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqFail')+'</b>'+FCCFcolEND );
            FCWinMain.FCWM_UMIFSh_RFdisp.HTMLText.Add(PPreqOutput);
            inc(PPreqCnt);
         end //==END== if PPisReqPassed ==//
         else if not PPisReqPassed
         then break;
      end; //==END== while PPreqCnt<=PPreqMax do ==//
   end;
   {.acceptance probability calculations}
   if PPisReqPassed
   then
   begin
      if GSPMmodMax=0
      then GSPMmodMax:=Length(FCDdgSPMi)-2;
      PPbAP:=50;//22;
      PPbREQ:=GSPMmarginMod;
      PPeSUM:=FCFgSPM_SPMiInfluence_Get(GSPMspmi, PPent);
      PPbcMod:=round( sqrt(FCDdgEntities[PPent].E_bureaucracy-FCDdgEntities[PPent].E_corruption)*2 );
//      PPfAP:=PPbAP+PPbREQ+round( ( (24*GSPMmodMax)+(PPeSUM*4) )/ GSPMmodMax )+PPbcMod;
      PPfAP:=PPbAP+PPbREQ+round(PPeSUM*1)+PPbcMod;
      GSPMap:=PPfAP;
      GSPMinfluence:=PPeSUM;
   end;
   Result:=PPisReqPassed;
end;

function FCFgSPM_PolicyEnf_PreprocNoUI(
   const PPent: integer;
   const PPpolicy: string
   ): boolean;
{:Purpose: preprocess a policy setup, return false if the faction doesn't meet the policy's requirements.
It doesn't update the UI and don't update the private SPM variables, it's only for requirement purposes.
    Additions:
      -2010Dec29- *add: UC cost in case of UC requirement.
}
{:DEV NOTES: WARNING: all updates in this procedure must be applied in FCFgSPM_PolicyEnf_Preproc.}
var
   PPcol
   ,PPinfra
   ,PPmarginMin
   ,PPreqCnt
   ,PPreqMax
   ,PPreqResult
   ,PPreqSubVal
   ,PPsubCnt
   ,PPsubMax: integer;

   PPisReqPassed: boolean;

   PEPNUIspmi: TFCRdgSPMi;

begin
   {.initialize the data}
   PPreqCnt:=0;
   PPreqMax:=0;
   PPisReqPassed:=true;
   PEPNUIspmi:=FCFgSPM_SPMIData_Get(PPpolicy, true);
   {.requirements calculations}
   PPreqMax:=length(PEPNUIspmi.SPMI_req)-1;
   if PPreqMax>0
   then
   begin
      FCDdgEntities[PPent].E_spmSettings[GSPMitmIdx].SPMS_ucCost:=0;
      PPreqCnt:=1;
      while PPreqCnt<=PPreqMax do
      begin
         if PPisReqPassed
         then
         begin
            case PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_type of
               dgBuilding:
               begin
                  PPcol:=0;
                  PPinfra:=0;
                  PPmarginMin:=0;
                  PPreqResult:=0;
                  PPsubCnt:=0;
                  PPsubMax:=0;
                  {.PPsubMax and PPsubCnt below related to colonies}
                  PPsubMax:=length(FCDdgEntities[PPent].E_colonies)-1;
                  if PPsubMax>0
                  then
                  begin
                     PPmarginMin:=round(PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_percCol*0.75);
                     PPsubCnt:=1;
                     while PPsubCnt<=PPsubMax do
                     begin
                        PPinfra:=FCFgC_ColInfra_DReq(gcSpecToken, PPent, PPsubCnt, PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_infToken);
                        if PPinfra>0
                        then inc(PPcol);
                        inc(PPsubCnt);
                     end;
                     PPreqResult:=round((PPcol*100)/PPsubMax);
                     if PPreqResult<PPmarginMin
                     then PPisReqPassed:=false;
                  end
                  else if PPsubMax=0
                  then PPisReqPassed:=false;
               end; //==END== case: dgBuilding ==//
               dgFacData:
               begin
                  case PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_datTp of
                     rfdFacLv1:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel=0
                        then PPisReqPassed:=false;
                     end;
                     rfdFacLv2:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=1
                        then PPisReqPassed:=false;
                     end;
                     rfdFacLv3:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=1
                        then PPisReqPassed:=false;
                     end;
                     rfdFacLv4:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=2
                        then PPisReqPassed:=false;
                     end;
                     rfdFacLv5:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=3
                        then PPisReqPassed:=false;
                     end;
                     rfdFacLv6:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=4
                        then PPisReqPassed:=false;
                     end;
                     rfdFacLv7:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=4
                        then PPisReqPassed:=false;
                     end;
                     rfdFacLv8:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=5
                        then PPisReqPassed:=false;
                     end;
                     rfdFacLv9:
                     begin
                        if FCDdgEntities[PPent].E_factionLevel<=6
                        then PPisReqPassed:=false;
                     end;
                     rfdFacStab..rfdEquil:
                     begin
                        case PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_datTp of
                           rfdFacStab: PPreqResult:=FCFgSPMD_GlobalData_Get(gspmdStability, PPent);
                           rfdInstrLv: PPreqResult:=FCFgSPMD_GlobalData_Get(gspmdInstruction, PPent);
                           rfdLifeQ: PPreqResult:=FCFgSPMD_GlobalData_Get(gspmdLifeQual, PPent);
                           rfdEquil: PPreqResult:=FCFgSPMD_GlobalData_Get(gspmdEquilibrium, PPent);
                        end;
                        PPmarginMin:=round(PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_datValue*0.75);
                        if PPreqResult<PPmarginMin
                        then PPisReqPassed:=false;
                     end; //==END== case: rfdFacStab..rfdEquil ==//
                  end; //==END== case PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_datTp of ==//
               end;
               dgTechSci:
               begin
                  {:DEV NOTES: req to implement technosciences database + research status array for entities before to put the code for this case.}
                  {.update the requirements list}
               end;
               dgUC:
               begin
                  {:DEV NOTES: PPreqSubVal= margin max.}
                  PPreqResult:=trunc(FCDdgEntities[PPent].E_ucInAccount);
                  if PPreqResult>0
                  then
                  begin
                     PPsubCnt:=1;
                     case PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_ucMethod of
                        dgFixed, dgFixed_yr:
                        begin
                           if PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_ucMethod=dgFixed_yr
                           then PPsubCnt:=12;
                           PPreqSubVal:=round( PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_ucVal*PPsubCnt );
                        end;
                        dgCalcPop, dgCalcPop_yr:
                        begin
                           if PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_ucMethod=dgCalcPop_yr
                           then PPsubCnt:=12;
                           PPreqSubVal:=round( PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_ucVal*FCFgSPMD_GlobalData_Get(gmspmdPopulation, PPent)*PPsubCnt );
                        end;
                        dgCalcCol, dgCalcCol_yr:
                        begin
                           if PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_ucMethod=dgCalcCol_yr
                           then PPsubCnt:=12;
                           PPreqSubVal:=round( PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_ucVal*( length(FCDdgEntities[PPent].E_colonies)-1 )*PPsubCnt );
                        end;
                     end; //==END== case PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_ucMethod of ==//
                     FCDdgEntities[PPent].E_spmSettings[GSPMitmIdx].SPMS_ucCost:=PPreqSubVal;
                     PPmarginMin:=round(PPreqSubVal*0.75);
                     if PPreqResult<PPmarginMin
                     then PPisReqPassed:=false;
                  end
                  else if PPreqResult=0
                  then PPisReqPassed:=false;
               end; //==END== case: dgUC ==//
            end; //==END== case PEPNUIspmi.SPMI_req[PPreqCnt].SPMIR_type of ==//
            inc(PPreqCnt);
         end //==END== if PPisReqPassed ==//
         else if not PPisReqPassed
         then break;
      end; //==END== while PPreqCnt<=PPreqMax do ==//
   end;
   Result:=PPisReqPassed;
end;

function FCFgSPM_PolicyProc_DoTest(PPDTsimulVal: integer): TFCEgspmPolRslt;
{:Purpose: process the policy enforcement test and retrieve the result.
    Additions:
      -2012Jan31- *fix: really use the PPDTsimulVal in the case of a simulation !
                  *mod: change the random probability calculation.
}
var
   PPDTproba: integer;
begin
   GSPMfap_x:=-50;
   PPDTproba:=0;
   Result:=gspmResMassRjct;
   GSPMfsMod:=FCFgSPM_Policy_GetFSMod(0);
   if PPDTsimulVal=0
   then
   begin
      PPDTproba:=(FCFcFunc_Rand_Int(4)+1)*20;
      GSPMfap_x:=GSPMap-(PPDTproba+GSPMfsMod);
   end
   else if PPDTsimulVal>0
   then
   begin
      GSPMfap_x:=GSPMap-(PPDTsimulVal+GSPMfsMod);
   end;
   if GSPMfap_x<-24
   then Result:=gspmResMassRjct
   else if (GSPMfap_x>=-24)
      and (GSPMfap_x<-10)
   then Result:=gspmResReject
   else if (GSPMfap_x>=-10)
      and (GSPMfap_x<=29)
   then Result:=gspmResFifFifty
   else if GSPMfap_x>29
   then Result:=gspmResAccept;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgSPM_Phase_Proc;
{:Purpose: SPM phase processing.
    Additions:
      -2012Aug20- *mod: the memes management is disabled until full audit of all the code.
      -2011Jan19- *add: trigger Government Destabilization if the political system doesn't meet a requirement.
      -2011Jan06- *add: complete memes processing.
      -2011Jan04- *add: meme requirements.
                  *add: complete policies processing.
      -2011Jan03- *add: meme SV calculations.
      -2011Jan02- *add: cohesion penalty calculation for retired policy that doesn't meet the requirements + warn the player.
                  *fix: forgot to re-enable the policy enforcement UI.
      -2010Dec29- *add: disable and re-enable the policy enforcement UI during the test of the player's entity.
}
var
   PPbBLP
   ,PPbREQ
   ,PPcohPenalty
   ,PPcolCnt
   ,PPcolMax
   ,PPcSV
   ,PPentCnt
   ,PPeSUM
   ,PPfAPtest
   ,PPfBLP
   ,PPmaSV
   ,PPmiSV
   ,PPnSV
   ,PPrand
   ,PPspmCnt
   ,PPspmMax
   ,PPsvMod: integer;

   PPblMod
   ,PPcalc
   ,PPt2
   ,PPt4: extended;

   PPblRed
   ,PPpostSVoverride
   ,PPreResult: boolean;

   PPspmi: TFCRdgSPMi;

   PPsvRng: GSPMMret;
begin
   {.disable the policy enforcement tab of the UMI}
   FCWinMain.FCWM_UMIFac_TabShSPMpol.Enabled:=false;
   PPentCnt:=0;
   PPspmMax:=length(FCDdgSPMi)-1;
   while PPentCnt<=FCCdiFactionsMax do
   begin
      if PPentCnt>0
      then FCWinMain.FCGLScadencer.Enabled:=true;
      PPspmCnt:=1;
      while PPspmCnt<=PPspmMax do
      begin
         PPblMod:=0;
         PPcalc:=0;
         PPcSV:=0;
         PPmaSV:=0;
         PPmiSV:=0;
         PPnSV:=0;
         PPrand:=0;
         PPsvRng[1]:=PPsvRng[0];
         PPsvRng[2]:=PPsvRng[0];
         PPcohPenalty:=0;
         PPbBLP:=0;
         PPbREQ:=0;
         PPeSUM:=0;
         PPsvMod:=0;
         PPfBLP:=0;
         PPt2:=0;
         PPt4:=0;
         PPpostSVoverride:=false;
         PPspmi:=FCFgSPM_SPMIData_Get(FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_token);
         if FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_isPolicy
         then
         begin
            if (not FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtIsSet)
               and (FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_duration>0)
            then dec(FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_duration)
            else if FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtIsSet
            then
            begin
               PPreResult:=FCFgSPM_PolicyEnf_PreprocNoUI(PPentCnt, FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_token);
               if (PPreResult)
                  and (FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_ucCost>0)
               then FCDdgEntities[PPentCnt].E_ucInAccount:=FCDdgEntities[PPentCnt].E_ucInAccount-FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_ucCost
               else if (not PPreResult)
                  and (not PPspmi.SPMI_isUnique2set)
               then
               begin
                  PPcohPenalty:=round(FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtAcceptanceProbability*0.1);
                  FCMgSPM_SPMI_Retire(PPentCnt, PPspmCnt);
                  {:DEV NOTES: apply cohesion penalty on the colonies.}
                  {:DEV NOTES: warning don't forget to NOT display a message but warn the AI in the case of the entity isn't the player.}
                  FCMuiM_Message_Add(
                     mtSPMrequirements
                     ,0
                     ,PPspmCnt
                     ,1
                     ,0
                     ,0
                     );
               end
               else if (not PPreResult)
                  and (PPspmi.SPMI_isUnique2set)
               then
               begin
                  PPcolCnt:=1;
                  PPcolMax:=length(FCDdgEntities[PPentCnt].E_colonies)-1;
                  if PPcolMax>0
                  then
                  begin
                     PPfAPtest:=FCFcFunc_Rand_Int(99)+1;
                     if PPfAPtest<=FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtAcceptanceProbability
                     then FCMgCSME_Event_Trigger(
                        ceGovernmentDestabilization
                        ,PPentCnt
                        ,PPcolCnt
                        ,1
                        ,false
                        );
                     inc(PPcolCnt);
                  end;
               end;
            end; //==END== else if FCentities[PPentCnt].E_spm[PPspmCnt].SPMS_isSet ==//
         end //==END== if FCentities[PPentCnt].E_spm[PPspmCnt].SPMS_isPolicy ==//
//         else if not FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_isPolicy
//         then
//         begin
//            PPcSV:=FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtSpreadValue;
//            PPsvRng:=FCFgSPMM_SVRange_Get(FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel);
//            PPmiSV:=PPsvRng[1];
//            PPmaSV:=PPsvRng[2];
//            {.SV evolution before BL calculations}
//            if FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel>blUnknown
//            then
//            begin
//               if PPcSV<PPmaSV
//               then
//               begin
//                  PPcolMax:=length(FCDdgEntities[PPentCnt].E_colonies)-1;
//                  PPblMod:=FCFgSPMM_BLMod_Get(FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel);
//                  PPcalc:=( ( (PPmaSV-PPcSV)-sqrt(PPcolMax) )*PPblMod )*0.1;
//                  if PPcalc<=0
//                  then PPnSV:=0
//                  else if PPcalc>0
//                  then
//                  begin
//                     PPrand:=FCFcFunc_Rand_Int(9)+1;
//                     PPnSV:=PPcSV+round(PPcalc*PPrand);
//                  end;
//               end
//               else if PPcSV>PPmaSV
//               then PPnSV:=round( PPcSV-(PPcSV*0.1) );
//            end;
//            {.meme requirements}
//            PPreResult:=FCFgSPMM_Req_DoTest(PPentCnt, FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_token);
//            if (not PPreResult)
//               and (FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel>blUnknown)
//               and (PPcSV<=PPmaSV)
//            then
//            begin
//               dec(FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel);
//               PPpostSVoverride:=true;
//            end
//            else if (
//               (not PPreResult)
//                  and (FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel>blUnknown)
//                  and (PPcSV>PPmaSV)
//               )
//               or (PPreResult)
//            then
//            begin
//               {.BL progression}
//               if not PPreResult
//               then PPpostSVoverride:=true;
//               PPbBLP:=50;
//               PPbREQ:=FCFgSPMM_Margin_Get;
//               PPeSUM:=FCFgSPM_SPMiInfluence_Get(PPspmi, PPentCnt);
//               PPsvMod:=round(PPcSV*0.2);
//               PPfBLP:=PPbBLP+PPbREQ+PPeSUM+PPsvMod;
//               PPrand:=FCFcFunc_Rand_Int(99)+1;
//               PPt2:=PPfBLP*2/3;
//               PPt4:=PPfBLP*4/3;
//               if PPrand<PPt2
//               then inc(FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel)
//               else if (PPrand>PPt4)
//                  and (FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel>blUnknown)
//               then
//               begin
//                  dec(FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel);
//                  PPblRed:=true;
//               end;
//            end;
//            {.SV evolution after BL calculations}
//             if PPpostSVoverride
//            then
//            begin
//               if PPnSV=0
//               then PPnSV:=PPcSV-round(PPcSV*0.1)
//               else if PPnSV<>0
//               then PPnSV:=PPnSV-round(PPcSV*0.1);
//            end
//            else if not PPpostSVoverride
//            then
//            begin
//               if (FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel=blUnknown)
//                  and (PPcSV>0)
//                  and (PPnSV=0)
//               then PPnSV:=PPcSV-round(PPcSV*0.1)
//               else if (FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel=blUnknown)
//                  and (PPcSV>0)
//                  and (PPnSV<>0)
//               then PPnSV:=PPnSV-round(PPcSV*0.1)
//               else if (PPcSV=0)
//                  and (FCDdgEntities[PPentCnt].E_spmSettings[PPspmCnt].SPMS_iPtBeliefLevel>blUnknown)
//                  and (PPnSV=0)
//               then PPnSV:=1;
//            end;
//            {.readjust custom effects modifiers and meme's modifiers}
//            FCMgSPMM_ModifCustFx_Upd(PPentCnt, PPspmCnt, PPnSV);
//         end; //==END== else if not FCentities[PPentCnt].E_spm[PPspmCnt].SPMS_isPolicy ==//
      ;
         inc(PPspmCnt);
      end; //==END== while PPspmCnt<=PPspmMax do ==//
      inc(PPentCnt);
   end; //==END== while PPentCnt<=FCCfacMax do ==//
//   update UMI
   {:DEV NOTES: temporarly line.}
   FCWinMain.FCWM_UMIFac_TabShSPMpol.Enabled:=true;
end;

procedure FCMgSPM_PolicyEnf_Confirm;
{:Purpose: end enforcement process: confirm policy.
    Additions:
      -2010Dec29- *add: applies UC cost if there's any.
      -2010Dec28- *rem: enforced policies doesn't have a duration anymore.
      -2010Dec22- *add: processing of unique policy.
}
var
   PECapplyCohMod
   ,PECcnt
   ,PECmax
   ,PECmodCoh
   ,PECmodTens
   ,PECmodSec
   ,PECmodEdu
   ,PECmodNat
   ,PECmodHeal
   ,PECmodBur
   ,PECmodCor
   ,PEColdPolIdx: integer;

   PEColdPolTok: string;

   PEColdPol: TFCRdgSPMi;
begin
   PECapplyCohMod:=0;
   PECmodCoh:=0;
   PECmodTens:=0;
   PECmodSec:=0;
   PECmodEdu:=0;
   PECmodNat:=0;
   PECmodHeal:=0;
   PECmodBur:=0;
   PECmodCor:=0;
   FCWinMain.FCWM_UMISh_CEFcommit.Enabled:=false;
   FCWinMain.FCWM_UMISh_CEFretire.Enabled:=false;
   FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Clear;
   case GSPMrslt of
      gspmResMassRjct: PECapplyCohMod:=GSPMcohPen;
      gspmResReject: PECapplyCohMod:=GSPMcohPen;
      gspmResFifFifty: PECapplyCohMod:=GSPMcohPen;
   end; //==END== case GSPMrslt of ==//
   {.processing of unique policy}
   if GSPMspmi.SPMI_isUnique2set
   then
   begin
      PEColdPolTok:=FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, GSPMspmi.SPMI_area);
      PEColdPol:=FCFgSPM_SPMIData_Get(PEColdPolTok);
      PEColdPolIdx:=FCFgSPM_GvtEconMedcaSpiSystems_GetIdx(0, GSPMspmi.SPMI_area);
      {.exchange the previous policy modifiers by the new one}
      PECmodCoh:=FCDdgEntities[0].E_spmMod_Cohesion;
      FCDdgEntities[0].E_spmMod_Cohesion:=PECmodCoh-PEColdPol.SPMI_modCohes+GSPMspmi.SPMI_modCohes;
      PECmodCoh:=-(PEColdPol.SPMI_modCohes-GSPMspmi.SPMI_modCohes);
      PECmodTens:=FCDdgEntities[0].E_spmMod_Tension;
      FCDdgEntities[0].E_spmMod_Tension:=PECmodTens-PEColdPol.SPMI_modTens+GSPMspmi.SPMI_modTens;
      PECmodTens:=-(PEColdPol.SPMI_modTens-GSPMspmi.SPMI_modTens);
      PECmodSec:=FCDdgEntities[0].E_spmMod_Security;
      FCDdgEntities[0].E_spmMod_Security:=PECmodSec-PEColdPol.SPMI_modSec+GSPMspmi.SPMI_modSec;
      PECmodSec:=-(PEColdPol.SPMI_modSec-GSPMspmi.SPMI_modSec);
      PECmodEdu:=FCDdgEntities[0].E_spmMod_Education;
      FCDdgEntities[0].E_spmMod_Education:=PECmodEdu-PEColdPol.SPMI_modEdu+GSPMspmi.SPMI_modEdu;
      PECmodEdu:=-(PEColdPol.SPMI_modEdu-GSPMspmi.SPMI_modEdu);
      PECmodNat:=FCDdgEntities[0].E_spmMod_Natality;
      FCDdgEntities[0].E_spmMod_Natality:=PECmodNat-PEColdPol.SPMI_modNat+GSPMspmi.SPMI_modNat;
      PECmodNat:=-(PEColdPol.SPMI_modNat-GSPMspmi.SPMI_modNat);
      PECmodHeal:=FCDdgEntities[0].E_spmMod_Health;
      FCDdgEntities[0].E_spmMod_Health:=PECmodHeal-PEColdPol.SPMI_modHeal+GSPMspmi.SPMI_modHeal;
      PECmodHeal:=-(PEColdPol.SPMI_modHeal-GSPMspmi.SPMI_modHeal);
      PECmodBur:=FCDdgEntities[0].E_spmMod_Bureaucracy;
      FCDdgEntities[0].E_spmMod_Bureaucracy:=PECmodBur-PEColdPol.SPMI_modBur+GSPMspmi.SPMI_modBur;
      FCDdgEntities[0].E_bureaucracy:=FCDdgEntities[0].E_bureaucracy-PEColdPol.SPMI_modBur+GSPMspmi.SPMI_modBur;
//      FCMumi_Faction_Upd(uiwPolStruc_bur, false);
      PECmodCor:=FCDdgEntities[0].E_spmMod_Corruption;
      FCDdgEntities[0].E_spmMod_Corruption:=PECmodCor-PEColdPol.SPMI_modCorr+GSPMspmi.SPMI_modCorr;
      FCDdgEntities[0].E_corruption:=FCDdgEntities[0].E_corruption-PEColdPol.SPMI_modCorr+GSPMspmi.SPMI_modCorr;
//      FCMumi_Faction_Upd(uiwPolStruc_cor, false);
      {.update the old policy's data}
      FCDdgEntities[0].E_spmSettings[PEColdPolIdx].SPMS_iPtIsSet:=false;
      FCDdgEntities[0].E_spmSettings[PEColdPolIdx].SPMS_iPtAcceptanceProbability:=-1;
      {.update the new policy's data}
      FCDdgEntities[0].E_spmSettings[GSPMitmIdx].SPMS_iPtIsSet:=true;
      FCDdgEntities[0].E_spmSettings[GSPMitmIdx].SPMS_iPtAcceptanceProbability:=GSPMap;
      {.apply the SPMi modifiers to all existing colonies}
      PECmax:=length(FCDdgEntities[0].E_colonies)-1;
      if PECmax>0
      then
      begin
         PECcnt:=1;
         while PECcnt<=PECmax do
         begin
            {.apply the direct cohesion penalty if any}
            if PECmodCoh<>0
            then FCMgCSM_ColonyData_Upd(
               dCohesion
               ,0
               ,PECcnt
               ,PECapplyCohMod
               ,0
               ,gcsmptNone
               ,false
               );
            {.apply the SPMi modifiers if needed}
            if GSPMspmi.SPMI_modCohes<>0
            then FCMgCSM_ColonyData_Upd(
               dCohesion
               ,0
               ,PECcnt
               ,PECmodCoh
               ,0
               ,gcsmptNone
               ,false
               );
            if GSPMspmi.SPMI_modTens<>0
            then FCMgCSM_ColonyData_Upd(
               dTension
               ,0
               ,PECcnt
               ,PECmodTens
               ,0
               ,gcsmptNone
               ,false
               );
            if GSPMspmi.SPMI_modSec<>0
            then FCMgCSM_ColonyData_Upd(
               dSecurity
               ,0
               ,PECcnt
               ,0
               ,0
               ,gcsmptNone
               ,true
               );
            if GSPMspmi.SPMI_modEdu<>0
            then FCMgCSM_ColonyData_Upd(
               dInstruction
               ,0
               ,PECcnt
               ,PECmodEdu
               ,0
               ,gcsmptNone
               ,false
               );
            if (GSPMspmi.SPMI_modNat<>0)
               and (GSPMspmi.SPMI_modTens=0)
            then FCMgCSM_ColonyData_Upd(
               dBirthRate
               ,0
               ,PECcnt
               ,0
               ,0
               ,gcsmptNone
               ,false
               );
            if (GSPMspmi.SPMI_modHeal<>0)
               and (GSPMspmi.SPMI_modTens=0)
            then FCMgCSM_ColonyData_Upd(
               dHealth
               ,0
               ,PECcnt
               ,PECmodHeal
               ,0
               ,gcsmptNone
               ,false
               );
            inc(PECcnt);
         end; //==END== while PECcnt<=PECmax do ==//
      end; //==END== if PERmax>0 ==// }
   end
   else if not GSPMspmi.SPMI_isUnique2set
   then
   begin
      PECmax:=length(FCDdgEntities[0].E_colonies)-1;
      if (PECmax>0)
         and (PECapplyCohMod<>0)
      then
      begin
         PECcnt:=1;
         while PECcnt<=PECmax do
         begin
            {.apply the direct cohesion penalty if any}
            FCMgCSM_ColonyData_Upd(
               dCohesion
               ,0
               ,PECcnt
               ,PECapplyCohMod
               ,0
               ,gcsmptNone
               ,false
               );
            inc(PECcnt);
         end; //==END== while PECcnt<=PECmax do ==//
      end; //==END== if PERmax>0 ==//
      FCMgSPM_SPMI_Set(
         0
         ,GSPMitmIdx
         ,true
         );
      {.update the policy's data}
      FCDdgEntities[0].E_spmSettings[GSPMitmIdx].SPMS_iPtIsSet:=true;
      FCDdgEntities[0].E_spmSettings[GSPMitmIdx].SPMS_iPtAcceptanceProbability:=GSPMap;
   end; //==END== else if not GSPMspmi.SPMI_isUnique2set ==//
   if FCDdgEntities[0].E_spmSettings[GSPMitmIdx].SPMS_ucCost>0
   then FCDdgEntities[0].E_ucInAccount:=FCDdgEntities[0].E_ucInAccount-FCDdgEntities[0].E_spmSettings[GSPMitmIdx].SPMS_ucCost;
//   FCMumi_Faction_Upd(uiwSPMpolEnfList);
end;

procedure FCMgSPM_PolicyEnf_Process(const PEPent: integer);
{:Purpose: process the enforcement of a policy.
    Additions:
      -2010Dec28- *rem: policies doesn't have duration anymore (excepted for rejected ones).
      -2010Dec19- *fix: correctly calculate the reject cohesion penalties.
                  *mod: change massive reject color display to the correct one.
      -2010Dec16- *fix: correctly calculate the cohesion penalties.
      -2010Dec15- *add: mitigated acceptance, reject and massive reject.
      -2010Dec14- *add: complete acceptance completion.
}
{:DEV NOTES: the PEPent will be useful mainly for future post beta AI implementation.}
begin
   FCWinMain.FCWM_UMIFSh_AFlist.Enabled:=false;
   FCWinMain.FCWM_UMISh_CEFenforce.Enabled:=false;
   FCWinMain.FCWM_UMISh_CEFenforce.Visible:=false;
   FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Clear;
   GSPMrslt:=FCFgSPM_PolicyProc_DoTest(0);
   FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforced'));
   GSPMduration:=0;
   case GSPMrslt of
      gspmResMassRjct:
      begin
         GSPMcohPen:=-round((50-GSPMfap_x)/5);
         GSPMcohPenRej:=round(GSPMcohPen*0.5);
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(
            FCCFcolRed+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltMReject')+FCCFcolEND+' '+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltMassRej')
               +'<b>'+IntToStr(GSPMduration)+'</b> '
               +FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedMReject1')
               +'<b>'+FCCFcolRed+IntToStr(GSPMcohPen)+FCCFcolEND+'</b> '
               +FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedMReject2')
               +'<b>'+FCCFcolRed+IntToStr(GSPMcohPenRej)+FCCFcolEND+'</b> '
               +FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedMReject3')
            );
      end;
      gspmResReject:
      begin
         GSPMcohPen:=-round((40-GSPMfap_x)/6);
         GSPMcohPenRej:=round(GSPMcohPen*0.5);
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(
            FCCFcolOrge+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltReject')+FCCFcolEND+' '+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedReject')
               +'<b>'+IntToStr(GSPMduration)+'</b> '
               +FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedReject1')
               +'<b>'+FCCFcolRed+IntToStr(GSPMcohPen)+FCCFcolEND+'</b> '
               +FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedReject2')
               +'<b>'+FCCFcolRed+IntToStr(GSPMcohPenRej)+FCCFcolEND+'</b> '
               +FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedReject3')
            );
      end;
      gspmResFifFifty:
      begin
         GSPMcohPen:=-round((30-GSPMfap_x)/7.8);
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(
            FCCFcolYel+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltMitig')+FCCFcolEND+' '+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedFift')
               +'<b>'+IntToStr(GSPMduration)+'</b> '
               +FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedFift1')
               +'<b>'+FCCFcolRed+IntToStr(GSPMcohPen)+FCCFcolEND+'</b> '
               +FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedFift2')
            );
      end;
      gspmResAccept: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(
         FCCFcolGreen+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltComplAcc')+FCCFcolEND+' '+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedCAcc')
            +' <b>'+IntToStr(GSPMduration)+'</b> '
            +FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfEnforcedCAcc1')
         );
   end; //==END== case GSPMrslt of ==//
   FCWinMain.FCWM_UMISh_CEFcommit.Enabled:=true;
   FCWinMain.FCWM_UMISh_CEFretire.Enabled:=true;
end;

procedure FCMgSPM_PolicyEnf_Retire;
{:Purpose: end enforcement process: retire policy.
    Additions:
      -2010Dec19- *add: complete the routine.
}
var
   PERapplyCohMod
   ,PERcnt
   ,PERmax: integer;
begin
   PERapplyCohMod:=0;
   FCWinMain.FCWM_UMISh_CEFcommit.Enabled:=false;
   FCWinMain.FCWM_UMISh_CEFretire.Enabled:=false;
   FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Clear;
   case GSPMrslt of
      gspmResMassRjct:
      begin
         PERapplyCohMod:=GSPMcohPenRej;
         FCDdgEntities[0].E_spmSettings[GSPMitmIdx].SPMS_duration:=12;
      end;
      gspmResReject:
      begin
         PERapplyCohMod:=GSPMcohPenRej;
         FCDdgEntities[0].E_spmSettings[GSPMitmIdx].SPMS_duration:=6;
      end;
      gspmResFifFifty: FCDdgEntities[0].E_spmSettings[GSPMitmIdx].SPMS_duration:=3;
      gspmResAccept:
      begin
         FCWinMain.FCWM_UMIFSh_AFlist.Enabled:=true;
//         FCMumi_Faction_Upd(uiwSPMpolEnfRAP, true);
      end;
   end; //==END== case GSPMrslt of ==//
   if PERapplyCohMod<>0
   then
   begin
      PERmax:=length(FCDdgEntities[0].E_colonies)-1;
      if PERmax>0
      then
      begin
         PERcnt:=1;
         while PERcnt<=PERmax do
         begin
            FCMgCSM_ColonyData_Upd(
               dCohesion
               ,0
               ,PERcnt
               ,PERapplyCohMod
               ,0
               ,gcsmptNone
               ,false
               );
            inc(PERcnt);
         end;
      end; //==END== if PERmax>0 ==//

   end; //==END== if PERapplyCohMod>0 ==//
//   if FCDdgEntities[0].E_spmSettings[GSPMitmIdx].SPMS_duration>0
//   then FCMumi_Faction_Upd(uiwSPMpolEnfList);
end;

procedure FCMgSPM_SPMI_Retire(
   const SPMIRent
         ,SPMIRidx: integer
   );
{:Purpose: retire a chosen SPMi, and update the centralized modifiers and/or entity's data.
}
var
   SPMIRcohes
   ,SPMIRtens
   ,SPMIRsec
   ,SPMIRedu
   ,SPMIRnat
   ,SPMIRhealth
   ,SPMIRbureau
   ,SPMIRcorrupt
   ,SPMIRcnt
   ,SPMIRmax: integer;

   SPMIRcohSet
   ,SPMIRtensSet
   ,SPMIRsecSet
   ,SPMIReduSet
   ,SPMIRnatSet
   ,SPMIRhealSet
   ,SPMIRburSet
   ,SPMIRcorSet: boolean;

   SPMIRspmDat: TFCRdgSPMi;
begin
   SPMIRcohes:=0;
   SPMIRtens:=0;
   SPMIRsec:=0;
   SPMIRedu:=0;
   SPMIRnat:=0;
   SPMIRhealth:=0;
   SPMIRbureau:=0;
   SPMIRcorrupt:=0;
   SPMIRcohSet:=true;
   SPMIRtensSet:=true;
   SPMIRsecSet:=true;
   SPMIReduSet:=true;
   SPMIRnatSet:=true;
   SPMIRhealSet:=true;
   SPMIRspmDat:=FCFgSPM_SPMIData_Get(FCDdgEntities[SPMIRent].E_spmSettings[SPMIRidx].SPMS_token);
   if FCDdgEntities[SPMIRent].E_spmSettings[SPMIRidx].SPMS_isPolicy
   then
   begin
      FCDdgEntities[SPMIRent].E_spmSettings[SPMIRidx].SPMS_duration:=0;
      FCDdgEntities[SPMIRent].E_spmSettings[SPMIRidx].SPMS_iPtIsSet:=false;
      FCDdgEntities[SPMIRent].E_spmSettings[SPMIRidx].SPMS_iPtAcceptanceProbability:=-1;
   end;
   {.set reverse modifiers}
   if SPMIRspmDat.SPMI_modCohes>0
   then SPMIRcohes:=-SPMIRspmDat.SPMI_modCohes
   else if SPMIRspmDat.SPMI_modCohes<0
   then SPMIRcohes:=abs(SPMIRspmDat.SPMI_modCohes)
   else SPMIRcohSet:=false;
   if SPMIRspmDat.SPMI_modTens>0
   then SPMIRtens:=-SPMIRspmDat.SPMI_modTens
   else if SPMIRspmDat.SPMI_modTens<0
   then SPMIRtens:=abs(SPMIRspmDat.SPMI_modTens)
   else SPMIRtensSet:=false;
   if SPMIRspmDat.SPMI_modSec>0
   then SPMIRSec:=-SPMIRspmDat.SPMI_modSec
   else if SPMIRspmDat.SPMI_modSec<0
   then SPMIRSec:=abs(SPMIRspmDat.SPMI_modSec)
   else SPMIRSecSet:=false;
   if SPMIRspmDat.SPMI_modEdu>0
   then SPMIREdu:=-SPMIRspmDat.SPMI_modEdu
   else if SPMIRspmDat.SPMI_modEdu<0
   then SPMIREdu:=abs(SPMIRspmDat.SPMI_modEdu)
   else SPMIREduSet:=false;
   if SPMIRspmDat.SPMI_modNat>0
   then SPMIRNat:=-SPMIRspmDat.SPMI_modNat
   else if SPMIRspmDat.SPMI_modNat<0
   then SPMIRNat:=abs(SPMIRspmDat.SPMI_modNat)
   else SPMIRNatSet:=false;
   if SPMIRspmDat.SPMI_modHeal>0
   then SPMIRhealth:=-SPMIRspmDat.SPMI_modHeal
   else if SPMIRspmDat.SPMI_modHeal<0
   then SPMIRhealth:=abs(SPMIRspmDat.SPMI_modHeal)
   else SPMIRHealSet:=false;
   if SPMIRspmDat.SPMI_modBur>0
   then SPMIRbureau:=-SPMIRspmDat.SPMI_modBur
   else if SPMIRspmDat.SPMI_modBur<0
   then SPMIRbureau:=abs(SPMIRspmDat.SPMI_modBur)
   else SPMIRBurSet:=false;
   if SPMIRspmDat.SPMI_modCorr>0
   then SPMIRcorrupt:=-SPMIRspmDat.SPMI_modCorr
   else if SPMIRspmDat.SPMI_modCorr<0
   then SPMIRcorrupt:=abs(SPMIRspmDat.SPMI_modCorr)
   else SPMIRCorSet:=false;
   {.set the entity's SPM modifiers}
   if SPMIRcohSet
   then FCDdgEntities[SPMIRent].E_spmMod_Cohesion:=FCDdgEntities[SPMIRent].E_spmMod_Cohesion+SPMIRcohes;
   if SPMIRtensSet
   then FCDdgEntities[SPMIRent].E_spmMod_Tension:=FCDdgEntities[SPMIRent].E_spmMod_Tension+SPMIRtens;
   if SPMIRSecSet
   then FCDdgEntities[SPMIRent].E_spmMod_Security:=FCDdgEntities[SPMIRent].E_spmMod_Security+SPMIRsec;
   if SPMIREduSet
   then FCDdgEntities[SPMIRent].E_spmMod_Education:=FCDdgEntities[SPMIRent].E_spmMod_Education+SPMIRedu;
   if SPMIRNatSet
   then FCDdgEntities[SPMIRent].E_spmMod_Natality:=FCDdgEntities[SPMIRent].E_spmMod_Natality+SPMIRnat;
   if SPMIRhealSet
   then FCDdgEntities[SPMIRent].E_spmMod_Health:=FCDdgEntities[SPMIRent].E_spmMod_Health+SPMIRhealth;
   if SPMIRburSet
   then
   begin
      FCDdgEntities[SPMIRent].E_spmMod_Bureaucracy:=FCDdgEntities[SPMIRent].E_spmMod_Bureaucracy+SPMIRbureau;
      FCDdgEntities[SPMIRent].E_bureaucracy:=FCDdgEntities[SPMIRent].E_bureaucracy+SPMIRbureau;
   end;
   if SPMIRcorSet
   then
   begin
      FCDdgEntities[SPMIRent].E_spmMod_Corruption:=FCDdgEntities[SPMIRent].E_spmMod_Corruption+SPMIRcorrupt;
      FCDdgEntities[SPMIRent].E_corruption:=FCDdgEntities[SPMIRent].E_corruption+SPMIRcorrupt;
   end;
   {.update the colonies}
   SPMIRmax:=length(FCDdgEntities[SPMIRent].E_colonies)-1;
   if SPMIRmax>0
   then
   begin
      SPMIRcnt:=1;
      while SPMIRcnt<=SPMIRmax do
      begin
         if SPMIRcohSet
         then FCMgCSM_ColonyData_Upd(
            dCohesion
            ,SPMIRent
            ,SPMIRcnt
            ,SPMIRcohes
            ,0
            ,gcsmptNone
            ,false
            );
         if SPMIRtensSet
         then
         begin
            if SPMIRhealSet
            then
            begin
               SPMIRnatSet:=false;
               SPMIRhealSet:=false;
            end;
            FCMgCSM_ColonyData_Upd(
               dTension
               ,SPMIRent
               ,SPMIRcnt
               ,SPMIRtens
               ,0
               ,gcsmptNone
               ,false
               );
         end;
         if SPMIRsecSet
         then FCMgCSM_ColonyData_Upd(
            dSecurity
            ,SPMIRent
            ,SPMIRcnt
            ,0
            ,0
            ,gcsmptNone
            ,true
            );
         if SPMIReduSet
         then FCMgCSM_ColonyData_Upd(
            dInstruction
            ,SPMIRent
            ,SPMIRcnt
            ,SPMIRedu
            ,0
            ,gcsmptNone
            ,false
            );
         if SPMIRnatSet
         then FCMgCSM_ColonyData_Upd(
            dBirthRate
            ,SPMIRent
            ,SPMIRcnt
            ,0
            ,0
            ,gcsmptNone
            ,false
            );
         if SPMIRhealSet
         then FCMgCSM_ColonyData_Upd(
            dHealth
            ,SPMIRent
            ,SPMIRcnt
            ,SPMIRnat
            ,0
            ,gcsmptNone
            ,false
            );
         inc(SPMIRcnt);
      end; //==END== while SPMIScnt<=SPMISmax do ==//
   end; //==END== if (SPMIScsmUpd) and (SPMISmax>0) ==//
end;

procedure FCMgSPM_SPMI_Set(
   const SPMISent
         , SPMISspmi: integer;
   const SPMIScsmUpd: boolean
   );
{:Purpose: set a chosen SPMi, and update the centralized modifiers and/or entity's data + the dependent CSM data if switched on.
    Additions:
      -2010Sep29- *add: bureaucray and corruption modifiers.
      -2010Sep26- *add: CSM data update for all colonies.
}
var
   SPMIScohes
   ,SPMIStens
   ,SPMISsec
   ,SPMISedu
   ,SPMISnat
   ,SPMIShealth
   ,SPMISbureau
   ,SPMIScorrupt
   ,SPMIScnt
   ,SPMISmax: integer;

   SPMIScohSet
   ,SPMIStensSet
   ,SPMISsecSet
   ,SPMISeduSet
   ,SPMISnatSet
   ,SPMIShealSet: boolean;

   SPMISspmDat: TFCRdgSPMi;
begin
   {.data init}
   SPMISspmDat:=FCDdgSPMi[0];
   SPMISbureau:=FCDdgEntities[SPMISent].E_bureaucracy;
   SPMIScorrupt:=FCDdgEntities[SPMISent].E_corruption;
   SPMIScohes:=FCDdgEntities[SPMISent].E_spmMod_Cohesion;
   SPMIStens:=FCDdgEntities[SPMISent].E_spmMod_Tension;
   SPMISsec:=FCDdgEntities[SPMISent].E_spmMod_Security;
   SPMISedu:=FCDdgEntities[SPMISent].E_spmMod_Education;
   SPMISnat:=FCDdgEntities[SPMISent].E_spmMod_Natality;
   SPMIShealth:=FCDdgEntities[SPMISent].E_spmMod_Health;
   SPMISbureau:=FCDdgEntities[SPMISent].E_spmMod_Bureaucracy;
   SPMIScorrupt:=FCDdgEntities[SPMISent].E_spmMod_Corruption;
   SPMIScohSet:=false;
   SPMIStensSet:=false;
   SPMISsecSet:=false;
   SPMISeduSet:=false;
   SPMISnatSet:=false;
   SPMIShealSet:=false;
   SPMISspmDat:=FCFgSPM_SPMIData_Get(FCDdgEntities[SPMISent].E_spmSettings[SPMISspmi].SPMS_token);
   {.update the SPM modifiers}
   if SPMISspmDat.SPMI_modCohes<>0
   then
   begin
      FCDdgEntities[SPMISent].E_spmMod_Cohesion:=SPMIScohes+SPMISspmDat.SPMI_modCohes;
      SPMIScohSet:=true;
   end;
   if SPMISspmDat.SPMI_modTens<>0
   then
   begin
      FCDdgEntities[SPMISent].E_spmMod_Tension:=SPMIStens+SPMISspmDat.SPMI_modTens;
      SPMIStensSet:=true;
   end;
   if SPMISspmDat.SPMI_modSec<>0
   then
   begin
      FCDdgEntities[SPMISent].E_spmMod_Security:=SPMISsec+SPMISspmDat.SPMI_modSec;
      SPMISsecSet:=true;
   end;
   if SPMISspmDat.SPMI_modEdu<>0
   then
   begin
      FCDdgEntities[SPMISent].E_spmMod_Education:=SPMISedu+SPMISspmDat.SPMI_modEdu;
      SPMISeduSet:=true;
   end;
   if SPMISspmDat.SPMI_modNat<>0
   then
   begin
      FCDdgEntities[SPMISent].E_spmMod_Natality:=SPMISnat+SPMISspmDat.SPMI_modNat;
      SPMISnatSet:=true;
   end;
   if SPMISspmDat.SPMI_modHeal<>0
   then
   begin
      FCDdgEntities[SPMISent].E_spmMod_Health:=SPMIShealth+SPMISspmDat.SPMI_modHeal;
      SPMIShealSet:=true;
   end;
   if SPMISspmDat.SPMI_modBur<>0
   then
   begin
      FCDdgEntities[SPMISent].E_spmMod_Bureaucracy:=SPMISbureau+SPMISspmDat.SPMI_modBur;
      FCDdgEntities[SPMISent].E_bureaucracy:=FCDdgEntities[SPMISent].E_bureaucracy+SPMISspmDat.SPMI_modBur;
   end;
   if SPMISspmDat.SPMI_modCorr<>0
   then
   begin
      FCDdgEntities[SPMISent].E_spmMod_Corruption:=SPMIScorrupt+SPMISspmDat.SPMI_modCorr;
      FCDdgEntities[SPMISent].E_corruption:=FCDdgEntities[SPMISent].E_corruption+SPMISspmDat.SPMI_modCorr;
   end;
   SPMISmax:=length(FCDdgEntities[SPMISent].E_colonies)-1;
   if (SPMIScsmUpd)
      and (SPMISmax>0)
   then
   begin
      SPMIScnt:=1;
      while SPMIScnt<=SPMISmax do
      begin
         if SPMIScohSet
         then FCMgCSM_ColonyData_Upd(
            dCohesion
            ,SPMISent
            ,SPMIScnt
            ,SPMISspmDat.SPMI_modCohes
            ,0
            ,gcsmptNone
            ,false
            );
         if SPMIStensSet
         then
         begin
            if SPMIShealSet
            then
            begin
               SPMIShealSet:=false;
               SPMISnatSet:=false;
            end;
            FCMgCSM_ColonyData_Upd(
               dTension
               ,SPMISent
               ,SPMIScnt
               ,SPMISspmDat.SPMI_modTens
               ,0
               ,gcsmptNone
               ,false
               );
         end;
         if SPMISsecSet
         then FCMgCSM_ColonyData_Upd(
            dSecurity
            ,SPMISent
            ,SPMIScnt
            ,0
            ,0
            ,gcsmptNone
            ,true
            );
         if SPMISeduSet
         then FCMgCSM_ColonyData_Upd(
            dInstruction
            ,SPMISent
            ,SPMIScnt
            ,SPMISspmDat.SPMI_modEdu
            ,0
            ,gcsmptNone
            ,false
            );
         if SPMISnatSet
         then FCMgCSM_ColonyData_Upd(
            dBirthRate
            ,SPMISent
            ,SPMIScnt
            ,0
            ,0
            ,gcsmptNone
            ,false
            );
         if SPMIShealSet
         then FCMgCSM_ColonyData_Upd(
            dHealth
            ,SPMISent
            ,SPMIScnt
            ,SPMISspmDat.SPMI_modHeal
            ,0
            ,gcsmptNone
            ,false
            );
         inc(SPMIScnt);
      end; //==END== while SPMIScnt<=SPMISmax do ==//
   end; //==END== if (SPMIScsmUpd) and (SPMISmax>0) ==//
end;

end.
