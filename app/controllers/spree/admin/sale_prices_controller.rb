module Spree
  module Admin
    class SalePricesController < BaseController

      before_filter :load_product, :except => [:import]

      respond_to :js, :html

      def index
        @sale_prices = @product.sale_prices
      end

      def create
        @sale_price = @product.put_on_sale params[:sale_price][:value], sale_price_params
        respond_with(@sale_price)
      end

      def import

        error = false

        session[:return_to] ||= request.referer

        file = params[:spree_sales_file].tempfile

        if File.extname(file.path) != ".csv"
          error = "Mauvais type de fichier: "+File.extname(file.path)
        end

        #Dir.glob("*").max_by{|f| /^(.+?)_/.match(File.basename(f)).captures[0]}
        if error.blank?
          begin
            #group = Spree::SaleGroup.create(number: DateTime.now, name: params[:spree_sales_file].original_filename)

            SmarterCSV.process(file.path, {:col_sep => ';', :chunk_size => 100}) do |chunk|
              #SalesWorker.perform_async(chunk, group.id)
              SalesWorker.perform_async(chunk)
            end

          rescue Redis::CannotConnectError
            group.delete
            error = "Une erreur de connection est survenue"
          rescue StandardError
            error = "Une erreur inconnue est survenue"
          end
        end

        if error.nil?
          flash[:error] = error
        else
          flash[:notice] = "Opération effectuée avec succès."
        end
        if session[:return_to]
          redirect_to session.delete(:return_to)
        else
          redirect_to("/admin")
        end
      end

      def destroy
        @sale_price = Spree::SalePrice.find(params[:id])
        @sale_price.destroy
        respond_with(@sale_price)
      end

      def disable
        @product.disable_sale
        flash[:success] = "Le solde a été désactivé"
        redirect_to admin_product_sale_prices_path
      end

      def enable
        @product.enable_sale
        flash[:success] = "Le solde a été activé"
        redirect_to admin_product_sale_prices_path
      end

      private

      def load_product
        @product = Spree::Product.find_by(slug: params[:product_id])
        redirect_to request.referer unless @product.present?
      end

      def sale_price_params
        params.require(:sale_price).permit(
            :id,
            :value,
            :currency,
            :start_at,
            :end_at,
            :enabled
        )
      end

    end
  end
end

