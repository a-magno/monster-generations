extends RefCounted
class_name Level

enum GrowthTypes {FAST,MEDIUM_FAST,MEDIUM_SLOW,SLOW}

#region FUNCTIONS

static func fast( n ):
	return 0.8 * pow(n, 3)

static func medium_fast( n ):
	return pow(n, 3)

static func medium_slow( n ):
	return 1.2*pow(n, 3) - (15 * pow(n, 2)) + 100*n - 140

static func slow( n ):
	return 1.25 * pow(n, 3)

#endregion
