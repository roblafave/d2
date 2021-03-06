module Spree
  module TaxonomyConcerns
    extend ActiveSupport::Concern

    class_methods do
      def restaurant
        find_by!(name: 'Restaurants')
      end

      def chef
        find_by!(name: 'Chefs')
      end

      def diets
        find_by!(name: 'Diets')
      end

      def allergens
        find_by!(name: 'Allergens')
      end

      def proteins
        find_by!(name: 'Proteins')
      end

      def pantry
        find_by!(name: 'Pantry')
      end

      def equipment
        find_by!(name: 'Equipment')
      end

      def pages
        find_by!(name: 'Pages')
      end
    end
  end
end
