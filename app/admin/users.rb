ActiveAdmin.register User do

  menu :parent   => I18n.t('activerecord.models.user.other'), 
       :label    => I18n.t('smartkiosk.admin.menu.manage'), 
       :priority => 1, 
       :if       => proc { can? :index, User }

  controller do
    before_filter(:only => [:update]) do
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
    end
  end

  #
  # INDEX
  #
  filter :id
  filter :roles_id, :as => 'multiple_select', :collection => proc{ Role.all }, :input_html => {
    :class => "chosen"
  }
  filter :email
  filter :current_sign_in_at
  filter :current_sign_in_ip
  filter :last_sign_in_at
  filter :last_sign_in_ip
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :id, :sortable => :id do |x|
      link_to x.id, [:admin, x]
    end
    column :email
    column :root do |x|
      status_boolean(self, x.root?)
    end
    column :roles do |x| 
      x.roles.map{|x| x.title}.join(', ')
    end
    column :last_sign_in_at
    column :updated_at
    default_actions
  end

  #
  # SHOW
  #
  show do |user|
    attributes_table do
      row :id
      row :email
      row :root do |x|
        status_boolean(self, x.root?)
      end
      row :roles do |x|
        x.roles.map{|x| x.title}.join(', ')
      end
      row :current_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_at
      row :last_sign_in_ip
      row :created_at
      row :updated_at
    end
  end

  #
  # FORM
  #
  form do |f|
    f.inputs do
      f.input :full_name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :root, :as => :select, :input_html => { :class => 'chosen' }
    end
    f.inputs do
      roles   = Role.all
      actions = Role.entries_actions

      f.has_many :user_roles do |ur|
        ur.input :role, :input_html => { 
          :class => 'chosen',
          :onchange => <<-JS
            select  = $(this);
            group   = select.parent().parent();
            visible = group.find('.privelege_'+select.val());

            group.find('.privelege').hide();
            visible.show();
            chosenify(visible.find('select'));
          JS
        }
        roles.each do |role|
          actions[role.keyword].each do |action, label|
            ur.input "can_#{role.keyword}_#{action}", :as => :select, :label => label,
              :input_html => { :class => ("chosen" if ur.object.role == role) },
              :wrapper_html => {
                :class => "privelege privelege_#{role.id}",
                :style => ("display: none" unless ur.object.role == role)
              }
          end
        end
        unless ur.object.new_record?
          ur.input :_destroy, :as => :boolean, :label => I18n.t('active_admin.delete')
        end
        ur.form_buffers.last
      end
    end
    f.buttons
  end
end