{=====(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved================

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: colony management

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

unit farc_game_colony;

interface

uses
   SysUtils

   ,farc_data_game
   ,farc_data_univ;

type TFCEgcAction=(
   gcaEstablished
   ,gcaRemoval
   );

type TFCEgcInfAsk=(
   gciaskNumOfHous
   ,gcSpecToken
   );

type TFCRgcEnvironment= record
   ENV_gravity: double;
   ENV_envType: TFCEduEnv;
   ENV_hydroTp: TFCEhydroTp;
end;

type TFCRgcInfraKit= array of record
   IK_index: integer;
   IK_token: string[20];
   IK_unit: integer;
   IK_infraLevel: integer;
end;

///<summary>
///   return the environment type of the specified colony. Include also the hydrosphere type, and the gravity
///</summary>
///   <param name="CEGTfac">faction index #</param>
///   <param name="CEGTcol">colony index #</param>
function FCFgC_ColEnv_GetTp( const CEGTfac, CEGTcol: integer ): TFCRgcEnvironment;

///<summary>
///   request specified data in a colony infrastructure sub-data structure
///</summary>
///   <param name="CIDRask">gciaskNumOfHous: return the # of housing, gcSpecToken: return the # of infra of a specified type</param>
///   <param name="CIDRfac">entity #</param>
///   <param name="CIDRcol">colony #</param>
///   <param name="CIDRsettle">settlement #</param>
///   <param name="CIDRtoken">infrastructure token, only w/ gcSpecToken</param>
function FCFgC_ColInfra_DReq(
   const CIDRask: TFCEgcInfAsk;
   const CIDRfac
         ,CIDRcol: integer;
   const CIDRtoken: string
   ): integer;

///<summary>
///   get the colony level index
///</summary>
function FCFgC_ColLvl_GetIdx(const CLGIfac, CLGIcol: integer): integer;

///<summary>
///   core system for colony creation/removal/data updating. Return the colony index.
///</summary>
///    <param name=""></param>
///    <param name=""></param>
function FCFgC_Colony_Core(
   const CCaction: TFCEgcAction;
   const CCfacId
         ,CClocSS
         ,CClocSt
         ,CClocOObj
         ,CClocSat: integer
   ): integer;

///<summary>
///   retrieve the HQ token status of a colony
///</summary>
///   <param name="HQGSent">entity #</param>
///   <param name="HQGScol">colony #</param>
function FCFgC_HQ_GetStr(const HQGSent, HQGScol: integer): string;

///<summary>
///   retrieve a dynamic array containing the list of infrastructure kits present in the colony's storage according to a give infrastructure
///</summary>
///   <param name="IKISRent">entity index #</param>
///   <param name="IKISRcol">colony index #</param>
///   <param name="IKISRinfraToken">infrastructure token to search</param>
function FCFgC_InfraKitsInStorage_Retrieve(
   const IKISRent
         ,IKISRcol
         ,IKISRset: integer;
   const IKISRinfraToken: string
   ): TFCRgcInfraKit;


///<summary>
///   retrieve the index # of a specified product contained in a specified colony's storage, with an option to create the storage's entry if not found
///</summary>
///   <param name="SRItoken">product's token</param>
///   <param name="SRIentity">entity index #</param>
///   <param name="SRIcolony">colony index #</param>
///   <param name="SRImustCreateIfNotFound">if true=> and the product isn't found in the storage, the entry is created</param>
///   <returns>the storage's index, 0 if not found and not created by SRImustCreateIfNotFound</returns>
function FCFgC_Storage_RetrieveIndex(
   const SRItoken: string;
   const SRIentity
         ,SRIcolony: integer;
   const SRImustCreateIfNotFound: boolean
   ): integer;

///<summary>
///   update the storage of a colony with a specific product. Return the amount in unit that couldn't be transfered
///</summary>
///   <param name="SUisStoreMode">if true=> the product is stored, if false=> the product is removed</param>
///   <param name="SUtoken">product's token</param>
///   <param name="SUunit">product's unit #</param>
///   <param name="SUtargetEnt">target entity #</param>
///   <param name="SUtargetCol">target colony #</param>
function FCFgC_Storage_Update(
   const SUisStoreMode: boolean;
   const SUtoken: string;
   const SUunit
         ,SUtargetEnt
         ,SUtargetCol: integer
   ): integer;     {:DEV NOTES: required parameters refactoring.}

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   remove the current HQ presence in a colony and see if there's no other HQ available. Update also the higher HQ level of the entity too
///</summary>
///   <param name="HQRent">entity index #</param>
///   <param name="HQRcol">colony index #</param>
procedure FCMgC_HQ_Remove( const HQRent, HQRcol: integer );

///<summary>
///   set the HQ of a designated colony to a new level
///</summary>
///   <param name="HQSent">entity index #</param>
///   <param name="HQScol">colony index #</param>
///   <param name="HQShqLevel">HQ level to set</param>
procedure FCMgC_HQ_Set(
   const HQSent
         ,HQScol: integer;
         HQShqLevel: TFCEdgHQstatus
   );

implementation

uses
   farc_common_func
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_game_csm
   ,farc_game_csmevents
   ,farc_game_infra
   ,farc_game_infracustomfx
   ,farc_game_prod
   ,farc_univ_func
   ,farc_win_debug;

var
   GCssys
   ,GCstar
   ,GCoobj
   ,GCsat: integer;

//===================================================END OF INIT============================

function FCFgC_ColEnv_GetTp( const CEGTfac, CEGTcol: integer ): TFCRgcEnvironment;
{:Purpose: return the environment type of the specified colony. Include also the hydrosphere type.
    Additions:
      -2011Oct23- *mod: orbital object indexes are now stored in unit's private data.
                  *mod: use the full row function to retrieve the indexes + remove useless code.
                  *add: retireve also the gravity.
                  *add: forgot to retrieve the hydrosphere type in case of a satellite.
      -2011Apr17- *add: include also the hydrosphere type.
      -2010Sep14- *add: entities code.
      -2010Aug29- *fix: correct the code concerning the satellite, this bug occurs to return gaseous even if it's for a telluric planet or asteroid.
}
var
   CEGTgravity: double;

   CEGToobjLoc: TFCRufStelObj;

   CEGTenv: TFCEduEnv;

   CEGThydro: TFCEhydroTp;
begin
   CEGTgravity:=0;
   CEGTenv:=gaseous;
   CEGThydro:=htNone;
   Result.ENV_gravity:=0;
   Result.ENV_envType:=gaseous;
   Result.ENV_hydroTp:=htNone;
   GCssys:=0;
   GCstar:=0;
   GCoobj:=0;
   GCsat:=0;
   CEGToobjLoc:=FCFuF_StelObj_GetFullRow(
      FCentities[CEGTfac].E_col[CEGTcol].COL_locSSys
      ,FCentities[CEGTfac].E_col[CEGTcol].COL_locStar
      ,FCentities[CEGTfac].E_col[CEGTcol].COL_locOObj
      ,FCentities[CEGTfac].E_col[CEGTcol].COL_locSat
      );
   if FCentities[CEGTfac].E_col[CEGTcol].COL_locSat='' then
   begin
      CEGTgravity:=FCDBSsys[ CEGToobjLoc[1] ].SS_star[ CEGToobjLoc[2] ].SDB_obobj[ CEGToobjLoc[3] ].OO_grav;
      CEGTenv:=FCDBSsys[ CEGToobjLoc[1] ].SS_star[ CEGToobjLoc[2] ].SDB_obobj[ CEGToobjLoc[3] ].OO_envTp;
      CEGThydro:=FCDBSsys[ CEGToobjLoc[1] ].SS_star[ CEGToobjLoc[2] ].SDB_obobj[ CEGToobjLoc[3] ].OO_hydrotp;
   end
   else if FCentities[CEGTfac].E_col[CEGTcol].COL_locSat<>'' then
   begin
      CEGTgravity:=FCDBSsys[ CEGToobjLoc[1] ].SS_star[ CEGToobjLoc[2] ].SDB_obobj[ CEGToobjLoc[3] ].OO_satList[ CEGToobjLoc[4] ].OOS_grav;
      CEGTenv:=FCDBSsys[ CEGToobjLoc[1] ].SS_star[ CEGToobjLoc[2] ].SDB_obobj[ CEGToobjLoc[3] ].OO_satList[ CEGToobjLoc[4] ].OOS_envTp;
      CEGThydro:=FCDBSsys[ CEGToobjLoc[1] ].SS_star[ CEGToobjLoc[2] ].SDB_obobj[ CEGToobjLoc[3] ].OO_satList[ CEGToobjLoc[4] ].OOS_hydrotp;
   end;
   Result.ENV_gravity:=CEGTgravity;
   Result.ENV_envType:=CEGTenv;
   Result.ENV_hydroTp:=CEGThydro;
end;

function FCFgC_ColInfra_DReq(
   const CIDRask: TFCEgcInfAsk;
   const CIDRfac
         ,CIDRcol: integer;
   const CIDRtoken: string
   ): integer;
{:Purpose: request specified data in a colony infrastructure sub-data structure.
    Additions:
      -2011Mar07- *add: infrastructure's environment.
                  *add: converted housing in the countinh of gciaskNumOfHous.
      -2011Feb12- *add: settlements specific code.
      -2010Nov04- *add: the missing testing code for gciaskNumOfHous for really count housing infrastructures.
                  *add: gcSpecToken switch + a CIDRtoken parameter.
      -2010Sep14- *add: entities code.
}
var
   CIDRinfraCnt
   ,CIDRinfraMax
   ,CIDRres
   ,CIDRsettleCnt
   ,CIDRsettleMax: integer;

   CIDRinfr: TFCRdipInfrastructure;
begin
   CIDRres:=0;
   CIDRsettleMax:=Length(FCentities[CIDRfac].E_col[CIDRcol].COL_settlements)-1;
   if CIDRsettleMax>0
   then
   begin
      CIDRsettleCnt:=1;
      while CIDRsettleCnt<=CIDRsettleMax do
      begin
         CIDRinfraMax:=length(FCentities[CIDRfac].E_col[CIDRcol].COL_settlements[CIDRsettleCnt].CS_infra)-1;
         CIDRinfraCnt:=1;
         while CIDRinfraCnt<=CIDRinfraMax do
         begin
            case CIDRask of
               {.number of housing infrastructures}
               gciaskNumOfHous:
               begin
                  CIDRinfr:=FCFgInf_DataStructure_Get(
                     CIDRfac
                     ,CIDRcol
                     ,FCentities[CIDRfac].E_col[CIDRcol].COL_settlements[CIDRsettleCnt].CS_infra[CIDRinfraCnt].CI_dbToken
                     );
                  if CIDRinfr.I_function=fHousing
                  then inc(CIDRres);
               end;
               {.return the number of infrastructures of a specified type token}
               gcSpecToken:
               begin
                  if FCentities[CIDRfac].E_col[CIDRcol].COL_settlements[CIDRsettleCnt].CS_infra[CIDRinfraCnt].CI_dbToken=CIDRtoken
                  then inc(CIDRres);
               end;
            end;
            inc(CIDRinfraCnt);
         end;
         inc(CIDRsettleCnt);
      end;
   end;
   Result:=CIDRres;
end;

function FCFgC_ColLvl_GetIdx(const CLGIfac, CLGIcol: integer): integer;
{:Purpose: get the colony level index.
    Additions:
      -2010Sep14- *add: faction index # as parameter.
                  *add: entities code.
}
begin
   case FCentities[CLGIfac].E_col[CLGIcol].COL_level of
      cl1Outpost: Result:=1;
      cl2Base: Result:=2;
      cl3Comm: Result:=3;
      cl4Settl: Result:=4;
      cl5MajCol: Result:=5;
      cl6LocSt: Result:=6;
      cl7RegSt: Result:=7;
      cl8FedSt: Result:=8;
      cl9ContSt: Result:=9;
      cl10UniWrld: Result:=10;
   end;
end;

function FCFgC_Colony_Core(
   const CCaction: TFCEgcAction;
   const CCfacId
         ,CClocSS
         ,CClocSt
         ,CClocOObj
         ,CClocSat: integer
   ): integer;
{:Purpose: core system for colony creation/removal/data updating. Return the colony index.
    Additions:
      -2010Mar19- *add: for established - initialize the colony's storage.
      -2010Sep14- *add: entities code.
      -2010Aug29- *fix: put the 2 event after the colony location initialization (remove a bug for Colony Established event).
      -2010Aug03- *fix: trigger the etHealthEduRel CSM event BEFORE any other event and data dependencies.
      -2010Aug02- *add: set the Health-Relation CSM event for colony creation.
      -2010Jul21- *add: csmTime data + update the csm phase list.
      -2010May30- *mod: transform the method in a function.
      -2010May21- *add: infrastructure list initialization.
                  *add: colony's name initialization + foundation date + location.
      -2010May19- *add: load the created colony in the related orbital object data structure.
      -2010May17- *add: foundation: initialize colony events sub datastructure.
                  *add: foundation: trigger a Colony Foundation event, to the colony.
}
var
   CCcolIdx: integer;
begin
   Result:=0;
   if CCaction=gcaEstablished
   then
   begin
      setlength(FCentities[CCfacId].E_col, length(FCentities[CCfacId].E_col)+1);
      CCcolIdx:=length(FCentities[CCfacId].E_col)-1;
      FCentities[CCfacId].E_col[CCcolIdx].COL_name:='';
      FCentities[CCfacId].E_col[CCcolIdx].COL_fndYr:=FCRplayer.P_timeYr;
      FCentities[CCfacId].E_col[CCcolIdx].COL_fndMth:=FCRplayer.P_timeMth;
      FCentities[CCfacId].E_col[CCcolIdx].COL_fndDy:=FCRplayer.P_timeday;
      FCentities[CCfacId].E_col[CCcolIdx].COL_csmtime:=FCRplayer.P_timeTick+FCCwkTick;
      FCMgCSM_PhaseList_Upd(0, CCcolIdx);
      {.set the colony's location data}
      FCentities[CCfacId].E_col[CCcolIdx].COL_locSSys:=FCDBsSys[CClocSS].SS_token;
      FCentities[CCfacId].E_col[CCcolIdx].COL_locStar:=FCDBsSys[CClocSS].SS_star[CClocSt].SDB_token;
      FCentities[CCfacId].E_col[CCcolIdx].COL_locOObj:=FCDBsSys[CClocSS].SS_star[CClocSt].SDB_obobj[CClocOObj].OO_token;
      {.initialize colony's data}
      FCMgCSM_ColonyData_Init(0, CCcolIdx);
      {.update the orbital object colonies presence}
      if CClocSat=0
      then
      begin
         FCentities[CCfacId].E_col[CCcolIdx].COL_locSat:='';
         FCDBsSys[CClocSS].SS_star[CClocSt].SDB_obobj[CClocOObj].OO_colonies[CCfacId]:=CCcolIdx;
      end
      else if CClocSat>0
      then
      begin
         FCentities[CCfacId].E_col[CCcolIdx].COL_locSat:=FCDBsSys[CClocSS].SS_star[CClocSt].SDB_obobj[CClocOObj].OO_satList[CClocSat].OOS_token;
         FCDBsSys[CClocSS].SS_star[CClocSt].SDB_obobj[CClocOObj].OO_satList[CClocSat].OOS_colonies[CCfacId]:=CCcolIdx;
      end;
      {.trigger basic CSM events}
      FCMgCSME_Event_Trigger(
         etHealthEduRel
         ,CCfacId
         ,CCcolIdx
         ,0
         ,false
         );
      FCMgCSME_Event_Trigger(
         etColEstab
         ,CCfacId
         ,CCcolIdx
         ,0
         ,false
         );
      Result:=CCcolIdx;
   end;
end;

function FCFgC_HQ_GetStr(const HQGSent, HQGScol: integer): string;
{:Purpose: retrieve the HQ token status of a colony.
    Additions:
}
begin
   Result:='';
   case FCentities[HQGSent].E_col[HQGScol].COL_hqPres of
      dgNoHQ: Result:='UMIhqNo';
      dgBasicHQ: Result:='UMIhqBasic';
      dgSecHQ: Result:='UMIhqSec';
      dgPriUnHQ: Result:='UMIhqPrim';
   end;
end;

function FCFgC_InfraKitsInStorage_Retrieve(
   const IKISRent
         ,IKISRcol
         ,IKISRset: integer;
   const IKISRinfraToken: string
   ): TFCRgcInfraKit;
{:Purpose: retrieve a dynamic array containing the list of infrastructure kits present in the colony's storage according to a given infrastructure.
    Additions:
      -2011Jul03- *add: IK_infraLevel initialization.
      -2011Jul02- *add: a settlement # parameter.
                  *add: retrieve only the infrastructure kits that are allowed in the current settlement.
      -2011Jun29- *add: storage index.
}
   var
      IKISRcnt
      ,IKISRmax
      ,IKISRprodIndex
      ,IKISRresIndex: integer;
begin
   SetLength(Result, 1);
   IKISRresIndex:=0;
   IKISRmax:=Length(FCentities[IKISRent].E_col[IKISRcol].COL_storageList)-1;
   if IKISRmax>0
   then
   begin
      IKISRcnt:=1;
      while IKISRcnt<=IKISRmax do
      begin
         IKISRprodIndex:=FCFgP_Product_GetIndex(FCentities[IKISRent].E_col[IKISRcol].COL_storageList[IKISRcnt].CPR_token);
         if (FCDBProducts[IKISRprodIndex].PROD_function=prfuInfraKit)
            and (FCDBProducts[IKISRprodIndex].PROD_fInfKitToken=IKISRinfraToken)
            and (FCentities[IKISRent].E_col[IKISRcol].COL_settlements[IKISRset].CS_level>=FCDBProducts[IKISRprodIndex].PROD_fInfKitLevel)
         then
         begin
            inc(IKISRresIndex);
            SetLength(Result, IKISRresIndex+1);
            Result[IKISRresIndex].IK_index:=IKISRcnt;
            Result[IKISRresIndex].IK_token:=FCDBProducts[IKISRprodIndex].PROD_token;
            Result[IKISRresIndex].IK_unit:=round(FCentities[IKISRent].E_col[IKISRcol].COL_storageList[IKISRcnt].CPR_unit);
            Result[IKISRresIndex].IK_infraLevel:=FCDBProducts[IKISRprodIndex].PROD_fInfKitLevel;
         end;
         inc(IKISRcnt);
      end;
   end;
end;

function FCFgC_Storage_RetrieveIndex(
   const SRItoken: string;
   const SRIentity
         ,SRIcolony: integer;
   const SRImustCreateIfNotFound: boolean
   ): integer;
{:Purpose: retrieve the index # of a specified product contained in a specified colony's storage, with an option to create the storage's entry if not found.
    Additions:
}
begin
   Result:=0;
   {:DEV NOTES: put search code here.}
   if ( Result=0 )
      and ( SRImustCreateIfNotFound ) then
   begin
      FCFgC_Storage_Update(
         true
         ,SRItoken
         ,0
         ,SRIentity
         ,SRIcolony
         );
//      Result:=searchcounter+1;
   end;
end;

function FCFgC_Storage_Update(
   const SUisStoreMode: boolean;
   const SUtoken: string;
   const SUunit
         ,SUtargetEnt
         ,SUtargetCol: integer
   ): integer;
{:Purpose: update the storage of a colony with a specific product. Return the amount in unit that couldn't be transfered.
    Additions:
      -2011Dec05- *add: include the case when the parameter SUunit=0.
                  *code: some writing cleanup.
      -2011Jul04- *code cleanup.
      -2011May06- *add: complete the code for the case when SUisStoreMode = false.
}
var
   SUcnt
   ,SUindex
   ,SUmax
   ,SUnewUnit: integer;

   SUcapaLoaded
   ,SUvolToXfer: double;
begin
   Result:=0;
   SUcnt:=0;
   SUindex:=FCFgP_Product_GetIndex(SUtoken);
   SUmax:=length(FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList)-1;
   SUnewUnit:=0;
   SUcapaLoaded:=0;
   SUvolToXfer:=0;
   if SUmax>0 then
   begin
      SUcnt:=1;
      while SUcnt<=SUmax do
      begin
         if FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_token=SUtoken
         then break
         else if SUcnt=SUmax then
         begin
            inc(SUcnt);
            SetLength(FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList, SUcnt+1);
            break;
         end;
         inc(SUcnt);
      end;
   end
   else if SUmax<=0 then
   begin
      SUcnt:=1;
      SetLength(FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList, 2);
   end;
   if (SUisStoreMode)
      and (SUcnt>0) then
   begin
      if FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_token=''
      then FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_token:=SUtoken;
      if SUunit<=0
      then Result:=0
      else begin
         SUvolToXfer:=FCFcFunc_Rnd(cfrttpVolm3, FCDBProducts[SUindex].PROD_volByUnit*SUunit);
         case FCDBProducts[SUindex].PROD_storage of
            stSolid:
            begin
               SUcapaLoaded:=SUvolToXfer+FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacitySolidCurr;
               if SUcapaLoaded<=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacitySolidMax then
               begin
                  FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacitySolidCurr:=SUcapaLoaded;
                  FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit+SUunit;
                  Result:=0;
               end
               else begin
                  SUnewUnit:=trunc(
                     (FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacitySolidMax-FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacitySolidCurr)
                     /FCDBProducts[SUindex].PROD_volByUnit
                     );
                  if SUnewUnit=0
                  then Result:=SUunit
                  else begin
                     SUvolToXfer:=FCFcFunc_Rnd(cfrttpVolm3, FCDBProducts[SUindex].PROD_volByUnit*SUnewUnit);
                     FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacitySolidCurr:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacitySolidCurr+SUvolToXfer;
                     FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit+SUunit;
                     Result:=SUunit-SUnewUnit;
                  end;
               end;
            end;

            stLiquid:
            begin
               SUcapaLoaded:=SUvolToXfer+FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityLiquidCurr;
               if SUcapaLoaded<=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityLiquidMax then
               begin
                  FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityLiquidCurr:=SUcapaLoaded;
                  FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit+SUunit;
                  Result:=0;
               end
               else begin
                  SUnewUnit:=trunc(
                     (FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityLiquidMax-FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityLiquidCurr)
                     /FCDBProducts[SUindex].PROD_volByUnit
                     );
                  if SUnewUnit=0
                  then Result:=SUunit
                  else begin
                     SUvolToXfer:=FCFcFunc_Rnd(cfrttpVolm3, FCDBProducts[SUindex].PROD_volByUnit*SUnewUnit);
                     FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityLiquidCurr:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityLiquidCurr+SUvolToXfer;
                     FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit+SUunit;
                     Result:=SUunit-SUnewUnit;
                  end;
               end;
            end;

            stGas:
            begin
               SUcapaLoaded:=SUvolToXfer+FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityGasCurr;
               if SUcapaLoaded<=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityGasMax then
               begin
                  FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityGasCurr:=SUcapaLoaded;
                  FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit+SUunit;
                  Result:=0;
               end
               else begin
                  SUnewUnit:=trunc(
                     (FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityGasMax-FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityGasCurr)
                     /FCDBProducts[SUindex].PROD_volByUnit
                     );
                  if SUnewUnit=0
                  then Result:=SUunit
                  else
                  begin
                     SUvolToXfer:=FCFcFunc_Rnd(cfrttpVolm3, FCDBProducts[SUindex].PROD_volByUnit*SUnewUnit);
                     FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityGasCurr:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityGasCurr+SUvolToXfer;
                     FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit+SUunit;
                     Result:=SUunit-SUnewUnit;
                  end;
               end;
            end;

            stBiologic:
            begin
               SUcapaLoaded:=SUvolToXfer+FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityBioCurr;
               if SUcapaLoaded<=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityBioMax
               then
               begin
                  FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityBioCurr:=SUcapaLoaded;
                  FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit+SUunit;
                  Result:=0;
               end
               else
               begin
                  SUnewUnit:=trunc(
                     (FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityBioMax-FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityBioCurr)
                     /FCDBProducts[SUindex].PROD_volByUnit
                     );
                  if SUnewUnit=0
                  then Result:=SUunit
                  else
                  begin
                     SUvolToXfer:=FCFcFunc_Rnd(cfrttpVolm3, FCDBProducts[SUindex].PROD_volByUnit*SUnewUnit);
                     FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityBioCurr:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityBioCurr+SUvolToXfer;
                     FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit+SUunit;
                     Result:=SUunit-SUnewUnit;
                  end;
               end;
            end;
         end;  //==END== case FCDBProducts[SUindex].PROD_storage of ==//
      end; //==END== else begin of: if SUunit<=0 ==//
   end //==END== if (SUisStoreMode) and (SUcnt>0) ==//
   else if (not SUisStoreMode)
      and (SUcnt>0) then
   begin
      SUvolToXfer:=FCFcFunc_Rnd(cfrttpVolm3, FCDBProducts[SUindex].PROD_volByUnit*SUunit);
      case FCDBProducts[SUindex].PROD_storage of
         stSolid:
         begin
            SUcapaLoaded:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacitySolidCurr-SUvolToXfer;
            FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacitySolidCurr:=SUcapaLoaded;
            Result:=0;
         end;
         stLiquid:
         begin
            SUcapaLoaded:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityLiquidCurr-SUvolToXfer;
            FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityLiquidCurr:=SUcapaLoaded;
            Result:=0;
         end;
         stGas:
         begin
            SUcapaLoaded:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityGasCurr-SUvolToXfer;
            FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityGasCurr:=SUcapaLoaded;
            Result:=0;
         end;
         stBiologic:
         begin
            SUcapaLoaded:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityBioCurr-SUvolToXfer;
            FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storCapacityBioCurr:=SUcapaLoaded;
            Result:=0;
         end;
      end;  //==END== case FCDBProducts[SUindex].PROD_storage of ==//
      FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit:=FCentities[SUtargetEnt].E_col[SUtargetCol].COL_storageList[SUcnt].CPR_unit-SUunit;
   end
   else begin
      Result:=SUunit;
   end;
end;
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgC_HQ_Remove( const HQRent, HQRcol: integer );
{:Purpose: remove the current HQ presence in a colony and see if there's no other HQ available. Update also the higher HQ level of the entity too.
    Additions:
}
   var
      HQRcolCnt
      ,HQRcolMax
      ,HQRinfraCnt
      ,HQRinfraMax
      ,HQRsetCnt
      ,HQRsetMax: integer;

      HQRhigherHQfound
      ,HQRsearchResult: TFCEdgHQstatus;

      HQRinfraData: TFCRdipInfrastructure;

begin
   HQRhigherHQfound:=dgNoHQ;
   HQRsetMax:=Length(FCentities[HQRent].E_col[HQRcol].COL_settlements)-1;
   HQRsetCnt:=1;
   while HQRsetCnt<=HQRsetMax do
   begin
      HQRinfraMax:=Length(FCentities[HQRent].E_col[HQRcol].COL_settlements[HQRsetCnt].CS_infra)-1;
      HQRinfraCnt:=1;
      while HQRinfraCnt<=HQRinfraMax do
      begin
         if (FCentities[HQRent].E_col[HQRcol].COL_settlements[HQRsetCnt].CS_infra[HQRinfraCnt].CI_function=fHousing)
            or (FCentities[HQRent].E_col[HQRcol].COL_settlements[HQRsetCnt].CS_infra[HQRinfraCnt].CI_function=fMiscellaneous)
         then
         begin
            HQRinfraData:=FCFgInf_DataStructure_Get(
               HQRent
               ,HQRcol
               ,FCentities[HQRent].E_col[HQRcol].COL_settlements[HQRsetCnt].CS_infra[HQRinfraCnt].CI_dbToken
               );
            HQRsearchResult:=FCFgICFX_EffectHQ_Search( HQRinfraData );
            if HQRsearchResult>HQRhigherHQfound
            then HQRhigherHQfound:=HQRsearchResult;
         end;
         inc(HQRinfraCnt);
      end;
      inc(HQRsetCnt);
   end;
   FCentities[HQRent].E_col[HQRcol].COL_hqPres:=HQRhigherHQfound;
   HQRcolMax:=Length(FCentities[HQRent].E_col)-1;
   HQRcolCnt:=1;
   while HQRcolCnt<=HQRcolMax do
   begin
      if FCentities[HQRent].E_col[HQRcolCnt].COL_hqPres>FCentities[HQRent].E_hqHigherLvl
      then FCentities[HQRent].E_col[HQRcolCnt].COL_hqPres:=FCentities[HQRent].E_hqHigherLvl;
      inc(HQRcolCnt);
   end;
end;

procedure FCMgC_HQ_Set(
   const HQSent
         ,HQScol: integer;
         HQShqLevel: TFCEdgHQstatus
   );
{:Purpose: set the HQ of a designated colony to a new level.
    Additions:
      -2011Aug09- *fix: set the COL_hqPres only if the current one < HQShqLevel.
}
begin
   if FCentities[HQSent].E_col[HQScol].COL_hqPres<HQShqLevel
   then FCentities[HQSent].E_col[HQScol].COL_hqPres:=HQShqLevel;
   if FCentities[HQSent].E_hqHigherLvl<HQShqLevel
   then FCentities[HQSent].E_hqHigherLvl:=HQShqLevel;
end;

end.
