module ApplicationHelper
  # returns the proper fontawesome class name for a boolean value
  def boolean_icon(boolean_value = false, surrounding = nil)
    "#{boolean_value ? 'check' : 'times'}#{" #{surrounding}" if surrounding}"
  end

  # make the title text for a page. additional kwargs
  # can change the output of the default title given
  def make_title(title, search: nil, sort: nil)
    titles = [title]
    titles.unshift "Search: \"#{search}\"" if search.is_a? String
    titles.unshift "Sort: \"#{sort}\"" if sort.is_a? String
    titles.join(' | ')
  end

  # change the default link renderer for will_paginate
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options = collection_or_options
      collection_or_options = nil
    end

    options = {
      inner_window: 2,
      previous_label: '<i class="fa fa-fw fa-angle-double-left"></i><span class="hidden-xs-down"> Previous</span>',
      next_label: '<span class="hidden-xs-down">Next </span><i class="fa fa-fw fa-angle-double-right"></i>',
      renderer: ExpressLinkRenderer
    }.merge(options)
    super(*[collection_or_options, options].compact)
  end
end
