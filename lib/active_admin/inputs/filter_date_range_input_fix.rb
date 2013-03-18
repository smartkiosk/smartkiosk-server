module ActiveAdmin
  module Inputs
    class FilterDateRangeInput

      def to_html
        input_wrapping do
          [ label_html,
            builder.text_field(gt_input_name, input_html_options(gt_input_name, 'datepickergte')),
            template.content_tag(:span, "-", :class => "seperator"),
            builder.text_field(lt_input_name, input_html_options(lt_input_name, 'datepickerlte')),
          ].join("\n").html_safe
        end
      end

      def input_html_options(input_name=gt_input_name, extra_class='')
        current_value = @object.send(input_name)
        { :size => 12,
          :class => "datepicker #{extra_class}",
          :max => 10,
          :value => current_value.respond_to?(:strftime) ? current_value.strftime("%d.%m.%Y") : "" }
      end
    end
  end
end