if strcmp(prior,'uniform')

    wRE(1:100,1:300) = 5;
    wRE(101:200,301:600) = 5;
    wRE(201:300,601:900) = 5;
    wRE(301:400,901:1200) = 5;
    wRE(401:500,1201:1500) = 5;
    wRE(501:600,1501:1800) = 5;
    wRE(601:700,1801:2100) = 5;
    wRE(701:800,2101:2400) = 5;

elseif strcmp(prior,'unimodal')
    
    wRE(1:100,1:100) = 5;
    wRE(101:200,101:300) = 5;
    wRE(201:300,301:700) = 5;
    wRE(301:400,701:1200) = 5;
    wRE(401:500,1201:1700) = 5;
    wRE(501:600,1701:2100) = 5;
    wRE(601:700,2101:2300) = 5;
    wRE(701:800,2301:2400) = 5;
    
    
elseif strcmp(prior,'bimodal')
    
    wRE(1:100,1:300) = 5;
    wRE(101:200,301:800) = 5;
    wRE(201:300,801:1100) = 5;
    wRE(301:400,1101:1200) = 5;
    wRE(401:500,1201:1300) = 5;
    wRE(501:600,1301:1600) = 5;
    wRE(601:700,1601:2100) = 5;
    wRE(701:800,2101:2400) = 5;
    
    
elseif strcmp(prior,'biased')
    
    wRE(1:100,1:400) = 5;
    wRE(101:200,401:800) = 5;
    wRE(201:300,801:1200) = 5;
    wRE(301:400,1201:1600) = 5;
    wRE(401:500,1601:1800) = 5;
    wRE(501:600,1801:2000) = 5;
    wRE(601:700,2001:2200) = 5;
    wRE(701:800,2201:2400) = 5;
    
elseif strcmp(prior,'load_unitobim')
    
    load(['/home/ahm17/Documents/Learning statistical structure/data/data_unitobim/wRE10_50_100_unitobim_' num2str(h) '.mat'])
    
elseif strcmp(prior,'load_bim')
    
    load(['/home/ahm17/Documents/Learning statistical structure/data/wRE_bim_' num2str(k) '.mat'])
    
end