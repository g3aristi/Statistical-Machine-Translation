function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  % separate end of sentece puntuation
  outSentence = regexprep( outSentence, '[.!?](?= SENTEND)', ' $0');
  %separte other puntuation [,:;()+-<>="]
  outSentence = regexprep( outSentence, '|\,|\:|\;|\(|\)|\-+|\+|<|>|\=|\"', ' $0 ');
  % trim whitespaces
  outSentence = regexprep( outSentence, '\s+', ' ');

  switch language
   case 'e'
    % separating possessives and clitics 
    outSentence = regexprep( outSentence, 'n''t|''\w+', ' $0');
    % trim whitespaces
    outSentence = regexprep( outSentence, '\s+', ' ');
    

   case 'f'
    % separate french contractions
    outSentence = regexprep( outSentence, '\w+''(?=on|il)|qu''|[a-ce-z]''', '$0 ');
    % trim whitespaces
    outSentence = regexprep( outSentence, '\s+', ' ');

  end

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );
 
  % preprocess(sentence, 'e')

