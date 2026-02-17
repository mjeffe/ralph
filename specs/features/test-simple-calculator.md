# Test Specification: Simple Calculator

## Overview

This is a test specification to validate the Ralph Wiggum Loop system. It defines a simple calculator library that will be implemented by Ralph in build mode to verify all system components work correctly.

## Purpose

- Validate Ralph loop creates IMPLEMENTATION_PLAN.md from specs
- Verify task execution and completion tracking
- Test PROGRESS.md updates
- Confirm git commits and pushes work correctly
- Validate all core infrastructure components

## Requirements

### Calculator Module

Create a simple calculator module in `src/lib/calculator.js` with the following functions:

**Basic Operations:**
- `add(a, b)` - Returns sum of two numbers
- `subtract(a, b)` - Returns difference of two numbers
- `multiply(a, b)` - Returns product of two numbers
- `divide(a, b)` - Returns quotient of two numbers
  - Should throw error if dividing by zero

**Input Validation:**
- All functions should validate that inputs are numbers
- Throw TypeError if non-numeric inputs provided

**Module Export:**
- Export all functions as named exports
- Use CommonJS format (module.exports)

### Tests

Create test file `src/lib/calculator.test.js` with comprehensive test coverage:

**Test Cases Required:**
- Addition: positive numbers, negative numbers, zero
- Subtraction: positive numbers, negative numbers, zero
- Multiplication: positive numbers, negative numbers, zero, by one
- Division: positive numbers, negative numbers, by one
- Division by zero: should throw error
- Invalid inputs: should throw TypeError for non-numeric inputs

**Test Framework:**
- Use Node.js built-in `assert` module (no external dependencies)
- Simple test runner that can be executed with `node src/lib/calculator.test.js`
- Tests should output clear pass/fail messages
- Exit with code 0 if all pass, non-zero if any fail

### Documentation

Update `README.md` to include:
- Calculator module in project structure
- How to run calculator tests
- Example usage of calculator functions

## Success Criteria

- [ ] Calculator module implemented with all required functions
- [ ] All functions have proper input validation
- [ ] Test file created with comprehensive coverage
- [ ] All tests pass when executed
- [ ] Documentation updated in README.md
- [ ] Code follows existing project patterns
- [ ] IMPLEMENTATION_PLAN.md properly maintained
- [ ] PROGRESS.md updated with completed tasks
- [ ] Git commits follow ralph commit message format

## Implementation Notes

**Keep it Simple:**
- This is a test specification, not a production feature
- Focus on validating Ralph system functionality
- No need for advanced calculator features
- Basic error handling is sufficient

**Expected Task Breakdown:**
Ralph should break this into approximately 3-4 tasks:
1. Create calculator module with basic operations
2. Add input validation and error handling
3. Create comprehensive test suite
4. Update documentation

**Validation:**
After implementation, verify:
- `node src/lib/calculator.test.js` runs successfully
- All tests pass
- Code is clean and well-structured
- Documentation is clear

## Example Usage

```javascript
const { add, subtract, multiply, divide } = require('./calculator');

// Basic operations
console.log(add(5, 3));        // 8
console.log(subtract(10, 4));  // 6
console.log(multiply(3, 7));   // 21
console.log(divide(15, 3));    // 5

// Error cases
try {
    divide(10, 0);  // Throws error
} catch (e) {
    console.error(e.message);
}

try {
    add('5', 3);  // Throws TypeError
} catch (e) {
    console.error(e.message);
}
```

## Test Output Example

```
Running calculator tests...
✓ add: positive numbers
✓ add: negative numbers
✓ add: with zero
✓ subtract: positive numbers
✓ subtract: negative numbers
✓ multiply: positive numbers
✓ multiply: by zero
✓ divide: positive numbers
✓ divide: by one
✓ divide: by zero throws error
✓ invalid input: non-numeric throws TypeError

All tests passed! (11/11)
```
