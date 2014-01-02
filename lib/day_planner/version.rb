module DayPlanner
	MAJOR = 0
	MINOR = 1
	TINY  = 0
	PRE   = "pre12"
	BUILD = nil

  VERSION = [MAJOR, MINOR, TINY, PRE, BUILD].compact.join(".")
end
