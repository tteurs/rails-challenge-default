require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  render_views

  describe 'GET #index' do
    it 'returns all users in JSON format' do
      user = User.create!(
        email: 'test@example.com',
        phone_number: '1234567890',
        full_name: 'Test User',
        password: 'securepassword',
        metadata: 'metadata'
      )
      get :index
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(JSON.parse(response.body)["users"].first["email"]).to eq(user.email)
    end

    it 'filters users by email' do
      User.create!(email: 'test1@example.com', phone_number: '1234567890', password: 'securepassword')
      User.create!(email: 'test2@example.com', phone_number: '0987654321', password: 'securepassword')
      get :index, params: { email: 'test1@example.com' }
      users = JSON.parse(response.body)["users"]
      expect(users.size).to eq(1)
      expect(users.first["email"]).to eq('test1@example.com')
    end

    it 'filters users by full_name' do
      User.create!(email: 'test1@example.com', phone_number: '1234567890', full_name: 'John Doe', password: 'securepassword')
      User.create!(email: 'test2@example.com', phone_number: '0987654321', full_name: 'Jane Doe', password: 'securepassword')
      get :index, params: { full_name: 'John Doe' }
      users = JSON.parse(response.body)["users"]
      expect(users.size).to eq(1)
      expect(users.first["full_name"]).to eq('John Doe')
    end

    it 'filters users by metadata' do
      User.create!(email: 'test1@example.com', phone_number: '1234567890', metadata: 'male', password: 'securepassword')
      User.create!(email: 'test2@example.com', phone_number: '0987654321', metadata: 'female', password: 'securepassword')
      get :index, params: { metadata: 'female' }
      users = JSON.parse(response.body)["users"]
      expect(users.size).to eq(1)
      expect(users.first["metadata"]).to eq('female')
    end

    it 'returns 422 if an invalid filter is used' do
      get :index, params: { cellphone: 'test' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to eq({"errors" => ["Invalid parameter"]})
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

      it 'triggers AccountKeyJob' do
        expect(AccountKeyJob).to receive(:perform_later)
        post :create, params: {
          user: {
            email: 'test@example.com',
            phone_number: '1234567890',
            full_name: 'Test User',
            password: 'securepassword',
            metadata: 'metadata'
          }
        }
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
