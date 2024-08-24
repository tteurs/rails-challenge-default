require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    user = User.new(
      email: 'test@example.com',
      phone_number: '1234567890',
      full_name: 'Test User',
      password: 'securepassword',
      metadata: 'metadata'
    )
    expect(user).to be_valid
  end

  it 'is not valid without an email' do
    user = User.new(email: nil)
    expect(user).to_not be_valid
  end

  it 'is not valid without a phone_number' do
    user = User.new(phone_number: nil)
    expect(user).to_not be_valid
  end

  it 'is not valid without a password' do
    user = User.new(password: nil)
    expect(user).to_not be_valid
  end

  it 'is not valid if email is not unique' do
    User.create!(email: 'test@example.com', phone_number: '1234567890', password: 'securepassword')
    user = User.new(email: 'test@example.com', phone_number: '0987654321', password: 'securepassword')
    expect(user).to_not be_valid
  end

  it 'is not valid if phone_number is not unique' do
    User.create!(email: 'test1@example.com', phone_number: '1234567890', password: 'securepassword')
    user = User.new(email: 'test2@example.com', phone_number: '1234567890', password: 'securepassword')
    expect(user).to_not be_valid
  end

  it 'is not valid if key is not unique' do
    user1 = User.create!(email: 'test1@example.com', phone_number: '1234567890', password: 'securepassword', key: SecureRandom.hex(32))
    user2 = User.new(email: 'test2@example.com', phone_number: '0987654321', password: 'securepassword', key: user1.key)
    expect(user2).to_not be_valid
  end

  it 'generates a key before validation' do
    user = User.new(
      email: 'test@example.com',
      phone_number: '1234567890',
      full_name: 'Test User',
      password: 'securepassword',
      metadata: 'metadata'
    )
    user.valid?
    expect(user.key).to be_present
  end

  it 'is not valid if email exceeds maximum length' do
    user = User.new(email: 'a' * 201 + '@example.com', phone_number: '1234567890', password: 'securepassword')
    expect(user).to_not be_valid
  end

  it 'is not valid if phone_number exceeds maximum length' do
    user = User.new(email: 'test@example.com', phone_number: '1' * 21, password: 'securepassword')
    expect(user).to_not be_valid
  end

  it 'is not valid if password exceeds maximum length' do
    user = User.new(email: 'test@example.com', phone_number: '1234567890', password: 'a' * 101)
    expect(user).to_not be_valid
  end

  it 'is not valid if key exceeds maximum length' do
    user = User.new(email: 'test@example.com', phone_number: '1234567890', password: 'securepassword', key: 'a' * 101)
    expect(user).to_not be_valid
  end

  it 'is not valid if account_key exceeds maximum length' do
    user = User.new(email: 'test@example.com', phone_number: '1234567890', password: 'securepassword', account_key: 'a' * 101)
    expect(user).to_not be_valid
  end

  it 'is not valid if metadata exceeds maximum length' do
    user = User.new(email: 'test@example.com', phone_number: '1234567890', password: 'securepassword', metadata: 'a' * 2001)
    expect(user).to_not be_valid
  end
end
