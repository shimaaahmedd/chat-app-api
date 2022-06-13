class ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat, :check_user, only: [:show, :update, :destroy, :search, :add_users]

  # GET /applications/[application_app_token]/chats
  def index
    chats = @application.chats
    return render json: { message: "No chats in this application" }, status: :forbidden if chats == []
    render json: chats.to_json(only: [:number, :messages_count])
  end

  # GET /applications/hydhhNQx2rMLei7UgJRTPLCH/chats/[number]
  def show
    render json: @chat.to_json(only: [:number, :messages_count])
  end

  # POST /applications/[application_app_token]/chats
  def create
    ChatWorkerJob.perform_async(@application.id, @user.id)
  end

  # PATCH/PUT /applications/[application_app_token]/chats/[number]
  def update
    if @chat.update(chat_params)
      render json: @chat.to_json(only: [:number, :messages_count])
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # DELETE /applications/[application_app_token]/chats/[number]
  def destroy
    chat_number = @chat.take.number
    @chat.take.destroy
    @application.chats.where("number > #{chat_number}").update_all("number = number - 1")
    @application.decrement(:chats_count)
    @application.save
    return render json: { message: "Chat deleted successfully" }
  end

  def search
    response = @chat.take.messages.search(params[:search_body]).records
    return render json: { message: "No records found" }, status: :forbidden if response.empty?
    return render json: response.to_json(only: [:number, :body])
  end

  def add_users
    return render json: { message: "No user found with this email" }, status: :forbidden unless User.exists?(email: params[:user_email])
    user = User.find_by(email: params[:user_email])
    return render json: { message: "User is already a member in this chat" }, status: :forbidden if @chat.take.users.exists?(user.id)
    @chat.take.users << user
    return render json: { message: "User added to chat successfully" }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      @chat = @application.chats.where(number: params[:number])
      return render json: { message: "No chat in this application with this number" }, status: :forbidden unless @chat.exists?
    end

    def set_application
      return render json: { message: "No Application found with this token" }, status: :forbidden unless Application.exists?(token: params["application_app_token"])
      @application = Application.find_by(token: params["application_app_token"])
    end

    # Only allow a trusted parameter "white list" through.
    def chat_params
      params.require(:chat).permit(:number, :messages_count, :application_id)
    end

    def check_user
      return render json: { message: "User cannot access this chat" }, status: :forbidden unless @chat.take.users.exists?(@user.id)
    end
end
