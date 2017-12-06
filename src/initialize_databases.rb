require 'sequel'

DB = Sequel.sqlite('src/bin/jadebot.db')

unless DB.table_exists?(:levels)
  DB.create_table :levels do
    integer 	:user_id
    integer		:server_id
    integer 	:level
    integer		:xp
    integer		:to_next_level
    primary_key %i[user_id server_id], name: :server_user_id
  end
end
