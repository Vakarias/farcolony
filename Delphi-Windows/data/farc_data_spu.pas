{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: space units - data unit

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
unit farc_data_spu;

interface

//uses

{.list of equipment modules classes}
{:DEV NOTES: update scdesignsdb.xml + FCMdFiles_DBSpaceCrafts_Read.}
type TFCEemClass=(
   {compartment}
   emcCompart
   {control as bridge or cockpit}
   ,emcCtrl
   {hull modification as a spinning hull w/ it's mechanism}
   ,emcHullMod
   {powergrid (generators and capacitors)}
   ,emcPwrGrid
   {space drive}
   ,emcSpDrive
   {subsystem}
   ,emcSubSys
   {weapon system}
   ,emcWeapSys
   );

{.architecture types}
{:REFERENCES LIST
   - scintstrucdb.xml
   - FCMdFiles_DBSpaceCrafts_Read
   - FCFdTFiles_UIStr_Get
   - FCMgMCore_Mission_Setup
   - FCFspuF_DockedSpU_GetNum
   - FCMuiW_FocusPopup_Upd
}
   type TFCEscArchTp=(
      {.for internal use only, do not put it in xml}
      scatNone
      {Deep-Space Vehicle}
      ,scarchtpDSV
      {Heavy-Lift Vehicle}
      ,scarchtpHLV
      {Lander Vehicle}
      ,scarchtpLV
      {Lander/Ascent Vehicle}
      ,scarchtpLAV
      {Orbital Multipurpose Vehicle}
      ,scarchtpOMV
      {Stabilized Space Infrastructure}
      ,scarchtpSSI
      {Transatmospheric Vehicle}
      ,scarchtpTAV
      {Beam Sail Vehicle}
      ,scarchtpBSV
      );
   {list of control module types}
   {:DEV NOTES: update scintstrucdb.xml + FCMdFiles_DBSpaceCrafts_Read.}
   type TFCEscCtlMdlTp=(
      {cockpit}
      sccmtCockpit
      {control bridge}
      ,sccmtBridge
      {unnamed controls - by an AI}
      ,sccmtUnna
      );
   {list of internal structure general shapes}
   {:DEV NOTE: UPDATE scintstrucdb.xml + FCMdFiles_DBSpaceCrafts_Read.}
   type TFCEisShape=(
      {assembled: assembled parts with a central beam or not}
      stAssem
      {composed of modules of SEV shape}
      ,stModul
      {spherical shape}
      ,stSpher
      {cylindrical shape}
      ,stCylin
      {streamlined cylindrical shape}
      ,stCylSt
      {streamlined delta shape}
      ,stDelta
      {box shape}
      ,stBox
      {toroidal shape}
      ,stTorus
      );

//==END PUBLIC ENUM=========================================================================

{datastructure of spacecraft's internal structures}
{:DEV NOTES: update FCMdFiles_DBSpaceCrafts_Read.}
   type TFCRscIntStr = record
      {internal infrastructure db token id}
      SCIS_token: string[20];
      {overall shape of the structure}
      SCIS_shape: TFCEisShape;
      {architecture type}
      SCIS_archTp: TFCEscArchTp;
      {type of control module allowed for the internal structure}
      SCIS_contMdlAllwd: TFCEscCtlMdlTp;
      {overall length in meter [RTO-1]}
      SCIS_length: extended;
      {overall wingsapn in meter [RTO-1]}
      SCIS_wingsp: extended;
      {overall height in meter [RTO-1]}
      SCIS_height: extended;
      {available volume for the design in cubic meter [RTO-1]}
      SCIS_availStrVol: extended;
      {available surface for the design in square meter [RTO-1]}
      SCIS_availStrSur: extended;
      {max volume, of total available, that can be occupied by the spacedrive [RTO-1]}
      SCIS_driveMaxVol: extended;
      {max surface, of total available, that can be occupied by the spacedrive [RTO-1]}
      SCIS_driveMaxSur: extended;
   end;
      {.spacecraft's internal structures dynamic array}
      TFCDBscintStruc = array of TFCRscIntStr;

      {:DEV NOTES: update FCMdFiles_DBSpaceCrafts_Read.}
   type TFCRscEqMdl = record
      SCEM_token: string[20];
      SCEM_emClass: TFCEemClass;
      //SCEM_subDriveData: Tlink to sub datastructure
//       SCEM_thrPerf: double; //rto-1 thrust / cubicmeter of volume of drive
                             {DEV NOTE: will be replaced later by a more
                             expanded structure (for taking in account R&D)}

   end;
      {.equipment modules dynamic array}
      TFCDBscEqMdls = array of TFCRscEqMdl;

   {datastructure of spacecraft's designs}
{:REFERENCES LIST
   - FCFcFunc_ScaleConverter
   - FCMdFiles_DBSpaceCrafts_Read
   - FCMgMCore_Mission_Setup
   - FCMgMiT_ITransit_Setup
   - FCFgMl_Land_Calc
   - FCMgNG_ColMode_Upd
   - FCMoglVM_SpUn_Gen
   - FCFspuF_Design_getDB
   - FCMuiWin_SpUnDck_Upd
}
   type TFCRspUdsgn = record
      {design db token id}
      SUD_token: string[20];
      {data structure clone of the internal structure linked to the design}
      SCD_intStrClone: TFCRscIntStr;
      {used volume out the available volume, in cubic meter [RTO-1}
      SCD_usedVol: extended;
      {used surface out the available surface, in square meter [RTO-1}
      SCD_usedSur: extended;
      {empty mass of the spacecraft, w/o payload & crew [RTO-2]}
      SCD_massEmp: extended;
      {list of installed equipment modules}
      SCD_eqMdlInst: array of TFCRscEqMdl;
      {ISP of installed space drive}
      SCD_spDriveISP: integer;
      {maximum reaction mass volume the spacecraft can carry}
      SCD_spDriveRMassMaxVol: extended;
      {.capabilities. when updated, update too: farc_spu_functions/TFCEsufCapab}
      SUD_capInterstel: boolean;
      SUD_capColoniz: boolean;
      SUD_capPassngr: boolean;
      SUD_capCombat: boolean;
      {DEV NOTE:
         total mass
         drive cloned: token / perf thr/vol of drive / rmass type product token
         total drive thr
      }
  end;
      {.spacecraft's designs dynamic array}
      TFCDBscDesigns = array of TFCRspUdsgn;

//==END PUBLIC RECORDS======================================================================

   //==========databases and other data structures pre-init=================================
var
   FCDBscDesigns: TFCDBscDesigns;
      FCDBscEqMdls: TFCDBscEqMdls;
      FCDBscIntStruc: TFCDBscintStruc;
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

implementation

//uses

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

end.
