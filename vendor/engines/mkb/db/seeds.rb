#CoreBanking::Operation.delete_all
#CoreBanking::Incassation.delete_all

TerminalProfile.create!(:keyword => 'DPS', :title => 'DPS Terminal', :support_phone => '111111111')
ProviderGroup.create!(:title => 'DPS')
ProviderProfile.create!(:title => 'DPS')

Gateway.create! [
  {:title => 'Cyberplat', :keyword => 'cyberplat', :payzilla => 'cyberplat'},
  {:title => 'OSMP', :keyword => 'osmp', :payzilla => 'osmp'},
  {:title => 'Eport', :keyword => 'eport', :payzilla => 'dummy'},
  {:title => 'Bashinform', :keyword => 'bashinform', :payzilla => 'dummy'},
  {:title => 'Anthill', :keyword => 'anthill', :payzilla => 'dummy'},
  {:title => 'PSKB', :keyword => 'pskb', :payzilla => 'dummy'},
  {:title => 'Skylink SPb', :keyword => 'skylink_spb', :payzilla => 'skylink'},
  {:title => 'Tiera', :keyword => 'tiera', :payzilla => 'dummy'},
  {:title => 'Westcall', :keyword => 'westcall', :payzilla => 'dummy'},
  {:title => 'AstraOreol', :keyword => 'asstraoreol', :payzilla => 'dummy'},
  {:title => 'Noth-West Net', :keyword => 'nw_net', :payzilla => 'dummy'},
  {:title => 'Nevalink', :keyword => 'nevalink', :payzilla => 'dummy'},
  {:title => 'YourNet', :keyword => 'yournet', :payzilla => 'dummy'},
  {:title => 'Peterstar', :keyword => 'peterstar', :payzilla => 'dummy'},
  {:title => 'HandyBank', :keyword => 'handy', :payzilla => 'dummy'},  
  {:title => 'MTS', :keyword => 'mts', :payzilla => 'mts'},
  {:title => 'Qiwi wallet', :keyword => 'qiwi_wallet', :payzilla => 'osmp'},
  {:title => 'UNIStream', :keyword => 'unistream', :payzilla => 'dummy'},
  {:title => 'MGTS through MTS', :keyword => 'mgts_mts', :payzilla => 'mts'},
  {:title => 'Megafon', :keyword => 'megafon', :payzilla => 'megafon'},
  {:title => 'Prosto dlya obscheniya', :keyword => 'prosto', :payzilla => 'dummy'},
  {:title => 'Sim4Fly', :keyword => 'sim4fly', :payzilla => 'dummy'},
  {:title => 'GIBDD SBP', :keyword => 'gibdd_spb', :payzilla => 'dummy'},
  {:title => 'Rapida', :keyword => 'rapida', :payzilla => 'rapida'},
  {:title => 'Rapida2', :keyword => 'rapida2', :payzilla => 'rapida'},
  {:title => 'Credit Pilot', :keyword => 'credit_pilot', :payzilla => 'dummy'},
  {:title => 'Beeline', :keyword => 'beeline', :payzilla => 'beeline'},
  {:title => 'Yota', :keyword => 'yota', :payzilla => 'yota'},
  {:title => 'MKB Credit Service', :keyword => 'mkb_credits', :payzilla => 'dummy'},
  {:title => 'MKB ZHKX Service', :keyword => 'mkb_housing', :payzilla => 'dummy'},
  {:title => 'Yandex.Money', :keyword => 'yamoney', :payzilla => 'yamoney'},
  {:title => 'Skylink', :keyword => 'skylink', :payzilla => 'skylink'},
  {:title => 'MGTS', :keyword => 'mgts', :payzilla => 'dummy'},
  {:title => 'Mail.ru', :keyword => 'mailru', :payzilla => 'mailru'},
  {:title => 'MKB BTI', :keyword => 'mkb_bti', :payzilla => 'dummy'},
  {:title => 'Cyberplat Money Transfers', :keyword => 'cyberplat_transfers', :payzilla => 'cyberplat'},
  {:title => 'Webmoney', :keyword => 'webmoney', :payzilla => 'webmoney'},
  {:title => 'AKADO', :keyword => 'akado', :payzilla => 'akado'},
  {:title => 'Manual Payments', :keyword => 'manual_payments', :payzilla => 'dummy'},
  {:title => 'MKB Popolnenie kart', :keyword => 'mkb_cards', :payzilla => 'dummy'},
  {:title => 'Ot Padeniy', :keyword => 'mkb_fails', :payzilla => 'dummy'},
  {:title => 'Ostatok ot operaciy', :keyword => 'mkb_balances', :payzilla => 'dummy'},
  {:title => 'Kapstroy Telekom Telefoniya', :keyword => 'capstroy_phone', :payzilla => 'dummy'},
  {:title => 'Kapstroy Telekom Internet & TV', :keyword => 'capstroy_internet', :payzilla => 'dummy'}, 
  {:title => 'ZelKom', :keyword => 'zelkom', :payzilla => 'dummy'},
  {:title => 'Northnet', :keyword => 'northnet', :payzilla => 'dummy'},
  {:title => 'Telekom MPK', :keyword => 'telekom_mpk', :payzilla => 'dummy'},
  {:title => 'Matrix.Mobile', :keyword => 'matrix', :payzilla => 'matrix'},
  {:title => 'ITKM', :keyword => 'itkm', :payzilla => 'dummy'},
  {:title => 'Cyberplat', :keyword => 'cyberplat_413', :payzilla => 'cyberplat'},
  {:title => 'Ostatok ot operaciy BTI', :keyword => 'mkb_balances_bti', :payzilla => 'dummy'},
  {:title => 'On-Lime', :keyword => 'onlime', :payzilla => 'dummy'},
  {:title => 'Moneta.ru', :keyword => 'moneta_ru', :payzilla => 'dummy'},
  {:title => '2KOM', :keyword => 'twokom', :payzilla => 'dummy'},
  {:title => 'ABK-Computer', :keyword => 'avk_computer', :payzilla => 'dummy'},
  {:title => 'NetByNet', :keyword => 'netbynet', :payzilla => 'dummy'}
]

