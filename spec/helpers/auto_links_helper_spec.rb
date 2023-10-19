require 'rails_helper'

RSpec.describe AutoLinksHelper do
  let(:content_other) do
    <<~COMMENTS
      It has been a while since your order has shipped. To avoid being charged for the drive, please ship it back to us as soon as possible.

      If we do not hear from you by June 23rd, we will assume you will not return the drive, and charge your account the replacement fee of $99.95 per Hard Drive.

      If you have any questions please utilize our 24-hour online chat support (https://www.idrive.com/support.htm) or call our customer support team at (866) 748-0555, 6AM - 6PM PST, Monday - Friday.
    COMMENTS
  end
  let(:content_shipping) do
    <<~COMMENTS
      USPS sent tracking number: 9410803699300080595368

      USPS return tracking number: 9410803699300080595375
    COMMENTS
  end

  describe '#auto_link_to_ticketing' do
    context 'with ticket.idrive.com tickets' do
      it 'links to support ticketing site with text only containing a ticket ID' do
        rendered = helper.auto_link_to_ticketing('ID011643145')
        expect(rendered).to eq(
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=ID011643145">'\
          'ID011643145'\
          '</a>'
        )
      end

      it 'links to support ticketing site with text only containing a ticket URL with id' do
        rendered = helper.auto_link_to_ticketing(
          'https://ticket.idrive.com/scp/tickets.php?id=26994'
        )
        expect(rendered).to eq(
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?id=26994">'\
          'https://ticket.idrive.com/scp/tickets.php?id=26994'\
          '</a>'
        )
      end

      it 'links to support ticketing site with text only containing a ticket URL with number' do
        rendered = helper.auto_link_to_ticketing(
          'https://ticket.idrive.com/scp/tickets.php?number=IB427467800'
        )
        expect(rendered).to eq(
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=IB427467800">'\
          'https://ticket.idrive.com/scp/tickets.php?number=IB427467800'\
          '</a>'
        )
      end

      it 'links to the support ticketing site with references to ticket at beginning of text' do
        rendered = helper.auto_link_to_ticketing("Ticket ID300258449.\nSee for context.")
        expect(rendered).to eq(
          'Ticket '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=ID300258449">ID300258449'\
          "</a>.\nSee for context."
        )
      end

      it 'links to the support ticketing site with references to ticket in middle of text' do
        rendered = helper.auto_link_to_ticketing(
          "User approved shipping fee via support ticket RP770065834.\n\nWill charge"
        )
        expect(rendered).to eq(
          'User approved shipping fee via support ticket '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=RP770065834">RP770065834'\
          "</a>.\n\nWill charge"
        )
      end

      it 'links to the support ticketing site with references to ticket at end of text' do
        rendered = helper.auto_link_to_ticketing('User approved shipping fee. Charging on ticket ID902889231')
        expect(rendered).to eq(
          'User approved shipping fee. Charging on ticket '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=ID902889231">ID902889231'\
          '</a>'
        )
      end

      it 'links to the support ticketing site with colon in the ticket text' do
        rendered = helper.auto_link_to_ticketing('Please check with ticket: RP669584513')
        expect(rendered).to eq(
          'Please check with ticket: '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=RP669584513">RP669584513'\
          '</a>'
        )
      end

      it 'links to the support ticketing site with text saying "ticket number"' do
        rendered = helper.auto_link_to_ticketing('Please reference ticket number IB299947821')
        expect(rendered).to eq(
          'Please reference ticket number '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=IB299947821">IB299947821'\
          '</a>'
        )
      end

      it 'links to the support ticketing site with text saying "ref IDXXXX"' do
        rendered = helper.auto_link_to_ticketing(
          "ref ID003564852\nI would like to confirm acceptance of $33.95USD for "\
          "shipping and please find below my shipping address\nMel Doyle\nForest "\
          "View,\nStramillion,\nMonasterevin,\nCo Kildare,\nIreland"
        )
        expect(rendered).to eq(
          'ref '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=ID003564852">ID003564852'\
          "</a>\nI would like to confirm acceptance of $33.95USD for shipping "\
          'and please find below my shipping '\
          "address\nMel Doyle\nForest View,\nStramillion,\nMonasterevin,\nCo "\
          "Kildare,\nIreland"
        )
      end

      it 'links to the support ticketing site with text saying "ticket # IDXXXX"' do
        rendered = helper.auto_link_to_ticketing(
          'Charging user replacement fee for the Hard Drive. Sent to Finance ticket # IB448378772'
        )
        expect(rendered).to eq(
          'Charging user replacement fee for the Hard Drive. Sent to Finance ticket # '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=IB448378772">IB448378772'\
          '</a>'
        )
      end

      it 'links to the support ticketing site with url embedded in text' do
        rendered = helper.auto_link_to_ticketing(
          'https://ticket.idrive.com/scp/tickets.php?'\
          "id=64998\n\nExtension Approved."
        )
        expect(rendered).to eq(
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'id=64998">'\
          'https://ticket.idrive.com/scp/tickets.php?id=64998'\
          '</a>'\
          "\n\nExtension Approved."
        )
      end

      it 'links to the support ticketing site with non https url embedded in text' do
        rendered = helper.auto_link_to_ticketing(
          'http://ticket.idrive.com/scp/tickets.php?'\
          "id=892773\n\nGranting 3 week extension. Requesting "\
          'user also provide tracking number upon returning drive.'
        )
        expect(rendered).to eq(
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'id=892773">'\
          'http://ticket.idrive.com/scp/tickets.php?id=892773'\
          '</a>'\
          "\n\nGranting 3 week extension. Requesting user also provide tracking number upon returning drive."
        )
      end

      it 'matches multiple tickets' do
        rendered = helper.auto_link_to_ticketing(
          'User has been contacting via ticket ID992047653 and support ticket IB299475684 for assistance.'
        )
        expect(rendered).to eq(
          'User has been contacting via ticket '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=ID992047653">ID992047653'\
          '</a> and support ticket '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=IB299475684">IB299475684'\
          '</a> '\
          'for assistance.'
        )
      end

      it 'matches multiple ticket urls' do
        rendered = helper.auto_link_to_ticketing(
          'See https://ticket.idrive.com/scp/tickets.php?'\
          'number=IB668523471 and https://ticket.idrive.com/scp/tickets.php?'\
          'id=644895 for more info.'
        )
        expect(rendered).to eq(
          'See '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=IB668523471">'\
          'https://ticket.idrive.com/scp/tickets.php?number=IB668523471'\
          '</a> and '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'id=644895">'\
          'https://ticket.idrive.com/scp/tickets.php?id=644895'\
          '</a> '\
          'for more info.'
        )
      end

      it 'matches mixed ticket and urls in text' do
        rendered = helper.auto_link_to_ticketing(
          "I responded to Ticket ID669325001.\n\nAlso you can read "\
          'https://ticket.idrive.com/scp/tickets.php?number=RP994875525.'
        )
        expect(rendered).to eq(
          'I responded to Ticket '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=ID669325001">'\
          'ID669325001'\
          "</a>.\n\nAlso you can read "\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=RP994875525">'\
          'https://ticket.idrive.com/scp/tickets.php?number=RP994875525'\
          '</a>.'
        )
      end

      it 'supports text like "ticket was XXXX"' do
        rendered = helper.auto_link_to_ticketing("My ticket was ID666588247.\n\nChad")
        expect(rendered).to eq(
          'My ticket was '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=ID666588247">ID666588247'\
          "</a>.\n\n"\
          'Chad'
        )
      end

      it 'supports text like "ticket number is XXXX"' do
        rendered = helper.auto_link_to_ticketing("My ticket number is IB987588461.\n\nChad")
        expect(rendered).to eq(
          'My ticket number is '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=IB987588461">IB987588461'\
          "</a>.\n\n"\
          'Chad'
        )
      end

      it 'does not allow XSS stuff' do
        rendered = helper.auto_link_to_ticketing(
          "Here is support ticket IB789456357.\n\n<script>console.log('And a vulernability!');</script>"
        )
        expect(rendered).to eq(
          'Here is support ticket '\
          '<a target="_blank" href="https://ticket.idrive.com/scp/tickets.php?'\
          'number=IB789456357">IB789456357'\
          "</a>.\n\n"\
          '&lt;script&gt;console.log(&#39;And a vulernability!&#39;);&lt;/script&gt;'
        )
      end

      it 'does not link to anything if no ticket is referenced' do
        expect(helper.auto_link_to_ticketing(content_other)).to eq(content_other)
        expect(helper.auto_link_to_ticketing(content_shipping)).to eq(content_shipping)
      end
    end

    context 'with ticket.ibackup.com tickets' do
      it 'links to support ticketing site with text only containing a ticket ID' do
        rendered = helper.auto_link_to_ticketing('ID01164314')
        expect(rendered).to eq(
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID01164314">'\
          'ID01164314'\
          '</a>'
        )
      end

      it 'links to support ticketing site with text only containing a ticket URL' do
        rendered = helper.auto_link_to_ticketing(
          'http://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?'\
          'ticket_id=ID01164314'
        )
        expect(rendered).to eq(
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID01164314">'\
          'http://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?'\
          'ticket_id=ID01164314'\
          '</a>'
        )
      end

      it 'links to the support ticketing site with references to ticket at beginning of text' do
        rendered = helper.auto_link_to_ticketing("Ticket ID00982616.\nSee for context.")
        expect(rendered).to eq(
          'Ticket '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID00982616">'\
          'ID00982616'\
          "</a>.\nSee for context."
        )
      end

      it 'links to the support ticketing site with references to ticket in middle of text' do
        rendered = helper.auto_link_to_ticketing(
          "User approved shipping fee via support ticket ID00671570.\n\nWill charge"
        )
        expect(rendered).to eq(
          'User approved shipping fee via support ticket '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID00671570">'\
          'ID00671570'\
          "</a>.\n\nWill charge"
        )
      end

      it 'links to the support ticketing site with references to ticket at end of text' do
        rendered = helper.auto_link_to_ticketing('User approved shipping fee. Charging on ticket ID00849570')
        expect(rendered).to eq(
          'User approved shipping fee. Charging on ticket '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID00849570">'\
          'ID00849570'\
          '</a>'
        )
      end

      it 'links to the support ticketing site with colon in the ticket text' do
        rendered = helper.auto_link_to_ticketing('Please check with ticket: ID64585210')
        expect(rendered).to eq(
          'Please check with ticket: '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID64585210">'\
          'ID64585210'\
          '</a>'
        )
      end

      it 'links to the support ticketing site with text saying "ticket number"' do
        rendered = helper.auto_link_to_ticketing('Please reference ticket number ID00866085')
        expect(rendered).to eq(
          'Please reference ticket number '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID00866085">'\
          'ID00866085'\
          '</a>'
        )
      end

      it 'links to the support ticketing site with text saying "ref IDXXXX"' do
        rendered = helper.auto_link_to_ticketing(
          "ref ID00864811\nI would like to confirm acceptance of $33.95USD for "\
          "shipping and please find below my shipping address\nMel Doyle\nForest "\
          "View,\nStramillion,\nMonasterevin,\nCo Kildare,\nIreland"
        )
        expect(rendered).to eq(
          'ref '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID00864811">'\
          'ID00864811'\
          "</a>\nI would like to confirm acceptance of $33.95USD for shipping "\
          'and please find below my shipping '\
          "address\nMel Doyle\nForest View,\nStramillion,\nMonasterevin,\nCo "\
          "Kildare,\nIreland"
        )
      end

      it 'links to the support ticketing site with text saying "ticket # IDXXXX"' do
        rendered = helper.auto_link_to_ticketing(
          'Charging user replacement fee for the Hard Drive. Sent to Finance ticket # ID00870353'
        )
        expect(rendered).to eq(
          'Charging user replacement fee for the Hard Drive. Sent to Finance ticket # '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID00870353">'\
          'ID00870353'\
          '</a>'
        )
      end

      it 'links to the support ticketing site with url embedded in text' do
        rendered = helper.auto_link_to_ticketing(
          'https://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?'\
          "ticket_id=ID00868616\n\nExtension Approved."
        )
        expect(rendered).to eq(
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID00868616">'\
          'https://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?ticket_id=ID00868616'\
          '</a>'\
          "\n\nExtension Approved."
        )
      end

      it 'links to the support ticketing site with non https url embedded in text' do
        rendered = helper.auto_link_to_ticketing(
          'http://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?'\
          "ticket_id=ID00857309\n\nGranting 3 week extension. Requesting "\
          'user also provide tracking number upon returning drive.'
        )
        expect(rendered).to eq(
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID00857309">'\
          'http://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?ticket_id=ID00857309'\
          '</a>'\
          "\n\nGranting 3 week extension. Requesting user also provide tracking number upon returning drive."
        )
      end

      it 'matches multiple tickets' do
        rendered = helper.auto_link_to_ticketing(
          'User has been contacting via ticket ID00684320 and support ticket ID03856490 for assistance.'
        )
        expect(rendered).to eq(
          'User has been contacting via ticket '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID00684320">'\
          'ID00684320'\
          '</a> and support ticket '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID03856490">'\
          'ID03856490'\
          '</a> '\
          'for assistance.'
        )
      end

      it 'matches multiple ticket urls' do
        rendered = helper.auto_link_to_ticketing(
          'See https://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?'\
          'ticket_id=ID94853165 and https://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?'\
          'ticket_id=ID97642205 for more info.'
        )
        expect(rendered).to eq(
          'See '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID94853165">'\
          'https://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?ticket_id=ID94853165'\
          '</a> and '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID97642205">'\
          'https://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?ticket_id=ID97642205'\
          '</a> '\
          'for more info.'
        )
      end

      it 'matches mixed ticket and urls in text' do
        rendered = helper.auto_link_to_ticketing(
          "I responded to Ticket ID82937450.\n\nAlso you can read "\
          'https://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?ticket_id=ID94853165.'
        )
        expect(rendered).to eq(
          'I responded to Ticket '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID82937450">'\
          'ID82937450'\
          "</a>.\n\nAlso you can read "\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID94853165">'\
          'https://ticket.ibackup.com/helpdesk/admin/ticket_detail.php?ticket_id=ID94853165'\
          '</a>.'
        )
      end

      it 'supports text like "ticket was XXXX"' do
        rendered = helper.auto_link_to_ticketing("My ticket was ID00947396.\n\nChad")
        expect(rendered).to eq(
          'My ticket was '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID00947396">'\
          'ID00947396'\
          "</a>.\n\n"\
          'Chad'
        )
      end

      it 'supports text like "ticket number is XXXX"' do
        rendered = helper.auto_link_to_ticketing("My ticket number is ID00918472.\n\nChad")
        expect(rendered).to eq(
          'My ticket number is '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID00918472">'\
          'ID00918472'\
          "</a>.\n\n"\
          'Chad'
        )
      end

      it 'does not allow XSS stuff' do
        rendered = helper.auto_link_to_ticketing(
          "Here is support ticket ID82688224.\n\n<script>console.log('And a vulernability!');</script>"
        )
        expect(rendered).to eq(
          'Here is support ticket '\
          '<a target="_blank" href="https://ticket.ibackup.com/helpdesk/admin/'\
          'ticket_detail.php?ticket_id=ID82688224">'\
          'ID82688224'\
          "</a>.\n\n"\
          '&lt;script&gt;console.log(&#39;And a vulernability!&#39;);&lt;/script&gt;'
        )
      end

      it 'does not link to anything if no ticket is referenced' do
        expect(helper.auto_link_to_ticketing(content_other)).to eq(content_other)
        expect(helper.auto_link_to_ticketing(content_shipping)).to eq(content_shipping)
      end
    end
  end
end
