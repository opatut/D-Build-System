# ToDo

- Error Handling, nice outputs
- Re-link if dependencies changed
- Partial compiling
- Intelligent module recognition

# Compilation process

- Load / Create Dependencies, Externals and Targets
- Prepare() the dependency tree upwards

## Target compilation

- Create a list of all Modules
- Push compiler commands in a queue
- Start n Workers, each Worker will be restarted with other commands from the queue when finished
- Finish when the queue is empty and no Worker is running anymore


INTERFACE Dependency:
  bool build();
  bool requiresBuilding(); // also returns true if already built

CLASS External:

CLASS DTarget:
  bool build(); //