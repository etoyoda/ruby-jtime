# jtime.rb would be like this if I choose "delegation" pattern instead of extending Time.
# 継承ではなく移譲で書こうとするとこうなる。

require 'forwardable'

class JTime

  extend Forwardable

  MEIJI_LIMIT = Time.gm(1912, 7, 29, 15, 43)
  TAISHO = '大正'
  TAISHO_LIMIT = Time.gm(1926, 12, 24, 16, 25)
  SHOWA = '昭和'
  SHOWA_LIMIT = Time.gm(1989, 1, 7, 15, 0)
  HEISEI = '平成'
  HEISEI_LIMIT = Time.gm(2019, 4, 30, 15, 0)
  ERA2019 = '〓〓'

  def _gengo_
    return if @era_name
    if @time <= TAISHO_LIMIT
      @era_name = TAISHO
      @era_year = @time.year - 1911
    elsif @time < SHOWA_LIMIT
      @era_name = SHOWA
      @era_year = @time.year - 1925
    elsif @time < HEISEI_LIMIT
      @era_name = HEISEI
      @era_year = @time.year - 1988
    else
      @era_name = ERA2019
      @era_year = @time.year - 2018
    end
    if utc_offset < 32400
      raise "Japanese era not allowed for timezone west of 135E"
    end
    self
  end

  private :_gengo_

  def initialize time = nil
    @era_name = @era_year = nil
    @time = case time
      when Time then time  # hidden feature for singleton methods
      when NilClass then Time.now  # documented usage with zero argument
      else raise TypeError
      end
  end

  class << self

    def at itime, usec = 0
      return new(itime) if Time === itime
      new(Time.at(itime, usec))
    end

    def now
      new
    end

    def utc *args
      new(Time.utc(*args))
    end
    alias :gm :utc

    def local *args
      new(Time.local(*args))
    end
    alias :mktime :local

  end

  attr_reader :era_name, :era_year

  def to_time
    @time
  end

  def era_name
    _gengo_
    @era_name
  end

  def era_year
    _gengo_
    @era_year
  end

  def era_year_name
    _gengo_
    if @era_year == 1
      '元'
    else
      @era_year.to_s
    end
  end

  def strftime fmt
    @time.strftime(fmt.
      gsub(/%Jf/, '%Je%Jgk年%m月%d日').
      gsub(/%Jy(k?)/, '%Je%Jg\1').
      gsub(/%Je/){ era_name }.
      gsub(/%Jgk/){ era_year_name }.
      gsub(/%Jg/){ era_year })
  end

  # 算術演算子は引数型により扱いを変えるので単に移譲では済まない

  def - other
    case other
    when Numeric then self.class.new(@time - other)
    when Time then @time - other
    when JTime then @time - other.to_time
    else raise TypeError
    end
  end

  def + other
    case other
    when Numeric then self.class.new(@time + other)
    when Time, JTime then raise TypeError, "#{self.class} + #{other.class}?"
    else raise TypeError
    end
  end

  def succ
    self + 1
  end

  def <=> other
    case other
    when JTime then @time <=> other.to_time
    when Time then @time <=> other
    when Numeric then to_f <=> other
    else raise ArgumentError
    end
  end

  def getgm
    self.class.new(@time.getgm)
  end
  alias :getutc :getgm

  def getlocal utc_offset = nil
    if utc_offset then
      self.class.new(@time.getlocal(utc_offset))
    else
      self.class.new(@time.getlocal)
    end
  end

  def gmtime
    @time.gmtime
    self
  end
  alias :utc :gmtime

  def localtime utc_offset = nil
    if utc_offset then
      @time.localtime(utc_offset)
    else
      @time.localtime
    end
    self
  end

  def round ndigits = 0
    self.class.new(@time.round(ndigits))
  end

# メソッド数が多いと def_delegator の動作が遅くなることもある。
# その場合には forwarder.rb, def_delegator() のかわりに次によっても一応動く
# ものが作れるが、 response_to? に正しく答えなくなるなど弊害もある
#
# def method_missing name, *args 
#   @time.send(name, *args)
# end

  %w(
    asctime ctime day mday dst? isdst eql? friday? gmt?
    utc? gmt_offset gmtoff utc_offset hash hour min mon month
    monday? nsec tv_nsec saturday? sec subsec sunday? thursday?
    to_a to_f to_i tv_sec to_r to_s tuesday? tv_usec usec wday wednesday? yday year zone
  ).each { |name|
    def_delegator :@time, name
  }

end
