% revisit some controversal trials to mark errors
% Xiuyun Wu, Nov/02/2020
clear all; clc; close all

load('validObservers.mat')
% first, to load both the initial screens and later versions
cd('..\ErrorFiles')
errorFileFolder = pwd;
cd('initialScreen')
initialScreenFolder = pwd;

