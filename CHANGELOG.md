2.2.4
-----------

- Add `whoami` to mantle config so an app can tag published messages
- Add `message_source` as a `__MANTLE__` payload so consumers can identify sender

2.2.3
-----------

- Remove reference to `Celluloid` as Sidekiq no longer depends on it

2.2.2
-----------

- Better formatted error messages

2.2.1
-----------

- Message router traps exception when enqueuing Sidekiq job and sends to
    logger

2.2.0
-----------

- Catch up queue is cleared every 60 min.

2.1.2
-----------

- `require 'delegate'` to use with `SimpleDelegator`

2.1.1
-----------

- Update Sidekiq to `3.4.2`
- Ensure root level `SimpleDelegator` is used in listener
