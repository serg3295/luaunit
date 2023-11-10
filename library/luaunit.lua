---@meta

---@class luaunit
---@field EPS number The machine epsilon, to be used with `assertAlmostEquals()`.
---@field ORDER_ACTUAL_EXPECTED boolean #This boolean value defines the order of arguments in assertion functions.
---@field PRINT_TABLE_REF_IN_ERROR_MSG boolean #This controls whether table references are always printed along with table or not. See `table-printing`_ for details. The default is `false`.
---@field STRIP_EXTRA_ENTRIES_IN_STACK_TRACE integer #This controls how many extra entries in a stack-trace are stripped. The default is 0
---@field VERSION string
---@field VERBOSITY_QUIET integer
---@field VERBOSITY_LOW integer
---@field VERBOSITY_VERBOSE integer
luaunit = {}

---@class luaunit.LuaUnit
luaunit.LuaUnit = {}

---@class runner
local runner = {}

--- The execution of a LuaUnit test suite is controlled through a runner object. This object is created with `LuaUnit.new()`.
--[[
#### Example
```lua
  lu = require('luaunit')

  runner = lu.LuaUnit.new()
  -- use the runner object...
  runner.runSuite()
```
]]
---@return runner
function luaunit.LuaUnit.new() end

--- Set the verbosity of the runner. The value is an integer ranging from lu.VERBOSITY_QUIET to lu.VERBOSITY_VERBOSE.
---@param verbosity integer | `VERBOSITY_QUIET` | `VERBOSITY_LOW` |`VERBOSITY_VERBOSE`
function runner:setVerbosity(verbosity) end

--- Set the quit-on-first-error behavior, like the command-line `--xx`.
---@param quitOnError boolean
function runner:setQuitOnError(quitOnError) end

--- Set the quit-on-first-failure-or-error behavior, like the command-line `--xx`.
---@param quitOnFailure boolean
function runner:setQuitOnFailuer(quitOnFailure) end

--- Set the number of times a test function is executed, like the command-line `-xx`.
---@param repeatNumber integer
function runner:setRepeat(repeatNumber) end

--- Set whether the test are run in randomized, like the command-line `--shuffle`.
---@param shuffle boolean
function runner:setShuffle(shuffle) end

--- Set the output type of the test suite. See *`Output formats`* for possible values. When setting the format `junit`, it is mandatory to set the filename receiving the *xml* output. This can be done by passing it as second argument of this function.
---@param type string
---@param junit_fname? string
function runner:setOutputType(type, junit_fname) end

--[[
This function runs the test suite.

If no arguments are supplied, it parses the command-line arguments of the script and interpret them. If arguments are supplied to the function, they are parsed as the command-line. It uses the same syntax.
Test names may be supplied in arguments, to execute only these specific tests.

*Note* that when explicit names are provided LuaUnit does not require the test names to necessarily start with *test*.

If no test names were supplied, a general test collection process is done and the resulting tests are executed.

```lua
  lu = require('luaunit')

  runner = lu.LuaUnit.new()
  os.exit(runner.runSuite())
```
#### Example of using pattern to select tests:
```lua
  lu = require('luaunit')

  runner = lu.LuaUnit.new()
  -- execute tests matching the 'withXY' pattern
  os.exit(runner.runSuite('--pattern', 'withXY')
```
#### Example of explicitly selecting tests:
```lua
  lu = require('luaunit')

  runner = lu.LuaUnit.new()
  os.exit(runner.runSuite('testABC', 'testDEF'))
```
]]
---@param ... string
---@return integer #It returns the number of failures and errors. On success *0* is returned, making is suitable for an exit code.
function runner:runSuite(...) end

--[[
This function may be called directly from the LuaUnit table. It will create internally a LuaUnit runner and pass all arguments to it.\
If no arguments are supplied, it parses the command-line arguments of the script and interpret them. If arguments are supplied to the function, they are parsed as the command-line. It uses the same syntax.

Test names may be supplied in arguments, to execute only these specific tests. *Note* that when explicit names are provided LuaUnit does not require the test names to necessarily start with *test*.

If no test names were supplied, a general test collection process is done and the resulting tests are executed.
#### Example
```lua
  execute tests matching the 'withXY' pattern
  os.exit(lu.LuaUnit.run('--pattern', 'withXY'))
```
]]
---@param ... string
---@return integer #It returns the number of failures and errors. On success 0 is returned, making is suitable for an exit code.
function luaunit.LuaUnit.run(...) end

