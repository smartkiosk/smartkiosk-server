ActiveAdmin.register ReportTemplate do

  menu :parent   => I18n.t('activerecord.models.report.other'), 
       :label    => I18n.t('activerecord.models.report_template.other'),
       :priority => 2,
       :if       => proc { can? :index, ReportTemplate }

  controller do
    def scoped_collection
      scope = ReportTemplate

      unless current_user.root
        t = ReportTemplate.arel_table

        scope = scope.where(t[:open].eq(true).or t[:user_id].eq(current_user.id))
      end

      scope
    end

    def edit
      @report_template = ReportTemplate.find(params[:id])
      @report_template.kind = params[:report_template][:kind] unless params[:report_template].try(:[], :kind).blank?
    end
  end

  #
  # INDEX
  #
  filter :kind, :as => 'multiple_select', :input_html => { :class => 'chosen' },
    :collection => proc { I18n.t('smartkiosk.reports.kinds').invert }
  filter :title
  filter :created_at

  index do
    column :kind do |report_template|
      I18n.t "smartkiosk.reports.kinds.#{report_template.kind}"
    end
    column :open do |x|
      status_boolean(self, x.open?)
    end
    column :title
    column :user
    column :created_at
    default_actions
  end

  #
  # SHOW
  #
  action_item :only => [:show] do
    link_to I18n.t('smartkiosk.admin.actions.report_templates.report'),
      new_admin_report_path('report[report_template_id]' => report_template.id)
  end

  show do |report_template|
    attributes_table do
      row :kind do
        I18n.t "smartkiosk.reports.kinds.#{report_template.kind}"
      end
      row :title
      row :open do |x|
        status_boolean(self, x.open?)
      end
      row :groupping do
        report_template.human_groupping_name
      end
      row :fields do
        unless report_template.fields.blank?
          report_template.fields.select{|x| !x.blank?}.map do |x|
            report_template.human_field_name x
          end.join ', '
        end
      end
      row :sorting do
        report_template.human_sorting_name
      end
      row :sort_desc do |x|
        status_boolean(self, x.sort_desc?)
      end
      row :email
      row :user
      row :created_at
      row :updated_at
    end

    panel I18n.t('smartkiosk.admin.panels.report_templates.conditions') do
      div(:class => 'attributes_table') do
        table do
          report_template.report_builder.conditions.each do |condition, values|
            tr do
              th do
                report_template.human_condition_name condition
              end
              td do
                report_template.human_condition_values(condition) || span(I18n.t('active_admin.empty'), :class => 'empty')
              end
            end
          end
        end
      end
    end

    panel I18n.t('smartkiosk.admin.panels.report_templates.recent') do
      table_for(
        report_template.reports.where(:state => 'done').order('id DESC'),:i18n => Report
      ) do |t|
        t.column :created_at do |r|
          link_to I18n.l(r.created_at, :format => :long), admin_report_path(r)
        end
        t.column :start
        t.column :finish
      end
    end

    active_admin_comments
  end

  #
  # FORM
  #
  form do |f|
    f.inputs I18n.t('smartkiosk.admin.panels.report_templates.form.basic') do
      f.input :kind, :as => :select,
        :collection => I18n.t('smartkiosk.reports.kinds').invert,
        :input_html => { 
          :class => 'chosen',
          :onchange => "location.href = '?report_template[kind]='+$(this).val()"
        }
      f.input :title
      f.input :open, :as => :select, :input_html => { :class => 'chosen' }
      f.input :email
      f.input :user, :input_html => { :class => 'chosen' }
    end

    if f.object.report_builder
      f.inputs I18n.t('smartkiosk.admin.panels.report_templates.form.select') do
        f.input :groupping, :as => :select,
          :collection => f.object.report_builder.human_groupping_names,
          :input_html => { 
            :class => 'chosen',
            :onchange => "reportChangeGroupping($(this).val())"
          }

        ([''] + f.object.report_builder.groupping).each do |g|
          f.input :fields, :as => :selectable_check_boxes,
            :collection => f.object.report_builder.human_groupping_field_names(g), 
            :wrapper_html => {
              :class => "groupping groupping-#{g.gsub '.', '-'}",
              :style => ('display: none' unless f.object.groupping == g)
            }
        end

        f.input :calculations, :as => :selectable_check_boxes,
          :collection => f.object.report_builder.human_calculation_names

        ([''] + f.object.report_builder.groupping).each do |g|
          f.input :sorting, :as => :select,
            :collection => f.object.report_builder.human_groupping_field_names(g),
            :input_html => {
              :id => "report_template_sorting_#{g.gsub '.', '-'}",
              :style => 'min-width: 50%',
              :disabled => ("disabled" unless f.object.groupping == g),
              :class => ('chosen' if f.object.groupping == g)
            },
            :wrapper_html => {
              :class => "sorting sorting-#{g.gsub '.', '-'}",
              :style => ('display: none' unless f.object.groupping == g)
            }
        end

        f.input :sort_desc

        f.form_buffers.last
      end

      f.inputs I18n.t('smartkiosk.admin.panels.report_templates.form.conditions') do
        f.object.report_builder.conditions.each do |condition, values|
          f.input "condition_#{condition}", :as => :select, 
            :label => f.object.report_builder.human_condition_name(condition),
            :collection => f.object.report_builder.human_condition_values(condition).invert,
            :input_html => { 
              :class => 'chosen', 
              :multiple => true,
              :'data-placeholder' => I18n.t('active_admin.filters.multiple_select.placeholder')
            }
        end

        f.form_buffers.last
      end
    else
      f.inputs I18n.t('smartkiosk.admin.panels.report_templates.form.more') do
        f.form_buffers.last << content_tag(:li,
          I18n.t('smartkiosk.admin.messages.report_templates.choose_report_type'
        ))
      end
    end

    if f.object.report_builder
      f.actions
    end

    f.form_buffers.last
  end
end
