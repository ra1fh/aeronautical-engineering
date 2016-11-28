#!/usr/bin/env ruby
#
# ptr-calc.rb
# 
# calculate pressure, temperature, density in standard atmosphere
# for given altitude
#

T0   = 288.15  # K
P0   = 101325  # Pa
A0   = -0.0065 # K/m
A1   = 0       # K/m
A2   = 0.001   # K/m
A3   = 0.0028  # K/m
A4   = 0       # K/m
RHO0 = 1.225   # kg/m^3
G    = 9.80065 # m/s^2
R    = 287     # J/kgK

LAYERS = [
    { :h0 => 0,     :h1 => 11000, :a => A0 },
    { :h0 => 11000, :h1 => 20000, :a => A1 },
    { :h0 => 20000, :h1 => 32000, :a => A2 },
    { :h0 => 32000, :h1 => 47000, :a => A3 },
    { :h0 => 47000, :h1 => nil  , :a => A4 },
    # ... to be continued ...
]

def ptr_calc(alt)
    t = T0
    p = P0
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
    if ARGV[0] and ARGV[0].match(/[\d.]+/)
        alt = ARGV[0].to_f
    end
    if not alt or alt < 0
        puts "usage: ptr-calc <altitude>"
        exit 1
    end

    t, p, rho = ptr_calc(alt)

    puts("alt  = #{alt}")
    puts("t    = #{t} K")
    puts("p    = #{p} Pa")
    puts("rho  = #{rho} kg/m^3")
end
