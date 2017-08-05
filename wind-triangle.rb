#!/usr/bin/env ruby

#
# wind-triangle.rb
# 
# calculate ground speed and wind correction angle
#

def wind_triangle(tc, tas, wa, ws)
    tcr = tc * Math::PI / 180
    war = wa * Math::PI / 180
    wcar = Math.asin(ws / tas * Math.sin(war - tcr))

    gs = ws * Math.sin(wcar.abs + war - tcr) / Math.sin(wcar)
    
    return gs, wcar * 180 / Math::PI
end

if __FILE__ == $0
    if ARGV[0] and ARGV[0].match(/[\d]+/)
        tc = ARGV[0].to_f
    end

    if ARGV[1] and ARGV[1].match(/[\d]+/)
        tas = ARGV[1].to_f
    end

    if ARGV[2] and ARGV[2].match(/[\d]+/)
        wa = ARGV[2].to_f
    end

    if ARGV[3] and ARGV[3].match(/[\d]+/)
        ws = ARGV[3].to_f
    end

    if not tc  or tc < 0  or tc > 360
       not tas or tas < 0 or
       not wa  or wa  < 0 or wa > 360
       not ws  or ws  < 0
        puts("usage: wind-triangle <tc> <tas> <wa> <ws>")
        puts()
        puts("           tc:  true course   [0-360]")
        puts("           tas: true airspeed [kt]")
        puts("           wa:  wind angle    [0-360]")
        puts("           ws:  wind speed    [kt]")
        exit 1
    end

    gs, wca = wind_triangle(tc, tas, wa, ws)

    puts("gs   = #{("% .2f" % gs ).rjust(7)}")
    puts("wca  = #{("% .2f" % wca).rjust(7)}")
end
