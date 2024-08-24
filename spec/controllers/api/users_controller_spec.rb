require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it 'returns all users in JSON format' do
      user = User.create!(
        email: 'test@example.com',
        phone_number: '1234567890',
        full_name: 'Test User',
        password: 'securepassword',
        metadata: 'metadata'
      )
      get :index
      expect(JSON.parse(response.body)).to include({
        "users" => [{
          "email" => user.email,
          "phone_number" => user.phone_number,
          "full_name" => user.full_name,
          "key" => user.key,
          "account_key" => user.account_key,
          "metadata" => user.metadata
        }]
      })
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        expect {
          post :create, params: {
            user: {
              email: 'test@example.com',
              phone_number: '1234567890',
              full_name: 'Test User',
              password: 'securepassword',
              metadata: 'metadata'
            }
          }
        }.to change(User, :count).by(1)
      end

      it 'returns a JSON response with the new user' do
        post :create, params: {
          user: {
            email: 'test@example.com',
            phone_number: '1234567890',
            full_name: 'Test User',
            password: 'securepassword',
            metadata: 'metadata'
          }
        }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with invalid params' do
      it 'returns a JSON response with errors for the new user' do
        post :create, params: { user: { email: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("errors")
      end
    end
  end
end
