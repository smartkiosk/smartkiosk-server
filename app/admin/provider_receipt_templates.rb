ActiveAdmin.register ProviderReceiptTemplate do

  menu :parent => I18n.t('activerecord.models.provider.other'), 
       :if     => proc { can? :index, Gateway }
  

  controller do
    before_filter(:only => :new) do
      @provider_receipt_template = ProviderReceiptTemplate.sample
    end
  end

  #
  # INDEX
  #
  filter :providers_id, :as => 'multiple_select', :input_html => { :class => 'chosen' },
    :collection => proc { Provider.rmap }
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :id
    column :providers do |x|
      x.title
    end
    column :created_at
    column :updated_at
    default_actions
  end

  #
  # SHOW
  #
  show do |rt|
    attributes_table do
      row :providers do |x|
        x.title
      end
      row :template do
        pre rt.template
      end
      row :updated_at
    end

    active_admin_comments
  end

  #
  # FORM
  #
  form do |f|
    f.inputs do
      unless f.object.system?
        f.input :providers, :collection => Provider.rmap, :input_html => { 
          :class => 'chosen',
          :'data-placeholder' => I18n.t('active_admin.filters.multiple_select.placeholder'),
        }
      end

      f.input :template, :input_html => { 
        :style => 'font-family: Consolas, Monaco, Lucida Console, Liberation Mono, DejaVu Sans Mono, Bitstream Vera Sans Mono, Courier New, monospace' 
      }
      f.form_buffers.last << Arbre::Context.new do
        table(:class => 'hint') do
          tr do
            ProviderReceiptTemplate.entities.each do |entity, fields|
              td(:style => 'white-space: nowrap') do
                fields.each do |field|
                  para do
                    strong "#{entity}_#{field}:"
                    span I18n.t("activerecord.attributes.#{entity}.#{field}")
                  end
                end
              end
            end
          end
        end
      end.to_s
    end
    f.actions
  end
end
