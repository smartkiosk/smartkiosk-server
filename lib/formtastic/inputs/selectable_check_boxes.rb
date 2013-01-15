module Formtastic
  module Inputs
    class SelectableCheckBoxesInput < CheckBoxesInput
      def to_html
        input_wrapping do
          choices_wrapping do
            legend_html <<
            hidden_field_for_all <<
            choices_group_wrapping do
              select_all_html +
              collection.map { |choice|
                choice_wrapping(choice_wrapping_html_options(choice)) do
                  choice_html(choice)
                end
              }.join("\n").html_safe
            end
          end
        end
      end

      def select_all_html
        choice_wrapping({}) do
          check_box = template.check_box_tag(nil, nil, false, 
            :onclick => <<-JS
              selector  = $(this);
              condition = selector.is(':checked');

              selector.closest('.choices-group').find('[type=checkbox]').attr('checked', condition);
            JS
          )

          template.content_tag(:label,
            check_box << I18n.t('select_all')
          )
        end
      end
    end
  end
end