#!/usr/bin/env ruby
#
# ptr-calc.rb
# 
# calculate pressure, temperature, density in standard atmosphere
# for given altitude in m or ft
#

T0   = 288.15  # K
P0   = 101325  # Pa
RHO0 = 1.225   # kg/m^3
G    = 9.80665 # m/s^2
R    = 287     # J/kgK
MPFT = 0.3048  # m/ft

LAYERS = [
    { :h0 => 0,     :h1 => 11000, :a => -0.0065 },
    { :h0 => 11000, :h1 => 20000, :a => 0       },
    { :h0 => 20000, :h1 => 32000, :a => 0.001   },
    { :h0 => 32000, :h1 => 47000, :a => 0.0028  },
    { :h0 => 47000, :h1 => nil  , :a => 0       },
    # ... to be continued ...
]

def ptr_calc(alt, qnh = nil)
    t = T0
    if qnh
        p = qnh
    else
        p = P0
    end
    rho = RHO0

    LAYERS.each do | layer |
        if alt > layer[:h0]
            if layer[:h1] and alt > layer[:h1]
                h1 = layer[:h1]
            else
                h1 = alt
            end
            t, p, rho = ptr_calc_layer(t0: t, p0: p, rho0: rho, h0: layer[:h0], h1: h1, a: layer[:a])
        end
    end
    return t, p, rho
end

def ptr_calc_layer(t0:, p0:, rho0:, h0:, h1:, a: nil)
    if a and a != 0
        t1 = t0 + a * (h1 - h0)
        p1 = p0 * (t1 / t0) ** (-G / a / R)
        rho1 = rho0 * (t1 / t0) ** (-G / a / R - 1)
        return t1, p1, rho1
    else
        t1 = t0
        p1 = p0 * Math.exp(-G / R / t0 * (h1 - h0))
        rho1 = rho0 * Math.exp(-G / R / t0 * (h1 - h0))
        return t1, p1, rho1
    end
end

if __FILE__ == $0
    if ARGV[1]
        qnh = ARGV[1].to_f * 100
    end
    if ARGV[0]
        if ARGV[0].match(/[\d.]+m/)
            alt = ARGV[0].to_f
        elsif ARGV[0].match(/[\d.]+ft/)
            alt = ARGV[0].to_f * MPFT
        else
            alt = ARGV[0].to_f
        end
    end
    if not alt or alt < 0
        puts "usage: ptr-calc <altitude> [QNH]"
        exit 1
    end

    t, p, rho = ptr_calc(alt, qnh)

    puts("alt  = #{alt} m")
    puts("     = #{alt / MPFT} ft")
    if qnh
        puts("qnh  = #{qnh / 100} hPa")
    end
    puts("t    = #{t} K")
    puts("p    = #{p} Pa")
    puts("rho  = #{rho} kg/m^3")
end
