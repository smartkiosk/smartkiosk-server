class ReportResult < ActiveRecord::Base
  #
  # RELATIONS
  #
  belongs_to :report
  has_one :report_template, :through => :report

  #
  # MODIFICATIONS
  #
  serialize :data

  def human_column_name(field)
    if field.starts_with?('_')
      report_template.human_field_name report.decode_field(field)
    else
      report_template.human_calculation_name field
    end
  end
end
