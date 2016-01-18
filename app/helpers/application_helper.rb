module ApplicationHelper

  def my_taxons_tree(root_taxon, current_taxon, max_level = 1)
    return '' if max_level < 1 || root_taxon.children.empty?
    content_tag :ul, :class => 'taxons-list' do
      root_taxon.children.except(:order).order(:name).map do |taxon|
        css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? 'current' : nil
        content_tag :li, :class => css_class do
         link_to(taxon.name, seo_url(taxon)) +
         taxons_tree(taxon, current_taxon, max_level - 1)
        end
      end.join("\n").html_safe
    end
  end

  def restaurant_logo_url(taxon)
    image_url("restaurants/#{taxon.name.parameterize}-logo.png")
  end

  def restaurant_photo_url(taxon)
    image_url("restaurants/#{taxon.name.parameterize}-photo.png")
  end

  def chef_photo_url(taxon)
    image_url("chefs/#{taxon.name.parameterize}-photo.png")
  end

  def support_email_link(subject="Help!")
    mail_to support_email_address, nil, subject: subject, target: "_blank", class: "text-nowrap"
  end

  def support_phone_link
    link_to support_phone_number, support_phone_tel, target: "_blank", class: "text-nowrap"
  end

  def support_email_address
    Rails.application.config.x.support_email_address
  end

  def support_phone_number
    Rails.application.config.x.support_phone_number
  end

  def support_phone_tel
    "tel:+1#{support_phone_number.remove('-')}"
  end
end
