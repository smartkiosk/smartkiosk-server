ActiveAdmin.register Terminal do

  SIMPLE_ORDERS = Terminal::ORDERS.select{|x| x != 'upgrade'} unless defined?(SIMPLE_ORDERS)

  menu :parent   => I18n.t('activerecord.models.terminal.other'),
       :label    => I18n.t('smartkiosk.admin.menu.manage'),
       :priority => 1,
       :if       => proc { can? :index, Terminal }

  controller do
    def scoped_collection
      Terminal.includes(:agent)
    end
  end

  member_action(:pings,
    :method => :get,
    :title  => I18n.t('smartkiosk.admin.panels.terminals.all_pings')
  ) do
    @pings = Terminal.find(params[:id]).pings.to_a

    if params[:format] == 'xls'
      package = Axlsx::Package.new do |p|
        p.workbook.add_worksheet(:name => "Pings") do |ws|
          bold   = ws.styles.add_style :b => true, :alignment=> {:horizontal => :center}
          fields = %w(
            created_at condition state version ip queues banknotes
            cash_sum cash_count cash_acceptor_error cash_acceptor_version
            printer_error printer_version modem_balance modem_signal_level
            modem_version
          )
          ws.add_row fields.map{|x| TerminalPing.human_attribute_name(x)}, :style => bold

          @pings.each do |p|
            values = Hash[*fields.map{|x| [x, p.send(x)]}.flatten]

            values['created_at'] = p.created_at.strftime("%d.%m.%Y %H:%M:%S")
            values['state'] = I18n.t("smartkiosk.terminal_states.#{p.state}")
            values['condition'] = I18n.t("smartkiosk.terminal_conditions.#{p.condition}")

            ws.add_row values.values
          end
        end
      end

      package.use_shared_strings = true
      send_data package.to_stream.read, :filename => 'report.xlsx',
        :type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    end
  end

  member_action(:session_records,
    :method => :get,
    :title  =>  I18n.t('smartkiosk.admin.panels.terminals.all_session_records')
  )

  member_action(:upgrade_build,
    :method => :get,
    :title => I18n.t('smartkiosk.admin.panels.terminals.upgrade')
  ) do
    raise CanCan::AccessDenied unless current_user.priveleged?(:terminals, :upgrade)

    @terminals = Terminal.where(:id => params[:id].split(','))
    @ids       = @terminals.map(&:id).join(',')
  end

  member_action :upgrade, :method => :post do
    build = TerminalBuild.find(params[:build_id])

    if build.gems_ready
      Terminal.where(:id => params[:id].split(',')).each do |t|
        t.order! :upgrade, build.id, build.version, build.path, build.url, URI.join(root_url, "/gems").to_s
      end

      redirect_to :action => :index
    else
      redirect_to :back, :flash => { :error => I18n.t('smartkiosk.admin.terminal_build.gems_not_ready_error') }
    end

  end

  SIMPLE_ORDERS.each do |order|
    member_action order, :method => :post do
      Terminal.find(params[:id]).order!(order)
      redirect_to :action => :show
    end
  end

  #
  # INDEX
  #
  batch_action(
    I18n.t('smartkiosk.admin.actions.terminals.upgrade'),
    :if => proc{current_user.priveleged?(:terminals, :upgrade)}
  ) do |selection|
    redirect_to upgrade_build_admin_terminal_path(Terminal.find(selection).map(&:id).join(','))
  end

  SIMPLE_ORDERS.each do |order|
    batch_action(
      I18n.t("smartkiosk.admin.actions.terminals.#{order}"),
      :if => proc{current_user.priveleged?(:terminals, order)}
    ) do |selection|
      Terminal.find(selection).each do |x|
        x.order!(order)
      end
      redirect_to :back
    end
  end

  scope I18n.t('active_admin.all'), :all
  scope I18n.t('activerecord.scopes.terminal.ok'), :ok
  scope I18n.t('activerecord.scopes.terminal.warning'), :warning
  scope I18n.t('activerecord.scopes.terminal.error'), :error

  filter :agent, :as => 'multiple_select', :input_html => { :class => 'chosen' },
    :collection => proc { Agent.rmap }
  filter :state, :as => 'multiple_select',
    :collection => proc { I18n.t('smartkiosk.terminal_states').invert },
    :input_html => { :class => 'chosen' }
  filter :keyword
  filter :address
  filter :ip
  filter :issues_started_at
  filter :collected_at
  filter :notified_at
  Terminal::HARDWARE.each do |device|
    filter :"#{device}_error", :as => 'multiple_select',
      :collection => proc { I18n.t("smartkiosk.hardware.#{device}.errors").invert },
      :input_html => { :class => 'chosen' }
  end

  index do
    selectable_column
    column :keyword, :sortable => :keyword do |x|
      div :class => "important #{'error' unless x.issues_started_at.blank?}" do
        link_to x.keyword, [:admin, x]
      end

      unless x.issues_started_at.blank?
        div :title => I18n.l(x.issues_started_at, :format => :long) do
          status_tag distance_of_time_in_words_to_now(x.issues_started_at), :error
        end
      end
    end
    column :address
    column :agent
    column :condition do |x|
      div :class => 'nowrap centered' do
        Terminal::HARDWARE.each do |device|
          error = x.send "#{device}_error"
          state = error.blank? ? :ok : (error >= 1000 ? :warning : :error)
          title = I18n.t("smartkiosk.hardware.#{device}.title")

          unless error.blank?
            title += ": "+(
              I18n.t("smartkiosk.hardware.#{device}.errors")[error] ||
              I18n.t('smartkiosk.unlocalized')
            )
            title += " (#{error})"
          end

          status_tag I18n.t("smartkiosk.hardware.#{device}.abbr"), state, :title => title
        end
      end
      div :class => 'nowrap centered' do
        status_tag I18n.t("smartkiosk.terminal_states.#{x.state}"), :raw
      end
    end
    column :collected_at, :sortable => :collected_at do |x|
      unless x.collected_at.blank?
        status_tag I18n.l(x.collected_at, :format => :long), :raw
      end
    end
    column :notified_at, :sortable => :notified_at do |x|
      unless x.notified_at.blank?
        state = :raw
        state = :warning if Time.now - x.notified_at > 5*60
        state = :error   if Time.now - x.notified_at > 15*60

        div :title => I18n.l(x.notified_at, :format => :long) do
          status_tag distance_of_time_in_words_to_now(x.notified_at), state
        end
      end
    end
    column :terminal_orders do |x|
      if x.incomplete_orders_count > 0
        x.terminal_orders.incomplete.map do |order|
          title = I18n.t("smartkiosk.terminal_orders.#{order.keyword}")
          title += " (#{order.percent}%)" unless order.percent.blank?

          status = nil
          status = :error if order.error?
          status = :warning if order.sent?
          div status_tag(title, status), :style => 'white-space: nowrap'
        end
      end
    end
  end

  #
  # SHOW
  #
  action_item :only => [:pings] do
    link_to I18n.t('smartkiosk.admin.actions.terminals.pings_excel'),
      pings_admin_terminal_path(:format => 'xls')
  end

  action_item :only => [:show], :if => proc{current_user.priveleged?(:terminals, :upgrade)} do
    link_to I18n.t('smartkiosk.admin.actions.terminals.upgrade'),
      upgrade_build_admin_terminal_path(terminal), :method => :get
  end

  SIMPLE_ORDERS.each do |order|
    action_item :only => [:show], :if => proc{current_user.priveleged?(:terminals, order)} do
      link_to I18n.t("smartkiosk.admin.actions.terminals.#{order}"),
        send("#{order}_admin_terminal_path", terminal), :method => :post
    end
  end

  show do |terminal|
    attributes_table do
      row :agent
      row :keyword
      row :description
      row :has_adv_monitor do |x|
        status_boolean(self, x.has_adv_monitor)
      end
      if terminal.incomplete_orders_count > 0
        row :terminal_orders do
          terminal.terminal_orders.incomplete.map do |order|
            title = I18n.t("smartkiosk.terminal_orders.#{order.keyword}")
            title += " (#{order.percent}%)" unless order.percent.blank?

            status = nil
            status = :error if order.error?
            status = :warning if order.sent?
            status_tag(title, status)
          end
        end
      end
      row :state do |t|
        unless t.state.blank?
          I18n.t "smartkiosk.terminal_states.#{t.state}"
        end
      end
      row :condition do |t|
        unless t.condition.blank?
          status_tag (I18n.t "smartkiosk.terminal_conditions.#{t.condition}"), t.condition.to_sym
        end
      end
      row :notified_at do |x|
        unless x.notified_at.blank?
          state = :raw
          state = :warning if Time.now - x.notified_at > 5*60
          state = :error   if Time.now - x.notified_at > 15*60

          div :title => I18n.l(x.notified_at, :format => :long) do
            status_tag distance_of_time_in_words_to_now(x.notified_at), state
          end
        end
      end
      row :issues_started_at
      Terminal::HARDWARE.each do |device|
        row :"#{device}_error" do |x|
          unless x.send("#{device}_error").blank?
            I18n.t("smartkiosk.hardware.#{device}.errors")[x.send("#{device}_error")] ||
            I18n.t('smartkiosk.unlocalized') + " (#{x.send("#{device}_error")})"
          else
            span(I18n.t('active_admin.empty'), :class => 'empty')
          end
        end
      end
    end

    unless terminal.pings.last.blank?
      panel I18n.t('smartkiosk.admin.panels.terminals.hardware') do
        attributes_table_for terminal.pings.first do
          row :cash_acceptor_model
          row :cash_acceptor_version
          row :modem_model
          row :modem_version
          row :printer_model
          row :printer_version
          row :card_reader_model
          row :watchdog_model
        end
      end
    end

    panel I18n.t('smartkiosk.admin.panels.terminals.juridical') do
      attributes_table_for terminal do
        row :terminal_profile
        row :sector
        row :contact_name
        row :contact_phone
        row :contact_email
        row :schedule
        row :juristic_name
        row :contract_number
        row :manager
        row :rent
        row :rent_finish_date
        row :collection_zone
        row :check_phone_number
        row :address do |t|
          div t.address
          unless t.address.blank?
            div(:class => 'terminal_map', :id => 'map')
            script(:type => 'text/javascript') do
              raw "$(function(){ showAddress('map', '#{t.address}') })"
            end
          end
        end
      end
    end

    panel I18n.t('activerecord.models.terminal_order.other') do
      table_for(terminal.terminal_orders.limit(20), :i18n => TerminalOrder) do |t|
        t.column :keyword do |x|
          I18n.t "smartkiosk.terminal_orders.#{x.keyword}"
        end
        t.column :args do |x|
          x.args.join(', ') unless x.args.blank?
        end
        t.column :state do |x|
          status = nil
          status = :error if x.error?
          status = :warning if x.sent?
          status_tag I18n.t("smartkiosk.terminal_order_states.#{x.state}"), status
        end
        t.column :created_at
      end
    end

    panel I18n.t('smartkiosk.admin.panels.terminals.pings') do
      table_for(terminal.pings[0..20], :i18n => TerminalPing) do |t|
        t.column :condition do |x|
          status_tag I18n.t("smartkiosk.terminal_conditions.#{x.condition}"), x.condition.to_sym
        end
        t.column :state do |x|
          I18n.t "smartkiosk.terminal_states.#{x.state}"
        end
        t.column :version
        t.column :cash_sum
        t.column :cash_count
        t.column :modem_balance
        t.column :modem_signal_level
      end

      div(:class => 'more') do
        text_node link_to(
          I18n.t('smartkiosk.admin.panels.terminals.all_pings'),
          pings_admin_terminal_path(terminal.id)
        )
      end
    end

    panel I18n.t('smartkiosk.admin.panels.terminals.session_records') do
      table_for(terminal.session_records[0..20], :i18n => SessionRecord) do |t|
        t.column :started_at do |x|
          Time.at(x.started_at).strftime("%d.%m.%Y %H:%M:%S")
        end
        t.column :upstream
        t.column :downstream
        t.column :time
      end

      div(:class => 'more') do
        text_node link_to(
          I18n.t('smartkiosk.admin.panels.terminals.all_session_records'),
          session_records_admin_terminal_path(terminal.id)
        )
      end
    end

    panel I18n.t('activerecord.models.collection.other') do
      table_for(terminal.collections.limit(20), :i18n => Collection) do |t|
        t.column :cash_sum
        t.column :payments_sum
        t.column :approved_payments_sum
        t.column :collected_at
      end

      div(:class => 'more') do
        text_node link_to(
         link_to I18n.t('smartkiosk.full_list'),
          admin_collections_path(:q => {:terminal_id_eq => terminal.id})
        )
      end
    end

    active_admin_comments
  end

  #
  # FORM
  #
  form do |f|
    f.inputs do
      f.input :agent, :input_html => { :class => 'chosen' }
      f.input :keyword
      f.input :description
      f.input :terminal_profile, :input_html => { :class => 'chosen' }
      f.input :has_adv_monitor, :as => :select, :input_html => { :class => 'chosen' }
    end
    f.inputs do
      f.input :sector
      f.input :contact_name
      f.input :contact_phone
      f.input :contact_email
      f.input :schedule
      f.input :juristic_name
      f.input :contract_number
      f.input :manager
      f.input :rent
      f.input :rent_finish_date
      f.input :collection_zone
      f.input :check_phone_number
      f.input :address
    end
    f.actions
  end
end
