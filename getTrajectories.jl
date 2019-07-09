
using Gadfly
using MAT, DelimitedFiles, JLD

mydir = "/home/mei/liljondir/kayaks/"

#datadir = "/media/data1/data/kayaks/07_18_parsed/";
# frames = collect(15:425);

# datadir = "/media/data1/data/kayaks/08_10_parsed/";
# frames = collect(1:2873);

exptype = 2

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

datadir = mydir*trialstr;
dataOut = zeros(length(frames),2);
for i in frames
    navfile = datadir*"/nav$(i).csv"
    dataOut[i,:] = readdlm(navfile,',',Float64,'\n')
end

if exptype !=1
    navfile = datadir*"/inav.csv"
    inav = readdlm(navfile,',',Float64,'\n')
end

iout = [];
dict = load(datadir*"/exp1.jld")
push!(iout,dict["icarus_gt"])
load(datadir*"/exp2.jld")
push!(iout,dict["icarus_gt"])
load(datadir*"/exp3.jld")
push!(iout,dict["icarus_gt"])

expwindow = [55;350];

file = matopen("/tmp/"*trialstr*".mat", "w")
write(file, "gps", dataOut)
write(file, "expwindow", expwindow)
if exptype != 1
    write(file, "inav", inav)
    write(file,"iout",iout)
end
close(file)
