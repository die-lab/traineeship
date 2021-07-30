#!/bin/sh
kraken2-build --download-taxonomy --skip-maps --db prokaryotes_190716
kraken2-build --download-library bacteria --db prokaryotes_190716
kraken2-build --download-library archaea --db prokaryotes_190716
kraken2-build --download-library viral --db prokaryotes_190716
kraken2-build --download-library UniVec_Core --db prokaryotes_190716
kraken2-build --build --threads 24 --db prokaryotes_190716
kraken2-build --clean --db prokaryotes_190716
