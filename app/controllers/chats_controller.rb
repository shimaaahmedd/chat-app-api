class ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat, only: [:show, :update, :destroy]

  # GET /chats
  def index
    @chats = Chat.where(application: @application)

    render json: @chats
  end

  # GET /chats/1
  def show
    render json: @chat
  end

  # POST /chats
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

  # PATCH/PUT /chats/1
  def update
    if @chat.update(chat_params)
      render json: @chat
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # DELETE /chats/1
  def destroy
    @chat.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      @chat = Chat.where("number = ? AND application_id = ?", params[:id], @application)
    end

    def set_application
      @application = Application.find_by(token: params["application_app_token"])
    end

    # Only allow a trusted parameter "white list" through.
    def chat_params
      params.require(:chat).permit(:number, :messages_count, :application_id)
    end
end
