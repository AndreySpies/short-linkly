class ShortLink < ApplicationRecord

    validates :long_link, presence: true, format: { with: URI.regexp }
    validates :user_id, presence: true, uniqueness: { scope: :long_link }

    def encoded_id
        self.id.to_s(36)
    end

    def self.decoded_id(id)
        id.to_i(36)
    end

    def get_short_link(base_url)
        "#{base_url}/#{encoded_id}"
    end

    def self.find_by_encoded_id(encoded_id)
       ShortLink.find_by_id(encoded_id.to_i(36))
    end

    def increase_accesses
        update(accesses: accesses + 1)
    end
end
