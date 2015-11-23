class SalesWorker
  include Sidekiq::Worker
  def perform(chunk)

    #group = Spree::SaleGroup.find(group_id)

    ActiveRecord::Base.transaction do
      chunk.each do |row|

        product = Spree::Product.find_by(product_code: row['product_id'])

        if product
          if row['sale_type'] && row['sale_type'] == 'percent' && row['sale_price'] < 1
            @sale_price = product.put_on_sale row['sale_price'], "Spree::Calculator::PercentOffSalePriceCalculator"
          else
            @sale_price = product.put_on_sale row['sale_price']
          end

          #group.sale_prices << @sale_price
        else
          puts "PRODUCT NOT FOUND"
        end

      end

    end
  end
end