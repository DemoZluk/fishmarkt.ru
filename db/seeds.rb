#encoding:utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

def main
  # open_file
  # create_groups
  # create_properties
  # create_products_and_values
  # setup_prices
  add_values_to_values
end

def open_file
  import = File.read('xml/import.xml')
  @doc = Nokogiri::XML(import)
end

def create_groups
  p 'Creating groups'

  groups = @doc.xpath('//Группы/descendant::Группа')
  groups_progress = ProgressBar.create(total: groups.size, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
  groups.each do |g|
    parent = g.xpath('ancestor::Группа').last
    group_id = g.at_css('>Ид').content
    if parent
      parent_id = parent.at_css('>Ид').content
    else
      parent_id = ''
    end
    title = g.at_css('>Наименование').content
    permalink = title.mb_chars.parameterize('_') #.gsub(/[^-\wа-яА-ЯёЁ]+/i, ' ').squish.gsub(/\s+/, '_')
    Group.create(
      id: group_id,
      title: title,
      parent_id: parent_id,
      permalink: permalink
    )
    groups_progress.increment
  end

  p 'End'
end

def create_properties
  p 'Creating Properties'

  props = @doc.css('Свойство')
  props_progress = ProgressBar.create(total: props.size, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
  props.each do |p|
    id = p.at_css('Ид').content
    title = p.at_css('Наименование').content
    Property.create(
      property_id: id,
      title: title
    )

    p.css('ВариантыЗначений>Справочник').each do |v|
      Value.create(
        value_id: v.at_css('ИдЗначения').content,
        title: v.at_css('Значение').content,
        property_id: id
      )
    end
    props_progress.increment
  end

  p 'End'  
end

def create_products_and_values
  p 'Creating Products and Values'

  prods = @doc.css('Товар')
  prods_progress = ProgressBar.create(total: prods.size, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
  prods.each do |product|
    product_title = product.at_css('>Наименование').content
    permalink = product_title.mb_chars.parameterize('_') #.gsub(/[^-\wа-яА-ЯёЁ]+/i, ' ').squish.gsub(/\s+/, '_')

    if Product.find_by permalink: permalink
      prods_progress.log 'Товар ' + product_title + ' уже существует.'
    else
      item_id = product.at_css('>Ид').content

      Product.create!(
        item: product.at_css('>Артикул').content,
        title: product_title,
        long_name: product.at_xpath("ЗначенияРеквизитов/ЗначениеРеквизита[Наименование='Полное наименование']/Значение").content,
        description: product.at_css('>Описание').inner_html,
        producer: product.at_css('>Изготовитель>Наименование').content,
        item_id: item_id,
        price: 0,
        unit: product.at_css('>БазоваяЕдиница').content,
        group_id: product.at_css('>Группы>Ид').content,
        permalink: permalink,
        rating: 0
      )

      product.css('ЗначенияСвойства').each do |p|
        ProductPropertyValue.create(
          product_id: Product.find_by(item_id: item_id).id,
          property_id: Property.find_by(property_id: p.at_css('Ид').content).id,
          value_id: Value.find_by(value_id: p.at_css('Значение').content).try(:id),
          value: ((val.title.match(/^\d+(.\d+)?$/)) ? title[0].to_f : nil)
        )

      #prods_progress.log 'Продукт ' + product_title + 'и его свойства добавлены в базу.'
      end

      product.css('Картинка').each do |img|
        Image.create(
          url: img.content,
          item_id: product.at_css('>Ид').content
        )
      end
    end

    prods_progress.increment
  end

  p 'End'
end

def setup_prices
  p 'Setting prices'

  offers = File.read('xml/offers.xml')
  prices = Nokogiri::XML(offers).css('Предложение')
  prices_progress = ProgressBar.create(total: prices.size, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
  prices.each do |offer|
    if product = Product.find_by(item_id: offer.at_css('Ид').content)
      price = offer.at_css('ЦенаЗаЕдиницу').content
      product.price = price.to_f
      # p product.title + ' price: ' + price
      product.save
    else
      prices_progress.log 'Product ' + offer.at_css('Наименование').content + ' not found'
    end
    prices_progress.increment
  end

  p 'End'
end


def add_values_to_values
  p 'Populating value attribute'

  values_progress = ProgressBar.create(total: Value.all.size, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
  Value.all.each do |val|
    title = val.title.split(' ')
    val.update value: (val.title.match(/^\d+(.\d+)?$/)) ? title[0].to_f : nil
    values_progress.increment
  end

  p 'End'
end

main
