class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email,        :null => false, :unique => true
      t.string :first_name,   :null => false
      t.string :last_name,    :null => false
      t.string :kth_username, :null => false, :unique => true
      t.cas_authenticatable
      t.recoverable
      t.rememberable
      t.trackable

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
