# encoding: utf-8

require 'blueprints'

require 'role'
require 'provider_gateway'
require 'terminal_profile_promotion'

class Seeder
  seeds_root = File.expand_path "../../db/seeds/", __FILE__

  cattr_accessor :engines
  cattr_accessor :system_receipt_templates_path, :providers_receipt_template_path
  attr_accessor :user, :agent, :terminals, :dummy

  @@engines = []
  @@system_receipt_templates_path   = "#{seeds_root}/receipt_templates/system/*.txt"
  @@providers_receipt_template_path = "#{seeds_root}/receipt_templates/payment.txt"

  def initialize
    seed_roles

    @user      = User.make! :root => true, :email => 'admin@example.com', :password => 'password'
    @agent     = Agent.make!
    @terminals = []
  end

  def truncate_database
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  def seed_engines
    self.class.engines.each do |e|
      e.const_get('Engine').load_seed
    end
  end

  def seed_roles
    Role.entries.each do |x|
      Role.create! :keyword => x
    end
  end

  def seed_gateways
    @dummy = Gateway.create! :title => 'Заглушка', :keyword => 'dummy', :payzilla => 'dummy'
  end

  def seed_terminal(keyword)
    Terminal.make!(:keyword => keyword, :agent => @agent).ping! TerminalPing.make
  end

  def seed_test_terminals
    100.times do |i|
      @terminals << Terminal.make!(:agent => @agent)
    end
  end

  def seed_terminal_profiles
    TerminalProfile.create! :keyword => 'default', :title => 'Основные'
  end

  def seed_test_providers
    Provider.make! :keyword => 'first'
    Provider.make! :keyword => 'second'
    Provider.make! :keyword => 'third'
    Provider.make! :keyword => 'fourth'

    Provider.all.each do |p|
      ProviderGateway.create! :provider => p, :gateway => @dummy, :priority => 1

      ([1,5].sample).times do
        ProviderField.make! :provider => p
      end
    end
  end

  def seed_test_terminal_profile_promotions
    profile = TerminalProfile.first

    Provider.all.each_with_index do |p, i|
      TerminalProfilePromotion.create! :terminal_profile => profile, :provider => p
    end
  end

  def seed_test_payments
    100.times do |i|
      Payment.make! :agent => @agent, :terminal => @terminals.sample, :provider_gateway => @dummy.provider_gateways.sample, :gateway_error => [nil, -1].sample
    end
  end

  def seed_receipt_templates
    Dir[self.class.system_receipt_templates_path].each do |rt|
      SystemReceiptTemplate.create! :keyword => File.basename(rt).gsub('.txt', ''), :template => File.read(rt)
    end

    ProviderReceiptTemplate.create!(
      :system   => true,
      :template => File.read(providers_receipt_template_path)
    )
  end

end