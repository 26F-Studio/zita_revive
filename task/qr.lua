--- The qrcode library is licensed under the 3-clause BSD license (aka "new BSD")
--- To get in contact with the author, mail to <gundlach@speedata.de>.
---
--- Original github project page: http://speedata.github.io/luaqrcode/)
---
--- Edited by MrZ (626.mrz@gmail.com)

-- Copyright (c) 2012-2020, Patrick Gundlach and contributors, see https://github.com/speedata/luaqrcode
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--	 * Redistributions of source code must retain the above copyright
--	   notice, this list of conditions and the following disclaimer.
--	 * Redistributions in binary form must reproduce the above copyright
--	   notice, this list of conditions and the following disclaimer in the
--	   documentation and/or other materials provided with the distribution.
--	 * Neither the name of SPEEDATA nor the
--	   names of its contributors may be used to endorse or promote products
--	   derived from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL SPEEDATA GMBH BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

local tonumber=tonumber
local min,floor,abs=math.min,math.floor,math.abs
local byte,sub,rep=string.byte,string.sub,string.rep
local gsub,match,format=string.gsub,string.match,string.format
local concat=table.concat
local bxor=bit.bxor

local hexToBin={[48]='0000',[49]='0001',[50]='0010',[51]='0011',[52]='0100',[53]='0101',[54]='0110',[55]='0111',[56]='1000',[57]='1001',[65]='1010',[66]='1011',[67]='1100',[68]='1101',[69]='1110',[70]='1111'}
local hexTable={[0]='0000',[1]='0001',[2]='0010',[3]='0011',[4]='0100',[5]='0101',[6]='0110',[7]='0111',[8]='1000',[9]='1001',[10]='1010',[11]='1011',[12]='1100',[13]='1101',[14]='1110',[15]='1111'}
-- return 0&1 string of a number with specified digits
local function toBinStr(n,digits)
    local s
    if n<=0xF then
        s=hexTable[n]
    elseif n<=0xFF then
        s=hexTable[floor(n/16)]..hexTable[n%16]
    else
        local hs=format('%X',n)
        s=hexToBin[byte(hs,1)]
        for i=2,#hs do
            s=s..hexToBin[byte(hs,i)]
        end
    end
    if #s>digits then s=gsub(s,'^0+','') end
    return rep('0',digits-#s)..s
end

-- The capacity (number of codewords) of each version (1-40) for error correction levels 1-4 (LMQH).
-- The higher the ec level, the lower the capacity of the version. Taken from spec, tables 7-11.
local capacity={
    {19, 16,13,9},{34,28,22,16},{55,44,34,26},{80,64,48,36},
    {108,86,62,46},{136,108,76,60},{156,124,88,66},{194,154,110,86},
    {232,182,132,100},{274,216,154,122},{324,254,180,140},{370,290,206,158},
    {428,334,244,180},{461,365,261,197},{523,415,295,223},{589,453,325,253},
    {647,507,367,283},{721,563,397,313},{795,627,445,341},{861,669,485,385},
    {932,714,512,406},{1006,782,568,442},{1094,860,614,464},{1174,914,664,514},
    {1276,1000,718,538},{1370,1062,754,596},{1468,1128,808,628},{1531,1193,871,661},
    {1631,1267,911,701},{1735,1373,985,745},{1843,1455,1033,793},{1955,1541,1115,845},
    {2071,1631,1171,901},{2191,1725,1231,961},{2306,1812,1286,986},{2434,1914,1354,1054},
    {2566,1992,1426,1096},{2702,2102,1502,1142},{2812,2216,1582,1222},{2956,2334,1666,1276},
}

local ver_mode_bits={
    {[1]=10,[2]=9, [4]=8, [8]=8},
    {[1]=12,[2]=11,[4]=16,[8]=10},
    {[1]=14,[2]=13,[4]=16,[8]=12},
}

local function get_version_eclevel(len,mode,requested_ec_level)
    local bits,digits,modebits
    local minversion=40
    local maxec_level=requested_ec_level or 1
    local minlv,maxlv=1,4
    if requested_ec_level and requested_ec_level>=1 and requested_ec_level<=4 then
        minlv=requested_ec_level
        maxlv=requested_ec_level
    end
    for ec_level=minlv,maxlv do
        for version=1,#capacity do
            bits=capacity[version][ec_level]*8-4 -- "-4" because mode indicator
            if version<10 then
                digits=ver_mode_bits[1][mode]
            elseif version<27 then
                digits=ver_mode_bits[2][mode]
            elseif version<=40 then
                digits=ver_mode_bits[3][mode]
            end
            modebits=bits-digits
            local _
            if mode==1 then
                _=floor(modebits*3/10)
            elseif mode==2 then
                _=floor(modebits*2/11)
            elseif mode==4 then
                _=floor(modebits*1/8)
            else
                _=floor(modebits*1/13)
            end
            if _>=len then
                if version<=minversion then
                    minversion=version
                    maxec_level=ec_level
                end
                break
            end
        end
    end
    return minversion,maxec_level
end

-- Return a bit string of 0s and 1s that includes the length of the code string.
-- The modes are numeric = 1, alphanumeric = 2, binary = 4, and japanese = 8
local function get_length(str,version,mode)
    local digits
    if version<=9 then
        digits=ver_mode_bits[1][mode]
    elseif version<=26 then
        digits=ver_mode_bits[2][mode]
    else
        digits=ver_mode_bits[3][mode]
    end
    return toBinStr(#str,digits)
end

local function get_version_eclevel_mode_bistringlength(str,requested_ec_level)
    local mode=
        match(str,'^[0-9]+$') and 1 or              -- numeric
        match(str,'^[0-9A-Z $%%*./:+-]+$') and 2 or -- alphanumeric
        4                                           -- binary

    local version,ec_level=get_version_eclevel(#str,mode,requested_ec_level)
    return
        version,
        ec_level,
        mode,
        toBinStr(mode,4)..get_length(str,version,mode)
end

local asciitbl={
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,    -- 0x01-0x0F
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, -- 0x10-0x1F
    36,-1,-1,-1,37,38,-1,-1,-1,-1,39,40,-1,41,42,43, -- 0x20-0x2F
    00,01,02,03,04,05,06,07,08,09,44,-1,-1,-1,-1,-1, -- 0x30-0x3F
    -1,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24, -- 0x40-0x4F
    25,26,27,28,29,30,31,32,33,34,35,-1,-1,-1,-1,-1, -- 0x50-0x5F
}

-- Return a binary representation of the numeric string `str`. This must contain only digits 0-9.
local function encode_string_numeric(str)
    local buffer={}
    for i=1,#str,3 do
        local a=sub(str,i,i+2)
        -- #a is 1, 2, or 3, so bits are 4, 7, or 10
        buffer[#buffer+1]=toBinStr(tonumber(a),#a*3+1)
    end
    return concat(buffer)
end

-- Return a binary representation of the alphanumeric string `str`. This must contain only
-- digits 0-9, uppercase letters A-Z, space and the following chars: $%*./:+-.
local function encode_string_ascii(str)
    local buffer={}
    for i=1,#str,2 do
        local a=sub(str,i,i+1)
        if #a==2 then
            buffer[#buffer+1]=toBinStr(asciitbl[byte(a,1)]*45+asciitbl[byte(a,2)],11)
        else
            buffer[#buffer+1]=toBinStr(asciitbl[byte(a)],6)
        end
    end
    return concat(buffer)
end

-- Return a bitstring representing string str in binary mode.
-- We don't handle UTF-8 in any special way because we assume the
-- scanner recognizes UTF-8 and displays it correctly.
local function encode_string_binary(str)
    local buffer={}
    for i=1,#str do
        buffer[i]=toBinStr(byte(str,i),8)
    end
    return concat(buffer)
end

-- Encoding the codeword is not enough. We need to make sure that
-- the length of the binary string is equal to the number of codewords of the version.
local function add_padding(version,ec_level,data)
    local cpty=capacity[version][ec_level]*8
    local count_to_pad=min(4,cpty-#data)
    if count_to_pad>0 then data=data..rep('0',count_to_pad) end
    if #data%8~=0 then data=data..rep('0',8-#data%8) end
    for i=1,(cpty-#data)/8 do data=data..(i%2==1 and '11101100' or '00010001') end
    return data
end

-- https://codyplanteen.com/assets/rs/gf256_log_antilog.pdf
local alpha_int={
    2,4,8,16,32,64,128,29,58,116,232,205,135,19,38,76,
    152,45,90,180,117,234,201,143,3,6,12,24,48,96,192,157,
    39,78,156,37,74,148,53,106,212,181,119,238,193,159,35,70,
    140,5,10,20,40,80,160,93,186,105,210,185,111,222,161,95,
    190,97,194,153,47,94,188,101,202,137,15,30,60,120,240,253,
    231,211,187,107,214,177,127,254,225,223,163,91,182,113,226,217,
    175,67,134,17,34,68,136,13,26,52,104,208,189,103,206,129,
    31,62,124,248,237,199,147,59,118,236,197,151,51,102,204,133,
    23,46,92,184,109,218,169,79,158,33,66,132,21,42,84,168,
    77,154,41,82,164,85,170,73,146,57,114,228,213,183,115,230,
    209,191,99,198,145,63,126,252,229,215,179,123,246,241,255,227,
    219,171,75,150,49,98,196,149,55,110,220,165,87,174,65,130,
    25,50,100,200,141,7,14,28,56,112,224,221,167,83,166,81,
    162,89,178,121,242,249,239,195,155,43,86,172,69,138,9,18,
    36,72,144,61,122,244,245,247,243,251,235,203,139,11,22,44,
    88,176,125,250,233,207,131,27,54,108,216,173,71,142,0,0,
}
alpha_int[0]=1
local int_alpha={}
for i=0,256 do int_alpha[alpha_int[i]]=i end

-- We only need the polynomial generators for block sizes 7, 10, 13, 15, 16, 17, 18, 20, 22, 24, 26, 28, and 30. Version
-- 2 of the qr codes don't need larger ones (as opposed to version 1). The table has the format x^1*ɑ^21 + x^2*a^102 ...
local generator_polynomial={
    [7]={21,102,238,149,146,229,87,0},
    [10]={45,32,94,64,70,118,61,46,67,251,0},
    [13]={78,140,206,218,130,104,106,100,86,100,176,152,74,0},
    [15]={105,99,5,124,140,237,58,58,51,37,202,91,61,183,8,0},
    [16]={120,225,194,182,169,147,191,91,3,76,161,102,109,107,104,120,0},
    [17]={136,163,243,39,150,99,24,147,214,206,123,239,43,78,206,139,43,0},
    [18]={153,96,98,5,179,252,148,152,187,79,170,118,97,184,94,158,234,215,0},
    [20]={190,188,212,212,164,156,239,83,225,221,180,202,187,26,163,61,50,79,60,17,0},
    [22]={231,165,105,160,134,219,80,98,172,8,74,200,53,221,109,14,230,93,242,247,171,210,0},
    [24]={21,227,96,87,232,117,0,111,218,228,226,192,152,169,180,159,126,251,117,211,48,135,121,229,0},
    [26]={70,218,145,153,227,48,102,13,142,245,21,161,53,165,28,111,201,145,17,118,182,103,2,158,125,173,0},
    [28]={123,9,37,242,119,212,195,42,87,245,43,21,201,232,27,205,147,195,190,110,180,108,234,224,104,200,223,168,0},
    [30]={180,192,40,238,216,251,37,156,130,224,193,226,173,42,125,222,96,239,86,110,48,50,182,179,31,216,152,145,173,41,0},
}

-- That's the heart of the error correction calculation.
local function calculate_error_correction(data,num_ec_codewords)
    -- Turn the binary string of length 8*x into a table size x of numbers.
    local mp={}
    for i=1,#data/8 do mp[i]=tonumber(sub(data,i*8-7,i*8),2) end

    local msgLen=#mp

    local top_exp=msgLen+num_ec_codewords-1
    local _mp,_gp -- message polynomial & generator polynomial

    -- create message shifted to left (highest exponent)
    _mp={[0]=0}
    for i=1,top_exp-msgLen do _mp[i]=0 end
    for i=msgLen,1,-1 do _mp[#_mp+1]=mp[i] end


    while true do
        -- Get a table that has 0's in the first entries and then the alpha
        -- representation of the generator polynominal
        _gp={}
        for i=0,top_exp-num_ec_codewords-1 do _gp[i]=0 end
        local L=generator_polynomial[num_ec_codewords]
        for i=1,num_ec_codewords+1 do _gp[top_exp-num_ec_codewords+i-1]=L[i] end

        -- Multiply generator polynomial by first coefficient of the above polynomial

        -- take the highest exponent from the message polynom (alpha) and add
        -- it to the generator polynom
        local exp=int_alpha[_mp[top_exp]]
        for i=top_exp,top_exp-num_ec_codewords,-1 do _gp[i]=exp==256 and 256 or (_gp[i]+exp)%255 end
        for i=top_exp-num_ec_codewords-1,0,-1 do _gp[i]=256 end
        for i=0,top_exp do _mp[i]=bxor(alpha_int[_gp[i]],_mp[i]) end

        for i=top_exp,num_ec_codewords,-1 do
            if _mp[i]~=0 then break end
            top_exp=i-1
        end

        if top_exp<num_ec_codewords then break end
    end

    local buffer={}
    for x=top_exp,0,-1 do
        buffer[top_exp-x+1]=toBinStr(_mp[x],8)
    end
    return concat(buffer)
end

-- ecblocks has 40 entries, one for each version. Each version entry has 4 entries, for each LMQH
-- ec level. Each entry has two or four fields, the odd files are the number of repetitions for the
-- folowing block info. The first entry of the block is the total number of codewords in the block,
-- the second entry is the number of data codewords. The third is not important.
local ecblocks={
    {{1,{26,19,2}},                   {1,{26,16,4}},                {1,{26,13,6}},                {1,{26,9,8}}},
    {{1,{44,34,4}},                   {1,{44,28,8}},                {1,{44,22,11}},               {1,{44,16,14}}},
    {{1,{70,55,7}},                   {1,{70,44,13}},               {2,{35,17,9}},                {2,{35,13,11}}},
    {{1,{100,80,10}},                 {2,{50,32,9}},                {2,{50,24,13}},               {4,{25,9,8}}},
    {{1,{134,108,13}},                {2,{67,43,12}},               {2,{33,15,9},2,{34,16,9}},    {2,{33,11,11},2,{34,12,11}}},
    {{2,{86,68,9}},                   {4,{43,27,8}},                {4,{43,19,12}},               {4,{43,15,14}}},
    {{2,{98,78,10}},                  {4,{49,31,9}},                {2,{32,14,9},4,{33,15,9}},    {4,{39,13,13},1,{40,14,13}}},
    {{2,{121,97,12}},                 {2,{60,38,11},2,{61,39,11}},  {4,{40,18,11},2,{41,19,11}},  {4,{40,14,13},2,{41,15,13}}},
    {{2,{146,116,15}},                {3,{58,36,11},2,{59,37,11}},  {4,{36,16,10},4,{37,17,10}},  {4,{36,12,12},4,{37,13,12}}},
    {{2,{86,68,9},2,{87,69,9}},       {4,{69,43,13},1,{70,44,13}},  {6,{43,19,12},2,{44,20,12}},  {6,{43,15,14},2,{44,16,14}}},
    {{4,{101,81,10}},                 {1,{80,50,15},4,{81,51,15}},  {4,{50,22,14},4,{51,23,14}},  {3,{36,12,12},8,{37,13,12}}},
    {{2,{116,92,12},2,{117,93,12}},   {6,{58,36,11},2,{59,37,11}},  {4,{46,20,13},6,{47,21,13}},  {7,{42,14,14},4,{43,15,14}}},
    {{4,{133,107,13}},                {8,{59,37,11},1,{60,38,11}},  {8,{44,20,12},4,{45,21,12}},  {12,{33,11,11},4,{34,12,11}}},
    {{3,{145,115,15},1,{146,116,15}}, {4,{64,40,12},5,{65,41,12}},  {11,{36,16,10},5,{37,17,10}}, {11,{36,12,12},5,{37,13,12}}},
    {{5,{109,87,11},1,{110,88,11}},   {5,{65,41,12},5,{66,42,12}},  {5,{54,24,15},7,{55,25,15}},  {11,{36,12,12},7,{37,13,12}}},
    {{5,{122,98,12},1,{123,99,12}},   {7,{73,45,14},3,{74,46,14}},  {15,{43,19,12},2,{44,20,12}}, {3,{45,15,15},13,{46,16,15}}},
    {{1,{135,107,14},5,{136,108,14}}, {10,{74,46,14},1,{75,47,14}}, {1,{50,22,14},15,{51,23,14}}, {2,{42,14,14},17,{43,15,14}}},
    {{5,{150,120,15},1,{151,121,15}}, {9,{69,43,13},4,{70,44,13}},  {17,{50,22,14},1,{51,23,14}}, {2,{42,14,14},19,{43,15,14}}},
    {{3,{141,113,14},4,{142,114,14}}, {3,{70,44,13},11,{71,45,13}}, {17,{47,21,13},4,{48,22,13}}, {9,{39,13,13},16,{40,14,13}}},
    {{3,{135,107,14},5,{136,108,14}}, {3,{67,41,13},13,{68,42,13}}, {15,{54,24,15},5,{55,25,15}}, {15,{43,15,14},10,{44,16,14}}},
    {{4,{144,116,14},4,{145,117,14}}, {17,{68,42,13}},              {17,{50,22,14},6,{51,23,14}}, {19,{46,16,15},6,{47,17,15}}},
    {{2,{139,111,14},7,{140,112,14}}, {17,{74,46,14}},              {7,{54,24,15},16,{55,25,15}}, {34,{37,13,12}}},
    {{4,{151,121,15},5,{152,122,15}}, {4,{75,47,14},14,{76,48,14}}, {11,{54,24,15},14,{55,25,15}},{16,{45,15,15},14,{46,16,15}}},
    {{6,{147,117,15},4,{148,118,15}}, {6,{73,45,14},14,{74,46,14}}, {11,{54,24,15},16,{55,25,15}},{30,{46,16,15},2,{47,17,15}}},
    {{8,{132,106,13},4,{133,107,13}}, {8,{75,47,14},13,{76,48,14}}, {7,{54,24,15},22,{55,25,15}}, {22,{45,15,15},13,{46,16,15}}},
    {{10,{142,114,14},2,{143,115,14}},{19,{74,46,14},4,{75,47,14}}, {28,{50,22,14},6,{51,23,14}}, {33,{46,16,15},4,{47,17,15}}},
    {{8,{152,122,15},4,{153,123,15}}, {22,{73,45,14},3,{74,46,14}}, {8,{53,23,15},26,{54,24,15}}, {12,{45,15,15},28,{46,16,15}}},
    {{3,{147,117,15},10,{148,118,15}},{3,{73,45,14},23,{74,46,14}}, {4,{54,24,15},31,{55,25,15}}, {11,{45,15,15},31,{46,16,15}}},
    {{7,{146,116,15},7,{147,117,15}}, {21,{73,45,14},7,{74,46,14}}, {1,{53,23,15},37,{54,24,15}}, {19,{45,15,15},26,{46,16,15}}},
    {{5,{145,115,15},10,{146,116,15}},{19,{75,47,14},10,{76,48,14}},{15,{54,24,15},25,{55,25,15}},{23,{45,15,15},25,{46,16,15}}},
    {{13,{145,115,15},3,{146,116,15}},{2,{74,46,14},29,{75,47,14}}, {42,{54,24,15},1,{55,25,15}}, {23,{45,15,15},28,{46,16,15}}},
    {{17,{145,115,15}},               {10,{74,46,14},23,{75,47,14}},{10,{54,24,15},35,{55,25,15}},{19,{45,15,15},35,{46,16,15}}},
    {{17,{145,115,15},1,{146,116,15}},{14,{74,46,14},21,{75,47,14}},{29,{54,24,15},19,{55,25,15}},{11,{45,15,15},46,{46,16,15}}},
    {{13,{145,115,15},6,{146,116,15}},{14,{74,46,14},23,{75,47,14}},{44,{54,24,15},7,{55,25,15}}, {59,{46,16,15},1,{47,17,15}}},
    {{12,{151,121,15},7,{152,122,15}},{12,{75,47,14},26,{76,48,14}},{39,{54,24,15},14,{55,25,15}},{22,{45,15,15},41,{46,16,15}}},
    {{6,{151,121,15},14,{152,122,15}},{6,{75,47,14},34,{76,48,14}}, {46,{54,24,15},10,{55,25,15}},{2,{45,15,15},64,{46,16,15}}},
    {{17,{152,122,15},4,{153,123,15}},{29,{74,46,14},14,{75,47,14}},{49,{54,24,15},10,{55,25,15}},{24,{45,15,15},46,{46,16,15}}},
    {{4,{152,122,15},18,{153,123,15}},{13,{74,46,14},32,{75,47,14}},{48,{54,24,15},14,{55,25,15}},{42,{45,15,15},32,{46,16,15}}},
    {{20,{147,117,15},4,{148,118,15}},{40,{75,47,14},7,{76,48,14}}, {43,{54,24,15},22,{55,25,15}},{10,{45,15,15},67,{46,16,15}}},
    {{19,{148,118,15},6,{149,119,15}},{18,{75,47,14},31,{76,48,14}},{34,{54,24,15},34,{55,25,15}},{20,{45,15,15},61,{46,16,15}}},
}

-- The given data can be a string of 0's and 1' (with #string mod 8 == 0).
-- Alternatively the data can be a table of codewords. The number of codewords
-- must match the capacity of the qr code.
local function arrange_codewords_and_calculate_ec(version,ec_level,data)
    -- if type(data)=='table' then
    --     for i=1,#data do
    --         data[i]=toBinStr(data[i],8)
    --     end
    --     data=concat(data)
    -- end

    -- If the size of the data is not enough for the codeword, we add 0's and two special bytes until finished.
    local blocks=ecblocks[version][ec_level]
    local size_data_bytes,size_ec_bytes
    local datablocks={}
    local final_ecblocks={}
    local count=1
    local pos=0
    local cpty_ec_bits=0
    for i=1,#blocks/2 do
        size_data_bytes=blocks[2*i][2]
        size_ec_bytes=blocks[2*i][1]-size_data_bytes
        for _=1,blocks[2*i-1] do
            cpty_ec_bits=cpty_ec_bits+size_ec_bytes*8
            datablocks[count]=sub(data,pos*8+1,(pos+size_data_bytes)*8)
            final_ecblocks[count]=calculate_error_correction(datablocks[count],size_ec_bytes)
            pos=pos+size_data_bytes
            count=count+1
        end
    end

    -- data
    local arranged_data={}
    local len
    len,pos=0,1
    while len<#data do
        for i=1,#datablocks do
            if pos<#datablocks[i] then
                arranged_data[#arranged_data+1]=sub(datablocks[i],pos, pos+7)
                len=len+8
            end
        end
        pos=pos+8
    end
    -- ec
    len,pos=0,1
    while len<cpty_ec_bits do
        for i=1,#final_ecblocks do
            if pos<#final_ecblocks[i] then
                arranged_data[#arranged_data+1]=sub(final_ecblocks[i],pos, pos+7)
                len=len+8
            end
        end
        pos=pos+8
    end
    return concat(arranged_data)
end

-- Position Detection Pattern & Alignment Pattern
local PDpat,Apat
do
    local _=-2
    PDpat={
        {_,_,_,_,_,_,_,_,_},
        {_,2,2,2,2,2,2,2,_},
        {_,2,_,_,_,_,_,2,_},
        {_,2,_,2,2,2,_,2,_},
        {_,2,_,2,2,2,_,2,_},
        {_,2,_,2,2,2,_,2,_},
        {_,2,_,_,_,_,_,2,_},
        {_,2,2,2,2,2,2,2,_},
        {_,_,_,_,_,_,_,_,_},
    }
    Apat={
        {2,2,2,2,2},
        {2,_,_,_,2},
        {2,_,2,_,2},
        {2,_,_,_,2},
        {2,2,2,2,2},
    }
end

local function add_position_detection_pattern(mat,x,y)
    for dx=1,9 do
        local L=mat[x+dx]
        if L then
            local L2=PDpat[dx]
            for dy=1,9 do
                if L[y+dy] then
                    L[y+dy]=L2[dy]
                end
            end
        end
    end
end

-- For each version, where should we place the alignment patterns? See table E.1 of the spec
local alignment_pattern_pos={
    {},{6,18},{6,22},{6,26},{6,30},{6,34},                                                                                                                 -- 1-6
    {6,22,38},{6,24,42},{6,26,46},{6,28,50},{6,30,54},{6,32,58},{6,34,62},                                                                                 -- 7-13
    {6,26,46,66},{6,26,48,70},{6,26,50,74},{6,30,54,78},{6,30,56,82},{6,30,58,86},{6,34,62,90},                                                            -- 14-20
    {6,28,50,72,94},{6,26,50,74,98},{6,30,54,78,102},{6,28,54,80,106},{6,32,58,84,110},{6,30,58,86,114},{6,34,62,90,118},                                  -- 21-27
    {6,26,50,74,98, 122},{6,30,54,78,102,126},{6,26,52,78,104,130},{6,30,56,82,108,134},{6,34,60,86,112,138},{6,30,58,86,114,142},{6,34,62,90,118,146},    -- 28-34
    {6,30,54,78,102,126,150},{6,24,50,76,102,128,154},{6,28,54,80,106,132,158},{6,32,58,84,110,136,162},{6,26,54,82,110,138,166},{6,30,58,86,114,142,170}, -- 35-40
}

local function add_alignment_pattern(mat,version)
    local ap=alignment_pattern_pos[version]
    local pos_x,pos_y
    for x=1,#ap do
        for y=1,#ap do
            -- no pattern on top of the positioning pattern
            if not (x*y==1 or x==#ap and y==1 or x==1 and y==#ap) then
                pos_x,pos_y=ap[x]-2,ap[y]-2
                for dy=1,5 do
                    for dx=1,5 do
                        mat[pos_x+dx][pos_y+dy]=Apat[dx][dy]
                    end
                end
            end
        end
    end
end

-- Bits for version information 7-40
-- The reversed strings from https://www.thonky.com/qr-code-tutorial/format-version-tables
local version_information={
    '001010010011111000','001111011010000100','100110010101100100','110010110010010100',
    '011011111101110100','010001101110001100','111000100001101100','101100000110011100','000101001001111100',
    '000111101101000010','101110100010100010','111010000101010010','010011001010110010','011001011001001010',
    '110000010110101010','100100110001011010','001101111110111010','001000110111000110','100001111000100110',
    '110101011111010110','011100010000110110','010110000011001110','111111001100101110','101011101011011110',
    '000010100100111110','101010111001000001','000011110110100001','010111010001010001','111110011110110001',
    '110100001101001001','011101000010101001','001001100101011001','100000101010111001','100101100011000101',
}

-- Versions 7+ need two bitfields with version information added to the code
local function add_version(mat,version)
    if version<=6 then return end
    local bitstring=version_information[version-6]
    local start_x,start_y=#mat-10,1
    for i=1,#bitstring do
        local b=byte(bitstring,i)==48 and -2 or 2
        local x,y=start_x+(i-1)%3,start_y+floor((i-1)/3)
        mat[x][y]=b -- top right
        mat[y][x]=b -- bottom left
    end
end

-- The first index is ec level (LMQH,1-4), the second is the mask (0-7). This bitstring of length 15 is to be used
-- as mandatory pattern in the qrcode. Mask -1 is for debugging purpose only and is the 'noop' mask.
local typeinfoLib={
    {[0]='111011111000100','111001011110011','111110110101010','111100010011101','110011000101111','110001100011000','110110001000001','110100101110110'},
    {[0]='101010000010010','101000100100101','101111001111100','101101101001011','100010111111001','100000011001110','100111110010111','100101010100000'},
    {[0]='011010101011111','011000001101000','011111100110001','011101000000110','010010010110100','010000110000011','010111011011010','010101111101101'},
    {[0]='001011010001001','001001110111110','001110011100111','001100111010000','000011101100010','000001001010101','000110100001100','000100000111011'},
}

-- The typeinfo is a mixture of mask and ec level information and is
-- added twice to the qr code, one horizontal, one vertical.
local function add_typeinfo(mat,ec_level,mask)
    local typeInfo=typeinfoLib[ec_level][mask]

    -- vertical from bottom to top
    local L=mat[9]
    for i=1,7 do L[#mat+1-i]=byte(typeInfo,i)==49 and 2 or -2 end
    for i=8,9 do L[17-i]=byte(typeInfo,i)==49 and 2 or -2 end
    for i=10,15 do L[16-i]=byte(typeInfo,i)==49 and 2 or -2 end
    -- horizontal, left to right
    for i=1,6 do mat[i][9]=byte(typeInfo,i)==49 and 2 or -2 end
    mat[8][9]=byte(typeInfo,7)==49 and 2 or -2
    for i=8,15 do mat[#mat-15+i][9]=byte(typeInfo,i)==49 and 2 or -2 end
end

-- Mask functions, replaced x with x-1 because the coordinate is 1-based indexed but original formulas are 0-based.
local maskFunc={
    [0]=function(j,i) return (i+j)%2==0 end,
    function(_,i) return i%2==0 end,
    function(j,_) return j%3==0 end,
    function(j,i) return (i+j)%3==0 end,
    function(j,i) return (i%4-1.5)*(j%6-2.5)>0 end,
    function(j,i) return (i*j)%2+(i*j)%3==0 end,
    function(j,i) return ((i*j)%3+i*j)%2==0 end,
    function(j,i) return ((i*j)%3+i+j)%2==0 end,
}

local function generate_final_matrix(version,data,ec_level,mask)
    local size=version*4+17

    -- Initialize empty matrix
    local mat={}
    for i=1,size do
        mat[i]={}
        for j=1,size do
            mat[i][j]=0
        end
    end

    -- Add fixed patterns
    add_position_detection_pattern(mat,-1,-1)
    add_position_detection_pattern(mat,-1,size-8)
    add_position_detection_pattern(mat,size-8,-1)
    add_alignment_pattern(mat,version)
    -- black pixel above lower left position detection pattern
    mat[9][size-7]=2
    -- timing patterns (dashed lines between two adjacent positioning patterns on row/column 7)
    for i=1+8,#mat-8 do
        local x=i%2==0 and -2 or 2
        mat[i][7],mat[7][i]=x,x
    end

    -- Fill in metadata
    add_version(mat,version)
    add_typeinfo(mat,ec_level,mask)

    -- Fill data into matrix
    local ptr=1             -- data pointer
    local x,y=size,size     -- writing position, starts from bottom right
    local x_dir,y_dir=-1,-1 -- state of movement, notice that y movement step once each 2 x steps
    while true do
        -- Write into available cell
        if mat[x][y]==0 then
            mat[x][y]=(byte(data,ptr)==49)~=maskFunc[mask](x-1,y-1) and 1 or -1
            ptr=ptr+1
            if ptr>#data then return mat end -- all data written
        end
        -- switch left/right
        x=x+x_dir
        if x_dir==1 then
            -- move up/down
            y=y+y_dir

            -- turn back at the edge
            if not mat[y] then       -- check if outside the edge
                x=x-2
                if x==7 then x=6 end -- jump over timing pattern
                y=y_dir==-1 and 1 or size
                y_dir=-y_dir
            end
        end
        -- prepare next left/right
        x_dir=-x_dir
    end
end

-- Return the penalty for the given matrix
local function calculate_penalty(mat)
    local size=#mat
    local p1,p2,p3=0,0,0
    local blackCount=0 -- for penalty 4

    -- 1: Adjacent modules in row/column in same color
    -- --------------------------------------------
    -- No. of modules = (5+i)  -> 3 + i
    local is_blank
    -- Vertical check
    for x=1,size do
        local consec_cnt=0
        local last_blank
        local L=mat[x]
        for y=1,size do
            is_blank=L[y]<0
            if not is_blank then
                -- small optimization: this is for penalty 4
                blackCount=blackCount+1
            end
            if last_blank==is_blank then
                consec_cnt=consec_cnt+1
            else
                if consec_cnt>=5 then
                    p1=p1+consec_cnt-2
                end
                consec_cnt=1
            end
            last_blank=is_blank
        end
        if consec_cnt>=5 then
            p1=p1+consec_cnt-2
        end
    end
    -- Horizontal check
    for y=1,size do
        local consec_cnt=0
        local last_blank
        for x=1,size do
            is_blank=mat[x][y]<0
            if last_blank==is_blank then
                consec_cnt=consec_cnt+1
            else
                if consec_cnt>=5 then
                    p1=p1+consec_cnt-2
                end
                consec_cnt=1
            end
            last_blank=is_blank
        end
        if consec_cnt>=5 then
            p1=p1+consec_cnt-2
        end
    end
    for x=1,size do
        local L=mat[x]
        local L1=mat[x+1]
        for y=1,size do
            -- 2: Block of modules in same color
            -- -----------------------------------
            -- Blocksize = m × n  -> 3 × (m-1) × (n-1)
            if y<size-1 and x<size-1 and (
                    (L[y]<0 and L1[y]<0 and L[y+1]<0 and L1[y+1]<0) or
                    (L[y]>0 and L1[y]>0 and L[y+1]>0 and L1[y+1]>0)
                )
            then
                p2=p2+3
            end

            -- 3: 1:1:3:1:1 ratio (dark:light:dark:light:dark) pattern in row/column
            -- ------------------------------------------------------------------
            -- Gives 40 points each
            --
            -- I have no idea why we need the extra 0000 on left or right side. The spec doesn't mention it,
            -- other sources do mention it. This is heavily inspired by zxing.
            if (
                    y+6<size and
                    L[y]>0 and
                    L[y+1]<0 and
                    L[y+2]>0 and
                    L[y+3]>0 and
                    L[y+4]>0 and
                    L[y+5]<0 and
                    L[y+6]>0 and
                    (
                        (
                            y+10<size and
                            L[y+7]<0 and
                            L[y+8]<0 and
                            L[y+9]<0 and
                            L[y+10]<0
                        ) or (
                            y-4>=1 and
                            L[y-1]<0 and
                            L[y-2]<0 and
                            L[y-3]<0 and
                            L[y-4]<0
                        )
                    )
                )
            then
                p3=p3+40
            end
            if (
                    x+6<=size and
                    L[y]>0 and
                    L1[y]<0 and
                    mat[x+2][y]>0 and
                    mat[x+3][y]>0 and
                    mat[x+4][y]>0 and
                    mat[x+5][y]<0 and
                    mat[x+6][y]>0 and
                    (
                        (
                            x+10<=size and
                            mat[x+7][y]<0 and
                            mat[x+8][y]<0 and
                            mat[x+9][y]<0 and
                            mat[x+10][y]<0
                        ) or (
                            x-4>=1 and
                            mat[x-1][y]<0 and
                            mat[x-2][y]<0 and
                            mat[x-3][y]<0 and
                            mat[x-4][y]<0
                        )
                    )
                )
            then
                p3=p3+40
            end
        end
    end
    -- 4: Proportion of dark modules in entire symbol
    -- ----------------------------------------------
    -- 50 ± (5 × k)% to 50 ± (5 × (k + 1))% -> 10 × k
    local p4=floor(abs(blackCount/(size*size)*100-50))*2
    return p1+p2+p3+p4
end

-- The bits that must be 0 if the version does fill the complete matrix.
-- Example: for version 1, no bits need to be added after arranging the data, for version 2 we need to add 7 bits at the end.
local remainder={0,7,7,7,7,7,0,0,0,0,0,0,0,3,3,3,3,3,3,3,4,4,4,4,4,4,4,3,3,3,3,3,3,3,0,0,0,0,0,0}

---@param str string string data to encode
---@param ec? 1|2|3|4 (optional) error correction level (1=L,2=M,3=Q,4=H)
---@param mask? 0|1|2|3|4|5|6|7 (optional) mask pattern (0-7), specify to skip mask evaluation for better performance
---@return Mat<-2|-1|1|2> QRmatrix -1|-2 = white, 1|2 = black, need extra white padding around when rendering
local function qrcode(str,ec,mask)
    assert(ec==nil or type(ec)=='number' and ec>=1 and ec<=4 and ec%1==0,"Error Correction level must be 1-4 integer")
    assert(mask==nil or type(mask)=='number' and mask>=0 and mask<=7 and mask%1==0,"Mask must be 0-7 integer")

    local version,ec_level,mode,mode_len_bitStr=get_version_eclevel_mode_bistringlength(str,ec)

    -- Encode data based on character mode
    local data=
        mode==1 and encode_string_numeric(str) or
        mode==2 and encode_string_ascii(str) or
        mode==4 and encode_string_binary(str) or
        error("not implemented yet")

    data=add_padding(version,ec_level,mode_len_bitStr..data)

    data=arrange_codewords_and_calculate_ec(version,ec_level,data)

    -- Add remainder bits if needed
    assert(#data%8==0,"Data length after EC is not 8*N")
    data=data..rep('0',remainder[version])

    if mask then
        return generate_final_matrix(version,data,ec_level,mask)
    else
        local bestTab
        local minPenalty=1e99
        for _mask=0,7 do
            local mat=generate_final_matrix(version,data,ec_level,_mask)
            local penalty=calculate_penalty(mat)
            if penalty<minPenalty then bestTab,minPenalty=mat,penalty end
        end
        return bestTab
    end
end

return qrcode
