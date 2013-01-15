module ActiveAdmin::ViewsHelper
  def status_boolean(context, value)
    return "" if value.nil?
    if value
      context.status_tag I18n.t('formtastic.yes'), :ok
    else
      context.status_tag I18n.t('formtastic.no'), :error
    end
  end

  def currency(value)
    return "" if value.blank?
    "#{value} #{I18n.t('smartkiosk.main_currency')}"
  end

  def percent(value)
    return "" if value.blank?
    "#{value}%"
  end
end 