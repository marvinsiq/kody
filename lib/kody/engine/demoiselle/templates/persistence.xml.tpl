<?xml version="1.0" encoding="UTF-8"?>
<persistence version="2.0" xmlns="http://java.sun.com/xml/ns/persistence" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://java.sun.com/xml/ns/persistence http://java.sun.com/xml/ns/persistence/persistence_2_0.xsd">

	<persistence-unit name="bookmark-ds" transaction-type="RESOURCE_LOCAL">

{% for entity in classes %}		<class>{{entity.package}}.{{entity.name}}</class>
{% endfor %}
	  <properties>	  
			<property name="javax.persistence.jdbc.driver" value="org.postgresql.Driver" />
			<property name="javax.persistence.jdbc.user" value="postgres" />
			<property name="javax.persistence.jdbc.password" value="postgres" />
			<property name="javax.persistence.jdbc.url" value="jdbc:postgresql://localhost:5432/teste" />	  
	  
			<property name="hibernate.dialect" value="org.hibernate.dialect.PostgreSQLDialect"/>
			<property name="hibernate.hbm2ddl.auto" value="validate"/>
			<property name="hibernate.show_sql" value="true"/>
			<property name="hibernate.format_sql" value="true"/>
	  </properties>	  

	</persistence-unit>

</persistence>