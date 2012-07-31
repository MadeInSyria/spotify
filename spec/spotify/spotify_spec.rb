describe Spotify do
  describe "VERSION" do
    it "is defined" do
      defined?(Spotify::VERSION).should eq "constant"
    end

    it "is the same version as in api.h" do
      spotify_version = API_H_SRC.match(/#define\s+SPOTIFY_API_VERSION\s+(\d+)/)[1]
      Spotify::API_VERSION.to_i.should eq spotify_version.to_i
    end
  end

  describe ".enum_value!" do
    it "raises an error if given an invalid enum value" do
      expect { Spotify.enum_value!(:moo, "error value") }.to raise_error(ArgumentError)
    end

    it "gives back the enum value for that enum" do
      Spotify.enum_value!(:ok, "error value").should eq 0
    end
  end

  describe ".attach_function" do
    it "is a retaining class if the method is not creating" do
      begin
        Spotify.attach_function :whatever, [], Spotify::User
      rescue FFI::NotFoundError
        # expected, this method does not exist
      end

      Spotify.attached_methods["whatever"][:returns].should eq Spotify::User.retaining_class
    end

    it "is a non-retaining class if the method is creating" do
      begin
        Spotify.attach_function :whatever_create, [], Spotify::User
      rescue FFI::NotFoundError
        # expected, this method does not exist
      end

      Spotify.attached_methods["whatever_create"][:returns].should eq Spotify::User
      Spotify.attached_methods["whatever_create"][:returns].should_not eq Spotify::User.retaining_class
    end

    it "defines instance methods as well" do
      klass = Class.new { include Spotify }
      object = klass.new
      object.should respond_to :error_message
    end
  end
end