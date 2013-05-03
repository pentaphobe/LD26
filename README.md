## My LudumDare-26 entry 

### Journal

#### 1:30pm 
	- I'm still brainstorming, but taking a break to just get the environment all set up and clean.
	
#### 4pm 
	- Got a generic state machine which will be used for UI, sub-game state and Actors
	- up next: add simple level map and a base actor for movement test
		- skipping any pathfinding for now, it can be added as a bonus if I'm a good code monkey

#### 5:30pm
	- Trying to keep things as data-oriented as possible without getting caught up on architecture too much.
		- the idea is that I get the code nailed down in the next couple of hours, then spend the remaining time on
		  art, music and balancing


#### 9:50pm
	- Heaps of changes, but I'll save an update for after this frantic sprint / bug finding mission
	- Will have to do a bit of cleanup soon, as aspects of the control flow are getting fuzzy
	- STUFF I DIDN'T WRITE EARLIER
		- menus work nicely, and are defined with json so it's pretty easy to beef 'em up
		- adding actors
		- constrained-time for AI player
		- finer grained time for Agent system

#### ~11:30pm
	- added basic actor selection
	- basic movement orders
	- fixed some state machine issues
	- actors tween a bit too
	- added a scrolling background test

#### 1:15am
	- now have (proper) RTS style selection and movement
		- had to patch HaxePunk in order to get an immediate mode non-filled rectangle, as a result this won't run without my patches
			I'll post my version in github too
	- tweening is going to need work as the internal tweens in HaxePunk aren't really suited to this (no pausing for example)
		- likely just going to do easing between current tile and next tile in our path

#### 5:30am
	- getting tired.  the electronic music I'm listening to just did a vinyl stop and I thought I was stroking out
	- things are looking pretty good.  there are definitely a few things going a little weird though :)

#### 6:53am (the next day)
	- whoops. journal.  yeah.. that thing.
	- back on track after a major refactor
	- gonna eat Pho, have a cuppa, maybe shower and then launch into the final sprint of:
		- art
		- particles (and juicy things)
		- music / sound
		... not much for 5 hours..  should be fine

### To Do (misc QA as I find it)
	- "back" option in About menu takes you to the game instead of back to the Main Menu
	- TutorialController isnt' hooked into the server as I rushed through and used string events instead should follow the original design:
		- is a ServerEventHandler and registers with the server
		- also provides a function for receiving client events
		- now go delete all that cruft from elsewhere :)
	- Need end-stage
	- perhaps add a list of locks for each level set?  eg. stage2 requires stage1 complete
	- Obviously a level-select screen

	- eventually:  
		- some kind of barriers
		- some kind of static enemies with high power
		- some limiting of shooting range per unit

### Notes

Theme this time is **Minimalist** which seems mightily redundant for a 48-hr compo :)

But hey, at least [we have someone to blame!](http://www.ludumdare.com/compo/2013/04/26/you-need-a-scapegoat/) (good on you klianc09 for taking the bullet and also reassuring everyone :)



