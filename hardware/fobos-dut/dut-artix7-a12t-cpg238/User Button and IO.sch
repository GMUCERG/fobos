EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 6 8
Title "FOBOS Artix-7 a12t DUT - User Buttons and I/O"
Date ""
Rev "1.0"
Comp "Cryptographic Engineering Research Group"
Comment1 "License: Apache License Version 2.0"
Comment2 "Copyright © Cryptographic Engineering Research Group"
Comment3 "Author: Jens-Peter Kaps, Eddie Ferrufino"
Comment4 "Project: FOBOS Artix-7 a12t DUT"
$EndDescr
$Comp
L power:GND #PWR?
U 1 1 600D00C9
P 2050 3800
AR Path="/5F449901/600D00C9" Ref="#PWR?"  Part="1" 
AR Path="/600CE672/600D00C9" Ref="#PWR046"  Part="1" 
F 0 "#PWR046" H 2050 3550 50  0001 C CNN
F 1 "GND" H 2055 3627 50  0000 C CNN
F 2 "" H 2050 3800 50  0001 C CNN
F 3 "" H 2050 3800 50  0001 C CNN
	1    2050 3800
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D?
U 1 1 600D00D8
P 2050 2200
AR Path="/5F449901/600D00D8" Ref="D?"  Part="1" 
AR Path="/600CE672/600D00D8" Ref="D2"  Part="1" 
F 0 "D2" V 1947 2378 60  0000 L CNN
F 1 "LG_L29K-G2J1-24-Z" V 2053 2378 60  0001 L CNN
F 2 "LED_SMD:LED_0603_1608Metric" H 2250 2400 60  0001 L CNN
F 3 "https://dammedia.osram.info/media/resource/hires/osram-dam-2493945/LG%20L29K.pdf" H 2250 2500 60  0001 L CNN
F 4 "475-2709-1-ND" H 2250 2600 60  0001 L CNN "Digi-Key_PN"
F 5 "LG L29K-G2J1-24-Z" H 2250 2700 60  0001 L CNN "MPN"
F 6 "Optoelectronics" H 2250 2800 60  0001 L CNN "Category"
F 7 "LED Indication - Discrete" H 2250 2900 60  0001 L CNN "Family"
F 8 "https://dammedia.osram.info/media/resource/hires/osram-dam-2493945/LG%20L29K.pdf" H 2250 3000 60  0001 L CNN "DK_Datasheet_Link"
F 9 "/product-detail/en/osram-opto-semiconductors-inc/LG-L29K-G2J1-24-Z/475-2709-1-ND/1938876" H 2250 3100 60  0001 L CNN "DK_Detail_Page"
F 10 "LED GREEN DIFFUSED 0603 SMD" H 2250 3200 60  0001 L CNN "Description"
F 11 "OSRAM Opto Semiconductors Inc." H 2250 3300 60  0001 L CNN "Manufacturer"
F 12 "Active" H 2250 3400 60  0001 L CNN "Status"
	1    2050 2200
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 600D00E4
P 2050 2600
AR Path="/5F449901/600D00E4" Ref="R?"  Part="1" 
AR Path="/600CE672/600D00E4" Ref="R57"  Part="1" 
F 0 "R57" V 2250 2600 50  0000 C CNN
F 1 "470R" V 2150 2600 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 1980 2600 50  0001 C CNN
F 3 "~" H 2050 2600 50  0001 C CNN
F 4 "RES 470 OHM 5% 1/10W 0603 SMD" H 2050 2600 50  0001 C CNN "Description"
F 5 "ERJ-U03J471V" H 2050 2600 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 2050 2600 50  0001 C CNN "Manufacturer"
	1    2050 2600
	1    0    0    -1  
$EndComp
Wire Wire Line
	2050 2850 2050 2750
Wire Wire Line
	2050 2450 2050 2350
Wire Wire Line
	2050 1950 2050 2050
Text GLabel 1800 1800 2    50   Input ~ 0
FC_3V3
Wire Wire Line
	1800 1800 1750 1800
Wire Wire Line
	1750 1800 1750 1950
Wire Wire Line
	1750 1950 2050 1950
