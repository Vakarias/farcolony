object FCWinAbout: TFCWinAbout
  Left = 0
  Top = 0
  AlphaBlend = True
  AlphaBlendValue = 180
  BorderStyle = bsNone
  Caption = 'FCWinAbout'
  ClientHeight = 343
  ClientWidth = 465
  Color = clBlack
  Ctl3D = False
  DefaultMonitor = dmMainForm
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -12
  Font.Name = 'FrancophilSans'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object FCWA_Frame: TAdvGroupBox
    Left = 0
    Top = 0
    Width = 465
    Height = 343
    Align = alClient
    Caption = 'FCWA_Frame'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = 'DejaVu Sans Condensed'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object FCWA_Frm_Header: THTMLabel
      Left = 2
      Top = 18
      Width = 461
      Height = 18
      Align = alTop
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 14803425
      Font.Height = -13
      Font.Name = 'FrancophilSans'
      Font.Style = []
      Hover = True
      HoverColor = clBlack
      HoverFontColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      URLColor = 14068651
      Version = '1.8.1.0'
    end
    object FCWA_Frm_Creds: THTMLCredit
      Left = 2
      Top = 220
      Width = 461
      Height = 121
      Align = alBottom
      AutoScroll = True
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 14803425
      Font.Height = -13
      Font.Name = 'FrancophilSans'
      Font.Style = []
      HoverColor = clBlack
      HoverFontColor = clSkyBlue
      Loop = True
      ParentColor = False
      ParentFont = False
      TabOrder = 0
      URLColor = 14068651
      OnMouseLeave = FCWA_Frm_CredsMouseLeave
      OnMouseEnter = FCWA_Frm_CredsMouseEnter
      Version = '1.1.1.0'
    end
  end
end