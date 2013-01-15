class Role < ActiveRecord::Base
  def self.entries
    @entries ||= %w(
      users versions reports report_templates 
      payments providers commissions limits
      provider_receipt_templates terminals
      agents collections terminal_profiles system_receipt_templates
      gateways rebates revisions
    )
  end

  def self.actions
    @actions ||= {
      'terminals' => %w(reload reboot disable enable upgrade)
    }
  end

  def self.entries_actions
    return @result unless @result.blank?

    @result = {}
    entries.each do |x|
      @result[x] = {}

      %w(read create edit destroy).each do |a|
        @result[x][a] = I18n.t("smartkiosk.role_priveleges.basic.#{a}")
      end

      actions[x].each do |a|
        @result[x][a] = I18n.t("smartkiosk.role_priveleges.#{x}.#{a}")
      end unless actions[x].blank?
    end

    @result
  end

  def title
    I18n.t "activerecord.models.#{keyword.singularize}.other"
  end

  def actions
    self.class.entries_actions[keyword]
  end

  def modelize
    keyword.singularize.camelize.constantize
  end
end
