
class String
  def capitalize_first(input)
    input[0].upcase + input[1..-1]
  end

  def underscore
    self.
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    gsub(/([A-Z\d])([A-Z])/,'\1_\2').
    gsub(/([A-Z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end	

  def camel_case
      return self.clone if self !~ /_/ && self =~ /[A-Z]+.*/
      split('_').map{|e| e.capitalize}.join
  end

  def lower_camel_case
      s = self.clone.camel_case
      s[0] = s[0].downcase
      s
  end  
end