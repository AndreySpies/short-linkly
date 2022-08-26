class NewShortLinkSerializer < ActiveModel::Serializer
  attributes :long_link, :short_link
  
  def short_link
    object.get_short_link(@instance_options[:url])
  end
end
