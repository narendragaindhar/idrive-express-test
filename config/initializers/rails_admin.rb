RailsAdmin.config do |config|
  config.main_app_name = 'IDrive Express'
  config.compact_show_view = false

  # Popular gems integration
  # == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)
  # == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0
  # More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.authenticate_with do
    require_login
  end

  config.actions do
    DISABLED = [Product, Report, Role, 'User', 'Readonly::Query'].freeze
    READ_ONLY = [OrderType, OrderState, Product, Role, 'User'].freeze

    dashboard # mandatory

    # collection actions
    index do
      except DISABLED
    end

    new do
      except READ_ONLY
    end
    export

    # member actions
    show do
      except DISABLED
    end
    edit do
      except READ_ONLY
    end
    show_in_app

    # With an audit adapter, you can add:
    # history_index
    # history_show
  end

  # required for authorizing with Pundit. see:
  # https://github.com/sferik/rails_admin/issues/2688 for more info
  config.parent_controller = '::ApplicationController'

  config.authorize_with do
    authorize :admin, :manage?
  end

  config.model Address do
    object_label_method do
      :full_address
    end

    configure :recipient do
      help 'This field or organization is required'
    end

    configure :organization do
      help 'This field or recipient is required'
    end

    configure :addressable do
      help "#{generic_help} Can be used to immediately associate a new address with an object."
    end
  end

  config.model Customer do
    object_label_method do
      :label
    end

    configure :phone do
      pretty_value do
        bindings[:object].human_phone
      end
    end

    configure :priority do
      help "#{generic_help} The higher the value more the customer's orders "\
           'will be prioritized in the system. Enter "0" for personal '\
           'accounts, "1" for business accounts.'
    end

    configure :quota do
      help "#{generic_help} Size is in bytes. 1TB = 1099511627776 bytes."
      pretty_value do
        bindings[:object].human_quota
      end
    end

    configure :server do
      help "#{generic_help} Customer's EVS data server (evsXXX.idrive.com)."
    end

    create do
      configure :orders do
        visible false
      end
    end
  end

  config.model DayCount do
    object_label_method do
      :label
    end

    configure :count do
      help "#{generic_help} The total number of days the order has been active with us."
    end

    configure :is_final do
      help "#{generic_help} If a day count is final, nothing will cause it "\
           'to be recounted in the future. It will only become final when '\
           'its order is completed.'
    end
  end

  config.model Destination do
    object_label_method do
      :name
    end

    configure :key do
      help "#{generic_help} A unique string key to identify the destination. "\
           'For example the third destination in Los Angeles could be "los_angeles_3".'
      read_only true
    end

    configure :active do
      help "#{generic_help} Disabling a destination will stop orders from being created for it"
      read_only true
    end

    configure :address do
      searchable %i[address city state zip_code country]
    end

    configure :orders do
      visible false
    end

    create do
      configure :active do
        read_only false
      end

      configure :key do
        read_only false
      end
    end
  end

  config.model Drive do
    object_label_method do
      :identification_number
    end

    configure :size do
      pretty_value do
        bindings[:object].humanize_size
      end
    end

    create do
      configure :drive_events do
        visible false
      end

      configure :size do
        visible false
      end

      field :identification_number
      field :serial
      field :active
      field :in_use
      field :orders

      group :drive_size do
        field :size_count, :integer do
          required true
        end

        field :size_units, :enum do
          enum do
            Drive::UNITS
          end
          required true
        end
      end
    end

    edit do
      configure :size do
        visible false
      end

      field :identification_number
      field :serial
      field :active
      field :in_use
      field :drive_events
      field :orders

      group :drive_size do
        field :size_count, :integer do
          required true
        end

        field :size_units, :enum do
          enum do
            Drive::UNITS
          end
          required true
        end
      end
    end

    show do
      group :default do
        field :identification_number
        field :serial
        field :size
      end
      group 'Drive events' do
        field :drive_events do
          pretty_value do
            bindings[:view].render(
              partial: 'drives/events',
              locals: {drive_id: bindings[:object].id, drive_events: bindings[:object].drive_events}
            )
          end
        end
      end
    end

    list do
      exclude_fields :size_count, :size_units
    end
  end

  config.model DriveEvent do
    object_label_method do
      :event
    end

    configure :user do
      associated_collection_cache_all true
      searchable %i[name email]
    end

    configure :drive do
      searchable %i[identification_number serial]
    end

    create do
      configure :user do
        default_value do
          bindings[:view].current_user.id
        end
      end
    end
  end

  config.model Order do
    configure :customer do
      nested_form false
      searchable %i[name username]
    end

    configure :destination do
      searchable [:name]
    end

    configure :drive do
      searchable %i[identification_number serial]
    end

    configure :size do
      help "#{generic_help} Size is in bytes. 1TB = 1099511627776 bytes."
      pretty_value do
        bindings[:object].humanize_size
      end
    end

    configure :needs_review do
      help 'True if the customer\'s account should be checked prior to shipping the order'
    end

    configure :order_states do
      visible false
    end

    configure :order_type do
      searchable [:name]
    end

    configure :os do
      help "#{generic_help} The customer's operating system (\"Windows\", \"Mac\", etc)."
      label 'OS'
    end

    configure :states do
      visible false
    end

    configure :users do
      associated_collection_cache_all true
    end

    create do
      configure :completed_at do
        visible false
      end

      configure :customer do
        nested_form false
      end

      configure :day_count do
        visible false
      end

      configure :states do
        visible false
      end

      configure :users do
        visible false
      end
    end

    show do
      configure :comments do
        pretty_value do
          bindings[:view].render(
            partial: 'text_plain',
            locals: {text: bindings[:object].comments}
          )
        end
      end

      configure :order_states do
        visible true
      end

      configure :states do
        visible false
      end
    end
  end

  config.model OrderState do
    show do
      include_all_fields
      field :comments do
        pretty_value do
          bindings[:view].render(
            partial: 'text_plain',
            locals: {text: bindings[:object].comments}
          )
        end
      end
    end
  end

  config.model OrderType do
    object_label_method do
      :full_name
    end

    configure :key do
      help "#{generic_help} A unique string key to identify this type of "\
           'express order. For example, restore orders could have the key '\
           '"restore".'
      read_only true
    end

    configure :name do
      help "#{generic_help} A simple 1-2 word description of this type of Express order."
    end

    configure :orders do
      visible false
    end

    configure :states do
      visible false
    end

    create do
      configure :key do
        read_only false
      end
    end
  end

  config.model Product do
    visible false
  end

  config.model Role do
    visible false # too many security issues to allow viewing/edits
  end

  config.model State do
    object_label_method do
      :label
    end

    configure :description do
      help "#{generic_help} Default description of what has happens in this "\
           'state. Can be a couple sentence summary. Newlines will be '\
           'rendered in the output.'
    end

    configure :active do
      help "#{generic_help} Marking a State as inactive will stop it from being added to Orders"
    end

    configure :order_type do
      read_only true
    end

    configure :is_drive_event do
      help "#{generic_help} Will adding this state to an order cause some "\
           'event to the associated drive of an order? Check this box for '\
           'states affecting the physical location of a drive. Whenever this '\
           'state is added to an order a corresponding event will happen for '\
           'the order\'s drive.'
    end

    configure :label do
      help "#{generic_help} Couple word description of the state. Something like \"Order shipped\"."
    end

    configure :key do
      help "#{generic_help} A unique string key to identify the state."
      read_only true
    end

    configure :notify_by_default do
      help "#{generic_help} By default, should this event also send the customer an email notification?"
    end

    configure :percentage do
      help "#{generic_help} A number from <code>1-100</code> indicating how "\
           'far through the order this state will be. For example, a value '\
           'of <code>15</code> would mean this state would indicate the '\
           'order is 15% done.'.html_safe
    end

    configure :public_by_default do
      help "#{generic_help} By default, should this event also notify IDrive website of what happened?"
    end

    configure :is_out_of_our_hands do
      help "#{generic_help} Does this state happen when the drive is "\
           'already physically out of our possession and we have no control '\
           'over it? States where this is true <b>will not</b> be counted '\
           'against the order\'s day count calculation.<br>For example, the '\
           'state <i>"Drive return delayed"</i> is out of our hands because '\
           'we cannot control it from happening and we cannot move the order '\
           'along any faster.'.html_safe
    end

    configure :leaves_us do
      help "#{generic_help} Does this state cause the drive to leave us "\
           'physically? For example, the state <i>"Order shipped"</i> causes '\
           'the drive to transition from being physically here to physically '\
           'away. It was physically in our posession when it occurs but it '\
           'will no longer be in our possession after that.'.html_safe
    end

    configure :orders do
      visible false
    end

    configure :order_states do
      visible false
    end

    create do
      configure :order_type do
        read_only false
      end

      configure :key do
        read_only false
      end
    end

    show do
      include_all_fields
      field :description do
        pretty_value do
          bindings[:view].render(
            partial: 'text_plain',
            locals: {text: bindings[:object].description}
          )
        end
      end
    end
  end

  config.model 'User' do
    visible false
  end
end