$Comp
L power:GND #PWR?
U 1 1 600D0F93
P 4100 3850
AR Path="/5F449901/600D0F93" Ref="#PWR?"  Part="1" 
AR Path="/600CE672/600D0F93" Ref="#PWR047"  Part="1" 
F 0 "#PWR047" H 4100 3600 50  0001 C CNN
F 1 "GND" H 4105 3677 50  0000 C CNN
F 2 "" H 4100 3850 50  0001 C CNN
F 3 "" H 4100 3850 50  0001 C CNN
	1    4100 3850
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D?
U 1 1 600D0FA2
P 4100 2250
AR Path="/5F449901/600D0FA2" Ref="D?"  Part="1" 
AR Path="/600CE672/600D0FA2" Ref="D3"  Part="1" 
F 0 "D3" V 3997 2428 60  0000 L CNN
F 1 "LG_L29K-G2J1-24-Z" V 4103 2428 60  0001 L CNN
F 2 "LED_SMD:LED_0603_1608Metric" H 4300 2450 60  0001 L CNN
F 3 "https://dammedia.osram.info/media/resource/hires/osram-dam-2493945/LG%20L29K.pdf" H 4300 2550 60  0001 L CNN
F 4 "475-2709-1-ND" H 4300 2650 60  0001 L CNN "Digi-Key_PN"
F 5 "LG L29K-G2J1-24-Z" H 4300 2750 60  0001 L CNN "MPN"
F 6 "Optoelectronics" H 4300 2850 60  0001 L CNN "Category"
F 7 "LED Indication - Discrete" H 4300 2950 60  0001 L CNN "Family"
F 8 "https://dammedia.osram.info/media/resource/hires/osram-dam-2493945/LG%20L29K.pdf" H 4300 3050 60  0001 L CNN "DK_Datasheet_Link"
F 9 "/product-detail/en/osram-opto-semiconductors-inc/LG-L29K-G2J1-24-Z/475-2709-1-ND/1938876" H 4300 3150 60  0001 L CNN "DK_Detail_Page"
F 10 "LED GREEN DIFFUSED 0603 SMD" H 4300 3250 60  0001 L CNN "Description"
F 11 "OSRAM Opto Semiconductors Inc." H 4300 3350 60  0001 L CNN "Manufacturer"
F 12 "Active" H 4300 3450 60  0001 L CNN "Status"
	1    4100 2250
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 600D0FAE
P 4100 2650
AR Path="/5F449901/600D0FAE" Ref="R?"  Part="1" 
AR Path="/600CE672/600D0FAE" Ref="R58"  Part="1" 
F 0 "R58" V 4300 2650 50  0000 C CNN
F 1 "470R" V 4200 2650 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 4030 2650 50  0001 C CNN
F 3 "~" H 4100 2650 50  0001 C CNN
F 4 "RES 470 OHM 5% 1/10W 0603 SMD" H 4100 2650 50  0001 C CNN "Description"
F 5 "ERJ-U03J471V" H 4100 2650 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 4100 2650 50  0001 C CNN "Manufacturer"
	1    4100 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	4100 2900 4100 2800
Wire Wire Line
	4100 2500 4100 2400
Wire Wire Line
	4100 2000 4100 2100
Text GLabel 3850 1850 2    50   Input ~ 0
FC_3V3
Wire Wire Line
	3850 1850 3800 1850
Wire Wire Line
	3800 1850 3800 2000
Wire Wire Line
	3800 2000 4100 2000
$Comp
L power:GND #PWR?
U 1 1 600D2B5B
P 5950 3850
AR Path="/5F449901/600D2B5B" Ref="#PWR?"  Part="1" 
AR Path="/600CE672/600D2B5B" Ref="#PWR048"  Part="1" 
F 0 "#PWR048" H 5950 3600 50  0001 C CNN
F 1 "GND" H 5955 3677 50  0000 C CNN
F 2 "" H 5950 3850 50  0001 C CNN
F 3 "" H 5950 3850 50  0001 C CNN
	1    5950 3850
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D?
U 1 1 600D2B6A
P 5950 2250
AR Path="/5F449901/600D2B6A" Ref="D?"  Part="1" 
AR Path="/600CE672/600D2B6A" Ref="D4"  Part="1" 
F 0 "D4" V 5847 2428 60  0000 L CNN
F 1 "LG_L29K-G2J1-24-Z" V 5953 2428 60  0001 L CNN
F 2 "LED_SMD:LED_0603_1608Metric" H 6150 2450 60  0001 L CNN
F 3 "https://dammedia.osram.info/media/resource/hires/osram-dam-2493945/LG%20L29K.pdf" H 6150 2550 60  0001 L CNN
F 4 "475-2709-1-ND" H 6150 2650 60  0001 L CNN "Digi-Key_PN"
F 5 "LG L29K-G2J1-24-Z" H 6150 2750 60  0001 L CNN "MPN"
F 6 "Optoelectronics" H 6150 2850 60  0001 L CNN "Category"
F 7 "LED Indication - Discrete" H 6150 2950 60  0001 L CNN "Family"
F 8 "https://dammedia.osram.info/media/resource/hires/osram-dam-2493945/LG%20L29K.pdf" H 6150 3050 60  0001 L CNN "DK_Datasheet_Link"
F 9 "/product-detail/en/osram-opto-semiconductors-inc/LG-L29K-G2J1-24-Z/475-2709-1-ND/1938876" H 6150 3150 60  0001 L CNN "DK_Detail_Page"
F 10 "LED GREEN DIFFUSED 0603 SMD" H 6150 3250 60  0001 L CNN "Description"
F 11 "OSRAM Opto Semiconductors Inc." H 6150 3350 60  0001 L CNN "Manufacturer"
F 12 "Active" H 6150 3450 60  0001 L CNN "Status"
	1    5950 2250
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 600D2B76
P 5950 2650
AR Path="/5F449901/600D2B76" Ref="R?"  Part="1" 
AR Path="/600CE672/600D2B76" Ref="R59"  Part="1" 
F 0 "R59" V 6150 2650 50  0000 C CNN
F 1 "470R" V 6050 2650 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 5880 2650 50  0001 C CNN
F 3 "~" H 5950 2650 50  0001 C CNN
F 4 "RES 470 OHM 5% 1/10W 0603 SMD" H 5950 2650 50  0001 C CNN "Description"
F 5 "ERJ-U03J471V" H 5950 2650 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 5950 2650 50  0001 C CNN "Manufacturer"
	1    5950 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	5950 2900 5950 2800
