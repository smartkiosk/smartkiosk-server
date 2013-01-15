ActiveAdmin.register Version do
  config.batch_actions = false
  actions :index, :show

  menu :parent => I18n.t('activerecord.models.user.other'),
       :if     => proc { can? :index, Version }

  #
  # INDEX
  #
  filter :user, :as => 'multiple_select', :input_html => { :class => 'chosen' }
  filter :item_type, :as => 'multiple_select', :input_html => { :class => 'chosen' },
    :collection => proc {
      [
        'User', 'Agent', 'Collection', 'Commission', 'Gateway', 'Limit', 'Payment',
        'Provider', 'TerminalCondition', 'TerminalType', 'Terminal'
      ].map {|x| [I18n.t("activerecord.models.#{x.underscore}", :count => 1), x]}
    }
  filter :item_id, :as => 'numeric'

  index do
    column :id do |x|
      link_to x.id, [:admin, x]
    end
    column :created_at
    column :user
    column :item_type do |x|
      I18n.t "activerecord.models.#{x.item_type.underscore}", :count => 1
    end
    column :item_id, :order => :item_id do |x|
      link_to x.item_id, :q => {:item_type_in => x.item_type, :item_id_eq => x.item_id}
    end
    column :item do |x|
      item  = x.item || x.reify
      title = item.respond_to?(:title) ? item.title : "---"

      if x.item.blank?
        span(title)
      else
        span(link_to title, [:admin, x.item]) rescue span(title)
      end
    end
    column :event do |x|
      type = :ok
      type = :warning if x.event == 'update'
      type = :error if x.event == 'destroy'

      status_tag I18n.t("smartkiosk.version_actions.#{x.event}"), type
    end
  end

  #
  # SHOW
  #
  show do |version|
    attributes_table do
      row :id
      row :created_at
      row :user
      row :item_type do |x|
        I18n.t "activerecord.models.#{x.item_type.underscore}", :count => 1
      end
      row :item_id do |x|
        x.item_id
      end
      row :item do |x|
        item  = x.item || x.reify
        title = item.respond_to?(:title) ? item.title : "---"

        if x.item.blank?
          span(title)
        else
          span(link_to title, [:admin, x.item]) rescue span(title)
        end
      end
      row :event do |x|
        type = :ok
        type = :warning if x.event == 'update'
        type = :error if x.event == 'destroy'

        status_tag I18n.t("smartkiosk.version_actions.#{x.event}"), type
      end

      # FIELDS
      type = version.item_type.constantize
      item = version.reify || version.item

      row :changeset do |x|
        unless x.changeset.blank?
          ul do
            x.changeset.each do |k, v|
              li do
                strong "#{type.human_attribute_name k}:"
                span v[0]
                span "&rarr;".html_safe
                span v[1]
              end
            end
          end
        end
      end
      row :fields do |x|
        ul do
          item.attributes.each do |k, v|
            li do
              strong "#{type.human_attribute_name k}:"
              span v
            end
          end
        end
      end
    end

    panel I18n.t('activerecord.models.version.other') do
      table_for(version.item.versions, :i18n => Version) do |t|
        column :id do |x|
          link_to x.id, [:admin, x]
        end
        column :created_at
        column :user
        column :event do |x|
          type = :ok
          type = :warning if x.event == 'update'
          type = :error if x.event == 'destroy'

          status_tag I18n.t("smartkiosk.version_actions.#{x.event}"), type
        end
      end
    end
  end
end
