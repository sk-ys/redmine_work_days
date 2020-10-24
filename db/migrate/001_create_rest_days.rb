class CreateRestDays < ActiveRecord::Migration[4.2]
  def change
    create_table :rest_days do |t|
      t.date :day
      t.string :description
    end
  end
end
