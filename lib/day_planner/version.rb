module DayPlanner
	MAJOR = 0
	MINOR = 1
	TINY  = 0
	PRE   = "pre6"
	BUILD = 1

  VERSION = [MAJOR, MINOR, TINY, PRE, BUILD].compact.join(".")
end
