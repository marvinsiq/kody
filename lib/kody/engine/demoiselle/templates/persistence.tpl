package {{project_persistence_package}};

import br.gov.frameworkdemoiselle.stereotype.PersistenceController;
import br.gov.frameworkdemoiselle.template.JPACrud;

import {{class.package}}.{{class.name}};

@PersistenceController
public class {{class.name}}DAO extends JPACrud<{{class.name}}, Long> {
	
	private static final long serialVersionUID = 1L;
	
}
