class SalesWorker
  include Sidekiq::Worker
  def perform(chunk)

    #group = Spree::SaleGroup.find(group_id)

    ActiveRecord::Base.transaction do
      chunk.each do |row|

        product = Spree::Product.ransack({product_code_eq: row['product_id']}).result(distinct: true).first

        if product
          puts "#############################"
          puts row.inspect
          puts "#############################"
          if row['sale_type'] && row['sale_type'] == 'percent' && row['sale_price'] < 1
            @sale_price = product.put_on_sale row['sale_price'], { calculator_type: Spree::Calculator::PercentOffSalePriceCalculator.new }
          else
            @sale_price = product.put_on_sale row['sale_price']
          end
          #group.sale_prices << @sale_price
        else
          puts row.inspect
        end

      end

    end
  end
end