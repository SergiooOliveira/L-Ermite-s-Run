# L'Ermite's Run

## Game concept
*L'Ermite's Run* is an endless dungeon crawler disguised as a dark, drag-and-drop Solitaire game. You play as a solitary Hermit navigating a shadowy crypt by stacking cards. It combines the familiar puzzle-solving of Solitaire with tense, survival-RPG resource management. Weapons and armor are persistent physical cards that degrade with every hit, forcing agonizing tactical choices as you fight to escape a crypt that is constantly collapsing around you.

## Gameplay loop
* **The Deal:** The crypt is dealt into standard columns. Top cards are illuminated; the rest are in the shadows.
* **Organize & Reveal:** Drag and drop illuminated cards to stack them in descending order and alternating colors. This organizes your board and reveals the hidden cards beneath.
* **Navigate Blockers:** Monsters (Spades/Clubs) are solid objects. You cannot stack cards on top of them, forcing you to build around them or fight them to clear the column.
* **Engage (RPG Combat):** Drag exposed cards to your Hermit Slot to consume them. 
    * *Clubs/Diamonds:* Equip as Weapons/Armor. You cannot unequip them; you must shatter them in combat to free up the slot.
    * *Spades:* Fight monsters. Damage chips away your Weapon, then Armor, then HP.
    * *Hearts:* Consume to heal HP.
* **Survive the Doom:** Every 5 successful moves, the crypt shifts, dealing a new card to the top of every column. If a column exceeds 6 cards, it overflows—the bottom card falls off the screen and auto-triggers its effect on the Hermit.
* **Escape:** Move cards to Foundation piles to earn Gold. Clearing the board plunges you into a new, harder floor.

## Technical approach
* **Framework:** 100% 2D SpriteKit using Swift. 
* **Input Handling:** Custom drag-and-drop by overriding `touchesBegan`, `touchesMoved`, and `touchesEnded` in the main `SKScene`.
* **Dual Hit-Testing:** Touch logic checks for two distinct drop zones: Column/Foundation drops (validates Solitaire math) and Hermit drops (triggers RPG math and deletes the node).
* **Data-Driven Architecture:** SpriteKit physics/collisions will *not* be used to govern rules. The game state is strictly controlled by pure Swift arrays and integer pools. A successful drop updates the arrays first, and then triggers visual `SKAction` movements and label updates.
* **Dynamic UI:** Because cards act as degrading health pools, `SKSpriteNode` cards will feature child `SKLabelNodes` that dynamically update their text during combat calculations.

## MVP scope
* **Week 1 (Foundation):** Build pure Swift data models (Card structs, Deck, Column arrays). Render basic card nodes on screen.
* **Week 2 (Drag System):** Implement touch tracking. Ensure a dragged card snaps back to its original position if dropped in an invalid space.
* **Week 3 (Solitaire Rules):** Implement valid column hit-testing, stack-dragging, and the "Blocker" rule that rejects drops onto Black suits.
* **Week 4 (Persistent Math):** Build the Hermit slot. Implement the combat math (Weapon blocks first, then Armor, then HP) and the "No Overwrite" equipment rule. Add the Game Over state.
* **Week 5 (The Crypt Shifts):** Implement the 5-move turn counter. Write the logic that appends a new card to every column, and the Overflow logic that damages the player if a column exceeds 6 cards. 
* **Week 6 (The Loop):** Implement Foundation piles. Write the logic that detects a cleared board, increments difficulty, and instantly deals a new floor.

## Future ideas
* **Joker Assassinations:** Add two Jokers to the deck that can be dragged onto any card to instantly destroy it with zero negative effects.
* **The Hermit's Shop:** Implement a store between floors where players can spend earned Gold to purchase permanent max HP upgrades, permanent damage buff, guarantee a shield at the start of the next run.
* **Visual Polish:** Add particle emitters (`SKEmitterNode`) for when a weapon shatters or a potion is consumed.
