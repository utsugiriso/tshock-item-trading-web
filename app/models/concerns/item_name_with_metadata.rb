module ItemNameWithMetadata
  extend ActiveSupport::Concern

  def item_name_with_metadata
    if self.item.prefix.present?
      "#{self.item.name} (#{self.item.prefix})"
    elsif self.stack > 1
      "#{self.item.name} (#{self.stack})}" # stackだけはselfを参照すること
    else
      self.item.name
    end
  end
end
