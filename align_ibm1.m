function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);
  disp(AM)

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  eng = {};
  fre = {};

  % TODO: your code goes here.
  ED = dir([mydir, filesep, '*', 'e']);
  FD = dir([mydir, filesep, '*', 'f']);
  ln = 1;                   % line number
  
  for file=1:length(ED)     % read all the data in all the files
	es = textread([mydir, filesep, ED(file).name], '%s','delimiter','\n');     % english sentences
    fs = textread([mydir, filesep, FD(file).name], '%s','delimiter','\n');     % french sentences
	for s=1:length(es)      % 'normalize' each sentence
		eng{ln} = strsplit(' ', preprocess(es{s}, 'e'));
		fre{ln} = strsplit(' ', preprocess(fs{s}, 'f'));
		ln = ln + 1;
		if ln > numSentences
			return
		end
    end
  end

end

function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    % TODO: your code goes here
    
    AM = {}; % AM.(english_word).(foreign_word)
    
    % 1) Initialize structure
    % for every english word, add an entry for every french word.
    for s=1:length(eng)             % all sentences
        es = eng{s};                
        fs = fre{s};                    
        
        for w=2:length(es) - 1      % for every english word
            ew = es{w};
            for m=2:length(fs) - 1  % add all the corresponding french words
                fw = fs{m};
                AM.(ew).(fw) = 1;
            end
        end
    end
    
    % 2) add the uniform probabilites for each bigram
    % For each english word in AM
    engList = fieldnames(AM);
    for we = 1:numel(engList)           % word in english
        engWord = AM.(engList{we});
        
        freList = fieldnames(engWord);
        d = length(freList);
        % divide each french word entry by the number of french words
        for wf = 1:numel(freList)       % word in french
            engWord.(freList{wf}) = 1 / d;
        end
    end
    
    % Add in SENTSTART/SENTEND
    AM.SENTSTART.SENTSTART = 1;
    AM.SENTEND.SENTEND = 1;

end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  % TODO: your code goes here
  % Get lists of english and french words
	ew = fieldnames(t);         % list of all english words
	fw = {};
	for w=1:length(ew)
		fw = [fw; fieldnames(t.(ew{w}))];
	end

	% Initialize structures
	fw = unique(fw);
	tcount = struct();
	total = struct();

	% for each sentence pair (F, E) in training corpus:
	for s=1:length(eng)
        ue = unique(eng{s});
		uf = unique(fre{s});
		% Remove SENTSTART and SENTEND
        ue = ue(~strcmp(ue(:), 'SENTSTART'));
        ue = ue(~strcmp(ue(:), 'SENTEND'));
		uf = uf(~strcmp(uf(:), 'SENTSTART'));
        uf = uf(~strcmp(uf(:), 'SENTEND'));
        % for each unique word f in F:
		for f=1:length(uf)
            % denom_c = 0
			dc = 0;
            % for each unique word e in E:
			for e=1:length(ue)
				% dc += P(f|e) * F.count(f)
				dc = dc + t.(ue{e}).(uf{f}) * sum(strcmp(fre{s},uf{f}));
            end
            % for each unique word e in E:
			for e=1:length(ue)
				% New French word -> initialize struct
				if ~isfield(tcount, uf{f})
					tcount.(uf{f}) = struct();
				end
				if ~isfield(tcount.(uf{f}), ue{e})
					tcount.(uf{f}).(ue{e}) = 0;
				end
				if ~isfield(total, ue{e})
					total.(ue{e}) = 0;
				end

				% Compute P(f|e) * F.count(f) * E.count(e) / denom_c
				to_add = t.(ue{e}).(uf{f}) * sum(strcmp(fre{s},uf{f})) * sum(strcmp(eng{s},ue{e})) / dc;

				% tcount(f,e) += P(f|e) * F.count(f) * E.count(e) / denom_c
				tcount.(uf{f}).(ue{e}) = tcount.(uf{f}).(ue{e}) + to_add;
				% total(e) += P(f|e) * F.count(f) * E.count(e) / denom_c
				total.(ue{e}) = total.(ue{e}) + to_add;
			end
		end
    end

    ew = ew(~strcmp(ew(:), 'SENTSTART'));
    ew = ew(~strcmp(ew(:), 'SENTEND'));
	% for each e in domain(total(:)):
	for e=1:length(ew)
		fre_w = fieldnames(t.(ew{e}));
        % for each f in domain(tcount(:,e)):
		for f=1:length(fre_w)
            % P(f|e) = tcount(f, e) / total(e)
			t.(ew{e}).(fre_w{f}) = tcount.(fre_w{f}).(ew{e}) / total.(ew{e});
		end
	end

end
