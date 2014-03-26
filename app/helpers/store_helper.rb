#encoding:utf-8
module StoreHelper
  def image_thumb_helper(product)

    thumb_format = 'png'
    thumb_size = '135x135'


    group = Group.find(product.group_id)

    path = group.title
    while parent = group.parent
      path = parent.title + '/' + path
      group = parent
    end

    thumb_path = ActiveSupport::Inflector.transliterate('app/assets/images/groups/' + path + '/thumbnails/').gsub(/\s+/, '_')

    if Dir.glob(thumb_path + product.permalink + "_thumb*").count < product.images.count
      product.images.each_with_index do |image, i|
        FileUtils.mkdir_p(thumb_path) unless File.directory?(thumb_path)

        img = MiniMagick::Image.open('app/assets/images/' + image.url)
        img.resize thumb_size
        img.format thumb_format
        img_path = "%s%s_thumb_%02d.%s" % [thumb_path, product.permalink, i+1, thumb_format]
        img.write img_path
      end
    end
  end

  def list_item_for param, item, cnt, dsb = nil
    checked = params[param].try(:index, item) || dsb
    title = item.try(:title) || item
    li = content_tag :li do
      check_box_tag("#{param}[]", (item.try(:id) || item), checked, {multiple: true, id: title.parameterize, disabled: dsb, autocomplete: 'off'}) + 
      label_tag(title.parameterize, title) + 
      content_tag(:span, " (#{cnt})", class: 'count')
    end
  end

  def create_thumbnail
    system("");
  end

  def numeric? array
    array.map{|v| v.value.to_f}.compact
  end
end