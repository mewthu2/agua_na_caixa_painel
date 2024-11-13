class AddExistsOnTinyToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :exists_on_tiny, :boolean, after: :segment, default: false
  end
end
