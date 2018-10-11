class JTime < Time

  MEIJI_LIMIT = Time.gm(1912, 7, 29, 15, 43)
  TAISHO = '大正'
  TAISHO_LIMIT = Time.gm(1926, 12, 24, 16, 25)
  SHOWA = '昭和'
  SHOWA_LIMIT = Time.gm(1989, 1, 7, 15, 0)
  HEISEI = '平成'
  HEISEI_LIMIT = Time.gm(2019, 4, 30, 15, 0)
  ERA2019 = '〓〓'

  def _gengo_
    return if defined?(@era_name)
    if self <= TAISHO_LIMIT
      @era_name = TAISHO
      @era_year = year - 1911
    elsif self < SHOWA_LIMIT
      @era_name = SHOWA
      @era_year = year - 1925
    elsif self < HEISEI_LIMIT
      @era_name = HEISEI
      @era_year = year - 1988
    else
      @era_name = ERA2019
      @era_year = year - 2018
    end
    if utc_offset < 32400
      raise "Japanese era not allowed for timezone west of 135E"
    end
    self
  end

  private :_gengo_

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
    super(fmt.
      gsub(/%Jf/, '%Je%Jgk年%m月%d日').
      gsub(/%Jy(k?)/, '%Je%Jg\1').
      gsub(/%Je/){ era_name }.
      gsub(/%Jgk/){ era_year_name }.
      gsub(/%Jg/){ era_year })
  end

  def + other
    self.class.new(super.to_f)
  end

  def - other
    case other
    when Numeric then self.class.new(super.to_f)
    else super
    end
  end

  def succ
    self.class.at(super)
  end

  def round ndigits = 0
    self.class.at(super)
  end

end
