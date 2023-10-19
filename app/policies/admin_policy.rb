AdminPolicy = Struct.new(:user, :admin) do
  def manage?
    user.role? :super_user, :idrive_employee
  end
end
