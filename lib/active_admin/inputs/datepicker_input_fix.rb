module ActiveAdmin
  module Inputs
    class DatepickerInput < ::Formtastic::Inputs::StringInput
      def input_html_options
        options = super
        options[:class] = [options[:class], "datepicker"].compact.join(' ')
        options[:value] = object.send(method).strftime("%d.%m.%Y")
        options
      end
    end
  end
end
