class CreateCharacters < ActiveRecord::Migration
  def change
    create_table :characters, options: "DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
      t.integer   :achievement_points
      t.integer   :gender
      t.integer   :level
      t.string    :portrait
      t.string    :name
      t.integer   :rank

      t.timestamps
    end

    add_reference :characters, :class, null: true
    add_reference :characters, :race,  null: true
  end
end
