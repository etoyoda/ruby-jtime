# jtime.rb would be like this if I choose "delegation" pattern instead of extending Time.

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
    self
  end

  private :_gengo_

  def initialize *args
    @time = case args.first
      when Time then args.first
      when Integer, String then Time.new(*args)
      when NilClass then Time.now
      else raise ArgumentError, "#{args.first.class} not accepted"
      end
    _gengo_
  end

  class << self

    def at itime, usec = 0
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

  def era_year_name
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

  def - other
    case other
    when Time, JTime, Numeric then to_f - other.to_f
    else raise ArgumentError
    end
  end

  def + other
    case other
    when Numeric then JTime.at(to_f + other.to_f)
    else raise ArgumentError
    end
  end

  def <=> other
    case other
    when JTime then @time <=> other.to_time
    when Time then @time <=> other
    when Numeric then to_f <=> other
    else raise ArgumentError
    end
  end

#
# def method_missing name, *args 
#   @time.send(name, *args)
# end

  %w(
    asctime ctime day mday dst? isdst eql? friday? getgm getutc getlocal gmt?
    utc? gmt_offset gmtoff utc_offset gmtime utc hash hour localtime min mon month
    monday? nsec tv_nsec round saturday? sec subsec succ sunday? thursday?
    to_a to_f to_i tv_sec to_r to_s tuesday? tv_usec usec wday wednesday? yday year zone
  ).each { |name|
    def_delegator :@time, name
  }

end
