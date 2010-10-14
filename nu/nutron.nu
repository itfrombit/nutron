
(global nutron-inspect
	(macro _nutron-inspect (item)
		`(Nutron inspect:,item withName:,(item stringValue))))
		
(global nutron-select-view
	(function _nutron-select-view ()
		(Nutron selectView)))
		
(global nutron-inspect-class
	(function _nutron-inspect-class (name)
		(Nutron viewClass:name)))
		
(global nutron-outline-class
	(function _nutron-outline-class (name)
		(Nutron outlineClass:name)))

(global nutron-console
	(function _nutron-console ()
		(Nutron console)))

(global nutron
	(function _nutron ()
		(Nutron nutronWithObject:nil andName:nil)))

(global nutron-with-parser
	(function _nutron-with-parser (parser)
		(Nutron nutronWithParser:parser)))