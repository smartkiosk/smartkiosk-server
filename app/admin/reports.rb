ActiveAdmin.register Report do
  actions :new, :create, :index, :show, :destroy

  menu :parent   => I18n.t('activerecord.models.report.other'),
       :label    => I18n.t('smartkiosk.admin.menu.manage'), 
       :priority => 1, 
       :if       => proc { can? :index, Report }

  controller do
    before_filter :only => :create do
      params[:report][:user_id] = current_user.id
    end

    def scoped_collection
      scope = Report.includes(:report_template, :report_results)

      unless current_user.root
        r = Report.arel_table
        t = ReportTemplate.arel_table

        scope = scope.where(t[:open].eq(true).or t[:user_id].eq(current_user.id))
      end

      scope
    end
  end

  member_action :refresh, :method => :post do
    report = Report.find(params[:id])
    report.enqueue!
    redirect_to [:admin, report]
  end

  #
  # INDEX
  #
  filter :report_template, :as => 'multiple_select', :input_html => { :class => 'chosen' }
  filter :user, :as => 'multiple_select', :input_html => { :class => 'chosen' }
  filter :state, :as => 'multiple_select',
    :input_html => { :class => 'chosen' },
    :collection => proc { I18n.t("smartkiosk.reports.states").invert }
  filter :start
  filter :finish

  index do
    column :id, :sortable => :id do |x|
      link_to x.id, [:admin, x]
    end
    column :report_template
    column :user
    column :state do |r|
      condition = :ok
      condition = :warning if r.state == 'queue'
      condition = :error if r.state == 'error'
      status_tag I18n.t("smartkiosk.reports.states.#{r.state}"), condition
    end
    column :start
    column :finish
    column :created_at
    default_actions do |r|
      unless r.report_results.first.blank?
        link_to I18n.t('smartkiosk.admin.actions.report_results.excel'), 
          excel_admin_report_result_path(r.report_results.first)
      end
    end
  end

  #
  # SHOW
  #
  action_item :only => [:show], :if => proc { ['done', 'error'].include? report.state } do
    link_to I18n.t('smartkiosk.admin.actions.reports.refresh'),
      refresh_admin_report_path(report), :method => :post
  end

  action_item :only => [:show], :if => proc { !report.report_results.first.blank? } do
    link_to I18n.t('smartkiosk.admin.actions.report_results.excel'),
      excel_admin_report_result_path(report.report_results.first)
  end


  show do
    attributes_table do
      row :report_template
      row :user
      row :state do |r|
        condition = :ok
        condition = :warning if r.state == 'queue'
        condition = :error if r.state == 'error'
        status_tag I18n.t("smartkiosk.reports.states.#{r.state}"), condition
      end
      row :start
      row :finish
      row :created_at
    end

    if report.report_results.count > 0
      panel I18n.t('activerecord.models.report_result.other') do
        table_for(report.report_results, :i18n => ReportResult) do |t|
          t.column :created_at do |rr|
            link_to I18n.l(rr.created_at, :format => :short), admin_report_result_path(rr)
          end
          t.column :rows
        end
      end
    end

    if report.state == 'done'
      result = report.report_results.first

      panel "#{I18n.t 'smartkiosk.admin.panels.reports.last_result'} (#{result.rows})" do
        unless result.data.blank?
          fields = result.data.first.keys
          table do
            tr do
              fields.each do |field|
                th result.human_column_name(field)
              end
            end
            result.data.each do |row|
              tr do
                fields.each do |field|
                  td row[field]
                end
              end
            end
          end
        end
      end
    end

    panel 'SQL' do
      para report.report_builder.query
    end
  end

  #
  # FORM
  #
  form do |f|
    f.inputs do
      f.input :report_template, :input_html => { :class => 'chosen' }
      f.input :start, :as => :datepicker
      f.input :finish, :as => :datepicker
    end

    f.actions
  end
end
