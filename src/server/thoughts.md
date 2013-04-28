
Game Server:
	Lobby
		Level Sets
			mode name
			list of levels in this mode
		Current Level List

	World
		Current Level
			node tile map (not visual)
				
		Agents
			map pos
			map path
				target pos
			template
			changeable stats [hp, mp, ap]

			Event handlers
				- these define the behaviour of this Agent
					as a result these should be interchangable
					(ie. encapsulated in the Agent)
				- these events are also sent to the Player and to the View
				- note that these are notifications which allow the agent to change states
				  the agent does not directly manipulate their date (eg. subtracting hitpoints)

				onPathArrived
					arrived at destination
				onPathCancelled
					something cancelled our pathing, normally the user/AI
					but perhaps this gets called optionally by onHit etc..
				onPathBlocked
					if our path (within a short 
					distance) is blocked
				onHit (who, how hard?)
					someone hit me
				onTarget
					just a thought, perhaps make targeting non-blocking?
					can make for more convoluted logic code, but makes other
					stuff cleaner.

					
		
		Player
			- handles control of a group of agents
			- queries the world in order to make decisions
			team information
				list of agents
			Event handlers (same set as the agents)
			
			
			
			
			
	
	