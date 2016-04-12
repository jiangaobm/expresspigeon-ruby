module ExpressPigeon
  class MetaResponse

    def initialize(delegate)
      @delegate = delegate
      @delegate.each_key do |k|
        v = @delegate[k] # lets go only one level down for now
        if v.kind_of? Hash
          @delegate[k] = MetaResponse.new(v)
        end
      end
    end

    def method_missing(m, *args, &block)
      @delegate[m.to_s]
    end

    def respond_to?(m)
      @delegate.key?(m.to_s)
    end

    def to_s
      @delegate.to_s
    end

    def inspect
      @delegate.inspect
    end
  end
end
