module ActiveAdmin
  module Inputs
    class FilterMultipleSelectInput < Formtastic::Inputs::SelectInput
      include FilterBase

      def input_name
        "#{super}_in"
      end

      def extra_input_html_options
        {
          :multiple => 'multiple',
          :'data-placeholder' => I18n.t('active_admin.filters.multiple_select.placeholder')
        }
      end
    end
  end
end