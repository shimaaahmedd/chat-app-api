class ApplicationController < ActionController::API

    before_action :authenticate

    def authenticate
        return render json: { message: "No Authorization header sent" }, status: :forbidden unless request.headers["Authorization"]
        auth_header = request.headers["Authorization"]
        decoded_token = JWT.decode(token(auth_header), secret)
        payload = decoded_token.first 
        user_id = payload["user_id"]
        return render json: { message: "No user found with this token" }, status: :forbidden unless User.exists?(user_id)
        return render json: { message: "Authorization token isn't correct" }, status: :forbidden unless user_id
        @user = User.find(user_id)
        
    end

    def secret 
        secret = ENV['SECRET_KEY_BASE'] || Rails.application.secrets.secret_key_base
    end

    def token(auth_header)
        auth_header.split(" ")[1]
    end

    def create_token(payload)
        JWT.encode(payload, secret)
    end
end
