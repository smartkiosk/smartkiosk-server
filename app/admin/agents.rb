ActiveAdmin.register Agent do

  menu :parent   => I18n.t('activerecord.models.terminal.other'),
       :if       => proc { can? :index, Agent }

  #
  # INDEX
  #
  scope I18n.t('active_admin.all'), :all
  scope I18n.t('activerecord.scopes.agent.root'), :root

  filter :id
  filter :agent, :as => 'multiple_select', :input_html => { :class => 'chosen' }, 
    :collection => proc { Agent.rmap }
  filter :title
  filter :created_at
  filter :updated_at  

  index do
    selectable_column
    column :id, :sortable => :id do |x|
      link_to x.id, [:admin, x]
    end
    column :title
    column :agent
    column :created_at
    column :updated_at
    default_actions
  end

  #
  # SHOW
  #
  show do |agent|
    attributes_table do
      row :id
      row :agent
      row :title
      row :terminals_count do |a|
        a.terminals.count
      end
      row :juristic_name
      row :juristic_address_city
      row :juristic_address_street
      row :juristic_address_home
      row :physical_address_city
      row :physical_address_district
      row :physical_address_subway
      row :physical_address_street
      row :physical_address_home
      row :contact_name
      row :contact_info
      row :director_name
      row :director_contact_info
      row :bookkeeper_name
      row :bookkeeper_contact_info
      row :inn
      row :support_phone
      row :created_at
      row :updated_at
    end

    panel I18n.t('activerecord.models.payment.other') do
      table_for(agent.payments.limit(20), :i18n => Payment) do |t|
        t.column :terminal do |p|
          unless p.terminal.blank?
            link_to p.terminal.keyword, admin_terminal_path(p.terminal)
          end
        end
        t.column :paid_amount
        t.column :provider
        t.column :created_at
      end

      div(:class => 'more') do
        text_node link_to(
          link_to I18n.t('smartkiosk.full_list'),
          admin_payments_path(:q => {:agent_id_eq => agent.id})
        )
      end
    end
  end

  #
  # FORM
  #
  form do |f|
    f.inputs do
      f.input :agent, :input_html => { :class => 'chosen' }
      f.input :title
      f.input :juristic_name
      f.input :juristic_address_city
      f.input :juristic_address_street
      f.input :juristic_address_home
      f.input :physical_address_city
      f.input :physical_address_district
      f.input :physical_address_subway
      f.input :physical_address_street
      f.input :physical_address_home
      f.input :contact_name
      f.input :contact_info
      f.input :director_name
      f.input :director_contact_info
      f.input :bookkeeper_name
      f.input :bookkeeper_contact_info
      f.input :inn
      f.input :support_phone
    end
    f.buttons
  end
end
