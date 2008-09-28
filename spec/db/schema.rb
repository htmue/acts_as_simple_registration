ActiveRecord::Schema.define(:version => 0) do
  create_table :sreg_users, :force => true do |t|
    t.string :name, :email
    t.timestamps
  end
end
