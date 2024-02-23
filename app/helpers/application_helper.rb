module ApplicationHelper
include Pagy::Frontend
    def pdf_image_tag(image, options = {})
        options[:src] = File.expand_path(Rails.root) + '/app/assets/images/' + image
        tag(:img, options)
    end

    def custom_time_ago_in_words(time)
        if time >= 1.hour.ago
          "#{distance_of_time_in_words_to_now(time)} ago"
        elsif time.today?
          time.strftime("%I:%M %p")
        else
          time.strftime("%b %d, %Y")
        end
    end
end
