# TODO: fplot

 _Format: [todomd.org template](https://github.com/todomd/todo.md)_

---

### Todo

- [ ] Add comprehensive input validation #feat #high
  - [ ] Validate gnuplot executable exists and is accessible
  - [ ] Add type checking for all option parameters
  - [ ] Validate file paths and permissions for output files
- [ ] Implement robust error handling #feat #high
  - [ ] Replace assertions with proper error messages and graceful degradation
  - [ ] Handle gnuplot execution failures with meaningful error reporting
  - [ ] Add fallback behavior for missing dependencies
  - [ ] Implement timeout handling for long-running gnuplot processes
- [ ] Add unit test suite #test #high
  - [ ] Test data formatting functions with various input types
  - [ ] Test option merging and command generation
  - [ ] Test multiplot functionality
  - [ ] Add integration tests with actual gnuplot execution
  - [ ] Test edge cases and error conditions
- [ ] Improve temporary file management #feat #high
  - [ ] Add proper cleanup on script failure or interruption
  - [ ] Consider using proper temp file APIs if available
- [ ] Performance optimizations #perf
  - [ ] Cache expensive operations like option parsing
  - [ ] Implement lazy evaluation for data formatting
  - [ ] Consider streaming large datasets instead of loading into memory
- [ ] Enhance API ergonomics #feat
  - [ ] Add convenience functions for common plot types (scatter, histogram, etc.)
  - [ ] Implement method chaining for plot configuration
  - [ ] Add data validation helpers
  - [ ] Create preset configurations for common use cases
- [ ] Extend gnuplot feature coverage #feat
  - [ ] Implement animation/gif output support
  - [ ] Implement polar plot support
- [ ] Improve debugging and logging #feat
  - [ ] Add configurable logging levels
  - [ ] Implement debug mode with verbose output
  - [ ] Add option to preserve temporary files for debugging
  - [ ] Better error messages with context and suggestions
- [ ] Document performance characteristics and limitations #docs #low
- [ ] Cross-platform compatibility #low
  - [ ] Add support for different gnuplot installations
  - [ ] Handle platform-specific terminal differences
  - [ ] Add macOS-specific optimizations
- [ ] Add statistical plotting functions (regression lines, error bars) #feat #low
- [ ] Code organization refactoring #refactor #low
  - [ ] Break down large functions into smaller, focused ones
  - [ ] Implement a proper configuration object/class
  - [ ] Separate core plotting logic from gnuplot-specific code
  - [ ] Add plugin architecture for extensibility
- [ ] Alternative backend support #future
  - [ ] Abstract plotting interface to support multiple backends
  - [ ] Add matplotlib/Python integration option
  - [ ] Consider web-based plotting backends
  - [ ] Implement SVG/Canvas direct output
- [ ] Interactive features #future
  - [ ] Enhanced interactive controls (sophisticated mouse/keyboard bindings)
  - [ ] Session management utilities (helpers to manage multiple persistent plots)
- [ ] Data processing enhancements #future
  - [ ] Add built-in statistical functions
  - [ ] Implement data transformation utilities
  - [ ] Add support for time series data
  - [ ] Implement data filtering and aggregation helpers

### In Progress
   - [ ] Validate data structure formats before processing #feat #high
   - [ ] Implement configurable temp directory location #feat #high
   - [ ] Add unique naming to prevent conflicts in concurrent usage #feat
      - _n.b.,_ `math.random 1000000` is used, but `math.randomseed` is never called, so every cold start produces the same sequence.
   - [ ] Optimize string concatenation patterns (use table.concat consistently) #perf
      - _n.b.,_ `safe-concat`/`table.concat` are used consistently in most places, but `..` concatenation still appears inside `option->cmd`.

### Done ✓
  - [x] Add support for more terminal types #low
  - [x] Test and fix Windows-specific path handling #low
  - [x] Add support for custom gnuplot functions and variables
   - This was added as the `extra-opts` in config.