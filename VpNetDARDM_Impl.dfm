object VpNetDARDM: TVpNetDARDM
  OldCreateOrder = False
  Left = 309
  Top = 173
  Height = 150
  Width = 215
  object db: TIBDatabase
    DatabaseName = 'E:\VpNet\VpNetDA\database\VpNetDA.gdb'
    Params.Strings = (
      'user_name=sysdba'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    SQLDialect = 1
    Left = 16
    Top = 8
  end
  object tr: TIBTransaction
    DefaultDatabase = db
    Params.Strings = (
      'read_committed'
      'rec_version'
      'wait')
    Left = 56
    Top = 8
  end
end
