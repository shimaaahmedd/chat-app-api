class ApplicationsController < ApplicationController
  
  before_action :set_application, only: [:show, :update, :destroy]

  # GET /applications
  def index
    applications = Application.all
    render json: applications.to_json(only: [:token, :name, :chats_count])
  end

  # GET /applications/[application_token]
  def show
    render json: @application.to_json(only: [:token, :name, :chats_count])
  end

  # POST /applications
  def create
    @application = Application.new(application_params)
    @application.chats_count = 0

    if @application.save
      render json: @application.to_json(only: [:token, :name, :chats_count]), status: :created, location: @application
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /applications/[application_token]
  def update
    if @application.update(name: application_params[:name])
      render json: @application.to_json(only: [:token, :name, :chats_count])
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # DELETE /applications/[application_token]
  def destroy
    @application.destroy
    return render json: { message: "Application deleted successfully" }

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      return render json: { message: "No Application found with this token" }, status: :forbidden unless Application.exists?(token: params[:app_token])
      @application = Application.find_by(token: params[:app_token])
    end

    # Only allow a trusted parameter "white list" through.
    def application_params
      params.require(:application).permit(:name)
    end
end
