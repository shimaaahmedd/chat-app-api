class ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat, only: [:show, :update, :destroy]

  # GET /applications/[application_app_token]/chats
  def index
    @chats = @application.chats
    return render json: { message: "No chats in this application" }, status: :forbidden if @chats == []
    render json: @chats
  end

  # GET /applications/hydhhNQx2rMLei7UgJRTPLCH/chats/[number]
  def show
    render json: @chat
  end

  # POST /applications/[application_app_token]/chats
  def create
    @chat = Chat.new
    @chat.application = @application
    @chat.number = @application.chats_count + 1
    @chat.messages_count = 0

    if @chat.save
      @application.update(chats_count: @chat.number)
      render json: @chat, status: :created, location: "application_#{@chat}"
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /applications/[application_app_token]/chats/[number]
  def update
    if @chat.update(chat_params)
      render json: @chat
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      @chat = @application.chats.where(number: params[:id])
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
end
