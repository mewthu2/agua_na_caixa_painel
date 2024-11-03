class Attempt < ApplicationRecord
  enum status: [:fail, :error, :success]
  enum kinds: [:create_order_primeiros_passos, 
               :create_order_agua_na_caixa, 
               :update_contact_primeiros_passos, 
               :update_contact_agua_na_caixa]
  # Callbacks
  # Associacoes

  # Validacoes

  # Escopos
  add_scope :search do |value|
    where('attempts.tiny_order_id LIKE :valor OR
           attempts.error LIKE :valor OR
           attempts.message LIKE :valor OR
           attempts.id LIKE :valor', valor: "#{value}%")
  end
  # Metodos estaticos
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
