
class Datatype

	def Datatype.java_type(type)
		types = {

			# UML Standard Profile
			'UML Standard Profile::boolean' => "boolean",
			'UML Standard Profile::byte' => "byte",
			'UML Standard Profile::char' => "char",
			'UML Standard Profile::date' => "java.util.Date",
			'UML Standard Profile::double' => "double",
			'UML Standard Profile::float' => "float",
			'UML Standard Profile::Integer' => "Integer",
			'UML Standard Profile::int' => "int",
			'UML Standard Profile::long' => "long",
			'UML Standard Profile::short' => "short",

			# AndroMda 3.1
			'datatype::Blob' => "java.sql.Blob",
			'datatype::boolean'  => "boolean",
			'datatype::Boolean'  => "Boolean",
			'datatype::boolean[]'  => "boolean[]",
			'datatype::Boolean[]'  => "Boolean[]",
			'datatype::byte'  => "byte",
			'datatype::Byte'  => "Byte",
			'datatype::Byte[]'  => "Byte[]",
			'datatype::byte[]'  => "byte[]",
			'datatype::char'  => "char",
			'datatype::char[]'  => "char[]",
			'datatype::Character'  => "Character",
			'datatype::Character[]'  => "Character[]",
			'datatype::Clob'  => "String",
			'datatype::Collection'  => "java.util.Collection",
			'datatype::Date'  => "java.util.Date",
			'datatype::Date[]'  => "java.util.Date[]",
			'datatype::DateTime'  => "java.util.Date",
			'datatype::DateTime[]'  => "java.util.Date[]",
			'datatype::Decimal'  => "java.math.BigDecimal",
			'datatype::Decimal[]'  => "java.math.BigDecimal[]",
			'datatype::Document'  => "org.w3c.dom.Document",
			'datatype::Double'  => "Double",
			'datatype::double'  => "double",
			'datatype::Double[]'  => "Double[]",
			'datatype::double[]'  => "double[]",
			'datatype::File'  => "java.io.File",
			'datatype::File[]'  => "java.io.File[]",
			'datatype::float'  => "float",
			'datatype::Float'  => "Float",
			'datatype::float[]'  => "float[]",
			'datatype::Float[]'  => "Float[]",
			'datatype::int'  => "int",
			'datatype::int[]'  => "int[]",
			'datatype::Integer'  => "Integer",
			'datatype::Integer[]'  => "Integer[]",
			'datatype::List'  => "java.util.List",
			'datatype::long'  => "long",
			'datatype::Long'  => "Long",
			'datatype::Long[]'  => "Long[]",
			'datatype::long[]'  => "long[]",
			'datatype::Map'  => "java.util.Map",
			'datatype::Mappings'  => "java.util.Map",
			'datatype::Money'  => "java.math.BigDecimal",
			'datatype::Object'  => "Object",
			'datatype::Object[]'  => "Object[]",
			'datatype::Set'  => "java.util.Set",
			'datatype::short'  => "short",
			'datatype::Short'  => "Short",
			'datatype::short[]'  => "short[]",
			'datatype::Short[]'  => "Short[]",
			'datatype::String'  => "String",
			'datatype::String[]'  => "String[]",
			'datatype::Time'  => "java.util.Date",
			'datatype::Time[]'  => "java.util.Date[]",
			'datatype::Timestamp'  => "java.util.Date",
			'datatype::Timestamp[]'  => "java.util.Date[]",
			'datatype::TreeNode'  => "Object",
			'datatype::URI'  => "java.net.URI",
			'datatype::URI[]'  => "java.net.URI[]",
			'datatype::URL'  => "java.net.URL",
			'datatype::URL[]'  => "java.net.URL[]",
			'datatype::void' => "void"
		}

		convert_type = types[type]
		convert_type = type if convert_type.nil?
		convert_type
	end

	def Datatype.short_java_type(type)
		 convert_type = Datatype.convert_type(type)
	end
end