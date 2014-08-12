def can_destroy?
  self.class.reflect_on_all_associations.all? do |assoc|
    ( ([:restrict_with_error, :restrict_with_exception].exclude? assoc.options[:dependent]) ||
      (assoc.macro == :has_one && self.send(assoc.name).nil?) ||
      (assoc.macro == :has_many && self.send(assoc.name).empty?) )
  end
end