class AddAncestryToGroups < ActiveRecord::Migration
  class Group < ActiveRecord::Base
    belongs_to :parent, class: Group
    has_many :children, class: Group, foreign_key: 'parent_id'

    def hierarchy
      [].tap { |acc|
        node = self
        while node
          acc.unshift node
          node = node.parent
        end
      }
    end
  end

  def change
    add_column :groups, :ancestry, :text
    add_column :groups, :ancestry_depth, :integer, default: 0, null: false
    add_index :groups, :ancestry

    Group.all.each do |group|
      ids = group.hierarchy.map(&:id)[0 .. -2]
      if ids.empty?
        Group.connection.execute <<-SQL
          UPDATE groups
          SET ancestry_depth = 0
          WHERE id = #{group.id}
        SQL
      else
        Group.connection.execute <<-SQL
          UPDATE groups
          SET ancestry = '#{ids.join('/')}',
              ancestry_depth = #{ids.length}
          WHERE id = #{group.id}
        SQL
      end
    end
    remove_column :groups, :parent_id
  end
end
