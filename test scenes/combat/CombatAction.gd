class_name CombatAction extends RefCounted

enum Actions {FIGHT, USE_ITEM, SWITCH, RUN}

var actor : Combatant
var target : Combatant
var action : Resource
var type : Actions
var priority : float

func _init(_actor : Combatant, _type : Actions, _target : Combatant = null, _action : Resource = null ):
	actor = _actor
	target = _target
	action = _action
	type = _type
	priority = calculate_priority()

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
	return 1.0
