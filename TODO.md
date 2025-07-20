# fplot.fnl TODO List

## High Priority (Critical for Production)

1. **Add comprehensive input validation**
   - Validate gnuplot executable exists and is accessible
   - Validate data structure formats before processing
   - Add type checking for all option parameters
   - Validate file paths and permissions for output files

2. **Implement robust error handling**
   - Replace assertions with proper error messages and graceful degradation
   - Handle gnuplot execution failures with meaningful error reporting
   - Add fallback behavior for missing dependencies
   - Implement timeout handling for long-running gnuplot processes

3. **Add unit test suite**
   - Test data formatting functions with various input types
   - Test option merging and command generation
   - Test multiplot functionality
   - Add integration tests with actual gnuplot execution
   - Test edge cases and error conditions

4. **Improve temporary file management**
   - Add proper cleanup on script failure or interruption
   - Implement configurable temp directory location
   - Add unique naming to prevent conflicts in concurrent usage
   - Consider using proper temp file APIs if available

## Medium Priority (Quality of Life Improvements)

5. **Performance optimizations**
   - Optimize string concatenation patterns (use table.concat consistently)
   - Cache expensive operations like option parsing
   - Implement lazy evaluation for data formatting
   - Consider streaming large datasets instead of loading into memory

6. **Enhance API ergonomics**
   - Add convenience functions for common plot types (scatter, histogram, etc.)
   - Implement method chaining for plot configuration
   - Add data validation helpers
   - Create preset configurations for common use cases

7. **Extend gnuplot feature coverage**
   - Add support for more terminal types
   - Implement animation/gif output support
   - Add support for custom gnuplot functions and variables
   - Implement polar plot support

8. **Improve debugging and logging**
   - Add configurable logging levels
   - Implement debug mode with verbose output
   - Add option to preserve temporary files for debugging
   - Better error messages with context and suggestions

## Low Priority (Nice to Have)

9. **Documentation improvements**
   - Document performance characteristics and limitations

10. **Cross-platform compatibility**
    - Test and fix Windows-specific path handling
    - Add support for different gnuplot installations
    - Handle platform-specific terminal differences
    - Add macOS-specific optimizations

11. **Advanced plotting features**
    - Add statistical plotting functions (regression lines, error bars)

12. **Code organization refactoring**
    - Break down large functions into smaller, focused ones
    - Implement a proper configuration object/class
    - Separate core plotting logic from gnuplot-specific code
    - Add plugin architecture for extensibility

## Future Considerations

13. **Alternative backend support**
    - Abstract plotting interface to support multiple backends
    - Add matplotlib/Python integration option
    - Consider web-based plotting backends
    - Implement SVG/Canvas direct output

14. **Interactive features**
    - Enhanced interactive controls (sophisticated mouse/keyboard bindings)
    - Session management utilities (helpers to manage multiple persistent plots)

15. **Data processing enhancements**
    - Add built-in statistical functions
    - Implement data transformation utilities
    - Add support for time series data
    - Implement data filtering and aggregation helpers
