module Api
  class UsersController < ApplicationController
    ALLOWED_FILTERS = %w[email full_name metadata].freeze

    def index
      if (filter_params.keys - ALLOWED_FILTERS).any?
        render json: { errors: ['Invalid parameter'] }, status: :unprocessable_entity
      else
        @users = User.all.order(created_at: :desc)
        filter_params.each do |key, value|
          @users = @users.where("#{key} ILIKE ?", "%#{value}%") if ALLOWED_FILTERS.include?(key)
        end
        render json: { users: @users }, status: :ok
      end
    rescue => e
      render json: { errors: [e.message] }, status: :unprocessable_entity
    end

    def create
      @user = User.new(user_params)
      if @user.save
        AccountKeyJob.perform_later(@user.id)
        render json: @user, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :phone_number, :full_name, :password, :metadata)
    end

    def filter_params
      params.permit(:email, :full_name, :metadata)
    end
  end
end
