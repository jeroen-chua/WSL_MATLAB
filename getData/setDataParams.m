function [ct_prev,pose,params] = setDataParams(dataset,params)
    rootDataFolder = '../Data/';
    
    %Pose formatted as: [y-origin,x-origin,major-axis,minor-axis, rotation]
    
    switch(dataset)
        case 1
            dataFolder = 'test_data/';
            %ct_prev = [2,2,0,1]';
            pose = [50,50,30,20,0]';
        case 2
            dataFolder = 'test_data2/';
            %ct_prev = [0,0,0,1]';
            pose = [50,50,30,20,0]';
        case 3
            dataFolder = 'test_data3/';
            %ct_prev = [0,0,0,1.01]';
            pose = [49.5,49.5,30,20,0]';
        case 4
            dataFolder = 'test_data4/';
            %ct_prev = [0,0,-1/80,1]';
            pose = [49.5,49.5,20,15,0]';
        case 5
            dataFolder = 'test_data5/';
            %ct_prev = ???
            pose = [49.5,49.5,20,15,0]';
        case 6
            dataFolder = 'test_data6/';
            %ct_prev = ???
            pose = [75,75,20,15,0]';
        case 10
            dataFolder = 'VTD_data_images/animal/';
        case 11
            dataFolder = 'VTD_data_images/basketball/';
        case 12
            dataFolder = 'VTD_data_images/football/';
        case 13
            dataFolder = 'VTD_data_images/shaking/';
        case 14
            dataFolder = 'VTD_data_images/singer1/';
        case 15
            dataFolder = 'VTD_data_images/singer2/';
        case 16
            dataFolder = 'VTD_data_images/skating1/';
        case 17
            dataFolder = 'VTD_data_images/skating2/';
        case 18
            dataFolder = 'VTD_data_images/soccer/';
        case 20
            dataFolder = 'VTS_data_images/iron/';
        case 21
            dataFolder = 'VTS_data_images/matrix/';
        otherwise
            error(['Bad dataset: ', int2str(dataset)]);
    end
    
    params.dataFolder = [rootDataFolder,dataFolder];
    
    if (~exist('pose','var'))
        load([rootDataFolder,dataFolder,'pose.mat'],'pose');
    end
    if(~exist('ct_prev', 'var'))
        ct_prev = [0,0,0,1]'; % identity transform
    end
    ct_prev(5) = pose(1); ct_prev(6) = pose(2);
end

