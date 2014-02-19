Spree::Variant.class_eval do
  has_many :sale_prices

  attr_accessible :sale_price, :on_sale
  # TODO also accept a class reference for calculator type instead of only a string
  def put_on_sale(value, calculator_type = "Spree::Calculator::DollarAmountSalePriceCalculator", start_at = Time.now, end_at = nil, enabled = true)
    sale_price = sale_prices.new({ value: value, start_at: start_at, end_at: end_at, enabled: enabled })
    sale_price.calculator_type = calculator_type
    sale_price.save
  end
  alias :create_sale :put_on_sale

  # TODO make update_sale method

  def active_sale
    on_sale? ? sale_prices.active.order("created_at DESC").first : nil
  end
  def current_sale
    has_sale_price? ? sale_prices.current.order("created_at DESC").first : nil
  end

  def next_active_sale
    sale_prices.present? ? sale_prices.order("created_at DESC").first : nil
  end
  alias :next_current_sale :next_active_sale

  def sale_price
    has_sale_price? ? current_sale.price : nil
  end

  def sale_price=(value)
    if value.to_f > 0
      if updateable_active_sale = active_sale
        updateable_active_sale.value = value
        updateable_active_sale.save
      else
        put_on_sale(value)
      end
    end
  end

  def on_sale
    active_sale.enabled if active_sale
  end

  def on_sale=(checked)
    disable_sale
    if checked.to_i == 1
      enable_sale
    end
  end

  def on_sale?
    sale_prices.active.present?
  end

  def has_sale_price?
    sale_prices.first.present?
  end

  def original_price
    self[:price]
  end

  # def price
  #   on_sale? ? sale_price : original_price
  # end

  def enable_sale
    return nil unless next_active_sale.present?
    next_active_sale.enable
  end

  def disable_sale
    return nil unless active_sale.present?
    active_sale.disable
  end

  def start_sale(end_time = nil)
    return nil unless next_active_sale.present?
    next_active_sale.start(end_time)
  end

  def stop_sale
    return nil unless active_sale.present?
    active_sale.stop
  end
end