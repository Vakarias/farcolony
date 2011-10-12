{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: savegame file management

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
unit farc_data_filesavegame;

interface

uses
   SysUtils
   ,TypInfo
   ,Windows
   ,XMLIntf;

///<summary>
///   load the current game
///</summary>
procedure FCMdFSG_Game_Load;

///<summary>
///   save the current game
///</summary>
procedure FCMdFSG_Game_Save;

///<summary>
///   save the current game and flush all other save game files than the current one
///</summary>
procedure FCMdFSG_Game_SaveAndFlushOther;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_common_func
   ,farc_data_files
   ,farc_data_game
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_data_univ
   ,farc_game_cps
   ,farc_game_gameflow
   ,farc_univ_func
   ,farc_main;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMdFSG_Game_Load;
{:Purpose: load the current game.
   Additions:
      -2011Oct11- *fix: forgot to set the size of the region dynamic array.
                  *fix: correction on spotSizCurr attribute loading.
      -2011Oct10- *add: list for surveyed resources.
      -2011Jul31- *add: infrastructure status istDisabledByEE.
      -2011Jul19- *add: CSM Energy module - storage data.
      -2011Jul13- *add: infrastructure consumed power.
      -2011Jul12- *add: CSM - Energy data.
      -2011Jul07- *add: colonies' production matrix.
      -2011May25- *rem: infrastructure - converted housing, useless state.
      -2011May15- *add: colony's infrastructure - CAB worked hours.
      -2011May05- *mod: complete change of colony's storage loading.
      -2011Apr26- *add: colonies' assigned population data.
                  *add: colonies' construction workforce.
      -2011Apr24- *add: energy output for Energy class infrastructures.
      -2011Apr20- *add: CPS - isEnabled.
      -2011Mar16-	*add: colonies' storages + reserves.
      -2011Mar09- *add: infrastructure's CAB duration.
                  *add: colonies' CAB queue.
      -2011Mar07- *add: converted housing infrastructures.
      -2011Feb14- *add: initialize region's settlement data.
      -2011Feb12- *add: extra task's data.
                  *add: settlements.
      -2011Feb08- *add: full status token loading, independent of the index.
      -2011Feb01- *add: economic & industrial output.
      -2010Dec29- *add: SPM cost storage data.
      -2010Dec19- *add: entities higher hq level present in the faction.
      -2010Nov08- *add: entities UC reserve.
      -2010Nov03- *add: SPMi duration.
      -2010Oct24- *add: HQ presence data for each colony.
      -2010Oct11- *add: player's faction status of the 3 categories.
      -2010Oct07- *add: memes values + policy status.
      -2010Sep29- *add: entity's bureaucracy and corruption modifiers.
      -2010Sep23- *fix: entity's bureaucracy and corruption load.
      -2010Sep22- *add: bureaucracy and corruption entities data.
                  *add: SPMi isSet data.
      -2010Sep21- *add: spm settings for entities.
      -2010Sep16- *add: entities code.
      -2010Sep07- *add: loading in specific file now, including date/time: name-yr-mth-day-h-mn.
      -2010Aug30- *add: CSM Phase list.
      -2010Aug19- *add: population type: militia.
      -2010Aug16- *add: population type: rebels.
      -2010Aug09- *add: CSM event duration.
      -2010Aug02- *add: CSM event health modifier.
      -2010Jul27- *add: CSM event level + economic & industrial output modifier.
      -2010Jul21- *add: csmTime data.
      -2010Jul02- *add: tasklisk string data.
      -2010Jun08- *add: space unit: include the docked sub data structure.
                  *fix: for each existing colony, the related orbital object data structure is updated.
      -2010Jun07- *add: display cps panel if cps is used and there's one colony.
      -2010May30- *add: colony's population sub-datastructure.
      -2010May27- *add: csm data pcap, spl, qol and heal.
      -2010May19- *add: colony infrastructures: status.
      -2010May18- *add: colony infrastructures.
      -2010May12- *add: in process task data phase.
      -2010May10- *add: the two time2xfert data.
      -2010May05- *add: TITP_regIdx.
      -2010May04- *add: TITP_timeOrg, TITP_orgType, TITP_timeDecel, TITP_accelbyTick.
                  *mod: threads loading is disabled.
      -2010Mar31- *add: colony level.
      -2010Mar27- *add space unit docked data.
      -2010Mar22- *add: cps time left.
      -2010Mar13- *add: cps data.
      -2010Mar03- *add: owned colonies.
      -2009Dec19- *add: player's sat location.
      -2009Dec18- *add: sat location for owned space unit.
      -2009Nov28- *add messages queue.
      -2009Nov27- *add TITP_usedRMassV.
      -2009Nov12- *add threads.
      -2009Nov10- *add tasklist in process.
      -2009Nov08- *add owned space units.
}
var
   GLxmlCAB
   ,GLxmlCol
   ,GLxmlColsub
   ,GLxmlDock
   ,GLxmlEntRoot
   ,GLxmlEntSubRoot
   ,GLxmlEnt
   ,GLxmlInfra
   ,GLxmlItm
   ,GLxmlMsg
   ,GLxmlCSMpL
   ,GLxmlCSMpLsub
   ,GLxmlProdMatrix
   ,GLxmlSPMset
   ,GLxmlSpOwn
   ,GLxmlStorage
   ,GLxmlTskInPr
   ,GLxmlViaObj
   ,GLxmlSurveyRsrc
   ,GLxmlSurveyRegion: IXMLNode;

   GLcabCnt
   ,GLcabValue
   ,GLcolMax
   ,GLentCnt
   ,GLspuMax
   ,GLspuCnt
   ,GLcount
   ,GLcrLineM
   ,GLcvs
   ,GLdock
   ,GLevCnt
   ,GLinfCnt
   ,GLphItm
   ,GLphFac
   ,GLphFacOld
   ,GLprodMatrixCnt
   ,GLregionIdx
   ,GLsettleCnt
   ,GLsettleMax
   ,GLstorageCnt
   ,GLsubCnt
   ,GLtLft
   ,GLenumIndex
   ,GLregionTtl: integer;

   GLcrInt
   ,GLcrLineU: double;

   GLisCPSenabled: boolean;

   GLcurrDir
   ,GLcurrG
   ,GLinfStatus
   ,GLsettleType: string;

   GLvObjList: array of TFCRcpsObj;

   GLoobjRow: TFCRufStelObj;
begin
   FCMdF_ConfigFile_Read(true);
   GLcurrDir:=FCVcfgDir+'SavedGames\'+FCRplayer.P_gameName;
   GLcurrG:=IntToStr(FCRplayer.P_timeYr)
      +'-'+IntToStr(FCRplayer.P_timeMth)
      +'-'+IntToStr(FCRplayer.P_timeday)
      +'-'+IntToStr(FCRplayer.P_timeHr)
      +'-'+IntToStr(FCRplayer.P_timeMin)
      +'.xml';
   if (DirectoryExists(GLcurrDir))
      and (FileExists(GLcurrDir+'\'+GLcurrG))
   then
   begin
      {.read the document}
      FCWinMain.FCXMLsave.FileName:=GLcurrDir+'\'+GLcurrG;
      FCWinMain.FCXMLsave.Active:=true;
      {.read the main section}
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfMain');
      if GLxmlItm<>nil
      then
      begin
         FCRplayer.P_facAlleg:=GLxmlItm.Attributes['facAlleg'];
         FCRplayer.P_starSysLoc:=GLxmlItm.Attributes['plyrsSSLoc'];
         FCRplayer.P_starLoc:=GLxmlItm.Attributes['plyrsStLoc'];
         FCRplayer.P_oObjLoc:=GLxmlItm.Attributes['plyrsOObjLoc'];
         FCRplayer.P_satLoc:=GLxmlItm.Attributes['plyrsatLoc'];
      end;
      {.read the "timeframe" section}
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfTimeFr');
      if GLxmlItm<>nil
      then
      begin
         FCRplayer.P_timeTick:=GLxmlItm.Attributes['tfTick'];
         FCRplayer.P_timeMin:=GLxmlItm.Attributes['tfMin'];
         FCRplayer.P_timeHr:=GLxmlItm.Attributes['tfHr'];
         FCRplayer.P_timeday:=GLxmlItm.Attributes['tfDay'];
         FCRplayer.P_timeMth:=GLxmlItm.Attributes['tfMth'];
         FCRplayer.P_timeYr:=GLxmlItm.Attributes['tfYr'];
      end;
      {.read the "status" section}
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfStatus');
      if GLxmlItm<>nil
      then
      begin
         FCRplayer.P_ecoStat:=GLxmlItm.Attributes['statEco'];
         FCRplayer.P_socStat:=GLxmlItm.Attributes['statSoc'];
         FCRplayer.P_milStat:=GLxmlItm.Attributes['statMil'];
      end;
      {.read "cps" section}
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfCPS');
      if GLxmlItm<>nil
      then
      begin
         GLisCPSenabled:=GLxmlItm.Attributes['cpsEnabled'];
         GLcvs:=GLxmlItm.Attributes['cpsCVS'];
         GLtLft:=GLxmlItm.Attributes['cpsTlft'];
         GLcrInt:=GLxmlItm.Attributes['cpsInt'];
         GLcrLineU:=GLxmlItm.Attributes['cpsCredU'];
         GLcrLineM:=GLxmlItm.Attributes['cpsCredM'];
         GLcount:=0;
         GLxmlViaObj:=GLxmlItm.ChildNodes.First;
         SetLength(GLvObjList, 1);
         while GLxmlViaObj<>nil do
         begin
            SetLength(GLvObjList, length(GLvObjList)+1);
            inc(GLcount);
            GLvObjList[GLcount].CPSO_type:=GLxmlViaObj.Attributes['objTp'];
            GLvObjList[GLcount].CPSO_score:=GLxmlViaObj.Attributes['score'];
            GLxmlViaObj:=GLxmlViaObj.NextSibling;
         end; //==END== GLxmlViaObj<>nil ==//
         FCcps:=TFCcps.Create(
            GLcvs
            ,GLtLft
            ,GLcrLineM
            ,GLcrInt
            ,GLcrLineU
            ,GLvObjList
            ,GLisCPSenabled
            );
      end; //==END== if GLxmlItm<>nil for CPS ==//
      {.read "taskinprocess" saved game item}
      SetLength(FCGtskListInProc, 1);
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfTskLstinProc');
      if GLxmlItm<>nil
      then
      begin
         GLcount:=0;
         GLxmlTskInPr:=GLxmlItm.ChildNodes.First;
         while GLxmlTskInPr<>nil do
         begin
            SetLength(FCGtskListInProc, length(FCGtskListInProc)+1);
            inc(GLcount);
            FCGtskListInProc[GLCount].TITP_enabled:=GLxmlTskInPr.Attributes['tipEna'];
            FCGtskListInProc[GLCount].TITP_actionTp:=GLxmlTskInPr.Attributes['tipActTp'];
            FCGtskListInProc[GLCount].TITP_phaseTp:=GLxmlTskInPr.Attributes['tipPhase'];
            FCGtskListInProc[GLCount].TITP_ctldType:=GLxmlTskInPr.Attributes['tipTgtTp'];
            FCGtskListInProc[GLCount].TITP_ctldFac:=GLxmlTskInPr.Attributes['tipTgtFac'];
            FCGtskListInProc[GLCount].TITP_ctldIdx:=GLxmlTskInPr.Attributes['tipTgtIdx'];
            FCGtskListInProc[GLcount].TITP_timeOrg:=GLxmlTskInPr.Attributes['tipTimeOrg'];
            FCGtskListInProc[GLCount].TITP_duration:=GLxmlTskInPr.Attributes['tipDura'];
            FCGtskListInProc[GLCount].TITP_interval:=GLxmlTskInPr.Attributes['tipInterv'];
            FCGtskListInProc[GLCount].TITP_orgType:=GLxmlTskInPr.Attributes['tipOrgTp'];
            FCGtskListInProc[GLCount].TITP_orgIdx:=GLxmlTskInPr.Attributes['tipOrgIdx'];
            FCGtskListInProc[GLCount].TITP_destType:=GLxmlTskInPr.Attributes['tipDestTp'];
            FCGtskListInProc[GLCount].TITP_destIdx:=GLxmlTskInPr.Attributes['tipDestIdx'];
            FCGtskListInProc[GLCount].TITP_regIdx:=GLxmlTskInPr.Attributes['tipRegIdx'];
            FCGtskListInProc[GLCount].TITP_velCruise:=GLxmlTskInPr.Attributes['tipVelCr'];
            FCGtskListInProc[GLCount].TITP_timeToCruise:=GLxmlTskInPr.Attributes['tipTimeTcr'];
            FCGtskListInProc[GLCount].TITP_timeDecel:=GLxmlTskInPr.Attributes['tipTimeTdec'];
            FCGtskListInProc[GLCount].TITP_time2xfert:=GLxmlTskInPr.Attributes['tipTime2Xfrt'];
            FCGtskListInProc[GLCount].TITP_time2xfert2decel:=GLxmlTskInPr.Attributes['tipTime2XfrtDec'];
            FCGtskListInProc[GLCount].TITP_velFinal:=GLxmlTskInPr.Attributes['tipVelFin'];
            FCGtskListInProc[GLCount].TITP_timeToFinal:=GLxmlTskInPr.Attributes['tipTimeTfin'];
            FCGtskListInProc[GLCount].TITP_accelbyTick:=GLxmlTskInPr.Attributes['tipAccelBtick'];
            FCGtskListInProc[GLcount].TITP_usedRMassV:=GLxmlTskInPr.Attributes['tipUsedRM'];
            FCGtskListInProc[GLcount].TITP_str1:=GLxmlTskInPr.Attributes['tipStr1'];
            FCGtskListInProc[GLcount].TITP_str2:=GLxmlTskInPr.Attributes['tipStr2'];
            FCGtskListInProc[GLcount].TITP_int1:=GLxmlTskInPr.Attributes['tipInt1'];
            GLxmlTskInPr:=GLxmlTskInPr.NextSibling;
         end; {.while GLxmlGamItmTskInPr<>nil}
      end; {.if GLxmlGamItmTskInPr<>nil}
      {.read all surveyed resources}
      setlength(FCRplayer.P_SurveyedResourceSpots, 1);
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfSurveyedResourceSpots');
      if GLxmlItm<>nil then
      begin
         GLcount:=0;
         GLxmlSurveyRsrc:=GLxmlItm.ChildNodes.First;
         while GLxmlSurveyRsrc<>nil do
         begin
            inc(GLcount);
            SetLength(FCRplayer.P_SurveyedResourceSpots, GLcount+1);
            FCRplayer.P_SurveyedResourceSpots[GLcount].SS_oobjToken:=GLxmlSurveyRsrc.Attributes['oobj'];
            FCRplayer.P_SurveyedResourceSpots[GLcount].SS_ssysIndex:=GLxmlSurveyRsrc.Attributes['ssysIdx'];
            FCRplayer.P_SurveyedResourceSpots[GLcount].SS_starIndex:=GLxmlSurveyRsrc.Attributes['starIdx'];
            FCRplayer.P_SurveyedResourceSpots[GLcount].SS_oobjIndex:=GLxmlSurveyRsrc.Attributes['oobjIdx'];
            FCRplayer.P_SurveyedResourceSpots[GLcount].SS_satIndex:=GLxmlSurveyRsrc.Attributes['satIdx'];
            if (
               (FCRplayer.P_SurveyedResourceSpots[GLcount].SS_oobjToken<>'')
               and
               (FCRplayer.P_SurveyedResourceSpots[GLcount].SS_satIndex=0)
               and ( FCDBsSys[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_ssysIndex].
                        SS_star[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_starIndex].
                        SDB_obobj[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_oobjIndex].OO_token=FCRplayer.P_SurveyedResourceSpots[GLcount].SS_oobjToken
                  )
               )
               or (
                  (FCRplayer.P_SurveyedResourceSpots[GLcount].SS_oobjToken<>'')
                  and
                  (FCRplayer.P_SurveyedResourceSpots[GLcount].SS_satIndex>0)
                  and ( FCDBsSys[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_ssysIndex].
                           SS_star[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_starIndex].
                           SDB_obobj[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_oobjIndex].
                           OO_satList[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_satIndex].OOS_token=FCRplayer.P_SurveyedResourceSpots[GLcount].SS_oobjToken
                     )
               ) then
            begin
               if FCRplayer.P_SurveyedResourceSpots[GLcount].SS_satIndex=0
               then SetLength(
                  FCRplayer.P_SurveyedResourceSpots[GLcount].SS_surveyedRegions
                  ,length(
                     FCDBsSys[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_ssysIndex].
                        SS_star[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_starIndex].
                        SDB_obobj[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_oobjIndex].OO_regions
                     )+1
                  )
               else if FCRplayer.P_SurveyedResourceSpots[GLcount].SS_satIndex>0
               then SetLength(
                  FCRplayer.P_SurveyedResourceSpots[GLcount].SS_surveyedRegions
                  ,length(
                     FCDBsSys[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_ssysIndex].
                        SS_star[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_starIndex].
                        SDB_obobj[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_oobjIndex].
                        OO_satList[FCRplayer.P_SurveyedResourceSpots[GLcount].SS_satIndex].OOS_regions
                     )+1
                  );
               GLxmlSurveyRegion:=GLxmlSurveyRsrc.ChildNodes.First;
               while GLxmlSurveyRegion<>nil do
               begin
                  GLsubCnt:=GLxmlSurveyRegion.Attributes['regionIdx'];
                  GLenumIndex:=GetEnumValue(TypeInfo(TFCEduRsrcSpotType), GLxmlSurveyRegion.Attributes['spotType'] );
                  FCRplayer.P_SurveyedResourceSpots[GLcount].SS_surveyedRegions[GLsubCnt].SR_type:=TFCEduRsrcSpotType(GLenumIndex);
                  if GLenumIndex=-1
                  then raise Exception.Create('bad gamesave loading w/rsrc spot type: '+GLxmlSurveyRegion.Attributes['spotType'])
                  else if GLenumIndex>0 then
                  begin
                     FCRplayer.P_SurveyedResourceSpots[GLcount].SS_surveyedRegions[GLsubCnt].SR_MQC:=GLxmlSurveyRegion.Attributes['meanQualCoef'];
                     FCRplayer.P_SurveyedResourceSpots[GLcount].SS_surveyedRegions[GLsubCnt].SR_SpotSizeCur:=GLxmlSurveyRegion.Attributes['spotSizCurr'];
                     FCRplayer.P_SurveyedResourceSpots[GLcount].SS_surveyedRegions[GLsubCnt].SR_SpotSizeMax:=GLxmlSurveyRegion.Attributes['spotSizeMax'];
                  end;
                  GLxmlSurveyRegion:=GLxmlSurveyRegion.NextSibling;
               end;
            end
            else raise Exception.Create('universe database is not compatible with the current save game file');
            GLxmlSurveyRsrc:=GLxmlSurveyRsrc.NextSibling;
         end;
      end; //==END== if GLxmlItm<>nil then... for surveyed resources ==//
      {.read "CSM" section}
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfCSM');
      if GLxmlItm<>nil
      then
      begin
         GLcount:=0;
         GLxmlCSMpL:=GLxmlItm.ChildNodes.First;
         SetLength(FCGcsmPhList, 1);
         while GLxmlCSMpL<>nil do
         begin
            SetLength(FCGcsmPhList, length(FCGcsmPhList)+1);
            inc(GLcount);
            FCGcsmPhList[GLcount].CSMT_tick:=GLxmlCSMpL.Attributes['csmTick'];
            GLphFac:=0;
            GLphFacOld:=-1;
            GLxmlCSMpLsub:=GLxmlCSMpL.ChildNodes.First;
            while GLxmlCSMpLsub<>nil do
            begin
               GLphFac:=GLxmlCSMpLsub.Attributes['fac'];
               if GLphFac<>GLphFacOld
               then
               begin
                  GLphFacOld:=GLphFac;
                  SetLength(FCGcsmPhList[GLcount].CSMT_col[GLphFac], 1);
                  GLphItm:=0;
               end;
               SetLength(FCGcsmPhList[GLcount].CSMT_col[GLphFac], length(FCGcsmPhList[GLcount].CSMT_col[GLphFac])+1);
               inc(GLphItm);
               FCGcsmPhList[GLcount].CSMT_col[GLphFac, GLphItm]:=GLxmlCSMpLsub.Attributes['colony'];
               GLxmlCSMpLsub:=GLxmlCSMpLsub.NextSibling;
            end;
            GLxmlCSMpL:=GLxmlCSMpL.NextSibling;
         end; //==END== GLxmlCSMpL<>nil ==//
      end; //==END== if GLxmlItm<>nil for CSM ==//
      {.entities section}
      FCMdG_Entities_Clear;
      GLxmlEntRoot:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfEntities');
      if GLxmlEntRoot<>nil
      then
      begin
         GLentCnt:=0;
         GLxmlEnt:=GLxmlEntRoot.ChildNodes.First;
         while GLxmlEnt<>nil do
         begin
            FCentities[GLentCnt].E_token:=GLxmlEnt.Attributes['token'];
            FCentities[GLentCnt].E_facLvl:=GLxmlEnt.Attributes['lvl'];
            FCentities[GLentCnt].E_bureau:=GLxmlEnt.Attributes['bur'];
            FCentities[GLentCnt].E_corrupt:=GLxmlEnt.Attributes['corr'];
            FCentities[GLentCnt].E_hqHigherLvl:=GLxmlEnt.Attributes['hqHlvl'];
            FCentities[GLentCnt].E_uc:=GLxmlEnt.Attributes['UCrve'];
            GLxmlEntSubRoot:=GLxmlEnt.ChildNodes.First;
            SetLength(FCentities[GLentCnt].E_spU, 1);
            SetLength(FCentities[GLentCnt].E_col,1);
            SetLength(FCentities[GLentCnt].E_spm,1);
            while GLxmlEntSubRoot<>nil do
            begin
               if GLxmlEntSubRoot.NodeName='entOwnSpU'
               then
               begin
                  GLcount:=0;
                  GLxmlSpOwn:=GLxmlEntSubRoot.ChildNodes.First;
                  while GLxmlSpOwn<>nil do
                  begin
                     SetLength(FCentities[GLentCnt].E_spU, length(FCentities[GLentCnt].E_spU)+1);
                     inc(GLcount);
                     FCentities[GLentCnt].E_spU[GLcount].SUO_spUnToken:=GLxmlSpOwn.Attributes['tokenId'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_nameToken:=GLxmlSpOwn.Attributes['tokenName'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_designId:=GLxmlSpOwn.Attributes['desgnId'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_starSysLoc:=GLxmlSpOwn.Attributes['ssLoc'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_starLoc:=GLxmlSpOwn.Attributes['stLoc'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_oobjLoc:=GLxmlSpOwn.Attributes['oobjLoc'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_satLoc:=GLxmlSpOwn.Attributes['satLoc'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_3dObjIdx:=GLxmlSpOwn.Attributes['TdObjIdx'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_locStarX:=GLxmlSpOwn.Attributes['xLoc'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_locStarZ:=GLxmlSpOwn.Attributes['zLoc'];
                     GLdock:=GLxmlSpOwn.Attributes['docked'];
                     if GLdock>0
                     then
                     begin
                        SetLength(FCentities[GLentCnt].E_spU[GLcount].SUO_dockedSU, GLdock+1);
                        GLsubCnt:=1;
                        GLxmlDock:=GLxmlSpOwn.ChildNodes.First;
                        while GLsubCnt<=GLdock do
                        begin
                           FCentities[GLentCnt].E_spU[GLcount].SUO_dockedSU[GLsubCnt].SUD_dckdToken:=GLxmlDock.Attributes['token'];
                           inc(GLsubCnt);
                           GLxmlDock:=GLxmlDock.NextSibling;
                        end;
                     end;
                     FCentities[GLentCnt].E_spU[GLcount].SUO_taskIdx:=GLxmlSpOwn.Attributes['taskId'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_status:=GLxmlSpOwn.Attributes['status'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_deltaV:=GLxmlSpOwn.Attributes['dV'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_3dmove:=GLxmlSpOwn.Attributes['TdMov'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_availRMass:=GLxmlSpOwn.Attributes['availRMass'];
                     GLxmlSpOwn:=GLxmlSpOwn.NextSibling;
                  end;
               end //==END== if GLxmlEntSubRoot.NodeName='entOwnSpU' ==//
               else if GLxmlEntSubRoot.NodeName='entColonies'
               then
               begin
                  GLcount:=0;
                  if assigned(FCcps)
                  then FCcps.FCM_ViabObj_Init(false);
                  GLxmlCol:=GLxmlEntSubRoot.ChildNodes.First;
                  while GLxmlCol<>nil do
                  begin
                     SetLength(FCentities[GLentCnt].E_col, length(FCentities[GLentCnt].E_col)+1);
                     inc(GLcount);
                     SetLength(FCentities[GLentCnt].E_col[GLcount].COL_evList, 1);
                     SetLength(FCentities[GLentCnt].E_col[GLcount].COL_settlements, 1);
                     GLevCnt:=0;
                     GLsettleCnt:=0;
                     FCentities[GLentCnt].E_col[GLcount].COL_name:=GLxmlCol.Attributes['prname'];
                     FCentities[GLentCnt].E_col[GLcount].COL_fndYr:=GLxmlCol.Attributes['fndyr'];
                     FCentities[GLentCnt].E_col[GLcount].COL_fndMth:=GLxmlCol.Attributes['fndmth'];
                     FCentities[GLentCnt].E_col[GLcount].COL_fndDy:=GLxmlCol.Attributes['fnddy'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmtime:=GLxmlCol.Attributes['csmtime'];
                     FCentities[GLentCnt].E_col[GLcount].COL_locSSys:=GLxmlCol.Attributes['locssys'];
                     FCentities[GLentCnt].E_col[GLcount].COL_locStar:=GLxmlCol.Attributes['locstar'];
                     FCentities[GLentCnt].E_col[GLcount].COL_locOObj:=GLxmlCol.Attributes['locoobj'];
                     FCentities[GLentCnt].E_col[GLcount].COL_locSat:=GLxmlCol.Attributes['locsat'];
                     GLoobjRow[1]:=GLoobjRow[0];
                     GLoobjRow[2]:=GLoobjRow[0];
                     GLoobjRow[3]:=GLoobjRow[0];
                     GLoobjRow[4]:=GLoobjRow[0];
                     GLoobjRow:=FCFuF_StelObj_GetFullRow(
                        FCentities[GLentCnt].E_col[GLcount].COL_locSSys
                        ,FCentities[GLentCnt].E_col[GLcount].COL_locStar
                        ,FCentities[GLentCnt].E_col[GLcount].COL_locOObj
                        ,FCentities[GLentCnt].E_col[GLcount].COL_locOObj
                        );
                     if GLoobjRow[4]=0
                     then FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_colonies[0]:=GLcount
                     else if GLoobjRow[4]>0
                     then FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_satList[GLoobjRow[4]].OOS_colonies[0]:=GLcount;
                     FCentities[GLentCnt].E_col[GLcount].COL_level:=GLxmlCol.Attributes['collvl'];
                     FCentities[GLentCnt].E_col[GLcount].COL_hqPres:=GLxmlCol.Attributes['hqpresence'];
                     FCentities[GLentCnt].E_col[GLcount].COL_cohes:=GLxmlCol.Attributes['dcohes'];
                     FCentities[GLentCnt].E_col[GLcount].COL_secu:=GLxmlCol.Attributes['dsecu'];
                     FCentities[GLentCnt].E_col[GLcount].COL_tens:=GLxmlCol.Attributes['dtens'];
                     FCentities[GLentCnt].E_col[GLcount].COL_edu:=GLxmlCol.Attributes['dedu'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmHOpcap:=GLxmlCol.Attributes['csmPCAP'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmHOspl:=GLxmlCol.Attributes['csmSPL'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmHOqol:=GLxmlCol.Attributes['csmQOL'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmHEheal:=GLxmlCol.Attributes['csmHEAL'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmENcons:=GLxmlCol.Attributes['csmEnCons'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmENgen:=GLxmlCol.Attributes['csmEnGen'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmENstorCurr:=GLxmlCol.Attributes['csmEnStorCurr'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmENstorMax:=GLxmlCol.Attributes['csmEnStorMax'];
                     FCentities[GLentCnt].E_col[GLcount].COL_eiOut:=GLxmlCol.Attributes['eiOut'];
                     GLxmlColsub:=GLxmlCol.ChildNodes.First;
                     while GLxmlColsub<>nil do
                     begin
                        {.colony population}
                        if GLxmlColsub.NodeName='colPopulation'
                        then
                        begin
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_total:=GLxmlColsub.Attributes['popTtl'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_meanA:=GLxmlColsub.Attributes['popMeanAge'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_dRate:=GLxmlColsub.Attributes['popDRate'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_dStack:=GLxmlColsub.Attributes['popDStack'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_bRate:=GLxmlColsub.Attributes['popBRate'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_bStack:=GLxmlColsub.Attributes['popBStack'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpColon:=GLxmlColsub.Attributes['popColon'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpColonAssigned:=GLxmlColsub.Attributes['popColonAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpASoff:=GLxmlColsub.Attributes['popOff'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpASoffAssigned:=GLxmlColsub.Attributes['popOffAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpASmiSp:=GLxmlColsub.Attributes['popMisSpe'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpASmiSpAssigned:=GLxmlColsub.Attributes['popMisSpeAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpBSbio:=GLxmlColsub.Attributes['popBiol'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpBSbioAssigned:=GLxmlColsub.Attributes['popBiolAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpBSdoc:=GLxmlColsub.Attributes['popDoc'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpBSdocAssigned:=GLxmlColsub.Attributes['popDocAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpIStech:=GLxmlColsub.Attributes['popTech'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpIStechAssigned:=GLxmlColsub.Attributes['popTechAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpISeng:=GLxmlColsub.Attributes['popEng'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpISengAssigned:=GLxmlColsub.Attributes['popEngAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpMSsold:=GLxmlColsub.Attributes['popSold'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpMSsoldAssigned:=GLxmlColsub.Attributes['popSoldAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpMScomm:=GLxmlColsub.Attributes['popComm'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpMScommAssigned:=GLxmlColsub.Attributes['popCommAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpPSphys:=GLxmlColsub.Attributes['popPhys'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpPSphysAssigned:=GLxmlColsub.Attributes['popPhysAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpPSastr:=GLxmlColsub.Attributes['popAstro'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpPSastrAssigned:=GLxmlColsub.Attributes['popAstroAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpESecol:=GLxmlColsub.Attributes['popEcol'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpESecolAssigned:=GLxmlColsub.Attributes['popEcolAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpESecof:=GLxmlColsub.Attributes['popEcof'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpESecofAssigned:=GLxmlColsub.Attributes['popEcofAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpAmedian:=GLxmlColsub.Attributes['popMedian'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpAmedianAssigned:=GLxmlColsub.Attributes['popMedianAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpRebels:=GLxmlColsub.Attributes['popRebels'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpMilitia:=GLxmlColsub.Attributes['popMilitia'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_wcpTotal:=GLxmlColsub.Attributes['wcpTotal'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_wcpAssignedPeople:=GLxmlColsub.Attributes['wcpAssignPpl'];
                        end
                        {.colony events}
                        else if GLxmlColsub.NodeName='colEvent'
                        then
                        begin
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_evList, length(FCentities[GLentCnt].E_col[GLcount].COL_evList)+1);
                           inc(GLevCnt);
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_token:=GLxmlColsub.Attributes['token'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_isRes:=GLxmlColsub.Attributes['isres'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_duration:=GLxmlColsub.Attributes['duration'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_lvl:=GLxmlColsub.Attributes['level'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_cohMod:=GLxmlColsub.Attributes['modcoh'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_tensMod:=GLxmlColsub.Attributes['modtens'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_secMod:=GLxmlColsub.Attributes['modsec'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_eduMod:=GLxmlColsub.Attributes['modedu'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_iecoMod:=GLxmlColsub.Attributes['modieco'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_healMod:=GLxmlColsub.Attributes['modheal'];
                        end
                        {.colony settlements}
                        else if GLxmlColsub.NodeName='colSettlement'
                        then
                        begin
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_settlements, length(FCentities[GLentCnt].E_col[GLcount].COL_settlements)+1);
                           inc(GLsettleCnt);
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra, 1);
                           FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_name:=GLxmlColsub.Attributes['name'];
                           GLsettleType:=GLxmlColsub.Attributes['type'];
                           if GLsettleType='stSurface'
                           then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_type:=stSurface
                           else if GLsettleType='stSpaceSurf'
                           then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_type:=stSpaceSurf
                           else if GLsettleType='stSubterranean'
                           then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_type:=stSubterranean
                           else if GLsettleType='stSpaceBased'
                           then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_type:=stSpaceBased;
                           FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_level:=GLxmlColsub.Attributes['level'];
                           FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_region:=GLxmlColsub.Attributes['region'];
                           GLregionIdx:=FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_region;
                           if GLoobjRow[4]=0
                           then
                           begin
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_regions[GLregionIdx].OOR_setEnt:=GLentCnt;
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_regions[GLregionIdx].OOR_setCol:=GLcount;
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_regions[GLregionIdx].OOR_setSet:=GLsettleCnt;
                           end
                           else if GLoobjRow[4]>0
                           then
                           begin
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_satList[GLoobjRow[4]].OOS_regions[GLregionIdx].OOR_setEnt:=GLentCnt;
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_satList[GLoobjRow[4]].OOS_regions[GLregionIdx].OOR_setCol:=GLcount;
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_satList[GLoobjRow[4]].OOS_regions[GLregionIdx].OOR_setSet:=GLsettleCnt;
                           end;
                           GLinfCnt:=0;
                           GLxmlInfra:=GLxmlColsub.ChildNodes.First;
                           while GLxmlInfra<>nil do
                           begin
                              SetLength(
                                 FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra
                                 ,length(FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra
                                 )+1);
                              inc(GLinfCnt);
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_dbToken:=GLxmlInfra.Attributes['token'];
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_level:=GLxmlInfra.Attributes['level'];
                              GLinfStatus:=GLxmlInfra.Attributes['status'];
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_cabDuration:=GLxmlInfra.Attributes['CABduration'];
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_cabWorked:=GLxmlInfra.Attributes['CABworked'];
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_powerCons:=GLxmlInfra.Attributes['powerCons'];
                              if GLinfStatus='istInKit'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istInKit
                              else if GLinfStatus='istInConversion'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istInConversion
                              else if GLinfStatus='istInAssembling'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istInAssembling
                              else if GLinfStatus='istInBldSite'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istInBldSite
                              else if GLinfStatus='istDisabled'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istDisabled
                              else if GLinfStatus='istDisabledByEE'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istDisabledByEE
                              else if GLinfStatus='istInTransition'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istInTransition
                              else if GLinfStatus='istOperational'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istOperational
                              else if GLinfStatus='istDestroyed'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istDestroyed;
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_function:=GLxmlInfra.Attributes['Func'];
                              case FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_function of
                                 fEnergy: FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_fEnergOut:=GLxmlInfra.Attributes['energyOut'];
                                 fHousing:
                                 begin
                                    FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_fhousPCAP:=GLxmlInfra.Attributes['PCAP'];
                                    FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_fhousQOL:=GLxmlInfra.Attributes['QOL'];
                                    FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_fhousVol:=GLxmlInfra.Attributes['vol'];
                                    FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_fhousSurf:=GLxmlInfra.Attributes['surf'];
                                 end;
                              end;
                              GLxmlInfra:=GLxmlInfra.NextSibling;
                           end; //==END== while GLxmlInfra<>nil do ==//
                        end //==END== else if GLxmlColsub.NodeName='colSettlement' ==//
                        {.colony's CAB queue}
                        else if GLxmlColsub.NodeName='colCAB'
                        then
                        begin
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_cabQueue, GLsettleCnt+1);
                           GLsettleMax:=GLsettleCnt;
                           GLsettleCnt:=1;
                           while GLsettleCnt<=GLsettleMax do
                           begin
                              SetLength(FCentities[GLentCnt].E_col[GLcount].COL_cabQueue[GLsettleCnt], 1);
                              inc(GLsettleCnt);
                           end;
                           GLxmlCAB:=GLxmlColsub.ChildNodes.First;
                           while GLxmlCAB<>nil do
                           begin
                              GLsettleCnt:=GLxmlCAB.Attributes['settlement'];
                              GLcabValue:=GLxmlCAB.Attributes['infraIdx'];
                              SetLength(FCentities[GLentCnt].E_col[GLcount].COL_cabQueue[GLsettleCnt], length(FCentities[GLentCnt].E_col[GLcount].COL_cabQueue[GLsettleCnt])+1);
                              GLcabCnt:=length(FCentities[GLentCnt].E_col[GLcount].COL_cabQueue[GLsettleCnt])-1;
                              FCentities[GLentCnt].E_col[GLcount].COL_cabQueue[GLsettleCnt, GLcabCnt]:=GLcabValue;
                              GLxmlCAB:=GLxmlCAB.NextSibling;
                           end;
                        end
                        {.colony's production matrix}
                        else if GLxmlColsub.NodeName='colProdMatrix'
                        then
                        begin
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_productionMatrix, 1);
                           GLprodMatrixCnt:=0;
                           GLxmlProdMatrix:=GLxmlColsub.ChildNodes.First;
                           while GLxmlProdMatrix<>nil do
                           begin
                              inc(GLprodMatrixCnt);
                              SetLength(FCentities[GLentCnt].E_col[GLcount].COL_productionMatrix, GLprodMatrixCnt+1);
                              FCentities[GLentCnt].E_col[GLcount].COL_productionMatrix[GLprodMatrixCnt].CPMI_token:=GLxmlProdMatrix.Attributes['token'];
                              FCentities[GLentCnt].E_col[GLcount].COL_productionMatrix[GLprodMatrixCnt].CPMI_unit:=GLxmlProdMatrix.Attributes['unit'];
                              FCentities[GLentCnt].E_col[GLcount].COL_productionMatrix[GLprodMatrixCnt].CPMI_StorageIndex:=GLxmlProdMatrix.Attributes['storIdx'];
                              GLxmlProdMatrix:=GLxmlProdMatrix.NextSibling;
                           end;
                        end
                        {.colony's storage}
                        else if GLxmlColsub.NodeName='colStorage'
                        then
                        begin
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacitySolidCurr:=GLxmlColsub.Attributes['capSolidCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacitySolidMax:=GLxmlColsub.Attributes['capSolidMax'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityLiquidCurr:=GLxmlColsub.Attributes['capLiquidCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityLiquidMax:=GLxmlColsub.Attributes['capLiquidMax'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityGasCurr:=GLxmlColsub.Attributes['capGasCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityGasMax:=GLxmlColsub.Attributes['capGasMax'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityBioCurr:=GLxmlColsub.Attributes['capBioCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityBioMax:=GLxmlColsub.Attributes['capBioMax'];
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_storageList, 1);
                           GLstorageCnt:=0;
                           GLxmlStorage:=GLxmlColsub.ChildNodes.First;
                           while GLxmlStorage<>nil do
                           begin
                              inc(GLstorageCnt);
                              SetLength(FCentities[GLentCnt].E_col[GLcount].COL_storageList, GLstorageCnt+1);
                              FCentities[GLentCnt].E_col[GLcount].COL_storageList[GLstorageCnt].CPR_token:=GLxmlStorage.Attributes['token'];
                              FCentities[GLentCnt].E_col[GLcount].COL_storageList[GLstorageCnt].CPR_unit:=GLxmlStorage.Attributes['unit'];
                              GLxmlStorage:=GLxmlStorage.NextSibling;
                           end;
                        end
                        else if GLxmlColsub.NodeName='colReserves'
                        then
                        begin
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveFoodCur:=GLxmlColsub.Attributes['foodCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveFoodMax:=GLxmlColsub.Attributes['foodMax'];
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveOxygenCur:=GLxmlColsub.Attributes['oxygenCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveOxygenMax:=GLxmlColsub.Attributes['oxygenMax'];
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveWaterCur:=GLxmlColsub.Attributes['waterCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveWaterMax:=GLxmlColsub.Attributes['waterMax'];
								end;
                        GLxmlColsub:=GLxmlColsub.NextSibling;
                     end; //==END== while GLxmlColsub<>nil do ==//
                     GLxmlCol:=GLxmlCol.NextSibling;
                  end; //==END== while GLxmlCol<>nil do ==//
               end //==END== else if GLxmlEntSubRoot.NodeName='entColonies' ==//
               else if GLxmlEntSubRoot.NodeName='entSPMset'
               then
               begin
                  FCentities[GLentCnt].E_spmMcohes:=GLxmlEntSubRoot.Attributes['modCoh'];
                  FCentities[GLentCnt].E_spmMtens:=GLxmlEntSubRoot.Attributes['modTens'];
                  FCentities[GLentCnt].E_spmMsec:=GLxmlEntSubRoot.Attributes['modSec'];
                  FCentities[GLentCnt].E_spmMedu:=GLxmlEntSubRoot.Attributes['modEdu'];
                  FCentities[GLentCnt].E_spmMnat:=GLxmlEntSubRoot.Attributes['modNat'];
                  FCentities[GLentCnt].E_spmMhealth:=GLxmlEntSubRoot.Attributes['modHeal'];
                  FCentities[GLentCnt].E_spmMBur:=GLxmlEntSubRoot.Attributes['modBur'];
                  FCentities[GLentCnt].E_spmMCorr:=GLxmlEntSubRoot.Attributes['modCorr'];
                  GLcount:=0;
                  GLxmlSPMset:=GLxmlEntSubRoot.ChildNodes.First;
                  while GLxmlSPMset<>nil do
                  begin
                     SetLength(FCentities[GLentCnt].E_spm, length(FCentities[GLentCnt].E_spm)+1);
                     inc(GLcount);
                     FCentities[GLentCnt].E_spm[GLcount].SPMS_token:=GLxmlSPMset.Attributes['token'];
                     FCentities[GLentCnt].E_spm[GLcount].SPMS_duration:=GLxmlSPMset.Attributes['duration'];
                     FCentities[GLentCnt].E_spm[GLcount].SPMS_ucCost:=GLxmlSPMset.Attributes['ucCost'];
                     FCentities[GLentCnt].E_spm[GLcount].SPMS_isPolicy:=GLxmlSPMset.Attributes['ispolicy'];
                     if FCentities[GLentCnt].E_spm[GLcount].SPMS_isPolicy
                     then
                     begin
                        FCentities[GLentCnt].E_spm[GLcount].SPMS_isSet:=GLxmlSPMset.Attributes['isSet'];
                        FCentities[GLentCnt].E_spm[GLcount].SPMS_aprob:=GLxmlSPMset.Attributes['aprob'];
                     end
                     else if not FCentities[GLentCnt].E_spm[GLcount].SPMS_isPolicy
                     then
                     begin
                        FCentities[GLentCnt].E_spm[GLcount].SPMS_bLvl:=GLxmlSPMset.Attributes['belieflvl'];
                        FCentities[GLentCnt].E_spm[GLcount].SPMS_sprdVal:=GLxmlSPMset.Attributes['spreadval'];
                     end;
                     GLxmlSPMset:=GLxmlSPMset.NextSibling;
                  end;
               end; //==END== if GLxmlEntSubRoot.NodeName='entSPMset' ==//
               GLxmlEntSubRoot:=GLxmlEntSubRoot.NextSibling;
            end; //==END== while GLxmlEntSubRoot<>nil do ==//
            inc(GLentCnt);
            GLxmlEnt:=GLxmlEnt.NextSibling;
         end; //==END== while GLxmlEnt<>nil do ==//
      end; //==END== if GLxmlEntRoot<>nil FOR COLONIES==//
      {.read "msgqueue" saved game item}
      setlength(FCVmsgStoTtl,1);
      setlength(FCVmsgStoMsg,1);
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfMsgQueue');
      if GLxmlItm<>nil
      then
      begin
         GLcount:=0;
         GLxmlMsg:=GLxmlItm.ChildNodes.First;
         while GLxmlMsg<>nil do
         begin
            SetLength(FCVmsgStoTtl, length(FCVmsgStoTtl)+1);
            SetLength(FCVmsgStoMsg, length(FCVmsgStoMsg)+1);
            inc(GLcount);
            FCVmsgStoTtl[GLcount]:=GLxmlMsg.Attributes['msgTitle'];
            FCVmsgStoMsg[GLcount]:=GLxmlMsg.Attributes['msgMain'];
            GLxmlMsg:=GLxmlMsg.NextSibling;
         end;
      end; {.if GLxmlGamItm<>nil}
   end //==END== if (DirectoryExists(GLcurrDir)) and (FileExists(GLcurrDir+'\'+GLcurrG)) ==//
   else FCRplayer.P_starSysLoc:='';
   {.free the memory}
   FCWinMain.FCXMLsave.Active:=false;
   FCWinMain.FCXMLsave.FileName:='';
end;

procedure FCMdFSG_Game_Save;
{:Purpose: save the current game.
    Additions:
      -2011Oct10- *add: list for surveyed resources.
      -2011Jul31- *add: infrastructure status istDisabledByEE.
      -2011Jul19- *add: CSM Energy module - storage data.
      -2011Jul13- *add: infrastructure consumed power.
      -2011Jul12- *add: CSM - Energy data.
      -2011Jul07- *add: colonies' production matrix.
      -2011May25- *rem: infrastructure - converted housing, useless state.
      -2011May15-	*add: colony's infrastructure - CAB worked hours.
      -2011May05- *mod: complete change of colony's storage loading/saving.
      -2011Apr26- *add: colonies' assigned population data.
                  *add: colonies' construction workforce.
      -2011Apr24- *add: energy output for Energy class infrastructures.
      -2011Apr20- *add: CPS - isEnabled.
      -2011Mar16-	*add: colonies' storages + reserves.
      -2011Mar09- *add: infrastructure's CAB duration.
                  *add: colonies' CAB queue.
      -2011Mar07- *add: converted housing infrastructures.
      -2011Feb12- *add: extra task's data.
                  *add: settlements.
      -2011Feb08- *add: full status token saving, independent of the index.
      -2011Feb01- *add: economic & industrial output.
      -2010Dec29- *add: SPM cost storage data.
      -2010Dec19- *add: entities higher hq level present in the faction.
      -2010Nov08- *add: entities UC reserve.
      -2010Nov03- *add: SPMi duration.
      -2010Oct24- *add: HQ presence data for each colony.
      -2010Oct11- *add: player's faction status of the 3 categories.
      -2010Oct07- *add: memes values + policy status.
      -2010Sep29- *add: entity's bureaucracy and corruption modifiers.
      -2010Sep22- *add: bureaucracy and corruption entities data.
                  *add: SPMi isSet data.
      -2010Sep21- *add: spm settings for entities.
      -2010Sep16- *add: entities code.
      -2010Sep07- *add: saving in specific file now, including date/time: name-yr-mth-day-h-mn.
                  *add: save current file time frame in configuration file.
      -2010Aug30- *add: CSM Phase list.
      -2010Aug19- *add: population type: militia.
      -2010Aug16- *add: population type: rebels.
      -2010Aug09- *add: CSM event duration.
      -2010Aug02- *add: CSM event health modifier.
      -2010Jul27- *add: CSM event level + economic & industrial output modifier.
      -2010Jul21- *add: csmTime data.
      -2010Jul02- *add: tasklisk string data.
      -2010Jun08- *add: space unit: include the docked sub data structure.
      -2010May30- *add: colony's population sub-datastructure.
      -2010May27- *add: csm data pcap, spl, qol and heal.
      -2010May19- *add: colony infrastructures: status.
      -2010May18- *add: colony infrastructures.
      -2010May12- *add: in process task phase data.
      -2010May10- *add: the two time2xfert data.
      -2010May05- *add: TITP_regIdx.
      -2010May04- *add: TITP_timeOrg, TITP_orgType, TITP_timeDecel, TITP_accelbyTick.
                  *mod: threads saving is disabled.
      -2010Mar31- *add: colony level.
      -2010Mar27- *add: space unit docked data.
      -2010Mar22- *add: cps time left
      -2010Mar11- *add: cps data.
      -2010Mar03- *add: owned colonies.
      -2010Jan08- *mod: change gameflow state method according to game flow changes.
      -2009Dec19- *add: player's sat location.
      -2009Dec18- *add: satellite location for owned space unit.
      -2009Nov28- *add messages queue.
      -2009Nov27- *add TITP_usedRMassV.
      -2009Nov12- *add threads.
      -2009Nov10- *add tasklist in process.
      -2009Nov09- *pause the game if FAR Colony is not in closing process, and release it
                  after.
      -2009Nov08- *add owned space units.
}
var
   GSxmlCAB
   ,GSxmlCABroot
   ,GSxmlCol
   ,GSxmlColEv
   ,GSxmlColInf
   ,GSxmlCPS
   ,GSxmlCSMpL
   ,GSxmlCSMpLsub
   ,GSxmlDock
   ,GSxmlEntRoot
   ,GSxmlEnt
   ,GSxmlItm
   ,GSxmlMsg
   ,GSxmlPop
   ,GSxmlProdMatrix
   ,GSxmlProdMatrixRoot
   ,GSxmlReserves
   ,GSxmlRoot
   ,GSxmlSettle
   ,GSxmlSPM
   ,GSxmlSpOwn
   ,GSxmlstorage
	,GSxmlstorageRoot
   ,GSxmlTskInPr
   ,GSxmlSurveyRsrc
   ,GSxmlSurveyRegion: IXMLNode;

   GScabCount
   ,GScabMax
   ,GScount
   ,GSsubCount
   ,GSsubMax
   ,GSdock
   ,GSlength
   ,GSphFac
   ,GSphItm
   ,GSspuMax
   ,GSspuCnt
   ,GScolMax
   ,GScolCnt
   ,GSprodMatrixCnt
   ,GSprodMatrixMax
   ,GSsettleCnt
   ,GSsettleMax
   ,GSstorageCnt
	,GSstorageMax
   ,GSspmMax
   ,GSspmCnt
   ,GSsubL
   ,GSsubC: integer;

   GScurrDir
   ,GScurrG
   ,GSinfStatus
   ,GSsettleTp: string;
begin
   if not FCWinMain.CloseQuery
   then FCMgTFlow_FlowState_Set(tphPAUSE);
   GScurrDir:=FCVcfgDir+'SavedGames\'+FCRplayer.P_gameName;
   GScurrG:=IntToStr(FCRplayer.P_timeYr)
      +'-'+IntToStr(FCRplayer.P_timeMth)
      +'-'+IntToStr(FCRplayer.P_timeday)
      +'-'+IntToStr(FCRplayer.P_timeHr)
      +'-'+IntToStr(FCRplayer.P_timeMin)
      +'.xml';
   {.create the save directory if needed}
   if not DirectoryExists(GScurrDir)
   then MkDir(GScurrDir);
   {.clear the old file if it exists}
   if FileExists(GScurrDir+'\'+GScurrG)
   then DeleteFile(pchar(GScurrDir+'\'+GScurrG));
   FCMdF_ConfigFile_Write(true);
   {.link and activate TXMLDocument}
   FCWinMain.FCXMLsave.Active:=true;
   {.create the root node of the saved game file}
   GSxmlRoot:=FCWinMain.FCXMLsave.AddChild('savedgfile');
   {.create "main" item}
   GSxmlItm:=GSxmlRoot.AddChild('gfMain');
   GSxmlItm.Attributes['gName']:= FCRplayer.P_gameName;
   GSxmlItm.Attributes['facAlleg']:= FCRplayer.P_facAlleg;
   GSxmlItm.Attributes['plyrsSSLoc']:= FCRplayer.P_starSysLoc;
   GSxmlItm.Attributes['plyrsStLoc']:= FCRplayer.P_starLoc;
   GSxmlItm.Attributes['plyrsOObjLoc']:= FCRplayer.P_oObjLoc;
   GSxmlItm.Attributes['plyrsatLoc']:=FCRplayer.P_satLoc;
   {.create "timeframe" item}
   GSxmlItm:=GSxmlRoot.AddChild('gfTimeFr');
   GSxmlItm.Attributes['tfTick']:= FCRplayer.P_timeTick;
   GSxmlItm.Attributes['tfMin']:= FCRplayer.P_timeMin;
   GSxmlItm.Attributes['tfHr']:= FCRplayer.P_timeHr;
   GSxmlItm.Attributes['tfDay']:= FCRplayer.P_timeday;
   GSxmlItm.Attributes['tfMth']:= FCRplayer.P_timeMth;
   GSxmlItm.Attributes['tfYr']:= FCRplayer.P_timeYr;
   {.create "status" item}
   GSxmlItm:=GSxmlRoot.AddChild('gfStatus');
   GSxmlItm.Attributes['statEco']:=FCRplayer.P_ecoStat;
   GSxmlItm.Attributes['statSoc']:=FCRplayer.P_socStat;
   GSxmlItm.Attributes['statMil']:=FCRplayer.P_milStat;
   {.create "cps" saved game item}
   if FCcps<>nil
   then
   begin
      GSlength:=length(FCcps.CPSviabObj);
      GSxmlItm:=GSxmlRoot.AddChild('gfCPS');
      GSxmlItm.Attributes['cpsEnabled']:=FCcps.CPSisEnabled;
      GSxmlItm.Attributes['cpsCVS']:=FCcps.FCF_CVS_Get;
      GSxmlItm.Attributes['cpsTlft']:=FCcps.FCF_TimeLeft_Get(true);
      GSxmlItm.Attributes['cpsInt']:=FCcps.FCF_CredInt_Get;
      GSxmlItm.Attributes['cpsCredU']:=FCcps.FCF_CredLine_Get(true, true);
      GSxmlItm.Attributes['cpsCredM']:=FCcps.FCF_CredLine_Get(false, true);
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlCPS:=GSxmlItm.AddChild('gfViabObj');
         GSxmlCPS.Attributes['objTp']:=FCcps.CPSviabObj[GScount].CPSO_type;
         GSxmlCPS.Attributes['score']:=FCcps.CPSviabObj[GScount].CPSO_score;
         inc(GScount);
      end; {.while GScount<=GSlength-1}
   end; //==END== if FCcps<>nil ==//
   {.create "taskinprocess" saved game item}
   GSlength:=length(FCGtskListInProc);
   if GSlength>1
   then
   begin
      GSxmlItm:=GSxmlRoot.AddChild('gfTskLstinProc');
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlTskInPr:=GSxmlItm.AddChild('gfTskInProc');
         GSxmlTskInPr.Attributes['tipEna']:=FCGtskListInProc[GScount].TITP_enabled;
         GSxmlTskInPr.Attributes['tipActTp']:=FCGtskListInProc[GScount].TITP_actionTp;
         GSxmlTskInPr.Attributes['tipPhase']:=FCGtskListInProc[GScount].TITP_phaseTp;
         GSxmlTskInPr.Attributes['tipTgtTp']:=FCGtskListInProc[GScount].TITP_ctldType;
         GSxmlTskInPr.Attributes['tipTgtFac']:=FCGtskListInProc[GScount].TITP_ctldFac;
         GSxmlTskInPr.Attributes['tipTgtIdx']:=FCGtskListInProc[GScount].TITP_ctldIdx;
         GSxmlTskInPr.Attributes['tipTimeOrg']:=FCGtskListInProc[GScount].TITP_timeOrg;
         GSxmlTskInPr.Attributes['tipDura']:=FCGtskListInProc[GScount].TITP_duration;
         GSxmlTskInPr.Attributes['tipInterv']:=FCGtskListInProc[GScount].TITP_interval;
         GSxmlTskInPr.Attributes['tipOrgTp']:=FCGtskListInProc[GScount].TITP_orgType;
         GSxmlTskInPr.Attributes['tipOrgIdx']:=FCGtskListInProc[GScount].TITP_orgIdx;
         GSxmlTskInPr.Attributes['tipDestTp']:=FCGtskListInProc[GScount].TITP_destType;
         GSxmlTskInPr.Attributes['tipDestIdx']:=FCGtskListInProc[GScount].TITP_destIdx;
         GSxmlTskInPr.Attributes['tipRegIdx']:=FCGtskListInProc[GScount].TITP_regIdx;
         GSxmlTskInPr.Attributes['tipVelCr']:=FCGtskListInProc[GScount].TITP_velCruise;
         GSxmlTskInPr.Attributes['tipTimeTcr']:=FCGtskListInProc[GScount].TITP_timeToCruise;
         GSxmlTskInPr.Attributes['tipTimeTdec']:=FCGtskListInProc[GScount].TITP_timeDecel;
         GSxmlTskInPr.Attributes['tipTime2Xfrt']:=FCGtskListInProc[GScount].TITP_time2xfert;
         GSxmlTskInPr.Attributes['tipTime2XfrtDec']:=FCGtskListInProc[GScount].TITP_time2xfert2decel;
         GSxmlTskInPr.Attributes['tipVelFin']:=FCGtskListInProc[GScount].TITP_velFinal;
         GSxmlTskInPr.Attributes['tipTimeTfin']:=FCGtskListInProc[GScount].TITP_timeToFinal;
         GSxmlTskInPr.Attributes['tipAccelBtick']:=FCGtskListInProc[GScount].TITP_accelbyTick;
         GSxmlTskInPr.Attributes['tipUsedRM']:=FCGtskListInProc[GScount].TITP_usedRMassV;
         GSxmlTskInPr.Attributes['tipStr1']:=FCGtskListInProc[GScount].TITP_str1;
         GSxmlTskInPr.Attributes['tipStr2']:=FCGtskListInProc[GScount].TITP_str1;
         GSxmlTskInPr.Attributes['tipInt1']:=FCGtskListInProc[GScount].TITP_int1;
         inc(GScount);
      end; {.while GScount<=GSlength-1}
   end; {.if GSlength>1 then... for taskinprocess}
   {.all surveyed resources}
   GSlength:=length(FCRplayer.P_SurveyedResourceSpots);
   if GSlength>1 then
   begin
      GSxmlItm:=GSxmlRoot.AddChild('gfSurveyedResourceSpots');
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlSurveyRsrc:=GSxmlItm.AddChild('gfSpotLocation');
         GSxmlSurveyRsrc.Attributes['oobj']:=FCRplayer.P_SurveyedResourceSpots[GScount].SS_oobjToken;
         GSxmlSurveyRsrc.Attributes['ssysIdx']:=FCRplayer.P_SurveyedResourceSpots[GScount].SS_ssysIndex;
         GSxmlSurveyRsrc.Attributes['starIdx']:=FCRplayer.P_SurveyedResourceSpots[GScount].SS_starIndex;
         GSxmlSurveyRsrc.Attributes['oobjIdx']:=FCRplayer.P_SurveyedResourceSpots[GScount].SS_oobjIndex;
         GSxmlSurveyRsrc.Attributes['satIdx']:=FCRplayer.P_SurveyedResourceSpots[GScount].SS_satIndex;
         GSsubMax:=length(FCRplayer.P_SurveyedResourceSpots[GScount].SS_surveyedRegions)-1;
         GSsubCount:=1;
         while GSsubCount<=GSsubMax do
         begin
            GSxmlSurveyRegion:=GSxmlSurveyRsrc.AddChild('gfSpotRegion');
            GSxmlSurveyRegion.Attributes['regionIdx']:=GSsubCount;
            GSxmlSurveyRegion.Attributes['spotType']:=GetEnumName(TypeInfo(TFCEduRsrcSpotType), Integer(FCRplayer.P_SurveyedResourceSpots[GScount].SS_surveyedRegions[GSsubCount].SR_type));
            GSxmlSurveyRegion.Attributes['meanQualCoef']:=FCRplayer.P_SurveyedResourceSpots[GScount].SS_surveyedRegions[GSsubCount].SR_MQC;
            GSxmlSurveyRegion.Attributes['spotSizCurr']:=FCRplayer.P_SurveyedResourceSpots[GScount].SS_surveyedRegions[GSsubCount].SR_SpotSizeCur;
            GSxmlSurveyRegion.Attributes['spotSizeMax']:=FCRplayer.P_SurveyedResourceSpots[GScount].SS_surveyedRegions[GSsubCount].SR_SpotSizeMax;
            inc(GSsubCount);
         end;
         inc(GScount);
      end; {.while GScount<=GSlength-1}
   end; //==END== if GSlength>1 then... for surveyed resource spots ==//
   {.create "CSM" saved game item}
   GSlength:=length(FCGcsmPhList);
   if GSlength>1
   then
   begin
      GSxmlItm:=GSxmlRoot.AddChild('gfCSM');
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlCSMpL:=GSxmlItm.AddChild('csmPhList');
         GSxmlCSMpL.Attributes['csmTick']:=FCGcsmPhList[GScount].CSMT_tick;
         GSphFac:=0;
         while GSphFac<=1 do
         begin
            GSsubL:=length(FCGcsmPhList[GScount].CSMT_col[GSphFac])-1;
            GSsubC:=1;
            if GSsubL>0
            then
            begin
               while GSsubC<=GSsubL do
               begin
                  GSxmlCSMpLsub:=GSxmlCSMpL.AddChild('csmPhase');
                  GSxmlCSMpLsub.Attributes['fac']:=GSphFac;
                  GSxmlCSMpLsub.Attributes['colony']:=FCGcsmPhList[GScount].CSMT_col[GSphFac, GSsubL];
                  inc(GSsubC);
               end;
            end;
            inc(GSphFac);
         end;
         inc(GScount);
      end; //==END== while GScount<=GSlength-1 ==//
   end; //==END== if GSlength>1 for CSM ==//
   {.create entities section}
   GSxmlEntRoot:=GSxmlRoot.AddChild('gfEntities');
   GScount:=0;
   while GScount<=FCCfacMax do
   begin
      GSxmlEnt:=GSxmlEntRoot.AddChild('entity');
      GSxmlEnt.Attributes['token']:=FCentities[GScount].E_token;
      GSxmlEnt.Attributes['lvl']:=FCentities[GScount].E_facLvl;
      GSxmlEnt.Attributes['bur']:=FCentities[GScount].E_bureau;
      GSxmlEnt.Attributes['corr']:=FCentities[GScount].E_corrupt;
      GSxmlEnt.Attributes['hqHlvl']:=FCentities[GScount].E_hqHigherLvl;
      GSxmlEnt.Attributes['UCrve']:=FCentities[GScount].E_uc;
      GSspuMax:=Length(FCentities[GScount].E_spU)-1;
      if GSspuMax>0
      then
      begin
         GSxmlItm:=GSxmlEnt.AddChild('entOwnSpU');
         GSspuCnt:=1;
         while GSspuCnt<=GSspuMax do
         begin
            GSdock:=length(FCentities[GScount].E_spU[GSspuCnt].SUO_dockedSU)-1;
            GSxmlSpOwn:=GSxmlItm.AddChild('entSpU');
            GSxmlSpOwn.Attributes['tokenId']:=FCentities[GScount].E_spU[GSspuCnt].SUO_spUnToken;
            GSxmlSpOwn.Attributes['tokenName']:=FCentities[GScount].E_spU[GSspuCnt].SUO_nameToken;
            GSxmlSpOwn.Attributes['desgnId']:=FCentities[GScount].E_spU[GSspuCnt].SUO_designId;
            GSxmlSpOwn.Attributes['ssLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_starSysLoc;
            GSxmlSpOwn.Attributes['stLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_starLoc;
            GSxmlSpOwn.Attributes['oobjLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_oobjLoc;
            GSxmlSpOwn.Attributes['satLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_satLoc;
            GSxmlSpOwn.Attributes['TdObjIdx']:=FCentities[GScount].E_spU[GSspuCnt].SUO_3dObjIdx;
            GSxmlSpOwn.Attributes['xLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_locStarX;
            GSxmlSpOwn.Attributes['zLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_locStarZ;
            GSxmlSpOwn.Attributes['docked']:=GSdock;
            GSsubC:=1;
            while GSsubC<=GSdock do
            begin
               GSxmlDock:=GSxmlSpOwn.AddChild('entSpUdckd');
               GSxmlDock.Attributes['token']:=FCentities[GScount].E_spU[GSspuCnt].SUO_dockedSU[GSsubC].SUD_dckdToken;
               inc(GSsubC);
            end;
            GSxmlSpOwn.Attributes['taskId']:=FCentities[GScount].E_spU[GSspuCnt].SUO_taskIdx;
            GSxmlSpOwn.Attributes['status']:=FCentities[GScount].E_spU[GSspuCnt].SUO_status;
            GSxmlSpOwn.Attributes['dV']:=FCentities[GScount].E_spU[GSspuCnt].SUO_deltaV;
            GSxmlSpOwn.Attributes['TdMov']:=FCentities[GScount].E_spU[GSspuCnt].SUO_3dmove;
            GSxmlSpOwn.Attributes['availRMass']:=FCentities[GScount].E_spU[GSspuCnt].SUO_availRMass;
            inc(GSspuCnt);
         end; {.while GSspuCnt<=GSspuMax}
      end; //==END== if GSspuMax>0 ==//
      GScolMax:=Length(FCentities[GScount].E_col)-1;
      if GScolMax>0
      then
      begin
         GSxmlItm:=GSxmlEnt.AddChild('entColonies');
         GScolCnt:=1;
         while GScolCnt<=GScolMax do
         begin
            GSxmlCol:=GSxmlItm.AddChild('entColony');
            GSxmlCol.Attributes['prname']:=FCentities[GScount].E_col[GScolCnt].COL_name;
            GSxmlCol.Attributes['fndyr']:=FCentities[GScount].E_col[GScolCnt].COL_fndYr;
            GSxmlCol.Attributes['fndmth']:=FCentities[GScount].E_col[GScolCnt].COL_fndMth;
            GSxmlCol.Attributes['fnddy']:=FCentities[GScount].E_col[GScolCnt].COL_fndDy;
            GSxmlCol.Attributes['csmtime']:=FCentities[GScount].E_col[GScolCnt].COL_csmtime;
            GSxmlCol.Attributes['locssys']:=FCentities[GScount].E_col[GScolCnt].COL_locSSys;
            GSxmlCol.Attributes['locstar']:=FCentities[GScount].E_col[GScolCnt].COL_locStar;
            GSxmlCol.Attributes['locoobj']:=FCentities[GScount].E_col[GScolCnt].COL_locOObj;
            GSxmlCol.Attributes['locsat']:=FCentities[GScount].E_col[GScolCnt].COL_locSat;
            GSxmlCol.Attributes['collvl']:=FCentities[GScount].E_col[GScolCnt].COL_level;
            GSxmlCol.Attributes['hqpresence']:=FCentities[GScount].E_col[GScolCnt].COL_hqPres;
            GSxmlCol.Attributes['dcohes']:=FCentities[GScount].E_col[GScolCnt].COL_cohes;
            GSxmlCol.Attributes['dsecu']:=FCentities[GScount].E_col[GScolCnt].COL_secu;
            GSxmlCol.Attributes['dtens']:=FCentities[GScount].E_col[GScolCnt].COL_tens;
            GSxmlCol.Attributes['dedu']:=FCentities[GScount].E_col[GScolCnt].COL_edu;
            GSxmlCol.Attributes['csmPCAP']:=FCentities[GScount].E_col[GScolCnt].COL_csmHOpcap;
            GSxmlCol.Attributes['csmSPL']:=FCentities[GScount].E_col[GScolCnt].COL_csmHOspl;
            GSxmlCol.Attributes['csmQOL']:=FCentities[GScount].E_col[GScolCnt].COL_csmHOqol;
            GSxmlCol.Attributes['csmHEAL']:=FCentities[GScount].E_col[GScolCnt].COL_csmHEheal;
            GSxmlCol.Attributes['csmEnCons']:=FCentities[GScount].E_col[GScolCnt].COL_csmENcons;
            GSxmlCol.Attributes['csmEnGen']:=FCentities[GScount].E_col[GScolCnt].COL_csmENgen;
            GSxmlCol.Attributes['csmEnStorCurr']:=FCentities[GScount].E_col[GScolCnt].COL_csmENstorCurr;
            GSxmlCol.Attributes['csmEnStorMax']:=FCentities[GScount].E_col[GScolCnt].COL_csmENstorMax;
            GSxmlCol.Attributes['eiOut']:=FCentities[GScount].E_col[GScolCnt].COL_eiOut;
            {.colony population}
            GSxmlPop:=GSxmlCol.AddChild('colPopulation');
            GSxmlPop.Attributes['popTtl']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_total;
            GSxmlPop.Attributes['popMeanAge']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_meanA;
            GSxmlPop.Attributes['popDRate']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_dRate;
            GSxmlPop.Attributes['popDStack']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_dStack;
            GSxmlPop.Attributes['popBRate']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_bRate;
            GSxmlPop.Attributes['popBStack']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_bStack;
            GSxmlPop.Attributes['popColon']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpColon;
            GSxmlPop.Attributes['popColonAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpColonAssigned;
            GSxmlPop.Attributes['popOff']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpASoff;
            GSxmlPop.Attributes['popOffAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpASoffAssigned;
            GSxmlPop.Attributes['popMisSpe']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpASmiSp;
            GSxmlPop.Attributes['popMisSpeAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpASmiSpAssigned;
            GSxmlPop.Attributes['popBiol']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpBSbio;
            GSxmlPop.Attributes['popBiolAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpBSbioAssigned;
            GSxmlPop.Attributes['popDoc']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpBSdoc;
            GSxmlPop.Attributes['popDocAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpBSdocAssigned;
            GSxmlPop.Attributes['popTech']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpIStech;
            GSxmlPop.Attributes['popTechAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpIStechAssigned;
            GSxmlPop.Attributes['popEng']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpISeng;
            GSxmlPop.Attributes['popEngAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpISengAssigned;
            GSxmlPop.Attributes['popSold']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpMSsold;
            GSxmlPop.Attributes['popSoldAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpMSsoldAssigned;
            GSxmlPop.Attributes['popComm']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpMScomm;
            GSxmlPop.Attributes['popCommAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpMScommAssigned;
            GSxmlPop.Attributes['popPhys']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpPSphys;
            GSxmlPop.Attributes['popPhysAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpPSphysAssigned;
            GSxmlPop.Attributes['popAstro']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpPSastr;
            GSxmlPop.Attributes['popAstroAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpPSastrAssigned;
            GSxmlPop.Attributes['popEcol']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpESecol;
            GSxmlPop.Attributes['popEcolAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpESecolAssigned;
            GSxmlPop.Attributes['popEcof']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpESecof;
            GSxmlPop.Attributes['popEcofAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpESecofAssigned;
            GSxmlPop.Attributes['popMedian']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpAmedian;
            GSxmlPop.Attributes['popMedianAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpAmedianAssigned;
            GSxmlPop.Attributes['popRebels']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpRebels;
            GSxmlPop.Attributes['popMilitia']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpMilitia;
            GSxmlPop.Attributes['wcpTotal']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_wcpTotal;
            GSxmlPop.Attributes['wcpAssignPpl']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_wcpAssignedPeople;
            {.colony events}
            GSsubL:=length(FCentities[GScount].E_col[GScolCnt].COL_evList);
            if GSsubL>1
            then
            begin
               GSsubC:=1;
               while GSsubC<=GSsubL-1 do
               begin
                  GSxmlColEv:=GSxmlCol.AddChild('colEvent');
                  GSxmlColEv.Attributes['token']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_token;
                  GSxmlColEv.Attributes['isres']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_isRes;
                  GSxmlColEv.Attributes['duration']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_duration;
                  GSxmlColEv.Attributes['level']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_lvl;
                  GSxmlColEv.Attributes['modcoh']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_cohMod;
                  GSxmlColEv.Attributes['modtens']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_tensMod;
                  GSxmlColEv.Attributes['modsec']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_secMod;
                  GSxmlColEv.Attributes['modedu']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_eduMod;
                  GSxmlColEv.Attributes['modieco']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_iecoMod;
                  GSxmlColEv.Attributes['modheal']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_healMod;
                  inc(GSsubC);
               end;
            end; //==END== if GSsubL>1 ==//
            {.colony settlements}
            GSsettleMax:=length(FCentities[GScount].E_col[GScolCnt].COL_settlements)-1;
            if GSsettleMax>0
            then
            begin
               GSxmlCABroot:=nil;
               GSsettleCnt:=1;
               while GSsettleCnt<=GSsettleMax do
               begin
                  GSxmlSettle:=GSxmlCol.AddChild('colSettlement');
                  GSxmlSettle.Attributes['name']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_name;
                  case FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_type of
                     stSurface: GSsettleTp:='stSurface';
                     stSpaceSurf: GSsettleTp:='stSpaceSurf';
                     stSubterranean: GSsettleTp:='stSubterranean';
                     stSpaceBased: GSsettleTp:='stSpaceBased';
                  end;
                  GSxmlSettle.Attributes['type']:=GSsettleTp;
                  GSxmlSettle.Attributes['level']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_level;
                  GSxmlSettle.Attributes['region']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_region;
                  GSsubL:=length(FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra)-1;
                  GSsubC:=1;
                  while GSsubC<=GSsubL do
                  begin
                     GSxmlColInf:=GSxmlSettle.AddChild('setInfra');
                     GSxmlColInf.Attributes['token']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_dbToken;
                     GSxmlColInf.Attributes['level']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_level;
                     case FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_status of
                        istInKit: GSinfStatus:='istInKit';
                        istInConversion: GSinfStatus:='istInConversion';
                        istInAssembling: GSinfStatus:='istInAssembling';
                        istInBldSite: GSinfStatus:='istInBldSite';
                        istDisabled: GSinfStatus:='istDisabled';
                        istDisabledByEE: GSinfStatus:='istDisabledByEE';
                        istInTransition: GSinfStatus:='istInTransition';
                        istOperational: GSinfStatus:='istOperational';
                        istDestroyed: GSinfStatus:='istDestroyed';
                     end;
                     GSxmlColInf.Attributes['status']:=GSinfStatus;
                     GSxmlColInf.Attributes['CABduration']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_cabDuration;
                     GSxmlColInf.Attributes['CABworked']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_cabWorked;
                     GSxmlColInf.Attributes['powerCons']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_powerCons;
                     GSxmlColInf.Attributes['Func']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_function;
                     case FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_function of
                        fEnergy: GSxmlColInf.Attributes['energyOut']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_fEnergOut;
                        fHousing:
                        begin
                           GSxmlColInf.Attributes['PCAP']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_fhousPCAP;
                           GSxmlColInf.Attributes['QOL']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_fhousQOL;
                           GSxmlColInf.Attributes['vol']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_fhousVol;
                           GSxmlColInf.Attributes['surf']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_fhousSurf;
                        end;
                     end;
                     inc(GSsubC);
                  end;
                  inc(GSsettleCnt);
               end; //==END== while GSsettleCnt<=GSsettleMax do ==//
               {.CAB queue}
               GSsettleCnt:=1;
               while GSsettleCnt<=GSsettleMax do
               begin
                  GScabMax:=length(FCentities[GScount].E_col[GScolCnt].COL_cabQueue[GSsettleCnt])-1;
                  if GScabMax>0
                  then
                  begin
                     if GSxmlCABroot=nil
                     then GSxmlCABroot:=GSxmlCol.AddChild('colCAB');
                     GScabCount:=1;
                     while GScabCount<=GScabMax do
                     begin
                        GSxmlCAB:=GSxmlCABroot.AddChild('cabItem');
                        GSxmlCAB.Attributes['settlement']:=GSsettleCnt;
                        GSxmlCAB.Attributes['infraIdx']:=FCentities[GScount].E_col[GScolCnt].COL_cabQueue[GSsettleCnt, GScabCount];
                        inc(GScabCount);
                     end;
                  end; //==END== if GScabMax>0 ==//
                  inc(GSsettleCnt);
               end;
               {.production matrix}
               GSprodMatrixMax:=Length(FCentities[GScount].E_col[GScolCnt].COL_productionMatrix)-1;
               if GSprodMatrixMax>0
               then
               begin
                  GSxmlProdMatrixRoot:=GSxmlCol.AddChild('colProdMatrix');
                  GSprodMatrixCnt:=1;
                  while GSprodMatrixCnt<=GSprodMatrixMax do
                  begin
                     GSxmlProdMatrix:=GSxmlProdMatrixRoot.AddChild('matrixItem');
                     GSxmlProdMatrix.Attributes['token']:=FCentities[GScount].E_col[GScolCnt].COL_productionMatrix[GSprodMatrixCnt].CPMI_token;
                     GSxmlProdMatrix.Attributes['unit']:=FCentities[GScount].E_col[GScolCnt].COL_productionMatrix[GSprodMatrixCnt].CPMI_unit;
                     GSxmlProdMatrix.Attributes['storIdx']:=FCentities[GScount].E_col[GScolCnt].COL_productionMatrix[GSprodMatrixCnt].CPMI_StorageIndex;
                     inc(GSprodMatrixCnt);
                  end;
               end;
               {.storage}
               GSxmlstorageRoot:=GSxmlCol.AddChild('colStorage');
               GSxmlstorageRoot.Attributes['capSolidCur']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacitySolidCurr;
               GSxmlstorageRoot.Attributes['capSolidMax']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacitySolidMax;
               GSxmlstorageRoot.Attributes['capLiquidCur']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityLiquidCurr;
               GSxmlstorageRoot.Attributes['capLiquidMax']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityLiquidMax;
               GSxmlstorageRoot.Attributes['capGasCur']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityGasCurr;
               GSxmlstorageRoot.Attributes['capGasMax']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityGasMax;
               GSxmlstorageRoot.Attributes['capBioCur']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityBioCurr;
               GSxmlstorageRoot.Attributes['capBioMax']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityBioMax;
					GSstorageMax:=length(FCentities[GScount].E_col[GScolCnt].COL_storageList)-1;
               if GSstorageMax>0
               then
               begin
                  GSstorageCnt:=1;
                  while GSstorageCnt<=GSstorageMax do
                  begin
                     GSxmlstorage:=GSxmlstorageRoot.AddChild('storItem'+IntToStr(GSstorageCnt));
                     GSxmlstorage.Attributes['token']:=FCentities[GScount].E_col[GScolCnt].COL_storageList[GSstorageCnt].CPR_token;
                     GSxmlstorage.Attributes['unit']:=FCentities[GScount].E_col[GScolCnt].COL_storageList[GSstorageCnt].CPR_unit;
                     inc(GSstorageCnt);
                  end;
               end;
               {.reserves}
               GSxmlReserves:=GSxmlCol.AddChild('colReserves');
               GSxmlReserves.Attributes['foodCur']:=FCentities[GScount].E_col[GScolCnt].COL_reserveFoodCur;
               GSxmlReserves.Attributes['foodMax']:=FCentities[GScount].E_col[GScolCnt].COL_reserveFoodMax;
               GSxmlReserves.Attributes['oxygenCur']:=FCentities[GScount].E_col[GScolCnt].COL_reserveOxygenCur;
               GSxmlReserves.Attributes['oxygenMax']:=FCentities[GScount].E_col[GScolCnt].COL_reserveOxygenMax;
               GSxmlReserves.Attributes['waterCur']:=FCentities[GScount].E_col[GScolCnt].COL_reserveWaterCur;
               GSxmlReserves.Attributes['waterMax']:=FCentities[GScount].E_col[GScolCnt].COL_reserveWaterMax;
            end; //==END== if GSsettleMax>0 ==//
            inc(GScolCnt);
         end; //==END== while GScolCnt<=GScolMax do ==//
      end; //==END== if GScolMax>0 ==//
      GSspmMax:=Length(FCentities[GScount].E_spm)-1;
      if GSspmMax>0
      then
      begin
         GSxmlItm:=GSxmlEnt.AddChild('entSPMset');
         GSxmlItm.Attributes['modCoh']:=FCentities[GScount].E_spmMcohes;
         GSxmlItm.Attributes['modTens']:=FCentities[GScount].E_spmMtens;
         GSxmlItm.Attributes['modSec']:=FCentities[GScount].E_spmMsec;
         GSxmlItm.Attributes['modEdu']:=FCentities[GScount].E_spmMedu;
         GSxmlItm.Attributes['modNat']:=FCentities[GScount].E_spmMnat;
         GSxmlItm.Attributes['modHeal']:=FCentities[GScount].E_spmMhealth;
         GSxmlItm.Attributes['modBur']:=FCentities[GScount].E_spmMBur;
         GSxmlItm.Attributes['modCorr']:=FCentities[GScount].E_spmMCorr;
         GSspmCnt:=1;
         while GSspmCnt<=GSspmMax do
         begin
            GSxmlSPM:=GSxmlItm.AddChild('entSPM');
            GSxmlSPM.Attributes['token']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_token;
            GSxmlSPM.Attributes['duration']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_duration;
            GSxmlSPM.Attributes['ucCost']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_ucCost;
            GSxmlSPM.Attributes['ispolicy']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_isPolicy;
            if FCentities[GScount].E_spm[GSspmCnt].SPMS_isPolicy
            then
            begin
               GSxmlSPM.Attributes['isSet']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_isSet;
               GSxmlSPM.Attributes['aprob']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_aprob;
            end
            else if not FCentities[GScount].E_spm[GSspmCnt].SPMS_isPolicy
            then
            begin
               GSxmlSPM.Attributes['belieflvl']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_bLvl;
               GSxmlSPM.Attributes['spreadval']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_aprob;
            end;
            inc(GSspmCnt);
         end;
      end;
      inc(GScount);
   end; //==END== while GScount<=FCCfacMax do ==//
   {.create "msgqueue" saved game item}
   GSlength:=length(FCVmsgStoMsg);
   if GSlength>1
   then
   begin
      GSxmlItm:=GSxmlRoot.AddChild('gfMsgQueue');
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlMsg:=GSxmlItm.AddChild('gfMsg');
         GSxmlMsg.Attributes['msgTitle']:=FCVmsgStoTtl[GScount];
         GSxmlMsg.Attributes['msgMain']:=FCVmsgStoMsg[GScount];
         inc(GScount);
      end; {.while GScount<=GSlength-1}
   end; {.if GSlength>1 then}
   FCWinMain.FCGLSHUDgameTime.Text:='Game Saved';
   {.write the file and free the memory}
   FCWinMain.FCXMLsave.SaveToFile(GScurrDir+'\'+GScurrG);
   FCWinMain.FCXMLsave.Active:=false;
   if not FCWinMain.CloseQuery
   then FCMgTFlow_FlowState_Set(tphTac);
end;

procedure FCMdFSG_Game_SaveAndFlushOther;
{:Purpose: save the current game and flush all other save game files than the current one.
    Additions:
}
var
   SFOtimeDay
   ,SFOtimeHr
   ,SFOtimeMin
   ,SFOtimeMth
   ,SFOtimeTick
   ,SFOtimeYr: integer;

   SFOcurrDir
   ,SFOcurrG: string;

   SFOxmlCurrGame: IXMLNode;
begin
   try
      FCMdFSG_Game_Save;
   finally
      {.read the document}
      FCWinMain.FCXMLcfg.FileName:=FCVpathCfg;
      FCWinMain.FCXMLcfg.Active:=true;
      SFOxmlCurrGame:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('currGame');
      if SFOxmlCurrGame<>nil
      then
      begin
         SFOtimeTick:=SFOxmlCurrGame.Attributes['tfTick'];
         SFOtimeMin:=SFOxmlCurrGame.Attributes['tfMin'];
         SFOtimeHr:=SFOxmlCurrGame.Attributes['tfHr'];
         SFOtimeDay:=SFOxmlCurrGame.Attributes['tfDay'];
         SFOtimeMth:=SFOxmlCurrGame.Attributes['tfMth'];
         SFOtimeYr:=SFOxmlCurrGame.Attributes['tfYr'];
      end;
      {.free the memory}
      FCWinMain.FCXMLcfg.Active:=false;
      FCWinMain.FCXMLcfg.FileName:='';
      SFOcurrDir:=FCVcfgDir+'SavedGames\'+FCRplayer.P_gameName;
      SFOcurrG:=IntToStr(SFOtimeYr)
         +'-'+IntToStr(SFOtimeMth)
         +'-'+IntToStr(SFOtimeDay)
         +'-'+IntToStr(SFOtimeHr)
         +'-'+IntToStr(SFOtimeMin)
         +'.xml';
      if FileExists(SFOcurrDir+'\'+SFOcurrG)
      then
      begin
         CopyFile(pchar(SFOcurrDir+'\'+SFOcurrG),pchar(FCVcfgDir+SFOcurrG),false);
         FCMcF_Files_Del(SFOcurrDir+'\','*.*');
         CopyFile(pchar(FCVcfgDir+SFOcurrG),pchar(SFOcurrDir+'\'+SFOcurrG),false);
         DeleteFile(pchar(FCVcfgDir+SFOcurrG));
      end;
   end;
end;

end.
