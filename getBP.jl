using Caesar
using Gadfly
using MAT, DelimitedFiles, JLD

mydir = "/home/mei/liljondir/kayaks/"
fFloor = 250;
fCeil = 1750;
nFFT_czt = 1024;
fSampling = 37500.0
soundSpeed = 1481;
azimuthDivs = 180;
azimuths = range(0,360,length=azimuthDivs)*pi/180;

exptype = 2

if exptype == 1
    trialstr = "20_gps_pos";
    #55-350
elseif exptype == 2
    trialstr = "08_10_parsed";
    #exp1-1510- 1950
elseif exptype == 3
    trialstr = "07_18_parsed_set1";
    frames = collect();
end

#Load Experimental Data
winstart = 1920;
phonesWindow = [5 7 10 12];
for nPhones in phonesWindow
    # nPhones =10
    rawWaveData = zeros(8000,nPhones);
    arrayElemPos = zeros(nPhones,2);
    for ele in winstart:winstart+nPhones-1
        dataFile = joinpath(ENV["HOME"],"liljondir", "kayaks", trialstr ,"waveform$(ele).csv");
        posFile = joinpath(ENV["HOME"],"liljondir", "kayaks", trialstr ,"nav$(ele).csv");
        tempRead = readdlm(dataFile,',',Float64,'\n') #first element only
        rawWaveData[:,ele-winstart+1] = adjoint(tempRead[1,:]);
        tempRead = readdlm(posFile,',',Float64,'\n');
        arrayElemPos[ele-winstart+1,:] = tempRead;
    end

    # plot(x=arrayElemPos[:,1],y=arrayElemPos[:,2], Geom.path)

    FFTfreqs = collect(LinRange(fFloor,fCeil,nFFT_czt))

    cfg = CBFFilterConfig(fFloor,fCeil,nFFT_czt,nPhones,azimuths,soundSpeed,FFTfreqs)
    myCBF = zeros(Complex{Float64}, getCBFFilter2Dsize(cfg));
    lm = zeros(2,1);
    dataTempHolder = zeros(Complex{Float64},nPhones,nFFT_czt)
    constructCBFFilter2D!(cfg, arrayElemPos, myCBF, lm, dataTempHolder)

    # MF and CZT
    w = exp(-2im*pi*(fCeil-fFloor)/(nFFT_czt*fSampling))
    a = exp(2im*pi*fFloor/fSampling)

    chirpFile = joinpath(ENV["HOME"],"data","sas","chirp250.txt");
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
    CBF2D_DelaySum!(cfg, cztData, dataOut,temp1,temp2,myCBF)

    file = matopen("/tmp/"*trialstr*"_bp$(nPhones)el$(winstart)start.mat", "w")
    write(file, "arrayElemPos", arrayElemPos)
    write(file, "winstart", winstart)
    write(file, "cztData", cztData)
    write(file, "dataOut", dataOut)
    write(file, "azimuths", collect(azimuths))
    close(file)
end
