{=====(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved================

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FARC Universe Generator (FUG) window

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

unit farc_win_fug;

interface

uses
   Controls
   ,Forms
   ,Messages
   ,SysUtils
   ,Windows, StdCtrls, Classes, AdvMemo, AdvPageControl, ComCtrls, ExtCtrls,

   AdvGlowButton
   ,AdvGroupBox, AdvCombo, htmlbtns;

type
   TFCWinFUG = class(TForm)
    FCWFoutput: TAdvMemo;
    Label1: TLabel;
    AdvPageControl1: TAdvPageControl;
    AdvTabSheet1: TAdvTabSheet;
    Label2: TLabel;
    AdvGroupBox1: TAdvGroupBox;
    FCWFssysToken: TLabeledEdit;
    FCWFlocX: TLabeledEdit;
    FCWFlocY: TLabeledEdit;
    FCWFlocZ: TLabeledEdit;
    FCWFgenerate: TAdvGlowButton;
    AdvGroupBox2: TAdvGroupBox;
    FUGmStartoken: TLabeledEdit;
    FUGmStarDiam: TLabeledEdit;
    FUGmStarMass: TLabeledEdit;
    FUGmStarLum: TLabeledEdit;
    FUGmStarClass: TAdvComboBox;
    Label3: TLabel;
    FUGmSType: TAdvComboBox;
    Label4: TLabel;
    FUGmStarOG: THTMLRadioGroup;
    FUGmStarNumOrb: TLabeledEdit;
    FUGmStarTemp: TLabeledEdit;
    FUGcs1Check: TCheckBox;
    AdvGroupBox3: TAdvGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    FUGcs1token: TLabeledEdit;
    FUGcs1Diam: TLabeledEdit;
    FUGcs1Mass: TLabeledEdit;
    FUGcs1Lum: TLabeledEdit;
    FUGcs1Class: TAdvComboBox;
    FUGcs1Type: TAdvComboBox;
    FUGcs1OG: THTMLRadioGroup;
    FUGcs1NumOrb: TLabeledEdit;
    FUGcs1Temp: TLabeledEdit;
    FUGcs2Check: TCheckBox;
    AdvGroupBox4: TAdvGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    FUGcs2token: TLabeledEdit;
    FUGcs2Diam: TLabeledEdit;
    FUGcs2Mass: TLabeledEdit;
    FUGcs2Lum: TLabeledEdit;
    FUGcs2Class: TAdvComboBox;
    FUGcs2Type: TAdvComboBox;
    FUGcs2OG: THTMLRadioGroup;
    FUGcs2NumOrb: TLabeledEdit;
    FUGcs2Temp: TLabeledEdit;
    procedure FCWFgenerateClick(Sender: TObject);
    procedure FUGmStarOGClick(Sender: TObject);
    procedure FUGcs1CheckClick(Sender: TObject);
    procedure FUGcs2CheckClick(Sender: TObject);
    procedure FUGmSTypeChange(Sender: TObject);
    procedure FUGcs1TypeChange(Sender: TObject);
    procedure FUGcs2TypeChange(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
   end;

var
   FCWinFUG: TFCWinFUG;

implementation

uses
   farc_common_func//to remove when FCFcFunc_Star_GetClass is moved
   ,farc_data_univ
   ,farc_fug_data
   ,farc_fug_orbits
   ,farc_fug_stars;

//=======================================END OF INIT========================================

{$R *.dfm}

procedure TFCWinFUG.FCWFgenerateClick(Sender: TObject);
var
   GCcnt: integer;

   GCclassStr
   ,GCorbStr: string;
begin
   if (FCWFssysToken.Text<>'stelsys')
      and (FCWFlocX.Text<>'')
      and (FCWFlocY.Text<>'')
      and (FCWFlocZ.Text<>'')
      and (FUGmStartoken.Text<>'')
   then
   begin
      {.FUG start process}
      FCDduStarSystem:=nil;
      SetLength(FCDduStarSystem, 1);
      FCDduStarSystem[0].SS_token:=FCWFssysToken.Text;
      FCDduStarSystem[0].SS_locationX:=StrToFloat(FCWFlocX.Text);
      FCDduStarSystem[0].SS_locationY:=StrToFloat(FCWFlocY.Text);
      FCDduStarSystem[0].SS_locationZ:=StrToFloat(FCWFlocZ.Text);
      FCRfdStarOrbits[1]:=-1;
      FCRfdStarOrbits[2]:=-1;
      FCRfdStarOrbits[3]:=-1;
      FCRfdSystemType[1]:=0;
      FCRfdSystemType[2]:=0;
      FCRfdSystemType[3]:=0;
      {.stars}
      FCMfS_Data_Load(1);
      FCDduStarSystem[0].SS_stars[1].S_token:=FUGmStartoken.Text;
      FCDduStarSystem[0].SS_stars[1].S_class:=TFCEduStarClasses(FUGmStarClass.ItemIndex);
      if FUGmStarTemp.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_temperature:=FCFfS_Temperature_Calc(1)
      else if FUGmStarTemp.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_temperature:=StrToInt(FUGmStarTemp.Text);
      if FUGmStarMass.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_mass:=FCFfS_Mass_Calc(1)
      else if FUGmStarMass.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_mass:=StrToInt(FUGmStarMass.Text);
      if FUGmStarDiam.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_diameter:=FCFfS_Diameter_Calc(1)
      else if FUGmStarDiam.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_diameter:=StrToFloat(FUGmStarDiam.Text);
      if FUGmStarLum.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_luminosity:=FCFfS_Luminosity_Calc(1)
      else if FUGmStarLum.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_luminosity:=StrToFloat(FUGmStarLum.Text);
      FCRfdSystemType[1]:=FUGmSType.ItemIndex+1;
      FCRfdStarOrbits[1]:=FUGmStarOG.ItemIndex-1;
      if FCRfdStarOrbits[1]=1
      then FCRfdStarOrbits[1]:=StrToInt(FUGmStarNumOrb.Text);
      if (AdvGroupBox3.Visible)
         and (FUGcs1token.Text<>'star')
      then
      begin
         FCDduStarSystem[0].SS_stars[2].S_token:=FUGcs1token.Text;
         FCDduStarSystem[0].SS_stars[2].S_class:=TFCEduStarClasses(FUGcs1Class.ItemIndex);
         if FUGcs1Temp.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_temperature:=FCFfS_Temperature_Calc(2)
         else if FUGcs1Temp.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_temperature:=StrToInt(FUGcs1Temp.Text);
         if FUGcs1Mass.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_mass:=FCFfS_Mass_Calc(2)
         else if FUGcs1Mass.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_mass:=StrToInt(FUGcs1Mass.Text);
         if FUGcs1Diam.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_diameter:=FCFfS_Diameter_Calc(2)
         else if FUGcs1Diam.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_diameter:=StrToFloat(FUGcs1Diam.Text);
         if FUGcs1Lum.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_luminosity:=FCFfS_Luminosity_Calc(2)
         else if FUGcs1Lum.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_luminosity:=StrToFloat(FUGcs1Lum.Text);
         FCMfS_CompStar_Calc(2);
         FCRfdSystemType[2]:=FUGcs1Type.ItemIndex+1;
         FCRfdStarOrbits[2]:=FUGcs1OG.ItemIndex-1;
         if FCRfdStarOrbits[2]=1
         then FCRfdStarOrbits[2]:=StrToInt(FUGcs1NumOrb.Text);
         if (AdvGroupBox4.Visible)
            and (FUGcs2token.Text<>'star')
         then
         begin
            FCDduStarSystem[0].SS_stars[3].S_token:=FUGcs2token.Text;
            FCDduStarSystem[0].SS_stars[3].S_class:=TFCEduStarClasses(FUGcs2Class.ItemIndex);
            if FUGcs2Temp.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_temperature:=FCFfS_Temperature_Calc(3)
            else if FUGcs2Temp.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_temperature:=StrToInt(FUGcs2Temp.Text);
            if FUGcs2Mass.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_mass:=FCFfS_Mass_Calc(3)
            else if FUGcs2Mass.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_mass:=StrToInt(FUGcs2Mass.Text);
            if FUGcs2Diam.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_diameter:=FCFfS_Diameter_Calc(3)
            else if FUGcs2Diam.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_diameter:=StrToFloat(FUGcs2Diam.Text);
            if FUGcs2Lum.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_luminosity:=FCFfS_Luminosity_Calc(3)
            else if FUGcs2Lum.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_luminosity:=StrToFloat(FUGcs2Lum.Text);
            FCMfS_CompStar_Calc(3);
            FCRfdSystemType[3]:=FUGcs2Type.ItemIndex+1;
            FCRfdStarOrbits[3]:=FUGcs1OG.ItemIndex-1;
            if FCRfdStarOrbits[3]=1
            then FCRfdStarOrbits[3]:=StrToInt(FUGcs1NumOrb.Text);

         end;
      end;
      if FCRfdSystemType[1]>-1
      then FCMfO_Generate(1);
      if (FCDduStarSystem[0].SS_stars[2].S_token<>'')
         and (FCRfdSystemType[2]>-1)
      then FCMfO_Generate(2);
      if (FCDduStarSystem[0].SS_stars[3].S_token<>'')
         and (FCRfdSystemType[3]>-1)
      then FCMfO_Generate(3);
      {.generate ouput}
      FCWFoutput.Lines.Clear;
      FCWFoutput.Lines.Add('===============================================');
      FCWFoutput.Lines.Add('===============================================');
      {.for stellar system}
      FCWFoutput.Lines.Add('<!-- -->');
      FCWFoutput.Lines.Add(
         '<starsys sstoken="'+FCDduStarSystem[0].SS_token+'" steslocx="'
         +FCWFlocX.Text+'" steslocy="'+FCWFlocY.Text+'" steslocz="'+FCWFlocZ.Text+'">'
         );
      {.for stars}
      GCcnt:=1;
      while GCcnt<=3 do
      begin
         if FCDduStarSystem[0].SS_stars[GCcnt].S_token=''
         then break
         else
         begin
            GCclassStr:=FCFcFunc_Star_GetClass(ufcfRaw, 0, GCcnt);
            FCWFoutput.Lines.Add('   <star startoken="'+FCDduStarSystem[0].SS_stars[GCcnt].S_token+'" starclass="'+GCclassStr+'">');
            FCWFoutput.Lines.Add(
               '      <starphysdata startemp="'+IntToStr(FCDduStarSystem[0].SS_stars[GCcnt].S_temperature)
               +'" starmass="'+FloatToStr(FCDduStarSystem[0].SS_stars[GCcnt].S_mass)
               +'" stardiam="'+FloatToStr(FCDduStarSystem[0].SS_stars[GCcnt].S_diameter)
               +'" starlum="'+FloatToStrF(FCDduStarSystem[0].SS_stars[GCcnt].S_luminosity, ffFixed, 15, 5)+'"'
               +'/>'
               );
            if GCcnt=2
            then
            begin
               FCWFoutput.Lines.Add(
                  '      <starcompdata compmsep="'+FloatToStr(FCDduStarSystem[0].SS_stars[GCcnt].S_isCompMeanSeparation)
                  +'" compminapd="'+FloatToStr(FCDduStarSystem[0].SS_stars[GCcnt].S_isCompMinApproachDistance)
                  +'" compecc="'+FloatToStr(FCDduStarSystem[0].SS_stars[GCcnt].S_isCompEccentricity)
                  +'"/>'
                  );
            end
            else if GCcnt=3
            then
            begin
               case FCDduStarSystem[0].SS_stars[GCcnt].S_isCompStar2OrbitType of
                  cotAroundMain_Companion1: GCorbStr:='coAroundCenter';
                  cotAroundCompanion1: GCorbStr:='coAroundComp';
                  cotAroundMain_Companion1GravityCenter: GCorbStr:='coAroundGravC';
               end;
               FCWFoutput.Lines.Add(
                  '      <starcompdata compmsep="'+FloatToStr(FCDduStarSystem[0].SS_stars[GCcnt].S_isCompMeanSeparation)
                  +'" compminapd="'+FloatToStr(FCDduStarSystem[0].SS_stars[GCcnt].S_isCompMinApproachDistance)
                  +'" compecc="'+FloatToStr(FCDduStarSystem[0].SS_stars[GCcnt].S_isCompEccentricity)
                  +'" comporb="'+GCorbStr+'"'
                  +'/>'
                  );
            end;
            FCWFoutput.Lines.Add('   </star>');
         end;
         inc(GCcnt);
      end;
      {.end root}
      FCWFoutput.Lines.Add('</starsys>');
   end
   else
   begin
      FCWFoutput.Lines.Add('===============================================');
      FCWFoutput.Lines.Add('!ERROR: DATA INIT!');
      FCWFoutput.Lines.Add('===============================================');
   end;
end;

procedure TFCWinFUG.FUGcs1CheckClick(Sender: TObject);
begin
   if FUGcs1Check.Checked
   then
   begin
      AdvGroupBox3.Visible:=true;
      FUGcs2Check.Enabled:=true;
   end
   else if not FUGcs1Check.Checked
   then
   begin
      AdvGroupBox3.Visible:=false;
      FUGcs2Check.Checked:=false;
      FUGcs2Check.Enabled:=false;
      AdvGroupBox4.Visible:=false;
   end;
end;

procedure TFCWinFUG.FUGcs1TypeChange(Sender: TObject);
begin
   if FUGcs1Type.ItemIndex=3
   then FUGcs1OG.ItemIndex:=0;
end;

procedure TFCWinFUG.FUGcs2CheckClick(Sender: TObject);
begin
   if FUGcs2Check.Checked
   then AdvGroupBox4.Visible:=true
   else if not FUGcs2Check.Checked
   then AdvGroupBox4.Visible:=false;
end;

procedure TFCWinFUG.FUGcs2TypeChange(Sender: TObject);
begin
   if FUGcs2Type.ItemIndex=3
   then FUGcs2OG.ItemIndex:=0;
end;

procedure TFCWinFUG.FUGmStarOGClick(Sender: TObject);
begin
   if FUGmStarOG.ItemIndex<2
   then FUGmStarNumOrb.Enabled:=false
   else FUGmStarNumOrb.Enabled:=true;
end;

procedure TFCWinFUG.FUGmSTypeChange(Sender: TObject);
begin
   if FUGmSType.ItemIndex=3
   then FUGmStarOG.ItemIndex:=0;
end;

end.