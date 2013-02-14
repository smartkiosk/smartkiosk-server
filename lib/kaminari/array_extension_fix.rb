module Kaminari
  class PaginatableArray < Array
    # AA tries to reorder selection to ease SQL count query
    # In cases when we use array as a collection source we 
    #   need this method to do nothing and be chainable
    def reorder(*args)
      self
    end
  end
end