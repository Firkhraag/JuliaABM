# Число домохозяйств каждого типа по районам
function get_district_households()::Matrix{Int}
    return [10702 4300 8419 1540 2016 1253 712 372 475 355 98 88 81 123 96 277 139 243 65 117 103 2941 773 591 137 189 13 17 13 20 542 257 125 28 53 546 784 50 60 117 580 216 210 256 47 47 53 55 3481 647 956 309 103 177 240 74 39 77 64;
        8912 4549 2359 2351 1114 1018 1292 201 326 308 149 40 69 115 92 150 102 201 56 76 115 1618 533 217 76 126 8 5 9 18 334 164 41 13 45 305 450 31 25 86 241 138 115 159 36 29 23 25 1531 70 297 30 4 129 94 11 38 29 36;
        9525 6484 6101 1720 1772 1541 862 255 526 433 123 50 125 188 143 251 128 225 65 96 138 3329 832 468 131 209 24 10 15 22 746 277 125 30 51 601 825 59 57 150 858 337 290 336 88 68 101 84 4007 226 1097 232 28 304 251 46 92 110 82;
        19995 4299 3393 1753 1446 1230 886 219 397 311 174 43 78 126 102 197 91 184 45 74 117 2589 920 336 147 248 14 23 11 28 615 282 94 20 62 369 698 49 37 139 444 273 184 197 50 43 34 37 2778 146 739 77 23 319 143 23 88 57 34;
        7094 3533 3625 2568 1532 1596 979 250 464 502 153 61 111 127 111 173 139 203 69 120 108 2487 975 347 133 270 12 22 17 26 508 259 69 28 75 500 872 70 64 151 428 288 188 294 77 40 52 48 2098 143 499 114 23 144 186 40 49 60 70;
        12148 6715 9465 2498 2287 1545 1211 416 539 431 159 71 117 184 146 189 167 248 93 112 113 4054 1012 1250 147 234 27 16 19 27 788 302 199 36 73 504 728 73 42 134 589 302 208 274 83 52 47 74 3312 142 553 113 12 177 192 36 45 52 58;
        12016 2985 2204 1581 1008 985 891 192 358 320 141 78 109 160 156 122 73 152 143 87 107 2101 746 241 107 178 16 14 22 20 452 239 49 19 56 313 593 38 29 125 325 211 164 217 61 51 37 62 2600 300 694 269 58 307 240 87 93 90 63;
        8028 3496 3046 1579 1717 1117 931 419 415 430 134 155 119 162 157 204 166 246 137 134 159 1982 368 313 92 125 25 5 12 13 478 91 90 19 25 379 395 53 39 98 411 127 214 178 43 48 41 31 2065 77 514 49 11 267 93 11 89 49 33;
        9658 3061 2217 941 1030 628 426 255 249 183 74 66 64 83 65 190 160 128 81 66 74 1142 472 117 62 83 16 3 6 15 283 132 27 7 23 221 268 29 22 49 238 74 131 121 35 52 27 28 1939 163 559 59 31 304 54 33 33 25 15;
        6410 3485 3591 2044 1659 934 1462 230 345 253 121 42 72 110 84 258 152 191 49 95 111 1686 467 293 76 107 27 5 4 16 312 94 69 8 31 216 335 29 19 64 296 92 93 108 24 21 17 17 1795 139 391 92 35 101 85 23 37 25 31;
        14126 6236 4977 2970 2222 2152 1573 325 681 569 221 63 149 209 194 250 111 323 84 143 163 3412 1291 483 190 369 20 17 32 39 707 407 93 28 98 587 1020 59 72 224 644 373 265 385 108 74 76 83 4195 439 962 281 98 264 292 98 142 106 81;
        12663 5303 3352 3393 1409 1630 1431 230 549 520 259 59 123 231 207 258 118 266 74 141 154 2785 1530 309 207 473 16 13 26 83 522 679 70 42 172 423 990 41 58 223 457 334 181 306 116 61 55 61 3052 677 745 402 164 234 307 148 107 129 124;
        21922 5024 2876 3879 1264 1597 1172 209 500 382 184 38 92 163 149 145 82 234 55 107 127 2289 2158 268 140 240 15 18 15 28 398 280 48 11 66 371 762 45 43 117 372 355 180 256 63 46 53 66 2405 126 628 123 18 225 182 33 72 64 57;
        7795 2584 3070 1181 1249 691 671 88 217 232 112 20 27 74 48 112 40 90 20 37 34 1227 629 305 97 217 15 6 8 30 239 141 82 19 40 197 319 29 21 80 225 101 77 101 28 23 16 21 1423 163 338 73 22 141 96 32 30 27 30;
        19413 6005 4367 2855 2004 1670 1799 274 542 474 295 35 93 182 218 207 94 293 64 161 180 2651 1050 376 139 296 23 15 24 37 494 233 75 29 69 372 723 43 30 151 351 211 172 192 66 35 37 50 2575 234 674 212 60 204 223 86 55 65 77;
        14188 4822 4036 2195 1671 1416 1245 389 656 501 294 65 106 169 169 156 264 360 91 157 166 2557 1095 348 152 238 21 14 9 42 598 322 77 30 92 319 599 38 34 116 350 198 140 165 55 49 49 49 2215 209 596 200 42 261 236 69 121 104 58;
        28487 2823 2270 1299 1061 859 663 221 340 228 111 54 87 113 82 92 48 137 37 85 71 1605 575 219 79 149 11 7 7 14 325 200 50 11 26 237 412 23 17 63 415 199 171 213 42 51 47 22 2111 133 730 111 20 399 156 32 67 64 26;
        8985 4738 3507 2450 1821 1863 1189 330 563 592 203 75 238 219 203 307 191 466 178 274 276 2361 811 265 120 204 9 12 16 26 441 239 58 24 61 435 684 66 51 172 346 266 200 269 77 38 52 56 2301 164 504 157 26 183 163 47 80 64 67;
        9280 3371 2549 1576 1006 897 771 208 273 221 139 70 77 85 112 107 79 149 59 55 92 1895 688 212 108 178 14 14 10 33 426 270 62 26 74 257 378 33 31 95 291 195 156 192 59 32 39 39 2203 151 440 70 18 198 98 19 43 25 23;
        14097 2789 1900 1597 812 963 853 152 244 251 134 17 40 100 93 86 51 125 39 85 81 1722 554 182 100 151 9 12 8 13 330 133 34 22 40 249 402 22 26 71 297 159 133 156 30 40 34 33 2695 404 574 131 118 220 108 42 58 27 35;
        6761 2836 2192 1334 1021 937 616 198 313 254 98 84 85 113 87 124 96 143 60 74 75 1860 617 255 88 159 9 9 3 23 413 223 46 23 67 303 546 34 36 97 232 170 119 148 39 39 38 34 1682 96 354 68 20 119 114 21 33 38 38;
        6948 3353 3225 2044 1653 1724 1113 380 666 579 196 67 137 222 166 232 163 372 116 191 225 2215 764 362 148 217 22 13 16 27 370 233 83 24 67 368 649 38 40 153 408 215 178 240 81 56 60 61 1506 85 331 62 16 98 143 26 29 71 72;
        10314 4510 3866 1959 1953 1291 985 353 400 339 135 101 107 131 109 220 130 237 101 125 131 2859 553 382 89 142 26 10 7 16 610 107 86 18 19 409 467 62 40 87 520 191 317 238 65 67 58 59 2528 92 820 107 14 521 145 28 103 52 36;
        7211 2077 1727 1182 869 884 617 132 327 263 65 92 103 113 75 80 45 149 29 75 118 1391 423 185 74 97 11 2 6 7 199 80 27 8 14 213 342 17 25 52 255 150 134 174 51 31 59 43 4271 533 2146 516 94 1259 398 171 454 203 144;
        6814 2995 2793 2013 1467 1550 1147 190 408 427 136 18 66 154 117 173 104 288 52 159 152 1842 707 311 112 197 18 18 18 26 369 204 57 20 42 260 517 44 33 109 312 190 128 172 46 24 23 31 1231 69 222 31 9 75 141 17 12 42 42;
        11125 4062 3015 2183 1307 1318 1196 253 454 398 205 84 106 148 171 134 91 181 103 124 140 2666 1142 286 140 294 18 15 16 29 511 416 56 54 89 394 723 31 55 120 388 264 206 251 81 50 56 73 2326 145 478 138 20 160 151 38 36 67 48;
        10798 2627 1618 1172 568 542 454 116 178 159 79 30 30 54 60 86 42 80 52 60 74 1073 438 119 53 113 6 4 3 11 288 154 49 17 52 168 281 23 12 56 177 110 73 86 32 18 13 21 1476 108 364 78 15 80 77 35 24 30 20;
        7672 2264 1668 1022 757 650 436 201 226 176 73 69 79 77 83 133 61 93 65 70 74 1039 441 146 62 161 9 4 9 17 241 156 52 26 67 188 329 25 19 93 202 159 118 132 56 41 31 32 1740 147 738 158 45 304 114 35 187 44 37;
        11564 3246 2346 1884 1088 1126 1206 221 395 420 197 54 89 140 159 163 134 305 131 169 262 1649 531 237 84 128 13 6 12 10 272 119 34 15 35 276 371 30 39 85 206 94 100 99 28 22 28 26 1652 85 470 133 29 327 144 54 77 57 40;
        11673 4350 2746 2221 993 1092 1316 142 236 325 194 37 48 102 81 114 72 141 40 55 98 2199 954 231 130 276 8 16 21 46 458 302 41 18 69 345 577 31 30 111 271 163 107 113 44 20 16 34 1727 108 267 58 20 71 83 17 17 24 22;
        24489 2987 1842 1599 698 650 763 145 223 307 113 25 45 75 77 68 67 230 37 85 152 1704 620 166 75 128 8 4 8 20 280 208 40 21 40 245 382 20 29 81 161 116 67 94 26 10 15 19 1590 156 461 92 23 224 84 22 94 32 34;
        3789 2944 2210 1996 762 907 719 103 288 237 76 10 47 109 62 113 51 213 36 116 132 1355 548 209 66 132 12 8 5 11 255 169 37 18 39 212 419 17 26 77 207 122 57 105 26 3 17 21 912 52 144 26 4 27 73 6 9 33 28;
        11462 3516 3213 1318 1462 1176 698 293 412 279 85 59 92 144 85 128 113 221 82 96 116 2332 723 269 94 176 10 15 6 15 535 303 69 27 64 353 590 42 36 112 376 189 143 179 33 39 29 27 2114 109 415 75 20 156 137 23 65 46 44;
        19887 4679 4578 2469 2544 2106 1421 553 1024 669 187 184 292 475 295 194 136 387 190 289 311 3344 1276 573 198 346 47 15 24 50 648 396 130 40 124 530 1152 67 69 215 668 413 367 500 108 104 145 153 2722 212 835 187 31 459 342 53 191 115 128;
        7407 2189 2259 1337 1099 981 672 243 431 300 109 152 159 199 180 173 131 242 184 163 206 988 426 184 61 137 9 13 5 18 224 145 64 19 38 155 324 17 23 71 272 187 148 188 60 42 32 28 1097 89 310 55 16 98 95 23 37 40 51;
        6648 2404 2037 1265 849 1052 643 107 392 281 73 7 63 106 77 118 63 242 38 121 159 1254 412 194 80 98 12 6 7 11 159 74 18 5 15 184 386 22 26 73 196 101 82 117 26 12 20 22 2356 708 765 483 171 283 335 143 132 121 93;
        13253 3387 2939 1075 1302 782 553 178 299 159 73 68 71 73 63 44 32 76 41 47 50 2824 1445 362 150 323 22 13 13 37 655 751 92 43 143 285 561 24 33 93 316 152 132 153 36 33 26 34 2065 148 347 81 15 142 123 24 37 43 37;
        2903 794 855 357 363 330 194 78 143 106 29 27 44 63 54 41 24 40 27 40 33 752 256 87 32 53 3 5 2 3 198 94 17 7 13 137 216 13 12 44 170 109 101 94 30 25 27 17 911 44 201 33 4 67 56 13 30 37 18;
        8755 2228 3028 1263 783 723 477 142 218 210 72 36 36 79 77 82 65 123 81 85 99 1688 568 377 106 194 9 8 9 15 338 218 94 15 57 416 452 36 21 81 310 164 73 106 30 15 15 19 1477 55 555 29 12 205 98 15 226 38 39;
        4315 2829 1979 1520 734 779 697 145 203 252 105 38 32 56 50 134 81 201 55 84 122 1197 384 152 67 84 2 1 6 11 236 77 18 10 18 249 332 13 13 51 231 152 68 80 21 21 22 19 1898 126 446 87 19 110 100 27 52 54 26;
        11973 6680 6301 3145 3319 2485 1733 620 1016 742 243 184 256 368 214 437 275 588 171 313 369 4074 931 700 172 228 43 15 9 25 719 181 111 22 35 570 924 82 64 171 775 297 429 435 83 80 101 106 3164 287 1026 259 23 569 461 138 223 308 182;
        3887 1555 1291 875 647 581 499 97 148 134 45 34 35 67 51 81 47 90 36 28 43 940 406 124 55 100 10 5 7 13 198 153 23 10 35 150 262 25 17 55 159 120 77 81 30 12 27 15 908 41 192 38 4 71 49 10 12 17 17;
        10389 2588 1710 1524 630 729 698 82 203 192 110 18 31 68 71 54 39 85 36 37 54 1452 727 152 83 196 7 5 6 20 305 197 31 15 36 194 322 8 27 55 228 183 71 136 29 17 30 20 1540 91 339 84 11 198 91 25 37 29 25;
        8685 4184 3568 3394 1945 1963 2174 463 639 727 321 71 140 210 194 344 264 484 165 218 361 2505 931 345 149 262 18 13 24 39 399 280 60 21 60 404 681 52 49 136 414 239 213 261 90 48 58 60 2296 195 557 206 65 204 236 69 77 74 68;
        7314 5010 2937 1611 1212 1085 834 143 359 267 94 40 72 107 102 127 41 105 25 74 73 2194 942 313 111 216 17 12 18 23 529 329 61 29 77 309 668 23 44 111 426 240 153 222 76 25 48 49 2462 144 511 98 12 123 149 26 36 46 51;
        7878 3589 2768 2296 1411 1508 1886 355 521 468 323 74 109 155 155 303 317 453 163 195 236 1648 605 255 106 159 26 9 14 28 215 101 36 8 32 271 490 71 37 103 258 145 111 157 53 27 30 32 1525 139 559 156 57 110 132 30 70 52 61;
        4364 2164 1816 991 1010 749 565 201 277 228 103 65 88 108 97 140 97 158 87 78 109 1265 433 186 69 113 11 16 8 20 255 177 47 11 22 253 328 41 34 81 265 118 152 127 29 25 29 30 1293 86 332 61 9 115 75 23 29 17 20;
        16741 6638 4242 2886 1783 2083 1442 538 777 806 304 201 296 465 401 301 319 717 708 786 1088 3222 1143 374 163 312 18 23 20 39 484 231 68 34 50 538 859 54 80 170 425 230 161 221 80 31 57 55 2207 109 413 39 10 94 151 31 57 54 65;
        6721 4680 4983 2276 2893 2335 1414 671 998 759 255 214 238 443 330 399 260 600 204 332 419 2799 897 488 152 296 48 15 15 31 603 271 99 39 66 449 1060 82 69 238 584 294 338 365 94 97 75 81 2110 134 600 91 27 349 294 42 168 76 109;
        15399 5201 4656 3172 2386 2360 1757 2196 808 909 272 84 163 284 208 500 371 345 109 143 196 3618 1527 480 200 453 20 9 35 66 802 567 86 46 141 600 1200 70 97 281 734 588 365 530 244 112 79 116 3568 675 827 360 200 762 388 254 97 105 109;
        10385 4369 3375 2242 1564 1421 1240 314 516 489 264 85 129 205 238 222 199 386 204 225 269 2676 878 311 120 255 15 9 18 41 627 321 49 28 87 407 664 43 36 126 360 174 147 175 63 36 42 47 2630 124 457 67 10 148 106 18 73 45 35;
        12027 4372 3683 1872 1784 1390 1074 318 499 358 165 88 143 169 144 154 102 199 84 126 136 2559 900 357 140 268 15 27 14 29 514 282 80 33 68 355 778 35 32 120 519 255 225 289 73 60 52 71 2777 171 783 91 22 247 149 31 82 48 60;
        7723 4166 3346 2246 1837 1542 1527 482 571 570 312 78 92 142 249 331 333 690 184 232 326 2108 726 286 128 222 14 8 14 44 391 187 56 22 41 402 522 63 48 110 272 150 132 135 50 60 24 27 1827 132 350 52 10 152 80 15 84 17 25;
        3267 1458 975 973 418 343 426 98 90 85 61 19 17 24 27 89 33 101 34 39 45 444 197 83 34 64 8 4 6 7 104 27 21 4 7 97 132 16 4 18 79 49 24 18 12 2 8 7 481 25 115 13 3 35 18 4 6 8 13;
        43891 10413 7675 3128 3638 2714 1685 506 991 619 204 106 207 318 208 539 278 388 97 202 197 4573 1978 682 337 501 41 29 34 54 1186 781 161 71 171 732 1296 87 78 220 972 456 428 493 138 89 113 90 6097 365 1203 196 39 326 307 57 68 89 93;
        4937 947 819 492 407 440 282 73 184 119 42 30 32 83 46 63 34 94 24 39 55 557 205 104 33 52 6 8 5 4 104 44 20 10 11 96 179 8 13 31 140 88 82 83 23 16 23 16 860 41 299 23 4 124 52 8 104 14 10;
        13265 4202 3742 2347 1873 1646 1125 394 557 438 161 177 173 213 155 182 110 233 76 110 125 2812 966 341 163 277 11 7 12 33 536 391 58 34 85 394 841 61 53 176 844 481 620 590 152 149 131 94 5800 547 2603 294 128 1755 284 60 465 105 56;
        8842 2710 2478 1250 1519 1042 704 262 314 212 84 137 114 141 80 137 89 116 70 87 98 1648 766 279 94 237 22 9 19 35 439 368 78 24 94 259 541 35 36 123 305 204 234 199 86 58 62 40 2320 217 788 205 85 488 204 106 384 117 89;
        19188 5716 5328 3516 2407 2381 1978 456 837 628 296 85 193 352 264 227 129 373 104 233 262 4055 1854 623 263 481 29 23 33 66 821 668 124 44 125 602 1299 61 63 226 699 416 275 426 123 65 95 103 3598 247 915 211 49 420 351 99 166 122 100;
        17559 7174 8317 5446 4703 4104 3472 762 1585 1115 617 131 373 642 497 408 297 798 225 595 558 5038 2822 1089 380 907 94 56 57 151 930 805 217 68 264 577 1704 107 88 330 866 632 364 508 183 93 101 105 4538 508 1392 448 184 531 615 167 137 220 206;
        7563 1252 1338 705 639 553 375 151 213 141 57 27 69 81 53 95 54 82 52 57 76 895 392 139 57 109 9 8 7 13 251 142 31 14 39 156 299 20 20 57 200 121 115 111 33 19 20 27 1141 73 318 61 14 101 66 16 33 35 31;
        6417 3062 2613 1576 1272 1157 730 262 513 329 109 140 169 215 116 158 127 235 126 189 167 2045 650 280 102 117 18 7 12 10 341 184 62 11 34 307 479 36 28 78 393 192 206 210 51 41 76 48 1928 123 612 152 25 342 205 59 119 107 65;
        10123 4003 3715 2234 1669 1655 857 289 489 360 86 42 79 141 97 340 178 288 60 116 114 2276 1043 337 125 243 22 8 13 23 627 377 109 29 91 514 924 58 50 150 537 272 200 237 65 43 41 34 2777 254 749 204 32 243 199 54 54 78 79;
        5898 2743 3060 1497 1996 1520 787 411 627 376 120 149 219 265 177 191 134 189 163 179 169 2126 709 317 126 164 19 16 19 19 488 279 80 35 75 365 639 52 32 152 570 346 386 390 104 107 99 86 2793 159 1110 268 37 561 355 102 137 155 89;
        6284 1836 2113 981 1392 923 528 246 386 214 85 87 119 188 120 97 57 89 95 103 92 1786 733 276 128 183 31 17 19 18 408 317 77 34 73 277 550 47 31 93 370 213 280 265 77 52 74 73 2013 156 535 169 24 346 284 55 50 80 69;
        23069 3172 2451 1259 1292 1004 641 283 401 292 139 151 179 256 199 126 90 159 73 81 96 1614 617 200 78 163 20 12 3 19 501 310 78 21 62 311 485 27 46 106 465 298 334 341 92 120 124 94 3205 480 988 293 105 528 248 91 269 100 55;
        7662 2763 2368 941 991 870 522 247 333 253 121 46 84 113 117 83 74 136 45 61 93 1704 450 216 91 149 6 10 9 18 452 187 43 24 59 323 383 35 36 82 379 191 186 164 56 72 59 35 2626 209 760 127 61 384 96 38 219 25 32;
        12830 3654 3458 1959 1668 1587 942 355 523 408 124 104 168 205 145 204 95 202 71 117 111 2063 882 259 120 200 5 9 11 26 436 333 50 25 53 390 728 38 55 136 764 433 410 492 105 99 122 85 5051 489 1562 343 82 823 315 95 143 127 73;
        26506 6786 4820 2831 2071 1840 1519 352 626 561 210 51 116 225 176 230 165 284 89 161 192 3292 1169 433 148 266 27 13 31 40 831 329 122 43 80 579 888 66 68 171 543 275 264 284 75 68 39 55 3879 237 880 129 36 393 197 45 110 63 55;
        6290 1995 1719 1043 785 886 534 157 333 295 121 44 74 120 173 91 58 178 56 94 146 1634 577 189 74 134 7 11 9 28 336 196 29 19 52 223 452 20 17 73 286 170 112 151 36 25 26 30 1938 139 365 67 20 92 92 38 38 34 39;
        6868 2691 2935 1137 1566 1010 631 300 360 255 103 130 109 121 137 180 86 84 102 71 92 2290 705 332 109 245 42 17 14 43 555 331 99 45 105 417 680 67 53 148 381 221 244 238 64 62 50 54 2257 176 621 184 50 315 228 69 109 54 50;
        14145 2988 2453 1690 1168 918 1060 259 248 240 181 80 92 91 96 116 82 120 69 66 53 1406 594 183 96 150 9 7 9 17 256 140 61 25 45 241 412 25 29 59 260 145 127 142 55 35 29 41 2052 238 580 141 63 183 115 52 135 60 41;
        7703 4509 4507 1967 2137 1953 1187 388 753 525 172 99 182 267 179 266 209 397 135 197 268 2712 815 401 151 217 23 15 20 36 539 250 79 34 64 520 889 82 70 167 622 282 332 335 79 94 85 72 2894 143 805 138 23 388 231 72 84 99 95;
        18180 4796 3507 2174 1473 1362 1226 301 353 339 176 74 57 112 99 275 146 308 79 111 159 2047 937 263 137 241 14 10 14 20 415 245 74 12 51 342 549 44 38 122 285 151 93 126 27 23 17 14 2426 172 570 150 37 231 241 84 79 109 81;
        13299 6070 6547 2927 3432 3038 1664 658 1137 939 295 136 290 425 263 588 391 790 269 383 470 3394 1056 605 182 295 31 20 16 43 655 368 115 33 90 639 1258 83 95 236 733 338 386 395 95 97 105 105 3017 224 994 234 44 411 442 94 98 175 147;
        11192 5093 4138 2818 2189 2172 1833 552 778 716 308 269 250 403 272 351 220 548 374 469 623 2716 1180 438 161 336 33 29 15 57 471 331 73 17 76 351 833 48 62 164 412 306 217 285 81 93 71 58 2304 166 693 95 16 469 194 38 307 74 70;
        7247 2417 2562 1522 1611 1548 980 320 633 503 177 81 151 212 147 190 163 376 166 255 220 1821 650 355 122 177 23 14 15 30 289 147 59 29 45 333 647 36 82 127 316 225 180 221 57 39 50 48 1415 103 298 63 10 140 185 18 31 65 49;
        3546 2341 3266 1486 2463 1544 728 872 775 488 113 377 314 360 190 381 401 471 335 437 364 1110 426 284 77 136 28 13 10 9 279 116 72 22 16 229 431 54 24 79 462 192 333 248 55 123 75 47 1883 56 794 47 17 409 142 18 119 60 51;
        7058 3024 3042 1368 1607 1304 721 281 522 347 102 72 149 179 151 99 96 180 73 107 126 2550 917 393 148 277 20 17 18 42 520 378 75 36 104 440 849 53 34 181 639 335 281 357 107 71 66 68 2449 162 623 133 32 210 227 50 67 72 78;
        5203 1814 1479 898 738 699 461 144 259 235 89 32 82 116 136 69 64 104 54 84 76 960 409 125 62 125 14 9 5 21 192 125 30 17 41 193 289 27 27 78 219 162 98 118 47 40 24 32 1007 110 364 95 29 150 108 32 25 23 22;
        4225 3309 4282 2066 3052 2116 1034 717 1076 712 157 286 376 470 251 535 520 701 388 469 467 1948 628 404 130 208 32 11 18 21 383 234 87 32 68 392 823 61 46 201 575 238 354 400 90 128 121 99 1649 116 520 81 32 248 264 36 73 106 104;
        7899 2562 3214 940 2161 856 492 407 409 209 61 173 160 180 109 223 137 189 108 147 115 1605 424 363 87 107 24 5 8 8 380 156 84 14 26 235 331 37 15 51 416 136 237 172 33 68 29 45 1559 60 445 62 13 174 107 21 64 36 31;
        7196 2722 2686 1430 1291 1155 791 237 384 352 88 60 89 124 88 104 94 200 50 123 118 2211 849 334 125 211 20 23 22 24 441 293 75 27 80 395 747 43 46 131 358 187 150 206 42 30 30 39 1777 110 292 55 15 81 155 19 25 57 47;
        4894 3263 3825 1949 2483 1884 1099 624 754 606 165 249 218 371 183 414 321 493 325 353 392 1757 591 327 121 186 23 16 16 36 411 214 68 24 67 575 761 90 58 189 514 239 284 338 89 100 78 83 1998 131 623 101 23 333 248 31 138 104 74;
        6986 3154 2578 1848 1717 1155 967 476 394 392 177 102 94 109 121 203 240 296 121 130 149 1735 675 246 80 197 14 9 10 20 301 166 44 14 43 258 437 44 32 98 265 149 132 134 33 27 18 35 1303 62 270 30 7 88 91 11 33 28 26;
        5499 3257 2803 1485 1359 1211 785 314 483 342 96 128 158 176 95 111 54 212 56 104 143 2008 548 273 101 129 16 9 7 15 254 110 42 6 27 283 538 27 36 117 355 164 359 256 43 165 75 67 2827 122 3782 112 20 2934 196 27 2973 112 56;
        7434 3446 3549 3600 1799 1571 743 302 688 353 94 116 214 225 131 132 92 264 71 145 189 2209 615 384 110 127 27 8 10 14 346 163 72 16 40 296 677 31 40 105 687 205 270 312 52 65 93 74 3269 110 13911 201 22 732 224 41 189 82 68;
        23255 7743 4587 1767 1524 1287 731 253 400 336 100 52 83 123 92 186 101 221 53 111 119 2990 2571 388 125 155 17 12 15 18 670 345 87 20 36 526 715 48 45 133 484 373 213 236 65 50 55 43 3710 138 981 83 13 267 178 36 102 83 67;
        10495 3086 2988 1230 1282 1242 670 885 1188 415 105 54 113 1149 153 114 115 234 66 123 151 1944 745 470 153 150 14 14 9 22 350 165 51 22 36 352 860 28 34 116 495 203 290 246 47 36 84 49 2837 90 4498 79 7 185 182 31 44 205 65;
        5055 3350 3680 2199 2223 2464 1353 526 832 746 201 98 197 249 200 471 251 625 139 259 309 1830 768 298 128 253 20 15 16 26 354 207 73 19 60 432 800 80 71 221 466 257 255 291 96 66 76 58 1952 146 502 94 47 209 191 33 72 59 63;
        12857 4036 6556 2984 1902 1805 979 259 663 452 139 107 123 206 186 190 123 316 69 169 166 3038 1166 670 244 852 26 7 12 46 665 410 156 32 153 656 1751 59 70 194 683 320 209 308 98 50 75 69 2851 176 2356 98 20 332 229 39 142 95 70;
        3140 1305 1145 384 558 409 190 133 173 110 31 51 50 55 47 72 68 76 43 51 40 574 175 70 25 44 3 2 8 15 210 89 20 4 20 107 144 8 8 23 126 49 52 48 13 7 9 8 764 69 164 17 6 33 21 6 5 6 7;
        10483 4519 4155 2319 1909 1435 1132 405 548 417 191 87 109 172 149 202 141 260 96 147 186 2497 904 377 167 250 25 14 12 26 582 265 107 30 67 465 636 66 52 121 445 218 278 238 63 67 45 64 2350 123 603 108 24 298 144 23 208 79 43;
        3807 1876 1568 846 782 614 446 144 178 163 72 30 41 69 64 130 76 125 53 53 73 1005 259 127 41 62 12 4 8 11 190 82 32 12 19 186 211 20 17 50 179 84 86 54 23 19 10 11 1184 54 350 35 2 94 54 9 31 10 11;
        11161 6300 4713 4263 1272 1263 957 225 419 319 512 38 78 147 113 133 99 195 50 81 96 2127 663 299 113 196 17 14 11 27 404 268 45 22 50 338 602 41 47 102 377 216 142 213 48 28 39 41 2062 82 484 63 14 145 148 14 30 53 45;
        16234 8401 7826 2324 1961 1899 1218 322 650 559 174 43 134 188 156 241 120 358 87 143 236 4745 1180 687 181 287 46 16 17 33 1001 377 142 34 74 700 1127 68 97 179 706 301 246 324 78 54 64 68 5001 384 1209 387 74 317 340 102 103 109 94;
        5106 1743 1653 924 906 668 444 247 321 236 91 129 126 197 156 90 79 127 76 129 156 1162 455 185 70 126 9 9 10 15 228 114 32 17 37 189 324 22 20 48 298 132 152 170 46 66 56 61 1186 91 338 64 10 112 102 18 74 48 33;
        6521 1648 1338 860 773 561 504 211 253 192 119 88 86 105 95 64 75 182 76 110 83 900 254 144 45 94 11 9 4 17 212 94 25 11 16 150 161 24 16 40 170 80 91 78 25 27 25 21 892 54 282 60 4 138 62 15 77 17 19;
        3549 1249 1195 643 603 510 316 133 202 152 62 23 44 65 55 90 56 129 44 72 92 829 273 137 50 79 7 3 7 11 167 112 24 10 25 159 296 13 20 59 168 106 85 87 28 16 16 13 728 38 183 19 7 73 59 12 11 22 18;
        7505 2946 2025 906 1008 669 541 256 259 192 76 101 85 75 98 155 93 132 85 92 98 1569 358 177 59 97 10 2 5 21 378 89 52 16 26 220 276 23 22 52 260 89 135 90 25 47 24 19 1407 45 269 35 5 121 77 10 80 27 17;
        9413 5139 3906 1300 1259 924 565 224 287 211 95 70 60 92 69 219 140 171 89 66 65 2146 578 221 93 118 7 7 15 14 513 167 72 24 34 375 436 49 21 73 370 149 167 136 35 47 23 35 2964 98 729 88 14 203 126 27 75 47 34;
        12293 5056 4213 2123 2203 1712 1126 610 720 509 244 263 238 254 244 329 269 269 168 211 171 2795 930 330 141 248 24 15 12 40 611 319 89 43 87 405 654 58 34 105 547 293 272 262 90 80 73 64 3333 166 743 109 10 278 143 35 97 72 50;
        5798 2189 1852 1525 811 950 704 136 276 292 111 32 58 92 110 141 90 178 46 76 122 1247 548 171 72 170 6 2 5 20 209 130 24 9 33 226 361 21 25 79 182 123 85 109 45 9 19 19 1487 136 339 129 23 128 115 43 44 39 39;
        4970 2254 2412 890 1489 725 442 249 258 179 72 72 52 68 62 210 200 115 102 54 54 1471 458 217 85 107 9 9 6 21 306 146 45 18 35 220 310 44 23 55 257 114 168 116 33 34 31 22 1373 58 261 38 8 104 82 7 40 26 20;
        10507 4951 4339 2363 2281 1762 1283 552 594 556 196 134 151 215 157 305 233 388 155 196 223 2704 935 368 178 273 34 17 18 27 548 306 74 35 54 476 752 99 62 176 498 241 249 233 62 63 51 48 2441 119 461 57 28 232 141 28 34 67 42;
        7073 3126 2324 1350 992 913 1310 297 424 414 176 90 141 190 244 131 169 305 185 307 343 1667 563 189 93 159 16 7 17 28 348 147 37 15 36 255 379 34 37 105 222 109 97 101 37 35 29 25 1343 63 246 26 12 76 67 9 19 24 26;
        5139 2625 1959 1666 771 828 1001 114 238 274 215 33 70 109 138 88 72 170 74 99 146 1341 586 164 70 157 8 6 10 12 230 127 35 18 36 198 316 24 25 63 182 112 62 73 22 17 13 20 970 50 266 43 10 80 58 5 16 18 28]
end
