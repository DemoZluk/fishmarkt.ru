module CurrentSettings
  extend ActiveSupport::Concern

  included do
  end

  def change_user_prefs
    # Create user preferences in session if undefined
    session[:user] ||= Hash[:prefs, {per_page: 10, order_by: 'title'}].with_indifferent_access unless session && session[:user] && session[:user][:prefs]

    session[:user][:prefs].delete_if{|key, val| val.blank?} if session[:user][:prefs] = user_prefs.presence

    # Update user preferences
    @per_page = session[:user][:prefs][:per_page] ||= 10
    @order_by = session[:user][:prefs][:order_by] ||= 'title'
    @desc = session[:user][:prefs][:descending].presence
    @order_by = @order_by + ' DESC' if @desc
  end

  # Define product list for current group
  # if group is present, else list all products
  def current_list_of products
    prod = filter products
    @products = prod.page(params[:page]).per(@per_page)
    # redirect_to store_path, notice: 'No results' if @products.empty?
  end

  def filter products

    set_min_max_price_for products
    min = @min_price
    max = @max_price
    products = products.where{(price >= min) & (price <= max)}

    if producers = params[:producer]
      products = products.where{producer >> producers}
    end

    if filters = params[:property]
      # products = products.where{item_id >> (.where{value.id >> filters})}
      #products = products.where{ item_id >> products.select }
      Value.uniq.where{id >> filters}.group_by{|value| value.property_id}.values.each do |vals|
        products = products.where{ item_id >> ProductPropertyValue.joins{value}.where{value.id >> vals} }
      end
      p products
      # products = products.where{item_id >> values.select{item_id}}
      # product_ids = ProductPropertyValue.uniq.with_indifferent_accesse{value_id >> filters}.pluck(:item_id)
      # filters.each do |f|
      #   products = products.where{product_property_values.value_id == f}
      # end
      # p '-----------------'
    end

    products
  end

  def set_min_max_price_for products
    param_min = params[:minPrice].to_i.abs
    param_max = params[:maxPrice].to_i.abs
    @products_min = products.minimum(:price).floor
    @products_max = products.maximum(:price).ceil
    @min_price = (param_min == 0) ? @products_min : ((param_min < @products_max) ? param_min : @products_max-1)
    @max_price = (param_max == 0) ? @products_max : ((param_max > @min_price) ? param_max : @min_price+1)
    @max_price = @min_price+1 if @max_price <= @min_price
  end

  private

    def user_prefs
      params.slice(:per_page, :order_by, :descending).presence || session[:user][:prefs]
    end
end