class TerminalPingsController < ApplicationController
  before_filter :authenticate_terminal

  def create
    begin
      profile = @terminal.terminal_profile

      ping_data = params[:terminal_ping]
      remote_timestamp = ping_data[:providers_updated_at].blank? ? nil : DateTime.parse(ping_data[:providers_updated_at])
      local_timestamp = nil
      profile.cached_providers_lock.lock { local_timestamp = profile.actual_timestamp }

      @terminal.ping!(TerminalPing.new ping_data)

      response = {
        :time => DateTime.now,
        :profile => {
          :support_phone => profile.support_phone,
          :logo          => profile.logo.url,
          :modified_at   => profile.updated_at
        },
        :orders => @terminal.terminal_orders.unsent.as_json(:only => [:id, :keyword, :args, :created_at]),
        :update_providers => remote_timestamp.blank? || local_timestamp.to_i > remote_timestamp.to_i, # to drop microseconds
        :last_session_started_at => @terminal.last_session_started_at
      }

      render :json => response
    rescue ActiveRecord::RecordInvalid
      render :text => nil, :status => 400
    end
  end

  def providers
    profile = @terminal.terminal_profile

    providers = nil
    profile.cached_providers_lock.lock do
      providers = profile.cached_providers.value

      if providers.nil?
        ActiveRecord::Base.transaction do
          providers = {
            :providers  => profile.providers_dump,
            :groups     => profile.provider_groups_dump,
            :promotions => profile.promotions_dump,
            :updated_at => profile.actual_timestamp
          }
        end

        providers = ActiveSupport::Gzip.compress(ActiveSupport::JSON.encode(providers))
        profile.cached_providers.value = providers
      end
    end

    send_data providers, :type => 'application/gzip', :disposition => 'inline'
  end
end
