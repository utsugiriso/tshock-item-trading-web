module ApplicationHelper
  def item_name_with_metadata(item, stack: nil)
    stack = item.stack if stack.nil?

    if item.prefix.present?
      raw "#{item.name} #{content_tag(:span, "(#{item.prefix})", class: 'text-info')}"
    elsif item.stack > 1
      raw "#{item.name} #{content_tag(:span, "(#{item.stack})", class: 'text-secondary')}"
    else
      item.name
    end
  end
end
