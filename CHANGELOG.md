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
