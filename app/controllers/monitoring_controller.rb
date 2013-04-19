class MonitoringController < ApplicationController
  helper 'joosy/sprockets'

  before_filter do
    redirect_to '/admin/' if !current_user || !current_user.role?('monitoring')
  end

  def index
    agents   = {}
    profiles = {}

    Agent.as_hash(['id', 'title']).each{|x| agents[x['id']] = x['title']}
    TerminalProfile.as_hash(['id', 'title']).each{|x| profiles[x['id']] = x['title']}

    fields = Role.actions['monitoring']
      .select{|x| current_user.priveleged?('monitoring', x)}
      .map{|x| x.gsub '-', '_'}

    fields << 'id'

    @terminals = Terminal.as_hash(fields) do |r|
      r['banknotes'] = JSON.load(r['banknotes'])
      r['agent_title'] = agents[r['agent_id']] if r['agent_id']
      r['terminal_profile_title'] = profiles[r['terminal_profile_id']] if r['terminal_profile_id']
    end

    @terminals = MultiJson.dump(@terminals)

    render layout: false
  end
end
