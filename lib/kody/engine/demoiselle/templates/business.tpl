package {{project_business_package}};

import br.gov.frameworkdemoiselle.stereotype.BusinessController;
import br.gov.frameworkdemoiselle.template.DelegateCrud;

import {{class.package}}.{{class.name}};
import {{project_persistence_package}}.{{class.name}}DAO;

@BusinessController
public class {{class.name}}BC extends DelegateCrud<{{class.name}}, Long, {{class.name}}DAO> {
	
	private static final long serialVersionUID = 1L;
	
}
