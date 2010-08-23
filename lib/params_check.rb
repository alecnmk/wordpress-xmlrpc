module ParamsCheck
  def check_param(params, param)
    raise ArgumentError, ":#{param} param is required" unless params[param]
    params[param]
  end #check_and_assign
end
