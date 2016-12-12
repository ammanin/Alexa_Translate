class CreateTranslationTables < ActiveRecord::Migration[5.0]
  def change
	create_table :tran_lists do |t|
	 t.string :lang	 
	 t.string :phrase
	 t.string :tras
     t.timestamps
	 end
  end
end
