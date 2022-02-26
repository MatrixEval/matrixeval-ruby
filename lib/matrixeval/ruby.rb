require 'matrixeval'
require_relative 'ruby/version'
require_relative 'ruby/target'

module Matrixeval
  module Ruby
    module_function
    def root
      Pathname.new("#{__dir__}/../..")
    end
  end
end

Matrixeval.register_target(:ruby, Matrixeval::Ruby::Target)