Wire Wire Line
	5950 2500 5950 2400
Wire Wire Line
	5950 2000 5950 2100
Text GLabel 5700 1850 2    50   Input ~ 0
FC_3V3
Wire Wire Line
	5700 1850 5650 1850
Wire Wire Line
	5650 1850 5650 2000
Wire Wire Line
	5650 2000 5950 2000
Text Notes 7200 2100 0    50   ~ 0
User Button_1
$Comp
L Device:R R?
U 1 1 6023D6CE
P 1550 3400
AR Path="/5F449901/6023D6CE" Ref="R?"  Part="1" 
AR Path="/600CE672/6023D6CE" Ref="R60"  Part="1" 
F 0 "R60" V 1343 3400 50  0000 C CNN
F 1 "10KR" V 1434 3400 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 1480 3400 50  0001 C CNN
F 3 "~" H 1550 3400 50  0001 C CNN
F 4 "RES SMD 10K OHM 1% 1/10W 0603" H 1550 3400 50  0001 C CNN "Description"
F 5 "ERJ-3EKF1002V" H 1550 3400 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 1550 3400 50  0001 C CNN "Manufacturer"
	1    1550 3400
	-1   0    0    1   
$EndComp
$Comp
L Device:R R?
U 1 1 6023DDF2
P 3600 3450
AR Path="/5F449901/6023DDF2" Ref="R?"  Part="1" 
AR Path="/600CE672/6023DDF2" Ref="R61"  Part="1" 
F 0 "R61" V 3393 3450 50  0000 C CNN
F 1 "10KR" V 3484 3450 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 3530 3450 50  0001 C CNN
F 3 "~" H 3600 3450 50  0001 C CNN
F 4 "RES SMD 10K OHM 1% 1/10W 0603" H 3600 3450 50  0001 C CNN "Description"
F 5 "ERJ-3EKF1002V" H 3600 3450 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 3600 3450 50  0001 C CNN "Manufacturer"
	1    3600 3450
	-1   0    0    1   
$EndComp
$Comp
L Device:R R?
U 1 1 6023E39A
P 5450 3450
AR Path="/5F449901/6023E39A" Ref="R?"  Part="1" 
AR Path="/600CE672/6023E39A" Ref="R62"  Part="1" 
F 0 "R62" V 5243 3450 50  0000 C CNN
F 1 "10KR" V 5334 3450 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 5380 3450 50  0001 C CNN
F 3 "~" H 5450 3450 50  0001 C CNN
F 4 "RES SMD 10K OHM 1% 1/10W 0603" H 5450 3450 50  0001 C CNN "Description"
F 5 "ERJ-3EKF1002V" H 5450 3450 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 5450 3450 50  0001 C CNN "Manufacturer"
	1    5450 3450
	-1   0    0    1   
$EndComp
Wire Wire Line
	2050 3250 2050 3650
Wire Wire Line
	4100 3300 4100 3700
Wire Wire Line
	5950 3300 5950 3700
Wire Wire Line
	5450 3600 5450 3700
Wire Wire Line
	5450 3700 5950 3700
Connection ~ 5950 3700
Wire Wire Line
	5950 3700 5950 3850
Wire Wire Line
	3600 3600 3600 3700
Wire Wire Line
	3600 3700 4100 3700
Connection ~ 4100 3700
Wire Wire Line
	4100 3700 4100 3850
Wire Wire Line
	1550 3550 1550 3650
Wire Wire Line
	1550 3650 2050 3650
Connection ~ 2050 3650
Wire Wire Line
	2050 3650 2050 3800
