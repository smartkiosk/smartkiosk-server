Joosy.namespace 'Welcome', ->

  class @IndexPage extends ApplicationPage
    @layout ApplicationLayout
    @view   'index'

    elements:
      'headers': '#listing th'

    @fetch (done) ->
      @data.agents    = window.terminals.map((x) -> x['agent_title']).unique()
      @data.terminals = Object.extended()

      window.terminals.each (t) => @data.terminals[t.id] = t
      done()

    @afterLoad ->
      $('select').chosen()