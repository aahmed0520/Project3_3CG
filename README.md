# Project3_3CG

Programming Patterns:

1. Game Loop
Definition: The core loop that keeps the game running by updating game logic and drawing frames every tick.
Use: Implemented in love.update(dt) and love.draw(). It handles card dragging, animation updates, and turn logic, ensuring the game state updates consistently every frame.

2. Command
Definition: Encapsulates actions as objects so they can be executed, queued, or undone.
Use: The processTurn() function acts as a command processor, queuing the player’s and AI’s card plays, then revealing and resolving them in a predictable order. This structure would allow for undo or replay features in future.

3. State
Definition: Allows an object to change its behavior when its internal state changes.
Use: Cards have distinct states: in deck, in hand, dragged, placed, revealed. These states affect how they're drawn and interactable (e.g., only draggable in hand, only revealed after Submit). Similarly, the game itself switches between title screen, gameplay, and victory screen states.

4. Observer
Definition: Lets parts of the system listen for changes in state and respond accordingly.
Use: The score and mana displays update reactively when card plays or turn changes happen. While not implemented as an event system, the logic mimics the observer pattern: changes in game data are reflected immediately in the UI.

5. Flyweight
Definition: Reduces memory use by sharing common data between objects.
Use: The cardPool stores base data for all cards (name, cost, power, effect text). Each card in the deck is instantiated from this shared data, avoiding redundant definitions.

6. Update Method
Definition: Each object has its own update method to manage its behavior.
Use: While not explicitly implemented per object, the selected card’s movement is handled through continuous position updates each frame in love.update(). This pattern could be extended to support animations or card effects over time.

7. Singleton / Centralized Control
Definition: Ensures a single instance of a class exists and provides global access.
Use: The AI system, card restrictions, and game configuration (like win conditions or location names) are stored in central tables like AI, cardRestrictions, and cardPool, acting as globally accessible data managers.


I think I did a great job creating the base game. I also was able to create AI players that can simulate playing this game properly. I think I could have made the game itself more advanced and better looking with more time. I think I will improve upon this game for the next project and have a product I am fully proud of with a little more advancements.
