object FCWinAbout: TFCWinAbout
  Left = 0
  Top = 0
  AlphaBlend = True
  AlphaBlendValue = 180
  BorderStyle = bsNone
  Caption = 'FCWinAbout'
  ClientHeight = 320
  ClientWidth = 434
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
  TextHeight = 14
  object FCWA_Frame: TAdvGroupBox
    Left = 0
    Top = 0
    Width = 434
    Height = 320
    Align = alClient
    Caption = 'FCWA_Frame'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -12
    Font.Name = 'DejaVu Sans Condensed'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object FCWA_Frm_Header: THTMLabel
      Left = 2
      Top = 17
      Width = 430
      Height = 17
      Align = alTop
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 14803425
      Font.Height = -12
      Font.Name = 'FrancophilSans'
      Font.Style = []
      Hover = True
      HoverColor = clBlack
      HoverFontColor = clSkyBlue
      ParentColor = False
      ParentFont = False
      URLColor = 14068651
      Version = '1.8.1.0'
      ExplicitLeft = 112
      ExplicitTop = 48
      ExplicitWidth = 120
    end
    object FCWA_Frm_Creds: THTMLCredit
      Left = 2
      Top = 205
      Width = 430
      Height = 113
      Align = alBottom
      AutoScroll = True
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 14803425
      Font.Height = -12
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
