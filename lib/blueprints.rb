require 'machinist/active_record'

require 'provider_field'

User.blueprint do
  full_name             { Faker::Name.name }
end

Agent.blueprint do
  title                 { Faker::Name.name }
end

ProviderProfile.blueprint do
  title                 { Faker::HipsterIpsum.words(2).join(' ') }
end

TerminalProfile.blueprint do
  title                 { Faker::HipsterIpsum.words(2).join(' ') }
  support_phone         { Faker::PhoneNumber.short_phone_number }
end

ProviderGroup.blueprint do
  title                 { Faker::HipsterIpsum.words(2).join(' ') }
end

Terminal.blueprint do
  terminal_profile      { TerminalProfile.first || TerminalProfile.make! }
  agent                 { Agent.first }
  address               { Faker::Address.street_address }
  keyword               { "TEST-" + (Terminal.count + 1).to_s }
  condition             { ['ok', 'warning', 'error'].sample }
  state                 { ['active', 'disabled', 'upgrading', 'rebooting'].sample }
  notified_at           { DateTime.now }
  collected_at          { DateTime.now }
  printer_error         { [nil, 1, 2000].sample }
  cash_acceptor_error   { [nil, 1, 2000].sample }
  modem_error           { [nil, 1, 2000].sample }
  issues_started_at     { [nil, nil, DateTime.now].sample }
  has_adv_monitor       { [true, false].sample }
end

Payment.blueprint do
  session_id            { Random.new.rand(1...1000000) }
  terminal              { Terminal.all.sample }
  gateway               { Gateway.first }
  provider              { Provider.all.sample }
  paid_amount           { Random.new.rand(100..10000).round(2) }
  enrolled_amount       { Random.new.rand(100..10000).round(2) }
  commission_amount     { Random.new.rand(1..1000).round(2) }
  rebate_amount         { Random.new.rand(1..1000).round(2) }
  paid_at               { DateTime.now }
  state                 { ['error', 'queue', 'manual', 'paid', 'checked'].sample }
end

TerminalPing.blueprint do
  state                 { 'active' }
  ip                    { '127.0.0.1' }
  version               { '0.0.1' }
  banknotes             { {'50' => 5, '1000' => 3} }
  cash_acceptor         { {'error' => nil, 'version' => '1.0'} }
  printer               { {'error' => nil, 'version' => '1.0'} }
  modem                 { {'error' => nil, 'version' => '1.0', 'signal_level' => 4, 'balance' => 44.5} }
  queues                { {'payments' => 4, 'orders' => 0} }
end

Provider.blueprint do
  title                 { Faker::HipsterIpsum.words(2).join(' ') }
  provider_profile      { ProviderProfile.first || ProviderProfile.make! }
  provider_group        { ProviderGroup.first || ProviderGroup.make! }
end

ProviderField.blueprint do
  keyword               { Faker::Lorem.word }
  title                 { Faker::HipsterIpsum.word }
  kind                  { ['phone', 'string', 'date', 'select'].sample }
  values                { Faker::HipsterIpsum.words(3).join(',') }
  mask                  { ['1-x-2', '1-1', nil].sample }
end