{%if class.stereotype == "value_object" %}package {{class.package}};

/**
 * {{class.name}}
 */
public class {{class.name}} {

{% for attribute in class.attributes %}	private {{attribute.type}} {{attribute.name}};
{% endfor %}{% for attribute in class.attributes %}
	{{attribute.visibility}} void set{{attribute.name | capitalize_first}}({{attribute.type | java}} {{attribute.name}}) {
		this.{{attribute.name}} = {{attribute.name}};
	}

	{{attribute.visibility}} {{class.name}} with{{attribute.name | capitalize_first}}({{attribute.type | java}} {{attribute.name}}) {
		this.set{{attribute.name | capitalize_first}}({{attribute.name}});
		return this;
	}	

	{{attribute.anotatios}}{{attribute.visibility}} {{attribute.type | java}} get{{attribute.name | capitalize_first}}() {
		return this.{{attribute.name}};
	}{% endfor %}

}{% endif %}