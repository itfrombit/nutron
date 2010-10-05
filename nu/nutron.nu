
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
