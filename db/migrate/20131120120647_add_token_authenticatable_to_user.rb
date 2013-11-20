class AddTokenAuthenticatableToUser < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      t.string :authentication_token
    end
  end
end
