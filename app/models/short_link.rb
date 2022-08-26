class ShortLink < ApplicationRecord

    URL_REGEX = /(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})/i
    validates :long_link, presence: true, format: { with: URL_REGEX }
    validates :user_id, presence: true, uniqueness: { scope: :long_link }

    def encoded_id
        self.id.to_s(36)
    end

    def self.decoded_id(id)
        id.to_i(36)
    end

    def self.find_by_encoded_id(encoded_id)
        ShortLink.find(encoded_id.to_i(36))
    end

    def increase_accesses
        update(accesses: accesses + 1)
    end
end
