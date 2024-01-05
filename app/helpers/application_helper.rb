module ApplicationHelper
include Pagy::Frontend
    def pdf_image_tag(image, options = {})
        options[:src] = File.expand_path(Rails.root) + '/app/assets/images/' + image
        tag(:img, options)
    end
end
