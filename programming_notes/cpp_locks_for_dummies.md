By default use [`std::lock_guard`](https://en.cppreference.com/w/cpp/thread/lock_guard) (since C++11), it will be locked only once on construction and unlocked on destruction.

[`std::scoped_lock`](https://stackoverflow.com/questions/43019598/stdlock-guard-or-stdscoped-lock) is useful to lock some number of mutex objects in a deadlock-free way. It's a generalisation of `std::lock_guard`.

A [`std::unique_lock`](https://en.cppreference.com/w/cpp/thread/unique_lock) can be created without immediately locking, can unlock at any point in its existence and can transfer ownership of the lock from one instance to another.


### Details
- [std::scoped_lock or std::unique_lock or std::lock_guard?](https://stackoverflow.com/q/58443465/3235496)
- [Howard Hinnant's answer to std::lock_guard or std::scoped_lock?](https://stackoverflow.com/a/60172828/3235496)
