ActiveAdmin.register Collection do
  config.batch_actions = false
  actions :index, :show

  menu :parent => I18n.t('activerecord.models.terminal.other'), 
       :if     => proc { can? :index, Collection }

  #
  # INDEX
  #
  filter :id
  filter :agent, :as => 'multiple_select', :input_html => { :class => 'chosen' },
    :collection => proc { Agent.rmap }
  filter :terminal, :as => 'multiple_select', :input_html => { :class => 'chosen' }
  filter :cash_sum, :as => 'numeric_range'
  filter :payments_sum, :as => 'numeric_range'
  filter :approved_payments_sum, :as => 'numeric_range'
  filter :payments_count, :as => 'numeric_range'
  filter :cash_payments_count, :as => 'numeric_range'
  filter :cashless_payments_count, :as => 'numeric_range'
  filter :collected_at

  index do
    column :id, :sortable => :id do |x|
      link_to x.id, [:admin, x]
    end
    column :collected_at
    column :terminal
    column :cash_sum
    column :payments_sum
    column :approved_payments_sum
    column :difference do |x|
      x.payments_sum - x.approved_payments_sum
    end
    default_actions
  end

  #
  # SHOW
  #
  show do
    attributes_table do
      row :id
      row :collected_at
      row :agent
      row :terminal
      row :cash_sum
      row :payments_sum
      row :approved_payments_sum
      row :cash_payments_count
      row :cashless_payments_count
      row :payments_count
      row :banknotes do |x|
        if x.banknotes.is_a?(Hash)
          x.banknotes.collect{|k,v| "<b>#{k}</b> &mdash; #{v}" }.join(', ').html_safe
        end
      end
    end

    active_admin_comments
  end
end
