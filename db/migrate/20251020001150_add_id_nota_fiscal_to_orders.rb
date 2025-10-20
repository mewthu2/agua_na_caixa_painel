class AddIdNotaFiscalToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :id_nota_fiscal, :integer
    add_index :orders, :id_nota_fiscal
  end
end
