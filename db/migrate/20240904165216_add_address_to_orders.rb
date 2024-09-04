class AddAddressToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :use_contact_order, :boolean, default: true, after: :contact_id
    add_column :orders, :endereco, :string, after: :use_contact_order
    add_column :orders, :numero, :string, after: :endereco
    add_column :orders, :complemento, :string, after: :numero
    add_column :orders, :bairro, :string, after: :complemento
    add_column :orders, :cep, :string, after: :bairro
    add_column :orders, :uf, :string, after: :cep
  end
end
