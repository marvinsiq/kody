{%if class.stereotype == "enumeration" %}package {{class.package}};

/**
 * {{class.name}}
 */
public enum {{class.name}} {

{% for attribute in class.attributes %}{% if forloop.last %}	{{attribute.name}}({{attribute.initial_value}}){% else %}	{{attribute.name}}({{attribute.initial_value}}),
{% endif %}{% endfor %};

 	{{class.enum_type}} value;

 	{{class.name}}({{class.enum_type}} value) {
 		this.value = value;
 	}

 	public {{class.enum_type}} getValue() {
 		return value;
 	}

 	public String toString() {
        return "" + value;
    }{% if class.enum_type != "String" %}

    public static {{class.name}} valueOf({{class.enum_type}} value) {
    	{{class.name}} {{class.name | uncapitalize}} = null;
         for ({{class.name}} item : {{class.name}}.values()) {
             if (item.getValue()==value) {
            	 {{class.name | uncapitalize}} = item;
                 break;
             }
         }
         return {{class.name | uncapitalize}};
    }{% endif %} 
}{% endif %}