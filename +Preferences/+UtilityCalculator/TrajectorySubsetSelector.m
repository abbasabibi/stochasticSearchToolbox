classdef TrajectorySubsetSelector < FeatureGenerators.FeatureGenerator
    
    properties
        utilFunction;
    end
    
    properties(SetObservable)
        trajPrefsPerIteration = 1;
        initPrefs = 1;
    end
    
    methods
        function obj =  TrajectorySubsetSelector(dataManager,utilFunction, featureVariables)
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager,{featureVariables, 'iterationNumber'}, 'selected', ':', 1);
            
            obj.linkProperty('trajPrefsPerIteration');
            obj.initPrefs = obj.trajPrefsPerIteration;
            obj.linkProperty('initPrefs');
            
            obj.utilFunction = utilFunction;
        end
        
        function [features] = getFeaturesInternal(obj, numElements, featureExpectations, iterationNumbers)
            if max(iterationNumbers)==1
                count = obj.initPrefs;
            else
                count = obj.trajPrefsPerIteration;
            end
            features = obj.reduceTrajectories(featureExpectations,count);
        end
        
        %returns the indexes of the trajectories to use
        function [idx] = reduceTrajectories(obj, featureExpectations,count)
            %Random version
            %selectedIdx = randsample(size(featureExpectations,1),obj.trajPrefsPerIteration);
            
            %best expected utility
            expectedUtility = obj.utilFunction.getExpectation(size(featureExpectations,1),featureExpectations(:,2:end));
            sortedUtility = sort(expectedUtility,'descend');
            limit = sortedUtility(count);
            validIdx = find(expectedUtility>=limit);
            if(size(validIdx,1)>count)
                selectedIdx = validIdx(obj.randsample(size(validIdx,1),count));
                %selectedIdx = validIdx(obj.mincosset(validIdx,featureExpectations,count));
                %selectedIdx = validIdx(obj.maxcosset(validIdx,featureExpectations,count));
                %selectedIdx = validIdx(obj.kmeansset(validIdx,featureExpectations,count));
                %selectedIdx = validIdx(obj.minmaxcosset(validIdx,featureExpectations,count));
                %selectedIdx = validIdx(obj.randmaxcos(validIdx,featureExpectations,count));
            else
                selectedIdx = validIdx;
            end
            
            idx = zeros(1,size(featureExpectations,1));
            idx(selectedIdx)=1;
        end
        
        function idx = randmaxcos(obj, valid, fe, count)
            idx = zeros(1,count);
            idx(1) = randi(size(fe,1));
            
            sim = obj.calccossim(valid,fe);
            sim(:,idx(1))=zeros(size(sim,1),1);
            for i = 2:count
                idx(i) = find(sim(idx(i-1),:)==max(sim(idx(i-1),:)));
            end
        end
        
        function idx = kmeansset(obj, valid, fe, count)
            validfe = fe(valid,:);
            try
                try
                    [~,~,~,distance] = kmeans(validfe,count);
                catch
                    [~,~,~,distance] = kmeans(validfe,count,'Start','sample');
                end
                for i = 1:count
                    [~,idx(i)] = min(distance(:,i));
                    distance(idx(i),:)=inf(1,count); %prevents duplicates
                end
            catch
                idx = obj.randsample(size(valid,1),count); %fallback
            end
        end
        
        function idx = minmaxcosset(obj, valid, fe, count)
            sim = obj.calccossim(valid,fe);
            
            [cbs,vals] = obj.cossimset(sim, valid, fe, count/2, []);
            minCbs=find(vals==min(vals));
            idx1 = cbs(minCbs(randi(numel(minCbs))),:);
            
            idx = idx1;
            for id = idx1
                nid = find(sim(id,:)==max(sim(id,:))); %%TODO: Duplicates
                idx = [idx,nid];
            end
            %[cbs,vals] = obj.cossimset(sim, valid, fe, count/2, idx);
            %minCbs=find(vals==max(vals));
            %idx = cbs(minCbs(randi(numel(minCbs))),:);
        end
        
        function sim = calccossim(obj, valid, fe)
            sim = zeros(max(valid),max(valid));
            
            for j = 1:numel(valid)
                x = fe(valid(j),:);
                for i = j+1:numel(valid)
                    y = fe(valid(i),:);
                    c = dot(x,y);
                    sim(valid(i),valid(j)) = c/(norm(x,2)*norm(y,2));
                end
            end
            
            sim = sim+sim';
        end
        
        function [cbs,vals] = cossimset(obj, sim, valid, fe, count, initial)
            cbsValid = valid;
            cbsValid(ismember(cbsValid,initial))=[];
            
            cbs = obj.combntns(cbsValid,count);
            
            cbs = [cbs,repmat(initial,size(cbs,1),1)];
            cbs = sort(cbs,2);
            
            vals = zeros(size(cbs,1),1);
            
            for k = 1:size(cbs,1)
                vals(k)=sum(sum(sim(cbs(k,1:count),cbs(k,1:(count-1)))));
            end
        end
        
        function idx = mincosset(obj, valid, fe, count)
            sim = obj.calccossim(valid,fe);
            [cbs,vals] = obj.cossimset(sim, valid, fe, count, []);
            
            minCbs=find(vals==min(vals));
            idx = cbs(minCbs(randi(numel(minCbs))),:);
        end
        
        function idx = maxcosset(obj, valid, fe, count)
            sim = obj.calccossim(valid,fe);
            [cbs,vals] = obj.cossimset(sim, valid, fe, count, []);
            
            minCbs=find(vals==max(vals));
            idx = cbs(minCbs(randi(numel(minCbs))),:);
        end
        
        function y = randsample(obj, n, k)
            %RANDSAMPLE Random sampling, without replacement
            %   Y = RANDSAMPLE(N,K) returns K values sampled at random, without
            %   replacement, from the integers 1:N.
            
            %   Copyright 1993-2002 The MathWorks, Inc.
            %   $Revision: 1.1 $  $Date: 2002/03/13 23:15:54 $
            
            % RANDSAMPLE does not (yet) implement weighted sampling.
            
            if nargin < 2
                error('Requires two input arguments.');
            end
            
            % If the sample is a sizeable fraction of the population, just
            % randomize the whole population (which involves a full sort
            % of n random values), and take the first k.
            if 4*k > n
                rp = randperm(n);
                y = rp(1:k);
                
                % If the sample is a small fraction of the population, a full
                % sort is wasteful.  Repeatedly sample with replacement until
                % there are k unique values.
            else
                x = zeros(1,n); % flags
                sumx = 0;
                while sumx < k
                    x(ceil(n * rand(1,k-sumx))) = 1; % sample w/replacement
                    sumx = sum(x); % count how many unique elements so far
                end
                y = find(x > 0);
                y = y(randperm(k));
            end
        end
        
        function out=combntns(obj,choicevec,choose);
            
            %COMBNTNS  Computes all combinations of a given set of values
            %
            %  c = COMBNTNS(choicevec,choose) returns all combinations of the
            %  values of the input choice vector.  The size of the combinations
            %  are given by the second input.  For example, if choicevec
            %  is [1 2 3 4 5], and choose is 2, the output is a matrix
            %  containing all distinct pairs of the choicevec set.
            %  The output matrix has "choose" columns and the combinatorial
            %  "length(choicevec)-choose-'choose'" rows.  The function does not
            %  account for repeated values, treating each entry as distinct.
            %  As in all combinatorial counting, an entry is not paired with
            %  itself, and changed order does not constitute a new pairing.
            %  This function is recursive.
            
            %  Copyright 1996-2002 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
            %  Written by:  E. Brown, E. Byrns
            %   $Revision: 1.11 $    $Date: 2002/03/20 21:24:56 $
            
            %  Input dimension tests
            
            if min(size(choicevec)) ~= 1 | ndims(choicevec) > 2
                error('Input choices must be a vector')
                
            elseif max(size(choose)) ~= 1
                error('Input choose must be a scalar')
                
            else
                choicevec = choicevec(:);       %  Enforce a column vector
            end
            
            %  Ensure real inputs
            
            if any([~isreal(choicevec) ~isreal(choose)])
                warning('Imaginary parts of complex arguments ignored')
                choicevec = real(choicevec);    choose = real(choose);
            end
            
            %  Cannot choose more than are available
            
            choices=length(choicevec);
            if choices<choose(1)
                error('Not enough choices to choose that many')
            end
            
            
            %  Choose(1) ensures that a scalar is used.  To test the
            %  size of choices upon input results in systems errors on
            %  the Macintosh.  Maybe somehow related to recursive nature of program.
            
            %  If the number of choices and the number to choose
            %  are the same, choicevec is the only output.
            
            if choices==choose(1)
                out=choicevec';
                
                %  If being chosen one at a time, return each element of
                %  choicevec as its own row
                
            elseif choose(1)==1
                out=choicevec;
                
                %  Otherwise, recur down to the level at which one such
                %  condition is met, and pack up the output as you come out of
                %  recursion.
                
            else
                out = [];
                for i=1:choices-choose(1)+1
                    tempout=obj.combntns(choicevec(i+1:choices),choose(1)-1);
                    out=[out; choicevec(i)*ones(size(tempout,1),1)	tempout];
                end
            end
        end
        
    end
end
