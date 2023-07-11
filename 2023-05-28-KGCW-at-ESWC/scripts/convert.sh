# Script to convert the tikz plots in the latex sources into pngs
# Searches for all .tex files in the local folder and creates pngs out of them

HEADER=`cat <<END
\documentclass{standalone}
\usepackage{pgfplots}
\let\fax\relax%
\usepackage{marvosym}
%\usepackage{tikz}
\pgfplotsset{width=9.5cm,compat=1.18}
\begin{document}

END
`

FOOTER=`cat <<END
\end{document}

END
`

DIR=`mktemp -d`
>&2 echo "Created temp dir: $DIR"

for texfile in *.tex; do
  FILENAME=`basename "$texfile"`
  BASENAME="${FILENAME%.*}"
  OUTFILE="$DIR/$FILENAME"
  printf "%s" "$HEADER" > "$OUTFILE"
  cat "$texfile" >> "$OUTFILE"
  printf "%s" "$FOOTER" >> $OUTFILE
 # pdflatex "/tmp/test.txt"
  # (cd "$DIR"; latex "$FILENAME"; dvisvgm "$BASENAME.dvi")
  (cd "$DIR"; pdflatex "$FILENAME"; pdftoppm -png "$BASENAME.pdf" > "$BASENAME.png" )

  # echo "$DIR/$BASENAME"
  #exit 0
done

>&2 echo "Created temp dir: $DIR"
