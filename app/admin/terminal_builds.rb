ActiveAdmin.register TerminalBuild do

  menu :parent   => I18n.t('activerecord.models.terminal.other'),
       :priority => 21,
       :if       => proc { can? :index, TerminalBuild }

  index do
    selectable_column
    column :id
    column :version
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
