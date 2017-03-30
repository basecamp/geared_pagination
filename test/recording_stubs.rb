class Recordings
  def initialize(recordings)
    @recordings = recordings
    @offset = 0
    @limit = nil
  end

  def limit(size)
    @limit = size
    self
  end

  def offset(number)
    @offset = number
    self
  end

  def unscope(restriction)
    case restriction
    when :offset then @offset = 0
    when :limit  then @limit  = nil
    end

    self
  end


  def [](index)
    slice[index]
  end

  def count
    slice.size
  end
  alias :size :count

  def include?(record)
    slice.include?(record)
  end


  private
    def slice
      @recordings[@offset..(@limit ? @offset + (@limit - 1) : -1)]
    end
end

class Recording
  def self.all(count = 120)
    Recordings.new(count.times.collect { |i| new(i) })
  end

  attr_reader :number

  def initialize(number)
    @number = 1
  end

  def ==(comparison)
    @number == comparison.number
  end
end
