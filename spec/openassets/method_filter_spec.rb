require 'spec_helper'
describe OpenAssets::MethodFilter do

  it 'before filter' do
    class FilterSpec
      include OpenAssets::MethodFilter

      before_filter :before, {:include => [:hoge]}

      def hoge
        puts "hoge"
      end

      def before
        puts "before"
      end
    end

    s = FilterSpec.new
    expect {s.hoge}.to output("before\nhoge\n").to_stdout
  end

end