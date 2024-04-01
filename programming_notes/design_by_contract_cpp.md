# Design by Contract Programming in C++

The [Eiffel programming language](https://en.wikipedia.org/wiki/Eiffel_(programming_language)) introduced "design by contract" to object oriented programming. The main idea here is to model interfaces between classes as contracts.
In this article, we will be applying this powerful technique to C++ programming.

## Interfaces as Contracts

In legal terms, a contract is a binding document that describes the responsibilities and expectations of the parties entering into the contract. Interfaces between classes can be modeled in the same way.
Whenever an object invokes a method of an other object, this interaction should be viewed as a contract between the caller and the called method. This contract consists of the following conditions:

- **Pre-conditions**. The caller of the method needs to pass parameters that meet the requirements of the called method. Pre-conditions check if the caller of the method is keeping its side of the contract by passing the right parameters.
- **Post-conditions**. The called method needs to return results that meet the expectations of the caller. Post-conditions check if the called method is keeping its side of the contract, i.e. returning the results required by this interface.
- **Consistency checks**. In addition to the pre-conditions and post-conditions, all the objects involved in the transaction should be left in a consistent state.

## Design by Contract Framework

We will consider an example here to see how "design by contract" is implemented in C++. We start by looking at the basic framework for design by contract.
The framework consists of the following macros that are available only in the debug mode. The macros are defined to blank in the release build.

- `assert`: this macro aborts the program if the parameter passed to the macro does not evaluate to true. When this macro is used in the code, the programmer is asserting that the condition specified in the parameter has to be true. If it's not so, further execution of the program cannot proceed.
- `Expects`: this macro should be used to check if the pre-conditions for the invoked method have been met. If the caller does not keep its part of the contract, this macro will assert (as it's just another redefinition of `assert`)
- `Ensures`: this macro checks if the post conditions have been met. Here the called function checks if it has kept its part of the contract. This macro will assert if there is a contract breach.
- `is_valid` method: this member function must be defined in every class. The code should check for consistency of the objects internal state. The programmer invokes this method before acting on an object.

## Design by Contract Framework

```C++
#if defined(__clang__) || defined(__GNUC__)
#  define ULTRA_LIKELY(x) __builtin_expect(!!(x), 1)
#  define ULTRA_UNLIKELY(x) __builtin_expect(!!(x), 0)
#else
#  define ULTRA_LIKELY(x) (!!(x))
#  define ULTRA_UNLIKELY(x) (!!(x))
#endif

#if defined(NDEBUG)
#  define Expects(expression)
#  define Ensures(expression)
#else
// Preconditions can be stated in many ways, including comments, `if`
// statements and `assert()`. This can make them hard to distinguish from
// ordinary code, hard to update, hard to manipulate by tools and may have
// the wrong semantics (do you always want to abort in debug mode and check
// nothing in productions runs?).
// \see C++ Core Guidelines I.6 <https://github.com/isocpp/CppCoreGuidelines/>
#  define Expects(expression)  assert(ULTRA_LIKELY(expression))

// Postconditions are often informally stated in a comment that states the
// purpose of a function; `Ensures()` can be used to make this more
// systematic, visible and checkable.
// Postconditions are especially important when they relate to something that
// isn't directly reflected in a returned result, such as a state of a data
// structure used.
// NOTE. Postconditions of the form "this resource must be released" are best
// expressed by RAII.
// \see C++ Core Guidelines I.8 <https://github.com/isocpp/CppCoreGuidelines/>
#  define Ensures(expression)  assert(ULTRA_LIKELY(expression))
#endif
```
## Debug and Release Builds

The "design by contract" framework can work only if the programmers can introduce aggressive checks without having to worrying about their performance implications.
The main idea here is that lab testing of the product should be done with debug builds (i.e. `NDEBUG` flag is not defined) where all the "design by contract" macros are enabled.
These macros will allow you to zero in on the faults very quickly as all breach of contract conditions are being checked. This can dramatically lower the debugging time in a large project.
This means you will have less of those unhealthy finger pointing sessions when bugs have to be isolated.

When the product is ready to be shipped, the release build can be made. This build will disable all the macros used in the "design by contract" framework. Thus you will obtain complete performance.
If CPU performance is not a big issue, in the initial deployment you may decide to retain the macros and replace the exit condition in the `assert` macro with exception throwing. Thus you have complete control on the level of debugging you wish to have in the final product.

**An important thing to note here is that the "design by contract" framework is not a replacement for defensive programming**. You still write defensive code which handles error conditions even in the release build.
You can view the contract checking as a diagnostic programming technique that allows you to be extra suspicious in handling contracts when the implementation of the contract is new and untested.
When you get comfortable with the contract implementation, you turn off the extra suspicious checking.

Another benefit of "design by contract" technique is that it gives you extra diagnostic capability without compromising readability. There is no need to add redundant if statements for diagnostic programming.
In fact, these macros will actually improve the readability as they clearly state the expectations of the caller and the called methods.

## An Example of Design by Contract Programming

Here we have taken an example from the [STL Design Patterns](https://web.archive.org/web/20170630041625/http://eventhelix.com/RealtimeMantra/Patterns/stl_design_patterns.htm) article and added support for the "design by contract" framework.
All the additions to the original Terminal Manager are shown in bold.

```C++
#include <map>
using std;

class TerminalManager
{
private:
  // The map is keyed with the terminal id and stores pointers to Terminals.
  // terminal id is an integer, terminal ids can be in the entire range for
  // an integer and they will still be efficiently stored inside a map.
  typedef map<int, Terminal *> TerminalMap;
  TerminalMap m_terminalMap;
  int m_managerType;
  FaultManager m_faultManager;

public:
  bool is_valid() const
  {
#if defined(NDEBUG)
    return true;
#else
    return m_terminalMap.count() <= MAX_TERMINALS_PER_MANAGER
           && m_managerType < MAX_MANAGER_TYPES
           && m_faultManager.IsValid();
#endif
  }

  Status AddTerminal(int terminalId, int type)
  {
    // Checking Preconditions
    Expects(terminalId < MAX_TERMINAL_ID);
    Expects(type >= TERMINAL_TYPE_RANGE_MIN && type <= TERMINAL_TYPE_RANGE_MAX);
          
    Status status;
          
    // Check if the terminal is already present in the map. count()
    // returns the total number of entries that are keyed by terminalId
    if (m_terminalMap.count(terminalId) == 0)
    {
      // count() returned zero, so no entries are present in the map
      Terminal *pTerm = new Terminal(terminalId, type);
     
      // Make sure that the newly created terminal is in consistent state
      IS_VALID(pTerm);
             
      // Since map overloads the array operator [ ], it gives 
      // the illusion of indexing into an array. The following
      // line makes an entry into the map
      m_terminalMap[termId] = pTerm;
             
      status = SUCCESS;
    }
    else
    {
      // count() returned a non zero value, so the terminal is already
      // present.
      status = FAILURE;
    }
          
    // Checking post conditions:
    // 1. TerminalManager should be consistent
    // 2. The new terminal should always be found
    // 3. The manager should not be controlling more terminals
    //    than allowed
    // 4. Make sure correct return code is being returned.
    IS_VALID(this);
    Ensures(FindTerminal(termId));
    Ensures(m_terminalMap.count() <= MAX_TERMINALS_PER_MANAGER));
    Ensures(status == SUCCESS || status == FAILURE);
    return status;
  }
       
  Status RemoveTerminal(int terminalId)
  {
    // Check pre-conditions
    // Note: Here the `Expects` macro makes sure that
    // terminal to be deleted is actually present. A similar
    // check will be done in the main body of the code.
    // The duplicate check in the `Expects` macro allows flagging
    // the error earlier.

    Expects(terminalId < MAX_TERMINAL_ID);
    Expects(FindTerminal(terminalId));
          
    Status status;
    // Check if the terminal is present
    if (m_terminalMap.count(terminalId) == 1)
    {
      // Save the pointer that is being deleted from the map
      Terminal *pTerm = m_terminalMap[terminalId]; 
          
      // Make sure that terminal object being deleted is in a consistent
      // state
      IS_VALID(pTerm);         
       
      // Erase the entry from the map. This just frees up the memory for
      // the pointer. The actual object is freed up using delete
      m_terminalMap.erase(terminalId);
      delete pTerm;
             
      status = SUCCESS;
    }
    else
      status = FAILURE;

    // Checking Post-conditions:
    // 1. Terminal has been successfully deleted (terminal find
    //    should return NULL)
    // 2. Only valid status should be returned.
    // 3. Terminal Manager is in a consistent state
    Ensures(FindTerminal(terminalId) == NULL);
    Ensures(status == SUCCESS || status == FAILURE);
    IS_VALID(this);     
          
    return status;
  }
      
  // Find the terminal for a given terminal id, return
  // NULL if terminal not found
  Terminal *FindTerminal(int terminalId)
  {
    Terminal *pTerm;
    if (m_terminalMap.count(terminalId) == 1)
      pTerm = m_terminalMap[terminalId];
    else
      pTerm = NULL;

    return pTerm;
  } 
      
  void HandleMessage(const Message *pMsg)
  {
    // Check pre-conditions:
    Ensures(FindTerminal(pMsg->GetTerminal()));
         
    int terminalId = pMsg->GetTerminalId();
         
    Terminal *pTerm;
         
    pTerm = FindTerminal(terminalId);
         
    if (pTerm)
      pTerm->HandleMessage(pMsg);
  }
};
