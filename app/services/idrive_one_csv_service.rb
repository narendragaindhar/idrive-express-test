class IDriveOneCSVService
  STATUS = 2
  ORDER_ID = 3
  DRIVE_IDENTIFICATION_NUMBER = 12
  DRIVE_SERIAL = 13
  TRACKING_NUMBER = 14
  COMMENTS = 19

  RE_HOLD = /\b(on )?hold\b/i
  RE_CANCELLED = /\bcancel(led)?\b/i

  def initialize(csv_file, user)
    @csv_file = csv_file
    @user = user
  end

  def process
    return @csv_file unless @csv_file.valid?

    begin
      lineno = 0
      CSV.parse(@csv_file.file, converters: [:strip]) do |row|
        lineno += 1
        id = row[ORDER_ID]
        order = Order.find_by(id: id) || next
        order_updated = false
        if order.order_type.key_is? :idrive_one
          @csv_file.records_processed += 1
        else
          @csv_file.warnings.add(:file, line_message(lineno, order.id, 'is not for an IDrive One'))
          next
        end

        # status
        status = row[STATUS]
        if status
          if status.match?(RE_HOLD)
            @csv_file.warnings.add(:file, line_message(lineno, order.id, 'is on hold and was not updated'))
            next
          elsif status.match?(RE_CANCELLED)
            order.order_states.find_or_create_by(state: state_cancelled) do |order_state|
              @csv_file.records_updated += 1
              order_state.user = @user
              order_state.comments = 'Your IDrive One order has been cancelled'
              order_state.did_notify = true
              order_state.is_public = true
            end
            next
          end
        end

        # drive
        identification_number = row[DRIVE_IDENTIFICATION_NUMBER]
        serial = row[DRIVE_SERIAL]
        if !order.drive && identification_number && serial
          drive_attrs = {
            identification_number: identification_number,
            serial: serial
          }
          order.drive = Drive.find_or_create_by(drive_attrs) do |drive|
            drive.size = order.size
          end

          order_updated = true if order.save
        end

        # private notes
        comments = row[COMMENTS]
        if comments
          order.order_states.find_or_create_by(state: state_status_update, comments: comments) do |order_state|
            order_updated = true
            order_state.user = @user
            order_state.did_notify = false
            order_state.is_public = false
          end
        end

        tracking_number = row[TRACKING_NUMBER]
        if tracking_number && tracking_number =~ RE_HOLD
          @csv_file.warnings.add(:file, line_message(lineno, order.id, 'is on hold via the tracking information'))
        elsif tracking_number
          order_updated = true if add_shipping_information(order, tracking_number)

          if order.drive.present?
            order_updated = true if complete_order(order, tracking_number)
          else
            @csv_file.warnings.add(
              :file,
              line_message(lineno, order.id, 'has a tracking number but no drive. '\
                                             'Order cannot be completed without a drive.')
            )
          end
        end
        @csv_file.records_updated += 1 if order_updated
      end
      @csv_file.success = true
    rescue ArgumentError, CSV::MalformedCSVError => e
      if e.is_a? CSV::MalformedCSVError
        Rails.logger.error "Malformed CSV error occurred in bulk processing: #{e.message}"
      end
      @csv_file.errors.add(:base, 'Invalid CSV file')
    end
    @csv_file
  end

  #
  # add shipping information to the order provided certain conditions are met
  #
  def add_shipping_information(order, tracking_number)
    if order.order_states.find_by(state: state_shipped)
      false # we have already shipped
    elsif order.order_states.where(state: state_shipping_label).where('`order_states`.`comments` LIKE ?', "%#{tracking_number}%").take # rubocop:disable Metrics/LineLength
      false # we already added it
    else
      comments = "USPS tracking number: #{tracking_number}"
      comments = "Updated #{comments}" if order.order_states.find_by(state: state_shipping_label)

      order.order_states.create(
        state: state_shipping_label, user: @user, comments: comments,
        did_notify: false, is_public: false
      ).persisted?
    end
  end

  #
  # complete the order provided certain conditions are met
  #
  def complete_order(order, tracking_number)
    if order.order_states.where(state: state_shipped).where('`order_states`.`comments` LIKE ?', "%#{tracking_number}%").take # rubocop:disable Metrics/LineLength
      false # already added it
    else
      comments = 'Your IDrive One has been shipped and your order is complete! Your '
      comments += 'UPDATED ' if order.order_states.find_by(state: state_shipped)
      comments += "tracking number is #{tracking_number}. Please allow 2-3 days for delivery."

      order.order_states.create(
        state: state_shipped, user: @user, comments: comments,
        did_notify: true, is_public: true
      ).persisted?
    end
  end

  def line_message(lineno, order_id, message)
    "line ##{lineno}: Order ##{order_id} #{message}"
  end

  private

  def state_cancelled
    @state_cancelled ||= State.find_by!(key: :idrive_one_order_cancelled)
  end

  def state_shipped
    @state_shipped ||= State.find_by!(key: :idrive_one_order_shipped)
  end

  def state_shipping_label
    @state_shipping_label ||= State.find_by!(key: :idrive_one_shipping_label_generated)
  end

  def state_status_update
    @state_status_update ||= State.find_by!(key: :idrive_one_status_update)
  end
end
