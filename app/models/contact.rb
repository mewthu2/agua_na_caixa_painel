class Contact < ApplicationRecord
  enum origin: [:primeiros_passos, :agua_na_caixa]
  enum segment: [:food,
                 :varejo,
                 :corporativo,
                 :eventos,
                 :farma,
                 :conveniência,
                 :hotel,
                 :distribuidores]

  # Callbacks
  after_commit :enqueue_update_tiny_contact_job, on: [:create, :update]

  # Associações
  belongs_to :order_payment_type, optional: true
  # Validações

  # Escopos
  add_scope :search do |value|
    where('contacts.origin LIKE :valor OR
         contacts.codigo LIKE :valor OR
         contacts.nome LIKE :valor OR
         contacts.fantasia LIKE :valor OR
         contacts.tipo_pessoa LIKE :valor OR
         contacts.cpf_cnpj LIKE :valor OR
         contacts.endereco LIKE :valor OR
         contacts.numero LIKE :valor OR
         contacts.complemento LIKE :valor OR
         contacts.bairro LIKE :valor OR
         contacts.cep LIKE :valor OR
         contacts.cidade LIKE :valor OR
         contacts.uf LIKE :valor OR
         contacts.email LIKE :valor OR
         contacts.fone LIKE :valor OR
         contacts.id_lista_preco LIKE :valor OR
         contacts.id_vendedor LIKE :valor OR
         contacts.nome_vendedor LIKE :valor OR
         contacts.situacao LIKE :valor OR
         contacts.data_criacao LIKE :valor OR
         contacts.id LIKE :valor', valor: "%#{value}%")
  end

  # Métodos privados
  private

  def enqueue_update_tiny_contact_job
    UpdateTinyContactJob.perform_later(self)
  end
end
