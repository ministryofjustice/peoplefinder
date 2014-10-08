module SymbolField
  def symbol_field(field, values)
    lookup = Hash[values.map(&:to_s).zip(values)]
    define_method field do
      lookup[attributes[field.to_s].to_s]
    end
  end
end
