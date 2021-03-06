{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: space units driven functions and procedures

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

unit farc_spu_functions;

interface

uses
   SysUtils

   ,farc_data_spu;

   {:DEV NOTES: put that in farc_data_spu, link it to TFCRdsuSpaceUnitDesign too!.}
type TFCEsufCapab=(
   sufcAny
   ,sufcInterstel
   ,sufcColoniz
   ,sufcPassngr
   ,sufcCombat
   );

type TFCEspufOrbIO=(
   spufoioAddOrbit
   ,spufoioRemOrbit
   );

type TFCRspufIndexes= array of integer;

///<summary>
///   get the choosen space unit status
///</summary>
///    <param name="ASGidxFac">space unit faction #</param>
///    <param name="ASGidxOwn">space unit index</param>
function FCFspuF_AttStatus_Get(const ASGfac, ASGidxOwn: integer): string;

///<summary>
///   get if an entity's space unit has an asked capability
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="SpaceUnit">entity's space unit index #</param>
///   <returns>true= has it</returns>
function FCFspuF_Capability_HasIt(
   const Entity
         ,SpaceUnit: integer;
   const Capability: TFCEsufCapab
   ): boolean;

///<summary>
///   get the orbital deltav of a given orbital object.
///</summary>
///    <param name="DVGFOstarsys">star system index</param>
///    <param name="DVGFOstar">star index</param>
///    <param name="DVGFOobobj">orbital object index</param>
function FCFspuF_DeltaV_GetFromOrbit(
   const DVGFOstarsys
         ,DVGFOstar
         ,DVGFOobobj
         ,DVGFOsat: integer
   ): extended;

///<summary>
///   retrieve db record number of given spacecraft internal structure/design token
///</summary>
///   <param name="ISDGBdsgnToken">design token id</param>
function FCFspuF_Design_getDB(const DGDBdsgnToken: string): integer;

///<summary>
///   get the index list of docked space units, of a specific architecture and/or capability.
///</summary>
///   <param name="DSUGNfac">faction index</param>
///   <param name="DSUGNidx">owned index</param>
///   <param name="DSUGNarch">architecture [optional]</param>
///   <param name="DSUGNcapab">capability [optional]</param>
function FCFspuF_DockedSpU_GetIndexList(
   const DSUGNfac
         ,DSUGNidx: integer;
   const DSUGNarch: TFCEdsuArchitectures;
   const DSUGNcapab: TFCEsufCapab
   ): TFCRspufIndexes;

///<summary>
///   get the number of docked space units, of a specific architecture and/or capability.
///</summary>
///   <param name="DSUGNfac">faction index</param>
///   <param name="DSUGNidx">owned index</param>
///   <param name="DSUGNarch">architecture [optional]</param>
///   <param name="DSUGNcapab">capability [optional]</param>
function FCFspuF_DockedSpU_GetNum(
   const DSUGNfac
         ,DSUGNidx: integer;
   const DSUGNarch: TFCEdsuArchitectures;
   const DSUGNcapab: TFCEsufCapab
   ): integer;

///<summary>
///   retrieve the index, in the mother craft docking list, of a docked space unit
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="MotherCraftDBIndex">mother craft db index #</param>
///   <param name="DockedCraftDBIndex">docked craft db index #</param>
///   <returns>mother craft docking list index</returns>
function FCFspuF_DockedSpU_RetrieveDockedIndex(
   const Entity
         ,MotherCraftDBIndex
         ,DockedCraftDBIndex: integer
         ): integer;

///<summary>
///   get the mission name assigned to the chosen space unit
///</summary>
///    <param name="MNGfac">faction index</param>
///    <param name="MNGidxOwn">owned space unit index</param>
function FCFspuF_Mission_GetMissName(const MNGfac, MNGidxOwn: integer): string;

///<summary>
///   get the phase name of the chosen space unit
///</summary>
///    <param name="MGPNfac">faction index</param>
///    <param name="MGPNspU">owned space unit index</param>
function FCFspuF_Mission_GetPhaseName(const MGPNfac, MGPNspU: integer): string;

///<summary>
///   search the corresponding space unit 3d object index regarding the owned #
///</summary>
///   <param name="SUOSfac">faction #</param>
///   <param name="SUOSidx">owned space unit #</param>
function FCFspuF_SpUObject_Search(const SUOSfac, SUOSidx: integer): integer;

///<summary>
///   remove the docked space unit specified by it's owned index #.
///</summary>
///   <param name="DSURmotherIdx">mother vessel owned index</param>
///   <param name="DSURdToken">docked token</param>
procedure FCMspuF_DockedSpU_Rem(
   const DSURfac
         ,DSURmotherIdx
         ,DSURdToken: integer
   );

///<summary>
///   add or remove a space unit in orbit of an orbital object
///</summary>
///   <param name="OPaction">action add/remove</param>
///   <param name="OPsSys">stellar system #</param>
///   <param name="OPstar">star #</param>
///   <param name="OPoobj">orbital object #</param>
///   <param name="OPsat">[optional, none=0] satellite #</param>
///   <param name="OPfac">faction #</param>
///   <param name="OPspuOwn">space unit owned list index #</param>
///   <param name="opUpd3dView">true= update the 3d view</param>
procedure FCMspuF_Orbits_Process(
   const OPaction: TFCEspufOrbIO;
   const OPsSys
         ,OPstar
         ,OPoobj
         ,OPsat
         ,OPfac
         ,OPspuOwn: integer;
   const opUpd3dView: boolean
   );

///<summary>
///   delete a chosen space unit from an faction's owned data structure
///</summary>
///   <param name=""></param>
///   <param name=""></param>
procedure FCMspuF_SpUnit_Remove(const Entity, TargetSpaceUnit: integer);

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_game
   ,farc_data_init
   ,farc_data_missionstasks
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_ogl_functions
   ,farc_ogl_viewmain
   ,farc_win_debug;

//===================================================END OF INIT============================

function FCFspuF_AttStatus_Get(const ASGfac, ASGidxOwn: integer): string;
{:Purpose: get the choosen space unit status.
    Additions:
      -2010Sep15- *mod: clean useless code w/ entities addition.
      -2010Sep13- *add: entities code.
      -2010Sep02- *code audit.
      -2010Jun06- *rem: clean useless function call.
      -2009Dec21- *add: set the correct status if the space unit is in orbit of a satellite.
      -2009Dec18- *add: get also the satellite index, if it's >0 then the space unit orbit a satellite.
      -2009Nov22- *give the full name, not the token.
                  *moved the function from farc_common_func.
                  *for in orbit, retrieve directly the orbital object name.
}
var
   ASGoobj
   ,ASGsat: string;

   ASGsatus: TFCEdgSpaceUnitStatus;
begin
   ASGoobj:=FCDdgEntities[ASGfac].E_spaceUnits[ASGidxOwn].SU_locationOrbitalObject;
   ASGsat:=FCDdgEntities[ASGfac].E_spaceUnits[ASGidxOwn].SU_locationSatellite;
   ASGsatus:=FCDdgEntities[ASGfac].E_spaceUnits[ASGidxOwn].SU_status;
   case ASGsatus of
      susInFreeSpace: result:=FCFdTFiles_UIStr_Get(uistrUI,'susInFreeSpace');
      susInOrbit:
      begin
         if ASGsat=''
         then result:=FCFdTFiles_UIStr_Get(uistrUI,'susInOrbit')+' '+FCFdTFiles_UIStr_Get(dtfscPrprName, ASGoobj)
         else if ASGsat<>''
         then result:=FCFdTFiles_UIStr_Get(uistrUI,'susInOrbit')+' '+FCFdTFiles_UIStr_Get(dtfscPrprName, ASGsat);
      end;
      susInAtmosphericFlightLandingTakeoff: result:=FCFdTFiles_UIStr_Get(uistrUI,'susInAtmosph');
      susLanded: result:=FCFdTFiles_UIStr_Get(uistrUI,'susLanded');
      susDocked: result:=FCFdTFiles_UIStr_Get(uistrUI,'susDocked');
      susOutOfControl: result:=FCFdTFiles_UIStr_Get(uistrUI,'susOutOfCtl');
      susDeadWreck: result:=FCFdTFiles_UIStr_Get(uistrUI,'susDeadWreck');
   end; //==END== case ASGsatus ==//
end;

function FCFspuF_Capability_HasIt(
   const Entity
         ,SpaceUnit: integer;
   const Capability: TFCEsufCapab
   ): boolean;
{:Purpose: get if an entity's space unit has an asked capability.
    Additions:
}
   var
      DesignIndex: integer;
begin
   DesignIndex:=0;
   Result:=false;
   DesignIndex:=FCFspuF_Design_getDB( FCDdgEntities[Entity].E_spaceUnits[SpaceUnit].SU_designToken );
   case Capability of
      sufcInterstel:
         if FCDdsuSpaceUnitDesigns[DesignIndex].SUD_capabilityInterstellarTransit
         then Result:=true;
      sufcColoniz:
         if FCDdsuSpaceUnitDesigns[DesignIndex].SUD_capabilityColonization
         then Result:=true;
      sufcPassngr:
         if FCDdsuSpaceUnitDesigns[DesignIndex].SUD_capabilityPassengers
         then Result:=true;
      sufcCombat:
         if FCDdsuSpaceUnitDesigns[DesignIndex].SUD_capabilityCombat
         then Result:=true;
   end; //==END== case Capability of ==//
end;

function FCFspuF_DeltaV_GetFromOrbit(
   const DVGFOstarsys
         ,DVGFOstar
         ,DVGFOobobj
         ,DVGFOsat: integer
   ): extended;
{:Purpose: get the orbital deltav of a given orbital object.
    Additions:
      -2010Sep02- *code audit.
      -2009Dec25- *add: satellite computing.
}
begin
   if DVGFOsat=0
   then Result:=FCFcF_Round(rttVelocityKmSec, FCDduStarSystem[DVGFOstarsys].SS_stars[DVGFOstar].S_orbitalObjects[DVGFOobobj].OO_escapeVelocity*0.83)
   else if DVGFOsat>0
   then Result:=FCFcF_Round(rttVelocityKmSec, FCDduStarSystem[DVGFOstarsys].SS_stars[DVGFOstar].S_orbitalObjects[DVGFOobobj].OO_satellitesList[DVGFOsat].OO_escapeVelocity*0.83);
end;

function FCFspuF_Design_getDB(const DGDBdsgnToken: string): integer;
{:Purpose: retrieve db record number of given spacecraft design token.
    Additions:
      -2010Sep02- *code audit.
                  *mod: remove the global variable CFVscraftDesgnDB and transform this procedure to a function which return desing db #.
      -2010Apr13- *mod: removed useless internal structure search
      -2010Mar28- *mod: moved the procedure to spu_functions.
      -2009Sep13- *retrieve design and internal structure id number in same time and put it
                  in global variable.
}
var
   DGDBcnt
   ,DGDBmax
   ,DGDBres: integer;
begin
   DGDBcnt:=0;
   DGDBres:=0;
   if DGDBdsgnToken=''
   then DGDBres:=-1
   else
   begin
      {.retrieve spacecraft design db}
      DGDBcnt:=1;
      DGDBmax:=Length(FCDdsuSpaceUnitDesigns)-1;
      while DGDBcnt<=DGDBmax do
      begin
         if FCDdsuSpaceUnitDesigns[DGDBcnt].SUD_token=DGDBdsgnToken
         then
         begin
            DGDBres:=DGDBcnt;
            Break;
         end
         else inc(DGDBcnt);
      end;
   end;
   Result:=DGDBres;
end;

function FCFspuF_DockedSpU_GetIndexList(
   const DSUGNfac
         ,DSUGNidx: integer;
   const DSUGNarch: TFCEdsuArchitectures;
   const DSUGNcapab: TFCEsufCapab
   ): TFCRspufIndexes;
{:Purpose: get the index list of docked space units, of a specific architecture and/or capability.
    Additions:
}
var
   Count
   ,DSUGNdesgn
   ,DSGUNdockIdx
   ,Max
   ,ResultIndex: integer;

   DSUGNresult: TFCRspufIndexes;

   procedure FCMdspuGIL_DockList_Update;
   begin
      inc( ResultIndex );
      SetLength( DSUGNresult, ResultIndex+1 );
      DSUGNresult[ResultIndex]:=DSGUNdockIdx;
   end;
begin
   SetLength( Result, 1 );
   SetLength( DSUGNresult, 1 );
   DSGUNdockIdx:=0;
   DSUGNresult:=0;
   DSUGNdesgn:=0;
   Count:=1;
   Max:=length(FCDdgEntities[DSUGNfac].E_spaceUnits[DSUGNidx].SU_dockedSpaceUnits)-1;
   ResultIndex:=0;
   while Count<=Max do
   begin
      DSGUNdockIdx:=FCDdgEntities[DSUGNfac].E_spaceUnits[DSUGNidx].SU_dockedSpaceUnits[Count].SUDL_index;
      DSUGNdesgn:=FCFspuF_Design_getDB(FCDdgEntities[DSUGNfac].E_spaceUnits[DSGUNdockIdx].SU_designToken);
      if (DSUGNarch=aNone)
         or (
            (DSUGNarch>aNone)
            and
            (FCDdsuSpaceUnitDesigns[DSUGNdesgn].SUD_internalStructureClone.IS_architecture=DSUGNarch)
            )
      then
      begin
         case DSUGNcapab of
            sufcAny: FCMdspuGIL_DockList_Update;

            sufcInterstel:
               if FCDdsuSpaceUnitDesigns[DSUGNdesgn].SUD_capabilityInterstellarTransit
               then FCMdspuGIL_DockList_Update;
            sufcColoniz:
               if FCDdsuSpaceUnitDesigns[DSUGNdesgn].SUD_capabilityColonization
               then FCMdspuGIL_DockList_Update;
            sufcPassngr:
               if FCDdsuSpaceUnitDesigns[DSUGNdesgn].SUD_capabilityPassengers
               then FCMdspuGIL_DockList_Update;
            sufcCombat:
               if FCDdsuSpaceUnitDesigns[DSUGNdesgn].SUD_capabilityCombat
               then FCMdspuGIL_DockList_Update;
         end;
      end; //==END== if DSUGNarch=scatNone ==//
      inc(Count);
   end; //==END== while DSUGNcnt<=DSUGNmax ==//
   SetLength( Result, length( DSUGNresult ) );
   Result:=DSUGNresult;
end;

function FCFspuF_DockedSpU_GetNum(
   const DSUGNfac
         ,DSUGNidx: integer;
   const DSUGNarch: TFCEdsuArchitectures;
   const DSUGNcapab: TFCEsufCapab
   ): integer;
{:Purpose: get the number of docked space units, of a specific architecture and/or capability.
    Additions:
      -2010Sep15- *mod: delete useless code after entities transformation.
      -2010Sep13- *add: a faction local data entry.
                  *add: entities code.
      -2010Sep02- *code audit.
                  *add: use a local variable for the design #.
}
var
   DSUGNcnt
   ,DSUGNdesgn
   ,DSGUNdockIdx
   ,DSUGNmax
   ,DSUGNresult: integer;
begin
   Result:=0;
   DSGUNdockIdx:=0;
   DSUGNresult:=0;
   DSUGNdesgn:=0;
   DSUGNcnt:=1;
   DSUGNmax:=length(FCDdgEntities[DSUGNfac].E_spaceUnits[DSUGNidx].SU_dockedSpaceUnits)-1;
   if DSUGNmax>0
   then
   begin
      while DSUGNcnt<=DSUGNmax do
      begin
         DSGUNdockIdx:=FCDdgEntities[DSUGNfac].E_spaceUnits[DSUGNidx].SU_dockedSpaceUnits[DSUGNcnt].SUDL_index;
         DSUGNdesgn:=FCFspuF_Design_getDB(FCDdgEntities[DSUGNfac].E_spaceUnits[DSGUNdockIdx].SU_designToken);
         if (DSUGNarch=aNone)
            or (
               (DSUGNarch>aNone)
               and
               (FCDdsuSpaceUnitDesigns[DSUGNdesgn].SUD_internalStructureClone.IS_architecture=DSUGNarch)
               )
         then
         begin
            case DSUGNcapab of
               sufcAny: inc(DSUGNresult);
               sufcInterstel:
                  if FCDdsuSpaceUnitDesigns[DSUGNdesgn].SUD_capabilityInterstellarTransit
                  then inc(DSUGNresult);
               sufcColoniz:
                  if FCDdsuSpaceUnitDesigns[DSUGNdesgn].SUD_capabilityColonization
                  then inc(DSUGNresult);
               sufcPassngr:
                  if FCDdsuSpaceUnitDesigns[DSUGNdesgn].SUD_capabilityPassengers
                  then inc(DSUGNresult);
               sufcCombat:
                  if FCDdsuSpaceUnitDesigns[DSUGNdesgn].SUD_capabilityCombat
                  then inc(DSUGNresult);
            end;
         end; //==END== if DSUGNarch=scatNone ==//
         inc(DSUGNcnt);
      end; //==END== while DSUGNcnt<=DSUGNmax ==//
   end; //==END== if DSUGNmax>0 ==//
   Result:=DSUGNresult;
end;

function FCFspuF_DockedSpU_RetrieveDockedIndex(
   const Entity
         ,MotherCraftDBIndex
         ,DockedCraftDBIndex: integer
         ): integer;
{:Purpose: retrieve the index, in the mother craft docking list, of a docked space unit.
    Additions:
}
   var
      Count
      ,Max: integer;
begin
   Result:=0;
   Count:=1;
   Max:=length( FCDdgEntities[Entity].E_spaceUnits[MotherCraftDBIndex].SU_dockedSpaceUnits )-1;
   while Count<=Max do
   begin
      if FCDdgEntities[Entity].E_spaceUnits[MotherCraftDBIndex].SU_dockedSpaceUnits[Count].SUDL_index=DockedCraftDBIndex then
      begin
         Result:=Count;
         break;
      end;
      inc( Count );
   end;
end;

function FCFspuF_Mission_GetMissName(const MNGfac, MNGidxOwn: integer): string;
{:Purpose: get the mission name assigned to the chosen space unit.
    Additions:
      -2012Dec09- *fix: forgot to update the strings.
      -2010Sep15- *mod: delete useless code after entities transformation.
      -2010Sep13- *add: entities code.
      -2010Sep06- *code audit.
      -2010Apr22- *add: colonization mission.
}
var
   MNGtask: integer; {:DEV NOTES: remove that!.}
begin
   MNGtask:=0;
   Result:='';
   MNGtask:=FCDdgEntities[MNGfac].E_spaceUnits[MNGidxOwn].SU_assignedTask;
   if MNGtask=0
   then Result:=FCFdTFiles_UIStr_Get(uistrUI,'spUnMissNone')
   else if MNGtask>0
   then
   begin
      result:='error';
      case FCDdmtTaskListInProcess[MNGtask].T_type of
         tMissionColonization: Result:=FCFdTFiles_UIStr_Get(uistrUI,'Mission.coloniz');
         tMissionInterplanetaryTransit: Result:=FCFdTFiles_UIStr_Get(uistrUI,'Mission.itransit');
      end;
   end;
end;

function FCFspuF_Mission_GetPhaseName(const MGPNfac, MGPNspU: integer): string;
{:Purpose: get the phase name of the chosen space unit.
    Additions:
      -2012Sep23- *add/mod: modify and expand the selection according to the overhaul of the task data structure.
      -2010Sep15- *mod: delete useless code after entities transformation.
      -2010Sep13- *add: entities code.
      -2010Sep06- *code audit.
      -2010Apr22- *add: space unit, atmospheric flight phase.
}
var
   MGPNtask: integer;  {:DEV NOTES: remove that!.}
begin
   MGPNtask:=0;
   Result:='';
   MGPNtask:=FCDdgEntities[MGPNfac].E_spaceUnits[MGPNspU].SU_assignedTask;
   if MGPNtask=0
   then Result:=FCFdTFiles_UIStr_Get(uistrUI,'spUnMissNone')
   else if MGPNtask>0
   then
   begin
      result:='error';
      case FCDdmtTaskListInProcess[MGPNtask].T_type of
         tMissionColonization:
         begin
            case FCDdmtTaskListInProcess[MGPNtask].T_tMCphase of
               mcpDeceleration: result:=FCFdTFiles_UIStr_Get(uistrUI,'ggfptDecel');
               mcpAtmosphericEntry: result:=FCFdTFiles_UIStr_Get(uistrUI,'ggftpAtmEnt');
            end;
         end;

         tMissionInterplanetaryTransit:
         begin
            case FCDdmtTaskListInProcess[MGPNtask].T_tMITphase of
               mitpAcceleration: result:=FCFdTFiles_UIStr_Get(uistrUI,'ggfptAccel');
               mitpCruise: result:=FCFdTFiles_UIStr_Get(uistrUI,'ggfptCruise');
               mitpDeceleration: result:=FCFdTFiles_UIStr_Get(uistrUI,'ggfptDecel');
            end;
         end;
      end;
   end;
end;

function FCFspuF_SpUObject_Search(const SUOSfac, SUOSidx: integer): integer;
{:Purpose: search the corresponding space unit 3d object index regarding the owned #.
    Additions:
      -2012Dec03- *mod: initialize correctly the Result.
      -2010Sep15- *mod: delete useless code after entities transformation.
      -2010Sep13- *add: entities code.
      -2010Sep06- *code audit.
                  *add: test if the space unit is in the current focused star system.
}
var
   SUOScnt: integer;

   SUOSret: extended;

   SUOSsyst: string;
begin
   Result:=0;
   SUOSret:=0;
   SUOScnt:=1;
   SUOSsyst:=FCDdgEntities[SUOSfac].E_spaceUnits[SUOSidx].SU_locationStar;
   if SUOSsyst=FCVdgPlayer.P_viewStar
   then
   begin
      while SUOScnt<=FC3doglMainViewTotalSpaceUnits do
      begin
         if (FC3doglSpaceUnits[SUOScnt].Tag=SUOSfac)
            and (FC3doglSpaceUnits[SUOScnt].TagFloat=SUOSidx)
         then
         begin
            SUOSret:=FC3doglSpaceUnits[SUOScnt].TagFloat;
            break;
         end;
         inc(SUOScnt);
      end;
   end;
   Result:=round(SUOSret);
end;

procedure FCMspuF_DockedSpU_Rem(
   const DSURfac
         ,DSURmotherIdx
         ,DSURdToken: integer
   );
{:Purpose: remove the docked space unit specified by it's owned index #.
    Additions:
      -2012Dec04- *add: apply the SU_locationDockingMotherCraft management.
      -2010Sep15- *add: a faction # parameter.
                  *add: entities code.
      -2010Sep06- *code audit.
}
var
   DSURmax
   ,DSURnewCnt
   ,DSURoldCnt: integer;

   DSURdckdClone: array of TFCRdgSpaceUnitDockList;
begin
   DSURmax:=length(FCDdgEntities[DSURfac].E_spaceUnits[DSURmotherIdx].SU_dockedSpaceUnits);
   SetLength(DSURdckdClone, DSURmax-1);
   DSURoldCnt:=1;
   DSURnewCnt:=0;
   while DSURoldCnt<=DSURmax-1 do
   begin
      if FCDdgEntities[DSURfac].E_spaceUnits[DSURmotherIdx].SU_dockedSpaceUnits[DSURoldCnt].SUDL_index<>DSURdToken
      then
      begin
         inc(DSURnewCnt);
         DSURdckdClone[DSURnewCnt].SUDL_index:=FCDdgEntities[DSURfac].E_spaceUnits[DSURmotherIdx].SU_dockedSpaceUnits[DSURoldCnt].SUDL_index;
      end;
      inc(DSURoldCnt);
   end;
   SetLength(FCDdgEntities[DSURfac].E_spaceUnits[DSURmotherIdx].SU_dockedSpaceUnits, length(DSURdckdClone));
   DSURnewCnt:=1;
   while DSURnewCnt<=DSURmax-2 do
   begin
      FCDdgEntities[DSURfac].E_spaceUnits[DSURmotherIdx].SU_dockedSpaceUnits[DSURnewCnt]:=DSURdckdClone[DSURnewCnt];
      inc(DSURnewCnt);
   end;
   SetLength(DSURdckdClone, 0);
   FCDdgEntities[DSURfac].E_spaceUnits[DSURdToken].SU_locationDockingMotherCraft:=0;
end;

procedure FCMspuF_Orbits_Process(
   const OPaction: TFCEspufOrbIO;
   const OPsSys,
         OPstar,
         OPoobj,
         OPsat,
         OPfac,
         OPspuOwn: integer;
   const opUpd3dView: boolean
   );
{:Purpose: add or remove a space unit in orbit of an orbital object.
    Additions:
      -2012Dec16- *fix: prevent a crash after to remove a space unit in orbit, the data structure is properly adjusted.
      -2010Nov04- *fix: only update the 3d view if the entity is the player's one.
      -2010Sep15- *add: entities code.
      -2010Sep06- *code audit.
      -2009Dec27- *fix: put opSatObj:=FCFoglVMain_SatObj_Search(opOOidx, opSatIdx); on in the case the 3d view is updated !
      -2009Dec26- *add: update 3d view for satellites.
      -2009Dec20- *add: satellite orbit if opSatIdx>0
}
var
   OPcnt
   ,OPcopyCnt
   ,OPsatObj
   ,OPttl: integer;

   OPcopyOrbArr: array[0..FCCduMaxSpaceUnitsInOrbit] of TFCRduOObSpaceUnitInOrbit;
begin
   {.add the space unit in orbit}
   if OPaction=spufoioAddOrbit
   then
   begin
      FCDdgEntities[OPfac].E_spaceUnits[OPspuOwn].SU_status:=susInOrbit;
      if OPsat=0
      then
      begin
         {.increment the counter}
         inc(FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitCurrentNumber);
         OPttl:=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitCurrentNumber;
         {.set the data}
         FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitSpaceUnitsList[OPttl].SUIO_faction:=OPfac;
         FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitSpaceUnitsList[OPttl].SUIO_ownedSpaceUnitIndex:=OPspuOwn;
         FCDdgEntities[OPfac].E_spaceUnits[OPspuOwn].SU_locationOrbitalObject:=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_dbTokenId;
         {.update the 3d view}
         if ( opUpd3dView )
            and (OPfac=0)
         then FCMoglVM_OObjSpUn_inOrbit(
            OPoobj
            ,0
            ,0
            ,false
            );
      end
      else if OPsat>0
      then
      begin
         {.increment the counter}
         inc(FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitCurrentNumber);
         OPttl:=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitCurrentNumber;
         {.set the data}
         FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitSpaceUnitsList[OPttl].SUIO_faction:=OPfac;
         FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitSpaceUnitsList[OPttl].SUIO_ownedSpaceUnitIndex:=OPspuOwn;
         FCDdgEntities[OPfac].E_spaceUnits[OPspuOwn].SU_locationOrbitalObject:=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_dbTokenId;
         FCDdgEntities[OPfac].E_spaceUnits[OPspuOwn].SU_locationSatellite:=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_dbTokenId;
         {.update the 3d view}
         if ( opUpd3dView )
            and (OPfac=0)
         then
         begin
            OPsatObj:=FCFoglF_Satellite_SearchObject(OPoobj, OPsat);
            FCMoglVM_OObjSpUn_inOrbit(
               OPoobj
               ,OPsat
               ,OPsatObj
               ,false
               );
         end;
      end;
   end //==END== if opOrbMode=spufoioAddOrbit ==//
   else if OPaction=spufoioRemOrbit
   then
   begin
//      FCDdgEntities[OPfac].E_spaceUnits[OPspuOwn].SU_locationOrbitalObject:='';
      FCDdgEntities[OPfac].E_spaceUnits[OPspuOwn].SU_status:=susInFreeSpace;
      if OPsat=0
      then
      begin
         OPttl:=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitCurrentNumber;
         {.if the one to delete is the last item}
         if FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitSpaceUnitsList[OPttl].SUIO_ownedSpaceUnitIndex=OPspuOwn
         then
         begin
            FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitSpaceUnitsList[OPttl]:=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitSpaceUnitsList[0];
            dec(FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitCurrentNumber);
            {.update the 3d view}
            if ( opUpd3dView )
            and (OPfac=0)
            then FCMoglVM_OObjSpUn_inOrbit(
               OPoobj
               ,0
               ,0
               ,false
               );
         end
         else
         begin
            OPcnt:=1;
            OPcopyCnt:=0;
            while OPcnt<=OPttl do
            begin
               if FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitSpaceUnitsList[OPcnt].SUIO_ownedSpaceUnitIndex<>OPspuOwn
               then
               begin
                  inc(OPcopyCnt);
                  OPcopyOrbArr[OPcopyCnt]:=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitSpaceUnitsList[OPcnt];
               end;
               inc(OPcnt);
            end;
            {.set the new counter}
            FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitCurrentNumber:=OPcopyCnt;
            {.clear the last one of the list}
            FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitSpaceUnitsList[OPttl]:=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitSpaceUnitsList[0];
            {.paste the new array in the data structure}
            OPcnt:=1;
            while OPcnt<=OPcopyCnt do
            begin
               FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_inOrbitSpaceUnitsList[OPcnt]:=OPcopyOrbArr[OPcnt];
               inc(OPcnt);
            end;
            {.update the 3d view}
            if ( opUpd3dView )
            and (OPfac=0)
            then FCMoglVM_OObjSpUn_inOrbit(
               OPoobj
               ,0
               ,0
               ,false
               );
         end;
      end //==END== if opSatIdx=0 ==//
      else if OPsat>0
      then
      begin
         OPttl:=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitCurrentNumber;
         FCDdgEntities[OPfac].E_spaceUnits[OPspuOwn].SU_locationSatellite:='';
         {.if the one to delete is the last item (more simple)}
         if FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitSpaceUnitsList[OPttl].SUIO_ownedSpaceUnitIndex=OPspuOwn
         then
         begin
            FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitSpaceUnitsList[OPttl]
               :=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitSpaceUnitsList[0];
            dec(FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitCurrentNumber);
            {.update the 3d view}
            if ( opUpd3dView )
            and (OPfac=0)
            then
            begin
               OPsatObj:=FCFoglF_Satellite_SearchObject(OPoobj, OPsat);
               FCMoglVM_OObjSpUn_inOrbit(
                  OPoobj
                  ,OPsat
                  ,OPsatObj
                  ,false
                  );
            end;
         end
         else
         begin
            OPcnt:=1;
            OPcopyCnt:=0;
            while OPcnt<=OPttl do
            begin
               if FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitSpaceUnitsList[OPcnt].SUIO_ownedSpaceUnitIndex<>OPspuOwn
               then
               begin
                  inc(OPcopyCnt);
                  OPcopyOrbArr[OPcopyCnt]:=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitSpaceUnitsList[OPcnt];
               end;
               inc(OPcnt);
            end;
            {.set the new counter}
            FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitCurrentNumber:=OPcopyCnt;
            {.clear the last one of the list}
            FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitSpaceUnitsList[OPttl]
               :=FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitSpaceUnitsList[0];
            {.paste the new array in the data structure}
            OPcnt:=1;
            while OPcnt<=OPcopyCnt do
            begin
               FCDduStarSystem[OPsSys].SS_stars[OPstar].S_orbitalObjects[OPoobj].OO_satellitesList[OPsat].OO_inOrbitSpaceUnitsList[OPcnt]:=OPcopyOrbArr[OPcnt];
               inc(OPcnt);
            end;
            {.update the 3d view}
            if ( opUpd3dView )
            and (OPfac=0)
            then
            begin
               OPsatObj:=FCFoglF_Satellite_SearchObject(OPoobj, OPsat);
               FCMoglVM_OObjSpUn_inOrbit(
                  OPoobj
                  ,OPsat
                  ,OPsatObj
                  ,false
                  );
            end;
         end;
      end //==END== else if opSatIdx>0 ==//
   end; {.if opOrbMode=spufoioRemOrbit}
end;

procedure FCMspuF_SpUnit_Remove(const Entity, TargetSpaceUnit: integer);
{:Purpose: delete a chosen space unit from an faction's owned data structure.
    Additions:
      -2012Dec04- *add: routine completion with docked space units management.
      -2012Dec03- *rem: remove the faction=0 test, this routine applies either to the player's faction and the AIs ones.
                  *fix: if the space unit is present in the current 3d view, its object is disabled by set its visibility to false.
      -2010Sep15- *entities code.
      -2010Sep06- *code audit.
}
{:DEV NOTES: later include if a space unit have docked space units, to remove them also. The only case it can happen is in case when a mother vessel is
   destroyed in combat, so the docked units are destroyed too. If they can escape, they will be no more docked at the time to remove the mother vessel anyway.}
var
   CloneCount
   ,Count
   ,Count1
   ,DockedIndex
   ,DockedMax
   ,Max
   ,SpaceUnit3dIndex
   ,TaskIndex: integer;

   SURisTgtDeleted: boolean;

   SURown: array of TFCRdgSpaceUnit;
begin
   SetLength(SURown, 1);
   SURisTgtDeleted:=false;
   Count:=1;
   Count1:=0;
   CloneCount:=0;
   DockedIndex:=0;
   DockedMax:=0;
   SpaceUnit3dIndex:=0;
   Max:=Length(FCDdgEntities[Entity].E_spaceUnits)-1;
   SetLength(SURown, Max);
   while Count<=Max do
   begin
      if Count=TargetSpaceUnit then
      begin
         SURisTgtDeleted:=true;
         if FCDdgEntities[Entity].E_spaceUnits[Count].SU_linked3dObject>0
         then FC3doglSpaceUnits[FCDdgEntities[Entity].E_spaceUnits[Count].SU_linked3dObject].Visible:=false;
      end
      else begin
         inc( CloneCount );
         SURown[CloneCount]:=FCDdgEntities[Entity].E_spaceUnits[Count];
         if SURown[CloneCount].SU_status=susDocked then
         begin
            DockedIndex:=FCFspuF_DockedSpU_RetrieveDockedIndex(
               Entity
               ,FCDdgEntities[Entity].E_spaceUnits[Count].SU_locationDockingMotherCraft
               ,Count
               );
            if FCDdgEntities[Entity].E_spaceUnits[Count].SU_locationDockingMotherCraft<Count
            then SURown[SURown[CloneCount].SU_locationDockingMotherCraft].SU_dockedSpaceUnits[DockedIndex].SUDL_index:=CloneCount
            else if FCDdgEntities[Entity].E_spaceUnits[Count].SU_locationDockingMotherCraft>Count
            then FCDdgEntities[Entity].E_spaceUnits[SURown[CloneCount].SU_locationDockingMotherCraft].SU_dockedSpaceUnits[DockedIndex].SUDL_index:=CloneCount;
         end;
         if SURisTgtDeleted then
         begin
            if SURown[CloneCount].SU_linked3dObject>0
            then FC3doglSpaceUnits[SURown[CloneCount].SU_linked3dObject].TagFloat:=CloneCount;
            if SURown[CloneCount].SU_assignedTask>0
            then
            begin
               TaskIndex:=SURown[CloneCount].SU_assignedTask;
               FCDdmtTaskListInProcess[TaskIndex].T_controllerIndex:=CloneCount;
            end;
         end;

      end;
      inc(Count);
   end;
   SetLength(FCDdgEntities[Entity].E_spaceUnits, Max);
   Count:=1;
   while Count<=Max-1 do
   begin
      FCDdgEntities[Entity].E_spaceUnits[Count]:=SURown[Count];
      DockedMax:=length(FCDdgEntities[Entity].E_spaceUnits[Count].SU_dockedSpaceUnits)-1;
      Count1:=1;
      while Count1<=DockedMax do
      begin
         if FCDdgEntities[Entity].E_spaceUnits[Count].SU_dockedSpaceUnits[Count1].SUDL_index<Count
         then FCDdgEntities[Entity].E_spaceUnits[FCDdgEntities[Entity].E_spaceUnits[Count].SU_dockedSpaceUnits[Count1].SUDL_index].SU_locationDockingMotherCraft:=Count
         else if FCDdgEntities[Entity].E_spaceUnits[Count].SU_dockedSpaceUnits[Count1].SUDL_index>Count
         then SURown[FCDdgEntities[Entity].E_spaceUnits[Count].SU_dockedSpaceUnits[Count1].SUDL_index].SU_locationDockingMotherCraft:=Count;
         inc( Count1 );
      end;
      inc(Count);
   end;

end;

end.
