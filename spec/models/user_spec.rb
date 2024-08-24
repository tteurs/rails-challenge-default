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
end
