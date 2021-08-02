class User < ApplicationRecord
  self.table_name = 'Users'
  establish_connection :tshock

  has_secure_password

  has_one :ts_character, foreign_key: 'Account'
  has_many :selling_items, dependent: :destroy
  has_many :bought_items, dependent: :destroy

  def id
    self['ID']
  end

  def password_digest
    self['Password']
  end

  def username
    self['Username']
  end
  alias name username

  def playing?
    RequestTshockApi.player_names.include?(self.name)
  end
end
