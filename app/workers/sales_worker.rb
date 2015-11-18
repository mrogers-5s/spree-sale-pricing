class SalesWorker
  include Sidekiq::Worker
  def perform(chunk)

    ActiveRecord::Base.transaction do
      chunk.each do |row|

        puts"##########################################"
        puts "#{row.inspect}"
        puts"##########################################"

        product = Spree::Product.find_by(product_code: row['product_id'])

        if product
          puts"##########################################"
          puts product.inspect
          puts"##########################################"
          product.put_on_sale row['sale_price']
        else
          puts "PRODUCT NOT FOUND"
        end

      end

    end
  end
end