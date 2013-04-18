Joosy.namespace 'Welcome', ->

  class @IndexPage extends ApplicationPage
    @layout ApplicationLayout
    @view   'index'

    defaultColumns: [
      'keyword',
      'terminal_profile_title',
      'address',
      'agent_title',
      'printer_error',
      'cash_acceptor_error',
      'modem_error',
      'card_reader_error',
      'watchdog_error',
      'collected_at',
      'notified_at',
      'issues_started_at'
    ]

    elements:
      'listing': '#listing'
      'inputs': 'input'
      'keyword': '#keyword'
      'error': '#error'
      'agent': '#agent'
      'terminalProfile': '#terminal_profile'
      'address': '#address'

    events:
      'click #filter': 'filter'

    @fetch (done) ->
      @data.agents   = []
      @data.profiles = []

      @terminals = window.terminals.clone()
      @index     = Object.extended()

      window.terminals.each (t) =>
        @index[t.id] = t
        @data.agents.push t['agent_title']
        @data.profiles.push t['terminal_profile_title']

      @data.agents = @data.agents.unique()
      @data.profiles = @data.profiles.unique()

      @widths  = $.cookie('widths')  || {}
      @sorter  = $.cookie('sorter')  || ['keyword', true]
      @columns = $.cookie('columns') || @defaultColumns

      done()

    @afterLoad ->
      $('select').chosen
        allow_single_deselect: true

      @fixHeight(); $(window).resize => @fixHeight()

      @sort()
      @setupCopier()
      @displayGrid()

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

      columns[@columns.indexOf('terminal_profile_title')].name = I18n.t("activerecord.attributes.terminal.terminal_profile")
      columns[@columns.indexOf('agent_title')].name = I18n.t("activerecord.attributes.terminal.agent")

      [
        'printer',
        'cash_acceptor',
        'modem',
        'card_reader',
        'watchdog'
      ].each (device) =>
        offset = @columns.indexOf("#{device}_error")
        columns[offset].name = I18n.t("smartkiosk.hardware.#{device}.title")
        columns[offset].formatter = (r, c, v) -> Joosy.Helpers.Application.hardwareError(device, v)

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
      error           = @error.val()
      agent           = @agent.val()
      terminalProfile = @terminalProfile.val()
      address         = @address.val()

      console.log [keyword, error, agent, terminalProfile, address]

      @terminals = window.terminals.filter (x) ->
        return (
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
