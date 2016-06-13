class SalesWorker
  include Sidekiq::Worker
  def perform(chunk)

    #group = Spree::SaleGroup.find(group_id)

    ActiveRecord::Base.transaction do
      chunk.each do |row|

        product = Spree::Product.ransack({product_code_eq: row['product_id']}).result(distinct: true)

        if product
          product.each do |p|
            if row['sale_price'].to_f > 1 && row['start_date'] && row['product_id']
              @sale_price = p.put_on_sale row['sale_price'], { start_at: row['start_date'], end_at: row['end_date']}
            end
          end
        else
          puts row.inspect
        end

      end

    end
  end
end

