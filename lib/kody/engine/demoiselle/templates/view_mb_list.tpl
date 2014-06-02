package {{class.view_package}};

import java.util.Iterator;
import java.util.List;

import javax.inject.Inject;

import br.gov.frameworkdemoiselle.annotation.NextView;
import br.gov.frameworkdemoiselle.annotation.PreviousView;
import br.gov.frameworkdemoiselle.stereotype.ViewController;
import br.gov.frameworkdemoiselle.template.AbstractListPageBean;
import br.gov.frameworkdemoiselle.transaction.Transactional;

import {{class.business_package}}.{{class.name}}BC;
import {{class.package}}.{{class.name}};

@ViewController
@NextView("./{{class.underscore_name}}_edit.xhtml")
@PreviousView("./{{class.underscore_name}}_list.xhtml")
public class {{class.name}}ListMB extends AbstractListPageBean<{{class.name}}, Long> {

	private static final long serialVersionUID = 1L;

	@Inject
	private {{class.name}}BC bc;

	@Override
	protected List<{{class.name}}> handleResultList() {
		return this.bc.findAll();
	}

	@Transactional
	public String deleteSelection() {
		boolean delete;
		for (Iterator<Long> iter = getSelection().keySet().iterator(); iter.hasNext();) {
			Long id = iter.next();
			delete = getSelection().get(id);

			if (delete) {
				bc.delete(id);
				iter.remove();
			}
		}
		return getPreviousView();
	}

}
