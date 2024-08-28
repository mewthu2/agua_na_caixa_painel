class CreateContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts do |t|
      t.bigint :origin
      t.string :codigo
      t.string :nome
      t.string :fantasia
      t.string :tipo_pessoa
      t.string :cpf_cnpj
      t.string :endereco
      t.string :numero
      t.string :complemento
      t.string :bairro
      t.string :cep
      t.string :cidade
      t.string :uf
      t.string :email
      t.string :fone
      t.integer :id_lista_preco
      t.integer :id_vendedor
      t.string :nome_vendedor
      t.string :situacao
      t.datetime :data_criacao

      t.timestamps
    end
  end
end
