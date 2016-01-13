class GroupLister
  class ListedGroup
    attr_reader :id, :parent_id, :name

    def initialize(index, group)
      @index = index
      @id = group.id
      @parent_id = group.ancestor_ids.last
      @name = group.name
    end

    def parent
      parent_id && @index[parent_id]
    end

    def path
      parent ? parent.path + [self] : [self]
    end

    def ancestors
      path[0..-2]
    end

    def to_s
      name
    end

    def name_with_path
      return name if ancestors.empty?
      "#{name} [#{ancestors.join(' > ')}]"
    end
  end

  def initialize(max_depth = nil)
    @scope = scope_with_maximum_depth(max_depth)
  end

  def list
    index = {}
    @scope.all.each do |group|
      index[group.id] = ListedGroup.new(index, group)
    end
    index.values
  end

  private

  def scope_with_maximum_depth(max_depth)
    return Group unless max_depth
    tbl = Group.arel_table
    Group.where(tbl[:ancestry_depth].lt(max_depth))
  end
end
