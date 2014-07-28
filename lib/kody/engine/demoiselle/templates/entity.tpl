{%if class.stereotype == "entity" %}package {{class.package}};

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;{% if class.extends == null %}
import java.io.Serializable;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;{% endif %}{% for import in class.imports %}
import {{import}};{% endfor %}

/**
 * {{class.name}}
 */
@Entity
@Table(name = "{{class.table_name}}"){% for annotation in class.annotations %}
{{annotation}}{% endfor %}{% if class.extends == null %}
@SequenceGenerator(name = "{{class.sequence_name}}", sequenceName = "{{class.sequence_name}}"){% endif %}
public class {{class.name}}{% if class.extends != null %} extends {{class.extends}}{% else %} implements Serializable{% endif %} {

	private static final long serialVersionUID = 1L;{% if class.extends == null %}

	@Id
	@GeneratedValue(strategy = GenerationType.AUTO, generator = "{{class.sequence_name}}")
	private Long id;
{% endif %}
{% for attribute in class.attributes %}	{% for annotation in attribute.annotations %}{{annotation}}
	{% endfor %}private {% if attribute.is_enum %}{{attribute.enum_type}}{% else %}{{attribute.type}}{% endif %} {{attribute.name}}{% if attribute.initial_value != "" %} = {{attribute.initial_value}}{% endif %};

{% endfor %}{% for ass in class.relations %} {% for annotation in ass.annotations %}	{{annotation}}
{% endfor %}	private {{ass.att_type}} {{ass.name}}{{ass.initialize}};

{% endfor %}{% if class.extends == null %}	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}{% endif %}{% for attribute in class.attributes %}
	{{attribute.visibility}} void set{{attribute.name | capitalize_first}}({{attribute.type | java}} {{attribute.name}}) {
		{% if attribute.is_enum %}this.{{attribute.name}} = {{attribute.name}}.getValue();{% else %}this.{{attribute.name}} = {{attribute.name}};{% endif %}
	}

	{{attribute.visibility}} {{class.name}} with{{attribute.name | capitalize_first}}({{attribute.type | java}} {{attribute.name}}) {
		this.set{{attribute.name | capitalize_first}}({{attribute.name}});
		return this;
	}	

	{{attribute.anotatios}}{{attribute.visibility}} {{attribute.type | java}} get{{attribute.name | capitalize_first}}() {
		{% if attribute.is_enum %}return {{attribute.type | java}}.valueOf(this.{{attribute.name}});{% else %}return this.{{attribute.name}};{% endif %}
	}
	{% endfor %}{% for ass in class.relations %}
	{{ass.visibility}} void set{{ass.name | capitalize_first}}({{ass.att_type}} {{ass.name}}) {
		this.{{ass.name}} = {{ass.name}};
	}

	{{ass.visibility}} {{ass.att_type}} get{{ass.name | capitalize_first}}() {
		return this.{{ass.name}};
	}
	{% endfor %}	
}{% endif %}