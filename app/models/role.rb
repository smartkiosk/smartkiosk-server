class Role < ActiveRecord::Base
  def self.entries
    @entries ||= %w(
      monitoring users versions reports report_templates 
      payments providers commissions limits
      provider_receipt_templates terminals
      agents collections terminal_profiles system_receipt_templates
      gateways rebates revisions
    )
  end

  def self.actions
    @actions ||= {
      'terminals' => %w(read create edit destroy reload reboot disable enable upgrade),
      'monitoring' => [
        'keyword',
        'address',
        'printer-error',
        'printer-model',
        'printer-version',
        'cash-acceptor-error',
        'cash-acceptor-version',
        'cash-acceptor-model',
        'modem-error',
        'modem-signal-level',
        'modem-balance',
        'card-reader-error',
        'card-reader-version',
        'card-reader-model',
        'watchdog-error',
        'collected-at',
        'notified-at',
        'issues-started-at',
        'agent-id',
        'terminal-profile-id',
        'version',
        'banknotes',
        'cash',
        'cashless',
        'upstream',
        'downstream',
        'ip',
        'juristic-name',
        'contract-number',
        'rent',
        'rent-finish-date'
      ]
    }
  end

  def self.entries_actions
    return @result unless @result.blank?

    @result = {}
    entries.each do |x|
      @result[x] = {}

      if actions[x].blank?
        %w(read create edit destroy).each do |a|
          @result[x][a] = I18n.t("smartkiosk.role_priveleges.basic.#{a}")
        end
      else
        actions[x].each do |a|
          @result[x][a] = I18n.t("smartkiosk.role_priveleges.#{x}.#{a}")
        end
      end
    end

    @result
  end

  def title
    roles = I18n.t("smartkiosk.roles").with_indifferent_access

    if roles.include?(keyword)
      roles[keyword]
    else
      I18n.t "activerecord.models.#{keyword.singularize}.other"
    end
  end

  def actions
    self.class.entries_actions[keyword]
  end

  def modelize
    keyword.singularize.camelize.constantize rescue nil
  end
end
