class AddNewFieldToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :segment, :bigint, after: :origin
    add_column :contacts, :nome_responsavel_tel, :string, after: :nome_vendedor
    add_column :contacts, :email_nota_fiscal, :string, after: :email
  end
end
