class User < ApplicationRecord
  before_validation :generate_key, on: :create

  validates :email, presence: true, uniqueness: true, length: { maximum: 200 }
  validates :phone_number, presence: true, uniqueness: true, length: { maximum: 20 }
  validates :password, presence: true, length: { maximum: 100 }
  validates :key, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :account_key, uniqueness: true, length: { maximum: 100 }, allow_nil: true
  validates :metadata, length: { maximum: 2000 }, allow_nil: true

  before_create :generate_key, :hash_password

  private

  def generate_key
    self.key = SecureRandom.hex(32)
  end

  def hash_password
    self.password = BCrypt::Password.create(self.password)
  end
end
