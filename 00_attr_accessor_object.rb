class AttrAccessorObject

  def self.my_attr_accessor(*names)
    names.each do |instance_var|

  		define_method("#{instance_var}=") do |value|
    		instance_variable_set("@#{instance_var}", value)
    	end

    	define_method("#{instance_var}") do
    		instance_variable_get("@#{instance_var}")
    	end
    end
  end

end