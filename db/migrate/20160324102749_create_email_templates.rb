class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :name
      t.string :description
      t.string :content
      t.timestamps null: false
    end
  end
end
