ActiveAdmin.register Limit do
  menu :parent => I18n.t('activerecord.models.provider.other'),
       :if     => proc { can? :index, Limit }

  #
  # INDEX
  #
  filter :id
  filter :provider_profile, :as => 'multiple_select', :input_html => { :class => 'chosen' },
    :collection => proc { ProviderProfile.rmap }
  filter :start
  filter :finish
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :id, :sortable => :id do |x|
      link_to x.id, [:admin, x]
    end
    column :provider_profile
    column :start
    column :finish
    default_actions
  end

  #
  # SHOW
  #
  show do
    attributes_table do
      row :provider_profile
      row :start
      row :finish
      row :created_at
      row :updated_at
    end

    panel I18n.t('activerecord.models.limit_section.other') do
      table_for(limit.limit_sections, :i18n => LimitSection) do |t|
        t.column :agent
        t.column :terminal
        t.column :payment_type
        t.column :min
        t.column :max
      end
    end

    active_admin_comments
  end

  #
  # FORM
  #
  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :provider_profile, :input_html => { :class => 'chosen' },
        :collection => ProviderProfile.rmap
      f.input :start, :as => :datepicker
      f.input :finish, :as => :datepicker
    end
    f.inputs do
      f.has_many :limit_sections do |lsf|
        lsf.semantic_errors
        lsf.input :agent, :collection => Agent.rmap, :input_html => { :class => 'chosen' }
        lsf.input :terminal, :collection => Terminal.rmap, :input_html => { :class => 'chosen' }
        lsf.input :payment_type, :as => :select, :input_html => { :class => 'chosen' }, 
          :collection => I18n.t('smartkiosk.payment_types').invert
        lsf.input :min
        lsf.input :max
        unless lsf.object.new_record?
          lsf.input :_destroy, :as => :boolean, :label => I18n.t('active_admin.delete')
        end
        lsf.form_buffers.last
      end
    end
    f.actions
  end
end