Text Notes 1700 1650 0    50   ~ 0
User LED_1
Text Notes 3800 1700 0    50   ~ 0
User LED_2\n
Text Notes 5650 1700 0    50   ~ 0
User LED_3
$Comp
L Device:R R?
U 1 1 60253141
P 7950 3050
AR Path="/5F449901/60253141" Ref="R?"  Part="1" 
AR Path="/600CE672/60253141" Ref="R63"  Part="1" 
F 0 "R63" V 7743 3050 50  0000 C CNN
F 1 "10KR" V 7834 3050 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 7880 3050 50  0001 C CNN
F 3 "~" H 7950 3050 50  0001 C CNN
F 4 "RES SMD 10K OHM 1% 1/10W 0603" H 7950 3050 50  0001 C CNN "Description"
F 5 "ERJ-3EKF1002V" H 7950 3050 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 7950 3050 50  0001 C CNN "Manufacturer"
	1    7950 3050
	-1   0    0    1   
$EndComp
$Comp
L Device:R R?
U 1 1 602539FD
P 10100 3050
AR Path="/5F449901/602539FD" Ref="R?"  Part="1" 
AR Path="/600CE672/602539FD" Ref="R65"  Part="1" 
F 0 "R65" V 9893 3050 50  0000 C CNN
F 1 "10KR" V 9984 3050 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 10030 3050 50  0001 C CNN
F 3 "~" H 10100 3050 50  0001 C CNN
F 4 "RES SMD 10K OHM 1% 1/10W 0603" H 10100 3050 50  0001 C CNN "Description"
F 5 "ERJ-3EKF1002V" H 10100 3050 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 10100 3050 50  0001 C CNN "Manufacturer"
	1    10100 3050
	-1   0    0    1   
$EndComp
$Comp
L Device:R R?
U 1 1 602586F7
P 8100 2700
AR Path="/5F449901/602586F7" Ref="R?"  Part="1" 
AR Path="/600CE672/602586F7" Ref="R64"  Part="1" 
F 0 "R64" V 7893 2700 50  0000 C CNN
F 1 "10KR" V 7984 2700 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 8030 2700 50  0001 C CNN
F 3 "~" H 8100 2700 50  0001 C CNN
F 4 "RES SMD 10K OHM 1% 1/10W 0603" H 8100 2700 50  0001 C CNN "Description"
F 5 "ERJ-3EKF1002V" H 8100 2700 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 8100 2700 50  0001 C CNN "Manufacturer"
	1    8100 2700
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 60258B8B
P 10250 2700
AR Path="/5F449901/60258B8B" Ref="R?"  Part="1" 
AR Path="/600CE672/60258B8B" Ref="R66"  Part="1" 
F 0 "R66" V 10043 2700 50  0000 C CNN
F 1 "10KR" V 10134 2700 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 10180 2700 50  0001 C CNN
F 3 "~" H 10250 2700 50  0001 C CNN
F 4 "RES SMD 10K OHM 1% 1/10W 0603" H 10250 2700 50  0001 C CNN "Description"
F 5 "ERJ-3EKF1002V" H 10250 2700 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 10250 2700 50  0001 C CNN "Manufacturer"
	1    10250 2700
	0    -1   -1   0   
$EndComp
Wire Wire Line
	7750 2700 7950 2700
Wire Wire Line
	7950 2900 7950 2700
Connection ~ 7950 2700
Wire Wire Line
	9900 2700 10100 2700
Wire Wire Line
	10100 2900 10100 2700
Connection ~ 10100 2700
$Comp
L power:GND #PWR?
U 1 1 6025C793
P 7950 3500
AR Path="/5F449901/6025C793" Ref="#PWR?"  Part="1" 
AR Path="/600CE672/6025C793" Ref="#PWR049"  Part="1" 
F 0 "#PWR049" H 7950 3250 50  0001 C CNN
F 1 "GND" H 7955 3327 50  0000 C CNN
F 2 "" H 7950 3500 50  0001 C CNN
F 3 "" H 7950 3500 50  0001 C CNN
	1    7950 3500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6025D03C
P 10100 3450
AR Path="/5F449901/6025D03C" Ref="#PWR?"  Part="1" 
AR Path="/600CE672/6025D03C" Ref="#PWR050"  Part="1" 
F 0 "#PWR050" H 10100 3200 50  0001 C CNN
F 1 "GND" H 10105 3277 50  0000 C CNN
F 2 "" H 10100 3450 50  0001 C CNN
F 3 "" H 10100 3450 50  0001 C CNN
	1    10100 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	10100 3200 10100 3450
Wire Wire Line
	7950 3200 7950 3500
Text GLabel 7150 2700 0    50   Input ~ 0
FC_3V3
Text GLabel 9350 2700 0    50   Input ~ 0
FC_3V3
Wire Wire Line
	9350 2700 9500 2700
