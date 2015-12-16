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
          if row['sale_price'] > 1 && row['start_date'] && row['product_id']
            @sale_price = product.put_on_sale row['sale_price'], { start_at: row['start_date'], end_at: row['end_date']}
          end
        else
          puts row.inspect
        end

      end

    end
  end
end

#$LAST
Spree::Product.find_each do |record|
  translation = record.translation_for(I18n.default_locale) || record.translations.build(:locale => I18n.default_locale)
    translation[:product_code] = record.read_attribute(:product_code, {:translated => false})
  translation.save!
end

all_translated_attributes = Spree::Product.all.collect{|m| m.attributes}

#FIRST
all_translated_attributes.each do |translated_record|
  # Create a hash containing the translated column names and their values.
  [:product_code].inject(fields_to_update={}) do |f, name|
    f.update({name.to_sym => translated_record[name.to_s]})
  end

  # Now, update the actual model's record with the hash.

  Spree::Product.where(:id => translated_record['id']).update_all(fields_to_update)

end