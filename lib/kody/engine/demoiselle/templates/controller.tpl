package {{controller.package}};

import br.gov.frameworkdemoiselle.stereotype.ViewController;
import br.gov.frameworkdemoiselle.template.AbstractPageBean;

@ViewController
public class {{controller.name}} extends AbstractPageBean {

	private static final long serialVersionUID = 1L;

{% for parameter in controller.parameters %}	{% for annotation in parameter.annotations %}{{annotation}}
	{% endfor %}private {{parameter.type}} {{parameter.name}};
{% endfor %}{% for parameter in controller.parameters %}
	{{parameter.visibility}} void set{{parameter.name | capitalize_first}}({{parameter.type | java}} {{parameter.name}}) {
		this.{{parameter.name}} = {{parameter.name}};
	}

	{{parameter.anotatios}}{{parameter.visibility}} {{parameter.type | java}} get{{parameter.name | capitalize_first}}() {
		return this.{{parameter.name}};
	}
	{% endfor %}{% for operation in controller.operations %}
	{{operation.visibility}} {{operation.return_type}} {{operation.name}}() {
		// TODO
	}
	{% endfor %}
}
