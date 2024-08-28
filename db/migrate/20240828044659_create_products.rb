class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.bigint :origin
      t.references :contact, foreign_key: true, after: :id
      t.datetime :data_criacao
      t.string :nome
      t.string :codigo
      t.decimal :preco, precision: 10, scale: 2, default: 0
      t.decimal :preco_promocional, precision: 10, scale: 2, default: 0
      t.string :unidade
      t.string :gtin
      t.string :tipoVariacao
      t.string :localizacao
      t.decimal :preco_custo, precision: 10, scale: 2, default: 0
      t.decimal :preco_custo_medio, precision: 10, scale: 2, default: 0
      t.string :situacao

      t.timestamps
    end
  end
end
