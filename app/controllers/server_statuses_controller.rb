class ServerStatusesController < ApplicationController
  def show
    @server_status = RequestTshockApi.server_status(Settings.tshock.api_hosts[params[:id].to_i])
    render partial: 'show'
  end
end
