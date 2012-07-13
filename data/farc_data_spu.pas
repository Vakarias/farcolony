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

{:REFERENCES LIST
   - scintstrucdb.xml
   - FCMdFiles_DBSpaceCrafts_Read
   - FCFdTFiles_UIStr_Get
   - FCMgMCore_Mission_Setup
   - FCFspuF_DockedSpU_GetNum
   - FCMuiW_FocusPopup_Upd
}
///<summary>
///   list of architectures
///</summary>
type TFCEdsuArchitectures=(
   ///<summary>
   ///   for internal use only, do no put this entry in the XML file
   ///</summary>
   aNone
   ///<summary>
   ///   Deep-Space Vehicle
   ///</summary>
   ,aDSV
   ///<summary>
   ///   Heavy-Lift Vehicle
   ///</summary>
   ,aHLV
   ///<summary>
   ///   Lander Vehicle
   ///</summary>
   ,aLV
   ///<summary>
   ///   Lander/Ascent Vehicle
   ///</summary>
   ,aLAV
   ///<summary>
   ///   Orbital Multipurpose Vehicle
   ///</summary>
   ,aOMV
   ///<summary>
   ///   Stabilized Space Infrastructure
   ///</summary>
   ,aSSI
   ///<summary>
   ///   Transatmospheric Vehicle
   ///</summary>
   ,aTAV
   ///<summary>
   ///   Beam Sail Vehicle
   ///</summary>
   ,aBSV
   );

{:REFERENCES LIST
   - scintstrucdb.xml
   - FCMdFiles_DBSpaceCrafts_Read
   -
   -
   -
   -
}
///<summary>
///   types of control module
///</summary>
type TFCEdsuControlModules=(
   cmCockpit
   ,cmBridge
   ,cmUnmanned
   );

{:REFERENCES LIST
   - FCMdFiles_DBSpaceCrafts_Read
   -
   -
   -
   -
}
///<summary>
///   equipment module classes
///</summary>
type TFCEdsuEquipmentModuleClasses=(
   emcCompartment
   ,emcControl
   ,emcHullModification
   ,emcPowerGrid
   ,emcSpaceDrive
   ,emcSubSystem
   ,emcWeaponSystem
   );

{:REFERENCES LIST
   - scintstrucdb.xml
   - FCMdFiles_DBSpaceCrafts_Read
   -
   -
   -
   -
}
///<summary>
///   internal structure shapes
///</summary>
type TFCEdsuInternalStructureShapes=(
   issAssembled
   ,issModular
   ,issSpherical
   ,issCylindrical
   ,issStreamlinedCylindrical
   ,issStreamlinedDelta
   ,issBox
   ,issToroidal
   );

//==END PUBLIC ENUM=========================================================================

{datastructure of spacecraft's internal structures}
{:DEV NOTES: update FCMdFiles_DBSpaceCrafts_Read.}
type TFCRscIntStr = record
   {internal infrastructure db token id}
   SCIS_token: string[20];
   {overall shape of the structure}
   SCIS_shape: TFCEdsuInternalStructureShapes;
   {architecture type}
   SCIS_archTp: TFCEdsuArchitectures;
   {type of control module allowed for the internal structure}
   SCIS_contMdlAllwd: TFCEdsuControlModules;
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
      SCEM_emClass: TFCEdsuEquipmentModuleClasses;
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
