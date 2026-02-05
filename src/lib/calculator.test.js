/**
 * Test Suite for Calculator Module
 * 
 * Uses Node.js built-in assert module for testing
 * Run with: node src/lib/calculator.test.js
 */

const assert = require('assert');
const { add, subtract, multiply, divide } = require('./calculator');

// Test counter
let passed = 0;
let failed = 0;

/**
 * Simple test runner
 */
function test(description, fn) {
  try {
    fn();
    console.log(`✓ ${description}`);
    passed++;
  } catch (error) {
    console.error(`✗ ${description}`);
    console.error(`  ${error.message}`);
    failed++;
  }
}

// Addition Tests
test('add: positive numbers', () => {
  assert.strictEqual(add(5, 3), 8);
  assert.strictEqual(add(10, 20), 30);
});

test('add: negative numbers', () => {
  assert.strictEqual(add(-5, -3), -8);
  assert.strictEqual(add(-10, 5), -5);
});

test('add: with zero', () => {
  assert.strictEqual(add(0, 5), 5);
  assert.strictEqual(add(5, 0), 5);
  assert.strictEqual(add(0, 0), 0);
});

// Subtraction Tests
test('subtract: positive numbers', () => {
  assert.strictEqual(subtract(10, 3), 7);
  assert.strictEqual(subtract(20, 5), 15);
});

test('subtract: negative numbers', () => {
  assert.strictEqual(subtract(-5, -3), -2);
  assert.strictEqual(subtract(5, -3), 8);
});

test('subtract: with zero', () => {
  assert.strictEqual(subtract(5, 0), 5);
  assert.strictEqual(subtract(0, 5), -5);
});

// Multiplication Tests
test('multiply: positive numbers', () => {
  assert.strictEqual(multiply(5, 3), 15);
  assert.strictEqual(multiply(7, 8), 56);
});

test('multiply: negative numbers', () => {
  assert.strictEqual(multiply(-5, 3), -15);
  assert.strictEqual(multiply(-4, -3), 12);
});

test('multiply: by zero', () => {
  assert.strictEqual(multiply(5, 0), 0);
  assert.strictEqual(multiply(0, 5), 0);
});

test('multiply: by one', () => {
  assert.strictEqual(multiply(5, 1), 5);
  assert.strictEqual(multiply(1, 5), 5);
});

// Division Tests
test('divide: positive numbers', () => {
  assert.strictEqual(divide(15, 3), 5);
  assert.strictEqual(divide(20, 4), 5);
});

test('divide: negative numbers', () => {
  assert.strictEqual(divide(-15, 3), -5);
  assert.strictEqual(divide(15, -3), -5);
  assert.strictEqual(divide(-15, -3), 5);
});

test('divide: by one', () => {
  assert.strictEqual(divide(5, 1), 5);
  assert.strictEqual(divide(100, 1), 100);
});

test('divide: by zero throws error', () => {
  assert.throws(
    () => divide(10, 0),
    {
      name: 'Error',
      message: 'Cannot divide by zero'
    }
  );
});

// Input Validation Tests
test('add: invalid input throws TypeError', () => {
  assert.throws(
    () => add('5', 3),
    {
      name: 'TypeError',
      message: 'Both arguments must be numbers'
    }
  );
  assert.throws(
    () => add(5, '3'),
    TypeError
  );
});

test('subtract: invalid input throws TypeError', () => {
  assert.throws(
    () => subtract('10', 3),
    TypeError
  );
  assert.throws(
    () => subtract(10, null),
    TypeError
  );
});

test('multiply: invalid input throws TypeError', () => {
  assert.throws(
    () => multiply(5, undefined),
    TypeError
  );
  assert.throws(
    () => multiply('5', 3),
    TypeError
  );
});

test('divide: invalid input throws TypeError', () => {
  assert.throws(
    () => divide(10, '2'),
    TypeError
  );
  assert.throws(
    () => divide([], 2),
    TypeError
  );
});

// Summary
console.log('\n' + '='.repeat(50));
if (failed === 0) {
  console.log(`All tests passed! (${passed}/${passed})`);
  process.exit(0);
} else {
  console.log(`Tests failed: ${failed}/${passed + failed} passed`);
  process.exit(1);
}
