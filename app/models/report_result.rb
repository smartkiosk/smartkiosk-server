class ReportResult < ActiveRecord::Base
  #
  # RELATIONS
  #
  belongs_to :report

  #
  # MODIFICATIONS
  #
  serialize :data

  def human_column_name(field)
    if field.starts_with?('_')
      model, name = report.decode_field(field).split '.'
      title       = []

      title << I18n.t("activerecord.models.#{model}", :count => 1)
      title << I18n.t("activerecord.attributes.#{model}.#{name}")

      title.join(': ')
    else
      I18n.t "smartkiosk.reports.data.#{report.report_template.kind}.calculations.#{field}"
    end
  end
end
