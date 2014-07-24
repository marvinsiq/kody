
class String
  
  def capitalize_first
    self[0].upcase + self[1..-1]
  end

  def capitalize_all
    self.
      gsub(/([a-z\d])([A-Z])/,'\1 \2').
      gsub(/([A-Z\d])([A-Z])/,'\1 \2').
      gsub(/([A-Z\d])([A-Z])/,'\1 \2').
      tr("_", " ").
      tr("-", " ").
      split(" ").each {|a| a.capitalize!}.join(" ")
  end

  def uncapitalize
    self[0].downcase + self[1..-1]
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

  def hyphenate
    self.
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1-\2').
    gsub(/([a-z\d])([A-Z])/,'\1-\2').
    gsub(/([A-Z\d])([A-Z])/,'\1-\2').
    gsub(/([A-Z\d])([A-Z])/,'\1-\2').
    tr(" ", "-").
    tr("_", "-").
    downcase    
  end

  def property_key
    self.
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1.\2').
    gsub(/([a-z\d])([A-Z])/,'\1.\2').
    gsub(/([A-Z\d])([A-Z])/,'\1.\2').
    gsub(/([A-Z\d])([A-Z])/,'\1.\2').
    tr(" ", ".").
    tr("_", ".").
    tr("-", ".").
    downcase    
  end  

  def camel_case
      return self.clone if self !~ /_/ && self !~ / / && self =~ /[A-Z]+.*/
      split('_').map{|e| e.capitalize}.join.
      split(' ').map{|e| e.capitalize}.join
  end

  def lower_camel_case
      s = self.clone.camel_case
      s[0] = s[0].downcase
      s
  end  
end