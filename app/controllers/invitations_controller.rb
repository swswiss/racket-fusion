class InvitationsController < ApplicationController
	before_action :authenticate_user!
    before_action :authenticate_blocked

    def index
        if false
            @tournaments_double = Tournament.where(double: true, status: true)
            @registrations_current_user = current_user.registrations.where(double: true)
            @registrations_from_user= Registration.where(teammate_id: current_user.id, double: true)
        end
    end
    def receive_data
        data = "pulaaa"
        # Process the received data as needed
        render json: { status: 'success' }
    end
    
end