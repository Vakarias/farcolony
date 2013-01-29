{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: 2d graphics core unit

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
unit farc_gfx_core;

interface

uses
   GR32
   ,GR32_Image;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   centralized graphics initialization caller
///</summary>
procedure FCMgfxC_Main_Init;

///<summary>
///   hide the resources icons
///</summary>
procedure FCMgfxC_PlanetarySurvey_Hide;

///<summary>
///   initialize the planetary survey related assets
///</summary>
procedure FCMgfxC_PlanetarySurvey_Init;

///<summary>
///   switch the display state of the selected region's settlement
///</summary>
///   <param name=""></param>
///   <param name=""></param>
procedure FCMgfxC_Settlement_SwitchDisplay(const Region, RegionMax: integer);

///<summary>
///   hide the settlements icons
///</summary>
procedure FCMgfxC_Settlements_Hide;

///<summary>
///   initialize the settlements icons
///</summary>
procedure FCMgfxC_Settlements_Init;

///<summary>
///   initialize the terrains graphic collection
///</summary>
procedure FCMgfxC_TerrainsCollection_Init;

implementation

uses
   farc_data_init
   ,farc_main
   ,farc_ui_surfpanel;

type TFCgfxCsettlementEvents = class
   {.settlements icons mouse enter event}
   procedure FCMgfxC_Settlement_OnMouseEnter(SOMEsender: TObject);
end;

const
   FCgFXsettlementIconsSize=40;
   FCgFXsettlementPoleIconsSize=30;

var FCgfxCsettlementEvents: TFCgfxCsettlementEvents;


//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure TFCgfxCsettlementEvents.FCMgfxC_Settlement_OnMouseEnter(SOMEsender: TObject);
{:Purpose: settlements icons mouse enter event.
    Additions:
      -2012Jan25- *mod: use a private data instead of FCWinMain.FCWM_SP_Surface.Tag.
}
var
   SOMEcnt
   ,SOMEreg: integer;

   RegionSelected: integer;
begin
   SOMEreg:=0;
   SOMEcnt:=1;
   while SOMEcnt<=30 do
   begin
      if SOMEsender=FCRdiSettlementPictures[SOMEcnt]
      then
      begin
         SOMEreg:=SOMEcnt;
         break;
      end;
      inc(SOMEcnt);
   end;
   RegionSelected:=FCFuiSP_VarRegionHovered_Get;
   if RegionSelected<>SOMEreg
   then FCMuiSP_RegionDataPicture_Update(SOMEreg, false);
end;

procedure FCMgfxC_Main_Init;
{:Purpose: centralized graphics initialization caller.
    Additions:
}
begin
   FCMgfxC_TerrainsCollection_Init;
   if not Assigned(FCRdiSettlementPictures[1])
   then FCMgfxC_Settlements_Init;
   FCMgfxC_PlanetarySurvey_Init;
end;

procedure FCMgfxC_PlanetarySurvey_Hide;
{:Purpose: hide the resources icons.
    Additions:
}
begin
   FCWinMain.SP_FRR_IconResourcesSurvey.Hide;
   FCWinMain.SP_FRR_IconCantSurvey.Hide;
   FCWinMain.SP_FRR_IconRsrcOreField.Hide;
   FCWinMain.SP_FRR_IconRsrcIcyOreField.Hide;
   FCWinMain.SP_FRR_IconRsrcGasField.Hide;
   FCWinMain.SP_FRR_IconRsrcHydroLocation.Hide;
   FCWinMain.SP_FRR_IconRsrcUndergroundWater.Hide;
end;

procedure FCMgfxC_PlanetarySurvey_Init;
{:Purpose: initialize the planetary survey related assets.
    Additions:
      -2013Jan27- *add: FRR_IconRsrcOreField + FRR_IconRsrcIcyOreField + FRR_IconRsrcGasField + FRR_IconRsrcHydroLocation + FRR_IconRsrcUndergroundWater.
      -2013Jan26- *add: FRR_IconCantSurvey.
}
begin
   FCWinMain.SP_FRR_IconResourcesSurvey.Bitmap.LoadFromFile(FCVdiPathResourceDir+'pics-ui-resources\resourceSurvey.jpg');
   FCWinMain.SP_FRR_IconCantSurvey.Bitmap.LoadFromFile(FCVdiPathResourceDir+'pics-ui-resources\cantSurvey.jpg');
   FCWinMain.SP_FRR_IconRsrcOreField.Bitmap.LoadFromFile(FCVdiPathResourceDir+'pics-ui-resources\orefield32.jpg');
   FCWinMain.SP_FRR_IconRsrcOreField.Left:=4;
   FCWinMain.SP_FRR_IconRsrcOreField.Top:=2;
   FCWinMain.SP_FRR_IconRsrcIcyOreField.Bitmap.LoadFromFile(FCVdiPathResourceDir+'pics-ui-resources\icyorefield32.jpg');
   FCWinMain.SP_FRR_IconRsrcIcyOreField.Left:=FCWinMain.SP_FRR_IconRsrcOreField.Left+(FCWinMain.SP_FRR_IconRsrcOreField.Width*2)+6;
   FCWinMain.SP_FRR_IconRsrcIcyOreField.Top:=FCWinMain.SP_FRR_IconRsrcOreField.Top;
   FCWinMain.SP_FRR_IconRsrcGasField.Bitmap.LoadFromFile(FCVdiPathResourceDir+'pics-ui-resources\gasfield32.jpg');
   FCWinMain.SP_FRR_IconRsrcGasField.Left:=FCWinMain.SP_FRR_IconRsrcOreField.Left+FCWinMain.SP_FRR_IconRsrcOreField.Width+3;
   FCWinMain.SP_FRR_IconRsrcGasField.Top:=FCWinMain.SP_FRR_IconRsrcOreField.Top+FCWinMain.SP_FRR_IconRsrcOreField.Height;
   FCWinMain.SP_FRR_IconRsrcHydroLocation.Bitmap.LoadFromFile(FCVdiPathResourceDir+'pics-ui-resources\hydrolocation32.jpg');
   FCWinMain.SP_FRR_IconRsrcHydroLocation.Left:=FCWinMain.SP_FRR_IconRsrcOreField.Left;
   FCWinMain.SP_FRR_IconRsrcHydroLocation.Top:=FCWinMain.SP_FRR_IconRsrcOreField.Top+(FCWinMain.SP_FRR_IconRsrcOreField.Height*2);
   FCWinMain.SP_FRR_IconRsrcUndergroundWater.Bitmap.LoadFromFile(FCVdiPathResourceDir+'pics-ui-resources\undergroundwater32.jpg');
   FCWinMain.SP_FRR_IconRsrcUndergroundWater.Left:=FCWinMain.SP_FRR_IconRsrcIcyOreField.Left;
   FCWinMain.SP_FRR_IconRsrcUndergroundWater.Top:=FCWinMain.SP_FRR_IconRsrcHydroLocation.Top;
end;

procedure FCMgfxC_Settlement_SwitchDisplay(const Region, RegionMax: integer);
{:Purpose: switch the display state of the selected region's settlement.
    Additions:
      -2013Jan07- *code: small refactoring.
                  *add: set the correct picture and size for settlement at north or south pole.
                  *add: new parameter to indicate the maximum # of regions.
}
var
   SSShot: integer;

   BitmapSettlement: TBitmap32;
begin
   SSShot:=0;
   if FCRdiSettlementPictures[Region].Visible
   then FCRdiSettlementPictures[Region].Hide
   else
   begin
      SSShot:=Region-1;
      if ( ( Region=1 ) or ( Region=RegionMax) )
         and ( FCRdiSettlementPictures[Region].Height=FCgFXsettlementIconsSize ) then
      begin
         BitmapSettlement:=TBitmap32.Create;
         BitmapSettlement.LoadFromFile(FCVdiPathResourceDir+'pics-ui-colony\colonysurfpoleicn.png');
         FCRdiSettlementPictures[Region].Bitmap:=BitmapSettlement;
         FCRdiSettlementPictures[Region].Height:=FCgFXsettlementPoleIconsSize;
         FCRdiSettlementPictures[Region].Width:=FCgFXsettlementPoleIconsSize;
         BitmapSettlement.Free;
      end
      else if FCRdiSettlementPictures[Region].Height=FCgFXsettlementPoleIconsSize then
      begin
         BitmapSettlement:=TBitmap32.Create;
         BitmapSettlement.LoadFromFile(FCVdiPathResourceDir+'pics-ui-colony\colonysurficn.png');
         FCRdiSettlementPictures[Region].Bitmap:=BitmapSettlement;
         FCRdiSettlementPictures[Region].Height:=FCgFXsettlementIconsSize;
         FCRdiSettlementPictures[Region].Width:=FCgFXsettlementIconsSize;
         BitmapSettlement.Free;
      end;
      FCRdiSettlementPictures[Region].Left:=FCWinMain.SP_SurfaceDisplay.HotSpots[SSShot].X+(FCWinMain.SP_SurfaceDisplay.HotSpots[SSShot].Width shr 1)-(FCRdiSettlementPictures[Region].Width shr 1);
      FCRdiSettlementPictures[Region].Top:=FCWinMain.SP_SurfaceDisplay.HotSpots[SSShot].Y+(FCWinMain.SP_SurfaceDisplay.HotSpots[SSShot].Height shr 1)-(FCRdiSettlementPictures[Region].Height shr 1);
      FCRdiSettlementPictures[Region].Show;
   end;
end;

procedure FCMgfxC_Settlements_Hide;
{:Purpose: hide the settlements icons.
    Additions:
}
var
   SHcnt: integer;
begin
   SHcnt:=1;
   while SHcnt<=30 do
   begin
      FCRdiSettlementPictures[SHcnt].Visible:=false;
      inc(SHcnt);
   end;
end;

procedure FCMgfxC_Settlements_Init;
{:Purpose: initialize the settlements icons.
    Additions:
      -2011Feb15- *add: ad OnMousEnter event initialization.
}
var
   SIcnt: integer;

   SIbmp: TBitmap32;
begin
   SIcnt:=1;
   SIbmp:=TBitmap32.Create;
   SIbmp.LoadFromFile(FCVdiPathResourceDir+'pics-ui-colony\colonysurficn.png');
   while SIcnt<=30 do
   begin
      FCRdiSettlementPictures[SIcnt]:=TImage32.Create(FCWinMain.SP_SurfaceDisplay);
      FCRdiSettlementPictures[SIcnt].Parent:=FCWinMain.SP_SurfaceDisplay;
      FCRdiSettlementPictures[SIcnt].Bitmap:=SIbmp;
      FCRdiSettlementPictures[SIcnt].BitmapAlign:=baTopLeft;
      FCRdiSettlementPictures[SIcnt].Height:=FCgFXsettlementIconsSize;
      FCRdiSettlementPictures[SIcnt].Left:=25+(SIcnt*FCgFXsettlementIconsSize);
      FCRdiSettlementPictures[SIcnt].Scale:=1;
      FCRdiSettlementPictures[SIcnt].ScaleMode:=smNormal;
      FCRdiSettlementPictures[SIcnt].Top:=60;
      FCRdiSettlementPictures[SIcnt].Visible:=false;
      FCRdiSettlementPictures[SIcnt].Width:=FCgFXsettlementIconsSize;
      FCRdiSettlementPictures[SIcnt].OnMouseEnter:=FCgfxCsettlementEvents.FCMgfxC_Settlement_OnMouseEnter;
      inc(SIcnt);
   end;
   SIbmp.Free;
end;

procedure FCMgfxC_TerrainsCollection_Init;
{:Purpose: initialize the terrains graphic collection.
    Additions:
      -2012Jan06- *code: procedure moved in its proper unit.
}
var
   TGCIcnt
   ,TGCIdmp: integer;
   TGCIfile: string;
begin
   if FCWinMain.FCWM_RegTerrLib.Bitmaps.Count>0
   then FCWinMain.FCWM_RegTerrLib.Bitmaps.Clear;
   TGCIcnt:=0;
   while TGCIcnt<=41 do
   begin
      TGCIdmp:=TGCIcnt;
      FCWinMain.FCWM_RegTerrLib.Bitmaps.Add;
      case TGCIcnt of
         0: TGCIfile:='rst01rockDes_plain.jpg';
         1: TGCIfile:='rst01rockDes_brok.jpg';
         2: TGCIfile:='rst01rockDes_moun.jpg';
         3: TGCIfile:='rst02sandDes_plain.jpg';
         4: TGCIfile:='rst02sandDes_brok.jpg';
         5: TGCIfile:='rst03volcanic_plain.jpg';
         6: TGCIfile:='rst03volcanic_brok.jpg';
         7: TGCIfile:='rst03volcanic_moun.jpg';
         8: TGCIfile:='rst04polar_plain.jpg';
         9: TGCIfile:='rst04polar_brok.jpg';
         10: TGCIfile:='rst04polar_moun.jpg';
         11: TGCIfile:='rst05arid_plain.jpg';
         12: TGCIfile:='rst05arid_brok.jpg';
         13: TGCIfile:='rst05arid_moun.jpg';
         14: TGCIfile:='rst06fertile_plain.jpg';
         15: TGCIfile:='rst06fertile_brok.jpg';
         16: TGCIfile:='rst06fertile_moun.jpg';
         17: TGCIfile:='rst07oceanic.jpg';
         18: TGCIfile:='rst08coastRockDes_plain.jpg';
         19: TGCIfile:='rst08coastRockDes_brok.jpg';
         20: TGCIfile:='rst08coastRockDes_moun.jpg';
         21: TGCIfile:='rst09coastSandDes_plain.jpg';
         22: TGCIfile:='rst09coastSandDes_brok.jpg';
         23: TGCIfile:='rst10coastVolcanic_plain.jpg';
         24: TGCIfile:='rst10coastVolcanic_brok.jpg';
         25: TGCIfile:='rst10coastVolcanic_moun.jpg';
         26: TGCIfile:='rst11coastPolar_plain.jpg';
         27: TGCIfile:='rst11coastPolar_brok.jpg';
         28: TGCIfile:='rst11coastPolar_moun.jpg';
         29: TGCIfile:='rst12coastArid_plain.jpg';
         30: TGCIfile:='rst12coastArid_brok.jpg';
         31: TGCIfile:='rst12coastArid_moun.jpg';
         32: TGCIfile:='rst13coastFertile_plain.jpg';
         33: TGCIfile:='rst13coastFertile_brok.jpg';
         34: TGCIfile:='rst13coastFertile_moun.jpg';
         35: TGCIfile:='rst14barren_plain.jpg';
         36: TGCIfile:='rst14barren_brok.jpg';
         37: TGCIfile:='rst14barren_moun.jpg';
         38: TGCIfile:='rst15icyBarren_plain.jpg';
         39: TGCIfile:='rst15icyBarren_brok.jpg';
         40: TGCIfile:='rst15icyBarren_moun.jpg';
      end; //==END== case TGCIcnt ==//
      FCWinMain.FCWM_RegTerrLib.Bitmap[TGCIdmp].LoadFromFile(FCVdiPathResourceDir+'pics-ui-terrain\'+TGCIfile);
      inc(TGCIcnt);
   end; //==END== while TGCIcnt<=41 ==//
end;

end.
