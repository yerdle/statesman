## v1.2.2 24 March 2015

- Add support for namespaced transition models (patch by [@DanielWright](https://github.com/DanielWright))

## v1.2.1 24 March 2015

- Add support for Postgres 9.4's `jsonb` column type (patch by [@isaacseymour](https://github.com/isaacseymour))

## v1.2.0 18 March 2015

*Changes*

- Add a `most_recent` column to transition tables to greatly speed up queries (ActiveRecord adapter only).
  - All queries are backwards-compatible, so everything still works without the new column.
  - The upgrade path is:
    - Generate and run a migration for adding the column, by running `rails generate statesman:add_most_recent <ParentModel> <TransitionModel>`.
    - Backfill the `most_recent` column on old records by running `rake statesman:backfill_most_recent[ParentModel] `.
    - Add constraints and indexes to the transition table that make use of the new field, by running `rails g statesman:add_constraints_to_most_recent <ParentModel> <TransitionModel>`.
  - The upgrade path has been designed to be zero-downtime, even on large tables. As a result, please note that queries will only use the `most_recent` field after the constraints have been added.
- `ActiveRecordQueries.{not_,}in_state` now accepts an array of states.


## v1.1.0 9 December 2014
*Fixes*

- Support for Rails 4.2.0.rc2:
  - Remove use of serialized_attributes when using 4.2+. (patch by [@greysteil](https://github.com/greysteil))
  - Use reflect_on_association rather than directly using the reflections hash. (patch by [@timrogers](https://github.com/timrogers))
- Fix `ActiveRecordQueries.in_state` when `Model.initial_state` is defined as a symbol. (patch by [@isaacseymour](https://github.com/isaacseymour))

*Changes*

- Transition metadata now defaults to `{}` rather than `nil`. (patch by [@greysteil](https://github.com/greysteil))

## v1.0.0 21 November 2014

No changes from v1.0.0.beta2

## v1.0.0.beta2 10 October 2014
*Breaking changes*

- Rename `ActiveRecordModel` to `ActiveRecordQueries`, to reflect the fact that it mixes in some helpful scopes, but is not required.

## v1.0.0.beta1 9 October 2014
*Breaking changes*

- Classes which include `ActiveRecordModel` must define an `initial_state` class method.

*Fixes*

- `ActiveRecordModel.in_state` and `ActiveRecordModel.not_in_state` now handle inital states correctly (patch by [@isaacseymour](https://github.com/isaacseymour))

*Additions*

- Transition tables created by generated migrations have `NOT NULL` constraints on `to_state`, `sort_key` and foreign key columns (patch by [@greysteil](https://github.com/greysteil))
- `before_transition` and `after_transition` allow an array of to states (patch by [@isaacseymour](https://github.com/isaacseymour))

## v0.8.3 2 September 2014
*Fixes*

- Optimisation for Machine#available_events (patch by [@pacso](https://github.com/pacso))

## v0.8.2 2 September 2014
*Fixes*

- Stop generating a default value for the metadata column if using MySQL.

## v0.8.1 19 August 2014
*Fixes*

- Adds check in Machine#transition to make sure the 'to' state is not an empty array (patch by [@barisbalic](https://github.com/barisbalic))

## v0.8.0 29 June 2014
*Additions*

- Events. Machines can now define events as a logical grouping of transitions (patch by [@iurimatias](https://github.com/iurimatias))
- Retries. Individual transitions can be executed with a retry policy by wrapping the method call in a `Machine.retry_conflicts {}` block (patch by [@greysteil](https://github.com/greysteil))

## v0.7.0 25 June 2014
*Additions*

- `Adapters::ActiveRecord` now handles `ActiveRecord::RecordNotUnique` errors explicitly and re-raises with a `Statesman::TransitionConflictError` if it is due to duplicate sort_keys (patch by [@greysteil](https://github.com/greysteil))

## v0.6.1 21 May 2014
*Fixes*
- Fixes an issue where the wrong transition was passed to after_transition callbacks for the second and subsequent transition of a given state machine (patch by [@alan](https://github.com/alan))

## v0.6.0, 19 May 2014
*Additions*
- Generators now handle namespaced classes (patch by [@hrmrebecca](https://github.com/hrmrebecca))

*Changes*
- `Machine#transition_to` now only swallows Statesman generated errors. An exception in your guard or callback will no longer be caught by Statesman (patch by [@paulspringett](https://github.com/paulspringett))

## v0.5.0, 27 March 2014
*Additions*
- Scope methods. Adds a module which can be mixed in to an ActiveRecord model to provide `.in_state` and `.not_in_state` query scopes.
- Adds `Machine#after_initialize` hook (patch by [@att14](https://github.com/att14))

*Fixes*
- Added MongoidTransition to the autoload statements, fixing [#29](https://github.com/gocardless/statesman/issues/29) (patch by [@tomclose](https://github.com/tomclose))

## v0.4.0, 27 February 2014
*Additions*
- Adds after_commit flag to after_transition for callbacks to be executed after the transaction has been
committed on the ActiveRecord adapter. These callbacks will still be executed on non transactional adapters.

## v0.3.0, 20 February 2014
*Additions*
- Adds Machine#allowed_transitions method (patch by [@prikha](https://github.com/prikha))

## v0.2.1, 31 December 2013
*Fixes*
- Don't add attr_accessible to generated transition model if running in Rails 4

## v0.2.0, 16 December 2013
*Additions*
- Adds Ruby 1.9.3 support (patch by [@jakehow](https://github.com/jakehow))
- All Mongo dependent tests are tagged so they can be excluded from test runs

*Changes*
- Specs now crash immediately if Mongo is not running

## v0.1.0, 5 November 2013

*Additions*
- Adds Mongoid adapter and generators (patch by [@dluxemburg](https://github.com/dluxemburg))

*Changes*
- Replaces `config#transition_class` with `Statesman::Adapters::ActiveRecordTransition` mixin. (inspired by [@cjbell88](https://github.com/cjbell88))
- Renames the active record transition generator from `statesman:transition` to `statesman:active_record_transition`.
- Moves to using `require_relative` internally where possible to avoid stomping on application load paths.

## v0.0.1, 28 October 2013.
- Initial release
