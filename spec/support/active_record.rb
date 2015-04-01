require "support/active_record"
require "json"

class MyStateMachine
  include Statesman::Machine

  state :initial, initial: true
  state :succeeded
  state :failed

  transition from: :initial, to: [:succeeded, :failed]
  transition from: :failed,  to: :initial
end

class MyActiveRecordModel < ActiveRecord::Base
  has_many :my_active_record_model_transitions
  alias_method :transitions, :my_active_record_model_transitions

  def state_machine
    @state_machine ||= MyStateMachine.new(
      self, transition_class: MyActiveRecordModelTransition)
  end

  def metadata
    super || {}
  end
end

class MyActiveRecordModelTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :my_active_record_model
  serialize :metadata, JSON
end

class CreateMyActiveRecordModelMigration < ActiveRecord::Migration
  def change
    create_table :my_active_record_models do |t|
      t.string :current_state
      t.timestamps null: false
    end
  end
end

# TODO: make this a module we can extend from the app? Or a generator?
# rubocop:disable MethodLength
class CreateMyActiveRecordModelTransitionMigration < ActiveRecord::Migration
  def change
    create_table :my_active_record_model_transitions do |t|
      t.string  :to_state
      t.integer :my_active_record_model_id
      t.integer :sort_key
      t.boolean :most_recent, default: true, null: false

      # MySQL doesn't allow default values on text fields
      if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
        t.text :metadata
      else
        t.text :metadata, default: '{}'
      end

      t.timestamps null: false
    end

    add_index :my_active_record_model_transitions,
              [:my_active_record_model_id, :sort_key],
              unique: true, name: "sort_key_index"
    add_index :my_active_record_model_transitions,
              [:my_active_record_model_id, :most_recent],
              unique: true, where: "most_recent",
              name: "index_my_active_record_model_transitions_"\
                    "parent_most_recent"
  end
end
# rubocop:enable MethodLength

class DropMostRecentColumn < ActiveRecord::Migration
  def change
    remove_index :my_active_record_model_transitions,
                 name: "index_my_active_record_model_transitions_"\
                       "parent_most_recent"
    remove_column :my_active_record_model_transitions, :most_recent
  end
end

module MyNamespace
  class MyActiveRecordModel < ActiveRecord::Base
    has_many :my_active_record_model_transitions,
             class_name: "MyNamespace::MyActiveRecordModelTransition"

    def self.table_name_prefix
      "my_namespace_"
    end

    def state_machine
      @state_machine ||= MyStateMachine.new(
        self, transition_class: MyNameSpace::MyActiveRecordModelTransition,
              association_name: :my_active_record_model_transitions)
    end

    def metadata
      super || {}
    end
  end

  class MyActiveRecordModelTransition < ActiveRecord::Base
    belongs_to :my_active_record_model,
               class_name: "MyNamespace::MyActiveRecordModel"
    serialize :metadata, JSON

    def self.table_name_prefix
      "my_namespace_"
    end
  end
end

class CreateNamespacedARModelMigration < ActiveRecord::Migration
  def change
    create_table :my_namespace_my_active_record_models do |t|
      t.string :current_state
      t.timestamps null: false
    end
  end
end

class CreateNamespacedARModelTransitionMigration < ActiveRecord::Migration
  def change
    create_table :my_namespace_my_active_record_model_transitions do |t|
      t.string  :to_state
      t.integer :my_active_record_model_id
      t.integer :sort_key

      # MySQL doesn't allow default values on text fields
      if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
        t.text :metadata
      else
        t.text :metadata, default: '{}'
      end

      t.timestamps null: false
    end

    add_index :my_namespace_my_active_record_model_transitions, :sort_key,
              unique: true, name: 'my_namespaced_key'
  end
end
