class AddSellerIdsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :seller_id_primeiros_passos, :integer, after: :profile_id
    add_column :users, :seller_id_agua_na_caixa, :integer, after: :seller_id_primeiros_passos
  end
end
