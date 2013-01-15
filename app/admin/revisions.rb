ActiveAdmin.register Revision do
  actions :index, :show, :new, :create, :destroy

  menu :parent => I18n.t('activerecord.models.gateway.other'),
       :if     => proc { can? :index, Revision }

  member_action :payments, :title => I18n.t('smartkiosk.admin.actions.revisions.payments') do
    @revision = Revision.find(params[:id])
    @payments = @revision.payments.page(params[:page]).per(100)
  end

  member_action :moderate do
    @revision = Revision.find(params[:id])
    @revision.moderate!
    redirect_to [:admin, @revision]
  end

  #
  # INDEX
  #
  batch_action I18n.t('smartkiosk.admin.actions.revisions.approve') do |selection|
    Revision.find(selection).each{|r| r.moderate!}
    redirect_to :back
  end

  scope I18n.t('active_admin.all'), :all
  scope I18n.t('activerecord.scopes.revision.unmoderated'), :unmoderated
  scope I18n.t('activerecord.scopes.revision.error'), :error

  filter :id
  filter :moderated, :as => 'select', :input_html => { :class => 'chosen' }
  filter :gateway, :as => 'multiple_select', :input_html => { :class => 'chosen' }
  filter :date
  filter :state, :as => 'multiple_select', :collection => proc { I18n.t('smartkiosk.revision_states').invert }, :input_html => { :class => 'chosen' }
  filter :payments_count, :as => 'numeric_range'
  filter :paid_sum, :as => 'numeric_range'
  filter :enrolled_sum, :as => 'numeric_range'
  filter :commission_sum, :as => 'numeric_range'

  index do
    selectable_column
    column :id, :sortable => :id do |x|
      link_to x.id, [:admin, x]
    end
    column :gateway
    column :date
    column :state do |x|
      type = 'warning'
      type = 'error' if x.state == 'error'
      type = 'ok' if x.state == 'done'
      type = nil if x.state == 'new'

      status_tag I18n.t("smartkiosk.revision_states.#{x.state}"), type
    end
    column :moderated do |x|
      status_boolean(self, x.moderated?)
    end
    column :payments_count
    column :paid_sum
    column :enrolled_sum
    default_actions
  end

  #
  # SHOW
  #
  action_item :only => [:show] do
    link_to I18n.t('smartkiosk.admin.actions.revisions.payments'),
      payments_admin_revision_path(revision)
  end

  action_item :only => [:show], :if => proc{!revision.moderated?} do
    link_to I18n.t('smartkiosk.admin.actions.revisions.approve'),
      moderate_admin_revision_path(revision)
  end

  show do
    attributes_table do
      row :id
      row :gateway
      row :date
      row :state do |x|
        type = 'warning'
        type = 'error' if x.state == 'error'
        type = 'ok' if x.state == 'done'
        type = nil if x.state == 'new'

        status_tag I18n.t("smartkiosk.revision_states.#{x.state}"), type
      end
      row :moderated do |x|
        status_boolean(self, x.moderated?)
      end
      row :payments_count
      row :paid_sum
      row :enrolled_sum
      row :commission_sum
      row :error do |x|
        unless x.error.blank?
          I18n.t("smartkiosk.gateways.#{x.gateway.keyword}.errors")[x.error]
        end
      end
      row :data do |x|
        link_to(File.basename(x.data.path), x.data.url)
      end
    end

    active_admin_comments
  end

  #
  # FORM
  #
  form do |f|
    f.inputs do
      f.input :gateway, :input_html => {:class => 'chosen'}
      f.input :date, :as => :datepicker
    end
    f.actions
  end
end
