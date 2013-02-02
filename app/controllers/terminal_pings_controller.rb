class TerminalPingsController < ApplicationController
  before_filter :authenticate_terminal

  def create
    begin
      ping_data = params[:terminal_ping]
      providers = ping_data[:providers]

      remote_timestamp = providers[:updated_at].blank? ? nil : DateTime.parse(providers[:updated_at])
      local_timestamp  = [
        Provider.timestamp.value || DateTime.civil(0, 1, 1),
        ProviderGroup.timestamp.value || DateTime.civil(0, 1, 1),
        TerminalProfilePromotion.timestamp.value || DateTime.civil(0, 1, 1)
      ].max

      @terminal.ping!(TerminalPing.new ping_data)

      response = {
        :time => DateTime.now,
        :profile => {
          :support_phone => @terminal.terminal_profile.support_phone,
          :logo          => @terminal.terminal_profile.logo.url,
          :modified_at   => @terminal.terminal_profile.updated_at
        },
        :orders => @terminal.terminal_orders.unsent.as_json(:only => [:id, :keyword, :args, :created_at]),
        :providers => {}
      }

      unless providers[:ids].blank?
        response[:providers][:remove] = providers[:ids].map{|x| x.to_s} - Provider.rmap.values
      end

      if remote_timestamp.blank? || local_timestamp > remote_timestamp
        response[:providers][:update] = @terminal.providers_dump remote_timestamp
        response[:providers][:groups] = @terminal.provider_groups_dump
        response[:providers][:promotions] = @terminal.promotions_dump
        response[:providers][:updated_at] = local_timestamp.strftime('%Y-%m-%dT%H:%M:%S.%9N%z')
      end

      render :json => response
    rescue ActiveRecord::RecordInvalid
      render :text => nil, :status => 400
    end
  end
end