Wire Wire Line
	7150 2700 7350 2700
Text Notes 9400 2100 0    50   ~ 0
User Button_2
$Comp
L power:GND #PWR?
U 1 1 602D02EF
P 2050 6300
AR Path="/5F449901/602D02EF" Ref="#PWR?"  Part="1" 
AR Path="/600CE672/602D02EF" Ref="#PWR022"  Part="1" 
F 0 "#PWR022" H 2050 6050 50  0001 C CNN
F 1 "GND" H 2055 6127 50  0000 C CNN
F 2 "" H 2050 6300 50  0001 C CNN
F 3 "" H 2050 6300 50  0001 C CNN
	1    2050 6300
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D?
U 1 1 602D02FE
P 2050 4700
AR Path="/5F449901/602D02FE" Ref="D?"  Part="1" 
AR Path="/600CE672/602D02FE" Ref="D5"  Part="1" 
F 0 "D5" V 1947 4878 60  0000 L CNN
F 1 "LG_L29K-G2J1-24-Z" V 2053 4878 60  0001 L CNN
F 2 "LED_SMD:LED_0603_1608Metric" H 2250 4900 60  0001 L CNN
F 3 "https://dammedia.osram.info/media/resource/hires/osram-dam-2493945/LG%20L29K.pdf" H 2250 5000 60  0001 L CNN
F 4 "475-2709-1-ND" H 2250 5100 60  0001 L CNN "Digi-Key_PN"
F 5 "LG L29K-G2J1-24-Z" H 2250 5200 60  0001 L CNN "MPN"
F 6 "Optoelectronics" H 2250 5300 60  0001 L CNN "Category"
F 7 "LED Indication - Discrete" H 2250 5400 60  0001 L CNN "Family"
F 8 "https://dammedia.osram.info/media/resource/hires/osram-dam-2493945/LG%20L29K.pdf" H 2250 5500 60  0001 L CNN "DK_Datasheet_Link"
F 9 "/product-detail/en/osram-opto-semiconductors-inc/LG-L29K-G2J1-24-Z/475-2709-1-ND/1938876" H 2250 5600 60  0001 L CNN "DK_Detail_Page"
F 10 "LED GREEN DIFFUSED 0603 SMD" H 2250 5700 60  0001 L CNN "Description"
F 11 "OSRAM Opto Semiconductors Inc." H 2250 5800 60  0001 L CNN "Manufacturer"
F 12 "Active" H 2250 5900 60  0001 L CNN "Status"
	1    2050 4700
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 602D0304
P 2050 5100
AR Path="/5F449901/602D0304" Ref="R?"  Part="1" 
AR Path="/600CE672/602D0304" Ref="R69"  Part="1" 
F 0 "R69" V 2250 5100 50  0000 C CNN
F 1 "470R" V 2150 5100 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 1980 5100 50  0001 C CNN
F 3 "~" H 2050 5100 50  0001 C CNN
F 4 "RES 470 OHM 5% 1/10W 0603 SMD" H 2050 5100 50  0001 C CNN "Description"
F 5 "ERJ-U03J471V" H 2050 5100 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 2050 5100 50  0001 C CNN "Manufacturer"
	1    2050 5100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2050 5350 2050 5250
Wire Wire Line
	2050 4450 2050 4550
Text GLabel 1800 4300 2    50   Input ~ 0
FC_3V3
Wire Wire Line
	1800 4300 1750 4300
Wire Wire Line
	1750 4300 1750 4450
Wire Wire Line
	1750 4450 2050 4450
$Comp
L Device:R R?
U 1 1 602D0314
P 1550 5900
AR Path="/5F449901/602D0314" Ref="R?"  Part="1" 
AR Path="/600CE672/602D0314" Ref="R68"  Part="1" 
F 0 "R68" V 1343 5900 50  0000 C CNN
F 1 "10KR" V 1434 5900 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 1480 5900 50  0001 C CNN
F 3 "~" H 1550 5900 50  0001 C CNN
F 4 "RES SMD 10K OHM 1% 1/10W 0603" H 1550 5900 50  0001 C CNN "Description"
F 5 "ERJ-3EKF1002V" H 1550 5900 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 1550 5900 50  0001 C CNN "Manufacturer"
	1    1550 5900
	-1   0    0    1   
$EndComp
Wire Wire Line
	2050 5750 2050 6150
Wire Wire Line
	1550 6050 1550 6150
Wire Wire Line
	1550 6150 2050 6150
Connection ~ 2050 6150
Wire Wire Line
	2050 6150 2050 6300
