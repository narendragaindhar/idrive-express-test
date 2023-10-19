class OrWhere
  attr_reader :values

  def initialize
    @wheres = []
    @values = []
  end

  # add an additional OR statement qualifier to the query
  def or_where(statement, value, likeify: false)
    @wheres << statement
    @values << (likeify ? _likeify(value) : value)
    self
  end

  # return the full OR statement properly joined
  def statement
    @wheres.join(' OR ')
  end

  private

  def _likeify(value)
    "%#{value}%"
  end
end
