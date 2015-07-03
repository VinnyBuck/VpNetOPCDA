object frmVpNetDAAbout: TfrmVpNetDAAbout
  Left = 469
  Top = 218
  AlphaBlendValue = 100
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #1054' '#1089#1077#1088#1074#1077#1088#1077
  ClientHeight = 48
  ClientWidth = 187
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnKeyUp = FormKeyUp
  OnMouseUp = FormMouseUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 187
    Height = 48
    Align = alClient
    BorderWidth = 1
    TabOrder = 0
    OnDblClick = Panel1DblClick
    OnMouseUp = FormMouseUp
    object lbProductName: TLabel
      Left = 8
      Top = 8
      Width = 164
      Height = 18
      Caption = #1057#1077#1088#1074#1077#1088' VpNet OPC DA'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      OnMouseUp = FormMouseUp
    end
    object lbVersion: TLabel
      Left = 8
      Top = 32
      Width = 63
      Height = 12
      Caption = #1042#1077#1088#1089#1080#1103' 1.0.0.1'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      OnMouseUp = FormMouseUp
    end
  end
  object VerInfo: TRzVersionInfo
    Left = 136
    Top = 16
  end
end