Text Notes 1750 4150 0    50   ~ 0
User LED_4
$Comp
L Transistor_FET:BSS138 Q7
U 1 1 602D521D
P 5850 3100
F 0 "Q7" H 6054 3146 50  0000 L CNN
F 1 "BSS138" H 6054 3055 50  0000 L CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 6050 3025 50  0001 L CIN
F 3 "https://www.fairchildsemi.com/datasheets/BS/BSS138.pdf" H 5850 3100 50  0001 L CNN
F 4 "MOSFET N-CH 50V 220MA SOT23-3" H 5850 3100 50  0001 C CNN "Description"
F 5 "BSS138" H 5850 3100 50  0001 C CNN "MPN"
F 6 "ON Semiconductor" H 5850 3100 50  0001 C CNN "Manufacturer"
	1    5850 3100
	1    0    0    -1  
$EndComp
$Comp
L Transistor_FET:BSS138 Q5
U 1 1 605337F1
P 4000 3100
F 0 "Q5" H 4204 3146 50  0000 L CNN
F 1 "BSS138" H 4204 3055 50  0000 L CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 4200 3025 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BSS138-D.PDF" H 4000 3100 50  0001 L CNN
F 4 "MOSFET N-CH 50V 220MA SOT23-3" H 4000 3100 50  0001 C CNN "Description"
F 5 "BSS138" H 4000 3100 50  0001 C CNN "MPN"
F 6 "ON Semiconductor" H 4000 3100 50  0001 C CNN "Manufacturer"
	1    4000 3100
	1    0    0    -1  
$EndComp
$Comp
L Transistor_FET:BSS138 Q4
U 1 1 60535EA9
P 1950 3050
F 0 "Q4" H 2154 3096 50  0000 L CNN
F 1 "BSS138" H 2154 3005 50  0000 L CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 2150 2975 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BSS138-D.PDF" H 1950 3050 50  0001 L CNN
F 4 "MOSFET N-CH 50V 220MA SOT23-3" H 1950 3050 50  0001 C CNN "Description"
F 5 "BSS138" H 1950 3050 50  0001 C CNN "MPN"
F 6 "ON Semiconductor" H 1950 3050 50  0001 C CNN "Manufacturer"
	1    1950 3050
	1    0    0    -1  
$EndComp
$Comp
L Transistor_FET:BSS138 Q6
U 1 1 60537AA7
P 1950 5550
F 0 "Q6" H 2154 5596 50  0000 L CNN
F 1 "BSS138" H 2154 5505 50  0000 L CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 2150 5475 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BSS138-D.PDF" H 1950 5550 50  0001 L CNN
F 4 "MOSFET N-CH 50V 220MA SOT23-3" H 1950 5550 50  0001 C CNN "Description"
F 5 "BSS138" H 1950 5550 50  0001 C CNN "MPN"
F 6 "ON Semiconductor" H 1950 5550 50  0001 C CNN "Manufacturer"
	1    1950 5550
	1    0    0    -1  
$EndComp
Wire Wire Line
	1750 5550 1550 5550
Wire Wire Line
	1550 5550 1550 5750
Wire Wire Line
	1750 3050 1550 3050
Wire Wire Line
	1550 3050 1550 3250
Wire Wire Line
	3800 3100 3600 3100
Wire Wire Line
	3600 3100 3600 3300
Wire Wire Line
	5650 3100 5450 3100
Wire Wire Line
	5450 3100 5450 3300
Text GLabel 1300 5550 0    50   Input ~ 0
USER_LED_4
Wire Wire Line
	1550 5550 1300 5550
Connection ~ 1550 5550
Text GLabel 5200 3100 0    50   Input ~ 0
USER_LED_3
Wire Wire Line
	5450 3100 5200 3100
Text GLabel 3350 3100 0    50   Input ~ 0
USER_LED_2
Wire Wire Line
	3600 3100 3350 3100
Text GLabel 1300 3050 0    50   Input ~ 0
USER_LED_1
Wire Wire Line
	1550 3050 1300 3050
Text GLabel 10550 2700 2    50   Input ~ 0
USER_BTN_2
Text GLabel 8450 2700 2    50   Input ~ 0
USER_BTN_1
Wire Wire Line
	8450 2700 8250 2700
Wire Wire Line
	10550 2700 10400 2700
