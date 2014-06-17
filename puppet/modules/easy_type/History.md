History
========

30-12-2013  Inital version based on extraction of common code
            from Oracle types for prorail deployment

12-01-2014	Version 0.2.0. Added support for having multiple before and after commands in
						the CommandBuilder.Added support for getting the property_hash and the property_flush
						Added support for including parameter and property file
						pass the commandbuilder in the on_apply function

16-02-2014	Renamed all to easy_type. It fits the purpose better

19-02-2014	Started using the CSV parser class for parsing the CSV's. 

24-05-2014  Version 0.8.0. Added support for daemon's for slow external utilities to be used on multiple types. 

02-06-2014  Version 0.8.1. Added support for defining your own pass and fail strings in the Daemon's sync.
