package {{class.view_package}};

import javax.inject.Inject;

import br.gov.frameworkdemoiselle.annotation.PreviousView;
import br.gov.frameworkdemoiselle.stereotype.ViewController;
import br.gov.frameworkdemoiselle.template.AbstractEditPageBean;
import br.gov.frameworkdemoiselle.transaction.Transactional;

import {{class.business_package}}.{{class.name}}BC;
import {{class.package}}.{{class.name}};

@ViewController
@PreviousView("./{{class.underscore_name}}_list.xhtml")
public class {{class.name}}EditMB extends AbstractEditPageBean<{{class.name}}, Long> {

	private static final long serialVersionUID = 1L;

	@Inject
	private {{class.name}}BC {{class.underscore_name}}BC;

	@Override
	@Transactional
	public String delete() {
		this.{{class.underscore_name}}BC.delete(getId());
		return getPreviousView();
	}

	@Override
	@Transactional
	public String insert() {
		this.{{class.underscore_name}}BC.insert(getBean());
		return getPreviousView();
	}

	@Override
	@Transactional
	public String update() {
		this.{{class.underscore_name}}BC.update(getBean());
		return getPreviousView();
	}

	@Override
	protected void handleLoad() {
		setBean(this.{{class.underscore_name}}BC.load(getId()));
	}

}
