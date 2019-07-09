
using Caesar
using Pkg
using DelimitedFiles
using MAT, JLD

#chirpFile = joinpath(Pkg.dir("Caesar"),"test","testdata","template.txt");
chirpFile = joinpath(Pkg.dir("Caesar"),"test","testdata","chirp250.txt");
chirpIn = readdlm(chirpFile,',',Float64,'\n')

#logfile = joinpath(Pkg.dir("Caesar"),"test","testdata","wavetest01.txt");
#logfile = joinpath(Pkg.dir("Caesar"),"test","testdata","waveform350.csv");
#logfile = "/home/mei/liljondir/kayaks/08_10_parsed/waveform1525.csv";

nPhones = 5

# 08_10 (drift) Files
#datadir="/home/mei/liljondir/kayaks/08_10_parsed/"
#expdict = load("/home/mei/liljondir/kayaks/08_10_parsed/exp1.jld")
#windowstart = expdict["ibegin"]
#windowend = expdict["iend"]

# 06_20 (dock) Files
# datadir="/home/mei/liljondir/kayaks/20_gps_pos/"
# expdict = load("/home/mei/liljondir/kayaks/08_10_parsed/exp1.jld")
# windowstart = 400;
# windowend = 700;

#Manuvering 07_18 and 07_20 Files
#datadir="/home/mei/liljondir/kayaks/07_18_parsed_set1/"
#datadir="/home/mei/liljondir/kayaks/07_18_parsed_set2/"
#datadir="/home/mei/liljondir/kayaks/07_20_parsed_set1/"
datadir="/home/mei/liljondir/kayaks/07_20_parsed_set2/"
expdict = load(datadir * "exp1.jld")
windowstart = expdict["nrange"][1]
windowend = expdict["nrange"][end]

for wfIndex in windowstart:windowend
    logfile = datadir * "waveform$(wfIndex).csv"
    rawData = readdlm(logfile,',',Float64,'\n')  # waveform timeseries from hydrophone
    rawDataAdj = zeros(Float64,size(rawData,2),size(rawData,1))
    adjoint!(rawDataAdj,rawData) #data x phones

    nFFT = nextpow(2,size(rawDataAdj,1))

    mf = Caesar.prepMF(chirpIn,nFFT,nPhones)
    dataOut = zeros(Complex{Float64}, nFFT, nPhones)
    mf(rawDataAdj,dataOut)

    tmpfile = "/home/mei/tempdata/" * "mfout$(wfIndex).mat";
    file = matopen(tmpfile, "w")
    write(file, "mfout", dataOut)
    close(file)
end

file = matopen("/tmp/mfin350.mat", "w")
write(file, "mfin", rawData)
close(file)

file = matopen("/tmp/chirp.mat", "w")
write(file, "chirp", chirpIn)
close(file)

0

# What are we doing -- to do matched FILTERING
# 1.) A: take fft over all data
# 1b.) OPTIONAL:  A = A./(abs.(A).^p + ε),  p ∈ [0,1] -- normalize mag over all frequency, gives 1's but keeps phase -- PHAT transform
# 2.) B: take fft |> conj! of the replica
# 3.) element wise mutiply: C = A.*B
# 4.) ifft(C) gives correlation in time domain
