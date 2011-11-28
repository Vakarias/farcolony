{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: 2d graphics core unit

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
unit farc_gfx_core;

interface

uses
   GR32
   ,GR32_Image;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgfxC_Settlement_SwitchState(const SSSregion: integer);

///<summary>
///   hide the settlements icons
///</summary>
procedure FCMgfxC_Settlements_Hide;

///<summary>
///   initialize the settlements icons
///</summary>
procedure FCMgfxC_Settlements_Init;

implementation

uses
   farc_data_init
   ,farc_main
   ,farc_ui_win;

type TFCgfxCsettlementEvents = class
   {.settlements icons mouse enter event}
   procedure FCMgfxC_Settlement_OnMouseEnter(SOMEsender: TObject);
end;

var FCgfxCsettlementEvents: TFCgfxCsettlementEvents;


//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure TFCgfxCsettlementEvents.FCMgfxC_Settlement_OnMouseEnter(SOMEsender: TObject);
{:Purpose: settlements icons mouse enter event.
    Additions:
}
var
   SOMEcnt
   ,SOMEreg: integer;
begin
   SOMEreg:=0;
   SOMEcnt:=1;
   while SOMEcnt<=30 do
   begin
      if SOMEsender=FCRdiSettlementPic[SOMEcnt]
      then
      begin
         SOMEreg:=SOMEcnt;
         break;
      end;
      inc(SOMEcnt);
   end;
   if (FCWinMain.FCWM_SP_Surface.Tag<>SOMEreg)
      and (FCWinMain.FCWM_SP_DataSheet.ActivePage=FCWinMain.FCWM_SP_ShReg)
   then FCMuiWin_SurfEcos_RegUpd(SOMEreg, false)
   else if (FCWinMain.FCWM_SP_Surface.Tag<>SOMEreg)
      and (FCWinMain.FCWM_SP_DataSheet.ActivePage<>FCWinMain.FCWM_SP_ShReg)
   then FCMuiWin_SurfEcos_RegUpd(SOMEreg, true);
end;

procedure FCMgfxC_Settlement_SwitchState(const SSSregion: integer);
{:Purpose: switch the display state of the selected region's settlement.
    Additions:
}
var
   SSShot: integer;
begin
   SSShot:=0;
   if FCRdiSettlementPic[SSSregion].Visible
   then FCRdiSettlementPic[SSSregion].Hide
   else
   begin
      SSShot:=SSSregion-1;
      FCRdiSettlementPic[SSSregion].Left:=
         FCWinMain.FCWM_SP_Surface.HotSpots[SSShot].X+(FCWinMain.FCWM_SP_Surface.HotSpots[SSShot].Width shr 1)-(FCRdiSettlementPic[SSSregion].Width shr 1);
      FCRdiSettlementPic[SSSregion].Top:=FCWinMain.FCWM_SP_Surface.HotSpots[SSShot].Y+4;
      FCRdiSettlementPic[SSSregion].Show;
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
      FCRdiSettlementPic[SHcnt].Visible:=false;
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
   SIbmp.LoadFromFile(FCVpathRsrc+'pics-ui-colony\colonysurficn.png');
   while SIcnt<=30 do
   begin
      FCRdiSettlementPic[SIcnt]:=TImage32.Create(FCWinMain.FCWM_SP_Surface);
      FCRdiSettlementPic[SIcnt].Parent:=FCWinMain.FCWM_SP_Surface;
      FCRdiSettlementPic[SIcnt].Bitmap:=SIbmp;
      FCRdiSettlementPic[SIcnt].BitmapAlign:=baTopLeft;
      FCRdiSettlementPic[SIcnt].Height:=40;
      FCRdiSettlementPic[SIcnt].Left:=25+(SIcnt*40);
      FCRdiSettlementPic[SIcnt].Scale:=1;
      FCRdiSettlementPic[SIcnt].ScaleMode:=smNormal;
      FCRdiSettlementPic[SIcnt].Top:=60;
      FCRdiSettlementPic[SIcnt].Visible:=false;
      FCRdiSettlementPic[SIcnt].Width:=40;
      FCRdiSettlementPic[SIcnt].OnMouseEnter:=FCgfxCsettlementEvents.FCMgfxC_Settlement_OnMouseEnter;
      inc(SIcnt);
   end;
   SIbmp.Free;
end;

end.
