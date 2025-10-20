class AddInvoiceFieldsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :xml_nota_fiscal, :text
  end
end
