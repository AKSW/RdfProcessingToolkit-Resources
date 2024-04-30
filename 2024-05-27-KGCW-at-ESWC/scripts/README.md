# Script to make plots from KGCW Challenge stats

## Dependencies

- [cpm](https://metacpan.org/pod/App::cpm::Tutorial#How-to-install-cpm)
- `cpm install`

### For drawing the plots

- [LaTeX](https://www.latex-project.org/) distribution, e.g. [TeX Live](https://www.tug.org/texlive/)
- [TikZ](https://github.com/pgf-tikz/pgf)
- [poppler](https://poppler.freedesktop.org/)-tools (RPM) / poppler-utils (DEB) (to create PNGs)


## Copy result data from the challenge-tool

1. [Run challenge](https://github.com/kg-construct/challenge-tool?tab=readme-ov-file#quick-start-kgcw-challenge-2024)
2. [Create results.zip](https://github.com/kg-construct/challenge-tool?tab=readme-ov-file#tutorial-generating-summaries-of-results)
3. Unzip results.zip
4. Move results root into `../data`:
   ```
   mv home/cloud/kg-construct-challenge-tool/downloads/eswc-kgc-challenge-2024 ../data
   ```

## Calculate input data sizes

- `./gather_input_sizes.sh /path/to/downloads/eswc-kgc-challenge-2024 > ../data/input_sizes.txt`

## Calculate (expected) output data size

- Either by copying the tables on https://zenodo.org/records/10973433 manually
- or by downloading the results.tar.gz from that page:
  ```
  mkdir -p results/track2
  cd results/track2
  tar xzf ../../results.tar.gz
  cd ..
  shopt -s globstar
  wc -l **/out.nt > ../../data/triples_count.txt
  ```
- or based on the actual output if your tool works correctly (make sure the paths match up)

## Create plots

- Define plots by editing `make_plots.sh`
- Define the steps your tool uses by editing `steps_config.inc.pl`
- Check the memory usage range using `perl scan_max_mem.pl ../data` and configure `mem_scale.inc` accordingly
- Run
  ```
  ./make_plots.sh
  ```

## Generate PNGs

- `./convert.sh`
  ==> Note the temp folder given in the last line, manually copy the PNG files from there

