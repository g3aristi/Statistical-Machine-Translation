function score = blue_score(cand, ref, N)

% Implementation of bleu scoring 
% cand: sentences and sentence words of the candidate
% ref: sentences and sentence words in the reference corpus
% N: max size of n-grams we will consider

	for s=1:length(cand)
        cand{s} = strsplit(' ', cand{s});
		ref{s} = strsplit(' ', ref{s});
	end

	% Compute brevity penalty
	cand_length = sum(cellfun('length', cand)) - 2*length(cand);	
	ref_length = sum(cellfun('length', ref)) - 2*length(ref);
	if cand_length > ref_length
		bp = 1;
	else
		bp = exp(1-ref_length/cand_length);
	end
	exponent = 0;
	for n=1:N
		% We give them all equal weighting
		exponent = exponent + 1/N * log(mod_prec(cand, ref,n));
	end

	score = bp * exp(exponent);
end

% Helper function to compute the modified precision for n-grams of length n
function p_n = mod_prec(cand, ref, n)
	count = 0;
	count_matched = 0;
	for sen=1:length(cand)
		% - 2 for start and end, - (n-1) for amount of n-grams
		count = count + length(cand{sen}) - 1 - n;
		% Check matches
		for i=2:length(cand{sen})-n
			if is_matched(cand{sen}(i:i+n-1), ref{sen}, n)
				count_matched = count_matched + 1;
			end
		end
	end
	p_n = count_matched / count;
end

% Helper function to see if an n-gram is matched in the reference sentence
function matched = is_matched(gram, ref, n)
	for i=2:length(ref)-n
		matched = 1;
		for j=1:n
			if ~strcmp(gram{j}, ref{i})
				matched = 0;
				break;
			end
		end
		if matched
			return
		end
	end

	matched = 0;
	return
end