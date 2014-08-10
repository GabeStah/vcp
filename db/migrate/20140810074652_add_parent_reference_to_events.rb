class AddParentReferenceToEvents < ActiveRecord::Migration
  def change
    add_reference :events, :parent
  end
end
