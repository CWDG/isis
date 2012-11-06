class AddRegisteredIdToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :registered_id, :integer
  end
end