luaunit.run = luaunit.LuaUnit.run

---@alias listOfNameAndInstances table<string, function|table>

--[[
This function runs test without performing the global test collection process on the global namespace, the test are explicitely provided as argument, along with their names.

Before execution, the function will parse the script command-line, like `runner:runSuite()`.

Input is provided as a list of { name, test_instance } . test_instance can either be a function or a table containing test functions starting with the prefix "test".
#### Example of using runSuiteByInstances

```lua
  lu = require('luaunit')

  runner = lu.LuaUnit.new()
  os.exit(runner.runSuiteByInstances( {'mySpecialTest1', mySpecialTest1}, {'mySpecialTest2', mySpecialTest2} } )
]]
---@param tbl listOfNameAndInstances
---@param ... listOfNameAndInstances
function runner:runSuiteByInstances(tbl, ...) end

--- Stops the ongoing test and mark it as skipped with the given message. This can be used to deactivate a given test.
---@param message string
function luaunit.skip(message) end

--- If the condition **condition** evaluates to `true`, stops the ongoing test and mark it as skipped with the given message.\
--- Else, continue the test execution normally.\
--- The expected usage is to call the function at the beginning of the test to verify if the conditions are met for executing such tests.
---@param condition boolean
---@param message string
function luaunit.skipIf(condition, message) end

--- If condition evaluates to `false`, stops the ongoing test and mark it as skipped with the given message. This is the opposite behavior of `skipIf()`.\
--- The expected usage is to call the function at the beginning of the test to verify if the conditions are met for executing such tests.
---@param condition boolean
---@param message string
---@return integer #Number of skipped tests, if any, are reported at the end of the execution.
function luaunit.runOnlyIf(condition, message) end

--- Stops the ongoing test and mark it as failed with the given message.
---@param message string
function luaunit.fail(message) end

--- If the condition *condition* evaluates to `true`, stops the ongoing test and mark it as failed with the given message.\
--- Else, continue the test execution normally.
---@param condition boolean
---@param message string
function luaunit.failIf(condition, message) end

--- Stops the ongoing test and mark it as successful.
function luaunit.success() end

--- If the condition *condition* evaluates to `true`, stops the ongoing test and mark it as successful.\
--- Else, continue the test execution normally.
---@param condition boolean
function luaunit.successIf(condition) end

--[[
Assert that two values are equal. This is the most used function for assertion within LuaUnit.\
The values being compared may be integers, floats, strings, tables, functions or a combination of those.

When comparing floating point numbers, it is better to use `assertAlmostEquals` which supports a margin for the equality verification.

For tables, the comparison supports nested tables and cyclic structures. To be equal, two tables must have the same keys and the value associated with a key must compare equal with assertEquals() (using a recursive algorithm).

When displaying the difference between two tables used as lists, LuaUnit performs an analysis of the list content to pinpoint the place where the list actually differs. See the below example:
```lua
  -- lua test code. Can you spot the difference ?
  function TestListCompare:test1()
    local A = { 121221, 122211, 121221, 122211, 121221, 122212, 121212, 122112, 122121, 121212, 122121 }
    local B = { 121221, 122211, 121221, 122211, 121221, 122212, 121212, 122112, 121221, 121212, 122121 }
    lu.assertEquals( A, B )
  end
```

```bash

$ lua test_some_lists_comparison.lua

  TestListCompare.test1 ... FAIL
  test/some_lists_comparisons.lua:22: expected:

  List difference analysis:
  * lists A (actual) and B (expected) have the same size
  * lists A and B start differing at index 9
  * lists A and B are equal again from index 10
  * Common parts:
    = A[1], B[1]: 121221
    = A[2], B[2]: 122211
    = A[3], B[3]: 121221
    = A[4], B[4]: 122211
    = A[5], B[5]: 121221
    = A[6], B[6]: 122212
    = A[7], B[7]: 121212
    = A[8], B[8]: 122112
  * Differing parts:
    - A[9]: 122121
    + B[9]: 121221
  * Common parts at the end of the lists
    = A[10], B[10]: 121212
    = A[11], B[11]: 122121
```
*Note* see `comparing-table-keys-table` for information on comparison of tables containing keys of type table.

LuaUnit provides other table-related assertions, see `assert-table` .
]]
---@param actual any
---@param expected any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertEquals(actual, expected, extra_msg) end

luaunit.assert_equals = luaunit.assertEquals

---Assert that two values are different. The assertion fails if the two values are identical. It behaves exactly like `assertEquals` but checks for the opposite condition.
---@param actual any
---@param expected any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotEquals(actual, expected, extra_msg) end

luaunit.assert_not_equals = luaunit.assertNotEquals

--- Assert that a given value evals to `true`. Lua coercion rules are applied so that values like `0`, `""`, `1.17` **succeed** in this assertion.\
--- See `assertTrue` for a strict assertion to boolean `true`.
---@param value any
---@param extra_msg? string If provided, extra_msg is a string which will be printed along with the failure message.
function luaunit.assertEvalToTrue(value, extra_msg) end

luaunit.assert_eval_to_true = luaunit.assertEvalToTrue

--- Assert that a given value eval to `false`. Lua coercion rules are applied so that `nil` and `false`  **succeed** in this assertion.\
--- See `assertFalse` for a strict assertion to boolean `false`.
---@param value any
---@param extra_msg? string If provided, extra_msg is a string which will be printed along with the failure message.
function luaunit.assertEvalToFalse(value, extra_msg) end

luaunit.assert_eval_to_false = luaunit.assertEvalToFalse

--- Assert that a given value is strictly `true`. Lua coercion rules do not apply so that values like `0`, `""`, `1.17` **fail** in this assertion.\
--- See `assertEvalToTrue` for an assertion to `true` where Lua coercion rules apply.
---@param value any
---@param extra_msg? string If provided, extra_msg is a string which will be printed along with the failure message.
function luaunit.assertIsTrue(value, extra_msg) end

luaunit.assertTrue = luaunit.assertIsTrue
luaunit.assert_true = luaunit.assertIsTrue
luaunit.assert_is_true = luaunit.assertIsTrue

--- Assert that a given value is strictly `false`. Lua coercion rules do not apply so that `nil` **fails** in this assertion.\
--- See `assertEvalToFalse` for an assertion to `false` where Lua coertion fules apply.
---@param value any
---@param extra_msg? string If provided, extra_msg is a string which will be printed along with the failure message.
function luaunit.assertIsFalse(value, extra_msg) end

luaunit.assertFalse = luaunit.assertIsFalse
luaunit.assert_false = luaunit.assertIsFalse
luaunit.assert_is_false = luaunit.assertIsFalse

--- Assert that a given value is *nil*.
---@param value any
---@param extra_msg? string If provided, extra_msg is a string which will be printed along with the failure message.
function luaunit.assertIsNil(value, extra_msg) end

luaunit.assertNil = luaunit.assertIsNil
luaunit.assert_nil = luaunit.assertIsNil
luaunit.assert_is_nil = luaunit.assertIsNil

--- Assert that a given value is not *nil* . Lua coercion rules are applied so that values like `0`, `""`, `false` all validate the assertion.
---@param value any
---@param extra_msg? string If provided, extra_msg is a string which will be printed along with the failure message.
function luaunit.assertNotIsNil(value, extra_msg) end

luaunit.assertNotNil = luaunit.assertNotIsNil
luaunit.assert_not_nil = luaunit.assertNotIsNil
luaunit.assert_not_is_nil = luaunit.assertNotIsNil

--[[
Assert that two variables are identical. For string, numbers, boolean and for nil, this gives the same result as `assertEquals` . For the other types, identity means that the two variables refer to the same object.
#### Example :
```lua
  s1='toto'
  s2='to'..'to'
  t1={1,2}
  t2={1,2}
  v1=nil
  v2=false

  lu.assertIs(s1,s1) -- ok
  lu.assertIs(s1,s2) -- ok
  lu.assertIs(t1,t1) -- ok
  lu.assertIs(t1,t2) -- fail
  lu.assertIs(v1,v2) -- fail
```
]]
---@param actual any
---@param expected any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertIs(actual, expected, extra_msg) end

luaunit.assert_is = luaunit.assertIs

--- Assert that two variables are not identical, in the sense that they do not refer to the same value.\
--- See `assertIs` for more details.
---@param actual any
---@param expected any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotIs(actual, expected, extra_msg) end

luaunit.assert_not_is = luaunit.assertNotIs

--- Assert that the string *str* contains the substring or pattern *sub*.
---
--- By default, substring is searched in the string. If *isPattern* is provided and is `true`, *sub* is treated as a pattern which is searched inside the string *str* .
---@param str string
---@param sub string
---@param isPattern? boolean
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertStrContains(str, sub, isPattern, extra_msg) end

luaunit.assert_str_contains = luaunit.assertStrContains

--- Assert that the string *str* contains the given substring *sub*, irrespective of the case.
---
--- *Note* that unlike `assertStrcontains`, you can not search for a pattern.
---@param str string
---@param sub string
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertStrIContains(str, sub, extra_msg) end

luaunit.assert_str_icontains = luaunit.assertStrIContains

--- Assert that the string *str* does not contain the substring or pattern *sub*.
---
--- By default, the substring is searched in the string. If *isPattern* is provided and is true, *sub* is treated as a pattern which is searched inside the string *str* .
---@param str string
---@param sub string
---@param isPattern? boolean
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotStrContains(str, sub, isPattern, extra_msg) end

luaunit.assert_not_str_contains = luaunit.assertNotStrContains

--- Assert that the string *str* does not contain the substring *sub*, irrespective of the case.
---
--- *Note* that unlike `assertNotStrcontains`, you can not search for a pattern.
---@param str string
---@param sub string
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotStrIContains(str, sub, extra_msg) end

luaunit.assert_not_str_icontains = luaunit.assertNotStrIContains

--- Assert that the string *str* matches the full pattern *pattern*.
---
--- If *start* and *final* are not provided or are *nil*, the pattern must match the full string, from start to end. The function allows to specify the expected start and end position of the pattern in the string.
---@param str string
---@param pattern string
---@param start? integer
---@param final? integer
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertStrMatches(str, pattern, start, final, extra_msg) end

luaunit.assert_str_matches = luaunit.assertStrMatches

--- Assert that calling functions *func* with the arguments yields an error. If the function does not yield an error, the assertion fails.
---
--- *Note* that the error message itself is not checked, which means that this function does not distinguish between the legitimate error that you expect and another error that might be triggered by mistake.
---
--- The next functions provide a better approach to error testing, by checking explicitly the error message content.
---
--- *Note*: When testing LuaUnit, switching from *assertError()* to *assertErrorMsgEquals()* revealed quite a few bugs!
---@param func function
---@param ... unknown
function luaunit.assertError(func, ...) end

luaunit.assert_error = luaunit.assertError

--- Assert that calling function *func* will generate exactly the given error message. If the function does not yield an error, or if the error message is not identical, the assertion fails.
---
--- Be careful when using this function that error messages usually contain the file name and line number information of where the error was generated. This is usually inconvenient so we have introduced the `assertErrorMsgContentEquals`. Be sure to check it.
---@param expectedMsg string
---@param func function
---@param ... unknown
function luaunit.assertErrorMsgEquals(expectedMsg, func, ...) end

luaunit.assert_error_msg_equals = luaunit.assertErrorMsgEquals

--- Assert that calling function *func* will generate exactly the given error message, excluding the file and line information. File and line information may change as your programs evolve so we find this version more convenient than `assertErrorMsgEquals`.
---@param expectedMsg string
---@param func function
---@param ... unknown
function luaunit.assertErrorMsgContentEquals(expectedMsg, func, ...) end

luaunit.assert_error_msg_content_equals = luaunit.assertErrorMsgContentEquals

--- Assert that calling function *func* will generate an error message containing *partialMsg* . If the function does not yield an error, or if the expected message is not contained in the error message, the    assertion fails.
---@param partialMsg string
---@param func function
---@param ... unknown
function luaunit.assertErrorMsgContains(partialMsg, func, ...) end

luaunit.assert_error_msg_contains = luaunit.assertErrorMsgContains

--- Assert that calling function *func* will generate an error message matching *expectedPattern* . If the function does not yield an error, or if the error message does not match the provided patternm the      assertion fails.
---
--- *Note* that matching is done from the start to the end of the error message. Be sure to escape magic all magic characters with `%` (like `-+.?*`).
---@param expectedPattern string
---@param func function
---@param ... unknown
function luaunit.assertErrorMsgMatches(expectedPattern, func, ...) end

luaunit.assert_error_msg_matches = luaunit.assertErrorMsgMatches

--- Assert that the argument is a number (integer or float).
---@param value any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertIsNumber(value, extra_msg) end

luaunit.assertNumber = luaunit.assertIsNumber
luaunit.assert_is_number = luaunit.assertIsNumber
luaunit.assert_number = luaunit.assertIsNumber

--- Assert that the argument is a string.
---@param value any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertIsString(value, extra_msg) end

luaunit.assertString = luaunit.assertIsString
luaunit.assert_is_string = luaunit.assertIsString
luaunit.assert_string = luaunit.assertIsString

--- Assert that the argument is a table.
---@param value any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertIsTable(value, extra_msg) end

luaunit.assertTable = luaunit.assertIsTable
luaunit.assert_is_table = luaunit.assertIsTable
luaunit.assert_table = luaunit.assertIsTable

--- Assert that the argument is a boolean.
---@param value any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertIsBoolean(value, extra_msg) end

luaunit.assertBoolean = luaunit.assertIsBoolean
luaunit.assert_is_boolean = luaunit.assertIsBoolean
luaunit.assert_boolean = luaunit.assertIsBoolean

--- Assert that the argument is nil.
---@param value any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertIsNil(value, extra_msg) end

luaunit.assertNil = luaunit.assertIsNil
luaunit.assert_is_nil = luaunit.assertIsNil
luaunit.assert_nil = luaunit.assertIsNil

--- Assert that the argument is a function.
---@param value any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertIsFunction(value, extra_msg) end

luaunit.assertFunction = luaunit.assertIsFunction
luaunit.assert_is_function = luaunit.assertIsFunction
luaunit.assert_function = luaunit.assertIsFunction

--- Assert that the argument is a userdata.
---@param value any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertIsUserdata(value, extra_msg) end

luaunit.assertUserdata = luaunit.assertIsUserdata
luaunit.assert_is_userdata = luaunit.assertIsUserdata
luaunit.assert_userdata = luaunit.assertIsUserdata

--- Assert that the argument is a coroutine (an object with type *thread* ).
---@param value any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertIsCoroutine(value, extra_msg) end

luaunit.assertCoroutine = luaunit.assertIsCoroutine
luaunit.assert_is_coroutine = luaunit.assertIsCoroutine
luaunit.assert_coroutine = luaunit.assertIsCoroutine

--- Same function as `assertIsCoroutine` . Since Lua coroutines have the type thread, it's not clear which name is the clearer, so we provide syntax for both names.
---@param value any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertIsThread(value, extra_msg) end

luaunit.assertThread = luaunit.assertIsThread
luaunit.assert_is_thread = luaunit.assertIsThread
luaunit.assert_thread = luaunit.assertIsThread

--[[
Assert that two tables contain the same items, irrespective of their keys.\
This function is practical for example if you want to compare two lists but where items are not in the same order:
```lua
  lu.assertItemsEquals( {1,2,3}, {3,2,1} ) -- assertion succeeds
```
The comparison is not recursive on the items: if any of the items are tables, they are compared using table equality (like as in `assertEquals` ), where the key matters.
```lua
  lu.assertItemsEquals( {1,{2,3},4}, {4,{3,2,},1} ) -- assertion fails because {2,3} ~= {3,2}
```
]]
---@param actual table
---@param expected table
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertItemsEquals(actual, expected, extra_msg) end

luaunit.assert_items_equals = luaunit.assertItemsEquals

--[[
Assert that the table contains at least one key with value `element`. Element may be of any type (including table), the recursive equality algorithm of assertEquals() is used for verifying the presence of the element.
```lua
  lu.assertTableContains( {'a', 'b', 'c', 'd'}, 'b' ) -- assertion succeeds
  lu.assertTableContains( {1, 2, 3, {4} }, {4} } -- assertion succeeds
```
]]
---@param table table
---@param element any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertTableContains(table, element, extra_msg) end

luaunit.assert_table_contains = luaunit.assertTableContains

--[[
Negative version of `assertTableContains` .

Assert that the table contains no element with value `element`. Element
may be of any type (including table), the recursive equality algorithm of assertEquals() is used for verifying the presence of the element.

```lua
lu.assertNotTableContains( {'a', 'b', 'c', 'd'}, 'e' ) -- assertion succeeds
lu.assertNotTableContains( {1, 2, 3, {4} }, {5} } -- assertion succeeds
```
]]
---@param table table
---@param element any
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotTableContains(table, element, extra_msg) end

luaunit.assert_not_table_contains = luaunit.assertNotTableContains

--- Assert that a given number is a *NaN* (Not a Number), according to the definition of IEEE-754_ .
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNan(value, extra_msg) end

luaunit.assert_nan = luaunit.assertNan

--- Assert that a given number is NOT a *NaN* (Not a Number), according to the definition of IEEE-754_ .
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotNan(value, extra_msg) end

luaunit.assert_not_nan = luaunit.assertNotNan

--- Assert that a given number is *plus infinity*, according to the definition of IEEE-754_ .
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertPlusInf(value, extra_msg) end

luaunit.assert_plus_inf = luaunit.assertPlusInf

--- Assert that a given number is *minus infinity*, according to the definition of IEEE-754_ .
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertMinusInf(value, extra_msg) end

luaunit.assert_minus_inf = luaunit.assertMinusInf

--- Assert that a given number is *infinity* (either positive or negative), according to the definition of IEEE-754_ .
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertInf(value, extra_msg) end

luaunit.assert_inf = luaunit.assertInf

--- Assert that a given number is NOT *plus infinity*, according to the definition of IEEE-754_.
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotPlusInf(value, extra_msg) end

luaunit.assert_not_plus_inf = luaunit.assertNotPlusInf

--- Assert that a given number is NOT *minus infinity*, according to the definition of IEEE-754_ .
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotMinusInf(value, extra_msg) end

luaunit.assert_not_minus_inf = luaunit.assertNotMinusInf

--- Assert that a given number is neither *infinity* nor *minus infinity*, according to the definition of IEEE-754_ .
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotInf(value, extra_msg) end

luaunit.assert_not_inf = luaunit.assertNotInf

--- Assert that a given number is *+0*, according to the definition of IEEE-754_ . The verification is done by dividing by the provided number and verifying that it yields *infinity* .\
--- Be careful when dealing with *+0* and *-0*, see note above.
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertPlusZero(value, extra_msg) end

luaunit.assert_plus_zero = luaunit.assertPlusZero

--- Assert that a given number is *-0*, according to the definition of IEEE-754_ . The verification is done by dividing by the provided number and verifying that it yields *minus infinity* .\
--- Be careful when dealing with *+0* and *-0*, see MinusZero_
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertMinusZero(value, extra_msg) end

luaunit.assert_minus_zero = luaunit.assertMinusZero

--- Assert that a given number is NOT *+0*, according to the definition of IEEE-754_ .\
--- Be careful when dealing with *+0* and *-0*, see MinusZero_
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotPlusZero(value, extra_msg) end

luaunit.assert_not_plus_zero = luaunit.assertNotPlusZero

--- Assert that a given number is NOT *-0*, according to the definition of IEEE-754_ .\
--- Be careful when dealing with *+0* and *-0*, see MinusZero_
---@param value number
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotMinusZero(value, extra_msg) end

luaunit.assert_not_minus_zero = luaunit.assertNotMinusZero

--- Assert that two floating point numbers or tables are equal by the defined margin.\
--- The function accepts either floating point numbers or tables. Complex structures with nested tables are supported. Comparing tables with `assertAlmostEquals` works just like `assertEquals` with the difference that values are compared with a margin instead of with direct equality.\
--- Be careful that depending on the calculation, it might make more sense to measure the absolute error or the relative error:
---@param actual number | table
---@param expected number | table
---@param margin? number If margin is not provided, the machine epsilon *EPS* is used.
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertAlmostEquals(actual, expected, margin, extra_msg) end

luaunit.assert_almost_equals = luaunit.assertAlmostEquals

--- Assert that two floating point numbers are not equal by the defined margin.\
--- Be careful that depending on the calculation, it might make more sense to measure the absolute error or the relative error.
---@param actual number
---@param expected number
---@param margin? number If margin is not provided, the machine epsilon *EPS* is used.
---@param extra_msg? string If provided, *extra_msg* is a string which will be printed along with the failure message.
function luaunit.assertNotAlmostEquals(actual, expected, margin, extra_msg) end

luaunit.assert_not_almost_equals = luaunit.assertNotAlmostEquals

--[[
Converts *value* to a nicely formatted string, whatever the type of the value. It supports in particular tables, nested table and even recursive tables. You can use it in your code to replace calls to *tostring()* .
#### Example of prettystr()
```lua
> lu = require('luaunit')
> t1 = {1,2,3}
> t1['toto'] = 'titi'
> t1.f = function () end
> t1.fa = (1 == 0)
> t1.tr = (1 == 1)
> print( lu.prettystr(t1) )
{1, 2, 3, f=function: 00635d68, fa=false, toto="titi", tr=true}
```
]]
---@param value any
---@return string
function luaunit.prettystr(value) end

return luaunit
