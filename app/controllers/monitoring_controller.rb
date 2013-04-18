class MonitoringController < ApplicationController
  helper 'joosy/sprockets'

  before_filter do
    redirect_to '/admin/' if !current_user && !current_user.role?('monitoring')
  end

  def index
    agents   = {}
    profiles = {}

    Agent.as_hash(['id', 'title']).each{|x| agents[x['id']] = x['title']}
    TerminalProfile.as_hash(['id', 'title']).each{|x| profiles[x['id']] = x['title']}

    fields = [
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
    ].select{|x|
      current_user.priveleged?('monitoring', x.gsub('_', '-'))
    }

    @terminals = Terminal.as_hash(fields) do |r|
      r['agent_title'] = agents[r['agent_id']] if r['agent_id']
      r['terminal_profile_title'] = profiles[r['terminal_profile_id']] if r['terminal_profile_id']
    end

    @terminals = Oj.dump(@terminals)

    render layout: false
  end
end
