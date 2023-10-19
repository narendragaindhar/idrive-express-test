module Release
  class Version
    attr_reader :major, :minor, :patch

    def initialize(major, minor, patch)
      @major = major
      @minor = minor
      @patch = patch
    end

    def bump(level)
      if level == 'patch'
        Version.new(@major, @minor, @patch + 1)
      elsif level == 'minor'
        Version.new(@major, @minor + 1, 0)
      elsif level == 'major'
        Version.new(@major + 1, 0, 0)
      else
        raise ArgumentError, 'Invalid version level'
      end
    end

    def to_s
      "#{@major}.#{@minor}.#{@patch}"
    end

    def to_tag
      "v#{self}"
    end

    def ==(other)
      @major == other.major && @minor == other.minor && @patch == other.patch
    end
  end
end
