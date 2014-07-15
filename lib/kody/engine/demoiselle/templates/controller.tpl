package {{class.package}};

import br.gov.frameworkdemoiselle.stereotype.ViewController;
import br.gov.frameworkdemoiselle.template.AbstractPageBean;

@ViewController
public class {{class.name}} extends AbstractPageBean {

	private static final long serialVersionUID = 1L;

{% for attribute in class.attributes %}	{% for annotation in attribute.annotations %}{{annotation}}
	{% endfor %}private {{attribute.type}} {{attribute.name}};

{% endfor %}{% for operation in class.operations %}
	{{operation.visibility}} {{operation.return_type}} {{operation.name}}() {
		// TODO
	}
	{% endfor %}
}
