ActiveAdmin.register Commission do

  menu :parent => I18n.t('activerecord.models.provider.other'),
       :if     => proc { can? :index, Commission }

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

    panel I18n.t('activerecord.models.commission_section.other') do
      table_for(commission.commission_sections, :i18n => CommissionSection) do |t|
        t.column :agent
        t.column :terminal
        t.column :payment_type
        t.column :min
        t.column :max
        t.column :percent_fee
        t.column :static_fee
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
      f.has_many :commission_sections do |csf|
        csf.semantic_errors
        csf.input :agent, :collection => Agent.rmap, :input_html => { :class => 'chosen' }
        csf.input :terminal, :collection => Terminal.rmap, :input_html => { :class => 'chosen' }
        csf.input :payment_type, :as => :select, :input_html => { :class => 'chosen' }, 
          :collection => I18n.t('smartkiosk.payment_types').invert
        csf.input :min
        csf.input :max
        csf.input :percent_fee
        csf.input :static_fee
        unless csf.object.new_record?
          csf.input :_destroy, :as => :boolean, :label => I18n.t('active_admin.delete')
        end
        csf.form_buffers.last
      end
    end
    f.actions
  end
end
