class Order < ApplicationRecord
  enum destiny: [:primeiros_passos, :agua_na_caixa]

  # Callbacks
  after_commit :calculate_destiny, on: [:create, :update]

  # Associacoes
  belongs_to :contact
  belongs_to :user
  has_many :order_products, dependent: :destroy
  has_many :order_payments, dependent: :destroy

  # Validacoes
  accepts_nested_attributes_for :order_products, allow_destroy: true
  accepts_nested_attributes_for :order_payments, allow_destroy: true
  # Escopos
  add_scope :search do |value|
    where('
      orders.destiny LIKE :value
    ', value: "%#{value}%")
  end

  # Metodos estaticos
  def calculate_destiny
    case use_contact_order
    when true
      update_column(:destiny, contact&.uf == 'SP' ? :agua_na_caixa : :primeiros_passos)
    when false
      update_column(:destiny, uf == 'SP' ? :agua_na_caixa : :primeiros_passos)
    end
  end
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
