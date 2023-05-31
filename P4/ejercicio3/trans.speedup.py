f = open("matrix_mul_times.dat", "r")
x = f.readlines()
with open("out.dat", "w") as fw:
    for line in x:
        dat = line.split(" ")
        q = str(dat[0])+" "+str(round(float(dat[1])/float(dat[2]), 2))+"\n"
        fw.write(q)