

module TextFilter
  
  def capitalize_first(input)
    input[0].upcase + input[1..-1]
  end

  def uncapitalize(input)
    input[0].downcase + input[1..-1]
  end  

  def property_key(input)
    input.
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1.\2').
    gsub(/([a-z\d])([A-Z])/,'\1.\2').
    gsub(/([A-Z\d])([A-Z])/,'\1.\2').
    gsub(/([A-Z\d])([A-Z])/,'\1.\2').
    tr(" ", ".").
    tr("_", ".").
    tr("-", ".").
    downcase     
  end

  def underscore(input)
    input.
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    gsub(/([A-Z\d])([A-Z])/,'\1_\2').
    gsub(/([A-Z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

end