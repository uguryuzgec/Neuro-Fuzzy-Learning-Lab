function names = stage_models(stage)
% Stage 0 offers the union; ANFIS appears only once.
switch stage
    case 0
        names={'Mean','Ridge','kNN','MLP','ELM','RVFL','Fixed-TSK1', ...
               'Adaptive-TSK0','ANFIS','Fuzzy-RVFL','FNN-GA','FNN-PSO'};
    case 1
        names={'Mean','Ridge','kNN','MLP','ELM','RVFL'};
    case 2
        names={'Fixed-TSK1','Adaptive-TSK0','ANFIS','Fuzzy-RVFL'};
    case 3
        names={'ANFIS','FNN-GA','FNN-PSO'};
    otherwise
        error('Stage must be 0, 1, 2 or 3.');
end
end
