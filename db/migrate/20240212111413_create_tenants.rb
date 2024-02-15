class CreateTenants < ActiveRecord::Migration[7.0]
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :sub_domain

      t.timestamps
    end
    add_index :tenants, 'LOWER(sub_domain)', unique: true
  end
end
