function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);
  
  % TODO: the student implements the following
  nw = char(words(1));
  sentence_MLE = 1;
  for i=2:length(words)
      cw = nw;                  % Current word
      nw = char(words(i));      % Next word
        
      MLE = -Inf;
        
      if isfield(LM.uni, cw)            % Part of the unigram
          if isfield(LM.bi.(cw), nw)    % The bigram exists
              MLE = (LM.bi.(cw).(nw) + delta) / (LM.uni.(cw) + delta * vocabSize);
          else                          % new biagram
              MLE = delta / (LM.uni.(cw) + delta * vocabSize);
          end
      else                              % New word with delta smoothing
          if delta > 0
              MLE = 1 / vocabSize;
          end
      end
      % sentence MLE = product of all the sentence words MLEs
      sentence_MLE = sentence_MLE * MLE;
  end
   
  logProb = log2(sentence_MLE); 
  % TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.
return
