class ExpressLinkRenderer < WillPaginate::ActionView::LinkRenderer
  protected

  def page_number(page)
    if page == current_page
      item(page, item_attrs: { class: 'active' })
    else
      item(page, link_to: page, link_attrs: { rel: rel_value(page) })
    end
  end

  def gap
    text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
    item(text, item_attrs: { class: 'disabled' })
  end

  def previous_or_next_page(page, text, classname)
    if page
      item(text, link_to: page, link_attrs: { class: classname })
    else
      item(text, item_attrs: { class: 'disabled' }, link_attrs: { class: classname })
    end
  end

  def html_container(html)
    tag(:ul, html, container_attributes)
  end

  private

  def item(text, link_to: false, item_attrs: {}, link_attrs: {})
    link_attrs[:class] = "page-link #{link_attrs.fetch(:class, '')}"
    link_html = if link_to
                  link(text, link_to, **link_attrs)
                else
                  tag(:span, text, **link_attrs)
                end

    item_attrs[:class] = "page-item #{item_attrs.fetch(:class, '')}"
    tag(:li, link_html, **item_attrs)
  end
end
