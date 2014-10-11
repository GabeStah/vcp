class CreateAssignment < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.references :role, null: false
      t.references :user, null: false
    end

    add_index :assignments, [:role_id, :user_id], unique: true
  end
end
