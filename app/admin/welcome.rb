ActiveAdmin.register_page "Dashboard" do
  menu :label => I18n.t('active_admin.dashboard')

  content do
    h3 I18n.t("smartkiosk.welcome.header", :user => current_user.full_name),
      :style => 'margin-bottom: 30px'

    table do
      tr do
        td :style => 'width: 60%' do
          panel I18n.t("smartkiosk.welcome.roles") do
            table do
              unless current_user.root
                current_user.user_roles.in_groups_of(3, false).each do |group|
                  tr do
                    group.each do |ur|
                      td :style => 'width: 33%;' do
                        div :style => 'padding: 5px; border: 1px solid gray; background-color: white;' do
                          h4 ur.role.title, :style => 'margin-bottom: 8px; font-weight: bold'
                          ur.role.actions.select{|k,v| ur.priveleged?(k)}.values.each do |v|
                            div v
                          end
                        end
                      end
                    end
                  end
                end
              else
                Role.entries_actions.to_a.in_groups_of(3, false).each do |group|
                  tr do
                    group.each do |role, actions|
                      td :style => 'width: 33%;' do
                        div :style => 'padding: 5px; border: 1px solid gray; background-color: white;' do
                          h4 I18n.t("activerecord.models.#{role.singularize}.other"), :style => 'margin-bottom: 8px; font-weight: bold'
                          actions.values.each do |label|
                            div label
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
        td do
          panel I18n.t("smartkiosk.welcome.properties") do
            attributes_table_for current_user do
              row :id
              row :email
              row :current_sign_in_at
              row :current_sign_in_ip
              row :last_sign_in_at
              row :last_sign_in_ip
              row :created_at
              row :updated_at
            end
          end 
        end
      end
    end
  end
end