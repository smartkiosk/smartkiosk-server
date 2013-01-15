module ActiveAdmin::ReportTemplatesHelper
  def localize_report_fields(data)
    if data.is_a? Array
      data.map do |x|
        localize_report_entry x
      end
    else
      localize_report_entry data
    end
  end

  def localize_report_entry(entry)
    model, name = entry.split '.'

    title =  I18n.t("activerecord.models.#{model}", :count => 1) 
    title += ' / '
    title += I18n.t("activerecord.attributes.#{model}.#{name}")

    [title, entry]
  end

  def localize_report_calculations(builder)
    builder.calculations.keys.map do |x|
      title = I18n.t "smartkiosk.reports.data.#{builder.keyword}.calculations.#{x}"
      [title, x]
    end
  end

  def localize_report_condition_title(builder, field)
    I18n.t "smartkiosk.reports.data.#{builder.keyword}.conditions.#{field}.title"
  end

  def localize_report_condition_value(builder, field, value)
    condition  = builder.conditions[field]
    collection = if condition.is_a?(Array)
      I18n.t "smartkiosk.reports.data.#{builder.keyword}.conditions.#{field}.values"
    else
      condition.call().with_indifferent_access
    end

    return value.is_a?(Array) ? value.map{|x| collection[x]}.join(', ') : collection[value]
  end

  def localize_report_conditions(builder, field)
    condition = builder.conditions[field]

    if condition.is_a?(Array)
      return condition.map do |x|
        title = I18n.t "smartkiosk.reports.data.#{builder.keyword}.conditions.#{field}.values.#{x}"
        [title, x]
      end
    elsif condition.is_a?(Proc)
      return condition.call().invert
    end
  end
end 