$Comp
L cerg:1825910-6 S4
U 1 1 60B3AD58
P 7550 2800
F 0 "S4" H 7550 3147 60  0000 C CNN
F 1 "1825910-6" H 7550 3041 60  0000 C CNN
F 2 "cerg:Switch_Tactile_THT_6x6mm" H 7750 3000 60  0001 L CNN
F 3 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=1825910&DocType=Customer+Drawing&DocLang=English" H 7750 3100 60  0001 L CNN
F 4 "450-1650-ND" H 7750 3200 60  0001 L CNN "Digi-Key_PN"
F 5 "1825910-6" H 7750 3300 60  0001 L CNN "MPN"
F 6 "Switches" H 7750 3400 60  0001 L CNN "Category"
F 7 "Tactile Switches" H 7750 3500 60  0001 L CNN "Family"
F 8 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=1825910&DocType=Customer+Drawing&DocLang=English" H 7750 3600 60  0001 L CNN "DK_Datasheet_Link"
F 9 "/product-detail/en/te-connectivity-alcoswitch-switches/1825910-6/450-1650-ND/1632536" H 7750 3700 60  0001 L CNN "DK_Detail_Page"
F 10 "SWITCH TACTILE SPST-NO 0.05A 24V" H 7750 3800 60  0001 L CNN "Description"
F 11 "TE Connectivity ALCOSWITCH Switches" H 7750 3900 60  0001 L CNN "Manufacturer"
F 12 "Active" H 7750 4000 60  0001 L CNN "Status"
	1    7550 2800
	1    0    0    -1  
$EndComp
$Comp
L cerg:1825910-6 S5
U 1 1 60B3B8EB
P 9700 2800
F 0 "S5" H 9700 3147 60  0000 C CNN
F 1 "1825910-6" H 9700 3041 60  0000 C CNN
F 2 "cerg:Switch_Tactile_THT_6x6mm" H 9900 3000 60  0001 L CNN
F 3 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=1825910&DocType=Customer+Drawing&DocLang=English" H 9900 3100 60  0001 L CNN
F 4 "450-1650-ND" H 9900 3200 60  0001 L CNN "Digi-Key_PN"
F 5 "1825910-6" H 9900 3300 60  0001 L CNN "MPN"
F 6 "Switches" H 9900 3400 60  0001 L CNN "Category"
F 7 "Tactile Switches" H 9900 3500 60  0001 L CNN "Family"
F 8 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=1825910&DocType=Customer+Drawing&DocLang=English" H 9900 3600 60  0001 L CNN "DK_Datasheet_Link"
F 9 "/product-detail/en/te-connectivity-alcoswitch-switches/1825910-6/450-1650-ND/1632536" H 9900 3700 60  0001 L CNN "DK_Detail_Page"
F 10 "SWITCH TACTILE SPST-NO 0.05A 24V" H 9900 3800 60  0001 L CNN "Description"
F 11 "TE Connectivity ALCOSWITCH Switches" H 9900 3900 60  0001 L CNN "Manufacturer"
F 12 "Active" H 9900 4000 60  0001 L CNN "Status"
	1    9700 2800
	1    0    0    -1  
$EndComp
Text Notes 7200 4150 0    50   ~ 0
Reset Button ACTIVE HIGH OR LOW?
$Comp
L Device:R R?
U 1 1 60EF3D05
P 7950 4900
AR Path="/5F449901/60EF3D05" Ref="R?"  Part="1" 
AR Path="/600CE672/60EF3D05" Ref="R73"  Part="1" 
F 0 "R73" V 7743 4900 50  0000 C CNN
F 1 "10KR" V 7834 4900 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 7880 4900 50  0001 C CNN
F 3 "~" H 7950 4900 50  0001 C CNN
F 4 "RES SMD 10K OHM 1% 1/10W 0603" H 7950 4900 50  0001 C CNN "Description"
F 5 "ERJ-3EKF1002V" H 7950 4900 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 7950 4900 50  0001 C CNN "Manufacturer"
	1    7950 4900
	-1   0    0    1   
$EndComp
$Comp
L Device:R R?
U 1 1 60EF3D0E
P 8100 4550
AR Path="/5F449901/60EF3D0E" Ref="R?"  Part="1" 
AR Path="/600CE672/60EF3D0E" Ref="R74"  Part="1" 
F 0 "R74" V 7893 4550 50  0000 C CNN
F 1 "10KR" V 7984 4550 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 8030 4550 50  0001 C CNN
F 3 "~" H 8100 4550 50  0001 C CNN
F 4 "RES SMD 10K OHM 1% 1/10W 0603" H 8100 4550 50  0001 C CNN "Description"
F 5 "ERJ-3EKF1002V" H 8100 4550 50  0001 C CNN "MPN"
F 6 "Panasonic Electronic Components" H 8100 4550 50  0001 C CNN "Manufacturer"
	1    8100 4550
	0    -1   -1   0   
$EndComp
Wire Wire Line
	7750 4550 7950 4550
Wire Wire Line
	7950 4750 7950 4550
Connection ~ 7950 4550
$Comp
L power:GND #PWR?
U 1 1 60EF3D17
P 7950 5350
AR Path="/5F449901/60EF3D17" Ref="#PWR?"  Part="1" 
AR Path="/600CE672/60EF3D17" Ref="#PWR033"  Part="1" 
F 0 "#PWR033" H 7950 5100 50  0001 C CNN
F 1 "GND" H 7955 5177 50  0000 C CNN
F 2 "" H 7950 5350 50  0001 C CNN
F 3 "" H 7950 5350 50  0001 C CNN
	1    7950 5350
	1    0    0    -1  
