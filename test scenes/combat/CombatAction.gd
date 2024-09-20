class_name CombatAction extends RefCounted

enum Actions {FIGHT, USE_ITEM, SWITCH, RUN}

var actor
var target
var action : Resource
var type : Actions
var priority : float

func _init(_actor, _type : Actions, _target = null, _action : Resource = null ):
	actor = _actor
	target = _target
	action = _action
	type = _type
	priority = calculate_priority()

func as_data():
	return {
		"attacker": actor,
		"target" : target,
		"action": action,
		"priority": priority,
		"type": Actions.keys()[type]
	}

func execute():
	match(type):
		Actions.FIGHT: 
			if not action is BaseMove: return
			action.use_move(target, actor)
		Actions.USE_ITEM:
			if not action is Item: return
			action.use(actor)
		Actions.SWITCH:
			if not action is Monster: return
			actor.switch( action )
		Actions.RUN:
			if not actor.active: return
			actor.flee()
	return self

func calculate_priority():
	return action.priority if action is BaseMove else 1.0