#megafon = Gateway.create!({:title => 'Megafon', :keyword => 'megafon', :payzilla => 'megafon'})

#megafon.setting_domain = '193.201.228.9'
#megafon.setting_client = 'MKB'
#megafon.setting_password = '1234'
#megafon.setting_key_password = '1234'
#megafon.attachment_cert = File.new()
#megafon.attachment_key = File.new()
#megafon.save!

Terminal.create(:agent_id => Agent.first.id, :keyword => 'SAD6', :terminal_profile => TerminalProfile.last)

#megafon = Provider.create!(:keyword => '1.mob_megafon', :title => 'Megafon', :provider_profile => ProviderProfile.first, :provider_group => ProviderGroup.first)
#beeline = Provider.create!(:keyword => '2.mob_beeline', :title => 'Beeline', :provider_profile => ProviderProfile.first, :provider_group => ProviderGroup.first)
#mts = Provider.create!(:keyword => 'mts', :title => 'Mts', :provider_profile => ProviderProfile.first, :provider_group => ProviderGroup.first)
#akado = Provider.create!(:keyword => '37.tel_akado', :title => 'akado', :provider_profile => ProviderProfile.first, :provider_group => ProviderGroup.first)
#cyberplat = Provider.create!(:keyword => 'cyberplat', :title => 'Cyberplat', :provider_profile => ProviderProfile.first, :provider_group => ProviderGroup.first)
#qiwi = Provider.create!(:keyword => 'qiwi', :title => 'OSMP', :provider_profile => ProviderProfile.first, :provider_group => ProviderGroup.first)
#skylink = Provider.create!(:keyword => 'skylink', :title => 'Skylink', :provider_profile => ProviderProfile.first, :provider_group => ProviderGroup.first)
#yandex = Provider.create!(:keyword => 'yandex', :title => 'Yandex', :provider_profile => ProviderProfile.first, :provider_group => ProviderGroup.first)
#matrix = Provider.create!(:keyword => 'matrix', :title => 'Matrix', :provider_profile => ProviderProfile.first, :provider_group => ProviderGroup.first)
#webmoney = Provider.create!(:keyword => 'webmoney', :title => 'Webmoney', :provider_profile => ProviderProfile.first, :provider_group => ProviderGroup.first)
#tele2 = Provider.create!(:keyword => '21.mob_tele2  ', :title => 'Tele2', :provider_profile => ProviderProfile.first, :provider_group => ProviderGroup.first)


#ProviderGateway.create!()
