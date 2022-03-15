library ieee; use ieee.std_logic_1164.all;
use work.gumnut_defs.all;
package gasm_data is
  constant data : DMem_array := (
    0 => "00000000",
    1 => "00000000",
    2 => "00000000",
    3 => "00000000",
    4 => "00000000",
    5 => "00000000",
    6 => "00000000",
    7 => "00000000",
    8 => "00000000",
    9 => "00000000",
    10 => "00000000",
    11 => "00000000",
    12 => "00000000",
    13 => "00000000",
    14 => "00000000",
    15 => "00000000",
    16 => "00000000",
    17 => "00000000",
    18 => "00000000",
    19 => "00000000",
    20 => "00000000",
    21 => "00000000",
    22 => "00000000",
    23 => "00000000",
    24 => "00000000",
    25 => "00000000",
    26 => "00000000",
    27 => "00000000",
    28 => "00000000",
    29 => "00000000",
    30 => "00000000",
    31 => "00000000",
    32 => "00000000",
    33 => "00000000",
    34 => "00000000",
    35 => "00000000",
    36 => "00000000",
    37 => "00000000",
    38 => "00000000",
    39 => "00000000",
    40 => "00000000",
    41 => "00000000",
    42 => "00000000",
    43 => "00000000",
    44 => "00000000",
    45 => "00000000",
    46 => "00000000",
    47 => "00000000",
    48 => "00000000",
    49 => "00000000",
    50 => "00000000",
    51 => "00000000",
    52 => "00000000",
    53 => "00000000",
    54 => "00000000",
    55 => "00000000",
    56 => "00000000",
    57 => "00000000",
    58 => "00000000",
    59 => "00000000",
    60 => "00000000",
    61 => "00000000",
    62 => "00000000",
    63 => "00000000",
    64 => "00000000",
    65 => "00000000",
    66 => "00000000",
    67 => "00000000",
    68 => "00000000",
    69 => "00000000",
    70 => "00000000",
    71 => "00000000",
    72 => "00000000",
    73 => "00000000",
    74 => "00000000",
    75 => "00000000",
    76 => "00000000",
    77 => "00000000",
    78 => "00000000",
    79 => "00000000",
    80 => "00000000",
    81 => "00000000",
    82 => "00000000",
    83 => "00000000",
    84 => "00000000",
    85 => "00000000",
    86 => "00000000",
    87 => "00000000",
    88 => "00000000",
    89 => "00000000",
    90 => "00000000",
    91 => "00000000",
    92 => "00000000",
    93 => "00000000",
    94 => "00000000",
    95 => "00000000",
    96 => "00000000",
    97 => "00000000",
    98 => "00000000",
    99 => "00000000",
    100 => "00000000",
    101 => "00000000",
    102 => "00000000",
    103 => "00000000",
    104 => "00000000",
    105 => "00000000",
    106 => "00000000",
    107 => "00000000",
    108 => "00000000",
    109 => "00000000",
    110 => "00000000",
    111 => "00000000",
    112 => "00000000",
    113 => "00000000",
    114 => "00000000",
    115 => "00000000",
    116 => "00000000",
    117 => "00000000",
    118 => "00000000",
    119 => "00000000",
    120 => "00000000",
    121 => "00000000",
    122 => "00000000",
    123 => "00000000",
    124 => "00000000",
    125 => "00000000",
    126 => "00000000",
    127 => "00000000",
    128 => "00000000",
    129 => "00000000",
    130 => "00000000",
    131 => "00000000",
    132 => "00000000",
    133 => "00000000",
    134 => "00000000",
    135 => "00000000",
    136 => "00000000",
    137 => "00000000",
    138 => "00000000",
    139 => "00000000",
    140 => "00000000",
    141 => "00000000",
    142 => "00000000",
    143 => "00000000",
    144 => "00000000",
    145 => "00000000",
    146 => "00000000",
    147 => "00000000",
    148 => "00000000",
    149 => "00000000",
    150 => "00000000",
    151 => "00000000",
    152 => "00000000",
    153 => "00000000",
    154 => "00000000",
    155 => "00000000",
    156 => "00000000",
    157 => "00000000",
    158 => "00000000",
    159 => "00000000",
    160 => "00000000",
    161 => "00000000",
    162 => "00000000",
    163 => "00000000",
    164 => "00000000",
    165 => "00000000",
    166 => "00000000",
    167 => "00000000",
    168 => "00000000",
    169 => "00000000",
    170 => "00000000",
    171 => "00000000",
    172 => "00000000",
    173 => "00000000",
    174 => "00000000",
    175 => "00000000",
    176 => "00000000",
    177 => "00000000",
    178 => "00000000",
    179 => "00000000",
    180 => "00000000",
    181 => "00000000",
    182 => "00000000",
    183 => "00000000",
    184 => "00000000",
    185 => "00000000",
    186 => "00000000",
    187 => "00000000",
    188 => "00000000",
    189 => "00000000",
    190 => "00000000",
    191 => "00000000",
    192 => "00000000",
    193 => "00000000",
    194 => "00000000",
    195 => "00000000",
    196 => "00000000",
    197 => "00000000",
    198 => "00000000",
    199 => "00000000",
    200 => "00000000",
    201 => "00000000",
    202 => "00000000",
    203 => "00000000",
    204 => "00000000",
    205 => "00000000",
    206 => "00000000",
    207 => "00000000",
    208 => "00000000",
    209 => "00000000",
    210 => "00000000",
    211 => "00000000",
    212 => "00000000",
    213 => "00000000",
    214 => "00000000",
    215 => "00000000",
    216 => "00000000",
    217 => "00000000",
    218 => "00000000",
    219 => "00000000",
    220 => "00000000",
    221 => "00000000",
    222 => "00000000",
    223 => "00000000",
    224 => "00000000",
    225 => "00000000",
    226 => "00000000",
    227 => "00000000",
    228 => "00000000",
    229 => "00000000",
    230 => "00000000",
    231 => "00000000",
    232 => "00000000",
    233 => "00000000",
    234 => "00000000",
    235 => "00000000",
    236 => "00000000",
    237 => "00000000",
    238 => "00000000",
    239 => "00000000",
    240 => "00000000",
    241 => "00000000",
    242 => "00000000",
    243 => "00000000",
    244 => "00000000",
    245 => "00000000",
    246 => "00000000",
    247 => "00000000",
    248 => "00000000",
    249 => "00000000",
    250 => "00000000",
    251 => "00000000",
    252 => "00000000",
    253 => "00000000",
    254 => "00000000",
    255 => "00000000" );
end package gasm_data;
