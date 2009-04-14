ActiveRecord::Schema.define(:version => 0) do
  create_table :people, :force => true do |t|
    t.string :type
    t.string :name
    t.text :data
  end
end
