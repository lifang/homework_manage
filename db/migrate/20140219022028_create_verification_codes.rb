class CreateVerificationCodes < ActiveRecord::Migration
  def change
    create_table :verification_codes do |t|
      t.integer :code
      t.timestamps
    end
  end
end
