class ReportResult < ActiveRecord::Base
  #
  # RELATIONS
  #
  belongs_to :report

  #
  # MODIFICATIONS
  #
  serialize :data
end
