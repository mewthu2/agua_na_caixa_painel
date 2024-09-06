class OrderProductsPresenter < SimpleDelegator
  def badges_for_order_products
    order_products.map do |order_product|
      badge_for_order_product(order_product)
    end.join.html_safe
  end

  private

  def badge_for_order_product(order_product)
    product_name = order_product.product.nome
    quantity = order_product.quantidade
    "<span class='badge badge-primary'>#{quantity} x #{product_name}</span>"
  end
end
