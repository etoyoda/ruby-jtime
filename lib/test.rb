def assert v, op, q
  raise "assert #{v} #{op} #{q}" unless v.send(op, q)
  puts "ok #{v} #{op} #{q}" if $DEBUG
end
ENV['TZ'] = 'JST-9'

j = JTime.new
t = Time.new
assert(-1..0, :===, j - t)
begin
  tj = t - j
rescue TypeError
  tj = 0
end
assert(0..1, :===, tj)

assert(JTime.local(1989, 1, 1).era_name, :==, JTime::SHOWA)
assert(JTime.local(1989, 1, 7).era_name, :==, JTime::SHOWA)
assert(JTime.local(1989, 1, 7, 23, 59, 59).era_name, :==, JTime::SHOWA)
assert(JTime.local(1989, 1, 7, 23, 59, 60).era_name, :==, JTime::HEISEI)
assert(JTime.local(1989, 1, 8, 0, 0, 1).era_name, :==, JTime::HEISEI)
assert(JTime.local(2018, 10, 2).era_name, :==, JTime::HEISEI)
assert(JTime.local(2018, 10, 2).era_name, :==, JTime::HEISEI)
assert(JTime.local(2018, 10, 2).strftime('%Jf'), :==, '平成30年10月02日')
assert(JTime.local(2019, 4, 29).strftime('%Jf'), :==, '平成31年04月29日')
assert(JTime.local(2019, 4, 30).strftime('%Jf'), :==, '平成31年04月30日')
assert(JTime.local(2019, 5,  1).strftime('%Jf'), :==, JTime::ERA2019 + '元年05月01日')
assert(JTime.local(2019, 12,31).strftime('%Jf'), :==, JTime::ERA2019 + '元年12月31日')
assert(JTime.local(2020, 1,  1).strftime('%Jf'), :==, JTime::ERA2019 + '2年01月01日')
