class Order < ApplicationRecord
  enum destiny: [:primeiros_passos, :agua_na_caixa]

  after_commit :calculate_destiny, on: [:create, :update]
  before_save :add_receiving_time_to_observation

  belongs_to :contact
  belongs_to :user
  has_many :order_products, dependent: :destroy
  has_many :order_payments, dependent: :destroy

  accepts_nested_attributes_for :order_products, allow_destroy: true
  accepts_nested_attributes_for :order_payments, allow_destroy: true

  validates :receiving_time, presence: { message: 'O horário de recebimento é obrigatório' }

  add_scope :search do |value|
    if Order.destinies.key?(value)
      where(destiny: value)
    else
      none
    end
  end

  def calculate_destiny
    case use_contact_order
    when true
      update_column(:destiny, contact&.uf == 'SP' ? :agua_na_caixa : :primeiros_passos)
    when false
      update_column(:destiny, uf == 'SP' ? :agua_na_caixa : :primeiros_passos)
    end
  end

  private

  def add_receiving_time_to_observation
    return if receiving_time.blank?

    formatted_time = receiving_time.strftime('%H:%M')
    time_text = "Horário de recebimento: #{formatted_time}"

    case observation
    when nil, ''
      self.observation = time_text
    when /Horário de recebimento: \d{2}:\d{2}/
      self.observation = observation.sub(/Horário de recebimento: \d{2}:\d{2}/, time_text)
    else
      self.observation = "#{time_text}\n\n#{observation}"
    end
  end
end
