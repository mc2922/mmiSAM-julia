using Caesar, IncrementalInference
using DelimitedFiles
using KernelDensityEstimatePlotting
using Gadfly, Cairo, Fontconfig

nfft_full= 8192                           #size of full FFT for matched filtering
freq_sampling= 37500.0                    #DAQ sampling frequency
sound_speed= 1481.0                       #sound speed of water
element = 2

exptype = 1

if exptype == 1
    trialstr = "20_gps_pos";
    frames = collect(1:1341);
elseif exptype == 2
    trialstr = "08_10_parsed";
    frames = collect(1:2873);
elseif exptype == 3
    trialstr = "07_18_parsed_set1";
    frames = collect();
end

datadir = joinpath(ENV["HOME"],"liljondir", "kayaks", trialstr)
savedir = joinpath(ENV["HOME"],"liljondir", "kayaks", "rangeOnly_"*trialstr)
chirpFile = joinpath(ENV["HOME"],"liljondir", "kayaks","chirp250.txt");
chirpIn = readdlm(chirpFile,',',Float64,'\n')
range_mf = prepMF(chirpIn,nfft_full,1) # MF

for frameIter in frames
    wavefile = datadir*"/waveform$(frameIter).csv"
    waveData = readdlm(wavefile,',',Float64,'\n');
    mfIn = waveData[element,:];
    range_mfData = zeros(Complex{Float64}, nfft_full, 1)
    range_mf(mfIn,range_mfData) # matched filter
    ranget = [0:8000-500;]*sound_speed/freq_sampling
    writedlm(savedir*"/range$(frameIter).txt", [ranget norm.(range_mfData[1:7501])], ",")

    mykde = kde!(exp.(norm.(range_mfData[1:7501])))
    plkplot = plotKDE(mykde); plkplot |> PDF(savedir*"/range$(frameIter).pdf")
end

# readdlm(savedir*"/range1.txt" , ',')
