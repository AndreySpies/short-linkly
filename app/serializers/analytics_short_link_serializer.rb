class AnalyticsShortLinkSerializer < ActiveModel::Serializer
    attributes :long_link, :short_link, :accesses

    def short_link
      object.get_short_link(@instance_options[:url])
    end
  end
  