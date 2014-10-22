module BestInPlace
  module BestInPlaceHelpers
    alias_method :best_in_place_original, :best_in_place
    def best_in_place(*params)
      best_in_place_original(*params) + raw(' <span class="glyphicon glyphicon-edit"></span>')
    end
  end
end