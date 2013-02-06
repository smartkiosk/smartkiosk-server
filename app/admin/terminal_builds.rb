ActiveAdmin.register TerminalBuild do

  menu :parent   => I18n.t('activerecord.models.terminal.other'),
       :priority => 21,
       :if       => proc { can? :index, TerminalBuild }

  index do
    selectable_column
    column :id
    column :version do |tb|
      div tb.version

      if tb.gems_ready
        status_tag(I18n.t('smartkiosk.admin.terminal_build.gems_ready'), :ok)
      else
        status_tag(I18n.t('smartkiosk.admin.terminal_build.gems_not_ready'), :error)
      end

    end
    column :source do |tb|
      link_to File.basename(tb.source.path), tb.source.url
    end
    column :created_at
    column :updated_at
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :version
      row :source do |tb|
        link_to File.basename(tb.source.path), tb.source.url
      end
      row :gems_ready do |tb|
        status_boolean(self, tb.gems_ready)
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :source
    end
    f.actions
  end

end
