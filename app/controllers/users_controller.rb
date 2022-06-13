class UsersController < ApplicationController
  skip_before_action :authenticate, only: [:create]
  before_action :set_user, only: [:show]


  # GET /users
  def index
    @users = User.all
    render json: @users.to_json(only: [:email, :first_name, :second_name])
  end

  # GET /users/1
  def show
    render json:
    {
        email: @user_to_show.email,
        first_name: @user_to_show.first_name,
        second_name: @user_to_show.second_name,
    }
  end

  # POST /register
  def create
    @user = User.new(user_params)
    if @user.save
      payload = { user_id: @user.id}
      token = create_token(payload)
      render json: 
       {
          email: @user.email,
          first_name: @user.first_name,
          second_name: @user.second_name,
          token: token
       }, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PUT /update
  def update
    if @user.update(user_params)
      render json: {
        email: @user.email,
        first_name: @user.first_name,
        second_name: @user.second_name,
     }
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /delete
  def destroy
    @user.destroy
    redirect_to logout_path
  end

  # GET /my_chats
  def my_chats
    return render json: { message: "You have no chats" }, status: :forbidden if @user.chats.empty?
    return render json:  @user.chats.to_json(include: {application: {only: [:token, :name]}}, only: [:number, :messages_count])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      return render json: { message: "No user found with this ID" }, status: :forbidden unless User.exists?(params[:id])
      @user_to_show = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:first_name, :second_name, :email, :password, :password_confirmation)
    end
end
