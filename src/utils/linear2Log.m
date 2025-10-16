function logStimuli = linear2Log(linearStimuli)
% Reference: https://dspillustrations.com/pages/posts/misc/decibel-conversion-factor-10-or-factor-20.html
logStimuli = 20 * log10(linearStimuli);
end