module ActiveAdmin
  module Inputs
    class DatepickerInput < ::Formtastic::Inputs::StringInput
      def input_html_options
        options = super
        value   = object.send(method)

        options[:class] = [options[:class], "datepicker"].compact.join(' ')
        options[:value] = value.blank? ? '' : value.strftime("%d.%m.%Y")
        options
      end
    end
  end
end
