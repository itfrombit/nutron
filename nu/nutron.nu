
(global inspect
	(macro _nutroninspect (item)
		`(Nutron inspect:,item withName:,(item stringValue))))
		
(global select-view
	(function nutron-select-view ()
		(Nutron selectView)))
		
(global inspect-class
	(function nutron-inspect-class (name)
		(Nutron viewClass:name)))
		
(global outline-class
	(function nutron-outline-class (name)
		(Nutron outlineClass:name)))

(global console
	(function nutron-console ()
		(Nutron console)))

(global nutron
	(function nutron-nutron ()
		(Nutron nutronWithObject:nil andName:nil)))

(global nutron-with-parser
	(function nutron-nutron-with-parser (parser)
		(Nutron nutronWithParser:parser)))