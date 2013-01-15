module ActiveAdmin
  class ResourceController < BaseController
    before_filter :fix_datetime_filter_inclusion, :only => :index

    def clean_search_params(search_params)
      super.delete_if do |key, value|
        value == [""]
      end
    end

  private 

    def fix_datetime_filter_inclusion
      resource_class.columns.each do |c|
        next unless c.type == :datetime

        if !params["q"].blank? && !params["q"]["#{c.name}_lte"].blank?
          params["q"]["#{c.name}_lte"] += " 23:59:59.999999"
        end
      end
    end
  end
end