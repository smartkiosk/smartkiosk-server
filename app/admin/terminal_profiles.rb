ActiveAdmin.register TerminalProfile do

  menu :parent   => I18n.t('activerecord.models.terminal.other'),
       :priority => 2,
       :if       => proc { can? :index, TerminalProfile }

  controller do
    before_filter(:only => [:create, :update]) do
      @groups    = {}
      @providers = {}

      if x = params[:terminal_profile_provider_groups]
        x.each_with_index do |value, i|
          @groups[value.delete(:provider_group_id)] = value
        end
      end

      if x = params[:terminal_profile_providers]
        x.each_with_index do |value, i|
          @providers[value.delete(:provider_id)] = value
        end
      end
    end

    after_filter(:only => [:create, :update]) do
      # GROUPS
      current = @terminal_profile.terminal_profile_provider_groups

      current.each do |x|
        attributes = @groups.delete(x.provider_group_id.to_s)

        if attributes.blank?
          x.destroy
        else
          x.update_attributes(attributes)
        end
      end

      excludes = ProviderGroup.select(:id).where(:id => @groups.keys).map{|x| x.id.to_s}
      excludes = @groups.keys - excludes

      @groups.each do |provider_group_id, attributes|
        TerminalProfileProviderGroup.create! attributes.merge(
          :terminal_profile => @terminal_profile,
          :provider_group_id => provider_group_id
        ) unless excludes.include?(provider_group_id)
      end

      # PROVIDERS
      current = @terminal_profile.terminal_profile_providers

      current.each do |x|
        attributes = @providers.delete(x.provider_id.to_s)

        if attributes.blank?
          x.destroy
        else
          x.update_attributes(attributes)
        end
      end

      excludes = Provider.select(:id).where(:id => @providers.keys).map{|x| x.id.to_s}
      excludes = @providers.keys - excludes

      @providers.each do |provider_id, attributes|
        TerminalProfileProvider.create! attributes.merge(
          :terminal_profile => @terminal_profile,
          :provider_id      => provider_id
        ) unless Provider.find_by_id(provider_id).blank?
      end
    end
  end

  member_action :sort, :title => I18n.t('smartkiosk.admin.actions.terminal_profiles.sort')

  action_item :only => [:show, :edit] do
    link_to I18n.t('smartkiosk.admin.actions.terminal_profiles.sort'),
      sort_admin_terminal_profile_path(terminal_profile)
  end

  form do
    active_admin_form_for [:admin, terminal_profile] do |f|
      f.inputs do
        f.input :title
        f.input :support_phone
      end

      f.inputs do
        f.has_many :terminal_profile_promotions, :sortable => :priority do |ftpp|
          ftpp.input :provider, :collection => Provider.rmap, :input_html => { :class => 'chosen' }
          ftpp.input :priority, :as => :hidden
          unless ftpp.object.new_record?
            ftpp.input :_destroy, :as => :boolean, :label => I18n.t('active_admin.delete')
          end
          ftpp.form_buffers.last
        end
      end

      f.actions
    end
  end
end
