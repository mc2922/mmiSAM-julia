
using Caesar, DelimitedFiles
using MAT

fFloor = 250;
fCeil = 1750;
nFFT_czt = 1024;
fSampling = 37500.0
nPhones = 10;
soundSpeed = 1481;
azimuthDivs = 180;
azimuths = range(0,360,length=azimuthDivs)*pi/180;

#Load Experimental Data - 10 frames
winstart = 1600;
rawWaveData = zeros(8000,nPhones);
arrayElemPos = zeros(nPhones,2);
trialstr = "08_20_sample";
for ele in winstart:winstart+nPhones-1
    dataFile = joinpath(ENV["HOME"],"liljondir", "kayaks", trialstr ,"waveform$(ele).csv");
    posFile = joinpath(ENV["HOME"],"liljondir", "kayaks", trialstr ,"nav$(ele).csv");
    tempRead = readdlm(dataFile,',',Float64,'\n') #first element only
    rawWaveData[:,ele-winstart+1] = adjoint(tempRead[1,:]);
    tempRead = readdlm(posFile,',',Float64,'\n');
    arrayElemPos[ele-winstart+1,:] = tempRead;
end

FFTfreqs = collect(LinRange(fFloor,fCeil,nFFT_czt))

cfg = CBFFilterConfig(fFloor,fCeil,nFFT_czt,nPhones,azimuths,soundSpeed,FFTfreqs)
myCBF = zeros(Complex{Float64}, getCBFFilter2Dsize(cfg));
lm = zeros(2,1);
dataTempHolder = zeros(Complex{Float64},nPhones,nFFT_czt)
delaysHolder = FFTfreqs;

@time constructCBFFilter2D!(cfg, arrayElemPos, myCBF, lm, dataTempHolder,delaysHolder)

# MF and CZT
w = exp(-2im*pi*(fCeil-fFloor)/(nFFT_czt*fSampling))
a = exp(2im*pi*fFloor/fSampling)

chirpIn = readdlm(chirpFile,',',Float64,'\n')

#Matched Filter on Data In
nFFT_full = nextpow(2,size(rawWaveData,1))  # MF
mfData = zeros(Complex{Float64}, nFFT_full, nPhones)
mf = prepMF(chirpIn,nFFT_full,nPhones) # MF
mf(rawWaveData,mfData) # MF

cztData = zeros(Complex{Float64}, nFFT_czt,nPhones)
filterCZT = prepCZTFilter(nFFT_full,nPhones,w,nFFT_czt,a)
filterCZT(mfData,cztData)

# CBF step
dataOut = zeros(length(azimuths));
temp1 = zeros(Complex{Float64},nFFT_czt);
temp2 = zeros(Complex{Float64},size(cztData));
@time CBF2D_DelaySum!(cfg, cztData, dataOut,temp1,temp2,myCBF)
