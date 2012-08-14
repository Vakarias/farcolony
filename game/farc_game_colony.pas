{=====(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved================

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: colony management

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
   ENV_gravity: extended;
   ENV_envType: TFCEduEnvironmentTypes;
   ENV_hydroTp: TFCEduHydrospheres;
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
///   add and initialize a new settlement for a colony
///</summary>
///   <param name="entity">entity  index #</param>
///   <param name="colony">colony index #</param>
///   <param name="region">settlement's region index #</param>
///   <param name="settlementType">type of settlement in enum index #</param>
///   <param name="settlementName">personalized name of the settlement</param>
///   <returns>the new settlement index #</returns>
function FCFgC_Settlement_Add(
   const Entity
         ,Colony
         ,Region
         ,SettlementType: integer;
   const SettlementName: string
   ): integer;

///<summary>
///   get the settlement index# of a given colony's region #
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="Region">region index #</param>
function FCFgC_Settlement_GetIndexFromRegion(
   const Entity
         ,Colony
         ,Region: integer
   ): integer;

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
///   update the storage of a colony with a specific product
///</summary>
///   <param name="SUtoken">product's token</param>
///   <param name="SUunit">product's unit # in + or -</param>
///   <param name="SUtargetEnt">target entity #</param>
///   <param name="SUtargetCol">target colony #</param>
///   <returns>amount in unit that couldn't be transfered</returns>
function FCFgC_Storage_Update(
   const ProductToken: string;
         UnitToTransfer: extended;
   const Entity
         ,Colony: integer;
   const isUpdateReserves: boolean
   ): extended;     {:DEV NOTES: required parameters refactoring.}

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
         HQShqLevel: TFCEdgHeadQuarterStatus
   );

implementation

uses
   farc_common_func
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_game_colonyrves
   ,farc_game_csm
   ,farc_game_csmevents
   ,farc_game_infra
   ,farc_game_infracustomfx
   ,farc_game_prod
   ,farc_ui_coredatadisplay
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
   CEGTgravity: extended;

   CEGToobjLoc: TFCRufStelObj;

   CEGTenv: TFCEduEnvironmentTypes;

   CEGThydro: TFCEduHydrospheres;
begin
   CEGTgravity:=0;
   CEGTenv:=etGaseous;
   CEGThydro:=hNoH2O;
   Result.ENV_gravity:=0;
   Result.ENV_envType:=etGaseous;
   Result.ENV_hydroTp:=hNoH2O;
   GCssys:=0;
   GCstar:=0;
   GCoobj:=0;
   GCsat:=0;
   CEGToobjLoc:=FCFuF_StelObj_GetFullRow(
      FCentities[CEGTfac].E_col[CEGTcol].C_locationStarSystem
      ,FCentities[CEGTfac].E_col[CEGTcol].C_locationStar
      ,FCentities[CEGTfac].E_col[CEGTcol].C_locationOrbitalObject
      ,FCentities[CEGTfac].E_col[CEGTcol].C_locationSatellite
      );
   if FCentities[CEGTfac].E_col[CEGTcol].C_locationSatellite='' then
   begin
      CEGTgravity:=FCDduStarSystem[ CEGToobjLoc[1] ].SS_stars[ CEGToobjLoc[2] ].S_orbitalObjects[ CEGToobjLoc[3] ].OO_gravity;
      CEGTenv:=FCDduStarSystem[ CEGToobjLoc[1] ].SS_stars[ CEGToobjLoc[2] ].S_orbitalObjects[ CEGToobjLoc[3] ].OO_environment;
      CEGThydro:=FCDduStarSystem[ CEGToobjLoc[1] ].SS_stars[ CEGToobjLoc[2] ].S_orbitalObjects[ CEGToobjLoc[3] ].OO_hydrosphere;
   end
   else if FCentities[CEGTfac].E_col[CEGTcol].C_locationSatellite<>'' then
   begin
      CEGTgravity:=FCDduStarSystem[ CEGToobjLoc[1] ].SS_stars[ CEGToobjLoc[2] ].S_orbitalObjects[ CEGToobjLoc[3] ].OO_satellitesList[ CEGToobjLoc[4] ].OO_gravity;
      CEGTenv:=FCDduStarSystem[ CEGToobjLoc[1] ].SS_stars[ CEGToobjLoc[2] ].S_orbitalObjects[ CEGToobjLoc[3] ].OO_satellitesList[ CEGToobjLoc[4] ].OO_environment;
      CEGThydro:=FCDduStarSystem[ CEGToobjLoc[1] ].SS_stars[ CEGToobjLoc[2] ].S_orbitalObjects[ CEGToobjLoc[3] ].OO_satellitesList[ CEGToobjLoc[4] ].OO_hydrosphere;
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
   CIDRsettleMax:=Length(FCentities[CIDRfac].E_col[CIDRcol].C_settlements)-1;
   if CIDRsettleMax>0
   then
   begin
      CIDRsettleCnt:=1;
      while CIDRsettleCnt<=CIDRsettleMax do
      begin
         CIDRinfraMax:=length(FCentities[CIDRfac].E_col[CIDRcol].C_settlements[CIDRsettleCnt].S_infrastructures)-1;
         CIDRinfraCnt:=1;
         while CIDRinfraCnt<=CIDRinfraMax do
         begin
            case CIDRask of
               {.number of housing infrastructures}
               gciaskNumOfHous:
               begin
                  CIDRinfr:=FCFgI_DataStructure_Get(
                     CIDRfac
                     ,CIDRcol
                     ,FCentities[CIDRfac].E_col[CIDRcol].C_settlements[CIDRsettleCnt].S_infrastructures[CIDRinfraCnt].I_token
                     );
                  if CIDRinfr.I_function=fHousing
                  then inc(CIDRres);
               end;
               {.return the number of infrastructures of a specified type token}
               gcSpecToken:
               begin
                  if FCentities[CIDRfac].E_col[CIDRcol].C_settlements[CIDRsettleCnt].S_infrastructures[CIDRinfraCnt].I_token=CIDRtoken
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
   case FCentities[CLGIfac].E_col[CLGIcol].C_level of
      cl1Outpost: Result:=1;
      cl2Base: Result:=2;
      cl3Community: Result:=3;
      cl4Settlement: Result:=4;
      cl5MajorColony: Result:=5;
      cl6LocalState: Result:=6;
      cl7RegionalState: Result:=7;
      cl8FederatedStates: Result:=8;
      cl9ContinentalState: Result:=9;
      cl10UnifiedWorld: Result:=10;
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
      -2012Apr16- *fix: bugfix in the attribution of the oxygen reserve.
      -2012Apr15- *add: set the oxygen reserve, according to the colony's environment type.
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

   ColonyEnvironment: TFCEduEnvironmentTypes;
begin
   Result:=0;
   if CCaction=gcaEstablished
   then
   begin
      setlength(FCentities[CCfacId].E_col, length(FCentities[CCfacId].E_col)+1);
      CCcolIdx:=length(FCentities[CCfacId].E_col)-1;
      FCentities[CCfacId].E_col[CCcolIdx].C_name:='';
      FCentities[CCfacId].E_col[CCcolIdx].C_foundationDateYear:=FCRplayer.P_currentTimeYear;
      FCentities[CCfacId].E_col[CCcolIdx].C_foundationDateMonth:=FCRplayer.P_currentTimeMonth;
      FCentities[CCfacId].E_col[CCcolIdx].C_foundationDateDay:=FCRplayer.P_currentTimeDay;
      FCentities[CCfacId].E_col[CCcolIdx].C_nextCSMsessionInTick:=FCRplayer.P_currentTimeTick+FCCwkTick;
      FCMgCSM_PhaseList_Upd(0, CCcolIdx);
      {.set the colony's location data}
      FCentities[CCfacId].E_col[CCcolIdx].C_locationStarSystem:=FCDduStarSystem[CClocSS].SS_token;
      FCentities[CCfacId].E_col[CCcolIdx].C_locationStar:=FCDduStarSystem[CClocSS].SS_stars[CClocSt].S_token;
      FCentities[CCfacId].E_col[CCcolIdx].C_locationOrbitalObject:=FCDduStarSystem[CClocSS].SS_stars[CClocSt].S_orbitalObjects[CClocOObj].OO_dbTokenId;
      {.initialize colony's data}
      FCMgCSM_ColonyData_Init(0, CCcolIdx);
      {.update the orbital object colonies presence, and secondary, retrieve the environment}
      if CClocSat=0
      then
      begin
         FCentities[CCfacId].E_col[CCcolIdx].C_locationSatellite:='';
         FCDduStarSystem[CClocSS].SS_stars[CClocSt].S_orbitalObjects[CClocOObj].OO_colonies[CCfacId]:=CCcolIdx;
         ColonyEnvironment:=FCDduStarSystem[CClocSS].SS_stars[CClocSt].S_orbitalObjects[CClocOObj].OO_environment;
      end
      else if CClocSat>0
      then
      begin
         FCentities[CCfacId].E_col[CCcolIdx].C_locationSatellite:=FCDduStarSystem[CClocSS].SS_stars[CClocSt].S_orbitalObjects[CClocOObj].OO_satellitesList[CClocSat].OO_dbTokenId;
         FCDduStarSystem[CClocSS].SS_stars[CClocSt].S_orbitalObjects[CClocOObj].OO_satellitesList[CClocSat].OO_colonies[CCfacId]:=CCcolIdx;
         ColonyEnvironment:=FCDduStarSystem[CClocSS].SS_stars[CClocSt].S_orbitalObjects[CClocOObj].OO_satellitesList[CClocSat].OO_environment;
      end;
      if ColonyEnvironment=etFreeLiving
      then FCentities[CCfacId].E_col[CCcolIdx].C_reserveOxygen:=-1;
      {.trigger basic CSM events}
      FCMgCSME_Event_Trigger(
         ceHealthEducationRelation
         ,CCfacId
         ,CCcolIdx
         ,0
         ,false
         );
      FCMgCSME_Event_Trigger(
         ceColonyEstablished
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
   case FCentities[HQGSent].E_col[HQGScol].C_hqPresence of
      hqsNoHQPresent: Result:='UMIhqNo';
      hqsBasicHQ: Result:='UMIhqBasic';
      hqsSecondaryHQ: Result:='UMIhqSec';
      hqsPrimaryUniqueHQ: Result:='UMIhqPrim';
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
   IKISRmax:=Length(FCentities[IKISRent].E_col[IKISRcol].C_storedProducts)-1;
   if IKISRmax>0
   then
   begin
      IKISRcnt:=1;
      while IKISRcnt<=IKISRmax do
      begin
         IKISRprodIndex:=FCFgP_Product_GetIndex(FCentities[IKISRent].E_col[IKISRcol].C_storedProducts[IKISRcnt].SP_token);
         if (FCDdipProducts[IKISRprodIndex].P_function=pfInfrastructureKit)
            and (FCDdipProducts[IKISRprodIndex].P_fIKtoken=IKISRinfraToken)
            and (FCentities[IKISRent].E_col[IKISRcol].C_settlements[IKISRset].S_level>=FCDdipProducts[IKISRprodIndex].P_fIKlevel)
         then
         begin
            inc(IKISRresIndex);
            SetLength(Result, IKISRresIndex+1);
            Result[IKISRresIndex].IK_index:=IKISRcnt;
            Result[IKISRresIndex].IK_token:=FCDdipProducts[IKISRprodIndex].P_token;
            Result[IKISRresIndex].IK_unit:=round(FCentities[IKISRent].E_col[IKISRcol].C_storedProducts[IKISRcnt].SP_unit);
            Result[IKISRresIndex].IK_infraLevel:=FCDdipProducts[IKISRprodIndex].P_fIKlevel;
         end;
         inc(IKISRcnt);
      end;
   end;
end;

function FCFgC_Settlement_Add(
   const Entity
         ,Colony
         ,Region
         ,SettlementType: integer;
   const SettlementName: string
   ): integer;
{:Purpose: add and initialize a new settlement for a colony.
    Additions:
      -2011Dec20- *mod: move the function into the farc_game_colony unit.
                  *code audit:
                  (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                  (x)parameters refactoring           (x) ()reformatting         (x)code optimizations
                  (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                  (x)summary completion
      -2011Mar09- *add: initialize the corresponding CAB queue range.
      -2011Feb14- *add: set region's settlement data.
}
   var
      Max: integer;

      OobjLocation: TFCRufStelObj;
begin
   Result:=0;
   OobjLocation[1]:=OobjLocation[0];
   OobjLocation[2]:=OobjLocation[0];
   OobjLocation[3]:=OobjLocation[0];
   OobjLocation[4]:=OobjLocation[0];
   OobjLocation:=FCFuF_StelObj_GetFullRow(
      FCentities[ Entity ].E_col[ Colony ].C_locationStarSystem
      ,FCentities[ Entity ].E_col[ Colony ].C_locationStar
      ,FCentities[ Entity ].E_col[ Colony ].C_locationOrbitalObject
      ,FCentities[ Entity ].E_col[ Colony ].C_locationSatellite
      );
   Max:=length( FCentities[ Entity ].E_col[ Colony ].C_settlements );
   if Max<1
   then Max:=1;
   setlength( FCentities[ Entity ].E_col[ Colony ].C_settlements, Max+1 );
   FCentities[ Entity ].E_col[ Colony ].C_settlements[ Max ].S_name:=SettlementName;
   FCentities[ Entity ].E_col[ Colony ].C_settlements[ Max ].S_settlement:=TFCEdgSettlements( SettlementType );
   FCentities[ Entity ].E_col[ Colony ].C_settlements[ Max ].S_level:=1;
   FCentities[ Entity ].E_col[ Colony ].C_settlements[ Max ].S_locationRegion:=Region;
   setlength( FCentities[ Entity ].E_col[ Colony ].C_settlements[ Max ].S_infrastructures, 1 );
   if OobjLocation[4]>0 then
   begin
      FCDduStarSystem[OobjLocation[1]].SS_stars[OobjLocation[2]].S_orbitalObjects[OobjLocation[3]].OO_satellitesList[OobjLocation[4]].OO_regions[ Region ].OOR_settlementEntity:=Entity;
      FCDduStarSystem[OobjLocation[1]].SS_stars[OobjLocation[2]].S_orbitalObjects[OobjLocation[3]].OO_satellitesList[OobjLocation[4]].OO_regions[ Region ].OOR_settlementColony:=Colony;
      FCDduStarSystem[OobjLocation[1]].SS_stars[OobjLocation[2]].S_orbitalObjects[OobjLocation[3]].OO_satellitesList[OobjLocation[4]].OO_regions[ Region ].OOR_settlementIndex:=Max;
   end
   else begin
      FCDduStarSystem[OobjLocation[1]].SS_stars[OobjLocation[2]].S_orbitalObjects[OobjLocation[3]].OO_regions[ Region ].OOR_settlementEntity:=Entity;
      FCDduStarSystem[OobjLocation[1]].SS_stars[OobjLocation[2]].S_orbitalObjects[OobjLocation[3]].OO_regions[ Region ].OOR_settlementColony:=Colony;
      FCDduStarSystem[OobjLocation[1]].SS_stars[OobjLocation[2]].S_orbitalObjects[OobjLocation[3]].OO_regions[ Region ].OOR_settlementIndex:=Max;
   end;
   {.update the colony's CAB queue}
   if length( FCentities[ Entity ].E_col[Colony].C_cabQueue )<2
   then SetLength( FCentities[ Entity ].E_col[ Colony ].C_cabQueue, 2 )
   else SetLength( FCentities[ Entity ].E_col[ Colony ].C_cabQueue, length( FCentities[ Entity ].E_col[ Colony ].C_cabQueue )+1 );
   Result:=Max;
end;

function FCFgC_Settlement_GetIndexFromRegion(
   const Entity
         ,Colony
         ,Region: integer
   ): integer;
{:Purpose: get the settlement index# of a given colony's region #.
    Additions:
      -2011Jan25- *code: forgot to complete the code audit, done now.
      -2011Dec20- *mod: move the function into the farc_game_colony unit.
                  *code audit:
                  (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                  (x)parameters refactoring           (o) ()reformatting         (x)code optimizations
                  (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                  (x)summary completion
}
   var
      Count
      ,Max: integer;
begin
   Result:=0;
   Max:=length( FCentities[ Entity ].E_col[ Colony ].C_settlements )-1;
   Count:=1;
   while Count<=Max do
   begin
      if FCentities[ Entity ].E_col[ Colony ].C_settlements[ Count ].S_locationRegion=Region then
      begin
         Result:=Count;
         break;
      end;
      inc( Count );
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
   var
      SRIcount
      ,SRImax: integer;
begin
   Result:=0;
   SRImax:=Length( FCentities[ SRIentity ].E_col[ SRIcolony ].C_storedProducts )-1;
   SRIcount:=1;
   while SRIcount<=SRImax do
   begin
      if FCentities[ SRIentity ].E_col[ SRIcolony ].C_storedProducts[ SRIcount ].SP_token=SRItoken then
      begin
         Result:=SRIcount;
         Break;
      end;
      inc( SRIcount );
   end;
   if ( Result=0 )
      and ( SRImustCreateIfNotFound )then
   begin
      FCFgC_Storage_Update(
         SRItoken
         ,0
         ,SRIentity
         ,SRIcolony
         ,false
         );
      inc( SRImax );
      Result:=SRImax;
   end;
end;

function FCFgC_Storage_Update(
   const ProductToken: string;
         UnitToTransfer: extended;
   const Entity
         ,Colony: integer;
   const isUpdateReserves: boolean
   ): extended;
{:Purpose: update the storage of a colony with a specific product. Return the amount in unit that couldn't be transfered.
    Additions:
      -2012May21- *fix: protect all float add/sub w/ FCFcFunc_Rnds, there's a precision bug in delphi or x86 architecture.
                  *fix: apply corrections in storage creation.
      -2012May20- *code: complete rewrite (but w/o audits).
      -2012May17- *rem: SUisStoreMode, must use +/- now.
      -2012May13- *add: SUunit must be > 0 to apply the storage rule.
      -2012Apr30- *fix: FCMuiCDD_Colony_Update - update the colony panel if only it's the player's faction which is concerned.
      -2012Apr16- *add: COMPLETE reserves management.
      -2012Apr15- *add: reserves management.
      -2012Jan11- *fix: many consolidation and fixes in the calculations.
      -2011Dec19- *rem: remove the constant switch for the unit parameter.
                  *add: ensure that the unit parameter is always put with a positive sign (force it).
                  *add: not store mode - put a protection to avoid the current storage value to be <0.
      -2011Dec14- *mod: change the parameter SUunit type to double, since a stored product with volume by unit =1 can have units in formatted float (x.xxx) format.
                  *mod: change also the return value to double;
      -2011Dec06- *some code cleanup.
      -2011Dec05- *add: include the case when the parameter SUunit=0.
                  *code: some writing cleanup.
      -2011Jul04- *code cleanup.
      -2011May06- *add: complete the code for the case when SUisStoreMode = false.
}
var
   StorageIdxToUse
   ,ProductIndex
   ,MaxStorageIndex
   ,FoodReserveIndex: integer;

   CapacityLoaded
   ,FinalTransferedUnits
   ,TotalVolToTransfer: extended;
begin
   Result:=0;
   ProductIndex:=FCFgP_Product_GetIndex(ProductToken);
   MaxStorageIndex:=length(FCentities[Entity].E_col[Colony].C_storedProducts)-1;
   StorageIdxToUse:=1;
   {.the asked storage index is retrieved, if it doesn't exist, it'S automatically created}
   if MaxStorageIndex>0 then
   begin
      while StorageIdxToUse<=MaxStorageIndex do
      begin
         if FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_token=ProductToken
         then break
         else if StorageIdxToUse=MaxStorageIndex then
         begin
            inc(StorageIdxToUse);
            SetLength(FCentities[Entity].E_col[Colony].C_storedProducts, StorageIdxToUse+1);
            FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_token:=ProductToken;
            {.specific code for reserves}
            if FCDdipProducts[ ProductIndex ].P_function=pfFood then
            begin
               FoodReserveIndex:=Length( FCentities[Entity].E_col[Colony].C_reserveFoodProductsIndex );
               SetLength( FCentities[Entity].E_col[Colony].C_reserveFoodProductsIndex, FoodReserveIndex+1 );
               FCentities[Entity].E_col[Colony].C_reserveFoodProductsIndex[ FoodReserveIndex ]:=StorageIdxToUse;
            end;
            {.END specific code for reserves}
            break;
         end;
         inc(StorageIdxToUse);
      end;
   end
   else if MaxStorageIndex<=0 then
   begin
      StorageIdxToUse:=1;
      SetLength(FCentities[Entity].E_col[Colony].C_storedProducts, StorageIdxToUse+1);
      FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_token:=ProductToken;
   end;
   {.transfer process}
   if (UnitToTransfer<>0)
      and (StorageIdxToUse>0) then
   begin
      TotalVolToTransfer:=FCFgP_VolumeFromUnit_Get( ProductIndex, UnitToTransfer );
      case FCDdipProducts[ProductIndex].P_storage of
         stSolid:
         begin
            CapacityLoaded:=FCFcFunc_Rnd( cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storageCapacitySolidCurrent+TotalVolToTransfer );
            {.normally a case that shouldn't happen...}
            if CapacityLoaded<0 then
            begin
               CapacityLoaded:=0;
               FinalTransferedUnits:=FCFgP_UnitFromVolume_Get( ProductIndex, FCentities[Entity].E_col[Colony].C_storageCapacitySolidCurrent );
               FCentities[Entity].E_col[Colony].C_storageCapacitySolidCurrent:=0;
               FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=0;
               Result:=FCFcFunc_Rnd( cfrttpVolm3, UnitToTransfer-FinalTransferedUnits );
            end
            else if CapacityLoaded<=FCentities[Entity].E_col[Colony].C_storageCapacitySolidMax then
            begin
               FinalTransferedUnits:=UnitToTransfer;
               FCentities[Entity].E_col[Colony].C_storageCapacitySolidCurrent:=CapacityLoaded;
               FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=FCFcFunc_Rnd( cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit+FinalTransferedUnits );
               Result:=0;
            end
            else if CapacityLoaded>FCentities[Entity].E_col[Colony].C_storageCapacitySolidMax then
            begin
               FinalTransferedUnits:=FCFgP_UnitFromVolume_Get( ProductIndex, FCentities[Entity].E_col[Colony].C_storageCapacitySolidMax-FCentities[Entity].E_col[Colony].C_storageCapacitySolidCurrent );
               if FinalTransferedUnits=0
               then Result:=UnitToTransfer
               else begin
                  FCentities[Entity].E_col[Colony].C_storageCapacitySolidCurrent:=FCentities[Entity].E_col[Colony].C_storageCapacitySolidMax;
                  FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=FCFcFunc_Rnd( cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit+FinalTransferedUnits );
                  Result:=FCFcFunc_Rnd( cfrttpVolm3, UnitToTransfer-FinalTransferedUnits );
               end;
            end;
         end; //==END== case: stSolid ==//

         stLiquid:
         begin
            CapacityLoaded:=FCFcFunc_Rnd(cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storageCapacityLiquidCurrent+TotalVolToTransfer);
            {.normally a case that shouldn't happen...}
            if CapacityLoaded<0 then
            begin
               CapacityLoaded:=0;
               FinalTransferedUnits:=FCFgP_UnitFromVolume_Get( ProductIndex, FCentities[Entity].E_col[Colony].C_storageCapacityLiquidCurrent );
               FCentities[Entity].E_col[Colony].C_storageCapacityLiquidCurrent:=0;
               FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=0;
               Result:=FCFcFunc_Rnd( cfrttpVolm3, UnitToTransfer-FinalTransferedUnits );
            end
            else if CapacityLoaded<=FCentities[Entity].E_col[Colony].C_storageCapacityLiquidMax then
            begin
               FinalTransferedUnits:=UnitToTransfer;
               FCentities[Entity].E_col[Colony].C_storageCapacityLiquidCurrent:=CapacityLoaded;
               FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=FCFcFunc_Rnd( cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit+FinalTransferedUnits );
               Result:=0;
            end
            else if CapacityLoaded>FCentities[Entity].E_col[Colony].C_storageCapacityLiquidMax then
            begin
               FinalTransferedUnits:=FCFgP_UnitFromVolume_Get( ProductIndex, FCentities[Entity].E_col[Colony].C_storageCapacityLiquidMax-FCentities[Entity].E_col[Colony].C_storageCapacityLiquidCurrent );
               if FinalTransferedUnits=0
               then Result:=UnitToTransfer
               else begin
                  FCentities[Entity].E_col[Colony].C_storageCapacityLiquidCurrent:=FCentities[Entity].E_col[Colony].C_storageCapacityLiquidMax;
                  FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=FCFcFunc_Rnd( cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit+FinalTransferedUnits );
                  Result:=FCFcFunc_Rnd( cfrttpVolm3, UnitToTransfer-FinalTransferedUnits );
               end;
            end;
         end; //==END== stLiquid ==//

         stGas:
         begin
            CapacityLoaded:=FCFcFunc_Rnd( cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storageCapacityGasCurrent+TotalVolToTransfer);
            {.normally a case that shouldn't happen...}
            if CapacityLoaded<0 then
            begin
               CapacityLoaded:=0;
               FinalTransferedUnits:=FCFgP_UnitFromVolume_Get( ProductIndex, FCentities[Entity].E_col[Colony].C_storageCapacityGasCurrent );
               FCentities[Entity].E_col[Colony].C_storageCapacityGasCurrent:=0;
               FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=0;
               Result:=FCFcFunc_Rnd( cfrttpVolm3, UnitToTransfer-FinalTransferedUnits );
            end
            else if CapacityLoaded<=FCentities[Entity].E_col[Colony].C_storageCapacityGasMax then
            begin
               FinalTransferedUnits:=UnitToTransfer;
               FCentities[Entity].E_col[Colony].C_storageCapacityGasCurrent:=CapacityLoaded;
               FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=FCFcFunc_Rnd( cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit+FinalTransferedUnits );
               Result:=0;
            end
            else if CapacityLoaded>FCentities[Entity].E_col[Colony].C_storageCapacityGasMax then
            begin
               FinalTransferedUnits:=FCFgP_UnitFromVolume_Get( ProductIndex, FCentities[Entity].E_col[Colony].C_storageCapacityGasMax-FCentities[Entity].E_col[Colony].C_storageCapacityGasCurrent );
               if FinalTransferedUnits=0
               then Result:=UnitToTransfer
               else begin
                  FCentities[Entity].E_col[Colony].C_storageCapacityGasCurrent:=FCentities[Entity].E_col[Colony].C_storageCapacityGasMax;
                  FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=FCFcFunc_Rnd( cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit+FinalTransferedUnits );
                  Result:=FCFcFunc_Rnd( cfrttpVolm3, UnitToTransfer-FinalTransferedUnits );
               end;
            end;
         end; //==END== stGas ==//

         stBiologic:
         begin
            CapacityLoaded:=FCFcFunc_Rnd( cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storageCapacityBioCurrent+TotalVolToTransfer );
            {.normally a case that shouldn't happen...}
            if CapacityLoaded<0 then
            begin
               CapacityLoaded:=0;
               FinalTransferedUnits:=FCFgP_UnitFromVolume_Get( ProductIndex, FCentities[Entity].E_col[Colony].C_storageCapacityBioCurrent );
               FCentities[Entity].E_col[Colony].C_storageCapacityBioCurrent:=0;
               FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=0;
               Result:=FCFcFunc_Rnd( cfrttpVolm3, UnitToTransfer-FinalTransferedUnits );
            end
            else if CapacityLoaded<=FCentities[Entity].E_col[Colony].C_storageCapacityBioMax then
            begin
               FinalTransferedUnits:=UnitToTransfer;
               FCentities[Entity].E_col[Colony].C_storageCapacityBioCurrent:=CapacityLoaded;
               FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=FCFcFunc_Rnd( cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit+FinalTransferedUnits );
               Result:=0;
            end
            else if CapacityLoaded>FCentities[Entity].E_col[Colony].C_storageCapacityBioMax then
            begin
               FinalTransferedUnits:=FCFgP_UnitFromVolume_Get( ProductIndex, FCentities[Entity].E_col[Colony].C_storageCapacityBioMax-FCentities[Entity].E_col[Colony].C_storageCapacityBioCurrent );
               if FinalTransferedUnits=0
               then Result:=UnitToTransfer
               else
               begin
                  FCentities[Entity].E_col[Colony].C_storageCapacityBioCurrent:=FCentities[Entity].E_col[Colony].C_storageCapacityBioMax;
                  FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit:=FCFcFunc_Rnd( cfrttpVolm3, FCentities[Entity].E_col[Colony].C_storedProducts[StorageIdxToUse].SP_unit+FinalTransferedUnits );
                  Result:=FCFcFunc_Rnd( cfrttpVolm3, UnitToTransfer-FinalTransferedUnits );
               end;
            end;
         end;
      end;  //==END== case FCDBProducts[ProductIndex].PROD_storage of ==//
      {.specific code for reserves}
      if (isUpdateReserves)
         and (
            ( FCDdipProducts[ProductIndex].P_function=pfFood )
            or ( ( FCDdipProducts[ProductIndex].P_function=pfOxygen ) and ( FCentities[Entity].E_col[Colony].C_reserveOxygen<>-1 ) )
            or ( FCDdipProducts[ProductIndex].P_function=pfWater )
            ) then
      begin
         FCMgCR_Reserve_UpdateByUnits(
            Entity
            ,Colony
            ,FCDdipProducts[ProductIndex].P_function
            ,FinalTransferedUnits
            ,FCDdipProducts[ProductIndex].P_massByUnit
            );
         if Entity=0 then
         begin
            case FCDdipProducts[ProductIndex].P_function of
               pfFood: FCMuiCDD_Colony_Update(
                  cdlReserveFood
                  ,Colony
                  ,0
                  ,0
                  ,true
                  ,false
                  ,false
                  );

               pfOxygen: FCMuiCDD_Colony_Update(
                  cdlReserveOxy
                  ,Colony
                  ,0
                  ,0
                  ,true
                  ,false
                  ,false
                  );

               pfWater: FCMuiCDD_Colony_Update(
                  cdlReserveWater
                  ,Colony
                  ,0
                  ,0
                  ,true
                  ,false
                  ,false
                  );
            end;
         end;
      end;
   end //==END== if (UnitToTransfer<>0) and (StorageIdxToUse>0) then ==//
   else Result:=UnitToTransfer;
   if Entity=0
   then FCMuiCDD_Colony_Update(
      cdlStorageItem
      ,Colony
      ,StorageIdxToUse
      ,0
      ,true
      ,false
      ,false
      );
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
      ,HQRsearchResult: TFCEdgHeadQuarterStatus;

      HQRinfraData: TFCRdipInfrastructure;

begin
   HQRhigherHQfound:=hqsNoHQPresent;
   HQRsetMax:=Length(FCentities[HQRent].E_col[HQRcol].C_settlements)-1;
   HQRsetCnt:=1;
   while HQRsetCnt<=HQRsetMax do
   begin
      HQRinfraMax:=Length(FCentities[HQRent].E_col[HQRcol].C_settlements[HQRsetCnt].S_infrastructures)-1;
      HQRinfraCnt:=1;
      while HQRinfraCnt<=HQRinfraMax do
      begin
         if (FCentities[HQRent].E_col[HQRcol].C_settlements[HQRsetCnt].S_infrastructures[HQRinfraCnt].I_function=fHousing)
            or (FCentities[HQRent].E_col[HQRcol].C_settlements[HQRsetCnt].S_infrastructures[HQRinfraCnt].I_function=fMiscellaneous)
         then
         begin
            HQRinfraData:=FCFgI_DataStructure_Get(
               HQRent
               ,HQRcol
               ,FCentities[HQRent].E_col[HQRcol].C_settlements[HQRsetCnt].S_infrastructures[HQRinfraCnt].I_token
               );
            HQRsearchResult:=FCFgICFX_EffectHQ_Search( HQRinfraData );
            if HQRsearchResult>HQRhigherHQfound
            then HQRhigherHQfound:=HQRsearchResult;
         end;
         inc(HQRinfraCnt);
      end;
      inc(HQRsetCnt);
   end;
   FCentities[HQRent].E_col[HQRcol].C_hqPresence:=HQRhigherHQfound;
   HQRcolMax:=Length(FCentities[HQRent].E_col)-1;
   HQRcolCnt:=1;
   while HQRcolCnt<=HQRcolMax do
   begin
      if FCentities[HQRent].E_col[HQRcolCnt].C_hqPresence>FCentities[HQRent].E_hqHigherLvl
      then FCentities[HQRent].E_col[HQRcolCnt].C_hqPresence:=FCentities[HQRent].E_hqHigherLvl;
      inc(HQRcolCnt);
   end;
end;

procedure FCMgC_HQ_Set(
   const HQSent
         ,HQScol: integer;
         HQShqLevel: TFCEdgHeadQuarterStatus
   );
{:Purpose: set the HQ of a designated colony to a new level.
    Additions:
      -2011Aug09- *fix: set the COL_hqPres only if the current one < HQShqLevel.
}
begin
   if FCentities[HQSent].E_col[HQScol].C_hqPresence<HQShqLevel
   then FCentities[HQSent].E_col[HQScol].C_hqPresence:=HQShqLevel;
   if FCentities[HQSent].E_hqHigherLvl<HQShqLevel
   then FCentities[HQSent].E_hqHigherLvl:=HQShqLevel;
end;

end.
