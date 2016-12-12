class CreateLanguageTable < ActiveRecord::Migration[5.0]
  def change
	create_table :lang_lists do |t|
		t.string :lang_name
		t.string :lang_code
	end
  end
end
