Joosy.namespace 'Welcome', ->

  class @IndexPage extends ApplicationPage
    @layout ApplicationLayout
    @view   'index'

    hardware: [
      'printer',
      'cash_acceptor',
      'modem',
      'card_reader',
      'watchdog'
    ]

    defaultColumns: [
      'keyword',
      'address',
      'printer_error',
      'printer_model',
      'printer_version',
      'cash_acceptor_error',
      'cash_acceptor_version',
      'cash_acceptor_model',
      'modem_error',
      'modem_signal_level',
      'modem_balance',
      'card_reader_error',
      'card_reader_version',
      'card_reader_model',
      'watchdog_error',
      'collected_at',
      'notified_at',
      'issues_started_at',
      'agent_id',
      'terminal_profile_id',
      'version',
      'banknotes',
      'cash',
      'cashless',
      'upstream',
      'downstream',
      'ip',
      'juristic_name',
      'contract_number',
      'rent',
      'rent_finish_date'
    ]

    elements:
      'listing': '#listing'
      'inputs': 'input'
      'keyword': '#keyword'
      'error': '#error'
      'agent': '#agent'
      'terminalProfile': '#terminal_profile'
      'address': '#address'
      'date': '.brand small'

    events:
      'click #filter': 'filter'

    @fetch (done) ->
      @data.agents   = []
      @data.profiles = []
      @data.hardware = @hardware

      @allowedFields = Object.keys(window.terminals.first())

      @terminals = window.terminals.clone()
      @index     = Object.extended()

      window.terminals.each (t) =>
        @index[t.id] = t
        @data.agents.push t['agent_title'] if t['agent_title']
        @data.profiles.push t['terminal_profile_title'] if t['terminal_profile_title']

      @data.agents = @data.agents.unique()
      @data.profiles = @data.profiles.unique()

      @widths  = $.cookie('widths')  || {}
      @sorter  = $.cookie('sorter')  || ['keyword', true]
      @columns = $.cookie('columns') || @defaultColumns

      @columns.add @defaultColumns.subtract(@columns)
      @columns = @columns.intersect(@defaultColumns).intersect(@allowedFields)

      done()

    @afterLoad ->
      $('select').chosen
        allow_single_deselect: true

      @fixHeight(); $(window).resize => @fixHeight()

      @sort()
      @setupCopier()
      @displayGrid()

      @socket = new WebSocket("ws://localhost:3001/")
      @socket.onmessage = (msg) =>
        terminal = JSON.parse(msg.data)
        Object.merge @index[terminal.id], terminal
        @grid.invalidate()
        @date.html Date.create().format(undefined, I18n.locale)

    setupCopier: ->
      @copier = new CopyPaste()

      @inputs.focus => @copier.disabled = true
      @inputs.blur  => @copier.disabled = false

      @copier.prepare (arg) =>
        range = @grid.getSelectionModel().getSelectedRanges().first()
        return "" unless range

        data = []

        for row in [range.fromRow..range.toRow]
          do (row) =>
            rowData = []

            for cell in [range.fromCell..range.toCell]
              do (cell) =>
                rowData.push $(@grid.getCellNode(row, cell)).text()

            data.push rowData

        SheetClip.stringify data

    displayGrid: ->
      columns = @columns.map (x) =>
        {
          field: x,
          id: x,
          name: I18n.t("activerecord.attributes.terminal.#{x}"),
          sortable: true,
          width: @widths[x] || 150
        }

      columns[@columns.indexOf('terminal_profile_title')]?.name = I18n.t("activerecord.attributes.terminal.terminal_profile")
      columns[@columns.indexOf('agent_title')]?.name = I18n.t("activerecord.attributes.terminal.agent")

      @hardware.each (device) =>
        offset = @columns.indexOf("#{device}_error")
        if columns[offset]
          columns[offset].name = I18n.t("smartkiosk.hardware.#{device}.title")
          columns[offset].formatter = (r, c, v) -> Joosy.Helpers.Application.hardwareError(device, v)

      columns[@columns.indexOf('banknotes')]?.formatter = (r, c, v) ->
        return "" unless v
        sum  = 0
        list = Object.keys(v).map((banknote) ->
          sum += banknote.toNumber() * v[banknote].toNumber()
          "<b>#{banknote}</b>: #{v[banknote]}"
        ).join(", ")

        "#{sum} &mdash; #{list}"

      @grid = new Slick.Grid @listing, @terminals, columns,
        enableCellNavigation: true
        enableColumnReorder: true

      @grid.setSortColumn(@sorter[0], @sorter[1])

      @grid.setSelectionModel(new Slick.CellSelectionModel())

      @grid.onSort.subscribe (e, args) =>
        @sorter = [args.sortCol.field, args.sortAsc]
        $.cookie('sorter', @sorter)
        @sort()
        @grid.invalidate()

      @grid.onColumnsResized.subscribe (e, args) =>
        args.grid.getColumns().each (c) => @widths[c.id] = c.width
        $.cookie('widths', @widths)

      @grid.onColumnsReordered.subscribe (e, args) =>
        $.cookie 'columns', args.grid.getColumns().map (x) -> x.id

    fixHeight: ->
      @listing.height "#{$(window).height() - 145}px"
      @grid?.resizeCanvas()

    filter: ->
      keyword         = @keyword.val()
      errors          = Object.extended()
      agent           = @agent.val()
      terminalProfile = @terminalProfile.val()
      address         = @address.val()

      @error.val()?.each (e) =>
        e = e.split('-')
        errors[e[0]] ||= []
        errors[e[0]].push e[1].toNumber()

      @terminals = window.terminals.filter (x) =>
        hardware = !@hardware.map( (h) =>
          !errors[h]? || errors[h].some(x["#{h}_error"])
        ).some(false)

        return (
          hardware &&
          (keyword.length == 0 || x['keyword'].startsWith(keyword, 0, false)) &&
          (agent.length == 0 || x['agent_title'] == agent) &&
          (terminalProfile.length == 0 || x['terminal_profile_title'] == terminalProfile) &&
          (address.length == 0 || x['address'].startsWith(address, 0, false))
        )

      @sort()
      @grid.setData @terminals
      @grid.invalidate()

    sort: ->
      if @sorter[0].endsWith('_error')
        @terminals.sort (a, b) =>
          a = a[@sorter[0]] || '99999'
          b = b[@sorter[0]] || '99999'

          return 0 if a == b

          result = if a > b then 1 else -1
          result = -result if !@sorter[1]
          result
      else
        @terminals.sort (a, b) =>
          return 0 if a[@sorter[0]] == b[@sorter[0]]
          result = if a[@sorter[0]] > b[@sorter[0]] then 1 else -1
          result = -result if !@sorter[1]
          result
