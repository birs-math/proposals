class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def summary
    "#{self.class.name}(id: #{id})"
  end
end
