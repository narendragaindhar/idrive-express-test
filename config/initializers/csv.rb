# CSV library customization

# strip the value if possible
CSV::Converters[:strip] = ->(v) { v&.strip }
