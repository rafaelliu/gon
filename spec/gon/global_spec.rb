require 'gon'

describe Gon::Global do

  before(:each) do
    Gon::Global.clear
  end

  describe '#all_variables' do

    it 'returns all variables in hash' do
      Gon.global.a = 1
      Gon.global.b = 2
      Gon.global.c = Gon.global.a + Gon.global.b
      Gon.global.c.should == 3
      Gon.global.all_variables.should == {'a' => 1, 'b' => 2, 'c' => 3}
    end

    it 'supports all data types' do
      Gon.global.clear
      Gon.global.int = 1
      Gon.global.float = 1.1
      Gon.global.string = 'string'
      Gon.global.array = [ 1, 'string' ]
      Gon.global.hash_var = { :a => 1, :b => '2'}
      Gon.global.hash_w_array = { :a => [ 2, 3 ] }
      Gon.global.klass = Hash
    end

  end

  describe '#include_gon' do

    before(:each) do
      Gon.clear
      Gon.global.clear
      ActionView::Base.
        instance_methods.
        map(&:to_s).
        include?('include_gon').should == true
      @base = ActionView::Base.new
      @base.request = request
    end

    it 'outputs correct js with an integer' do
      Gon.global.int = 1
      @base.include_gon.should == "<script>window.gon = {};" +
                                    "gon.global={\"int\":1};" +
                                  "</script>"
    end

    it 'outputs correct js with an integer and integer in Gon' do
      Gon::Request.
        instance_variable_set(:@request_id, request.object_id)
      Gon.int = 1
      Gon.global.int = 1
      @base.include_gon.should == "<script>window.gon = {};" +
                                    "gon.int=1;" +
                                    "gon.global={\"int\":1};" +
                                  "</script>"
    end

    it 'outputs correct js with a string' do
      Gon.global.str = %q(a'b"c)
      @base.include_gon.should == "<script>window.gon = {};" +
                                    "gon.global={\"str\":\"a'b\\\"c\"};" +
                                  "</script>"
    end

    it 'outputs correct js with a script string' do
      Gon.global.str = %q(</script><script>alert('!')</script>)
      @base.include_gon.should == "<script>window.gon = {};" +
                                    "gon.global={\"str\":\"<\\/script><script>alert('!')<\\/script>\"};" +
                                  "</script>"
    end

  end

  it 'returns exception if try to set public method as variable' do
    Gon.global.clear
    lambda { Gon.global.all_variables = 123 }.should raise_error
    lambda { Gon.global.rabl = 123 }.should raise_error
  end

  it 'works fine with rabl and jbuilder' do
    pending
  end

  def request
    @request ||= double 'request', :env => {}
  end

end