local bench = { }

bench.random_hamming_freq = function (s, q)
   local _s = s or 97
   local _q = q or 5000
   act("Benchmark: hamming distance between random, arguments: ".._s.." ".._q)

   -- ECP coordinates are 97 bytes
   local new = O.random(_s)
   local tot = 0
   local old
   for i=_q,1,-1 do
	  old = new
	  new = O.random(_s)
	  tot = tot + O.hamming(old,new)
   end
   return tot / _q
end

bench.random_kdf = function()
   act("Benchmark: KDF2 SHA256 and SHA512 on random")
   -- KDF2 input can be any, output
   local r = O.random(64)
   ECDH.kdf2(HASH.new('SHA256'),r)
   ECDH.kdf2(HASH.new('SHA512'),r)
end


-- find primes
local square = {} for i=0,9 do square[i]=i*i end
local function sqrsum(n)
   local sum = 0
   while n > 0 do sum, n = sum + square[n % 10], math.floor(n / 10) end
   return sum
end
local function isHappy(n)
   while n ~= 1 and n ~= 4 do n = sqrsum(n) end
   return n == 1
end
local prime_numbers = { 2, 3 }
local function isPrime(n)
   if n == 1 then return true end
   for _,i in ipairs(prime_numbers) do
	  if n == i then return true end
	  if n%i == 0 then return false end
   end
   for i = prime_numbers[#prime_numbers], math.floor(n/2)+1, 2 do
	  if n%i == 0 then return false end
   end
   if n > prime_numbers[#prime_numbers] then
	  table.insert(prime_numbers, n)
   end
   return true
end
bench.math = function(a, b, c)

   local _a = a or 50000
   local _b = b or _a+50000
   local _c = c or 1
   act("Benchmark: math based prime number, args: ".._a.." ".._b.." ".._c)
   local res = { }
   for n=_a,_b,_c do 
	  if isHappy(n) and isPrime(n) then
		 table.insert(res, n)
	  end
   end
   return res
end

function bench.bit32(N)
   N = N or 1000
   act("Benchmark: bit32 based Mandelbrot generation, iterations: "..N)
   local bit = bit32
   local bor, band = bit.bor, bit.band
   local shl, shr, rol = bit.lshift, bit.rshift, bit.lrotate
   local char, unpack = string.char, table.unpack

   local M, buf = 2/N, {}
   for y=0,N-1 do
	  local Ci, b, p = y*M-1, -16777216, 0
	  local Ciq = Ci*Ci
	  for x=0,N-1,2 do
		 local Cr, Cr2 = x*M-1.5, (x+1)*M-1.5
		 local Zr, Zi, Zrq, Ziq = Cr, Ci, Cr*Cr, Ciq
		 local Zr2, Zi2, Zrq2, Ziq2 = Cr2, Ci, Cr2*Cr2, Ciq
		 b = rol(b, 2)
		 for i=1,49 do
			Zi = Zr*Zi*2 + Ci; Zi2 = Zr2*Zi2*2 + Ci
			Zr = Zrq-Ziq + Cr; Zr2 = Zrq2-Ziq2 + Cr2
			Ziq = Zi*Zi; Ziq2 = Zi2*Zi2
			Zrq = Zr*Zr; Zrq2 = Zr2*Zr2
			if band(b, 2) ~= 0 and Zrq+Ziq > 4.0 then b = band(b, -3) end
			if band(b, 1) ~= 0 and Zrq2+Ziq2 > 4.0 then b = band(b, -2) end
			if band(b, 3) == 0 then break end
		 end
		 if b >= 0 then p = p + 1; buf[p] = b; b = -16777216; end
	  end
	  if b ~= -16777216 then
		 if band(N, 1) ~= 0 then b = shr(b, 1) end
		 p = p + 1; buf[p] = shl(b, 8-band(N, 7))
	  end
	  -- write(char(unpack(buf, 1, p)))
	  -- write('.')
   end
   -- print('.')
end



return bench