$EndComp
Wire Wire Line
	7950 5050 7950 5350
Text GLabel 7150 4550 0    50   Input ~ 0
FC_3V3
Wire Wire Line
	7150 4550 7350 4550
Text GLabel 8450 4550 2    50   Input ~ 0
FC_RST
Wire Wire Line
	8450 4550 8250 4550
$Comp
L cerg:1825910-6 S2
U 1 1 60EF3D2B
P 7550 4650
F 0 "S2" H 7550 4997 60  0000 C CNN
F 1 "1825910-6" H 7550 4891 60  0000 C CNN
F 2 "cerg:Switch_Tactile_THT_6x6mm" H 7750 4850 60  0001 L CNN
F 3 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=1825910&DocType=Customer+Drawing&DocLang=English" H 7750 4950 60  0001 L CNN
F 4 "450-1650-ND" H 7750 5050 60  0001 L CNN "Digi-Key_PN"
F 5 "1825910-6" H 7750 5150 60  0001 L CNN "MPN"
F 6 "Switches" H 7750 5250 60  0001 L CNN "Category"
F 7 "Tactile Switches" H 7750 5350 60  0001 L CNN "Family"
F 8 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=1825910&DocType=Customer+Drawing&DocLang=English" H 7750 5450 60  0001 L CNN "DK_Datasheet_Link"
F 9 "/product-detail/en/te-connectivity-alcoswitch-switches/1825910-6/450-1650-ND/1632536" H 7750 5550 60  0001 L CNN "DK_Detail_Page"
F 10 "SWITCH TACTILE SPST-NO 0.05A 24V" H 7750 5650 60  0001 L CNN "Description"
F 11 "TE Connectivity ALCOSWITCH Switches" H 7750 5750 60  0001 L CNN "Manufacturer"
F 12 "Active" H 7750 5850 60  0001 L CNN "Status"
	1    7550 4650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60FBBA52
P 10450 4950
AR Path="/5F3A1954/60FBBA52" Ref="#PWR?"  Part="1" 
AR Path="/600CE672/60FBBA52" Ref="#PWR034"  Part="1" 
F 0 "#PWR034" H 10450 4700 50  0001 C CNN
F 1 "GND" H 10455 4777 50  0000 C CNN
F 2 "" H 10450 4950 50  0001 C CNN
F 3 "" H 10450 4950 50  0001 C CNN
	1    10450 4950
	1    0    0    -1  
$EndComp
Text GLabel 9750 4800 0    50   Input ~ 0
SW_PROGRAM_B
Wire Wire Line
	10350 4800 10450 4800
Wire Wire Line
	10450 4800 10450 4950
Wire Wire Line
	9950 4800 9750 4800
$Comp
L cerg:1825910-6 S?
U 1 1 60FBBA65
P 10150 4700
AR Path="/5F3A1954/60FBBA65" Ref="S?"  Part="1" 
AR Path="/600CE672/60FBBA65" Ref="S3"  Part="1" 
F 0 "S3" H 10150 5047 60  0000 C CNN
F 1 "1825910-6" H 10150 4941 60  0000 C CNN
F 2 "cerg:Switch_Tactile_THT_6x6mm" H 10350 4900 60  0001 L CNN
F 3 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=1825910&DocType=Customer+Drawing&DocLang=English" H 10350 5000 60  0001 L CNN
F 4 "450-1650-ND" H 10350 5100 60  0001 L CNN "Digi-Key_PN"
F 5 "1825910-6" H 10350 5200 60  0001 L CNN "MPN"
F 6 "Switches" H 10350 5300 60  0001 L CNN "Category"
F 7 "Tactile Switches" H 10350 5400 60  0001 L CNN "Family"
F 8 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=1825910&DocType=Customer+Drawing&DocLang=English" H 10350 5500 60  0001 L CNN "DK_Datasheet_Link"
F 9 "/product-detail/en/te-connectivity-alcoswitch-switches/1825910-6/450-1650-ND/1632536" H 10350 5600 60  0001 L CNN "DK_Detail_Page"
F 10 "SWITCH TACTILE SPST-NO 0.05A 24V" H 10350 5700 60  0001 L CNN "Description"
F 11 "TE Connectivity ALCOSWITCH Switches" H 10350 5800 60  0001 L CNN "Manufacturer"
F 12 "Active" H 10350 5900 60  0001 L CNN "Status"
	1    10150 4700
	1    0    0    -1  
$EndComp
Text Notes 9800 4150 0    50   ~ 0
Progam_B Button
Wire Wire Line
	2050 4850 2050 4950
$EndSCHEMATC
