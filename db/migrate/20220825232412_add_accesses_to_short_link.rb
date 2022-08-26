class AddAccessesToShortLink < ActiveRecord::Migration[5.2]
  def change
    add_column :short_links, :accesses, :integer, default: 0
  end
end
