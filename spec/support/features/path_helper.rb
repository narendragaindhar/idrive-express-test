module PathHelper
  def ensure_path(path)
    visit path unless current_path == path
  end
end
