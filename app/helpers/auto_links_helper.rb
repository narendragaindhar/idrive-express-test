module AutoLinksHelper
  TICKET_ID_RE = /(?:ID|IB|RP)\d{9,11}/i
  URL_RE = %r{
    https?://ticket\.idrive\.com/scp/tickets\.php\?
    (?:id=\d+|number=#{TICKET_ID_RE}) # match both id and number formats
  }xi
  TICKET_RE = /#{URL_RE}|#{TICKET_ID_RE}/i

  OLD_TICKET_ID_RE = /(?:ID|ST|SL|RP)\d{7,8}/i
  OLD_URL_RE = %r{
    https?://ticket\.ibackup\.com/helpdesk/admin/ticket_detail\.php\?
    ticket_id=#{OLD_TICKET_ID_RE}
  }xi
  OLD_TICKET_RE = /#{OLD_URL_RE}|#{OLD_TICKET_ID_RE}/i

  # auto link to the support ticketing site in the given text content
  def auto_link_to_ticketing(content)
    case content
    when TICKET_RE
      matches = content.scan(TICKET_RE)
      parts = content.split(TICKET_RE)
      url_re = URL_RE
      link_builder = :link_to_idrive
    when OLD_TICKET_RE
      matches = content.scan(OLD_TICKET_RE)
      parts = content.split(OLD_TICKET_RE)
      url_re = OLD_URL_RE
      link_builder = :link_to_ibackup
    else
      return content # no tickets
    end

    parts.push('') if parts.size < 2
    capture do
      parts.each_with_index do |text, i|
        concat text
        link_text = matches[i]
        ticket = if url_re.match?(link_text)
                   link_text.match(/\w+\Z/i)[0] # "id" is always at the end
                 else
                   link_text
                 end
        send(link_builder, link_text, ticket) if matches[i]
      end
    end
  end

  # link to a ticket at ticket.ibackup.com
  def link_to_ibackup(link_text, ticket)
    concat link_to(
      link_text,
      URI::HTTPS.build(
        host: 'ticket.ibackup.com', path: '/helpdesk/admin/ticket_detail.php',
        query: {ticket_id: ticket}.to_query
      ).to_s,
      target: '_blank'
    )
  end

  # link to a ticket at ticket.idrive.com
  def link_to_idrive(link_text, ticket)
    query = if TICKET_ID_RE.match?(ticket)
              {number: ticket}
            else
              {id: ticket}
            end

    concat link_to(
      link_text,
      URI::HTTPS.build(
        host: 'ticket.idrive.com', path: '/scp/tickets.php',
        query: query.to_query
      ).to_s,
      target: '_blank'
    )
  end
end
