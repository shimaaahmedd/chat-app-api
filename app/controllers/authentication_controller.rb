class AuthenticationController < ApplicationController
    skip_before_action :authenticate, only: [:login, :logout]

    # POST /login
    def login
        @user = User.find_by(email: params[:email])
        if @user
            if(@user.authenticate(params[:password]))
                payload = { user_id: @user.id }
                secret = ENV['SECRET_KEY_BASE'] || Rails.application.secrets.secret_key_base 
                token = create_token(payload)
                render json:
                {
                    email: @user.email,
                    first_name: @user.first_name,
                    second_name: @user.second_name,
                    token: token,
                }
                
            else
                render json: { message: "Authentication Failed"}
            end 
        else
            render json: { message: "Could not find user"}
        end
    end

    # GET /logout
    def logout
        request.headers["Authorization"] = ''
        render json: { message: "logged out"}
        @user = nil
    end
end
