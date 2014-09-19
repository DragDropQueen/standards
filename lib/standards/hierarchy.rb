module Standards
  class Hierarchy
    attr_reader :name, :tags, :subhierarchies, :id
    attr_accessor :parent_id

    def initialize(attributes)
      @id             = attributes.fetch(:id)        { raise ArgumentError, 'Hierarchies must have an id' }
      @parent_id      = attributes.fetch(:parent_id) { raise ArgumentError, 'Hierarchies must have a parent_id' }
      @name           = attributes.fetch(:name)      { raise ArgumentError, 'Hierarchies must have a name' }
      @tags           = attributes.fetch :tags, []
      @subhierarchies = attributes.fetch :subhierarchies, []
      raise ArgumentError, "Must have a name" unless name
    end

    # TODO: rename to add_subhierarchy
    def add(child)
      child.parent_id = id
      subhierarchies << child
      self
    end

    def find(&block)
      return self if block.call self
      subhierarchies.find { |h| h.find &block }
    end

    # TODO: to_enum on this does not work right
    def depth_first(&block)
      _depth_first([], block)
    end

    def standards_filter
      Standards::Filter.new(tags: tags)
    end

    def inspect
      if subhierarchies.any?
        "#<Standards::Hierarchy\n#{child_inspect(1)}>"
      else
        inspected = "#<Standards::Hierarchy #{name.inspect}>"
      end
    end

    protected

    def child_inspect(indentation)
      me = ("  " * indentation)
      me << name.inspect << "\n"
      subhierarchies.each do |subhierarchy|
        me << subhierarchy.child_inspect(indentation+1)
      end
      me
    end

    def _depth_first(ancestry, block)
      block.call self, ancestry do
        subhierarchies.each do |subhierarchy|
          subhierarchy._depth_first [self, *ancestry], block
        end
      end
    end
  end
end