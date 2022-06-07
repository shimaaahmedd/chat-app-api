class MessagesController < ApplicationController
  before_action :set_application, :set_chat
  before_action :set_message, only: [:show, :update, :destroy]

  # GET /applications/[application_app_token]/chats/[chat_number]/messages
  def index
    messages = @chat.messages
    return render json: { message: "No messages in this application" }, status: :forbidden if messages == []
    render json: messages.to_json(include: {user: {only: [:first_name, :second_name]}}, only: [:body, :number])
  end

  # GET /applications/[application_app_token]/chats/[chat_number]/messages/[number]
  def show
    render json: @message.to_json(include: {user: {only: [:first_name, :second_name]}}, only: [:body, :number])
  end

  # POST /applications/[application_app_token]/chats/[chat_number]/messages
  def create
    MessageWorkerJob.perform_async(@application.id, @chat.id, message_params[:body], @user.id)
  end

  # PUT /applications/[application_app_token]/chats/[chat_number]/messages/[number]
  def update
    if @message.update(body: message_params[:body])
      render json: @message.to_json(include: {user: {only: [:first_name, :second_name]}}, only: [:body, :number])
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /applications/[application_app_token]/chats/[chat_number]/messages/[number]
  def destroy
    message_number = @message.take.number
    @message.take.destroy
    @chat.messages.where("number > #{message_number}").update_all("number = number - 1")
    @chat.decrement(:messages_count)
    @chat.save
    return render json: { message: "Message deleted successfully" }
  end

  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      return render json: { message: "No Application found with this token" }, status: :forbidden unless Application.exists?(token: params["application_app_token"])
      @application = Application.find_by(token: params["application_app_token"])
    end

    def set_chat
      @chat = @application.chats.where(number: params[:chat_number])
      return render json: { message: "No chat in this application with this number" }, status: :forbidden unless @chat.exists?
      @chat =  @chat.take
    end

    def set_message
      @message = @chat.messages.where(number: params[:number])
      return render json: { message: "No message in this chat with this number" }, status: :forbidden unless @message.exists?

    end

    # Only allow a trusted parameter "white list" through.
    def message_params
      params.require(:message).permit(:body)
    end
end
