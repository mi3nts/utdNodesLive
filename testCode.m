
clc
clear all
close all



tic
GPGGAUtdRead("MINTS_001e06305a12_GPSGPGGA2_2020_03_04.csv",seconds(30));
toc
tic
GPGGAReadFast("MINTS_001e06305a12_GPSGPGGA2_2020_03_04.csv",seconds(30));
toc


tic
BME280Read("MINTS_001e06305a12_BME280_2020_04_04.csv",seconds(30));
toc
tic
readFast("MINTS_001e06305a12_BME280_2020_04_04.csv",seconds(30));
toc