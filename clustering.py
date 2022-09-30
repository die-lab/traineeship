import os
import numpy as np

genome_size = 1000
reads_population = 100000
window = 20
n_clusters = 50
reads_dict = []

def build_reads(pos,ref):
    read = ref[int(pos):(int(pos)+int(window))]
    return read

def delete_item(item):
    if os.path.exists(item):
        os.remove(item)
        print("The file " + item + " has been deleted successfully, a new file will replace it")
    else:
        print("The file " + item + " does not exist!, it will be created now")

genome = ''.join(np.random.choice(list('ACGT'), size=genome_size, replace=True))
clusters_startes = np.random.choice(range(1,1000), size=n_clusters, replace=False)

for i in range(int(reads_population/2)):
    start = int(np.random.choice(range(1, 1000), size=1))
    read = build_reads(start, genome)
    reads_dict.append(read)

for i in range(int(reads_population/2)):
    start = np.random.choice(clusters_startes, size=1)
    read = build_reads(start, genome)
    reads_dict.append(read)

np.random.shuffle(reads_dict)


#write fasta file
delete_item("reads_fasta.fa")
with open("reads_fasta.fa", "a") as fasta:
    a = 0
    while a < reads_population :
        fasta.write(">" + str(a) + "\n")
        fasta.write(reads_dict[a] + "\n")
        a += 1
    fasta.close()

#write clusters info
delete_item("clusters_info.txt")
with open("clusters_info.txt", "a") as info :
    info.write("number of clusters:" + str(n_clusters) + "\n" + "\n")
    n = 0
    while n < n_clusters:
        start = clusters_startes[n]
        read = build_reads(start, genome)
        n += 1
        info.write( str(n) + " " + read + "\n" )
    info.close()
