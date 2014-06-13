class AddQuestionTypeToPq < ActiveRecord::Migration
  def change
    add_column :pqs, :question_type, :string
  end
end
