class MonitoringController < ApplicationController
  helper 'joosy/sprockets'

  before_filter do
    redirect_to '/admin/' if !current_user
  end

  def index
    agents   = {}
    profiles = {}

    Agent.as_hash(['id', 'title']).each{|x| agents[x['id']] = x['title']}
    TerminalProfile.as_hash(['id', 'title']).each{|x| profiles[x['id']] = x['title']}

    @terminals = Terminal.as_hash([
      'id',
      'keyword',
      'address',
      'printer_error',
      'cash_acceptor_error',
      'modem_error',
      'card_reader_error',
      'watchdog_error',
      'collected_at',
      'notified_at',
      'issues_started_at',
      'agent_id',
      'terminal_profile_id'
    ]) do |r|
      r['agent_title'] = agents[r['agent_id']]
      r['terminal_profile_title'] = profiles[r['terminal_profile_id']]
    end

    @terminals = Oj.dump(@terminals)

    render layout: false
  end
end
