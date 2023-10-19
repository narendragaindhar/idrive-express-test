module OrderQuery
  def self.resolve(query, relation = Order)
    OrderQuery.new(query, relation).resolve
  end

  class OrderQuery
    IDRIVE_UPLOAD_RE = /\Aidrive([\s_-]*express)?[\s_-]*upload\z/i
    IDRIVE_RESTORE_RE = /\Aidrive([\s_-]*express)?[\s_-]*restore\z/i
    IDRIVE_ONE_RE = /\A(idrive)?[\s_-]*one\z/i
    IDRIVE_BMR_RE = /\A(idrive)?[\s_-]*bmr\z/i
    IDRIVE_BMR_UPLOAD_RE = /\A(idrive)?[\s_-]*bmr([\s_-]*express)?[\s_-]*upload\z/i
    IDRIVE_BMR_RESTORE_RE = /\A(idrive)?[\s_-]*bmr([\s_-]*express)?[\s_-]*restore\z/i
    IDRIVE360_UPLOAD_RE = /\A(idrive)?[\s_-]*360([\s_-]*express)?[\s_-]*upload\z/i
    IDRIVE360_RESTORE_RE = /\A(idrive)?[\s_-]*360([\s_-]*express)?[\s_-]*restore\z/i
    IBACKUP_UPLOAD_RE = /\Aibackup([\s_-]*express)?[\s_-]*upload\z/i
    IBACKUP_RESTORE_RE = /\Aibackup([\s_-]*express)?[\s_-]*restore\z/i
    SIZE_RE = /\A((\d+)(\.\d+)?)((k|m|g|t|p)?b)\z/i

    def initialize(query, relation)
      @query = query
      @relation = relation
    end

    def resolve
      if @query.is_a? String
        KeywordSearch.search(@query) do |with|
          with.default_keyword :query

          with.keyword :query do |values|
            @relation = generic(values)
          end

          with.keyword :comments do |values|
            @relation = comments(values)
          end

          with.keyword :completed do |values|
            @relation = Helpers::DateFilter.filter(@relation, '`orders`.`completed_at`', values.first)
          end

          with.keyword :created do |values|
            @relation = Helpers::DateFilter.filter(@relation, '`orders`.`created_at`', values.first)
          end

          with.keyword :customer do |values|
            @relation = customer(values)
          end

          with.keyword :drive do |values|
            @relation = drive(values)
          end

          with.keyword :id do |values|
            @relation = @relation.where(id: values)
          end

          with.keyword :is do |values|
            @relation = is(values)
          end

          with.keyword :order_type do |values|
            @relation = order_type(values)
          end

          with.keyword :size do |values|
            @relation = size(values)
          end

          with.keyword :state do |values|
            @relation = state(values)
          end

          with.keyword :updated do |values|
            @relation = Helpers::DateFilter.filter(@relation, '`orders`.`updated_at`', values.first)
          end

          with.keyword :user do |values|
            @relation = user(values)
          end

          with.keyword :day_count do
            @relation = order_sort('day_count')
          end

          with.keyword :priority do
            @relation = order_sort('priority')
          end

          with.keyword :order_updated do
            @relation = order_sort('recently_updated')
          end
        end
      end

      @relation
        .includes(
          :address,
          :customer,
          :day_count,
          :drive,
          order_type: :product,
          order_states: :state
        )
        .order(Arel.sql('`orders`.`completed_at` IS NULL DESC'))
        .order(completed_at: :desc)
        .order(id: :desc)
    end

    private

    def generic(values)
      query = values.join(' ')
      or_where = OrWhere.new
                        .or_where('`orders`.`id` = ?', query)
                        .or_where('`customers`.`email` = ?', query)
                        .or_where('`customers`.`username` = ?', query)
                        .or_where('`drives`.`identification_number` = ?', query)
                        .or_where('`drives`.`serial` = ?', query)

      @relation.references(:customer)
               .where(or_where.statement, *or_where.values)
    end

    def comments(values)
      or_where = OrWhere.new
      values.each do |value|
        or_where
          .or_where('`orders`.`comments` LIKE ?', value, likeify: true)
          .or_where('`order_states`.`comments` LIKE ?', value, likeify: true)
      end

      @relation.references(:order_states)
               .where(or_where.statement, *or_where.values)
    end

    def customer(values)
      or_where = OrWhere.new
      values.each do |value|
        or_where
          .or_where('`customers`.`email` = ?', value)
          .or_where('`customers`.`name` LIKE ?', value, likeify: true)
          .or_where('`customers`.`server` = ?', value)
          .or_where('`customers`.`username` = ?', value)
      end

      @relation.references(:customer)
               .where(or_where.statement, *or_where.values)
    end

    def drive(values)
      or_where = OrWhere.new
      values.each do |value|
        or_where
          .or_where('`drives`.`identification_number` = ?', value)
          .or_where('`drives`.`serial` = ?', value)
      end

      @relation.references(:drive)
               .where(or_where.statement, *or_where.values)
    end

    def is(values)
      or_where = OrWhere.new
      values.each do |value|
        if value.casecmp('open').zero?
          or_where.or_where('`orders`.`completed_at` IS ?', nil)
        elsif value.casecmp('closed').zero?
          or_where.or_where('`orders`.`completed_at` IS NOT ?', nil)
        end
      end

      @relation.where(or_where.statement, *or_where.values)
    end

    def order_type(values)
      or_where = OrWhere.new
      values.each do |value|
        case value
        when IDRIVE_UPLOAD_RE
          or_where.or_where('`order_types`.`key` = ?', OrderType::IDRIVE_UPLOAD)
        when IDRIVE_RESTORE_RE
          or_where.or_where('`order_types`.`key` = ?', OrderType::IDRIVE_RESTORE)
        when IDRIVE_ONE_RE
          or_where.or_where('`order_types`.`key` = ?', OrderType::IDRIVE_ONE)
        when IDRIVE_BMR_RE
          or_where.or_where('`order_types`.`key` = ?', OrderType::IDRIVE_BMR)
        when IDRIVE_BMR_UPLOAD_RE
          or_where.or_where('`order_types`.`key` = ?', OrderType::IDRIVE_BMR_UPLOAD)
        when IDRIVE_BMR_RESTORE_RE
          or_where.or_where('`order_types`.`key` = ?', OrderType::IDRIVE_BMR_RESTORE)
        when IDRIVE360_UPLOAD_RE
          or_where.or_where('`order_types`.`key` = ?', OrderType::IDRIVE360_UPLOAD)
        when IDRIVE360_RESTORE_RE
          or_where.or_where('`order_types`.`key` = ?', OrderType::IDRIVE360_RESTORE)
        when IBACKUP_UPLOAD_RE
          or_where.or_where('`order_types`.`key` = ?', OrderType::IBACKUP_UPLOAD)
        when IBACKUP_RESTORE_RE
          or_where.or_where('`order_types`.`key` = ?', OrderType::IBACKUP_RESTORE)
        else
          or_where.or_where('`order_types`.`name` LIKE ?', value.humanize, likeify: true)
        end
      end

      @relation.references(:order_type)
               .where(or_where.statement, *or_where.values)
    end

    def size(values)
      or_where = OrWhere.new
      values.each do |value|
        next unless value =~ SIZE_RE

        or_where.or_where(
          '`orders`.`size` = ?',
          Sizable.to_bytes(Regexp.last_match(1), Regexp.last_match(4))
        )
      end

      @relation.where(or_where.statement, *or_where.values)
    end

    def state(values)
      or_where = OrWhere.new
      values.each do |value|
        or_where.or_where('`states`.`label` LIKE ?', value, likeify: true)
      end

      @relation.references(:state)
               .where(or_where.statement, *or_where.values)
    end

    def user(values)
      or_where = OrWhere.new
      values.each do |value|
        or_where
          .or_where('`users`.`email` = ?', value)
          .or_where('`users`.`name` LIKE ?', value, likeify: true)
      end

      @relation.joins(orders_users: :user)
               .where(or_where.statement, *or_where.values)
    end

    def order_sort(value)
      case value
      when 'day_count'
        @relation.where(completed_at: nil).order('day_counts.count DESC')
      when 'priority'
        @relation.where(completed_at: nil)
                 .order(
                   "customers.priority DESC,
                    orders.created_at DESC"
                 )
      when 'recently_updated'
        @relation.order('orders.updated_at DESC')
      end
    end
  end
end
