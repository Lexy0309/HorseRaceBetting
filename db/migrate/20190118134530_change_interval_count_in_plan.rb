class ChangeIntervalCountInPlan < ActiveRecord::Migration[5.1]
  def change
    change_column :plans, :interval_count, :string
  end
end
