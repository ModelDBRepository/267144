%% Uniform sampler to Read-outs test weights

%initial connectivity chosen such that it has a large L1 distance to target
large = false;
unitobim = false;
bim = false;

if large
    wRE(1:100,1:1200) = 5;
    wRE(101:200,1201:2200) = 5;
    wRE(201:300,2201:3000) = 5;
    wRE(301:400,3001:3600) = 5;
    wRE(401:500,3601:4200) = 5;
    wRE(501:600,4201:4600) = 5;
    wRE(601:700,4601:4800) = 5;

elseif unitobim
    wRE(1:100,1:100) = 5;
    wRE(101:200,101:300) = 5;
    wRE(201:300,301:700) = 5;
    wRE(301:400,701:1200) = 5;
    wRE(401:500,1201:1700) = 5;
    wRE(501:600,1701:2100) = 5;
    wRE(601:700,2101:2300) = 5;
    wRE(701:800,2301:2400) = 5;
elseif bim
    wRE(1:100,1:300) = 5;
    wRE(101:200,301:800) = 5;
    wRE(201:300,801:1100) = 5;
    wRE(301:400,1101:1200) = 5;
    wRE(401:500,1201:1300) = 5;
    wRE(501:600,1301:1600) = 5;
    wRE(601:700,1601:2100) = 5;
    wRE(701:800,2101:2400) = 5;

else
    wRE(1:100,1:600) = 5;
    wRE(101:200,601:1100) = 5;
    wRE(201:300,1101:1500) = 5;
    wRE(301:400,1501:1800) = 5;
    wRE(401:500,1801:2100) = 5;
    wRE(501:600,2101:2300) = 5;
    wRE(601:700,2301:2400) = 5;
end

%comment the next line if you want to start with an untrained network
%load('./data/wRE10_50_100_small_v3_100.mat')

