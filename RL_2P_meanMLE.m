function result = RL_2P_meanMLE(choice, reward, trialtype)

%{

3. Slot Choice (1=pos; 2=neg; 3=neutral) ? shows which slot machine they choose
4. Reward (1=positive; 0.5=neutral; 0=negative) ? shows the outcome they actually got (e.g.,. positive money is a picture of 5 cents; neutral money is an empty circle; negative money is a picture of 5 cents with a red line through it)
    80% probability
5. Trial type (0=positive; 1=negative) ? positive trials have a choice of positive or neutral slot; negative trials have a choice of negative or neutral slot
    0 --> c = [1 3]; 1 --> c = [2 3];
6. Accuracy (1=correct response; 0=effort incorrect response).

%}

alpha = 0.251602092;
beta = 16.93636755;

b = [alpha beta];
dof = length(b);

result.choice = choice;
result.reward = reward;
result.trialtype = trialtype;
[loglike, ~, cV, rpe] = model(b, choice, reward, trialtype); %finalizing best fitting model based on optimal alpha and beta
result.modelLL = -loglike;
result.nullmodelLL = log(0.5)*size(choice,1); %LL of random-choice model
result.pseudoR2 = 1 + loglike/(result.nullmodelLL); %pseudo-R2 statistic
result.BIC = 2 * loglike + (dof * log(size(choice,1)));
result.AIC = 2 * loglike + (dof * 2);
result.rpe = rpe; % reward prediction error for each trial
result.cV = cV; %expected/chosen value (maybe "stimulus value" according to Lin et al?)





function [loglike, V, cV, rpe] = model(x, choice, reward, trialtype)
%function to evaluate the loglikelihood of the model for parameters alpha
%and beta given the data

alpha = x(1); % avoid using matlab function names as variables (alpha and beta)
beta = x(2);
loglike = 0; % log likelihood

ntrial = length(choice);
V = zeros(ntrial,3); %columns: 1 (pos), 2 (neg), 3 (neu)
V(1,:) = [0 0 0]; %initializing at 0 (neutral); this could change.
rpe = zeros(ntrial,1);
cV = zeros(ntrial,1);

for t = 1:ntrial
    
    % the chosen stimulus (1 or 2 or 3)
    c = choice(t);
    
    if c == -99 % ignore missed trials
        
        V(t+1,2) = V(t,2); %don't update
        V(t+1,3) = V(t,3); %don't update
        V(t+1,1) = V(t,1); %don't update
        rpe(t) = -99;
        cV(t) = -99;
        
    else
        
        if trialtype(t) == 1 % choosing between 2 and 3 (negative)
            
            if c == 2
                
                k = beta * (V(t,2) - V(t,3));
                cV(t) = V(t,2);
                rpe(t) = reward(t) - V(t,2);
                V(t+1,2) = V(t,2) + alpha*rpe(t); %update chosen
                V(t+1,3) = V(t,3); %don't update
                V(t+1,1) = V(t,1); %don't update
                
            elseif c == 3
                
                k = beta * (V(t,3) - V(t,2));
                cV(t) = V(t,3);
                rpe(t) = reward(t) - V(t,3);
                V(t+1,3) = V(t,3) + alpha*rpe(t); %update chosen
                V(t+1,2) = V(t,2); %don't update
                V(t+1,1) = V(t,1); %don't update
                
            end
            
        elseif trialtype(t) == 0 % choosing between 1 and 3 (positive)
            
            if c == 1
                
                k = beta * (V(t,1) - V(t,3));
                cV(t) = V(t,1);
                rpe(t) = reward(t) - V(t,1);
                V(t+1,1) = V(t,1) + alpha*rpe(t); %update chosen
                V(t+1,2) = V(t,2); %don't update
                V(t+1,3) = V(t,3); %don't update
                
            elseif c == 3
                
                k = beta * (V(t,3) - V(t,1));
                cV(t) = V(t,3);
                rpe(t) = reward(t) - V(t,3);
                V(t+1,3) = V(t,3) + alpha*rpe(t); %update chosen
                V(t+1,2) = V(t,2); %don't update
                V(t+1,1) = V(t,1); %don't update
                
            end
        end
        
        %compute likelihood with softmax
        likelihood = 1/(1 + exp(-k));
        loglike = loglike + log(likelihood);
    end
    
end
loglike = -loglike;  % so we can minimize the function rather than maximize.
% end: function [loglike, V, cV, rpe] = model(x, choice, reward, trialtype)

